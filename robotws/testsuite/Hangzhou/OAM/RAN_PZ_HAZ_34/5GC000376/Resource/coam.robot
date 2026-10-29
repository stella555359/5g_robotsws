*** Settings ***
Documentation    Author: liangliang.heng@nokia-sbell.com
Resource   ../../common/gnb.robot
Variables   ../libraries/var.py
Library    DateTime

*** Variables ***
${BTSID}                        ${MRBTS}
${INSID}                        ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${OAM_IP}                       ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${remote_path}                  /tmp

*** Keywords ***
Set MRBTS Variables
    [Arguments]   ${gnb_index}=${0}
    Set Test Variable   ${MRBTS_ID}     ${tl.gnbs[${gnb_index}].instance_id}
    Set Test Variable   ${BTSID}     MRBTS-${MRBTS_ID}
    Set Test Variable   ${INSID}     ${BTSID}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}

Remove PCMD Object
    [Documentation]   ${tce_remove} will be added when feature 5GC000376_BB releases
    log to console    Starting ... Remove PCMD Object
    Close Web Startup View Window
    Set PCMD Flag   pcmd_flag=false
    ${cu_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRCTRLTS-1
    ${du_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1
    ${tce_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1
    Run keyword If   ${cu_remove} or ${du_remove} or ${tce_remove}   Validate and Activate Plan

Add PCMD Object
    [Arguments]   ${du_resourceDN}=${INSID}/NRCELL-1   ${radio_resource}=allResources
    Log To Console   starting ... Add PCMD Object ..to.. du_resourceDN='${du_resourceDN}'
    Close Web Startup View Window
    Set PCMD Flag   pcmd_flag=true
    Add PCMD Object of TCE
    selenium_coam.add_object    object_name=${INSID}/NRDU-1    object_class_name=NRCTRLTSDU   id_value=1
    ...   is_load_default_values=${true}
	selenium_coam.add_object   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1    object_class_name=NRMTRACEDU   id_value=1
    ...   is_load_default_values=${true}
	Add PCMD Object of NRMTRACEDU   du_cellMaxActiveUEsTraced=100  du_actPCMDReporting=true   radio_resource=${radio_resource}
	Add PCMD Object of NRMTRACECU   NRCTRLTS=${true}   radio_resource=allResources
    Validate and Activate Plan

Add PCMD Object of NRMTRACEDU
    [Arguments]   ${du_cellMaxActiveUEsTraced}=100   ${du_actPCMDReporting}=true   ${radio_resource}=allResources
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object of NRMTRACEDU' Starting ...
    Close Web Startup View Window
    ${mcc}   selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=MCC in PLMN
    ${mnc}   selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=MNC in PLMN
    ${mnc_length}   selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=MNC length of PLMN ID in primary PLMN of gNB
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...   filter_param=Cell maximum active UE traced
    ...   new_value=${du_cellMaxActiveUEsTraced}
    selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=Job type
	...   new_value=TraceOnly
	selenium_coam.add_element
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference MCC
	...   new_value=${mcc}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference MNC
	...   new_value=${mnc}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference MNC length
	...   new_value=${mnc_length}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference trace Id
	...   new_value=${MRBTS_ID}
    selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=New Radio Trace Collector Entity identifier
	...   new_value=1
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=Activate PCMD reporting
	...   new_value=${du_actPCMDReporting}
	selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=Scope of New Radio Resource
	...   new_value=${radio_resource}
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object of NRMTRACEDU' Finished!

Add PCMD Object of NRMTRACECU
    [Arguments]   ${NRCTRLTS}=${true}   ${radio_resource}=allResources
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object of NRMTRACECU' Starting ...
    Close Web Startup View Window
    ${mcc}   selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=MCC in PLMN
    ${mnc}   selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=MNC in PLMN
    ${mnc_length}   selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=MNC length of PLMN ID in primary PLMN of gNB
    Run Keyword If   ${NRCTRLTS}   selenium_coam.add_object    object_name=${INSID}    object_class_name=NRCTRLTS   id_value=1
    ...   is_load_default_values=${true}
	selenium_coam.add_object   object_name=${INSID}/NRCTRLTS-1    object_class_name=NRMTRACECU   id_value=1   is_load_default_values=${true}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=Activate cell trace reporting for CU
	...   new_value=false
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=Activate PCMD reporting
	...   new_value=true
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=Job type
	...   new_value=TraceOnly
	selenium_coam.add_element
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference MCC
	...   new_value=${mcc}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference MNC
	...   new_value=${mnc}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference MNC length
	...   new_value=${mnc_length}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference trace Id
	...   new_value=${MRBTS_ID}
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=New Radio Trace Collector Entity identifier
	...   new_value=1
	selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=Scope of New Radio Resource
	...   new_value=${radio_resource}
#	selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#	...   filter_param=Trace NGAP setting
#	...   new_value=none
#	selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#	...   filter_param=Trace NRRRC setting
#	...   new_value=none
#	selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#	...   filter_param=Trace X2 setting
#	...   new_value=none
#	selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#	...   filter_param=Trace XN setting
#	...   new_value=none
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object of NRMTRACECU' Finished!

Add PCMD Object of TCE
    [Arguments]   ${c4mn_server_ip}=10.57.195.82   ${c4mn_server_port}=49148
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object of TCE' Starting ...
    Close Web Startup View Window
#    selenium_coam.add_object    object_name=${INSID}/NRCTRLTS-1    object_class_name=NRTCE   id_value=1
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1    object_class_name=TCEADM   id_value=1
    ...   is_load_default_values=${true}
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1    object_class_name=TCE   id_value=1
    ...   is_load_default_values=${true}
    selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRTCE-1
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity ip address
	...   new_value=${c4mn_server_ip}
	selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRTCE-1
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity port number
	...   new_value=${c4mn_server_port}
	selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRTCE-1
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity identifier
	...   new_value=1
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object of TCE' Finished!

Set PCMD Flag
    [Arguments]    ${pcmd_flag}=true
    Close Web Startup View Window
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}
    ...   filter_param=Activate PCMD report
    ...   new_value=${pcmd_flag}

Set PCMD Flag And Activate Plan
    [Arguments]    ${pcmd_flag}=true
    Close Web Startup View Window
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}
    ...   filter_param=Activate PCMD report
    ...   new_value=${pcmd_flag}
    Validate and Activate Plan

Add PCMD Object Without PCMD Flag
    [Arguments]   ${du_resourceDN}=${INSID}/NRCELL-1   ${radio_resource}=allResources
    Log To Console   starting ... Add PCMD Object Without PCMD Flag ..to.. du_resourceDN='${du_resourceDN}'
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object Without PCMD Flag' Starting ...
    Close Web Startup View Window
    Add PCMD Object of TCE
    Close Web Startup View Window
    selenium_coam.add_object    object_name=${INSID}/NRDU-1    object_class_name=NRCTRLTSDU   id_value=1
    ...   is_load_default_values=${true}
	selenium_coam.add_object   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1    object_class_name=NRMTRACEDU   id_value=1
    ...   is_load_default_values=${true}
	Add PCMD Object of NRMTRACEDU   du_cellMaxActiveUEsTraced=100  du_actPCMDReporting=true   radio_resource=${radio_resource}
	Add PCMD Object of NRMTRACECU   NRCTRLTS=${true}   radio_resource=allResources
#	Run Keyword If   '${du_typeNrDu}'=='cell'   Run Keywords   selenium_coam.add_object
#	...   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1    object_class_name=NRRESOURCEDU   id_value=1
#	...   AND   Add Cell Trace Object of NRRESOURCEDU   du_resourceDN=${du_resourceDN}   du_typeNrDu=${du_typeNrDu}
    Validate and Activate Plan
    ${currenttime}    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console   ${currenttime}  'Add PCMD Object Without PCMD Flag' Finished!

Get PCMD Flag
    Close Web Startup View Window
    ${actPCMDReport}     selenium_coam.get_parameter_value   dist_name=${INSID}   filter_param=Activate PCMD report
    [Return]   ${actPCMDReport}

Remove PCMD Object And Set PCMD Flag to false
    [Documentation]   ${tce_remove} will be added when feature 5GC000376_BB releases
    Close Web Startup View Window
    ${result}   Get PCMD Flag
    Run keyword If     '${result}'=='true'     Set PCMD Flag    pcmd_flag=false
    ${cu_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRCTRLTS-1
    ${du_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1
    ${tce_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1
    Run keyword If   ${cu_remove} or ${du_remove} or ${tce_remove} or '${result}'=='true'   Validate and Activate Plan

Validate and Activate Plan
    Log To Console   'Validate and Activate Plan' Starting ...
    Close Web Startup View Window
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300
    Close Web Startup View Window
    Log To Console   'Validate and Activate Plan' Finished!

Validate Plan and Return Error
    [Documentation]   Validate Plan and Report Error
    Close Web Startup View Window
    selenium_coam.validate_plan
    @{errors} =    create list
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    ${validate_errors}    combine lists    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    ${validate_errors_num}    Get Length   ${validate_errors}
    Log to console    The current BTS exist ${validate_errors_num} validate_errors.
    Log to console    defination_errors: ${defination_errors}
    Log to console    relation_errors: ${relation_errors}
    Log to console    hardware_errors: ${hardware_errors}
    [Return]    ${validate_errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}

Close Web Startup View Window
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window

Get Validation Error Before Modify Parameter
    Close Web Startup View Window
    ${errors_num_before}   ${defination_errors_before}   ${relation_errors_before}   ${hardware_errors_before}
    ...   Validate Plan and Return Error
    set suite variable   ${errors_num_before}
    set suite variable   ${defination_errors_before}
    set suite variable   ${relation_errors_before}
    set suite variable   ${hardware_errors_before}

Stop and download Wireshark file on ASIK
   [Arguments]         ${filename}    ${alias}=gNB
   csn.send_command    command= pkill tcpdump    connection=${alias}
   sleep    30
   csn.download_file   ${remote_path}/${filename}    ${Log_directory}/${filename}   connection=${alias}
   csn.send_command    command= rm ${remote_path}/${filename}   connection=${alias}
   run keyword and ignore error    csn.disconnect    connection=${alias}

Get CellIdentity from WebUI
    Close Web Startup View Window
    ${cell_numbers}    Get Cell Number
    ${CellIndentity_pure_num_list}   Set Variable   ${EMPTY}
    FOR  ${idx}    IN RANGE    1    ${cell_numbers}+1
         ${CellIndentity_dec}  selenium_coam.get_parameter_value    dist_name=${INSID}/NRCELL-${idx}   filter_param=NR Cell Identity
         ${CellIndentity_hex}     Evaluate    hex(${CellIndentity_dec})
         ${CellIndentity_end}     Catenate    SEPARATOR=     ${CellIndentity_hex}         0
         ${CellIndentity_pure_num}     Remove String    ${CellIndentity_end}       0x
         ${CellIndentity_length}   Get Length    ${CellIndentity_pure_num}
         ${CellIndentity_0_num}    Evaluate      10-${CellIndentity_length}
         ${CellIndentity_pure_num}     Get Pure Number CllIdentity    ${CellIndentity_0_num}   ${CellIndentity_pure_num}
         ${CellIndentity_pure_num_list}     Catenate   ${CellIndentity_pure_num_list}   ${CellIndentity_pure_num}
    END
    [Return]   ${CellIndentity_pure_num_list}

Get Pure Number CllIdentity
    [Arguments]      ${CellIndentity_0_num}    ${CellIndentity_pure_num}
    FOR   ${idx}    IN RANGE    0    ${CellIndentity_0_num}
          ${CellIndentity_pure_num}     Catenate   SEPARATOR=     0    ${CellIndentity_pure_num}
    END
    [Return]   ${CellIndentity_pure_num}

Check the target cellIdentity
     [Arguments]     ${cellIdentity}      ${pcap_cellIdentity}
     ${cell_numbers}    Get Cell Number
     ${cell_string}   set variable   ${EMPTY}
     FOR   ${idx}    IN RANGE    0   ${cell_numbers}
            @{cellIdengtity_element}    Split String    ${cellIdentity}
            ${cell_string}   Run Keyword if  '${pcap_cellIdentity}' == '${cellIdengtity_element}[${idx}]'   Set Variable    ${1}
            ...   ELSE   Set Variable    ${EMPTY}
            Exit For Loop If   '${pcap_cellIdentity}' == '${cellIdengtity_element}[${idx}]'
            ${cell_string}   Catenate    SEPARATOR=   ${cell_string}   ${0}
     END
     [Return]   ${cell_string}

Get PLMNIdentity from WebUI
    Close Web Startup View Window
   ${mcc}    selenium_coam.get_parameter_value     dist_name=${INSID}    filter_param=MCC in PLMN
   ${mnc}    selenium_coam.get_parameter_value     dist_name=${INSID}    filter_param=MNC in PLMN
   ${mnc_length}    selenium_coam.get_parameter_value     dist_name=${INSID}    filter_param=MNC length of PLMN ID in primary PLMN of gNB
   ${mnc_length_tmp}    Get Length    ${mnc}
   ${zero_num}=    Evaluate     ${mnc_length}-${mnc_length_tmp}
   FOR   ${idx}    IN RANGE    0    ${zero_num+1}
       Exit For Loop If    '${mnc_length}'=='${mnc_length_tmp}'
       ${mnc}     Catenate    SEPARATOR=     0    ${mnc}
       ${mnc_length_tmp}    Get Length    ${mnc}
   END
   ${PLMNIdentity_dec}      Catenate    SEPARATOR=     ${mcc}   ${mnc}
   [Return]   ${PLMNIdentity_dec}

Get Cell Number
    ${cell_list}   COAM Get Cell List
    ${cell_numbers}    get length    ${cell_list}
    [Return]    ${cell_numbers}

# Check PCMD Related Object Exist
#     ${scf_xml}   COAM Get SCF Content
#     # COAM Backup Full SCF
#     # ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
#     ${NRCTRLTS_EXIST}   Run Keyword And Return Status
#     ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
#     ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
#     ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
#     ${TCEADM_EXIST}   Run Keyword And Return Status
#     ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
#     Set Suite Variable   ${NRCTRLTS_EXIST}
#     Set Suite Variable   ${NRCTRLTSDU_EXIST}
#     Set Suite Variable   ${TCEADM_EXIST}

COAM Remove PCMD Object via API
    # COAM Update PCMD Flag
    Check PCMD Related Object Exist
    @{del_all_pcmd}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrlts}
    Run Keyword If   ${NRCTRLTSDU_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrltsdu}
    Run Keyword If   ${TCEADM_EXIST}   Append To List   ${del_all_pcmd}   ${del_tceadm}
    ${del_str}   Convert To String   ${del_all_pcmd}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}

COAM Add PCMD Object via API
    # COAM Update PCMD Flag   flag=true
    ${add_str}   Convert To String   ${add_all_pcmd}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}
