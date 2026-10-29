__maintainer__ = "Kamil Ostrzolek"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "kamil.ostrzolek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ue import Android
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
        addr="10.44.156.144", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(addr="10.44.206.187", port_numbers=[1], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.205.3", port_numbers=[6], model="EPC", version="8221-1")
_pdu_asib = Gude(addr="10.44.206.142", port_numbers=[6], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.64.51",
        vlan_id=454,
        routing_v4=RoutingInformation(gateway="10.44.64.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.44.64.51", vlan_id=454),
    x2u=NetworkAddress(v4="10.44.64.51", vlan_id=454),
    s1u=NetworkAddress(v4="10.44.64.51", vlan_id=454),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[1],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="root", password="root"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[6],
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asib.pdu_ports[6],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50304, instance_id=50304)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asib_du1]),
    x2_link_addr=NetworkAddress(v4="10.44.64.116", vlan_id=454),
    global_bts_id=40304,
)

_lte.m = NetworkAddress(v4="10.44.64.52", vlan_id=455)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/data/data/com.magicandroidapps.iperf/bin/iperf",
)

_ue_pc_ssh = SshServiceDetails("10.42.22.136", "wro5goam", password="Uteadmin1@")

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey_ue.yaml"
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1B2_AHLOA_AHDB",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
    ues=[_qualcomm_ue],
)
__all__ = ["tl"]
