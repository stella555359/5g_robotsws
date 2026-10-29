__maintainer__ = "Mateusz Kowalczyk"
__team__ = "DCM"
__email__ = "mateusz.kowalczyk@nokia.com"

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
from taf.config.testline.ue import TafUeAt, TafUeAndroid
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
            ru_hw_group, default_ssh_connection_details=default_ssh_connection_details, pdu_port=pdu_port,
            radio_type=radio_type, serial_number=serial_number, product_code=product_code
        )
        self.cells = cells

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

_pdu_gnb = Gude(addr="10.44.200.86", port_numbers=[1, 8, 11], model="EPC", version="8220-1")

_abio_1_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101214",
)
_abio_2_gnb_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="DH230251201",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_1, _abio_2_gnb_1],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224704434",
    pdu_port=_pdu_gnb.pdu_ports[11],
)

_pdu_ru_1 = Gude(addr="10.44.200.97", port_numbers=[6, 7, 10, 12], model="EPC", version="8220-1")
_pdu_ru_2 = Gude(addr="10.44.200.221", port_numbers=[9], model="EPC", version="8041-1")
_pdu_ru_3 = Gude(addr="10.44.200.131", port_numbers=[5], model="EPC", version="8041-1")


_FRPE_1_gnb_1 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FRPE_V",
    serial_number="HFR2309M123.53",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_ru_1.pdu_ports[12],
    cells={
        64: {"sector": None, "carrier": None},
    }
)

_FRGH_1_gnb_1 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FHGD_V",
    serial_number="HFR2309M123.51",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_ru_2.pdu_ports[9],
    cells={
        176: {"sector": None, "carrier": None},
    }
)

_FRGH_2_gnb_1 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FHGD_V",
    serial_number="HFR2309M123.52",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_ru_1.pdu_ports[10],
    cells={
        96: {"sector": None, "carrier": None},
    }
)

_AVQC_gnb_1 = RU(
    ru_hw_group="",
    radio_type="AVQC",
    serial_number="1M242710758",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_ru_3.pdu_ports[5]
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.189", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb_1],
)

_airscale_gnb_1 = Airscale([_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_FRPE_1_gnb_1, _FRGH_1_gnb_1, _FRGH_2_gnb_1, _AVQC_gnb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50019, instance_id=1
)

_core = RealCore5G()

# --------------------------- gNB 2 ---------------------------

_cu_gnb_2 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.45.28", username="Nemuadmin", password="nemuuser", port=443
    )
)

_abio_1_gnb_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204104743",
)

_abio_2_gnb_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1210904908",
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1213806903",
    pdu_port=_pdu_gnb.pdu_ports[8],
)

_FRPE_1_gnb_2 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FRPE_V",
    serial_number="HFR2309M123.56",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_ru_1.pdu_ports[6],
    cells={
        160: {"sector": None, "carrier": None},
    }
)

_FRGH_1_gnb_2 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FHGD_V",
    serial_number="HFR2309M123.55",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_ru_1.pdu_ports[7],
    cells={
        128: {"sector": None, "carrier": None},
    }
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.190", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb_2],
)

_airscale_gnb_2 = Airscale([_asil_gnb_2])

_du_1_gnb_2 = DU(airscale=_airscale_gnb_2, rus=[_FRPE_1_gnb_2, _FRGH_1_gnb_2])

_cbts_2 = ClassicalBts(
    cu=_cu_gnb_2, dus=[_du_1_gnb_2], global_bts_id=50018, instance_id=1
)

# --------------------------- UEs ---------------------------

_ue_ctrl_pc_ssh_details = SshServiceDetails(addr="10.42.224.227", username="plwrranpzk3", password="p_5PvX7#a3jz")

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="syslab",
    password="system",
    bind_interface_ip="10.45.168.53",
    expected_prompt="syslab@wl-srn-server-1-idf3_4"
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf", app_server=_app_server_1, version=2)
_data_transfer_ping = TafUeDataTransferProtocol(protocol_name="ping", app_server=_app_server_1, interval=1)
_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name="ftp", app_server=_app_server_1, interval=1)

_sdx = TafUeAndroid(
    serial_number="b26e732c",
    capabilities=["REAL_UE"],
    ue_pc_address="10.42.224.227",
    network_mode_switch_method="ADB",
    path_to_network_mode_type="SIMs/DOCOMO MVNO/Preferred network type",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe"
)

_attenuator = TopYoung(
    ip_addr="10.42.75.207",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts, _cbts_2],
    tl_cloud_topology="CLOUD_DCM_ASIL_2xABIO_2xORUSIM_MED_EPC",
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
        hostname = "10.42.54.199"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.54.198"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 1

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class IUG:
    """
    Class for IUG model representation
    """
    def __init__(self, config, hostname, pdu_port=None, username="admin", password="admin1234"):
        """
        :param config: dict containing mapped IUG port ids with its matching RMOD and information about FHM
                      e.g. 1: {"rmod": _ru1, "fhm": False}
        :type config: dict[int, dict[str, LteRU or bool]]
        :param pdu_port: PDU port number
        :type pdu_port: PduPort
        :param hostname: IUG ip address
        :type hostname: str
        :param username: IUG ssh username
        :type username: str
        :param password: IUG ssh password
        :type password: str
        """
        self.config = config
        self.hostname = hostname
        self.pdu_port = pdu_port
        self.username = username
        self.password = password


