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


_snmp_user = {
    "userName": "user",
    "authKey": "aCoP_!123456",
    "privKey": "PoliCe_!123456",
    "authProtocol": "SHA",
    "privProtocol": "AES",
    }

_ru1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHBCC",
    serial_number="K9190632317",
    pdu_port=ENICS(addr="100.68.226.17", port_numbers=[2]).pdu_ports[2],
    product_code="474341A.101",
    alds=None,
)

_ru2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHBCC",
    serial_number="K9190632316",
    pdu_port=ENICS(addr="100.68.226.17", port_numbers=[3]).pdu_ports[3],
    product_code="474341A.101",
    alds=None,
)

_rus = [_ru1, _ru2]

_bbmod1 = CapacityUnit(
    hardware_type="ABIA",
    product_code="473096A.103",
    serial_number="L1181917727",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[_ru1],
)

_bbmod2 = CapacityUnit(
    hardware_type="ABIA",
    product_code="473096A.103",
    serial_number="L1172604900",
    addr="192.168.253.20",
    slot_id=SlotId.B5,
    rus=[_ru2],
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            product_code="474403A.101",
            common_units=[
                CommonUnit(
                    hardware_type="ASIA",
                    serial_number="L1172216406",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[_bbmod1, _bbmod2],
                    pdu_port=ENICS(addr="100.68.226.168", port_numbers=[10]).pdu_ports[10],
                    slot_id=SlotId.C2,
                    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
                    trs_connections=TRSInterfaces.EIF5,
                )
            ],
        ),
        instance_id=101609,
        global_bts_id=101609,
        oam_ip=NetworkAddress(
            v4="100.68.98.139/27",
            v6="2a00:8a00:4000:4a43::140b/120",
            routing_v4=RoutingInformation(gateway="100.68.98.129", destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1401",
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
                    unit=_ru1,
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
                    unit=_ru2,
                    label="SFP",
                    port_id=1,
                ),
            ),
        ],
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
                v6="2a00:8a00:4000:4a22::8044",
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=123,
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
        addr="100.68.194.125", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enbs[0].system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(test_pc=_test_vm, enbs=_enbs, core=_core)

__all__ = ["tl"]
