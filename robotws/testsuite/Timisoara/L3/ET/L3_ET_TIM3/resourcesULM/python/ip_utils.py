from netaddr import valid_ipv4, valid_ipv6


def is_valid_ipv4(ip_address):
    return valid_ipv4(ip_address)


def is_valid_ipv6(ip_address):
    return valid_ipv6(ip_address)


def is_valid_ip(ip_address):
    return (valid_ipv4(ip_address) or valid_ipv6(ip_address))


def should_be_valid_ip(ip_address):
    assert is_valid_ip(ip_address), "{} is not a valid ip".format(ip_address)
