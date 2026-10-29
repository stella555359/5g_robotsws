__maintainer__ = "Tomasz Godlewski"
__team__ = "RRM1 team"
__email__ = "tomasz.1.godlewski@nokia.com"
__owner_email__ = "tomasz.1.godlewski@nokia.com"

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


_pdu1 = Gude(addr="10.44.206.187", port_numbers=[7], model="EPC", version="8221-1")
_pdu2 = ATEN(addr="10.44.205.203", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu3 = ATEN(addr="10.44.205.201", port_numbers=[6])
_pdu4 = Gude(addr="10.44.206.141", port_numbers=[4], model="EPC", version="8221-1")
_pdus = [_pdu1, _pdu2, _pdu3, _pdu4]

_attenuator = TopYoung(
    ip_addr="10.42.221.61",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.12",
        v6=None,
        vlan_id=820,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
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
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    xnc=NetworkAddress(
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    xnu=NetworkAddress(
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    ngc=NetworkAddress(
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
    ngu=NetworkAddress(
        v4="10.44.76.76",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.76.1/26"),
    ),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AHBCB",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.38", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[7],
    ru_hw_group="",
    radio_type="UHFA",
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.42", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu4.pdu_ports[4],
    ru_hw_group="",
    radio_type="UHIE",
)

_abil_master = CapacityUnit(
    addr="192.168.253.36", hardware_type="ABIL", serial_number="L1192614817", rus=[_ru1]
)
_abil_slave = CapacityUnit(
    addr="192.168.253.37", hardware_type="ABIL", serial_number="L1192614810", rus=[_ru2]
)

_abil_loner = CapacityUnit(
    addr="192.168.253.38", hardware_type="ABIN", serial_number="L1214511961", rus=[_ru3]
)

_smod_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu3.pdu_ports[6],
    hardware_type="ASIB",
)

_smod_1 = Airscale([_smod_gnb])

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.71", username="wro5grrm", password="5gpass!1"
)

_abia = CapacityUnit(addr="192.168.253.20", rus=[_ru2, _ru3], hardware_type="ABIA")

_smod_enb_1 = CommonUnit(
    hardware_type="ASIA",
    serial_number="L1172805754",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu3.pdu_ports[6],
)

_airscale_enb_1 = Airscale([_smod_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    global_bts_id=41151,
    instance_id=41151,
    x2_link_addr=NetworkAddress(
        v4="10.44.76.13/26",
        v6=None,
        vlan_id=821,
    ),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.205", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="iperf",
)


_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_du = DU(_smod_1, rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=51058, global_bts_id=51058)
_core = RealCore5G(mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.18", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL73_ASIB_ABIL_ABIN_AHBCB_UHFA_UHIE",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    attenuator=_attenuator,
    ues=[_ues],
    test_pcs=[_test_pc, _lmp_vm_enb_1],
)

__all__ = ["tl"]
