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
from taf.config.testline.pdu import PduPort, Gude
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

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_du_pdu = Gude(
    addr="10.44.71.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=5)

### ENB
_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
    hardware_type="ASIA",
)

_airscale = Airscale(common_units=[_du_common_unit])
_enb = RealEnb(
    system_module=_airscale,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
)


## CUS1
_ru_pdu = Gude(
    addr="10.44.71.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=3)

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

## copying from QT_4G_FDD_AIRSCALE_CUS_WRO_3155
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu_1 = Gude(
    addr="10.44.71.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
airscale_1_capacity_unit_fbip1 = CapacityUnit(addr="127.0.0.2", hardware_type="ABIA")
airscale_1_common_unit = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[airscale_1_capacity_unit_fbip1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
)

enb_airscale_1 = Airscale([airscale_1_common_unit])

enb_1 = RealEnb(
    system_module=enb_airscale_1,
)

cus_capacity_unit_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
)

cus_capacity_unit_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
)

cus_capacity_unit_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
)

cus_common_unit_1 = CommonUnit(
    SshServiceDetails(addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[cus_capacity_unit_1, cus_capacity_unit_2, cus_capacity_unit_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
)

cus_airscale_1 = Airscale([cus_common_unit_1])

cus_ue_1 = CUS(l1=cus_airscale_1, trs_ip="10.0.2.2")
## end of copying from QT_4G_FDD_AIRSCALE_CUS_WRO_3155

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.186.29", username="ute", password="UTE.debian12"
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
    selected_topology = "3159"
    selected_ues = [_cus]
else:
    selected_enbs = [enb_1]
    selected_topology = "CLOUD_R4A_CUS"
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
    "btsName": "QT-ASIA_ABIA_4G_FDD_CUS-WRO-3159",
    "bbmod_1_prodcode": "473096A.102",
}

__all__ = ["tl"]
