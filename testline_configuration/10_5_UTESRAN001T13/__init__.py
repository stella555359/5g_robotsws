import os
import yaml
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.lmi import SerialOverHost,Local
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
# #host VM pc
_host_13 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.54", username="ute", password="ute"
    )
)
_host_529 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.55", username="ute", password="ute"
    )
)
# Downlink Iperf Server
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

# UE configuration
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
# #RealEnb
# _real_enb_pdu = FPFH(addr="10.68.152.231", port_numbers=[3,4,5])
_attenuator = TopYoung(
    ip_addr="10.108.161.38",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 17)],
    model="TAS16T16-51-120-1S-DES",
)

########## LTE RU for Classical LTE BTS LNBTS13 ##########
_ru_1_pdu = FPFH(addr="10.108.161.39", port_numbers=[3])
# _ru_2_pdu = FACOM(addr="10.69.66.178", port_numbers=[5])

# BTS13 RRU_1 AZHA
_ru_0 = RU(
    ru_hw_group="AZHA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="172.16.9.130", username="root", password=""),
    pdu_port=_ru_1_pdu.pdu_ports[3],
    radio_type=RadioTypes.AZHA,
    signal_analyzer=None,
    serial_number="6Q173706877",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [3, 11]  # port 20
    ],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.108.161.40",
                username="csv5-tester",
                password="Nokia123!"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM38"
            )
        ]
    ),
)
# BTS13 RRU_2 FZHM
# _ru_1 = RU(
#     ru_hw_group="FZHM",
#     default_ssh_connection_details=SshServiceDetails(
#         addr="172.16.9.129", username="root", password=""
#     ),
#     lmp_connection=SshServiceDetails(addr="172.16.9.129", username="root", password=""),
#     pdu_port=_ru_2_pdu.pdu_ports[5],
#     radio_type=RadioTypes.FZHM,
#     signal_analyzer=None,
#     serial_number="EA154622350",
#     attenuation_ports=[
#         _attenuator.attenuator_ports[i] for i in [5, 13]  # port 21
#     ],
# )
# [_attenuator.attenuator_ports[1],_attenuator.attenuator_ports[10]]

# DU for classicalBTS LNBTS13
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20", hardware_type="ASIA")  #
_capacity_unit_1 = CapacityUnit(addr="192.168.253.24", hardware_type="ASIA")
_gnb_pdu = FPFH(addr="10.108.161.39", port_numbers=[5])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0, _capacity_unit_1],
    pdu_port=_gnb_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    # ABIA1 Port2 to AZHA Port2
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    ),
    # ABIA2 Port2 to AZHA Port2
    Cablink(
        source=Endpoint(unit=_capacity_unit_1, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=2),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0],
    f1_m_ip_addr="10.108.161.36",
    cablinks=_ru_cablinks,
)

# CU for classicalbts13
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.108.161.36",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.161.36", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.161.36", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.108.161.36",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.108.161.36",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.108.161.36",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
)

# classicalbts13
_classical_bts_13 = ClassicalBts(dus=[_du], cu=_cu, instance_id=13, global_bts_id=13)


################### LTE RU for classicalBTS LNBTS529 ###################
_ru_3_pdu = FPFH(addr="10.108.161.39", port_numbers=[2])
_ru_4_pdu = FPFH(addr="10.108.161.39", port_numbers=[1])

_ru_3 = RU(
    ru_hw_group="FXEB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.10.128", username="root", password=""
    ),
    pdu_port=_ru_3_pdu.pdu_ports[2],
    radio_type=RadioTypes.FXEB,
    signal_analyzer=None,
    serial_number="1M165210243",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [2, 10]]  # port 2 and port 10
    ],
)

_ru_4 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.128", username="root", password=""
    ),
    pdu_port=_ru_4_pdu.pdu_ports[1],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2037V0L4Q",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [5, 13]]  # port 5 and port 13
    ],
)

# DU for classicalBTS LNBTS529
_lmp_connection_529 = SshServiceDetails(
    addr="10.108.161.37", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_529 = CapacityUnit(addr="192.168.253.20", hardware_type="ASIB")  #
_gnb_pdu_529 = FPFH(addr="10.108.161.39", port_numbers=[4])

_common_unit_529 = CommonUnit(
    lmp_connection=_lmp_connection_529,
    capacity_units=[_capacity_unit_529],
    pdu_port=_gnb_pdu_529.pdu_ports[4],
)

_airscale_529 = Airscale(common_units=[_common_unit_529])
# RRU Connection interpretation
_ru_cablinks_529 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_529, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_3, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit_529, label="SFP", port_id=3),
        target=Endpoint(unit=_ru_4, label="SFP", port_id=1),
    )
]

_du_529 = DU(
    airscale=_airscale_529,
    rus=[_ru_3, _ru_4],
    f1_m_ip_addr="10.108.161.37",
    cablinks=_ru_cablinks_529,
)

_cu_529 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.108.161.37",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.161.37", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.161.37", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.108.161.37",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.108.161.37",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.108.161.37",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.161.254", ip_prefix_length=24),
    ),
)

# classicalbts 529
_classical_bts_529 = ClassicalBts(
    dus=[_du_529], cu=_cu_529, instance_id=529, global_bts_id=529
)
# Topology Name
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIAL_ABIAB2_AZHA_FZHM-ASIBR_ABINB1_ABIAB1_FXEB_AHFIB"
)
# _apc_pdu = APC(addr="10.106.212.130", port_numbers=[1])
tl = TestLine(
    test_pc=_host_13,
    test_pcs=[_host_13, _host_529],
    gnbs=[_classical_bts_13, _classical_bts_529],
    tl_cloud_topology=_tl_cloud_topology,
    # enbs=[_lte_real_enb],
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
    # pdus=[_real_enb_pdu, _gnb_pdu_529, _apc_pdu]
)
print(tl)
# old version keyword under robotws5g/resource compatibility workaround
