*** Settings ***
Documentation    Variables imported from init file.

*** Variables ***
${LMP_VCU_IP_2}=          ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${SSH_VCU_IP_2}=          ${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${CRAN_VCU_2}=            ${tl.gnbs[1].cloud_deployment.cloud_hosting.namespace}
${MRBTS_CU_2}=            ${tl.gnbs[1].cu.global_bts_id}
${SSH_K8S_VCU_IP}=        ${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
