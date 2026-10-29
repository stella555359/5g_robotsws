*** Settings ***
Documentation
...  Case name:
     ...  The purpose for this TC is to:
          ...  show how to write DV UTE airframe + AirScale + LTESIM + PoC ORAN-SIM case

...  "Author: T04 "
...  *How To execute test case:*
...  cd ~/robotws
...  rybot -t "5GC002392_B_TC020_OAM"

#Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    ./testsuite/Bangalore/ORAN/SG04/resources/orualarm.py
Library    BuiltIn
Library    taf.ue
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/Common_resource.robot
Variables    ./testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py
Library    ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library     taf.sw.dcap.rd   WITH NAME   rd
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
&{CB006943_A_TC018_OAM}    QC_ID_FL00=QC_31644

${host1}=     10.58.239.169
${user1}=     ute
${password1}=    BT5l@bus3rl0g1n
${host2}=     192.168.255.129
${user2}=    toor4nsn
${password2}=    oZPS0POrRieRtu
${UE_PC}=    10.45.150.167
${id}=    inbabtslabuser
${password}=    BT5l@bus3rl0g1n
${ru_ip}=     192.168.1.131
${ru_id}=    User1-vSFQEFw1
${ru_pass}=  Q+*!LD0sem
${cmnd1}=    ru -stat
${search_string_1}=    administrative${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}:${SPACE}Unlocked
${search_string_2}=    administrative${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}:${SPACE}Locked
${voice_call_TC}=    LTE5524
@{capabilities}				Legacy_3
${RMOD_ID}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1


*** Test Cases ***
CB006943_A_TC018_OAM
    [Tags]    TRUNK    OAM18    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
     ...     Test teardown    AND    Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting    tl_name_only=${scout_id1}
	Test steps


*** Keywords ***

Test steps
    Log to console   --Test setup--
    coam.setup_admin	bts_host=${host1}    timeout=300
    Check BTS is OnAir
    coam.get_active_alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    ${trace_id}    DCAP Start
#    DCAP Start
    Set global variable    ${trace_id}
    Log to console   \n--DCAP Started --\n

    Log to console  \n--Executing/Start voice call--\n

    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}

    ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
    Sleep    40
    ta_ultracaller.stop_voice_call    ${UE_alias}

    Log to console  \n--Executing FOR Loop to get ORU ID--\n
    FOR    ${x}    IN RANGE    0    3
        ${target_ru} =    Set Variable    '${RMOD_ID}'
        Set suite variable    ${oru_id}    ${x}
        ${bts_info}=    coam.get_bts_info
        ${ru_identy}=    Evaluate    ${bts_info} ['radioModules']['rmod'][${x}]['id']['internal']
        Exit For Loop IF    '${ru_identy}' == ${target_ru}
        Log to console    ${x}
        Log to console    ${ru_identy}
    END

    Log to console  \n--Checking RMODs state and it should be unlock--\n
    ${adminstate_RU}=    Create List	${bts_info ['radioModules']['rmod'][${oru_id}]['status']['administrativeState']}
	Should Be Equal As Strings    ${adminstate_RU}    ['Unlocked']
    sleep    30

	Log to console  \n--Lock ORU via WebEM--\n
	coam.lock    dist_name=${RMOD_ID}    timeout=300s
    ${bts_info}=    coam.get_bts_info

    Log to console  \n--checking RMODs Lock status in WebEM--\n
	${adminstate_RU}=    Create List	${bts_info['radioModules']['rmod'][${oru_id}]['status']['administrativeState']}
	Should Be Equal As Strings    ${adminstate_RU}    ['Locked']

    Log to Console    \n--Login to FJT and executing command ${cmnd1} to check status in RU--\n
    coam.get_active_alarms
    ${outputy}=    RU_execute    ${UE_PC}    ${id}    ${password}    ${ru_ip}    ${ru_id}    ${ru_pass}    ${cmnd1}
    Log    ${outputy}
    should Contain	${outputy[0]}    ${search_string_2}

    Log to console  \n--UnLock ORU via WebEM--\n
    coam.unlock    dist_name=${RMOD_ID}    timeout=300s
    ${bts_info}=    coam.get_bts_info

    Log to console  \n--checking RMODs UnLock status in WebEM--\n
    ${adminstate_RU}=    Create List    ${bts_info['radioModules']['rmod'][${oru_id}]['status']['administrativeState']}
    Should Be Equal As Strings    ${adminstate_RU}    ['Unlocked']

    Log to Console    \n--Login to FJT and executing command ${cmnd1} to check status in RU--\n
    coam.get_active_alarms
    ${outputy}=    RU_execute    ${UE_PC}    ${id}    ${password}    ${ru_ip}    ${ru_id}    ${ru_pass}    ${cmnd1}
    Log    ${outputy}
    should Contain  ${outputy[0]}    ${search_string_1}
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console  DCAP_LOG_STATUS: ${dcap_log_status}

Test teardown
    Log to console   \n--Test teardown Started--\n
    Check BTS is OnAir
    sleep    10
    Log to console   \n--Test teardown completed--\n
#    Run Keyword If    "${dcap_log_status}" == "1.0"    Abort DCAP Trace    ${trace_id}
#    ...    ELSE    DCAP Stop with log Transfer    ${trace_id}
    RP Settings
	Run Keyword If    "${sw_release}" == "None"
    ...    Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually--    html=true
    ...    console=true
    interface.Common step trigger
    coam.Teardown All Aliases For Admin




Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    coam.get_bts_statuses
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

