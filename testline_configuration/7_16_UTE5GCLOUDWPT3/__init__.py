__maintainer__ = "Michal Halucha"
__team__ = "RRM team"
__email__ = "michal.halucha@nokia.com"
__owner_email__ = "michal.halucha@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails, IperfDataTransferIperfOptions,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation, PDNAndroidDetails
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.pdn import PDNTafUeAndroidDetails

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu1 = Gude(
    addr="10.45.177.36",
    port_numbers=[6, 7, 9, 11],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.45.177.41",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.45.172.158",
    port_numbers=[11, 12],
    model="EPC",
    version="8221-1",
)

_pdu4 = Gude(
    addr="10.45.172.155",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdu5 = Gude(
    addr="10.45.172.157",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_pdu6 = Gude(
    addr="10.44.235.7",
    port_numbers=[1,5],
    model="EPC",
    version="8041-1",
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5, _pdu6]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2106K2123",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2037K209Z",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[11],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2037K209U",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AWEWB.value,
    serial_number="YK221100047",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu6.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2037K209Q",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[9],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AWEWB.value,
    serial_number="YK221100034",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu6.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1213006698",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:102",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104682",
    rus=[_rmod_4],
)

_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1183112874",
    rus=[_rmod_5],
)

_fsp_4 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1194210362",
    rus=[_rmod_6],
)

_fsp_5 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143164",
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1214405328",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu3.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1212606595",
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu4.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1214008225",
)

_fct_4 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5],
    pdu_port=_pdu3.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173005111",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])
_smod_4 = Airscale([_fct_4])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)
_du_3 = DU(_smod_3)

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.173.38",
        v6="2a00:8a00:6000:607c::a:90",
        vlan_id=105,
        routing_v4=RoutingInformation(gateway="10.45.173.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::a:81"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.45.173.38", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.45.173.102",
        v6="2a00:8a00:6000:607c::a:d0",
        vlan_id=106,
        routing_v4=RoutingInformation(gateway="10.45.173.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::a:c1"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.45.173.166",
        v6="2a00:8a00:6000:607c::a:110",
        vlan_id=107,
        routing_v4=RoutingInformation(gateway="10.45.173.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::a:101"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.45.173.226",
        v6="2a00:8a00:6000:607c::a:150",
        vlan_id=108,
        routing_v4=RoutingInformation(gateway="10.45.173.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::a:141"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.45.173.226",
        v6="2a00:8a00:6000:607c::a:150",
        vlan_id=109,
        routing_v4=RoutingInformation(gateway="10.45.173.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::a:141"
        ),
    ),
)

_cu_1.m = NetworkAddress(
    v4="10.45.173.38",
    v6="2a00:8a00:6000:607c::a:90",
    vlan_id=105,
    routing=RoutingInformation(gateway="10.45.173.1"),
)

_cu_1.sync = NetworkAddress(
    v4="10.45.174.34",
    v6="2a00:8a00:6000:607c::a:190",
    vlan_id=109,
    routing=RoutingInformation(gateway="10.45.174.1"),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.47.8",
        v6="",
        vlan_id=150,
        routing_v4=RoutingInformation(gateway="10.42.47.1"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.47.8", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.47.72",
        v6="",
        vlan_id=151,
        routing_v4=RoutingInformation(gateway="10.42.47.65"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    x2u=NetworkAddress(
        v4="10.42.47.136",
        v6="",
        vlan_id=152,
        routing_v4=RoutingInformation(gateway="10.42.47.129"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    s1u=NetworkAddress(
        v4="10.42.47.200",
        v6="",
        vlan_id=153,
        routing_v4=RoutingInformation(gateway="10.42.47.193"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    ngu=NetworkAddress(
        v4="10.42.47.200",
        v6="",
        vlan_id=153,
        routing_v4=RoutingInformation(gateway="10.42.47.193"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
)

_cu_2.m = NetworkAddress(
    v4="10.42.47.8",
    v6="",
    vlan_id=150,
    routing=RoutingInformation(gateway="10.42.47.1"),
)

_cu_2.sync = NetworkAddress(
    v4="10.44.198.136",
    v6="",
    vlan_id=154,
    routing=RoutingInformation(gateway="10.44.198.129"),
)

_cu_3 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.47.9",
        v6="",
        vlan_id=150,
        routing_v4=RoutingInformation(gateway="10.42.47.1"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.47.9", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.47.73",
        v6="",
        vlan_id=151,
        routing_v4=RoutingInformation(gateway="10.42.47.65"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    x2u=NetworkAddress(
        v4="10.42.47.137",
        v6="",
        vlan_id=152,
        routing_v4=RoutingInformation(gateway="10.42.47.129"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    s1u=NetworkAddress(
        v4="10.42.47.201",
        v6="",
        vlan_id=153,
        routing_v4=RoutingInformation(gateway="10.42.47.193"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
    ngu=NetworkAddress(
        v4="10.42.47.201",
        v6="",
        vlan_id=153,
        routing_v4=RoutingInformation(gateway="10.42.47.193"),
        routing_v6=RoutingInformation(
            gateway=""
        ),
    ),
)

_cu_3.m = NetworkAddress(
    v4="10.42.47.9",
    v6="",
    vlan_id=150,
    routing=RoutingInformation(gateway="10.42.47.1"),
)

_cu_3.sync = NetworkAddress(
    v4="10.44.198.137",
    v6="",
    vlan_id=154,
    routing=RoutingInformation(gateway="10.44.198.129"),
)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50859, instance_id=50859)
_gnb_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=50858, instance_id=50858)
_gnb_3 = ClassicalBts(cu=_cu_3, dus=[_du_3], global_bts_id=50856, instance_id=50856)\

_enb_1 = RealEnb(
    system_module=_smod_4,
    rms=[_rmod_5],
    oam_ip=NetworkAddress("10.42.46.8"),
    x2_link_addr=NetworkAddress(
        v4="10.42.46.8",
        v6="",
        vlan_id=154,
        routing_v4=RoutingInformation(gateway="10.42.46.1"),
    ),
    global_bts_id=40858,
    instance_id=40858,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.71.23", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.71.25", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_3 = TestPc(
    SshServiceDetails(addr="10.42.71.24", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_3.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_4 = TestPc(
    SshServiceDetails(addr="10.42.71.26", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails("10.44.234.142", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.45.168.53',
                                  user='5g',
                                  password='2019H@slo',
                                  )

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    bind_ue_ip='10.42.197.170'
)

pdn_n26HOwro = PDNTafUeAndroidDetails(
    entryName="n26HOwro",
    apnName="n26HOwro",
    apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
    carrierEnabled=True,
    operatorNumeric="54001",
)

pdn_n26wro = PDNTafUeAndroidDetails(
    entryName="n26wro",
    apnName="n26wro",
    apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
    carrierEnabled=True,
    operatorNumeric="54001",
)

UE_1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.234.142",
    serial_number="R5CT20GCN0F",
    imsi="540017000000066",
    capabilities=["UE_1"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach=16,
    service_call_detach=16,
)

SDX70 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.234.142",
    serial_number="25df1db0",
    imsi="540017000000161",
    capabilities=["SDX70"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro, pdn_n26HOwro],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1, _gnb_2, _gnb_3],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIBL_2xABIO_3xAHFIC_AEWB_ASIBR_ABIL_AHFIC_ASILL_ABIL_AWEWB_UTECA",
    core=_core,
    pdus=_pdus,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3, _test_pc_4],
    ues=[UE_1, SDX70],
)

__all__ = ["tl"]
