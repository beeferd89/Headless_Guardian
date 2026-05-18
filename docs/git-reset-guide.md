# Git Reset Guide
## Dimension 4: State Restoration
### Part of the Omni Git Command Framework

---

## PHILOSOPHY

Reset is the **most powerful and dangerous** git command. It moves your HEAD pointer and manipulates the staging area and working directory.

Three modes:
- **--soft**: Move HEAD only (safe)
- **--mixed**: Move HEAD + unstage changes (medium)
- **--hard**: Move HEAD + discard changes (DESTRUCTIVE)

Think of it as "rewind time in your repository" — but only you see the rewind. Everyone else is still in the future.

---

## MENTAL MODEL

```
Working Directory    Staging Area    Repository (HEAD)
─────────────────    ────────────    ────────────────
modified files   ←→  staged files  ←→  committed history

git reset --soft:    Move HEAD only
  Repository rewinds, Staging stays, Working dir unchanged

git reset --mixed:   Move HEAD + unstage  
  Repository rewinds, Staging unstaged, Working dir has changes

git reset --hard:    Move HEAD + discard everything
  Repository rewinds, Staging cleared, Working dir cleared
  ⚠️ DESTRUCTIVE: Changes are LOST
```

---

## BASIC COMMANDS

### Unstage a File (--mixed, implicit)

```bash
git reset HEAD src/main.ts
```

Takes `src/main.ts` out of the staging area but keeps it modified in your working directory.

**Equivalently:**
```bash
git reset --mixed HEAD src/main.ts
```

### Undo Last Commit, Keep Changes (--soft)

```bash
git reset --soft HEAD~1
```

Moves HEAD back 1 commit, but:
- Your changes remain staged
- You can re-commit with a different message
- Zero data loss

**Use case:**
```bash
# You committed "WIP: feature X"
git reset --soft HEAD~1
# Changes are still staged, ready to recommit
git commit -m "feature: complete feature X with full description"
```

### Undo Last Commit, Changes to Working Dir (--mixed)

```bash
git reset --mixed HEAD~1
# or just:
git reset HEAD~1
```

Moves HEAD back 1 commit, and:
- Your changes are unstaged (in working directory)
- You can review before re-committing
- Still zero data loss

---

### Undo Last Commit, DISCARD Changes (--hard)

```bash
git reset --hard HEAD~1
```

Moves HEAD back 1 commit, and:
- **ALL changes are deleted**
- Working directory is clean
- Staging area is cleared
- **CANNOT BE UNDONE** (without reflog)

⚠️ **Only use if you're 100% sure you don't want the changes.**

---

## INTERMEDIATE WORKFLOWS

### Workflow 1: Unstage Multiple Files

**Scenario:** You staged 5 files but only want to commit 2.

```bash
# Current state: 5 files staged
git status
# Changes to be committed:
#   new file: file1.ts
#   new file: file2.ts
#   modified: file3.ts
#   modified: file4.ts
#   modified: file5.ts

# Unstage the ones you don't want
git reset HEAD file3.ts file4.ts file5.ts

# Status now shows:
# Changes to be committed: (file1, file2)
# Changes not staged: (file3, file4, file5)

# Commit only the staged ones
git commit -m "feature: add new files"

# Commit the others separately later
git add file3.ts
git commit -m "refactor: update file3"
```

---

### Workflow 2: Undo Multiple Commits, Keep Work

**Scenario:** You made 3 commits that should be 1 squashed commit.

```bash
# Current history:
git log --oneline
# C: part 3
# B: part 2
# A: part 1
# X: (older commit)

# Undo the 3 commits, keep changes staged
git reset --soft HEAD~3

# All changes from A, B, C are now staged
git status
# Changes to be committed: (all the code from 3 commits)

# Recommit as one
git commit -m "feature: complete implementation of feature X"
```

---

### Workflow 3: Move Commits to Different Branch

**Scenario:** You committed on `main` but the work belongs on `feature/new-work`.

```bash
# Current state: main has 3 extra commits
git log --oneline main
# C: feature work
# B: feature work  
# A: feature work
# X: (should be here)
# Y: (main baseline)

# Step 1: Create new branch at current HEAD
git checkout -b feature/new-work

# Step 2: Go back to main
git checkout main

# Step 3: Reset main to remove the 3 commits
git reset --hard HEAD~3

# Result:
# main is now clean (back to Y)
# feature/new-work has C, B, A
```

---

### Workflow 4: Recover From Bad Reset (Using Reflog)

**Scenario:** You did `git reset --hard HEAD~5` and regretted it.

```bash
# Check reflog to see what was lost
git reflog

# Output:
# abc123 HEAD@{0}: reset: moving to HEAD~5
# def456 HEAD@{1}: commit: feature: something
# ghi789 HEAD@{2}: commit: feature: else
# jkl012 HEAD@{3}: (earlier)

# The commit you want is def456 (HEAD@{1})
git reset --hard def456

# Or use the SHA directly
git reset --hard abc123
```

**Note:** Reflog expires after ~90 days. If it's gone, the commits are unrecoverable.

---

## ADVANCED PATTERNS

### Pattern 1: Reset to Specific Commit (Anywhere in History)

```bash
# Reset to commit abc123 (which is 10 commits back)
git reset --hard abc123

# All commits after abc123 are undone
# Your working directory is at abc123
```

### Pattern 2: Reset Index Only (Keep Working Dir)

```bash
# Unstage everything but keep working directory changes
git reset

# Equivalent to:
git reset HEAD
```

### Pattern 3: Partial Reset (Specific File at Specific Commit)

