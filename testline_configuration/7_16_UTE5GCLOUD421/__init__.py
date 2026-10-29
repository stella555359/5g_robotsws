__maintainer__ = "Rafal Sytyk"
__team__ = "I_5GSC_5G_PZ1_WRO_9"
__email__ = "I_5GSC_5G_PZ1_WRO_9@internal.nsn.com"
__owner_email__ = "rafal.sytyk@nokia.com"

import os
import yaml
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, PduPort, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.core import RealCore4G

from taf.config.testline.ue import Android

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.58", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_nokia_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yml"
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.78.15",
        v6="2a00:8a00:6000:607c::3f0f",
        vlan_id=860,
        routing_v4=RoutingInformation(gateway="10.44.78.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::3f01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.78.79",
        v6="2a00:8a00:6000:607c::400f",
        vlan_id=861,
        routing_v4=RoutingInformation(gateway="10.44.78.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4001/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.81.207",
        v6="2a00:8a00:6000:607c::410f",
        vlan_id=862,
        routing_v4=RoutingInformation(gateway="10.44.81.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4101/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.82.15",
        v6="2a00:8a00:6000:607c::420f",
        vlan_id=863,
        routing_v4=RoutingInformation(gateway="10.44.82.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4201/120"),
    ),
)

_pdu_gnb = Gude(addr="10.44.205.169", port_numbers=[1], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.171", port_numbers=[11], model="EPC", version="8221-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.205.171", port_numbers=[3], model="EPC", version="8221-1"
)
_pdu_gnb_ru3 = Gude(
    addr="10.44.205.171", port_numbers=[7], model="EPC", version="8221-1"
)
_pdu_gnb_ru4 = Gude(
    addr="10.44.205.171", port_numbers=[8], model="EPC", version="8221-1"
)
_pdu_fanbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gpsbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])

_pdus = [
    _pdu_gnb,
    _pdu_gnb_ru1,
    _pdu_gnb_ru2,
    _pdu_gnb_ru3,
    _pdu_gnb_ru4,
    _pdu_fanbreaker,
    _pdu_gpsbreaker,
]

_gnb_ru1 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[11],
    radio_type=RadioTypes.AZHL.value,
)

_gnb_ru2 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[3],
    radio_type=RadioTypes.AZHL.value,
)

_gnb_ru3 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.54", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[7],
    radio_type=RadioTypes.AZHL.value,
)

_gnb_ru4 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.55", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru4.pdu_ports[8],
    radio_type=RadioTypes.AZHL.value,
)


_abil1_gnb_1_master = CapacityUnit(
    hardware_type="ABIO",
    addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(hardware_type="ABIO",
                                  addr="192.168.253.21",
                                  rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4])

_abil1_gnb_1_loner = CapacityUnit(
    hardware_type="ABIO",
    addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50390, instance_id=50390
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.167", username="wro5goam", password="Uteadmin1@"
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.58", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_cbts.dus[0].airscale.common_units[0], interface_type="lmp")
    ],
)

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yml")
) as f:
    _nokia_ue = yaml.load(f, yaml.FullLoader)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABIO_4xAZHL"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_enb_1],
    ues=[_nokia_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
