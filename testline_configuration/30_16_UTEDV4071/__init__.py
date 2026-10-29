__maintainer__ = "Sebastian Kupisiewicz"
__team__ = "DCM"
__email__ = "sebastian.kupisiewicz@nokia.com"

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
from taf.config.testline.pdu import Gude

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.2"),
    x2u=NetworkAddress(v4="10.0.1.2"),
    s1u=NetworkAddress(v4="10.0.1.2"),
    xnc=NetworkAddress(v4="10.0.1.2"),
    xnu=NetworkAddress(v4="10.0.1.2"),
    ngc=NetworkAddress(v4="10.0.1.2"),
    ngu=NetworkAddress(v4="10.0.1.2"),
)

_pdu_gnb = Gude(addr="10.44.200.102", port_numbers=[2, 3], model="EPC", version="8221-1")
_pdu_apo = Gude(addr="10.44.200.102", port_numbers=[1], model="EPC", version="8221-1")

ru1 = RU(
    radio_type="TA24395-B20X",
    ru_hw_group="Simulated_RU",
    serial_number="00002472",
)

_abio_gnb_primary_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204104697",
)

_abio_gnb_primary_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1210302282",
)

_abio_gnb_primary_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204505514",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_primary_1, _abio_gnb_primary_2, _abio_gnb_primary_3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1214010360",
    pdu_port=_pdu_gnb.pdu_ports[2]
)

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.129", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[1],
            )
        ]
    ),
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.211", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_airscale_gnb_1 = Airscale([_asil_gnb_primary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[ru1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary],
    gnbs=[_cbts],
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.61.27"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.61.29"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class WTS:
    hostname = "10.42.221.211"
    username = "ute"
    password = "ute"


class KVM:
    hostname = "10.42.221.229"


setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "mrbts_id", "1")
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.221.211")
setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.128")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")
setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")
setattr(tl, "enable_af_ssh_reset_WA", "no")
setattr(tl, "enb_type", "lrc")
setattr(tl, 'gnb_id_list', [1])
setattr(tl, "windows_control_pc_user", "ute")
setattr(tl, "windows_control_pc_pwd", "ute")
setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')
setattr(tl, "ute_control_pc_host", "10.42.221.211")
setattr(tl, "gnb_control_pc_host", ["10.42.221.211"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.42.221.211")
setattr(tl, "l3sim_host", "10.42.221.211")
