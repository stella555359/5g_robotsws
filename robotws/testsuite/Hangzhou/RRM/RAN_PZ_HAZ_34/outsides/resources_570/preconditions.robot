*** Settings ***
Library             OperatingSystem
Library             BuiltIn
Library             String
Library             Collections
Library             taf.transport.ssh      WITH NAME   ssh
Library             ./webUI_operations.py
Library             ./preconditions_py.py
Library             taf.sbts.oam.coam.admin      WITH NAME    coam

Resource  	        ./connections.robot
Resource            ./commissioning.robot
Resource            ./LTEemu.robot
Resource            ./logs.robot



*** Variables ***
${LOG_PATH}         ${OUTPUT DIR}
${WEBUI_URL}        https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ALLOWED_ALARMS_RE}    .*(LMP access via port|SSH enabled|Service Port enabled|BTS Reset Cause|Service account root access is enabled
${ALLOWED_ALARMS_REGEX}    ${ALLOWED_ALARMS_RE}|Ethernet port security is disabled).*
${GN_OAM_ADDR}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
Set global variables
    Set global variable    ${mrbts_id}     ${tl.gnbs[0].instance_id}
    Set global variable    ${bts_id}       ${tl.gnbs[0].instance_id}       #duplicated mrbts_id as historical value used in tests
    Set global variable    ${nrbts_id}     ${tl.gnbs[0].global_bts_id}
    Set global variable    ${radio type}   ${tl.gnbs[0].dus[0].rus[0].radio_type}
    ${sw release name}=    get software release name
    Set global variable                    ${sw release name}
    ${smod name}=          get smod name
	Set global variable                    ${smod name}
    update_python_globals


Get BTS id and set as suite variable
    coam.connect to     bts_host=${GN_OAM_ADDR}
    ${bts_id}=   preconditions_py.get_bts_info   attribute=id
    set suite variable                ${bts_id}


Set TESTNAME without spaces
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    set test variable   ${test_name}



Clear cache
    ssh.Reset Cache


Is ASIK and ABIL ready
    ${output}=  is BBMOD ready
    Should Match Regexp   ${output}   Enabled   BBMOD is not ready   ignore_case=False



Wait for cell to be in given state
   [Documentation]   Possible values to ask: online/offline
   [Arguments]    ${cell_state}   ${cell_number}=1
   Wait until keyword succeeds   900 s
   ...                           15 s
   ...                           Is cell in state   ${cell_state}   ${cell_number}


Get startup_DEFAULT log in case of error
    [Documentation]   This keyword can only be used in a suite teardown.
    ...               Trying to use it anywhere else results in an error.
    Run keyword if any tests failed   Get startup_DEFAULT.log from ASIK


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



Check Allowed Alarms
    taf.sbts.oam.coam.admin.Teardown
    taf.sbts.oam.coam.admin.Connect To
    ${alarms_list}=    Get Active Alarms
    ${alarms_list_length}=    Get Length    ${alarms_list}
    FOR    ${alarm_temp}    IN RANGE    ${alarms_list_length}
           ${alarm_list2}=    Get From List    ${alarms_list}    ${alarm_temp}
           ${single_alarm_dict}=    Get From Dictionary    ${alarm_list2}       alarmDetail
           Run Keyword And Continue On Failure    Should Match Regexp    ${single_alarm_dict}    ${ALLOWED_ALARMS_REGEX}
    END
    [Teardown]    taf.sbts.oam.coam.admin.Teardown
