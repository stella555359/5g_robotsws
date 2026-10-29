__maintainer__ = "Alexandru Goman"
__email__ = "alexandru.goman@nokia.com"
# BTS ID: 10826
# BTS name: TL3_VOLKSWAGEN
# EXTRA LINE

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline import Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude(
    addr="10.255.3.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.3.14",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3 = Gude(
    addr="10.255.3.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)             
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"                                                 

_pdus = [_pdu_1, _pdu_2, _pdu_3]                                

_rmod_1 = RU(
    radio_type="AZQS",
    ru_hw_group="RF.ERM6.23R3.20230708.001",
    serial_number="4H205230065",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_2 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.23R3.20230719.003",
    serial_number="DH210669330",
    pdu_port=_pdu_3.pdu_ports[12],
)
_rmod_3 = RU(
    radio_type="FRGU",
    ru_hw_group="FRM33.32.R02D",
    serial_number="K9170319068",
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_4 = RU(
    radio_type="FXED",
    ru_hw_group="FRM33.32.R02D",
    serial_number="L1170711405",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_7 = RU(
    radio_type="AZQS",
    ru_hw_group="RF.ERM6.23R3.20230708.001",
    serial_number="1M212807149",
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_11 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01",
    serial_number="F7172701594",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_12 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01",
    serial_number="F7172314051",
    pdu_port=_pdu_2.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225207056",
    rus=[_rmod_7],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225206962",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171308595",
    rus=[_rmod_11, _rmod_12],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164819545",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164817848",
    rus=[_rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171302155",
    rus=[_rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1242114514",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1181219181",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_11, _rmod_12],
    oam_ip=NetworkAddress("10.15.236.226"),
    instance_id=10826,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3, _rmod_4, _rmod_7],
    master=_enb_sbts_1,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.221", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),

    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.227", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),

    ],
)

_enb_sbts_1.slave = _enb_sbts_2

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,           
    tl_cloud_topology="CLOUD_SRAN_NLWG_10826_1ASIB_2ABIO_1ABIA_1ASIA_3ABIA_2FXDB_2AZQS_1FXED_1FRGU_1AHEH",
)

__all__ = ["tl"]

