__maintainer__ = "Grzegorz Karnecki"
__team__ = "DCM"
__email__ = "grzegorz.karnecki@nokia.com"


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
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline import Airphone
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

_pdu_gnb = Gude(addr="10.44.200.116", port_numbers=[2], model="EPC", version="8220-1")

_abio_1_gnb_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH214242005",
)

_abio_2_gnb_1 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204304802",
)

_abio_3_gnb_1 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211511250",
)

_abio_1_gnb_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="DH225050236",
)

_abio_2_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="DH225050288",
)

_abio_3_gnb_2 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1213010358",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_1, _abio_2_gnb_1, _abio_3_gnb_1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220640271",
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_asil_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_2, _abio_2_gnb_2, _abio_3_gnb_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1204003914",
)

_airscale_gnb_1 = Airscale([_asil_gnb])
_airscale_gnb_2 = Airscale([_asil_secondary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])
_du_2_gnb_2 = DU(airscale=_airscale_gnb_2, rus=[])

_cbts_1 = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=77)
_cbts_2 = ClassicalBts(cu=_cu_gnb_1, dus=[_du_2_gnb_2])

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.75.53", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=3,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.75.221", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts_1, _cbts_2],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.237", username="ute", password="ute"
    ),
    connections=[_asil_gnb, _mediator],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_DCM_I_LOO_AP_LOO_MED",
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.221"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.53"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 3

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class KVM:
    hostname = "10.42.75.238"


setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
