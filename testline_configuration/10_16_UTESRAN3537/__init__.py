# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Paulina Trela"
__email__ = "paulina.trela@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection



from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude(
    addr="10.44.200.81",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_2 = APC(
    addr="10.44.206.17",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_3 = APC(
    addr="10.44.177.164",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_4 = Gude(
    addr="10.44.177.190",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_shared_rmod_1 = RU(
    ru_hw_group="", 
    serial_number="BL2120V0CZU", 
    radio_type="AHFIB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[6],

)

_shared_rmod_2 = RU(
    ru_hw_group="", 
    serial_number="BL1919V00RN", 
    radio_type="AHFIB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[5], 

)

_shared_rmod_3 = RU(
    ru_hw_group="", 
    serial_number="BL2045V0RR9", 
    radio_type="AHFIB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9] 

)
_gnb_rmod_4 = RU(
    ru_hw_group="cMAArChile_64T64R", 
    serial_number="L1204708732", 
    radio_type="AEHC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],

)

_gnb_rmod_5 = RU(
    ru_hw_group="cMAArChile_64T64R", 
    serial_number="L1204708734", 
    radio_type="AEHC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.22", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9], 

)

_gnb_rmod_6 = RU(
    ru_hw_group="cMAArChile_64T64R", 
    serial_number="L1204708733", 
    radio_type="AEHC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.30", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1], 

)
_shared_rmod_7 = RU(
    ru_hw_group="", 
    serial_number="BL2040G1M6T", 
    radio_type="AHLOA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[8],

)

_shared_rmod_8 = RU(
    ru_hw_group="", 
    serial_number="BL2116G1CHD", 
    radio_type="AHLOA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[10], 

)

_shared_rmod_9 = RU(
    ru_hw_group="", 
    serial_number="BL2040G1M59", 
    radio_type="AHLOA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[7], 

)
# ===================================== ENB ===========================================


_fsp_1 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808085",
	rus=[_shared_rmod_1,_shared_rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172909007",
	rus=[_shared_rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173514763",
	rus=[_shared_rmod_7,_shared_rmod_8,_shared_rmod_9],
)

_fct_1 = CommonUnit(
     lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201401735",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod_1 = Flexi([_fct_1])


_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_shared_rmod_1, _shared_rmod_2, _shared_rmod_3, _shared_rmod_7, _shared_rmod_8, _shared_rmod_9],
    oam_ip=NetworkAddress("10.42.86.162"),
    instance_id=4053,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.51", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)


# ===================================== GNB ===========================================
_fsp_4 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301732",
	rus=[_gnb_rmod_4,_gnb_rmod_5,_gnb_rmod_6],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223007913",
	rus=[_shared_rmod_7,_shared_rmod_8,_shared_rmod_9],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1241801784",
	rus=[_shared_rmod_1,_shared_rmod_2,_shared_rmod_3],
)

_fct_2 = CommonUnit(
     lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1214809685",
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
)

_smod_2 = Flexi([_fct_2])


_gnb_sbts = RealEnb(
    system_module=_smod_2,
    rms=[_shared_rmod_1, _shared_rmod_2, _shared_rmod_3, _gnb_rmod_4, _gnb_rmod_5, _gnb_rmod_6, _shared_rmod_7, _shared_rmod_8, _shared_rmod_9],
    master=_enb_sbts,
    instance_id=6041,
)

_gnb_sbts.oam_ip = NetworkAddress(
    v4="10.42.84.58/24",
    vlan_id=517,
)


_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.52", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_gnb_sbts.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

tl = TestLine(
    test_pc=_test_pc_2,
    test_pcs=[_test_pc_2, _test_pc_1],
    enbs=[_gnb_sbts, _enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIL_1ABIP_2ABIO_1ASIB_3ABIA_3AHFIB_3AEHC_3AHLOA_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
