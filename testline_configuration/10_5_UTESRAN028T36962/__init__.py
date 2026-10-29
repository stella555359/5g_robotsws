import os
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
from taf.config.testline.attenuator import HBTE, JFW
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "Dongjun.Tong"
__team__ = "NSB MN SRAN Prod HZH RRM 2 Vrf"
__email__ = "Dongjun.tong@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.201.185", username="ute", password="UTE.debian12"
    )
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.69.112.179", username="ute", password="ute", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.112.179",
    iperf_path="iperf",
    port="54015",
)

_appserver = AppServer(_iperf)

# Qualcomm

_android2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.56.201.134", username="five-tester", password="Nokia123!"
    ),
    serial_number="10ACCS1CZH0013Y",
    server_dir="C:\cygwin64",
    python_path="C:/Users/five-tester/AppData/Local/Programs/Python/Python39/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM4_MIFI", "dingli"],
)
_attenuator_5G = TopYoung(
    ip_addr="10.56.201.152",
    port=1000,
    attenuation_port_numbers=[1, 10, 19, 28],
    model="TAS16T16-51-120-1S-DES",
)

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.56.201.151", port_numbers=[1])

_ru_0 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw="
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="root", password="k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw="
    ),
    pdu_port=_ru_0_pdu.pdu_ports[1],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[10],
        _attenuator_5G.attenuator_ports[19],
        _attenuator_5G.attenuator_ports[28],
    ],
    serial_number=None,
)

## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.56.202.3",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_gnb_pdu = FACOM(addr="10.56.202.131", port_numbers=[3])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[3],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=2),
    ),
]

_du = DU(
    airscale=_airscale, rus=[_ru_0], f1_m_ip_addr="10.56.202.3", cablinks=_ru_cablinks
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.202.3",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.202.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.202.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.202.3", username="Nemuadmin", password="nemuuser"
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=37648, global_bts_id=37648)


tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASOH_2xAHEGG_1xAKQJ",
    ues=[_android2],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=_attenuator_5G,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
tl_ultracaller = os.path.join(_CFG_DIR, "uc_config.yaml")
 
__all__ = ["tl", "tl_ultracaller"]
