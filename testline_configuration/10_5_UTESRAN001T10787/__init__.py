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
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude, HBTE
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
from taf.config.testline.attenuator import RadioRack
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
    addr="10.56.198.156", username="ute", password="UTE.debian12", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.198.156",
    iperf_path="/usr/bin/",
    port="5001",
)
_appserver = AppServer(_iperf)

ue_config_path = os.path.join(_cfg_dir, "TestData/inseego2.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(stream=f, Loader=yaml.FullLoader)
else:
    ue_config = ""

_site1_pdu = TP(addr="10.108.191.40", port_numbers=[2,4,6])
_attenuator = TopYoung(
    ip_addr="10.56.5.200",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 16)],
    model="TAS16T16-51-120-1S-DES",
)
# 5GRU for classicalBTS for LNBTS10787
_ru_0 = RU(
    ru_hw_group="AZHM",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[4],
    radio_type=RadioTypes.AZHM,
    signal_analyzer=None,
    serial_number="1M213808330",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1, 2]]  # port 20
    ],
)
_ru_1 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="EA203761586",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [4, 7]]
    ],
)
_ru_2_AZHM_ANT1234 = RU(
    ru_hw_group="AZHM",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[2],
    radio_type=RadioTypes.AZHM,
    signal_analyzer=None,
    serial_number="1M213808330",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1]]  # port 20
    ],
)
_ru_3_AZHM_ANT5678 = RU(
    ru_hw_group="AZHM",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[2],
    radio_type=RadioTypes.AZHM,
    signal_analyzer=None,
    serial_number="1M213808330",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [2]]  # port 20
    ],
)
_ru_4_AHEGB_ANT13 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[4],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="EA203761586",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [4]]
    ],
)
_ru_5_AHEGB_ANT24 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[4],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="EA203761586",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [7]]
    ],
)

# DU for classicalBTS LNBTS10787
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIK")  #

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[6],
    hardware_type="ASIL"
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
    rus=[_ru_0, _ru_1, _ru_2_AZHM_ANT1234, _ru_3_AZHM_ANT5678, _ru_4_AHEGB_ANT13, _ru_5_AHEGB_ANT24],
    f1_m_ip_addr="10.56.5.134",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.134",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.134", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.134", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.134",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.134",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.134",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10787, global_bts_id=10787)

# 5GRU for classicalBTS for NRBTS10788
_gnb_pdu_10788 = HBTE(addr="10.108.191.40", port_numbers=[1,3,5])

_ru_10788 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_10788.pdu_ports[3],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="K9184605354",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [3]]
    ],
)
_ru_10788_AZHL = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_10788.pdu_ports[1],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="YK210500033",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [5, 6]]
    ],
)
_ru_10788_AZHL_ANT5678 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_10788.pdu_ports[1],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="YK210500033",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [5]]
    ],
)
_ru_10788_AZHL_ANT1234 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_10788.pdu_ports[1],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="YK210500033",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [6]]
    ],
)

# DU for classicalBTS LNBTS6480
_lmp_connection_10788 = SshServiceDetails(
    addr="10.56.5.135", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_10788 = CapacityUnit(addr="192.168.253.20",
                                    hardware_type="ASIL")  #


_common_unit_10788 = CommonUnit(
    lmp_connection=_lmp_connection_10788,
    capacity_units=[_capacity_unit_10788],
    pdu_port=_gnb_pdu_10788.pdu_ports[5],
    hardware_type="ASIL"
)

_airscale_10788 = Airscale(common_units=[_common_unit_10788])

_ru_cablinks_10788 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_10788, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_10788, label="SFP", port_id=1),
    )
]

_du_10788 = DU(
    airscale=_airscale_10788,
    rus=[_ru_10788, _ru_10788_AZHL, _ru_10788_AZHL_ANT5678, _ru_10788_AZHL_ANT1234],
    f1_m_ip_addr="10.56.5.135",
    cablinks=_ru_cablinks_10788,
)

_cu_10788 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.135",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.135", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.135", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.135",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.135",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.135",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_10788 = ClassicalBts(
    dus=[_du_10788], cu=_cu_10788, instance_id=10788, global_bts_id=10788
)
###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.133", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
_host_10788 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.134", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_10788.dus[0].airscale.common_units[0], ue_config],
)
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host, _host_10788],
    gnbs=[_classical_bts, _classical_bts_10788],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# old version keyword under robotws5g/resource compatibility workaround
