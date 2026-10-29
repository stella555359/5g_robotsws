__maintainer__ = "Jim.3.Liu"
__team__ = "NSB MN SRAN Prod HZH RRM 3 Vrf"
__email__ = "jim.3.liu@nokia-sbell.com"

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

##pdus
_pdu1 = FPFH(
    port_numbers=[1,2,3,4,5,6],
    addr="10.56.202.131",
    login="admin",
    password="admin",
)

_pdu2 = FPFH(
    port_numbers=[1,2,3,4,5,6],
    addr="10.56.202.140",
    login="admin",
    password="admin",
)

_pdus = [_pdu1, _pdu2]

## attenuator
_attenuator_5G = TopYoung (
    ip_addr="10.56.202.130",
    port=1000,
    attenuation_port_numbers=[i for i in range(1,256)],
    model="TAS32B8-34-60-1N-DES",
)

# 5GRU for classicalBTS
_rus0 = RU(
    ru_hw_group="AQQJ",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw="
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="root", password="k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw="
    ),
    pdu_port=_pdus[1].pdu_ports[2],
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ235190490",
)

_rus1 = RU(
    ru_hw_group="AHPJ",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw="
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="root", password="k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw="
    ),
    pdu_port=_pdus[1].pdu_ports[3],
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232904929",
)
## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
)

_capacity_unit = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1214912278",
    rus=[_rus0, _rus1],
)

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    hardware_type="ASIL",
    capacity_units=[_capacity_unit],
    pdu_port=_pdus[0].pdu_ports[3],
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(_airscale)

_cu = CU(
    backhaul_site_oam_ip="10.56.202.194",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.202.194", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.202.194", username="Nemuadmin", password="nemuuser"
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=11283, global_bts_id=11283)

# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.202.182", username="ute", password="UTE.debian12"
    ),
    connections=[_common_unit_0],
)

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_AQQY_AKNB_AHPDA_AHEGHA",
    ues=[],
    pdus=[_pdus],
    attenuator=_attenuator_5G,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
tl_ultracaller = os.path.join(_CFG_DIR)
 
__all__ = ["tl"]
