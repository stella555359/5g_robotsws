__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"


import os, sys
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Connection, CUS

use_cbts = 'false'
for arg in sys.argv:
    if arg.startswith('USE_CBTS:'):
        use_cbts = arg.split(':')[1]

use_cbts = use_cbts.lower() == 'true'

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.1.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.1.2", username="Nemuadmin", password="nemuuser"

    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = ATEN(
    addr="10.42.168.169",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=7)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])
_enb = RealEnb(
    system_module=_airscale,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
)


_ru_pdu = ATEN(
    addr="10.42.170.97",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)


_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=1)

_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[None],
    pdu_port=_ru_pdu_port,
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

_ru = RU(
    ru_hw_group="CUS",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.200.126", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(addr="192.168.200.126", username="toor4nsn", password="oZPS0POrRieRtu"),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="192.168.255.129")

_cbts = ClassicalBts(cu=_cu, dus=[_du])


_cus = Android(
    ssh_connection_details=SshServiceDetails(
        addr="192.168.200.126", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    serial_number=None,
    server_dir=None,
    python_path=None,
    imsi="cus",
    capabilities=['_4G'],
)

_cus.ue_type = "cus"

## copying from QT_4G_FDD_FSMF_CUS_WRO_3134
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu_1 = ATEN(
    addr="10.42.168.169",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_2 = ATEN(
    addr="10.42.170.97",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.18", hardware_type="FBBC", pdu_port=_pdu_1.pdu_ports[7]
        ),
        CapacityUnit(
            addr="192.168.253.19", hardware_type="FBBC", pdu_port=_pdu_1.pdu_ports[7]
        ),
    ],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="FSMF",
)

enb_airscale_1 = Airscale([_enb_common_unit1])

enb_1 = RealEnb(
    system_module=enb_airscale_1,
)

cus_capacity_unit_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
)

cus_common_unit_1 = CommonUnit(
    SshServiceDetails(addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[cus_capacity_unit_1],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIA",
)

cus_airscale_1 = Airscale([cus_common_unit_1])

cus_ue_1 = CUS(l1=cus_airscale_1, trs_ip="10.0.2.2")
## end of copying from QT_4G_FDD_FSMF_CUS_WRO_3134

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.158.111", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=enb_1.system_module.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=cus_ue_1),
    ],
)

if use_cbts:
    selected_enbs = [_cbts]
    selected_topology = "3134"
    selected_ues = [_cus]
else:
    selected_enbs = [enb_1]
    selected_topology = "CLOUD_FCC_CUS_A"
    selected_ues = [cus_ue_1]

tl = TestLine(
    test_pc=_test_pc,
    ues=selected_ues,
    enbs=selected_enbs,
    tl_cloud_topology=selected_topology,
)

tl.target_traffic_4G = {
    "MAX_DL": "15", #Mbits/sec
    "MAX_UL": "7", #Mbits/sec
    "IPERF_DURATION": "120", #seconds
}

tl.scf_variables = {
    "btsName": "QT-FSMF_FBBC_4G_FDD_CUS-WRO-3134",
}

__all__ = ["tl"]
