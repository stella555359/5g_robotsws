__maintainer__ = "Krzysztof Kulibab"
__team__ = "MN RAN K3"
__email__ = "krzysztof.kulibab@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.pdn import PDNTafUeAndroidDetails

__all__ = ["tl"]

_tl0_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_tl0_pdu_1 = Gude(addr="10.45.177.51", port_numbers=[4], model="EPC", version="8221-1")
_tl0_pdu_2 = Gude(addr="10.45.177.50", port_numbers=[4], model="EPC", version="8221-1")
_tl0_pdu_3 = Gude(addr="10.45.172.155", port_numbers=[4], model="EPC", version="8221-1")

_tl3_pdu_1 = Gude(addr="10.45.177.38", port_numbers=[12], model="EPC", version="8221-1")  #TODO do sprawdzenia

_tl0_abio_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1231900191",
)

_tl0_abio_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1222501218",
)

_tl0_abio_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1222501232",
)

_tl0_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_tl0_abio_1, _tl0_abio_2, _tl0_abio_3],
    hardware_type="ASIM",
    hardware_version="A103",
    serial_number="L1242005909",
    pdu_port=_tl0_pdu_1.pdu_ports[4],
)
#RMOD-1
_tl0_ru_fujitsu_45_1 = RU(
    serial_number="00003098",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    )
)
#RMOD-2
_tl0_ru_fujitsu_37_1 = RU(
    serial_number="00000899",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    )
)
#RMOD-3
_tl0_ru_fujitsu_45_2 = RU(
    serial_number="00010902",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    )
)
#RMOD-4
_tl0_ru_fujitsu_37_2 = RU(
    serial_number="00000897",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    )
)
#RMOD-5
_tl0_ru_nec = RU(
    serial_number="Na2166008294",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    )
)

_tl0_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.68", username="ute", password="ute"
    ),
    connections=[_tl0_asil],
)

_tl0_airscale = Airscale([_tl0_asil])
# _tl0_ru_fujitsu_45_1
_tl0_du = DU(airscale=_tl0_airscale, rus=[_tl0_ru_fujitsu_45_1, _tl0_ru_fujitsu_37_1, _tl0_ru_fujitsu_45_2, _tl0_ru_fujitsu_37_2, _tl0_ru_nec])

_tl0_cbts = ClassicalBts(
    cu=_tl0_cu, dus=[_tl0_du], global_bts_id=50015, instance_id=55
)

_tl3_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.45.173.12", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_tl3_abio_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101298",
)

_tl3_ru_nec_37 = RU(
    serial_number="Na23660014536",
    ru_hw_group=""
)

_tl3_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_tl3_abio_1],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="DH220840058",
    pdu_port=_tl3_pdu_1.pdu_ports[12],
)

_tl3_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.13", username="ute", password="ute"
    ),
    connections=[_tl3_asil],
)

_tl3_airscale = Airscale([_tl3_asil])

_tl3_du = DU(airscale=_tl3_airscale, rus=[_tl3_ru_nec_37])

_tl3_cbts = ClassicalBts(
    cu=_tl3_cu, dus=[_tl3_du], global_bts_id=50020, instance_id=58
)

_tl0_attenuator = TopYoung(
    ip_addr="10.44.234.76",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS_24T24_04G6_90_1S_EJS",
)

_tl3_attenuator = TopYoung(
    ip_addr="10.44.234.74",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS_24T24_04G6_90_1S_EJS",
)

_tl0_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.44.234.179",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)
_tl0_fr2_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.44.234.215",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)

