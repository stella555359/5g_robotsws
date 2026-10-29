from taf.hw.switch import switch

switch_instance = switch()
nokia_tps = None


def connect_to_switch(hostname, username, password, type='nokia1830tps', port=None, alias=None):
    global nokia_tps
    nokia_tps = switch_instance.connect_to(hostname=hostname,
                                           username=username,
                                           password=password,
                                           type=type,
                                           port=port,
                                           alias=alias)


def config_port_sync_down(port):
    global nokia_tps
    nokia_tps.config_port_sync_down(port=port)
    return nokia_tps.is_port_sync_up(port=port)


def config_port_sync_up(port):
    global nokia_tps
    nokia_tps.config_port_sync_up(port=port)
    return nokia_tps.is_port_sync_up(port=port)
