##########################################
# TestLine TL287 Ulm (7_15_UTESRANTL287) #
##########################################

__maintainer__ = "VRF Ulm 3"
__team__ = "MN RAN RD VRF ULM 3"
__email__ = "i_mn_ran_rd_vrf_ulm_csv@internal.nsn.com"

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
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.appserver import AppServer
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline import PDNTafUeAndroidDetails

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_fsmf_pdu = Gude(
    addr="10.46.152.85", # TBD
    port_numbers=[
        6,  # FSMF
    ],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_radio_pdu = Gude(
    addr="10.46.152.85", # TBD
    port_numbers=[
        8,  # FXEB 1
        9,  # FXEB 2
    ],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="FXEB",
    pdu_port=_radio_pdu.pdu_ports[8],
    serial_number="L1124212454",
    product_code="472501A.101",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="FXEB",
    pdu_port=_radio_pdu.pdu_ports[9],
    serial_number="L1124506176",
    product_code="472501A.101",
)


_enb_1_cap_1 = CapacityUnit(
    hardware_type="FSPD",
    serial_number="L1134304676",
    product_code="085422A.103",
    addr="",
    slot_id=None,
    rus=[_ru_1, _ru_2],
)


_enbs = [
    RealEnb(
        system_module=Flexi(
            common_units=[
                CommonUnit(
                    hardware_type="FSMF",
                    lmp_connection=SshServiceDetails(
                        addr="192.168.255.129",
                        username="toor4nsn",
                        port=22,
                        password="oZPS0POrRieRtu",
                        private_key=None,
                        proxy=None,
                    ),
                    capacity_units=[_enb_1_cap_1],
                    pdu_port=_fsmf_pdu.pdu_ports[6],
                    slot_id=None,
                    trs_connections=TRSInterfaces.EIF1,
                    serial_number="L1134309411",
                )
            ]
        ),
        instance_id=452871,
        global_bts_id=452871,
        oam_ip=NetworkAddress(
            v4="10.47.13.211",
            #v4="192.168.255.129",
        ),
        trs_ip=NetworkAddress(
            v4="10.47.13.211",
        ),
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=1),
                target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
            ),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=2),
                target=Endpoint(unit=_ru_2, label="SFP", port_id=1),
            ),
        ],
    ),
]

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]
_core = RealCore( mcc="001", mnc="01", pdns=_pdns)

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.12.87", username="ute", password="UTE.debian12"
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
