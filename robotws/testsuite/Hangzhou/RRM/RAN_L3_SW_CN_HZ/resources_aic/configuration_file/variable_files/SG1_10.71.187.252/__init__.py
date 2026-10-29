__maintainer__ = "Li Tom"
__owner_email__ = "tom.li@nokia-sbell.com"

import os

from taf.config.testline.cloud_hosting import (
    CloudDeployment,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
# from taf.config.testline import RealEnb
# from taf.config.testline.gnb.du import FHGW
# from taf.config.testline.lab_infrastructure import PxeServer
# from taf.config.testline.core import RealCore
# from taf.config.testline.nms import NMS
# from taf.config.testline.nms import NOM


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# This is test PC for AIC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.71.187.252", username="ute", password="tribe!L3SW1CN@"
    )
)

# vCU configuration
_cu = CU(
    # vCU web UI ip address, oam interface ip of oam-ext pod
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.100.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    # vCU OAM ssh connection, oam interface ip of oam-ext pod
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.57.219.2", username="core", password="system123"
    ),
    backhaul_site_oam_ip="None",
    # route configuration for x2 link to ENB, v4 is network address of ENB x2 link
    x2c=NetworkAddress(
        v4="10.0.1.111",
        vlan_id=3154,
        routing_v4=RoutingInformation(gateway="10.0.1.1/24"),
    ),
    # route configuration for xn link to GNB,v4 is network address of GNB xnc link
    xnc=NetworkAddress(
        v4="10.0.12.111",
        vlan_id=3153,
        routing_v4=RoutingInformation(gateway="10.0.12.1/24"),
    ),
    # route configuration for f1c link to VDU on VCU,v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="172.16.1.101",
        vlan_id=3151,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="172.16.1.201",
        vlan_id=3151,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
    s1u=NetworkAddress(
        v4="10.1.1.113",
        vlan_id=3155,
        routing_v4=RoutingInformation(gateway="10.0.1.1/24"),
    ),
    x2u=NetworkAddress(
        v4="10.0.1.112",
        vlan_id=3154,
        routing_v4=RoutingInformation(gateway="10.0.1.1/24"),
    ),
    xnu=NetworkAddress(
        v4="10.0.12.112",
        vlan_id=3153,
        routing_v4=RoutingInformation(gateway="10.0.12.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.0.11.111",
        vlan_id=3152,
        routing_v4=RoutingInformation(gateway="10.0.11.1/24"),
    ),
    ngu=NetworkAddress(
        v4="10.0.11.112",
        vlan_id=3152,
        routing_v4=RoutingInformation(gateway="10.0.11.1/24"),
    ),
    tracing=None,
)

_vdu1_k8s_ssh_connection_details = SshServiceDetails(
    addr="192.168.2.2", username="core", password="system123"
)

_vdu1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="192.168.2.2", username="core", password="system123", port=22
)

_vdu1_master_node = MasterNode(
    k8s_connection_details=_vdu1_k8s_connection_details,
    ssh_connection_details=_vdu1_k8s_ssh_connection_details,
)

_vdu1_k8s = K8S(namespace="cran1", master_node=_vdu1_master_node)

_vdu2_k8s_ssh_connection_details = SshServiceDetails(
    addr="192.168.2.3", username="core", password="system123"
)

_vdu2_k8s_connection_details = K8SConnectionDetails(
    ip_addr="192.168.2.3", username="core", password="system123", port=22
)

_vdu2_master_node = MasterNode(
    k8s_connection_details=_vdu2_k8s_connection_details,
    ssh_connection_details=_vdu2_k8s_ssh_connection_details,
)

_vdu2_k8s = K8S(namespace="cran1", master_node=_vdu2_master_node)

# VDU deployment configuration
_k8s_cloud_deployment_du1 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu1_k8s,
)

_k8s_cloud_deployment_du2 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu2_k8s,
)

# VDU oam http connection
_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.129", port="443", username="Nemuadmin", password="nemuuser"
)

_vdu2_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.130", port="443", username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="RU_INT_ECPRI", serial_number="1M213624067")
_ru_2 = RU(ru_hw_group="RU_INT_ECPRI", serial_number="DU213624067")

# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_du1,
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    # _SpecialForm[NetworkAddress]
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.255.129",
        vlan_id=3150,
        routing_v4=RoutingInformation(gateway="192.168.255.1/24"),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="172.16.1.102",
        vlan_id=3151,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="172.16.1.202",
        vlan_id=3151,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
)

_vdu_1 = VDU(
    cloud_deployment=_k8s_cloud_deployment_du2,
    oam_http_connection_details=_vdu2_oam_http_connection_details,
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.255.130",
        vlan_id=3150,
        routing_v4=RoutingInformation(gateway="192.168.255.1/24"),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="172.16.1.103",
        vlan_id=3151,
        routing_v4=RoutingInformation(gateway="192.168.101.1/24"),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="172.16.1.203",
        vlan_id=3151,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
)

# ssh connection information of vCU
_vcu_ssh_connection_details = SshServiceDetails(
    addr="10.57.219.2", username="core", password="system123"
)

# ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.57.219.2", username="core", password="system123", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="tl765", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
)

# vCU vDU global configuration
_cbts = CloudBts(
    dus=[_vdu_0, _vdu_1],  # vdu related parameter
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    # instance_id="1",
    # global_bts_id="1",
)

# route configuration of fhm link to airphone on VDU, no need ip, just fetch vlanid for iphy.xml configuration
_vlan1 = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=2333)

_vlan2 = PreferredVlan(slot_id=SlotId.B2, port_id=1, preferred_vlan_id=2335)

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                ],
                hardware_type="ASIL",
                # pdu_port=_pdus[0].pdu_ports[7],
            )
        ]
    ),
    preferred_vlans=[_vlan1, _vlan2],
)


# Testline configuration, tl is only variable which can be accessed by agent and test case
# you can access all parameters configured upper by tl parameter
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dR2.0_2vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD",
    ues=[_ue],
    cloud_hostings=[_vcu_k8s, _vdu1_k8s, _vdu2_k8s],
)

# only tl variable can be accessed by user
__all__ = ["tl"]
