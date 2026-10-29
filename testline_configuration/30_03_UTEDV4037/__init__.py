__maintainer__ = "Lv Bin"
__team__ = "DCM"
__email__ = "bin.2.lv@nokia-sbell.com"


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
from taf.config.testline.core import RealCore5G
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, Gude, EPC, APC


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=291),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=291),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=291),
)

_pdu_gnb = APC(addr="10.71.23.2", port_numbers=[7])
_pdu_apo = APC(addr="10.68.251.58", port_numbers=[3])

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1210904953",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214608124",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1210903912",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1214704660",
    pdu_port=_pdu_gnb.pdu_ports[7],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1
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
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[3],
            )
        ]
    ),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.251.17", username="ute", password="Nemuuser#365"
    ),
    connections=[_asil_gnb, _ue],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_I_[LOOO]_AP_[LOOO]_MED",
    ues=[_ue],
    pdus=[_pdu_gnb, _pdu_apo],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.71.21.169"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.68.251.18"
        username = "ute"
        password = "ute"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class RUSim1:
    serial_number = "S0123456"
    interface = "eth3"
    configuration_id = "1"


class KVM:
    hostname = "10.42.221.151"
    username = "ute"
    password = "3016K3admin#"


setattr(tl, "kvm", KVM)
setattr(tl, "oru_kvms", [KVM])
setattr(tl, "simulated_rmods", [RUSim1])
setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.68.251.17")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")


setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.71.21.24")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Nemuadmin365")
setattr(tl, "af_bmc_interface", "redfish_oe_19")
setattr(tl, "ntp_server_ip_address", "10.171.8.4")
