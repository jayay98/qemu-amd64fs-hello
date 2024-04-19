#  QEMU-AMD64FS-HELLO

The helper script creates an AMD64 Filesystem image, that is based on TinyCore linux distro (http://tinycorelinux.net/). To simply create a bootable image, run 
```sh
wget https://raw.githubusercontent.com/jayay98/qemu-amd64fs-hello/main/run.sh
chmod +x ./run.sh
./run.sh
```

To launch the output disk image after creation:
```sh
LAUNCH=2 ./run.sh
```

To launch the QEMU with TinyCore kernel and modified initramdisk:
```sh
LAUNCH=1 ./run.sh
```

For debugging purpose, if you wish to keep all the intermediate files:
```sh
CLEAN=0 ./run.sh
```