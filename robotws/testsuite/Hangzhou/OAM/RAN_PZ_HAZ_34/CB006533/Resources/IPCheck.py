import ipaddress


def check_ipv4(ip):
    try:
        ipaddress.IPv4Address(ip)
        return True
    except ValueError:
        return False


def check_ipv6(ip):
    try:
        ipaddress.IPv6Address(ip)
        return True
    except ValueError:
        return False