_tl3_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.44.234.194",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.56.70",
    user="vrfwro1",
    password="VrfWroP@ss1!",
    bind_interface_ip="10.42.56.70",  #WPT
)
_app_server_2 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.52",
    user="syslab",
    password="system",
    # user="qt5g",
    # password="5Gqtmoth!",
    bind_interface_ip="10.45.168.52",  #WL
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_2,
    server_close_delay=200,
    interval=1,
    version=2
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_ASUS = TafUeAndroid(
    serial_number="M9AIKN01N614YKG",
    ue_pc_address="10.44.234.179",
    capabilities=["REAL_UE"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_tl0_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_QC_tl0_fr1 = TafUeAndroid(
    # serial_number="b895331b", #SDX75
    serial_number="c190bc78",  # SDX55
    ue_pc_address="10.44.234.179",
    capabilities=["REAL_UE", "QUALCOMM" "TL0"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_tl0_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_QC_tl0_fr2 = TafUeAndroid(
    # serial_number="b895331b", #SDX75
    serial_number="c190bc78",  # SDX55
    ue_pc_address="10.44.234.215",
    capabilities=["REAL_UE", "QUALCOMM" "TL0"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_tl0_fr2_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_QC_tl3 = TafUeAndroid(
    serial_number="b00baddd",
    ue_pc_address="10.44.234.194",
    capabilities=["REAL_UE", "QUALCOMM", "TL3"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_tl3_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_samsung_tl0 = TafUeAndroid(
    serial_number="R5CTC0S5JSZ",
    ue_pc_address="10.44.234.179",
    capabilities=["REAL_UE", "SAMSUNG", "TL0"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_tl0_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=False,
    airplane_mode_switcher_text="Off|On",
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_samsung_tl3 = TafUeAndroid(
    serial_number="R5CTC060ZDL",
    ue_pc_address="10.44.234.194",
    capabilities=["REAL_UE", "SAMSUNG", "TL3"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_tl3_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=False,
    airplane_mode_switcher_text="Off|On",
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

tl = TestLine(
    test_pc=_tl0_lmp_vm,
    test_pcs=[_tl0_lmp_vm, _tl3_lmp_vm],
    gnbs=[_tl0_cbts, _tl3_cbts],
    pdus=[_tl0_pdu_1, _tl0_pdu_2, _tl0_pdu_3, _tl3_pdu_1],
    attenuator=_tl0_attenuator,
    attenuators=[_tl0_attenuator, _tl3_attenuator],
    # ues=[_QC_tl0_fr1, _QC_tl3],
    ues=[_QC_tl0_fr1, _QC_tl0_fr2, _QC_tl3],
)
setattr(tl, "ue_chip_name", ["SDX55M", None])
setattr(tl, "ue_nvitems", [{74213: '0,28672,0,0,1,0,0,0', 74087: '0,0,0,0,0,0,0,0', 65633: '1'},
                           None])


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.44.234.109"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.44.234.73"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "1"

    class WTS:
        hostname = "127.0.0.1"
        username = "ute"
        password = "ute"
        alias = "l3_sim"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT
    wts_vm = WTS

    gnbs = [_tl0_cbts]


class Mediator2:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.44.234.109"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.44.234.16"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "1"

    class WTS:
        hostname = "10.44.234.13"
        username = "ute"
        password = "ute"
        alias = "mediator_2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT
    wts_vm = WTS

    gnbs = [_tl3_cbts]


class HDBDE:
    class MMT:
        hostname = "10.44.234.72"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


class HDBDE2:
    class MMT:
        hostname = "10.44.234.15"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


class Positioner:
    hostname = "10.44.234.246"
    username = "user-lab0"
    password = "NokiaBts2003"
    positioner_type = "krk"


setattr(tl, "lkc_login", "michal.lys@nokia.com")
setattr(tl, "lkc_passwd", "DcmOam4$")
setattr(tl, "lkc_path", "/cygdrive/c/Users/plwrranpzk3/Desktop/QPM_LK3.1.2/QPM_LK3.1.2")
setattr(tl, "mediator", Mediator)
setattr(tl, "mediator_2", Mediator2)
setattr(tl, "mediators", [Mediator, Mediator2])
setattr(tl, "hdbde", HDBDE)
setattr(tl, "hdbde_2", HDBDE2)
setattr(tl, "hdbdes", [HDBDE, HDBDE2])
setattr(tl, "uepc_python_path", "c:/Users/plwrranpzk3/AppData/Local/Programs/Python/Python310/python.exe")
setattr(tl, "uepc_dmc_path", "c:/auto/20220819_lightweight_ngn_SA_ETWS.dmc")
setattr(tl, "uepc_python_scripts_path", "c:/Users/plwrranpzk3/AppData/Local/Programs/Python/Python310/Scripts")
setattr(tl, "positioner", Positioner)
