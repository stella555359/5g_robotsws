__maintainer__ = "Monika Szczeciak"
__team__ = "DCM"
__email__ = "monika.szczeciak@nokia.com"

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

_pdu_gnb = Gude(addr="10.44.200.100", port_numbers=[1], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223309958",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223309938",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244685",
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.201", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223310008",
)

_abio_gnb_4 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223309967",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_3, _abio_gnb_4],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244558",
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.202", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_airscale_gnb_1 = Airscale([_asil_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=38
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASIL_3xABIO_2xORUSIM_MED_EPC",
    pdus=[_pdu_gnb],
)


setattr(tl, "ltesim_pc_host", "10.42.75.218")

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.44.196.75")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")

setattr(tl, "enable_af_ssh_reset_WA", "no")
setattr(tl, "debug_run", "True")

setattr(tl, "gnb_logic_group", [[1]])
setattr(tl, "BTSID", "1")
setattr(tl, "mrbts_id", "1")

setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")

setattr(tl, "oran_sim_pc_host", ["10.42.75.201", "10.42.75.201"])
setattr(tl, "oran_sim_version", "v2.1.30")
setattr(tl, "oran_sim_container_id", ["docker2", "docker3", "docker4", "docker5", "docker6", "docker7"])
setattr(tl, "oran_sim_container_serial_numbers", ["S000001", "S000002", "S000003", "S000004", "S000005", "S000006"])
setattr(tl, "oran_sim_pc_port", ["eth2", "eth3", "eth4", "eth5", "eth6", "eth7"])
setattr(tl, "oran_sim_path", ["/home/ute/ute_oran_sim"])
setattr(tl, "oran_sim_container_path", ["/etc/orusim"])

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")

setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "ue_control_pc_user", "ute")
setattr(tl, "ue_control_pc_pwd", "ute")
setattr(tl, "windows_control_pc_user", "ute")
setattr(tl, "windows_control_pc_pwd", "ute")

setattr(tl, "dhcp_ip", "10.42.75.114")
setattr(tl, "dhcp_user", "ute")
setattr(tl, "dhcp_pwd", "UTE.debian12")

setattr(tl, 'oam_airframe_mmt_host_user', 'labadmin')
setattr(tl, 'oam_airframe_mmt_host_password', 'uteadmin')
setattr(tl, 'dm_enable', 'True')
setattr(tl, "hwy_type", "10g")
setattr(tl, 'tl_type', 'airframe')
setattr(tl, "oru_to_gnb_fh_interface", ["docker2", "docker3", "docker4", "docker5", "docker6", "docker7"])
setattr(tl, "oru_from_gnb_fh_interface", "1/0")
setattr(tl, "oru_sim_pc_user", "ute")
setattr(tl, "oru_sim_pc_password", "ute")
setattr(tl, "oru_sim_pc_host", ["10.42.75.201"])
setattr(tl, "tps_vpls_list", ["3101", "3102", "3103", "3104"])
setattr(tl, "tps_sap_mcuplane_list", ["C13", "C14", "C15", "C16"])
setattr(tl, "tps_vpls_card", "t24ps2")
setattr(tl, "tps_vpls_slot", "1/4")
setattr(tl, "tps_IP", "10.42.221.105")

setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')

setattr(tl, 'lmp_connection_addr', '192.168.255.129')
setattr(tl, 'lmp_connection_username', 'toor4nsn')
setattr(tl, 'lmp_connection_pass', 'oZPS0POrRieRtu')

setattr(tl, 'dm_enable', 'True')
setattr(tl, "hwy_type", "10g")
setattr(tl, 'tl_type', 'airframe')
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
