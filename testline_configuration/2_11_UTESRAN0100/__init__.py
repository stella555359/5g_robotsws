__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import CoreUnit, Airscale, TRSInterfaces
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
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

_enb_1_core_unit_1_pdu_port = ENICS(
    addr="100.68.226.160", model="ENICS", port_numbers=[9]
).pdu_ports[9]

_enb_1_core_unit = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_enb_1_core_unit_1_pdu_port,
    hardware_type="ASOG",
    serial_number="L1243802122",
    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
    trs_connections=TRSInterfaces.EIF1,
    rus=[],
)

_enb_1_core_units = [_enb_1_core_unit]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.196.234", username="ute", password="None"
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_enb_1_core_units[0])
    ],
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            core_units=_enb_1_core_units, product_code="476254A.101"
        ),
        instance_id=100308,
        global_bts_id=100308,
        oam_ip=NetworkAddress(
            v4="100.68.96.138/27",
            v6="2a00:8a00:4000:4a43::40a/120",
            routing_v4=RoutingInformation(gateway="100.68.96.129"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::401"),
        ),
        cablinks=[],
    ),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None
            ),
            s1=NetworkAddress(v4="10.35.18.8", v6="2a00:8a00:4000:4a22::2:1108"),
        ),
        tac=500,
        ntp=NetworkAddress(v4="100.68.254.130", v6="None"),
    ),
    five_g=None,
)
tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1],
    velocity=_velocity,
    gnbs=None,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]
