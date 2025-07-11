#!/bin/bash
set -euo pipefail

# Configurable parameters
ALLOWED_INBOUND_RANGES="${ALLOWED_INBOUND_RANGES:-192.168.32.0/24,10.9.0.0/16}"
ALLOWED_OUTBOUND_PRIVATE_RANGES="${ALLOWED_OUTBOUND_PRIVATE_RANGES:-10.0.0.0/8,192.168.24.0/23}"
DNS_SERVERS="${DNS_SERVERS:-192.168.16.1}"  # Can override with your DNS servers

echo "Firewall Configuration:"
echo "  Allowed inbound ranges: $ALLOWED_INBOUND_RANGES"
echo "  Allowed outbound private ranges: $ALLOWED_OUTBOUND_PRIVATE_RANGES"
echo "  Additional DNS servers: $DNS_SERVERS"
echo ""

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# INBOUND RULES - Allow from specified networks
IFS=',' read -ra INBOUND_RANGES <<< "$ALLOWED_INBOUND_RANGES"
for range in "${INBOUND_RANGES[@]}"; do
    range=$(echo "$range" | xargs)  # Trim whitespace
    echo "Adding inbound rule for: $range"
    iptables -A INPUT -s "$range" -j ACCEPT
done

# Auto-detect host network (Docker VM's bridge network)
HOST_IP=$(ip route | grep default | cut -d" " -f3)
if [ -n "$HOST_IP" ]; then
    HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
    echo "Docker host network detected as: $HOST_NETWORK"
    iptables -A INPUT -s "$HOST_NETWORK" -j ACCEPT
fi

# OUTBOUND RULES - Block private IPs except allowed ranges
# First, allow outbound to specified private ranges
IFS=',' read -ra OUTBOUND_RANGES <<< "$ALLOWED_OUTBOUND_PRIVATE_RANGES"
for range in "${OUTBOUND_RANGES[@]}"; do
    range=$(echo "$range" | xargs)  # Trim whitespace
    echo "Adding outbound rule for private range: $range"
    iptables -A OUTPUT -d "$range" -j ACCEPT
done

# Allow outbound to Docker host network (needed for DNS, etc)
if [ -n "$HOST_NETWORK" ]; then
    echo "Adding outbound rule for host network: $HOST_NETWORK"
    iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT
fi

# Allow DNS servers from /etc/resolv.conf
RESOLV_DNS=$(grep ^nameserver /etc/resolv.conf | awk '{print $2}')
for dns in $RESOLV_DNS; do
    echo "Adding outbound rule for DNS server (from resolv.conf): $dns"
    iptables -A OUTPUT -d "$dns" -j ACCEPT
done

# Also allow configured DNS servers
IFS=',' read -ra CONFIGURED_DNS <<< "$DNS_SERVERS"
for dns in "${CONFIGURED_DNS[@]}"; do
    dns=$(echo "$dns" | xargs)  # Trim whitespace
    echo "Adding outbound rule for DNS server (configured): $dns"
    iptables -A OUTPUT -d "$dns" -j ACCEPT
done

# Then block ALL private ranges
# Note: ACCEPT rules above take precedence due to order
echo "Blocking outbound to all private ranges..."
iptables -A OUTPUT -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -d 169.254.0.0/16 -j DROP  # Link-local

# All other outbound (public IPs) is allowed by default policy

# Set default policies
iptables -P INPUT DROP        # Drop all other inbound
iptables -P FORWARD DROP      # No forwarding
iptables -P OUTPUT ACCEPT     # Allow public IP outbound

echo ""
echo "Firewall rules applied:"
echo "✓ Inbound: Only from $ALLOWED_INBOUND_RANGES and host network"
echo "✓ Outbound to private IPs: Only to $ALLOWED_OUTBOUND_PRIVATE_RANGES and host network"
echo "✓ Outbound to public IPs: Allowed"
echo "✗ All other private IP ranges: Blocked"

# Show current rules
echo ""
echo "Current OUTPUT rules (first 15):"
iptables -L OUTPUT -n -v --line-numbers | head -15

# Verify outbound access
echo ""
echo "Testing connectivity..."

# Test DNS resolution first
if nslookup google.com >/dev/null 2>&1; then
    echo "✅ DNS resolution working"
else
    echo "❌ DNS resolution failed - checking DNS server..."
    cat /etc/resolv.conf | grep nameserver
fi

# Test internet connectivity
if curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
    echo "✅ Internet access verified"
else
    echo "❌ Internet access failed"
    # Try with a direct IP to see if it's a DNS issue
    if curl --connect-timeout 5 https://1.1.1.1 >/dev/null 2>&1; then
        echo "   Direct IP access works - this is a DNS issue"
    else
        echo "   Direct IP access also failed"
    fi
fi

# Test if we can reach allowed private ranges (may fail if not routable)
for range in "${OUTBOUND_RANGES[@]}"; do
    # Extract first IP from range for testing
    test_ip=$(echo "$range" | cut -d'/' -f1 | sed 's/0$/1/')
    if ping -c 1 -W 1 "$test_ip" >/dev/null 2>&1; then
        echo "✅ Private range $range appears reachable"
    else
        echo "ℹ️  Private range $range not responding (may be normal)"
    fi
done