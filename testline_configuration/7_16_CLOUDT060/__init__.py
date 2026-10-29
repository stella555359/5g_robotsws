__maintainer__ = "Kamil Ostrzolek"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "kamil.ostrzolek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.hardware_controller import AmiaFanHardwareController
from taf.config.testline.attenuator import TopYoung


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.96", username="ute", password="ute"
    )
)

_pdu_rmod1 = ATEN(addr="10.42.61.94", port_numbers=[8])
_pdu_asik = ATEN(addr="10.42.61.152", port_numbers=[3])
_pdus = [_pdu_rmod1, _pdu_asik]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.18",
        vlan_id=820,
        routing_v4=RoutingInformation(gateway="10.44.76.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.44.76.82", vlan_id=821),
    x2u=NetworkAddress(v4="10.44.76.146", vlan_id=822),
    s1u=NetworkAddress(v4="10.44.76.210", vlan_id=823),
)
_gnb_ru1 = RU(
    ru_hw_group="AEQN",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[8],
)
_cu.m = NetworkAddress(v4="10.44.76.18", vlan_id=820)

_cu.sync = NetworkAddress(v4="10.44.77.18", vlan_id=824)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asik.pdu_ports[3],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50320, instance_id=50320)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asik_du1]),
    x2_link_addr=NetworkAddress(v4="10.44.76.79", vlan_id=821),
    global_bts_id=40308,
)

_lte.m = NetworkAddress(v4="10.44.76.15", vlan_id=820)

_rpi_smod = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.190", username="pi", password="pi"
    )
)

_rpi_rmod = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.189", username="pi", password="pi"
    )
)

_attenuator = TopYoung(
    ip_addr="10.42.61.195", port=["1-1.4", "1-1.3"], attenuation_port_numbers=[4, 3]
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ATT_RPI-EAC_ASIKL_ABILB1_AZQL",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
    hardware_controllers=[_rpi_smod, _rpi_rmod],
    attenuator=_attenuator,
)

__all__ = ["tl"]
