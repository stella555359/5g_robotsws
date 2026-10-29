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

_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.168", model="ENICS", port_numbers=[12]
).pdu_ports[12]

_enb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.16", model="ENICS", port_numbers=[6]
).pdu_ports[6]

_enb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.16", model="ENICS", port_numbers=[5]
).pdu_ports[5]

_enb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.16", model="ENICS", port_numbers=[4]
).pdu_ports[4]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AZHL",
    serial_number="AH212200240",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="474715A.101",
)

_enb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AZHL",
    serial_number="YK205100123",
    pdu_port=_enb_1_ru_2_pdu_port,
    product_code="474715A.101",
)

_enb_1_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AZHL",
    serial_number="YK205100124",
    pdu_port=_enb_1_ru_3_pdu_port,
    product_code="474715A.101",
)

_enb_1_rms = [_enb_1_ru_1, _enb_1_ru_2, _enb_1_ru_3]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="DH222140473",
    product_code="475266A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[_enb_1_ru_1, _enb_1_ru_2, _enb_1_ru_3],
)

_enb_1_cap_units = [_enb_1_cap_1]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIB",
        serial_number="L1201903711",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.127", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_enb_1_common_units[0]
        )
    ],
)

_gnbs = []

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473764A.102"
        ),
        instance_id=101611,
        global_bts_id=101611,
        oam_ip=NetworkAddress(
            v4="100.68.98.141/27",
            v6="2a00:8a00:4000:4a43::140d/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="100.68.98.129", ip_prefix_length=None, destIpAddr=None
            ),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1401",
                ip_prefix_length=None,
                destIpAddr=None,
            ),
        ),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=1),
            ),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=2),
                target=Endpoint(unit=_enb_1_ru_2, label="SFP", port_id=1),
            ),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_3, label="SFP", port_id=1),
            ),
        ],
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
            s1=NetworkAddress(
                v4="10.35.18.8",
                v6="2a00:8a00:4000:4a22::2:1108",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=123,
        ntp=NetworkAddress(
            v4="100.68.254.130", v6="None", vlan_id=None, routing_v4=None, routing_v6=None
        ),
    ),
    five_g=None,
)
tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]

sync = None
