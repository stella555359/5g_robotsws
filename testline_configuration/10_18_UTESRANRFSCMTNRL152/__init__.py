__maintainer__ = "cosmin.florea@nokia.com"
__owner__ = "cosmin.florea@nokia.com"
__email__ = "cosmin.florea@nokia.com"
 
import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.cu import CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.gnb import CloudBts
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
 
_cfg_dir = os.path.dirname(os.path.abspath(__file__))
 
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.32",
		username="ute",
		password="uteUTE!"
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.32",
		username="ute",
		password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
 
_pdu_1 = Gude(
	addr="10.255.2.33",
	port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	model="EPC",
	version="8220-1"
)
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
	addr="10.255.2.34",
	port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	model="EPC",
	version="8220-1"
)
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
 
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW232200999",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW232201000",
    pdu_port=_pdu_2.pdu_ports[11],
)
 
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104948",
    rus=[_rmod_1, _rmod_2],
)
 
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1200808330",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
 
_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],   
    instance_id=621152,
    oam_ip=NetworkAddress(v4="10.0.65.242"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_rannic_1 = RANNIC(
    serial_number="L1250200969",
    product_code="AF1791.102",
    rus=[_rmod_1, _rmod_2],
)
 
_vdu_1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.134",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)
 
_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu_1_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=624152,
    fhuc_vlans=[201],
)
 
_cu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.4", username="core", password="system123"
)
 
_cu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.135",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)
 
_cu = CU(
    backhaul_site_oam_ip="None",
    oam_ssh_connection_details=_cu_oam_ssh_connection_details,
    oam_http_connection_details=_cu_oam_http_connection_details,
)
 
_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=None,
    dus=[_vdu_1],
)
 
_test_pc_1.connections.append(_cbts)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb_lte],
)
 
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
 }
 
__all__ = ["tl"]