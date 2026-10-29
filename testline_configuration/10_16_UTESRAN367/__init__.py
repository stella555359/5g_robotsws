__maintainer__ = "Daniel Grzesik"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "daniel.grzesik@nokia.com"

from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)

_pdu_1 = Gude(addr="10.44.205.237", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8220-1")
_pdu_2 = Gude(addr="10.44.205.241",  port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_3 = Gude(addr="10.44.205.222", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_4 = Gude(addr="10.44.205.192", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_lte_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA203859961",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)

_lte_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA205155154",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="1172.16.9.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

_lte_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9190520181",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_5g_ru_1 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M204539359",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.2", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[11],
)

_5g_ru_2 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M213608230",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_5g_ru_3 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M202412898",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[12],
)

_shared_ru_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="YK223200016",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_shared_ru_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="YK223200014",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_shared_ru_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2322C61LR",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="DH212899153",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="DH212898730",
    rus=[],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="DH212899205",
    rus=[_lte_ru_1, _lte_ru_2, _lte_ru_3],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH222841886",
    rus=[_5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.45",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="	L1224904542",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1171605487",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201401744",
)

_smod_enb = Airscale(common_units=[_fct_1])
_smod_gnb = Airscale(common_units=[_fct_2])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.64.58",
        vlan_id=454,
        routing=RoutingInformation(gateway="10.44.64.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.44.64.122", vlan_id=455),
    x2u=NetworkAddress(v4="10.44.64.187",  vlan_id=456),
    s1u=NetworkAddress(v4="10.44.64.251", vlan_id=457),
)

_du_gnb = DU(
    airscale=_smod_gnb, 
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3, _5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_enb = RealEnb(
    system_module=_smod_enb,
    global_bts_id=40254,
    oam_ip="10.44.92.18",
    instance_id=40254,
    rms=[_shared_ru_1, _shared_ru_2, _shared_ru_3, _lte_ru_1, _lte_ru_2, _lte_ru_3],
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_gnb], global_bts_id=51096, instance_id=51096)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.53.33", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_smod_gnb.common_units[0],   
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.53.31", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_smod_enb.common_units[0],   
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIL_ABIO_WRO_TRS_367",
)

__all__ = ["tl"]
