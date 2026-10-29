__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"

import os
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.ue import TafUeAt, PluginAtClassType

_test_pc = TestPc(
	default_ssh_connection_details=SshServiceDetails(
		addr="10.33.98.191",
		username="ute",
		password="UTE.debian12",
	)
)

_test_pc_2 = TestPc(
	default_ssh_connection_details=SshServiceDetails(
		addr="10.33.95.114",
		username="ute",
		password="UTE.debian12",
	)
)

_appserver_ssh = SshServiceDetails(
	addr="10.33.98.192",
	username="ute",
	password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
	ssh_connection_details=_appserver_ssh,
	network_interface_address="10.35.102.96",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
	address="10.35.102.96",
	user="srn",
	password="!!IperfUser@25",
	bind_interface_ip="10.35.102.96",
	expected_prompt="srn@iperfU39",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
	protocol_name="iperf",
	app_server=_appserver_taf_ue,
	interval=1
)

_snmp_user_data = dict(
	userName="administrator",
	authKey="password",
	privKey="password",
	authProtocol="SHA1",
	privProtocol="AES-128",
)

_cu = CU(
	backhaul_site_oam_ip="10.33.54.132",
	oam_ssh_connection_details=SshServiceDetails(
		addr="10.33.54.132", username="toor4nsn", password="oZPS0POrRieRtu"
	),
	oam_http_connection_details=HttpConnectionDetails(
		addr="10.33.54.132", username="Nemuadmin", password="nemuuser"
	),
)

_du_lmp_connection = SshServiceDetails(
	addr="10.33.54.132", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu_0 = Gude(
	addr="10.33.11.9",
	port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	model="EPC",
	version="8220-1",
	snmp_user=_snmp_user_data,
)

_du_pdu_1 = Gude(
	addr="10.33.11.10",
	port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	model="EPC",
	version="8220-1",
	snmp_user=_snmp_user_data,
)

_du_common_unit0 = CommonUnit(
	lmp_connection=_du_lmp_connection,
	capacity_units=[None],
	pdu_port=_du_pdu_0.pdu_ports[3],
)

_du_common_unit1 = CommonUnit(
	lmp_connection=_du_lmp_connection,
	capacity_units=[None],
	pdu_port=_du_pdu_1.pdu_ports[9],
)

_airscale = Airscale(common_units=[_du_common_unit0, _du_common_unit1])

_ru_pdu = Gude(
	addr="10.33.16.144",
	port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	model="EPC",
	version="8220-1",
	snmp_user=_snmp_user_data,
)

_ru1 = RU(
	ru_hw_group="AHEGA",
	default_ssh_connection_details=SshServiceDetails(
		addr="172.16.33.129", username="root", password=""
	),
	lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
	pdu_port=PduPort(pdu=_ru_pdu, port_no=11)
)

_ru2 = RU(
	ru_hw_group="FXJB",
	default_ssh_connection_details=SshServiceDetails(
		addr="172.16.10.128", username="root", password=""
	),
	lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
	pdu_port=PduPort(pdu=_ru_pdu, port_no=8)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.42.6.38")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_lmp_connection = SshServiceDetails(
	addr="5.5.5.5", username="user5", password="password5"
)

_android_4G = TafUeAndroid(
	serial_number="PetuintK074",
	capabilities=["_4G"],
	ue_pc_address="10.33.10.75",
	data_transfer=[_data_transfer_iperf],
	ssh_connection_details=SshServiceDetails(
		addr="10.33.10.75", username="FIOUSRUSR", password="!SRkuivasranta2"
	),
	ueproxy_force_release=False,
	proxy_mngr_port=80,
	imsi="244096010198217",
	qualcomm_prototype=False,
	voice_call_dialing_timeout="30",
	network_mode_switch_method="secretcode",
	#airplane_mode_switcher_text="Off|On",
)

_android_4G.ue_type = "android"

tl = TestLine(
	test_pc=_test_pc,
	gnbs=[_cbts],
	core=None,
	ues=[_android_4G],
	tl_cloud_topology="7012",
	test_pcs=[_test_pc_2, _test_pc],
)

tl.target_traffic_4G = {
	"MIN_DL": "12",  # Mbits/sec
	"MIN_UL": "8",  # Mbits/sec
	"MAX_DL": "15",  # Mbits/sec
	"MAX_UL": "10",  # Mbits/sec
	"IPERF_DURATION": "70",  # seconds
	"cell_id_rf1": "18739713",
}

tl.custom = {
	"is_MRAT": "True",
}

tl.scf_variables = {
	# General
	"btsid": "73202",
	"btsName": "QT-ASIB_FSMF_ABIA_4G_3G_2G_FDD-OULU-7012",
	"location": "OULU",

	# Sync
	"_gps": "false",
	"_top": "true",
	"masterIpAddr": "10.33.50.2",  # Optional (comment if not used)
	"ntpServerIpAddr": "10.35.50.209",  # Optional (comment if not used)

	# IP addresses
	"ipif_4": "10.33.54.132",
	"ipif_4_prefixlength": "27",
	"ipif_4_destipprefixlength": "0",
	"ipif_4_destipaddr": "0.0.0.0",
	"ipif_4_gateway": "10.33.54.129",

	# GSM
	"bcfid": "307",
	"bscid": "606",
	"perTrxPower": "391",
	"gsm_ipaddressomusig": "10.35.70.176",

	# WCDMA
	"wcdma_rncidentifier": "604",
	"wcdma_sctpfarendsubnetipaddress": "10.35.74.149",
	"wcdma_sctpfarendsubnetprefixlength": "32",
	"wcdma_sctpportmin": "49234",
	"wncel_id": "1",
	"wncel_id_defaultcarrier": "10740",
	"maxCarrierPower": "421",

	# LTE
	"lnbtsid": "73202",
	"ipAddrPrim": "10.33.58.200",
	
	#"gtpu_sgwipaddress": "",  # Optional (comment if not used)
	"mcc": "244",
	"mnc": "9",
	"tac": "9000",
	"lncel_id01": "23316",
	"lncel_id01_phycell": "1",
	"lncel_id01_earfcndl": "3630",
	"lncel_id01_earfcnul": "21630",
	"LCELL": "1",
	"lcrId": "1",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]