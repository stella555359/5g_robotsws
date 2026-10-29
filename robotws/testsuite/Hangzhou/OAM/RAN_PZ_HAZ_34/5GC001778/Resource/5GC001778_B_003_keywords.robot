*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com

Resource   emil.robot
Resource   coam.robot
Resource   common.robot

*** Keywords ***
Step1 Set NRMTRACECU-jobType as TraceOnly
    log to console   Step1 Set NRMTRACECU-jobType as TraceOnly
    Get Validation Error Before Modify Parameter
    Add Cell Trace Object Without Activate
#    @{VALUE}   selenium_coam.get_planned_parameter_value
#     ...  dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#     ...   filter_param=Job type
#     should be equal   @{VALUE}[0]   TraceOnly
#     should be equal   @{VALUE}[-1]   TraceOnly
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Job type
    ...   new_value=TraceOnly

Step2 Set NRMTRACECU-actCellTraceReporting to false
    log to console   Step2 Set NRMTRACECU-actCellTraceReporting to false
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Activate cell trace reporting for CU
    ...   new_value=false
    ${errors_num_2}   ${defination_errors_2}   ${relation_errors_2}   ${hardware_errors_2}
    ...   Validate Plan and Return Error
    ${new_errors}   Evaluate   ${errors_num_2}-${errors_num_before}
    Run Keyword If   ${new_errors} != 1   Log To Console   Validation Error check Failed: ${new_errors}!=1.
    ${key_error}   set variable   NRMTRACECU-1.actCellTraceReportingCU (value: false) equal to true
    ${validation_check}   Evaluate   str(@{relation_errors_2.values()}).count('${key_error}')
    Run Keyword If      ${validation_check} == 1      Log To Console  Validation report error which meet case expectation.
    ...         ELSE    Log To Console  Case Failed!
    Should Be True      ${new_errors} == 1 and ${validation_check} == 4
    [Teardown]   selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Activate cell trace reporting for CU
    ...   new_value=true

Step3 Change TCE IP Address from IPV4 to IPV6
    log to console   Step3 Change TCE IP Address from IPV4 to IPV6
    selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity ip address
	...   new_value=2a00:8a00:8000:136:10:57:167:172
    ${errors_num_3}   ${defination_errors_3}   ${relation_errors_3}   ${hardware_errors_3}
    ...   Validate Plan and Return Error
    should be equal   ${errors_num_3}   ${errors_num_before}
    [Teardown]   selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	...   filter_param=Trace collector entity ip address
	...   new_value=${tl.test_pcs[0].default_ssh_connection_details.addr}

Step4 Configure a Non-valid TceID
    log to console   Step6 Configure a Non-valid TceID
    selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=New Radio Trace Collector Entity identifier
	...   new_value=2
    ${errors_num_4}   ${defination_errors_4}   ${relation_errors_4}   ${hardware_errors_4}
    ...   Validate Plan and Return Error
    ${new_errors}   Evaluate   ${errors_num_4}-${errors_num_before}
    Run Keyword If   ${new_errors} != 1   Log To Console   Validation Error check Failed: ${new_errors}!=1.
    ${release}   Get gnb release   host=${WEBUI_ADDR}
    ${key_error}   set variable if  '${release}' >= 'SBTS23R3'    There should exist such an instance of TCE for which
    ...    It is required that there exist MOs TCE)
    ${validation_check}   Evaluate   str(@{relation_errors_4.values()}).count('${key_error}')
    Run Keyword If      ${validation_check} == 1      Log To Console  Validation report error which meet case expectation.
    ...         ELSE    Log To Console  Case Failed!
    Should Be True      ${new_errors} == 1 and ${validation_check} == 1
    [Teardown]   selenium_coam.set_parameter_value
	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
	...   filter_param=New Radio Trace Collector Entity identifier
	...   new_value=1

Step5 Check the Relationship of actCellTraceReporting true and Interfaces
    log to console   Step5 Check the Relationship of actCellTraceReporting true and Interfaces
    Set Cell Trace CU Flag without activate   celltrace_cu=true   rrc=none    x2=none   xn=none   ngap=none
    ${errors_num_5}   ${defination_errors_5}   ${relation_errors_5}   ${hardware_errors_5}
    ...   Validate Plan and Return Error
    ${new_errors}   Evaluate   ${errors_num_5}-${errors_num_before}
    Run Keyword If   ${new_errors} != 1   Log To Console   Validation Error check Failed: ${new_errors}!=1.
    ${key_error}   set variable   NRMTRACECU-1.traceXNSetting (value: none) equal to none
    ${validation_check}   Evaluate   str(@{relation_errors_5.values()}).count('${key_error}')
    Run Keyword If      ${validation_check} == 1      Log To Console  Validation report error which meet case expectation.
    ...         ELSE    Log To Console  Case Failed!
    Should Be True      ${new_errors} == 1 and ${validation_check} == 1
    [Teardown]   selenium_coam.undo_changes

Set Cell Trace CU Flag without activate
    [Arguments]    ${celltrace_cu}=true    ${rrc}=all    ${x2}=all   ${xn}=all   ${ngap}=all
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Activate cell trace reporting for CU
    ...   new_value=${celltrace_cu}
    selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace NRRRC setting
    ...   new_value=${rrc}
    Run Keyword   selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace X2 setting
    ...   new_value=${x2}
    Run Keyword   selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace XN setting
    ...   new_value=${xn}
    Run Keyword   selenium_coam.set_parameter_value
    ...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
    ...   filter_param=Trace NGAP setting
    ...   new_value=${ngap}

