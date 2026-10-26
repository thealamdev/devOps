# Linux Filesystem, Users, and Shell Prompt

## 1. Linux starts from `/`

In Linux, the filesystem starts from `/`.

`/` is called the **root directory**.

A typical top-level filesystem structure looks like:

```text
/
├── bin
├── boot
├── dev
├── etc
├── home
├── lib
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── sys
├── tmp
├── usr
└── var
```

All of these directories are directly inside `/` and are at the same directory level.

---

## 2. Root user and root directory are different

There are two different meanings of `root`:

### Root user

`root` is the **superuser/administrator account**.

### Root directory

`/` is the **root directory**, which is the top of the entire Linux filesystem.

There is also:

```text
/root
```

This is the **home directory of the root user**.

So:

```text
root      → username
/         → root directory
/root     → root user's home directory
```

---

## 3. Understanding the Linux prompt

When logged in as the root user, you might see:

```text
root@tc:/#
```

Breakdown:

```text
root @ tc : / #
│     │    │ │
│     │    │ └── # → prompt indicator for root/superuser
│     │    └────── current directory
│     └─────────── hostname
└──────────────── username
```

Therefore:

```text
root@tc:/#
```

means:

- `root` → current username
- `@` → separates username and hostname
- `tc` → hostname
- `:` → separates hostname and current directory
- `/` → current directory is the root directory
- `#` → root/superuser prompt

So you can read it as:

> The user `root` is on the machine/container `tc`, currently inside `/`, and is operating as the superuser.

---

# 4. Creating a new user

When logged in as root, you can create a new user with:

```bash
useradd -m shah
```

The `-m` option tells Linux to create a home directory for the user.

This will normally create:

```text
/home/shah
```

So the filesystem might contain:

```text
/
├── home
│   └── shah
│
└── root
```

Here:

```text
/home/shah → shah's home directory
/root      → root user's home directory
```

---

# 5. Switching to another user

From the root user, you can switch to `shah` using:

```bash
su - shah
```

`su` means **switch user**.

The `-` tells the shell to start a **login shell** for `shah`, loading that user's login environment and normally starting in their home directory.

After switching, you might see:

```text
$
```

This usually means you are now a **normal/non-root user**.

You can verify the current user with:

```bash
whoami
```

Output:

```text
shah
```

And verify your current directory:

```bash
pwd
```

Output:

```text
/home/shah
```

---

# 6. `$` vs `#`

A common convention is:

```text
$ → normal user
# → root/superuser
```

For example:

```text
root@tc:/#
```

means root/superuser.

While:

```text
shah@tc:~$
```

means a normal user.

However, **the prompt is configurable**. Seeing `$` or `#` is not a guaranteed way to determine your user.

The reliable way is:

```bash
whoami
```

For example:

```bash
$ whoami
shah
```

or:

```bash
# whoami
root
```

---

# 7. Why might you see only `$`?

After running:

```bash
su - shah
```

you might see:

```text
$
```

instead of:

```text
shah@tc:~$
```

This is because the shell prompt is controlled by the `PS1` variable.

`PS1` means:

> **Primary Prompt String**

Check its value with:

```bash
echo "$PS1"
```

It may simply contain:

```text
$
```

Therefore, the shell only displays:

```text
$
```

---

# 8. Setting `PS1`

In Bash, you can set a more informative prompt:

```bash
PS1='\u@\h:\w\$ '
```

The special sequences mean:

| Sequence | Meaning |
|---|---|
| `\u` | Current username |
| `\h` | Hostname |
| `\w` | Current working directory |
| `\$` | `#` for root, `$` for normal user |

So:

```bash
PS1='\u@\h:\w\$ '
```

could display:

```text
shah@tc:~$
```

If you are in `/`:

```text
shah@tc:/$
```

If you are root:

```text
root@tc:/#
```

The `\$` is useful because Bash automatically chooses:

```text
$ → normal user
# → root
```

---

# 9. Why `/bin/sh` may show `\u@\h:\w$` literally

There is an important shell difference.

If the user's shell is:

```text
/bin/sh
```

and you run:

```bash
PS1='\u@\h:\w\$ '
```

you may see:

```text
\u@\h:\w$
```

instead of:

```text
shah@tc:~$
```

This happens because the prompt escape sequences such as:

```text
\u
\h
\w
```

are Bash-specific prompt features and are not necessarily interpreted by `/bin/sh`.

You can check the configured shell with:

```bash
echo "$SHELL"
```

For example:

```text
/bin/sh
```

You can check the shell process that is currently running with:

```bash
ps -p $$ -o comm=
```

---

# 10. Starting Bash

If you are currently inside `/bin/sh`, you can start Bash by running:

```bash
bash
```

Now you are running a Bash shell inside the previous shell.

You can then set:

```bash
PS1='\u@\h:\w\$ '
```

and you should get something like:

```text
shah@tc:~$
```

You can verify the current shell with:

```bash
ps -p $$ -o comm=
```

which should show:

```text
bash
```

---

# 11. What does `~` mean?

`~` is called **tilde**.

It represents the **current user's home directory**.

For `root`:

```text
~ = /root
```

For `shah`:

```text
~ = /home/shah
```

Therefore:

```bash
cd ~
```

means:

> Go to my home directory.

For example, as `shah`:

```bash
cd ~
pwd
```

produces:

```text
/home/shah
```

As root:

```bash
cd ~
pwd
```

produces:

```text
/root
```

---

# 12. Important commands to remember

### Who am I?

```bash
whoami
```

### Where am I?

```bash
pwd
```

### What is my home directory?

```bash
echo "$HOME"
```

### What shell am I using?

```bash
echo "$SHELL"
```

### What shell process is currently running?

```bash
ps -p $$ -o comm=
```

### Show the current prompt configuration

```bash
echo "$PS1"
```

### Switch user

```bash
su - shah
```

### Return to the previous shell/user

```bash
exit
```

---

# 13. The complete picture

You can think about your Linux session like this:

```text
                    Linux filesystem
                           │
                           │
                           ▼
                           /
          ┌────────────────┼────────────────┐
          │                │                │
        /home             /root            /usr
          │
          └── shah
              │
              └── shah's home directory
```

And the users:

```text
root
 │
 ├── home directory → /root
 └── usually shown with #


shah
 │
 ├── home directory → /home/shah
 └── usually shown with $
```

The shell prompt can then display information such as:

```text
shah@tc:~$
│    │  ││
│    │  │└── normal-user prompt
│    │  └─── home directory (/home/shah)
│    └────── hostname
└─────────── username
```

For root:

```text
root@tc:/#
│    │ ││
│    │ │└── root/superuser prompt
│    │ └─── current directory (/)
│    └───── hostname
└────────── username
```

## Key idea

Remember these four concepts separately:

```text
/       → root directory
/root   → root user's home directory
~       → current user's home directory
# / $   → shell prompt convention
```

And don't rely only on the prompt to determine who you are. Use:

```bash
whoami
```

for the definitive answer.