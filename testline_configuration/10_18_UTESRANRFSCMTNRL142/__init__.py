__maintainer__ = "liana.ferescu@nokia.com"
__email__ = "liana.ferescu@nokia.com"
__owner_email__ = "liana.ferescu@nokia.com"

import os
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote
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

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.31",
        username="ute",
        password="ute",
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.31",
        username="ute",
        password="ute",
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = Gude(
    "10.255.2.21",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"


_pdu_2 = Gude(
    "10.255.2.22",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="AS211809249",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.51", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM33")],  # windows
    ),
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7204203040",
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.51", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM44")],  # windows
    ),
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2330H60AR",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.51", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM31")],  # windows
    ),
)

_ru_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9190837417",
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101576",
    rus=[_ru_1, _ru_2, _ru_3],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104932",
    rus=[_ru_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230610636",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])

_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3, _ru_4],
    instance_id=621142,
    oam_ip=NetworkAddress("10.0.65.230"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_fhgw1_default_ssh_connection_details = SshServiceDetails(
    addr="10.5.46.42", username="root", password="root"
)

_fhgw_1 = FHGW(
    user_config_path=os.path.join(_cfg_dir, "None"),
    rus=[_ru_1, _ru_2, _ru_3],
    fhgw_id=1,
    default_ssh_connection_details=_fhgw1_default_ssh_connection_details,
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.38",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    fhgws=[_fhgw_1],
    instance_id=623142,
    fhuc_vlans=[301],
)

_cu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.5", username="core", password="system123"
)

_cu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.39",
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
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]
