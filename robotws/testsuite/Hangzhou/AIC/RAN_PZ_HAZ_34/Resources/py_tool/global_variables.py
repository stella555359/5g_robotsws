import os
import logging
from robot.libraries.BuiltIn import BuiltIn
import copy
from cProfile import label
import subprocess
from pprint import pprint


from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from utils import (
    fast_connect_to_cu_k8s_master_with_admin,
    fast_execute_cu,
    fast_disconnect,
)

from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM
from taf.config.testline.testpc import TestPc

__all__ = [
    "get_vdu_pods_container_mapping",
    "set_vdu_pod_container_suite_variables",
    "get_vcu_stream",
    "get_vcu_pods_and_abbreviated_containers_mapping",
    "get_all_nom_server",
    "get_all_netact_server",
    "get_all_Sherpa_server",
    "get_all_RF_infos",
    "set_dcap_server_suite_variables",
    "get_all_Lcmaas_server",
    "get_appointed_dcap_info",
    "get_ru_MiocroDTX_cli"
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
    "nwmgmt",
    "l2hi",
    "l2rt",
    "nftmgmt",
    "ipsecmgmt",
]
L2RT_CONTAINERS = [
    "nwmgmt",
    "l2rt",
    "nftmgmt",
]
L2NRT_CONTAINERS = [
    "nwmgmt",
    "l2hi",
    "nftmgmt",
    "ipsecmgmt",
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

OAMASM_CONTAINERS = ["nwmgmt", "nftmgmt", "oamasm"]

OAMCM_CONTAINERS = ["nwmgmt", "nftmgmt", "oamcm"]

OAMCONFIG_CONTAINERS = [
    "nwmgmt",
    "nftmgmt",
    "oamconfig",
    "appsecretinitoamconfig",
    "oamconfigcredmediator",
    "oamconfigstunnel",
]

OAMCTP_CONTAINERS = ["oamctp"]

OAMEXT_CONTAINERS = [
    "nwmgmt",
    "nftmgmt",
    "httpd",
    "apigw",
    "certman",
    "providercontroller",
    "oamagent",
    "ne3sagent",
    "oamext-default-read-certstunnel",
    "oamext-default-write-certstunnel",
    "certificatemanagementstunnel",
    "oamextipsecreadstunnel",
    "oamext-default-read-certcredmediator",
    "oamext-default-write-certcredmediator",
    "certificatemanagementcredmediator",
    "oamextipsecreadcredmediator",
    "tracecontroller",
    "cnumserver",
    "ipsecmgmt",
    "givaxi",
    "sdp",
    "ne3sadapt",
]

OAMFH_CONTAINERS = ["nwmgmt", "nftmgmt", "oamfh", "dhcp", "vsftp"]

OAMFM_CONTAINERS = ["nwmgmt", "nftmgmt", "oamfm"]

OAMPM_CONTAINERS = ["oampm"]


CPRT_CONTAINERS = [
    "nwmgmt",
    "cprt",
    "nftmgmt",
    "ipsecmgmt",
    "cprtipsecreadstunnel",
    "cprtipsecreadcredmediator",
]

AHM_CONTAINERS = ['unfs3', 'l1commproxy']

FHNWMGMT_CONTAINERS = ['fhnwmgmt']

OAMBB_CONTAINERS = ['oambb']

OAMKPIANALYZER_CONTAINERS = ["oamkpianalyzer"]


def server_mapping_decorator(a_func):
    def server_mapping(*args):
        if "netact" in a_func.__name__.lower():
            setattr(a_func, "__maintainer__", "peng.lin@nokia-sbell.com")
        elif "nom" in a_func.__name__.lower():
            setattr(a_func, "__maintainer__", "jie.8.liu@nokia-sbell.com")
        elif "dcap" in a_func.__name__.lower():
            setattr(a_func, "__maintainer__", "xiaomian.zhang@nokia-sbell.com")
        setattr(
            a_func,
            "__page__",
            "https://confluence.ext.net.nokia.com/display/ASAiCBTS/3rd+server+maintainer+info",
        )
        result = a_func(*args)
        print("This 3rd server maintainer is:", getattr(a_func, "__maintainer__"))
        print("This 3rd server confluence page is:", getattr(a_func, "__page__"))
        return result

    return server_mapping


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


def get_vdu_pods_container_mapping(cloudran_version='2.0', up_pod_split_flag='0'):
    """get mapping table between VDU pod abbreviation and container abbreviation.

    *AUTHOR* calla.wang@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -xx.xx.xxxx,calla.wang@nokia-sbell.com, initialization.
        -16.2.2023,chris.l.cao@nokia-sbell.com, adapt UP_CONTAINERS to VRAN4.0
        -8.3.2023,chris.l.cao@nokia-sbell.com, adapt UP pod split into l2rt and l2nrt
        -11.3.2023,chris.l.cao@nokia-sbell.com, give up_pod_split_flag default value for invalid up_pod_split_flag

    | Input Parameters | Man. | Description |
    | cloudran_version | no | cloudran version, 2.0 or 4.0, default is 2.0 |
    | up_pod_split_flag | no | UP pod split flag, 0-UP pod is not split, 1-UP pod is split, default is '0' |

    *RETURN VALUE*
    Dictionary of mapping

    Example
    | ${aic_vdu_pods} | get_vdu_pods_container_mapping |
    """
    if cloudran_version == '2.0' and up_pod_split_flag == '1':
        raise RuntimeError("When cloudran_version is '2.0', up_pod_split_flag should be '0'")

    if up_pod_split_flag not in ['0', '1']:
        log_format = "%(asctime)s - %(levelname)s - %(message)s"
        logging.basicConfig(level=logging.DEBUG, format=log_format)
        logging.error("up_pod_split_flag should be '0' or '1', but now it's value is '{}',"
                      "we set it to '0' by default!"
                      .format(up_pod_split_flag)
                      )
        up_pod_split_flag = '0'

    _check_enviroment_variables()
    if cloudran_version not in ['4.0', 'INLINE', 'RINLINE']:
        UP_CONTAINERS.append("l1hi")

    if vdu_steam == "300" and up_pod_split_flag == '0':
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
            "oamkpianalyzer": OAMKPIANALYZER_CONTAINERS,
        }
    elif vdu_steam == "300" and up_pod_split_flag == '1':
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
            "l2rt": L2RT_CONTAINERS,
            "l2nrt": L2NRT_CONTAINERS,
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
            "oamkpianalyzer": OAMKPIANALYZER_CONTAINERS,
        }
    buildin_obj = BuiltIn()
    if cloudran_version in ['4.0', 'INLINE', 'RINLINE']:
        aic_vdu_pods['ahm'] = AHM_CONTAINERS
        aic_vdu_pods['fhnwmgmt'] = FHNWMGMT_CONTAINERS
        aic_vdu_pods['oambb'] = OAMBB_CONTAINERS
    buildin_obj.run_keyword("set_suite_variable", "${AIC_VDU_PODS}", aic_vdu_pods)
    aic_vdu_pods_container_abbr = copy.deepcopy(aic_vdu_pods)
    buildin_obj.run_keyword(
        "set_suite_variable",
        "${AIC_VDU_PODS_CONTAINER_ABBR}",
        aic_vdu_pods_container_abbr,
    )
    return aic_vdu_pods


