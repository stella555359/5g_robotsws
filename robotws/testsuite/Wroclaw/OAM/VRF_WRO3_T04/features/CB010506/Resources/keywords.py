import os


def send_ping(ip_address):
    return os.system("ping -c 1 {0}".format(ip_address))


def send_ping_ipv6(ip_address):
    return os.system("ping -6 -c 1 {0}".format(ip_address))


def check_ping_status(ping_status, should_ping_works):
    if should_ping_works:
        if ping_status:
            raise ValueError("Error. According to parameter "
                             "icmpResponseEnabled=True ping to M-Plane IP "
                             "addres should work, but it does not work")
    else:
        if not ping_status:
            raise ValueError("Error. According to parameter "
                             "icmpResponseEnabled=False ping to M-Plane IP "
                             "addres should not work, but it works")
