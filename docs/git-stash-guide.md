# Git Stash Guide
## Dimension 1: Temporary State Management
### Part of the Omni Git Command Framework

---

## PHILOSOPHY

The stash is a **temporary snapshot buffer** that lives outside your git tree. It allows you to:

- **Suspend work** without committing
- **Switch contexts** cleanly
- **Preserve experiments** without history pollution
- **Manage parallel tracks** on the same branch

Think of it as a "work shelf" where you place incomplete changes, switch to another task, then return and pick up where you left off.

---

## MENTAL MODEL

```
Working Directory (dirty files)
    │
    ├─→ COMMIT (permanent, in history)
    │
    ├─→ STASH (temporary, in buffer)  ← You are here
    │
    └─→ DISCARD (deleted forever)
```

When you `git stash`, your uncommitted changes are:
1. Captured as a snapshot
2. Removed from your working directory (repo is "clean")
3. Stored in a temporary reference
4. Recoverable via `git stash pop` or `git stash apply`

---

## BASIC COMMANDS

### Save Work to Stash

```bash
git stash
```

This is the fastest way. It stashes all tracked files with uncommitted changes.

**With a meaningful message:**
```bash
git stash push -m "WIP: feature X - halfway through refactor"
```

**Stash only specific files:**
```bash
git stash push src/main.ts src/utils.ts -m "save these two files"
```

**Include untracked files (new files not yet added):**
```bash
git stash push -u -m "include untracked files too"
```

### View Stash List

```bash
git stash list
```

Output:
```
stash@{0}: WIP: feature X - halfway through refactor
stash@{1}: On main: quick fix attempt (experimental)
stash@{2}: Saved at Fri May 18 12:30:45 2026 +0000
```

Each stash has:
- **Index** (`stash@{0}`, `stash@{1}`, etc.)
- **Branch** (which branch it was created on)
- **Message** (your annotation)
- **Timestamp** (when it was stashed)

### Restore Stash

**Pop (restore and remove):**
```bash
git stash pop
```
Takes the most recent stash (`stash@{0}`), applies it to your working directory, and deletes it.

**Apply (restore and keep):**
```bash
git stash apply
```
Same as pop, but the stash remains in the list (safe if you want to apply it multiple places).

**Restore specific stash:**
```bash
git stash apply stash@{2}
git stash pop stash@{2}
```

### Inspect Stash Without Applying

**View contents (diff):**
```bash
git stash show
```

Shows summary of changes in most recent stash:
```
 src/main.ts    | 15 ++++++++++-----
 src/utils.ts   |  3 +--
 2 files changed, 11 insertions(+), 7 deletions(-)
```

**View full diff:**
```bash
git stash show -p
git stash show -p stash@{2}
```

Outputs the exact changes (lines added/removed).

**Compare stash to current HEAD:**
```bash
git diff HEAD stash@{0}
```

### Delete Stash

**Drop most recent:**
```bash
git stash drop
```

**Drop specific stash:**
```bash
git stash drop stash@{2}
```

**Clear all stashes:**
```bash
git stash clear
```

⚠️ This is permanent (no reflog recovery).

---

## INTERMEDIATE WORKFLOWS

### Workflow 1: Switch Context Without Committing

**Scenario:** You're working on feature X on branch `main`. An urgent hotfix arrives.

```bash
# Status: main has uncommitted changes
git status
# Changes not staged for commit: (lots of edits)

# Step 1: Stash your work
git stash push -m "feature X: halfway done, do not lose"

# Step 2: Verify repo is clean
git status
# nothing to commit, working tree clean

# Step 3: Create and switch to hotfix branch
git checkout -b hotfix/urgent-bug

# Step 4: Fix the bug and commit
git commit -m "hotfix: critical security bug"
git push origin hotfix/urgent-bug

# Step 5: Return to main
git checkout main

# Step 6: Restore your work
git stash pop

# Step 7: Continue editing (pick up where you left off)
```

**Euclidean Distance:** 0.1 (very low risk, fully reversible)

---

### Workflow 2: Apply Stash to Different Branch

**Scenario:** You stashed on branch A, but realized you wanted to work on branch B.

```bash
# Current state: stashed on main, need to apply to feature/new-work

# Step 1: Switch to target branch
git checkout feature/new-work

# Step 2: Apply the stash from main
git stash apply stash@{0}

# Step 3: Verify changes applied
git status

# Step 4: If conflicts, resolve manually
git add resolved.ts
git commit -m "merge stashed work into feature"

# Step 5: (Optional) Return to main and drop stash
git checkout main
git stash drop
```

**Euclidean Distance:** 0.25 (low risk if no conflicts)

---

### Workflow 3: Selective Stashing (Ignore Some Files)

**Scenario:** You have edits to 5 files, but only want to stash 2.

```bash
# Current state: 5 files modified, you want to keep 3 unstaged

# Option A: Stash specific files
git stash push src/app.ts src/main.ts -m "save these two"

# Remaining: src/utils.ts, src/config.ts, src/index.ts still dirty

# Option B: Alternative - stage what you want to keep, stash the rest
git add src/utils.ts src/config.ts src/index.ts  # Stage keepers
git stash --keep-index -m "save only untracked changes"

# Result: keepers remain in working dir, others stashed
```

---

### Workflow 4: Stash and Create New Branch

**Scenario:** You made changes that deserve their own branch, not committed to main yet.

```bash
# Current state: main is dirty with 10 edits

# Step 1: Create new branch FROM current HEAD (takes the edits with it)
git checkout -b feature/my-work

# Step 2: Check status
git status
# Changes not staged for commit: (your 10 edits still here)

# Step 3: Commit the work
git commit -a -m "feature: my work"

# Or, if you want to stash first and commit selectively:
git stash
git checkout main       # Verify main is clean
git checkout feature/my-work
git stash pop
git commit -a -m "feature: my work"
```

