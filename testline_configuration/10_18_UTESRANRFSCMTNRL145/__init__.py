__maintainer__ = "anelore.tasala@nokia.com"
__email__ = "anelore.tasala@nokia.com"
__owner_email__ = "anelore.tasala@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.gnb.cu import CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.gnb import CloudBts
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ran import RNC
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    CloudDeployment,
    HelmChart,
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))


_test_pc_1= TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.37",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.37", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.53", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.2.20",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"


_pdu_2 = Gude(
    "10.255.2.21",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    "10.255.2.22",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="BL2351C69VG",
    pdu_port=_pdu_3.pdu_ports[11],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.45",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM7"
            )
        ]
    )
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9182830755",
    pdu_port=_pdu_1.pdu_ports[7],
)

_ru_3 = RU(
  ru_hw_group="",
  radio_type=RadioTypes.AHFIB.value,
    serial_number="K9183140933",
    pdu_port=_pdu_1.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.45",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM4"
            )
        ]
    )
)

_ru_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH251707684",
    pdu_port=_pdu_1.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.104",
    serial_number="L1221102634",
    rus=[_ru_1],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778040",
    rus=[_ru_1],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.104",
    serial_number="L1221102636",
    rus=[_ru_2, _ru_3],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170416093",
    rus=[_ru_2, _ru_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1244004849",
    test_pc=_test_pc_2,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1223402810",
    test_pc=_test_pc_3,
)


_smod_1 = Airscale([_fct_1, _fct_2])


_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3],
    instance_id=621145,
    oam_ip=NetworkAddress("10.0.70.235"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[1],
        interface_type="lmp",
    )
)

_rannic_1 = RANNIC(
    serial_number="L1240401496",
    product_code="AF1791.101",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4],
)



_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.44",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.48", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.12.48", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vdu-cluster-preparation.yaml"),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vdu-prerequisite.yaml"),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "vdu-cnf.yaml"),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_1 = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=623145,
    fhuc_vlans=[301],
)

_vcu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.11", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.12.16", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_oam_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vcu-cluster-preparation.yaml"),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_vcu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.45",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_cu = CU(
    backhaul_site_oam_ip="None",
    oam_ssh_connection_details=_vcu_oam_ssh_connection_details,
    oam_http_connection_details=_vcu_oam_http_connection_details,
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    dus=[_vdu_1],
)

_test_pc_1.connections.append(_cbts)

_rnc = RNC(
    rnc_id=8,
    oms_ip="10.44.44.219",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="root", password="root"
    ),
)

#_rnc = RNC(
#    rnc_id="10290",
#    oms_ip="10.27.31.235",
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.55.0.13", username="_nokadmin", password="_P@ssword123"
#    ),
#)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.24",
    user="ftp3_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.138",
)

#_app_server_2 = TafUeAppServer(
#    app_server_name="APP_2",
#    address="10.9.146.30",
#    user="iperf_user",
#    password="Treperf",
#    bind_interface_ip="10.9.146.30",
#)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

#_data_transfer_iperf_2 = TafUeDataTransferProtocol(
#    protocol_name="iperf", app_server=_app_server_2, interval=1, server_close_delay=50
#)

_android1 = TafUeAndroid(
    serial_number="H0J9DE1CN01C0900204",
    ue_pc_address="10.5.55.45",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.45", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS1_NR"],
)

_android2 = TafUeAndroid(
    serial_number="H2J9FI1CN03C2200346",
    ue_pc_address="10.5.55.45",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.45", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS2_LTE"],
)

#_android3 = TafUeAndroid(
#    serial_number="H0J9DE1LV0190600345",
#    ue_pc_address="10.5.55.47",
#    data_transfer=[_data_transfer_iperf_2],
#    ssh_connection_details=SshServiceDetails(
#        addr="10.5.55.47", username="rfsharing", password="Nokia2022!@1"
#    ),
#    ue_pc_port="80",
#    capabilities=["BTS2_WCDMA"],
#)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_cbts],
    ues=[_android1, _android2],
    enbs=[_enb_lte],
    rncs=[_rnc],

)

CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSCMTNRL145/cell_target_bw.yaml"
)
#RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSCMTNRL145/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "USER_STOP_AND_FIX": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
#    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "POWER_ON_FLAG": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSCMTNRL145/custom_rmod_setup.yaml"
}

__all__ = ["tl"]
