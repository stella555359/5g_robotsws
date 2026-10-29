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
    addr="10.56.221.13", username="ute", password="ute", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.221.13",
    iperf_path="/usr/bin/",
    port="50002",
)
_appserver = AppServer(_iperf)

ue_config_path = os.path.join(_cfg_dir, "TestData/inseego.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(stream=f, Loader=yaml.FullLoader)
else:
    ue_config = ""

_site1_pdu = FACOM(addr="10.108.151.124", port_numbers=[1, 2, 7, 8])
_attenuator = HB(
    ip_addr="10.108.164.149",
    port=5000,
    attenuation_port_numbers=[i for i in range(1, 256)],
    model="PAM-32X16-6-127-0.5-B-S"
)

# 5GRU for classicalBTS for LNBTS6483
_ru_0 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[1],
    radio_type=RadioTypes.AHCA,
    signal_analyzer=None,
    serial_number="1M193000211",
    # attenuation_ports=[
    #     _attenuator.attenuator_ports[i] for i in [i for i in [1,2]]  # port 20
    # ],
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
    serial_number="K9181002566",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [13, 45, 77, 109, 14, 46, 78, 110]]
    ],
)
_ru_2 = RU(
    ru_hw_group="FRGU",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_site1_pdu.pdu_ports[7],
    radio_type=RadioTypes.FRGU,
    signal_analyzer=None,
    serial_number="K9172851255",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [5, 37, 69, 101, 6, 38, 70, 102]]
    ],
)
# DU for classicalBTS LNBTS6483
_lmp_connection = SshServiceDetails(
    addr="10.0.81.13", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIL")  #

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[8],
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
    rus=[_ru_0, _ru_1, _ru_2],
    f1_m_ip_addr="10.0.81.13",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.0.81.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.81.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.81.211", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.0.81.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.0.81.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.0.81.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(
    dus=[_du],
    cu=_cu,
    instance_id=6483,
    global_bts_id=6483)

# 5GRU for classicalBTS for NRBTS6489
_gnb_pdu_6489 = FACOM(addr="10.108.164.154", port_numbers=[1, 5])
_ru_6489_AZQG = RU(
    ru_hw_group="AZQG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_6489.pdu_ports[5],
    radio_type=RadioTypes.AZQG,
    signal_analyzer=None,
    serial_number="EA201554066",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [9, 41, 73, 105, 10, 42, 74, 106]
        # ((9,1),(9,2),(9,3),(9,4),(10,1),(10,2),(10,3),(10,4)),
    ],
)

# DU for classicalBTS LNBTS6489
_lmp_connection_6489 = SshServiceDetails(
    addr="10.0.81.12", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6489 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIB")  #


_common_unit_6489 = CommonUnit(
    lmp_connection=_lmp_connection_6489,
    capacity_units=[_capacity_unit_6489],
    pdu_port=_gnb_pdu_6489.pdu_ports[5],
    hardware_type="ASIB"
)

_airscale_6489 = Airscale(common_units=[_common_unit_6489])

_ru_cablinks_6489 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6489, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_6489_AZQG, label="SFP", port_id=1),
    )
]

_du_6489 = DU(
    airscale=_airscale_6489,
    rus=[_ru_6489_AZQG],
    f1_m_ip_addr="10.0.81.12",
    cablinks=_ru_cablinks_6489,
)

_cu_6489 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.81.212", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.81.212", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_6489 = ClassicalBts(
    dus=[_du_6489], cu=_cu_6489, instance_id=6489, global_bts_id=6489
)

# RU for classicalBTS for LTEBTS2589
_gnb_pdu_2589 = FACOM(addr="10.108.164.154", port_numbers=[2, 4])
_ru_2589_FXED = RU(
    ru_hw_group="FXED",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_2589.pdu_ports[4],
    radio_type=RadioTypes.FXED,
    signal_analyzer=None,
    serial_number="1M164904504",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [11, 43, 75, 107, 12, 44, 76, 108]]
    ],
)

# DU for classicalBTS LNBTS6480
_lmp_connection_2589 = SshServiceDetails(
    addr="10.108.151.135", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_2589 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIA")  #


_common_unit_2589 = CommonUnit(
    lmp_connection=_lmp_connection_2589,
    capacity_units=[_capacity_unit_2589],
    pdu_port=_gnb_pdu_2589.pdu_ports[2],
    hardware_type="ASIA"
)

_airscale_2589 = Airscale(common_units=[_common_unit_2589])

_ru_cablinks_2589 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_2589, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_2589_FXED, label="SFP", port_id=1),
    )
]

_du_2589 = DU(
    airscale=_airscale_2589,
    rus=[_ru_2589_FXED],
    f1_m_ip_addr="10.108.151.135",
    cablinks=_ru_cablinks_2589,
)

_cu_2589 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.108.151.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.151.222",
            ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.212", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.151.212", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.108.151.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.151.222",
            ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.108.151.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.151.222",
            ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.108.151.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.151.222",
            ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_2589 = ClassicalBts(
    dus=[_du_2589], cu=_cu_2589, instance_id=2589, global_bts_id=2589
)


# RU for classicalBTS for LTEBTS6470
_gnb_pdu_6470 = FACOM(addr="10.108.151.124", port_numbers=[5])
_gnb_pdu_6469_2 = FACOM(addr="10.108.151.94", port_numbers=[6])
_ru_6470_AAHF = RU(
    ru_hw_group="AAHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_6469_2.pdu_ports[6],
    radio_type=RadioTypes.AAHF,
    signal_analyzer=None,
    serial_number="1M191627121",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [1, 33, 65, 97, 2, 34, 66, 98]
        # ((1,1),(1,2),(1,3),(1,4),(2,1),(2,2),(2,3),(2,4)),
    ],
)

