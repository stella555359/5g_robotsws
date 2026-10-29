# -*- coding: utf-8 -*-
import socket
import fcntl
import struct


def get_local_ip(ifname):
    text = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    inet = fcntl.ioctl(text.fileno(), 0x8915, struct.pack('256s', bytes(ifname[:15], 'utf-8')))
    return socket.inet_ntoa(inet[20:24])
