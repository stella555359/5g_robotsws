*** Settings ***
Documentation
...  author: Heng Liangliang
...  contact: liangliang.heng@nokia-sbell.com   lei.nie@nokia-sbell.com

Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Resource    ../../UUF/Resource/common.robot
Library     ../../libraries/nms_vars.py
Resource    ../../5GI000114/Resource/NetAct_common.robot
Resource    ../../5GI000114/CaseResource/CM_Activating_configuration_changes_with_Send_To_Network.robot

*** Variables ***
${BTSID}    MRBTS-${tl.gnbs[0].instance_id}
${INSID}   ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${NA_EXPORT_DIR}=           /var/opt/oss/global/racops/export
${NA_IMPORT_DIR}=           /var/opt/oss/global/racops/import
${LOCAL_TMP_DIR}=           /tmp
${VALIDATION}=              True
${NetAct_NODE}=           10.108.248.82
*** Keywords ***
Integrate NE to NetAct and CM Upload
    ${active_sw_version}   ${passive_sw_version}   wait until keyword succeeds   3 min   30 s
     ...   gnb_handler.get_sw_version_by_ssh   gnb_ip=${LMP_ADDR}   format=full
    ${netact_nodeip}   Set Variable    ${NetAct_NODE}
    Integrating NE to NetAct Case Setup For 1756  current_version=${active_sw_version}  netact_nodeip=${netact_nodeip}
    Integrating NE to NetAct For 1756
    [Teardown]  Integrating NE to NetAct Case Teardown For 1756

Integrating NE to NetAct Case Setup For 1756
    [Arguments]     ${current_version}   ${netact_nodeip}
    ${NetAct_info}    Set Variable   ${netact_global_configuration}[${netact_nodeip}]
    ${lab_name}   Set Variable   ${NetAct_info['name']}
    ${MRC_name}   Set Variable   ${LAB_INFO['${lab_name}']['MRC']}
    ${MR_name}   Set Variable    ${LAB_INFO['${lab_name}']['MR']}
    ${MR_NEIW}   Set Variable    MRC-${MRC_name}/MR-${MR_name}
    ${OMC_USER}  Set Variable    ${NetAct_info['ssh_username']}
    ${OMC_PASS}  Set Variable    ${NetAct_info['ssh_password']}
    run keyword and ignore error  selenium_sbts.enable_virtual_display
    IPV6 no proxy setting   ip_addr=${LMP_ADDR}
    Set Global Lab Information    lab_name=${lab_name}
    ${NE_TYPE}   set variable   COAM
    ${NE_release}   Catch build release   ${current_version}
    ${common_build_type}   Run Keyword And Return Status   should contain   ${NE_release}  SBTS
    ${release}  Run keyword if  ${common_build_type} == False  set variable  ${NE_release}CLA
    ...  ELSE  set variable  ${NE_release}
    set suite variable  ${netact_nodeip}
    set suite variable  ${release}
    set suite variable  ${NE_TYPE}
    set suite variable  ${MR_NEIW}
    set suite variable  ${OMC_USER}
    set suite variable  ${OMC_PASS}
#    set suite variable  ${MO_NAME}   ${bts_id}
    #Above" set suite variable  ${MO_NAME}   MRBTS-${bts_id}" will be removed
    run keyword if  '${NE_TYPE}'=='COAM'   COAM Get Info of WebUI for Integration   file_name=${file_name}
    ...   ELSE   Get Info of WebUI for Integration

COAM Get Info of WebUI for Integration
    [Arguments]   ${file_name}=old_commission.xml
    ${connection}   wait until keyword succeeds  5min   1min   coam.connect_to   bts_host=${WEBUI_ADDR}   name=COAM
    COAM Backup SCF   local_dir=${OUTPUT_DIR}   file_name=${file_name}   connection=COAM
    ${XML}   xml.parse xml   ${OUTPUT_DIR}/${file_name}
    ${distname}   xml.get element attribute   ${XML}   distName    xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    ${btsid}   should match regexp   ${distname}   \\d+
    set suite variable  ${MO_NAME}   MRBTS-${bts_id}
    ${oam_tls_status}   xml.get element text   ${XML}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"]
    run keyword if    '${oam_tls_status}'=='off'    Set Suite Variable    ${NE3SWS_mode}    no${SPACE}TLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS
    run keyword if    '${release}'>='SBTS22R3' and '${oam_tls_status}'=='off'  Set Suite Variable    ${NE3SWS_mode}    Non_TLS
    ${status_ip}=    run keyword and return status    should contain    ${oam_addr}    :
    run keyword if    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    [Teardown]   run keyword and ignore error  coam.teardown   connection=${connection}

Get Info of WebUI for Integration
    wait until keyword succeeds  5mins   10s   selenium_coam.login
    ...   url=https://${WEBUI_ADDR}/login.html    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#    ${bts_id}=    selenium_coam.get_text_parameter_value    dist_name=mrbtsid    abbr=mrbtsId
    set suite variable  ${MO_NAME}   MRBTS-${bts_id}
#    ${oam_tls_status}=    selenium_coam.get_list_parameter_value    dist_name=TLS usage    abbr=oamTls
    run keyword if    '${oam_tls_status}'=='off'    Set Suite Variable    ${NE3SWS_mode}    no${SPACE}TLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS
    run keyword if    '${release}'=='SBTS22R3' and '${oam_tls_status}'=='off'  Set Suite Variable    ${NE3SWS_mode}    Non_TLS
    ${status_ip}=    run keyword and return status    should contain    ${oam_addr}    :
    run keyword if    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    [Teardown]  Run Keyword And Ignore Error    selenium_coam.Logout

