__maintainer__ = "anelore.tasala@nokia.com"
__email__ = "anelore.tasala@nokia.com"
__owner_email__ = "anelore.tasala@nokia.com"

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
        addr="10.5.52.48",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.48",
        username="ute",
        password="uteUTE!",
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude(
    "10.255.2.23",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.2.24",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="LR242602032",
    pdu_port=_pdu_1.pdu_ports[5],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIHA.value,
    serial_number="RW233403220",
    pdu_port=_pdu_1.pdu_ports[12],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA222550665",
    pdu_port=_pdu_1.pdu_ports[6],
)

_ru_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2244D50YJ",
    pdu_port=_pdu_1.pdu_ports[10],
)

_ru_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242027980",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174124499",
    rus=[_ru_1,_ru_2],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.10",
    serial_number="L1191510069",
    rus=[_ru_1,_ru_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212874104",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2],
    instance_id=621150,
    oam_ip=NetworkAddress("10.0.69.240"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)


_rannic_1 = RANNIC(
    serial_number="L1242306068",
    product_code="AF1791.102",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5],
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.130",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=624150,
    fhuc_vlans=[301],
)

_cu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.2", username="core", password="system123"
)

_cu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.131",
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
    oms_ip="10.94.92.155",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="root", password="root"
    ),
)

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