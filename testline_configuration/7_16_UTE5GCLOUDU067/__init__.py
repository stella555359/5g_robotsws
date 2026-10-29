__maintainer__ = "Oleksandr Kulieshov"
__email__ = "oleksandr.kulieshov@nokia.com"
__owner_email__ = "oleksandr.kulieshov@nokia.com"
__team__ = "pz2wro3"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.ue import Android
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
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


_pdu_1 = Gude("10.44.177.22", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA192271134",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q182503962",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q175002443",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC.value,
    serial_number="F7173732319",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC.value,
    serial_number="F7180745265",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS180402642",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_7 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q184658950",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M212807193",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.158", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_9 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M212807190",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172903745",
    rus=[],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172602547",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214209196",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214209189",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162715597",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163606695",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1203700843",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1220401913",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.233"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=19656, instance_id=4068)
_gnb_2 = ClassicalBts(cu=_cu, dus=[_du_2], master=_gnb_1)

_gnb_1.slave = _gnb_2
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
    ],
    oam_ip=NetworkAddress("10.44.207.144"),
    global_bts_id=19656,
    instance_id=19656,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_6], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.72", username="nokiadmin", password="system"
    ),
)
_bsc = BSC(
    name="BSC_acBSC24",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.196.170", username="VRFUSER", password="VRFPASSWORD"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.76", username="ute", password="ute"),
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
    SshServiceDetails(addr="10.44.156.77", username="ute", password="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.61", username="syslab", password="system"
    ),
    network_interface_address="10.42.197.171",
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.147", username="sranwro9", password="Ru1eTheAir!9"
)

_qualcomm = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="a6d52163",
    server_dir="C:/taf_proxy",
    python_path="C:/Program Files/Python38/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/taf_proxy/DIAG.cfg",
    iperf_details=_iperf_ue,
    capabilities=["UE_FOR_HO"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_1, _gnb_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_qualcomm],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASIL_4xABIA_2xABIO_3xAHDB_2xFXFC_FRGU_AZNA_2xAZQS",
    pdus=[_pdu_1],
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
