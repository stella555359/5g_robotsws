__team__ = "MN RAN RD VRF WRO1 4"
__maintainer__ = "Sylwia Pawlak"
__email__ = "sylwia.pawlak@nokia.com"

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
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.37", port_numbers=[1], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.205.57", port_numbers=[1, 2, 3, 4, 5, 6], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQU",
    serial_number="4H210530090",
    product_code="475665A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
    lmp_connection=SshServiceDetails(addr="10.255.33.95", port=2003, username=""),
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQB",
    serial_number="L1243409773",
    product_code="476629A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
    lmp_connection=SshServiceDetails(addr="10.255.33.93", port=3000, username="3001"),
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHHB",
    serial_number="EA205250544",
    product_code="474252A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_ru_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVHA",
    serial_number="L1243804505",
    product_code="476541A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
    lmp_connection=SshServiceDetails(addr="10.255.33.92", port=3000, username="3001"),
)

_ru_5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M222600267",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
    lmp_connection=SshServiceDetails(addr="10.255.33.96", port=2003, username=""),
)

_ru_6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHPMDA",
    serial_number="K9184238623",
    product_code="473997A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)
_asog_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASOG",
    hardware_version="A101",
    serial_number="L1240913023",
)

_airscale_gnb_1 = Airscale(common_units=[_asog_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6]
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.224",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::293d", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::293d", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::293d", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=55206, instance_id=55206
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.219", username="ute", password="ute"
    ),
    connections=[_asog_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_oneplus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.99", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M9AIKN01N573BCM",
    ue_pc_address="10.42.224.99",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
)
tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_oneplus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOG_AVHA_AVQQB_AKQJ_AZQU",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
