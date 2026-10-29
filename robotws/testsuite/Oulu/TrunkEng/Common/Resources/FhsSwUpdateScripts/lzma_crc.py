#!/usr/bin/env python3

import zlib
import sys
import re
import os


def checksum(lzma_name):
    with open(lzma_name, "rb") as f:
        return zlib.adler32(f.read())


def parse(lzma_path, build_name):
    lzma_name = os.path.basename(lzma_path)
    digits = re.search(r'[0-9]+', lzma_name)[0]
    version = digits[:8] + '.' + digits[-1]
    print(f"Version: {version}")
    # print(checksum(lzma_path),  build_name, lzma_name, version)
    print(checksum(lzma_path))
    # SWmanShellCommand -s <fileName> <checksum> <fileVersion> <fileType>
    # print(
    #    f'SWmanShellCommand -s /run/swman/{lzma_name} {checksum(lzma_path)} {version} ""'
    # )
    # SWmanShellCommand -a <bldName> <bldVersion> <fileName> <fileVersion>
    # print(
    #    f'SWmanShellCommand -a {build_name} {build_name} {lzma_name} {version}'
    # )


USAGE = """
Usage:
    swman_cmds.py <lzma_path> <build_name>
    swman_cmds.py FHS-OD-SW_20220311084931.tar.lzma FHS22.03.R02
"""

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(USAGE)
    else:
        print(checksum(sys.argv[1]))
