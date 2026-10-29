*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for OAM

*** Variables ***

${PATH_Storage}                     ${OUTPUT DIR}

${MAX_LOOP}                         5

${GN_WEBUI_ASIx}                    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER}                    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PASSWORD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_OAM_IP}                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_USER_NAME}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_USER_PWD}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}