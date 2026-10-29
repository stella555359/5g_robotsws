__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = ""

from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import HBTE
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.enb import RealEnb

_pdu_su = Gude(
    addr="10.44.205.189",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru1 = Gude(
    addr="10.44.177.30",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru2 = Gude(
    addr="10.44.177.28",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru3 = Gude(
    addr="10.44.177.29",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru4 = Gude(
    addr="10.44.177.35",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_attenuator = HBTE(
    ip_addr="10.42.54.167",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 23, 24],
    model="PA-16-16-6-127-0.5-B-S",
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.137", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[6],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="ARHA",
    serial_number="1M205131729",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[1:5],
)

_rmod_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.138", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[5],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="ARHA",
    serial_number="1M205014950",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[9:13],
)

_rmod_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.139", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[5],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="ARMA",
    serial_number="1M223316535",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[5:9],
)

_rmod_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.134", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[6],
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="ARGA",
    serial_number="K9224010603",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[13:15],
)

_rmod_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.135", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[3],
    ru_hw_group="FRMr5_4T4R",
    radio_type="ARGA",
    serial_number="K9224010639",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[19:23],
)

_rmod_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.136", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[4],
    ru_hw_group="FRMr5_4T4R",
    radio_type="AREA",
    serial_number="K9224143130",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[15:19],
)

_rmod_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.140", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[5],
    ru_hw_group="FRMr5_4T4R",
    radio_type="AREA",
    serial_number="K9224143128",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[15:19],
)

_rmod_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru4.pdu_ports[3],
    ru_hw_group="FRMr5_4T4R",
    radio_type="AEQQ",
    serial_number="1M210912470",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[15:19],
)

_rmod_9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.10", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru4.pdu_ports[6],
    ru_hw_group="FRMr5_4T4R",
    radio_type="AEQQ",
    serial_number="1M210912469",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[15:19],
)

_rmod_10 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.18", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru4.pdu_ports[9],
    ru_hw_group="FRMr5_4T4R",
    radio_type="AEQQ",
    serial_number="1M210912466",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[15:19],
)

_rmod_11 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[2],
    ru_hw_group="FRMr5_4T4R",
    radio_type="ARPA",
    serial_number="F7201207468",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[15:19],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="L1171612755",
    rus=[_rmod_6, _rmod_7]
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="L1172902464",
    rus=[_rmod_4, _rmod_5]
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A.104",
    product_code="475266A.104",
    serial_number="L1213905484",
    rus=[_rmod_1, _rmod_2, _rmod_3]
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="A.103",
    product_code="475266A.103",
    serial_number="L1211201061",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_11]
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="A.104",
    product_code="475266A.104",
    serial_number="L1213905478",
    rus=[_rmod_8, _rmod_9, _rmod_10]
)

_fct_1 = CommonUnit(                    # master
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_su.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1212713894",
)

_fct_2 = CommonUnit(                    # slave
    SshServiceDetails(addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_5, _fsp_6],
    pdu_port=_pdu_su.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1212713748",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.41.16"),
    global_bts_id=41807,
    instance_id=41807,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2,
                      rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7,
                           _rmod_8, _rmod_9, _rmod_10, _rmod_11],
                      master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_cu.m = NetworkAddress(
    v4="10.42.41.16",
    vlan_id=540,
    routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=26),
)
_du_1 = DU(_smod_1)

_du_2 = DU(_smod_2)


_gnb_sbts_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=41807, instance_id=51807)
_gnb_sbts_2 = ClassicalBts(cu=_cu, dus=[_du_2], master=_gnb_sbts_1)

_gnb_sbts_1.slave = _gnb_sbts_2

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=234, mnc=30)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.26", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_sbts_1.system_module.common_units[0]
        )
    ]
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.143", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_sbts_2.system_module.common_units[0]
        )
    ]
)

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.197.170",
    bind_interface_ip="10.42.197.170",
    user="5g",
    password="2019H@slo"
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    interval=1,
    server_close_delay=50,
    interface_name="everywhere"
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.224.9", "wro5grrm", password="5gpass!1")

_android_mtk_ue = TafUeAndroid(                 # MTK
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.224.9",
    ue_pc_port="8080",
    serial_number="DUJAC_POZYCZONY",
    imsi="234300100000535",
    phone_number='+358485620000535',
    capabilities=["MTK_UE"],                # MTK_UE            REAL_UE
    data_transfer=[_iperf_ue],
)

_android_asus_ue = TafUeAndroid(                    # ASUS
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.224.9",
    ue_pc_port="8080",
    serial_number="NBAIOC196905DY4",
    imsi="234300100000115",
    phone_number='+358485620000115',
    capabilities=["ASUS_UE"],         # ASUS_UE           REAL_UE
    data_transfer=[_iperf_ue],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_gnb_sbts_1, _gnb_sbts_2],
    tl_cloud_topology=
    "CLOUD_SRAN_CLASSICAL_FULLRACK_SA_NSA_3xANDROID_2xASIB_3xABIO_2xABIA_2xARHA_ARMA_2xARGA_2xAREA_3xAEQQ_ARPA_GNB",
    attenuator=_attenuator,
    core=_real_core,
    ues=[_android_asus_ue, _android_mtk_ue],
    pdus=[_pdu_su, _pdu_ru1, _pdu_ru2, _pdu_ru3, _pdu_ru4],
)

tl.max_atten_value = 40
tl.tl_type = "sa/nsa"
tl.smod_slave = False

__all__ = ["tl"]
