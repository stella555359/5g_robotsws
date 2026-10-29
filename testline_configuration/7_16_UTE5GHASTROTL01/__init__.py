__maintainer__ = "Pawel Zabawczuk"
__team__ = "RRM team"
__email__ = "pawel.k.zabawczuk@nokia.com"
__owner_email__ = "pawel.k.zabawczuk@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.flexi import Flexi
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.ue import Android
from taf.config.testline.attenuator import TopYoung


_pdu_gnb = ATEN(addr="10.44.206.39", port_numbers=[2, 3, 4])

_pdu_gnb_ru = Gude(
    addr="10.44.206.147",
    port_numbers=[4, 5],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]

_attenuator = TopYoung(
    ip_addr="10.42.54.194",
    port=3001,
    attenuation_port_numbers=[3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="TAS_24T24_02G6_90_1S_EJS",
)

_pdu_gnb_att = Gude(
    addr="10.44.177.130",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
)

_attenuator.pdu_port = _pdu_gnb_att.pdu_ports[12]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.76.57/26", v6=None, vlan_id=820),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.76.110/26", v6=None, vlan_id=821),
    x2u=NetworkAddress(v4="10.44.76.159/26", v6=None, vlan_id=822),
    s1u=NetworkAddress(v4="10.44.76.224/26", v6=None, vlan_id=823),
    tracing=None,
)

_cu_gnb_1.sync = NetworkAddress(v4="10.44.77.31/26", v6=None, vlan_id=824)

_cu_gnb_1.m = NetworkAddress(v4="https://10.44.76.57", v6=None, vlan_id=820)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AZQJ",
    serial_number="1M222701644",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],
    ],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AZQI",
    serial_number="1M203838380",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
)

_bbmod_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183301774",
    rus=[_gnb_ru_1, _gnb_ru_2],
)


_smod_gnb_1 = CommonUnit(
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="L1190908790",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb = DU(_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb], instance_id=50090, global_bts_id=50090
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.43", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=555, mnc=10)

_nokia_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yaml"
)

# ************************************************LTE****************************
_enb_ru_1 = RU(
    ru_hw_group="",
    radio_type="FRHA",
    serial_number="L1110109260",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
)

_bbmod_enb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184674496",
    rus=[_enb_ru_1],
)

_smod_enb_1 = CommonUnit(
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1184702812",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_enb_1],
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_airscale_enb_1 = Flexi([_smod_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    rms=[_enb_ru_1],
    instance_id=40092,
    global_bts_id=40092,
    x2_link_addr=NetworkAddress(v4="10.44.76.97/26", v6=None, vlan_id=821),
)

_enb_1.m = NetworkAddress(v4="https://10.44.76.33", v6=None, vlan_id=820)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.58", username="ute", password="ute"
    ),
    connections=[_enb_1.system_module.common_units[0]],
)
# *******************************************************************************

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL01_ASIK_ABIL_AZQJ_AZQI",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    ues=[_nokia_ue],
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
)

__all__ = ["tl"]

# define max tput values in Mbit/sec
setattr(tl, "max_tput", {"dl": {"nr": 1530, "lte": 23}, "ul": {"nr": 110, "lte": 18}})

############### ADDITIONAL PARAMS ###############
#
# 5G SWITCH DATA: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.187.109&type=quanta
# 5G SWITCH MGMT: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.219&type=cisco
#
# POD ID: 7
# RACK: 633
