__maintainer__ = "Michal Lys"
__team__ = "MN RAN DCM Vrf WRO"
__email__ = "michal.lys@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN, APC, FPFH, EPC, Gude
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import TafUeAt, TafUeAndroid, Android
from taf.config.testline.connection_details import SshServiceDetails, IperfDataTransferDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.attenuator import TopYoung


__all__ = ["tl"]


class LteRU(RU):
    """
    Class for LTE RU model representation
    """
    def __init__(
            self, ru_hw_group, radio_type, pdu_port, default_ssh_connection_details,
            serial_number=None, product_code=None, cells=None
    ):
        """
        :param ru_hw_group: Radio Unit hardware group
        :type ru_hw_group: str
        :param radio_type: (unique identifier) of the radio module, should be one of RadioTypes" attributes
        :type radio_type: str
        :param pdu_port: PduPort class instance object, mandatory parameter
        :type pdu_port: PduPort
        :param default_ssh_connection_details: SshServiceDetails class instance object
        :type default_ssh_connection_details: SshServiceDetails
        :param serial_number: serial number of RU
        :type serial_number: str
        :param product_code: product code of RU
        :type product_code: str
        :param cells: dict containing HDBDE/LTE cell index as a key and its information as value
                      Example for cell with index 1 with sector 3 and carrier number 1
                      {1: {"sector": 3, "carrier": 1}}
        :type cells: dict[int, dict[str, Any]]
        """
        super().__init__(
            ru_hw_group,  default_ssh_connection_details=default_ssh_connection_details, pdu_port=pdu_port,
            radio_type=radio_type, serial_number=serial_number, product_code=product_code
        )
        self.cells = cells


_pdu_gnb = Gude(addr="10.45.177.8", port_numbers=[5], model="EPC", version="8221-1")
_pdu_gnb2 = Gude(addr="10.45.177.8", port_numbers=[1], model="EPC", version="8221-1")

_pdu_ru_1 = Gude(addr="10.45.177.0", port_numbers=[2], model="EPC", version="8221-1")
_pdu_ru_2 = Gude(addr="10.45.177.0", port_numbers=[10], model="EPC", version="8221-1")


# --------------------------- gNB 1 ---------------------------

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_abio_1_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1223310016",
)
_abio_2_gnb_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214608291",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_1, _abio_2_gnb_1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1220307984",
    pdu_port=_pdu_gnb.pdu_ports[5],
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1240400120",
    pdu_port=_pdu_gnb2.pdu_ports[1],
)

_ru_1_gnb_1 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQC",
    serial_number="1M242710755",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.132.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_pdu_ru_1.pdu_ports[2]
)

_ru_2_gnb_1 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="NWA-A14432-001",
    serial_number="Na2366010376",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="", password=""
    ),
    pdu_port=_pdu_ru_2.pdu_ports[10]
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.145.11", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.145.28", username="ute", password="ute"
    ),
    connections=[_asil_gnb_2],
)

_airscale_gnb_1 = Airscale([_asil_gnb_1])
_airscale_gnb_2 = Airscale([_asil_gnb_2])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1_gnb_1, _ru_2_gnb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50013, instance_id=1
)

_core = RealCore5G()

# --------------------------- UEs ---------------------------

_ue_ctrl_pc_ssh_details = SshServiceDetails(addr="10.44.234.238", username="plwrranpzk3", password="p_5PvX7#a3jz")

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.61",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.171",
    expected_prompt="syslab@wl-srn-server-2-idf3_4"
)

_app_server_2 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
    expected_prompt="syslab@wl-srn-server-1-idf3_4"
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf", app_server=_app_server_2, version=3)
_data_transfer_ping = TafUeDataTransferProtocol(protocol_name="ping", app_server=_app_server_2, interval=1)
_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name="ftp", app_server=_app_server_2, interval=1)

_Nokia83 = TafUeAndroid(
    serial_number='HZQN1876AAK90900733',
    ue_pc_address="10.44.234.238",
    capabilities=["REAL_UE"],
    network_mode_switch_method="ADB",
    path_to_network_mode_type="Mobile network/Preferred network type",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=False,
    pdns=[_pdn1],
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
)

_qualcomm = TafUeAt(
    com_port="9",
    serial_number="xxxxxxx",
    capabilities=["AT_UE"],
    ue_pc_address="10.44.234.238",
    ue_pc_login="plwrranpzk3",
    ue_pc_password="p_5PvX7#a3jz",
    data_transfer=[_data_transfer_iperf,  _data_transfer_ping, _data_transfer_ftp]
)

_sdx = TafUeAndroid(
    serial_number="RFCX115GNTW",
    ue_pc_address="10.44.234.238",
    capabilities=["REAL_UE"],
    network_mode_switch_method="ADB",
    path_to_network_mode_type="Mobile network/Preferred network type",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe"
)

