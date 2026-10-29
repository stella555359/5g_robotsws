__team__ = "VRF_WRO1_T04_01"
__maintainer__ = "Adam Masztalerz"
__email__ = "adam.masztalerz@nokia.com"

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
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.197.170",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.170",
)

_iperf = TafUeDataTransferProtocol(
    app_server=_appserver_ssh,
    protocol_name="iperf",
    version=2,
)

_android = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.172", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M6AIKN009207JV9",
    ue_pc_address="10.42.22.172",
    qualcomm_prototype=False,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    data_transfer=[_iperf],
    network_mode_switch_method='secretcode',
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.68.172",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b42b", vlan_id=909),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b42b", vlan_id=909),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b42b", vlan_id=909),
)

_pdu_gnb = Gude(addr="10.44.205.243", port_numbers=[11], model="EPC", version="8221-1")

_pdu_gnb_ru1 = Gude(
    addr="10.44.177.233", port_numbers=[8], model="EPC", version="8221-1"
)

_pdu_gnb_ru2 = Gude(
    addr="10.44.177.233", port_numbers=[9], model="EPC", version="8221-1"
)

_pdu_gnb_ru3 = Gude(
    addr="10.44.205.17", port_numbers=[4], model="EPC", version="8221-1"
)

_pdu_gnb_ru4 = Gude(
    addr="10.44.205.243", port_numbers=[4], model="EPC", version="8221-1"
)

_pdu_gnb_ru5 = Gude(
    addr="10.44.205.243", port_numbers=[2], model="EPC", version="8221-1"
)

_pdu_gnb_ru6 = Gude(
    addr="10.44.177.233", port_numbers=[10], model="EPC", version="8221-1"
)

_pdu_gnb_ru7 = Gude(
    addr="10.44.177.233", port_numbers=[11], model="EPC", version="8221-1"
)

_pdu_gnb_ru8 = Gude(
    addr="10.44.177.233", port_numbers=[12], model="EPC", version="8221-1"
)

_pdu_gnb_ru9 = Gude(
    addr="10.44.177.79", port_numbers=[10], model="EPC", version="8221-1"
)

_gnb_ru1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQG",
    serial_number="L1243308121",
    product_code="476640A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.202", port=3000),
                                    Remote(addr="10.255.33.202", port=3001)]),
    pdu_port=_pdu_gnb_ru1.pdu_ports[8],
)

_gnb_ru2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQG",
    serial_number="L1243308124",
    product_code="476640A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.201", port=3000),
                                    Remote(addr="10.255.33.201", port=3001)]),
    pdu_port=_pdu_gnb_ru2.pdu_ports[9],
)

_gnb_ru3 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQQA",
    serial_number="L1241908602",
    product_code="476596A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.200", port=3000),
                                    Remote(addr="10.255.33.200", port=3001)]),
    pdu_port=_pdu_gnb_ru3.pdu_ports[4],
)

_gnb_ru4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="AS173810414",
    product_code="472956A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.128",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru4.pdu_ports[4],
)

_gnb_ru5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="AS180324514",
    product_code="472956A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.129",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru5.pdu_ports[2],
)

_gnb_ru6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="EA205150681",
    product_code="474253A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_pdu_gnb_ru6.pdu_ports[10],
)

_gnb_ru7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="EA220653544",
    product_code="474253A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130",
        username="rfsw",
        password="ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=",
    ),
    pdu_port=_pdu_gnb_ru7.pdu_ports[11],
)

_gnb_ru8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="EA213657734",
    product_code="474253A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="rfsw",
        password="ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=",
    ),
    pdu_port=_pdu_gnb_ru8.pdu_ports[12],
)

_gnb_ru9 = RU(
    ru_hw_group="FRMr4.0a_2T4R_Corona",
    radio_type="FRCJ",
    serial_number="EA182610785",
    product_code="473818A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru9.pdu_ports[10],
)

_asog_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASOG",
    serial_number="L1240913019",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.87", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_asog_gnb_1)
    ],
)

_airscale_gnb_1 = Airscale(common_units=[_asog_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4, _gnb_ru5, _gnb_ru6, _gnb_ru7, _gnb_ru8, _gnb_ru9],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50544, instance_id=50544
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
        _pdu_gnb_ru9,
    ],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOG_2xAVQG_AVQQA_2xFRGU_3xAHEH_FRCJ",
)