def set_vdu_pod_container_suite_variables(cloudran_version='4.0', up_pod_split_flag='1'):
    buildin_obj = BuiltIn()
    aic_vdu_pods = get_vdu_pods_container_mapping(
        cloudran_version=cloudran_version,
        up_pod_split_flag=up_pod_split_flag
    )
    pprint(aic_vdu_pods)
    for pod, containers in aic_vdu_pods.items():
        buildin_obj.run_keyword(
            "set_suite_variable",
            "${{{pod}_CONTAINERS}}".format(pod=pod.upper()),
            containers,
        )


# ================ Start of VCU ===================
def _check_enviroment_variables_for_vcu():
    VCU_BUILD = os.getenv("SPECIFIC_VCU_BUILD", "").strip()
    print("SPECIFIC_VCU_BUILD:{}".format(VCU_BUILD))

    if len(VCU_BUILD) > 0:
        build_info = VCU_BUILD.split(".")
        main_stream = build_info[0].split("_")[-1]
        vcu_stream = "{}.{}".format(main_stream, build_info[1])
    else:
        # vcu_stream = "14.250"
        vcu_stream = get_vcu_stream()

    print("vcu_steam:{}".format(vcu_stream))

    return vcu_stream


def get_vcu_stream():
    """Get vcu stream, e.g, "14.300"

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    None

    *RETURN VALUE*
    Dictionary of mapping

    Example
    | ${vcu_stream} | get_vcu_stream |
    """
    alias = fast_connect_to_cu_k8s_master_with_admin()
    try:
        out = fast_execute_cu(
            command="helm list",
            with_pipeline_command="|grep aic-vcu-cnf|awk -F 'aic-vcu-cnf-' '{print $2}'|awk '{print $1}'",
            alias=alias,
        )
    except Exception as e:
        try:
            fast_disconnect(alias=alias)
        except Exception as e:
            pass
    fast_disconnect(alias=alias)
    print("get_vcu_stream:{}".format(out))

    main_stream_list = out.split(".")
    vcu_stream = "{}.{}".format(main_stream_list[0], main_stream_list[1])

    return vcu_stream


