__maintainer__ = "liana.ferescu@nokia.com"
__email__ = "liana.ferescu@nokia.com"
__owner_email__ = "liana.ferescu@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.cu import CU
from taf.config.testline.gnb.du import VDU, FHGW
from taf.config.testline.gnb.gnb import CloudBts
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ran import BSC

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.33",
        username="ute",
        password="ute",
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.33",
        username="ute",
        password="ute",
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.2.20",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.2.21",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    "10.255.2.22",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M193119536",
    pdu_port=_pdu_3.pdu_ports[5],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M190413177",
    pdu_port=_pdu_3.pdu_ports[6],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW232200994",
    pdu_port=_pdu_3.pdu_ports[8],
)

_ru_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHGF.value,
    serial_number="4H230130001",
    pdu_port=_pdu_1.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223303276",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1191509981",
    rus=[_ru_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1204101064",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])

_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3, _ru_4],
    instance_id=621140,
    oam_ip=NetworkAddress("10.0.70.231"),
    bcf_id="3231",
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_fhgw1_default_ssh_connection_details = SshServiceDetails(
    addr="10.5.46.36", username="root", password="root"
)

_fhgw_1 = FHGW(
    user_config_path=os.path.join(_cfg_dir, "None"),
    rus=[_ru_1, _ru_2, _ru_3],
    fhgw_id=1,
    default_ssh_connection_details=_fhgw1_default_ssh_connection_details,
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.34",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    fhgws=[_fhgw_1],
    instance_id=623140,
    fhuc_vlans=[301],
)

_cu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.2", username="core", password="system123"
)

_cu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.35",
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

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7",
        username="SYSTEM",
        password="SYSTEM",
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb_lte],
    bscs=[_bsc],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]
