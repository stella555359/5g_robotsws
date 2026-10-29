# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Rashmi R
:contact: rashmi.r@nokia.com
:maintainer: Rashmi R
:contact: rashmi.r@nokia.com
"""
from filetype import guess
from pathlib import Path
from subprocess import PIPE, run


def _unzip(tmp_dir, file_name):
    run(["unzip", "-n", file_name], cwd=tmp_dir)
    run(["rm", file_name], cwd=tmp_dir)


def _unxz(tmp_dir, file_name):
    stderr = run(["unxz", file_name], cwd=tmp_dir, stderr=PIPE).stderr
    if b"Compressed data is corrupt" in stderr:
        run(
            f"unxz -d '{file_name}' > _ ; mv _ '{file_name}'",
            shell=True,
            cwd=tmp_dir)


def _gunzip(tmp_dir, file_name):
    stderr = run(["gunzip", file_name], cwd=tmp_dir, stderr=PIPE).stderr
    if b"unknown suffix -- ignored" in stderr:
        run(
            f"gzip -dc '{file_name}' > _ ; mv _ '{file_name}'",
            shell=True,
            cwd=tmp_dir)


def _untar(tmp_dir, file_name):
    run(["tar", "xvf", file_name], cwd=tmp_dir)
    run(["rm", file_name], cwd=tmp_dir)


_unpack_funcs = {
    "application/zip": _unzip,
    "application/x-xz": _unxz,
    "application/gzip": _gunzip,
    "application/x-tar": _untar,
}


def unpack(path):
    path = Path(path)
    try:
        file_type = guess(path)
    except PermissionError:
        file_type = None
    if not file_type:
        return
    unpack_func = _unpack_funcs.get(file_type.mime)
    if not unpack_func:
        return
    tmp_dir = path.parent / "_"
    tmp_dir.mkdir()
    new_path = tmp_dir / path.name
    path.rename(new_path)
    unpack_func(tmp_dir, path.name)
    tmp_dir.rename(path)
    for file_path in filter(Path.is_file, path.rglob("*")):
        unpack(file_path)
