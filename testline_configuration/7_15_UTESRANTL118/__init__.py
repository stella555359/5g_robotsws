##########################################
# TestLine TL118 Ulm (7_15_UTESRANTL118) #
##########################################
__maintainer__ = "Masiar Makkinejad"
__email__ = "masiar.makkinejad@nokia.com"

import os

from typing import Optional, List, Union
from enum import Enum

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.pdn import PDN, PDPTypes

from taf.config.testline.appserver import AppServer

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline import PDNTafUeAndroidDetails
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.lmi import SerialOverTcp, Remote

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ---------------- START Power Switchs

# pdu1-215 - SMOD_pdu and RMOD_pdu
_pdu1_215 = Gude(
    addr="10.46.133.35",
    port_numbers=[
        2,  # SMOD-1 (ASOG)
        10,  # RMOD-1 - AHPMDG#09
        11,  # RMOD-2 - AHPMDG#14
        12,  # RMOD-3 - AHPMDG#15
    ],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
# gNB118_rf_att = deul5gatt215
_gNB118_rf_att = HBTE(
    ip_addr="10.46.133.95",
    port="5000",
    attenuation_port_numbers=[
        1,
        2,
        3,
        4,  # AHPMDG#09 Ant1 - Ant4
        5,
        6,
        7,
        8,  # AHPMDG#14 Ant1 - Ant4
        9,
        10,
        11,
        12,  # AHPMDG#15 Ant1 - Ant4
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- END RF Attenuators

# ---------------- START gNB-1 -------------------TL118#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.200.1",
        v6="",
        vlan_id=1118,
        routing_v4=RoutingInformation(gateway="10.47.200.6/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.200.25",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.30/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    x2u=NetworkAddress(
        v4="10.47.200.33",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.38/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    s1u=NetworkAddress(
        v4="10.47.200.33",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.38/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngu=NetworkAddress(
        v4="10.47.200.57",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.62/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngc=NetworkAddress(
        v4="10.47.200.49",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.54/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    xnc=NetworkAddress(
        v4="10.47.200.49",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.54/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    xnu=NetworkAddress(
        v4="10.47.200.57",
        v6="",
        vlan_id=1218,
        routing_v4=RoutingInformation(gateway="10.47.200.62/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu1_215.pdu_ports[2],
    hardware_type="ASOG",
    serial_number="L1243802113",
)

# RMOD-1: AHPMDG #09
_rmod1_AHPMDG_09 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242706913",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_215.pdu_ports[10],
    attenuation_ports=[
        _gNB118_rf_att.attenuator_ports[1],
        _gNB118_rf_att.attenuator_ports[2],
        _gNB118_rf_att.attenuator_ports[3],
        _gNB118_rf_att.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.10", port="5001"),
        ],
    ),
)

# RMOD-2: AHPMDG #14
_rmod2_AHPMDG_14 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242702528",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_215.pdu_ports[11],
    attenuation_ports=[
        _gNB118_rf_att.attenuator_ports[5],
        _gNB118_rf_att.attenuator_ports[6],
        _gNB118_rf_att.attenuator_ports[7],
        _gNB118_rf_att.attenuator_ports[8],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.20", port="5001"),
        ],
    ),
)

# RMOD-3: AHPMDG #15
_rmod3_AHPMDG_15 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242702549",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu1_215.pdu_ports[12],
    attenuation_ports=[
        _gNB118_rf_att.attenuator_ports[9],
        _gNB118_rf_att.attenuator_ports[10],
        _gNB118_rf_att.attenuator_ports[11],
        _gNB118_rf_att.attenuator_ports[12],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.30", port="5001"),
        ],
    ),
)


_airscale_TL118 = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale_TL118,
    rus=[
        _rmod1_AHPMDG_09,
        _rmod2_AHPMDG_14,
        _rmod3_AHPMDG_15,
    ],
)
_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=8011, instance_id=8011
)

# ----------------- START eNB Common --------------------TL118 #
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDG_09,
        _rmod2_AHPMDG_14,
        _rmod3_AHPMDG_15,
    ],
    oam_ip=NetworkAddress(v4="10.47.200.1"),
)
# ----------------- STOP eNB Common --------------------TL118 #

_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDG_09,
        _rmod2_AHPMDG_14,
        _rmod3_AHPMDG_15,
    ],
    bcf_id="17",
    master=_comnBTS_eNB1,
)

_bsc = BSC(
    name="BSC-17",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START Core APP Server ------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv02.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.202",
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv02
_app_server = TafUeAppServer(
    app_server_name="DEUL5Gappsrv02",
    address="DEUL5Gappsrv02.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.202",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server,
    interval=1,
    version=3,
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server,
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server,
    interval=1,
)
# ---------------- END Core APP Server ------------------- #

# ---------------- START PDNs ------------------- #
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="001", mnc="01", pdns=_pdns)
# ---------------- END PDNs.

# ---------------- START UE1 ------------------------
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-118.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)
_ue1_pdn1_details = [
    PDNTafUeAndroidDetails(
        entryName="ulmsa", apnName="ulmsa", apnType=["DEFAULT", "MMS", "XCAP"]
    )
]

# UE#1 - UE type: TBD
_ue1 = TafUeAndroid(
    serial_number="RFCX81EWE0J",
    ue_pc_address="DEUL5GNUC1-118.intra.noklab.net",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    pdns=_ue1_pdn1_details,
)
# ---------------- END UE1 ------------------------


# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL118.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        Connection(interface="eth1", device=_SMOD1, interface_type="lmp"),
    ],
)
# ---------------- END TEST PCs -------------------------- #

# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    bts2g_objects=[_bts2g_gsm],
    gnbs=[_comnBTS_gNB1],
    enbs=[_comnBTS_eNB1],
    pdus=[_pdu1_215],
    core=_tampereCore,
    attenuators=[_gNB118_rf_att],
    appserver=_appserver,
    # tl_cloud_topology="N/A",
    ues=[_ue1],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
