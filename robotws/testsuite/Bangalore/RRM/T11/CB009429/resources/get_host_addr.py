import time
from taf.ul.ue.sim.env_setup.ute_config_loader import get_ute_tl_config


def get_host_addr():
    tl, _ = get_ute_tl_config()
    host_id1 = tl.test_pcs[0].default_ssh_connection_details.addr
    host_id2 = tl.test_pcs[1].default_ssh_connection_details.addr
    return host_id1, host_id2