def get_vcu_pods_and_abbreviated_containers_mapping():
    """Get mapping table between vcu pod abbreviation and container abbreviation.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    None

    *RETURN VALUE*
    Dictionary of mapping

    Example
    | ${aic_vcu_pods} | get_vcu_pods_and_abbreviated_containers_mapping |
    """
    vcu_stream = _check_enviroment_variables_for_vcu()
    # if vcu_stream == "0.250" or vcu_stream == "14.250" or vcu_stream == "15.250":
    if True:
        aic_vcu_pods = {
            "cpcl": ["nwmgmt", "cpcl", "haagent"],
            "cpif": [
                "nwmgmt",
                "cpif",
                "nftmgmt",
                "haagent",
                "ipsecmgmt",
                "irstunnel",
                "ircredmediator",
            ],
            "cpnb": ["nwmgmt", "cpnb"],
            "cpnrt": ["nwmgmt", "cpnrt", "haagent"],
            "cpue": ["nwmgmt", "cpue"],
            "healing-controller": ["healing-controller"],
            "kubeapisymptomdataprovider": ["kubeapisymptomdataprovider"],
            "logservice": ["logstorageserver", "logprocessor"],
            "lwsd": ["lwsd"],
            "oamasm": [
                "nwmgmt",
                "oamasm",
                "oamasm-gwcredmediator",
                "oamasm-gwstunnel",
                "appsecretinitgeoresilie",
            ],
            "oamcm": ["nwmgmt", "oamcm"],
            "oamconfig": [
                "nwmgmt",
                "oamconfig",
                "oamconfig-dwccredmediator",
                "oamconfig-iwcredmediator",
                "oamconfig-dwcstunnel",
                "oamconfig-iwstunnel",
                "appsecretinitdefaultwri",
            ],
            "oamext": [
                "nwmgmt",
                "appsecretinitcertificat",
                "appsecretinitdefaultrea",
                "appsecretinitdefaultwri",
                "appsecretinitipsec-r",
                "appsecretinitoamagent",
                "nftmgmt",
                "httpd",
                "apigw",
                "certman",
                "providercontroller",
                "oamagent",
                "tracecontroller",
                "oamext-drccredmediator",
                "oamext-dwccredmediator",
                "certificatcredmediator",
                "oamagent-grcredmediator",
                "oamext-ircredmediator",
                "oamext-drcstunnel",
                "oamext-dwcstunnel",
                "certificatstunnel",
                "oamagent-grstunnel",
                "oamext-irstunnel",
                "ne3sagent",
                "ipsecmgmt",
                "cnumserver",
                "givaxi",
                "sdp",
            ],
            "oamfm": ["nwmgmt", "oamfm"],
            "oampm": ["nwmgmt", "oampm"],
            "pm": ["pmcore", "pm-rest-server"],
            "rcpfm": ["fm-chown", "rcpfm"],
            "rcpsdl": ["rcpsdl", "rcpsdl-sentinel"],
            "rcpum": ["um-init-0", "um-init-1", "rcpum"],
            "securestorage": [
                "secretinit",
                "vaultloganalyzer",
                "vaultserver",
                "stunnel",
                "vaultmanager",
            ],
            "trsconfig": ["trsconfig"],
            "upue": [
                "nwmgmt",
                "nftmgmt",
                "appsecretinitipsec-r",
                "l2hicu",
                "ipsecmgmt",
                "upue-irstunnel",
                "upue-ircredmediator",
            ],
        }

    return aic_vcu_pods


