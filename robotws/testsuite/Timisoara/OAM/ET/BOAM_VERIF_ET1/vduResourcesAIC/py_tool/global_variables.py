import os
import logging
from robot.libraries.BuiltIn import BuiltIn

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM

VDU_BUILD = os.getenv("SPECIFIC_VDU_BUILD", "").strip()
VDU_STREAM_LIST = ["300", "400"]
OAMCP_CONTAINERS = [
    "nwmgmt",
    "oam",
    "oamfh",
    "cprt",
    "dhcp",
    "nftmgmt",
    "httpd",
    "apigw",
    "givaxi",
    "providercontroller",
    "vsftp",
    "httpdstunnel",
    "ne3sagentstunnel",
    "providercontrollerstunnel",
    "httpdcredmediator",
    "ne3sagentcredmediator",
    "providercontrollercredmediator",
]
UP_CONTAINERS = ["nwmgmt", "l2hi", "l2rt", "l1hi", "nftmgmt"]
LWSD_CONTAINERS = ["lwsd"]
RCPSDL_CONTAINERS = ["rcpsdl"]
RCPFM_CONTAINERS = ["rcpfm"]
PM_CONTAINERS = ["pmcore", "pm-rest-server"]
TRSCONFIG_CONTAINERS = ["trsconfig"]
LOGSERVICE_CONTAINERS = ["logstorageserver", "logsymptomdataprovider"]
RCPUM_CONTAINERS = ["rcpum"]
SECURESTORAGE_CONTAINERS = [
    "vaultloganalyzer",
    "vaultserver",
    "stunnel",
    "vaultmanager",
]
CERTIFICATE_MANAGEMENT_CONTAINERS = [
    "certman",
    "certificatemanagementstunnel",
    "certificatemanagementcredmediator",
]
KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS = ["kubeapisymptomdataprovider"]
HEALING_CONTROLLER_CONTAINERS = ["healing-controller"]
'''
OAM_CONTAINERS = [
    "certman_chris",
    "nwmgmt",
    "oam",
    "oamfh",
    "dhcp",
    "apigw",
    "httpd",
    "nftmgmt",
    "vsftp",
    "providercontroller",
    "ne3sagentcredmediator",
    "ne3sagentstunnel",
    "httpdcredmediator",
    "httpdstunnel",
    "providercontrollercredmediator",
    "providercontrollerstunnel",
    "certificatemanagementcredmediator",
    "certificatemanagementstunnel",
]
'''

OAMASM_CONTAINERS = [
    "nwmgmt", "nftmgmt", "oamasm"
]

OAMCM_CONTAINERS = [
    "nwmgmt", "nftmgmt", "oamcm"
]

OAMCONFIG_CONTAINERS = [
    "nwmgmt", "nftmgmt", "oamconfig", "appsecretinitoamconfig", "oamconfigcredmediator", "oamconfigstunnel"
]

OAMCTP_CONTAINERS = [
    "oamctp"
]

OAMEXT_CONTAINERS = [
    "appsecretinitcertificatemanagement", "appsecretinithttp", "appsecretinitne3sagent",
    "appsecretinitprovidercontroller", "nwmgmt", "nftmgmt", "httpd", "apigw", "certman",
    "providercontroller", "oamagent", "ne3sagent", "httpdstunnel", "ne3sagentstunnel",
    "providercontrollerstunnel", "certificatemanagementstunnel", "httpdcredmediator",
    "ne3sagentcredmediator", "providercontrollercredmediator", "certificatemanagementcredmediator",
    "tracecontroller"
]

OAMFH_CONTAINERS = [
    "nwmgmt", "nftmgmt", "oamfh", "dhcp", "vsftp"
]

OAMFM_CONTAINERS = [
    "nwmgmt", "nftmgmt", "oamfm"
]

OAMPM_CONTAINERS = [
    "oampm"
]


CPRT_CONTAINERS = ["nwmgmt", "cprt", "givaxi", "nftmgmt"]


