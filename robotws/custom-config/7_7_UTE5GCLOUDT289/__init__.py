__maintainer__ = 'Artur Ekert'
__team__ = 'SG_4'
__email__ = 'artur.ekert@nokia.com'
__owner_email__ = 'artur.ekert@nokia.com'


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline import DU, RU, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import NetworkAddress, RealEnb
from taf.config.testline.appserver import AppServer
from taf.config.testline.ue import Prisma
from taf.config.testline.core import EPCSim
from taf.config.testline.attenuator import JFW


def _set_abstract_lib_config_env(config_file):
    tl_config_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(tl_config_dir, config_file)


_5g_bts_id = 289
_4g_bts_id = 77014

_ncir_vnf = "5gbts" + str(_5g_bts_id)

# SB00
_ncir_ip = "10.83.190.225"
_ncir_user = "5Guser1"
_ncir_pass = "5Guser@3"
_ncir_tenant = "5Gtenant1"

_cu_oam_ip = NetworkAddress(v4="10.83.183.39")
_4g_ip = NetworkAddress(v4="10.84.190.14")

_du_m_ip = NetworkAddress(
    v4="192.168.255.129"  # "172.16.5.61",
)
_du_f1c_ip = NetworkAddress(
    v4="192.168.255.129"  # "172.16.5.61",
)
_du_f1u_ip = NetworkAddress(
    v4="192.168.255.129"  # "172.16.5.61",
)

_du_m_route_cu = NetworkAddress(
    routing_v4=RoutingInformation(gateway="", ip_prefix_length=0)
)
_du_f1c_route_cu = NetworkAddress(
    routing_v4=RoutingInformation(gateway="", ip_prefix_length=27)
)
_du_f1u_route_cu = NetworkAddress(
    routing_v4=RoutingInformation(gateway="", ip_prefix_length=27)
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr='7-7-UTE5GCLOUDT289.sc5g.krk-lab.nsn-rdnet.net',
        username='ute',
        password='ute'))


_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr=_ncir_ip,  # Nokia AirFrame Cloud Infrastructure
        username=_ncir_user,
        tenant=_ncir_tenant,
        password=_ncir_pass,
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr=_ncir_ip,  # Nokia AirFrame Cloud Infrastructure
        username=_ncir_user,
        password=_ncir_pass,
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password="")
)

_ncir = NCIR(
    compute_nodes=[_compute], control_nodes=[_control_0], version="ncir_19"
)

_cbts_flavor = DeploymentFlavorStack(name='TL_7_7_UTE5GCLOUDT289_FLAVOR',
                                     env_files=[os.path.join(_CFG_DIR, 'config_flavor.env')],
                                     default_vnf_prefix=_ncir_vnf,
                                     )

_cbts_net = DeploymentNetworkStack(name='TL_7_7_UTE5GCLOUDT289_EXT_NET',
                                   env_files=[os.path.join(_CFG_DIR, 'config_ext_net.env')],
                                   )

_cbts_vnf = DeploymentVnfStack(name='TL_7_7_UTE5GCLOUDT289_BTS',
                               env_files=[os.path.join(_CFG_DIR, 'config_bts.env')],
                               )

_cloud_deployment = CloudDeployment(default_cfg_dir=_CFG_DIR,
                                    flavors=[_cbts_flavor],
                                    networks=[_cbts_net],
                                    vnfs=[_cbts_vnf],
                                    cloud_hosting=_ncir)

_cu = CU(backhaul_site_oam_ip=_cu_oam_ip,
         oam_ssh_connection_details=SshServiceDetails(addr=_cu_oam_ip.v4,
                                                      username='robot',
                                                      password='rastre1'),
         oam_http_connection_details=HttpConnectionDetails(addr=_cu_oam_ip.v4,
                                                           username='Nemuadmin',
                                                           password='nemuuser'),
         instance_id=_5g_bts_id,
         global_bts_id=_5g_bts_id,
         f1m=NetworkAddress(v4="172.16.5.102"),
         f1c=NetworkAddress(v4="172.16.5.102"),
         f1u=NetworkAddress(v4="172.16.5.103"),
         x2c=NetworkAddress(v4="172.16.2.101"),
         x2u=NetworkAddress(v4="172.16.2.102"),
         )

# GNB DU1 ABIL
_gnb_du1_capu = CapacityUnit(addr='192.168.253.37', hardware_type='ABIL')

# GNB DU1 ASIK
_gnb_du1_comu = CommonUnit(lmp_connection=SshServiceDetails(addr='192.168.255.129',
                                                            username='toor4nsn',
                                                            password='oZPS0POrRieRtu'),
                           capacity_units=[_gnb_du1_capu],
                           hardware_type='ASIK')

