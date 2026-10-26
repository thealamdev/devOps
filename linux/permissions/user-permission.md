### How to give sudo access to a user

Run all of these as **root**.

#### 1. Install sudo (if it isn't installed)

```bash
apt update
apt install -y sudo
```

- `apt update` refreshes the package list (needed in a fresh container)
- `apt install -y sudo` installs `sudo`; `-y` auto-answers "yes"

#### 2. Create the user (if it doesn't exist yet)

```bash
useradd -m -s /bin/bash shah
```

- `-m` creates the home directory `/home/shah`
- `-s /bin/bash` sets bash as the login shell

#### 3. Set a password for the user

```bash
passwd shah
```

`sudo` asks for the user's own password, so one must be set.

#### 4. Add the user to the sudo group

```bash
usermod -aG sudo shah
```

| Part | Meaning |
|---|---|
| `usermod` | modifies an existing user account |
| `-G sudo` | sets the supplementary group to `sudo` |
| `-a` | append: adds the group without removing the user's other groups |
| `shah` | the user being changed |

#### 5. Verify

```bash
id shah
```

The output should include `sudo` in the groups list.

#### 6. Test as the user

```bash
su - shah
sudo apt update
```

Enter shah's password when asked. The user must log out and back in for the new group to apply.

#### Quick version (all in one)

```bash
apt update && apt install -y sudo
useradd -m -s /bin/bash shah
passwd shah
usermod -aG sudo shah
```

### Give Full Access (No Password Required)

To give a user full `sudo` access without requiring a password:

1. Log in as the **root** user.

2. Open the `sudoers` configuration file:

```bash
nano /etc/sudoers
```

3. Find the line for the `root` user:

```text
root    ALL=(ALL:ALL) ALL
```

4. Directly below it, add:

```text
username    ALL=(ALL) NOPASSWD: ALL
```

Replace `username` with the actual username.

For example, if the username is `admin`:

```text
root     ALL=(ALL:ALL) ALL
admin    ALL=(ALL) NOPASSWD: ALL
```

5. Save the file and exit `nano`.

Now the `admin` user can run **any command with `sudo` without entering a password**:

```bash
sudo apt update
sudo systemctl restart nginx
sudo chmod 777 some-file
```

### Important

`NOPASSWD: ALL` gives the user **full root-level privileges** through `sudo`. They can essentially do anything the `root` user can do.

Also, it's safer to edit `/etc/sudoers` using:

```bash
visudo
```

instead of directly using:

```bash
nano /etc/sudoers
```

because `visudo` checks the syntax before saving and helps prevent accidentally breaking `sudo`.