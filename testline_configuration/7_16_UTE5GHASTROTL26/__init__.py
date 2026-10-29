import os
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import ATEN
from taf.config.testline.ue import MediaTek
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.flexi import Flexi
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.lmi import LMI, Local

__maintainer__ = "Tomasz Godlewski"
__team__ = "RRM1 team"
__email__ = "tomasz.1.godlewski@nokia.com"
__owner_email__ = "tomasz.1.godlewski@nokia.com"
_pdu_gnb = ATEN(addr="10.44.206.44", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_gnb_ru = ATEN(addr="10.44.206.44", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_gnb_ru_1 = ATEN(addr="10.44.205.203", port_numbers=[5])
_pdu_gnb_ru_2 = ATEN(addr="10.44.177.90", port_numbers=[8])
_pdu_gnb_ru_3 = ATEN(addr="10.44.206.58", port_numbers=[4])
_pdus = [_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru_1, _pdu_gnb_ru_2]

_attenuator = TopYoung(
    ip_addr="10.42.221.165",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)


_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    xnc=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    xnu=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    ngc=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
    ngu=NetworkAddress(
        v4="10.44.88.189",
        v6=None,
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
    ),
)

_ru_lmi_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.72.241", username="wro5grrm", password="5gpass!1"
    )
)

_ru_lmi_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.224.197", username="wro5grrm", password="5gpass!1"
    )
)

_ahloa_lmi = LMI(product_code="", host=_ru_lmi_pc_2, uart_mapping=[Local(port="COM9")])

_ahfib_lmi = LMI(product_code="", host=_ru_lmi_pc_2, uart_mapping=[Local(port="COM12")])

_aehc_lmi = LMI(product_code="", host=_ru_lmi_pc_1, uart_mapping=[Local(port="COM59")])

_avqqa_lmi = LMI(product_code="", host=_ru_lmi_pc_1, uart_mapping=[Local(port="COM56")])

_ahfii_lmi = LMI(product_code="", host=_ru_lmi_pc_1, uart_mapping=[Local(port="COM55")])


_gnb_ru_1 = RU(
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
    ru_hw_group="",
    serial_number="BL1933G10O2",
    radio_type="AHLOA",
#    lmi=_ahloa_lmi,
)
_gnb_ru_2 = RU(
    pdu_port=_pdu_gnb_ru_2.pdu_ports[8],
    ru_hw_group="",
    serial_number="BL2045V0RO4",
    radio_type="AHFIB",
#    lmi=_ahfib_lmi,
)
_gnb_ru_3 = RU(
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
    ru_hw_group="",
    serial_number="L1213808576",
    radio_type="AEHC",
#    lmi=_aehc1_lmi,
)
_gnb_ru_4 = RU(
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
    ru_hw_group="",
    serial_number="L1251101679",
    radio_type="AVQQA",
#    lmi=_aehc2_lmi,
)
_gnb_ru_5 = RU(
    pdu_port=_pdu_gnb_ru_3.pdu_ports[4],
    ru_hw_group="",
    serial_number="BL2221N4063",
    radio_type="AHFII",
#    lmi=_ahfii_lmi,
)

_abia_1 = CapacityUnit(addr="192.168.253.36", hardware_type="ABIA", rus=[_gnb_ru_1])
_abia_2 = CapacityUnit(addr="192.168.253.37", hardware_type="ABIA", rus=[_gnb_ru_2])
_abio_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIO", rus=[_gnb_ru_3, _gnb_ru_4]
)
_abio_slave = CapacityUnit(
    addr="192.168.253.21", hardware_type="ABIO", rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_5]
)
_smod_gnb_1 = CommonUnit(
    hardware_type="ASIL",
    serial_number="DH223149009",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave],
    pdu_port=_pdu_gnb.pdu_ports[3],
)


_smod_enb_1 = CommonUnit(
    hardware_type="ASIA",
    serial_number="L1184702810",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])
_airscale_enb_1 = Flexi([_smod_enb_1])
_cu_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    rms=[_gnb_ru_1, _gnb_ru_2],
    global_bts_id=40861,
    instance_id=40861,
    x2_link_addr=NetworkAddress(
        v4="10.44.90.124/26",
        v6=None,
        vlan_id=480,
    ),
)


## common
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_du_1_gnb_1 = DU(
    _airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5]
)
_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], instance_id=50861, global_bts_id=50861
)


# Test PC
_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.123", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.124", username="ute", password="ute"
    ),
    connections=[_cu_enb_1.system_module.common_units[0]],
)


_core = RealCore5G(mcc=310, mnc=260)
_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_proxy_config.yaml"
)
tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    enbs=[_cu_enb_1],
    ues=[_ue_config],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL26_ASIL_ABIO_AHLOA_AHFIB_AEHC_AVQQA_AHFII",
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
)
__all__ = ["tl"]
