__team__ = "VRF_WRO1_T02_01_VRF_SiSo"
__owner__ = "Filip Poprawa"
__maintainer__ = "Filip Poprawa"
__email__ = "filip.poprawa@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import Leoni

__all__ = ["tl"]

_attenuator = TopYoung(
    ip_addr="10.42.75.76",
    port=3001,
    attenuation_port_numbers=[13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1S_EJS",
    serial_number="30022091042",
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_iperf = TafUeDataTransferProtocol(
    app_server=_appserver_ssh,
    protocol_name="iperf",
    version=3,
)

_android = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.138", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M6AIKN008892RYA",
    ue_pc_address="10.42.224.138",
    qualcomm_prototype=False,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    data_transfer=[_iperf],
    airplane_mode_switcher_text="Airplane mode",
    is_rooted=True,
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.66.138",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::602b", vlan_id=465),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::602b", vlan_id=465),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::602b", vlan_id=465),
)

_optical_switch = Leoni(addr="10.42.66.159", model="mol 6x(2x6)", port=3001)

_pdu_gnb = Gude(addr="10.44.206.8", port_numbers=[4], model="EPC", version="8220-1")

_pdu_gnb_ru1 = ATEN(addr="10.44.205.9", port_numbers=[1])

_pdu_gnb_ru2 = Gude(
    addr="10.44.206.218", port_numbers=[8], model="EPC", version="8220-1"
)

_pdu_gnb_ru3 = Gude(
    addr="10.44.205.163", port_numbers=[6], model="EPC", version="8221-1"
)

_pdu_gnb_ru4 = Gude(
    addr="10.44.206.11", port_numbers=[4], model="EPC", version="8221-1"
)

_pdu_gnb_ru5 = Gude(
    addr="10.44.206.11", port_numbers=[3], model="EPC", version="8221-1"
)

_pdu_gnb_ru6 = Gude(
    addr="10.44.205.64", port_numbers=[6], model="EPC", version="8221-1"
)

_pdu_gnb_ru7 = Gude(
    addr="10.44.177.174", port_numbers=[11], model="EPC", version="8221-1"
)

_pdu_gnb_ru8 = Gude(
    addr="10.44.177.174", port_numbers=[4], model="EPC", version="8221-1"
)

_gnb_ru1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1232711651",
    product_code="476203A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[1],
)

_gnb_ru2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1251800371",
    product_code="476203A.205",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[8],
)

_gnb_ru3 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1232908042",
    product_code="476203A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.18",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[6],
)

_gnb_ru4 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKQJ",
    serial_number="1M220223981",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.26",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru4.pdu_ports[4],
)

_gnb_ru5 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKQJ",
    serial_number="1M222600209",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.30",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru5.pdu_ports[3],
)

_gnb_ru6 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKQJ",
    serial_number="1M220223983",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.34",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru6.pdu_ports[6],
)

_gnb_ru7 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZNA",
    serial_number="6Q180404576",
    product_code="473914A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_pdu_gnb_ru7.pdu_ports[11],
)

_gnb_ru8 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZNA",
    serial_number="6Q190208562",
    product_code="473914A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_pdu_gnb_ru8.pdu_ports[4],
)

_abip_1_gnb_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:101",
    hardware_type="ABIP",
    serial_number="L1232004132",
    product_code="475792A.101",
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3],
)

_abip_2_gnb_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:101",
    hardware_type="ABIP",
    serial_number="L1231811783",
    product_code="475792A.101",
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4, _gnb_ru5, _gnb_ru6],
)

_abiq_1_gnb_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:101",
    hardware_type="ABIQ",
    serial_number="L1241505072",
    product_code="476397A.102",
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru7, _gnb_ru8],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1_gnb_1, _abip_2_gnb_1, _abiq_1_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[4],
    hardware_type="ASIL",
    serial_number="L1202606179",
    product_code="474767A.101",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.176", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_asil_gnb_1)
    ],
)

_airscale_gnb_1 = Airscale(
    common_units=[_asil_gnb_1],
    product_code="473098A",
)

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4, _gnb_ru5, _gnb_ru6, _gnb_ru7, _gnb_ru8],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50568, instance_id=50568
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    ues=[_android],
    core=_core,
    pdus=[
        _pdu_gnb,
        _pdu_gnb_ru1,
        _pdu_gnb_ru2,
        _pdu_gnb_ru3,
        _pdu_gnb_ru4,
        _pdu_gnb_ru5,
        _pdu_gnb_ru6,
        _pdu_gnb_ru7,
        _pdu_gnb_ru8,
    ],
    optical_switches=[_optical_switch],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_2xABIP_3xAVQL_3xAKQJ",
    attenuators=[_attenuator],
)
