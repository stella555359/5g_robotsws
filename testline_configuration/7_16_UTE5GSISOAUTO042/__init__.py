__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__email__ = "I_EXT_5G_SISO_CRT@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAt, TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_gnb = ATEN(addr="10.44.167.209", port_numbers=[8])
_pdu_azhl = Gude(addr="10.44.167.207", port_numbers=[2, 3, 4], model="EPC", version="8221-1")
_pdu_avql = Gude(addr="10.44.167.206", port_numbers=[1], model="EPC", version="8220-1")
_pdu_aqqn = Gude(addr="10.44.167.205", port_numbers=[1, 2], model="EPC", version="8220-1")

_attenuator = TopYoung(
    ip_addr="10.45.167.176", port=3001, attenuation_port_numbers=range(1, 25), serial_number="30022062923"
)

_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AVQL",
    serial_number="L1233108786",
    product_code="476204A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.44.41.105", port=3000),
                                    Remote(addr="10.44.41.105", port=3001)
                                    ]),
    pdu_port=_pdu_avql.pdu_ports[1],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AQQN",
    serial_number="L1224413035",
    product_code="093176A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.44.41.100", port=2003)]),
    pdu_port=_pdu_aqqn.pdu_ports[1],
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AQQN",
    serial_number="L1224413034",
    product_code="093176A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.44.41.101", port=2003)]),
    pdu_port=_pdu_aqqn.pdu_ports[2],
)

_ru_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZHL",
    serial_number="AH221500786",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.44.41.103", port=2003)]),
    pdu_port=_pdu_azhl.pdu_ports[4],
)

_ru_5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZHL",
    serial_number="AH212600308",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.44.41.102", port=2003)]),
    pdu_port=_pdu_azhl.pdu_ports[3],
)

_ru_6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZHL",
    serial_number="AH221500744",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.44.41.104", port=2003)]),
    pdu_port=_pdu_azhl.pdu_ports[2],
)

_abip_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A101",
    serial_number="L1231811781",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)

_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_loner],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1232304192",
)

_airscale_gnb_1 = Airscale(common_units=[_asil])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.25.252",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="2a00:8a00:6000:6f00::1:3f8", vlan_id=401),
    x2u=NetworkAddress(v4="2a00:8a00:6000:6f00::1:3f8", vlan_id=401),
    s1u=NetworkAddress(v4="2a00:8a00:6000:6f00::1:3f8", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50675, instance_id=50675
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.7", username="ute", password="ute"
    ),
    connections=[_asil],
)

_appserver_ssh_1 = TafUeAppServer(
    app_server_name="APP_Server_WG",
    address="10.44.184.246",
    user="ranpz",
    password="Pass4Testers!",
    expected_prompt="ranpz@wg-srn-iperf-728:~",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name='iperf',                                            
    app_server=_appserver_ssh_1,
    interval=1,
)

_android = TafUeAndroid(
    serial_number="M9AIKN01N632W8P",
    ue_pc_address="10.42.36.162",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.36.162", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_data_transfer_iperf],
    network_mode_switch_method='secretcode',
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABIPB1_AVQL_2x_AQQN_3xAZHL",
    pdus=[_pdu_gnb, _pdu_azhl, _pdu_avql, _pdu_aqqn],
    attenuators=[_attenuator],
)
