__maintainer__ = "Kuang Chao"  # TL owner name
__team__ = "I_NSB_MN_BOAM_RD_OM_FRSMZ_EITPIT_GMS_GMS <I_NSB_MN_BOAM_RD_OM_FRSMZ_EITPIT_GMS@internal.nsn.com>"  # TL owner's team
__email__ = "chao.kuang@nokia-sbell.com"
__owner_email__ = "chao.kuang@nokia-sbell.com"  # TL owner's email

import os

from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    OSP,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)

from taf.config.testline.testpc import TestPc
from taf.config.testline.core import RealCore
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.pdu import FACOM
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.gnb.du import DU

# from taf.config.testline.gnb.ClassicalBts import ClassicalBts
from taf.config.testline import RealEnb
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.cbam import Cbam
from taf.config.testline.nms import NMS

# from taf.config.testline.nom import NOM
from taf.config.testline.attenuator import HBTE
from taf.config.testline.ue import Android
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb.networkaddress import RoutingInformation
from taf.config.testline.connection_details import K8SConnectionDetails

# from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.radio import RU


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Testpc

# UTE IP address and User Name, Password
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.163.81", username="ute", password="Hangzhoueit123!"
    )
)

# VCU related NCIR controlNode
_control = ControlNode(
    # Configuration for SSH access
    default_ssh_connection_details=SshServiceDetails(
        addr="10.107.8.112", username="CBTS69user", password="system123"
    ),
    # Configuration for openstack connection
    open_stack_connection_details=OpenStackConnectionDetails(
        username="CBTS69user",
        password="system123",
        ip_addr="10.107.8.112",
        tenant="CBTS69",
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

# configuration of VCU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_19")


######################################## eNB start ######################################################
_common_unit_pdu = FACOM(addr="10.108.246.130", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_lmp_connection_0 = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="ip")

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection_0,
    capacity_units=[_capacity_unit_0],
    pdu_port=_common_unit_pdu.pdu_ports[6],
)


# airscale
_airscale_0 = Airscale(common_units=[_common_unit_0])

# test pc information of enb


############################# eNB END ############################################################

# flavor of VCU
flavor_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_flavor.env")]

# ext_net of VCU
net_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.env")]

# heat parameters delete later
vnf_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.env")]

_cbts_flavor = DeploymentFlavorStack(
    name="hgz-5211",
    env_files=flavor_env_files,
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_flavor.yaml"),
    default_vnf_prefix="hgz-5211",
)

_cbts_net = DeploymentNetworkStack(
    name="hgz-5211",
    env_files=net_env_files,
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="hgz-5211",
    env_files=vnf_env_files,
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.yaml"),
)

# cloud deployment configuration fo VCU
_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)

# cloud osp
_osp_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.107.8.112",
        username="CBTS69user",
        tenant="CBTS69",
        password="system123",
        port=13000,
        protocol="https",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.107.8.112", username="stack", password="nokia123"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="", username="admin", password="admin"
    ),
)


_osp_control_2 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.107.8.112",
        username="CBTS69user",
        tenant="CBTS69",
        password="system123",
        port=13000,
        protocol="https",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.107.8.112", username="stack", password="nokia123"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="", username="admin", password="admin"
    ),
)

_osp_1 = OSP(
    control_nodes=[_osp_control_1],
    version="19A",
    cloud_deployments=None,
    compute_nodes=[],
)

_osp_2 = OSP(
    control_nodes=[_osp_control_2],
    version="19A",
    cloud_deployments=None,
    compute_nodes=[],
)

# CloudBts
_flavor_env_files = [os.path.join(_cfg_dir, "5gbts_flavor_cit.env")]

_net_env_files = [os.path.join(_cfg_dir, "5gbts_ext_net.env")]

_vnf_env_files = [
    os.path.join(_cfg_dir, "5gbts_heat.env"),
    os.path.join(_cfg_dir, "5gbts_heat_cit.env"),
]
_cbts_flavor = DeploymentFlavorStack(
    name="flavor_3220-5gbts",
    env_files=_flavor_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_flavor.yaml"),
    default_vnf_prefix="flavor-3220",
)

_cbts_net = DeploymentNetworkStack(
    name="EXT_NET",
    env_files=_net_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="vnf_3220-5gbts",
    env_files=_vnf_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_heat.yaml"),
)

_cloud_deployment_1 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_osp_1,
)

_cloud_deployment_2 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_osp_2,
)


###################### VCU global configuration ##########
# CU configuration
_cu1 = CU(
    # CU web UI ip address, oam interface ip of oam vm
    # oam_ssh_connection_details=SshServiceDetails(
    #     addr="2a00:8a00:8000:5002:0:f:11:17", username="serviceuser", password="Pl(FzaYj5~c5;q"
    # ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.168.183", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(v4="10.110.99.27"),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.168.183", username="Nemuadmin", password="nemuuser", port="443"
    ),
    # route configuration for x2c link to ENB, v4 is network address of ENB x2c link
    x2c=NetworkAddress(
        v4="10.0.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.101.1", ip_prefix_length=8),
    ),
    # route configuration for x2u link to ENB, v4 is network address of ENB x2u link
    x2u=NetworkAddress(
        v4="10.0.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.101.129", ip_prefix_length=8),
    ),
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.71.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.100.1", ip_prefix_length=16),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.71.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.100.1", ip_prefix_length=16),
    ),
    tracing=None,
)

