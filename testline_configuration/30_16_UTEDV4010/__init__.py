__maintainer__ = "Mariusz Kozlowski"
__team__ = "DCM"
__email__ = "mariusz.kozlowski@nokia.com"


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

_pdu_gnb = ATEN(addr="10.42.61.202", port_numbers=[1])

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="mock",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="mock",
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.75.29", username="labadmin", password="uteadmin"
    ),
    dct_interface=2,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.75.47", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.11", username="ute", password="ute"
    ),
    connections=[_asil_gnb, _mediator],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASILL_2xABIOB1B2_1xORUSIM_MED_EPC",
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.47"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.29"
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
    hostname = "10.42.75.32"


setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.75.58")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")


setattr(tl, 'af_type', 'AFRM')
setattr(tl, 'af_bmc_ip', '10.42.208.106')
setattr(tl, 'af_bmc_bridge_ip', '10.42.75.11')
setattr(tl, 'af_bmc_username', 'admin')
setattr(tl, 'af_bmc_passwd', 'admin')
setattr(tl, 'ne3s_alarm_white_list', ['61029', '7115', '7107', '7116', '61050', '7220', '7100'])

setattr(tl, 'enable_af_ssh_reset_WA', 'yes')

setattr(tl, "ue_control_pc_user", "ute")
setattr(tl, "ue_control_pc_pwd", "ute")

setattr(tl, 'oam_airframe_mmt_host_user', 'plwrranpzk3')
setattr(tl, 'oam_airframe_mmt_host_password', 'p_5PvX7#a3jz')

setattr(tl, 'gnb_logic_group', [[1]])

setattr(tl, "oran_sim_pc_host", ["10.42.75.11"])
setattr(tl, "oran_sim_version", ["UE_APP-OAM-0.1908"])

setattr(tl, "oran_sim_container_id", ["ru_sim_0"])
setattr(tl, "oran_sim_pc_port", ["eth4"])
setattr(tl, "oran_sim_path", ["/home/ute/ru_sim_0"])
setattr(tl, "oran_sim_container_path", ["/etc/orusim/"])

setattr(tl, 'gnb_scard_name', 'ASIL')
setattr(tl, 'gnb_bcard_name', 'ABIO')

setattr(tl, 'oam_airframe_mediator_host', '10.42.75.47')  # MEDIATOR HOST OS
setattr(tl, 'oam_airframe_mediator_user', 'root')
setattr(tl, 'oam_airframe_mediator_pwd', 'uteadmin')

setattr(tl, 'oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
setattr(tl, 'oam_airframe_mediator_guest_user', 'toor4nsn')
setattr(tl, 'oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

setattr(tl, 'oam_airframe_mediator_interface', 'ens4f0')  # dcmnet
setattr(tl, 'oam_airframe_mediator_sudo_pwd', 'uteadmin')

setattr(tl, 'gnb_control_pc_user', 'ute')
setattr(tl, 'gnb_control_pc_pwd', 'ute')

setattr(tl, "mrbts_id", "1")

setattr(tl, 'gnb_id_list', [1])
setattr(tl, 'gnb_radio_info',
             {
                 tl.gnb_id_list[0]:
                     {
                         'O-RU Sim':
                             {
                                 '1': 1,
                             }
                     }
             })
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
