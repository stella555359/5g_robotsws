__maintainer__ = "xilou"
__email__ = "xingxin.lou@nokia-sbell.com"

import os
import re
import yaml
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM, HBTE, TopYoung
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts

_pdu_1 = FACOM(addr="10.108.151.187", port_numbers=[1, 5])
_pdu_2 = TopYoung(addr="10.108.151.102", port_numbers=[3])
_pdu_3 = HBTE(addr="10.106.198.40", port_numbers=[4])

_rmod_1 = RU(
    ru_hw_group="eCPRI_RRH_64T64R",
    radio_type="AEHB",
    serial_number="L1213414031",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="OBSAI_RRH_6T6R",
    radio_type="FRGU",
    serial_number="K9172902118",
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204601138",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211508281",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_1, _rmod_2],    
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1185009188",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212076848",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1,_rmod_2], f1_m_ip_addr="10.108.151.182")  # 5G S1 IP
_du_2 = DU(airscale=_smod_2, rus=[_rmod_1], f1_m_ip_addr="10.108.151.182")
# CU
_cu = CU(
    backhaul_site_oam_ip="10.108.151.182",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.182", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(dus=[_du_1], cu=_cu, instance_id=335, global_bts_id=335)
_classical_bts_2 = ClassicalBts(dus=[_du_2], cu=_cu, instance_id=335, global_bts_id=335)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.198.185", username="ute", password="ute"),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.106.198.186", username="ute", password="ute"),
    connections=[_classical_bts_2.dus[0].airscale.common_units[0]],
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "./askey_ue_data.yml")
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


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIBLR_ABIOB1B4_AEHB_FRGU_FULLRACK",
)

__all__ = ["tl"]
