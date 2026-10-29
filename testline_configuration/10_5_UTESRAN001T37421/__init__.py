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
    addr="10.21.41.122", username="ute", password="UTE.debian12", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.21.41.122",
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

_site1_pdu = FACOM(addr="10.108.233.188", port_numbers=[3,4])
_site1_pdu_rru = HBTE(addr="10.108.233.187", port_numbers=[4,5,6,3,2])
_site1_pdu_rru_2 = FACOM(addr="10.108.233.132", port_numbers=[4])
_attenuator = TopYoung(
    ip_addr="10.108.233.189",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 257)],
    model="32*8"
)
# 5GRU for classicalBTS for LNBTS6142
_ru_0 = RU(
    ru_hw_group="AHEGC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[4],
    radio_type=RadioTypes.AHEGC,
    signal_analyzer=None,
    serial_number="EA212253513",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1]]  # port 20
    ],
)
_ru_1 = RU(
    ru_hw_group="AHEGC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[5],
    radio_type=RadioTypes.AHEGC,
    signal_analyzer=None,
    serial_number="EA212253494",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [9]]  # port 20
    ],
)
_ru_2 = RU(
    ru_hw_group="AHEGC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[6],
    radio_type=RadioTypes.AHEGC,
    signal_analyzer=None,
    serial_number="EA212253509",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1,2]]  # to do
    ],
)
_ru_3 = RU(
    ru_hw_group="AEQB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[3],
    radio_type=RadioTypes.AEQB,
    signal_analyzer=None,
    serial_number="1M200711507",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [65,74,92]]
    ],
)
_ru_4 = RU(
    ru_hw_group="AEQB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[2],
    radio_type=RadioTypes.AEQB,
    signal_analyzer=None,
    serial_number="1M195002711",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [97,106,124]]
    ],
)
_ru_5 = RU(
    ru_hw_group="AEQB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[4],
    radio_type=RadioTypes.AEQB,
    signal_analyzer=None,
    serial_number="1M201109181",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [83]] # to do 
    ],
)
# DU for classicalBTS LNBTS6483
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIK")  #

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[3],
    hardware_type="ASIK"
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
    rus=[_ru_0,_ru_1,_ru_3,_ru_4],
    f1_m_ip_addr="192.168.255.129",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.108.233.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.108.233.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.222", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.108.233.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.222", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.108.233.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=6142, global_bts_id=6142)

# 5GRU for classicalBTS for NRBTS6141


# DU for classicalBTS LNBTS6141
_lmp_connection_6141 = SshServiceDetails(
    addr="10.69.71.97", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6141 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIK")  #


_common_unit_6141 = CommonUnit(
    lmp_connection=_lmp_connection_6141,
    capacity_units=[_capacity_unit_6141],
    pdu_port=_site1_pdu.pdu_ports[4],
    hardware_type="ASIA"
)

_airscale_6141 = Airscale(common_units=[_common_unit_6141])

_du_6141 = DU(
    airscale=_airscale_6141,
    rus=[_ru_0,_ru_1],
    f1_m_ip_addr="10.69.71.97",
)

_cu_6141 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.69.71.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.71.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.71.212", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.71.212", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.69.71.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.71.222", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.69.71.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.71.222", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.69.71.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.71.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_6141 = ClassicalBts(
    dus=[_du_6141], cu=_cu_6141, instance_id=6141, global_bts_id=6141
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_RFS_ASIK_ABIL3_AHEGC3_AEQB3-ASIA_ABIA"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.141", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# old version keyword under robotws5g/resource compatibility workaround
