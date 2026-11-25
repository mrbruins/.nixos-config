# Containers on the MacBook

One tool: [Lima](https://lima-vm.io). It comes with devvm, which uses it for agent sandboxes. Colima, Lume, Docker
Desktop and nerdctl are not used.

```sh
rig docker        # start the VM `docker`, creating it the first time, and select it
docker compose up # the normal Docker CLI, with Compose and buildx
rig docker stop   # give the memory back
```

- The VM runs rootless Docker with 4 CPUs, 6 GB of memory and a disk that grows to 60 GB.
- Only `~/dev` is shared with it, writable. A bind mount from anywhere else is an empty directory in the container.
- Published ports appear on `127.0.0.1`.
- `docker --context truenas`, or `truenas-docker`, talks to the NAS instead.
- This VM is not an agent sandbox. Anything that can use its socket can write to `~/dev`.
- To start over: `limactl delete docker`, then `rig docker`. That removes its images and volumes.
