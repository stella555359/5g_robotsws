# Generated with TL configuration generator at 2025-05-23_08:16:30

# Repository  -> https://wrgitlab.int.net.nokia.com/ran_pz_krk/config_generator
# Jenkins job -> http://krk-pz-jenkins.krk-lab.nsn-rdnet.net:5990/view/Tools/job/Config_Generator/build?delay=0sec

__maintainer__ = "KRKAUTO5GPZ"
__team__ = "I_MN_RAN_PZ_KRK_TAG"
__email__ = "I_MN_RAN_PZ_KRK_TAG@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.radio import RU, RUExtension
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import (
    Airscale,
    CommonUnit,
    CoreUnit,
    CapacityUnit,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.pdu import PduPort, FPFH, HPE
from taf.config.testline.lmi import SerialOverTcp, Remote
import os
import yaml

# ------------------------PDU_CONFIGURATION------------------------

_bts_pdu = FPFH(
    port_numbers=[1],         # update port_no
    addr="10.255.17.25",   # update address
    login="admin",
    password="admin",
)

_hpe_snmp_user = {
    "userName": "administrator",
    "authKey": "password",
    "privKey": "password",
    "authProtocol": "MD5",
    "privProtocol": "AES",      # HPE v2.0.0.K DES, HPE v2.0.0.Q/v2.0.0.T AES, ATEN should be AES
}

_ru_pdu = HPE(
    port_numbers=[19],         # update port_no
    addr="hg04.mgt.ska-lab.nsn-rdnet.net",    # update address
    snmp_user=_hpe_snmp_user,
)

# ------------------------GNB0_CONFIGURATION------------------------

_test_pc_gnb_0 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G10SK087.p10.ska-lab.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    )
)

_gnb_0_instance_id = 84087
_gnb_0_global_bts_id = 84087

_gnb_0_primary_ssh_lmp_connection = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
    proxy=_test_pc_gnb_0.default_ssh_connection_details,
)

_gnb_0_oam_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_f1m_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_f1c_ip = NetworkAddress(
    v4="/0",
    routing_v4=RoutingInformation(gateway="", destIpAddr=""),
    vlan_id=0,
)

_gnb_0_f1u_ip = NetworkAddress(
    v4="/0",
    routing_v4=RoutingInformation(gateway="", destIpAddr=""),
    vlan_id=0,
)

_gnb_0_x2c_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_x2u_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_s1c_ip = NetworkAddress(
    v4="/0",
    routing_v4=RoutingInformation(gateway="", destIpAddr=""),
    vlan_id=0,
)

_gnb_0_s1u_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_xnc_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_xnu_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_ngc_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_ngu_ip = NetworkAddress(
    v4="10.89.10.87/23",
    routing_v4=RoutingInformation(gateway="10.89.11.254", destIpAddr="0.0.0.0"),
    vlan_id=504,
)

_gnb_0_oam_http_connection = HttpConnectionDetails(
    addr=_gnb_0_oam_ip.v4.split("/")[0],
    username="Nemuadmin",
    password="nemuuser",
    port=443,
)

_cu_gnb_0 = CU(
    backhaul_site_oam_ip=_gnb_0_oam_ip,
    oam_ssh_connection_details=_gnb_0_primary_ssh_lmp_connection,
    oam_http_connection_details=_gnb_0_oam_http_connection,
    f1m=_gnb_0_f1m_ip,
    f1c=_gnb_0_f1c_ip,
    f1u=_gnb_0_f1u_ip,
    x2c=_gnb_0_x2c_ip,
    x2u=_gnb_0_x2u_ip,
    s1c=_gnb_0_s1c_ip,
    s1u=_gnb_0_s1u_ip,
    xnc=_gnb_0_xnc_ip,
    xnu=_gnb_0_xnu_ip,
    ngc=_gnb_0_ngc_ip,
    ngu=_gnb_0_ngu_ip,
    instance_id=_gnb_0_instance_id,
    global_bts_id=_gnb_0_global_bts_id,
)

_gnb_0_radio_unit_0 = RU(
    ru_hw_group="APHG",
    default_ssh_connection_details=SshServiceDetails(
       addr="172.22.0.30",
       username="toor4nsn",
       password="oZPS0POrRieRtu",),
    serial_number="NH210200276",

    radio_type="APHG",
    product_code="475295A.101S",
    pdu_port=PduPort(pdu=_ru_pdu, port_no=19),    # uncomment & update port_no for gNB - for eNB you can delete
    # lmi=SerialOverTcp(
    #    uart_mapping=[Remote(addr=NetworkAddress(v4="MUMIN-LMI_FQDN"), port=5001)]
    )


_gnb_0_core_unit_0 = CoreUnit(
    lmp_connection=_gnb_0_primary_ssh_lmp_connection,
    hardware_type="ASOH",
    hardware_version="A.101",
    serial_number="L1242102482",
    mac_addr="28:74:f5:29:e3:81",
    # trs_connections=[TRSInterfaces.EIF1],
    rus=[_gnb_0_radio_unit_0],
    pdu_port=PduPort(pdu=_bts_pdu, port_no=1),    # uncomment & update port_no for gNB - for eNB you can delete
)

_gnb_0_airscale = Airscale(
    core_units=[_gnb_0_core_unit_0],
    product_code="N/A",
    )

_du_gnb_0 = DU(
    airscale=_gnb_0_airscale,
    oam_ip=_gnb_0_oam_ip,
    f1_m_ip_addr=_gnb_0_f1m_ip,
    f1_c_ip_addr=_gnb_0_f1c_ip,
    f1_u_ip_addr=_gnb_0_f1u_ip,
    f1_m_cu=_gnb_0_f1m_ip,
    f1_c_cu=_gnb_0_f1c_ip,
    f1_u_cu=_gnb_0_f1u_ip,
    instance_id=_gnb_0_instance_id,
    global_bts_id=_gnb_0_global_bts_id,
    )

_gnb_0 = ClassicalBts(
    cu=_cu_gnb_0,
    dus=[_du_gnb_0],
    instance_id=_gnb_0_instance_id,
    global_bts_id=_gnb_0_global_bts_id,
)

_test_pc_gnb_0.connections = [
    Connection(
        device=_gnb_0.dus[0].airscale.core_units[0],
        interface="eth1",
        interface_type="lmp",
    )
]

# ------------------------TL_CONFIGURATION------------------------


tl = TestLine(
    test_pc=_test_pc_gnb_0,
    gnbs=[_gnb_0],
    test_pcs=[_test_pc_gnb_0],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIR_ASOH_APHG_12xAWHFIQB"
)

__all__ = ["tl"]
