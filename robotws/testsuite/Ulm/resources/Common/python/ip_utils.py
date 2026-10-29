from netaddr import valid_ipv4, valid_ipv6
from robot.api import logger


def is_valid_ipv4(ip_address):
    return valid_ipv4(ip_address.strip())


def is_valid_ipv6(ip_address):
    return valid_ipv6(ip_address.strip())


def is_valid_ip(ip_address):
    return (valid_ipv4(ip_address) or valid_ipv6(ip_address))


def should_be_valid_ip(ip_address):
    assert is_valid_ip(ip_address), "Error, this isn't a valid IP address: {!r} !".format(ip_address)
