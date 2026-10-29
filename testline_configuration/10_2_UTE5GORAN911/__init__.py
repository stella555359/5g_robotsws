__maintainer__ = "Challa Ravali"
__team__ = "I_MN_RAN_RD_VRF_BLR1_T02_GMS"
__email__ = "challa.ravali@nokia.com"
__owner_email__ = "challa.ravali@nokia.com"

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
        addr="10.58.238.12", username="ute", password="BT5l@bus3rl0g1n"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_du_pdu = RRB("10.45.153.163", [5])
_ru1_pdu = RRB("10.58.242.70", [2])
_ru2_pdu = RRB("10.58.242.70", [8])
_ru3_pdu = RRB("10.58.242.78", [8])
_ru4_pdu = RRB("10.45.153.161", [3])
_ru5_pdu = RRB("10.58.242.70", [4])
_du_pdu.pdu_ports[5].contactor = "NORMALLY_OPENED"
_ru1_pdu.pdu_ports[2].contactor = "NORMALLY_OPENED"
_ru2_pdu.pdu_ports[8].contactor = "NORMALLY_OPENED"
_ru3_pdu.pdu_ports[8].contactor = "NORMALLY_OPENED"
_ru4_pdu.pdu_ports[3].contactor = "NORMALLY_OPENED"
_ru5_pdu.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdus = [_du_pdu, _ru1_pdu, _ru2_pdu, _ru3_pdu, _ru4_pdu, _ru5_pdu]

##ahhb radio 
_ru_1 = RU(
    radio_type=RadioTypes.AHHB,
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="EA220654577",
    product_code="474252A.102",
    pdu_port=_ru1_pdu.pdu_ports[2], 
)

##fujitsu ofegsa ru
_ru_2 = FujitsuRU(
    radio_type=FujitsuRadioTypes.OFEGSA,
    hw_version="0100",
#    ru_hw_group="ThirdParty",
    serial_number="00015",
    product_code="TA08029-B311/01",
#    netconf_ssh_configuration=SshServiceDetails(addr="172.22.0.2",username="fjncuser0", password="ncCl2fjRu+autH0")
    pdu_port=_ru2_pdu.pdu_ports[8],
)

##ahpmdg radio 
_ru_3 = RU(
    radio_type=RadioTypes.AHPMDG,
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9250315109",
    product_code="476122A.101",  
    pdu_port=_ru3_pdu.pdu_ports[8],    
)

##azqp radio 
_ru_4 = RU(
    radio_type=RadioTypes.AZQP,
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="1M210201233",
    product_code="475198A.102",  
    pdu_port=_ru4_pdu.pdu_ports[3],    
)

##awhqn radio 
_ru_5 = RU(
    radio_type=RadioTypes.AWHQN,
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="AH242307856",
    product_code="475701A.103",  
    pdu_port=_ru5_pdu.pdu_ports[4],    
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    serial_number="DH214542912",
    pdu_port=_du_pdu.pdu_ports[5],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    serial_number="L1234500973",
    pdu_port=_du_pdu.pdu_ports[5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    serial_number="L1232907512",
    pdu_port=_du_pdu.pdu_ports[5],
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2,_fsp_3],
    pdu_port=_du_pdu.pdu_ports[5],
    hardware_type="ASIM",
	serial_number="L1231505501",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5],
)
_airscale = Airscale([_common_unit])
_cu = CU(
    backhaul_site_oam_ip="10.58.239.6",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.58.239.6", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.58.239.6", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1101),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1102),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1103),
)
_du = DU(_airscale)
_cbts = ClassicalBts(cu=_cu, dus=[_du])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.58.238.12", username="ute", password="BT5l@bus3rl0g1n"
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
    tl_cloud_topology="CLOUD_5G_ORAN_CLASSICAL_1ASIM_1ABIO_1ABIP_1ABIQ_1OFEGSA_1AHHB_1AHPMDG_1AZQP_1AWHQN",
    #ues=[_ue],
    pdus=_pdus,
)
__all__ = ["tl"]
