import os
import yaml
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import DU
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude, HBTE, FPFH
from taf.config.testline.pdu import TopYoung as TP
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    Android,
    Qualcomm,
    QualcommUeType,
)
from taf.config.testline.enb import (
    Enb,
    SimEnb,
    RealEnb,
    LTEEmuEnb,
    PrismaEnb,
    DocomoEnb,
)

# added in taf.meta 5.4
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.gnb.networkaddress import NetworkAddress  # add in taf.meta 5.4
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)

# from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE as HB
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "I_HAZ1_RRM7_CODER_TEAM@internal.nsn.com"
__team__ = "NSB MN SRAN PROD IWK HZ GMS "
__email__ = "I_HAZ1_RRM7_CODER_TEAM@internal.nsn.com"
# 10787 is enb site treate as 5g site
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Iperf
# _appserver_ssh = SshServiceDetails(
#     addr="10.108.184.78", username="ute", password="ute", port="50002"
# )
_appserver_ssh = SshServiceDetails(
    addr="10.56.221.13", username="ute", password="ute", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.221.13",
    iperf_path="/usr/bin/",
    port="50002",
)
_appserver = AppServer(_iperf)

ue_config_path = os.path.join(_cfg_dir, "TestData/inseego2.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(stream=f, Loader=yaml.FullLoader)
else:
    ue_config = ""


_site1_pdu = HBTE(addr="10.108.233.188", port_numbers=[1, 8])
_site1_pdu_2 = HBTE(addr="10.108.233.194", port_numbers=[1, 2])
_site1_pdu_3 = HBTE(addr="10.108.233.187", port_numbers=[1])
_site2_pdu = FACOM(addr="10.108.233.176", port_numbers=[1, 2, 3, 4])
_site2_pdu_2 = HBTE(addr="10.108.233.175", port_numbers=[3])

_attenuator = TopYoung(
    ip_addr="10.56.5.201",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 257)],
    model="32*8"
)
# 5GRU for classicalBTS for LNBTS6090
_ru_0 = RU(
    ru_hw_group="AZQP",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_3.pdu_ports[1],
    radio_type=RadioTypes.AZQP,
    signal_analyzer=None,
    serial_number="1M203439981",
    attenuation_ports=[
        # 25,26,27,28
        _attenuator.attenuator_ports[i] for i in [197, 206, 215, 224]
    ],
)
_ru_1 = RU(
    ru_hw_group="AZQS",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_2.pdu_ports[2],
    radio_type=RadioTypes.AZQS,
    signal_analyzer=None,
    serial_number="1M212807074",
    attenuation_ports=[
        # 29, 30, 31, 32
        _attenuator.attenuator_ports[i] for i in [229, 238, 247, 256]
    ],
)
_ru_2 = RU(
    ru_hw_group="FHEL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_2.pdu_ports[1],
    radio_type=RadioTypes.FHEL,
    signal_analyzer=None,
    serial_number="6Q175002447",
    attenuation_ports=[
        # 17,18
        _attenuator.attenuator_ports[i] for i in [i for i in [133, 142]]
    ],
)

# DU for classicalBTS LNBTS6090
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIB")  #

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[8],
    hardware_type="ASIB"
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0, _ru_1, _ru_2],
    f1_m_ip_addr="192.168.255.129",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip="10.56.5.141",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.141", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.141", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.69.221.34", vlan_id=112),
    x2u=NetworkAddress(v4="10.69.221.34", vlan_id=112),
    s1u=NetworkAddress(v4="10.69.221.34", vlan_id=112),
)

# classicalbts
_classical_bts = ClassicalBts(
    dus=[_du],
    cu=_cu,
    instance_id=6090,
    global_bts_id=6090)


# 5GRU for classicalBTS for LNBTS6091
_ru_FHDB = RU(
    ru_hw_group="FHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site2_pdu.pdu_ports[2],
    radio_type=RadioTypes.FHDB,
    signal_analyzer=None,
    serial_number="L1125013332",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [181, 190]  # 23,24
    ],
)
_ru_FHDB_1 = RU(
    ru_hw_group="FHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site2_pdu.pdu_ports[3],
    radio_type=RadioTypes.FHDB,
    signal_analyzer=None,
    serial_number="1M163350500"
)
_ru_FHDB_2 = RU(
    ru_hw_group="FHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site2_pdu.pdu_ports[4],
    radio_type=RadioTypes.FHDB,
    signal_analyzer=None,
    serial_number="1M181001221",

)
_ru_AZQS_3 = RU(
    ru_hw_group="AZQS",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site2_pdu_2.pdu_ports[3],
    radio_type=RadioTypes.AZQS,
    signal_analyzer=None,
    serial_number="1M212807056",
    attenuation_ports=[
        # 19,20,21,22
        _attenuator.attenuator_ports[i] for i in [149, 158, 167, 176]
    ],
)
# DU for classicalBTS LNBTS6091
_lmp_connection_6091 = SshServiceDetails(
    addr="10.56.5.142", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6091 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIB")  #

_common_unit_6091 = CommonUnit(
    lmp_connection=_lmp_connection_6091,
    capacity_units=[_capacity_unit_6091],
    pdu_port=_site1_pdu.pdu_ports[1],
    hardware_type="ASIB"
)

_airscale_6091 = Airscale(common_units=[_common_unit_6091])

_ru_cablinks_6091 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6091, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_FHDB, label="SFP", port_id=1),
    )
]

_du_6091 = DU(
    airscale=_airscale_6091,
    rus=[_ru_FHDB, _ru_AZQS_3],
    f1_m_ip_addr="10.56.5.142",
    cablinks=_ru_cablinks_6091,
)

_cu_6091 = CU(
    backhaul_site_oam_ip="10.56.5.142",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.142", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.142", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.69.221.38", vlan_id=113),
    x2u=NetworkAddress(v4="10.69.221.38", vlan_id=113),
    s1u=NetworkAddress(v4="10.69.221.38", vlan_id=113),
)

# classicalbts
_classical_bts_6091 = ClassicalBts(
    dus=[_du_6091],
    cu=_cu_6091,
    instance_id=6091,
    global_bts_id=6091)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.142", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config]
)
_host_6091 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.143", username="ute", password="ute"
    ),
    connections=[
        _classical_bts_6091.dus[0].airscale.common_units[0],
        ue_config]
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_ASIBR_ABIO_ABIA_AZQP_AZQS_FHEL_FRCJ-ASIBR_ABIO2_FHDB3_AZQS"
)

tl = TestLine(
    test_pc=_host,
    test_pcs=[_host, _host_6091],
    gnbs=[_classical_bts, _classical_bts_6091],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# print(tl)
# old version keyword under robotws5g/resource compatibility workaround
