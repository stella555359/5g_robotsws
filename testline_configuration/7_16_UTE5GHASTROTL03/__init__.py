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
from taf.config.testline.attenuator import TopYoung, JFW


_pdu_gnb = ATEN(addr="10.42.61.80", port_numbers=[3])

_pdu_gnb_ru_1 = ATEN(addr="10.44.206.25", port_numbers=[5])

_pdu_gnb_ru_2 = Gude(
    addr="10.44.177.82",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_3 = Gude(
    addr="10.44.206.170",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_gnb_ru_3]

_attenuator = JFW(
    ip_addr="10.42.61.4",
    port=3001,
    attenuation_port_numbers=[5, 6, 7, 8, 9, 10, 11, 12],
    model="50PA-717",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.43/26",
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
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=821,
    ),
    x2u=NetworkAddress(
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=820,
    ),
    s1u=NetworkAddress(
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=820,
    ),
    xnc=NetworkAddress(
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=820,
    ),
    xnu=NetworkAddress(
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=820,
    ),
    ngc=NetworkAddress(
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=820,
    ),
    ngu=NetworkAddress(
        v4="10.44.76.43/26",
        v6=None,
        vlan_id=820,
    ),
)

_cu_gnb_1.m = NetworkAddress(
    v4="https://10.44.76.43",
    v6=None,
    vlan_id=820,
)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213808578",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1204708773",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[10],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH220540882",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_3.pdu_ports[11],
)


_bbmod_1_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208594",
    rus=[_gnb_ru_1, _gnb_ru_2],
)

_bbmod_2_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233206254",
    rus=[_gnb_ru_3],
)

_bbmod_3_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1214511965",
    rus=[_gnb_ru_2, _gnb_ru_2],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203606152",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1, _bbmod_2_gnb_1, _bbmod_3_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb = DU(_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb], instance_id=50088, global_bts_id=50088
)

_enb_1 = RealEnb(
    system_module=_airscale_gnb_1,
    instance_id=50088,
    global_bts_id=40420,
    x2_link_addr=NetworkAddress(
        v4="10.44.76.117/26",
        v6=None,
        vlan_id=821,
    ),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.81", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_ABIQ_ABIN_2xAEHC_AZHL_MRAT",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    ues=[_ues],
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1],
)

__all__ = ["tl"]
