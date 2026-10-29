# Docker LEMP Stack: Learning Notes

LEMP = **L**inux + **E**ngine-X (nginx) + **M**ySQL + **P**HP.
These notes explain a working Docker Compose setup, line by line, and answer the questions that came up while learning it.

---

## Table of Contents

1. [Project structure](#1-project-structure)
2. [The final working files](#2-the-final-working-files)
3. [Fixing "I can't see anything" (port and service name)](#3-fixing-i-cant-see-anything)
4. [docker-compose.yml syntax explained](#4-docker-composeyml-syntax-explained)
5. [Why a Dockerfile for PHP?](#5-why-a-dockerfile-for-php)
6. [Using the latest PHP version](#6-using-the-latest-php-version)
7. [The nginx config explained](#7-the-nginx-config-explained)
8. [Volumes: why both nginx and php need `./www`](#8-volumes-why-both-nginx-and-php-need-www)
9. [Volumes: sharing vs persisting](#9-volumes-sharing-vs-persisting)
10. [Using a `.env` file for passwords](#10-using-a-env-file-for-passwords)
11. [Does `.env` have to be next to docker-compose.yml?](#11-does-env-have-to-be-next-to-docker-composeyml)
12. [Troubleshooting: "variable is not set" warning](#12-troubleshooting-variable-is-not-set-warning)
13. [Command cheat sheet](#13-command-cheat-sheet)
14. [Quick troubleshooting table](#14-quick-troubleshooting-table)

---

## 1. Project structure

```
project/
├── docker-compose.yml
├── .env
├── nginx/
│   └── default.conf
├── php/
│   └── Dockerfile
└── www/
    └── index.php
```

---

## 2. The final working files

### `docker-compose.yml`

```yaml
services:
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./www:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
    networks:
      - lempnet

  php:
    build: ./php
    environment:
      DB_HOST: mysql
      DB_NAME: ${MYSQL_DATABASE}
      DB_USER: ${MYSQL_USER}
      DB_PASS: ${MYSQL_PASSWORD}
    volumes:
      - ./www:/var/www/html
    networks:
      - lempnet

  mysql:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - lempnet

volumes:
  db_data:

networks:
  lempnet:
```

### `.env`

```env
MYSQL_ROOT_PASSWORD=your_strong_root_password
MYSQL_DATABASE=exampledb
MYSQL_USER=user
MYSQL_PASSWORD=your_strong_user_password
```

### `php/Dockerfile`

```dockerfile
FROM php:8.2-fpm

RUN docker-php-ext-install mysqli pdo pdo_mysql

WORKDIR /var/www/html
```

### `nginx/default.conf`

```nginx
server {
    listen 80;
    server_name localhost;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### `www/index.php`

```php
<?php
echo "<h1>LEMP Stack is Working!</h1>";

$host = getenv('DB_HOST');
$db   = getenv('DB_NAME');
$user = getenv('DB_USER');
$pass = getenv('DB_PASS');

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "<p>Connected to MySQL successfully!</p>";

$conn->close();
```

Open: **http://localhost:8080**

---

## 3. Fixing "I can't see anything"

There were two problems in the original setup.

### Problem 1: Wrong port

The compose file said `"8080:80"`, so the site is at `http://localhost:8080`.
The URL `http://127.0.0.1:8000` doesn't work because nothing is mapped to port 8000.

### Problem 2: Wrong PHP hostname in nginx

The original config had:

```nginx
fastcgi_pass app:9000;
```

But the PHP service in the compose file is named `php`, not `app`. Docker's internal DNS only knows the **service names** from your compose file. The fix:

```nginx
fastcgi_pass php:9000;
```

**Lesson:** a service name in `docker-compose.yml` is also its hostname on the network. That's why `php:9000` (in nginx) and `$host = 'mysql'` (in PHP) work.

---

## 4. docker-compose.yml syntax explained

### YAML basics

The file is written in YAML. Three rules:

- **Indentation = nesting.** Use spaces (not tabs), usually 2 per level.
- **`key: value`** is a setting.
- **`- item`** is an entry in a list.

```yaml
nginx:                    # a key whose value is a nested block
  image: nginx:latest     # key: value
  ports:                  # a key whose value is a list
    - "8080:80"           # list item
```

### The three top-level sections

```yaml
services:   # the containers you want to run
volumes:    # named storage areas (persistent data)
networks:   # virtual networks the containers talk over
```

### `services`

Each name under `services:` (`nginx`, `php`, `mysql`) is one container.

#### nginx service

| Line | Meaning |
|---|---|
| `image: nginx:latest` | Use the ready-made image from Docker Hub |
| `ports: - "8080:80"` | `host_port:container_port`. Your PC's 8080 goes to port 80 in the container |
| `volumes: - ./www:/var/www/html` | Share your `www` folder into the container |
| `volumes: - ./nginx/default.conf:/etc/nginx/conf.d/default.conf` | Replace nginx's default config with yours |
| `depends_on: - php` | Start `php` before `nginx` (start order only, it doesn't wait until PHP is ready) |
| `networks: - lempnet` | Attach to the `lempnet` network so containers can reach each other by name |

#### php service

| Line | Meaning |
|---|---|
| `build: ./php` | Don't use a ready-made image. Build one from the Dockerfile in `./php` |

#### mysql service

| Line | Meaning |
|---|---|
| `image: mysql:8.0` | Official MySQL 8.0 image |
| `restart: always` | Restart the container if it crashes or Docker restarts |
| `environment:` | Environment variables passed into the container. The MySQL image reads these on first startup to create the root password, database and user |
| `volumes: - db_data:/var/lib/mysql` | A **named volume** that stores database files so they survive container deletion |

### Bottom sections

```yaml
volumes:
  db_data:      # declares the named volume used by mysql

networks:
  lempnet:      # declares the network all three services join
```

An empty value means "use the defaults."

---

## 5. Why a Dockerfile for PHP?

**Question:** Why can't we just pull PHP from Docker Hub like `nginx:latest`?

**Answer:** We do pull from Docker Hub. The Dockerfile starts from the official PHP image. But the official `php:8.2-fpm` image is deliberately minimal and **does not include the MySQL extensions** (`mysqli`, `pdo_mysql`). Without them, `new mysqli(...)` crashes with "Class mysqli not found."

nginx needs no extra additions for this setup, so the stock image is enough.

### What the Dockerfile does

```dockerfile
FROM php:8.2-fpm                                  # start from the official image
RUN docker-php-ext-install mysqli pdo pdo_mysql   # add the MySQL extensions
WORKDIR /var/www/html                             # default folder inside the container
```

`build: ./php` in the compose file means: "take the official PHP image, add what I need, and use the result."

### Can you skip the Dockerfile?

Only if you find a pre-built image that already has those extensions. Those are usually from third parties and less trustworthy. Building your own on top of the official image is standard, and you can add more later (Composer, `gd`, `redis`, ...) with one more `RUN` line.

**Important:** after editing the Dockerfile, rebuild:

```bash
docker compose up -d --build
```

---

## 6. Using the latest PHP version

The newest PHP image **still doesn't include** `mysqli` or `pdo_mysql`. The MySQL extensions always have to be installed with `docker-php-ext-install`, whatever the version. Only the tag changes:

```dockerfile
FROM php:8.5-fpm

RUN docker-php-ext-install mysqli pdo pdo_mysql

WORKDIR /var/www/html
```

### Tag notes

- `php:fpm` always points to the newest PHP with FPM. Convenient, but a rebuild after a new major version can break your project.
- `php:8.5-fpm` pins a version, which is better for reproducibility. Check the tag list at https://hub.docker.com/_/php for the current stable version.
- The same idea applies to `nginx:latest`. Pinning (like `nginx:1.27`) avoids surprises.

---

## 7. The nginx config explained

nginx is a web server. It serves static files itself, but it **can't run PHP**. For `.php` files, it hands the request to **PHP-FPM** (the `php` container) and returns the result.

```nginx
server {
```
One website (a "virtual host").

```nginx
    listen 80;
    server_name localhost;
```
Listen on port 80 *inside* the container (your `8080:80` mapping connects your PC's 8080 to this). `server_name` is the domain this block answers to.

```nginx
    root /var/www/html;
    index index.php index.html;
```
`root` is the folder files are served from (where `./www` is mounted). `index` says which file to serve for a folder URL like `/`, trying `index.php` first.

```nginx
    location / {
        try_files $uri $uri/ =404;
    }
```
Rules for ordinary requests: try the exact file, then a directory, otherwise return 404.

```nginx
    location ~ \.php$ {
```
Matches any URL ending in `.php` (`~` means regular expression). This is where PHP requests get special handling.

```nginx
        include fastcgi_params;
```
Loads standard FastCGI variables (request method, query string, ...) that PHP needs.

```nginx
        fastcgi_pass php:9000;
```
Send the request to host `php` on port 9000, where PHP-FPM listens.

```nginx
        fastcgi_index index.php;
```
Default file if the URL points at a directory.

```nginx
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
```
Tells PHP-FPM the **full path of the script to run**, e.g. `/var/www/html/index.php`.

### The full request flow

```
Browser → localhost:8080 → nginx container (port 80)
                              │
                 .html/.css/.js? → nginx serves the file directly
                              │
                 .php?  → fastcgi_pass php:9000 → PHP-FPM runs the script
                              │                         │
                              │                         └→ connects to mysql:3306
                              └← HTML response ←────────┘
```

---

## 8. Volumes: why both nginx and php need `./www`

```yaml
- ./www:/var/www/html
```

Each container has its own **isolated filesystem**. Your `index.php` lives on your PC, and a container can't see it unless you share it in.

This line means: take the `www` folder next to `docker-compose.yml` (`./` = relative to this file) and make it appear inside the container at `/var/www/html`.

It is **not a copy**. It's the same folder seen from two places, so edits on your PC show up instantly.

```
Your PC: ./www/index.php
              │
     ┌────────┴────────┐
     ▼                 ▼
nginx container    php container
/var/www/html      /var/www/html
```

### Why both containers need it

- **nginx** needs it to serve static files and to check whether a requested file exists (`try_files`).
- **php** needs it to actually **open and run** the script. PHP-FPM only receives a path from nginx and opens that file in its own filesystem.

### What happens if you remove one

| Missing from | Result |
|---|---|
| nginx | nginx can't find `index.php` → **404** |
| php | nginx finds the file and forwards it, but PHP can't open it → **"File not found."** |

### Why the container path must match

nginx tells PHP: "run `/var/www/html/index.php`". PHP looks for that exact path in its own container. If the php service mounted the folder at `/app`, PHP wouldn't find it.

**Rule:** both containers see the same files at the same path.

### Alternative: copy instead of share

You could put `COPY ./www /var/www/html` in the Dockerfile. That's common for production, but every code change needs a rebuild. For development, the volume is better.

---

## 9. Volumes: sharing vs persisting

**Question:** Volumes are for persisting data, but `./www` doesn't look like persistence.

**Answer:** Volumes do two jobs:

1. **Persist data** so it survives when a container is deleted.
2. **Share files** between your PC and a container, or between containers.

`./www` is job 2. `db_data` is job 1.

| | `./www:/var/www/html` | `db_data:/var/lib/mysql` |
|---|---|---|
| Type | **Bind mount** | **Named volume** |
| Stored where | A folder on your PC you can see and edit | Inside Docker's storage area |
| Purpose | Share your code into containers | Persist database files |

- The `www` files do survive `docker compose down`, but that's a side effect. The goal is to **get your code into the containers**, since they start from a clean image.
- MySQL needs a named volume because a container's own filesystem is thrown away when it's removed. Without `db_data`, `down` then `up` would give an empty database.
- `docker compose down -v` also deletes named volumes.

**Rule of thumb:**

- Code you edit → **bind mount** (`./folder:/path`)
- Data the app generates (databases, uploads) → **named volume** (`name:/path`)

---

## 10. Using a `.env` file for passwords

Compose automatically reads a file named `.env` next to `docker-compose.yml`. You reference values with `${VARIABLE}`.

### Step 1: create `.env`

```env
MYSQL_ROOT_PASSWORD=your_strong_root_password
MYSQL_DATABASE=exampledb
MYSQL_USER=user
MYSQL_PASSWORD=your_strong_user_password
```

No spaces around `=`. No quotes needed unless the value contains spaces.

### Step 2: use it in the compose file

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
  MYSQL_DATABASE: ${MYSQL_DATABASE}
  MYSQL_USER: ${MYSQL_USER}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```

### Step 3: pass them to PHP too

```yaml
php:
  build: ./php
  environment:
    DB_HOST: mysql
    DB_NAME: ${MYSQL_DATABASE}
    DB_USER: ${MYSQL_USER}
    DB_PASS: ${MYSQL_PASSWORD}
```

Then in PHP, use `getenv('DB_HOST')`, `getenv('DB_NAME')`, and so on instead of hardcoded values (see the final `index.php` in section 2).

### Step 4: apply

MySQL reads these variables only on **first initialization**. If the `db_data` volume already exists with old credentials, reset it (**this deletes the database data**):

```bash
docker compose down -v
docker compose up -d --build
```

Check that substitution works:

```bash
docker compose config
```

### Step 5: keep it out of Git

Add to `.gitignore`:

```
.env
```

Commit a `.env.example` with placeholder values so others know what to set.

### Optional: default or required values

```yaml
MYSQL_DATABASE: ${MYSQL_DATABASE:-exampledb}                             # default
MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}  # error if missing
```

> **Security tip:** don't paste real passwords into chats, screenshots, or files you share. If you did, change them.

---

## 11. Does `.env` have to be next to docker-compose.yml?

No, but it's the default and the recommended setup. By default Compose looks in the **project directory** (the folder containing the compose file).

### Other options

```bash
# Point to a different file
docker compose --env-file ./config/.env up -d
docker compose --env-file .env.production up -d

# Compose file elsewhere, but look for .env in the current folder
docker compose -f ./docker/docker-compose.yml --project-directory . up -d
```

### `env_file:` is a different feature

```yaml
services:
  mysql:
    image: mysql:8.0
    env_file:
      - ./config/mysql.env
```

| | `.env` (auto-loaded) | `env_file:` |
|---|---|---|
| Used for | `${VAR}` substitution **inside** `docker-compose.yml` | Setting env vars **inside the container** |
| Location | Project directory by default (changeable with `--env-file`) | Any path you write |
| Loaded | Automatically | Only for services that list it |

### File name

The compose file can be `compose.yaml` (preferred), `compose.yml`, `docker-compose.yml`, or `docker-compose.yaml`. All work without `-f`.

---

## 12. Troubleshooting: "variable is not set" warning

```
WARN The "MYSQL_ROOT_PASSWORD" variable is not set. Defaulting to a blank string.
```

Compose can't find or read your `.env`. Check these in order:

1. **Wrong file name.** It must be exactly `.env`. Not `env`, `.env.txt` (Windows can hide the `.txt`), or `.env.example`.
   Check with `ls -la` (Linux/macOS) or `dir /a` (Windows).
2. **Wrong location.** `.env` must be in the same folder as `docker-compose.yml` (where you run the command).
3. **Wrong format.** Each line must be plain `KEY=value`.
   - No spaces around `=`
   - The names in `.env` must match the names in `${...}`
   - Save as UTF-8 (some Windows editors save UTF-16)
4. **Check what Compose sees:**
   ```bash
   docker compose config
   docker compose --env-file .env config
   ```
   If the second works but the first doesn't, the problem is the file's name or location.

After fixing, reset the volume if needed:

```bash
docker compose down -v
docker compose up -d --build
```

---

## 13. Command cheat sheet

| Command | What it does |
|---|---|
| `docker compose up -d` | Start all services in the background |
| `docker compose up -d --build` | Rebuild images (after Dockerfile changes), then start |
| `docker compose down` | Stop and remove containers and networks (keeps volumes) |
| `docker compose down -v` | Same, but **also deletes named volumes** (database data!) |
| `docker compose ps` | List running services |
| `docker compose logs` | Show logs of all services |
| `docker compose logs nginx php` | Show logs of specific services |
| `docker compose config` | Show the final compose file with variables filled in |
| `docker compose restart nginx` | Restart one service |
| `docker compose exec php bash` | Open a shell inside the php container |

---

## 14. Quick troubleshooting table

| Symptom | Likely cause | Fix |
|---|---|---|
| Page doesn't load at `:8000` | Port mapping is `8080:80` | Use `http://localhost:8080` |
| **502 Bad Gateway** | nginx can't reach PHP (wrong `fastcgi_pass` host) | Use the service name: `fastcgi_pass php:9000;` |
| **404 Not Found** | `www` not mounted in nginx, or file in the wrong folder | Check the volumes and that the file is at `www/index.php` |
| **"File not found."** | `www` not mounted in php, or mounted at a different path | Mount `./www:/var/www/html` in both |
| `Class "mysqli" not found` | MySQL extensions missing in PHP image | Add `docker-php-ext-install mysqli pdo pdo_mysql` and rebuild |
| `Connection failed` right after start | MySQL still initializing (10–30 s) | Wait and refresh |
| `Connection failed: Access denied` after changing credentials | Old credentials stored in the `db_data` volume | `docker compose down -v`, then `up -d --build` |
| `variable is not set` warning | `.env` missing, misnamed, or in the wrong folder | See section 12 |
| Dockerfile change has no effect | Image not rebuilt | `docker compose up -d --build` |

---

## Key ideas to remember

1. **Service name = hostname** on the Compose network (`php`, `mysql`).
2. **`image:`** uses a ready-made image; **`build:`** builds one from your Dockerfile.
3. **Bind mount** (`./www:/path`) shares your code; **named volume** (`db_data:/path`) persists data.
4. nginx serves static files; **PHP-FPM runs PHP**. nginx forwards `.php` requests via `fastcgi_pass`.
5. Both nginx and php need the code at the **same path**.
6. `.env` fills `${VARS}` in the compose file. `env_file:` sets variables inside a container.
7. MySQL reads its environment variables **only the first time** the data volume is created.

## Good next topics

- Create a table and query it from PHP
- Add phpMyAdmin to the compose file
- Add a `healthcheck` so nginx/PHP wait until MySQL is truly ready
- Pin image versions for reproducible builds