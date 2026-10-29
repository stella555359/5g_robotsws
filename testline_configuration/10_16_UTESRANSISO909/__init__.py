__maintainer__ = "Piotr Korczynski"
__team__ = "siso"
__email__ = "piotr.korczynski@nokia.com"
__owner_email__ = "piotr.korczynski@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ald import ALD
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.optical_switch import OpticalSwitch, Leoni


_pdu_1 = ATEN(
    "10.42.51.232",
    [6, 7, 8],
)
_pdu_2 = ATEN(
    "10.42.51.180",
    [1, 2, 3, 4],
)

# _opt_sw_1 = Leoni(addr="192.168.255.129", model="mol 6x(2x6)", port=3001)
# _opt_sw_2 = Leoni(addr="192.168.255.119", model="mol 6x(2x6)", port=3001)
# _attenuator_1 = JFW(
#     ip_addr="192.168.255.129",
#     port=3001,
#     attenuation_port_numbers=range(1, 16),
#     serial_number="123456",
# )

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L1154809204",
    pdu_port=_pdu_1.pdu_ports[6],
    radio_type=RadioTypes.FXEF.value,
    # alds=[ALD(ald_type='MHA', serial_number="L1173212399"), ALD(ald_type='RET', serial_number='L1173212398')],
    # attenuation_ports=[
    #     _attenuator_1.attenuator_ports[13],
    #     _attenuator_1.attenuator_ports[14],
    #     _attenuator_1.attenuator_ports[15],
    #     _attenuator_1.attenuator_ports[16],
    # ],
    # optical_switch_channels=[
    #     _opt_sw_1.modules[1].channels[3],
    #     _opt_sw_1.modules[2].channels[1],
    #     _opt_sw_1.modules[3].channels[1],
    # ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L1154809206",
    radio_type=RadioTypes.FRGS.value,
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L6141629878",
    pdu_port=_pdu_1.pdu_ports[8],
    radio_type=RadioTypes.FRGS.value,
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L1141611333",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="L1141527943",
    pdu_port=_pdu_2.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1173009916",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1173003010",
    pdu_port=_pdu_2.pdu_ports[1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    serial_number="L1173003023",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    serial_number="L1173009893",
    pdu_port=_pdu_2.pdu_ports[2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    serial_number="L1164508172",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIA",
    serial_number="L1173212304",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIA",
    serial_number="L1173212320",
)

_node_1 = Airscale([_fct_1])
_node_2 = Airscale([_fct_2])

_du_1 = DU(_node_1, rus=[_rmod_1, _rmod_2])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.168.109"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

# _gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=1462)
_enb_sbts_1 = RealEnb(
    system_module=_node_1,
    rms=[_rmod_1, _rmod_2],
    global_bts_id=1411,
    instance_id=1411,
    oam_ip=NetworkAddress("10.42.106.133"),
)

# _enb_sbts_2 = RealEnb(system_module=_node_2, rms=[_rmod_3, _rmod_4, _rmod_5])
_enb_sbts_2 = RealEnb(
    system_module=_node_2, rms=[_rmod_3, _rmod_4, _rmod_5], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.184.146", username="ute"
    ),
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
    SshServiceDetails(addr="10.42.184.125", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_rnc = RNC(  # RNC configuration (optional - for 3G)
    rnc_id=40,  # RNC ID
    oms_ip=NetworkAddress("10.44.44.218"),  # OMS IP
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.23.26",
        username="SYSTEM",
        password="SYSTEM",  # U/C-plane of WCDMA, and OMS login username/password
    ),
)
_bsc = BSC(  # BSC configuration (optional - for 2G)
    name="asBSC23",  # BSC ID
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.4.132",
        username="PZUSER4",
        password="Ut3pa5s#1be1",  # IP, username and password to BSC
    ),
)
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    # optical_switches=[_opt_sw_1, _opt_sw_2],
    # attenuators=[_attenuator_1],
)

__all__ = ["tl"]
