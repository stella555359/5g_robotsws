__maintainer__ = "Sorescu Valentin"
__email__ = "valentin.sorescu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nms import NMS
from taf.config.testline.nms import NetAct


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.35", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.48",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdu_2 = Gude(
    addr="10.255.1.47",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


netact_id = {
    "srnclab1027": {
        "node_ip": "10.43.48.192",
        "user": "omc",
        "password": "Medsql!_1893",
        "url": "https://srnclab1047lbwas.srnblr.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "Medsql!_1893",
        "mr": "MRC-COMMON/MR-COMMON/MRBTS-10680",
    },
}

_netact = NetAct(netact_id)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="LR253915490",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="LR253915494",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="LR253806505",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="K9252106991",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW243001847",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW243203675",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1240803220",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_smod_1 = Airscale([_fct_1])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.80"),
    instance_id=10680,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))


_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    nms=_netact,
    tl_cloud_topology="CLOUD_SRAN_NLG_10680_1ASOG_2AHEGA",
    bscs=[_bsc],
    #rncs=[_rnc],
)


__all__ = ["tl"]

