__maintainer__ = "Michal Dyrda"
__team__ = "DCM"
__email__ = "michal.dyrda@nokia.com"


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
from taf.config.testline.ue import TafUeAndroid


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

_pdu_gnb = Gude(addr="10.44.177.183", port_numbers=[8, 11], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
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
    pdu_port=_pdu_gnb.pdu_ports[11],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.192", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_x2_vm_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.194", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

azqi = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQI",
    serial_number="1M223205338",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb.pdu_ports[8]
)

ru1 = RU(
    radio_type="FHGD_V",
    ru_hw_group="5Ggen3_HighF_2T2R",
    serial_number="HFR2221M020.52",
)

ru2 = RU(
    radio_type="FHGD_V",
    ru_hw_group="5Ggen3_HighF_2T2R",
    serial_number="HFR2221M020.53",
)

ru3 = RU(
    radio_type="FRPE_V",
    ru_hw_group="5Ggen3_HighF_2T2R",
    serial_number="HFR2221M020.54",
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[azqi, ru1, ru2, ru3])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_core = RealCore5G()

_android = TafUeAndroid(
    ue_pc_address='10.42.224.97',
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.97", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    serial_number="f1d4dced",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    network_mode_switch_method='adb',
    capabilities=['REAL_UE']
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _x2_vm_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASIL_3xABIO_2xORUSIM_MED_EPC",
    core=_core,
    ues=[_android],
    pdus=[_pdu_gnb],
)

class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.221.191"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.196"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "amf_vm_host", "10.42.75.194")

setattr(tl, "hdbde_vm_ip_address", "10.42.75.194")

setattr(tl, "oran_sim_pc_port", ["eth3", "eth4"])

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.75.85")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