```bash
# Reset src/main.ts to how it was 3 commits ago
git reset HEAD~3 src/main.ts

# Only src/main.ts is affected; other files untouched
```

---

## RESET MODES DETAILED

### Mode 1: --soft (Safest)

```bash
git reset --soft HEAD~1

# Tree changes: Move HEAD back 1
# Index changes: None (staging area unchanged)
# Working dir: None
# Data loss: Zero
```

**Use when:** You want to redo a commit's message or split it up.

### Mode 2: --mixed (Default, Moderate)

```bash
git reset HEAD~1
# or explicitly:
git reset --mixed HEAD~1

# Tree changes: Move HEAD back 1
# Index changes: Files unstaged
# Working dir: Files with uncommitted changes
# Data loss: Zero (changes still exist in working dir)
```

**Use when:** You want to undo a commit and reconsider what to commit.

### Mode 3: --hard (Destructive)

```bash
git reset --hard HEAD~1

# Tree changes: Move HEAD back 1
# Index changes: Cleared
# Working dir: DELETED
# Data loss: Everything since HEAD~1
```

**Use when:** You're 100% sure you don't want any of the changes.

---

## RESET VS OTHER COMMANDS

| Scenario | Command | Is History Rewritten? | Is Working Dir Safe? | Public Branch? |
|----------|---------|----------------------|----------------------|--|
| Undo commit, keep history | revert | No | Yes | ✓ YES |
| Undo commit, erase history | reset | Yes | Depends on flag | ✗ NO |
| Copy commit elsewhere | cherry-pick | No | Yes | ✓ YES |
| Move branches back | reset | Yes | Depends on flag | ✗ NO |

---

## SAFETY MECHANISMS

### Before Destructive Reset: Create Backup

```bash
# Always backup when doing --hard
git branch backup/before-reset

# Do the reset
git reset --hard HEAD~3

# If something went wrong:
git reset --hard backup/before-reset
```

### Use Reflog as Emergency Recovery

```bash
# Something went wrong
git reflog

# Find the SHA of the state you want
git reset --hard <SHA>
```

### Staged Changes: Always Stage Before Resetting

```bash
# If you have uncommitted work, stash it
git stash

# Or commit it to a temporary branch
git checkout -b temp-work
git checkout -

# Then reset safely
```

---

## EUCLIDEAN DISTANCE SCORING

| Operation | Distance | Safety | Recovery |
|-----------|----------|--------|----------|
| `git reset HEAD <file>` | 0.05 | ✓ Safe | File unchanged, just unstaged |
| `git reset --soft HEAD~1` | 0.10 | ✓ Safe | Changes staged, can recommit |
| `git reset --mixed HEAD~1` | 0.20 | ✓ Safe | Changes in working dir |
| `git reset --hard HEAD~1` | 0.60 | ⚠ Medium | Reflog recovery possible |
| `git reset --hard HEAD~5` | 0.75 | ⚠ High | Risky, reflog needed |
| `git push --force` after reset | 0.95 | 🔴 CRITICAL | Breaks for other developers |

**Key:** --hard without --force is recoverable. --hard with --force on shared branch is catastrophic.

---

## BEST PRACTICES (SOMA INTEGRATION)

**1. Never --hard reset on shared branches**
```bash
# ✗ BAD (will break everything):
git reset --hard HEAD~1
git push --force

# ✓ GOOD (use revert):
git revert HEAD~1
git push
```

**2. Always backup before --hard**
```bash
git branch backup-$(date +%s)
git reset --hard HEAD~N
```

**3. Use --soft for commit amendments**
```bash
git reset --soft HEAD~1  # Fix message, redo commit
git commit -m "corrected message"
```

**4. Use --mixed for review before recommit**
```bash
git reset HEAD~1         # Review what you're about to recommit
git diff                 # See all changes
git add file1.ts         # Stage selectively
git commit -m "split into logical commits"
```

**5. Combine with Soma workflow for complex operations**
```swift
let engine = OmniGitEngine()
let plan = await engine.planCruxWorkflow(
    moveCommitsToBranch: 3,
    fromBranch: "main",
    toBranch: "feature/new-work"
)
// This uses reset internally with safety checks
```

---

## TROUBLESHOOTING

### "I did --hard reset and lost commits!"

```bash
# Check reflog immediately
git reflog

# Find the commit SHA
# Restore:
git reset --hard <SHA>
```

### "I reset --hard, pushed --force, and broke the team's work"

1. Check with team: Do they have commits locally?
2. If yes: Have them check `git reflog`
3. If no: It's a crisis. Consider reverting the force-push in git hosting.

### "I want to undo a reset"

```bash
# As long as it's recent, reflog has it
git reflog
git reset --hard <original-SHA>

# If reflog is expired (~90 days), commits are lost
```

---

## REAL-WORLD EXAMPLE: Fixing a Commit Message

```bash
# You committed with wrong message
git log --oneline
# A: "wip: feature X"  ← Wrong message
# B: (previous commit)

# Fix it:
git reset --soft HEAD~1

# Changes from A are now staged
git status
# Changes to be committed: (all code from A)

# Recommit with correct message
git commit -m "feature: implement feature X with full description"

# Result: Commit is re-done with better message
```

---

## REAL-WORLD EXAMPLE: Unstaging Accidental Commit

```bash
# You ran: git add . && git commit -m "temp"
# But you weren't ready

git reset --mixed HEAD~1

# Changes are back in working dir (unstaged)
git status
# Changes not staged for commit: (everything)

# Now carefully select what to commit
git add src/core-feature.ts
git commit -m "feature: core work"

git add tests/
git commit -m "tests: add test suite"

# Result: Properly organized commits instead of one "temp" commit
```

