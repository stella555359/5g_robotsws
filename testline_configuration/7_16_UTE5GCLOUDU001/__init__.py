# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "michal.piechowski@nokia.com"
__email__ = "michal.piechowski@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.ue import Android
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB


_pdu_1 = Gude(
    addr="10.44.177.65",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.44.205.198",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_3 = Gude(
    addr="10.44.206.155",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_4 = Gude(
    addr="10.44.72.148",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA205155518",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA215050331",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2217N402H",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192301678",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1232908043",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.50.2", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.50.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    radio_type=RadioTypes.AZQP.value,
    serial_number="1M203665216",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.50.162", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
# LTE
_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="103",
    product_code="473096A.103",
    serial_number="L1173405497",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="103",
    product_code="473096A.103",
    serial_number="L1173313648",
    rus=[],
)
# NR
_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="104",
    product_code="475266A.104",
    serial_number="L1214403587",
    rus=[_rmod_1, _rmod_2, _rmod_4, _rmod_5],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABI0",
    hardware_version="101",
    product_code="475266A.101",
    serial_number="L1204304785",
    rus=[_rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="101",
    serial_number="L1164621019",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="102",
    serial_number="L1213511626",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.44.95.118"),
    instance_id=8073,
)
_du_1 = DU(_smod_2, rus=[_rmod_1, _rmod_2, _rmod_4, _rmod_5, _rmod_6, _rmod_7])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.95.119"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)
_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=6104, instance_id=6104)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.165", username="ute", password="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.166", username="ute", password="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.197.180", username="4g5giwk", password="4g5giwk"
    ),
    network_interface_address="10.42.197.180",
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.233", username="sranwro2", password="Ru1eTheAir!2"
)

_qualcomm = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="fc7658e6",
    server_dir="C:/taf_proxy",
    python_path="C:/Program Files/Python38/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/taf_proxy/DIAG.cfg",
    iperf_details=_iperf_ue,
    capabilities=["REAL_ANDROID_UE"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_1],
    ues=[_qualcomm],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_4xANDROID_ASIL_2xABIO_ABIL_ASIA_2xABIA_2xAHEGC_AZQH_AHFII_AHIB_FHFB_AVQL_AZQP",
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4],
)

__all__ = ["tl"]