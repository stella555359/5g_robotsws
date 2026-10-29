__maintainer__ = "alin.necula@nokia.com"
__owner__ = "alin.necula@nokia.com"
__email__ = "alin.necula@nokia.com"

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
# UTE Timisoara 5G Classical BTS NSA Configuration #
####################################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))

# LMP virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.25.131", username="ute", password="ute"
    )
)

# Power breakers
_pdu_du = Gude(addr="10.255.3.26", port_numbers=[9], model="EPC", version="8221-1")
_pdu_du_ru = Gude(addr="10.255.3.24", port_numbers=[8], model="EPC", version="8221-1")

_pdu_du.pdu_ports[9].contactor = "NORMALLY_OPEN"
_pdu_du_ru.pdu_ports[8].contactor = "NORMALLY_OPEN"

# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AZQG",
    pdu_port=_pdu_du_ru.pdu_ports[8],
)
_radio_units_gnb = [_ru_1]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.232.58",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.58",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.58",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.58",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
)

# 5G Distributed Unit
"""
192.168.253.20 fsp-1-1a  fsp1_a
192.168.253.21 fsp-1-1b  fsp1_b
192.168.253.22 fsp-1-1c  fsp1_c
"""
_abil_master = CapacityUnit(addr="fsp-1a")
_abil_slave = CapacityUnit(addr="fsp-1b")
_abil_loner = CapacityUnit(addr="fsp-1c")
_capacity_units_gnb = [_abil_master, _abil_slave, _abil_loner]
_common_unit_gnb = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_gnb,
    pdu_port=_pdu_du.pdu_ports[9],
    sync_input=SyncHub(total_delay_from_shm=10),
)
_airscale_gnb = Airscale(common_units=[_common_unit_gnb])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil_master, label="QSFP", port_id=2),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    )
]
_distributed_unit_gnb = DU(
    airscale=_airscale_gnb, rus=_radio_units_gnb, cablinks=_ru_cablinks
)
# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=10658,
    global_bts_id=10658,
)

# 4G radio units
_radio_units_enb = [RU(ru_hw_group="LTE_RADIO", radio_type="FXEB")]

# 4G anchor BTS
_capacity_units_enb = [CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")]
_common_unit_enb = CommonUnit(
    hardware_type="ASIA",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_enb,
)

_airscale_enb = Airscale(common_units=[_common_unit_enb])
_lte_enb = RealEnb(
    airscale=_airscale_enb,
    rms=_radio_units_enb,
    instance_id=10800,
    global_bts_id=10800,
    oam_ip=NetworkAddress(
        v4="10.15.236.199",
        routing_v4=RoutingInformation(gateway="10.15.236.1", ip_prefix_length=26),
    ),
    x2_link_addr=NetworkAddress(
        v4="10.5.23.204",
        routing_v4=RoutingInformation(gateway="10.5.23.1", ip_prefix_length=26),
    ),
)

# enb test VM
_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.25.150", username="ute", password="ute"
    ),
    connections=[_lte_enb],
)

# Core network
_core = RealCore()

# Testline
tl = TestLine(
    test_pc=_lmp_vm,
    test_pcs=[_lmp_vm, _test_pc_enb],
    gnbs=[_classical_bts_gnb],
    enbs=[_lte_enb],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABILB1_AZQG_ECPRI_ENB",
)
__all__ = ["tl"]
