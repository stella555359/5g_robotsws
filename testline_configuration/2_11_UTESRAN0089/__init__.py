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
from taf.config.testline.fhs import FHS, FhsType

_snmp_user = {
    "userName": "user",
    "authKey": "aCoP_!123456",
    "privKey": "PoliCe_!123456",
    "authProtocol": "SHA",
    "privProtocol": "AES",
}

_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.171", model="ENICS", port_numbers=[7]
).pdu_ports[7]


_enb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.85", model="ENICS", port_numbers=[10]
).pdu_ports[10]

_enb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.17", model="ENICS", port_numbers=[10]
).pdu_ports[10]

_enb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.19", model="ENICS", port_numbers=[10]
).pdu_ports[10]

_enb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.85", model="ENICS", port_numbers=[8]
).pdu_ports[8]

_enb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.85", model="ENICS", port_numbers=[7]
).pdu_ports[7]

_enb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.85", model="ENICS", port_numbers=[9]
).pdu_ports[9]

_enb_1_ru_7_pdu_port = ENICS(
    addr="100.68.226.85", model="ENICS", port_numbers=[6]
).pdu_ports[6]

_enb_1_ru_8_pdu_port = ENICS(
    addr="100.68.226.78", model="ENICS", port_numbers=[3]
).pdu_ports[3]

_enb_1_ru_9_pdu_port = ENICS(
    addr="100.68.226.85", model="ENICS", port_numbers=[5]
).pdu_ports[5]


_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFB",
    serial_number="AH214501657",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="474036A.103",
)

_enb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEB",
    serial_number="DH251323798",
    pdu_port=_enb_1_ru_2_pdu_port,
    product_code="473484A.101",
)

_enb_1_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHCA",
    serial_number="AS202010702",
    pdu_port=_enb_1_ru_3_pdu_port,
    product_code="473966A.101",
)

_enb_1_ru_4 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L6121323439",
    pdu_port=_enb_1_ru_4_pdu_port,
    product_code="472142A.202",
)

_enb_1_ru_5 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L6114700097",
    pdu_port=_enb_1_ru_5_pdu_port,
    product_code="472142A.202",
)

_enb_1_ru_6 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L1112715106",
    pdu_port=_enb_1_ru_6_pdu_port,
    product_code="472142A.101",
)

_enb_1_ru_7 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FHDB",
    serial_number="1M142637799",
    pdu_port=_enb_1_ru_7_pdu_port,
    product_code="472649A.102",
)

_enb_1_ru_8 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FHDB",
    serial_number="L6134427288",
    pdu_port=_enb_1_ru_8_pdu_port,
    product_code="472649A.102",
)

_enb_1_ru_9 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FHDB",
    serial_number="1M142637795",
    pdu_port=_enb_1_ru_9_pdu_port,
    product_code="472649A.102",
)

_enb_1_rms = [
    _enb_1_ru_1,
    _enb_1_ru_2,
    _enb_1_ru_3,
    _enb_1_ru_4,
    _enb_1_ru_5,
    _enb_1_ru_6,
    _enb_1_ru_7,
    _enb_1_ru_8,
    _enb_1_ru_9,
]

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=ENICS(addr="100.68.226.171", port_numbers=[15]).pdu_ports[15],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.81.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q193802954",
    product_code="473922A.102",
    rus=_enb_1_rms,
)

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1163615142",
    product_code="473096A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=_enb_1_rms,
    fhs=[_fhs_1],
)

_enb_1_cap_units = [_enb_1_cap_1]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIA",
        serial_number="AH183904882",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.61", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_enb_1_common_units[0]
        )
    ],
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473095A.203"
        ),
        instance_id=100818,
        global_bts_id=100818,
        oam_ip=NetworkAddress(
            v4="100.68.99.20/27",
            v6="2a00:8a00:4000:4a43::1814/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="100.68.99.1", ip_prefix_length=None, destIpAddr=None
            ),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1801",
                ip_prefix_length=None,
                destIpAddr=None,
            ),
        ),
        rms=_enb_1_rms,
    )
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
tl = TestLine(test_pc=_test_vm_enb_1, test_pcs=[_test_vm_enb_1], enbs=_enbs, core=_core)

__all__ = ["tl"]

sync = None
