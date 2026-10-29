__maintainer__ = "Lukasz Gajewski"
__team__ = "DCM"
__email__ = "lukasz.gajewski@nokia.com"


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
from taf.config.testline.pdu import Gude


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

_pdu_gnb = Gude(addr="10.44.200.100", port_numbers=[12], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1214403571",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1231900217",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244838",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.2", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASILL_2xABIOB1B2_2xORUSIM_MED_EPC_IPSEC",
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.4"
        username = "root"
        password = "uteadmin"
        dcmnet_interface = "ens11f0"

    class MMT:
        hostname = "10.42.75.3"
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
setattr(tl, "ltesim_pc_host", "10.42.75.2")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "security_gateway_ip", "10.42.75.136")

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.86")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_20")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
