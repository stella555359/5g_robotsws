__maintainer__ = "Bartosz Kozłowski"
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
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation, Connection
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.attenuator import JFW, AttenuationPort
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))


_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu1 = Gude(
    addr="10.44.206.131",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu2 = Gude(
    addr="10.42.61.242",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_attenuator = JFW(
    ip_addr="10.42.54.74", port=3001, attenuation_port_numbers=[1, 2], pdu_port = _pdu_atten.pdu_ports[7]
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="cMAA_Gen4.0_8T8R",
    radio_type="AZQH",
    serial_number="L1194009226",
    product_code="475074A.101",
    pdu_port=_pdu1.pdu_ports[9],
    attenuation_ports=[AttenuationPort(attenuator=_attenuator, port_no=1),
                       AttenuationPort(attenuator=_attenuator, port_no=2)]
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRGU",
    radio_type="FRGU",
    serial_number="AS180324512",
    product_code="472956A.102",
    # Possible that the RU is linked directly to the SB, without an attenuator
)

_abil_master = CapacityUnit(
    addr="fsp-5a",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183413597",
    rus=[_ru1],
)
_abil_slave = CapacityUnit(
    addr="fsp-5b",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183413597",
    rus=[_ru1],
)
_abil_loner = CapacityUnit(
    addr="fsp-5c",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183413597",
    rus=[_ru1],
)

_abia = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181620069",
    rus=[_ru2],
)

_smod_nr = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[6],
    hardware_version="473764A.102",
    serial_number="L1203708183",
)

_smod_lte = CommonUnit(
    hardware_type="ASIA",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    hardware_version="473095A.203",
    serial_number="L1184505435",
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.80.18",
        v6="2a00:8a00:6000:607c::5a66",
        vlan_id="459",
        routing_v4=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5a01", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.80.78",
        v6="2a00:8a00:6000:607c::5b62",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.80.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5b01", ip_prefix_length=120),
    ),
    x2u=NetworkAddress(
        v4="10.44.65.213",
        v6="2a00:8a00:6000:607c::5c43",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5c01", ip_prefix_length=120),
    ),
    s1u=NetworkAddress(
        v4="10.44.66.21",
        v6="2a00:8a00:6000:607c::5d43",
        vlan_id=462,
        routing_v4=RoutingInformation(gateway="10.44.66.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5d01", ip_prefix_length=120),
    ),
    ngu=NetworkAddress(
        v4="10.44.66.85",
        v6="2a00:8a00:6000:607c::5e42",
        vlan_id=463,
        routing_v4=RoutingInformation(gateway="10.44.66.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5e01", ip_prefix_length=120),
    ),
)

_du = DU(airscale=Airscale([_smod_nr]), rus=[_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50033, instance_id=50033)

_core = RealCore5G(mcc=555, mnc=10)

_lte = RealEnb(
    system_module=Airscale(common_units=[_smod_lte]),
    x2_link_addr=NetworkAddress(
        v4="10.44.80.83",
        v6="2a00:8a00:6000:607c::5b3e",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    global_bts_id=40033,
    instance_id=40033,
    oam_ip=NetworkAddress(v4="10.44.80.23"),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.18", username="ute", password="ute"
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

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.22", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_lte.system_module.common_units[0]
        )
    ]
)

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo!"
)

_ue_pc_ssh = SshServiceDetails("10.42.63.233", "wro5grrm", password="5gpass!1")

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50
)

_android_ue = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.63.233",
    serial_number="HZQN1876AAK60100182",
    imsi="450057000070125",
    capabilities=["REAL_UE"],
    data_transfer=[_iperf_ue],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIBR_ABILB4_AZQH",
    gnbs=[_cbts],
    enbs=[_lte],
    pdus=[_pdu1, _pdu2],
    ues=[_android_ue],
    core=_core,
    attenuator=_attenuator,
    test_pc=_test_pc,
    test_pcs=[_test_pc, _lte_test_pc]
)

__all__ = ["tl"]
