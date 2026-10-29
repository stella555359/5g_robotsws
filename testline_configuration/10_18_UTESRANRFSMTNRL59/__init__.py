__maintainer__ = "lia.caraiman@nokia.com"
__owner__ = "lia.caraiman@nokia.com"
__email__ = "lia.caraiman@nokia.com"
__customer__ = "Generic"
__bucket__ = "2.2"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, Remote, Local
from taf.config.testline.fhs import FHS, FhsType

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.71", username="ute", password="pass"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.72", username="ute", password="pass"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.41", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.40", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="K9221532052",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRPD.value,
    serial_number="EA194910645",
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7172950648",
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS195200006",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fhs = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[5],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.81.129", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="YY224410167",
    product_code="473922A.102",
    rus=[_rmod_2],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M224419760",
    pdu_port=_pdu_1.pdu_ports[11],
)

_abil_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203900916",
    rus=[_rmod_2],
    fhs=[_fhs],
)
_abil_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203900900",
    rus=[_rmod_1],
)
_abil_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201605821",
    rus=[_rmod_5],
)
_abin_1 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="474824B.101",
    serial_number="L1224006540",
    rus=[_rmod_1],
)
_abia_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216194",
    rus=[_rmod_2, _rmod_3],
)
_abia_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172903070",
    rus=[_rmod_4],
)

_asik = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_1, _abil_2, _abil_3],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="DH200864165",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_5],
)
_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abin_1, _abia_2, _abia_3],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1230408170",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_smod_1 = Airscale([_asik])
_smod_2 = Airscale([_asib])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.67.59"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.59", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.59", username="Nemuadmin", password="nemuuser"
    ),
)

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_5])

_gnb_1 = ClassicalBts(cu=_cu_gnb, dus=[_du_1], instance_id=621059)

_enb_lte = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=5063,
    oam_ip=NetworkAddress("10.0.69.59"),

)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_1],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL59",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": True,
}
__all__ = ["tl"]
