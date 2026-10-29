__maintainer__ = "Sahadeb Ghosh"
__team__ = "VRFBLR1TO3"
__email__ = "sahadeb.ghosh@nokia.com"
__owner_email__ = "sahadeb.ghosh@nokia.com"

import os
import yaml
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import Gude, RRB
from taf.config.testline import RU, RadioTypes, FujitsuRU, FujitsuRadioTypes
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.58.238.103", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_du_pdu = RRB("10.45.153.147", [2])
_ru1_pdu = RRB("10.45.153.147", [1])
_ru2_pdu = RRB("10.45.153.147", [4])
_du_pdu.pdu_ports[2].contactor = "NORMALLY_OPENED"
_ru1_pdu.pdu_ports[1].contactor = "NORMALLY_OPENED"
_ru2_pdu.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdus = [_du_pdu, _ru1_pdu, _ru2_pdu]

_ru_1 = RU(
    radio_type=RadioTypes.AKQJ,
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    serial_number="1M241710136",
    product_code="475824A.101",
    pdu_port=_ru1_pdu.pdu_ports[1],
)

_ru_2 = RU(
    radio_type=RadioTypes.ARGA,
    ru_hw_group="FRMr5.1_1_6T6R",
    serial_number="AS212911517",
    product_code="474800A.102",
    pdu_port=_ru2_pdu.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    serial_number="L1211712420",
    pdu_port=_du_pdu.pdu_ports[2],
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_du_pdu.pdu_ports[2],
    hardware_type="ASIL",
	serial_number="DH220351323",
    rus=[_ru_1, _ru_2],
)
_airscale = Airscale([_common_unit])
_cu = CU(
    backhaul_site_oam_ip="10.58.239.180",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.58.239.180", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.58.239.180", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.58.239.180", vlan_id=1102),
    x2u=NetworkAddress(v4="10.58.239.180", vlan_id=1102),
    s1u=NetworkAddress(v4="10.58.239.180", vlan_id=1102),
)
_du = DU(_airscale)
_cbts = ClassicalBts(cu=_cu, dus=[_du])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.58.238.103", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
       # _ue,
    ],
)

def _set_abstract_lib_config_env(ue_config_file):
   tl_config_dir = os.path.dirname(os.path.abspath(__file__))
   ue_config_abs_path = os.path.join(tl_config_dir, ue_config_file)
   with open(ue_config_abs_path) as ta_ue_config:
       ue_config = yaml.safe_load(ta_ue_config)
   os.environ["ABSTRACT_LIB_CONFIG"] = ue_config_abs_path
   return ue_config

_ue_config = _set_abstract_lib_config_env("ta_ue_config.yaml")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_N_1ASIL_1ABIO_1AKQJ_1ARGA",
    #ues=[_ue],
    pdus=_pdus,
)
__all__ = ["tl"]
