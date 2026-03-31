# Local Docker Environment (Lima + nerdctl)

This setup uses [Lima](https://lima-vm.io/) as a lightweight Linux VM and [nerdctl](https://github.com/containerd/nerdctl) as a Docker-compatible CLI, replacing Docker Desktop on macOS.

Both `lima` and `nerdctl` are installed via `modules/darwin/packages.nix`. The shell aliases and `DOCKER_HOST` are configured in `modules/darwin/home-manager.nix`.

## VM name

The Lima VM is named **`docker`**. All Lima commands below reference this name explicitly.

The `DOCKER_HOST` session variable is configured to point at this VM's socket:

```
DOCKER_HOST=unix://$HOME/.lima/docker/sock/docker.sock
```

## Create and start the VM

On first use, create the VM from the built-in Docker template:

```sh
limactl create --name=docker template://docker
limactl start docker
```

Or in a single step:

```sh
limactl start --name=docker template://docker
```

Lima will download the VM image and start containerd inside it. This takes a few minutes on first run.

## Running containers

Once the VM is running, use the `docker` or `nerdctl` aliases — both are wired to `lima nerdctl`:

```sh
docker run --rm hello-world
docker ps
docker compose up -d
```

Under the hood these expand to `lima nerdctl <args>`, which runs nerdctl inside the `docker` VM.

## Check VM status

```sh
limactl list
```

## Stop and start the VM

```sh
limactl stop docker
limactl start docker
```

## Delete the VM

```sh
limactl delete docker
```

> **Note:** Deleting the VM removes all containers and images stored inside it.

## Troubleshooting

**`Cannot connect to the Docker daemon`**

Ensure the VM is running (`limactl list`) and that `DOCKER_HOST` is set correctly in your shell. Open a new terminal after running `nix run .#build-switch` to pick up the session variable.

**Port forwarding**

Lima automatically forwards ports exposed by containers to `127.0.0.1` on the host. No additional configuration is needed for standard `docker run -p` usage.

**Rootless vs rootful**

The `template://docker` Lima template runs containerd in rootless mode by default. If a container requires root, start the VM with the `template://docker-rootful` template instead:

```sh
limactl start --name=docker template://docker-rootful
```
