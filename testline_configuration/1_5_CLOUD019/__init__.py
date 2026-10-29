__owner__ = "Wu Xiaotong"
__maintainer__ = "Wu Xiaotong"
__email__ = "xiaotong.wu@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.fhs import FHS

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)


_pdu_1 = FACOM(addr="10.56.7.123", port_numbers=[1, 2, 3])

_pdu_2 = FPFH(addr="10.56.7.171", port_numbers=[1, 4], password="admin")

_pdu_3 = FACOM(addr="10.106.211.92", port_numbers=[1, 7])

_pdu_4 = HBTE(addr="10.106.208.47", port_numbers=[1])

_pdu_5 = FACOM(addr="10.106.208.42", port_numbers=[3])

_pdu_6 = FACOM(addr="10.106.211.88", port_numbers=[5])

_rmod_1 = RU(
    ru_hw_group="AHBB:CPRI_A_RRH_4T4R",
    radio_type="AHBB",
    serial_number="EA183313004",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="AHBB:CPRI_A_RRH_4T4R",
    radio_type="AHBB",
    serial_number="EA183313043",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="AHLBA:CPRI_A_RRH_4T4R",
    radio_type="AHLBA",
    serial_number="K9180709091",
    pdu_port=_pdu_4.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="UHLC:CPRI_A_RRH_4T4R",
    radio_type="UHLC",
    serial_number="17YD07000265",
    pdu_port=_pdu_5.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="UHLC:CPRI_A_RRH_4T4R",
    radio_type="UHLC",
    serial_number="13W363G30012",
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_6 = RU(
    ru_hw_group="AHLBA:CPRI_A_RRH_4T4R",
    radio_type="AHLBA",
    serial_number="K9180709089",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="UHLC:CPRI_A_RRH_4T4R",
    radio_type="UHLC",
    serial_number="13W363G30013",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="AHLBA:CPRI_A_RRH_4T4R",
    radio_type="AHLBA",
    serial_number="K9183948209",
    pdu_port=_pdu_2.pdu_ports[4],
)

_fhs_1 = FHS(
    fhs_type="AFAA",
    pdu_port=_pdu_6.pdu_ports[5],
    serial_number="6Q191127117",
    product_code="474122A.101",
    rus=[_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184380927",
    pdu_port=_pdu_1.pdu_ports[1],
    fhs=[_fhs_1],
    rus=[_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184380912",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2],
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA184776790",
    capacity_units=[_fsp_1,  ],
)

_airscale_enb = Airscale(common_units=[_common_unit])

_enb_sbts = RealEnb(
    system_module=_airscale_enb,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
    oam_ip=NetworkAddress("10.56.7.88"),
    instance_id=2482,
)


_test_pc = TestPc(
    SshServiceDetails(addr="10.106.213.91", username="ute", password="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_common_unit, interface_type="lmp"), _ue_config
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIAL_ABIAB1B2_3xUHLC_2xAHBB_2xAHLBA",
)

__all__ = ["tl"]
