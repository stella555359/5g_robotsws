__maintainer__ = "Marta Irasiak-Gaciarek"
__team__ = "VRF_WRO2_T07"
__email__ = "marta.irasiak-gaciarek@nokia.com"
__owner_email__ = ""

from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import JFW
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

_pdu_su = Gude(
    addr="10.44.200.109",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru1 = Gude(
    addr="10.44.200.126",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru2 = Gude(
    addr="10.44.200.110",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_attenuator = JFW(
    ip_addr="10.42.61.94", port=3001, attenuation_port_numbers=range(1, 25), pdu_port=_pdu_su.pdu_ports[8]
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="", v6="", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[9],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="4H211630025",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[1:5],
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.10", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[11],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="1M222706935",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[9:13],
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.18", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[3],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="4H211630008",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[5:9],
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[10],
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHEC",
    serial_number="6Q184414287",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[13:15],
)


_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="A.101",
    product_code="475792A.101",
    serial_number="L1231803533",
    rus=[_ru1, _ru2, _ru3]
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="A.102",
    product_code="475792A.102",
    serial_number="L1232909680",
    rus=[_ru4]
)

_common_unit = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1240404793",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6],
    pdu_port=_pdu_su.pdu_ports[6]
)

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
    v4="10.42.84.35",
    vlan_id=707,
    routing=RoutingInformation(gateway="10.42.84.1", ip_prefix_length=26),
)

_du = DU(Airscale([_common_unit]))

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=55186, instance_id=55186)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.50", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts.dus[0].airscale.common_units[0]
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
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com'
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.63.248", "wro5grrm", password="5gpass!1")

_android_ue1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.63.248",
    ue_pc_port="8001",
    serial_number="N9AIOC145995PX4",
    imsi="310260560003590",
    phone_number='+310260560003590',
    capabilities=["SA_UE"],
    data_transfer=[_iperf_ue],
)

_android_ue2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.63.248",
    ue_pc_port="8001",
    serial_number="FigeaChupa",
    imsi="310260560003591",
    phone_number='+310260560003591',
    capabilities=["NSA_UE"],
    data_transfer=[_iperf_ue],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_ANDROID_SA_NSA_ASILR_ABIPR_ABIPR_3AZHM_AHEC_UTECA",
    attenuator=_attenuator,
    core=_real_core,
    ues=[_android_ue1, _android_ue2],
    pdus=[_pdu_su, _pdu_ru1, _pdu_ru2],
)

tl.max_atten_value = 40
tl.tl_type = "sa/nsa"
tl.smod_slave = False

__all__ = ["tl"]
