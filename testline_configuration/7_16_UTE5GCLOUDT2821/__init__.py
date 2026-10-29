__maintainer__ = "Sebastian Jakubik"
__team__ = "RRM team"
__email__ = "sebastian.jakubik@nokia.com"
__owner_email__ = "sebastian.jakubik@nokia.com"

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
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid, TafUeMtk
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import SerialOverTcp, Remote


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
#
# _pdu1 = Gude(
#     addr="10.44.205.86",
#     port_numbers=[5, 11],
#     model="EPC",
#     version="8221-1",
# )
#
# _pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AWEUA.value,
    serial_number="AH224002452",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104998",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1243204165",
)

_core = RealCore5G(mcc=310, mnc=260)

_smod_1 = Airscale([_fct_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.47.7",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.47.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2a01"
        # ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.47.71",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.47.65"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2b01"
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.42.47.199",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.47.129"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2c01"
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.42.47.199",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.47.193"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2d01"
        # ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.43",
        vlan_id=919,
        routing_v4=RoutingInformation(gateway="10.44.225.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2e01"
        # ),
    ),
)

_du_1 = DU(_smod_1)

# _attenuator = TopYoung(
#     ip_addr="10.42.54.153", port=3001, attenuation_port_numbers=[13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
# )

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50869, instance_id=50869)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.45.172.77", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails("10.44.234.228", "wro5grrm", password="5gpass!1")

# _realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
#                                   address='10.45.168.53',
#                                   user='5g',
#                                   password='2019H@slo',
#                                   )

# _iperf_ue = TafUeDataTransferProtocol(
#     protocol_name='iperf',
#     app_server=_realcore_appsrv,
#     binary_path='/data/data/com.nokia.android.application/',
#     interval=1,
#     server_close_delay=50,
#     bind_ue_ip='10.42.197.170',
#     interface_name='5gsawro',
# )
#
# pdn_5gsawro = PDNTafUeAndroidDetails(
#     entryName="5gsawro",
#     apnName="5gsawro",
#     apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
#     carrierEnabled=True,
#     operatorNumeric="54001",
# )
#
# _android_ue_1 = TafUeAndroid(
#     ssh_connection_details=_ue_pc_ssh,
#     ue_pc_address="10.42.22.159",
#     serial_number="P2411T-E264",
#     imei="351901031120409",
#     imsi="310260560003083",
#     capabilities=["REAL_ANDROID_UE"],
#     data_transfer=[_iperf_ue],
#     network_mode_switch_method="ADB",
#     secret_code='*#*#4636#*#*',
#     voice_call_technology_timeout=60.0,
#     voice_call_dialing_timeout=-1.0,
#     pdns=[pdn_5gsawro],
# )


tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1],
    tl_cloud_topology="VRF_WRO2_T08_ASIM_ABIP_AWEUA",
    core=_core,
    # pdus=_pdus,
    # attenuator=_attenuator,
    # enbs=[_enb_1],
    test_pcs=[_test_pc_1],
    # ues=[_android_ue_1],
)

__all__ = ["tl"]
