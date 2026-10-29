__team__ = "MN RAN RD VRF WRO 1 5"
__maintainer__ = "Zuzanna Wielkoszynska"
__email__ = "zuzanna.wielkoszynska@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.177.69", port_numbers=[4], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.177.69", port_numbers=[3], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.177.69", port_numbers=[2, 5, 9], model="EPC", version="8221-1"
)
_pdu_enb_ru = Gude(addr="10.44.177.69", port_numbers=[6], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M222600177",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M222011914",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)
_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M220223976",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[4],
    hardware_type="ASOE",
    hardware_version="A102",
    serial_number="EA214652527",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.181.45",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2a4", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2a4", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2a4", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50570
)

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[3],
    serial_number="EA194850050",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    global_bts_id=40570,
    instance_id=40570,
    rms=[
        RU(
            ru_hw_group="5Ggen3_HighF_2T2R",
            radio_type="AHEB",
            serial_number="EA201755975",
            pdu_port=_pdu_enb_ru.pdu_ports[6],
        )
    ],
    oam_ip=NetworkAddress(v4="10.42.181.44"),
)
_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.7", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb_1],
)
_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.116", username="ute", password="UTE.debian12"
    ),
    connections=[_enb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_2xAZHM_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
)
