__maintainer__ = "UTE team"
__team__ = "UTE team"
__email__ = "ute@nokia.com"
__owner_email__ = "UTE Lab Team"


import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import Airphone
from taf.config.testline.pdu import FACOM
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE, JFW
from taf.config.testline.core import RealCore
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)
from taf.config.testline.enb import (
    RealEnb,
)
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

## attenuator
_attenuator = JFW(
    ip_addr="10.69.71.4",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="50PA-574",
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.69.69.194", username="ute", password="uteUTE!", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.9.10",
    iperf_path="iperf",
    port="54015",
)

_appserver = AppServer(_iperf)

## DU for classicalBTS
_gnb_pdu = FACOM(addr="10.68.183.69", port_numbers=[4])

_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[4],
    hardware_type="ASIB",
)

_airscale = Airscale([_common_unit])

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.68.183.69", port_numbers=[4])

_ru_0 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    ru_hw_group="AHEGB",
    radio_type="AHEGB",
    pdu_port=_ru_0_pdu.pdu_ports[4],
    serial_number=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
)

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]
_cu = CU(
    backhaul_site_oam_ip="10.69.68.210",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.68.210", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.68.210", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.108.233.27", vlan_id=None),
    x2u=NetworkAddress(v4="10.108.233.27", vlan_id=None),
    s1u=NetworkAddress(v4="10.108.233.27", vlan_id=None),
)

_du = DU(airscale=_airscale, rus=[_ru_0], f1_m_ip_addr="10.69.68.210", cablinks=_ru_cablinks)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], instance_id=3388, global_bts_id=6200)

#RealEnb
_real_enb_pdu = FACOM(addr="10.68.183.69", port_numbers=[4])


_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[4],
    hardware_type="ASIB",
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# Mifi
ue_config_path = os.path.join(_CFG_DIR, "TestData/mifi.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.full_load(f)
else:
    ue_config = ""

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.69.194", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_MIFI_ASIBL_ABIAB1_ABIOB2_FRGU_AHEGB",
    ues=[ue_config],	
    #enbs=[_lte_real_enb],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=_attenuator,
)

__all__ = ["tl"]
