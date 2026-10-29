__maintainer__ = "Piotr Wejman"
__team__ = "DCM"
__email__ = "piotr.wejman@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails

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

_pdu_gnb = Gude(addr="10.44.200.69", port_numbers=[6], model="EPC", version="8220-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1210903509",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1210808188",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1210400962",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1240400199",
    pdu_port=_pdu_gnb.pdu_ports[6],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.84", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb],
)

_x2_vm_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.138", username="ute", password="uteUTE!"
    )
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_gnb_ru_1 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="HFR2333M252.51",
    pdu_port="1.1.1.1",
)

_gnb_ru_2 = RU(
    ru_hw_group="FRPE_V",
    radio_type="472822A.101",
    serial_number="HFR2333M252.52",
    pdu_port="1.1.1.1",
)

_gnb_ru_3 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="HFR2333M252.54",
    pdu_port="1.1.1.1",
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo"
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    server_close_delay=200,
    interval=1,
    version=2
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_android = TafUeAndroid(
    serial_number="565e4bc8",  # SDX55M
    ue_pc_address="10.42.22.242",
    capabilities=["REAL_UE"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.242", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    ue_pc_port="80",
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_attenuator = TopYoung(
    ip_addr="10.42.75.154",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _x2_vm_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASIL_3xABIO_FHGD_FHGD_FHGD_FRPE_MED_HDBDE_IUG_IPSEC",
    ues=[_android],
    pdus=[_pdu_gnb],
    attenuator=_attenuator,
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.221.137"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.221.142"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 1

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class HDBDE:
    class MMT:
        hostname = "10.42.75.57"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "1"

    class WTS:
        hostname = "10.42.221.138"
        username = "ute"
        password = "UTE.debian12"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"
    wts_vm = WTS
    mmt_vm = MMT


setattr(tl, "lkc_login", "michal.lys@nokia.com")
setattr(tl, "lkc_passwd", "DcmOam4$")
setattr(tl, "lkc_path", "/cygdrive/c/Users/plwrranpzk3/Desktop/QXDM/QPM_LK3.1.2/QPM_LK3.1.2")

setattr(tl, "mediator", Mediator)
setattr(tl, "hdbde", HDBDE)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.221.138")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "security_gateway_ip", "10.42.221.138")
setattr(tl, "hdbde_vm_ip_address", "10.42.221.138")

setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.42.210.122")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_20")

setattr(tl, 'ru_info', [{'id': 1, 'RMOD_R': 1, 'cell_id': [1], 'bbmod_port': 1, 'iug_port': 1,
                         'iug': 'yes', 'fhm': 'no', 'hdbde_cell': {'exist': 'no'}},
                        {'id': 2, 'RMOD_R': 2, 'cell_id': [2], 'bbmod_port': 9, 'iug_port': 2,
                         'iug': 'yes', 'fhm': 'no',
                         'hdbde_cell': {'exist': 'yes', 'Sector_Number': 2, 'Carrier_Number': 1, 'CPRI_Link_ID': 2}},
                        {'id': 3, 'RMOD_R': 3, 'cell_id': [3], 'bbmod_port': 18, 'iug_port': 4,
                         'iug': 'yes', 'fhm': 'no',
                         'hdbde_cell': {'exist': 'yes', 'Sector_Number': 1, 'Carrier_Number': 3, 'CPRI_Link_ID': 13}}])
setattr(tl, 'iug_ip_addr', '10.42.61.193')
setattr(tl, 'iug_connection_username', 'admin')
setattr(tl, 'iug_connection_pass', 'admin1234')
setattr(tl, "switch_ip_addr", "10.42.187.103")
setattr(tl, "switch_username", "u1472221")
setattr(tl, "switch_password", "C0Qrw9OFmIk6ImE")
setattr(tl, "switch_port", "10")
setattr(tl, "uepc_python_path", "c:/Users/plwrranpzk3/AppData/Local/Programs/Python/Python39/python.exe")
setattr(tl, "uepc_python_scripts_path", "c:/Users/plwrranpzk3/AppData/Local/Programs/Python/Python39/Scripts")
setattr(tl, "uepc_dmc_path", "c:/auto/20220819_lightweight_RRC_TPUT+MAC.dmc")
setattr(tl, "ue_chip_name", ["SDX55M", None])
