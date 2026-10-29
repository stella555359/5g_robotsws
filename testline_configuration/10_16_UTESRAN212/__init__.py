__maintainer__ = "Monika Walendzik"
__team__ = "TRSSEC"
__email__ = "I_MN_RAN_RD_VRF_WRO3_2@internal.nsn.com"
import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF, RealCore4G
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_enb = ATEN(addr="10.42.61.105", port_numbers=[8])

_pdu_enb_ru_1 = ATEN(addr="10.44.206.46", port_numbers=[2])


_enb_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="FZNI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.133", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[2],
)

_fbbc_enb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6144315561",
    rus=[_enb_ru_1],
)

_fsmf_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fbbc_enb_1_master],
    pdu_port=_pdu_enb.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="084792A.105",
    serial_number="AS174601533",
)

_smod_1 = Flexi(common_units=[_fsmf_enb_1])

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_enb_ru_1],
    instance_id=40219,
    oam_ip=NetworkAddress("10.42.249.229"),
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "10.44.180.7", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_tl_cloud_topology = "CLOUD_4G_CLASSICAL_FSMF_FBBC_FZNI_SEC_SCAN_212"

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.188", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_pdus = [_pdu_enb]

tl = TestLine(
    test_pc=_lmp_vm_enb_1,
    test_pcs=[_lmp_vm_enb_1],
    enbs=[_enb_1],
    tl_cloud_topology=_tl_cloud_topology,
    pdus=_pdus,
)
