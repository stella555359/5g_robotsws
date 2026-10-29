__maintainer__ = "HZ OAM"
__team__ = "MN_RAN_HAZ_PZ1_T05"
__email__ = "xiaofei.chen@nokia-sbell.com"
__owner_email__ = "xiaofei.chen@nokia-sbell.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline import RU
from taf.config.testline.core import (
    RealCore,
    RealCore5GDetails,
    AMF,
    RealCore4GDetails,
    MME,
)
from taf.config.testline.airscale import (
    Airscale,
    CommonUnit,
    CapacityUnit,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.pdu import ENICS
from taf.config.testline.pdu import Gude
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.sync_input import ToPServer
###############################################
# UTE HAZ LTE-NR RF Sharing Testline         #
###############################################
# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))
# Radio units
_radio_pdu_1 = Gude(
    addr="10.106.243.48",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model='FPFH',
)
_radio_pdu_2 = Gude(
    addr="10.106.243.45",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_radio_pdu_3 = Gude(
    addr="10.106.243.42",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_radio_pdu_4 = Gude(
    addr="10.106.243.43",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AHFIB",
    pdu_port=_radio_pdu_1.pdu_ports[1],
    serial_number="BL2039V0MER",
    product_code="474216A.101",
)
_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AHLOA",
    pdu_port=_radio_pdu_3.pdu_ports[1],
    serial_number="BL1930G11PO",
    product_code="474331A.101",
)
_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2032G1GQY",
    pdu_port=_radio_pdu_1.pdu_ports[6],
    product_code="474331A.101",
)
_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2243G1BHZ",
    pdu_port=_radio_pdu_2.pdu_ports[4],
    product_code="474331A.101",
)
_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.154", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1204708748",
    pdu_port=_radio_pdu_4.pdu_ports[1],
    product_code="475124B.M01",
)
_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1202503112",
    pdu_port=_radio_pdu_2.pdu_ports[3],
    product_code="475124A.101",
)
_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.10", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1203007271",
    pdu_port=_radio_pdu_2.pdu_ports[5],
    product_code="475124B.101",
)

###############################################
# MRBTS-11214 SBTS Side                                     #
###############################################
# Power breakers
_bbu_pdu_2 =Gude(
    addr="10.106.243.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_radio_units_SBTS = [_ru_1, _ru_2, _ru_3, _ru_4]
# NR Cloud Unit
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9173315738",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172422490",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA174622922",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_bbu_pdu_2.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203864257",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_bbu_pdu_2.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="EA173863750",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])

_ru_cablinks_SBTS = [
    Cablink(
        source=Endpoint(unit=_fsp_1, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_2, label="SFP", port_id=3),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_2, label="SFP", port_id=4),
        target=Endpoint(unit=_ru_3, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_2, label="SFP", port_id=5),
        target=Endpoint(unit=_ru_4, label="SFP", port_id=1),
    ),
]
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3, _ru_4],
    cablinks=_ru_cablinks_SBTS,
    oam_ip=NetworkAddress("10.68.195.140"),
    instance_id=11214,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(
    rnc_id=301,
    oms_ip=NetworkAddress("10.70.119.30"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.70.119.30", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_1",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.70.120.17", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.195.163", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.195.164", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
###############################################
# MRBTS-11186 5G Side                                    #
###############################################
# Power breakers
_bbu_pdu_1 = Gude(
    addr="10.106.243.47",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_rus_enb = [_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7]
# 5G baseband module
_nr_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="474020A.102",
    serial_number="DH200160092",
)
_nr_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="474020A.102",
    serial_number="EA200950267",
)
_nr_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="474020A.102",
    serial_number="EA200950280",
)
_nr_fsp_4 = CapacityUnit(
    addr="none",
    hardware_type="FBBA",
    hardware_version="475266A.101",
    serial_number="L1204008424",
)

_nr_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_bbu_pdu_2.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1223516637",
)
_nr_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_nr_fsp_4],
    pdu_port=_bbu_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224807366",
)

_nr_smod_1 = Airscale([_nr_fct_1])
_nr_smod_2 = Airscale([_nr_fct_2])

_ru_cablinks_5G = [
    Cablink(
        source=Endpoint(unit=_nr_fsp_1, label="SFP", port_id=4),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_1, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_1, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_3, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_2, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_4, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_4, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_5, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_4, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_5, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_4, label="SFP", port_id=3),
        target=Endpoint(unit=_ru_6, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_4, label="SFP", port_id=7),
        target=Endpoint(unit=_ru_6, label="SFP", port_id=2),
    ),
        Cablink(
        source=Endpoint(unit=_nr_fsp_4, label="SFP", port_id=8),
        target=Endpoint(unit=_ru_7, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_nr_fsp_4, label="SFP", port_id=9),
        target=Endpoint(unit=_ru_7, label="SFP", port_id=2),
    ),
]
_gnb_sbts_1 = RealEnb(
    system_module=_nr_smod_1,
    rms=_rus_enb,
    cablinks=_ru_cablinks_5G,
    oam_ip=NetworkAddress("10.68.195.132"),
    instance_id=11186,
)
_gnb_sbts_2 = RealEnb(system_module=_nr_smod_2, rms=[],cablinks=_ru_cablinks_5G, master=_gnb_sbts_1)
_gnb_sbts_1.slave = _gnb_sbts_2

_test_pc_nr_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.195.162", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_nr_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.195.165", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
###############################################
# MRBTS-2498 Side                                    #
###############################################
_rus_enb_lte = [_ru_5, _ru_6, _ru_7]

# LTE BTS
_lte_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIC",
    hardware_version="473096A.102",
    serial_number="EA194354101",
)
_lte_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="475266A.103",
    serial_number="6Q191229795",
)
_lte_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIC",
    hardware_version="474824A.103",
    serial_number="6Q194300519",
)
_lte_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_lte_fsp_1, _lte_fsp_2, _lte_fsp_3],
    pdu_port=_radio_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH211963906",
)
_lte_smod_1 = Airscale([_lte_fct_1])
_ru_cablinks_4G = [
    Cablink(
        source=Endpoint(unit=_lte_fsp_1, label="SFP", port_id=5),
        target=Endpoint(unit=_ru_5, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_lte_fsp_1, label="SFP", port_id=6),
        target=Endpoint(unit=_ru_5, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_lte_fsp_2, label="SFP", port_id=5),
        target=Endpoint(unit=_ru_6, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_lte_fsp_2, label="SFP", port_id=6),
        target=Endpoint(unit=_ru_6, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_lte_fsp_3, label="SFP", port_id=5),
        target=Endpoint(unit=_ru_7, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_lte_fsp_3, label="SFP", port_id=6),
        target=Endpoint(unit=_ru_7, label="SFP", port_id=2),
    ),
]
_enb_lte_1 = RealEnb(
    system_module=_lte_smod_1,
    rms=_rus_enb_lte,
    cablinks=_ru_cablinks_4G,
    oam_ip=NetworkAddress("10.106.243.22"),
    instance_id=2498,
)

_test_pc_lte_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.195.161", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

# Testline
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_lte_1, _test_pc_nr_1, _test_pc_lte_1],
    gnbs=[_gnb_sbts_1, _gnb_sbts_2],
    enbs=[_enb_sbts_1, _enb_sbts_2, _enb_lte_1],
    bscs=[_bsc],
    rncs=[_rnc],    
    tl_cloud_topology="CLOUD_SRAN_LWG_ASIB_2ABIA_FSMF_FBBC_3xAHLOA_AHFIB_11214_RFS",
)
__all__ = ["tl"]
