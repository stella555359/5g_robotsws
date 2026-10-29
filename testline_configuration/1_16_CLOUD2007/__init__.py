__maintainer__ = "Marcin Berkowski"
__team__ = "MN RAN VRF 3 WRO 5"
__email__ = "marcin.berkowski@nokia.com"

import os
import shutil

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline import RU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.flexi import Flexi
from taf.config.testline.enb import RealEnb
from taf.config.testline.testline import TestLine
from collections import OrderedDict
from taf.config.testline.pdu import Gude

cfg_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]

_pdu_1 = Gude("10.44.177.145", [2, 5], "EPC", "8041-1")
_pdu_2 = Gude("10.44.200.147", [1], "EPC", "8220-1")

_rmod_1 = RU(
	radio_type="RadioTypes.AHFIB.value",
	ru_hw_group="RF.FRM5.trunk.20240219.004",
	product_code="474216A.101",
	serial_number="BL1911V00CG",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.232", port=2323
    ),
	pdu_port=_pdu_1.pdu_ports[2]
)
_rmod_2 = RU(
	radio_type="RadioTypes.AHFIB.value",
	ru_hw_group="RF.FRM5.trunk.20240219.004",
	product_code="474216A.101",
	serial_number="K9181806880",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.231", port=2323
    ),
	pdu_port=_pdu_1.pdu_ports[5]
)

_fsp_enb_1 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="101",
    product_code="472797A.101",
    rus=[_rmod_1],
    serial_number="AS172532860",
)
_fsp_enb_2 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="101",
    product_code="472797A.101",
    rus=[_rmod_2],
    serial_number="AS172532514",
)
_fct_enb_1 = CommonUnit(
    capacity_units=[_fsp_enb_2, _fsp_enb_1],
    hardware_type="FSMF",
    hardware_version="472181A",
    lmp_connection=SshServiceDetails(addr="192.168.255.129", password="oZPS0POrRieRtu", port=22, username="toor4nsn"),
    pdu_port=_pdu_2.pdu_ports[1],
    serial_number="L1142733297",
)
_smod_enb_1 = Flexi([_fct_enb_1])
_enb_sbts_1 = RealEnb(
    global_bts_id=100710,
    instance_id=100710,
    oam_ip=NetworkAddress(v4="10.42.87.23"),
    rms=[_rmod_1, _rmod_2],
    system_module=_smod_enb_1,
)
_test_pc_enb_1 = TestPc(
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(device=_enb_sbts_1.system_module.common_units[0], interface="eth1", interface_type="lmp"),
    ],
    default_ssh_connection_details=SshServiceDetails(addr="10.44.156.42", password="UTE.debian12", port=22, username="ute"),
)
_pdus = [_pdu_1, _pdu_2]
_tl_cloud_topology = "CLOUD_SRAN_LWG_FSMF_FBBC_AHFIB_LM"

tl = TestLine(
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    test_pc=_test_pc_enb_1,
    test_pcs=[_test_pc_enb_1],
    tl_cloud_topology=_tl_cloud_topology,
)
