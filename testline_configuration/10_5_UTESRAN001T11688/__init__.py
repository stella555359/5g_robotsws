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
_real_enb_pdu = FPFH(addr="10.108.191.54", port_numbers=[1,2])
_attenuator = TopYoung(
    ip_addr="10.56.218.6",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 257)],
    model="TAS32B8-51-120-1N-DES",
)

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[1],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(system_module=_real_enb, rms=None)

# 5GRU for classicalBTS for LNBTS11688
_ru_pdu_AZHL_AEHC_AQQL = FPFH(addr="10.108.191.53", port_numbers=[2, 4, 5])
_ru_pdu_AHFIB_AHLOA = FPFH(addr="10.108.191.54", port_numbers=[3, 4, 5])
_ru_AHLOA_1_U1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFIB_AHLOA.pdu_ports[4],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL1930G11NF",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [21, 22, 23, 24, 29, 30, 31, 32]]
    ],
)

_ru_AHLOA_1_U2 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFIB_AHLOA.pdu_ports[4],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL1930G11NF",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [21, 22, 23, 24, 29, 30, 31, 32]]
    ],
)

_ru_AHLOB_2_U1 = RU(
    ru_hw_group="AHLOB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFIB_AHLOA.pdu_ports[5],
    radio_type=RadioTypes.AHLOB,
    signal_analyzer=None,
    serial_number="BL2032G1GNO",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [37, 38, 39, 40, 45, 46, 47, 48]]
    ],
)
_ru_AHLOB_2_U2 = RU(
    ru_hw_group="AHLOB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFIB_AHLOA.pdu_ports[5],
    radio_type=RadioTypes.AHLOB,
    signal_analyzer=None,
    serial_number="BL2032G1GNO",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [37, 38, 39, 40, 45, 46, 47, 48]]
    ],
)

_ru_AHFIB_U1 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFIB_AHLOA.pdu_ports[3],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2144V0OER",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [5, 6, 7, 8, 13, 14, 15, 16]]
    ],
)
_ru_AHFIB_U2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AHFIB_AHLOA.pdu_ports[3],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2144V0OER",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [5, 6, 7, 8, 13, 14, 15, 16]]  # nochange
    ],
)

_ru_AZHL_U1 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC_AQQL.pdu_ports[2],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="AH222602974",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [149, 150, 151, 152, 157, 158, 159, 160]]
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
    pdu_port=_ru_pdu_AZHL_AEHC_AQQL.pdu_ports[2],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="AH222602974",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [149, 150, 151, 152, 157, 158, 159, 160]]
    ],
)

_ru_AHEC_U1 = RU(
    ru_hw_group="AHEC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.1.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC_AQQL.pdu_ports[5],
    radio_type=RadioTypes.AHEC,
    signal_analyzer=None,
    serial_number="L1204209445",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [165, 166, 167, 168, 173, 174, 175, 176]]
    ],
)

_ru_AHEC_U2 = RU(
    ru_hw_group="AHEC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC_AQQL.pdu_ports[5],
    radio_type=RadioTypes.AHEC,
    signal_analyzer=None,
    serial_number="L1204209445",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [165, 166, 167, 168, 173, 174, 175, 176]]
    ],
)

_ru_AQQL_U1 = RU(
    ru_hw_group="AQQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.154", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC_AQQL.pdu_ports[4],
    radio_type=RadioTypes.AQQL,
    signal_analyzer=None,
    serial_number="L1221107166",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [181, 182, 183, 184, 189, 190, 191, 192]]
    ],
)

_ru_AQQL_U2 = RU(
    ru_hw_group="AQQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.154", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC_AQQL.pdu_ports[4],
    radio_type=RadioTypes.AQQL,
    signal_analyzer=None,
    serial_number="L1221107166",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [181, 182, 183, 184, 189, 190, 191, 192]]
    ],
)
# DU for classicalBTS LNBTS10787
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_lmp_connection_11221 = SshServiceDetails(
    addr="10.106.230.22", username="toor4nsn", password="oZPS0POrRieRtu"
)


_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIL")  #

_capacity_unit_11221 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIM")
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_real_enb_pdu.pdu_ports[1],
    hardware_type="ASIL"
)

_common_unit_11221 = CommonUnit(
    lmp_connection=_lmp_connection_11221,
    capacity_units=[_capacity_unit_11221],
    pdu_port=_real_enb_pdu.pdu_ports[2],
    hardware_type="ASIM"
)

_airscale = Airscale(common_units=[_common_unit_0])
_airscale_11221 = Airscale(common_units=[_common_unit_11221])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AHFIB_U2, label="SFP", port_id=1),
    )
]

_ru_cablinks_11221 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_11221, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AHFIB_U2, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_AHFIB_U2, _ru_AZHL_U2, _ru_AHLOB_2_U2, _ru_AHLOA_1_U2, _ru_AHEC_U2, _ru_AQQL_U2,
         _ru_AHFIB_U1, _ru_AZHL_U1, _ru_AHLOB_2_U1, _ru_AHLOA_1_U1, _ru_AHEC_U1, _ru_AQQL_U1],
    f1_m_ip_addr="10.106.230.21",
    cablinks=_ru_cablinks,
)

_du_11221 = DU(
    airscale=_airscale_11221,
    rus=[_ru_AHFIB_U1],
    f1_m_ip_addr="10.106.230.22",
    cablinks=_ru_cablinks_11221,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.230.21",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.21", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.230.21", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.230.21",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
    x2u=NetworkAddress(
        v4="10.106.230.21",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.106.230.21",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
)

_cu_11221 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.230.22",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.22", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.230.22", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.230.22",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
    x2u=NetworkAddress(
        v4="10.106.230.22",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.106.230.22",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.230.1/26"),
    ),
)

# classicalbts
_classical_bts_11688 = ClassicalBts(dus=[_du], cu=_cu, instance_id=11688, global_bts_id=11688)

_classical_bts_11221 = ClassicalBts(
    dus=[_du_11221], cu=_cu_11221, instance_id=11221, global_bts_id=11221
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL"
)
# #host VM pc
_host_11688 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.56", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_11688.dus[0].airscale.common_units[0], ue_config],
)

# host LTE VM PC
_host_11221 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.58", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_11221.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_host_11688,
    test_pcs=[_host_11688, _host_11221],
    gnbs=[_classical_bts_11688,_classical_bts_11221],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
print(tl)
# old version keyword under robotws5g/resource compatibility workaround