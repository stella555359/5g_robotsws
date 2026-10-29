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

__maintainer__ = "He,winnie"
__team__ = "NSB MN SRAN PROD IWK HZ GMS "
__email__ = "winnie.he@nokia-sbell.com"
# 2298 is enb site treate as 5g site
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Iperf
# _appserver_ssh = SshServiceDetails(
#     addr="10.108.184.78", username="ute", password="ute", port="50002"
# )
_appserver_ssh = SshServiceDetails(
    addr="10.56.198.157", username="ute", password="UTE.debian12", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.198.157",
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
# _android = Android(
#     ssh_connection_details=SshServiceDetails(
#         addr="10.70.14.235", username="feat3", password="Nokia@123"
#     ),
#     serial_number="e7983f30",
#     # server_dir='/cygdrive/c/pyro_server',
#     server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.96---07141439/Pioneer.exe",
#     python_path="/cygdrive/c/Python27/python.exe",
#     qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
#     diag_cfg_path="C:/pyro_server/DIAG.cfg",
#     iperf_details=_iperf,
#     capabilities=["RRM3_S20", "Commercial"]
#     # capabilities=['RRM3_S20', 'huawei_sigspark']
# )
# PDU info
_2298_pdu_1 = FPFH(addr="10.106.253.244", port_numbers=[1,2,3,4])
_2298_pdu_2 = FPFH(addr="10.106.253.245", port_numbers=[1,2,3,4,5])
_2298_pdu_3 = FPFH(addr="10.106.253.246", port_numbers=[1,2,3,4,5])
# #RealEnb
_attenuator = TopYoung(
    ip_addr="10.56.5.205",
    port=3000,
    attenuation_port_numbers=[i for i in range(257)],
    model="TAS32B8-51-120-1N-DES",
)

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_2298_pdu_2.pdu_ports[5],
    hardware_type="ASIL"
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# 5GRU for classicalBTS for LNBTS2298
# _ru_1_2_3_pdu = FPFH(addr="10.106.212.151", port_numbers=[1, 2, 3, 4, 5, 6])
# _ru_0_pdu = FPFH(addr="10.106.212.151", port_numbers=[3])
_ru_0 = RU(
    ru_hw_group="FRPA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="172.16.8.129", username="root", password=""),
    pdu_port=_2298_pdu_3.pdu_ports[2],
    radio_type=RadioTypes.FRPA,
    signal_analyzer=None,
    serial_number="EA170510027",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [81, 90]]  # port 11,12
    ],
)
_ru_1 = RU(
    ru_hw_group="FRHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.131", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="172.16.8.131", username="root", password=""),
    pdu_port=_2298_pdu_3.pdu_ports[4],
    radio_type=RadioTypes.FRHF,
    signal_analyzer=None,
    serial_number="F7170254737",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1, 10]]  # port 21
    ],
)
_ru_2 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="172.16.8.128", username="root", password=""),
    pdu_port=_2298_pdu_1.pdu_ports[4],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="K9184444675",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [17, 26, 33, 42]]  # old 17,26,35,44 port 3,4,5,6
    ],
)
_ru_3 = RU(
    ru_hw_group="FRHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_2298_pdu_2.pdu_ports[1],
    radio_type=RadioTypes.FRHF,
    signal_analyzer=None,
    serial_number="F7162822033",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [49, 58]]  # port 29
    ],
)
_ru_2_cell_2 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="172.16.8.128", username="root", password=""),
    pdu_port=_2298_pdu_1.pdu_ports[4],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="K9184444675",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [17, 26]]  # port 3,4
    ],
)
_ru_2_cell_3 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="172.16.8.128", username="root", password=""),
    pdu_port=_2298_pdu_1.pdu_ports[4],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="K9184444675",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [33, 42]]  # port 28
    ],
)
# DU for classicalBTS LNBTS6231
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20", hardware_type="ASIB")

_gnb_pdu = FPFH(addr="10.68.152.231", port_numbers=[4])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_gnb_pdu.pdu_ports[4],
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
    rus=[_ru_0, _ru_1, _ru_2, _ru_3, _ru_2_cell_2, _ru_2_cell_3],
    f1_m_ip_addr="10.56.5.156",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.156",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.156", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.156", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.156",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.156",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.156",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=2298, global_bts_id=2298)

