# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "cristina.costache@nokia.com"
__maintainer__ = "cristina.costache@nokia.com"
__email__ = "cristina.costache@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.19.63", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.19.64", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.130")],
)


_pdu_1 = Gude(
    "10.255.5.223", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], "EPC", "8221-1"
)
_pdu_2 = Gude("10.255.5.222", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204505498",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008397",
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181415984",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1211905228",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201004612",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB,
    serial_number="1M214207541",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB,
    serial_number="1M214207536",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB,
    serial_number="1M214207535",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGS,
    serial_number="1M174251136",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)


_cu_smod = CU(
    backhaul_site_oam_ip="10.0.65.54",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.54", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.54", username="Nemuadmin", password="nemuuser"
    ),
)
_du_smod = DU(
    airscale=_smod_1,
    rus=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
    ],
)
_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623054)
_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
    ],
    instance_id=621054,
    oam_ip=NetworkAddress(v4="10.0.65.54"),
)
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B4_B1_B2_MTNRL54_3xAENB_1xFRGS",
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
}

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL54/ues.yaml"

__all__ = ["tl"]
