__maintainer__ = "nicoleta.frumosu@nokia.com"
__email__ = "nicoleta.frumosu@nokia.com"
__owner_email__ = "nicoleta.frumosu@nokia.com"

import os
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote
from taf.config.testline.testline import TestLine
from taf.config.testline.optical_switch import Calient
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit, CoreUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.cu import CU
from taf.config.testline.gnb.du import VDU, FHGW, RANNIC
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.gnb.gnb import CloudBts
from taf.config.testline import NetAct
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
    BmcConnectionDetails,
    OpenStackConnectionDetails
)
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.ran import BSC
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    CloudDeployment,
    HelmChart,
    ControlNode,
    NCIR,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.36",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.36",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.2.14",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_OPENED"

_pdu_2 = Gude(
    addr="10.255.2.15",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPENED"

vcu_server_mgmt = SshServiceDetails(
        addr="10.5.46.48",
        username="user_bmc",
        password="Aikon_1234",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.5.46.49",
        username="user_bmc",
        password="Aikon_1234",
    )

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="YK214600105",
    pdu_port=_pdu_1.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM17")],  # windows
    ),
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2221N405R",
    pdu_port=_pdu_1.pdu_ports[10],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM24")],  # windows
    ),
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2214N400R",
    pdu_port=_pdu_1.pdu_ports[11],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM35")],  # windows
    ),
)

_ru_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2330H60AJ",
    pdu_port=_pdu_1.pdu_ports[4],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM25")],  # windows
    ),
)

_ru_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH211400647",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASOG",
    hardware_version="476254A.102",
    serial_number="L1243802132",
    test_pc=_test_pc_2,
)

# _smod_1 = CoreUnit=[_fct_1])

_smod_1 = Airscale(core_units=[_fct_1])

_netact_ssh_2002 = SshServiceDetails(
    addr="10.82.47.15", username="omc", password='Medsql!_1893'
)

_netact_http_2002 = HttpConnectionDetails(
    addr="srnclab2002lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_2002 = NetAct(_netact_ssh_2002, _netact_http_2002)

_netact_ssh_5012 = SshServiceDetails(
    addr="10.8.103.177", username="omc", password='Medsql!_1893'
)

_netact_http_5012 = HttpConnectionDetails(
    addr="srnclab5012lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_5012 = NetAct(_netact_ssh_5012, _netact_http_5012)

_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3, _ru_4],
    instance_id=621144,
    oam_ip=NetworkAddress("10.0.70.234"),
    bcf_id="3234",
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.core_units[0],
        interface_type="lmp",
    )
)

_fhgw1_default_ssh_connection_details = SshServiceDetails(
    addr="10.5.46.49", username="root", password="root"
)
_fhgw_1 = FHGW(
    user_config_path=os.path.join(_cfg_dir, "fhgw_cnf.yaml"),
    rus=[_ru_1, _ru_2, _ru_3, _ru_4],
    fhgw_id=144,
    default_ssh_connection_details=_fhgw1_default_ssh_connection_details,
)

#_vdu1_oam_http_connection_details = HttpConnectionDetails(
#    addr="10.5.12.42",
#    username="Nemuadmin",
#    port=443,
#    password="Nokia@123",
#)

_rannic_1 = RANNIC(
    serial_number="L1240401494",
    product_code="1791.101",
    rus=[_ru_5],
)

"""_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=624144,
    fhuc_vlans=[301],
)"""

_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

"""_vdu_1 = VDU(
    cloud_deployment="None",
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    fhgws=[_fhgw_1],
    rannics=[_rannic_1],
    instance_id=624144,
    fhuc_vlans=[301],
)"""
    
_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.9", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.12.9", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vdu-cluster-preparation.yaml"),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vdu-prerequisite.yaml"),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vdu.yaml"),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.42", port=443, username="Nemuadmin", password="Nokia@123"
)
_vdu = VDU(
    rannics=[_rannic_1],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_1],
    f1_c_ip_addr=NetworkAddress(
        v4="10.5.12.80",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/26"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.5.12.81",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/26"),
    ),
    instance_id=1,
)

"""_cu = CU(
    backhaul_site_oam_ip="None",
    oam_ssh_connection_details=_vcu_oam_ssh_connection_details,
    oam_http_connection_details=_vcu_oam_http_connection_details,
)"""

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.5.12.43",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.5.12.10", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.5.12.43", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.5.12.82",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    xnc=NetworkAddress(
        v4="10.5.12.83",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    f1c=NetworkAddress(
        v4="10.5.12.82",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    f1u=NetworkAddress(
        v4="10.5.12.83",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    ngc=NetworkAddress(
        v4="10.5.12.82",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    ngu=NetworkAddress(
        v4="10.5.12.83",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    tracing=None,
    global_bts_id=62414401,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.10", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.12.10", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vcu-cluster-preparation.yaml"),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vcu.yaml"),
)

'''_vcu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.12.43",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)'''

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

"""_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    dus=[_vdu_1],
)"""

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vDU-624144",
    instance_id=624144, # parameter to do depricated!
)

_test_pc_1.connections.append(_cbts)

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7",
        username="SYSTEM",
        password="SYSTEM",
    ),
)

_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.134",
)

# _app_server_2 = TafUeAppServer(
#    app_server_name="APP_2",
#    address="10.9.146.30",
#    user="iperf_user",
#    password="Treperf",
#    bind_interface_ip="10.9.146.30",
# )

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

# _data_transfer_iperf_2 = TafUeDataTransferProtocol(
#    protocol_name="iperf", app_server=_app_server_2, interval=1, server_close_delay=50
# )

_android1 = TafUeAndroid(
    serial_number="H0R9FI1CN0290800285",
    ue_pc_address="10.5.55.74",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS1_NR"],
)

_android2 = TafUeAndroid(
    serial_number="H2J9FI1CN03A1100054",
    ue_pc_address="10.5.55.74",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS1_NR66"],
)

_android3 = TafUeAndroid(
    serial_number="HZQN1876BAK91400447",
    ue_pc_address="10.5.55.74",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS1_NR3"],
)

_android4 = TafUeAndroid(
    serial_number="Y13K990002550917548",
    ue_pc_address="10.5.55.74",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.74", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="80",
    capabilities=["BTS2_LTE"],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb_lte],
    bscs=[_bsc],
    ues=[_android1, _android2, _android3, _android4],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    nms=_netact_5012,
)

CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSCMTNRL144/cell_target_bw.yaml"
)

# RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSCMTNRL144/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_STOP_AND_FIX": True,
    "USER_RTWP_CHECK": False,
    "USER_RSI_INFO_COLLECT": False,
    "USER_SCF_VALIDATION_CHECK": True,
    "SYSLOG_CHECK": True,
    "SYSLOG_CONTINUE_ON_FAIL": True,
}

__all__ = ["tl"]
