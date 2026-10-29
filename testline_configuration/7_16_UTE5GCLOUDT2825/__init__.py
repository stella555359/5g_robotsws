__maintainer__ = "Michal Gradowski-Nowak"
__team__ = "RRM team"
__email__ = "michal.gradowski-nowak@nokia.com"
__owner_email__ = "michal.gradowski-nowak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.pdu import Gude
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.177.8",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="EPC",
    version="8220-1",
)

_pdu2 = Gude(
    addr="10.44.177.5",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.177.2",
    port_numbers=[2, 5, 6, 11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1214609088",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1214609085",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1214707161",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1214707164",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1214609086",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1214609087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K916473535",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[11],
)

_rmod_8 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.FXCC.value,
    serial_number="K913921799",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[6],
)

_rmod_9 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9182603795",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204505519",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225100183",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204509707",
    rus=[],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="RW192105811",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1231605988",
    pdu_port=_pdu2.pdu_ports[1],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171208999",
    pdu_port=_pdu3.pdu_ports[2],
)

_core = RealCore5G(mcc=450, mnc=5)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.38",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.102",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.166",
        vlan_id=906,
    ),
    s1u=NetworkAddress(
        v4="10.44.224.230",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.230",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
)

_du = DU(_smod_1)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=50844, instance_id=50844)

_enb_1 = RealEnb(
    system_module=_smod_2,
    oam_ip=NetworkAddress("10.44.225.164"),
    x2_link_addr=NetworkAddress(v4="10.44.225.164",
                                v6="",
                                vlan_id=921,
                                routing_v4=RoutingInformation(gateway="10.44.225.129")),
    global_bts_id=40845,
    instance_id=40845,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.194.202", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc = TestPc(default_ssh_connection_details=SshServiceDetails(addr="10.42.22.86",
                                                                 username="wro5grrm",
                                                                 password="5gpass!1",
                                                                 port="9092"))

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.75.195", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.45.168.53',
                                  user='5g',
                                  password='2019H@slo')

_iperf_ue_samsung = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application',
    interval=1,
    server_close_delay=50,
    interface_name='rmnet_data1',
    bind_ue_ip='10.42.197.170'
)

_iperf_ue_asus = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application',
    interval=1,
    server_close_delay=50,
    interface_name='ccmni1',
    bind_ue_ip='10.42.197.170'
)

_pdn_n26wro = PDNTafUeAndroidDetails(
    entryName='n26wro',
    apnName='n26wro',
    apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
    carrierEnabled=True,
    operatorNumeric='4505'
)

_asus = TafUeAndroid(
    ssh_connection_details=_ue_pc.default_ssh_connection_details,
    ue_pc_address="10.42.22.86",
    serial_number="0123456789ABCDEF",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "ASUS"],
    data_transfer=[_iperf_ue_asus],
    network_mode_switch_method='ADB',
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[_pdn_n26wro]
)

_samsung_s23 = TafUeAndroid(
    ssh_connection_details=_ue_pc.default_ssh_connection_details,
    ue_pc_address="10.42.22.86",
    serial_number="R3CW506NKDP",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "SAMSUNG_S23"],
    data_transfer=[_iperf_ue_samsung],
    network_mode_switch_method='ADB',
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[_pdn_n26wro]
)

tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIL_3xABIO_6xAQQL",
    core=_core,
    pdus=[_pdus],
    ues=[_samsung_s23, _asus],
    test_pcs=[_test_pc_1, _test_pc_2],
)

__all__ = ["tl"]
