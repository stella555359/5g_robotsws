__maintainer__ = "Mateusz Guziana"
__team__ = "I_MN_RAN_PZ_IWK_TEST_AUTO_WRO_4_5"
__email__ = "I_MN_RAN_PZ_IWK_TEST_AUTO_WRO_4_5@internal.nsn.com"
__owner_email__ = "mateusz.guziana@nokia.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import Gude, ATEN, PduPort
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore5G

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.251.80", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_gnb = Gude(addr="10.44.205.196", port_numbers=[5], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.198", port_numbers=[4], model="EPC", version="8220-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.205.198", port_numbers=[5], model="EPC", version="8220-1"
)

_pdus = [_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2]

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.251.81", username="ute", password="ute"
    )
)
_pdu_enb = Gude(addr="10.44.205.196", port_numbers=[6], model="EPC", version="8221-1")
_pdu_enb_ru1 = Gude(
    addr="10.44.205.196", port_numbers=[2], model="EPC", version="8221-1"
)
_pdu_enb_ru2 = Gude(
    addr="10.44.205.196", port_numbers=[3], model="EPC", version="8221-1"
)
_pdu_enb_ru3 = Gude(
    addr="10.44.205.196", port_numbers=[7], model="EPC", version="8221-1"
)

_lmp_vm_enb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.251.79", username="ute", password="ute"
    )
)

_pdu_enb2 = Gude(addr="10.44.205.196", port_numbers=[4], model="EPC", version="8221-1")
_pdu_enb2_ru1 = Gude(
    addr="10.44.205.196", port_numbers=[1], model="EPC", version="8221-1"
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABILB1_2xAHPD"

_core = RealCore5G(mcc=555, mnc=10)

_ue_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.22.55", username="plwr4gcp", password="Ru1eTheAir!cp"
    )
)

tl = TestLine(
    test_pc=_ue_pc,
    # gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    # enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    pdus=_pdus,
)

TA_UE_AND_ATTENUATOR_CONFIG = (
    "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2313/GVE_WRO_UTESRAN2313.yml"
)
ABSTRACT_LIB_CONFIG = (
    "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2313/GVE_WRO_UTESRAN2313.yml"
)
TA_ATTENUATOR_CONFIG = (
    "/home/ute/robotlte/config/Wroclaw/10_16_UTESRAN2313/GVE_WRO_UTESRAN2313.yml"
)

REMOTE_TSHARK = {
    "interface": "ens3f0",
    "tshark_dir": "/usr/local/bin",
    "ssh_ip": "10.42.61.49",
    "log_dir": "/tmp",
    "ssh_username": "ute",
    "ssh_password": "uteute",
}

TSHARK_S1_INTERFACE = {
    "capture_filter": "host 10.44.95.14 || 10.44.94.206 || 10.44.95.15 || 10.44.94.207 || 10.44.95.17 || 10.44.94.209",
    "capture_filter2": "host 10.44.199.158",
    "cplane_ip_addr": "host 10.44.95.14 || 10.44.95.15 || 10.44.95.17",
    "uplane_ip_addr": "host 10.44.94.206 || 10.44.94.207 || 10.44.94.209",
    "rau_ip_addr": "host 10.42.28.137 || 10.44.199.178",
    "SGSN_to BSC_ip_addr": "host 10.44.199.178",
}

__all__ = ["tl"]
