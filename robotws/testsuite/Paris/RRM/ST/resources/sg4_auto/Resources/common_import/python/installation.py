import sys


def has_a_tty():
    """ Check if has connected tty device for yaft"""
    return sys.stdin.isatty()