# 5GRU for classicalBTS for NRBTS11053
_ru_11053_pdu = FACOM(addr="10.106.253.242", port_numbers=[3])

_ru_11053 = RU(
    ru_hw_group="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_ru_11053_pdu.pdu_ports[3],
    radio_type=RadioTypes.AEQE,
    signal_analyzer=None,
    serial_number="1M203225045",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [65, 74]]  # port 9,10
    ],
)

# DU for classicalBTS LNBTS11053
_lmp_connection_11053 = SshServiceDetails(
    addr="10.56.5.159", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_11053 = CapacityUnit(addr="192.168.253.20", hardware_type="ASIB")
_gnb_pdu_11053 = FPFH(addr="10.106.253.246", port_numbers=[3])

_common_unit_11053 = CommonUnit(
    lmp_connection=_lmp_connection_11053,
    capacity_units=[_capacity_unit_11053],
    pdu_port=_2298_pdu_3.pdu_ports[3],
    hardware_type="ASIB"
)

_airscale_11053 = Airscale(common_units=[_common_unit_11053])

_ru_cablinks_11053 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_11053, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_11053, label="SFP", port_id=1),
    )
]

_du_11053 = DU(
    airscale=_airscale_11053,
    rus=[_ru_11053],
    f1_m_ip_addr="10.56.5.159",
    cablinks=_ru_cablinks_11053,
)

_cu_11053 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.159",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.159", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.159", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.159",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.159",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.159",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts_11053 = ClassicalBts(
    dus=[_du_11053], cu=_cu_11053, instance_id=11053, global_bts_id=11053
)
############## classical bts BTS10768 ####################
#   update by winnie
# RU for classicalBTS for LTE BTS10768
# _ru_10768_pdu = FPFH(addr="10.106.212.151", port_numbers=[2])
_ru_10768_pdu_2 = FPFH(addr="10.68.152.232", port_numbers=[1, 2, 3])

_ru_10768 = RU(
    ru_hw_group="FXED",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_3.pdu_ports[1],
    radio_type=RadioTypes.FXED,
    signal_analyzer=None,
    serial_number="F7171115252",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [97, 106]]  # port 13,14
    ],
)
_ru_10768_AHEGB_CELL1 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_1.pdu_ports[2],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="EA203761399",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [145]]  # port 19
    ],
)
_ru_10768_AHEGB_Cell3 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_1.pdu_ports[2],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="EA203761399",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [153]]  # port 20
    ],
)
_ru_10768_AHPF_Cell28 = RU(
    ru_hw_group="AHPF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_1.pdu_ports[3],
    radio_type=RadioTypes.AHPF,
    signal_analyzer=None,
    serial_number="EA211155291",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [161]]  # port 21
    ],
)
_ru_10768_AHEGC_Cell11 = RU(
    ru_hw_group="AHEGC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_2.pdu_ports[2],
    radio_type=RadioTypes.AHEGC,
    signal_analyzer=None,
    serial_number="EA215152998",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [169]]  # port 22
    ],
)
_ru_10768_AHEGC_Cell31 = RU(
    ru_hw_group="AHEGC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_2.pdu_ports[2],
    radio_type=RadioTypes.AHEGC,
    signal_analyzer=None,
    serial_number="EA215152998",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [177]]  # port 23
    ],
)
# DU for classicalBTS LTE BTS10768
_lmp_connection_10768 = SshServiceDetails(
    addr="10.56.5.158", username="toor4nsn", password="oZPS0POrRieRtu"
)
_lmp_connection_10768_2 = SshServiceDetails(
    addr="10.69.221.46 ", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit_10768 = CapacityUnit(addr="192.168.253.20",
                                    hardware_type="ASIB")  #
_gnb_pdu_10768 = FPFH(addr="10.68.152.231", port_numbers=[3])

_common_unit_10768 = CommonUnit(
    lmp_connection=_lmp_connection_10768,
    capacity_units=[_capacity_unit_10768],
    pdu_port=_gnb_pdu_10768.pdu_ports[3],
    hardware_type="ASIB"
)
_common_unit_10768_2 = CommonUnit(
    lmp_connection=_lmp_connection_10768_2,
    capacity_units=[_capacity_unit_10768],
    pdu_port=_gnb_pdu_10768.pdu_ports[3],
    hardware_type="ASIB"
)
_airscale_10768 = Airscale(common_units=[_common_unit_10768, _common_unit_10768_2])

_ru_cablinks_10768 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_10768, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_10768, label="SFP", port_id=1),
    )
]

