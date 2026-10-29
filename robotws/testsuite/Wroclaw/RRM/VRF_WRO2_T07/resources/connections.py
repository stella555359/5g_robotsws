import re
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

_ssh = ssh()


@logged_keyword
def connect_to_smod(container='master', connection_alias='smod_connection'):
    smod_master = _ssh.connect_to(hostname=get_smod_ip('master'),
                                  username=tl.gnbs[0].cu.oam_ssh_connection_details.username,
                                  password=tl.gnbs[0].cu.oam_ssh_connection_details.password,
                                  alias=connection_alias + '_master_proxy')

    return _ssh.connect_to(hostname=get_smod_ip(container),
                           username=tl.gnbs[0].cu.oam_ssh_connection_details.username,
                           password=tl.gnbs[0].cu.oam_ssh_connection_details.password,
                           proxy=smod_master,
                           alias=connection_alias + '_' + container)


@logged_keyword
def connect_to_bbmod(container='master', connection_alias='bbmod_connection'):
    hostname = get_bbmod_ip(container)
    return _ssh.connect_to(hostname=hostname,
                           username=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username,
                           password=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password,
                           proxy=connect_to_smod(),
                           alias=connection_alias + '_' + container)


@logged_keyword
def connect_to_test_pc(connection_alias='test_pc_connection'):
    return _ssh.connect_to(hostname=tl.test_pc.default_ssh_connection_details.addr,
                           username=tl.test_pc.default_ssh_connection_details.username,
                           password=tl.test_pc.default_ssh_connection_details.password,
                           alias=connection_alias)


@logged_keyword
def connect_to_uepc(ue_id=0, connection_alias='uepc_connection'):
    return _ssh.connect_to(hostname=tl.ues[ue_id].ssh_connection_details.addr,
                           username=tl.ues[ue_id].ssh_connection_details.username,
                           password=tl.ues[ue_id].ssh_connection_details.password,
                           alias=connection_alias)


@logged_keyword
def connect_to_appserver(connection_alias='appserver_connection'):
    return _ssh.connect_to(hostname=tl.test_pcs[1].address,
                           username=tl.test_pcs[1].user,
                           password=tl.test_pcs[1].password,
                           alias=connection_alias)


@logged_keyword
def connect_to_enb(enb_id=0, connection_alias='enb_connection'):
    return _ssh.connect_to(hostname=tl.enbs[enb_id].oam_ip.v4,
                           username='toor4nsn',
                           password='oZPS0POrRieRtu',
                           alias=connection_alias)


def connect_to_enb_pc(enb_id=0, connection_alias='enb_pc_connection'):
    return _ssh.connect_to(hostname=tl.enb_pc_ip,
                           username='ute',
                           password='ute',
                           alias=connection_alias)


@logged_keyword
def get_bbmod_ip(container):
    connect_to = {'master': 0, 'slave': 1, 'loner': 2, 'loner2': 3, 'loner3': 4}
    container_id = connect_to[container.lower()]
    return tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[container_id].addr


@logged_keyword
def get_smod_ip(container):
    connect_to = {'master': tl.gnbs[0].cu.oam_ssh_connection_details.addr, 'slave': '192.168.253.2',
                  'loner': None, 'loner2': None, 'loner3': None}
    # TODO: Find a suitable place for SMOD IPs in init
    return connect_to[container.lower()]


@logged_keyword
def disconnect(connection):
    return _ssh.disconnect(connection)


@logged_keyword
def connect_to_ru(ru_ip='192.168.254.52', username='root',
                  password='umniedziala', proxy='asik', connection='ru'):
    container_connection = check_if_connection_through_lxc_is_enabled(proxy)
    if container_connection is True:
        kw_proxy = 'fhnet_container'
        connect_to_fhnet_container(proxy=proxy)
    else:
        kw_proxy = proxy
    rmod_connection = _ssh.connect_to(hostname=ru_ip, username=username,
                                      password=password, proxy=kw_proxy,
                                      alias=connection)
    return rmod_connection


@logged_keyword
def connect_to_fhnet_container(fhnet_host_ip='192.168.255.254', proxy='asik', connection='fhnet_container'):
    containers = _ssh.execute('lxc-ls', connection=proxy)
    fhnet_container = get_fhnet_container(containers)
    _ssh.send_command('rm -rf /tmp/sshd_debug.log', connection=proxy)
    _ssh.send_command('lxc-attach -n {} -- /usr/sbin/sshd -p 22 -f /dev/null'
                      ' -o "PermitRootLogin yes" > /tmp/sshd_debug.log'.format(fhnet_container), connection=proxy)
    _ssh.connect_to(hostname=fhnet_host_ip,
                    username=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username,
                    password=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password,
                    proxy=proxy,
                    alias=connection)


@logged_keyword
def check_if_connection_through_lxc_is_enabled(connection):
    containers = _ssh.execute('lxc-ls', connection=connection)
    if get_fhnet_container(containers):
        return True
    else:
        return False


@logged_keyword
def get_fhnet_container(containers):
    match = re.match(r'0x[12]018', containers)
    if match:
        return match[0]