Integrating NE to NetAct For 1756
    run keyword and ignore error  Renew Registrations on NE3SWS Network Element
    Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${false}
    Integrating_NE_to_NetAct.Integrate NE via NEIW   DN=${DN}   Adminstration_folder=${Adminstration_folder}   NEIW_position=${NEIW_position}
    ...   NE_Type=${NEIW_NE_Type}   release=${release}   MR=${MR_NEIW}   IP=${IP}
    ...   NE3SWS_IPversion=${NE3SWS_IPversion}   NE3SWS_mode=${NE3SWS_mode}
    sleep   10s
    CM Upload in Backend ENV

Integrating NE to NetAct Case Teardown For 1756
    run keyword and ignore error  selenium_sbts.disable_virtual_display
    run keyword and ignore error   selenium_netact.Logout

Activated And Configured PCMD By NetAct
     Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
     Step1: Open CM Editor In Send To Network
     Step2: Expand Actual Configuration And Click Tree Node For 1756
     Step3: Modify Table Value And CM Send To Network For 1756
     run keyword and ignore error   selenium_netact.Logout
     Configure PCMD MO By NetAct Backend ENV



Activated And Configured PCMD By NetAct For CB008196
     run keyword and ignore error  selenium_sbts.enable_virtual_display
     Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
     Step1: Open CM Editor In Send To Network
     Step2: Expand Actual Configuration And Click Tree Node For 8196
     Step3: Modify Table Value And CM Send To Network For 8196
     run keyword and ignore error   selenium_netact.Logout
     run keyword and ignore error  selenium_sbts.disable_virtual_display
     #Configure PCMD MO By NetAct Backend ENV

Deactivated And Configured PCMD By NetAct For CB008196
     run keyword and ignore error  selenium_sbts.enable_virtual_display
     Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
     Step1: Open CM Editor In Send To Network
     Step2: Expand Actual Configuration And Click Tree Node For 8196
     #Step3: Modify Table Value And CM Send To Network For 8196
     Step3: Modify Table Value And CM Send To Network For 8196_2
     run keyword and ignore error   selenium_netact.Logout
     run keyword and ignore error  selenium_sbts.disable_virtual_display

Step2: Expand Actual Configuration And Click Tree Node For 8196
    Select Main Window
    ${TREE_PATH}    CM Get Tree Path For 1756   tree_name=navigationTree   tree_path_header=Actual Configuration|PLMN-PLMN
    #Set Test Variable   ${TREE_PATH}    ${TREE_PATH}|${MO_NAME} ${MO_NAME}
    Set Test Variable   ${TREE_PATH}    ${TREE_PATH}|${MO_NAME}
    Log To Console   ${TREE_PATH}
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${TREE_PATH}|${NRBTS}
    ...   component_name=${table_name}

Step3: Modify Table Value And CM Send To Network For 8196
    Check Check Box   identifier=parameters.by.actual.view.modify
#    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
#    ...   table_name=${table_name}   search_key=Parameter   search_value=Activate PCMD report   target_key=Actual value
    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
    ...   table_name=${table_name}   search_key=Parameter   search_value=Activate cell trace report   target_key=Actual value
#    Run keyword if  '${ORIGIN_PARA}' == 'true'   Set Test Variable   ${EDITED_PARA}   false
#    ...  ELSE   Set Test Variable   ${EDITED_PARA}   true
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=true

    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
    ...   table_name=${table_name}   search_key=Parameter   search_value=Activate PCMD report   target_key=Actual value
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=true


#    Set Test Variable   ${ROW}
#    Set Test Variable   ${COLUMN}
#    Set Test Variable   ${ORIGIN_PARA}
    Execute Send To Network And Verify The Status For 8196   tree_path=${TREE_PATH}|${NRBTS}   mo_name=${MO_NAME}
    Sleep   5s

Step3: Modify Table Value And CM Send To Network For 8196_2
    Check Check Box   identifier=parameters.by.actual.view.modify

    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
    ...   table_name=${table_name}   search_key=Parameter   search_value=Activate cell trace report   target_key=Actual value
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=false

    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
    ...   table_name=${table_name}   search_key=Parameter   search_value=Activate PCMD report   target_key=Actual value
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=false


    Execute Send To Network And Verify The Status For 8196   tree_path=${TREE_PATH}|${NRBTS}   mo_name=${MO_NAME}
    Sleep   5s



Execute Send To Network And Verify The Status For 8196
    [Arguments]   ${tree_path}   ${mo_name}
    Click On Tree Node   navigationTree   ${tree_path}   \#0
    Select From Popup Menu On Selected Tree Nodes   identifier=navigationTree   menuPath=Send to Network
    Select Dialog   identifier=CM Editor
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=OK
#    Wait Until Keyword Succeeds   3 times   10s
#    ...   swing.Select Window   identifier=Provision - Activate: Finished - Modify ${NRBTS} in ${mo_name} ${mo_name}
#    Wait Until Keyword Succeeds   3 times   10s
#    ...   swing.Select Window   identifier=Provision - Activate: Finished - Modify ${NRBTS} in ${mo_name}
#
#    Sleep   5s
#    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Close


