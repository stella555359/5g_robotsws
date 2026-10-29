__maintainer__ = "Marin Wolczynski"
__team__ = "VRF_WRO2_T07"
__email__ = "marcin.wolczynski@nokia.com"
__owner_email__ = "marcin.wolczynski@nokia.com"


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
    addr="10.44.200.110",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru2 = Gude(
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

_pdus = [_pdu_su, _pdu_ru, _pdu_ru2]

_RUE_attenuator = JFW(
    ip_addr="10.42.75.83", port=3001, attenuation_port_numbers=[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
)

_RUE_attenuator.pdu_port = _pdu_su.pdu_ports[10]

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.131", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[4], #port4
    serial_number="BL1934G10W8",
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[4:6],
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.132", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[6], #port6
    serial_number="BL1933G10NL",
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[0:2],
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.133", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[5], #port5
    serial_number="BL1933G10O5",
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[2:4],
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[11], #port11
    serial_number="BL1920V007A",
    ru_hw_group="",
    radio_type="AHFIB",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[6:10],
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[5], #port5
    serial_number="BL1907V00L9",
    ru_hw_group="",
    radio_type="AHFIB",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[10:12],
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[6], #port6
    serial_number="K9182845213",
    ru_hw_group="",
    radio_type="AHFIB",
)

_fsp_1 = CapacityUnit(
    addr="172.16.14.146",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222607810",
    rus=[_ru_4, _ru_5, _ru_6]
)

_fsp_2 = CapacityUnit(
    addr="172.16.14.150 ",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008497",
    rus=[_ru_1, _ru_2, _ru_3]
)

_common_unit = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213611498",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_su.pdu_ports[2]
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
    v4="10.42.84.15",
    vlan_id=517,
    routing=RoutingInformation(gateway="10.42.84.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.42.85.204",
    vlan_id=521,
    routing=RoutingInformation(gateway="10.42.85.193", ip_prefix_length=26),
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=55200, global_bts_id=55200)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=310, mnc=260)

_core = RealCore5G(mcc=310, mnc=260)


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.32", username="ute", password="uteUTE!"
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


_realcore_appsrv_ipv4 = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.197.170",
    bind_interface_ip="10.42.197.170",
    user="5g",
    password="2019H@slo"
)

_realcore_appsrv_ipv6 = TafUeAppServer(
    app_server_name="realcore",
    address="10.45.168.53",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:ee05",
    user="syslab",
    password="system"
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.22.237", "wro5grrm", password="5gpass!1")

_iperf_ue_ipv4 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv4,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com'
)

_iperf_ue_ipv6 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv6,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com'
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.20",
    ue_pc_port="8001",
    serial_number="R5CT62PZ25K",
    imsi="310260560002719",
    phone_number='+358485600002719',
    capabilities=["SA_VONR", "REAL_UE_SA", "REAL_UE", "REAL_UE_SA"],
    data_transfer=[_iperf_ue_ipv4],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach='16',
    service_call_detach='16'
)

_android_ue_2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.20",
    serial_number="R5CR418GVZN",
    ue_pc_port="8001",
    imsi="310260560003100",
    phone_number='+358485600003100',
    capabilities=["REAL_UE_NSA"],
    data_transfer=[_iperf_ue_ipv4],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach='16',
    service_call_detach='16'
)


tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="CLOUD_SRAN_5G_CLASSICAL_SA_ASIB_2XABIO_3XAHLOA_AHFII",
    gnbs=[_cbts],
    pdus=_pdus,
    ues=[_android_ue_1, _android_ue_2],
    attenuator=_RUE_attenuator,
    test_pcs=[_test_pc],
    )

tl.max_atten_value = 90
tl.tl_type = "sa/nsa"
tl.smod_slave = False

__all__ = ["tl"]


