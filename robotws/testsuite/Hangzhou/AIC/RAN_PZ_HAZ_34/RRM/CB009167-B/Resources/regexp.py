import re


def regexp_containerid(id):
    containerid = re.findall('//\\w*', id)[0].lstrip('//')
    return containerid


def regexp_pid(id):
    pid = re.findall('\\s\\w*', id)[0].lstrip(' ')
    return pid


def hex_to_oct(i):
    s = hex(int(i))[2:]
    return s
