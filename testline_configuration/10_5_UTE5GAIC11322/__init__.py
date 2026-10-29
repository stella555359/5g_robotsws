__maintainer__ = "Ling, Larry"
__team__ = "I_NSB_MN_RAN_PZ_1_HAZ_12_GMS"
__email__ = "i_nsb_mn_ran_pz_1_haz_12@internal.nsn.com"
__owner_email__ = "larry.ling@nokia-sbell.com"

import os, subprocess

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
    IperfDataTransferDetails,
)
from taf.config.testline import NetAct
from taf.config.testline.testpc import TestPc
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import HBTE, FACOM, PduPort, Pdu, EPC
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.core import RealCore
from taf.config.testline.ue import Android, Qualcomm
from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes

# Following mandatory files and parameters should be configured
# Please don't ignore any parameters, you can add, but don't ingore
# Any problem, please check with CI team

#####  FOLLOWING ARE CHECKLIST OF TESTLINE CONFIGURATION #######

#  1. 5gbts_ext_net.env have been configured as following
#  2. 5gbts_flavor.env have been configured as following
#  3. 5gbts_heat.env have been configured as following
#  4. aic-intnet-values-override_${vdu_index}.yaml (vdu_index should start from 0) have been configured as following
#  5. aic-vdu-values-override_${vdu_index}.yaml (vdu_index should start from 0) have been configured as following
#  6. user_config_${fhgw_index}.yaml (fhgw_index should start from 0) have been configured as following (currently, it's not used)
#  7. "vnf_prefix" in 5gbts_flavor.env should be re-configued, don't use common flavor name
#  8. vnf_prefix naming rule should be flavor-<testline name>, e.g: flavor-7_5_UTE5GAIC001T037
#  9. "flavors" in 5gbts_heat.env should be configured and prefix should equal to vnf_prefix value configured on 5gbts_flavor.env
#  10. please make sure 5gbts_ext_net.env, 5gbts_flavor.env, 5gbts_heat.env are new enough for next build
#  11. please make sure aic-intnet-values-override_x.yaml and aic-vdu-values-override_x.yaml are new enough for next build
#  12. please make sure files in step 1,2,3,4,5 have valid configuration
#  13. please make sure ip address of NCIR and test pc can be accessible by network
#  14. please make sure VDU on OE have been cleared or VDU helm release name is equal to name of DeploymentVnfStack before start agent_5g_aic
#  15. please make sure VCU on NCIR have been cleared or VCU stack name is TL_<testline name>_BTS before start agent_5g_aic
#  16. please check nom mo configured
#################################################################


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# UTE IP address and User Name, Password,
# this is test PC for AIC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.44", username="ute", password="uteUTE!"
    )
)

########### Part 6: attenuator ############################
# _hbte_params = {
#     "ip_addr": "10.97.83.32",
#     "port": 5000,
#     "attenuation_port_numbers": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
#     "model": "HBTE-PA-8-2-4-127-0.5-B-S",
#     "version": None,
# }
# _attenuator_5G = HBTE(**_hbte_params)