# ================ Start of NOM ==================
@server_mapping_decorator
def get_all_nom_server():
    """get_all_nom_server

    *AUTHOR* jie.8.liu@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -15.08.2021,chris.l.cao@nokia-sbell.com, optimization.
        -15.12.2021, calla.wang@nokia-sbell.com ? add NOM13 server
        -16.2.2022, chris.l.cao@nokia-sbell.com, add field configured_status
        -19.7.2022, chris.l.cao@nokia-sbell.com, change NOM13 as the first priority candidate

    | Input Parameters | Man. | Description |
    None

    *RETURN VALUE*
    List of NOM server

    Example
    | ${nom_server_list} | get_all_nom_server |
    """
    _nom_ssh_connection_edge0 = SshServiceDetails(
        addr="10.39.156.122", username="cloud-user"
    )

    _nom1 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge0],
        https_main_info=HttpConnectionDetails(
            addr="https://neo-hosting-page.srncnms04.srnblr.nsn-rdnet.net",
            username="cnms04",
            password="Qwert_12345",
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
    _cnms1["ssh_key_file"] = "nom/id_rsa"
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
    _cnms1["configured_status"] = "available"

    _nom_ssh_connection_edge10 = SshServiceDetails(
        addr="10.110.73.30", username="cloud-user"
    )
    _nom2 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge10],
        https_main_info=HttpConnectionDetails(
            addr="https://neo-hosting-page.srncnms10.srnblr.nsn-rdnet.net",
            username="neonetics",
            password="Nokia123@",
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
    _cnms2["ssh_key_file"] = "nom/id_rsa_nom10"
    _cnms2["version"] = "nom_v1"
    _cnms2["ca_file"] = ""
    _cnms2["vdu_integrate_to_nom_certificate_file"] = ""
    _cnms2["ca_sn"] = ""
    _cnms2["ca_id"] = ""
    _cnms2["pm_sftp_ip"] = "10.110.73.33"
    _cnms2["pm_sftp_username"] = "sftpuser1"
    _cnms2["pm_sftp_password"] = "Qwer_1234"
    _cnms2["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms2["pm_sftp_root_path_rest"] = "/nedata/perfs"
    _cnms2["configured_status"] = "available"

    _nom_ssh_connection_edge13 = SshServiceDetails(
        addr="10.27.137.179", username="cloud-user"
    )
    _nom13 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge13],
        https_main_info=HttpConnectionDetails(
            addr="https://neo-hosting-page.srncnms13.srnblr.nsn-rdnet.net/",
            username="neonetics",
            password="Nokia123#",
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="https://user-mgmt.srncnms13.srnblr.nsn-rdnet.net"
        ),
        https_rest_info=HttpConnectionDetails(
            addr="https://apigw.srncnms13.srnblr.nsn-rdnet.net"
        ),
        neo_endpoints_ip="10.27.137.181",
    )
    _cnms13 = {}
    _cnms13["label"] = "NOM13"
    _cnms13["main_info"] = _nom13
    _cnms13["integrate_link"] = "http://nei-bot-svc.neo.svc.cluster.local/api/"
    _cnms13["ssh_ip_mask_len"] = "24"
    _cnms13["ssh_key_file"] = "nom/id_rsa_nom13"
    _cnms13["version"] = "nom_v1"
    _cnms13["ca_file"] = "nom/nom13_ca.crt"
    _cnms13["vdu_integrate_to_nom_certificate_file"] = "nom/ca1_cacert"
    _cnms13["ca_sn"] = "0xD75"
    _cnms13["ca_id"] = ""
    _cnms13["pm_sftp_ip"] = "10.27.137.181"
    _cnms13["pm_sftp_username"] = "sftpuser1"
    _cnms13["pm_sftp_password"] = "Qwer_1234"
    _cnms13["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms13["pm_sftp_root_path_rest"] = "/nedata/perfs"
    _cnms13["configured_status"] = "unavailable"

    _nom_ssh_connection_edge22 = SshServiceDetails(
        addr="100.74.45.194", username="core"
    )
    _nom22 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge22],
        https_main_info=HttpConnectionDetails(
            addr="https://neo6530.dyn.nesc.nokia.net",
            username="petcnms",
            password="Qwer_12345",
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="https://neo6530.dyn.nesc.nokia.net"
        ),

        https_rest_info=HttpConnectionDetails(
            addr="https://neo6530.dyn.nesc.nokia.net"
        ),
        neo_endpoints_ip="100.74.44.173",
    )

    _cnms22 = {}
    _cnms22["label"] = "NOM22"
    _cnms22["main_info"] = _nom22
    _cnms22["integrate_link"] = "http://nei-bot-svc.neo.svc.cluster.local/api/"
    _cnms22["ssh_ip_mask_len"] = "24"
    _cnms22["ssh_key_file"] = "nom/id_rsa_nom22"
    _cnms22["version"] = "nom_v1"
    _cnms22["ca_file"] = "nom/neo6530_ca"
    _cnms22["vdu_integrate_to_nom_certificate_file"] = "nom/ca1_cacert"
    _cnms22["ca_sn"] = "0xA4D758BDC5589F93"
    _cnms22["ca_id"] = ""
    _cnms22["pm_sftp_ip"] = "100.74.44.173"
    _cnms22["pm_sftp_username"] = "sftpuser1"
    _cnms22["pm_sftp_password"] = "Qwer_1234"
    _cnms22["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms22["pm_sftp_root_path_rest"] = "/nedata/perfs"
    _cnms22["configured_status"] = "available"

    _nom_ssh_connection_edge22_neo8922 = SshServiceDetails(
        addr="100.74.134.189", username="core"
    )
    _nom22_neo8922 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge22_neo8922],
        https_main_info=HttpConnectionDetails(
            addr="https://neo8922.dyn.nesc.nokia.net",
            username="petcnms",
            password="Qwer_1234",
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="https://neo8922.dyn.nesc.nokia.net"
        ),

        https_rest_info=HttpConnectionDetails(
            addr="https://neo8922.dyn.nesc.nokia.net"
        ),
        neo_endpoints_ip="100.74.132.103",
    )

    _cnms22_neo8922 = {}
    _cnms22_neo8922["label"] = "NOM22_neo8922"
    _cnms22_neo8922["main_info"] = _nom22_neo8922
    _cnms22_neo8922["integrate_link"] = "http://nei-bot-svc.neo.svc.cluster.local/api/"
    _cnms22_neo8922["ssh_ip_mask_len"] = "24"
    _cnms22_neo8922["ssh_key_file"] = "nom/id_rsa_nom22_neo8922"
    _cnms22_neo8922["version"] = "nom_v1"
    _cnms22_neo8922["ca_file"] = "nom/ca1_cacert"
    _cnms22_neo8922["vdu_integrate_to_nom_certificate_file"] = "nom/ca1_cacert"
    _cnms22_neo8922["ca_sn"] = "0xD75"
    _cnms22_neo8922["ca_id"] = ""
    _cnms22_neo8922["pm_sftp_ip"] = "100.74.132.103"
    _cnms22_neo8922["pm_sftp_username"] = "sftpuser1"
    _cnms22_neo8922["pm_sftp_password"] = "Qwer_1234"
    _cnms22_neo8922["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms22_neo8922["pm_sftp_root_path_rest"] = "/nedata/perfs"
    _cnms22_neo8922["configured_status"] = "available"

    _nom_ssh_connection_edge22_neo5325 = SshServiceDetails(
        addr="100.74.139.129", username="core"
    )
    _nom22_neo5325 = NOM(
        ssh_connections_info=[_nom_ssh_connection_edge22_neo5325],
        https_main_info=HttpConnectionDetails(
            addr="https://neo5325.dyn.nesc.nokia.net",
            username="petcnms",
            password="Qwer_1234",
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="https://neo5325.dyn.nesc.nokia.net"
        ),

        https_rest_info=HttpConnectionDetails(
            addr="https://neo5325.dyn.nesc.nokia.net"
        ),
        neo_endpoints_ip="100.74.136.47",
    )

    _cnms22_neo5325 = {}
    _cnms22_neo5325["label"] = "NOM22_neo5325"
    _cnms22_neo5325["main_info"] = _nom22_neo5325
    _cnms22_neo5325["integrate_link"] = "http://nei-bot-svc.neo.svc.cluster.local/api/"
    _cnms22_neo5325["ssh_ip_mask_len"] = "24"
    _cnms22_neo5325["ssh_key_file"] = "nom/id_rsa_nom22_neo5325"
    _cnms22_neo5325["version"] = "nom_v1"
    _cnms22_neo5325["ca_file"] = "nom/ca1_cacert"
    _cnms22_neo5325["vdu_integrate_to_nom_certificate_file"] = "nom/ca1_cacert"
    _cnms22_neo5325["ca_sn"] = "0xD75"
    _cnms22_neo5325["ca_id"] = ""
    _cnms22_neo5325["pm_sftp_ip"] = "100.74.136.47"
    _cnms22_neo5325["pm_sftp_username"] = "sftpuser1"
    _cnms22_neo5325["pm_sftp_password"] = "Qwer_1234"
    _cnms22_neo5325["pm_sftp_root_path"] = "/nedata/perfs/HQZ"
    _cnms22_neo5325["pm_sftp_root_path_rest"] = "/nedata/perfs"
    _cnms22_neo5325["configured_status"] = "available"

    nom_server_list = [_cnms22_neo8922, _cnms22_neo5325, _cnms1, _cnms2]
    # nom_server_list = [_cnms22_neo8922, _cnms1, _cnms2]

    return nom_server_list


# ================ Start of Netact ==================
@server_mapping_decorator
def get_all_netact_server():
    """get_all_netact_server

    *AUTHOR* chris.l.cao@nokia-sbell.com
    modified by:        <22-02-2021>, <hongysun>, <add netact_info3,modify netact_info2>

    | Input Parameters | Man. | Description |
    None

    *RETURN VALUE*
    List of netact server

    Example
    | ${netact_server_list} | get_all_netact_server |
    """
    netact_clab1057_mr_dict = {
        "vcu_mrc": "MRC-AICTAVCU/MR-",
        "vdu_mrc": "MRC-AICTAVDU/MR-",
        "fhgw_mrc": "MRC-AICTAFHGW/MR-",
    }

    netact_clab1057 = {
        "netact_id": "clab1057",
        "node_ip": "10.68.122.63",
        "user": "omc",
        "password": "Medsql!_1893",
        "url": "https://srnclab1057lbwas.srnblr.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "Medsql!_1893",
        "mr": netact_clab1057_mr_dict,
        "ca_file": "nom/clab33ca.pem",
        "ca_sn": "0x9B",
        "ca_id": "CACERT_R1",
        "configured_status": "available",
    }

    netact_clab2003_mr_dict = {
        "vcu_mrc": "MRC-AICTAVCU/MR-",
        "vdu_mrc": "MRC-AICTAVDU/MR-",
        "fhgw_mrc": "MRC-AICTAFHGW/MR-",
    }

    netact_clab2003 = {
        "netact_id": "clab2003",
        "node_ip": "10.82.47.46",
        "user": "omc",
        "password": "Medsql!_1893",
        "url": "https://srnclab2003lbwas.srnblr.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "Medsql!_1893",
        "mr": netact_clab2003_mr_dict,
        "ca_file": "nom/clab33ca.pem",
        "ca_sn": "0x9B",
        "ca_id": "CACERT_R1",
        "configured_status": "available",
    }

    netact_clabZheng3_mr_dict = {
        "vcu_mrc": "MRC-AICTAVCU/MR-",
        "vdu_mrc": "MRC-AICTAVDU/MR-",
        "fhgw_mrc": "MRC-AICTAFHGW/MR-",
    }

    netact_clabZheng3 = {
        "netact_id": "clabZheng3",
        "node_ip": "10.110.188.146",
        "user": "omc",
        "password": "Nokia123!",
        "url": "https://zheng3lbwas.zheng3.srnhz.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "Nokia123!",
        "mr": netact_clabZheng3_mr_dict,
        "ca_file": "nom/HZzhou4.pem",
        "ca_sn": "0xA0C",
        "ca_id": "CACERT_R1",
        "configured_status": "available",
    }

    netact_clabChen4_mr_dict = {
        "vcu_mrc": "MRC-AICTAVCU/MR-",
        "vdu_mrc": "MRC-AICTAVDU/MR-",
        "fhgw_mrc": "MRC-AICTAFHGW/MR-",
    }

    netact_clabChen4 = {
        "netact_id": "clabChen4",
        "node_ip": "10.108.248.82",
        "user": "omc",
        "password": "Nokia126_",
        "url": "https://gansulbwas.gansu.srnhz.nsn-rdnet.net",
        "url_user": "omc",
        "url_password": "Nokia126_",
        "mr": netact_clabChen4_mr_dict,
        "ca_file": "nom/HZzhou4.pem",
        "ca_sn": "0xA0C",
        "ca_id": "CACERT_R1",
        "configured_status": "available",
    }

    netact_server_list = [netact_clabChen4, netact_clabZheng3, netact_clab1057, netact_clab2003]
    buildin_obj = BuiltIn()
    buildin_obj.run_keyword(
        "set_suite_variable",
        "${ALL_NETACTs_INFO}",
        netact_server_list,
    )
    return netact_server_list


# ================ Start of Sherpa ==================
def get_all_Sherpa_server():
    Sherpa_info1 = {
        "hostname": "10.97.120.168",
        "username": "aic",
        "password": "Nokia123!",
    }

    Sherpa_server_list = [Sherpa_info1]
    return Sherpa_server_list


# ================ Start of RF ==================
def get_all_RF_infos():
    RF_info1 = {
        "model": {"AEQP", "AEQY", "AEQE", "AEQQ", "AEQK"},
        "type": "TDD",
        "username": "serviceuser",
        "password": "bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
        "2nduser": "root",
        "rf_local_ip": ["192.168.101.2"],
        "atten": {"0", "1", "2", "3", "4", "5", "6", "7"},
        "prompt": "Node\\d:~#",
    }
    RF_info2 = {
        "model": {"AZQI", "AZQJ", "AZQW", "AZQS"},
        "type": "TDD",
        "username": "rfsw",
        "password": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
        "2nduser": "rfsw",
        "rf_local_ip": ["192.168.101.2"],
        "atten": {"0", "2", "4", "6"},
        "prompt": "made:~$",
    }
    RF_info3 = {
        "model": {"AEHC"},
        "type": "TDD",
        "username": "serviceuser",
        "password": "7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=",
        "2nduser": "root",
        "rf_local_ip": ["192.168.100.10"],
        "atten": {"0", "1", "2", "3", "4", "5", "6", "7"},
        "prompt": "aehb:~$",
    }
    RF_info4 = {
        "model": {"AHBCC", "AHFIA", "AHFIB"},
        "type": "FDD",
        "username": "serviceuser",
        "password": "bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
        "2nduser": "root",
        "rf_local_ip": [],
        "atten": {"66": {"2", "3"}, "5": {"2", "3"}, "25": {"0", "1"}},
        "prompt": "",
    }
    RF_info5 = {
        "model": {"AHCA", "AHHB", "AHPB"},
        "type": "FDD",
        "username": "serviceuser",
        "password": "bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
        "2nduser": "root",
        "rf_local_ip": [],
        "atten": {"5": {"0", "1"}, "7": {"0", "1"}, "28": {"0", "1"}},
        "prompt": "",
    }
    RF_info6 = {
        "model": {"AQQL"},
        "type": "TDD",
        "username": "rfsw",
        "password": "3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
        "2nduser": "root",
        "rf_local_ip": ["192.168.101.3", "192.168.101.2"],
        "atten": {"0", "2", "4", "6"},
        "prompt": "",
    }
    RF_info7 = {
        "model": {"AZQL"},
        "type": "TDD",
        "username": "root",
        "password": "w@=EIj7P6R0bVy85OjCVa^ho&8",
        "2nduser": "root",
        "rf_local_ip": ["192.168.100.3"],
        "atten": {"0", "1", "2", "3"},
        "prompt": "",
    }
    RF_info8 = {
        "model": {"AQQN"},
        "type": "TDD",
        "username": "rfsw",
        "password": "3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
        "2nduser": "root",
        "rf_local_ip": ["192.168.101.2"],
        "atten": {"0", "2", "4", "6"},
        "prompt": "",
    }

    RF_infos_list = [RF_info1, RF_info2, RF_info3, RF_info4, RF_info5, RF_info6, RF_info7, RF_info8]
    return RF_infos_list


def _spv(varname, value):
    """get available DCAP server info
    *AUTHOR* luofei.tu@nokia-sbell.com
    """
    if "$" not in varname and "@" not in varname and "&" not in varname:
        varname = "${%s}" % (varname)
    buildin_obj = BuiltIn()
    buildin_obj.set_global_variable(varname, value)


def _get_available_DCAP_server_info():
    """get available DCAP server info
    *AUTHOR* luofei.tu@nokia-sbell.com
    """

    _dcap_server1 = TestPc(
        default_ssh_connection_details=SshServiceDetails(
            addr="10.107.169.16", username="dcapuser", password="dcapadmin!"
        )
    )
    _dcap_1 = {
        "label": "DCAP1",
        "Type": "commercial",
        "main_info": _dcap_server1,
        "port": "49151",
        "dpca_ipv6": "2a00:8a00:8000:5002:0:f:30:1e",
        "dcap_log_dir": "/sharedvolume/ntracer/_data/",
        "dcap_cp_log_dir": "/sharedvolume/flowtracer5g/tmp/5G",
        "dcap_up_log_dir": "/sharedvolume/udptracer/_data/",
        "configured_status": "available",
    }

    _dcap_server2 = TestPc(
        default_ssh_connection_details=SshServiceDetails(
            addr="10.107.169.19", username="dcapuser", password="dcapadmin!"
        )
    )
    _dcap_2 = {
        "label": "DCAP2",
        "Type": "basic",
        "main_info": _dcap_server2,
        "port": "49151",
        "dpca_ipv6": "fe80::f816:3eff:fe40:727f",
        "dcap_log_dir": "/sharedvolume/ntracer/_data/",
        "dcap_cp_log_dir": "/sharedvolume/flowtracer5g/tmp/5G",
        "dcap_up_log_dir": "/sharedvolume/udptracer/_data/",
        "configured_status": "available",
    }

    _dcap_server3 = TestPc(
        default_ssh_connection_details=SshServiceDetails(
            addr="10.107.169.186", username="dcapuser", password="dcapadmin!"
        )
    )
    _dcap_server3_http = HttpConnectionDetails(
            addr="10.107.169.186", username="dcapuser", password="dcapadmin!", port="443"
    )
    _dcap_server3_http_v6 = HttpConnectionDetails(
        addr="2a00:8a00:8000:5002:0:f:5:186", username="dcapuser", password="dcapadmin!", port="443"
    )

    _dcap_server4 = TestPc(
        default_ssh_connection_details=SshServiceDetails(
            addr="10.107.169.185", username="dcapuser", password="dcapadmin!"
        )
    )
    _dcap_server4_http = HttpConnectionDetails(
            addr="10.107.169.185", username="dcapuser", password="dcapadmin!", port="443"
    )
    _dcap_server4_http_v6 = HttpConnectionDetails(
        addr="2a00:8a00:8000:5002:0:f:5:185", username="dcapuser", password="dcapadmin!", port="443"
    )

    _dcap_4 = {
        "label": "DCAP4",
        "Type": "basic",
        "main_info": _dcap_server4,
        "port": "49151",
        "dpca_ipv6": "",
        "dcap_log_dir": "/sharedvolume/ntracer/_data/",
        "dcap_cp_log_dir": "/sharedvolume/flowtracer5g/traces/5G",
        "dcap_up_log_dir": "/sharedvolume/udptracer/_data/",
        "configured_status": "available",
        "http_info": _dcap_server4_http,
        "http_info_v6": _dcap_server4_http_v6
    }

    _dcap_3 = {
        "label": "DCAP3",
        "Type": "basic",
        "main_info": _dcap_server3,
        "port": "49151",
        "dpca_ipv6": "",
        "dcap_log_dir": "/sharedvolume/ntracer/_data/",
        "dcap_cp_log_dir": "/sharedvolume/flowtracer5g/tmp/5G",
        "dcap_up_log_dir": "/sharedvolume/udptracer/_data/",
        "configured_status": "available",
        "http_info": _dcap_server3_http,
        "http_info_v6": _dcap_server3_http_v6
    }
    dcap_server_list = [_dcap_1, _dcap_2, _dcap_3, _dcap_4]
    return dcap_server_list


@server_mapping_decorator
def set_dcap_server_suite_variables():
    """get available DCAP server info
    *AUTHOR* luofei.tu@nokia-sbell.com
    """
    dcap_servers = _get_available_DCAP_server_info()
    availaile_dcap_server = 0
    for dcap in dcap_servers:
        if dcap["configured_status"] == "unavailable":
            continue
        result = ping_server(dcap["main_info"].default_ssh_connection_details.addr)
        if result:
            _spv("DCAP_IP", dcap["main_info"].default_ssh_connection_details.addr)
            _spv("DCAP_USER", dcap["main_info"].default_ssh_connection_details.username)
            _spv(
                "DCAP_PASSWORD",
                dcap["main_info"].default_ssh_connection_details.password,
            )
            _spv("DCAP_PORT", dcap["port"])
            _spv("DCAP_IPv6", dcap["dpca_ipv6"])
            _spv("DCAP_LOG_DIR", dcap["dcap_log_dir"])
            _spv("DCAP_CP_LOG_DIR", dcap["dcap_cp_log_dir"])
            _spv("DCAP_UP_LOG_DIR", dcap["dcap_up_log_dir"])
            availaile_dcap_server += 1
            break
        else:
            print(
                "*WARN* The %s is broken DCAP"
                % dcap["main_info"].default_ssh_connection_details.addr
            )
    if availaile_dcap_server == 0:
        print(
            "*ERROR* ALL DCAP are broken,please go to DCAP server info confluence page and contact the related owner"
        )


def ping_server(ip):
    status = subprocess.call(
        ["ping", "-q", "-c", "3", ip], stdout=open(os.devnull, "wb")
    )
    if status == 0:
        status = True
    print("unpingable:", status)
    return status


set_dcap_server_suite_variables()


def get_appointed_dcap_info(dcap_label='dcap3'):
    all_info = _get_available_DCAP_server_info()
    for info in all_info:
        if info['label'].upper() == dcap_label.upper():
            return info
    raise Exception('Did not find this dcap.')


# ================ Start of Lcmaas ==================
def get_all_Lcmaas_server():
    Lcmaas_info1 = {
        "hostname": "10.109.5.235",
        "username": "lcm",
        "password": "system123",
        "ssh_user": "hzaicst",
        "ssh_pass": "nokia123"
    }

    Lcmaas_server_list = [Lcmaas_info1]
    return Lcmaas_server_list


def get_ru_MiocroDTX_cli(ru_type):
    ru_type_cli_dic = {
        'AEQX': ['/ action create PsuMeasurements /CI/PsuMeasurements /module', '/CI/PsuMeasurements action measure',
                 '/CI/PsuMeasurements action terminate'],
        'AEQY': ['/ action create PsuMeasurements /CI/PsuMeasurements /module', '/CI/PsuMeasurements action measure',
                 '/CI/PsuMeasurements action terminate'],
        'AEHC': ['/ action create PsuMeasurements /psu1 /module/psu1', '/psu1 action measure',
                 '/psu1 action terminate'],
        'AQQX': ['/ action create PsuMeasurements /rf_psu /rf/psu', '/rf_psu action measure',
                 '/rf_psu action terminate'],
        'AQQL': ['/ action create PsuMeasurements /rf_psu /rf/psu', '/rf_psu action measure',
                 '/rf_psu action terminate'],
        'AZQJ': ['/ action create PsuMeasurements /CI/PsuMeasurements /module', '/CI/PsuMeasurements action measure',
                 '/CI/PsuMeasurements action terminate'],
        'AQQN': ['/ action create PsuMeasurements /rf_psu /rf/psu', '/rf_psu action measure',
                 '/rf_psu action terminate']
    }
    return ru_type_cli_dic[ru_type]