_attenuator = TopYoung(
    ip_addr="10.44.234.9",
    port=3001,
    attenuation_port_numbers=range(1, 12),
    model="TAS12T12-51-90-1S-EJS",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_2xASIL_2xABIO_AVQC_AQQY_MED_EPC",
    core=_core,
    pdus=[_pdu_gnb],
    ues=[_sdx],
    attenuator=_attenuator,
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.44.234.29"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.44.145.13"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = 1

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "mediator", Mediator)
setattr(tl, "uepc_python_path", "C:/Users/plwrranpzk3/AppData/Local/Programs/Python/Python39/python.exe")
setattr(tl, "uepc_dmc_path", "C:/Users/plwrranpzk3/Desktop/Filtry/20220819_lightweight_ngn_SA_ETWS_QTRACES.dmc")

setattr(tl, "mrbts_id", "50013")
setattr(tl, "ute_control_pc_host", "10.44.145.11")
setattr(tl, "gnb_control_pc_host",  ["10.44.145.11"])
setattr(tl, "oam_airframe_mmt_host", "10.44.145.13")
setattr(tl, "oam_airframe_mmt_dct0", "1")
setattr(tl, "enb_control_pc_host", "10.44.145.11")
setattr(tl, "enb_control_pc_user", "labadmin")
setattr(tl, "enb_control_pc_password", "uteadmin")
setattr(tl, "enb_lcp_list",  [0])
setattr(tl, "enb_lsp_list",  [])
setattr(tl, "enb_fan_list",  [])
setattr(tl, "enb_lbr_list",  [])
setattr(tl, "enb_lni_list",  [])
setattr(tl, "enb_lps_list",  [0])
setattr(tl, "enb_type", "lrc")
setattr(tl, "gnb_pdu_ip",  ["10.45.177.8"])
setattr(tl, "gnb_pdu_outlet",  [5])
setattr(tl, "gnb_id_list",  [1])
setattr(tl, "gnb_card_slot",  [[1, 2, 3]])
setattr(tl, "gnb_fh_connect",  [[1]])
setattr(tl, "gnb_fh_bitrate",  [[25, 25, 25]])

setattr(tl, "af_type", "OE20")
setattr(tl, "af_bmc_ip", "10.44.235.220")
# setattr(tl, "af_bmc_bridge_ip", "10.44.234.29")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")
setattr(tl,
    "ne3s_alarm_white_list", ["61029", "7115", "7107", "7116", "61050", "7220", "7100"]
)

setattr(tl, "enable_af_ssh_reset_WA", "yes")

setattr(tl, "gnb_logic_group", [[1]])

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")

setattr(tl, "oam_airframe_mediator_host", "10.44.234.29")
setattr(tl, "oam_airframe_mediator_user", "toor4nsn")
setattr(tl, "oam_airframe_mediator_pwd", "oZPS0POrRieRtu")
setattr(tl, "oam_airframe_mediator_interface", "ens35f0")
setattr(tl, "oam_airframe_mediator_sudo_pwd", "uteadmin")

setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "ue_control_pc_user", "plwrranpzk3")
setattr(tl, "ue_control_pc_pwd", "p_5PvX7#a3jz")
setattr(tl, "windows_control_pc_user", "plwrranpzk3")
setattr(tl, "windows_control_pc_pwd", "p_5PvX7#a3jz")

setattr(tl, "oam_airframe_mmt_host_user", "labadmin")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")

setattr(tl, "oam_airframe_mediator_guest", "192.168.129.3")  # MEDIATOR guest OS
setattr(tl, "oam_airframe_mediator_guest_user", "toor4nsn")
setattr(tl, "oam_airframe_mediator_guest_pwd", "oZPS0POrRieRtu")

setattr(tl, "ue_pc_addr", "10.44.234.238")
setattr(tl, "ue_pc_username", "plwrranpzk3")
setattr(tl, "ue_pc_password", "p_5PvX7#a3jz")

setattr(tl, "oam_http_addr", "192.168.255.129")
setattr(tl, "oam_http_port", "443")
setattr(tl, "oam_http_username", "Nemuadmin")
setattr(tl, "oam_http_password", "nemuuser")
setattr(tl, "lmp_connection_username", "toor4nsn")
setattr(tl, "lmp_connection_pass", "oZPS0POrRieRtu")

setattr(tl, "appserver_addr", "10.42.61.61")
setattr(tl, "appserver_username", "syslab")
setattr(tl, "appserver_password", "system")
setattr(tl, "appserver_tput_addr", "10.42.197.171")
setattr(tl, "appserver_f1_addr", "10.42.61.61")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")