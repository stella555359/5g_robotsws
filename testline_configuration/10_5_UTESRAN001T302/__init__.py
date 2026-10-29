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
# 6093 is enb site treate as 5g site
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Iperf
# _appserver_ssh = SshServiceDetails(
#     addr="10.108.184.78", username="ute", password="ute", port="50002"
# )
_appserver_ssh = SshServiceDetails(
    addr="10.56.198.156", username="ute", password="UTE.debian12", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.198.156",
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
# #RealEnb#
_real_enb_pdu = FPFH(addr="10.108.191.55", port_numbers=[1,2])
_attenuator = TopYoung(
    ip_addr="10.56.218.8",
    port=1000,
    attenuation_port_numbers=[i for i in range(1, 128)],
    model="TAS16T16-51-120-1S-DES",
)

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[1],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# 5GRU for classicalBTS for LNBTS302
_ru_pdu_AHFII_AZHL_AHLOA_AHLOA = FPFH(addr="10.108.191.55", port_numbers=[3, 4, 5, 6])
_ru_pdu_AHFII_AZHL_AHFII_AVQQA_AHLOA = FPFH(addr="10.108.191.56", port_numbers=[2, 3, 4, 5, 6])

_ru_AZHL_U1 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHLOA_AHLOA.pdu_ports[4],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="AH230200736",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [81, 82, 83, 84, 89, 90, 91, 92]]
    ],
)
_ru_AZHL_U2 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHFII_AVQQA_AHLOA.pdu_ports[3],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="AH211900790",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [97, 98, 99, 100, 105, 106, 107, 108]]
    ],
)
_ru_AHLOA_U1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHLOA_AHLOA.pdu_ports[5],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2114G1A80",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [1, 2, 3, 4, 9, 10, 11, 12]]
    ],
)
_ru_AHLOA_U2 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHFII_AVQQA_AHLOA.pdu_ports[6],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2116G1CFC",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [17, 18, 19, 20, 25, 26, 27, 28]]
    ],
)
_ru_AHLOA_U3 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHLOA_AHLOA.pdu_ports[6],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2116G1CH1",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [1, 2, 3, 4, 9, 10, 11, 12]]
    ],
)
_ru_AVQQA_U1 = RU(
    ru_hw_group="AVQQA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHFII_AVQQA_AHLOA.pdu_ports[5],
    radio_type=RadioTypes.AVQQA,
    signal_analyzer=None,
    serial_number="L1244002019",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [113, 114, 115, 116, 121, 122, 123, 124]]
    ],
)
_ru_AHFII_U1 = RU(
    ru_hw_group="AHFII",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHFII_AVQQA_AHLOA.pdu_ports[4],
    radio_type=RadioTypes.AHFII,
    signal_analyzer=None,
    serial_number="K9244348183",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [33, 34, 35, 36, 41, 42, 43, 44]]
    ],
)
_ru_AHFII_U2 = RU(
    ru_hw_group="AHFII",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHLOA_AHLOA.pdu_ports[3],
    radio_type=RadioTypes.AHFII,
    signal_analyzer=None,
    serial_number="K9244348175",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [49, 50, 51, 52, 57, 58, 59, 60]]
    ],
)
_ru_AHFII_U3 = RU(
    ru_hw_group="AHFII",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFII_AZHL_AHFII_AVQQA_AHLOA.pdu_ports[2],
    radio_type=RadioTypes.AHFII,
    signal_analyzer=None,
    serial_number="K9244348170",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [65, 66, 67, 68, 73, 74, 75, 76]]
    ],
)
# DU for classicalBTS LNBTS6093
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_lmp_connection_6093 = SshServiceDetails(
    addr="10.106.230.24", username="toor4nsn", password="oZPS0POrRieRtu"
)


_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIL")  #

_capacity_unit_6093 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIL")
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_real_enb_pdu.pdu_ports[1],
    hardware_type="ASIL"
)

_common_unit_6093 = CommonUnit(
    lmp_connection=_lmp_connection_6093,
    capacity_units=[_capacity_unit_6093],
    pdu_port=_real_enb_pdu.pdu_ports[2],
    hardware_type="ASIL"
)

_airscale = Airscale(common_units=[_common_unit_0])
_airscale_6093 = Airscale(common_units=[_common_unit_6093])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AHLOA_U1, label="SFP", port_id=1),
    )
]

_ru_cablinks_6093 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6093, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AHLOA_U1, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_AHLOA_U1, _ru_AHLOA_U2, _ru_AHLOA_U3, _ru_AZHL_U1, _ru_AZHL_U2, _ru_AVQQA_U1, _ru_AHFII_U1, _ru_AHFII_U2, _ru_AHFII_U3],
    f1_m_ip_addr="10.106.230.23",
    cablinks=_ru_cablinks,
)

_du_6093 = DU(
    airscale=_airscale_6093,
    rus=[_ru_AHLOA_U1, _ru_AHLOA_U1],
    f1_m_ip_addr="10.106.230.24",
    cablinks=_ru_cablinks_6093,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.230.23",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.23", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.230.23", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.230.23",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.230.23",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.230.23",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
)

_cu_6093 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.230.24",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.24", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.230.24", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.230.24",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.230.24",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.230.24",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.1", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=302, global_bts_id=302)

_classical_bts_6093 = ClassicalBts(
    dus=[_du_6093], cu=_cu_6093, instance_id=6093, global_bts_id=6093
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROID_ASIMR_ABIP_ABIO_ABIQ_AHLOA_AHLOA_AZHL_AVQQA"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.59", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)

# host LTE VM PC
_host_6093 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.60", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_6093.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    core=RealCore(mcc=262, mnc=3),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
print(tl)
# old version keyword under robotws5g/resource compatibility workaround