########### Part 3: gnbs ##################################
# RU configuration
_pdu_1 = FACOM(
    addr="10.97.65.200",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_ru_1 = RU(
    ru_hw_group="RU_INT_ECPRI",
    serial_number="1M214802107",
    # radio_type=RadioTypes.AZQJ,
    radio_type="AZQJ",
    # attenuation_ports=[
    #     _attenuator_5G.attenuator_ports[1],
    #     _attenuator_5G.attenuator_ports[2],
    #     _attenuator_5G.attenuator_ports[3],
    #     _attenuator_5G.attenuator_ports[4],
    #     _attenuator_5G.attenuator_ports[5],
    #     _attenuator_5G.attenuator_ports[6],
    #     _attenuator_5G.attenuator_ports[7],
    #     _attenuator_5G.attenuator_ports[8],
    #     _attenuator_5G.attenuator_ports[9],
    #     _attenuator_5G.attenuator_ports[10],
    #     _attenuator_5G.attenuator_ports[11],
    #     _attenuator_5G.attenuator_ports[12],
    #     _attenuator_5G.attenuator_ports[13],
    #     _attenuator_5G.attenuator_ports[14],
    #     _attenuator_5G.attenuator_ports[15],
    #     _attenuator_5G.attenuator_ports[16],
    # ],
    pdu_port=_pdu_1.pdu_ports[2],
)
# VDU related NCIR controlNode
_control = ControlNode(
    # Configuration for SSH access
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.195.98", username="cranuser1", password="systeM!23"
    ),
    # Configuration for openstack connection
    open_stack_connection_details=OpenStackConnectionDetails(
        username="cranuser1",
        password="systeM!23",
        ip_addr="10.108.195.98",
        tenant="cran1",
    ),
    # Configuration of BMC connection, if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(
        addr="10.108.195.19", username="admin", password="Nokia*1234567890"
    ),
)

# configuration of VCU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="OE20")

# CU configuration
_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.110.83.133"
        # v6='2a00:8a00:8000:136:10:57:159:1111'
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.110.83.133", username="Nemuadmin", password="nemuuser"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.110.83.133", username="Nemuadmin", password="Nokia@123", port="443"
    ),
    # route configuration for x2 link to ENB, v4 is network address of ENB x2 link
    x2c=NetworkAddress(
        v4="10.110.80.164",
        vlan_id=3323,
        routing=RoutingInformation(gateway="10.110.80.161", ip_prefix_length=28),
    ),
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.110.81.57",
        vlan_id=2101,
        routing=RoutingInformation(gateway="10.110.81.1", ip_prefix_length=24),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.110.81.59",
        vlan_id=2101,
        routing=RoutingInformation(gateway="10.110.81.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.110.80.196",
        vlan_id=3325,
        routing=RoutingInformation(gateway="10.110.80.193", ip_prefix_length=28),
    ),
    x2u=NetworkAddress(
        v4="10.110.80.164",
        vlan_id=3323,
        routing=RoutingInformation(gateway="10.110.80.161", ip_prefix_length=28),
    ),
    tracing=None,
)

# enb for NSA
_real_enb = RealEnb(oam_ip="10.97.122.232", instance_id="")

# test pc information of enb
# you can configure it as AIC UTE environment
_enb_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.44", username="ute", password="uteUTE!"
    ),
    connections=[_real_enb],
)

# # flavor of VCU
# flavor_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_flavor.env")]
#
# # ext_net of VCU
# net_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.env")]
#
# # heat parameters
# vnf_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.env")]
#
# _cbts_flavor = DeploymentFlavorStack(
#     name="name is not used",  # this name is not used, you need NOT configure it, let it be
#     env_files=flavor_env_files,
#     default_vnf_prefix="hgz-tl4444",
# )
#
# _cbts_net = DeploymentNetworkStack(
#     name="name is not used",  # this name is not used, you need NOT configure it, let it be
#     env_files=net_env_files,
#     yaml_file=os.path.join(_cfg_dir, "5gbts_ext_net.yaml"),
# )
#
# _cbts_vnf = DeploymentVnfStack(
#     name="name is not used",  # this name is not used, you need NOT configure it, let it be
#     env_files=vnf_env_files,
#     yaml_file=os.path.join(_cfg_dir, "5gbts_heat.yaml"),
# )
#
# # cloud deployment configuration fo VCU
# _cloud_deployment = CloudDeployment(
#     default_cfg_dir=_cfg_dir,
#     flavors=[_cbts_flavor],
#     networks=[_cbts_net],
#     vnfs=[_cbts_vnf],
#     cloud_hosting=_ncir,
# )

# VDU configuration for deployment
_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",  # this is vdu release name, the name should only be lower case and only can include alphabet, number, _
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

# VDU internal network configuration for deployment
_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",  # this is intnet release name, the name should only be lower case and only can include alphabet, number, _
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cluster-preparation.yaml'),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