Deactivated PCMD by NetAct
     Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
     Step1: Open CM Editor In Send To Network
     Step2: Expand Actual Configuration And Click Tree Node For 1756
     Step3: Modify Table Value And CM Send To Network For 1756
     [Teardown]  run keyword and ignore error   selenium_netact.Logout

Step2: Expand Actual Configuration And Click Tree Node For 1756
    Select Main Window
    ${TREE_PATH}    CM Get Tree Path For 1756   tree_name=navigationTree   tree_path_header=Actual Configuration|PLMN-PLMN
    Set Test Variable   ${TREE_PATH}    ${TREE_PATH}|${MO_NAME} ${MO_NAME}
    Log To Console   ${TREE_PATH}
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${TREE_PATH}|${NRBTS}
    ...   component_name=${table_name}

CM Get Tree Path For 1756
    [Arguments]   ${tree_name}   ${tree_path_header}
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${tree_path_header}
    ...   component_name=${tree_name}
    Sleep   5s
    @{child_list}   Get Tree Node Child Names   ${tree_name}     ${tree_path_header}
    Return From Keyword If   '${MO_NAME} ${MO_NAME}' in ${child_list}   ${tree_path_header}|${MO_NAME} ${MO_NAME}
    FOR   ${folder_name}   IN   @{child_list}
       Continue For Loop If   "${folder_name.find('MRBTS')}"=="-1"
       ${folder_name}   Strip String   ${folder_name}
       @{range}   Split String   ${folder_name}   -
       @{range}   Split String   ${range[-1]}   ...
       Return From Keyword If   ${MRBTS_ID} >=${range[0]} and ${MRBTS_ID} <=${range[1]}   ${tree_path_header}|${folder_name}
    END

Step3: Modify Table Value And CM Send To Network For 1756
    Check Check Box   identifier=parameters.by.actual.view.modify
    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
    ...   table_name=${table_name}   search_key=Parameter   search_value=Activate PCMD report   target_key=Actual value
    Run keyword if  '${ORIGIN_PARA}' == 'true'   Set Test Variable   ${EDITED_PARA}   false
    ...  ELSE   Set Test Variable   ${EDITED_PARA}   true
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=${EDITED_PARA}
    Set Test Variable   ${ROW}
    Set Test Variable   ${COLUMN}
    Set Test Variable   ${ORIGIN_PARA}
    Execute Send To Network And Verify The Status For 1756   tree_path=${TREE_PATH}|${NRBTS}   mo_name=${MO_NAME}
    Sleep   5s

Execute Send To Network And Verify The Status For 1756
    [Arguments]   ${tree_path}   ${mo_name}
    Click On Tree Node   navigationTree   ${tree_path}   \#0
    Select From Popup Menu On Selected Tree Nodes   identifier=navigationTree   menuPath=Send to Network
    Select Dialog   identifier=CM Editor
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=OK
    Wait Until Keyword Succeeds   3 times   10s
    ...   swing.Select Window   identifier=Provision - Activate: Finished - Modify ${NRBTS} in ${mo_name} ${mo_name}
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Close

Configure PCMD MO By NetAct Backend ENV
    ${gnb_release}   Get gnb release
    ${list_params}=  Prepare list of modifications By NetAct Backend ENV   gNB_release=${gnb_release}
    Add PCMD Parameters By NetAct Backend ENV   ${BTSID}     ${list_params}

Prepare list of modifications By NetAct Backend ENV
    [Arguments]   ${tceIpAddress}=10.57.157.163   ${gNB_release}=SBTS22R2
    Log to console         Prepare list of modifications
    ${list_line1}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tceIpAddress            ${tceIpAddress}
    ${list_line2}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tcePortNumber           49148
    ${list_line3}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tceIdentifier             1
    ${list_line4}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tlsEnabled              false
    ${list_line30}=        create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   certTypeForTlsAuth      RSA
    ${list_line5}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   actCellTraceReportingCU   false
    ${list_line6}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   actPCMDReporting          true
    ${list_line7}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   cellMaxActiveUEsTraced    100
    ${list_line8}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   jobType                   TraceOnly
    ${list_line9}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   nrMtraceCuId              1
    ${list_line10}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   mcc           ${mcc}
    ${list_line11}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   mnc           ${mnc_inital}
    ${list_line12}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   mncLength     ${mnc_length}
    ${list_line13}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   traceId       ${MRBTS_ID}
    ${list_line14}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   nrTceIdentifier           1
    ${list_line15}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   scope                     allResources
    ${list_line16}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceNGAPSetting          none
    ${list_line17}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceNRRRCSetting         none
    ${list_line18}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceX2Setting            none
    ${list_line19}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceXNSetting            none
    ${list_line20}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   actPCMDReporting          true
    ${list_line21}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   cellMaxActiveUEsTraced    100
    ${list_line22}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   jobType                   TraceOnly
    ${list_line23}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   nrMtraceDuId              1
    ${list_line24}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   mcc           ${mcc}
    ${list_line25}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   mnc           ${mnc_inital}
    ${list_line26}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   mncLength     ${mnc_length}
    ${list_line27}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   traceId       ${MRBTS_ID}
    ${list_line28}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   nrTceIdentifier       1
    ${list_line29}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   scope           allResources
    ${list_params}=        run keyword if   '${gNB_release}'<'SBTS22R4'   create list
    ...                                 ${list_line1}    ${list_line2}   ${list_line3}   ${list_line4}    ${list_line5}    ${list_line6}
    ...                                 ${list_line7}    ${list_line8}   ${list_line9}   ${list_line10}   ${list_line11}   ${list_line12}
    ...                                  ${list_line13}   ${list_line14}   ${list_line15}   ${list_line16}   ${list_line17}   ${list_line18}
    ...                                  ${list_line19}   ${list_line20}   ${list_line21}   ${list_line22}   ${list_line23}   ${list_line24}
    ...                                 ${list_line25}   ${list_line26}   ${list_line27}   ${list_line28}  ${list_line29}
    ...   ELSE   create list       ${list_line30}   ${list_line1}    ${list_line2}   ${list_line3}   ${list_line4}   ${list_line5}    ${list_line6}
    ...                                 ${list_line7}    ${list_line8}   ${list_line9}   ${list_line10}   ${list_line11}   ${list_line12}
    ...                                  ${list_line13}   ${list_line14}   ${list_line15}   ${list_line16}   ${list_line17}   ${list_line18}
    ...                                  ${list_line19}   ${list_line20}   ${list_line21}   ${list_line22}   ${list_line23}   ${list_line24}
    ...                                 ${list_line25}   ${list_line26}   ${list_line27}   ${list_line28}  ${list_line29}
    Return from Keyword    ${list_params}

