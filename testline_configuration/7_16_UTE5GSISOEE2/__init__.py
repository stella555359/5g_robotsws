__maintainer__ = "Zuzanna Wielkoszynska"
__team__ = "MN RAN RD VRF WRO 1 5"
__email__ = "zuzanna.wielkoszynska@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import Android, PluginAndroidClassType
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.attenuator import TopYoung

__all__ = ["tl"]

_pdu_gnb = ATEN(addr="10.44.206.244", port_numbers=[8])

_pdu_gnb_ru = Gude(
    addr="10.44.200.239",
    port_numbers=[1, 2, 7, 8, 9, 10],
    model="EPC",
    version="8221-1",
)


_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQB",
    serial_number="L1243108226",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQB",
    serial_number="L1243409774",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQB",
    serial_number="L1243108227",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_ru_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQ",
    serial_number="1M244206027",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)
_ru_5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQ",
    serial_number="1M244206029",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)
_ru_6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQ",
    serial_number="1M244206025",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_abio_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIQ",
    hardware_version="A103",
    serial_number="L1233105851",
    rus=[_ru_1, _ru_2, _ru_3],
)

_abio_gnb_2_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A103",
    serial_number="L1234301747",
    rus=[_ru_4, _ru_5, _ru_6],
)
_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_loner, _abio_gnb_2_loner],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="A102",
    serial_number="L1233406266",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6]
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.88.46",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:600c::2820", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:600c::2820", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:600c::2820", vlan_id=370),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=55211, instance_id=55211
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.212", username="ute", password="UTE.debian12"
    ),
    connections=[_asib_gnb_1],
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)

_nokia_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.42.197.170",
    iperf_path="/data/data/com.nokia.android.application",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    # ues=[_xiaomi],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIQ_ABIP_3xAVQQB_3xAVQQ_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
