__maintainer__ = "Rafal Kaczmarski"
__team__ = "I_MN_RAN_RD_VRF_WRO_8"
__email__ = "I_MN_RAN_RD_VRF_WRO_8@internal.nsn.com"
__owner_email__ = "rafal.kaczmarski@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.cloud_hosting import MasterNode, K8S, ContainerRegistry
from taf.config.testline.pdu import Gude

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

vcu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu", username ="robot$vrf", password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR")
vdu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="ObCV0W80KGzzazO1aCRKDU25DozYU338")

_pdu_1 = Gude(
    addr="10.44.200.138",
    port_numbers=[4, 8, 9, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.44.200.140",
    port_numbers=[1, 2, 4, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.200.139",
    port_numbers=[2, 4],
    model="EPC",
    version="8221-1",
)

_pdu_4 = Gude(
    addr="10.44.200.137",
    port_numbers=[2, 6],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_vdu1_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.17", username="core", password="system123"
)

_vdu1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.17", username="core", password="system123", port=22
)

_vdu1_master_node = MasterNode(
    k8s_connection_details=_vdu1_k8s_connection_details,
    ssh_connection_details=_vdu1_k8s_ssh_connection_details,
)
_vdu2_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.16", username="core", password="system123"
)

_vdu2_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.16", username="core", password="system123", port=22
)

_vdu2_master_node = MasterNode(
    k8s_connection_details=_vdu2_k8s_connection_details,
    ssh_connection_details=_vdu2_k8s_ssh_connection_details,
)

_vdu_k8s1 = K8S(namespace="vdu8505", master_node=_vdu1_master_node)

_vdu_k8s2 = K8S(namespace="vdu8506", master_node=_vdu2_master_node)

_prerequisite_du_1 = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu1-prerequisite.yaml'),
)

_prerequisite_du_2 = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu2-prerequisite.yaml'),
)

_cnf_du1 = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu1-cnf.yaml'),
)

_cnf_du2 = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu2-cnf.yaml'),
)

_vdu_k8s_cloud_deployment1 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s1,
    prerequisite=_prerequisite_du_1,
    cnf=_cnf_du1,
)

_vdu_k8s_cloud_deployment2 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s2,
    prerequisite=_prerequisite_du_2,
    cnf=_cnf_du2,
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.38.209", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu2_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.38.208", port=443, username="Nemuadmin", password="Nokia@123"
)

# RU configuration
_ru_1 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu_1.pdu_ports[4], radio_type="AHBCC", serial_number="BL2215Y28QQ")
_ru_2 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu_2.pdu_ports[12], radio_type="AHLOB", serial_number="BL2239D50KB")
_ru_3 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu_3.pdu_ports[2], radio_type="AHLBBA", serial_number="BL2236G264R")
_ru_4 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu_2.pdu_ports[4], radio_type="AHHB", serial_number="LR240209126")
_ru_5 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu_4.pdu_ports[2], radio_type="AHFII", serial_number="BL2408N4EKN")
_ru_6 = RU(ru_hw_group="FRMr5_8T8R", pdu_port=_pdu_1.pdu_ports[8], radio_type="AKQI", serial_number="1M233605415")

_ru_7 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu_2.pdu_ports[2], radio_type="AHBCC", serial_number="K9190632542")
_ru_8 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu_3.pdu_ports[4], radio_type="AHLOB", serial_number="BL2244D50YY")
_ru_9 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu_2.pdu_ports[1], radio_type="AHLBBA", serial_number="BL2236G269K")
_ru_10 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu_1.pdu_ports[12], radio_type="AHHB", serial_number="LR240109249")
_ru_11 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu_4.pdu_ports[6], radio_type="AHFII", serial_number="BL2340N4A1R")
_ru_12 = RU(ru_hw_group="FRMr5_8T8R", pdu_port=_pdu_1.pdu_ports[9], radio_type="AKQI", serial_number="1M233605419")

_fhgw_1 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6]
)

_fhgw_2 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_7, _ru_8, _ru_9, _ru_10, _ru_11, _ru_12]
)

_vdu_0_rannic1 = RANNIC(serial_number="L1240813781", product_code="AF1791.101")

_vdu_1_rannic1 = RANNIC(serial_number="L1234511818", product_code="AF1791.M01")

_vdu_1 = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment1,
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    fhgws=[_fhgw_1],
    instance_id=8505,
    fhuc_vlans=[301],
    rannics=[_vdu_0_rannic1]
)

_vdu_2 = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment2,
    oam_http_connection_details=_vdu2_oam_http_connection_details,
    fhgws=[_fhgw_2],
    instance_id=8506,
    fhuc_vlans=[301],
    rannics=[_vdu_1_rannic1]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.129", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.93.184", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    backhaul_site_oam_ip="10.42.93.184",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.91.146", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.91.146", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="vcu8505", master_node=_vcu_master_node)

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
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(
    dus=[_vdu_1, _vdu_2],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
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
    address='10.45.168.53',
    user='5g',
    password='2019H@slo',
)


_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=60,
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
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro],
)

_android_ue_2 = TafUeAndroid(
    ue_pc_address=_ue_pc_ssh.addr,
    ssh_connection_details=_ue_pc_ssh,
    serial_number="259df830",
    imei="351602005842552",
    imsi="",
    capabilities=["REAL_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
#    secret_code='*#*#4636#*#*',
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro],
)

_attenuator_1 = TopYoung(ip_addr="10.42.61.216", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                         attenuation_port_numbers=[1, 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 16])
_attenuator_2 = TopYoung(ip_addr="10.42.61.171", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                         attenuation_port_numbers=[9, 10, 11, 12, 13, 14, 15, 16])
_attenuator_3 = TopYoung(ip_addr="10.42.61.243", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                         attenuation_port_numbers=[1, 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 16])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.122",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s1, _vdu_k8s2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_2vDU_P_LOO_CMW_FDD_WRO8",
    pdus=_pdus,
    core=RealCore5G(mcc=310, mnc=260),
    attenuators=[_attenuator_1, _attenuator_2, _attenuator_3],
    ues=[_android_ue_1, _android_ue_2]
)

__all__ = ["tl"]
