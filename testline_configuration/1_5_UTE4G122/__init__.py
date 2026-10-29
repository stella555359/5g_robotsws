__owner__ = "Wu Nick"
__maintainer__ = "Wu Nick"
__email__ = "nick.1.wu@nokia-sbell.com"


import os
import re

import yaml
from taf.config.testline.airscale import Airscale
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM, HBTE, TopYoung
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_pdu_1 = FACOM(addr="10.108.151.66", port_numbers=[3, 4])  # ASIB LEFT:3, ASIB RIGHT:4
# _pdu_2 = FACOM(addr="10.108.151.99", port_numbers=[6])  # AZQF1
# _pdu_3 = FACOM(
#    addr="10.108.151.101", port_numbers=[4, 5, 6, 8]
# FXEB,# AZQF1  # AZNB:3, AZQF:8
_pdu_4 = HBTE(addr="10.108.151.100", port_numbers=[1, 2, 3])  # AZQF1, # FXEB, # AZQF2
_pdu_5 = HBTE(addr="10.108.151.97", port_numbers=[3])  # AZNB
# _pdu_6 = HBTE(addr="10.108.151.133", port_numbers=[4], model="hbte")  # AAHF2:4
_pdu_7 = HBTE(addr="10.106.198.104", port_numbers=[1, 4])  # AEHB1:1 AEHB2:2

_rmod_2 = RU(
    ru_hw_group="AZQF1:CPRI",
    radio_type="AZQF",
    serial_number="6Q181710305",
    pdu_port=_pdu_4.pdu_ports[1],
)  # AZQF1
_rmod_3 = RU(
    ru_hw_group="AZNB:CPRI",
    radio_type="AZNB",
    serial_number="L1162105358",
    pdu_port=_pdu_5.pdu_ports[3],
)  # AZNB
_rmod_4 = RU(
    ru_hw_group="FXEB:CPRI",
    radio_type="FXEB",
    serial_number="1M173634014",
    pdu_port=_pdu_4.pdu_ports[2],
)  # FXEB
_rmod_6 = RU(
    ru_hw_group="AZQF:CPRI",
    radio_type="AZQF",
    serial_number="6Q181710303",
    pdu_port=_pdu_4.pdu_ports[3],
)  # AZQF2
# _rmod_1 = RU(
#    ru_hw_group="AAHF1:CPRI",
#    serial_number="1M194603256",
#    pdu_port=_pdu_5.pdu_ports[1],
# )  # AAHF1
# _rmod_5 = RU(
#    ru_hw_group="AAHF2:CPRI",
#    serial_number="1M194603257",
#    pdu_port=_pdu_6.pdu_ports[4],
# )  # AAHF2
_rmod_7 = RU(
    ru_hw_group="AEHB1:CPRI",
    radio_type="AEHB",
    serial_number="L1211113059",
    pdu_port=_pdu_7.pdu_ports[1],
)  # AEHB1
_rmod_8 = RU(
    ru_hw_group="AEHB2:CPRI",
    radio_type="AEHB",
    serial_number="L1213414030",
    pdu_port=_pdu_7.pdu_ports[4],
)  # AEHB2

# ABIA LEFT
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174908005",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174908003",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174907997",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_4],
)
# ABIC+ABIA RIGHT
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIC",
    hardware_version="474723A.101",
    serial_number="6Q191328436",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_7],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIC",
    hardware_version="474723A.101",
    serial_number="6Q191215214",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_8],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163418452",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_6],
)
# ASIB LEFT
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1182811442",
)
# ASIB RIGHT
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1190601917",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_2, _rmod_3, _rmod_4])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_6, _rmod_7, _rmod_8],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
    port=22,
)

_appserver = AppServer(_iperf_details_on_appserver)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "android_ue_config.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_android = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_android)
        for item in qci_port:
            _ue_android = _ue_android.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_android, Loader=yaml.FullLoader)
else:
    _ue_config = ""

print(_ue_config)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.151.225", username="ute", password="ute"),
    connections=[
        _enb_sbts_1.system_module.common_units[0],
        _ue_config,
        NetworkAddress(v4="192.168.255.126"),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.108.151.226", username="ute", password="ute"),
    connections=[
        _enb_sbts_2.system_module.common_units[0],
        _ue_config,
        NetworkAddress(v4="192.168.255.126"),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B6_AEHB_AZNB_AZQF_FXEB",
)
__all__ = ["tl"]
