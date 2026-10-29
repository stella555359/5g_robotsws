__maintainer__ = "Filip Jozefczak"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "filip.jozefczak@nokia.com"
__owner_email__ = "filip.jozefczak@nokia.com"


from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import EPCSim, RealCore5G
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import JFW
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_pdu_ru = Gude(
    addr="10.44.200.126",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru_2 = Gude(
    addr="10.44.200.127",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_su = Gude(
    addr="10.44.200.109",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdus = [_pdu_su, _pdu_ru, _pdu_ru_2]

_RUE_attenuator = JFW(
    ip_addr="10.42.61.215", port=3001, attenuation_port_numbers=range(1, 25)
)

_RUE_attenuator.pdu_port = _pdu_ru_2.pdu_ports[9]

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru_2.pdu_ports[8],
    serial_number="EB2248R0177",
    ru_hw_group="ScRMr6.1_4T4R",
    radio_type="AWHTA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[12:16],
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru_2.pdu_ports[7],
    serial_number="DC1936000PK",
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[8:12],
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.2.6", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[8],
    serial_number="AH221201836",
    ru_hw_group="cMAA_gen6.1_8T8R",
    radio_type="AZHL",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[0:4],
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.2.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[6],
    serial_number="1M203800434",
    ru_hw_group="cMAA_gen6.1_8T8R",
    radio_type="AZQO",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[4:8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20 ",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222606838",
    rus=[_ru_1]
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222605425",
    rus=[_ru_2]
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210301891",
    rus=[_ru_3, _ru_4]
)

_abio_master = CapacityUnit(addr="fsp-1a", hardware_type="ABIO")
_abio_slave = CapacityUnit(addr="fsp-1b", hardware_type="ABIO")
_abio_loner = CapacityUnit(addr="fsp-1c", hardware_type="ABIO")

_common_unit = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224708406",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_su.pdu_ports[5]
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_cu.m = NetworkAddress(
    v4="10.42.84.19",
    vlan_id=517,
    routing=RoutingInformation(gateway="10.42.84.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.42.85.142",
    vlan_id=520,
    routing=RoutingInformation(gateway="10.42.85.129", ip_prefix_length=26),
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=51701, global_bts_id=51701)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(v4="10.27.28.136", vlan_id=None)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_core = RealCore5G(mcc=555, mnc=10)


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.51", username="ute", password="ute"
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

_nuc_ue_pc_ssh = SshServiceDetails("10.42.63.196", "wro5grrm", password="5gpass!1")

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_realcore_appsrv,
    interval=1,
    server_close_delay=50,
    interface_name="everywhere",
)


_android_ue = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.63.196",
    ue_pc_port="8001",
    serial_number="Figeaczyna",
    imsi="234300100000115",
    phone_number="+358485620000525",
    capabilities=["REAL_UE_SA"],
    data_transfer=[_iperf_ue],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
)

tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HALFRACK_SA_MEDIATEK_ASIL_3xABIO_AWHTA_AHFIC_AZHL_AZQO_GNB",
    gnbs=[_cbts],
    pdus=_pdus,
    ues=[_android_ue],
    attenuator=_RUE_attenuator,
    test_pcs=[_test_pc],
    )

tl.max_atten_value = 90
tl.tl_type = "sa/nsa"
tl.smod_slave = False

tl.cell_0_7_ports = [13, 14, 15, 16]  # AWHTA n79
tl.cell_1_2_ports = [1, 2, 3, 4]  # AZHL  n41
tl.cell_3_4_ports = [5, 6, 7, 8]  # AZQO  n77
tl.cell_5_6_ports = [9, 10, 11, 12]  # AHFIC n25 n66
tl.all_cells_ports = (
    tl.cell_0_7_ports + tl.cell_1_2_ports + tl.cell_3_4_ports + tl.cell_5_6_ports
)
tl.cell_with_no_CC = 7

__all__ = ["tl"]
