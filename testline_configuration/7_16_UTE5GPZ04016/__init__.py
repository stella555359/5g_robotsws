__maintainer__ = "Krzysztof Kulibab"
__team__ = "MN RAN K3"
__email__ = "krzysztof.kulibab@nokia.com"

from taf.config.testline.testline import TestLine

from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.connection_details import (SshServiceDetails, HttpConnectionDetails)
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

from taf.config.testline.attenuator import TopYoung
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.pdn import PDNTafUeAndroidDetails

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu"),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129",
        username="Nemuadmin",
        password="nemuuser",
        port=443)
)

_abio_gnb = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1223319778",
)
_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1223319779",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu"),
    capacity_units=[_abio_gnb, _abio_gnb_2],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224704433",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.85",
        username="ute",
        password="ute"),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1,
                 rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1,
    dus=[_du_1_gnb_1],
    global_bts_id=1,
    instance_id=1)

_attenuator = TopYoung(
    ip_addr="10.44.234.119",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_12T12_51_90_1S_EJS",
)

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.44.234.178",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.44.234.86",
    user="ute",
    password="ute",
    bind_interface_ip="3.7.254.254",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    server_close_delay=200,
    interval=1,
    version=2
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='mopera.net',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_Qualcomm = TafUeAndroid(
    serial_number="9e3115e4",
    ue_pc_address="10.44.234.178",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "Qualcomm"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1]
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    attenuator=_attenuator,
    tl_cloud_topology="",
    ues=[_Qualcomm],
)

setattr(tl, "oam_http_addr", "192.168.255.129")
setattr(tl, "oam_http_port", "443")
setattr(tl, "oam_http_username", "Nemuadmin")
setattr(tl, "oam_http_password", "nemuuser")

setattr(tl, "ue_pc_addr", "10.44.234.178")
setattr(tl, "ue_pc_username", "plwrranpzk3")
setattr(tl, "ue_pc_password", "p_5PvX7#a3jz")

setattr(tl, "lmp_connection_addr", "192.168.255.129")
setattr(tl, "lmp_connection_username", "toor4nsn")
setattr(tl, "lmp_connection_pass", "oZPS0POrRieRtu")

setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")

setattr(tl, "hdbde_vm_ip_address", "10.44.234.86")
setattr(tl, "hdbde_egate_port", "20000")
setattr(tl, "hdbde_edaemon_port", "10000")
setattr(tl, "hdbde_edaemon_l3sim_port", "10010")
setattr(tl, "hdbde_edaemon_enb_port", "10020")

setattr(tl, "mrbts_id", "700160")
setattr(tl, "nrbts_id", "700160")

setattr(tl, "appserver_addr", "10.42.61.61")
setattr(tl, "appserver_f1_addr", "10.42.197.171")
setattr(tl, "appserver_username", "syslab")
setattr(tl, "appserver_password", "system")

setattr(tl, "hdbde_mmt_ip", "192.168.129.3")
setattr(tl, "hdbde_mmt_dct0", "1")
setattr(tl, "hdbde_control_pc_host", "10.44.234.87")
setattr(tl, "hdbde_control_pc_user", "labadmin")
setattr(tl, "hdbde_control_pc_password", "uteadmin")
