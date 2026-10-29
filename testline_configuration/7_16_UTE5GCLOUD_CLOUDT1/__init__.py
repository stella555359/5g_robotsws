__maintainer__ = "Adam Kropiwnicki"
__email__ = "adam.kropiwnicki@nokia.com"

import os

from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU, FHGW
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.core import RealCore5G
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.122", username="ute", password="ute"
    )
)

_attenuator_1 = TopYoung(ip_addr="10.42.61.216", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                         attenuation_port_numbers=[1, 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 16])
_attenuator_2 = TopYoung(ip_addr="10.42.61.171", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                         attenuation_port_numbers=[9, 10, 11, 12, 13, 14, 15, 16])
_attenuator_3 = TopYoung(ip_addr="10.42.61.243", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                         attenuation_port_numbers=[1, 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 16])

_vcu_vnf_8505 = DeploymentVnfStack(
    name="aic-vcu", #????
    yaml_file=os.path.join(
        _cfg_dir, "[path_to_be_updated]DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vcu_intnet_8505 = DeploymentNetworkStack(
    name="aic-vcu-intnet", #????
    yaml_file=os.path.join(
        _cfg_dir, "[path_to_be_updated]DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu_master_node_8505 = MasterNode(
    k8s_connection_details=K8SConnectionDetails(
        ip_addr="127.0.0.1", #???
        username="core",
        password="system123",
        port="22"
    ),
    ssh_connection_details=SshServiceDetails(
        addr="127.0.0.1", #????
        username="core",
        password="system123"
    )
)
_vcu_k8s_8505 = K8S(
    namespace="cran1", #?????
    master_node=MasterNode(
        k8s_connection_details=K8SConnectionDetails(
            ip_addr="127.0.0.1", #???
            username="core",
            password="system123",
            port="22"
        ),
        ssh_connection_details=SshServiceDetails(
            addr="127.0.0.1", #???
            username="core",
            password="system123"
        )
    )
)

_vcu_k8s_cloud_deployment_8505 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_8505],
    vnfs=[_vcu_vnf_8505],
    cloud_hosting=_vcu_k8s_8505,
)

_vcu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.93.184"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.93.184", username="Nemuadmin", password="Nokia@123", port="443"
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="", username="", password="",
    ),
    tracing=None,
    global_bts_id=8505,
)


_vdu_vnf_8505 = DeploymentVnfStack(
    # this is vdu release name, the name should only be lower case and only can include alphabet, number,
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "[path_to_be_updated]DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_8505 = DeploymentNetworkStack(
    # this is intnet release name, the name should only be lower case and only can include alphabet, number,
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "[path_to_be_updated]DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vdu_master_node_8505 = MasterNode(
    k8s_connection_details=K8SConnectionDetails(
        ip_addr="10.42.38.17",
        username="core",
        password="system123",
        port="22"
    ),
    ssh_connection_details=SshServiceDetails(
        addr="10.42.38.17",
        username="core",
        password="system123"
    )
)
_vdu_k8s_8505 = K8S(
    namespace="cran1",
    master_node=MasterNode(
        k8s_connection_details=K8SConnectionDetails(
            ip_addr="10.42.38.17",
            username="core",
            password="system123",
            port="22"
        ),
        ssh_connection_details=SshServiceDetails(
            addr="10.42.38.17",
            username="core",
            password="system123"
        )
    )
)

_vdu_k8s_cloud_deployment_8505 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_8505],
    vnfs=[_vdu_vnf_8505],
    cloud_hosting=_vdu_k8s_8505,
)

_pxe_server = PxeServer(           #?????????????????
    nfs_ip="10.42.239.60",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.239.60",
        username="ute",
        password="Ut3pa5s#1be1"
    )
)

# FHGW information
_fhgw_8505 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[],
    pxe_server=_pxe_server,
    fhgw_id=8505,
)

