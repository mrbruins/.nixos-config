# NAS cutover: TrueNAS to NixOS

Every step here is done by a person. Steps 1 to 5 change nothing on TrueNAS except snapshots and a stopped
Docker; step 6 erases its boot disk.

## 1. Before the day

- TrueNAS: System → General → Manage Configuration → Download File, **with** the password secret seed. Keep it
  in 1Password and on a USB stick. Without it, a TrueNAS USB drive boots without your settings.
- Download the TrueNAS ISO for the installed version or newer, and the NixOS 26.05 minimal ISO (x86_64).
  Verify both checksums. Write the NixOS one to a USB stick.
- Home Assistant: Settings → System → Backups → make a full backup, download it to a Mac, and store its
  encryption key in 1Password. It is the way back if the VM does not boot (see step 8).
- Have a screen and keyboard on the NAS. SSH and DNS will be down.
- Merge and build the `nas` host. CI must be green.

## 2. Snapshot with everything stopped

Shut down the Home Assistant VM in TrueNAS. Do **not** stop stacks in Dockhand: a container stopped by hand
stays stopped after the move. Stop Docker itself instead. On the NAS:

```bash
sudo systemctl stop docker.socket docker.service
sudo zfs snapshot -r Max@before-nixos
for d in Lewis/photos Lewis/videos Lewis/backups Lewis/Media/home-movies; do sudo zfs snapshot "$d@before-nixos"; done
```

Docker and the VM stay off until step 8.

## 3. Copy to two drives

Connect the first empty 2 TB drive. Find its ID and check it twice; creating the pool erases it.

```bash
ls -l /dev/disk/by-id/ | grep usb-
sudo zpool create -R /mnt -O compression=zstd -O encryption=aes-256-gcm -O keyformat=passphrase -O mountpoint=none \
  rescue1 /dev/disk/by-id/<drive 1>
for d in Lewis/photos Lewis/videos Lewis/Media/home-movies Max/docker/data Max/docker/stacks Max/VMs/haos-vm; do
  sudo zfs send -v "$d@before-nixos" | sudo zfs receive -u "rescue1/${d//\//-}"
done
sudo zfs create -o mountpoint=/rescue1-volumes rescue1/docker-volumes    # lands under /mnt
sudo rsync -aHAX /mnt/.ix-apps/docker/volumes/ /mnt/rescue1-volumes/
```

If `docker/` is already unmounted, mount it first with `sudo zfs mount Max/ix-apps/docker`. Put
`Lewis/backups` on the second drive the same way, as `rescue2`.

**Verify.** Scrub each drive and require zero errors. Then restore one database and a folder of photos to
another place and open them:

```bash
sudo zpool scrub -w rescue1 && sudo zpool status -v rescue1
sudo zpool export rescue1
```

Store the passphrases in 1Password. Unplug the drives. Do not continue until both are verified.

## 4. Prepare the Docker copy and export

```bash
sudo zfs clone -o mountpoint=legacy Max/ix-apps/docker@before-nixos Max/docker-root
```

NixOS runs Docker on this clone; the original stays as it was. Shut the NAS down from the TrueNAS interface,
which exports the pools.

## 5. Read-only import test

Boot the NixOS stick. Nothing below writes to a pool:

```bash
sudo -i
lsblk -o NAME,SIZE,MODEL,ID-LINK        # the 1 TB disk is nvme-eui.e8238fa6bf530001001b448b4762e23a
zpool import                            # lists Lewis and Max, both ONLINE
for p in Lewis Max; do zpool import -o readonly=on -N -R /mnt -d /dev/disk/by-id -f $p; done
zpool status -v
mount -t zfs -o ro,zfsutil Lewis/photos /mnt2 --mkdir && ls /mnt2 && umount /mnt2
zpool export Lewis && zpool export Max
```

If a pool does not import cleanly, stop: remove the stick and boot TrueNAS.

## 6. Install

This erases the 1 TB disk. Going back now needs the TrueNAS USB drive and the configuration file.

```bash
nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/v1.13.0 -- \
  --mode destroy,format,mount --flake github:mrbruins/.nixos-config#nas
nixos-install --flake github:mrbruins/.nixos-config#nas --no-root-passwd
nixos-enter --root /mnt -c 'passwd michielbruins'
reboot
```

## 7. First boot

```bash
zpool status && zfs list -o name,mountpoint,mounted -r -d 2 Lewis Max
systemctl --failed
sudo chown michielbruins:michielbruins /mnt/Lewis/photos /mnt/Lewis/videos
sudo smbpasswd -a michielbruins
sudo tailscale up --qr
sudo install -d -m 0750 /etc/nas && sudo install -m 0600 /dev/stdin /etc/nas/alert-url   # paste the URL, Ctrl-D
echo "test" | sudo nas-alert
```

The old SSH host key is gone, so remove it with `ssh-keygen -R` on your machines. Never run `zpool upgrade`.

## 8. Services

Docker and the VM start by themselves once the pools are up. Check, in this order: Traefik and AdGuard answer,
Dockhand shows every stack running, Home Assistant answers on its own address, the four shares mount from a
Mac, and a container that transcodes sees `/dev/dri`.

**If Home Assistant does not start** within a few minutes (`virsh console haos`), rebuild it instead of
debugging it. The old disk stays as it is:

```bash
sudo systemctl stop haos && sudo virsh destroy haos
sudo zfs rename Max/VMs/haos-vm Max/VMs/haos-vm-truenas
sudo zfs create -s -V 32G Max/VMs/haos-vm
# Download haos_ova-<version>.qcow2.xz from the Home Assistant OS releases page and verify its checksum.
xz -d haos_ova-*.qcow2.xz
sudo nix shell nixpkgs#qemu-utils -c qemu-img convert -O raw haos_ova-*.qcow2 /dev/zvol/Max/VMs/haos-vm
sudo systemctl start haos
```

The MAC address stays the same, so it gets the same address. On its first page, choose *Restore from backup*
and upload the backup. Going back to TrueNAS then needs the old disk's name back:
`sudo zfs rename Max/VMs/haos-vm Max/VMs/haos-vm-new && sudo zfs rename Max/VMs/haos-vm-truenas Max/VMs/haos-vm`.

DNS stays on the router during the cutover. Move it back to AdGuard when everything has been stable for a few
days.

## Going back

Boot TrueNAS from its USB drive, upload the configuration file, and import both pools. Files written since the
cutover are there; container data from before it is in the `before-nixos` snapshots:

```bash
sudo zfs rollback -r Max/docker/data@before-nixos     # loses everything containers wrote since
```

Keep the snapshots and the clone's origin for at least a month. `Max/docker-root` depends on its snapshot, so
delete neither until the clone has been promoted.
