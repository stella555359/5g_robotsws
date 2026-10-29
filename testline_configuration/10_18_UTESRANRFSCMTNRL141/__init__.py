__maintainer__ = "adrian.chisim@nokia.com"
__email__ = "adrian.chisim@nokia.com"
__owner_email__ = "adrian.chisim@nokia.com"

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
from taf.config.testline.ran import RNC

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.34",
        username="ute",
        password="uteUTE!",
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.34",
        username="ute",
        password="uteUTE!",
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.2.20",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.2.21",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    "10.255.2.22",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2220N403Y",
    pdu_port=_pdu_1.pdu_ports[12],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2216N4017",
    pdu_port=_pdu_3.pdu_ports[9],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2212N4009",
    pdu_port=_pdu_3.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224207716",
    rus=[_ru_1],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.10",
    serial_number="L1191510069",
    rus=[_ru_1],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400391",
    rus=[_ru_2, _ru_3],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1191510079",
    rus=[_ru_2, _ru_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220747042",
    test_pc=_test_pc_2,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1204202869",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1, _fct_2])

_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3],
    instance_id=621141,
    oam_ip=NetworkAddress("10.0.70.232"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_rannic_1 = RANNIC(
    serial_number="L1240803839",
    product_code="1791B.101",
    rus=[_ru_1, _ru_2, _ru_3],
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.36",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=623141,
    fhuc_vlans=[301],
)

_cu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.3", username="core", password="system123"
)

_cu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.37",
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

_rnc = RNC(
    rnc_id=8,
    oms_ip="10.44.44.219",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="root", password="root"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb_lte],
    rncs=[_rnc],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]
