#!/bin/bash

cd /cluster/root_fs
tar cf - . | xz -z -9 -e -T 0 -c -k > /cluster/image/image.tar.xz

