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
from taf.config.testline.pdu import ATEN, Gude, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.248", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(
    addr="10.44.205.224", port_numbers=[11], model="EPC", version="8221-1"
)
_pdu_asib = Gude(addr="10.44.205.146", port_numbers=[3], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.85.90",
        v6="2a00:8a00:6000:607c::1:6083",
        vlan_id=820,
        routing_v4=RoutingInformation(gateway="10.44.85.64"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6001"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:6183", vlan_id=821),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:624d", vlan_id=822),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:6353", vlan_id=823),
)

_gnb_ru1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[11],
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.36")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asib.pdu_ports[3],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50903, instance_id=50903)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asib_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:617d", vlan_id=821),
    global_bts_id=40333,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:607d", vlan_id=820)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AZQO_ECPRI",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
)

__all__ = ["tl"]