# CU configuration
_cu2 = CU(
    # CU web UI ip address, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.168.182", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(v4="2a00:8a00:8000:5002:0:f:11:14"),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.168.183", username="Nemuadmin", password="nemuuser", port="443"
    ),
    # route configuration for x2c link to ENB, v4 is network address of ENB x2c link
    x2c=NetworkAddress(
        v4="10.0.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.101.1", ip_prefix_length=8),
    ),
    # route configuration for x2u link to ENB, v4 is network address of ENB x2u link
    x2u=NetworkAddress(
        v4="10.0.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.101.129", ip_prefix_length=8),
    ),
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.71.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.100.1", ip_prefix_length=16),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.71.0.0",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.110.100.1", ip_prefix_length=16),
    ),
    tracing=None,
)
# ########DU##########
_5g_ru_pdu = FACOM(addr="10.108.246.130", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_ru_1 = RU(
    ru_hw_group="mmw",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[5],
    radio_type="AEUD",
)

_ru_2 = RU(
    ru_hw_group="mmw",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[4],
    radio_type="AEUA",
)

_ru_3 = RU(
    ru_hw_group="mmw",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[5],
    radio_type="AEUD",
)

_ru_4 = RU(
    ru_hw_group="mmw",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[4],
    radio_type="AEUA",
)


_lmp_connection_1 = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_1 = CapacityUnit(addr="192.168.253.18")

# DU1
_common_unit_1 = CommonUnit(
    lmp_connection=_lmp_connection_1,
    hardware_type="ASOD",
    capacity_units=[_capacity_unit_1],
    pdu_port=6,
)

# DU2
_common_unit_2 = CommonUnit(
    lmp_connection=_lmp_connection_1,
    hardware_type="ASIK",
    capacity_units=[_capacity_unit_1],
    pdu_port=3,
)

# DU3
_common_unit_3 = CommonUnit(
    lmp_connection=_lmp_connection_1,
    hardware_type="ASOD",
    capacity_units=[_capacity_unit_1],
    pdu_port=6,
)

# DU4
_common_unit_4 = CommonUnit(
    lmp_connection=_lmp_connection_1,
    hardware_type="ASIK",
    capacity_units=[_capacity_unit_1],
    pdu_port=3,
)

# airscale
_airscale_1 = Airscale(common_units=[_common_unit_1])

_airscale_2 = Airscale(common_units=[_common_unit_2])

_airscale_3 = Airscale(common_units=[_common_unit_3])

_airscale_4 = Airscale(common_units=[_common_unit_4])

_du_1 = DU(airscale=_airscale_1, rus=[_ru_1], oam_ip="10.108.245.5")

_du_2 = DU(airscale=_airscale_2, rus=[_ru_2], oam_ip="10.108.245.8")

_du_3 = DU(airscale=_airscale_3, rus=[_ru_3], oam_ip="10.108.245.9")

_du_4 = DU(airscale=_airscale_4, rus=[_ru_4], oam_ip="10.108.245.7")

du_1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.108.245.5", username="Nemuadmin", password="nemuuser", port="443"
)

du_2_oam_http_connection_details = HttpConnectionDetails(
    addr="10.108.245.8", username="Nemuadmin", password="nemuuser", port="443"
)

du_3_oam_http_connection_details = HttpConnectionDetails(
    addr="10.108.245.9", username="Nemuadmin", password="nemuuser", port="443"
)

du_4_oam_http_connection_details = HttpConnectionDetails(
    addr="10.108.245.7", username="Nemuadmin", password="nemuuser", port="443"
)

_vdu_1 = VDU(
    cloud_deployment=_cloud_deployment_1,
    oam_http_connection_details=du_1_oam_http_connection_details,
)

_vdu_2 = VDU(
    cloud_deployment=_cloud_deployment_1,
    oam_http_connection_details=du_2_oam_http_connection_details,
)

_vdu_3 = VDU(
    cloud_deployment=_cloud_deployment_1,
    oam_http_connection_details=du_3_oam_http_connection_details,
)

_vdu_4 = VDU(
    cloud_deployment=_cloud_deployment_1,
    oam_http_connection_details=du_4_oam_http_connection_details,
)

_cbts1 = CloudBts(
    dus=[_du_1, _vdu_1, _du_2, _vdu_2, _du_3, _vdu_3, _du_4, _vdu_4],
    cu=_cu1,
    cloud_deployment=_cloud_deployment_1,
    vnf_name="CBTS69-CB007644-CU1",
    instance_id="01",
)

_cbts2 = CloudBts(
    dus=[_du_1, _vdu_1, _du_2, _vdu_2],
    cu=_cu2,
    cloud_deployment=_cloud_deployment_2,
    vnf_name="CBTS69-CB007644-CU2",
    instance_id="02",
)

_cbam = Cbam(
    addr="10.108.201.204",
    client_id="restful_api",
    client_secret="01b31b05-1e00-4e4b-8f73-5e4ee81959fe",
)

# Testline configuration
tl = TestLine(
    test_pc=_test_pc,
    cbam=_cbam,
    gnbs=[_cbts1, _cbts2],
    #    enbs=[_real_enb],
    tl_cloud_topology="CLOUD_5G_AIC_NCIR_NCIR_FHGW_AHCA_Android",
    cloud_hostings=[_ncir],
    core=_realcore,
)

# only tl variable can be accessed by user
__all__ = ["tl"]
