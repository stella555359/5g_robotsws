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
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude
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
from taf.config.testline.flexi import Flexi

__maintainer__ = "Xu Yuyan"
__team__ = "I_NSB_MN_RAN_PZ_1_HAZ_11_GMS"
__email__ = "yuyan.xu@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.111.117", username="ute", password="RAN_pz_HAZ1_SG11", port="54015"
    )
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.111.117", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


########### Part 4: UE ####################################
#  iperf server info   #liu server 10.108.229.121 ute ute
_appserver_ssh = SshServiceDetails(
    # addr="10.106.245.10", username="Oper1", password="Nokia@123"
    addr="10.108.229.121",
    username="ute",
    password="ute",
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    # network_interface_address="10.106.243.149",
    # network_interface_address="10.106.245.10",
    network_interface_address="10.108.229.121",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="50017",
    # dl pass 50017 50018 5001
    # port="50015",
)

# Iperf
_appserver_ssh2 = SshServiceDetails(
    addr="10.69.4.46", username="rrm2-tester", password="Nokia123!", port="54015"
)

_iperf2 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.212.49",
    iperf_path="/home/",
    port="54015",
)

_appserver = AppServer(_iperf)

# Mifi
ue_config_path = os.path.join(_cfg_dir, "TestData/mifi.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(f, Loader=yaml.FullLoader)
else:
    ue_config = ""

# Qualcomm
_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.4.46", username="rrm2-tester", password="Nokia123!"
    ),
    serial_number="R5CN20BJXTL",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "RRM2_S20"],
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.4.46", username="rrm2-tester", password="Nokia123!"
    ),
    serial_number="9YS0220730009229",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "RRM2_HUAWEI"],
)


huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.106.245.25", username="Oper1", password="Nokia@123"
    ),
    serial_number="R5CT12GAS8E",
    # serial_number="7TD5T21715003750",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei1"],
)


# RealEnb
_real_enb_pdu = FACOM(addr="10.106.245.166", port_numbers=[1])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202903938",
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# attenuator
_attenuator = HBTE(
    ip_addr="10.69.4.18",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="PA-16-16-6-127-0.5-B-S",
)


_attenuator_5G = TopYoung(
    ip_addr="10.106.245.23",
    port=1000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14],
    model="PA-8-2-4-127-0.5-B-S",
)

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.69.4.14", port_numbers=[3])


_ru_0 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[3],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[2],
        _attenuator_5G.attenuator_ports[3],
        _attenuator_5G.attenuator_ports[4],
        _attenuator_5G.attenuator_ports[5],
        _attenuator_5G.attenuator_ports[6],
        _attenuator_5G.attenuator_ports[7],
        _attenuator_5G.attenuator_ports[8],
        _attenuator_5G.attenuator_ports[10],
        _attenuator_5G.attenuator_ports[12],
        _attenuator_5G.attenuator_ports[13],
        _attenuator_5G.attenuator_ports[14],
    ],
    serial_number=None,
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_gnb_pdu = FACOM(addr="10.69.4.14", port_numbers=[1])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0],
    f1_m_ip_addr="10.69.4.4",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.69.4.4",
        routing_v4=RoutingInformation(gateway="10.69.4.30", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.4.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.4.4", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.69.4.36",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.69.4.36",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
    ngc=NetworkAddress(
        v4="10.69.4.36",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
    ngu=NetworkAddress(
        v4="10.69.4.36",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
    xnc=NetworkAddress(
        v4="10.69.4.36",
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
    xnu=NetworkAddress(
        v4="10.69.4.36",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.69.4.36",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.62", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1880, global_bts_id=1880)


_pdu = FACOM(
    addr="10.106.245.166", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="FACOM"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH203864509",
    capacity_units=[],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202903938",
    capacity_units=[],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(ru_hw_group="", serial_number="BL1923V0A9R", pdu_port=_pdu.pdu_ports[2])

_rmod_3 = RU(ru_hw_group="", serial_number="6Q181103531", pdu_port=_pdu.pdu_ports[3])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3],
    oam_ip=NetworkAddress("10.70.14.71"),
)


_tl_cloud_topology = "CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1880"

tl = TestLine(
    # test_pc=[_host],
    # test_pcs=[_host],
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    # enbs=[_lte_real_enb],
    enbs=[_enb_sbts_1],
    ues=[huawei1],
    # ues=[ue_config],
    attenuator=_attenuator_5G,
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
)

# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
