__owner__ = "Liu Xiaoyi"
__maintainer__ = "Liu Xiaoyi"
__email__ = "xiaoyi.liu@nokia-sbell.com "

import os
import yaml
import re
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdu import FACOM, HBTE, FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_2 = FPFH(
    addr="10.68.160.67",
    port_numbers=[2, 3, 4, 5, 6],
)

_pdu_3 = FACOM(
    addr="10.106.211.130",
    port_numbers=[2, 4],
)

_pdu_4 = FACOM(
    addr="10.106.208.152",
    port_numbers=[3, 4, 6],
)

_pdu_5 = HBTE(
    addr="10.68.160.78",
    port_numbers=[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163707417",
    pdu_port=_pdu_3.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163707411",
    pdu_port=_pdu_3.pdu_ports[2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163707404",
    pdu_port=_pdu_3.pdu_ports[2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1171305134",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
    port=22,
)
_appserver = AppServer(iperf_details=_iperf)
_ue_pc_ssh = SshServiceDetails(
    addr="10.106.211.144", username="siso3-tester", password="Nokia123!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.197",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="dbaae86e",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM3",
    iperf_details=_android_iperf,
    capabilities=["qualcomm", "REAL_UE"],
)
_rmod_1 = RU(
    ru_hw_group="AZQF:FRMTDr5.1a_1_8T8R",
    radio_type="AZQF",
    serial_number="6Q181710312",
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="UZFA:fALU_TDr1.0_8T8R",
    radio_type="UZFA",
    serial_number="YP144507A0F",
    # pdu_port=_pdu_4.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="AZNB:FRMTDr5.1a_1_8T8R",
    radio_type="AZNB",
    serial_number="L1162105358",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FZHR:FRMTDr3.3_8T8R",
    radio_type="FZHR",
    serial_number="6Q164207117",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="AZNC:FRMTDr5.1a_1_8T8R",
    radio_type="AZNC",
    serial_number="6Q180811674",
    pdu_port=_pdu_5.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="FZHJ:FRMTDr3.0_8T8R",
    radio_type="FZHJ",
    serial_number="RY150506449",
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_7 = RU(
    ru_hw_group="FZFF-e:TD-Tech1.0_8T8R",
    radio_type="FZFF-e",
    serial_number="11BYU10EA001915",
    pdu_port=_pdu_4.pdu_ports[3],
)

_rmod_8 = RU(
    ru_hw_group="FZQE:FRMTDr3.2_8T8R",
    radio_type="FZQE",
    serial_number="EA181612484",
    # pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="FZQE:FRMTDr3.2_8T8R",
    radio_type="FZQEP",
    serial_number="EA181612497",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_10 = RU(
    ru_hw_group="FZQE:FRMTDr3.2_8T8R",
    radio_type="FZQE",
    serial_number="EA183911496",
    pdu_port=_pdu_2.pdu_ports[3],
)

_enb_sbts = RealEnb(
    system_module=_smod,
    rms=[
        _rmod_1,
        _rmod_4,
        _rmod_6,
        _rmod_7,
    ],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.211.246", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

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
tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    ues=[_android_ue, _ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIA_ABIA_FZHR_FZFF-e_FZHJ",
)

__all__ = ["tl"]
