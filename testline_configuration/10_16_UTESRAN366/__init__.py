__maintainer__ = "Tomasz Stawowczyk"
__team__ = "I_MN_RAN_RD_VRF_WRO3_2"
__email__ = "tomasz.stawowczyk@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
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
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB

_pdu_1 = Gude("10.44.200.106", [5, 6, 7, 8, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2 = Gude("10.44.200.94", [4, 5, 6, 9], model="EPC", version="8220-1")
_pdu_3 = Gude("10.44.200.95", [10, 11], model="EPC", version="8220-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_5g_ru_1 = RU(
    ru_hw_group="cMMAr6.2_64T64R",
    radio_type="AVQE",
    serial_number="L1253502258",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_5g_ru_2 = RU(
    ru_hw_group="cMMAr6.2_64T64R",
    radio_type="AVQE",
    serial_number="L1253502256",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[11],
)
_5g_ru_3 = RU(
    ru_hw_group="cMMAr6.2_64T64R",
    radio_type="AVQE",
    serial_number="L1253502260",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)
_5g_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARGA",
    serial_number="AS213305026",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_5g_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHSB",
    serial_number="RW234900063",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_5g_ru_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHSB",
    serial_number="RW234900049",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_5g_ru_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHSB",
    serial_number="RW234900064",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_lte_ru_1 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="F7190529728",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_lte_ru_2 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="F7151608617",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_lte_ru_3 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARDA",
    serial_number="K9203309882",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_lte_ru_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="AS174128555",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_lte_ru_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7172308848",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.134", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
    
_fsp_1 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172911415",
    rus=[_lte_ru_1, _lte_ru_2, _lte_ru_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105741",
    rus=[_lte_ru_3, _lte_ru_4, _lte_ru_5, _5g_ru_4, _5g_ru_5, _5g_ru_6, _5g_ru_7],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233105939",
    rus=[_5g_ru_1, _5g_ru_2, _5g_ru_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234403063",
)

_smod_1 = Airscale(common_units=[_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, global_bts_id=51134, instance_id=51134, rms=[_lte_ru_1, _lte_ru_2, _lte_ru_3, _lte_ru_4, _lte_ru_5])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.17",
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
    airscale=_smod_1, 
    rus=[_5g_ru_1, _5g_ru_2, _5g_ru_3, _5g_ru_4, _5g_ru_5, _5g_ru_6, _5g_ru_7],
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_gnb], global_bts_id=51134, instance_id=51134)

_bsc = BSC(
    name="BSC_mcBSC24",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.91.107", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.170", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_smod_1.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_cbts],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLG_ASIM_1ABIA_2ABIP_3AQQE_2FRHC_1ARGA_1FXED_1FRMF_1ARDA",
)

__all__ = ["tl"]
