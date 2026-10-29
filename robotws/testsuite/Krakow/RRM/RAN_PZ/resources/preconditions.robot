*** Settings ***
Library             OperatingSystem
Library             BuiltIn
Library             String
Library             Collections
Library             taf.transport.ssh      WITH NAME   ssh
Library             testsuite.Krakow.RRM.RAN_PZ.resources.webui.WebuiInterface   WITH NAME   WebUI
Library             ./webUI_operations.py
Library             ./preconditions_py.py
Library             taf.gnb.oam.coam.admin

*** Variables ***
${LOG_PATH}         ${OUTPUT DIR}
${WEBUI_URL}        https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ALLOWED_ALARMS_RE}    .*(LMP access via port|SSH enabled|Service Port enabled|Service account root access is enabled
${ALLOWED_ALARMS_REGEX}  ${ALLOWED_ALARMS_RE}|BTS Reset Cause|Ethernet port security is disabled|Sanity Check Error).*

*** Keywords ***
Set global variables
    Set global variable    ${mrbts_id}     ${tl.gnbs[0].instance_id}
    Set global variable    ${bts_id}       ${tl.gnbs[0].instance_id}      #duplicated mrbts_id as historical value used
    Set global variable    ${nrbts_id}     ${tl.gnbs[0].global_bts_id}
    Set global variable    ${radio type}   ${tl.gnbs[0].dus[0].rus[0].radio_type}
    ${sw release name}=    get software release name
    Set global variable                    ${sw release name}
    ${smod name}=          get smod name
	Set global variable                    ${smod name}
    update_python_globals


Get BTS id and set as suite variable
    WebUI.create_session
    ${bts_id}=   WebUI.get_bts_info   attribute=id
    set suite variable                ${bts_id}
    [Teardown]  WebUI.teardown_session


Set TESTNAME without spaces
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    set test variable   ${test_name}


Check VMs availability
    WebUI.create_session
    ${vm_list}=                     WebUI.get_all_vms_types

    ${oam_availability_status}=     WebUI.get_vm_availability_status  vm_name=oamVM
    ${cpif_availability_status}=    WebUI.get_vm_availability_status  vm_name=cpifVM

    Should be equal as strings      ${cpif_availability_status}      online
    Should be equal as strings      ${oam_availability_status}       online

    [Teardown]  WebUI.teardown_session


Trigger Site Reset
    WebUI.create_session
    WebUI.reset_and_wait_for_site
    WebUI.create_session
    # ssh.Reset Cache


Trigger Site Reset and wait for availability
    WebUI.create_session
    WebUI.reset_and_wait_for_site
    WebUI.create_session
    wait until keyword succeeds   900   5   Check FRM availability
    # ssh.Reset Cache
    [Teardown]  WebUI.teardown_session


Clear cache
    ssh.Reset Cache


Is ASIK and ABIL ready
    ${output}=  is BBMOD ready
    Should Match Regexp   ${output.lower()}   enabled   BBMOD is not ready


Check FRM availability
    ${get_frm}   WebUI.get_frm
    ${radio_status}   Evaluate    ${get_frm}[status].get('availabilityStatus')
    Should Be True   '${radio_status}' == 'online' or '${radio_status}' == 'Online' or '${radio_status}' == 'None'
    ${radio_status}   WebUI.get_frm    attribute=operationalState
    Should Be Equal  ${radio_status}   enabled


Wait for cell to be in given state
   [Documentation]   Possible values to ask: online/offline
   [Arguments]    ${cell_state}   ${cell_number}=1
   Wait until keyword succeeds   900 s
   ...                           15 s
   ...                           Is cell in state   ${cell_state}   ${cell_number}


Is cell in state
    [Arguments]    ${cell_state}   ${cell_number}=1
    WebUI.create_session
    ${result}=   WebUI.is_cell_in_state    state=${cell_state}   number=${cell_number}
    should be true   ${result}   is cell in state returns ${result}
    ${operationalState}=   WebUI.get_cell_specific_info   cell_number=${cell_number}   attribute=operationalState
    should be equal as strings  ${operationalState}   enabled
    [Teardown]  WebUI.teardown_session


(Un)Lock cell and check its status
    [Arguments]    ${cell_state}   ${cell_number}=1
    WebUI.create_session
    ${status}=   WebUI.get_cell_specific_info   cell_number=${cell_number}   attribute=administrativeState
    Run Keyword If   '${cell_state}' == 'locked' and '${status}' == 'unlocked'
    ...        WebUI.cell_lock   cell_id=${cell_number}
    Run Keyword If   '${cell_state}' == 'unlocked' and '${status}' == 'locked'
    ...        WebUI.cell_unlock   cell_id=${cell_number}
    ${result}=   WebUI.get_cell_specific_info   cell_number=${cell_number}   attribute=administrativeState
    should be equal   ${result}    ${cell_state}
    Log to console   Cell is ${result}
    [Teardown]  WebUI.teardown_session


Make snapshot in case of error
    Set TESTNAME without spaces
    Run keyword if test failed  make webui snapshot


Make snapshot if any tests failed
    [Documentation]   This keyword can only be used in a suite teardown.
    ...               Trying to use it anywhere else results in an error.
    Set Global Variable    ${test_name}    TEARDOWN
    Run keyword if any tests failed  make webui snapshot


Load testline specific scf
    ${scf_file}=   Get Variable Value   ${testline_scf}   ${none}
    Run keyword if   '${scf_file}' != '${none}'
    ...   Perform commissioning and wait till oam ready  ${scf_file}
    ...   ELSE
    ...   Log   Testline specific scf not found


Get active alarms
    WebUI.create_session
    ${alarms}=  WebUI.Get active alarms
    WebUI.teardown_session
    [Return]  ${alarms}

Check Allowed Alarms
    taf.gnb.oam.coam.admin.Teardown
    taf.gnb.oam.coam.admin.Connect To
    ${alarms_list}=    Get Active Alarms
    ${alarms_list_length}=    Get Length    ${alarms_list}
    :FOR    ${alarm_temp}    IN RANGE    ${alarms_list_length}
    \       ${alarm_list2}=    Get From List    ${alarms_list}    ${alarm_temp}
    \       ${single_alarm_dict}=    Get From Dictionary    ${alarm_list2}       alarmDetail
    \       Run Keyword And Continue On Failure    Should Match Regexp  ${single_alarm_dict}  ${ALLOWED_ALARMS_REGEX}
    [Teardown]    taf.gnb.oam.coam.admin.Teardown
