*** Settings ***
Documentation
...  author: Heng Liangliang
...  contact: lianbgliang.heng@nokia-sbell.com

Resource   Common.robot

*** Variables ***


*** Keyword ***
COAM Ensure Existence of Basic Trace Object
    ${NRCTRLTS_EXIST}   ${NRSTRACECU_EXIST}   ${TCE2_EXIST}   ${NRMTRACECU_EXIST}   ${TCE1_EXIST}   ${NRCTRLTSDU_EXIST}
    ...  ${TCEADM_EXIST}  ${TCE_EXIST}    Check Trace Related Object Exist
    Run Keyword If   ${NRCTRLTS_EXIST}== False   COAM Add NRCTRLTS
    Run Keyword If   ${TCEADM_EXIST}== False   COAM Add TCEADM

COAM Add NRCTRLTS
    ${add_str}   Convert To String   ${add_nrctrlts}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Add TCEADM
    ${add_str}   Convert To String   ${add_tceadm}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Add TCE
    [Arguments]   ${tce_id}=1
    ${add_tce_only}   Set Variable if   '${tce_id}' == '1'   ${add_tce1}   ${add_tce2}
    ${add_str}   Convert To String   ${add_tce_only}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Add Cell trace and PCMD without TCE
    ${add_str}   Convert To String   ${add_cell_trace_and_pcmd_without_tce}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Add Cell trace and PCMD without TCE for EDA
    [Arguments]   ${release}=SBTS23R3
    ${add_str} =   Run keyword if  '${release}' == 'SBTS23R3'   Convert To String   ${add_cell_trace_and_pcmd_without_tce_23R3}
    ...  ELSE    Convert To String   ${add_cell_trace_and_pcmd_without_tce}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Add PCMD CU DU and Cell Trace
    [Arguments]   ${tce_id}=1
    COAM Add TCE   tce_id=${tce_id}
    ${release}   Get gnb release   host=${WEBUI_ADDR}
    COAM Add Cell trace and PCMD without TCE for EDA    release=${release}
    COAM Update Trace Related Flag for EDA   flag=${true}   trace_type=actCellTraceReport
    COAM Update Trace Related Flag for EDA   flag=${true}   trace_type=actPCMDReport

COAM Remove PCMD CU DU and Cell Trace
    COAM Remove All Trace Object
    COAM Update Trace Related Flag for EDA    flag=${false}   trace_type=actCellTraceReport
    COAM Update Trace Related Flag for EDA    flag=${false}   trace_type=actPCMDReport

COAM Remove NRSTRACE
    ${delete_str}   Convert To String   ${del_nrstracecu}
    ${delete_str}   Set Variable   ${delete_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${delete_str}

COAM Remove All Trace Object
    ${NRCTRLTS_EXIST}   ${NRSTRACECU_EXIST}   ${TCE2_EXIST}   ${NRMTRACECU_EXIST}   ${TCE1_EXIST}   ${NRCTRLTSDU_EXIST}
    ...  ${TCEADM_EXIST}  ${TCE_EXIST}   Check Trace Related Object Exist
    @{del_all_trace}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_trace}   ${del_nrctrlts}
    Run Keyword If   ${NRCTRLTSDU_EXIST}   Append To List   ${del_all_trace}   ${del_nrctrltsdu}
    Run Keyword If   ${TCEADM_EXIST}   Append To List   ${del_all_trace}   ${del_tceadm}
    ${del_str}   Convert To String   ${del_all_trace}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

