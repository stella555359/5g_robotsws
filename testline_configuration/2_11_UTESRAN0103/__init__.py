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
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME

_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocity.linnanmaa.dyn.nesc.nokia.net",
        v6="None",
        vlan_id=None,
        routing_v4=None,
        routing_v6=None,
    )
)

_bbmod1 = CapacityUnit(
    hardware_type="ABIA",
    product_code="473096A.103",
    serial_number="L1173003772",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[],
)

_bbmod2 = CapacityUnit(
    hardware_type="ABIA",
    product_code="473096A.103",
    serial_number="L1173006995",
    addr="192.168.253.20",
    slot_id=SlotId.B5,
    rus=[],
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            product_code="473764A.102",
            common_units=[
                CommonUnit(
                    hardware_type="ASIB",
                    serial_number="DH203062801",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[_bbmod1, _bbmod2],
                    pdu_port=ENICS(addr="100.68.226.174", port_numbers=[2]).pdu_ports[2],
                    slot_id=SlotId.C2,
                    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
                    trs_connections=TRSInterfaces.EIF1,
                )
            ],
        ),
        instance_id=101551,
        global_bts_id=101551,
        oam_ip=NetworkAddress(
            v4="10.35.58.141/24",
            v6="None",
            routing_v4=RoutingInformation(gateway="10.35.58.129", destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway="None",
                destIpAddr=None,
            ),
        ),
        rms=[],
        cablinks=[],
    )
]

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.197.78", username="ute", password=None
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
                v4="10.35.108.4",
                v6="2A00:8A00:4000:4A22::8044",
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=140,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            routing_v4=None,
            routing_v6=None,
        ),
    ),
)

tl = TestLine(test_pc=_test_vm, enbs=_enbs, core=_core, velocity=_velocity)

__all__ = ["tl"]
