*** Settings ***

Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description: This feature allows to operate Nokia O-DU with 3rd party O-RU
...               (KDDI O-RU) and Nokia O-RU, using different IOT-profile parameter values.

Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/gnb.robot
Resource        ../../../Resources/robot/oam_operations.robot

Suite Setup       Common Suite Setup    feature_folder=CB013328

*** Variables ***
${dl_tput}               5
${ul_tput}               5
@{SA_UE_List}            1
@{FDD_UE_List}           1    2
${LOCK_UNLOCK_REPETITIONS}    1
${Profile1_TDD_RFM_Plugin}         RFMPlugin_O-RU_SJ_CB013328TDD1_0001.zip
${Profile1b_TDD_RFM_Plugin}        RFMPlugin_O-RU_SJ_CB013328TDD2_0001.zip
${Profile3_FDD_RFM_Plugin}         RFMPlugin_O-RU_FJ_CB013328FDD_0001.zip
${Profile1_TDD_cfg}                ${CURDIR}/Config_Files/TDD_Profile1
${Profile1b_TDD_cfg}               ${CURDIR}/Config_Files/TDD_Profile1b
${Profile3_FDD_cfg}                ${CURDIR}/Config_Files/FDD_Profile3
${timer}                           5400
${capability_file}                 capability.cfg
${commands_file}                   commands.lua
${multi_ue_file}                   multi_ue_sa_script_new
${sansa_file}                      sansa.lua
&{CELL_TDD_LOCK_UNLOCK}    Cell_Count=1    NO_OF_CELLS=1   AMF_PAIR=1,5    DIR=None
   ...    AMF_COUNT=5    NO_REG=True    NO_OF_CELLS=1
   ...    UEC_COUNT=6    LOOP_TIMES=1    NC_SNAPSHOT=samji_ncs
   ...    SIB_WAIT_TIME=60
${simmode_active}    SimMode is ready now
${RFM_Plugin}                 ${Profile1_TDD_RFM_Plugin}
${pdu_id}                          1
${reset_repetitions}               1