_vdu_8505 = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment_8505,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.38.209",
        port="443",
        username="Nemuadmin",
        password="Nokia@123"
    ),
    fhgws=[_fhgw_8505],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.254.33",
        vlan_id=295,
        routing=RoutingInformation(gateway="192.168.254.33", ip_prefix_length=26),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.42.38.81",
        vlan_id=759,
        routing=RoutingInformation(gateway="10.42.38.65", ip_prefix_length=24),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.42.38.145",
        vlan_id=760,
        routing=RoutingInformation(gateway="10.42.38.129", ip_prefix_length=24),
    ),
    instance_id=8505,
)


_vdu_vnf_8506 = DeploymentVnfStack(
    # this is vdu release name, the name should only be lower case and only can include alphabet, number,
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_8506 = DeploymentNetworkStack(
    # this is intnet release name, the name should only be lower case and only can include alphabet, number,
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_master_node_8506 = MasterNode(
    k8s_connection_details=K8SConnectionDetails(
        ip_addr="10.42.38.17",
        username="core",
        password="system123",
        port="22"
    ),
    ssh_connection_details=SshServiceDetails(
        addr="10.42.38.17",
        username="core",
        password="system123"
    )
)
_k8s_8506 = K8S(
    namespace="cran1",
    master_node=MasterNode(
        k8s_connection_details=K8SConnectionDetails(
            ip_addr="10.42.38.17",
            username="core",
            password="system123",
            port="22"
        ),
        ssh_connection_details=SshServiceDetails(
            addr="10.42.38.17",
            username="core",
            password="system123"
        )
    )
)

_k8s_cloud_deployment_8506 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_8506],
    vnfs=[_vdu_vnf_8506],
    cloud_hosting=_k8s_8506,
)

_pxe_server = PxeServer(    #?????????????????
    nfs_ip="10.42.239.60",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.239.60",
        username="ute",
        password="Ut3pa5s#1be1"
    )
)

# FHGW information
_fhgw_8506 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[],
    pxe_server=_pxe_server,
    fhgw_id=8506,
)

_vdu_8506 = VDU(
    cloud_deployment=_k8s_cloud_deployment_8506,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.38.208",
        port="443",
        username="Nemuadmin",
        password="Nokia@123"
    ),
    fhgws=[_fhgw_8506],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.254.33",
        vlan_id=295,
        routing=RoutingInformation(gateway="192.168.254.33", ip_prefix_length=26),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.42.38.80",
        vlan_id=759,
        routing=RoutingInformation(gateway="10.42.38.64", ip_prefix_length=24),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.42.38.144",
        vlan_id=760,
        routing=RoutingInformation(gateway="10.42.38.128", ip_prefix_length=24),
    ),
    instance_id=8506,
)

_cbts = CloudBts(
    dus=[_vdu_8505, _vdu_8506],
    cu=_vcu,
    cloud_deployment=_vcu_k8s_cloud_deployment_8505,
    vnf_name="vdu8505",
    instance_id="8505",
)


pdn_n26wro = PDNTafUeAndroidDetails(
    entryName="n26wro",
    apnName="n26wro",
    apnType=["DEFAULT", "MMS", "SUPL", "HIPRI", "FOTA", "CBS", "XCAP"],
    carrierEnabled=True,
    operatorNumeric="310260",
)


_realcore_appsrv = TafUeAppServer(
    app_server_name='APP_1',
    address='10.42.61.65',
    bind_interface_ip="10.42.197.170",
    user='5g',
    password='2019H@slo',
)


_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    bind_ue_ip='10.42.197.170',
    interface_name='n26wro',
)


_ue_pc_ssh = SshServiceDetails("10.42.61.132", "wro5grrm", password="5gpass!1")

_android_ue_1 = TafUeAndroid(
    ue_pc_address=_ue_pc_ssh.addr,
    ssh_connection_details=_ue_pc_ssh,
    serial_number="Dujac_H0965",
    imei="351901034130470",
    imsi="",
    capabilities=["REAL_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    secret_code='*#*#4636#*#*',
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro],
)



tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
#    tl_cloud_topology="CLOUD_5G_AIC_SISO_TEST",
#    test_pcs=[_enb_test_pc],
    core=RealCore5G(mcc=310, mnc=260),
    attenuators=[_attenuator_1, _attenuator_2, _attenuator_3],
    ues=[_android_ue_1]
)

__all__ = ["tl"]
