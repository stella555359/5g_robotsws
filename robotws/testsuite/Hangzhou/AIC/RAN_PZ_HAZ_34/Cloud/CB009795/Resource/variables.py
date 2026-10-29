from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

tl = BuiltIn().get_variable_value("${tl}")

all_gnbs = tl.gnbs
all_gnbs_detail = []
for single_gnbs in all_gnbs:
    dcap_server_ip = single_gnbs.dcap.connection_details.addr
    dcap_server_username = single_gnbs.dcap.connection_details.username
    dcap_server_password = single_gnbs.dcap.connection_details.password
    single_cu = single_gnbs.cu
    cu_mrbts_id = single_cu.global_bts_id
    cu_nrbts_id = single_cu.instance_id
    cu_ssh_addr = single_cu.oam_ssh_connection_details.addr
    cu_ssh_username = single_cu.oam_ssh_connection_details.username
    cu_ssh_password = single_cu.oam_ssh_connection_details.password
    cu_webem_addr = single_cu.oam_http_connection_details.addr
    cu_webem_username = single_cu.oam_http_connection_details.username
    cu_webem_password = single_cu.oam_http_connection_details.password
    cu_k8s_namespace = single_gnbs.cloud_deployment.cloud_hosting.namespace

    all_dus = single_gnbs.dus
    all_dus_detail = []
    for single_du in all_dus:
        du_mrbts_id = single_du.global_bts_id
        du_nrbts_id = single_du.instance_id
        du_webem_addr = single_du.oam_http_connection_details.addr
        du_webem_username = single_du.oam_http_connection_details.username
        du_webem_password = single_du.oam_http_connection_details.password
        single_du_detail = {
            "du_mrbts_id": du_mrbts_id,
            "du_nrbts_id": du_nrbts_id,
            "du_webem_addr": du_webem_addr,
            "du_webem_username": du_webem_username,
            "du_webem_password": du_webem_password,
        }
        all_dus_detail.append(single_du_detail)
    single_gnbs_detail = {
        "dcap_server_ip": dcap_server_ip,
        "dcap_server_username": dcap_server_username,
        "dcap_server_password": dcap_server_password,
        "cu_mrbts_id": cu_mrbts_id,
        "cu_nrbts_id": cu_nrbts_id,
        "cu_ssh_addr": cu_ssh_addr,
        "cu_ssh_username": cu_ssh_username,
        "cu_ssh_password": cu_ssh_password,
        "cu_webem_addr": cu_webem_addr,
        "cu_webem_username": cu_webem_username,
        "cu_webem_password": cu_webem_password,
        "cu_k8s_namespace": cu_k8s_namespace,

        "all_dus_detail": all_dus_detail,
    }
    all_gnbs_detail.append(single_gnbs_detail)

print(all_gnbs_detail)
