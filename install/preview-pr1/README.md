# Isolated preview for PR 1 (saved-chat delete)

This stack is only for the fresh preview container **CT 105** at **10.72.72.219**.

Do not run it on the live NOMAD host **10.72.72.88**. Do not reuse `/opt/project-nomad`, the live database, or the live Redis. The inference server at `http://10.72.72.89:8080` is only referenced as a chat URL. Do not change that server.

No git checkout is required on the preview CT. Download the three files below and the image archive.

## What this is

- linux/amd64 image `nomad-preview-pr1:pr1`
- Built with the repository Dockerfile from git `f3443440a99042d911d60e2bdc18d91f99830f73` (the PR branch commit that contains the flame delete). The compose file and this SQL are not inside the image.
- Also tagged `nomad-preview-pr1:f3443440a99042d911d60e2bdc18d91f99830f73`
- Fresh MySQL 8 and Redis volumes, created the first time this compose project starts
- Three synthetic chats, titled `Synthetic: ...`, inserted after the app has migrated and seeded an empty database
- Knowledge base retrieval forced off (`rag.enabled=false`)
- No updater sidecar, so this preview will not replace itself with the upstream image

Archive: `nomad-preview-pr1-amd64.tar.gz` (539 MiB gzip). SHA256 `373d861efa7cf7a788ac92fd1221a1eb090b02f7f867e7dc962f90c4e33adfe9`. Image id `sha256:cf3825e0e45ef7b01d3e5d5e3a694f22f469e62bab99e57efcd192e96e77f27e`. `linux/amd64`. `version.json` inside the image is `pr1-f3443440a990`.

Download (public prerelease, not a NOMAD product release):

- Archive: https://github.com/SomerledDesign/project-nomad/releases/download/preview-pr1-f344344/nomad-preview-pr1-amd64.tar.gz
- Checksums: https://raw.githubusercontent.com/SomerledDesign/project-nomad/cursor/individual-chat-delete-97c3/install/preview-pr1/CHECKSUMS.txt
- Compose: https://raw.githubusercontent.com/SomerledDesign/project-nomad/cursor/individual-chat-delete-97c3/install/preview-pr1/compose.yaml
- Synthetic chats: https://raw.githubusercontent.com/SomerledDesign/project-nomad/cursor/individual-chat-delete-97c3/install/preview-pr1/synthetic-chats.sql

## Runtime the CT needs

Install Docker on the preview CT. Do not install it on .88.

```bash
apt-get update
apt-get install -y ca-certificates curl docker.io docker-compose
```

`docker-compose` from Debian 12 is enough. `docker compose` (plugin) is also fine.

Confirm the engine is up (`docker info`) before loading the image. This CT is unprivileged with nesting and keyctl; that is the expected Docker-in-LXC setup. If `dockerd` will not start, stop and report that rather than changing the live host.

Budget, given 2 GiB RAM, 512 MiB swap, and 20 GiB disk:

- Load only this image plus `mysql:8.0` and `redis:7-alpine`
- Do not install Ollama, Kiwix, or other Supply Depot apps on this CT
- MySQL is limited to a 128 MiB buffer pool and native AIO is off (needed in unprivileged LXC)
- The admin Node heap is capped at 384 MiB

Published port on this CT only: **8080**. MySQL and Redis are not published to the CT's network.

## Load and start

On CT 105, as root:

```bash
mkdir -p /opt/nomad-preview-pr1/storage
cd /opt/nomad-preview-pr1

# Download from the URLs in the PR. Do not git clone.
curl -fL -o compose.yaml 'https://raw.githubusercontent.com/SomerledDesign/project-nomad/cursor/individual-chat-delete-97c3/install/preview-pr1/compose.yaml'
curl -fL -o synthetic-chats.sql 'https://raw.githubusercontent.com/SomerledDesign/project-nomad/cursor/individual-chat-delete-97c3/install/preview-pr1/synthetic-chats.sql'
curl -fL -o nomad-preview-pr1-amd64.tar.gz 'https://github.com/SomerledDesign/project-nomad/releases/download/preview-pr1-f344344/nomad-preview-pr1-amd64.tar.gz'
curl -fL -o CHECKSUMS.txt 'https://raw.githubusercontent.com/SomerledDesign/project-nomad/cursor/individual-chat-delete-97c3/install/preview-pr1/CHECKSUMS.txt'

sha256sum -c CHECKSUMS.txt
docker load -i nomad-preview-pr1-amd64.tar.gz
docker image inspect nomad-preview-pr1:pr1 --format '{{.Id}} {{.Os}}/{{.Architecture}}'

if docker compose version >/dev/null 2>&1; then DC="docker compose"; else DC="docker-compose"; fi
$DC -p nomad-preview-pr1 -f compose.yaml up -d
$DC -p nomad-preview-pr1 -f compose.yaml ps
```

`docker image inspect` must report `linux/amd64`. The `synthetic-chats` service runs once after `/api/health` succeeds, then exits. That is expected.

Open `http://10.72.72.219:8080/chat`.

The sidebar should list only:

- Synthetic: Water treatment
- Synthetic: Field notes
- Synthetic: Radio check

Each row has an outlined flame after the title. The tooltip and confirmation say **Delete chat**. Cancel leaves the chat. Confirm removes that chat and its messages. Deleting the open chat returns to an empty new chat. Deleting one of the others leaves the open transcript in place. **Clear History** still deletes every chat; use a single flame to try the new control.

These three threads are fixtures inserted by `synthetic-chats.sql`. They are not copies of live chats.

## Stop and remove the preview

On CT 105 only:

```bash
cd /opt/nomad-preview-pr1
if docker compose version >/dev/null 2>&1; then DC="docker compose"; else DC="docker-compose"; fi
$DC -p nomad-preview-pr1 -f compose.yaml down -v
rm -rf /opt/nomad-preview-pr1
docker image rm nomad-preview-pr1:pr1 nomad-preview-pr1:f3443440a99042d911d60e2bdc18d91f99830f73
```

`-v` deletes the preview database and Redis volumes. It does not touch 10.72.72.88.
