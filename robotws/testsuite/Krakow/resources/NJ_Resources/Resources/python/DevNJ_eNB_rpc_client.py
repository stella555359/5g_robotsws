from robot.libraries.Remote import Remote


def run_rpc_keyword(ipaddr, name, *args, **kwargs):
    url = "http://{}:8270".format(ipaddr)
    rpc = Remote(url, "60 minute")
    return rpc.run_keyword(name, args, kwargs)