# DU for classicalBTS LNBTS6470
_lmp_connection_6470 = SshServiceDetails(
    addr="10.0.81.5", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6470 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIK")  #


_common_unit_6470 = CommonUnit(
    lmp_connection=_lmp_connection_6470,
    capacity_units=[_capacity_unit_6470],
    pdu_port=_gnb_pdu_6470.pdu_ports[5],
    hardware_type="ASIK"
)

_airscale_6470 = Airscale(common_units=[_common_unit_6470])

_ru_cablinks_6470 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6470, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_6470_AAHF, label="SFP", port_id=1),
    )
]

_du_6470 = DU(
    airscale=_airscale_6470,
    rus=[_ru_6470_AAHF],
    f1_m_ip_addr="10.0.81.5",
    cablinks=_ru_cablinks_6470,
)

_cu_6470 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.81.212", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.81.212", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_6470 = ClassicalBts(
    dus=[_du_6470], cu=_cu_6470, instance_id=6470, global_bts_id=6470
)

# RU for classicalBTS for LTEBTS6467
_gnb_pdu_6467 = HBTE(addr="10.108.164.131", port_numbers=[2, 3])
_ru_6467_AAHF = RU(
    ru_hw_group="AAHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_6467.pdu_ports[3],
    radio_type=RadioTypes.AAHF,
    signal_analyzer=None,
    serial_number="6Q184029797",
    # (17,1),(17,2),(17,3),(17,4),(18,1),(18,2),(18,3),(18,4)
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [17, 49, 81, 113, 18, 50, 82, 114]
    ],
)

# DU for classicalBTS LNBTS6467
_lmp_connection_6467 = SshServiceDetails(
    addr="10.0.81.6", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6467 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIK")  #


_common_unit_6467 = CommonUnit(
    lmp_connection=_lmp_connection_6467,
    capacity_units=[_capacity_unit_6467],
    pdu_port=_gnb_pdu_6467.pdu_ports[2],
    hardware_type="ASIK"
)

_airscale_6467 = Airscale(common_units=[_common_unit_6467])

_ru_cablinks_6467 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6467, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_6467_AAHF, label="SFP", port_id=1),
    )
]

_du_6467 = DU(
    airscale=_airscale_6467,
    rus=[_ru_6467_AAHF],
    f1_m_ip_addr="10.0.81.6",
    cablinks=_ru_cablinks_6467,
)

_cu_6467 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.81.212", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.81.212", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.108.151.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.151.222",
            ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_6467 = ClassicalBts(
    dus=[_du_6467], cu=_cu_6467, instance_id=6467, global_bts_id=6467
)


# RU for classicalBTS for LTEBTS6469
_gnb_pdu_6469 = FACOM(addr="10.108.151.124", port_numbers=[6])

_ru_6469_AAHF = RU(
    ru_hw_group="AAHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_6469_2.pdu_ports[6],
    radio_type=RadioTypes.AAHF,
    signal_analyzer=None,
    serial_number="1M191627121"
)

# DU for classicalBTS LNBTS6469
_lmp_connection_6469 = SshServiceDetails(
    addr="10.108.164.147", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6469 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIK")  #


_common_unit_6469 = CommonUnit(
    lmp_connection=_lmp_connection_6469,
    capacity_units=[_capacity_unit_6469],
    pdu_port=_gnb_pdu_6469.pdu_ports[6],
    hardware_type="ASIK"
)

_airscale_6469 = Airscale(common_units=[_common_unit_6469])

_ru_cablinks_6469 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6469, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_6469_AAHF, label="SFP", port_id=1),
    )
]

_du_6469 = DU(
    airscale=_airscale_6469,
    rus=[_ru_6469_AAHF],
    f1_m_ip_addr="10.108.164.147",
    cablinks=_ru_cablinks_6469,
)

_cu_6469 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.108.164.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.164.222",
            ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.164.212", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.164.212", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.108.164.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.164.222",
            ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.108.164.212",
        vlan_id=None,
        routing=RoutingInformation(
            gateway="10.108.164.222",
            ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.0.81.212",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.0.81.222", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_6469 = ClassicalBts(
    dus=[_du_6469], cu=_cu_6469, instance_id=6469, global_bts_id=6469
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIA3_AHCA_AHEGB_FRGU-ASIBL_ABIL2_AHEGB_AZQG-ASIA_ABIA_FXED"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.238", username="pzhz2", password="Nokia123!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
_host_6489 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.221.33", username="pzhz2", password="Nokia123!"
    ),
    connections=[_classical_bts_6489.dus[0].airscale.common_units[0], ue_config],
)
_host_2589 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.122", username="jiahaoc", password="Nokia123!"
    ),
    connections=[_classical_bts_2589.dus[0].airscale.common_units[0], ue_config],
)
_host_6470 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.164.185", username="pzhz2", password="Nokia123!"
    ),
    connections=[_classical_bts_6470.dus[0].airscale.common_units[0], ue_config],
)
_host_6467 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.164.182", username="pzhz2", password="Nokia123!"
    ),
    connections=[_classical_bts_6467.dus[0].airscale.common_units[0], ue_config],
)
_host_6469 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.164.184", username="pzhz2", password="Nokia123!"
    ),
    connections=[_classical_bts_6469.dus[0].airscale.common_units[0], ue_config],
)
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host, _host_6489, _host_2589,
              _host_6470, _host_6467, _host_6469],
    gnbs=[_classical_bts, _classical_bts_6489, _classical_bts_2589,
          _classical_bts_6470, _classical_bts_6467, _classical_bts_6469],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
print(tl)
# old version keyword under robotws5g/resource compatibility workaround
