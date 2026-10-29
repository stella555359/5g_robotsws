__maintainer__ = "Mateusz Bury"
__team__ = "RRM team"
__email__ = "mateusz.bury@nokia.com"
__owner_email__ = "mateusz.bury@nokia.com"

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
from taf.config.testline.lmi import LMI, Local, SerialOverHost

_pdu_gnb = ATEN(addr="10.44.206.39", port_numbers=[5, 6, 7])

_pdu_gnb_ru_1 = ATEN(addr="10.44.206.121", port_numbers=[3])

_pdu_gnb_ru_2 = ATEN(addr="10.44.205.252", port_numbers=[5])

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2]

_attenuator = TopYoung(
    ip_addr="10.42.221.78",
    port=3001,
    attenuation_port_numbers=[1, 2, 5, 6, 7, 8, 9, 10, 11, 12],
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.231.216/26", v6=None, vlan_id=707),
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
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
    x2u=NetworkAddress(
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
    s1u=NetworkAddress(
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
    xnc=NetworkAddress(
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
    xnu=NetworkAddress(
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
    ngc=NetworkAddress(
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
    ngu=NetworkAddress(
        v4="10.44.232.24/26",
        v6=None,
        vlan_id=708,
    ),
)

_cu_gnb_1.m = NetworkAddress(
    v4="https://10.44.231.216",
    v6=None,
    vlan_id=707,
)

_lmi_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.22.4", username="wro5grrm", password="5gpass!1"
    )
)

_ahfii_mumin = SerialOverHost(host=_lmi_pc, uart_mapping=[Local(port="COM17")])
_azhl_lmi = LMI(product_code="", host=_lmi_pc, uart_mapping=[Local(port="COM15")])
_ahfib_lmi = LMI(product_code="", host=_lmi_pc, uart_mapping=[Local(port="COM21")])
_avql_lmi = LMI(product_code="", host=_lmi_pc, uart_mapping=[Local(port="COM3")])

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2240N42OI",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb.pdu_ports[5],
    lmi=_ahfii_mumin,
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH211900763",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[5],
    lmi=_azhl_lmi,
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="K9182844174",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb.pdu_ports[6],
    lmi=_ahfib_lmi,
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AVQL",
    serial_number="L1233304837",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[3],
    lmi=_avql_lmi,
)


_bbmod_1_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204509692",
    rus=[_gnb_ru_3],
)

_bbmod_2_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="EA194457508",
    rus=[_gnb_ru_2, _gnb_ru_4],
)

_bbmod_3_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234500985",
    rus=[_gnb_ru_1],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220345007",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1, _bbmod_2_gnb_1, _bbmod_3_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[7],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb = DU(_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb], instance_id=51992, global_bts_id=51992
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.81", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

# _ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
#    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
# )

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL71_ASIL_ABIO_ABIL_ABIP_AHFII_AZHL_AHFIB_AVQL_MRAT",
    core=_core,
    pdus=_pdus,
    #    ues=[_ues],
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1],
)

__all__ = ["tl"]
