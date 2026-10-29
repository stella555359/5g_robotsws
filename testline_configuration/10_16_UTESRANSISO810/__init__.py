__maintainer__ = "Magda Bielska"
__team__ = "MN RAN RD VRF WRO3 7"
__email__ = "magdalena.bielska@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

__all__ = ["tl"]

_pdu_gnbs = Gude(addr="10.42.168.168", port_numbers=[4, 3], model="EPC", version="8220-1")
_pdu_rus_2 = Gude(addr="10.42.168.74", port_numbers=[5],model="EPC", version="8220-1")
_pdu_rus_3 = Gude(addr="10.42.169.88", port_numbers=[1, 2, 3, 4, 5, 6, 7], model="EPC", version="8220-1")
_pdu_rus_4 = Gude(addr="10.42.169.63", port_numbers=[8, 9], model="EPC", version="8220-1")


ahpmdg_ru_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2344C66RY",
    pdu_port=_pdu_rus_4.pdu_ports[8],
)
ahpmdg_ru_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2343C66BB",
    pdu_port=_pdu_rus_3.pdu_ports[2],
)
ahpmdg_ru_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2344C66NX",
    pdu_port=_pdu_rus_3.pdu_ports[1],
)
ahegg_ru_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="RW232200990",
    pdu_port=_pdu_rus_3.pdu_ports[6],
)
ahegg_ru_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="K9252214053",
    pdu_port=_pdu_rus_3.pdu_ports[7],
)
ahegg_ru_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="RW232200991",
    pdu_port=_pdu_rus_4.pdu_ports[9],
)
avqq_ru_7 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQQ",
    serial_number="1M242100044",
    pdu_port=_pdu_rus_3.pdu_ports[3],
)
aeqq_ru_8 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AEQQ",
    serial_number="1M221913335",
    pdu_port=_pdu_rus_3.pdu_ports[4],
)
aeqq_ru_9 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AEQQ",
    serial_number="1M220620980",
    pdu_port=_pdu_rus_3.pdu_ports[5],
)
arda_ru_10 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARDA",
    serial_number="K9203323102",
    pdu_port=_pdu_rus_2.pdu_ports[5],
)


_abio_1_primary = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204806013",
    rus=[avqq_ru_7, aeqq_ru_8, aeqq_ru_9],
)

_abio_2_primary = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204703440",
    rus=[ahpmdg_ru_1, ahpmdg_ru_2, ahpmdg_ru_3],
)

_abia_3_primary = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="A102",
    serial_number="L1163607861",
    rus=[ahegg_ru_4, ahegg_ru_5, ahegg_ru_6],
)

abia_4_secondary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="A104",
    serial_number="DH195290546",
    rus=[arda_ru_10],
)

_asib_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_primary, _abio_2_primary, _abia_3_primary],
    pdu_port=_pdu_gnbs.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A101",
    serial_number="L1182811228",
)

_asia_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[abia_4_secondary],
    pdu_port=_pdu_gnbs.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A101",
    serial_number="L1163201126",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_primary, _asia_gnb_secondary])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[ahpmdg_ru_1, ahpmdg_ru_2, ahpmdg_ru_3,
                                   ahegg_ru_4, ahegg_ru_5, ahegg_ru_6,
                                   avqq_ru_7, aeqq_ru_8, aeqq_ru_9,
                                   arda_ru_10],
)

_cu_gnb = CU(
    backhaul_site_oam_ip="10.42.175.66",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", #port=443
    ),
)


_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=1318)

# _lmp_vm_gnb_primary = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.42.184.47", username="ute", password="ute"
#     ),
#     connections=[_asib_gnb_primary],
# )

# _lmp_vm_gnb_secondary = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.42.184.46", username="ute", password="ute"
#     ),
#     connections=[_asia_gnb_secondary],
# )

_lmp_vm_gnb_secondary = TestPc(
    SshServiceDetails(addr="10.42.184.47", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_asia_gnb_secondary,
            interface_type="lmp",
        ),
    ],
)

_lmp_vm_gnb_primary = TestPc(
    SshServiceDetails(addr="10.42.184.46", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_asib_gnb_primary,
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    host_ip="10.42.184.46",
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    tl_cloud_topology='''WITHOUT_EE.xml''',
    pdus=[_pdu_gnbs, _pdu_rus_2, _pdu_rus_3, _pdu_rus_4],
)
