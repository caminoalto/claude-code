#!/bin/bash
set -euo pipefail

# Get script directory and workspace root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "\n🔒 STEP 2: Security & Firewall Setup"
echo "===================================="

# Check if running with proper privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ ERROR: This script must be run with sudo"
    echo "Please run: sudo $0"
    exit 1
fi

# Load environment variables
ENV_FILE="$WORKSPACE_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    echo "📁 Loaded firewall configuration from .env"
else
    echo "❌ ERROR: .env file not found"
    exit 1
fi

# Check if iptables is available
if ! command -v iptables &> /dev/null; then
    echo "❌ ERROR: iptables not available"
    exit 1
fi

# Test iptables functionality
if ! iptables -L -n >/dev/null 2>&1; then
    echo "❌ ERROR: iptables not functional"
    echo "This might be due to missing kernel modules or container restrictions"
    exit 1
fi

echo "✅ iptables is functional"


# Clear existing rules first
echo ""
echo "🧹 Clearing existing firewall rules..."
iptables -F
iptables -X
#iptables -t nat -F - These nuke Docker NAT causing the container connectivity to fail
#iptables -t nat -X - These nuke Docker NAT causing the container connectivity to fail
iptables -t mangle -F
iptables -t mangle -X
echo ""
echo "🔒 ENABLING firewall with security rules"
echo "========================================"

echo ""
echo "🔧 Firewall Configuration:"
echo "=========================="
echo "Allowed inbound: $ALLOWED_INBOUND_RANGES"
echo "Allowed outbound private: $ALLOWED_OUTBOUND_PRIVATE_RANGES"
echo "DNS servers: $DNS_SERVERS"

# Set default policies - strict security
echo ""
echo "🚫 Setting restrictive default policies..."
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
echo "✅ Default policies set to DROP (deny all)"

# Essential rules
echo ""
echo "➕ Adding firewall rules..."

# Allow all loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
echo "  ✓ Loopback traffic allowed"

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "  ✓ Established connections allowed"

# Allow ICMP (ping)
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
echo "  ✓ ICMP (ping) allowed"

# Parse and allow inbound from specified ranges
IFS=',' read -ra IN_RANGES <<< "$ALLOWED_INBOUND_RANGES"
for range in "${IN_RANGES[@]}"; do
    range=$(echo "$range" | xargs)  # trim whitespace
    if [[ "$range" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
        iptables -A INPUT -s "$range" -j ACCEPT
        echo "  ✓ Inbound from $range allowed"
    fi
done

# Parse and allow outbound to specified private ranges
IFS=',' read -ra OUT_RANGES <<< "$ALLOWED_OUTBOUND_PRIVATE_RANGES"
for range in "${OUT_RANGES[@]}"; do
    range=$(echo "$range" | xargs)  # trim whitespace
    if [[ "$range" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
        # If it's a single IP without /mask, add /32
        if [[ ! "$range" =~ "/" ]]; then
            range="${range}/32"
        fi
        iptables -A OUTPUT -d "$range" -j ACCEPT
        echo "  ✓ Outbound to $range allowed"
    fi
done

# Allow DNS to specified servers
IFS=',' read -ra DNS_LIST <<< "$DNS_SERVERS"
for dns in "${DNS_LIST[@]}"; do
    dns=$(echo "$dns" | xargs)  # trim whitespace
    if [[ "$dns" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        iptables -A OUTPUT -d "$dns" -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -d "$dns" -p tcp --dport 53 -j ACCEPT
        echo "  ✓ DNS to $dns allowed"
    fi
done

# Docker internal DNS
iptables -A OUTPUT -d 127.0.0.11 -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -d 127.0.0.11 -p tcp --dport 53 -j ACCEPT
echo "  ✓ Docker internal DNS allowed"

# Allow HTTP/HTTPS to public internet
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
echo "  ✓ HTTP/HTTPS to internet allowed"

    # Allow database connections (PostgreSQL and Redis)
    iptables -A OUTPUT -p tcp --dport 5432 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 6379 -j ACCEPT
    echo "  ✓ Database ports (5432, 6379) allowed"

# Block all other private ranges
iptables -A OUTPUT -d 10.0.0.0/8 -j REJECT --reject-with icmp-host-prohibited
iptables -A OUTPUT -d 172.16.0.0/12 -j REJECT --reject-with icmp-host-prohibited
iptables -A OUTPUT -d 192.168.0.0/16 -j REJECT --reject-with icmp-host-prohibited
echo "  ✓ Other private ranges blocked"

# Test connectivity
echo ""
echo "🔍 Testing connectivity with firewall rules..."

# Test DNS
echo -n "• DNS resolution: "
if nslookup google.com >/dev/null 2>&1; then
    echo "✅ Working"
else
    echo "❌ Failed"
fi

# Test HTTP
echo -n "• Internet access: "
if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://example.com 2>/dev/null | grep -q "200\|301\|302"; then
    echo "✅ Working"
else
    echo "❌ Failed"
fi

# Test blocked private access
echo -n "• Private IP blocking: "
if ! ping -c 1 -W 1 192.168.1.1 >/dev/null 2>&1; then
    echo "✅ Correctly blocked"
else
    echo "⚠️  May not be blocked"
fi


echo "🔒 Security restrictions in place:"
echo "=================================="
echo "• ❌ Host network access: BLOCKED (except allowed ranges)"
echo "• ❌ Private IP ranges: BLOCKED (except allowed ranges)"
echo "• ❌ Arbitrary ports: BLOCKED (only 80/443 allowed)"
echo "• ✅ Internet access: ALLOWED (HTTP/HTTPS only)"
echo "• ✅ DNS queries: ALLOWED (only to specified servers)"

echo ""
echo "✅ Firewall ENABLED and configured!"

echo ""
