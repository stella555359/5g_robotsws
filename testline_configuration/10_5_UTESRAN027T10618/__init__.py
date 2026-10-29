__maintainer__ = "NSB MN RAN RD VRF HAZ1 1"
__team__ = "NSB MN RAN RD VRF HAZ1 1"
__email__ = "i_nsb_mn_ran_rd_vrf_haz1_2@internal.nsn.com"
__owner_email__ = "anan.liu@nokia-sbell.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.connection_details import TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude, FPFH
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

_pdu = FPFH(
    port_numbers=[1, 2, 3, 4, 5, 6],
    addr="10.108.191.130",
    login="admin",
    password="admin",
)

_pdus = [_pdu]

_attenuator_5G = TopYoung(
    ip_addr="10.71.182.66",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 256)],
    model="TAS16T16-51-120-1S-DES",
)

_rru1 = RU(
    ru_hw_group="AVQA",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251502449",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdus[0].pdu_ports[4],
)
_rru2 = RU(
    ru_hw_group="AVQA",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251502446",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdus[0].pdu_ports[5],
)
_rru3 = RU(
    ru_hw_group="AVQA",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251502453",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdus[0].pdu_ports[6],
)
_rru4 = RU(
    ru_hw_group="AHPB",
    radio_type=RadioTypes.AHPB.value,
    serial_number="K9203716627",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdus[0].pdu_ports[2],
)
_rru5 = RU(
    ru_hw_group="AHPB",
    radio_type=RadioTypes.AHPB.value,
    serial_number="K9201111420",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdus[0].pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ASOE",
    hardware_version="475587A.103",
    serial_number="DH224605562",
    rus=[_rru1, _rru2, _rru3, _rru4, _rru5],
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    hardware_type="ASOE",
    pdu_port=_pdus[0].pdu_ports[1],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="10.71.182.130",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.71.182.130",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.71.182.130",
        username="Nemuadmin",
        password="nemuuser",
    ),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.63", username="ute", password="uteUTE!"
    ),
    connections=[_common_unit],
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_RJIO_ASOE_2xAHPB+3xAVQA",
    ues=[],
    pdus=[_pdus],
    attenuator=_attenuator_5G,    
)

__all__ = ["tl"]
