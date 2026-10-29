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
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME



_pdu = ENICS(
    addr="100.68.226.88", model="ENICS", port_numbers=[1, 3, 4])

_ru1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXFC",
    serial_number="F7144716763",
    pdu_port=_pdu.pdu_ports[4],
    product_code="472679A.101",
    alds=None,
)

_ru2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXFC",
    serial_number="F7163930912",
    pdu_port=_pdu.pdu_ports[3],
    product_code="472679A.102",
    alds=None,
)

_rus = [_ru1, _ru2]

_bbmod1 = CapacityUnit(
    hardware_type="ABIO",
    product_code="475266A.103",
    serial_number="L1220201178",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=_rus,
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            product_code="473764A.102",
            common_units=[
                CommonUnit(
                    hardware_type="ASIB",
                    serial_number="DH201860851",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[_bbmod1],
                    pdu_port=_pdu.pdu_ports[1],
                    slot_id=SlotId.C1,
                    sync_input=None,
                    trs_connections=TRSInterfaces.EIF1,
                )
            ],
        ),
        instance_id=100822,
        global_bts_id=100822,
        oam_ip=NetworkAddress(
            v4="100.68.99.24/27",
            v6="2a00:8a00:4000:4a43::1818/120",
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
                    port_id=1,
                ),
                target=Endpoint(
                    _ru1,
                    label="SFP",
                    port_id=1,
                ),
            ),
            Cablink(
                source=Endpoint(
                    unit=_bbmod1,
                    label="SFP",
                    port_id=2,
                ),
                target=Endpoint(
                    _ru2,
                    label="SFP",
                    port_id=1,
                ),
            ),
        ],
    )
]

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.95", username="ute", password="None"
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
        tac=500,
        ntp=None,
    ),
)

tl = TestLine(test_pc=_test_vm, enbs=_enbs, core=_core)
__all__ = ["tl"]
