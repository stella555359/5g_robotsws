__maintainer__ = "ariel.ciucurita@nokia.com"
__email__ = "ariel.ciucurita@nokia.com"
__owner_email__ = "ariel.ciucurita@nokia.com"

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
        addr="10.5.52.54",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[],
)

_pdu_1 = Gude(
    "10.255.2.26",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARPA.value,
    serial_number="F7195111541",
    pdu_port=_pdu_1.pdu_ports[8],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="YK223200009",
    pdu_port=_pdu_1.pdu_ports[10],
)
_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M190413173",
    pdu_port=_pdu_1.pdu_ports[12],
)

_rannic_1 = RANNIC(
    serial_number="L1243505169",
    product_code="AF1791.102",
    rus=[_ru_1, _ru_2, _ru_3],
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.146",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=624160,
    fhuc_vlans=[301],
)

_cu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.12", username="core", password="system123"
)

_cu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.147",
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
    test_pcs=[_test_pc_1],
    gnbs=[_cbts],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]
