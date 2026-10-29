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

_pdu_gnb = Gude(addr="10.44.200.116", port_numbers=[11], model="EPC", version="8220-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508098",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1222607833",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244833",
    pdu_port=_pdu_gnb.pdu_ports[11],
)

_x2_vm_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.125", username="ute", password="ute"
    ),
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_gnb_ru_1 = RU(
    ru_hw_group="FRPE_V",
    radio_type="472822A.101",
    serial_number="HFR2313M098.51",
    attenuation_ports=[],
    pdu_port="1.1.1.1",
)

_gnb_ru_2 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="HFR2313M098.53",
    attenuation_ports=[],
    pdu_port="1.1.1.1",
)

_gnb_ru_3 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="HFR2313M098.54",
    attenuation_ports=[],
    pdu_port="1.1.1.1",
)

_gnb_ru_4 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="HFR2313M098.55",
    attenuation_ports=[],
    pdu_port="1.1.1.1",
)


_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_android = TafUeAndroid(
    ue_pc_address='10.42.224.233',
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.233", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    serial_number="e63ed86",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    network_mode_switch_method='adb',
    capabilities=['REAL_UE']
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.75.127", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=1,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.75.129", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.123", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb, _mediator],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _x2_vm_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASIL_2xABIO_FHGD_FHGD_FHGD_FRPE_MED_HDBDE_IUG_IPSEC",
    ues=[_android],
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.129"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.127"
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
        hostname = "10.42.75.217"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "3"

    class WTS:
        hostname = "10.42.75.125"
        username = "ute"
        password = "ute"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"
    wts_vm = WTS
    mmt_vm = MMT



setattr(tl, "mediator", Mediator)
setattr(tl, "hdbde", HDBDE)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.75.125")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "security_gateway_ip", "10.42.75.125")
setattr(tl, "hdbde_vm_ip_address", "10.42.75.125")

setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.42.210.169")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_20")

setattr(tl, 'ru_info', [{'id': 1, 'RMOD_R': 1, 'cell_id': [1], 'bbmod_port': 1, 'iug_port': 1,
                         'iug': 'yes', 'fhm': 'no', 'hdbde_cell': {'exist': 'no'}},
                        {'id': 2, 'RMOD_R': 2, 'cell_id': [2], 'bbmod_port': 10, 'iug_port': 3,
                         'iug': 'yes', 'fhm': 'no',
                         'hdbde_cell': {'exist': 'yes', 'Sector_Number': 2, 'Carrier_Number': 1, 'CPRI_Link_ID': 2}},
                        {'id': 3, 'RMOD_R': 3, 'cell_id': [3], 'bbmod_port': 9, 'iug_port': 4,
                         'iug': 'yes', 'fhm': 'no',
                         'hdbde_cell': {'exist': 'yes', 'Sector_Number': 3, 'Carrier_Number': 1, 'CPRI_Link_ID': 3}},
                        {'id': 4, 'RMOD_R': 4, 'cell_id': [4], 'bbmod_port': 18, 'iug_port': 5,
                         'iug': 'yes', 'fhm': 'no',
                         'hdbde_cell': {'exist': 'yes', 'Sector_Number': 1, 'Carrier_Number': 3, 'CPRI_Link_ID': 13}}])

setattr(tl, 'iug_ip_addr', '10.42.75.6')
setattr(tl, 'iug_connection_username', 'admin')
setattr(tl, 'iug_connection_pass', 'admin1234')
setattr(tl, "switch_ip_addr", "10.42.137.37")
setattr(tl, "switch_username", "u1472221")
setattr(tl, "switch_password", "C0Qrw9OFmIk6ImE")
setattr(tl, "switch_port", "16")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")

setattr(tl,'pdu_iug_ip_addr', '10.44.200.116')
setattr(tl,'pdu_iug_model', 'EPC')
setattr(tl,'pdu_iug_port', '12')
