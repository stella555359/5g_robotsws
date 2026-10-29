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


# _pdu_1 = Gude(addr="10.69.14.82", port_numbers=[4, 5, 6, 7, 8], model="FACOM")
# _pdu_2 = Gude(addr="10.69.14.2", port_numbers=[4], model="FACOM")

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
        addr="10.106.245.25", username="Oper1", password="Nokia@123"
    ),
    # serial_number="R5CT12GAS8E",
    serial_number="R5CT21008YW",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "samsung21"],
)

_attenuator_5G = TopYoung(
    ip_addr="10.106.245.23",
    port=1000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14],
    model="PA-8-2-4-127-0.5-B-S",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210855855",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
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
        _attenuator_5G.attenuator_ports[10],
        _attenuator_5G.attenuator_ports[12],
        _attenuator_5G.attenuator_ports[13],
        _attenuator_5G.attenuator_ports[14],
    ],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210855854",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.136", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210855850",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.137", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA220152474",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q184610181",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q171412363",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.3", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_7 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="RW192700867",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="K9202403987",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="EA213555279",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA220654599",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_11 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA220655080",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_12 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA220654569",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.135", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172758759",
    rus=[_rmod_4, _rmod_8, _rmod_9],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163812842",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184380928",
    rus=[_rmod_5, _rmod_6, _rmod_7],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q183807119",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="6Q180310393",
    capacity_units=[_fsp_1, _fsp_2, _fsp_4],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="6Q174125282",
    capacity_units=[_fsp_3],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3],
    oam_ip=NetworkAddress("10.69.236.116"),
    instance_id=1880,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2, _rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

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
        addr="10.106.245.26", username="ute"
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
        addr="10.106.245.27", username="ute"
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

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_1880_2ASIA_4ABIA_3AHEGC_3AHPDA_3AZNA_3AHHB",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[huawei1],
    attenuator=_attenuator_5G,
    appserver=_appserver,
)

__all__ = ["tl"]