def _check_enviroment_variables():
    global vdu_steam
    if len(VDU_BUILD) > 0:
        vdu_steam = VDU_BUILD.split(".")[-2]
    else:
        vdu_steam = "300"
    log_format = "%(asctime)s - %(levelname)s - %(message)s"
    logging.basicConfig(level=logging.DEBUG, format=log_format)
    logging.info("The current vdu build stream is {}.".format(vdu_steam))
    if vdu_steam not in VDU_STREAM_LIST:
        raise AssertionError(
            "VDU steam must in {vdu_steam_list}".format(vdu_steam_list=VDU_STREAM_LIST)
        )


def get_vdu_pods_container_mapping():
    _check_enviroment_variables()
    if vdu_steam == "300":
        aic_vdu_pods = {
            "oamasm": OAMASM_CONTAINERS,
            "oamcm": OAMCM_CONTAINERS,
            "oamconfig": OAMCONFIG_CONTAINERS,
            "oamctp": OAMCTP_CONTAINERS,
            "oamext": OAMEXT_CONTAINERS,
            "oamfh": OAMFH_CONTAINERS,
            "oamfm": OAMFM_CONTAINERS,
            "oampm": OAMPM_CONTAINERS,
            "cprt": CPRT_CONTAINERS,
            "up": UP_CONTAINERS,
            "lwsd": LWSD_CONTAINERS,
            "rcpsdl": LWSD_CONTAINERS,
            "rcpfm": RCPFM_CONTAINERS,
            "pm": PM_CONTAINERS,
            "trsconfig": TRSCONFIG_CONTAINERS,
            "logservice": LOGSERVICE_CONTAINERS,
            "rcpum": RCPUM_CONTAINERS,
            "securestorage": SECURESTORAGE_CONTAINERS,
            "kubeapisymptomdataprovider": KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS,
            "healing-controller": HEALING_CONTROLLER_CONTAINERS,
        }
    if vdu_steam == "400":
        aic_vdu_pods = {
            "oam": OAM_CONTAINERS,
            "cprt": CPRT_CONTAINERS,
            "up": UP_CONTAINERS,
            "lwsd": LWSD_CONTAINERS,
            "rcpsdl": LWSD_CONTAINERS,
            "rcpfm": RCPFM_CONTAINERS,
            "pm": PM_CONTAINERS,
            "trsconfig": TRSCONFIG_CONTAINERS,
            "logservice": LOGSERVICE_CONTAINERS,
            "rcpum": RCPUM_CONTAINERS,
            "securestorage": SECURESTORAGE_CONTAINERS,
            "certificate-management": CERTIFICATE_MANAGEMENT_CONTAINERS,
            "kubeapisymptomdataprovider": KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS,
            "healing-controller": HEALING_CONTROLLER_CONTAINERS,
        }
    buildin_obj = BuiltIn()
    buildin_obj.run_keyword("set_suite_variable", "${AIC_VDU_PODS}", aic_vdu_pods)
    return aic_vdu_pods


def set_vdu_pod_container_suite_variables():
    buildin_obj = BuiltIn()
    aic_vdu_pods = get_vdu_pods_container_mapping()
    for pod, containers in aic_vdu_pods.items():
        buildin_obj.run_keyword(
            "set_suite_variable",
            "${{{pod}_CONTAINERS}}".format(pod=pod.upper()),
            containers,
        )


# All NOM Parameters