# ssh connection information of OE, for tenant user
_ssh_connection_details = SshServiceDetails(
    addr="10.108.195.98", username="cranuser1", password="systeM!23"
)

# ssh connection information of OE, for cloud admin user
_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.108.195.98", username="core", password="system123", port="22"
)

# master node information of OE
_master_node = MasterNode(
    k8s_connection_details=_k8s_connection_details,
    ssh_connection_details=_ssh_connection_details,
)

_k8s = K8S(namespace="cran1", master_node=_master_node)

# VDU deployment configuration
_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    # networks=[_vdu_intnet_0],
    # vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

# VDU oam http connection
_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.108.195.130", port="443", username="Nemuadmin", password="Nokia@123"
)

# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="10.108.194.30", username="ute", password="N0kia@dmin"
)
_pxe_server = PxeServer(
    nfs_ip="10.108.194.30", ssh_connection_details=_pxe_server_ssh_info
)

# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1],
    pxe_server=_pxe_server,
)

# fhgw extra parameter configuration
_fhgw_0.ssh_username = "toor4nsn"
_fhgw_0.ssh_password = "Fhgw@nokia123"

# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=11322,
    fhuc_vlans=[717, 717],

    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.254.33",
        vlan_id=295,
        routing=RoutingInformation(gateway="192.168.254.34", ip_prefix_length=26),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.108.195.122",
        vlan_id=715,
        routing=RoutingInformation(gateway="10.108.195.121", ip_prefix_length=29),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.108.195.123",
        vlan_id=715,
        routing=RoutingInformation(gateway="10.108.195.121", ip_prefix_length=29),
    ),
)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)

_vcu_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu_vnf_1 = DeploymentVnfStack(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_vdu_values_override_0.yaml"
    ),
)


# ssh connection information of OE, for tenant user
_vcu_ssh_connection_details = SshServiceDetails(
    addr="10.110.18.98", username="cranuser2", password="systeM!23"
)
# VCU_1 ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.110.18.98", username="core", password="system123", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cluster-preparation.yaml'),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    # networks=[_vcu_intnet_1],
    # vnfs=[_vcu_vnf_1],

)


# VCU global configuration
_cbts_0 = CloudBts(
    dus=[_vdu_0],  # vdu related parameter
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    instance_id="11322",
    global_bts_id="11322",
)

########### Part 4: UE ####################################
#  iperf server info
vm_password='uteUTE!'
if os.path.exists('/etc/ute/vncpasswd'):
    vm_password=subprocess.check_output("sudo cat /etc/ute/vncpasswd", shell=True).decode('utf-8')

_appserver_ssh = SshServiceDetails(
    addr="10.110.18.98", username="ute", password=vm_password
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.110.18.98",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

xiaomi12 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.97.143", username="hzoam-tester", password="Nokia123!"
    ),
    serial_number="863561069122916",   # temp one, sn in onelab
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "xiaomi12"],
)
########### Part 9: Appserver #############################
_appserver = AppServer(_iperf)


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

### Hangzhou Labs ### start ###
_netact_ssh_chen4 = SshServiceDetails('10.108.248.82', 'omc', password='Nokia126_')
_netact_http_chen4 = HttpConnectionDetails('chen4lbwas.chen4.srnhz.nsn-rdnet.net', 'omc', password='Nokia126_')
_netact_chen4 = NetAct(_netact_ssh_chen4, _netact_http_chen4)
### Hangzhou Labs ### end ###

########### Main: Testline configuration ##################
# Testline configuration, tl is only variable which can be accessed by agent and test case
# you can access all parameters configured upper by tl parameter
tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts_0],
    ues=[xiaomi12],
    tl_cloud_topology="CLOUD_5G_AIC_SA_NSA_1xvDU_OE20_1xFHGW_1xAZQJ",
    # attenuator=_attenuator_5G,
    core=_realcore,
    nms=_netact_1015,
    appserver=_appserver,
)


# only tl variable can be accessed by user
__all__ = ["tl"]
