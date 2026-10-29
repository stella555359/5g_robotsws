__maintainer__ = "xiaochen"
__team__ = "MN_RAN_HAZ_PZ1_T05"
__email__ = "xiaofei.chen@nokia-sbell.com"
__owner_email__ = "xiaofei.chen@nokia-sbell.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetAct

### BLR Labs ### start ###
_netact_ssh_1015 = SshServiceDetails('10.41.146.134', 'omc', password='Medsql!_1893')
_netact_http_1015 = HttpConnectionDetails('srnclab1015lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1015 = NetAct(_netact_ssh_1015, _netact_http_1015)

_netact_ssh_1019 = SshServiceDetails('10.41.147.15', 'omc', password='Medsql!_1893')
_netact_http_1019 = HttpConnectionDetails('srnclab1016lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1019 = NetAct(_netact_ssh_1019, _netact_http_1019)

_netact_ssh_1047 = SshServiceDetails('10.43.48.192', 'omc', password='Medsql!_1893')
_netact_http_1047 = HttpConnectionDetails('srnclab1025lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1047 = NetAct(_netact_ssh_1047, _netact_http_1047)

_netact_ssh_1027 = SshServiceDetails('10.41.148.99', 'omc', password='Medsql!_1893')
_netact_http_1027 = HttpConnectionDetails('srnclab1027lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1027 = NetAct(_netact_ssh_1027, _netact_http_1027)

_netact_ssh_2003 = SshServiceDetails('10.82.47.46', 'omc', password='Medsql!_1893')
_netact_http_2003 = HttpConnectionDetails('srnclab2003lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_2003 = NetAct(_netact_ssh_2003, _netact_http_2003)

_netact_ssh_2002 = SshServiceDetails('10.82.47.15', 'omc', password='Medsql!_1893')
_netact_http_2002 = HttpConnectionDetails('srnclab2002lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_2002 = NetAct(_netact_ssh_2002, _netact_http_2002)

_netact_ssh_3007 = SshServiceDetails('10.99.127.179', 'omc', password='Medsql!_1893')
_netact_http_3007 = HttpConnectionDetails('srnclab2002lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_3007 = NetAct(_netact_ssh_3007, _netact_http_3007)
### BLR Labs ### start ###

### Hangzhou Labs ### start ###
_netact_ssh_chen4 = SshServiceDetails('10.108.248.82', 'omc', password='Nokia126_')
_netact_http_chen4 = HttpConnectionDetails('chen4lbwas.chen4.srnhz.nsn-rdnet.net', 'omc', password='Nokia126_')
_netact_chen4 = NetAct(_netact_ssh_chen4, _netact_http_chen4)

_netact_ssh_chen2 = SshServiceDetails('10.68.84.15', 'omc', password='Nokia123！')
_netact_http_chen2 = HttpConnectionDetails('chen2lbwas.chen2.srnhz.nsn-rdnet.net', 'omc', password='Nokia123！')
_netact_chen2 = NetAct(_netact_ssh_chen2, _netact_http_chen2)

_netact_ssh_jiang7 = SshServiceDetails('10.56.3.18', 'omc', password='Nokia123！')
_netact_http_jiang7 = HttpConnectionDetails('jiang7lbwas.jiang7.srnhz.nsn-rdnet.net', 'omc', password='Nokia123！')
_netact_jiang7 = NetAct(_netact_ssh_jiang7, _netact_http_jiang7)
### Hangzhou Labs ### end ###

# Radio units
_pdu_1 = TopYoung(
    addr="10.108.151.102",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="TopYoung",
)
_pdu_2 = FPFH(
    addr="10.69.101.26",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    login="admin",
    password="admin",
    model="FPFH",
)
_rmod_1 = RU(
    ru_hw_group="RRH6.2",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2234N41L0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="RRH6.2",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2316N44W1",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="RRH6.2",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2216N401E",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="RRH6.0",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH211900767",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="RRH6.0",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH213190134",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

###############################################
# MRBTS-37564 SBTS Side #
###############################################
_pdu_3 = FACOM(
    addr="10.108.166.201",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_4 = FPFH(
    addr="10.106.205.35",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
   
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA213850668",
    rus=[],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650633",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309827",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2,],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1204202777",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3,],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220845091",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_ru_cablinks_5G = [
    Cablink(
        source=Endpoint(unit=_fsp_1, label="SFP", port_id=1),
        target=Endpoint(unit=_rmod_3, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_1, label="SFP", port_id=2),
        target=Endpoint(unit=_rmod_2, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_2, label="SFP", port_id=1),
        target=Endpoint(unit=_rmod_1, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_3, label="SFP", port_id=1),
        target=Endpoint(unit=_rmod_4, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_3, label="SFP", port_id=3),
        target=Endpoint(unit=_rmod_5, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_fsp_3, label="SFP", port_id=7),
        target=Endpoint(unit=_rmod_4, label="SFP", port_id=1),
    ),
]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    cablinks=_ru_cablinks_5G,    
    oam_ip=NetworkAddress("10.106.205.131"),
    instance_id=8241,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2,], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.152.229", username="ute"),
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
    SshServiceDetails(addr="10.108.152.236", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)



###############################################
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_N_2ASIL_2ABIL_ABIO_3AHFII_2AZHL_RFS_602",
    nms=_netact_2002, 
)

__all__ = ["tl"]
