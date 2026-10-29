__owner__ = "Nie Sue"
__maintainer__ = "Nie Sue"
__email__ = "sue.nie@nokia-sbell.com"

import os
import yaml
import re

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.testpc import TestPc
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.ue import Android



_pdu_1 = FACOM(addr="10.106.208.41", port_numbers=[5])
_pdu_2 = HBTE(addr="10.106.208.47", port_numbers=[2, 3])
_pdu_3 = HBTE(addr="10.106.173.25", port_numbers=[3])

_rmod_1 = RU(
    ru_hw_group="AHEGB:CPRI_RRH_4T4R",
    radio_type="AHEGB",
    serial_number="EA203761452",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="AHEGB:CPRI_RRH_4T4R",
    radio_type="AHEGB",
    serial_number="K9193300757",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="AHEGB:CPRI_RRH_4T4R",
    radio_type="AHEGB",
    serial_number="K9193300755",
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184380857",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184380860",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191004172",
)

_smod = Airscale([_fct_1])


_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1,_rmod_2,_rmod_3])


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)

_appserver = AppServer(iperf_details=_iperf)

_ue_pc_ssh = SshServiceDetails(
    addr="10.106.208.53", username="siso1-tester", password="Nokia123!"
)

_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "ta_ue_config.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.206", username="ute", password="ute"
    ),
    connections=[_enb_sbts.system_module.common_units[0],NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_F_CRT_1060",
)

__all__ = ["tl"]
