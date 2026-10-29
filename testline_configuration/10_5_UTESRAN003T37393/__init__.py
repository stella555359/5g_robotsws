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
from taf.config.testline.pdu import HBTE, FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude
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
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "Yang, Mengli"
__team__ = "NSB MN SRAN Prod HZH RRM 3 Vrf"
__email__ = "mengli.yang@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.57", username="ute", password="ute"
    )
)

# Iperf

_appserver_ssh = SshServiceDetails(
    addr="10.56.5.56", username="ute", password="ute", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.243.149",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)

ue_config_path2 = os.path.join(_cfg_dir, "TestData/mifi.yml")
if os.path.isfile(ue_config_path2):
    with open(ue_config_path2) as f:
        ue_config2 = yaml.load(f, Loader=yaml.Loader)
else:
    ue_config2 = ""

#
huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.195", username="PzHZ2", password="Nokia123!"
    ),
    serial_number="H4K5T20B26002536",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei1"],
)

huawei2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.123.49", username="aic", password="Nokia123!"
    ),
    serial_number="9YS0220116017987",
    iperf_details=_iperf,
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    capabilities=["Commercial", "huawei2"],
)



##RealEnb
_real_enb_pdu = FACOM(addr="10.106.243.239", port_numbers=[5])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[5],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

## attenuator
_attenuator = HBTE(
    ip_addr="10.106.243.203",
    port=5000,
    attenuation_port_numbers=[9, 26, 43, 60, 1, 18, 35, 52],
    model="PA-16-16-6-127-0.5-B-S",
)


# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.106.243.241", port_numbers=[2])

_ru_0 = RU(
    ru_hw_group="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[2],
    radio_type=RadioTypes.AEQE,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[26],
        _attenuator.attenuator_ports[43],
        _attenuator.attenuator_ports[60],
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[18],
        _attenuator.attenuator_ports[35],
        _attenuator.attenuator_ports[52],
    ],
    serial_number=None,
)

# _ru_2 = RU(
#     ru_hw_group='AZNA',
#     default_ssh_connection_details=SshServiceDetails(
#         addr='172.16.37.130',
#         username='root',
#         password='root'),
#     lmp_connection=SshServiceDetails(
#         addr='172.16.37.130',
#         username='root',
#         password='root'),
#     pdu_port=_ru_0_pdu.pdu_ports[2],
#     radio_type=RadioTypes.AZNA,
#     signal_analyzer=None,
#     attenuation_ports=[
#         _attenuator.attenuator_ports[1],
#         _attenuator.attenuator_ports[18],
#         _attenuator.attenuator_ports[9],
#         _attenuator.attenuator_ports[26],
#         _attenuator.attenuator_ports[43],
#         _attenuator.attenuator_ports[60]],
#     serial_number=None,
# )

## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit5 = CapacityUnit(addr="192.168.253.20")
_capacity_unit6 = CapacityUnit(addr="192.168.253.20")
_capacity_unit7 = CapacityUnit(addr="192.168.253.20")

_gnb_pdu = FACOM(addr="10.106.243.241", port_numbers=[1])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit5, _capacity_unit6, _capacity_unit7],
    pdu_port=_gnb_pdu.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit5, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0],
    f1_m_ip_addr="10.97.97.3",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.97.97.3",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.243.129", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.97.97.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.97.97.3", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.243.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.243.129", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.243.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.243.129", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.243.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.243.129", ip_prefix_length=27),
    ),
)
# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=11042, global_bts_id=11042)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_NSASA_1XHW_2XASIB_2XABIL_2XABIA_1XABIO_1XAEQY_1XAEQE_1XAHEGB"

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    ues=[huawei1, huawei2],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=_attenuator,
)

# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
