def format_ip_address_if_ipv6(url):
    """
    This function checks if IP is in version 6, if it is then add square brackets before and after the IP.
    Parameter may start with http://, https:// or be without any prefix. Address passed to this function can
    also contain subpages.
    :param url: url address
    :return: url: formatted url if IPv6, else not changed url
    """

    def _does_address_start_with_http_or_https(url):
        return '://' in url

    def _is_address_ipv6_with_possible_subpages(address):
        return ':' in address and '/' in address

    def _is_ip_ipv6(ip):
        return ':' in ip

    if '[' in url and ']' in url:
        pass
    elif _does_address_start_with_http_or_https(url):
        split = url.split('/')
        if ':' in split[2]:
            split[2] = '[{}]'.format(split[2])
            url = '/'.join(split)
    elif _is_address_ipv6_with_possible_subpages(url):
        split = url.split('/')
        split[0] = '[{}]'.format(split[0])
        url = '/'.join(split)
    elif _is_ip_ipv6(url):
        url = '[{}]'.format(url)
    return url


def add_square_brackets_if_ipv6(address):
    if ":" in address:
        return "[{}]".format(address)
