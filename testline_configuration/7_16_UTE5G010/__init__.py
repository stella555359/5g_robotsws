__maintainer__ = "Mariusz Waczynski"
__team__ = "MN RAN RD VRF WRO1 3"
__email__ = "mariusz.waczynski@nokia.com"
__owner_email__ = "mariusz.waczynski@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu1 = Gude(
    addr="10.45.172.149",
    port_numbers=[1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
version="8041-1",
)

_pdu2 = Gude(
    addr="10.45.177.40",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1"
)

_pdus = [_pdu1, _pdu2]


_abio_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_abio_du2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asil_du1 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[_abio_du1],
)

_asil_du2 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[3],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    capacity_units=[_abio_du2],
)

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.1.1.2", vlan_id=201),
    x2u=NetworkAddress(v4="10.1.1.2", vlan_id=201),
    s1u=NetworkAddress(v4="10.1.1.2", vlan_id=201),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=201),
)

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.1.1.3", vlan_id=201),
    x2u=NetworkAddress(v4="10.1.1.3", vlan_id=201),
    s1u=NetworkAddress(v4="10.1.1.3", vlan_id=201),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=201),
)


_du1 = DU(airscale=Airscale(common_units=[_asil_du1]))
_du2 = DU(airscale=Airscale(common_units=[_asil_du2]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1], global_bts_id=55217, instance_id=55217)
_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2], master=_cbts1)
_cbts1.slave = _cbts2


_ue1 = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.92", hardware_type="ABIO"),
                ],
            )
        ]
    ),
)

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.42.61.65',
                                  bind_interface_ip="10.44.43.71",
                                  user='5g',
                                  password='2019H@slo',
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    bind_ue_ip='0.0.0.1'
)

_ue_pc_ssh = SshServiceDetails("10.45.172.214", "wro5gsiso", password="oZPS0POrRieRtu")

_ue2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.45.172.214",
    serial_number="xxxxxxx",
    imsi="00000000000000000",
    capabilities=["UE_1"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    secret_code='*#*#4636#*#*',
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach=16,
    service_call_detach=16,
)


_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.56.70",
    user="vrfwro1",
    password="VrfWroP@ss1!",
    expected_prompt="vrfwro1@wpt-srn-iperf-2167-100g\:\~\$",
    bind_interface_ip="10.42.56.70",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server,
    interface_name='5gwrowpt1',
    interval=1,
    version=2
)

_ue3 = TafUeAt(
    com_port="10",
    serial_number="5a13fb8e",
    ue_pc_address="10.45.172.214",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="9955",
    data_transfer=[_data_transfer_iperf],
    capabilities=["ASKEY_1_APOLLO"],
    pdu_port=_pdu2.pdu_ports[11]
)

_ue4 = TafUeAt(
    com_port="8",
    serial_number="d9f67e4f",
    ue_pc_address="10.45.172.214",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="9955",
    data_transfer=[_data_transfer_iperf],
    capabilities=["ASKEY_2_APOLLO"],
    pdu_port=_pdu2.pdu_ports[3]
)

_ue5 = TafUeAt(
    com_port="3",
    serial_number="d783231f",
    ue_pc_address="10.45.172.214",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="9955",
    data_transfer=[_data_transfer_iperf],
    capabilities=["ASKEY_3_APOLLO"],
    pdu_port=_pdu2.pdu_ports[10]
)

_ue6 = TafUeAt(
    com_port="7",
    serial_number="43881403",
    ue_pc_address="10.45.172.214",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="9955",
    data_transfer=[_data_transfer_iperf],
    capabilities=["ASKEY_4_APOLLO"],
    pdu_port=_pdu2.pdu_ports[4]
)


_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.145.58", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ue3,
    ],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.145.59", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HYBRID_2xASIM_3xABIP",
    ues=[_ue1, _ue3, _ue4, _ue5, _ue6],
    pdus=_pdus,
)

__all__ = ["tl"]