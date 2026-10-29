*** Settings ***
Documentation
...    Test suite for regression testing for feature CB006483
...    authors: Kamil Pielka, Wioleta Swies, Lubomir Krzeminski, Barlomiej Bienko
...    maintainer: TO BE DONE
...    group: RAN_PZ_KRK_SG_7
...    contact: i_5g_pz_mmw_krk_7sg_test@internal.nsn.com

Library     keywords.py
Library     taf.hw.pdu    WITH NAME    pdu
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library     on_air_tl_preparation.testline_preparation
Library     on_air_tl_preparation.testline_preparation_resources
Library     taf.nms.netact.interface.netact    WITH NAME    netact
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${GN_WEBUI_ASIx}         ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PASSWORD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}

# gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0]
${RU_PDU_MODEL}          ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].pdu_port.pdu.__class__.__name__}
${RU_PDU_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].pdu_port.pdu.addr}
${RU_PDU_PORT}           ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].pdu_port.port_no}

${WEBUI_ADDRESS_CU}      ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split('/')[0]}

${LSS_HOST}             ${tl.test_pcs[1].default_ssh_connection_details.addr}
${LSS_USERNAME}         ${tl.test_pcs[1].default_ssh_connection_details.username}
${LSS_PASSWORD}         ${tl.test_pcs[1].default_ssh_connection_details.password}
${LSS_USER_HOME_DIR}    /home/${LSS_USERNAME}

${LSS_SECONDARY_USERNAME}         ${tl.test_pcs[1].connections[2].username}
${LSS_SECONDARY_PASSWORD}         ${tl.test_pcs[1].connections[2].password}
${LSS_SECONDARY_USER_HOME_DIR}    /home/${LSS_SECONDARY_USERNAME}

${LSS_IP_ADDR}           ${tl.test_pcs[1].connections[0].v4}

${SNAP_TRIG_DIST_NAME}   MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1

${ACTCLI_DIST_NAME}      MNL_CONF_M-1/MNLENT_CONF_M-1/FEATCADM_CONF_M-1

@{SNAPSHOT_FILE_PARAMETERS}    end_time     start_time    trigger_type
...                            trigger_originator    trigger_reason    coverage_level    snapshot_result
${SNAP_LOCATION}          /d/oss/global/diagsnap/ne3sws

${NODE_IP}               10.41.146.105
${USERNAME_NETACT}       ${tl.nms.netact.ssh_connections_info.username}
${PASSWORD_NETACT}       ${tl.nms.netact.ssh_connections_info.password}
${WEB_URL}               srnclab1014lbwas.srnblr.nsn-rdnet.net
${NETACT_NAME}           srnclab1014
${DIST_NAME}             PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}
${MRBTS_IP}              ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${NETACT_RELEASE}        SBTS23R3
${MR}                    MRC-Common/MR-Common

${SCF_NAME}              GNB0_SCF.xml
${SCF_FAILED_NAME}       SCF_FAILED.xml

*** Keywords ***
Precondition For NetAct
    Add Node    cmwas    ${NODE_IP}   ${USERNAME_NETACT}    ${PASSWORD_NETACT}    alias=${NETACT_NAME}
    Add WEB URL    ${WEB_URL}    ${USERNAME_NETACT}    ${PASSWORD_NETACT}    alias=${NETACT_NAME}

Postcondition For NetAct
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

Integrate With NetAct
    ${integration_output}=    Integrate MRBTS With Netact    release=${NETACT_RELEASE}    mr=${MR}
    ...                                                      mrbts_address=${WEBUI_ADDRESS_CU}   dist_name=${DIST_NAME}
    ...                                                      security_mode=no TLS    ip_version=IPv4
    ...                                                      alias=${NETACT_NAME}
    Should Contain    ${integration_output}    Completed to verify NE    ignore_case=True

Deintegrate With Netact
    ${deintegration_output}=    Deintegrate MRBTS From Netact    dist_name=${DIST_NAME}  alias=${NETACT_NAME}
    Should Contain    ${deintegration_output}    Succeed to de-integrate NE    ignore_case=True

Restore To Default Configuration
    ${SCF_PATH}=    Get Scf Path    ${ENB_BUILD}
    Perform Full Commissioning on gNB    scf_file=${SCF_PATH}/${SCF_NAME}
    ...                                  validate_scf=${False}
    ...                                  timeout=${400}
    Wait For Site To Be Onair
    Check If Fault Snapshot Triggers Is Activated
    Set ActCli    value=${True}
    Change Lss Credentials    username=${LSS_USERNAME}    password=${LSS_PASSWORD}

