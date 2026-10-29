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

_pdu_1 = HBTE(
    addr="10.108.190.22",
    port_numbers=[2, 3],
    model="HBTE",
)
_pdu_2 = HBTE(
    addr="10.108.190.23",
    port_numbers=[2],
    model="HBTE",
)

_pdu_3 = FPFH(
    addr="10.108.190.73",
    port_numbers=[2, 3, 4],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_4 = FPFH(
    addr="10.108.190.74",
    port_numbers=[1, 2, 4],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_5 = HBTE(
    addr="10.108.190.66",
    port_numbers=[2, 4],
    model="HBTE",
)
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4,_pdu_5]

# _ru_1_pdu = PBHBTE(addr="10.68.87.14", port_numbers=[7])
_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[1],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2249V0EDU",
    radio_type=RadioTypes.AHFIB,
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[2],
    ru_hw_group="FRMr5.1_1_2T4R",
    serial_number="K9182845207",
    radio_type=RadioTypes.AHFIB,
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[4],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2249V0EDX",
    radio_type=RadioTypes.AHFIB,
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[2],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="K9221231650",
    radio_type=RadioTypes.AEHC,
)
_ru5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[3],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="AH232700001",
    radio_type=RadioTypes.AEHC,
)

_ru6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[2],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="L1210403315",
    radio_type=RadioTypes.AEHC,
)

_ru7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[2],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="K9183920946",
    radio_type=RadioTypes.AHLOA,
)

_ru8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[3],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="BL1930G11SK",
    radio_type=RadioTypes.AHLOA,
)

_ru9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[4],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="BL1930G11T9",
    radio_type=RadioTypes.AHLOA,
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220610197",
    rus=[_ru1, _ru2, _ru3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220610198",
    rus=[_ru4, _ru5, _ru6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1174603760",
    rus=[_ru4, _ru5, _ru6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH214242138",
    rus=[_ru7, _ru8, _ru9],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213108399",
    rus=[_ru7, _ru8, _ru9],
)

_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_5.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213511563",
)

_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_5.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1223304502",
)

_smod_1 = Airscale(common_units=[_common_unit1])

_smod_2 = Airscale(common_units=[_common_unit2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_ru1, _ru2, _ru3, _ru4, _ru5, _ru6],
    oam_ip=NetworkAddress("10.68.181.72"),
    instance_id=11297,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_ru7, _ru8, _ru9], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.101", username="ute"
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
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.102", username="ute"
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
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_2ASIL_4ABIO_1ABIA_3AHLOA_3AHFIB_3AEHC",
    nms=_netact_tang4
)

__all__ = ["tl"]