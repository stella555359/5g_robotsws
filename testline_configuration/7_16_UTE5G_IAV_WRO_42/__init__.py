__maintainer__ = "Michal Pogodzinski"
__team__ = "I_EXT_5G_SISO7"
__email__ = "I_EXT_5G_SISO7@internal.nsn.com"
__owner_email__ = "michal.pogodzinski@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN


__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.156.24", username="ute", password="ute"
    )
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.194.38", username="ute", password="ute"
    )
)


_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:a232", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a232", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a232", vlan_id=370),
)

_pdu_gnb = ATEN(addr="10.44.206.189", port_numbers=[7])

_pdu_enb = ATEN(addr="10.44.206.188", port_numbers=[3])

_pdu_gnb_ru = ATEN(addr="10.44.206.188", port_numbers=[8])


_ru_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZTA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.49", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_abio_loki = CapacityUnit(addr="192.168.253.22")

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_loki],
    test_pc=_lmp_vm_gnb_1,
    pdu_port=_pdu_gnb.pdu_ports[7],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_ru_1],
)

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    test_pc=_lmp_vm_enb_1,
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[3],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50121, instance_id=1
)

_core = RealCore5G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:a233", vlan_id=370),
    global_bts_id=40121,
    instance_id=40121,
    oam_ip=NetworkAddress(v4="10.42.181.175"),
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_1xAZTA",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
)
