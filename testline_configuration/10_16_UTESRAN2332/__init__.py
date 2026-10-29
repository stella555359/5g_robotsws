# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "monika.ceglarek@nokia.com"
__email__ = "monika.ceglarek@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.251.98", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.44.205.141", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="F7162408619",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="F7141004869",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L6142165110",
)

_smod_1 = Flexi([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="L1155212990",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXDD,
    serial_number="F7173533538",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.44.207.138"),
    instance_id=5082,
)


_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.210"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.74", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC34",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.44.139.2", username="SYSTEM", password="SYSTEM"
    ),
)

# ABSTRACT_LIB_CONFIG = "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2332/SBTS_5082_ceglarek/device/ta_ue_config.yaml"
# HANGING_SCRIPT_PATH = "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2332/SBTS_5082_ceglarek/device/hanging.py"

# TSHARK_3G_CONNECTION_PARAMS = {"ip": "10.42.109.243", "user": "ute", "password": "ute"}


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_1FSMF_2FBBA_1FRGU_1FXDD_DEV",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
