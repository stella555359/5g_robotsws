__maintainer__ = "Jakub Wodzislawski"
__team__ = "MN RAN DCM Vrf WRO 2 SG"
__email__ = "jakub.wodzislawski@nokia.com"

from taf.config.testline.ue import Prisma
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.pdu import Gude

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.177.170", port_numbers=[2], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1221007365",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1210302282",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204505514",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1214008221",
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.18", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_keysight = Prisma(
    airmosaic_ssh_connection_details=SshServiceDetails(addr='10.42.75.18', username='ute', password='ute'),
    airmosaic_harness_connection_details=HttpConnectionDetails(addr='localhost', port=8090),
    lsu_uu_ssh_connection_details=SshServiceDetails(addr='10.42.221.141', username='user', password='user'),
    tstm_uu_ssh_connection_details=SshServiceDetails(addr='10.42.221.141', username='user', password='user'),
    )

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    pdus=[_pdu_gnb],
    ues=[_keysight]
)

setattr(tl, 'gnb_control_pc_user', 'ute')
setattr(tl, 'gnb_control_pc_pwd', 'ute')

setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')

setattr(tl, 'lmp_connection_username', 'toor4nsn')
setattr(tl, 'lmp_connection_pass', 'oZPS0POrRieRtu')

setattr(tl, 'gnb_ru_pdu_ip', ['10.44.177.170'])

setattr(tl, 'gnb_ru_pdu_outlet', [7, 8, 9, 10])

setattr(tl, 'keysight_host', '10.42.221.141')
setattr(tl, 'keysight_user', 'user')
setattr(tl, 'keysight_username', 'user')
setattr(tl, 'keysight_pass', 'user')
setattr(tl, 'keysight_pwd', 'user')
setattr(tl, 'mrbts_id', 1)

setattr(tl, 'ks_ctrl_pc', '10.42.63.237')

setattr(tl, 'lmp_connection_addr', '192.168.255.129')
setattr(tl, 'lmp_connection_username', 'toor4nsn')
setattr(tl, 'lmp_connection_pass', 'oZPS0POrRieRtu')
setattr(tl, 'mplane_addr', '172.16.11.200')
setattr(tl, 'gnb_control_pc_host', ['10.42.75.18'])
setattr(tl, 'ute_control_pc_host', ['10.42.75.18'])
