def Spliting_rate(text):
    d = text.split('rate limit: ')[1].split(',')[0]
    return d


def Spliting_filter(text):
    d = text.split('filter: ')[1].split(',')[0]
    return d


def Spliting_total(text):
    d = text.split('total: ')[1].split(' =')[0]
    return d


def Absolute_Value(value):
    b = abs(value)
    return b


def Get_IP_after_lease(lease_string):
    return lease_string.split("lease ")[1].split(" {")[0]


def Get_string_after_dev(dev_string):
    return dev_string.split("dev ")[1].split(" lladdr")[0]


def Get_mac_after_lladdr(lladdr_string):
    return lladdr_string.split("lladdr ")[1].split(" STALE")[0]
