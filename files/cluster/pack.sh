#!/bin/bash

cd /cluster/image
find . -print0 | cpio --null -ov --format=newc | gzip --fast > /tftpboot/initramfs.gz

