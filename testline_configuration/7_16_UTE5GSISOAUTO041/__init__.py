__maintainer__ = "Robert Wsiaki"
__team__ = "5G_PZ_1_WRO_4_SG"
__email__ = "robert.wsiaki@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.46.185",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.44.46.173", vlan_id=332),
    x2u=NetworkAddress(v4="10.44.46.173", vlan_id=332),
    s1u=NetworkAddress(v4="10.44.46.173", vlan_id=332),
)

_pdu_gnb = Gude(addr="10.45.167.61", port_numbers=[3], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.45.167.61", port_numbers=[1, 2], model="EPC", version="8221-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AHEGA",
    serial_number="K9182603839",
    product_code="473995A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128",
        username="root",
        password="",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[2],
)

_gnb_ru_2 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FXED",
    serial_number="1M192000032",
    product_code="472924A.203",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.128",
        username="",
        password="",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[1],
)


_abia_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="A104",
    serial_number="DH195291130",
    rus=[_gnb_ru_1, _gnb_ru_2],
)

_abio_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1222103982",
    rus=[_gnb_ru_1],
)


_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abio_1],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="DH214044583",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.113", username="ute", password="uteUTE!"
    ),
    connections=[_asib_gnb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=40615, instance_id=40615
)

_core = RealCore5G()

_airscale_enb_1 = Airscale(common_units=[_asib_gnb_1])

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_Server_WG",
    address="10.44.184.246",
    user="ranpz",
    password="Pass4Testers!",
)

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    ue_pc_address="10.45.165.142",
    serial_number="HZQN1876AAKA1500044",
    ssh_connection_details=SshServiceDetails(
        addr="10.45.165.142", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    data_transfer=[_nokia_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    is_rooted=True,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBR_ABIAR_ABIOR_AHEGA_FXED_GNB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru_1],
)
