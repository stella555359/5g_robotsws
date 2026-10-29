__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.connection_details import TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, NetworkAddress, RoutingInformation
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude, FPFH
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

_pdu_1 = Gude("10.44.200.34", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.27", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")


_pdus = [_pdu_1, _pdu_2]

# _attenuator_5G = TopYoung(
#     ip_addr="10.71.182.66",
#     port=3000,
#     attenuation_port_numbers=[i for i in range(1, 256)],
#     model="TAS16T16-51-120-1S-DES",
# )

_ru1 = RU(
    ru_hw_group="AVQA",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251900659",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdus[1].pdu_ports[6],
)
_ru2 = RU(
    ru_hw_group="AVQA",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251604439",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdus[0].pdu_ports[7],
)
_ru3 = RU(
    ru_hw_group="AVQA",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251502486",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdus[1].pdu_ports[8],
)
_ru4 = RU(
    ru_hw_group="AHPB",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH251803004",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdus[1].pdu_ports[9],
)
_ru5 = RU(
    ru_hw_group="AHPB",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH251803000",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdus[1].pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213153854",
    rus=[_ru1, _ru2, _ru3, _ru4, _ru5],
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    hardware_type="ASOE",
    pdu_port=_pdus[0].pdu_ports[2],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="10.44.137.29",
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
        v4="10.44.137.84",
        routing=RoutingInformation(
            gateway="10.44.137.65",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.137.148",
        routing=RoutingInformation(gateway="10.44.137.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.137.224",
        routing=RoutingInformation(gateway="10.44.137.193", ip_prefix_length=26),
    ),

)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.206", username="ute", password="uteUTE!"
    ),
    connections=[_common_unit],
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_2xAHPB_3xAVQA",
    ues=[],
    pdus=[_pdus],
    # attenuator=_attenuator_5G,    
)

__all__ = ["tl"]
