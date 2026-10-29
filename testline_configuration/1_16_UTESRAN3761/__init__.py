__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "8.9"
__rack__ = "GTA-883"

from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.flexi import Flexi
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# ************************************************ PDU ************************************************
# SMOD port: ASIL_1 4, ASIL_2 3,
_pdu_smod = Gude(
    addr="10.42.80.233",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port: AWHHF_2 9, AWHHF_3 12
_pdu_rmod1 = Gude(
    addr="10.42.199.197",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port: AWHHF_1 2, AWHHF_4 3, AWHHF_5 11, AWHHF_6 1
_pdu_rmod2 = Gude(
    addr="10.42.199.198",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port: AHIB_1 7,  AHIB_2  8,  AHIB_3 9,  AHIB_4 10,  AHIB_5 11,  AHIB_6 12
_pdu_rmod3 = Gude(
    addr="10.42.80.116",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port: AHFB_1 7,  AHFB_2  8,  AHFB_3 9,  AHFB_4 10,  AHFB_5 11,  AHFB_6 12
_pdu_rmod4 = Gude(
    addr="10.42.80.110",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdus = [_pdu_smod, _pdu_rmod1, _pdu_rmod2, _pdu_rmod3, _pdu_rmod4]

# ************************************************ RMs ************************************************

_AWHHF_1 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH243003014",
    pdu_port=_pdu_rmod2.pdu_ports[2],
)

_AWHHF_2 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH243003020",
    pdu_port=_pdu_rmod1.pdu_ports[9],
)

_AWHHF_3 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH243003025",
    pdu_port=_pdu_rmod1.pdu_ports[12],
)

_AWHHF_4 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH243002968",
    pdu_port=_pdu_rmod2.pdu_ports[3],
)

_AWHHF_5 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH243003015",
    pdu_port=_pdu_rmod2.pdu_ports[11],
)

_AWHHF_6 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH243003023",
    pdu_port=_pdu_rmod2.pdu_ports[1],
)

_AHIB_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="AH241302038",
    pdu_port=_pdu_rmod3.pdu_ports[7],
)

_AHIB_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="AH241302055",
    pdu_port=_pdu_rmod3.pdu_ports[8],
)

_AHIB_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="AH241302070",
    pdu_port=_pdu_rmod3.pdu_ports[12],
)

_AHIB_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="AH241302026",
    pdu_port=_pdu_rmod3.pdu_ports[11],
)

_AHIB_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="AH241300395",
    pdu_port=_pdu_rmod3.pdu_ports[10],
)

_AHIB_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="AH241302077",
    pdu_port=_pdu_rmod3.pdu_ports[9],
)

_AHFB_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH243402543",
    pdu_port=_pdu_rmod4.pdu_ports[7],
)

_AHFB_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH243402541",
    pdu_port=_pdu_rmod4.pdu_ports[8],
)

_AHFB_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH243402545",
    pdu_port=_pdu_rmod4.pdu_ports[9],
)

_AHFB_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH243300457",
    pdu_port=_pdu_rmod4.pdu_ports[10],
)

_AHFB_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH243300437",
    pdu_port=_pdu_rmod4.pdu_ports[11],
)

_AHFB_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH243300455",
    pdu_port=_pdu_rmod4.pdu_ports[12],
)


# ************************************************ ENB ************************************************

_ABIO_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508206",
    rus=[_AHIB_1, _AHIB_2, _AHIB_3, _AHFB_1, _AHFB_2, _AHFB_3],
)
_ABIO_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223310032",
    rus=[_AHIB_4, _AHIB_5, _AHIB_6, _AHFB_4, _AHFB_5, _AHFB_6],
)

_ASIL_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_ABIO_1, _ABIO_2],
    pdu_port=_pdu_smod.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1231805646",
)

_smod_1 = Airscale([_ASIL_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _AHIB_1,
        _AHIB_2,
        _AHIB_3,
        _AHIB_4,
        _AHIB_5,
        _AHIB_6,
        _AHFB_1,
        _AHFB_2,
        _AHFB_3,
        _AHFB_4,
        _AHFB_5,
        _AHFB_6,
    ],
    instance_id=8948, global_bts_id=8948
)


# ************************************************ GNB ************************************************


_ABIO_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706811",
    rus=[_AWHHF_1, _AWHHF_2, _AWHHF_3],
)
_ABIO_4 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210804455",
    rus=[_AWHHF_4, _AWHHF_5, _AWHHF_6],
)

_ASIL_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_ABIO_3, _ABIO_4],
    pdu_port=_pdu_smod.pdu_ports[3],
    hardware_version="474767A.103",
    serial_number="L1240503653",
)

_Airscale_ASIL = Airscale(common_units=[_ASIL_2])

_du_asil = DU(
    airscale=_Airscale_ASIL,
    rus=[_AWHHF_1, _AWHHF_2, _AWHHF_3, _AWHHF_4, _AWHHF_5, _AWHHF_6],
)

_cu_asil = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.149.80", v6="", vlan_id=149),
    x2u=NetworkAddress(v4="10.42.148.20", v6="", vlan_id=148),
)

_classical_asil = ClassicalBts(
    dus=[_du_asil], cu=_cu_asil, instance_id=55290, global_bts_id=55290
)

# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.21", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_Airscale_ASIL.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.22", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ************************************************ SUM ************************************************

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_asil],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIL_2ABIO_1ASIL_2ABIO_6AHIB_6AHFB_6AWHHF_UUF_2_UTECA",
)

__all__ = ["tl"]
