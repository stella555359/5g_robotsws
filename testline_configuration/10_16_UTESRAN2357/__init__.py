__maintainer__ = "Michal Hadrysiak"
__owner_email__ = "michal.hadrysiak@nokia.com"
__email__ = "michal.hadrysiak@nokia.com"

import os

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

# testline config variables


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.251.123", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.251.124", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

pdu = Gude("10.44.205.181", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171402094",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192409501",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203601960",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1192405415",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=pdu.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH200762505",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3, _fsp_4],
    pdu_port=pdu.pdu_ports[11],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="EA202458458",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FRHF,
    serial_number="F7154044090",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=pdu.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FXED,
    serial_number="L1160409654",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=pdu.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FRPD,
    serial_number="EA201610278",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.131", port=2323
    ),
    pdu_port=pdu.pdu_ports[3],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.44.95.120"),
    instance_id=8074,
)
# 10.44.151.243
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3],
    oam_ip=NetworkAddress("10.44.95.121"),
    instance_id=55014,
)

# _enb_sbts_1.slave = _enb_sbts_2


# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2], tl_cloud_topology="not added to agent yet")
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="not added to agent yet",
    pdus=[pdu],
)

# other variables

# needed by hran_frame_sbts resource.
HW_LOCATION_CODE = "Wroclaw"

# needed by hran_frame_sbts resource.
TESTLINE_NAME = "10_16_UTESRAN2357"

# needed by Common Test Setup to setup remote TL.
REMOTE_TESTLINES = {"gNB": {"PC_IP1": "10.42.251.124", "SMOD_IP1": "10.44.95.121"}}

# needed for ute_ue library.

##ABSTRACT_LIB_CONFIG = os.path.dirname(os.path.abspath(__file__)) + "/ta_ue_config.yaml"
ABSTRACT_LIB_CONFIG = (
    "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2357/ta_ue_config.yaml"
)
ABSTRACT_LIB_CONFIG2 = (
    "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2357/interfaces.yaml"
)

# path to script which must be run after each TC involving UEs.
HANGING_SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__)) + "/hanging.py"

# path to check call drop script
PATH_TO_CHECK_CALL_DROP_SCRIPT = (
    os.path.dirname(os.path.abspath(__file__)) + "/check_call_drop.bash"
)

# path to script for collection of TTI trace from ABIL.
# https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=739583899#TTItraces-HowtogettheTTITraceUsingaScript.
TTI_TRACE_SCRIPT_PATH = (
    os.path.dirname(os.path.abspath(__file__)) + "/gnb_tti_traces.py"
)

__all__ = ["tl"]
