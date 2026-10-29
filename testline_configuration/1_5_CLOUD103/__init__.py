__owner__ = "Dong Vinton"
__maintainer__ = "Dong Vinton"
__email__ = "vinton.dong@nokia-sbell.com"

from taf.config.testline.ue import Android
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
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNTafUeAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid

_pdu_1 = FACOM(addr="10.69.3.228", port_numbers=[1, 2, 4, 7, 8])
_pdu_2 = FACOM(addr="10.69.238.67", port_numbers=[2])



_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805390",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607804",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607799",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="6Q174523188",
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

_smod_1 = Airscale([_fct_1])

_ue_pc_ssh = SshServiceDetails(
    addr="10.69.68.99", username="SISO2-tester", password="Nokia123!"
)

_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="UQG5T20A29004523",
    server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.5.9.54---05161057/Pioneer.exe",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM5",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)

_rmod_1 = RU(
    ru_hw_group="AZQD:FRMTDr5.1_4T4R_LP",
    serial_number="EA190313253",
    pdu_port=_pdu_1.pdu_ports[7],
    product_code="474798A.X21",
)

_rmod_2 = RU(
    ru_hw_group="AZQD:FRMTDr5.1_4T4R_LP",
    serial_number="EA190313244",
    pdu_port=_pdu_1.pdu_ports[8],
    product_code="474798A.X21",
)

_rmod_3 = RU(
    ru_hw_group="AZQD:FRMTDr5.1_4T4R_LP",
    serial_number="EB191060020",
    pdu_port=_pdu_1.pdu_ports[1],
    product_code="474798A.101",
)
_rmod_4 = RU(
    ru_hw_group="AZNA:FRMTDr5.1_1_4T4R",
    serial_number="6Q184422159",
    pdu_port=_pdu_1.pdu_ports[2],
    product_code="473914A.102",
)
_rmod_5 = RU(
    ru_hw_group="FZFH:HW1.0_2T2R_DB",
    serial_number="11DTP9WJ8000361",
    pdu_port=_pdu_1.pdu_ports[4],
    product_code="473256A.06HWxxA12E2",
)


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[])
# _enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2
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

_pdn1 = PDNTafUeAndroidDetails(entryName='stdata2',
                          apnName='stdata2',
                          apnType=['DEFAULT'])


# _android_ue = Android(
#     ssh_connection_details=_ue_pc_ssh,
#     serial_number="UQG5T20A29004523",
#     server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.5.9.54---05161057/Pioneer.exe",
#     python_path="C:/Python27/python.exe",
#     qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
#     diag_cfg_path="C:/pyro_server/DIAG.cfg",
#     dmc_path="C:/Users/user-lab0/adam.dmc",
#     diag_com="COM5",
#     iperf_details=_android_iperf,
#     capabilities=["REAL_ANDROID_UE", "REAL_UE"],
# )
# _ue_pc_ssh = SshServiceDetails(
#     addr="10.69.68.99", username="SISO2-tester", password="Nokia123!"
# )

_android1 = TafUeAndroid(serial_number='UQG5T20A29004523',
                         capabilities=['REAL_UE'],
                         ue_pc_address='10.69.68.99',
                         data_transfer=[_data_transfer_iperf],
                         ssh_connection_details=_ue_pc_ssh,
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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.211.237", username="ute", password="ute"
    ),
    connections=[_smod_1.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts_1],
    ues=[_android1],
    #ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIAR_ABIAB1_ABIAB2_ABIAB3_FZFH_AZNA",
)
__all__ = ["tl"]

