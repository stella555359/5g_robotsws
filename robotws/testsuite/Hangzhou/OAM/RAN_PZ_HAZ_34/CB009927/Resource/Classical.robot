*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***


*** Keywords ***
Common Setup Classical
    Log To Console   ${EMPTY}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}

    # # Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    # # Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    # COAM Backup SCF
    # COAM Backup Full SCF
    Get ALL Suite Variables


Common Teardown Classical
    Run Keyword And Ignore Error   COAM Logout


Get ALL Suite Variables
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    ${SW_Release}   COAM Get SW Release
    Set Suite Variable   ${SW_Release}


Check PCMD Related Object Exist
    ${scf_xml}   COAM Get SCF Content
    # COAM Backup Full SCF
    # ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
    ${TCEADM_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
    Set Suite Variable   ${NRCTRLTS_EXIST}
    Set Suite Variable   ${NRCTRLTSDU_EXIST}
    Set Suite Variable   ${TCEADM_EXIST}

    ${actPCMDReport}   XML.Get Element Text   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="actPCMDReport"]
    ${actCellTraceReport}   XML.Get Element Text   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="actCellTraceReport"]
    ${PCMD_FLAG}   Set Variable If   "${actPCMDReport}"=="true"   ${True}   ${False}
    ${CELLTRACE_FLAG}   Set Variable If   "${actCellTraceReport}"=="true"   ${True}   ${False}
    Set Suite Variable   ${PCMD_FLAG}
    Set Suite Variable   ${CELLTRACE_FLAG}


COAM Remove PCMD Object
    # COAM Update PCMD Flag
    Check PCMD Related Object Exist
    @{del_all_pcmd}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrlts}
    Run Keyword If   ${NRCTRLTSDU_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrltsdu}
    Run Keyword If   ${TCEADM_EXIST}   Append To List   ${del_all_pcmd}   ${del_tceadm}
    Run Keyword If   ${PCMD_FLAG}   Append To List   ${del_all_pcmd}   ${del_pcmd_flag}
    Run Keyword If   ${CELLTRACE_FLAG}   Append To List   ${del_all_pcmd}   ${del_celltrace_flag}
    ${del_str}   Convert To String   ${del_all_pcmd}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}


COAM Add PCMD Object
    ${all_pcmd_object}   Set Variable If
    ...   '${SW_Release}'=='SBTS22R2' or '${SW_Release}'=='SBTS22R3'   ${add_all_pcmd_old}
#    ...   '${SW_Release}'=='SBTS23R4'   ${add_all_pcmd_new}
    ...   '${SW_Release}'>='SBTS23R4' and '${SW_Release}'<'SBTS24R3'   ${add_all_pcmd_new}
    ...   ${add_all_pcmd_24R3}

    # ${all_pcmd_object}   Set Variable   ${add_all_pcmd}

    ${add_str}   Convert To String   ${all_pcmd_object}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}


Remove And Add PCMD Object
    COAM Remove PCMD Object
    COAM Add PCMD Object
    Wait Until Keyword Succeeds   3x   1m   Check Session Setup
    # Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir


Check Session Setup
    [Arguments]   ${setup}=${true}
    Wait Until Keyword Succeeds   5m   20s
    ...   csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    ${sessions}   csn.Execute   command=netstat -tan | grep ${dcap_server_port}   connection=LOCAL
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${dcap_server_ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   csn.Disconnect   connection=LOCAL
