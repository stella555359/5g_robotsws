__maintainer__ = "Daniel Kulpa"
__owner_email__ = "I_MN_RAN_RD_TV_OTACI_CITCRT2@internal.nsn.com"
__email__ = "daniel.kulpa@nokia.com"

from taf.config.testline import Connection
from taf.config.testline.pdu import ENICS
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit, SlotId
from taf.config.testline.enb import RealEnb
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine

__all__ = ["tl"]

_pdu_sm = ENICS(addr="10.44.204.54", port_numbers=[3, 4], version="48-16")
_pdu_ru = ENICS(addr="10.44.204.57", port_numbers=[4, 5], version="48-16")

# 4G setup
_ru1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="EA173313199",
    pdu_port=_pdu_ru.pdu_ports[4],
)
_bbmod1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1162601128",
    slot_id=SlotId.B4,
    rus=[_ru1],
)
_smod1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod1],
    pdu_port=_pdu_sm.pdu_ports[3],
    slot_id=SlotId.C2,
    hardware_type="ASIA",
    hardware_version="A.204",
    serial_number="L1201600924",
)
_enb1 = RealEnb(
    instance_id="35288",
    oam_ip=NetworkAddress(
        v4="10.44.204.69", routing_v4=RoutingInformation(gateway="10.44.204.1")
    ),
    system_module=Airscale(common_units=[_smod1]),
    rms=[_ru1],
)
_vm1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.204.18", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb1.system_module.common_units[0],
        )
    ],
)

# 5G setup
_ru2 = RU(
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="AEUB",
    serial_number="L1200101883",
    pdu_port=_pdu_ru.pdu_ports[5],
)
_bbmod2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214209192",
    slot_id=SlotId.B1,
    rus=[_ru2],
)
_smod2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod2],
    pdu_port=_pdu_sm.pdu_ports[4],
    slot_id=SlotId.C1,
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH214247585",
)
_enb2 = RealEnb(
    instance_id="35287",
    oam_ip=NetworkAddress(
        v4="10.44.204.70", routing_v4=RoutingInformation(gateway="10.44.204.1")
    ),
    system_module=Airscale(common_units=[_smod2]),
    rms=[_ru2],
)
_vm2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.204.19", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb2.system_module.common_units[0],
        )
    ],
)


tl = TestLine(
    test_pc=_vm1,
    test_pcs=[_vm1, _vm2],
    enbs=[_enb1, _enb2],
    tl_cloud_topology="CLOUD_CB",
)
