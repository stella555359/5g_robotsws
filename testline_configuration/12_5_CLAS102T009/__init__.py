__maintainer__ = "Yang Wei"
__team__ = "BOAM Hangzhou EIT"
__owner_email__ = "wei.2.yang@nokia-sbell.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    SCRadioConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import SC5GRadio, SC4GRadio
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, Pdu
from taf.config.testline.enb import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.pdu import PduPort, ATEN, FACOM, Pdu, EPC
import os
import yaml

def _set_abstract_lib_config_env(ue_config_file):
    tl_config_dir = os.path.dirname(os.path.abspath(__file__))
    ue_config_abs_path = os.path.join(tl_config_dir, ue_config_file)

    with open(ue_config_abs_path) as ta_ue_config:
        ue_config = yaml.safe_load(ta_ue_config)

    os.environ["ABSTRACT_LIB_CONFIG"] = ue_config_abs_path

    return ue_config

_capacity_unit_enb = CapacityUnit(
    addr="fsp1_c", hardware_type="ABIO", hardware_version="475266A.102"
)

_common_unit_enb = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
        proxy=SshServiceDetails(
            addr="10.108.246.84", username="ute", password="Hangzhoueit123!"
        ),
    ),
    capacity_units=[_capacity_unit_enb],
)

_airscale_enb = Airscale(common_units=[_common_unit_enb])

_ru_enb = SC4GRadio(
    sc_radio_connection_details=SCRadioConnectionDetails(
        ssh_connection_details=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu",
            proxy=SshServiceDetails(
                addr="10.108.246.84", username="ute", password="Hangzhoueit123!"
            ),
        ),
        telnet_connection_details=TelnetConnectionDetails(
            addr="tty-server", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
    ),
    serial_number="xxxxxxxx",
)

_lteenb = RealEnb(
    system_module=_airscale_enb,
    rms=[_ru_enb],
    # dus=[],
    instance_id=41,
    global_bts_id=41,
    oam_ip=NetworkAddress(v4="172.30.1.10"),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.246.84", username="ute", password="Hangzhoueit123!"
    )
)

_cu = CU(
    backhaul_site_oam_ip="10.108.244.24",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.244.24", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.244.24", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.108.244.24", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(
    addr="192.168.253.22", hardware_type="ABIO", hardware_version="A102"
)

_du_pdu = FACOM("1.1.1.1", [0])
_du_pdu_port = PduPort(_du_pdu, 0)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    hardware_type="ASIL",
    hardware_version="A102",
    pdu_port=_du_pdu_port,
)

_ru = SC5GRadio(
    ru_hw_group="ASIR-HUB",
    sc_radio_connection_details=SCRadioConnectionDetails(
        ssh_connection_details=SshServiceDetails(
            addr="1.1.1.1",
            username="toor4nsn",
            password="oZPS0POrRieRtu",
            proxy=SshServiceDetails(
                addr="1.1.1.1", username="ute", password="Hangzhoueit123"
            ),
        ),
        telnet_connection_details=TelnetConnectionDetails(
            addr="tty-server", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=PduPort(pdu=FACOM(addr="1.1.1.1", port_numbers=[1, 2]), port_no=1),
    serial_number="xxxxxxxx",
)

_airscale = Airscale([_du_common_unit])

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=1, global_bts_id=1)

_core_pc_ssh = SshServiceDetails(
    addr="10.108.246.84", username="ute", password="Hangzhoueit123!"
)
_core_pc = TestPc(default_ssh_connection_details=_core_pc_ssh)

_epcsim = EPCSim(
    mme_ip="172.31.1.1",
    edaemon_port=10000,
    egate_port=20000,
    mcc=460,
    mnc=6,
    tac=663,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.246.84",
        username="ute",
        password="Hangzhoueit123!",
    ),
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    ues=None,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_ASIR",
    core=_epcsim,
)

__all__ = ["tl"]
