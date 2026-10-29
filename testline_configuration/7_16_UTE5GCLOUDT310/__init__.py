__maintainer__ = "Tomasz Dąbrowski "
__team__ = "MN 5G RAN PZ WRO2 SG05 Jumbo"
__email__ = "tomasz.dabrowski@nokia.com"
__owner_email__ = "tomasz.dabrowski@nokia.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
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
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung

_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ues.yaml")


_pdu1 = Gude(addr="10.44.200.28", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu2 = Gude(addr="10.44.200.29", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu3 = Gude(addr="10.44.200.30", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu4 = Gude(addr="10.44.200.31", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu5 = Gude(addr="10.44.200.34", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5]

_attenuator1 = TopYoung(ip_addr="10.42.83.15", port=3001, attenuation_port_numbers=range(1, 25), pdu_port=_pdus[3].pdu_ports[1])
_attenuator2 = TopYoung(ip_addr="10.42.83.16", port=3001, attenuation_port_numbers=range(1, 25), pdu_port=_pdus[3].pdu_ports[2])

_vm_1_ssh = SshServiceDetails(addr="10.42.209.74", username="ute", password="ute")
_vm_2_ssh = SshServiceDetails(addr="10.42.209.90", username="ute", password="ute")
_ue_pc_ssh = SshServiceDetails(addr="10.42.188.119", username="wro5grrm", password="5gpass!1")
_lmp_ssh = SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
_lmp_ssh_2 = SshServiceDetails(addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu")

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.137.32/26",
        v6=None,
        vlan_id=404,
    ),
    oam_ssh_connection_details=_lmp_ssh,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.137.32", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.137.86/26",
        v6=None,
        vlan_id=405,
    ),
    x2u=NetworkAddress(
        v4="10.44.137.150/26",
        v6=None,
        vlan_id=406,
    ),
    s1u=NetworkAddress(
        v4="10.44.137.227/26",
        v6=None,
        vlan_id=407,
    ),
    xnc=NetworkAddress(
        v4="10.44.137.86/26",
        v6=None,
        vlan_id=405,
    ),
    xnu=NetworkAddress(
        v4="10.44.137.150/26",
        v6=None,
        vlan_id=406,
    ),
    ngc=NetworkAddress(
        v4="10.42.70.86/26",
        v6=None,
        vlan_id=415,
    ),
    ngu=NetworkAddress(
        v4="10.44.137.227/26",
        v6=None,
        vlan_id=407,
    ),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2239D50K0"
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.134", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50W8"
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[10],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50WA"
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.166", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[5],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001325"
)

_ru5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.166", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[6],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001327"
)

_ru6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.58.162", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001326"
)

_ru7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="K9245001200"
)

_ru8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="K9245001131"
)

_ru9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="K9245001199"
)

_ru10 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1243806287"
)
_ru11 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1243806289"
)


_ru12 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="serviceuser", password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1243606671"
)


#MASTER NODE
_abip_1 = CapacityUnit(addr="fsp1s0icom", hardware_type="ABIO", rus=[_ru1, _ru2, _ru3])
_master_node_capacity_units = [_abip_1]

#SECONDARY NODE
_abip_2 = CapacityUnit(addr="fsp4s0icom", hardware_type="ABIO", rus=[_ru4, _ru5, _ru6, _ru10, _ru11, _ru12])
_abip_3 = CapacityUnit(addr="fsp5s0icom", hardware_type="ABIO", rus=[_ru7, _ru8, _ru9])
_secondary_node_capacity_units = [_abip_2, _abip_3]


_common_unit1 = CommonUnit(
    lmp_connection=_lmp_ssh,
    hardware_type="ASIM",
    capacity_units=_master_node_capacity_units, pdu_port=_pdu5.pdu_ports[7]
)

_common_unit2 = CommonUnit(
    lmp_connection=_lmp_ssh_2,
    hardware_type="ASIM",
    capacity_units=_secondary_node_capacity_units, pdu_port=_pdu5.pdu_ports[5]
)

_airscale1 = Airscale([_common_unit1])
_airscale2 = Airscale([_common_unit2])

_du1 = DU(_airscale1, rus=[_ru1, _ru2, _ru3])
_du2 = DU(_airscale2, rus=[_ru4, _ru5, _ru6, _ru7, _ru8, _ru9, _ru10, _ru11, _ru12])

_cbts1 = ClassicalBts(cu=_cu, dus=[_du1], instance_id=55404, global_bts_id=55404)
_cbts2 = ClassicalBts(cu=_cu, dus=[_du2], instance_id=55404, global_bts_id=55404)

_vm_1_lmp_connection = Connection(interface="eth1", device=_cbts1.dus[0].airscale.common_units[0], interface_type="lmp")
_vm_2_lmp_connection = Connection(interface="eth1", device=_cbts2.dus[0].airscale.common_units[0], interface_type="lmp")

_test_pc1 = TestPc(default_ssh_connection_details=_vm_1_ssh, connections=[_vm_1_lmp_connection])
_test_pc2 = TestPc(default_ssh_connection_details=_vm_2_ssh, connections=[_vm_2_lmp_connection])

_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIM_ABIP_3xAHLOB_3xAVHA_3xAHFII_3xAVQQA",
    core=_core,
    pdus=_pdus,
    attenuators=[_attenuator1, _attenuator2]
)

__all__ = ["tl"]
