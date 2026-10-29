__maintainer__ = "Szymon Przybylak"
__team__ = "siso"
__email__ = "szymon.przybylak@nokia.com"
__owner_email__ = "szymon.przybylak@nokia.com"


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
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.core import RealCore
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S, ComputeNode
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude
from taf.config.testline.optical_switch import Leoni

# from taf.config.testline.nms import NMS
# from taf.config.testline.nms import NOM
# from taf.config.testline.nms import Netact
# from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# this is test PC for AIC, including UTE IP address, User Name and Password.
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.25", username="ute", password="uteUTE!"
    )
)
# _test_pc_1 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#       addr="10.42.184.18", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],

_los = Leoni(addr="10.42.201.30", model="mol 6x(2x6)")

# TL8433_AHCA_105
_pdu1 = Gude(addr="10.44.167.191", port_numbers=[10], model="EPC", version="8221-1")

_pdus = [_pdu1]

# ######## start of vCU ##########################################################
# VCU related NCIR controlNode
_control = ControlNode(
    # Configuration for SSH access
    default_ssh_connection_details=SshServiceDetails(
        addr="x", username="core", password="system123"
    ),
    # Configuration for openstack connection
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="x",
        tenant="vcu-cli-nonha-cran-252",
    ),
    # Configuration for BMC access if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

# configuration of VCU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_17")

# #################### START of VCU CNF platform ##########################
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
    addr="10.42.126.213", username="core", password="system123"
)
# ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.126.213", username="core", password="system123", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="vcu-cli-nonha-cran-252", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_vnf_1],
    cloud_hosting=_vcu_k8s,
)
# #################### End of VCU CNF platform ##########################

# CU  configuration
_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.126.153"
        # v6='2a00:8a00:8000:136:10:57:159:1111'
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.126.153", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.126.153", username="Nemuadmin", password="Nokia@123", port="443"
    ),
    # route configuration for x2 link to ENB, v4 is network address of ENB x2 link
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.44.168.172",
        routing=RoutingInformation(gateway="10.44.130.129", ip_prefix_length=26),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.42.67.172",
        routing=RoutingInformation(gateway="10.44.130.65", ip_prefix_length=26),
    ),
    # route configuration for x2 link to ENB on VCU, v4 is network address of ENB x2 link
    ngc=NetworkAddress(
        v4="10.27.135.6",
        routing=RoutingInformation(gateway="10.42.25.1", ip_prefix_length=24),
    ),
    ngu=NetworkAddress(
        v4="10.27.135.6",
        routing=RoutingInformation(gateway="10.42.24.1", ip_prefix_length=24),
    ),
    tracing=None,
    global_bts_id=8424,
)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="244", mnc="08", pdns=None)

# ######## start of ENB #############################
# _capacity_unit = CapacityUnit(addr="6.6.6.6")
#
# _common_unit = CommonUnit(
#     lmp_connection=SshServiceDetails(
#         addr="10.97.120.140", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_capacity_unit],
# )

# _airscale = Airscale(common_units=[_common_unit])
#
# _real_enb = RealEnb(airscale=_airscale, oam_ip="10.97.120.141")
#
# # you can configure it as AIC UTE environment
# _enb_test_pc = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.108.229.91", username="ute", password="ute"
#     ),
#     connections=[_real_enb],
# )


_vdu_vnf_0 = DeploymentVnfStack(
    # this is vdu release name, the name should only be lower case and only can include alphabet, number,
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    # this is intnet release name, the name should only be lower case and only can include alphabet, number,
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_ssh_connection_details_0 = SshServiceDetails(
    addr="10.42.126.12", username="core", password="system123"
)
# ip_addr="10.97.119.62", username="core", password="system123", port="22"
_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.42.126.12", username="core", password="system123", port="22"
)

_master_node_0 = MasterNode(
    k8s_connection_details=_k8s_connection_details_0,
    ssh_connection_details=_ssh_connection_details_0,
)
_k8s_0 = K8S(namespace="cran8433", master_node=_master_node_0)
_k8s_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s_0,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.126.76", port="443", username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=10, serial_number="1M190413180")
_ru_2 = RU(
    ru_hw_group="test_ru_hw_group", pdu_port=4, serial_number="test_serial_number"
)

_pxe_server_ssh_info = SshServiceDetails(
    addr="10.42.239.60", username="ute", password="Ut3pa5s#1be1"
)
_pxe_server = PxeServer(
    nfs_ip="10.42.239.60", ssh_connection_details=_pxe_server_ssh_info
)

# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2],
    pxe_server=_pxe_server,
    fhgw_id=8433,
)

_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_0,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.254.37",
        vlan_id=295,
        routing=RoutingInformation(gateway="192.168.254.33", ip_prefix_length=26),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.44.130.153",
        vlan_id=373,
        routing=RoutingInformation(gateway="10.44.168.1", ip_prefix_length=24),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.44.130.89",
        vlan_id=370,
        routing=RoutingInformation(gateway="10.42.67.1", ip_prefix_length=24),
    ),
    instance_id=8433,
)

# ######## start of Netact ######################################################
# netact_id = {
#     "clab3766": {
#         "node_ip": "10.32.217.23",
#         "user": "omc",
#         "password": "omc",
#         "url": "https://clab3766lbwas.netact.nsn-rdnet.net",
#         "url_user": "omc",
#         "url_password": "omc",
#         "mr": "MRC-VRAN2.0/MR-10820",
#     },
#     "clab3386": {
#         "node_ip": "10.32.217.141",
#         "user": "omc",
#         "password": "omc",
#         "url": "https://clab3386lbwas.netact.nsn-rdnet.net",
#         "url_user": "omc",
#         "url_password": "omc",
#         "mr": "MRC-1/MR-1",
#     },
# }
#
# _netact = Netact(netact_id)

# vcu CNF: _vcu_k8s_cloud_deployment
_cbts = CloudBts(
    dus=[_vdu_0],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8433",
    instance_id="8433",
)
tl = TestLine(
    test_pc=_test_pc,
    #    nms=_netact,
    gnbs=[_cbts],
    #    enbs=[_real_enb],
    #    tl_cloud_topology="CLOUD_5G_AIC_SISO_TEST",
    cloud_hostings=[_ncir],
    #    test_pcs=[_enb_test_pc],
    core=_realcore,
    pdus=_pdus,
    optical_switches=[_los],
)
__all__ = ["tl"]
