import ipaddress


def FunIncrementIp(IPADDRESS, IPADDRESSES):
    """
    Increment IPv4 or IPv6 address by 1 and return list of addresses.
    """
    ip_list = []

    if ':' in IPADDRESS:
        IPADDRESS = str(IPADDRESS)
        IPADDRESSMOD = ipaddress.IPv6Address(IPADDRESS)
        print('this is ipv6 address')
    else:
        IPADDRESSMOD = ipaddress.IPv4Address(IPADDRESS)
        print('this is ipv4 address')

    IPADDRESSES = int(IPADDRESSES)
    end_address = IPADDRESSMOD + IPADDRESSES

    while IPADDRESSMOD < end_address:
        ip_list.append(str(IPADDRESSMOD))
        IPADDRESSMOD += 1

    print(ip_list)
    return ip_list


def Get_IP_Array(ip_list):
    """
    Pick every 4th IP from the given list.
    """
    result = []
    length = len(ip_list)

    for i in range(0, length, 4):
        result.append(ip_list[i])

    print(result)
    return result


def Get_IPaddress_array(IPADDRESS, IPADDRESSES):
    """
    Increment IPv4 or IPv6 address by step of 4.
    """
    ip_list = []

    if ':' in IPADDRESS:
        IPADDRESS = str(IPADDRESS)
        IPADDRESSMOD = ipaddress.IPv6Address(IPADDRESS)
        print('this is ipv6 address')
    else:
        IPADDRESSMOD = ipaddress.IPv4Address(IPADDRESS)
        print('this is ipv4 address')

    IPADDRESSES = int(IPADDRESSES)
    end_address = IPADDRESSMOD + IPADDRESSES

    while IPADDRESSMOD < end_address:
        ip_list.append(str(IPADDRESSMOD))
        IPADDRESSMOD += 4

    print(ip_list)
    return ip_list


def Get_expanded_ipv6(IPADDRESS):
    """
    Return expanded IPv6 address.
    """
    IPADDRESS = str(IPADDRESS)
    IPADDRESSMOD = ipaddress.IPv6Address(IPADDRESS)
    return IPADDRESSMOD.exploded
