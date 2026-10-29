__owner__ = "Wu Amy"
__maintainer__ = "Wu Amy"
__email__ = "amy.wu@nokia-sbell.com"

import os
import re
import yaml
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.testpc import TestPc


_pdu_1 = FPFH(
    addr="10.69.67.105",
    port_numbers=[1, 3, 4, 5],
)

_pdu_2 = FPFH(
    addr="10.56.7.133",
    port_numbers=[1, 2, 3, 5, 6],
)

_pdu_3 = FPFH(
    addr="10.69.66.102",
    port_numbers=[1],
)

_pdu_4 = FACOM(
    addr="10.56.7.232",
    port_numbers=[2],
)

_rmod_1 = RU(
    ru_hw_group="OBSAI_RRH_6T6R",
    radio_type="FRPA",
    serial_number="EA170910436",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="OBSAI_RRH_6T6R",
    radio_type="FRPA",
    serial_number="EA170910428",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="EA223754908",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="ARHA",
    serial_number="1M212702072",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="ARHA",
    serial_number="1M213115852",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="ARHA",
    serial_number="1M213115860",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_7 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AHEGB",
    serial_number="EA223757656",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AHEGC",
    serial_number="EA231152064",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AHEGC",
    serial_number="EA231152085",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_10 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AHEGC",
    serial_number="EA231152063",
    pdu_port=_pdu_3.pdu_ports[1],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1214206701",
    pdu_port=_pdu_4.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1215206588",
    pdu_port=_pdu_4.pdu_ports[2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1231505870",
    pdu_port=_pdu_4.pdu_ports[2],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_4.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1223306797",
    capacity_units=[_fsp_3],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8,
                                              _rmod_9, _rmod_10])

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.204", username="ute", password="ute"
    ),
    connections=[_enb_sbts.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
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

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FH_CRT2_1058",
)

__all__ = ["tl"]
