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
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.200.154", port_numbers=[8], model="EPC", version="8041-1")

_pdu_gnb_ru = Gude(
    addr="10.44.200.239", port_numbers=[3, 4], model="EPC", version="8221-1"
)

_pdu_gnb_ru2 = Gude(
    addr="10.44.205.6", port_numbers=[11], model="EPC", version="8221-1"
)


_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQ",
    serial_number="1M251604739",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQ",
    serial_number="1M251604740",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQ",
    serial_number="1M251604741",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[11],
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASOH",
    hardware_version="A102",
    serial_number="L1242306620",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.89.56",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.42.89.114", vlan_id=571),
    x2u=NetworkAddress(v4="10.42.89.114", vlan_id=571),
    s1u=NetworkAddress(v4="10.42.89.114", vlan_id=571),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=55224, instance_id=55224
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.213", username="ute", password="UTE.debian12"
    ),
    connections=[_asim_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    app_server_name="APP_1",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
    version=3,
)


tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    #  ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOH_3xAVQQ_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru2],
)
