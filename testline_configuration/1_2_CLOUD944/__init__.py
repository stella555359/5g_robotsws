# ##########################################################################################
#
#    7_2_UTE5GCLOUD944  IV_PS_045  -  CV045
#
#    2024-03-08 22:12:20.454778:
#  
#
# ##########################################################################################

__maintainer__ = "Suhel Ansari"
__owner_email__ = "suhel.ansari@nokia.com"
__team__ = "I_MN_RAN_RD_VRF_BLR1_T07_GMS"
__email__ = "suhel.ansari@nokia.com"

import os
import shutil

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline import RU, DU
from taf.config.testline.pdu import ATEN, FPFH, PduPort
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.core import RealCore4G
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer
from taf.config.testline.ue import Android
from collections import OrderedDict
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.pdu import Gude, RRB

# ################################################################################ #
#                                                                                  #
#                          TL standard definition                                  #
#                                                                                  #
# ################################################################################ #

cfg_dir = os.path.dirname(os.path.abspath(__file__))
os.environ["INIT_CONFIG_FILE_PATH"] = cfg_dir
os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(cfg_dir, "ue_config.yaml")

__all__ = ["tl"]
_du1_pdu_gnb = RRB("10.58.242.75", [1])
_ru1_pdu_gnb = RRB("10.58.242.59", [1,7])
_rmod_gnb_1 = RU(
    pdu_port=_ru1_pdu_gnb.pdu_ports[7],
    radio_type="OSQA",
    ru_hw_group="Third Party",
    serial_number="SJEOSQA2302S0011",
)
_rmod_gnb_2 = RU(
    pdu_port=_ru1_pdu_gnb.pdu_ports[1],
    radio_type="OSQA",
    ru_hw_group="Third Party",
    serial_number="SJEOSQA2302S0008",
)
_fsp_gnb_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="103",
    product_code="475266A.103",
    rus=[_rmod_gnb_1,_rmod_gnb_2],
    serial_number="DH214840836",
)
_fct_gnb_1 = CommonUnit(
    capacity_units=[_fsp_gnb_1],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu", port=22
    ),
    pdu_port=_du1_pdu_gnb.pdu_ports[1],
    serial_number="L1231505492",
)
_smod_gnb_1 = Airscale(common_units=[_fct_gnb_1])
_du_1 = DU(airscale=_smod_gnb_1, global_bts_id=944, instance_id=45)
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        routing_v4=RoutingInformation(gateway="10.58.239.129/0"),
        v4="10.58.239.151",
        vlan_id="1102",
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.45", password="nemuuser", port=443, username="Nemuadmin"
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.45", password="oZPS0POrRieRtu", port=22, username="toor4nsn"
    ),
    s1u=NetworkAddress(v4="10.58.239.151/25", vlan_id="4001"),
    x2c=NetworkAddress(v4="10.58.239.151/25", vlan_id="4001"),
    x2u=NetworkAddress(v4="10.58.239.151/25", vlan_id="4001"),
)
_gnb_sbts_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=944, instance_id=45)

_du1_pdu_enb = RRB("10.58.242.75",[2])

_fsp_enb_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="",
    product_code="",
    rus=[],
    serial_number="",
)
_fct_enb_1 = CommonUnit(
    capacity_units=[_fsp_enb_1],
    hardware_type="ASIB",
    hardware_version="",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", password="oZPS0POrRieRtu", port=22, username="toor4nsn"
    ),
    pdu_port=_du1_pdu_enb.pdu_ports[2],
    serial_number="",
)
_smod_enb_1 = Airscale(common_units=[_fct_enb_1])
_enb_sbts_1 = RealEnb(
    global_bts_id=943,
    instance_id=943,
    oam_ip=NetworkAddress(v4="10.58.239.22"),
    rms=[],
    system_module=_smod_enb_1,
)

_lte_enb = RealEnb(
    system_module=Airscale(
        common_units=[
            CommonUnit(
                hardware_type="ASIB",
                lmp_connection=SshServiceDetails(
                    addr="10.58.239.22",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu",
                ),
                capacity_units=[
                    CapacityUnit(
                        addr="192.168.253.20",
                        hardware_type="ABIO",
                    )
                ],
            )
        ]
    ),
    rms=[
        RU(
            ru_hw_group="LTE_RADIO",
            radio_type="FRHG",
        )
    ],
    instance_id=943,
    global_bts_id=943,
    oam_ip=NetworkAddress(
        v4="10.58.239.22",
        routing=RoutingInformation(
            gateway="10.58.239.22",
            ip_prefix_length=23,
        ),
    ),
    x2_link_addr=NetworkAddress(v4="10.58.239.151"),
)
_test_pc_gnb_1 = TestPc(
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(
            device=_gnb_sbts_1.dus[0].airscale.common_units[0],
            interface="eth1",
            interface_type="lmp",
        ),
    ],
    default_ssh_connection_details=SshServiceDetails(
        addr="10.58.238.45", password="ute", port=22, username="ute"
    ),
)
_pdus = [_du1_pdu_gnb, _ru1_pdu_gnb, _du1_pdu_enb]
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_NSA_ASIM_ABIO_2OSQA_UTECA"

tl = TestLine(
    gnbs=[_gnb_sbts_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    test_pc=_test_pc_gnb_1,
    test_pcs=[_test_pc_gnb_1],
    tl_cloud_topology=_tl_cloud_topology,
)
