__maintainer__ = "george.medesan@nokia.com"
__owner__ = "george.medesan@nokia.com"
__email__ = "george.medesan@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.enb import RealEnb
from taf.config.testline.core import RealCore
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.sync_input import SyncHub


####################################################
# UTE Timisoara 5G Classical BTS SA Configuration #
####################################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))

# LMP virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.25.167", username="ute", password="ute"
    )
)

# Power breakers
_pdu_du = Gude(addr="10.255.3.22", port_numbers=[2], model="EPC", version="8220-1")

_pdu_du.pdu_ports[2].contactor = "NORMALLY_OPEN"

# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AZQI",
)
_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AZQI",
)

_radio_units_gnb = [_ru_1, _ru_2]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.5.34.92",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.5.34.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.5.34.92",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.5.34.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.5.34.92",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.5.34.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.5.34.92",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.5.34.1", ip_prefix_length=24),
    ),
)

# 5G Distributed Unit
_abio_4a = CapacityUnit(addr="fsp-4a")
_capacity_units_gnb = [_abio_4a]
_common_unit_gnb = CommonUnit(
    hardware_type="ASIL",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_gnb,
    pdu_port=_pdu_du.pdu_ports[2],
    sync_input=SyncHub(total_delay_from_shm=10),
)
_airscale_gnb = Airscale(common_units=[_common_unit_gnb])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abio_4a, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abio_4a, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=1),
    ),
]
_distributed_unit_gnb = DU(
    airscale=_airscale_gnb, rus=_radio_units_gnb, cablinks=_ru_cablinks
)
# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=10616,
    global_bts_id=10616,
)

# Core network
_core = RealCore()

# Testline
tl = TestLine(
    test_pc=_lmp_vm,
    gnbs=[_classical_bts_gnb],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_2xO-RU",
)
__all__ = ["tl"]
