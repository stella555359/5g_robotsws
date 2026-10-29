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
    addr="10.108.233.142", username="spark", password="spark123", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.108.233.142",
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
_real_enb_pdu = FPFH(addr="10.108.190.98", port_numbers=[3])
_attenuator = TopYoung(
    ip_addr="10.106.201.133",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 257)],
    model="TAS32B8-51-120-1N-DES",
)

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[3],
) 

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# 5GRU for classicalBTS for LNBTS11688
_ru_pdu_AHLOA = FPFH(addr="10.106.210.53", port_numbers=[6])
_ru_pdu_AHLOA_AHFIG_AHLOA_AHFIG_AHFIG = FPFH(addr="10.108.190.100", port_numbers=[1,2,3,4,5])
_ru_pdu_AEHC_AEHC_AHLOA = FPFH(addr="10.108.190.105", port_numbers=[1,2,3])

_ru_AHLOA = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.73.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHLOA.pdu_ports[6],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2034G1HHB",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [33, 35, 42, 44]]
    ],
)

_ru_AHFIG_1 = RU(
    ru_hw_group="AHFIG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHLOA_AHFIG_AHLOA_AHFIG_AHFIG.pdu_ports[2],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2012V090E",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [65, 67, 74, 76, 81, 83, 90, 92]]
    ],
)

_ru_AHFIG_2 = RU(
    ru_hw_group="AHFIG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHLOA_AHFIG_AHLOA_AHFIG_AHFIG.pdu_ports[4],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2012V090E",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [65, 67, 74, 76, 81, 83, 90, 92]]
    ],
)

_ru_AHFIG_3 = RU(
    ru_hw_group="AHFIG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHLOA_AHFIG_AHLOA_AHFIG_AHFIG.pdu_ports[5],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2012V090E",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [65, 67, 74, 76, 81, 83, 90, 92]]
    ],
)

_ru_AHEC = RU(
    ru_hw_group="AHEC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AEHC_AEHC_AHLOA.pdu_ports[1],
    radio_type=RadioTypes.AHEC,
    signal_analyzer=None,
    serial_number="L1203604935",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [193, 195, 202, 204]]
    ],
)

# DU for classicalBTS LNBTS10787
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20", 
                                hardware_type="ASIM")  #
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_real_enb_pdu.pdu_ports[3],
    hardware_type="ASIM"
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AHFIG_1, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_AHFIG_1, _ru_AHLOA, _ru_AHEC],
    f1_m_ip_addr="10.106.201.196",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.126", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.201.196", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.201.196", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.126", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.126", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.126", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=301, global_bts_id=301)
###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROID_SANSA_ASIM_ABIP_ABIO_AHLOA_AHFIB_AEHC"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.201.224", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
print(tl)
# old version keyword under robotws5g/resource compatibility workaround