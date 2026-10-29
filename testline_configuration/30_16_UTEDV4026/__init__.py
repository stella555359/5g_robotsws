__maintainer__ = "Ewa Burnecka"
__team__ = "MN RAN RD CIS CWO DCM Vrf WRO 3 (L06)"
__email__ = "ewa.burnecka@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline import Airphone
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.pdu import Gude

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_pdu_gnb = Gude(addr="10.44.200.85", port_numbers=[10], model="EPC", version="8220-1")
_pdu_apo = Gude(addr="10.44.200.85", port_numbers=[5], model="EPC", version="8220-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214608292",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH215140163",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH215140159",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _abio_gnb_1,
        _abio_gnb_2,
        _abio_gnb_3
    ],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1215007551",
    pdu_port=_pdu_gnb.pdu_ports[10]
)


_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.177", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1)

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[5],
            )
        ]
    ),
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary],
    gnbs=[_cbts],
    pdus=[_pdu_gnb, _pdu_apo],
    ues=[_ue],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.183"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.181"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 1

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class KVM:
    hostname = "10.42.75.185"


setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.75.177")
setattr(tl, "ltesim_x2_addr", "172.16.11.5") # why .5? maybe .50?
setattr(tl, "gnb_x2_addr", "172.16.11.200")

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.110")
setattr(tl, "af_bmc_username", "dcmuser")
setattr(tl, "af_bmc_passwd", "Test*OAM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_20") #according to the af type? oe19/oe20?

setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")

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
setattr(tl, "enb_control_pc_password", "UTE.debian12")
setattr(tl, "enb_control_pc_host", "10.42.75.177")
setattr(tl, "ute_control_pc_host", "10.42.75.177")
setattr(tl, "gnb_control_pc_host", ["10.42.75.177"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "UTE.debian12")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "epc_host", "10.42.75.177")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "l3sim_host", "10.42.75.177")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "dct_host", "10.42.75.177")
setattr(tl, "rnc_3g_host", "10.42.75.177")
setattr(tl, "tm500_3g_host", "10.42.75.177")
setattr(tl, "oam_airframe_l3sim_host", "10.42.75.177")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "ATEN")
setattr(tl, "oam_airframe_mmt_host", "0.0.0.0")
setattr(tl, "gnb_card_slot", [[1, 2]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25, 25]])
setattr(tl, "sw_builds_ftp_address", "10.68.251.31")
setattr(tl, "sw_builds_ftp_username", "ute")
setattr(tl, "sw_builds_ftp_password", "Nemuuser#365")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