Add PCMD Parameters By NetAct Backend ENV
    [Timeout]           10 minutes
    [Arguments]         ${BTSID}   ${list_parameters}      ${check_error}=True

    ${timestamp} =   Compute TimeStamp
    ${old_plan_file}=           Set Variable    exported_${timestamp}.xml
    ${new_plan_file}=           Set Variable    modified_${timestamp}.xml
    ${changed_plan_name}=       Set Variable    robot_set_${timestamp}
    ${delta_plan_name}=         Set Variable    robot_delta_${timestamp}
    # ${backup_plan_name}=        Set Variable    robot_backup_${timestamp}

    CM Export By NetAct Backend ENV    ${BTSID}  ${LOCAL_TMP_DIR}  ${old_plan_file}    ALL_MOCS    true
    Add Parameters By NetAct Backend ENV
			    ...	    ${list_parameters}
                            ...     ${LOCAL_TMP_DIR}/${old_plan_file}
                            ...     ${LOCAL_TMP_DIR}/${new_plan_file}
    CM Import By NetAct Backend ENV      ${LOCAL_TMP_DIR}  ${new_plan_file}  ${changed_plan_name}  UIValues=true   USE_OBJECT_OPERATION=false
    Log to console          ${changed_plan_name} imported
    Prepare Delta Plan By NetAct Backend ENV      ${changed_plan_name}    ${delta_plan_name}
    Log to console          ${delta_plan_name} delta plan to provision
    ${stdout_provision}=    Provision Plan By NetAct Backend ENV          ${delta_plan_name}      check_error=${check_error}
        # ...                     create_backup_plan=true        backup_plan_name=${backup_plan_name}
        # Remove Plan             ${delta_plan_name}

CM Export By NetAct Backend ENV
     [Documentation]     Run Export Actual Configuration in NetAct for specified dist_name and save actual configuration to OUTPUT_FILE
                ...         - ${dist_name} - distinguish name of managed object to be exported (without PLMN)
                ...         - ${LOCAL_DIR}
                ...         - ${OUTPUT_FILE}
                ...         - ${CLASS_FILTER} - A comma separated string of MOCs to be exported, e.g. LNBTS,LNCEL. By default all MOCs are exported.
                ...         - ${UI_VALUES} - false (by default) or true

     [Timeout]           15 minutes
     [Arguments]         ${BTSID}    ${LOCAL_DIR}    ${OUTPUT_FILE}    ${CLASS_FILTER}=ALL_MOCS    ${UI_VALUES}=false
     ${EXPORTED_FILE}=    SetVariable    CRT_ROBOT.xml

     ${cmd}=    Set Variable    racclimx.sh -op Import_Export -fileFormat RAML2 -importExportOperation actualExport
     ${cmd}=    Set Variable    ${cmd} -DN PLMN-PLMN/${BTSID} -fileName ${EXPORTED_FILE} -UIValues ${UI_VALUES} -v
     ${cmd}=    Set Variable If    '${CLASS_FILTER}'!='ALL_MOCS'   ${cmd} -classFilter ${CLASS_FILTER}   ${cmd}
     ${expect_output}=    set variable       Status received: Finished
     csn.connect_to    hostname=${netact_nodeip}
     ...   username=${OMC_USER}    password=${OMC_PASS}    alias=WasNode   timeout=60
     ${output}=   csn.execute   command=${cmd}   connection=WasNode   timeout=300
     run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
     # Should Contain    ${stdout}    Export finished
     # Log to Console       *** Status CM Export = ${stdout}
     ${Status}=    Run Keyword And Return Status
                   ...    csn.Download File
                   ...    remote_path=${NA_EXPORT_DIR}/${EXPORTED_FILE}
                   ...    local_path=${LOCAL_DIR}/${OUTPUT_FILE}
                   ...    connection=WasNode
     ${remove_file_cmd}=    Set Variable    rm -f ${NA_EXPORT_DIR}/${EXPORTED_FILE}
     ${output}=   csn.execute   command=${remove_file_cmd}   connection=WasNode   timeout=300
     Run Keyword If  ${Status}==False  Fail  Cannot get plan file
     ${Status}=  Run Keyword And Return Status
                  ...  OperatingSystem.File Should Not Be Empty  ${LOCAL_DIR}/${OUTPUT_FILE}
     run keyword and ignore error  csn.disconnect    connection=WasNode
     Run Keyword If  ${Status}==False  Fail  Local plan file is empty
     ${content}=   Grep File    ${LOCAL_DIR}/${OUTPUT_FILE}    <p name=
     ${size}=     Get Length    ${content}
     Run Keyword If    ${size}==0    Fail  Exported file has no param inside