*** Test Cases ***
Profile_1_LockUnlock_verify_L3 call and oam lock unlock operations with KDDI O-RU TDD
    [Tags]    AP_REG    Profile1_TDD_lock
    [Setup]    Test Setup for CB013328    TC_dictionary=&{CELL_TDD_LOCK_UNLOCK}    rfm_plugin_name=${Profile1_TDD_RFM_Plugin}
    ...        feature=Profile1_TDD_IOT_lockunlock        custom_config=True
    ...    custom_config_folder=${Profile1_TDD_cfg}
    ${start_traffic}=    Set Variable    seq_start rate=1 id=25 detailed_print=on duration=5 max_start=2
    ute_wtssim.Execute Egate Command    ${start_traffic}    timeout=10minutes
    Sleep    60s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=${pdu_id}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${LOCK_UNLOCK_REPETITIONS}
        ${fault_dict_after_cell_lock}=    Perform Cell Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_rmod_lock}=    Perform RMOD Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_cell_lock}    iteration_index=${index}
        ${fault_dict_after_amf_lock}=    Perform AMF Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_rmod_lock}    iteration_index=${index}
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Profile_1_Reset_Verify OAM reset operations with KDDI O-RU TDD
    [Documentation]    Verify RU reset,BBMOD reset and site reset with 5DL_5UL Traffic
    [Tags]    AP_REG    Profile1_TDD_reset
    [Setup]    Test Setup for CB013328    TC_dictionary=&{CELL_TDD_LOCK_UNLOCK}    rfm_plugin_name=${Profile1_TDD_RFM_Plugin}
    ...        feature=Profile1_TDD_IOT_reset        custom_config=True
    ...    custom_config_folder=${Profile1_TDD_cfg}
    ${start_traffic}=    Set Variable    seq_start rate=1 id=25 detailed_print=on duration=5 max_start=2
    ute_wtssim.Execute Egate Command    ${start_traffic}    timeout=10minutes
    Sleep    60s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=${pdu_id}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    sleep    30s
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${reset_repetitions}
        ${fault_dict_after_ru_reset}=    Perform RU Reset With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_bbmod_reset}=    Perform BBMOD Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_ru_reset}    iteration_index=${index}
        ${fault_dict_after_site_reset}=    Perform Site Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_bbmod_reset}    iteration_index=${index}
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Profile_1b_LockUnlock_Verify L3 call and oam lock unlock with KDDI O-RU TDD
    [Documentation]    Verify Cell Lock and Unlock with 5DL_5UL Traffic
    [Tags]    AP_REG    Profile1b_TDD_lock
    [Setup]    Test Setup for CB013328    TC_dictionary=&{CELL_TDD_LOCK_UNLOCK}    rfm_plugin_name=${Profile1b_TDD_RFM_Plugin}
    ...        feature=Profile1b_TDD_IOT_lockunlock        custom_config=True
    ...    custom_config_folder=${Profile1b_TDD_cfg}
    ${start_traffic}=    Set Variable    seq_start rate=1 id=25 detailed_print=on duration=5 max_start=2
    ute_wtssim.Execute Egate Command    ${start_traffic}    timeout=10minutes
    Sleep    60s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=${pdu_id}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${LOCK_UNLOCK_REPETITIONS}
        ${fault_dict_after_cell_lock}=    Perform Cell Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_rmod_lock}=    Perform RMOD Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_cell_lock}    iteration_index=${index}
        ${fault_dict_after_amf_lock}=    Perform AMF Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_rmod_lock}    iteration_index=${index}
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Profile_1b_Reset_Verify OAM reset operations with KDDI O-RU TDD
    [Documentation]    Verify RU reset,BBMOD reset and site reset with 5DL_5UL Traffic
    [Tags]    AP_REG    Profile1b_TDD_reset
    [Setup]    Test Setup for CB013328    TC_dictionary=&{CELL_TDD_LOCK_UNLOCK}    rfm_plugin_name=${Profile1b_TDD_RFM_Plugin}
    ...        feature=Profile1b_TDD_IOT_reset        custom_config=True
    ...    custom_config_folder=${Profile1b_TDD_cfg}
    ${start_traffic}=    Set Variable    seq_start rate=1 id=25 detailed_print=on duration=5 max_start=2
    ute_wtssim.Execute Egate Command    ${start_traffic}    timeout=10minutes
    Sleep    60s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=${pdu_id}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    sleep    30s
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${reset_repetitions}
        ${fault_dict_after_ru_reset}=    Perform RU Reset With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_bbmod_reset}=    Perform BBMOD Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_ru_reset}    iteration_index=${index}
        ${fault_dict_after_site_reset}=    Perform Site Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_bbmod_reset}    iteration_index=${index}
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Profile_3_LockUnlock_Verify L3 call and oam lock unlock with KDDI O-RU FDD
    [Documentation]    Verify Cell Lock and Unlock with 5DL_5UL Traffic
    [Tags]    AP_REG    Profile3_FDD_lock
    [Setup]    Test Setup for CB013328    TC_dictionary=&{CELL_TDD_LOCK_UNLOCK}    rfm_plugin_name=${Profile3_FDD_RFM_Plugin}
    ...        feature=Profile3_FDD_IOT_lockunlock        custom_config=True
    ...    custom_config_folder=${Profile3_FDD_cfg}
    ${start_traffic}=    Set Variable    seq_start rate=1 id=33 detailed_print=on duration=5 max_start=2
    ute_wtssim.Execute Egate Command    ${start_traffic}    timeout=10minutes
    Sleep    60s
    Validate Bearer Stats for multiple UEs    ue_list=${FDD_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=${pdu_id}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${FDD_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${LOCK_UNLOCK_REPETITIONS}
        ${fault_dict_after_cell_lock}=    Perform Cell Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_rmod_lock}=    Perform RMOD Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_cell_lock}    iteration_index=${index}
        ${fault_dict_after_amf_lock}=    Perform AMF Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_rmod_lock}    iteration_index=${index}
    END
    [Teardown]    Simple Test Teardown    ${FDD_UE_List}

Profile_3_Reset_Verify OAM reset operations with KDDI O-RU FDD
    [Documentation]    Verify RU reset,BBMOD reset and site reset with 5DL_5UL Traffic
    [Tags]    AP_REG    Profile3_FDD_reset
    [Setup]    Test Setup for CB013328    TC_dictionary=&{CELL_TDD_LOCK_UNLOCK}    rfm_plugin_name=${Profile3_FDD_RFM_Plugin}
    ...        feature=Profile3_FDD_IOT_reset        custom_config=True
    ...    custom_config_folder=${Profile3_FDD_cfg}
    ${start_traffic}=    Set Variable    seq_start rate=1 id=33 detailed_print=on duration=5 max_start=2
    ute_wtssim.Execute Egate Command    ${start_traffic}    timeout=10minutes
    Sleep    60s
    Validate Bearer Stats for multiple UEs    ue_list=${FDD_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=${pdu_id}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${FDD_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    sleep    30s
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${reset_repetitions}
        ${fault_dict_after_ru_reset}=    Perform RU Reset With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_bbmod_reset}=    Perform BBMOD Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_ru_reset}    iteration_index=${index}
        ${fault_dict_after_site_reset}=    Perform Site Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_bbmod_reset}    iteration_index=${index}
    END
    [Teardown]    Simple Test Teardown    ${FDD_UE_List}

