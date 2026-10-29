__maintainer__ = "Jakub Klein"
__team__ = "MI RAN RD VRF WRO1 3"
__email__ = "jakub.klein@nokia.com"
__owner_email__ = "jakub.klein@nokia.com"

import os
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RoutingInformation
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.radio import RU
from taf.config.testline.optical_switch import OpticalSwitch, Leoni
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.ue import TafUeAt
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import (
    TafUeDataTransferProtocol,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

#_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
#    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
#)

_opt_sw_1 = Leoni(addr="10.45.176.148", model="mol 6x(2x6)", port=3001)

_vm_1_ssh = SshServiceDetails(addr="10.42.71.69", username="ute", password="ute")

_lmp_ssh = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
    proxy=_vm_1_ssh,
)
_lmp_http = HttpConnectionDetails(
    addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
)
_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)
_ue_pc_ssh = SshServiceDetails("10.44.234.212", "wro5gsiso", password="oZPS0POrRieRtu")


_pdu_1 = Gude(addr="10.45.172.133", port_numbers=[8], model="EPC", version="8221-1")
_pdu_2 = Gude(addr="10.45.177.27", port_numbers=[6], model="EPC", version="8221-1")
_pdu_3 = Gude(addr="10.45.177.18", port_numbers=[8, 9], model="EPC", version="8221-1")

_attenuator_1 = TopYoung(
    ip_addr="10.44.234.47",
    port=28888,
    attenuation_port_numbers=range(1, 129),
    model="MCS2350A2-128B16-A4",
)

_rmod_1 = RU(
    ru_hw_group="hw_group",
    radio_type="AQQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="hw_group",
    radio_type="AQQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="fsp2s0icom",
    hardware_type="ABIP",
    hardware_version="A.102",
    rus=[_rmod_2],
)
_fct_0 = CommonUnit(
    lmp_connection=_lmp_ssh,
    capacity_units=[_fsp_1],
    hardware_type="ASIM",
    hardware_version="A.104",
    pdu_port=_pdu_1.pdu_ports[8],
)
_airscale_1 = Airscale(common_units=[_fct_0])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    oam_ssh_connection_details=_lmp_ssh,
    oam_http_connection_details=_lmp_http,
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    x2u=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    s1u=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    xnc=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    xnu=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    ngc=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
    ngu=NetworkAddress(
        v4="",
        routing_v4=RoutingInformation(gateway=""),
        v6="",
        routing_v6=RoutingInformation(gateway=""),
        vlan_id=0,
    ),
)
_du_1 = DU(_airscale_1, rus=[_rmod_1, _rmod_2])

_cbts_1 = ClassicalBts(
    cu=_cu_1, dus=[_du_1], global_bts_id=50976, instance_id=50976
)
_vm_1_lmp_connection = Connection(
    interface="eth1",
    device=_cbts_1.dus[0].airscale.common_units[0],
    interface_type="lmp",
)
_vm_1 = TestPc(
    default_ssh_connection_details=_vm_1_ssh, connections=[_vm_1_lmp_connection]
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
    # interface_name='',
    # interval=1,
    # version=2,
)

_data_transfer_iperf_android = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server,
    # interface_name='5gwrowpt1',
    # interval=1,
    # version=2,
)

_at_1 = TafUeAt(
    com_port="6",
    serial_number="374fe75f",
    ue_pc_address="10.44.234.152",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="80",
    # ue_pc_expected_prompt='dummy3_expected_prompt',
    data_transfer=[_data_transfer_iperf],
    capabilities=["REAL_UE_1"],
)

_at_2 = TafUeAt(
    com_port="8",
    serial_number="5fd7d7de",
    ue_pc_address="10.44.234.152",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="80",
    # ue_pc_expected_prompt='dummy3_expected_prompt',
    data_transfer=[_data_transfer_iperf],
    capabilities=["REAL_UE_2"],
)