_ru_du1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(addr="", username=""),
    lmp_connection=SshServiceDetails(addr="", username=""),
    radio_type="AEUD",
)

_du1 = DU(
    airscale=Airscale(common_units=[_gnb_du1_comu]),
    instance_id=_5g_bts_id,  # change
    global_bts_id=_5g_bts_id,  # ??
    rus=[_ru_du1],
    oam_ip=_du_m_ip,
    f1_m_ip_addr=_du_m_ip,
    f1_c_ip_addr=_du_f1c_ip,
    f1_u_ip_addr=_du_f1u_ip,
)


_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    vnf_name=_ncir_vnf,
    dus=[_du1],
)


# _epcsim = EPCSim(mme_ip='172.16.2.2',
#                  mcc=244,
#                  mnc=8,
#                  tac=1024,
#                  # addr='sc5g-enb-293.sc5g.krk-lab.nsn-rdnet.net',
#                  # username='ute',
#                  # password='ute',
#                  dir_path='/home/ute/epc/',
#                  cfg_filename='sim_293.cfgdd',
#                  edaemon_port=60002,
#                  egate_port=60001)

_net_iperf = IperfDataTransferDetails(ssh_connection_details=SshServiceDetails(addr='ul5gappserv302',
                                                                               username='dpdktests',
                                                                               password='qwer2009!'),
                                      network_interface_address="192.168.13.1",
                                      iperf_path="/usr/bin/iperf")

_net_appserver = AppServer(iperf_details=_net_iperf)

_enb = RealEnb(x2_link_addr=NetworkAddress(v4='172.16.2.1'))


_airmosaic_ssh = SshServiceDetails(addr='7-7-CLOUDT164.sc5g.krk-lab.nsn-rdnet.net',
                                   username='ute',
                                   password='uteUTE!')

_airmosaic_harness = HttpConnectionDetails(addr='2a00:8a02:60:3a:5054:ff:fe00:f5fc',
                                           port=8090)

_lsu_uu_ssh = SshServiceDetails(addr='172.25.30.150',
                                username='user',
                                password='user',
                                proxy=_airmosaic_ssh)

_tstm_uu_ssh = SshServiceDetails(addr='172.25.30.150',
                                 username='user',
                                 password='user',
                                 proxy=_airmosaic_ssh)

_app_server_ssh = SshServiceDetails(addr='7-7-UTE5GCLOUDT293.sc5g.krk-lab.nsn-rdnet.net',
                                    username='ute',
                                    password='ute')

_ue_host_ssh = SshServiceDetails(addr='SC5G-eNB-238-uesim.sc5g.krk-lab.nsn-rdnet.net',
                                 username='paf',
                                 password='noki@PAF1234')

_app_server_iperf_details = IperfDataTransferDetails(
    ssh_connection_details=_app_server_ssh,
    network_interface_address='41.1.1.254',
    iperf_path='/usr/bin/iperf')

_ue_host_iperf_details = IperfDataTransferDetails(
    ssh_connection_details=_ue_host_ssh,
    network_interface_address='192.168.70.130',
    iperf_path='/usr/bin/iperf')

_ue_prisma = Prisma(
   airmosaic_ssh_connection_details=_airmosaic_ssh,
   airmosaic_harness_connection_details=_airmosaic_harness,
   lsu_uu_ssh_connection_details=_lsu_uu_ssh,
   tstm_uu_ssh_connection_details=_tstm_uu_ssh,
   iperf_details=_ue_host_iperf_details,
   imsi='244:08:5000000044',
   sec_key='00112233445566778899AABBCCDDEEFF',
   gnb_common_unit_for_throughput_check=_gnb_du1_comu)

_common_unit_lte_ssh = SshServiceDetails(addr='192.168.255.129',
                                         username='toor4nsn',
                                         password='oZPS0POrRieRtu')

#  ###########  ATTENUATOR JFW #####################
#            #     ASIK-RU     #      ASOD-RU      #
#  Atten port#  3   4   5   6  #  7   8   9   10   #
#            #  |   |   |   |  #  |   |   |    |   #
#  RU PORT   # RX6 TX6 RX2 TX2 # RX6 TX6 RX2  TX2  #
#  #################################################
_attenuator = JFW(
    ip_addr="10.83.176.33",
    port=3001,
    attenuation_port_numbers=[3, 4, 5, 6],
    model="50PA-628",
)

tl = TestLine(test_pc=_test_pc,
              gnbs=[_cbts],
              cloud_hostings=[_ncir],
              tl_cloud_topology="CLOUD_5G_ASIKR_ABILB4_AEUD",
              enbs=[_enb],
              ues=[_ue_prisma],
              attenuator=[_attenuator],
              appserver=AppServer(_app_server_iperf_details))

__all__ = ['tl']
