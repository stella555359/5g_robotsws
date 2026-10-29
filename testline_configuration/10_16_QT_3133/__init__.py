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
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, ATEN


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.158.124", username="ute", password="UTE.debian12"
    )
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)


_du_pdu = ATEN(
    addr="10.42.51.211",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=6)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(
    addr="10.42.51.211",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=8)

_ru = RU(
    ru_hw_group="AHEB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="192.168.255.129")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_ue_pdu = ATEN(
    addr="10.42.51.211",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="ATEN",
)

_ue_pdu_port = PduPort(pdu=_ue_pdu, port_no=5)

_real_ue = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.158.125", username="ute", password="Ut3pa5s#1be1"
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
    tl_cloud_topology="3133",
)

tl.UE = {
    "UE_ip": "10.0.3.1",
    "master_eth": "192.168.8.111",
    "core_network": "10.0.3.254",
    "router_ip": "192.168.8.1",
    "router_user": "admin",
    "router_password": "admin01",
    "lte_band": "4",
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
    # Sections IDs
    "MRBTS": "1865",
    "LNBTS": "1865",
    "BBMOD": "1",
    "LCELL": "11",
    "LNCEL": "1",
    "TRSNW": "1",

    # Site specific variables
    "_real_core": "false",
    "_gps": "false",
    "_top": "true",

    # MRBTS
    "btsName": "QT-ASIL-ABIP-4G-FDD-WRO-3133",
	
    # MRBTS/EQM/APEQM
    "location": "WRO",

    # MRBTS/EQM/APEQM/CABINET/SMOD
    "moduleLocation": "GTB_Rack7",  # optional

    # MRBTS/EQM/HWTOP/CABLINK
    "firstEndpointPortId_BACKPLANE": "1",
    "firstEndpointPortId_OPT": "1",

    # MRBTS/LNBTS
    "mcc": "244",
    "mnc": "9",

    # MRBTS/LNBTS/LNMME
    "ipAddrPrim": "10.0.1.1",

    # MRBTS/LNBTS/LNCEL
    "lcrId": "11",
    "phyCellId": "11",
    "tac": "124",

    # MRBTS/LNBTS/LNCEL/LNCEL_FDD
    "ulChBw": "10 MHz",
    "dlChBw": "10 MHz",
    "earfcnDL": "1800",
    "earfcnUL": "19800",

    # MRBTS/MNL/MNLENT/SYNC
    "btsSyncMode": "FreqSync",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK
    "syncInputType": "TOPF",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK/NTP
    "ntpServerIpAddrOrFqdnList": "10.42.162.252",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK/TOP/TOPF
    "masterIpAddr": "10.42.161.252",

    # MRBTS/MNL/MNLENT/SYNC/TIME

    # MRBTS/TNLSVC/TNL/IPNO/IPRT
    "gateway": "10.0.1.1",

    # MRBTS/TNLSVC/TNL/IPNO/IPIF/IPADDRESSV4
    "localIpAddr": "10.0.1.2",
    "localIpPrefixLength": "25",
}

__all__ = ["tl"]
