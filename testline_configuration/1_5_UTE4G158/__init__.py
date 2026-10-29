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
from taf.config.testline.pdu import FACOM
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
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNTafUeAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid

_pdu_1 = FACOM(addr="10.56.7.187", port_numbers=[7])
_pdu_2 = FACOM(addr="10.69.66.106", port_numbers=[1, 4])
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170221117",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162615490",
    pdu_port=_pdu_1.pdu_ports[7],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162704312",
    pdu_port=_pdu_1.pdu_ports[7],
)
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.68.94.15", username="ute"),
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="EA191572423",
)
_smod_1 = Airscale([_fct_1])

_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170221117",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162615490",
    pdu_port=_pdu_2.pdu_ports[1],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162704312",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473095A.203",
    serial_number="DH212444332",
)
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="1M172813693",
)
_rmod_2 = RU(
    ru_hw_group="CPRI_RRH_1T3R",
    serial_number="EA202550192",
)
_rmod_3 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="EA215153001",
)
_rmod_4 = RU(
    ru_hw_group="CPRI_RRH_2T2R",
    serial_number="EA215153005",
)
_rmod_5 = RU(
    ru_hw_group="CPRI_RRH_8T8R",
    serial_number="1M172443603",
)
_rmod_6 = RU(
    ru_hw_group="CPRI_RRH_2T2R",  ###what it use for?
    serial_number="6Q190247590",
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts = RealEnb(system_module=_smod_1, rms=[_rmod_6])

_du_1 = DU(
    airscale=_smod_2,
    rus=[_rmod_6],
    f1_m_ip_addr="10.68.160.50",
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

_classical_bts = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=6478, global_bts_id=6478
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

# _cfg_dir = os.path.dirname(os.path.abspath(__file__))
# _ue_config_path = os.path.join(_cfg_dir, "huawei_ue_data.yaml")
# if os.path.isfile(_ue_config_path):
#     with open(_ue_config_path) as f:
#         _ue_askey = f.read()
#         qci_port = re.findall("(_iperf.*?port)", _ue_askey)
#         for item in qci_port:
#             _ue_askey = _ue_askey.replace(item, str(eval(item)))
#         _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
# else:
#     _ue_config = ""
# print(_ue_config)

_ue_pc_ssh = SshServiceDetails(
    addr="10.56.7.212", username="siso2-tester", password="Nokia123!"
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
    serial_number="UQG5T20B19019608",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.68.94.15", username="ute"),
    connections=[_classical_bts],
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "nokia_cpe_data.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_android = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_android)
        for item in qci_port:
            _ue_android = _ue_android.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_android, Loader=yaml.FullLoader)
else:
    _ue_config = ""

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.69.64.197",
                               user="tdlte-tester",
                               password="btstest",
                               bind_interface_ip="10.69.64.196",
                               expected_prompt="~]$")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 )  # OPTIONAL

_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)

_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)

_pdn1 = PDNTafUeAndroidDetails(entryName='stdata1',
                          apnName='stdata1',
                          apnType=['DEFAULT'])


_android1 = TafUeAndroid(serial_number='UQG5T20B19019608',
                         capabilities=['REAL_UE'],
                         ue_pc_address='10.56.7.212',
                         data_transfer=[_data_transfer_iperf],
                         ssh_connection_details=SshServiceDetails(addr='10.56.7.212',
                                                                  username='siso2-tester',
                                                                  password='Nokia123!'),
                         phone_number='+358480500013',
                         ue_pc_port='8080',
                         imei='12345678912345',
                         imsi='260123456789',
                         pdns=[_pdn1],
                         # qualcomm_prototype=True,
                         # service_call_attach='16',
                         # service_call_detach='16',
                         # network_mode_switch_method='ADB',
                         # airplane_mode_switcher_text='Airplane',
                         # airplane_mode_confirm_button_text='OK',
                         # path_to_network_mode_type='Mobile networks/Preferred network type',
                         # secret_code='*#*#4636#*#*',
                         # is_rooted='no',
                         # voice_call_technology='2G',
                         # voice_call_technology_timeout=60.0,
                         # voice_call_dialing_timeout=-1.0
                         )

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.12", username="ute", password="ute"
    ),
    connections=[_smod_1.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_2,
    test_pcs=[_test_pc_2],
    #gnbs=[_classical_bts],
    enbs=[_enb_sbts],
    #ues=[_ue_config],
    ues=[_android1],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIAR_ABIAB1_ABIAB2_ABIAB3_2xFXDB_3xAHEGC",
)
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])


__all__ = ["tl"]
