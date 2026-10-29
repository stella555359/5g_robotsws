__maintainer__ = "Michal Piechowski"
__team__ = "I_MN_RAN_RD_VRF_WRO3_2"
__email__ = "michal.piechowski@nokia.com"

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

_pdu_1 = Gude(addr="10.44.205.213", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_2 = Gude(addr="10.44.177.13",  port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_3 = Gude(addr="10.44.177.132", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_4 = Gude(addr="10.44.200.115", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_lte_ru_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    serial_number="EA220450754",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_lte_ru_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    serial_number="DH223847857",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_lte_ru_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    serial_number="EA202151827",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.135", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_5g_ru_1 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M204800300",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[12],
)

_5g_ru_2 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M221016603",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_5g_ru_3 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M221016497",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9220726159",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)

_shared_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA223757592",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_shared_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9203006905",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_shared_ru_4 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS213313838",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="1172.16.77.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_shared_ru_5 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="F7201904385",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)

_shared_ru_6 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS220107978",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1180417992",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1183906414",
    rus=[_shared_ru_4, _shared_ru_5, _shared_ru_6, _lte_ru_1, _lte_ru_2, _lte_ru_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233206255",
    rus=[_5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233006454",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3, _shared_ru_4, _shared_ru_5, _shared_ru_6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173500890",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503185",
)

_smod_enb = Airscale(common_units=[_fct_1])
_smod_gnb = Airscale(common_units=[_fct_2])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.88.159",
        vlan_id=480,
        routing=RoutingInformation(gateway="10.44.88.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.44.88.211", vlan_id=481),
    x2u=NetworkAddress(v4="10.44.89.19",  vlan_id=482),
    s1u=NetworkAddress(v4="10.44.89.100", vlan_id=483),
)

_du_gnb = DU(
    airscale=_smod_gnb, 
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3, _shared_ru_4, _shared_ru_5, _shared_ru_6, _5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_enb = RealEnb(
    system_module=_smod_enb,
    global_bts_id=40231,
    oam_ip="10.44.90.17",
    instance_id=40231,
    rms=[_shared_ru_1, _shared_ru_2, _shared_ru_3, _shared_ru_4, _shared_ru_5, _shared_ru_6, _lte_ru_1, _lte_ru_2, _lte_ru_3],
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_gnb], global_bts_id=50230, instance_id=50230)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.188", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_smod_gnb.common_units[0],   
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.189", username="ute"),
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_2xABIP_WRO_TRS_365",
)

__all__ = ["tl"]
