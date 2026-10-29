from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.utilities.tl_config import get_oam_ip_address

oam_ip_address = get_oam_ip_address()


@load_moler_configuration_from_tl()
def block_nms(gnb_id=0, du_id=0):
    """
    Block nms ports.

    :return: None
    """
    du = DeviceFactory.get_device(name=connection_names.ssh_bts_du.format('GNB', gnb_id, du_id),
                                  initial_state="PROXY_PC")
    du.set_fct_address(address=oam_ip_address)
    du.goto_state("FCT")
    cmds = ['iptables -A INPUT -p tcp --dport 8443 -j REJECT',
            'iptables -A INPUT -p tcp --dport 8080 -j REJECT',
            'iptables -A OUTPUT -p tcp --dport 8443 -j REJECT',
            'iptables -A OUTPUT -p tcp --dport 8080 -j REJECT',
            ]
    for cmd in cmds:
        du.get_cmd(cmd_name="run_script", cmd_params={'script_command': cmd})()


@load_moler_configuration_from_tl()
def unblock_nms(gnb_id=0, du_id=0):
    """
    Unblock nms ports.

    :return: None
    """
    du = DeviceFactory.get_device(name=connection_names.ssh_bts_du.format('GNB', gnb_id, du_id))
    cmd = 'iptables -F'
    du.get_cmd(cmd_name="run_script", cmd_params={'script_command': cmd})()
