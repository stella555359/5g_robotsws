__maintainer__ = "Aleksandra Chudzik"
__email__ = "aleksandra.chudzik@nokia.com"

from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu = Gude(
    addr="10.42.80.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_shared_rmod_1 = RU(ru_hw_group="FRMr5.1a_4T4R", 
serial_number="1M184800058", 
pdu_port=_pdu.pdu_ports[7], 
radio_type="AZQC",
)

# ===================================== ENB ===========================================

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173009888",
	rus=[_shared_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH214044375",
    capacity_units=[_fsp_1],
)

_smod_1 = Flexi([_fct_1])

_enb_sbts = RealEnb(system_module=_smod_1, rms=[_shared_rmod_1])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.145", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
# ===================================== GNB ===========================================

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101588",
	rus=[_shared_rmod_1],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902198",
    capacity_units=[_fsp_2],
)

_smod_2 = Flexi([_fct_2])

_gnb_sbts = RealEnb(system_module=_smod_2, rms=[_shared_rmod_1], master=_enb_sbts)

_gnb_sbts.oam_ip = NetworkAddress(
    v4="10.42.20.205/24",
    vlan_id=287,
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.62.244", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_gnb_sbts.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ================================================================================

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts, _gnb_sbts],
    tl_cloud_topology="CLOUD_RFS_AIL_ABIA_AIR_ABIO_AZQC_CBRS_9",
)

__all__ = ["tl"]
