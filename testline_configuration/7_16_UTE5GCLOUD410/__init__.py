__maintainer__ = "Karol Palac"
__team__ = "RRM2 team"
__email__ = "karol.palac@nokia.com"
__owner_email__ = "sebastian.mikos@nokia.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline import RoutingInformation
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import TopYoung

_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_pdu1 = ATEN(addr="10.42.61.221", port_numbers=[3])

_pdu2 = Gude("10.44.177.39", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu3 = ATEN(addr="10.42.61.241", port_numbers=[4])

_pdus = [_pdu1, _pdu2, _pdu3]

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[12],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHFIB",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.132", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[11],
    ru_hw_group="",
    radio_type="AHFIB",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHFIB",
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.14", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AEHC",
)

_ru_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AEHC",
)

_ru_9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.10", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AEHC",
)

_attenuator1 = TopYoung(
    ip_addr="10.42.221.124",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="",
)

_attenuator2 = TopYoung(
    ip_addr="10.42.221.125",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model = ""
)

_abil_master = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL", rus=[_ru_1, _ru_2])
_abil_slave = CapacityUnit(addr="192.168.253.21", hardware_type="ABIL", rus=[_ru_3])
_abio_loner = CapacityUnit(addr="192.168.253.22", hardware_type="ABIO", rus=[_ru_4, _ru_5, _ru_6])
_abip_master = CapacityUnit(addr="192.168.253.36", hardware_type="ABIP", rus=[_ru_7, _ru_8, _ru_9])

_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abio_loner],
    hardware_type="ASIL",
    pdu_port=_pdu3.pdu_ports[4],
)

_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_master],
    hardware_type="ASIL",
    pdu_port=_pdu1.pdu_ports[3],
)

_airscale1 = Airscale(common_units=[_common_unit1])

_airscale2 = Airscale(common_units=[_common_unit2])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=820,
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
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=821,
    ),
    x2u=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=822,
    ),
    s1u=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=823,
    ),
    xnc=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=821,
    ),
    xnu=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=822,
    ),
    ngc=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=895,
    ),
    ngu=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=823,
    ),
)


_du1 = DU(_airscale1, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6])

_du2 = DU(_airscale2, rus=[_ru_7, _ru_8, _ru_9])

_cbts1 = ClassicalBts(cu=_cu, dus=[_du1], instance_id=50857, global_bts_id=50857)

_cbts2 = ClassicalBts(cu=_cu, dus=[_du2], instance_id=50857, global_bts_id=50857)

_core = RealCore5G(mcc=310, mnc=260)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.119", username="ute", password="ute"
    ),
    connections=[_cbts1.dus[0].airscale.common_units[0]],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.120", username="ute", password="ute"
    ),
    connections=[_cbts2.dus[0].airscale.common_units[0]],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.183", username="wro5grrm", password="5gpass!1"
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.45.168.53",
    iperf_path="/data/data/com.nokia.android.application/iperf",
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIL_ABIO_ABIP_TMO_129",
    core=_core,
    pdus=_pdus,
    ues=[_ue_config],
    attenuators=[_attenuator1, _attenuator2],
)

__all__ = ["tl"]
