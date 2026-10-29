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

_pdu_1 = Gude("10.44.200.107", [1, 2, 3, 4, 5, 6, 7, 8], model="EPC", version="8220-1")
_pdu_2 = Gude("10.44.200.106", [3], model="EPC", version="8220-1")
_pdu_3 = Gude("10.44.200.94", [1, 2, 3], model="EPC", version="8220-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_lte_ru_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXED",
    serial_number="F7154832802",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_lte_ru_2 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="F7163207727",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_lte_ru_3 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="F7141549914",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARGA",
    serial_number="F7202906264",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_5g_ru_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARGA",
    serial_number="K9221631103",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_5g_ru_2 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARGA",
    serial_number="F7201201460",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_5g_ru_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHSB",
    serial_number="RW235000366",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_5g_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHSB",
    serial_number="RW235000365",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_5g_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHSB",
    serial_number="RW235000369",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="472924A.101",
    serial_number="L1171402092",
    rus=[_lte_ru_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164416890",
    rus=[_lte_ru_2, _lte_ru_3, _shared_ru_1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="L6143602687",
    rus=[],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210302288",
    rus=[_shared_ru_1],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1192005417",
    rus=[_5g_ru_1],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210302502",
    rus=[_5g_ru_2, _5g_ru_3, _5g_ru_4, _5g_ru_5],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1174814982",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="084792A.104",
    serial_number="F7164761629",
)

_fct_3 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1211509459",
)

_smod_1 = Airscale(common_units=[_fct_1])
_smod_2 = Flexi(common_units=[_fct_2])
_smod_3 = Airscale(common_units=[_fct_3])

_enb_sbts_1 = RealEnb(system_module=_smod_1, global_bts_id=5010, instance_id=5010, rms=[_lte_ru_1, _lte_ru_2, _lte_ru_3, _shared_ru_1])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.6",
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
    airscale=_smod_3, 
    rus=[_5g_ru_1, _5g_ru_2, _5g_ru_3, _5g_ru_4, _5g_ru_5, _shared_ru_1],
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_gnb], global_bts_id=507001, instance_id=507001)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.94", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.119", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_3 = TestPc(
    SshServiceDetails(addr="10.44.156.105", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_smod_3.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_3,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_cbts],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIA_ASIB_ABIL_ABIO_ARGA_FXED_FHRC",
)

__all__ = ["tl"]
