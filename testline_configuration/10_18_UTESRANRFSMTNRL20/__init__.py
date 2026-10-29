__maintainer__ = "ancuta.muresan@nokia.com"
__owner__ = "ancuta.muresan@nokia.com"
__email__ = "ancuta.muresan@nokia.com"


import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, FPFH, PSU
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
#from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline import NetAct


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.97", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.117",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.5.118",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"



# _dcap_1 = DcapRnD(
#     HttpConnectionDetails(l
#         addr="10.5.19.97", port="9443", username="utfuser", password="utfadmin!")
# )


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="K9221140923",
    pdu_port=_pdu_2.pdu_ports[2],
)



_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA213353822",
    test_pc=_test_pc_1,
    rus=[_rmod_1],
)

_smod_1 = Airscale(core_units=[_fct_1])

_netact_ssh_2002 = SshServiceDetails(
    addr="10.82.47.15", username="omc", password='Medsql!_1893'
)

_netact_http_2002 = HttpConnectionDetails(
    addr="srnclab2002lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_2002 = NetAct(_netact_ssh_2002, _netact_http_2002)

_netact_ssh_1052 = SshServiceDetails(
    addr="10.63.2.155", username="omc", password='Medsql!_1893'
)

_netact_http_1052 = HttpConnectionDetails(
    addr="srnclab1052lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_1052 = NetAct(_netact_ssh_1052, _netact_http_1052)

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=621020,
   # dcap=_dcap_1,
    oam_ip=NetworkAddress(v4="10.0.69.20"),
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_1.system_module.core_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL20",
    nms=_netact_1052,
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,
}

__all__ = ["tl"]
