__owner__ = "Di Zheng"
__maintainer__ = "Di Zheng"
__email__ = "zheng.di@nokia-sbell.com"

import os
import re
import yaml
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_pdu_1 = FACOM(
    addr="10.56.7.139",
    port_numbers=[1, 3, 4],
    #    model="facom",
)

_rmod_1 = RU(
    ru_hw_group="AZQF:5314_2CL1_T4_L_247",
    radio_type="AZQF",
    serial_number="6Q182328541",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="AZQS:CB008970_SR_E_TD_RF_CS_373",
    radio_type="AZQS",
    serial_number="1M222429849",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206713",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220503976",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203864253",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Airscale([_fct_1])

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yaml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""


def config():
    import env

    print(__name__)
    m = env
    test_line_config = {}
    for att in dir(m):
        value = getattr(m, att)
        print(type(value))
        if att.startswith("_") or type(value) == "function":
            continue
        else:
            test_line_config[att] = getattr(m, att)
            print(att, getattr(m, att))
    print(test_line_config)
    return test_line_config


_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.123", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts.system_module.common_units[0],
        _ue_config,
        NetworkAddress(v4="192.168.255.126"),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIR_B4_AZQS_AZQF",
)

__all__ = ["tl"]
