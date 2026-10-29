*** Settings ***
Documentation    Author: jingmin.he@nokia-sbell.com
Resource   collect_log.robot
Resource   ../../common/gnb.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001778/libraries/pcmd_para_var.py

*** Variables ***
${BTSID}    MRBTS-${tl.gnbs[0].instance_id}
${INSID}   ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
#${INSID}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

*** Keywords ***
Remove Cell Trace Object If Exists
    [Documentation]   ${tce_remove} will be added when feature 1778-B releases
    Close Web Startup View Window
#    ${cu_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRCTRLTS-1
#    ${du_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1
#    ${tce_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d_%H%M%S
    ${cu_remove}   Remove Object With MO exists   parent=${INSID}   class_name=NRCTRLTS
    ${du_remove}   Remove Object With MO exists   parent=${INSID}/NRDU-1   class_name=NRCTRLTSDU
    ${tce_remove}   Remove Object With MO exists   parent=MRBTS-${MRBTS_ID}/MNL-1   class_name=TCEADM
    Run keyword If   ${cu_remove} or ${du_remove} or ${tce_remove}   Validate and Activate Plan
    [Teardown]   Run Keyword If   $KEYWORD_STATUS == 'FAIL'   selenium_coam.save_screenshot
    ...   filename=screen_commission_${timestamp}.png   screenshot_dir=${OUTPUT_DIR}

Remove Object With MO exists
    [Arguments]   ${parent}   ${class_name}
    COAM Login   alias=remove
    ${obj_res}   coam.Get Managed Objects  class_name=${class_name}_A   connection=remove
    Run Keyword If   ${obj_res}   Wait Until Keyword Succeeds   3x   30s
    ...   selenium_coam.remove_object   object_name=${parent}/${class_name}-1
    [Return]   ${obj_res}
    [Teardown]   COAM Logout   connection=remove

Add Cell Trace DU Object
    [Arguments]   ${du_actPCMDReporting}=false   ${du_resourceDN}=${INSID}/NRCELL-1   ${du_typeNrDu}=cell   ${radio_resource}=allResources
    Close Web Startup View Window
    COAM WEBUI Add Object With Close Startup View window Retry    object_name=${INSID}/NRDU-1    object_class_name=NRCTRLTSDU   id_value=1
    ...   is_load_default_values=${true}
	COAM WEBUI Add Object With Close Startup View window Retry   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1
    ...   object_class_name=NRMTRACEDU   id_value=1   is_load_default_values=${true}
	Add Cell Trace Object of NRMTRACEDU   du_cellMaxActiveUEsTraced=2  du_actPCMDReporting=${du_actPCMDReporting}   radio_resource=${radio_resource}
	Run Keyword If   '${du_typeNrDu}'=='cell'   Run Keywords   COAM WEBUI Add Object With Close Startup View window Retry
	...   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1    object_class_name=NRRESOURCEDU   id_value=1
    ...   is_load_default_values=${true}
	...   AND   Add Cell Trace Object of NRRESOURCEDU   du_resourceDN=${du_resourceDN}   du_typeNrDu=${du_typeNrDu}

Add Cell Trace Object of NRMTRACEDU
    [Arguments]   ${du_cellMaxActiveUEsTraced}=2   ${du_actPCMDReporting}=false   ${radio_resource}=allResources
    Close Web Startup View Window
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...   filter_param=Cell maximum active UE traced
    ...   new_value=${du_cellMaxActiveUEsTraced}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=Job type
	...   new_value=TraceOnly
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.add_element
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference MCC
	...   new_value=460
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference MNC
	...   new_value=2
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference MNC length
	...   new_value=2
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=NR trace reference trace Id
	...   new_value=${MRBTS_ID}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=New Radio Trace Collector Entity identifier
	...   new_value=1
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=Activate PCMD reporting
	...   new_value=${du_actPCMDReporting}
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
	...   filter_param=Scope of New Radio Resource
	...   new_value=${radio_resource}

Add Cell Trace Object of NRRESOURCEDU
    [Documentation]  When ${du_typeNrDu} is cell, the ${resource} should be MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    [Arguments]   ${du_typeNrDu}   ${du_resourceDN}
    Close Web Startup View Window
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1/NRRESOURCEDU-1
    ...   filter_param=Resource distinguished name
    ...   new_value=${du_resourceDN}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1/NRRESOURCEDU-1
    ...   filter_param=Type of New Radio Resource
    ...   new_value=${du_typeNrDu}

