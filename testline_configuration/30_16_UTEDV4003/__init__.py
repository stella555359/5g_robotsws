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
from taf.config.testline import DU
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

_pdu_gnb = Gude(addr="10.44.200.101", port_numbers=[12], model="EPC", version="8221-1")

_abio_gnb = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1210400889",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1213511566",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.96", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=3
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASILL_ABIOB1_ORUSIM_EPCSIM",
    pdus=[_pdu_gnb],
)


class KVM:
    hostname = "10.42.61.103"


setattr(tl, "kvm", KVM)

setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.61.96")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "gnb_logic_group", [[1]])

setattr(tl, "oran_sim_pc_host", ["10.42.61.96"])
setattr(tl, "oran_sim_version", ["v2.1.33"])
setattr(tl, 'oru_to_gnb_fh_interface', ["docker0"])
setattr(tl, "oran_sim_container_id", ["ute_oran_sim_0"])
setattr(tl, "oran_sim_pc_port", ["eth3"])
setattr(tl, "oran_sim_path", ["/home/ute/ute_oran_sim_0"])
setattr(tl, "oran_sim_container_path", ["/etc/orusim"])
setattr(tl, "oran_sim_container_serial_numbers", ["S000001"])

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")
setattr(tl, "gnb_radio_info", {1: {"O-RU Sim": {"1": 1}}})

######   dummy variables for SR

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
setattr(tl, "enb_control_pc_host", "10.42.61.96")
setattr(tl, "ute_control_pc_host", "10.42.61.96")
setattr(tl, "gnb_control_pc_host", ["10.42.61.96"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "epc_host", "10.42.61.96")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "l3sim_host", "10.42.75.3")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "dct_host", "10.42.221.154")
setattr(tl, "rnc_3g_host", "10.42.221.154")
setattr(tl, "tm500_3g_host", "10.42.221.154")
setattr(tl, "oam_airframe_l3sim_host", "10.42.75.3")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "ATEN")
setattr(tl, "oam_airframe_mmt_host", "0.0.0.0")
setattr(tl, "gnb_card_slot", [[1, 2]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25, 25]])
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
