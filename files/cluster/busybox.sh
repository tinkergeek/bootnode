#!/bin/bash

cd /cluster/busybox
find . -print0 | cpio --null -ov --format=newc | gzip --fast > /tftpboot/busybox.gz

