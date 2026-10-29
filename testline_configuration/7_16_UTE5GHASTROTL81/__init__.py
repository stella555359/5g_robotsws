__maintainer__ = "Filip Wlosik"
__team__ = "RRM team"
__email__ = "filip.wlosik@nokia.com"
__owner_email__ = "filip.wlosik@nokia.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
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
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import TopYoung

_pdu1 = Gude(addr="10.44.206.222", port_numbers=[3, 9, 12], model="EPC", version="8221-1")

_attenuator = TopYoung(
    ip_addr="10.42.75.84",
    port=3001,
    attenuation_port_numbers=range(1, 17),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.88.5/26",
        v6=None,
        vlan_id=707,
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
        v4="10.44.84.152/26",
        v6=None,
        vlan_id=707,
    ),
    x2u=NetworkAddress(
        v4="10.44.84.152/26",
        v6=None,
        vlan_id=707,
    ),
    s1u=NetworkAddress(
        v4="10.44.84.152/26",
        v6=None,
        vlan_id=707,
    ),
    xnc=NetworkAddress(
        v4="10.44.84.152/26",
        v6=None,
        vlan_id=707,
    ),
    xnu=NetworkAddress(
        v4="10.44.231.196/26",
        v6=None,
        vlan_id=707,
    ),
    ngc=NetworkAddress(
        v4="10.44.84.152/26",
        v6=None,
        vlan_id=707,
    ),
    ngu=NetworkAddress(
        v4="10.44.84.152/26",
        v6=None,
        vlan_id=707,
    ),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[9],
    ru_hw_group="",
    radio_type="AHLOB",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AHFII",
)

_bbmod = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIO", rus=[_ru1, _ru2]
)
_smod_gnb_1 = CommonUnit(
    hardware_type="ASIL",
    serial_number="L1223402811",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod],
    pdu_port=_pdu1.pdu_ports[3],
)

_airscale = Airscale([_smod_gnb_1])

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.211", username="wro5grrm", password="5gpass!1"
)


_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="iperf",
)


_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_proxy.yaml"
)

_du = DU(_airscale, rus=[_ru1, _ru2])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50924, global_bts_id=50924)

_core = RealCore5G(mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.19", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIL_ABIO_AHLOB",
    core=_core,
    attenuator=_attenuator,
    ues=[_ues],
    pdus=_pdu1
)

__all__ = ["tl"]