_iug = IUG(config={
        1: {"shelf_id": 2, "rmod": 1, "iug_port_group": 0},
        2: {"shelf_id": 2, "rmod": 2, "iug_port_group": 0},
        3: {"shelf_id": 2, "rmod": 3, "iug_port_group": 0},
        5: {"shelf_id": 3, "rmod": 1, "iug_port_group": 0},
        6: {"shelf_id": 3, "rmod": 2, "iug_port_group": 0}},
    hostname="10.42.75.214",
    username="admin",
    password="admin1234"
)

setattr(tl, "mediator", Mediator)
setattr(tl, "iug", _iug)
setattr(tl, "uepc_python_path", "'C:/Program Files/Python38/python.exe'")
setattr(tl, "uepc_dmc_path", "C:/Users/plwrranpzk3/Desktop/Filtry/sa_NSA.dmc")

setattr(tl, "mrbts_id", "50019")
setattr(tl, "ute_control_pc_host", "10.42.54.189")
setattr(tl, "gnb_control_pc_host", ["10.42.54.189"])
setattr(tl, "oam_airframe_mmt_host", "10.42.54.198")
setattr(tl, "oam_airframe_mmt_dct0", "2")
setattr(tl, "enb_control_pc_user", "plwrranpzk3")
setattr(tl, "enb_control_pc_password", "p_5PvX7#a3jz")
setattr(tl, "enb_lcp_list", [0])
setattr(tl, "enb_lsp_list", [])
setattr(tl, "enb_fan_list", [])
setattr(tl, "enb_lbr_list", [])
setattr(tl, "enb_lni_list", [])
setattr(tl, "enb_lps_list", [0])
setattr(tl, "enb_type", "lrc")
setattr(tl, "gnb_pdu_ip", ["10.44.205.218"])
setattr(tl, "gnb_pdu_outlet", [2])
setattr(tl, "gnb_id_list", [1])
setattr(tl, "gnb_card_slot", [[1, 2]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25, 25]])

setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.42.54.53")
setattr(tl, "af_bmc_bridge_ip", "10.42.54.189")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")
setattr(tl,
        "ne3s_alarm_white_list", ["61029", "7115", "7107", "7116", "61050", "7220", "7100"]
        )

setattr(tl, "enable_af_ssh_reset_WA", "yes")

setattr(tl, "gnb_logic_group", [[1]])

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")

setattr(tl, "oam_airframe_mediator_host", "10.42.54.199")
setattr(tl, "oam_airframe_mediator_user", "ute")
setattr(tl, "oam_airframe_mediator_pwd", "Ut3pa5s#1be1")
setattr(tl, "oam_airframe_mediator_interface", "ens4f0")
setattr(tl, "oam_airframe_mediator_sudo_pwd", "Ut3pa5s#1be1")

setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "UTE.debian12")
setattr(tl, "ue_control_pc_user", "plwrranpzk3")
setattr(tl, "ue_control_pc_pwd", "p_5PvX7#a3jz")
setattr(tl, "windows_control_pc_user", "plwrranpzk3")
setattr(tl, "windows_control_pc_pwd", "p_5PvX7#a3jz")

setattr(tl, "oam_airframe_mmt_host_user", "plwrranpzk3 ")
setattr(tl, "oam_airframe_mmt_host_password", "p_5PvX7#a3jz")

setattr(tl, "oam_airframe_mediator_guest", "192.168.129.3")  # MEDIATOR guest OS
setattr(tl, "oam_airframe_mediator_guest_user", "toor4nsn")
setattr(tl, "oam_airframe_mediator_guest_pwd", "oZPS0POrRieRtu")

setattr(tl, "iug_ip_addr", "10.42.75.214")
setattr(tl, "iug_connection_username", "admin")
setattr(tl, "iug_connection_pass", "admin1234")

setattr(tl, "pdu_iug_ip_addr", "10.44.200.86")
setattr(tl, "pdu_iug_model", "GUDE")
setattr(tl, "pdu_iug_port", "1")

setattr(tl, "ue_pc_addr", "10.42.224.227")
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

setattr(tl, "gnb_2_mplane", "10.42.45.28")
setattr(tl, "gnb_pdu_type", "GUDE")
setattr(tl, "gnb_pdu_version", "8220-1")
setattr(tl, "ltesim_pc_host", "10.42.75.180")
setattr(tl, "wtssim_vm_ip", "10.42.54.189")
setattr(tl, "wtssim_vm_user", "ute")
setattr(tl, "wtssim_vm_pass", "ute")
setattr(tl, "x2_vm_ip", "10.42.75.180")