CM Import By NetAct Backend ENV
    [Documentation]     Import plan given as ${INPUT_FILE} located in ${LOCAL_DIR} as Netact plan name=${PLAN_NAME}
               ...      NA CLI Command: ``racclimx.sh -op Import_Export -fileFormat RAML2 -importExportOperation planImport
               ...      -fileName ${INPUT_FILE} -planName ${PLAN_NAME} -UIValues ${UIValues} -v -useObjectOperationDefinedInImportFile true ``
               ...          - ${LOCAL_DIR} - directory where plan file is stored on local mashine
               ...          - ${INPUT_FILE} - plan file
               ...          - ${PLAN_NAME} - name of newly created plan in Netact
               ...          - ${UIValues} :
               ...                           - true  - UI Values are used in plan file
               ...                           - false - internal values are used in plan file
               ...                           - (default value = false)
               ...          - ${USE_OBJECT_OPERATION} :
               ...                           - true  - Object operation taken from plan
               ...                           - false - Object operation taken care by NetAct
               ...                           - (default value = true)
               ...          - ${skip_existing}:
               ...                           - True  - Existing objects are not overwritten in import
               ...                           - False - Existing objects are overwritten in import
               ...                           - (default value = False)
               ...      Returns as string standard output (stdout) from operation's execution.
               ...      Timeout for this keyword is set to 5 minutes.
    [Timeout]           15 minutes
    [Arguments]     ${LOCAL_DIR}    ${INPUT_FILE}    ${PLAN_NAME}    ${UIValues}=false    ${USE_OBJECT_OPERATION}=true    ${skip_existing}=False
     csn.connect_to    hostname=${netact_nodeip}
     ...   username=${OMC_USER}    password=${OMC_PASS}    alias=WasNode   timeout=60
#     SSHLibrary.Switch Connection  ${NA_CONNECTION}
#    Remove Plan     ${PLAN_NAME}
     csn.Upload File   local_path=${LOCAL_DIR}/${INPUT_FILE}   remote_path=${NA_IMPORT_DIR}/${INPUT_FILE}  connection=WasNode
#    SSHLibrary.Put File    ${LOCAL_DIR}/${INPUT_FILE}    ${NA_IMPORT_DIR}/${INPUT_FILE}
     csn.File Exists    remote_path=${NA_IMPORT_DIR}/${INPUT_FILE}     connection=WasNode
#    SSHLibrary.File Should Exist    ${NA_IMPORT_DIR}/${INPUT_FILE}
     ${cmd}=    Set Variable    racclimx.sh -op Import_Export -fileFormat RAML2 -importExportOperation planImport
     ${cmd}=    Set Variable    ${cmd} -fileName ${INPUT_FILE} -planName ${PLAN_NAME} -UIValues ${UIValues}
     ${cmd}=    Set Variable    ${cmd} -useObjectOperationDefinedInImportFile ${USE_OBJECT_OPERATION} -v -setSystemTemplate false
     ${cmd}=    Set Variable If    ${skip_existing}    ${cmd} -skipExisting true   ${cmd}
#     ${stdout}  ${stderr}  ${rc}    Exec NA CLI Command    ${cmd}
     ${expect_output}=    Set Variable     Status received: Finished
     ${output}   csn.execute   command=${cmd}   connection=WasNode   timeout=300
     run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
     ${remove_file_cmd}=    Set Variable    rm ${NA_IMPORT_DIR}/${INPUT_FILE}
     ${stdout}   csn.execute   command=${remove_file_cmd}   connection=WasNode   timeout=300
     run keyword and ignore error  csn.disconnect    connection=WasNode
     # Should Not Contain  ${stdout}  failed
      # does not fully work on our NA !!!   Should Contain    ${stdout}    0 object(s) failed
    # ! EXPERIMENTAL RETURN - MAY NOT WORK PROPERLY  - ADDED BY MF!
    [Return]    ${stdout}

Prepare Delta Plan By NetAct Backend ENV
    [Documentation]     Make delta from given plan name and save it as ${DELTA_PLAN_NAME} in Netact
               ...      NA Command:
               ...          ``racclimx.sh -op Compare -planName ${NA_PLAN_NAME} -deltaPlanName ${DELTA_PLAN_NAME} -v``
               ...      Timeout is set to 300 seconds.
    [Arguments]         ${NA_PLAN_NAME}  ${DELTA_PLAN_NAME}
    [Timeout]           300s

#    Remove Plan     ${DELTA_PLAN_NAME}
     ${cmd}=    set variable   racclimx.sh -op Compare -planName ${NA_PLAN_NAME} -deltaPlanName ${DELTA_PLAN_NAME} -v
#    ${stdout}  ${stderr}  ${rc}
#    ...  Exec NA CLI Command  racclimx.sh -op Compare -planName ${NA_PLAN_NAME} -deltaPlanName ${DELTA_PLAN_NAME} -v
     csn.connect_to    hostname=${netact_nodeip}
     ...   username=${OMC_USER}    password=${OMC_PASS}    alias=WasNode   timeout=60
     ${output}=   csn.execute   command=${cmd}   connection=WasNode   timeout=300
     ${expect_output}=    Set Variable     Status received: Finished
     run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
