__maintainer__ = "qianzhou"
__owner_email__ = "qiang.1.zhou@nokia-sbell.com"
__email__ = "qiang.1.zhou@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM, TopYoung, HBTE
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

_pdu_1 = FACOM(addr="10.106.208.165", port_numbers=[4])
_pdu_2 = TopYoung(addr="10.68.160.37", port_numbers=[1, 2, 3])  # 3*AHFII
_pdu_3 = FACOM(addr="10.106.208.165", port_numbers=[1])  # AHEGC1 SN:EA215156167
_pdu_4 = FACOM(addr="10.106.208.165", port_numbers=[2])  # AHEGC2 SN:EA215156172
_pdu_5 = HBTE(addr="10.106.208.161", port_numbers=[1, 2, 6])  # AHEGC3 SN:EA215156196
_pdu_6 = HBTE(addr="10.106.208.170", port_numbers=[6])  # AHEGC4 SN:EA215156185

# _ru_enb_pdu = TopYoung(addr="10.101.45.54", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_rmod_1 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHFII",
    serial_number="BL2220N4043",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHFII",
    serial_number="BL2221N405P",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHFII",
    serial_number="BL2222N4072",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHEGC",
    serial_number="EA215156167",
    pdu_port=_pdu_5.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHEGC",
    serial_number="EA215156172",
    pdu_port=_pdu_5.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHEGC",
    serial_number="EA215156196",
    pdu_port=_pdu_5.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHEGC",
    serial_number="EA215156185",
    pdu_port=_pdu_6.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIN",
    hardware_version="473096A.101",
    serial_number="L1204212516",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204703420",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1203700859",
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    f1_m_ip_addr="192.168.255.1",
)  # 5G S1 IP

# CU
_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=10718, global_bts_id=10718
)

# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

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
print(_ue_config)
_ue_pc_ssh = SshServiceDetails(
    addr="10.106.208.163", username="siso3-tester", password="Nokia123!"
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
    serial_number="9YS0220214012978",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["huawei", "REAL_UE"],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.68.94.123", username="ute"),
    connections=[
        _classical_bts_1.dus[0].airscale.common_units[0],
        _android_ue,
        _ue_config,
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_android_ue, _ue_config],
    # ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIL_ABIO_ABIN_3xAHFII_4xAHEGC",
)
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])


__all__ = ["tl"]
