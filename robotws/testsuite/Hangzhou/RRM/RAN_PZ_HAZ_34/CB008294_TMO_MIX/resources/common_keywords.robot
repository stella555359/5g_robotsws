*** Settings ***
Documentation
...   author: pengliang.wu@nokia-sbell.com
...   contact: pengliang.wu@nokia-sbell.com

#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Variables    TL_variables.py



*** Variables ***
${DU_OAM_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_USER}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}         ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}             ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}
${GNB_MRBTS_ID}            ${tl.gnbs[0].instance_id}
${GNB_NRBTS_ID}            ${tl.gnbs[0].global_bts_id}


*** Keywords ***
