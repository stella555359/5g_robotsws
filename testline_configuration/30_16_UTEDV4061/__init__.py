__maintainer__ = "Mateusz Kowalczyk"
__team__ = "MN RAN Pz DCM WRO 1"
__email__ = "mateusz.kowalczyk@nokia.com"

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

_pdu_gnb = Gude(addr="10.44.200.88", port_numbers=[12], model="EPC", version="8220-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101309",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1232101306",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1232101201",
)

_abio_gnb_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1211507994",
)

_abio_gnb_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIO",
    hardware_version="A104U",
    serial_number="L1223009467",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224704432",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_4, _abio_gnb_5],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1232304194",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_airscale_gnb_1 = Airscale([_asil_gnb_1, _asil_gnb_2])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=38
)

_core = RealCore5G()

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.61.18", username="labadmin", password="uteadmin"
    ),
    dct_interface=1,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.61.19", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.7", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1, _mediator],
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.9", username="ute", password="ute"
    ),
    connections=[_asil_gnb_2],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASIL_2xABIO_2xORUSIM_MED_EPC",
    core=_core,
    pdus=[_pdu_gnb],
)

class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.61.19"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.61.18"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "1"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "mediator", Mediator)

setattr(tl, "AS_TYPE", "ASIL_ABIO_ORAN")
setattr(tl, "ltesim_pc_host", "10.42.61.9")

setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.42.210.193")
setattr(tl, "af_bmc_bridge_ip", "10.42.61.7")
setattr(tl, "af_bmc_username", "dcmuser")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl,
    "ne3s_alarm_white_list", ["61029", "7115", "7107", "7116", "61050", "7220", "7100"]
)
setattr(tl, "oam_airframe_mediator_host", "10.42.61.19")
setattr(tl, "oam_airframe_mediator_user", "root")
setattr(tl, "oam_airframe_mediator_pwd", "uteadmin")
setattr(tl, "oam_airframe_mediator_interface", "ens4f0")
setattr(tl, "oam_airframe_mediator_sudo_pwd", "uteadmin")


setattr(tl, "enable_af_ssh_reset_WA", "yes")

setattr(tl, "gnb_logic_group", [[1]])

setattr(tl, "oran_sim_pc_host", ["10.42.61.7", "10.42.61.7", "10.42.61.7", "10.42.61.7", "10.42.61.7"])
setattr(tl, "oran_sim_version", ["UE_APP-OAM-0.2507", "UE_APP-OAM-0.2507", "UE_APP-OAM-0.2507", "UE_APP-OAM-0.2507", "UE_APP-OAM-0.2507"])

setattr(tl, "oran_sim_container_id", ["ute_oran_sim", "ute_oran_sim2", "ute_oran_sim3", "ute_oran_sim4", "ute_oran_sim5"])
setattr(tl, "oran_sim_pc_port", ["eth5", "eth6", "eth7", "eth8", "eth9"])
setattr(tl, "oran_sim_path", ["/home/ute/ute_oran_sim", "/home/ute/ute_oran_sim2", "/home/ute/ute_oran_sim3", "/home/ute/ute_oran_sim4", "/home/ute/ute_oran_sim5"])
setattr(tl, "oran_sim_container_path", ["/etc/rusim/", "/etc/rusim/", "/etc/rusim/", "/etc/rusim/", "/etc/rusim/"])

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")

setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "ue_control_pc_user", "ute")
setattr(tl, "ue_control_pc_pwd", "ute")
setattr(tl, "windows_control_pc_user", "ute")
setattr(tl, "windows_control_pc_pwd", "ute")

setattr(tl, "oam_airframe_mmt_host_user", "labadmin")
setattr(tl, "oam_airframe_mmt_host", "10.42.61.18")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")

setattr(tl, "lmp_connection_addr", "192.168.255.129")
setattr(tl, "lmp_connection_username", "toor4nsn")
setattr(tl, "lmp_connection_pass", "oZPS0POrRieRtu")

setattr(tl, "enb_control_pc_user", "labadmin")
setattr(tl, "enb_control_pc_password", "uteadmin")

setattr(tl, 'oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
setattr(tl, 'oam_airframe_mediator_guest_user', 'toor4nsn')
setattr(tl, 'oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

setattr(tl, "oam_http_addr", "192.168.255.129")
setattr(tl, "oam_http_port", "443")
setattr(tl, "oam_http_username", "Nemuadmin")
setattr(tl, "oam_http_password", "nemuuser")

setattr(tl, "mediator_uec_port", "10000")
setattr(tl, "mediator_edaemon_port", "10010")
setattr(tl, "mediator_l3_sim_port", "10020")
setattr(tl, "mediator_egate_port", "20000")
setattr(tl, "gnb_control_pc_host", ["10.42.61.7"])
setattr(tl, "ute_control_pc_host", "10.42.61.7")
setattr(tl, "oam_airframe_mmt_dct0", "1")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
