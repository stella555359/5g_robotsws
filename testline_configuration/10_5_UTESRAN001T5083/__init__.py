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
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "SHENG KEFANG"
__team__ = "NSB MN SRAN Prod HZH RRM 2 Vrf"
__email__ = "kefang.sheng@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.4.43", username="rrm2-tester", password="Nokia123!", port="54015"
    )
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.101.2.23", username="ute", password="Ut3pa5s#ff97", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    #network_interface_address="10.69.4.57",
    # iperf_path="/home/",
    # port="54015",
)

_appserver = AppServer(_iperf)

# Qualcomm
_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.4.43", username="rrm2-tester", password="Nokia123!"
    ),

    serial_number="bb528c41",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "Qualcomm8150"],
)

##RealEnb
_real_enb_pdu = HBTE(addr="10.69.4.12", port_numbers=[0])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[0],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

## attenuator


# 5GRU for classicalBTS

## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_gnb_pdu = HBTE(addr="10.69.4.12", port_numbers=[4])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[4],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_pdu = HBTE(addr="10.69.4.12", port_numbers=[1])

_ru_0 = RU(
    ru_hw_group="AKNB",
    serial_number="1M222812793",
    # attenuation_ports=[
    #     _attenuator_5G.attenuator_ports[1],
    #     _attenuator_5G.attenuator_ports[2],
    #     _attenuator_5G.attenuator_ports[3],
    #     _attenuator_5G.attenuator_ports[4],
    #     _attenuator_5G.attenuator_ports[5],
    #     _attenuator_5G.attenuator_ports[6],
    #     _attenuator_5G.attenuator_ports[7],
    #     _attenuator_5G.attenuator_ports[8],
    #     _attenuator_5G.attenuator_ports[9],
    #     _attenuator_5G.attenuator_ports[10],
    #     _attenuator_5G.attenuator_ports[11],
    #     _attenuator_5G.attenuator_ports[12],
    # ],
    pdu_port=_ru_pdu.pdu_ports[1],
)
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0],
    f1_m_ip_addr="10.69.4.1",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.69.4.1",
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.4.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.4.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.69.4.1",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    x2u=NetworkAddress(
        v4="10.69.4.1",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    ngc=NetworkAddress(
        v4="10.69.4.1",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    ngu=NetworkAddress(
        v4="10.69.4.1",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    xnc=NetworkAddress(
        v4="10.69.4.1",
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    xnu=NetworkAddress(
        v4="10.69.4.1",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
    s1u=NetworkAddress(
        v4="10.69.4.1",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.69.4.126", ip_prefix_length=28),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=5083, global_bts_id=4)

_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_ABILB2_AHPDA_RFS"
)
tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    ues=[_android],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    # attenuator=_attenuator,
)

# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
