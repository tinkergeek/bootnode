# Bootnode

## Introduction

Run this Ansible playbook on a freshly installed Rocky 8 server. It needs to have two networks: public and private. Connect your compute nodes to the private network. This can be a home router and a dumb switch. Two switches or VLANs or whatever you want really.

On first execution, it will download and create a compute node image and a failsafe busybox image. There are two compute nodes defined (node-000 and node-001) which boot one of the images. **This process could take a while.**

If you are using real hardware then you must add your hardware's boot MAC addresses to dhcpd.conf.

If you want to do this with qemu and VDE:
```
# Run this daemon: (provide a private Ethernet network)
vde_switch -d -s /tmp/vde.ctl -M /tmp/mgmt

# Boot the headnode: (note net1 and net2)
qemu-system-x86_64 -accel kvm \
    -cpu host \
    -smp 4 \
    -m 8192 \
    -netdev user,id=net1 -device virtio-net-pci,netdev=net1 \
    -netdev vde,sock=/tmp/vde.ctl,id=net2 -device virtio-net-pci,netdev=net2 \
    -drive file=Rocky-8-GenericCloud-Base.latest.x86_64.qcow2,if=virtio 

# Boot node-000: (no storage)
qemu-system-x86_64 -accel kvm \
    -cpu host \
    -smp 2 \
    -m 4096 \
    -net nic,model=virtio,macaddr=fc:ab:14:e8:66:01 -net vde,sock=/tmp/vde.ctl

# Boot node-001: (these fake MAC addresses are already in dhcpd.conf)
qemu-system-x86_64 -accel kvm \
    -cpu host \
    -smp 2 \
    -m 4096 \
    -net nic,model=virtio,macaddr=fc:ab:14:e8:66:02 -net vde,sock=/tmp/vde.ctl
```

## Compute Image

Making the compute image happens in three steps:

1. `dnf` puts a minimal Rocky 8 operating system into /cluster/root_fs
  Make customizations to the image here
2. Then we create a tarball of the image
  If the first script works properly then `xz` is used to make the image as small as possible
3. We pack up our init script, busybox binary, and tarball into our ramdisk image
  This step is separate so that init ram files can be changed independently of the OS image

## Compute Node Booting

1. Server BIOS/EFI executes some built-in PXE boot loader, somehow
2. Bare PXE will DHCP to get networking information from `dhcpd`
3. Bare PXE will use TFTP to download the iPXE binary from `tftp-server`
4. iPXE will DHCP *again* which will get a boot script (written in iPXE's scripting language)
  Note that if your hardware uses iPXE as its built-in loader (like Mellanox's host adapters or a qemu VM) then you might start the process here
5. iPXE will use HTTP to download the Linux kernel and ramdisk image to boot
6. Linux will boot using our init script
7. Init will execute by busybox's interpreter to set up a tmpfs file system
8. Init will uncompress the root image into the tmpfs
9. Finally Init launches the image's own init system
10. Systemd will start and the node boots as normal... out of RAM
  If the kernel file at /tftpboot/vmlinuz matche the kernel modules found in the image (the node booted with the correct kernel) then systemd will happily piece together the system even though the initial ramdisk environment loaded squat in terms of hardware drivers

