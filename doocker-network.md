# Docker Network Notes

## 1. List Networks

```bash
docker network ls
```

Shows all existing networks. Initially you will see three, which Docker creates internally:

| Network  | Purpose                                              |
|----------|------------------------------------------------------|
| `bridge` | Default network for containers                       |
| `host`   | Container uses the host's network directly           |
| `none`   | No networking at all                                 |

---

## 2. Create a Network

Always create the network **first**, then run containers in it.

```bash
docker network create mynet
```

---

## 3. Run Containers in the Network

```bash
docker run -dit --name c1 --network mynet ubuntu
docker run -dit --name c2 --network mynet ubuntu
```

| Part               | Meaning                                         |
|--------------------|-------------------------------------------------|
| `-d`               | Run in the background (detached)                |
| `-i`               | Keep input open (interactive)                   |
| `-t`               | Allocate a terminal (tty)                       |
| `--name c1`        | Name the container `c1`                         |
| `--network mynet`  | Attach the container to the `mynet` network     |
| `ubuntu`           | Image used to create the container              |

> Note: use `docker run` to create a container. `docker exec` only runs a command inside an **already running** container.

---

## 4. Install `ping` in Ubuntu Containers

Ubuntu images do **not** include `ping`. Alpine and BusyBox have it by default.

Run this for **each** Ubuntu container (`c1` and `c2`):

```bash
docker exec c1 apt-get update
docker exec c1 apt-get install -y iputils-ping

docker exec c2 apt-get update
docker exec c2 apt-get install -y iputils-ping
```

- `apt-get update` refreshes the package list inside the container.
- `apt-get install -y iputils-ping` installs `ping` (`-y` auto-confirms).

---

## 5. Test the Connection

```bash
docker exec c1 ping -c 2 c2
```

- Pings container `c2` from container `c1`.
- `-c 2` means send only **2** packets, then stop.
- Works by **container name** because custom networks have built-in DNS.

---

## 6. Connect and Disconnect a Container

Attach a running container to a network, or detach it:

```bash
docker network connect mynet c1
docker network disconnect mynet c1
```

---

## 7. Remove Containers

Remove specific containers:

```bash
docker rm -f c1 c2
```

Remove **all** containers dynamically:

```bash
docker rm -f $(docker ps -qa)
```

> ⚠️ This deletes **every** container on your machine, running or stopped. Use with care.

---

## 8. Remove a Network

```bash
docker network rm mynet
```

If you get an `active endpoints` error, remove or disconnect the containers first.

Remove all unused networks:

```bash
docker network prune
```

---

## 9. Using Alpine Instead of Ubuntu

Alpine is small and already includes `ping`, so no extra install is needed.

```bash
docker pull alpine
docker run -dit --name c1 --network mynet alpine
docker run -dit --name c2 --network mynet alpine
docker exec c1 ping -c 2 c2
```

Enter an Alpine container with `sh` (Ubuntu uses `bash`):

```bash
docker exec -it c1 sh
```

---

## Quick Summary (Full Flow)

```bash
docker network create mynet
docker run -dit --name c1 --network mynet ubuntu
docker run -dit --name c2 --network mynet ubuntu

docker exec c1 apt-get update
docker exec c1 apt-get install -y iputils-ping
docker exec c2 apt-get update
docker exec c2 apt-get install -y iputils-ping

docker exec c1 ping -c 2 c2

docker rm -f c1 c2
docker network rm mynet
```