__maintainer__ = "Adam Mazik"
__team__ = "DCM"
__email__ = "adam.mazik@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, Gude, EPC
from taf.config.testline.connection_details import SshServiceDetails, IperfDataTransferDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.dcm_specific import MMTVM, DCMMiddleware

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.200.72", port_numbers=[12], model="EPC", version="8220-1")
_pdu_gnb_ru = Gude(addr="10.44.200.99", port_numbers=[7, 9], model="EPC", version="8220-1")


_pdus = [_pdu_gnb, _pdu_gnb_ru]


_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508035",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1213511588",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="SJEOSQA2302S0027",
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
    attenuation_ports=[],
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_core = RealCore5G()

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.42.75.55",
                               user="ute",
                               password="ute",
                               expected_prompt="dummy_prompt")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 server_close_delay=200,
                                                 interval=1,
                                                 version=2)


_appserver_ssh = SshServiceDetails(
    addr="10.42.61.61", username="syslab", password="system"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.42.61.61",
    iperf_path="/system/bin/iperf",
)

_android = TafUeAndroid(
    ue_pc_address='10.42.224.212',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.212", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    serial_number="ffe39602",
    path_to_network_mode_type='Mobile network/Preferred network type',
    ue_pc_port="80",
    qualcomm_prototype=False,
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    network_mode_switch_method='adb',
    capabilities=['REAL_UE']
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.75.26", username="labadmin", password="uteadmin"
    ),
    dct_interface=2,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.54.66", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.8", username="ute", password="ute"
    ),
    connections=[_asil_gnb, _mediator],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASILL_ABIPB1_MED_HDBDE_FRGH_SAMJI_QC",
    core=_core,
    pdus=[_pdu_gnb,_pdu_gnb_ru],
)


class HDBDE:
     class MMT:
         hostname = "10.42.54.215"
         username = "labadmin"
         password = "uteadmin"
         dct_interface = "2"

     class WTS:
         hostname = "10.42.75.55"
         username = "ute"
         password = "ute"

     hostname = "192.168.129.3"
     username = "toor4nsn"
     password = "oZPS0POrRieRtu"

     mmt_vm = MMT
     wts_vm = WTS

class Mediator:
     class GuestOS:
         hostname = '172.16.11.18'
         username = 'root'
         password = 'uteadmin'

     class HostOS:
         hostname = '10.42.54.66'
         username = 'root'
         password = 'uteadmin'

     class MMT:
         hostname = "10.42.75.26"
         username = "labadmin"
         password = "uteadmin"
         dct_interface = "2"

     hostname = "192.168.129.3"
     username = "toor4nsn"
     password = "oZPS0POrRieRtu"

     guest_os = GuestOS
     host_os = HostOS
     mmt_vm = MMT


class KVM:
    hostname = "10.42.75.34"


setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "hdbde", HDBDE)
setattr(tl, "ues", [_android])
setattr(tl, 'wtssim_egate_port', '20000')
setattr(tl, 'wtssim_edaemon_port', '10000')
setattr(tl, 'wtssim_edaemon_port2', '10010')
setattr(tl, 'wtssim_edaemon_port3', '10020')
setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, "mrbts_id", "7")
setattr(tl, "ltesim_pc_host", "10.42.75.55")
setattr(tl, "ltesim_x2_addr", "10.42.75.55")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.95")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")
setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")
setattr(tl, "gnb_radio_info", {1: {"O-RU Sim": {"1": 1}}})
setattr(tl, "enable_af_ssh_reset_WA", "no")
setattr(tl, "enb_type", "epc")
setattr(tl, 'gnb_id_list', [1])
setattr(tl, "tm500_ver", "HSUPA - E4.0.4")
setattr(tl, "enb_cpri_links", "[1, 4, 14, 17, 27, 30, 7, 8, 9, 2]")
setattr(tl, "has_mmt_tool", "false")
setattr(tl, "windows_control_pc_user", "ute")
setattr(tl, "windows_control_pc_pwd", "ute")
setattr(tl, "oam_airframe_mmt_host_user", "labadmin")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")
setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')
setattr(tl, "enb_control_pc_user", "ute")
setattr(tl, "enb_control_pc_password", "ute")
setattr(tl, "enb_control_pc_host", "10.42.75.8")
setattr(tl, "ute_control_pc_host", "10.42.75.8")
setattr(tl, "gnb_control_pc_host", ["10.42.75.8"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "epc_host", "10.42.75.55")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "l3sim_host", "10.42.75.55")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "dct_host", "10.42.221.154")
setattr(tl, "rnc_3g_host", "10.42.221.154")
setattr(tl, "tm500_3g_host", "10.42.221.154")
setattr(tl, "oam_airframe_l3sim_host", "10.42.75.8")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "Gude")
setattr(tl, "gnb_pdu_type", "Gude")
setattr(tl, "oam_airframe_mmt_host", "0.0.0.0")
setattr(tl, "gnb_card_slot", [[1, 2]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25, 25]])
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
