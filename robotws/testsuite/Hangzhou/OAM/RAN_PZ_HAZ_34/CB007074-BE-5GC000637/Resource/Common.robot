*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Library     DateTime
Library     BuiltIn
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap   WITH NAME   cap
Resource    ./COAM.robot
Resource    ./LOG.robot
# Resource    ./ModalView.robot
Resource    ../../common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables   ../../libraries/global_vars.py
# Variables   ./test_instance_id_list.py

*** Variables ***
${display}   ${False}

*** Keyword ***
Common Setup
    Log To Console   ${EMPTY}
    Get ALL Suite Variables
    COAM Login Local
    COAM Login Peer
    COAM Get IP Interface
    COAM Backup SCF   file_name=old_commission_local.xml   connection=LOCAL
    COAM Backup SCF   file_name=old_commission_peer.xml   connection=PEER
    COAM Get ALL Variables From SCF
    Add XNLINK and NRADJGNB by WebEM Local
    Add XNLINK and NRADJGNB by WebEM Peer
    Get XNLINK and NRADJGNB from SCF
    COAM Wait XNLINK Status Available

Common Teardown
    Run Keyword And Ignore Error   COAM Logout Local
    Run Keyword And Ignore Error   COAM Logout Peer
    COAM Login Local
    COAM Login Peer
    Run Keyword And Ignore Error   Change Administrative Status   connection=LOCAL   status=Unlocked
    Run Keyword And Ignore Error   Change Administrative Status   connection=PEER   status=Unlocked

    COAM Wait XNLINK Status Available
    # Run Keyword And Ignore Error   COAM Reset Site   wait_for_reconnection=${False}   connection=LOCAL
    # Run Keyword And Ignore Error   COAM Reset Site   wait_for_reconnection=${False}   connection=PEER
    # Run Keyword And Ignore Error   COAM Logout Local
    # Run Keyword And Ignore Error   COAM Logout Peer
    # Wait Until Keyword Succeeds   20m   1m   COAM Login Peer
    # Wait Until Keyword Succeeds   20m   1m   COAM Login Local
    # Wait Until Keyword Succeeds   20m   3m   Check XN Link Status by WebEM
    # ...   url=${LOCAL_WEBUI_ADDR}   username=${LOCAL_WEBUI_USER}   password=${LOCAL_WEBUI_PWD}   xn_status=available   BTS=${LOCAL_MRBTS_ID}
    # Wait Until Keyword Succeeds   20m   3m   Check XN Link Status by WebEM
    # ...   url=${PEER_WEBUI_ADDR}   username=${PEER_WEBUI_USER}   password=${PEER_WEBUI_PWD}   xn_status=available   BTS=${PEER_MRBTS_ID}

#    Wait Until Keyword Succeeds   5m   1m   Check XN Link Status  connection=LOCAL   xn_status=available
#    Wait Until Keyword Succeeds   5m   1m   Check XN Link Status  connection=PEER    xn_status=available
    Run Keyword And Ignore Error   COAM Logout Local
    Run Keyword And Ignore Error   COAM Logout Peer

Set QC Instance ID Test Tag
    @{list}   Split String   ${TEST_NAME}   _
    ${test_id}   Set Variable   ${list[1]}
    ${status}   Run Keyword And Return Status   Set Test Variable   ${QC_ID}   ${qc_id_list['${BTS_ID}']['${test_id}']}
    Run Keyword If   not ${status}   Log To Console   QC ID Tag Not Exist, Using QC File To Report.
    Return From Keyword If   not ${status}
    Log To Console   QC_ID: ${QC_ID}
    Set Tags   QC_${QC_ID}