_at_3 = TafUeAt(
    com_port="5",
    serial_number="c8bcebc1",
    ue_pc_address="10.44.234.212",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="80",
    # ue_pc_expected_prompt='dummy3_expected_prompt',
    data_transfer=[_data_transfer_iperf],
    capabilities=["REAL_UE_3"],
)

_at_4 = TafUeAt(
    com_port="4",
    serial_number="3da83ea2",
    ue_pc_address="10.44.234.212",
    ue_pc_login="wro5gsiso",
    ue_pc_password="oZPS0POrRieRtu",
    ue_pc_port="80",
    # ue_pc_expected_prompt='dummy3_expected_prompt',
    data_transfer=[_data_transfer_iperf],
    capabilities=["REAL_UE_4"],
)


_at_5 = TafUeAndroid(
                # com_port='22',
                serial_number="R5CT30NNV9N",       #"78ba200c",  #"8a6e9e1f",  #"R5CT30NNV9N",  #"fd85e75b",
                ue_pc_address="10.44.234.192",
                ue_pc_port="80",
                data_transfer=[_data_transfer_iperf_android],
                ssh_connection_details=SshServiceDetails(
                    addr="10.44.234.192",
                    username="wro5gsiso",
                    password="oZPS0POrRieRtu",
                ),
                capabilities=["REAL_UE_5"],
)

_at_6 = TafUeAndroid(
                # com_port='22',
                serial_number="78ba200c",       #"78ba200c",  #"8a6e9e1f",  #"R5CT30NNV9N",  #"fd85e75b",
                ue_pc_address="10.44.234.192",
                ue_pc_port="80",
                data_transfer=[_data_transfer_iperf_android],
                ssh_connection_details=SshServiceDetails(
                    addr="10.44.234.192",
                    username="wro5gsiso",
                    password="oZPS0POrRieRtu",
                ),
                capabilities=["REAL_UE_6"],
)

_at_7 = TafUeAndroid(
                # com_port='22',
                serial_number="8a6e9e1f",       #"78ba200c",  #"8a6e9e1f",  #"R5CT30NNV9N",  #"fd85e75b",
                ue_pc_address="10.44.234.192",
                ue_pc_port="80",
                data_transfer=[_data_transfer_iperf_android],
                ssh_connection_details=SshServiceDetails(
                    addr="10.44.234.192",
                    username="wro5gsiso",
                    password="oZPS0POrRieRtu",
                ),
                capabilities=["REAL_UE_7"],
)

_at_8 = TafUeAndroid(
                # com_port='22',
                serial_number="fd85e75b",       #"78ba200c",  #"8a6e9e1f",  #"R5CT30NNV9N",  #"fd85e75b",
                ue_pc_address="10.44.234.192",
                ue_pc_port="80",
                data_transfer=[_data_transfer_iperf_android],
                ssh_connection_details=SshServiceDetails(
                    addr="10.44.234.192",
                    username="wro5gsiso",
                    password="oZPS0POrRieRtu",
                ),
                capabilities=["REAL_UE_8"],
)


_at_9 = TafUeAt(
                com_port="6",
                serial_number="d343b2ba",
                ue_pc_address="10.45.172.211",
                ue_pc_login="wro5grrm",
                ue_pc_password="5gpass!1",
                ue_pc_port="5001",
                # ue_pc_expected_prompt='dummy3_expected_prompt',
                data_transfer=[_data_transfer_iperf],
                capabilities=["CB012725_UE"],
)

tl = TestLine(
    test_pc=_vm_1,
    test_pcs=[_vm_1],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIP_2xAVQQA",
    ues=[_at_1, _at_2, _at_3, _at_4, _at_5, _at_6, _at_7, _at_8, _at_9],
    attenuator=[_attenuator_1],
    pdus=[_pdu_1,_pdu_2,_pdu_3],
    optical_switches=[_opt_sw_1],
)

__all__ = ["tl"]