#    Remove Plan     ${NA_PLAN_NAME}
     ${remove_plan_cmd}=    set variable  racclimx.sh -op planDeletion -planName ${NA_PLAN_NAME} -v
     Run Keyword And Ignore Error
     ...  csn.execute   command=${remove_plan_cmd}  connection=WasNode   timeout=300
     run keyword and ignore error  csn.disconnect    connection=WasNode


Add Parameters By NetAct Backend ENV
    [Documentation]     Add parameters (and associated MO/list/item if missing) from a given XML.
    [Timeout]           30s
	[Arguments] 	${list_params}	${input_xml}	${output_xml}
	${root}=	XML.Parse XML	${input_xml}
	FOR	${param}	IN	@{list_params}
		${MO}=	set variable	${param[0]}
		${mo_xpath}=	set variable	//managedObject[@distName="${MO}"]
		${exist}=	run keyword and return status	XML.Element Should Exist	${root}	 xpath=${mo_xpath}
		run keyword if	${exist}	XML.Set Element Attribute	${root}	  operation	update	 ${mo_xpath}
       Set Suite Variable      ${g_level_MO}   0
       run keyword if  not ${exist}    create MO_0     ${root}    ${MO}
    END
    FOR	${param}	IN	@{list_params}
		${list}=	set variable	${param[1]}
		Continue For Loop If	'${list}' == 'None'
		${MO}=	set variable	${param[0]}
		${list_path}=	set variable	//managedObject[@distName="${MO}"]/list[@name="${list}"]
		${exist}=	run keyword and return status	XML.Element Should Exist	${root}	 xpath=${list_path}
		Continue For Loop If	${exist}
		XML.add element		${root}		<list name="${list}"/>	 xpath=//managedObject[@distName="${MO}"]
    END
	FOR	${param}	IN	@{list_params}
		${list}=	set variable	${param[1]}
		Continue For Loop If	'${list}' == 'None'
		${item}=	set variable	${param[2]}
		${MO}=	set variable	${param[0]}
		${list_path}=	set variable	//managedObject[@distName="${MO}"]/list[@name="${list}"]
		${exist}=	run keyword and return status	XML.Element Should Exist	${root}	 xpath=(${list_path}/item)[${item}]
		Continue For Loop If	${exist}
		XML.add element		${root}		<item/>	 xpath=//managedObject[@distName="${MO}"]/list[@name="${list}"]
    END
	FOR	${param}	IN	@{list_params}
		${MO}=		set variable	${param[0]}
		${list}=	set variable	${param[1]}
		${item}=	set variable	${param[2]}
		${name}=	set variable	${param[3]}
		${value}=	set variable	${param[4]}
		${path}=	set variable	//managedObject[@distName="${MO}"]
		${path}=	set variable if	  '${list}' == 'None'	${path}
		...		${path}/list[@name="${list}"]/item[${item}]
		${exist}=	run keyword and return status	XML.Element Should exist	${root}		xpath=${path}/p[@name="${name}"]
		run keyword if	 ${exist}	XML.Set Element Text	${root}	  text=${value}	  xpath=${path}/p[@name="${name}"]
		...	ELSE			XML.Add Element		${root}	   <p name="${name}">${value}</p>	xpath=${path}
    END
	XML.save XML	${root}		${output_xml}

create MO_0
    [Arguments]     ${root}   ${MO}

    ${class}=       fetch from right        ${MO}   /
    ${father}=      fetch from left         ${MO}   /${class}
    ${class}=       fetch from left         ${class}        -
    ${exist}=       run keyword and return status   XML.element should exist        ${root}    xpath=//managedObject[@distName="${father}"]
    ${level_MO}=    evaluate        ${g_level_MO}+1
    Set Suite variable      ${g_level_MO}     ${level_MO}
    run keyword if    not ${exist}    create MO_${g_level_MO}         ${root}         ${father}

    ${version}=     XML.get element attribute       ${root}   version         xpath=//managedObject[@distName="${father}"]
    XML.add element         ${root}         <managedObject distName="${MO}" class="${class}" version="${version}" operation="update"/>
    ...    xpath=//cmData

create MO_1
        [Arguments]     ${root}   ${MO}

        ${class}=       fetch from right        ${MO}   /
        ${father}=      fetch from left         ${MO}   /${class}
        ${class}=       fetch from left         ${class}        -
        ${exist}=       run keyword and return status   XML.element should exist        ${root}    xpath=//managedObject[@distName="${father}"]
        ${level_MO}=    evaluate        ${g_level_MO}+1
        Set Suite variable      ${g_level_MO}    ${level_MO}
        run keyword if    not ${exist}    create MO_${g_level_MO}         ${root}         ${father}

        ${version}=     XML.get element attribute       ${root}   version         xpath=//managedObject[@distName="${father}"]
        XML.add element         ${root}         <managedObject distName="${MO}" class="${class}" version="${version}" operation="update"/>
        ...    xpath=//cmData

