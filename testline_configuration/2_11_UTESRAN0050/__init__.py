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
from taf.config.testline.pdu import ENICS, DELTA
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME

_ru1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AZNC",
    serial_number="K9222036296",
    pdu_port=ENICS(addr="100.68.226.93", port_numbers=[3]).pdu_ports[3],
    product_code="474052A.101",
    alds=None,
)

_ru2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="AH242102897",
    pdu_port=ENICS(addr="100.68.226.15", port_numbers=[5]).pdu_ports[5],
    product_code="475124B.101",
    alds=None,
)

_ru3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRGU",
    serial_number="K9170814525",
    pdu_port=ENICS(addr="100.68.226.93", port_numbers=[4]).pdu_ports[4],
    product_code="472956A.102",
    alds=None,
)

_ru4 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRGU",
    serial_number="K9170703216",
    pdu_port=ENICS(addr="100.68.226.93", port_numbers=[5]).pdu_ports[5],
    product_code="472956A.102",
    alds=None,
)

_ru5 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2114G1AE6",
    pdu_port=ENICS(addr="100.68.226.93", port_numbers=[1]).pdu_ports[1],
    product_code="474331A.101",
    alds=None,
)

_ru6 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2114G1AD5",
    pdu_port=ENICS(addr="100.68.226.93", port_numbers=[2]).pdu_ports[2],
    product_code="474331A.101",
    alds=None,
)

_rus = [_ru1, _ru2, _ru3, _ru4, _ru5, _ru6]

_bbmod1 = CapacityUnit(
    hardware_type="ABIO",
    product_code="475266A.107",
    serial_number="L1240803960",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[_ru1, _ru2],
)

_bbmod2 = CapacityUnit(
    hardware_type="ABIQ",
    product_code="476397A.101",
    serial_number="L1232305684",
    addr="192.168.253.24",
    slot_id=SlotId.B5,
    rus=[_ru3, _ru4],
)

_bbmod3 = CapacityUnit(
    hardware_type="ABIQ",
    product_code="476397A.101",
    serial_number="L1232305684",
    addr="192.168.253.24",
    slot_id=SlotId.B6,
    rus=[_ru5, _ru6],
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            product_code="475765A.104",
            common_units=[
                CommonUnit(
                    hardware_type="ASIM",
                    serial_number="L1233302522",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[_bbmod1, _bbmod2, _bbmod3],
                    pdu_port=ENICS(addr="100.68.226.170", port_numbers=[8]).pdu_ports[8],
                    slot_id=SlotId.C2,
                    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
                    trs_connections=TRSInterfaces.EIF1,
                )
            ],
        ),
        instance_id=100807,
        global_bts_id=100807,
        oam_ip=NetworkAddress(
            v4="100.68.99.9/27",
            v6="2a00:8a00:4000:4a43::1809/120",
            routing_v4=RoutingInformation(gateway="100.68.99.1", destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1801",
                destIpAddr=None,
            ),
        ),
        rms=_rus,
        cablinks=[
            Cablink(
                source=Endpoint(
                    unit=_bbmod1,
                    label="SFP",
                    port_id=5,
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
            Cablink(
                source=Endpoint(
                    unit=_bbmod2,
                    label="SFP",
                    port_id=2,
                ),
                target=Endpoint(
                    unit=_ru4,
                    label="SFP",
                    port_id=1,
                ),
            ),
            Cablink(
                source=Endpoint(
                    unit=_bbmod3,
                    label="SFP",
                    port_id=1,
                ),
                target=Endpoint(
                    unit=_ru5,
                    label="SFP",
                    port_id=1,
                ),
            ),
            Cablink(
                source=Endpoint(
                    unit=_bbmod3,
                    label="SFP",
                    port_id=2,
                ),
                target=Endpoint(
                    unit=_ru6,
                    label="SFP",
                    port_id=1,
                ),
            ),
        ],
    )
]

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.255", username="ute", password="None"
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
                v6="2A00:8A00:4000:4A22::8044",
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=154,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            routing_v4=None,
            routing_v6=None,
        ),
    ),
)

tl = TestLine(test_pc=_test_vm, enbs=_enbs, core=_core)
__all__ = ["tl"]