Add Cell Trace Object of NRMTRACECU
    [Arguments]   ${NRCTRLTS}=${true}
    Close Web Startup View Window
    Run Keyword If   ${NRCTRLTS}   COAM WEBUI Add Object With Close Startup View window Retry    object_name=${INSID}
    ...    object_class_name=NRCTRLTS   id_value=1   is_load_default_values=${true}
	COAM WEBUI Add Object With Close Startup View window Retry
	...   object_name=${INSID}/NRCTRLTS-1    object_class_name=NRMTRACECU   id_value=1   is_load_default_values=${true}
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=Job type
	...   new_value=TraceOnly
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.add_element
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference MCC
	...   new_value=460
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference MNC
	...   new_value=2
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference MNC length
	...   new_value=2
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=NR trace reference trace Id
	...   new_value=${MRBTS_ID}
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=New Radio Trace Collector Entity identifier
	...   new_value=1
	Run Keyword and Ignore Error  selenium_coam.delete_parameter
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=NR periodic UE measurements
    Run Keyword and Ignore Error  selenium_coam.delete_parameter
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=NR immediate MDT control
    Run Keyword and Ignore Error  selenium_coam.delete_parameter
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=NR immediate MDT UE measurements


Add Cell Trace Object of NRRESOURCECU
    [Documentation]  When ${radio_resoure} is cell, the ${resource} should be MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    [Arguments]   ${radio_resoure}=central   ${resource}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    COAM WEBUI Add Object With Close Startup View window Retry   object_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   object_class_name=NRRESOURCECU   id_value=1   is_load_default_values=${true}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
	...   filter_param=Type of New Radio Resource
	...   new_value=${radio_resoure}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
	...   filter_param=Resource distinguished name
	...   new_value=${resource}

Add Cell Trace Object of TCE
    [Arguments]   ${dcap_server_ip}=${trace_host}
    ...   ${dcap_server_port}=${trace_port}
    COAM WEBUI Add Object With Close Startup View window Retry    object_name=MRBTS-${MRBTS_ID}/MNL-1
    ...    object_class_name=TCEADM   id_value=1
    COAM WEBUI Add Object With Close Startup View window Retry    object_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1
    ...    object_class_name=TCE   id_value=1   is_load_default_values=${true}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRTCE-1
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity ip address
	...   new_value=${dcap_server_ip}
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRTCE-1
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity port number
	...   new_value=${dcap_server_port}
	wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
#	...   dist_name=${INSID}/NRCTRLTS-1/NRTCE-1
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity identifier
	...   new_value=1

Set PCMD CU Flag
    [Arguments]    ${pcmd_flag}=true
    Close Web Startup View Window
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Activate PCMD reporting
    ...   new_value=${pcmd_flag}

Set Cell Trace CU Flag
    [Arguments]    ${celltrace_cu}=true    ${rrc}=all    ${x2}=all   ${xn}=all   ${ngap}=all   ${scope}=allResources   ${max_ue}=3
    Close Web Startup View Window
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Activate cell trace reporting for CU
    ...   new_value=${celltrace_cu}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace NRRRC setting
    ...   new_value=${rrc}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace X2 setting
    ...   new_value=${x2}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace XN setting
    ...   new_value=${xn}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace NGAP setting
    ...   new_value=${ngap}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Scope of New Radio Resource
    ...   new_value=${scope}
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Cell maximum active UE traced
    ...   new_value=${max_ue}

Set Cell Trace Flag
    [Arguments]    ${trace_flag}=true
    Close Web Startup View Window
    wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value
    ...   dist_name=${INSID}
    ...   filter_param=Activate cell trace report
    ...   new_value=${trace_flag}
    Validate and Activate Plan

Validate and Activate Plan
    Close Web Startup View Window
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300
    Sleep   10s
    COAM WEBUI Whether Close Start Up View Window