Provision Plan By NetAct Backend ENV
    [Documentation]     Provision plan with given name as argument.
               ...      NA Command:
               ...          ``racclimx.sh -op Provision -planName ${NA_PLAN_NAME} -v``
               ...      Returns as string standard output (stdout) from operation's execution.
               ...      Keyword timeut is set to 15 minutes.

    [Arguments]         ${NA_PLAN_NAME}
                        ...     ${return_stdout_on_failure}=False
                        ...     ${provisioning_operation}=activate
                        ...     ${validate}=${VALIDATION}
                        ...     ${create_backup_plan}=false
                        ...     ${backup_plan_name}=None
                        ...     ${check_error}=True
    [Timeout]           20 minutes
            ${cmd}=   set variable    racclimx.sh -op Provision -planName ${NA_PLAN_NAME} -backupPlanName ${backup_plan_name}
            ${cmd}=   set variable    ${cmd} -provisioningOperation ${provisioning_operation} -createBackupPlan ${create_backup_plan} -v

            ${cmd_no_val}=   set variable    racclimx.sh -op Provision -planName ${NA_PLAN_NAME} -validateBeforePreactivationForLTE false
            ${cmd_no_val}=   set variable    ${cmd_no_val} -provisioningOperation ${provisioning_operation}
            ${cmd_no_val}=   set variable    ${cmd_no_val} -createBackupPlan ${create_backup_plan} -backupPlanName ${backup_plan_name} -v


            csn.connect_to    hostname=${netact_nodeip}
                        ...   username=${OMC_USER}    password=${OMC_PASS}    alias=WasNode   timeout=60
            csn.execute   command=${cmd}   connection=WasNode   timeout=300
            ${stdout}   Run Keyword if  "${validate}"=="True"   csn.execute   command=${cmd}   connection=WasNode   timeout=300
            ...  ELSE   csn.execute   command=${cmd_no_val}   connection=WasNode   timeout=300
            run keyword and ignore error  csn.disconnect    connection=WasNode
    [Return]    ${stdout}

Compute TimeStamp
     ${date} =   DateTime.Get Current Date    exclude_millis=True
     ${date} =   Replace String      ${date}         ${SPACE}    _
     ${date} =   Replace String      ${date}         -           ${EMPTY}
     ${date} =   Replace String      ${date}         :           ${EMPTY}
     [Return]   ${date}

Verify Trace Result
    [Arguments]  ${expected_text}
    ${text}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text
    ...   //*[@id="trace-session-details-table-actions-header-0"]/div[4]/div
    should be equal   ${text}   ${expected_text}

Activate PCMD Configuration From NetAct Trace Expert
    [Arguments]  ${traceNanme}   ${BTS_MO}   ${profile_name}   ${NetAct_url}=${START_PAGE}   ${username}=${OMC_USER}   ${password}=${OMC_PASS}
    log to console   Activate PCMD Configuration From NetAct Trace Expert
    run keyword and ignore error  selenium_sbts.enable_virtual_display
    wait until keyword succeeds  5 times   15s   Open Netact Start Page
    ...   url=${NetAct_url}    username=${username}    password=${password}    showall=${false}
    wait until keyword succeeds  5 times   5s   selenium_netact.switch_to_page   page_name=Start Page
    selenium_netact.open_sub_page    category_xpath=//*[@id="calypso-container"]/div[2]/div/a[3]
    ...   page_xpath=//*[@id="calypso-container"]/div[2]/div/a[36]    page_name=Trace Expert
    selenium_netact.wait_for_visibility   //*[@id="title"]
    wait until keyword succeeds  5 times   5s   selenium_netact.write_value
    ...   input_xpath=//*[@id="traceSessionDescription-textInput"]   value=${traceNanme}
    sleep   2s
    wait until keyword succeeds  5 times   5s   selenium_netact.write_value_and_enter
    ...   input_xpath=//*[@id="textInput-textInput"]   value=${profile_name}
    selenium_netact.wait_for_visibility   //*[@class="ag-cell ag-cell-not-inline-editing ag-cell-with-height ag-cell-value"]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button
    ...   //*[@class="ag-cell ag-cell-not-inline-editing ag-cell-with-height ag-cell-value"]
    wait until keyword succeeds  5 times   5s   selenium_netact.write_value
    ...   input_xpath=//*[@id="ScopeSelectorInput"]/div/textarea   value=${BTS_MO}
    wait until keyword succeeds  5 times   5s   selenium_netact.write_value_and_enter
    ...   input_xpath=//*[@id="ScopeSelectorInput"]/div/input   value=${BTS_MO}
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@class="toggle-switch-content"]
    wait until keyword succeeds  5 times   5s   selenium_netact.scroll_element_to_view   //*[@id="okButton-floatingActionBtn-content"]
    wait until keyword succeeds  5 times   5s   selenium_netact.move_to_element   //*[@id="okButton-floatingActionBtn-content"]
#    run keyword and ignore error   selenium_netact.wait_for_enable   //*[@id="okButton-floatingActionBtn-content"]
#    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@id="okButton-floatingActionBtn-content"]
    wait until keyword succeeds  3 times   5s   Click Start Button on Trace Expert
    wait until keyword succeeds  10 min   5s   Verify Trace Result   expected_text=Activation Finished
    [Teardown]  run keywords    Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    ...   AND   run keyword and ignore error   selenium_netact.Logout
    ...   AND   run keyword and ignore error  selenium_sbts.disable_virtual_display

