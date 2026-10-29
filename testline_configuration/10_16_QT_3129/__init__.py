__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, APC


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.113", username="ute", password="UTE.debian12"
    )
)

_cu = CU(
    backhaul_site_oam_ip="10.42.174.176",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.174.176", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.174.176", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)


_du_pdu = APC(
    addr="10.42.168.210",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=4)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu1 = APC(
    addr="10.42.168.210",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_ru_pdu2 = APC(
    addr="10.42.168.210",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_ru_pdu_port1 = PduPort(pdu=_ru_pdu1, port_no=4)
_ru_pdu_port2 = PduPort(pdu=_ru_pdu2, port_no=4)

_ru1 = RU(
    ru_hw_group="FRHC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.129", port=2323
    ),
    pdu_port=_ru_pdu_port1,
)

_ru2 = RU(
    ru_hw_group="FRHC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_ru_pdu_port2,
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="192.168.255.129")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_ue_pdu = APC(
    addr="10.42.168.211",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="APC",
)

_ue_pdu_port = PduPort(pdu=_ue_pdu, port_no=4)

_real_ue = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.158.241", username="ute", password="Ut3pa5s#1be1"
    ),
    serial_number="None",
    server_dir=None,
    python_path=None,
    imsi="None",
    capabilities=["_4G"],
    pdu_port=_ue_pdu_port,
)

_real_ue.ue_type = "huawei_router"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_real_ue],
    enbs=[_cbts],
    tl_cloud_topology="3129",
)

tl.UE = {
    "UE_ip": "192.168.125.4",
    "master_eth": "192.168.35.101",
    "core_network": "192.168.125.1",
    "router_ip": "192.168.35.130",
    "router_user": "admin",
    "router_password": "admin01",
    "lte_band": "40",
    "S1_interface": "eth2",
    "UE_mode": "remote_master",
}

tl.target_traffic_4G = {
    "tput_dl_min": "40",  # Mbits/sec
    "tput_ul_min": "12",  # Mbits/sec
    "port_ul": "5110",
    "port_dl": "7010",
    "tput_time": "120",
    "tput_ul": "15M",
    "tput_dl": "50M",
    "interval": "1",
    "len_ul": "1320",
    "len_dl": "1470",
}

tl.scf_variables = {
    # MRBTS
    "btsName": "QT-ASIA_ABIA_4G_FDD-WRO-3129",
    "enbName": "LTERPIVTL1",
	    		
    # Site specific variables
    "_real_core": "false",
    "_top": "false",

	# Sections IDs
    "MRBTS": "1293",
    "LNBTS": "1293",
	
	
    # MRBTS/EQM/APEQM/CABINET/SMOD
    "moduleLocation": "GTB",  # optional
    "positionInSubrack": "LeftSide",
	
    # MRBTS/EQM/HWTOP/CABLINK
    "firstEndpointPortId_BACKPLANE_1": "2",
    "firstEndpointPortId_OPT": "1",
    "firstEndpointPortId_BACKPLANE_2": "1",
    "firstEndpointLabel": "OPT",
	
	
    # MRBTS/LNBTS
    "mcc": "244",
    "mnc": "9",
	
    # MRBTS/LNBTS/LNCEL
    "ulChBw": "10 MHz",
    "dlChBw": "10 MHz",
    "phyCellId_1": "1",
    "phyCellId_2": "2",
    "phyCellId_3": "3",
    "tac": "124",	
    "earfcnDL_1": "2900",
    "earfcnUL_1": "20900",
    "earfcnDL_2": "2900",
    "earfcnUL_2": "20900",
    "earfcnDL_3": "2900",
    "earfcnUL_3": "20900",
	
    # MRBTS/LNBTS/LNMME
    "ipAddrPrim": "10.42.174.66",
	
    # MRBTS/MNL/MNLENT/SYNC/CLOCK/NTP
    "ntpServerIpAddrOrFqdnList": "10.42.162.252",
	
    # MRBTS/TNLSVC/TNL/IPNO/IPRT
    "gateway": "10.42.174.1",

    # MRBTS/TNLSVC/TNL/IPNO/IPIF/IPADDRESSV4
    "localIpAddr": "10.42.174.176",
    "localIpPrefixLength": "23",

}


__all__ = ["tl"]
