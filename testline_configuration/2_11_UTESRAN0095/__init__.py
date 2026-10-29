__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import CapacityUnit, CommonUnit, CoreUnit, Airscale, SlotId, TRSInterfaces
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME, RealCore5GDetails, AMF
from taf.config.testline.flexi import Flexi
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol

_pdu_ue_dummy = ENICS(addr="0.0.0.0", port_numbers=[1, 2, 3])

_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.160", model="ENICS", port_numbers=[1]).pdu_ports[1]

_enb_1_ru_1_pdu_port = ENICS(addr="100.68.226.107", port_numbers=[1]).pdu_ports[1]
_enb_1_ru_2_pdu_port = ENICS(addr="100.68.226.107", port_numbers=[2]).pdu_ports[2]
_enb_1_ru_3_pdu_port = ENICS(addr="100.68.226.107", port_numbers=[3]).pdu_ports[3]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEGB",
    serial_number="EA210654461",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="474090A.101")

_enb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEGB",
    serial_number="EA210654435",
    pdu_port=_enb_1_ru_2_pdu_port,
    product_code="4474090A.101")

_enb_1_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEGB",
    serial_number="EA210654635",
    pdu_port=_enb_1_ru_3_pdu_port,
    product_code="474090A.101")

_enb_1_rms = [_enb_1_ru_1, _enb_1_ru_2, _enb_1_ru_3]

_enb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1232001196",
    product_code="475792A.101",
    slot_id=SlotId.B1,
    rus=[_enb_1_ru_1, _enb_1_ru_2])

_enb_1_cap_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    serial_number="L1240602945",
    product_code="475792A.101",
    slot_id=SlotId.B2,
    rus=[_enb_1_ru_3])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2]

_enb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_enb_1_common_unit_1_pdu_port,
        capacity_units=_enb_1_cap_units,
        hardware_type="ASIL",
        serial_number="L1232400104",
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.68", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_1_common_units[0])
    ])

_gnbs = []

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="474767A.102"),
        instance_id=100300,
        global_bts_id=100300,
        oam_ip=NetworkAddress(
            v4="100.68.96.130/27",
            v6="2a00:8a00:4000:4a43::402/120",
            routing_v4=RoutingInformation(gateway="100.68.96.129"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::401")),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=7),
                target=Endpoint(unit=_enb_1_ru_2, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_3, label="SFP", port_id=1))
        ]),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None),
            s1=NetworkAddress(
                v4="10.35.18.8", v6="2a00:8a00:4000:4a22::2:1108")),
        tac=154,
        ntp=NetworkAddress(v4="100.68.254.130", v6="None")),
    five_g=None,
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
    serial_number="R5CN216VJ2E",
    ue_pc_address="100.68.218.105",
    #ue_pc_port="80",
    proxy_mngr_port="9955",
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.218.105", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352563112591228",
    imsi="244091101136921",
    pdu_port=_pdu_ue_dummy.pdu_ports[1],
)

_android2 = TafUeAndroid(
    capabilities=["REAL_UE2"],
    serial_number="R5CN70Q6WAV",
    ue_pc_address="100.68.218.105",
    #ue_pc_port="80",
    proxy_mngr_port="9955",
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.218.105", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352563112703138",
    imsi="244091101136920",
    pdu_port=_pdu_ue_dummy.pdu_ports[2],
)

_android3 = TafUeAndroid(
    capabilities=["REAL_UE3"],
    serial_number="R5CN70Q6X1D",
    ue_pc_address="100.68.218.105",
    #ue_pc_port="80",
    proxy_mngr_port="9955",
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.218.105", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352563112703377",
    imsi="244091101136922",
    pdu_port=_pdu_ue_dummy.pdu_ports[3],
)

tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
    ues=[_android1, _android2, _android3],
    )

__all__ = ["tl"]

sync = None
