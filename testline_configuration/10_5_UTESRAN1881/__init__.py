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

_pdu_1 = FACOM(addr="10.106.245.166", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_2 = FACOM(addr="10.70.14.75", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])


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
        addr="10.106.245.10", username="Oper1", password="Nokia@123"
    ),
    serial_number="H4K5T21108009488",
    # serial_number="7TD5T21715003750",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei_mate40"],
)

_attenuator_5G = TopYoung(
    ip_addr="10.106.245.22",
    port=1000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9],
    model="PA-8-2-4-127-0.5-B-S",
)

_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M204902619",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
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
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M214905136",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.10", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZQI.value,
    serial_number="1M223213317",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210855855",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210855854",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210855850",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190504708",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="K9202403987",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA220152474",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA213555279",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_14 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M220107706",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.49.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_15 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M220107703",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.49.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206788",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901167",
    rus=[_rmod_9, _rmod_14, _rmod_15],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206669",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1221903649",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
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
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_14,
        _rmod_15,
    ],
    # oam_ip=NetworkAddress("10.69.236.241"),
    oam_ip=NetworkAddress("10.106.245.7"),
    instance_id=1881,
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
        addr="10.106.245.28", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[huawei1],
    attenuator=_attenuator_5G,
    appserver=_appserver,
)

__all__ = ["tl"]