*** Keyword ***
Check Occurances from Egate Console
    [Arguments]    ${pattern}    ${expected_occurances}
    ${file}=    Set Variable    egate_console.log
    ${grepArgs}    Set Variable    find /opt/wts/latest/ -iname '${file}' -exec grep -m ${expected_occurances}
    ${command}    Catenate    ${grepArgs}    '${pattern}'    {} \\;    |    wc -l
    ${result}     Run    ${command}
    Should Be Equal    ${result}     ${expected_occurances}    msg=Error Found in Egate Logs: ${pattern} Not Found

Test Setup for CB013328
    [Arguments]     ${TC_dictionary}    ${rfm_plugin_name}   ${feature}    &{kwargs}
    Check and Create test case log folder
    Set Suite Variable    ${IS_ORAN}    True
    Fetch Dictionary items    ${TC_dictionary}
    Update RFM Plugin And Add Netconf Account     rfm_plugin_name=${rfm_plugin_name}
    Basic Test Setup    ${feature}    &{kwargs}
    Start WTS
    sleep    180
    Wait Until Keyword Succeeds    3min    60s    Check All SystemInformationBlockType Updates

Check SystemInformationBlockType Updates In Egate Log
    [Documentation]    Check if SystemInformationBlockType updates are present in egate console log
    [Arguments]    ${uec_id}    ${expected_count}=${EMPTY}     ${diff_sib1_sib2_count}=False
    ute_wtssim.Execute Egate Command    set_log flush
    ${log_content}=    Run    cat /opt/wts/latest/egate_console.log
    ${original_expected_count}=    Set Variable    ${expected_count}
    FOR    ${block_type}    IN RANGE    1    6
        ${pattern}=    Set Variable    UEC-${uec_id}:.*SystemInformationBlockType${block_type}-NR updated
        ${matches}=    Get Regexp Matches    ${log_content}    ${pattern}
        ${match_count}=    Get Length    ${matches}
        ${expected_count_for_block}    Run Keyword If    '${original_expected_count}' != '${EMPTY}'
        ...    Evaluate    ${original_expected_count} - 1 if ${diff_sib1_sib2_count} and ${block_type} != 1 else ${original_expected_count}
        Run Keyword If    '${expected_count_for_block}' != '${None}'
        ...    Should Be Equal As Integers    ${match_count}    ${expected_count_for_block}
        ...    ELSE    Should Be True    ${match_count} > 0
        Log    Found ${match_count} SystemInformationBlockType${block_type} updates for UEC-${uec_id}
    END

Check All SystemInformationBlockType Updates
    [Documentation]    Check for all SystemInformationBlockType updates (Type1, Type2, Type3, Type4, Type5)
    [Arguments]    ${expected_sib_count}=${EMPTY}     ${diff_sib1_sib2_count}=False
    FOR     ${uec_id}    IN RANGE    1    7
        Check SystemInformationBlockType Updates In Egate Log    uec_id=${uec_id}    expected_count=${expected_sib_count}
        ...    diff_sib1_sib2_count=${diff_sib1_sib2_count}
    END

Fetch Dictionary items
    [Arguments]    ${dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    Log To Console    ${status}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END

Start WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS SIM
    Stop Edaemon Egate
    Connect To WTS VM
    Run    cd /opt/wts/latest && ulimit -c unlimited && sudo bash -c 'echo "core_%e.%p" > /proc/sys/kernel/core_pattern'
    ute_wtssim.Setup Edaemon    edaemon_port=${EDAEMON_PORT}    tool_dir=${WTS_INSTALL_PATH}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${EGATE_PORT}    tool_dir=${WTS_INSTALL_PATH}    save_egate=True
    ute_wtssim.Start Egate Process
    ${ls_cfg}    Run    ls ${WTS_INSTALL_PATH}/*cfg
    ${ls_lua}    Run    ls ${WTS_INSTALL_PATH}/*lua
    Log To Console    ${ls_cfg }
    Log To Console    ${ls_lua}
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    ute_wtssim.Execute Egate Command    ${wts_lua_command}    timeout=10minutes
    Wait Until Keyword Succeeds    5min    30s    Check Occurances from Egate Console    ${simmode_active}    1
    Log to console     WTS Started

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    SSH.Connect To        127.0.0.1    ute    ute    alias=local
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=20 &&
    ...               sysctl -w net.sctp.rto_min=400 &&
    ...               sysctl -w net.sctp.rto_initial=400 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Check NgLink and Cell Setup
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    ute_wtssim.Execute Egate Command And Wait For Data    ${wts_lua_command}    pass_regexp=NG link is Up    timeout=10minutes