def get_all_nom_server():
    _nom_ssh_connection_edge0 = SshServiceDetails(
        addr="10.39.156.122", username="cloud-user"
    )

    _nom1 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge0],
        https_main_info=HttpConnectionDetails(
            addr="https://neo-hosting-page.srncnms04.srnblr.nsn-rdnet.net/",
            username="cnms04",
            password="Qwer_1234",
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="https://user-mgmt.srncnms04.srnblr.nsn-rdnet.net"
        ),
        https_rest_info=HttpConnectionDetails(
            addr="https://apigw.srncnms04.srnblr.nsn-rdnet.net"
        ),
        neo_endpoints_ip="10.39.156.88",
    )

    _cnms1 = {}
    _cnms1["label"] = "NOM4"
    _cnms1["main_info"] = _nom1
    _cnms1["integrate_link"] = "http://nei-bot-svc.neo.svc.cluster.local/api/"
    _cnms1["ssh_ip_mask_len"] = "24"
    _cnms1["version"] = "nom_v1"
    _cnms1["ca_file"] = "nom/srncnms04_ca"
    _cnms1["vdu_integrate_to_nom_certificate_file"] = "nom/ca1_cacert"
    _cnms1["ca_sn"] = "0xFCA0530DA218DF4B"
    _cnms1["ca_id"] = "CACERT_R1"
    _cnms1["pm_sftp_ip"] = "10.39.156.88"
    _cnms1["pm_sftp_username"] = "sftpuser1"
    _cnms1["pm_sftp_password"] = "Qwer@1234"
    _cnms1["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms1["pm_sftp_root_path_rest"] = "/nedata/perfs"

    _nom_ssh_connection_edge10 = SshServiceDetails(
        addr="10.110.73.30", username="cloud-user"
    )
    _nom2 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge10],
        https_main_info=HttpConnectionDetails(
            addr="https://neo-hosting-page.srncnms10.srnblr.nsn-rdnet.net/",
            username="neonetics",
            password="Nokia_150",
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="https://user-mgmt.srncnms10.srnblr.nsn-rdnet.net"
        ),
        https_rest_info=HttpConnectionDetails(
            addr="https://apigw.srncnms10.srnblr.nsn-rdnet.net"
        ),
        neo_endpoints_ip="10.110.73.33",
    )

    _cnms2 = {}
    _cnms2["label"] = "NOM10"
    _cnms2["main_info"] = _nom2
    _cnms2["integrate_link"] = "http://nei-bot-svc.neo.svc.cluster.local/api/"
    _cnms2["ssh_ip_mask_len"] = "24"
    _cnms2["version"] = "nom_v1"
    _cnms2["ca_file"] = ""
    _cnms2["vdu_integrate_to_nom_certificate_file"] = ""
    _cnms2["ca_sn"] = ""
    _cnms2["ca_id"] = ""
    _cnms2["pm_sftp_ip"] = "10.110.73.33"
    _cnms2["pm_sftp_username"] = "sftpuser1"
    _cnms2["pm_sftp_password"] = "Nokia_150"
    _cnms2["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms2["pm_sftp_root_path_rest"] = "/nedata/perfs"

    nom_server_list = [_cnms1, _cnms2]
    # nom_count = len(nom_server_list)
    return nom_server_list


def get_all_netact_server():
    netact_info1_mr_dict = {
        "vcu_mrc": "MRC-5G22R2VCU/MR-",
        "vdu_mrc": "MRC-5G22R1VDU/MR-",
        "fhgw_mrc": "MRC-FHGW/MR-",
    }

    netact_info1 = {
        "netact_id": "clab3766",
        "node_ip": "10.32.217.23",
        "user": "omc",
        "password": "omc",
        "url": "https://clab3766lbwas.netact.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "omc",
        # "mr": "MRC-5G22R1VDU/MR-5227",
        "mr": netact_info1_mr_dict,
        "ca_file": "nom/clab3766ca.pem",
        "ca_sn": "0x63F008A095288472E25DCF1D3D49DDDEAF7DBE18",
        "ca_id": "CACERT_R1",
    }

    netact_info2_mr_dict = {
        "vcu_mrc": "MRC-5G22R2VCU/MR-",
        "vdu_mrc": "MRC-5G22R1VDU/MR-",
        "fhgw_mrc": "MRC-FHGW/MR-",
    }

    netact_info2 = {
        "netact_id": "clab3386",
        "node_ip": "10.32.217.141",
        "user": "omc",
        "password": "omc",
        "url": "https://clab3386lbwas.netact.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "omc",
        # "mr": "MRC-1/MR-1",
        "mr": netact_info2_mr_dict,
        "ca_file": "",
        "ca_sn": "",
        "ca_id": "",
    }

    netact_server_list = [netact_info1, netact_info2]
    return netact_server_list
