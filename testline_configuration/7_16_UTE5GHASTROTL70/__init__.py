__maintainer__ = "Grzegorz Slowinski"
__team__ = "RRM team"
__email__ = "grzegorz.slowinski@nokia.com"
__owner_email__ = "grzegorz.slowinski@nokia.com"

import os
import yaml
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
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import TopYoung


_pdu_gnb = ATEN(addr="10.42.61.127", port_numbers=[2])

_pdu_gnb_ru = Gude(
    addr="10.44.177.139",
    port_numbers=[3, 4, 5],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]

_attenuator = TopYoung(
    ip_addr="10.42.54.171",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_gnb_ru_1 = RU(
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
    ru_hw_group="",
    serial_number="BL1930G11Q6",
    radio_type="AHLOA",
)

_gnb_ru_2 = RU(
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
    ru_hw_group="",
    serial_number="BL1934G10V7",
    radio_type="AHLOA",
)

_gnb_ru_3 = RU(
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
    ru_hw_group="",
    serial_number="BL1933G10Q3",
    radio_type="AHLOA",
)

_bbmod_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="474020A.101",
    serial_number="L1183000708",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1210402786",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_airscale = Airscale([_smod_gnb_1])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.88.137/26",
        v6=None,
        vlan_id=480,
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
        v4="10.44.88.201/26",
        v6=None,
        vlan_id=481,
    ),
    x2u=NetworkAddress(
        v4="10.44.89.9/26",
        v6=None,
        vlan_id=482,
    ),
    s1u=NetworkAddress(
        v4="10.44.89.74/26",
        v6=None,
        vlan_id=483,
    ),
    xnc=NetworkAddress(
        v4="10.44.88.201/26",
        v6=None,
        vlan_id=481,
    ),
    xnu=NetworkAddress(
        v4="10.44.89.9/26",
        v6=None,
        vlan_id=482,
    ),
    ngc=NetworkAddress(
        v4="10.44.89.137/26",
        v6=None,
        vlan_id=485,
    ),
    ngu=NetworkAddress(
        v4="10.44.89.74/26",
        v6=None,
        vlan_id=483,
    ),
)

_du_1_gnb_1 = DU(_airscale, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], instance_id=51333, global_bts_id=51333
)

_core = RealCore5G(mcc=540, mnc=1)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.173", username="wro5grrm", password="5gpass!1"
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.82", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_2xANDROID_ASIL_ABIP_3xAHLOA_4x4MIMO",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    test_pcs=[_lmp_vm_gnb_1],
    attenuator=_attenuator,
)

__all__ = ["tl"]
