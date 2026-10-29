*** Settings ***
Resource   Common.robot

*** Variables ***
# ${example}   SEPARATOR=

*** Keyword ***
COAM Remove PCMD Object
    Check PCMD Related Object Exist
    @{del_all_pcmd}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrlts}
    Run Keyword If   ${NRCTRLTSDU_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrltsdu}
    Run Keyword If   ${TCEADM_EXIST}   Append To List   ${del_all_pcmd}   ${del_tceadm}
    ${del_str}   Convert To String   ${del_all_pcmd}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

COAM Add PCMD Object
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    ${add_str}    Run keyword If  '${release_sbts}'=='SBTS23R1' 
    ...        Convert To String   ${add_all_pcmd} 
    ...    ELSE IF   '${release_sbts}'=='SBTS23R2' or '${release_sbts}'=='SBTS23R3'  
    ...        Convert To String   ${add_all_pcmd_23R2}
    ...    ELSE   Convert To String   ${add_all_pcmd_23R4}

    #${add_str}   Convert To String   ${add_all_pcmd}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Update PCMD Flag
    [Arguments]   ${flag}=true
    Run Keyword If   '${flag}'!='false' and '${flag}'!='true'   FAIL   Please Input "true" or "false"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=actPCMDReport   value=${flag}

COAM Update Celltrace Flag
    [Arguments]   ${flag}=true
    Run Keyword If   '${flag}'!='false' and '${flag}'!='true'   FAIL   Please Input "true" or "false"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=actCellTraceReport   value=${flag}

Check PCMD Related Object Exist
    ${scf_xml}   COAM Get SCF Content
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
    ${TCEADM_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
    Set Suite Variable   ${NRCTRLTS_EXIST}
    Set Suite Variable   ${NRCTRLTSDU_EXIST}
    Set Suite Variable   ${TCEADM_EXIST}

Delete MO via COAM
    [Arguments]  ${MO_name}   ${BTS_ip}=${WEBUI_ADDR}   ${usernanme}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    log to console   Delete MO via COAM
    ${parameter}    create list
    ${conn}   wait until keyword succeeds  5 times   1min   coam.connect_to
    ...   bts_host=${BTS_ip}
    ...   username=${usernanme}
    ...   password=${password}
    ...   name=COAM
    coam.perform_object_recommissioning   dist_name=${MO_name}   parameter=${parameter}   operation=delete
    ...   skip_parameter_relation_errors=True   connection=${conn}
    [Teardown]  run keyword and ignore error   coam.teardown   connection=${conn}

Check NRCTRLTS Object Exist
    ${scf_xml}   COAM Get SCF Content
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    Set test variable  ${NRCTRLTS_EXIST}

COAM Remove NRCTRLTS Object
    Check NRCTRLTS Object Exist
    @{del_all_nrctrlts}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_nrctrlts}   ${del_nrctrlts}
    ${del_str}   Convert To String   ${del_all_nrctrlts}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

COAM Add NRCTRLTS Object
    [Arguments]  ${add_object}=${add_all_pcmd}
    ${add_str}   Convert To String   ${add_object}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Update actInactDetNSAUe
    [Arguments]   ${actInactDetNSAUe_expect_value}=false   ${nsaInactivityTimer_expect_value}=1
    COAM Update Parameter   dist_name=${INSID}   parameter=actInactDetNSAUe   value=${actInactDetNSAUe_expect_value}
    COAM Update Parameter   dist_name=${INSID}   parameter=nsaInactivityTimer   value=${nsaInactivityTimer_expect_value}

COAM Update SERVEDAMF administrativeState
    [Arguments]   ${administrativeState_expect_value}=Unlocked
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    COAM Update Parameter   dist_name=${INSID}/SERVEDAMF-1   parameter=administrativeState   value=${administrativeState_expect_value}

COAM Update absThreshSsbRsrpConsolidation
    [Arguments]   ${absThreshSsbRsrpConsolidation_expect_value}=0
    COAM Update Parameter   dist_name=${INSID}/NRCELL-1   parameter=absThreshSsbRsrpConsolidation
    ...   value=${absThreshSsbRsrpConsolidation_expect_value}