_du_10768 = DU(
    airscale=_airscale_10768,
    rus=[_ru_10768, _ru_10768_AHEGB_CELL1,
         _ru_10768_AHEGB_Cell3,
         _ru_10768_AHPF_Cell28,
         _ru_10768_AHEGC_Cell11,
         _ru_10768_AHEGC_Cell31],
    f1_m_ip_addr="10.56.5.158",
    cablinks=_ru_cablinks_10768,
)

_cu_10768 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.158",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.158", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.158", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.158",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.158",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.158",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
)
# classicalbts
_classical_bts_10768 = ClassicalBts(
    dus=[_du_10768], cu=_cu_10768, instance_id=10768, global_bts_id=10768
)
### classical bts BTS11359
# RU  for classicalBTS for LTE BTS11359
# _ru_11359_pdu = FPFH(addr="10.106.212.151", port_numbers=[1])

_ru_11359_cell28 = RU(
    ru_hw_group="AHPF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_2.pdu_ports[3],
    radio_type=RadioTypes.AHPF,
    signal_analyzer=None,
    serial_number="EA211155343",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [113, 122]]  # port 2
    ],
)
_ru_11359_cell29 = RU(
    ru_hw_group="AHPF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.48.166", username="root", password=""
    ),
    pdu_port=_2298_pdu_2.pdu_ports[3],
    radio_type=RadioTypes.AHPF,
    signal_analyzer=None,
    serial_number="EA211155343",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [129, 138]]  # port 2
    ],
)

# DU for classicalBTS LTE BTS10768
_lmp_connection_11359 = SshServiceDetails(
    addr="10.56.5.157", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_11359 = CapacityUnit(addr="192.168.253.20", hardware_type="ASIB")
# _gnb_pdu_11359 = FPFH(addr="10.68.152.231", port_numbers=[5])

_common_unit_11359 = CommonUnit(
    lmp_connection=_lmp_connection_11359,
    capacity_units=[_capacity_unit_11359],
    pdu_port=_2298_pdu_2.pdu_ports[4],
    hardware_type="ASIB"
)

_airscale_11359 = Airscale(common_units=[_common_unit_11359])

_ru_cablinks_11359 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_11359, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_11359_cell28, label="SFP", port_id=1),
    )
]

_du_11359 = DU(
    airscale=_airscale_11359,
    rus=[_ru_11359_cell28, _ru_11359_cell29],
    f1_m_ip_addr="10.56.5.157",
    cablinks=_ru_cablinks_11359,
)

_cu_11359 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.157",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.157", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.157", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.157",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.157",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.157",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts_11359 = ClassicalBts(
    dus=[_du_11359], cu=_cu_11359, instance_id=11359, global_bts_id=11359
)
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.144", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
_host_11053 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.145", username="ute", password="ute"
    ),
    connections=[_classical_bts_11053.dus[0].airscale.common_units[0], ue_config],
)
_host_10768 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.146", username="ute", password="ute"
    ),
    connections=[_classical_bts_10768.dus[0].airscale.common_units[0], ue_config],
)
_host_11359 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.147", username="ute", password="ute"
    ),
    connections=[_classical_bts_11359.dus[0].airscale.common_units[0], ue_config],
)
_apc_pdu = APC(addr="10.106.212.130", port_numbers=[1])
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host, _host_11053, _host_10768, _host_11359],
    gnbs=[_classical_bts, _classical_bts_11053, _classical_bts_10768, _classical_bts_11359],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    core=RealCore(mcc=262, mnc=3),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
    pdus=[_2298_pdu_1, _gnb_pdu_11053, _apc_pdu]
)
print(tl)
# old version keyword under robotws5g/resource compatibility workaround
