__maintainer__ = "henry.1.wang@nokia-sbell.com"
__email__ = "amaand.li@nokia-sbell.com"
__owner_email__ = "amaand.li@nokia-sbell.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import Gude, TopYoung, FACOM, HBTE
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.radio import RadioTypes

_pdu_1 = HBTE(
    addr="10.56.201.130",
    port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
    ],
)
_pdu_2 = HBTE(
    addr="10.56.201.131",
    port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
    ],
)
_pdus = [_pdu_1, _pdu_2]
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password=""
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    ru_hw_group="",
    serial_number="EA151930038",
    radio_type=RadioTypes.FRGY,
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password=""
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    ru_hw_group="",
    serial_number="L9143300308",
    radio_type=RadioTypes.FRGY,
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.10", username="root", password=""
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    ru_hw_group="",
    serial_number="L1144804634",
    radio_type=RadioTypes.FRGY,
)

_fbbc_1 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA163322583",
)

_fsfm = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fbbc_1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7163132977",
)

_smod_1 = Flexi([_fsfm])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.201.132",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
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
    tracing=None,
)


_du = DU(
    airscale=_smod_1,
    rus=[
        _ru_1,
        _ru_2,
        _ru_3,
    ],
)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=10737, instance_id=10737)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.165", username="ute", password="uteUTE!"
    ),
    connections=[_cbts],
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_LW_FSMF_FBBC_3xFRGY",
    pdus=_pdus,
)

__all__ = ["tl"]