**Euclidean Distance:** 0.15 (low risk)

---

### Workflow 5: Multiple Stashes - Complex Parallel Work

**Scenario:** You're juggling 3 features, each with 2-3 stashes.

```bash
# Create a tracking system (pseudocode - you maintain manually)

# STASH 1: Feature X rough draft
git stash push -m "feature/X: design phase, do not commit yet"
# Result: stash@{0}

# (Switch and work on something else)
# ... edit different files ...

# STASH 2: Feature Y experiment
git stash push -m "feature/Y: trying new approach, keep as backup"
# Result: stash@{0}  (old stash now @{1})

# STASH 3: Hotfix (related but different)
git stash push -m "hotfix: quick fix, commit ASAP"
# Result: stash@{0}  (old stashes now @{1} and @{2})

# Now list all
git stash list
# stash@{0}: On main: hotfix: quick fix, commit ASAP
# stash@{1}: On main: feature/Y: trying new approach, keep as backup
# stash@{2}: On main: feature/X: design phase, do not commit yet

# Apply specific stash when needed
git stash apply stash@{2}  # Restore feature X
```

**Best Practice:** Always use `-m` (message) with stash. Future-you will be grateful.

---

## ADVANCED PATTERNS

### Pattern 1: Stash Before Every Branch Switch

```bash
# Safer workflow: always clean before switching
git stash push -m "before switching to $(git rev-parse --abbrev-ref HEAD)"
git checkout other-branch
# ... work ...
git checkout -
git stash pop  # Resume original work
```

### Pattern 2: Combine Stash with Interactive Rebase

```bash
# Stash current work
git stash push -m "WIP before rebase"

# Perform interactive rebase
git rebase -i HEAD~5

# If rebase succeeds:
git stash drop   # No longer needed

# If rebase fails:
git rebase --abort
git stash pop    # Resume work and retry
```

### Pattern 3: Stash Staging Area Only (not working dir)

```bash
# You have staged changes you want to save, but keep working dir dirty
git stash push --keep-index -m "save staged changes only"

# Now working dir is dirty again, but staged changes are safe in stash
```

---

## CONFLICT HANDLING

### Scenario: Stash Conflicts on Pop

```bash
# You stashed on commit A
git stash push -m "work on A"

# But meantime, someone else committed to B (changed same files)
git pull   # Now at commit B
git stash pop
# CONFLICT: stash conflicts with local changes
```

**Resolution:**
```bash
# Step 1: See what conflicted
git status

# Step 2: Manually resolve (your editor)
# Edit files, resolve <<<< ==== >>>> markers

# Step 3: Mark resolved
git add resolved-file.ts

# Step 4: Complete the stash pop by committing
git commit -m "merge stashed work with recent changes"

# Result: stash is removed, conflicts resolved, history intact
```

---

## TROUBLESHOOTING

### "I can't find my stash!"

```bash
# Find it
git stash list

# Still can't find it? Check reflog
git reflog show stash

# Example output:
# 3c9c8f2 refs/stash@{0}: WIP on main: abc1234 last commit
# 4f9d8e3 refs/stash@{1}: WIP on main: def5678 previous commit
```

### "I accidentally dropped a stash!"

```bash
# Git doesn't garbage collect reflog entries immediately
git reflog show stash

# Find the SHA of your lost stash
git show <SHA>

# Restore it
git stash apply <SHA>

# Or commit it directly
git commit -m "recovered stash" -- <files>
```

### "Stash apply created conflicts"

```bash
# Verify conflicts
git status

# Resolve manually in your editor
git add resolved.ts

# Continue with commit
git commit -m "merge stashed changes, resolved conflicts"
```

---

## STASH VS ALTERNATIVES

| Scenario | Use Stash? | Alternative |
|----------|-----------|-------------|
| Temporarily save to switch branches | ✓ YES | git commit + git reset (more complex) |
| Permanent save | ✗ NO | git commit (commit to history) |
| Save multiple versions of same file | ✓ YES | Multiple stashes with messages |
| Save for later reference | ⚠ Maybe | git branch instead (clearer intent) |
| Undo committed code | ✗ NO | git revert or git reset |

---

## BEST PRACTICES (SOMA INTEGRATION)

**1. Always use messages**
```bash
git stash push -m "feature X: describe what this is"
# NOT just: git stash
```

**2. Stash frequently when switching contexts**
```bash
# Before switching branches, stash
git stash
git checkout other-branch
```

**3. Use stash as temporary only**
- Stash is not a backup system
- If you care about it, commit it
- Stash can be garbage collected (though rare)

**4. Name stashes like you'd name branches**
```bash
# Good:
git stash push -m "feature/auth: halfway through JWT implementation"

# Bad:
git stash push -m "stuff"
```

**5. Combine with reflog for safety**
```bash
# If you're doing risky operations:
git branch backup                # Create backup first
git stash clear
git reflog                       # Can recover from reflog
```

---

## EUCLIDEAN DISTANCE SCORING

**Stash operations always score low risk:**

| Operation | Distance | Recovery |
|-----------|----------|----------|
| `git stash` | 0.0 | Fully reversible |
| `git stash pop` | 0.05 | Fully reversible |
| `git stash apply` | 0.05 | Fully reversible |
| `git stash drop` | 0.1 | Recoverable via reflog |
| `git stash clear` | 0.3 | Recoverable via reflog (time-dependent) |

**Why so low?** Stash never modifies history, always reversible, rarely loses data.

