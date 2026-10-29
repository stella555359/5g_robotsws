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
        addr="10.56.5.50", username="ute", password="ute"
    )
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.106.243.149", username="ute", password="ute", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.243.149",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54016",
)

_appserver = AppServer(_iperf)

# Qualcomm
huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.106.243.221", username="RRM3", password="Nokia@123"
    ),
    serial_number="9YS0220116017987",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei"],
)
huawei2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.106.243.221", username="RRM3", password="Nokia@123"
    ),
    serial_number="9YS0220721019710",
    # 262
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei"],
)

# RealEnb
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

# attenuator
_attenuator = HBTE(
    ip_addr="10.106.243.238",
    port=5000,
    attenuation_port_numbers=[1, 18, 9, 26, 43, 60, 7, 24],
    model="PA-16-16-6-127-0.5-B-S",
)

# 5GRU for classicalBTS
_ru_1_pdu = FACOM(addr="10.106.243.239", port_numbers=[1])
_ru_2_pdu = FACOM(addr="10.106.243.239", port_numbers=[2])
_ru_1 = RU(
    ru_hw_group="AHFB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    pdu_port=_ru_1_pdu.pdu_ports[1],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[18],
    ],
    serial_number=None,
)

_ru_2 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.128", username="root", password="root"
    ),
    pdu_port=_ru_2_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[26],
        _attenuator.attenuator_ports[43],
        _attenuator.attenuator_ports[60],
    ],
    serial_number=None,
)
_ru_3 = RU(
    ru_hw_group="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    radio_type=RadioTypes.AEQE,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[24],
    ],
    serial_number=None,
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit1 = CapacityUnit(addr="fsp-1b")
_capacity_unit2 = CapacityUnit(addr="fsp-5b")
_capacity_unit3 = CapacityUnit(addr="fsp-6b")

_gnb_pdu = FACOM(addr="10.106.243.239", port_numbers=[3])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit1, _capacity_unit2, _capacity_unit3],
    pdu_port=_gnb_pdu.pdu_ports[3],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit1, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit1, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit2, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit2, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit3, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_3, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit3, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_3, label="SFP", port_id=2),
    ),
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_1, _ru_2, _ru_3],
    f1_m_ip_addr="10.68.195.3",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.68.195.3",
        v6="2a00:8a00:8000:10c:1:4:0:3",
        vlan_id=31,
        routing_v4=RoutingInformation(gateway="10.68.195.1", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:1", ip_prefix_length=125
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.195.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.195.3", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.68.195.11",
        v6="2a00:8a00:8000:10c:1:4:0:b",
        vlan_id=32,
        routing_v4=RoutingInformation(gateway="10.68.195.9", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:9", ip_prefix_length=125
        ),
    ),
    x2u=NetworkAddress(
        v4="10.68.195.19",
        v6="2a00:8a00:8000:10c:1:4:0:13",
        vlan_id=33,
        routing_v4=RoutingInformation(gateway="10.68.195.17", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:11", ip_prefix_length=125
        ),
    ),
    ngc=NetworkAddress(
        v4="10.68.195.51",
        v6="2a00:8a00:8000:10c:1:4:0:33",
        vlan_id=37,
        routing_v4=RoutingInformation(gateway="10.68.195.49", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:31", ip_prefix_length=125
        ),
    ),
    ngu=NetworkAddress(
        v4="10.68.195.59",
        v6="2a00:8a00:8000:10c:1:4:0:3b",
        vlan_id=38,
        routing_v4=RoutingInformation(gateway="10.68.195.56", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:39", ip_prefix_length=125
        ),
    ),
    xnc=NetworkAddress(
        v4="10.68.195.35",
        v6="2a00:8a00:8000:10c:1:4:0:23",
        vlan_id=35,
        routing_v4=RoutingInformation(gateway="10.68.195.33", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:21", ip_prefix_length=125
        ),
    ),
    xnu=NetworkAddress(
        v4="10.68.195.43",
        v6="2a00:8a00:8000:10c:1:4:0:2b",
        vlan_id=36,
        routing_v4=RoutingInformation(gateway="10.68.195.41", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:29", ip_prefix_length=125
        ),
    ),
    s1u=NetworkAddress(
        v4="10.68.195.27",
        v6="2a00:8a00:8000:10c:1:4:0:1b",
        vlan_id=34,
        routing_v4=RoutingInformation(gateway="10.68.195.25", ip_prefix_length=29),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:8000:10c:1:4:0:19", ip_prefix_length=125
        ),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1734, global_bts_id=552)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_AHFB_ASIBR_ABILB1_ABILB2_AHLOA_AEQE_fullrack"

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    ues=[huawei1, huawei2],
    appserver=_appserver,
    core=RealCore(mcc=460, mnc=2),
    attenuator=_attenuator,
)

# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
