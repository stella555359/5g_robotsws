__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "agata.l.skoczylas@nokia.com"
__customer__ = "TMO US"
__bucket__ = "s"
__rack__ = "GTA-1544"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, Remote, Local
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc

# smod port 9, 10
# rm  PDU 2  port 2,3; PDU 3 port 7; PDU 4 port 11
_pdu_1 = Gude(
    addr="10.42.60.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.60.80",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.42.80.26",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_4 = Gude(
    addr="10.42.80.192",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9182400421",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="AHFB: FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="EA173813489",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2114G1AA7",
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHQN",
    serial_number="AH242307928",
    pdu_port=_pdu_4.pdu_ports[11],
)

_fsp1_ = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203802119",
    rus=[_rmod_1],
)
_fsp2_ = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:201",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212564282",
    rus=[_rmod_2],
)
_fsp3_ = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:301",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212564281",
    rus=[_rmod_3],
)
_fsp4_ = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:1101",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221405726",
    rus=[_rmod_4],
)

_asil_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp1_, _fsp2_, _fsp3_],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1202800743",
)
_asil_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp4_],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1240504373",
)

_smod_1 = Airscale([_asil_1])
_smod_2 = Airscale([_asil_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3],
                      global_bts_id=8618, instance_id=8618)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.35", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.47", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_LEZDUIT_UUFWRO",
)

__all__ = ["tl"]
