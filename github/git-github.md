# Git & GitHub for DevOps

A practical guide: install Git on Ubuntu/Linux, configure it, create a repo, push to GitHub, and authenticate with a token or SSH key.

---

## 1. Install Git (Ubuntu / Debian)

```bash
sudo apt update          # refresh the package index
sudo apt install git -y  # install git (-y = answer "yes" automatically)
git --version            # verify the installation
```

> `apt` = **Advanced Package Tool**, the package manager for Ubuntu/Debian.
> For other distros: `sudo dnf install git` (Fedora/RHEL) or `sudo pacman -S git` (Arch).

---

## 2. Configure Git (one-time setup)

Set your identity. It is attached to every commit you make.

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Optional but recommended:

```bash
git config --global init.defaultBranch main   # use "main" instead of "master"
git config --global core.editor "nano"        # or vim / code --wait
git config --list                             # view all settings
```

---

## 3. Create a Local Repository

```bash
mkdir devops-testing && cd devops-testing   # create and enter a project folder
git init                                    # initialize a git repo (creates .git/)
echo "# DevOps Testing" > README.md         # create a file
```

---

## 4. Create a Remote Repository on GitHub

1. Go to [github.com](https://github.com) and click **New repository**.
2. Name it (e.g. `devops-testing`) and choose Public or Private.
3. Do **not** add a README if you already have one locally (avoids merge conflicts).
4. Copy the repository URL (HTTPS or SSH).

---

## 5. Core Workflow: add, commit, push

```bash
git status                       # see changed / untracked files
git add README.md                # stage one file
git add .                        # stage everything in the folder
git commit -m "Initial commit"   # save a snapshot with a message
git branch -M main               # rename current branch to main
git remote add origin https://github.com/thealamdev/devops-testing.git
git push -u origin main          # push and set upstream (first time)
```

After the first push, `git push` alone is enough.

### Workflow overview

```
Working Directory --(git add)--> Staging Area --(git commit)--> Local Repo --(git push)--> GitHub
```

---

## 6. Authentication Option A: Personal Access Token (HTTPS)

When pushing over HTTPS, GitHub asks for a **username** and a **token** (passwords are no longer accepted).

### Generate a token

`GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token`

- Select the **repo** scope.
- Set an expiration date.
- Copy the token immediately; it is shown only once.

### Save credentials so Git does not ask every time

**Method 1: Embed in the remote URL (simple, but less secure)**

```bash
git remote set-url origin https://USERNAME:TOKEN@github.com/thealamdev/devops-testing.git
```

This is the same as editing `.git/config` and putting `USERNAME:TOKEN@` before `github.com`:

```ini
[remote "origin"]
    url = https://USERNAME:TOKEN@github.com/thealamdev/devops-testing.git
```

> ⚠️ **Security warning:** the token is stored in plain text in `.git/config`. Never commit or share that file, and avoid this on shared machines.

**Method 2: Git credential helper (better)**

```bash
git config --global credential.helper store         # saves in ~/.git-credentials (plain text)
git config --global credential.helper 'cache --timeout=3600'   # keep in memory for 1 hour
```

---

## 7. Authentication Option B: SSH Key (recommended)

SSH keys avoid tokens and passwords entirely and are the standard for servers and CI machines.

### Step 1: Generate the key pair

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

- Note: the comment flag is **capital `-C`**, not `-c`.
- Press Enter to accept the default path (`~/.ssh/id_ed25519`).
- Optionally set a passphrase for extra security.

This creates two files in `~/.ssh/`:

| File | Type | Share it? |
|------|------|-----------|
| `id_ed25519` | **Private key** | Never share |
| `id_ed25519.pub` | **Public key** | Add to GitHub |

### Step 2: Add the public key to GitHub

```bash
cat ~/.ssh/id_ed25519.pub     # copy the entire output
```

`GitHub → Settings → SSH and GPG keys → New SSH key` → paste the key → Save.

### Step 3: Start the agent and load the key (if you used a passphrase)

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Step 4: Test the connection

```bash
ssh -T git@github.com
# Expected: "Hi <username>! You've successfully authenticated..."
```

### Step 5: Switch the remote URL to SSH

```bash
git remote set-url origin git@github.com:thealamdev/devops-testing.git
git remote -v                  # verify
git push                       # no username/password/token prompt
```

### Fix permissions if SSH complains

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

---

## 8. Daily Git Commands Cheat Sheet

| Task | Command |
|------|---------|
| Clone a repo | `git clone <url>` |
| Check status | `git status` |
| Stage changes | `git add <file>` or `git add .` |
| Commit | `git commit -m "message"` |
| Push | `git push` |
| Pull latest | `git pull` |
| Fetch without merging | `git fetch` |
| View history | `git log --oneline --graph` |
| See differences | `git diff` / `git diff --staged` |
| List remotes | `git remote -v` |
| Change remote URL | `git remote set-url origin <url>` |

### Branching

```bash
git branch                      # list branches
git branch feature-login        # create a branch
git checkout -b feature-login   # create and switch (or: git switch -c feature-login)
git switch main                 # switch back
git merge feature-login         # merge into current branch
git branch -d feature-login     # delete merged branch
```

### Undoing things

```bash
git restore <file>              # discard unstaged changes
git restore --staged <file>     # unstage a file
git commit --amend              # edit the last commit
git revert <commit>             # safely undo a commit with a new commit
git stash / git stash pop       # temporarily shelve changes
```

---

## 9. Ignore Files with `.gitignore`

Keep secrets and generated files out of the repo:

```gitignore
.env
node_modules/
vendor/
*.log
.DS_Store
```

> Never commit secrets (tokens, `.env`, private keys). If you accidentally do, revoke and rotate them immediately.

---

## 10. Common Errors & Fixes

| Error | Cause / Fix |
|-------|-------------|
| `Authentication failed` | Using a password instead of a token, or the token expired or lacks the `repo` scope. |
| `Permission denied (publickey)` | Public key not added to GitHub, or the wrong key is loaded. Run `ssh -T git@github.com`. |
| `remote origin already exists` | Use `git remote set-url origin <url>` instead of `remote add`. |
| `failed to push some refs` | Remote has commits you lack. Run `git pull --rebase`, then push. |
| `fatal: not a git repository` | Run `git init` or `cd` into the project folder. |

---

## 11. Quick Start Summary

```bash
# One-time
sudo apt update && sudo apt install git -y
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
ssh-keygen -t ed25519 -C "you@example.com"   # add .pub to GitHub

# Per project
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin git@github.com:thealamdev/devops-testing.git
git push -u origin main
```