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
from taf.config.testline.core import RealCore5G
from taf.config.testline.hardware_controller import AmiaFanHardwareController
from taf.config.testline import RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.78", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(addr="10.44.206.141", port_numbers=[5], model="EPC", version="8221-1")
_pdu_asib = ATEN(addr="10.42.61.152", port_numbers=[6])
_pdus = [_pdu_rmod1, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.14",
        vlan_id=820,
        routing_v4=RoutingInformation(gateway="10.44.76.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.44.76.78", vlan_id=821),
    x2u=NetworkAddress(v4="10.44.76.78", vlan_id=822),
    s1u=NetworkAddress(v4="10.44.76.78", vlan_id=823),
)

_gnb_ru1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AZQG",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="root"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[5],
)
_core = RealCore5G(mcc=555, mnc=10)

_cu.m = NetworkAddress(v4="10.44.76.78", vlan_id=820)

_cu.sync = NetworkAddress(v4="10.44.76.78", vlan_id=824)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asib.pdu_ports[6],
)

_du_1_gnb_1 = DU(Airscale(common_units=[_asib_du1]), rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50308, instance_id=50308)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asib_du1]),
    x2_link_addr=NetworkAddress(v4="10.44.76.79", vlan_id=821),
    global_bts_id=40308,
)

_lte.m = NetworkAddress(v4="10.44.76.15", vlan_id=459)

_rpi_smod = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.142", username="pi", password="pi"
    )
)

_rpi_rmod = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.143", username="pi", password="pi"
    )
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AZQL",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
    hardware_controllers=[_rpi_smod, _rpi_rmod],
)

__all__ = ["tl"]
