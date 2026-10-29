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
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME
from taf.config.testline.flexi import Flexi

_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocity.linnanmaa.dyn.nesc.nokia.net",
        v6="None",
        routing_v4=None,
        routing_v6=None,
    )
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=[
                CommonUnit(
                    hardware_type="ASIA",
                    serial_number="AH182914440",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[
                        CapacityUnit(
                            hardware_type="ABIA",
                            addr="192.168.253.20",
                            slot_id=SlotId.B4,
                            serial_number="L1183111498",
                        ),
                        CapacityUnit(
                            hardware_type="ABIA",
                            addr="192.168.253.20",
                            slot_id=SlotId.B5,
                            serial_number="L1183116998",
                        ),
                        CapacityUnit(
                            hardware_type="ABIA",
                            addr="192.168.253.20",
                            slot_id=SlotId.B6,
                            serial_number="L1183114165",
                        ),
                    ],
                    pdu_port=ENICS(addr="100.68.226.142", port_numbers=[10]).pdu_ports[
                        10
                    ],
                    slot_id=SlotId.C2,
                    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
                    trs_connections=TRSInterfaces.EIF5,
                )
            ]
        ),
        instance_id=100859,
        global_bts_id=100859,
        oam_ip=NetworkAddress(
            v4="100.68.100.139/27",
            v6="2a00:8a00:4000:4a43::240b/120",
            routing_v4=RoutingInformation(
                gateway="100.68.100.129", ip_prefix_length=None, destIpAddr=None
            ),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::2401",
                ip_prefix_length=None,
                destIpAddr=None,
            ),
        ),
        rms=[],
        cablinks=[],
    )
]

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
        tac=12,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            routing_v4=None,
            routing_v6=None,
        ),
    ),
)

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.76", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enbs[0].system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(test_pc=_test_vm, velocity=_velocity, enbs=_enbs, core=_core)

__all__ = ["tl"]
