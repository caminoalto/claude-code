# Smart Batch Commit Prompt for Claude Code

Generate multiple meaningful commits by analyzing and grouping related changes.

## Instructions

1. **Analyze Repository State**
   - Run `git status` to see all untracked files and modifications
   - Run `git diff` to see both staged and unstaged changes  
   - Run `git log --oneline -10` to understand recent commit message style

2. **Group Changes by Logic**
   - Group related files into logical commit batches based on:
     - **Feature additions** (new functionality, new files for same feature)
     - **Bug fixes** (corrections, error handling improvements)
     - **Refactoring** (code restructuring, cleanup, optimization)
     - **Documentation** (README, comments, guides)
     - **Configuration** (settings, environment, build files)
     - **Tests** (test files, test data, validation)
     - **Dependencies** (package updates, requirement changes)

3. **Create Commits in Logical Order**
   - Start with foundational changes (configs, dependencies)
   - Then core functionality changes
   - Follow with tests and documentation
   - End with cleanup/refactoring

4. **For Each Commit Batch**
   - Add only the relevant files with `git add <specific-files>`
   - Create a concise commit message that:
     - Uses imperative mood (e.g., "Add", "Fix", "Update")
     - Summarizes the batch purpose clearly
     - Focuses on "why" rather than "what"
     - Follows existing commit style from history
   - Include the standard Claude Code footer

## Example Grouping

```
Batch 1 (Config): ansible.cfg, inventory.yml, group_vars/
Batch 2 (Core): roles/new_feature/, playbooks/new_playbook.yml  
Batch 3 (Docs): README.md, docs/new_guide.md
Batch 4 (Tests): test files, validation scripts
```

## Notes

- Creates multiple focused commits instead of one large commit
- Each commit should represent a complete, logical unit of work
- Maintains clean git history for better collaboration and debugging
- Review each batch carefully before committing