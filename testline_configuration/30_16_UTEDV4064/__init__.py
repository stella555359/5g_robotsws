__maintainer__ = "Maciej Cupial"
__team__ = "DCM"
__email__ = "maciej.cupial@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, Gude, EPC

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=286),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=286),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=286),
)

_pdu_gnb = Gude(addr="10.44.200.83", port_numbers=[2], model="EPC", version="8220-1")
_pdu_apo = Gude(addr="10.44.200.83", port_numbers=[1], model="EPC", version="8220-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204902712",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211506432",
)

_asil_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1213511605",
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_abio_gnb_4 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204101637",
)

_abio_gnb_6 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204104895",
)

_asil_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_4, _abio_gnb_6],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220843166",
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type='ASIL',
                capacity_units=[
                    CapacityUnit(addr='192.168.253.84', hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[1]
            )
        ]
    ),
)

_lmp_vm_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.224", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_primary, _ue],
)

_airscale_gnb_1 = Airscale([_asil_primary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=2, instance_id=2
)

_lmp_vm_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.224", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_secondary, _ue],
)

_airscale_gnb2 = Airscale([_asil_secondary])

_du_2 = DU(airscale=_airscale_gnb2, rus=[])

_cbts_2 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=2, instance_id=2
)

tl = TestLine(
    test_pc=_lmp_vm_1,
    test_pcs=[_lmp_vm_1, _lmp_vm_2],
    gnbs=[_cbts],
    pdus=[_pdu_gnb, _pdu_apo],
    ues=[_ue],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"       #Mediator VM IP M-Plane (BH_VLAN)
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.221.222"      #mediator HostOS Rdnet IP
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.221.231"       #MMT Rdnet IP + VLAN
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "mediator", Mediator)
