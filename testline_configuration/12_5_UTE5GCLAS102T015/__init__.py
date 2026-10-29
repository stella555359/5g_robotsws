__maintainer__ = "Yang Wei"  # TL owner name
__team__ = "I_NSB_MN_BOAM_RD_OM_FRSMZ_EITPIT_GMS_GMS <I_NSB_MN_BOAM_RD_OM_FRSMZ_EITPIT_GMS@internal.nsn.com>"  # TL owner's team
__email__ = "wei.2.yang@nokia-sbell.com"  # TL owner's email

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import RealCore
from taf.config.testline import RU, DU
from taf.config.testline.pdu import FACOM
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline import NetworkAddress, RoutingInformation

# common
__all__ = ["tl"]
_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# 5GRU for classicalBTS
_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="0.0.0.0", username="root", password="root"),
    radio_type=RadioTypes.AZQP,
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_gnb_pdu = FACOM(addr="10.56.115.241", port_numbers=[1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="OPT", port_id=1),
        target=Endpoint(unit=_ru, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="OPT", port_id=9),
        target=Endpoint(unit=_ru, label="OPT", port_id=2),
    ),
]
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[1],
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(
    airscale=_airscale, rus=[_ru], f1_m_ip_addr="192.168.255.129", cablinks=_ru_cablinks
)

# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="192.168.255.129",
        vlan_id=None,
        routing=RoutingInformation(gateway="0.0.0.0", ip_prefix_length=25),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="0.0.0.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="0.0.0.0", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="0.0.0.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="0.0.0.0", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="0.0.0.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="0.0.0.0", ip_prefix_length=26),
    ),
)

# RealEnb
_lmp_connection_enb = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_enb_pdu = FACOM(addr="10.56.115.241", port_numbers=[1])
_common_unit_1 = CommonUnit(
    lmp_connection=_lmp_connection_enb,
    capacity_units=[],
    pdu_port=_enb_pdu.pdu_ports[1],
)
_real_enb = Airscale(common_units=[_common_unit_1])
_lte_real_enb = RealEnb(airscale=_real_enb)

# cloud_topology
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASOE_AHCA_FDD_ENB"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu)

# test pc
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.163.81", username="ute", password="ute"
    )
)
_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.163.81", username="ute", password="ute"
    ),
    connections=[_lte_real_enb],
)

# switch Dtor
_dell_s4048on_ssh = SshServiceDetails(
    addr="0.0.0.0", port="1", username="5gran", password="nokia123"
)
_dell_s4048on_switch = DellS4048ONSwitch(_dell_s4048on_ssh)

# switch Mtor
_dell_s4048ton_ssh = SshServiceDetails(
    addr="0.0.0.0", port="1", username="5gran", password="nokia123"
)
_dell_s4048ton_switch = DellS4048TONSwitch(_dell_s4048ton_ssh)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    enbs=[_lte_real_enb],
    core=RealCore(mcc=262, mnc=3),
    tl_cloud_topology=_tl_cloud_topology,
    switches=[_dell_s4048on_switch, _dell_s4048ton_switch],
)