Remove Trace Plan on NetAct Backend
    [Arguments]  ${wasNode_IP}=${netact_nodeip}   ${omc_uername}=${SERVICE_USER}   ${omc_passowrd}=${SERVICE_PASSWORD}
    log to console   Remove Trace Plan on NetAct Backend
    ${command_part1}   set variable   racclimx.sh -op Delete_Plans_Older_Than -scope allPlans
    ${command_part2}   set variable   -includeBackupPlans false -includeTemporaryPlans false -timeUnit minutes -deletePlansOlderThan 30 -v
    ${commond}   set variable   ${command_part1} ${command_part2}
    wait until keyword succeeds  2 times   1min   Connect to NetAct WasNode and execute command   wasNode_IP=${wasNode_IP}
    ...   omc_uername=${omc_uername}   omc_passowrd=${omc_passowrd}  command=${commond}

Deactivation PCMD Configuration From NetAct Trace Expert
    [Arguments]  ${traceName}   ${NetAct_url}=${START_PAGE}   ${username}=${START_PAGE_USER}   ${password}=${START_PAGE_PASSWORD}
    log to console   Deactivation PCMD Configuration From NetAct Trace Expert
    run keyword and ignore error  selenium_sbts.enable_virtual_display
    wait until keyword succeeds  5 times   15s   Open Netact Start Page
    ...   url=${NetAct_url}    username=${username}    password=${password}    showall=${false}
    wait until keyword succeeds  5 times   5s   selenium_netact.switch_to_page   page_name=Start Page
    selenium_netact.open_sub_page    category_xpath=//*[@id="calypso-container"]/div[2]/div/a[3]
    ...   page_xpath=//*[@id="calypso-container"]/div[2]/div/a[36]    page_name=Trace Expert
    selenium_netact.wait_for_visibility   //*[@id="title"]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@id="csfWidgets-banner-appBanner-sideDrawer-menu-1"]
    run keyword and ignore error   selenium_netact.wait_for_visibility   
    ...   //*[@id="csfWidgets-banner-appBanner-main-content-area"]/div/div/div[1]//div//div//div//h1
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@class="search-with-chips__icon-wrapper"]
    selenium_netact.wait_for_visibility   //div//li//div[contains(text(), "Description")]
    wait until keyword succeeds  5 times   5s   selenium_netact.move_to_element   //div//li//div[contains(text(), "Description")]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //div//li//div[contains(text(), "Description")]/..
    wait until keyword succeeds  5 times   5s   selenium_netact.move_to_element   //div//li//div[contains(text(), "Contains (:)")]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //div//li//div[contains(text(), "Contains (:)")]/..
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button
    ...   //div[@class="search-with-chips__items-wrapper"]//div[@data-test="ccfk-multi-inputs__inputs-container"][3]//input
    wait until keyword succeeds  5 times   5s   selenium_netact.write_value_and_enter
    ...   input_xpath=//div[@class="search-with-chips__items-wrapper"]//div[@data-test="ccfk-multi-inputs__inputs-container"][3]//input
    ...   value=${traceName}
    wait until keyword succeeds  5 times   5s   selenium_netact.move_to_element
    ...   //div[@class="search-with-chips__items-wrapper"]//div[@class="csfWidgets list list--with-shadow"]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button
    ...   //div[@class="search-with-chips__items-wrapper"]//div[@class="csfWidgets list list--with-shadow"]
    wait until keyword succeeds  5 times   5s   selenium_netact.move_to_element   //*[@class="app-toolbar__title"]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@class="app-toolbar__title"]
    sleep   5s
    run keyword and ignore error   selenium_netact.wait_for_visibility   //*[@id="trace.errorCode.128"]/div[2]
    sleep   5s
    ${xpath_part1}   set variable   //div[@class="ag-center-cols-clipper"]//div[@class="ag-center-cols-container"]/div[@row-index="0"]
    ${xpath_part2}   set variable   //div[@data-test="ccfk-card"]//div[@data-test="ccfk-card-cardContent"]/div/div/div
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   ${xpath_part1}${xpath_part2}
#    wait until keyword succeeds  5 times   5s   selenium_netact.click_button
#    ...   //div[@class="ag-center-cols-clipper"]//div[@class="ag-center-cols-container"]/div[@row-index="0"]//div[@data-test="ccfk-checkbox"]/../..
    selenium_netact.wait_for_visibility   //*[@id="trace-session-details-table-header-0"]/div[3]/div/span[1]

    wait until keyword succeeds  5 times   5s   selenium_netact.move_to_element   //*[@id="deactivate-content"]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@id="deactivate-content"]

    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@id="deactivationConfirmationDialog-ok-content"]
    wait until keyword succeeds  10min   10s   Verify Trace Result   expected_text=Deactivation Finished
    sleep    10s
    [Teardown]  run keywords    Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    ...   AND   run keyword and ignore error   selenium_netact.Logout
    ...   AND   run keyword and ignore error  selenium_sbts.disable_virtual_display

Get NetAct Info
    Set Suite Variable    ${netact_nodeip}   ${NetAct_NODE}
    ${NetAct_info}    Set Variable   ${netact_global_configuration}[${netact_nodeip}]
    ${lab_name}   Set Variable   ${NetAct_info['name']}
    IPV6 no proxy setting   ip_addr=${LMP_ADDR}
    Set Global Lab Information    lab_name=${lab_name}

Click Start Button on Trace Expert
    run keyword and ignore error   selenium_netact.wait_for_enable   //*[@id="okButton-floatingActionBtn-content"]
    wait until keyword succeeds  5 times   5s   selenium_netact.click_button   //*[@id="okButton-floatingActionBtn-content"]
    selenium_netact.wait_for_visibility   //*[@id="trace-session-details-table-actions-header-0"]/div[4]/div
