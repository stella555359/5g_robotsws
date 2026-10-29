__maintainer__ = "Adam Kropiwnicki"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "adam.kropiwnicki@nokia.com"
__owner_email__ = "adam.kropiwnicki@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.lmi import SerialOverTcp, Remote

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu1 = Gude(
    addr="10.44.205.86",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.87",
    port_numbers=[8, 10],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.205.113",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
)

_pdu4 = Gude(
    addr="10.44.205.114",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)

_pdu5 = Gude(
    addr="10.44.205.116",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
)

_pdu6 = Gude(
    addr="10.44.177.199",
    port_numbers=[1, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5, _pdu6,]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS194202598",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu4.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.10", port=5001),
        ]
    ),
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS201205500",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.35", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu4.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.8", port=5001),
        ]
    ),
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS201205449",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.36", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.9", port=5001),
        ]
    ),
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS200205542",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu5.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.29", port=5001),
        ]
    ),
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7160367139",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[10],
)

_rmod_6 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC.value,
    serial_number="F7173812406",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu6.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1204505682",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1183112977",
    rus=[_rmod_4],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163500207",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu2.pdu_ports[8],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="L1203500035",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu1.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1204300887",
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu6.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1172804328",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.3",
        v6="2a00:8a00:6000:607c::2a03",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a01"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.224.3", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.67",
        v6="2a00:8a00:6000:607c::2b03",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.131",
        v6="2a00:8a00:6000:607c::2c03",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.195",
        v6="2a00:8a00:6000:607c::2d03",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
    ),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.44",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a01"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.224.44", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.108",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.172",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.236",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
    ),
)

_enb_1 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.44.225.131"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.131",
        v6="2a00:8a00:6000:607c::3003",
        vlan_id=922,
        routing_v4=RoutingInformation(gateway="10.44.225.193"),
    ),
    global_bts_id=40822,
    instance_id=40822,
)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50822, instance_id=50822)
_gnb_2 = ClassicalBts(cu=_cu_2, dus=[_du_2],  global_bts_id=50850, instance_id=50850)

_attenuator_1 = TopYoung(
    ip_addr="10.42.61.37",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_attenuator_2 = TopYoung(
    ip_addr="10.42.54.195",
    port=3001,
    attenuation_port_numbers=[9, 10, 11, 12]
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.100", username="ute"),
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
    SshServiceDetails(addr="10.44.149.99", username="ute"),
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
    SshServiceDetails(addr="10.44.149.101", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails("10.42.22.156", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(
    app_server_name='APP_1',
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

# pdn_5gwro1 = PDNTafUeAndroidDetails(
#     entryName="5gwro1",
#     apnName="5gwro1",
#     apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
#     carrierEnabled=True,
#     operatorNumeric="54001",
# )
#
# pdn_5gsawro = PDNTafUeAndroidDetails(
#     entryName="5gsawro",
#     apnName="5gsawro",
#     apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
#     carrierEnabled=True,
#     operatorNumeric="54001",
# )

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="5gsawro"),
    PDN(pdp_type=PDPTypes.IP.value, apn="5gwro1"),
]

_core = RealCore5G(mcc=310, mnc=260)

_mtk_ue_1 = TafUeMtk(
    ue_pc_address="10.42.22.156",
    ue_pc_port=1234,
    serial_number="P2421-T_E266",
    data_transfer=[
        _iperf_ue,
    ],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="351901031120755",
    imsi="310260560003084",
    pdns=_pdns,
    default_pdn_name="5gsawro",
    capabilities=["REAL_UE", "REAL_MTK_UE"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    gnbs=[_gnb_1, _gnb_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIK_ABIL_3xAHCA_ASIB_ABIL_AHCA_ASIA_ABIA_FRGT_UTECA",
    core=_core,
    pdus=_pdus,
    attenuator=[_attenuator_1, _attenuator_2],
    enbs=[_enb_1],
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    ues=[_mtk_ue_1],
)

__all__ = ["tl"]
