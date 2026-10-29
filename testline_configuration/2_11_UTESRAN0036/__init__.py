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
from taf.config.testline.fhs import FHS, FhsType

_snmp_user = {
    "userName": "user",
    "authKey": "aCoP_!123456",
    "privKey": "PoliCe_!123456",
    "authProtocol": "SHA",
    "privProtocol": "AES",
    }


_rus = [
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="AHFB",
        serial_number="AH202300132",
        pdu_port=ENICS(addr="100.68.226.85", port_numbers=[4]).pdu_ports[4],
        product_code="474036A.103",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="AHEB",
        serial_number="EA202152694",
        pdu_port=ENICS(addr="100.68.226.17", port_numbers=[1]).pdu_ports[1],
        product_code="473484A.101",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="AHCA",
        serial_number="1M193000141",
        pdu_port=ENICS(addr="100.68.226.10", port_numbers=[6]).pdu_ports[6],
        product_code="473966B.101",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="FXCA",
        serial_number="K9144146998",
        pdu_port=ENICS(addr="100.68.226.85", port_numbers=[3]).pdu_ports[3],
        product_code="472142A.202",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="FXCA",
        serial_number="K9144520092",
        pdu_port=ENICS(addr="100.68.226.85", port_numbers=[2]).pdu_ports[2],
        product_code="472142A.303",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="FXCA",
        serial_number="K9131117790",
        pdu_port=ENICS(addr="100.68.226.85", port_numbers=[1]).pdu_ports[1],
        product_code="472142A.202",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="FHDB",
        serial_number="L6150103932",
        pdu_port=ENICS(addr="100.68.226.78", port_numbers=[2]).pdu_ports[2],
        product_code="472649A.102",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="FHDB",
        serial_number="L6150103912",
        pdu_port=ENICS(addr="100.68.226.78", port_numbers=[1]).pdu_ports[1],
        product_code="472649A.102",
        alds=None,
    ),
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="FHDB",
        serial_number="L6150109507",
        pdu_port=ENICS(addr="100.68.226.78", port_numbers=[4]).pdu_ports[4],
        product_code="472649A.102",
        alds=None,
    ),
]

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=ENICS(addr="100.68.226.171", port_numbers=[16]).pdu_ports[16],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.81.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q203407787",
    product_code="473922A.102",
    rus=_rus,
)

_enbs = [
    RealEnb(
        system_module=Airscale(
            product_code="473095A.204",
            common_units=[
                CommonUnit(
                    hardware_type="ASIA",
                    serial_number="EA194857233",
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
                            product_code="473096A.107",
                            serial_number="L1211506031",
                            addr="192.168.253.20",
                            slot_id=SlotId.B1,
                            rus=_rus,
                            fhs=[_fhs_1],
                        )
                    ],
                    pdu_port=ENICS(addr="100.68.226.170", port_numbers=[9]).pdu_ports[9],
                    slot_id=SlotId.C1,
                    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
                    trs_connections=TRSInterfaces.EIF5,
                )
            ]
        ),
        instance_id=100808,
        global_bts_id=100808,
        oam_ip=NetworkAddress(
            v4="100.68.99.10/27",
            v6="2a00:8a00:4000:4a43::180a/120",
            routing_v4=RoutingInformation(gateway="100.68.99.1", destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1801", destIpAddr=None
            ),
        ),
        rms=_rus,
    )
]

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.0", username="ute", password="None"
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
        tac=123,
        ntp=NetworkAddress(
            v4="100.68.254.130", v6="None", routing_v4=None, routing_v6=None
        ),
    ),
)

tl = TestLine(test_pc=_test_vm, enbs=_enbs, core=_core)
__all__ = ["tl"]
