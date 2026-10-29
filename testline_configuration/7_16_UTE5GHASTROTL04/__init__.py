__maintainer__ = "Tomasz Godlewski"
__team__ = "PZ2 WRO4"
__email__ = "tomasz.1.godlewski@nokia.com"
__owner_email__ = "tomasz.1.godlewski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, Gude, APC
from taf.config.testline.attenuator import TopYoung

_pdu1 = Gude(addr="10.44.206.147", port_numbers=[2, 11], model="EPC", version="8221-1")
_pdu2 = APC(addr="10.44.205.216", port_numbers=[4])
_pdu3 = ATEN(addr="10.42.61.136", port_numbers=[1])
_pdus = [_pdu1, _pdu2, _pdu3]


_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.36", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHFIB",
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.38", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[1],
    ru_hw_group="",
    radio_type="ARPA",
)

_abio = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    serial_number="L1222310032",
    rus=[_ru1, _ru2],
)
_abia = CapacityUnit(
    addr="192.168.253.37", hardware_type="ABIA", serial_number="K9173643962", rus=[_ru3]
)

_abil = CapacityUnit(
    addr="192.168.253.38", hardware_type="ABIL", serial_number="EA194457512", rus=[_ru3]
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu2.pdu_ports[4],
    hardware_type="ASIB",
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.65.72",
        v6=None,
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.44.65.65/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.65.132",
        v6=None,
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.65.196",
        v6=None,
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.66.4",
        v6=None,
        vlan_id=462,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    xnc=NetworkAddress(
        v4="10.44.65.132",
        v6=None,
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    xnu=NetworkAddress(
        v4="10.44.65.196",
        v6=None,
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    ngc=NetworkAddress(
        v4="10.44.47.7",
        v6=None,
        vlan_id=892,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    ngu=NetworkAddress(
        v4="10.44.47.8",
        v6=None,
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.224.179", username="wro5grrm", password="5gpass!1"
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="iperf",
)


_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_proxy_config.yaml"
)

_du = DU(_airscale, rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50896, global_bts_id=50896)
_core = RealCore5G(mcc=310, mnc=260)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.127", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_attenuator = TopYoung(
    ip_addr="10.42.221.121",
    port=3001,
    attenuation_port_numbers=range(1, 7),
    model="TAS_24T24_02G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL04_ASIB_ABIA_ABIL_ABIO_AHLOA_AHFIB_ARPA_MRAT",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    test_pcs=[_lmp_vm_gnb_1],
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]