Modify Parameter actCellTraceReport To ${set_actCellTraceReport}
    Close Web Startup View Window
    ${flag_actCellTraceReport}   selenium_coam.get_parameter_value   dist_name=${INSID}
    ...   filter_param=Activate cell trace report
    ${need_change}   Evaluate   '${flag_actCellTraceReport.lower()}'!='${set_actCellTraceReport.lower()}'
    Run Keyword If   ${need_change}   wait until keyword succeeds   3x   10s
    ...       selenium_coam.set_parameter_value   dist_name=${INSID}
    ...   filter_param=Activate cell trace report   new_value=${set_actCellTraceReport.lower()}
    Run Keyword If   ${need_change}   Log to Console
    ...   Modify actCellTraceReport from ${flag_actCellTraceReport} to ${set_actCellTraceReport.lower()}
    [Return]   ${need_change}

Modify Parameter actPCMDReport To ${set_actPCMDReport}
    Close Web Startup View Window
    ${flag_actPCMDReport}   selenium_coam.get_parameter_value   dist_name=${INSID}
    ...   filter_param=Activate PCMD report
    ${need_change}   Evaluate   '${flag_actPCMDReport.lower()}'!='${set_actPCMDReport.lower()}'
    Run Keyword If   ${need_change}   wait until keyword succeeds   3x   10s
    ...   selenium_coam.set_parameter_value   dist_name=${INSID}
    ...   filter_param=Activate PCMD report   new_value=${set_actPCMDReport.lower()}
    Run Keyword If   ${need_change}   Log to Console
    ...   Modify actPCMDReport from ${flag_actPCMDReport} to ${set_actPCMDReport.lower()}
    [Return]   ${need_change}

Add Cell Trace Object Without Activate
    [Arguments]   ${celltrace_cu}=true   ${rrc}=all    ${x2}=all   ${xn}=all   ${ngap}=all
    ...   ${dcap_server_ip}=${trace_host}
    ...   ${dcap_server_port}=${trace_port}
    ...   ${pcmd_cu}=false
    ...   ${scope}=allResources
    Close Web Startup View Window
    Add Cell Trace Object of TCE   dcap_server_ip=${dcap_server_ip}   dcap_server_port=${dcap_server_port}
	Add Cell Trace Object of NRMTRACECU
#	Add Cell Trace Object of NRRESOURCECU
	Set PCMD CU Flag   pcmd_flag=${pcmd_cu}
	Run Keyword   Modify Parameter actCellTraceReport To ${celltrace_cu}
	Run Keyword   Modify Parameter actPCMDReport To ${pcmd_cu}
	Set Cell Trace CU Flag   celltrace_cu=${celltrace_cu}   rrc=${rrc}    x2=${x2}   xn=${xn}  ngap=${ngap}   scope=${scope}

Change gNB Time Zone
    [Documentation]   Timezone change
    [Arguments]    ${timezone}
    Close Web Startup View Window
    ${old_setting}   selenium_coam.get_parameter_value    dist_name=${BTSID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    filter_param=Time zone
    selenium_coam.set_parameter_value    dist_name=${BTSID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    filter_param=Time zone    new_value=${timezone}
    ${need_change}   Evaluate   '${old_setting}'!='${timezone}'
    Run Keyword If   ${need_change}   _gNB Reset When Activation   ELSE   _gNB Reset Without Activation
    [Return]   ${need_change}

_gNB Reset When Activation
    selenium_coam.validate_plan
    Sleep   5s
    Close Web Startup View Window
    wait until keyword succeeds   1m   10s   selenium_coam.activate_plan   activate_plan_despite_errors=${true}
    Sleep    2m
    _gNB To Be onair

_gNB Reset Without Activation
    Close Web Startup View Window
    selenium_coam.reset_site
    Sleep    2m
    _gNB To Be onair

_gNB To Be onair
    wait until keyword succeeds   10m   1m   Try Connect gNB
    wait until keyword succeeds   25m   1m   COAM Check All Cells Onair
    Close Web Startup View Window

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

Cell State Verify
    [Arguments]   ${cell_index}   ${state}=Unlocked
    Close Web Startup View Window
    ${cell_info}   selenium_coam.Get_Cell_Info    cell_idx=${cell_index}
    ${status}   Set Variable   ${cell_info['Status']}
    Should Contain   ${status['Administrative state'].lower()}   ${state.lower()}

COAM Add Trace Object
    [Arguments]    ${cell_trace_only}='ngap'
    ${add_mo}    Run Keyword If   ${cell_trace_only}=='ngap'   Set Variable   ${add_cell_trace_ngap}
    ...   ELSE IF   ${cell_trace_only}=='rrc'   Set Variable   ${add_cell_trace_rrc}
    ${add_str}   Convert To String   ${add_mo}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