COAM Remove Subscriber Trace Object
     ${NRCTRLTS_EXIST}   ${NRSTRACECU_EXIST}   ${TCE2_EXIST}   ${NRMTRACECU_EXIST}   ${TCE1_EXIST}   ${NRCTRLTSDU_EXIST}
    ...  ${TCEADM_EXIST}  ${TCE_EXIST}  Check Trace Related Object Exist
    @{del_all_Subscriber}   Create List
    Run Keyword If   ${NRSTRACECU_EXIST}   Append To List   ${del_all_Subscriber}   ${del_nrstracecu}
    Run Keyword If   ${TCE2_EXIST}   Append To List   ${del_all_Subscriber}   ${del_tce}
    ${del_str}   Convert To String   ${del_all_Subscriber}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRSTRACECU_EXIST} or ${TCE_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

COAM Add Trace Related Object
    [Arguments]     ${add_trace_para}=${add_all_subscriber_trace}
#    @{add_str}    Create List
#    Run Keyword If   ${NRCTRLTS_EXIST}=='False'  Append To List  ${add_str}   ${add_str_nrctrlts}
#    Append To List   ${add_str}   ${add_trace_para}
    ${add_str}   Convert To String   ${add_trace_para}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

COAM Update Trace Related Flag
    [Arguments]   ${flag}=true   ${trace_type}=actSubscriberTraceReport
    Run Keyword If   '${flag}'!='false' and '${flag}'!='true'   FAIL   Please Input "true" or "false"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=${trace_type}   value=${flag}

COAM Update Trace Related Flag for EDA
    [Arguments]   ${flag}=true   ${trace_type}=actSubscriberTraceReport
    Run Keyword If   '${flag}'!='False' and '${flag}'!='True'   FAIL   Please Input "True" or "False"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=${trace_type}   value=${flag}

COAM Update TLS Flag for Subscriber Trace
    [Arguments]   ${flag}=false
    Run Keyword If   '${flag}'!='false' and '${flag}'!='true'   FAIL   Please Input "true" or "false"!
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}/NRCTRLTS-1/NRSTRACECU-1   parameter=tlsEnabled   value=${flag}

COAM Check Fault 8000 Exists
    [Arguments]   ${should_exist}=${true}
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${alarm_exists}      Set Variable If   ${should_exist}   Present   Absent
    Run Keyword   Expect Fault Should ${alarm_exists}    faultId=8000   connection=COAM   is_need_to_setup_gnb_connection=${False}

COAM NG HO
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=actIntraNrNgHo   value=sourceAndTarget    connection=COAM
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}/NRCELL-1/NRREL-1    parameter=handoverAllowedSA   value=XnHoNotAllowed    connection=COAM
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    ...   bts_host=${PEER_WEBUI_ADDR}
    ...   username=${PEER_WEBUI_USER}
    ...   password=${PEER_WEBUI_PWD}
    ...   alias=PEER
    COAM Update Parameter   dist_name=${PEER_MRBTS}/${PEER_NRBTS}   parameter=actIntraNrNgHo   value=sourceAndTarget   connection=PEER
    COAM Update Parameter   dist_name=${PEER_MRBTS}/${PEER_NRBTS}/NRCELL-2/NRREL-1   parameter=handoverAllowedSA   value=XnHoNotAllowed
    ...   connection=PEER
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER

COAM Xn HO
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}   parameter=actIntraNrNgHo   value=disabled    connection=COAM
    COAM Update Parameter   dist_name=${MRBTS}/${NRBTS}/NRCELL-1/NRREL-1    parameter=handoverAllowedSA   value=allowed    connection=COAM
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    ...   bts_host=${PEER_WEBUI_ADDR}
    ...   username=${PEER_WEBUI_USER}
    ...   password=${PEER_WEBUI_PWD}
    ...   alias=PEER
    COAM Update Parameter   dist_name=${PEER_MRBTS}/${PEER_NRBTS}   parameter=actIntraNrNgHo   value=disabled   connection=PEER
    COAM Update Parameter   dist_name=${PEER_MRBTS}/${PEER_NRBTS}/NRCELL-2/NRREL-1   parameter=handoverAllowedSA   value=allowed  connection=PEER
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER

Check Trace Related Object Exist
    ${scf_xml}   COAM Get SCF Content
    # COAM Backup Full SCF
    # ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${TCEADM_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    ${NRSTRACECU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRSTRACECU"]
    ${TCE2_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@distName="MRBTS-837/MNL-1/TCEADM-1/TCE-2"]
    ${NRMTRACECU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRMTRACECU"]
    ${TCE1_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@distName="MRBTS-837/MNL-1/TCEADM-1/TCE-1"]
    ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
    ${TCE_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCE"]
    [Return]   ${NRCTRLTS_EXIST}   ${NRSTRACECU_EXIST}   ${TCE2_EXIST}   ${NRMTRACECU_EXIST}   ${TCE1_EXIST}   ${NRCTRLTSDU_EXIST}
    ...  ${TCEADM_EXIST}  ${TCE_EXIST}
