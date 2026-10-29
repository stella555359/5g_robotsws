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

_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocity.linnanmaa.dyn.nesc.nokia.net",
        v6="None",
        vlan_id=None,
        routing_v4=None,
        routing_v6=None))

_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.143", model="ENICS", port_numbers=[2]).pdu_ports[2]

_enb_1_rms = []

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIN",
    serial_number="L1213615787",
    product_code="474824A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[])

_enb_1_cap_2 = CapacityUnit(
    hardware_type="ABIN",
    serial_number="L1213615791",
    product_code="474824A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B5,
    rus=[])

_enb_1_cap_3 = CapacityUnit(
    hardware_type="ABIN",
    serial_number="L1214007334",
    product_code="474824A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B6,
    rus=[])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2, _enb_1_cap_3]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1235102173",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF4)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.80", username="ute", password="None"),
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
            common_units=_enb_1_common_units, product_code="474767A.103"),
        instance_id=100863,
        global_bts_id=100863,
        oam_ip=NetworkAddress(
            v4="100.68.100.143/27",
            v6="2a00:8a00:4000:4a43::240f/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="100.68.100.129",
                ip_prefix_length=None,
                destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::2401",
                ip_prefix_length=None,
                destIpAddr=None)),
        rms=_enb_1_rms,
        cablinks=[]),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None),
            s1=NetworkAddress(
                v4="10.35.22.232",
                v6="2a00:8a00:4000:4a22::2:1308",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None)),
        tac=500,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6="None",
            vlan_id=None,
            routing_v4=None,
            routing_v6=None)),
    five_g=None,
)
tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1],
    velocity=_velocity,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
