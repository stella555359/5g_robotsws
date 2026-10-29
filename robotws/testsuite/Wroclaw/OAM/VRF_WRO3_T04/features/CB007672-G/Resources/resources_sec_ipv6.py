def get_trs_ipv6_route(ipv6_address):
    ipv6_route = ipv6_address[:-1]+str(int(ipv6_address[-1:])+1)
    return ipv6_route
