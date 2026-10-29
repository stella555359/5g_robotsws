__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import (
    CapacityUnit,
    CommonUnit,
    CoreUnit,
    Airscale,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import (
    RealCore,
    RealCore4GDetails,
    MME,
    RealCore5GDetails,
    AMF,
)
from taf.config.testline.flexi import Flexi
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.160", model="ENICS", port_numbers=[5]
).pdu_ports[5]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.105", model="ENICS", port_numbers=[1]
).pdu_ports[1]

_pdu_ue_dummy = ENICS(addr="0.0.0.0", port_numbers=[1])

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AZQS",
    serial_number="1M212316229",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="475664A.101",
)

_gnb_1_rms = [_gnb_1_ru_1]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIP",
    serial_number="L1232001180",
    product_code="475792A.101",
    addr="192.168.253.36",
    slot_id=SlotId.B1,
    rus=[_gnb_1_ru_1],
)

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1213507453",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=None,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.112", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.96.166/27",
                v6="2a00:8a00:4000:4a43::506/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.161", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::501",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            oam_ssh_connection_details=SshServiceDetails(
                addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            oam_http_connection_details=HttpConnectionDetails(
                addr="192.168.255.129",
                username="Nemuadmin",
                password="nemuuser",
                port=443,
            ),
            x2c=NetworkAddress(
                v4="100.68.96.198/27",
                v6="2a00:8a00:4000:4a43::606/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.193", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::601",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            x2u=NetworkAddress(
                v4="100.68.96.166/27",
                v6="2a00:8a00:4000:4a43::506/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.161", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::501",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            s1u=NetworkAddress(
                v4="100.68.96.166/27",
                v6="2a00:8a00:4000:4a43::506/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.161", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::501",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngu=NetworkAddress(
                v4="100.68.96.166/27",
                v6="2a00:8a00:4000:4a43::506/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.161", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::501",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngc=NetworkAddress(
                v4="100.68.96.198/27",
                v6="2a00:8a00:4000:4a43::606/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.193", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::601",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnc=NetworkAddress(
                v4="100.68.96.198/27",
                v6="2a00:8a00:4000:4a43::606/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.193", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::601",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnu=NetworkAddress(
                v4="100.68.96.166/27",
                v6="2a00:8a00:4000:4a43::506/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.96.161", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::501",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
        ),
        dus=[
            DU(
                airscale=Airscale(
                    common_units=_gnb_1_common_units, product_code="474767A.101"
                ),
                rus=_gnb_1_rms,
                cablinks=[
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="SFP", port_id=1),
                        target=Endpoint(unit=_gnb_1_ru_1, label="SFP", port_id=1),
                    )
                ],
            )
        ],
        instance_id=100304,
        global_bts_id=100304,
    ),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="9",
    four_g=None,
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=7926,
    ),
)

# Data transfer
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.35.102.96",
    user="srn",
    password="!!IperfUser@25",
    bind_interface_ip="10.35.102.96",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1
)

# Android UE
_android1 = TafUeAndroid(
    capabilities=["REAL_UE1"],
    serial_number="H0J9DE1CN0172100165",
    ue_pc_address="100.68.219.42",
    # ue_pc_port="80",
    proxy_mngr_port=9955,
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.219.42", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352179570361515",
    imsi="244091101136914",
    pdu_port=_pdu_ue_dummy.pdu_ports[1],
)

tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_UE_SA_ASIL_ABIP_AZQS",
    ues=[_android1],
)

__all__ = ["tl"]

sync = None
