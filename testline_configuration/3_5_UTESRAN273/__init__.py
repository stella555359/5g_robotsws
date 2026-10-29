__maintainer__ = "Amaand.li"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "Amaand.li@nokia-sbell.com"
__owner_email__ = "Amaand.li@nokia-sbell.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetAct

### BLR Labs ### start ###
_netact_ssh_1013 = SshServiceDetails('10.41.146.72', 'omc', password='Medsql!_1893')
_netact_http_1013 = HttpConnectionDetails('srnclab1013lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1013 = NetAct(_netact_ssh_1013, _netact_http_1013)

_netact_ssh_1014 = SshServiceDetails('10.41.146.105', 'omc', password='Medsql!_1893')
_netact_http_1014 = HttpConnectionDetails('srnclab1014lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1014 = NetAct(_netact_ssh_1014, _netact_http_1014)

_netact_ssh_1015 = SshServiceDetails('10.41.146.134', 'omc', password='Medsql!_1893')
_netact_http_1015 = HttpConnectionDetails('srnclab1015lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1015 = NetAct(_netact_ssh_1015, _netact_http_1015)

_netact_ssh_1016 = SshServiceDetails('10.41.146.167', 'omc', password='Medsql!_1893')
_netact_http_1016 = HttpConnectionDetails('srnclab1016lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1016 = NetAct(_netact_ssh_1016, _netact_http_1016)

_netact_ssh_1025 = SshServiceDetails('10.41.148.15', 'omc', password='Medsql!_1893')
_netact_http_1025 = HttpConnectionDetails('srnclab1025lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1025 = NetAct(_netact_ssh_1025, _netact_http_1025)

_netact_ssh_1027 = SshServiceDetails('10.41.148.99', 'omc', password='Medsql!_1893')
_netact_http_1027 = HttpConnectionDetails('srnclab1027lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1027 = NetAct(_netact_ssh_1027, _netact_http_1027)

_netact_ssh_2003 = SshServiceDetails('10.82.47.46', 'omc', password='Medsql!_1893')
_netact_http_2003 = HttpConnectionDetails('srnclab2003lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_2003 = NetAct(_netact_ssh_2003, _netact_http_2003)
### BLR Labs ### start ###

### Hangzhou Labs ### start ###
_netact_ssh_chen4 = SshServiceDetails('10.108.248.82', 'omc', password='Nokia126_')
_netact_http_chen4 = HttpConnectionDetails('chen4lbwas.chen4.srnhz.nsn-rdnet.net', 'omc', password='Nokia126_')
_netact_chen4 = NetAct(_netact_ssh_chen4, _netact_http_chen4)

_netact_ssh_jiang7 = SshServiceDetails('10.56.3.19', 'omc', password='Nokia123!')
_netact_http_jiang7 = HttpConnectionDetails('https://jiang7lbwas.jiang7.srnhz.nsn-rdnet.net/', 'omc', password='Nokia123!')
_netact_jiang7 = NetAct(_netact_ssh_jiang7, _netact_http_jiang7)
### Hangzhou Labs ### end ###

_pdu_1 = FPFH(
    addr="10.108.166.200",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_2 = FACOM(
    addr="10.108.151.208",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)

_pdu_3 = TopYoung(
    addr="10.106.205.36",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TopYoung",
)
_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AT1",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA222959250",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA222356301",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHM.value,
    serial_number="1M222529019",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222401719",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1214311444",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174042718",
    rus=[_rmod_2, _rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220808971",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1221903636",
    rus=[_rmod_1],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907562",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1233304545",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1233304546",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_2,
        _rmod_3,
    ],
    oam_ip=NetworkAddress("10.106.205.201"),
    instance_id=2345,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.157", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.159", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIM_2ABIO_2ABIN_1ABIA_1ABIP_1AZHM_1AHDB_1AHEGB_1AHLOA",
    nms=_netact_jiang7
)

__all__ = ["tl"]
