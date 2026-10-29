__maintainer__ = "Bartosz Galczynski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.galczynski@nokia.com"
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
    addr="10.42.208.152",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru1 = Gude(
    addr="10.44.206.130",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_ru2 = Gude(
    addr="10.44.206.117",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_attenuator = JFW(
    ip_addr="10.42.54.23", port=3001, attenuation_port_numbers=range(1, 25), pdu_port=_pdu_su.pdu_ports[10]
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[5],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="1M222707023",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[1:5],
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.10", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[7],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="1M222707014",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[9:13],
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.18", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[9],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="1M222603348",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[5:9],
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[12],
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHEC",
    serial_number="6Q190516653",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[13:15],
)


_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="A.101",
    product_code="475792A.101",
    serial_number="L1232004050",
    rus=[_ru1, _ru2, _ru3]
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="A.Y16",
    product_code="475792A.Y16",
    serial_number="L1224710344",
    rus=[_ru4]
)

_common_unit = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1204505469",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6],
    pdu_port=_pdu_su.pdu_ports[8]
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
    v4="10.44.231.213",
    vlan_id=707,
    routing=RoutingInformation(gateway="10.44.231.193", ip_prefix_length=26),
)

_du = DU(Airscale([_common_unit]))

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51040, instance_id=51040)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.210", username="ute", password="ute"
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
    address="10.45.168.52",
    bind_interface_ip="10.45.168.52",
    user="syslab",
    password="system"
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    #binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.224.143", "wro5grrm", password="5gpass!1")

_android_ue1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.224.143",
    ue_pc_port="8001",
    serial_number="HZQN1876AAK60100468",
    imsi="001016900022983",
    phone_number='+358485630022983',
    capabilities=["SA_UE"],
    data_transfer=[_iperf_ue],
    service_call_attach=14,
    service_call_detach=14,
)

_android_ue2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.224.143",
    ue_pc_port="8001",
    serial_number="FigeaChupa",
    imsi="001016900022984",
    phone_number='+358485630022984',
    capabilities=["NSA_UE"],
    data_transfer=[_iperf_ue],
)

_android_ue3 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.224.143",
    ue_pc_port="8001",
    serial_number="HZQN1876FAL33100418",
    imsi="001016900022985",
    phone_number='+358485630022985',
    capabilities=["VONR_UE"],
    data_transfer=[_iperf_ue],
    service_call_attach=14,
    service_call_detach=14,
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_ANDROID_SA_NSA_ASILR_ABIPR_ABIPR_3AZHM_AHEC_2AHLOA_UTECA",
    attenuator=_attenuator,
    core=_real_core,
    ues=[_android_ue1, _android_ue2, _android_ue3],
    pdus=[_pdu_su, _pdu_ru1, _pdu_ru2],
)

tl.max_atten_value = 40
tl.tl_type = "sa/nsa"
tl.smod_slave = False

__all__ = ["tl"]
