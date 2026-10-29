__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"


from taf.config.testline import TestPc, SshServiceDetails, TestLine, Connection
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import (
    CapacityUnit,
    CommonUnit,
    Airscale,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol

_pdu_ue_dummy = ENICS(addr="0.0.0.0", port_numbers=[1, 2, 3])

_ru1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEGB",
    serial_number="EA214954859",
    pdu_port=ENICS(addr="100.68.226.104", port_numbers=[1]).pdu_ports[1],
    product_code="474090A.101",
    alds=None,
)

_ru2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEGB",
    serial_number="EA211155645",
    pdu_port=ENICS(addr="100.68.226.104", port_numbers=[2]).pdu_ports[2],
    product_code="4474090A.101",
    alds=None,
)

_ru3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEGB",
    serial_number="EA210654641",
    pdu_port=ENICS(addr="100.68.226.104", port_numbers=[3]).pdu_ports[3],
    product_code="474090A.101",
    alds=None,
)

_rus = [_ru1, _ru2, _ru3]

_bbmod1 = CapacityUnit(
    hardware_type="ABIP",
    product_code="475792A.101",
    serial_number="L1232001206",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[_ru1, _ru2],
)

_bbmod2 = CapacityUnit(
    hardware_type="ABIP",
    product_code="475792A.101",
    serial_number="L1232001201",
    addr="192.168.253.21",
    slot_id=SlotId.B2,
    rus=[_ru3],
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            product_code="474767A.103",
            common_units=[
                CommonUnit(
                    hardware_type="ASIL",
                    serial_number="L1202703589",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[_bbmod1, _bbmod2],
                    pdu_port=ENICS(addr="100.68.226.160", port_numbers=[7]).pdu_ports[
                        7
                    ],
                    slot_id=SlotId.C1,
                    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
                    trs_connections=TRSInterfaces.EIF1,
                )
            ],
        ),
        instance_id=100306,
        global_bts_id=100306,
        oam_ip=NetworkAddress(
            v4="100.68.96.136/26",
            v6="None",
            routing_v4=RoutingInformation(gateway="100.68.96.129", destIpAddr=None),
            routing_v6=RoutingInformation(gateway="None", destIpAddr=None),
        ),
        rms=_rus,
        cablinks=[
            Cablink(
                source=Endpoint(
                    unit=_bbmod1,
                    label="SFP",
                    port_id=1,
                ),
                target=Endpoint(
                    unit=_ru1,
                    label="SFP",
                    port_id=1,
                ),
            ),
            Cablink(
                source=Endpoint(
                    unit=_bbmod1,
                    label="SFP",
                    port_id=7,
                ),
                target=Endpoint(
                    unit=_ru2,
                    label="SFP",
                    port_id=1,
                ),
            ),
            Cablink(
                source=Endpoint(
                    unit=_bbmod2,
                    label="SFP",
                    port_id=1,
                ),
                target=Endpoint(
                    unit=_ru3,
                    label="SFP",
                    port_id=1,
                ),
            ),
        ],
    )
]

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.196.232", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enbs[0].system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1",
                username="dummy",
                port=22,
                password=None,
                private_key=None,
                proxy=None,
            ),
            s1=NetworkAddress(
                v4="10.35.18.8",
                v6="2a00:8a00:4000:4a22::2:1108",
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=154,
        ntp=NetworkAddress(
            v4="100.68.254.130", v6="None", routing_v4=None, routing_v6=None
        ),
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
    serial_number="R5CN70Q738A",
    ue_pc_address="100.68.219.105",
    # ue_pc_port="80",
    proxy_mngr_port=9955,
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.219.105", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352563112705422",
    imsi="244091101136937",
    pdu_port=_pdu_ue_dummy.pdu_ports[1],
)

_android2 = TafUeAndroid(
    capabilities=["REAL_UE2"],
    serial_number="R5CN3004B3Z",
    ue_pc_address="100.68.219.105",
    # ue_pc_port="80",
    proxy_mngr_port=9955,
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.219.105", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352563113412804",
    imsi="244091101136936",
    pdu_port=_pdu_ue_dummy.pdu_ports[2],
)

_android3 = TafUeAndroid(
    capabilities=["REAL_UE3"],
    serial_number="R5CN70Q72JT",
    ue_pc_address="100.68.219.105",
    # ue_pc_port="80",
    proxy_mngr_port=9955,
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="100.68.219.105", username="fioucdsusr", password="!PETlintula1"
    ),
    imei="352563112705190",
    imsi="244091101136938",
    pdu_port=_pdu_ue_dummy.pdu_ports[3],
)

tl = TestLine(
    test_pc=_test_vm,
    enbs=_enbs,
    core=_core,
    ues=[_android1, _android2, _android3],
)

__all__ = ["tl"]
