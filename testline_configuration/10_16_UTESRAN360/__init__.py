__maintainer__ = "Tomasz Stawowczyk"
__team__ = "I_MN_RAN_RD_VRF_WRO3_2"
__email__ = "tomasz.stawowczyk@nokia.com"

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
from taf.config.testline.flexi import Flexi
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)

_pdu_1 = Gude("10.44.200.106", [1], model="EPC", version="8220-1")
_pdu_2 = Gude("10.44.200.94", [11, 12], model="EPC", version="8220-1")
_pdu_3 = Gude("10.44.200.95", [9], model="EPC", version="8220-1")
_pdu_4 = Gude("10.44.200.106", [9, 10], model="EPC", version="8220-1")

_pdus = [_pdu_1, _pdu_2]

_5g_ru_1 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="DH232011167",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_5g_ru_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1214604793",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_5g_ru_3 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1214705937",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)

_lte_ru_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARMA",
    serial_number="1M201628298",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9],
)

_lte_ru_2 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA191273986",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[10],
)

_abip_enb_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1233105985",
    rus=[_lte_ru_1, _lte_ru_2],
)

_abip_gnb_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1231609458",
    rus=[_5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_abip_enb_2, _abip_gnb_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503182",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.22",
        vlan_id=517,
        routing=RoutingInformation(gateway="10.42.84.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_gnb = DU(
    airscale=_airscale_gnb_1, 
    rus=[_lte_ru_1, _lte_ru_2, _5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_gnb], global_bts_id=51099, instance_id=51099)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.53.103", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_gnb_1.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_cbts],
    enbs=[],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIP_AQQQ_WRO_TRS_360",
)

__all__ = ["tl"]
