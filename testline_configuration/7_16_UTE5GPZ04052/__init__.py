__maintainer__ = "Michal Lys"
__team__ = "MN RAN K3 TL52"
__email__ = "michal.lys@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAt
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.pdu import ATEN, APC, FPFH, EPC, Gude
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails, IperfDataTransferDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol, TafUeAtDataTransferProtocol

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

_pdu_gnb = Gude(addr="10.44.205.218", port_numbers=[1], model="EPC", version="8221-1")

_abio1_gnb = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1223319780",
)
_abio2_gnb = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1231900192",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb, _abio2_gnb],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220350942",
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.222", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_core = None
# ---------------- START TAF_UE_PROXY UEs ----------------
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.42.224.211", username="plwrranpzk3", password="p_5PvX7#a3jz"
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.61",
    user="syslab",
    password="system",
    # bind_interface_ip="10.42.61.61",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=3
)

_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)

_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)

_Askey = TafUeAt(com_port='4',
                serial_number='1e644ed2',
                capabilities=['AT_UE'],
                ue_pc_address='10.42.224.211',
                ue_pc_login='plwrranpzk3',
                ue_pc_password='p_5PvX7#a3jz',
                # ue_pc_expected_prompt='plwrranpzk3@PLWRSRAN5708',
                # ue_expected_prompt='\/ #',
                data_transfer=[_data_transfer_iperf,
                               _data_transfer_ping,
                               _data_transfer_ftp],
                # phone_number='+358480500013',
                # ue_pc_port='8080',
                # imei='123456789',
                imsi='987654312'
                )
# ---------------- STOP TAF_UE_PROXY UEs ----------------
tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="",
    core=_core,
    pdus=[_pdu_gnb],
    ues=[_Askey],
)

class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.232"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.231"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = '2'

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ute_control_pc_host", "10.42.75.222")
setattr(tl, "gnb_control_pc_host",  ["10.42.75.222"])
# setattr(tl, "oam_airframe_l3sim_host", "10.42.75.222")
setattr(tl, "oam_airframe_mmt_host", "10.42.75.231")
setattr(tl, "oam_airframe_mmt_dct0", "2")
setattr(tl, "enb_control_pc_user", "labadmin")
setattr(tl, "enb_control_pc_password", "uteadmin")
setattr(tl, "enb_lcp_list",  [0])
setattr(tl, "enb_lsp_list",  [])
setattr(tl, "enb_fan_list",  [])
setattr(tl, "enb_lbr_list",  [])
setattr(tl, "enb_lni_list",  [])
setattr(tl, "enb_lps_list",  [0])
setattr(tl, "gnb_pdu_ip",  ["10.44.205.218"])
setattr(tl, "gnb_pdu_outlet",  [1])
setattr(tl, "gnb_id_list",  [1])
setattr(tl, "gnb_card_slot",  [[1, 2, 3]])
setattr(tl, "gnb_fh_connect",  [[1,2], [1]])
setattr(tl, "gnb_fh_bitrate",  [[25, 25], [25]])

#----------
setattr(tl, "gnb_pdu_type", "GUDE")
setattr(tl, "gnb_pdu_version", "8221-1")
#setattr(tl, "AS_TYPE", "ASIL_ABIO_ORAN")
setattr(tl, "wtssim_vm_ip", "10.42.75.222")
setattr(tl, "ltesim_pc_host", "10.42.75.229")
setattr(tl, "x2_vm_ip", "10.42.75.229")

setattr(tl, "af_type", "AFRM")
# setattr(tl, "af_bmc_ip", "10.42.54.53")
setattr(tl, "af_bmc_bridge_ip", "10.42.75.222")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")
setattr(tl,
    "ne3s_alarm_white_list", ["61029", "7115", "7107", "7116", "61050", "7220", "7100"]
)

setattr(tl, "enable_af_ssh_reset_WA", "yes")

setattr(tl, "gnb_logic_group", [[1]])

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")

setattr(tl, "oam_airframe_mediator_host", "10.42.75.232")
setattr(tl, "oam_airframe_mediator_user", "ute")
setattr(tl, "oam_airframe_mediator_pwd", "Ut3pa5s#1be1")
setattr(tl, "oam_airframe_mediator_interface", "ens4f0")
setattr(tl, "oam_airframe_mediator_sudo_pwd", "ute")

# setattr(tl,
#     "gnb_radio_info",
#     {
#         tl.gnb_id_list[0]: {
#             "O-RU Sim": {
#                 "1": 1,
#             }
#         }
#     },
# )

setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "ue_control_pc_user", "labadmin")
setattr(tl, "ue_control_pc_pwd", "uteadmin")
setattr(tl, "windows_control_pc_user", "labadmin")
setattr(tl, "windows_control_pc_pwd", "uteadmin")
# setattr(tl, "ue_control_pc_user", "plwrranpzk3")
# setattr(tl, "ue_control_pc_pwd", "p_5PvX7#a3jz")
# setattr(tl, "windows_control_pc_user", "plwrranpzk3")
# setattr(tl, "windows_control_pc_pwd", "p_5PvX7#a3jz")

setattr(tl, 'oam_airframe_mmt_host_user', 'labadmin')
setattr(tl, 'oam_airframe_mmt_host_password', 'uteadmin')

setattr(tl, 'oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
setattr(tl, 'oam_airframe_mediator_guest_user', 'toor4nsn')
setattr(tl, 'oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

setattr(tl, 'iug_ip_addr', '10.42.75.214')
setattr(tl, 'iug_connection_username', 'admin')
setattr(tl, 'iug_connection_pass', 'admin1234')

setattr(tl, 'pdu_iug_ip_addr', '10.44.205.218')
setattr(tl, 'pdu_iug_model', 'GUDE')
setattr(tl, 'pdu_iug_port', '5')

setattr(tl, 'ue_pc_addr', '10.42.224.211')
setattr(tl, 'ue_pc_username', 'plwrranpzk3')
setattr(tl, 'ue_pc_password', 'p_5PvX7#a3jz')

setattr(tl, "oam_http_addr", "192.168.255.129")
setattr(tl, "oam_http_port", "443")
setattr(tl, "oam_http_username", "Nemuadmin")
setattr(tl, "oam_http_password", "nemuuser")
setattr(tl, "lmp_connection_username", "toor4nsn")
setattr(tl, "lmp_connection_pass", "oZPS0POrRieRtu")

# setattr(tl, "ltesim_egate_port", "20000")
# setattr(tl, "ltesim_edaemon_port", "10000")

setattr(tl, "mediator_uec_port", "10000")
setattr(tl, "mediator_l3_sim_port", "10020")
setattr(tl, "mediator_egate_port", "20022")

# setattr(tl, "epc_egate_port", "20000")
# setattr(tl, "epc_edaemon_port1", "10000")
# setattr(tl, "epc_edaemon_port2", "10010")
# setattr(tl, "epc_edaemon_port3", "10020")
# setattr(tl, "amf_edaemon_port", "30000")
# setattr(tl, "amf_egate_port", "40000")

setattr(tl, 'appserver_addr', '10.42.61.61')
setattr(tl, 'appserver_username', 'syslab')
setattr(tl, 'appserver_password', 'system')
setattr(tl, 'appserver_f1_addr', '10.42.61.61')
