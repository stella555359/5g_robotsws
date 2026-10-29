__maintainer__ = "Piotr Linek"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import EPCSim
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, APC, Gude
from collections import Counter

# ===================================== VMs ===========================================

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.83.204", username="ute", password="ute"
    )
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.83.208", username="ute", password="ute"
    )
)
# ===================================== PDUs ===========================================

_pdu1 = Gude(
    addr="10.42.80.236",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)
_pdus = [_pdu1]

# ===================================== RUs ===========================================

_shared_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[6],
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
)

# ===================================== ENB ===========================================

_abia = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183942800",
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu1.pdu_ports[12],
    serial_number="L1174808381",
    hardware_type="ASIA",
    hardware_version="473095A.203",
)

# ===================================== GNB ===========================================

_abil_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184007512",
)

_asik_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_1],
    pdu_port=_pdu1.pdu_ports[10],
    serial_number="L1184210711",
    hardware_version="474021A.101",
    hardware_type="ASIK",
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.1.1.3"),
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
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    s1c=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    tracing=None,
)

_airscale = Airscale([_asik_gnb])

_du = DU(_airscale, rus=[_shared_ru1])

_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.1.1.5",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    rms=[_shared_ru1],
)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=3666, instance_id=6039)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_RFS_AIR_B4_2722_1a1_AHLOA",
    pdus=_pdus,
    enbs=[_lte],
)

__all__ = ["tl"]

# =================================== Backup =========================================
# _abil_1 = CapacityUnit(
#     addr="192.168.253.20",
#     hardware_type="ABIL",
#     hardware_version="474020A.102",
#     serial_number="L1184007512",
# )
#
# _common_unit = CommonUnit(
#     lmp_connection=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_abil_1],
#     pdu_port=_pdu1.pdu_ports[10],
#     serial_number="L1184210711",
#     hardware_version="474021A.101",
#     hardware_type="ASIK",
# )
#
# _airscale = Airscale([_common_unit])
#
# _cu = CU(
#     backhaul_site_oam_ip=NetworkAddress(v4="10.1.1.3"),
#     oam_ssh_connection_details=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     oam_http_connection_details=HttpConnectionDetails(
#         addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
#     ),
#     f1m=None,
#     f1c=None,
#     f1u=None,
#     x2c=NetworkAddress(
#         v4="10.1.1.3",
#         v6=None,
#         vlan_id=None,
#         routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
#     ),
#     x2u=NetworkAddress(
#         v4="10.1.1.3",
#         v6=None,
#         vlan_id=None,
#         routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
#     ),
#     s1c=NetworkAddress(
#         v4="10.1.1.3",
#         v6=None,
#         vlan_id=None,
#         routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
#     ),
#     s1u=NetworkAddress(
#         v4="10.1.1.3",
#         v6=None,
#         vlan_id=None,
#         routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
#     ),
#     tracing=None,
# )
#
# _shared_ru1 = RU(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="192.168.254.52", username="root", password="umniedziala"
#     ),
#     lmp_connection=SshServiceDetails(addr="", username=""),
#     pdu_port=_pdu1.pdu_ports[6],
#     ru_hw_group="FRMr5.1a_4T4R",
#     radio_type="AHLOA",
# )
#
# _du = DU(_airscale, rus=[_shared_ru1])
#
# _cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=3666)
#
# _core = EPCSim(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.42.53.81", username="ute", password="ute"
#     ),
#     dir_path="/home/ute/epcsim",
#     cfg_filename="config_new.cfg",
#     mme_ip="10.1.1.100",
#     mcc=311,
#     mnc=489,
#     tac=788,
#     edaemon_port=10000,
#     egate_port=20000,
# )
#
# _common_unit_lte_ssh = SshServiceDetails(
#     addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
# )
#
# _common_unit_lte = CommonUnit(
#     _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=None
# )
#
# _abia = CapacityUnit(
#     addr="192.168.253.36",
#     hardware_type="ABIA",
#     hardware_version="473096A.103",
#     serial_number="EA183942800",
# )
#
# _asia = CommonUnit(
#     lmp_connection=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_abia],
#     pdu_port=_pdu1.pdu_ports[12],
#     serial_number="L1174808381",
#     hardware_type="ASIA",
#     hardware_version="473095A.203",
# )
#
# _lte = RealEnb(
#     system_module=Airscale(common_units=[_asia]),
#     x2_link_addr=NetworkAddress(
#         v4="10.1.1.5",
#         v6=None,
#         vlan_id=None,
#         routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
#     ),
#     global_bts_id=1,
#     rms=[_shared_ru1],
# )
#
# tl = TestLine(
#     test_pc=_test_pc_1,
#     test_pcs=[_test_pc_1, _test_pc_2],
#     gnbs=[_cbts],
#     tl_cloud_topology="CLOUD_RFS_AIR_B4_2722_1a1_AHLOA",
#     core=_core,
#     pdus=_pdus,
#     enbs=[_lte],
# )
#
# __all__ = ["tl"]
#
#
# def combine_hardware(tl):
#
#     if tl.enbs is not None and tl.gnbs is not None:
#         rmod_list = []
#         smod_list = []
#         cards_list = []
#         for item in tl.gnbs[0].dus[0].rus:
#             rmod_list.append(str(item.radio_type))
#         for item in tl.gnbs[0].dus[0].airscale.common_units:
#             smod_list.append(item.hardware_type)
#             for item in item.capacity_units:
#                 cards_list.append(item.hardware_type)
#
#         for item in tl.enbs[0].rms:
#             rmod_list.append(str(item.radio_type))
#         for item in tl.enbs[0].system_module.common_units:
#             smod_list.append(item.hardware_type)
#             for item in item.capacity_units:
#                 cards_list.append(item.hardware_type)
#     else:
#         rmod_list = []
#         smod_list = []
#         cards_list = []
#         for item in tl.enbs[0].rms:
#             rmod_list.append(str(item.radio_type).split(".")[1])
#         for item in tl.enbs[0].system_module.common_units:
#             smod_list.append(item.hardware_type)
#             for item in item.capacity_units:
#                 cards_list.append(item.hardware_type)
#
#     radios = count_hardware(rmod_list)
#     cards = count_hardware(cards_list[:4])
#     system_modules = count_hardware(smod_list[:4])
#     hw_config = ("{}+{}+{}").format(system_modules, cards, radios)
#     return hw_config, radios
#
#
# def count_hardware(devices):
#     sorted_devices = []
#     devices_list = dict(Counter(devices))
#     for hw in devices_list.keys():
#         sorted_devices.append(str(devices_list[hw]) + str(hw))
#     return "+".join(sorted_devices)
#
#
# if __name__ == "__main__":
#     combine_hardware(tl)
