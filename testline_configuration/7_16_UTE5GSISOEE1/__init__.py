__maintainer__ = "Zuzanna Wielkoszynska"
__team__ = "MN RAN RD VRF WRO 1 5"
__email__ = "zuzanna.wielkoszynska@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

__all__ = ["tl"]

_pdu_gnb = Gude(
    addr="10.44.205.234", port_numbers=[7, 10], model="EPC", version="8221-1"
)

_pdu_gnb_ru1 = Gude(
    addr="10.44.200.204", port_numbers=[1, 2, 3], model="EPC", version="8221-1"
)

_pdu_gnb_ru3 = Gude(
    addr="10.44.205.6", port_numbers=[1, 4, 6, 7, 8, 9], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHEGHA",
    serial_number="BL2346H659O",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[7],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHEGHA",
    serial_number="BL2345H64W2",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[4],
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHEGHA",
    serial_number="BL2346H659W",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[8],
)
_ru_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHPMDG",
    serial_number="BL2344C66KW",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[1],
)

_ru_5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHPMDG",
    serial_number="BL2344C66OJ",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[6],
)

_ru_6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHPMDG",
    serial_number="BL2344C66Q0",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[9],
)
_ru_7 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQL",
    serial_number="L1240202774",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[1],
)

_ru_8 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQL",
    serial_number="L1241408155",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[2],
)

_ru_9 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQL",
    serial_number="L1232908041",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[3],
)

_abio_1_primary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204806033",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)

_abio_2_primary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="DH221846665",
    rus=[_ru_4, _ru_5, _ru_6],
)

_abia_primary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1172904143",
    rus=[_ru_1, _ru_2, _ru_3],
)

_abio_secondary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204509709",
    rus=[_ru_7, _ru_8, _ru_9],
)

_asib_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_primary, _abio_2_primary, _abia_primary],
    pdu_port=_pdu_gnb.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="L1204301385",
)

_asib_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_secondary],
    pdu_port=_pdu_gnb.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="DH213637577",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_primary, _asib_gnb_secondary])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9],
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.32.142",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.42.88.66", vlan_id=571),
    x2u=NetworkAddress(v4="10.42.88.66", vlan_id=571),
    s1u=NetworkAddress(v4="10.42.88.66", vlan_id=571),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51200, instance_id=51200
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.211", username="ute", password="UTE.debian12"
    ),
    connections=[_asib_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.198", username="ute", password="UTE.debian12"
    ),
    connections=[_asib_gnb_secondary],
)

_appserver_ssh = TafUeAppServer(
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    app_server_name="APP_1",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
    version=3,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    # ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_2xASIB_3xABIO_ABIA_3xAVQL_3xAHEGHA_3xAHPMDG_ENB",
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru3],
)
