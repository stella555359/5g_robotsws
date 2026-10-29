__maintainer__ = "Bartlomiej Lebda"
__team__ = "DCM"
__email__ = "bartlomiej.lebda@nokia.com"


from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.dcm_specific import MMTVM, DCMMiddleware
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.pdu import Gude
from taf.config.testline.simulator import RUsim
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    oam_http_connection_details=HttpConnectionDetails(addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443),
)

_pdu_gnb = Gude(addr="10.44.200.100", port_numbers=[2], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH214242035",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A1043",
    serial_number="L1220705771",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1221207214",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1204107431",
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_mmtvm_med = MMTVM(mmtvm_connection_info=SshServiceDetails(addr="10.42.221.250", username="plwrranpzk3", password="p_5PvX7#a3jz"), dct_interface=2)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=37)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"),
    hostos=SshServiceDetails(addr="10.42.75.33", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)


_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.42.221.154", username="ute", password="ute"),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_cbts.dus[0].airscale.common_units[0]),
        _mediator,
    ],
)

_rusim_1 = RUsim(test_pc=_lmp_vm_gnb_1, interface="eth3")

_rusim_2 = RUsim(test_pc=_lmp_vm_gnb_1, interface="eth4")


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASILL_3xABIOB1B2B3_2xORUSIM_MED_EPC",
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.33"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.221.250"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class KVM:
    hostname = "10.42.221.151"


setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.221.154")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")

setattr(tl, "oran_sim_pc_port", ["eth3"])

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.187")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_20")

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
setattr(tl, "enb_control_pc_host", "10.42.221.154")
setattr(tl, "ute_control_pc_host", "10.42.221.154")
setattr(tl, "gnb_control_pc_host", ["10.42.221.154"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "epc_host", "10.42.221.154")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "l3sim_host", "10.42.221.154")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "dct_host", "10.42.221.154")
setattr(tl, "rnc_3g_host", "10.42.221.154")
setattr(tl, "tm500_3g_host", "10.42.221.154")
setattr(tl, "oam_airframe_l3sim_host", "10.42.221.154")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "ATEN")
setattr(tl, "oam_airframe_mmt_host", "0.0.0.0")
setattr(tl, "gnb_card_slot", [[1, 2]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25, 25]])
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
