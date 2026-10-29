__maintainer__ = "haifhuan"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "haifeng.huang@nokia-sbell.com"
__owner_email__ = "haifeng.huang@nokia-sbell.com"


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

### Hangzhou Labs ### start ###
_netact_ssh_chen4 = SshServiceDetails('10.108.248.82', 'omc', password='Nokia126_')
_netact_http_chen4 = HttpConnectionDetails('chen4lbwas.chen4.srnhz.nsn-rdnet.net', 'omc', password='Nokia126_')
_netact_chen4 = NetAct(_netact_ssh_chen4, _netact_http_chen4)

_netact_ssh_jiang7 = SshServiceDetails('10.56.3.19', 'omc', password='Nokia123!')
_netact_http_jiang7 = HttpConnectionDetails('https://jiang7lbwas.jiang7.srnhz.nsn-rdnet.net/', 'omc', password='Nokia123!')
_netact_jiang7 = NetAct(_netact_ssh_jiang7, _netact_http_jiang7)

_netact_ssh_han5 = SshServiceDetails('10.107.183.26', 'omc', password='Nokia123!')
_netact_http_han5 = HttpConnectionDetails('https://han5lbwas.han5.srnhz.nsn-rdnet.net/', 'omc', password='Nokia123!')
_netact_han5 = NetAct(_netact_ssh_han5, _netact_http_han5)

_netact_ssh_qin6 = SshServiceDetails('10.107.245.83', 'omc', password='Nokia123!')
_netact_http_qin6 = HttpConnectionDetails('https://qin6lbwas.qin6.srnhz.nsn-rdnet.net/', 'omc', password='Nokia123!')
_netact_qin6 = NetAct(_netact_ssh_qin6, _netact_http_qin6)

_netact_ssh_tang4 = SshServiceDetails('10.70.114.82', 'omc', password='Nokia123!')
_netact_http_tang4 = HttpConnectionDetails('https://tang4lbwas.tang4.srnhz.nsn-rdnet.net/', 'omc', password='Nokia123!')
_netact_tang4 = NetAct(_netact_ssh_tang4, _netact_http_tang4)
### Hangzhou Labs ### end ###


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


_pdu_1 = FPFH(
    addr="10.108.191.2",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="FPFH",
)
_pdu_2 = FACOM(
    addr="10.68.170.185",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_3 = HBTE(
    addr="10.68.170.190",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="FACOM",
)
_pdu_4 = HBTE(
    addr="10.68.179.211",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="HBTE",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA191772253",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
 )
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA203761430",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCE.value,
    serial_number="EB191760214",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213014328",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213012521",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="DH200160121",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172409543",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508130",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    hardware_version="473096A.102",
    serial_number="L1232907576",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190206783",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1170502827",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1, _rmod_2,
    ],
    oam_ip=NetworkAddress("10.97.97.145"),
    instance_id=884,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2,], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.97.92.252", username="ute"
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
        addr="10.97.92.253", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NL_ASIB_1ABIO_1ABIN_1ABIL_ASIA_3ABIA_1AHEGB_1AHDB_1AHCE",
    nms=_netact_jiang7
)

__all__ = ["tl"]
