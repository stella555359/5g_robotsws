__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "bartosz.1.kozlowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import (
    DU,
    RU,
    RealEnb,
    NetworkAddress,
    RoutingInformation,
    Connection,
)
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))



_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(v4="10.27.28.136", vlan_id=None)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_abio_master = CapacityUnit(addr="fsp-1a", hardware_type="ABIO")
_abio_slave = CapacityUnit(addr="fsp-1b", hardware_type="ABIO")
_abio_loner = CapacityUnit(addr="fsp-1c", hardware_type="ABIO")

_pdu_1 = Gude(
    addr="10.44.177.157",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1"
    # SMOD port 1 PDU rack 2364     # AWHTA port 4 PDU rack 2364        # Atten port A5 PDU rack 2364
)

_pdu_2 = Gude(
    addr="10.44.205.116",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1"
    # AZQO port 6 PDU5 wro8     # AZHL port 7 PDU5 wro8     # AHFIC port 11 PDU5 wro8
)

_attenuator = JFW(
    ip_addr="10.42.221.218",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    pdu_port=_pdu_1.pdu_ports[5],
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
    v4="10.44.224.58",
    vlan_id=915,
    routing=RoutingInformation(gateway="10.44.224.1", ip_prefix_length=26),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="ScRMr6.1_4T4R",
    radio_type="AWHTA",
    serial_number="EB2150R0797",
    pdu_port=_pdu_1.pdu_ports[4],
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="cMAA_Gen6.1_8T8R",
    radio_type="AZQO",
    serial_number="1M203800457",
    pdu_port=_pdu_2.pdu_ports[6],
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="cMAA_Gen6.1_8T8R",
    radio_type="AZHL",
    serial_number="AH211900798",
    pdu_port=_pdu_2.pdu_ports[7],
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="DC19360014B",
    pdu_port=_pdu_2.pdu_ports[11],
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213611498",
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_ru1, _ru2, _ru3, _ru4]
)

_airscale = Airscale([_common_unit])

_du = DU(_airscale, rus=[_ru1, _ru2, _ru3, _ru4])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51701, instance_id=51701)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.63.231", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    user="syslab",
    password="Pass4System!",
    bind_interface_ip="10.44.184.246",
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_realcore_appsrv,
    interval=1,
    server_close_delay=50,
    interface_name="everywhere",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.52", username="ute", password="ute"
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

_android_ue = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.63.231",
    ue_pc_port="8001",
    serial_number="Figeaczyna",
    imsi="234300100000115",
    capabilities=["REAL_UE_SA"],
    data_transfer=[_iperf_ue],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_MEDIATEK_ASILL_ABIOB1B2B3_AWHTA_AHFIC_AZHL_AZQO",
    attenuators=[_attenuator],
    core=_real_core,
    ues=[_android_ue],
    pdus=[_pdu_1, _pdu_2],
)

tl.max_atten_value = 90
tl.qxdm_username = "krystian.wojakiewicz@nokia.com"
tl.qxdm_password = "Password2"

tl.cell_0_7_ports = [13, 14, 15, 16]  # AWHTA n79
tl.cell_1_2_ports = [9, 10, 11, 12]  # AZHL  n41
tl.cell_3_4_ports = [1, 2, 3, 4]  # AZQO  n77
tl.cell_5_6_ports = [17, 18, 19, 20]  # AHFIC n25 n66
tl.all_cells_ports = (
    tl.cell_0_7_ports + tl.cell_1_2_ports + tl.cell_3_4_ports + tl.cell_5_6_ports
)
tl.cell_with_no_CC = 7

__all__ = ["tl"]