Get ALL Suite Variables
    Set Suite Variable   ${LOCAL_MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${LOCAL_NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${PEER_MRBTS_ID}   ${tl.gnbs[1].instance_id}
    Set Suite Variable   ${PEER_NRBTS_ID}   ${tl.gnbs[1].global_bts_id}

    Set Suite Variable   ${LOCAL_DIST_NAME}   MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${PEER_DIST_NAME}   MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].global_bts_id}

    Set Suite Variable   ${LOCAL_WEBUI_ADDR}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Set Suite Variable   ${LOCAL_WEBUI_USER}   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    Set Suite Variable   ${LOCAL_WEBUI_PWD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
    Set Suite Variable   ${PEER_WEBUI_ADDR}   ${tl.gnbs[1].cu.oam_http_connection_details.addr}
    Set Suite Variable   ${PEER_WEBUI_USER}   ${tl.gnbs[1].cu.oam_http_connection_details.username}
    Set Suite Variable   ${PEER_WEBUI_PWD}   ${tl.gnbs[1].cu.oam_http_connection_details.password}

    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Suite Variable   ${PEER_SSH_ADDR}   ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${PEER_SSH_USER}   ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${PEER_SSH_PWD}   ${tl.gnbs[1].cu.oam_ssh_connection_details.password}

COAM Get IP Interface
    ${local_smod}   Get SMOD Product Name   connection=LOCAL
    ${peer_smod}   Get SMOD Product Name   connection=PEER
    ${local_interface}   Set Variable If
    ...   '${local_smod}'=='ASIK'   fp0
    ...   '${local_smod}'=='ASIB'   br1
    ...   '${local_smod}'=='ASIL'   br0
    ${peer_interface}   Set Variable If
    ...   '${local_smod}'=='ASIK'   fp0
    ...   '${local_smod}'=='ASIB'   br1
    ...   '${local_smod}'=='ASIL'   br0
    Set Suite Variable   ${LOCAL_INTERFACE}
    Set Suite Variable   ${PEER_INTERFACE}

COAM Get ALL Variables From SCF
    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/old_commission_local.xml
    ${peer_xml}   XML.Parse XML   ${OUTPUT_DIR}/old_commission_peer.xml

    ${local_tac}  XML.Get Element Text  ${local_xml}  xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]
    ${peer_tac}  XML.Get Element Text  ${peer_xml}  xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]

    ${LOCAL_TAC}   Convert To Hex   item=${local_tac}   lowercase=true
    ${PEER_TAC}   Convert To Hex   item=${peer_tac}   lowercase=true
    Set Suite Variable   ${LOCAL_TAC}
    Set Suite Variable   ${PEER_TAC}

    ${local_gnbidlenth}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${LOCAL_DIST_NAME}"]/p[@name="gNbIdLength"]
    ${peer_gnbidlenth}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_DIST_NAME}"]/p[@name="gNbIdLength"]
    Set Suite Variable   ${LOCAL_GNBIDLENTH}
    Set Suite Variable   ${PEER_GNBIDLENTH}

    ${local_mcc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${LOCAL_DIST_NAME}"]/p[@name="mcc"]
    ${local_mnc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${LOCAL_DIST_NAME}"]/p[@name="mnc"]
    ${local_mnclength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${LOCAL_DIST_NAME}"]/p[@name="mncLength"]
    ${peer_mcc}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_DIST_NAME}"]/p[@name="mcc"]
    ${peer_mnc}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_DIST_NAME}"]/p[@name="mnc"]
    ${peer_mnclength}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_DIST_NAME}"]/p[@name="mncLength"]
    Set Suite Variable   ${LOCAL_MCC}
    Set Suite Variable   ${LOCAL_MNC}
    Set Suite Variable   ${LOCAL_MNCLENGTH}
    Set Suite Variable   ${PEER_MCC}
    Set Suite Variable   ${PEER_MNC}
    Set Suite Variable   ${PEER_MNCLENGTH}
    Set Suite Variable   ${LOCAL_PLMN}   ${local_mcc}${local_mnc.zfill(int(${local_mnclength}))}
    Set Suite Variable   ${PEER_PLMN}   ${peer_mcc}${peer_mnc.zfill(int(${peer_mnclength}))}

    ${local_tmp}   Set Variable If
    ...   '${local_mnclength}'=='2'   ${local_mcc}f${local_mnc.zfill(int(${local_mnclength}))}
    ...   '${local_mnclength}'=='3'   ${local_mcc}${local_mnc.zfill(int(${local_mnclength}))}
    ${peer_tmp}   Set Variable If
    ...   '${peer_mnclength}'=='2'   ${peer_mcc}f${peer_mnc.zfill(int(${peer_mnclength}))}
    ...   '${peer_mnclength}'=='3'   ${peer_mcc}${peer_mnc.zfill(int(${peer_mnclength}))}

    Set Suite Variable   ${LOCAL_PLMN_CODE}   ${local_tmp[1]}${local_tmp[0]}${local_tmp[3]}${local_tmp[2]}${local_tmp[5]}${local_tmp[4]}
    Set Suite Variable   ${PEER_PLMN_CODE}   ${peer_tmp[1]}${peer_tmp[0]}${peer_tmp[3]}${peer_tmp[2]}${peer_tmp[5]}${peer_tmp[4]}

#    ${local_xn_dn}   XML.Get Element Attribute   ${local_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:XNLINK"]
#    ${peer_xn_dn}   XML.Get Element Attribute   ${peer_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:XNLINK"]
#    Set Suite Variable   ${LOCAL_XN_DN}
#    Set Suite Variable   ${PEER_XN_DN}
#
#    ${local_adjgnb_dn}   XML.Get Element Attribute   ${local_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRADJGNB"]
#    ${peer_adjgnb_dn}   XML.Get Element Attribute   ${peer_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRADJGNB"]
#    Set Suite Variable   ${LOCAL_ADJGNB_DN}
#    Set Suite Variable   ${PEER_ADJGNB_DN}

    ${local_rmod_count}   XML.Get Element Count   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    ${peer_rmod_count}   XML.Get Element Count   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    Run Keyword If   '${local_rmod_count}'=='2'
    ...   Run Keywords   Set Suite Variable   ${MASTER}   LOCAL
    ...   AND   Set Suite Variable   ${SLAVE}   PEER
    Run Keyword If   '${peer_rmod_count}'=='2'
    ...   Run Keywords   Set Suite Variable   ${MASTER}   PEER
    ...   AND   Set Suite Variable   ${SLAVE}   LOCAL

Get XNLINK and NRADJGNB from SCF
    COAM Backup SCF   file_name=old_commission_local.xml   connection=LOCAL
    COAM Backup SCF   file_name=old_commission_peer.xml   connection=PEER
    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/old_commission_local.xml
    ${peer_xml}   XML.Parse XML   ${OUTPUT_DIR}/old_commission_peer.xml

    ${local_xn_dn}   XML.Get Element Attribute   ${local_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:XNLINK"]
    ${peer_xn_dn}   XML.Get Element Attribute   ${peer_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:XNLINK"]
    Set Suite Variable   ${LOCAL_XN_DN}
    Set Suite Variable   ${PEER_XN_DN}

    ${local_adjgnb_dn}   XML.Get Element Attribute   ${local_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRADJGNB"]
    ${peer_adjgnb_dn}   XML.Get Element Attribute   ${peer_xml}   distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRADJGNB"]
    Set Suite Variable   ${LOCAL_ADJGNB_DN}
    Set Suite Variable   ${PEER_ADJGNB_DN}