import os
import logging
from robot.libraries.BuiltIn import BuiltIn
import copy

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM

__all__ = [
    "get_vdu_pods_container_mapping",
    "set_vdu_pod_container_suite_variables"
]

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
UP_CONTAINERS = [
    "nwmgmt", "l2hi", "l2rt", "l1hi", "nftmgmt", "ipsecmgmt", "upipsecreadstunnel", "upipsecreadcredmediator"
]
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
    "nwmgmt", "nftmgmt", "httpd", "apigw", "certman", "providercontroller", "oamagent", "ne3sagent",
    "oamext-default-read-certstunnel", "oamext-default-write-certstunnel", "certificatemanagementstunnel",
    "oamextipsecreadstunnel", "oamext-default-read-certcredmediator", "oamext-default-write-certcredmediator",
    "certificatemanagementcredmediator", "oamextipsecreadcredmediator", "tracecontroller",
    "cnumserver", "ipsecmgmt", "givaxi", "sdp"
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


CPRT_CONTAINERS = [
    "nwmgmt", "cprt", "nftmgmt", "ipsecmgmt", "cprtipsecreadstunnel", "cprtipsecreadcredmediator"
]


# ================ Start of VDU ==================
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
    """get mapping table between VDU pod abbreviation and container abbreviation.

    *AUTHOR* calla.wang@nokia-sbell.com

    | Input Parameters | Man. | Description |
    None

    *RETURN VALUE*
    Dictionary of mapping

    Example
    | ${aic_vdu_pods} | get_vdu_pods_container_mapping |
    """
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
    aic_vdu_pods_container_abbr = copy.deepcopy(aic_vdu_pods)
    buildin_obj.run_keyword("set_suite_variable", "${AIC_VDU_PODS_CONTAINER_ABBR}", aic_vdu_pods_container_abbr)
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
