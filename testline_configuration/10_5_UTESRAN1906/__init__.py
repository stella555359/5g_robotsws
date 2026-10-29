__maintainer__ = "Yuyan Xu"
__email__ = "yuyan.xu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, RRB, APC, Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    Android,
    Qualcomm,
    QualcommUeType,
)

_pdu_1 = FPFH(
    addr="10.106.253.28",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_2 = FACOM(addr="10.106.253.6", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_3 = FACOM(addr="10.106.253.37", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_4 = FPFH(
    addr="10.106.253.19",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_5 = FPFH(
    addr="10.106.253.38",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)

#  iperf server info   #liu server 10.108.229.121 ute ute
_appserver_ssh = SshServiceDetails(
    # addr="10.106.245.10", username="Oper1", password="Nokia@123"
    addr="10.108.229.121",
    username="ute",
    password="ute",
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    # network_interface_address="10.106.243.149",
    # network_interface_address="10.106.245.10",
    network_interface_address="10.108.229.121",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="50017",
    # dl pass 50017 50018 5001
    # port="50015",
)

_appserver = AppServer(_iperf)


huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.106.253.24", username="Oper1", password="Nokia@123"
    ),
    serial_number="JJ6975PNCUV4BYEU",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei_mate40"],
)

_attenuator_5G = TopYoung(
    ip_addr="10.106.253.18",
    port=1000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9],
    model="PA-8-2-4-127-0.5-B-S",
)


_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M220739542",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[2],
        _attenuator_5G.attenuator_ports[3],
        _attenuator_5G.attenuator_ports[4],
        _attenuator_5G.attenuator_ports[5],
        _attenuator_5G.attenuator_ports[6],
        _attenuator_5G.attenuator_ports[7],
        _attenuator_5G.attenuator_ports[8],
        _attenuator_5G.attenuator_ports[9],
    ],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M220739523",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M220739536",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.22", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA223860461",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA223860409",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA213059703",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[3],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M212300074",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_8 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2333H60JK",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2334H60LQ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[4],
)

_rmod_10 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2334H60LG",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[6],
)

_rmod_11 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M212306542",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.14", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_12 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M211713212",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.18", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220503795",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_8, _rmod_9, _rmod_10],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220402380",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_3.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1221903652",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod_1 = Flexi([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
    oam_ip=NetworkAddress("10.106.253.141"),
    instance_id=1906,
)


_rnc = RNC(
    rnc_id=511,
    oms_ip=NetworkAddress("10.68.171.228"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.69.28.173", username="root", password="root"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.107.151.137", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.245.29", username="ute"
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

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[huawei1],
    attenuator=_attenuator_5G,
    appserver=_appserver,
)

__all__ = ["tl"]
