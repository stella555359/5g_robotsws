*** Settings ***
Documentation    Author: Arunkumar A
...              mail: arunkumar@nokia.com
...              Regression CB012601 Test cWITH NAMEes are avaialble. HUB(High Uplink BLER)
...             :Adapted to RF5.0
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.sw.dcap.rd    WITH NAME    rd
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.selenium.sbts    WITH NAME     Sbts_Selenium
Library     ../../../Python/Test_Verification_Handler.py    WITH NAME    Validation
Resource    ../../logging_keywords.robot
Resource    ../../Rjio_Operation_keywords.resource
Resource    ../../UE_keywords.robot
Resource    ../../Common_keywords.resource
Variables    ../../../variables/ANR_test_case_variables.py
Variables    ../../../variables/CB012601_Variables.py
Variables    ../../../variables/alarm_variables.py

*** Keywords ***
Feature Activation CB012601 OAM
    [Documentation]    Feature activation
    [Arguments]    ${ObjectName}=NRREDRT
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Feature Activation CB012601 OAM Started [Time:${time_stamp}]
    ${NRCell_COUNT}    BuiltIn.Get Length    ${NRCell_list}
    FOR  ${index}  IN RANGE  ${NRCell_COUNT}
        coam.perform_parameter_recommissioning    dist_name=${NRCell_list}[${index}]
        ...    parameter=${deprioritization_timer}    operation=update    value=${DeprioTimer_5min}
        ...    skip_parameter_relation_errors=${False}
        ...    should_activate=${True}
        ...    connection=${connection}
        &{ULBLER_DICT}    BuiltIn.Create Dictionary    ${redir_Data}=${ulblerPercentage}
        ...    ${redir_Vonr}=${ulblerPercentage}
        @{ULBLER_List}    BuiltIn.Create List    ${ULBLER_DICT}
        coam.perform_parameter_recommissioning    dist_name=${NRCell_list}[${index}]
        ...    parameter=${ul_bler}    operation=update
        ...    value=${ULBLER_List}
        ...    skip_parameter_relation_errors=${False}
        ...    should_activate=${True}
        ...    connection=${connection}
        coam.perform_parameter_recommissioning    dist_name=${NRCell_list}[${index}]
        ...    parameter=${bler_base_redir}    operation=update    value=${highUlBlerBased}
        ...    skip_parameter_relation_errors=${False}
        ...    should_activate=${True}
        ...    connection=${connection}
    END
    IF  "${TEST_NAME}" == "UE_redirected_to_a_intergNB_TDD_frequency_layer_due_to_bad_uplink_radio_conditions_after_an_Incoming_Ng_handover"
        ${Status}    NRREDRT NR Object Modification    ObjectName=${ObjectName}
    ELSE IF    "${TEST_NAME}" == "UE_redirected_to_a_eutra RAT_frequency_layer_due_to_bad_uplink_radio_conditions_after_an_Initial_Context_Setup"
        ${Status}    NRREDRT EUTRA Object Modification    ObjectName=${ObjectName}
    ELSE
        BuiltIn.Fail    [ ERROR ]: TEST FAILED DUE TO TEST CASE NAME NOT FOUND.!
    END
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Feature Activation CB012601 OAM Ended [Time:${time_stamp}]

NRREDRT NR Object Modification
    [Documentation]    Get the NRREDRT Object in Current SCF.
    ...    Find out where redirPrio:1 configured and Modified params
    ...    Param: redirRat:nr, redirSsbScs:30KHz, redirFreqNr:636576
    ...    Finally performed Deleta commission on BTS.
    ...    return: True
    [Arguments]    ${ObjectName}    ${nr_prio}=1
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: NRREDRT NR Object Modification Started [Time:${time_stamp}]
    @{redirprio_1}    BuiltIn.Create List    redirPrio
    @{Get_NRREDRT_object_list}    coam.get_parameter_by_class
    ...    class_name=${ObjectName}    parameter_list=${redirprio_1}
    ${length}    BuiltIn.Get Length    ${Get_NRREDRT_object_list}
    FOR  ${item}    IN RANGE    ${length}
        IF    ${Get_NRREDRT_object_list}[${item}][parameters][redirPrio] == ${nr_prio}
            ${get_moc}    Set Variable    ${Get_NRREDRT_object_list}[${item}][distName]
            coam.perform_parameter_recommissioning    dist_name=${get_moc}
            ...    parameter=${RAT_redir}    operation=update    value=${nr}
            ...    skip_parameter_relation_errors=${True}
            ...    should_activate=${True}
            ...    connection=${connection}
            coam.perform_parameter_recommissioning    dist_name=${get_moc}
            ...    parameter=${redirFreqNr}    operation=update    value=${arfcnssbPbch_1062}
            ...    skip_parameter_relation_errors=${True}
            ...    should_activate=${True}
            ...    connection=${connection}
            coam.perform_parameter_recommissioning    dist_name=${get_moc}
            ...    parameter=${redirSsbScs}    operation=update    value=${Scs}
            ...    skip_parameter_relation_errors=${False}
            ...    should_activate=${True}
            ...    connection=${connection}
        END
    END
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: NRREDRT NR Object Modification Ended [Time:${time_stamp}]
    RETURN    ${True}

NRREDRT EUTRA Object Modification
    [Documentation]
    [Arguments]    ${ObjectName}    ${eutra_prio}=1
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: NRREDRT EUTRA Object Modification Started [Time:${time_stamp}]
    @{redirprio_1}    BuiltIn.Create List    redirPrio
    @{Get_NRREDRT_object_list}    coam.get_parameter_by_class
    ...    class_name=${ObjectName}    parameter_list=${redirprio_1}
    ${length}    BuiltIn.Get Length    ${Get_NRREDRT_object_list}
    FOR  ${item}    IN RANGE    ${length}
        IF    ${Get_NRREDRT_object_list}[${item}][parameters][redirPrio] == ${eutra_prio}
            ${get_moc}    Set Variable    ${Get_NRREDRT_object_list}[${item}][distName]
            coam.perform_parameter_recommissioning    dist_name=${get_moc}
            ...    parameter=${RAT_redir}    operation=update    value=${eutra}
            ...    skip_parameter_relation_errors=${True}
            ...    should_activate=${True}
            ...    connection=${connection}
            coam.perform_parameter_recommissioning    dist_name=${get_moc}
            ...    parameter=${redirFreqEutra}    operation=update    value=${erfcn_eutra}
            ...    skip_parameter_relation_errors=${False}
            ...    should_activate=${True}
            ...    connection=${connection}
        END
    END
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: NRREDRT EUTRA Object Modification Ended [Time:${time_stamp}]
    RETURN    ${True}

BadULRadio Condition After ICS
    [Documentation]    Test for Bad Uplink Radio condition Verification
    ...    Test Scenario:
    ...    |Param: Activate bad UL radio based redirection - MRBTS-1061/NRBTS-1061/NRCELL-0
    ...     - actBadUplinkRadioRedirect - highUlBlerBased
    ...    |Param: Bad UL redirect deprioritization timer - MRBTS-1061/NRBTS-1061/NRCELL-0
    ...     -badULRedirectDeprioTimer - 5min
    ...    |Addelement = ulBler
    ...    |Param: MRBTS-1061/NRBTS-1061/NRCELL-0 - ulBlerThresholdRedirectData - 2
    ...    |Param: MRBTS-1061/NRBTS-1061/NRCELL-0 - ulBlerThresholdRedirectVoNR - 2
    ...    |Param: MRBTS-1062/NRBTS-1062/NRCELL-4- arfcnSsbPbch - 636576
    Feature Activation CB012601 OAM
    &{bts_status}   Wait Until Keyword Succeeds    10 min    1 min    coam.get_bts_statuses
    BuiltIn.Should Be Equal    ${bts_status}[operationalState]    Enabled
    Set Local Variable    ${bad_uplink}    [bad uplink radio redirect]
    ${alarm_status}    BuiltIn.Run Keyword And Return Status
    ...    Validation.Acitive_Alarm_Verification_Test    ${ALLOWED_FAULT}
    IF    '${alarm_status}' == '${False}'     FAIL    Unexpected Alarm found.!
    Run Keyword And Continue On Failure    UE_keywords.Require UE
    FOR    ${port}    IN    @{Attenuator_Ports_1061_1063}
        Common_keywords.Set_attenuation_on_single_port  port=${port}  value=${value_in_dB}[-1]
        ...    Attenuator_device_config=${att}
        Sleep    2s
        BuiltIn.Log To Console    [ INFO ]: Attenuation value ${value_in_dB}[-1] set on port ${port}
    END
    Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
    ...        value=${value_in_dB}[0]
    ...        Attenuator_device_config=${att}
    BuiltIn.Log To Console    [ INFO ]: Port ${Attenuator_Ports_1061_1063}[0] Value is ${value_in_dB}[0].
    Wait Until Keyword Succeeds    2 minute    20 s    UE_keywords.Attach Ue via taf ue    ue_alias=${ue_alias}
    ${Ul_traffic_dt_name}    UE_keywords.start_UL_UDP_traffic_for_ever    ue_alias=${ue_alias}
    BuiltIn.Log To Console    [ INFO ]: UDP UL Traffic is started.!
    ${dt_status}    UE_keywords.check_data_transfer_is_alive_taf    dt_name=${Ul_traffic_dt_name}
    IF    '${dt_status}' == '${True}'
        BuiltIn.Log To Console    [ INFO ]: UDP UL Data transfer ongoing.!
    ELSE
        Fail    [ FAILED ]:VFR_1 UDP UL Data Trafic failed.!
    END
    ${inter_HO_TDD_TDD_status}    Intra Frequency Handover TDD TDD CB0012601
    IF    '${inter_HO_TDD_TDD_status}' == 'True'
        BuiltIn.Log To Console    [ INFO ]: Inter frequency Handover(TDD->TDD) is done
    ELSE
        Fail    [ FAILED ]:(TEST FAILD) Inter frequency Handover Failed.
    END
    ${dt_status}    UE_keywords.check_data_transfer_is_alive_taf    dt_name=${Ul_traffic_dt_name}
    IF    '${dt_status}' == '${True}'
        BuiltIn.Log To Console    [ INFO ]:VRF_2(After Handover) UDP UL Data transfer ongoing.!
    ELSE
        Fail    [ FAILED ]: UDP UL Data Trafic failed.!
    END
    Run Keyword And Warn On Failure    UE_keywords.stop_data_transfer_taf    dt_name=${Ul_traffic_dt_name}
    Run Keyword And Continue On Failure    UE_keywords.Detach Ue via taf ue     ue_alias=${ue_alias}
    Run Keyword And Warn On Failure    Stop Btslog With Path Check    target_dir=${syslog_path}
    Wait Until Keyword Succeeds    10 min    1 min    logging_keywords.Stop_DCAP
    Validation.validate_syslog_file_contents    dir_path=${syslog_path}    search_string=${bad_uplink}
    ${Decoded Json File Path}    logging_keywords.DCAP_EMIL_DECODER    Utf Folder Path=${dcap_log_file}
    ${Status}    Validation.CB012601_Emil_Log_Validation    decoded_json_path=${Decoded_emil_path}    call_count=${1}
    Should Be True    ${Status} == ${True}
    [Teardown]    Run keywords    Common_keywords.set_attenuation_on_multi_port    ports=${Attenuator_Ports_1061_1063}
    ...    value=${value_in_dB}[-1]
    ...    Attenuator_device_config=${att}
    ...    AND    BuiltIn.Log To Console    [ INFO ]: ${TEST_NAME} : COMPLETED

Bad Uplink Radio Conditions After An Incoming Ng Handover Keyword
    [Documentation]    UE redirected to a intergNB TDD frequency layer due to
    ...    bad uplink radio conditions after an Incoming Ng handover
    Set Suite Variable    ${bad_uplink}    [bad uplink radio redirect]
    ${alarm_status}  BuiltIn.Run Keyword And Return Status  Validation.Acitive_Alarm_Verification_Test  ${ALLOWED_FAULT}
    IF    '${alarm_status}' == '${False}'     FAIL    Unexpected Alarm found.!
    Run Keyword And Continue On Failure    UE_keywords.Require UE
    FOR    ${port}    IN    @{Attenuator_Ports_1061_1063}
        Common_keywords.Set_attenuation_on_single_port  port=${port}  value=${value_in_dB}[-1]
        ...  Attenuator_device_config=${att}
        Sleep  2s
        BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[-1] set on port ${port}
    END
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[7]  value=${value_in_dB}[0]
    ...  Attenuator_device_config=${att}
    BuiltIn.Log To Console  [ INFO ]: Port ${Attenuator_Ports_1061_1063}[7] Value is ${value_in_dB}[0].
    Wait Until Keyword Succeeds  2 minute  20 s  UE_keywords.Attach Ue via taf ue  ue_alias=${ue_alias}
    ${Ul_traffic_dt_name}  UE_keywords.start_UL_UDP_traffic_for_ever  ue_alias=${ue_alias}
    BuiltIn.Log To Console  [ INFO ]: UDP UL Traffic is started.!
    ${dt_status}  UE_keywords.check_data_transfer_is_alive_taf  dt_name=${Ul_traffic_dt_name}
    IF  '${dt_status}' == '${True}'
        BuiltIn.Log To Console  [ INFO ]: UDP UL Data transfer ongoing.!
    ELSE
        Fail    [ FAILED ]: UDP UL Data Trafic failed.!
    END
    ${inter_HO_TDD_TDD_status}    Inter Frequency Handover TDD TDD CB0012601
    IF  '${inter_HO_TDD_TDD_status}' == 'True'
        BuiltIn.Log To Console    [ INFO ]: Inter frequency Handover(TDD->TDD) is done
    ELSE
        Fail    [ FAILED ]:(TEST FAILD)Inter Frequency Handover(TDD->TDD) Failed
    END
    ${dt_status}    UE_keywords.check_data_transfer_is_alive_taf    dt_name=${Ul_traffic_dt_name}
    IF  '${dt_status}' == '${True}'
        BuiltIn.Log To Console    [ INFO ]: UDP UL Data transfer ongoing.!
    ELSE
        Fail    [ FAILED ]: UDP UL Data Trafic failed.!
    END
    ${intra_HO_TDD_TDD_status}    Intra Frequency Handover TDD TDD CB0012601
    IF  '${intra_HO_TDD_TDD_status}' == 'True'
        BuiltIn.Log To Console    [ INFO ]: Intra frequency Handover(TDD->TDD) is done
    ELSE
        Fail    [ FAILED ]:(TEST FAILD)Intra Frequency Handover(TDD->TDD) Failed
    END
    ${dt_status}    UE_keywords.check_data_transfer_is_alive_taf    dt_name=${Ul_traffic_dt_name}
    IF  '${dt_status}' == '${True}'
        BuiltIn.Log To Console    [ INFO ]: UDP UL Data transfer ongoing.!
    ELSE
        Fail    [ FAILED ]: UDP UL Data Trafic failed.!
    END
    Run Keyword And Warn On Failure    UE_keywords.stop_data_transfer_taf    dt_name=${Ul_traffic_dt_name}
    Run Keyword And Continue On Failure    UE_keywords.Detach Ue via taf ue     ue_alias=${ue_alias}
    Run Keyword And Warn On Failure    Stop Btslog With Path Check    target_dir=${syslog_path}
    BuiltIn.Run Keyword And Continue On Failure    logging_keywords.Stop_DCAP
    Validation.validate_syslog_file_contents    dir_path=${syslog_path}    search_string=${bad_uplink}
    @{msg_check}	Create list		 DL RRC:rrcReleWITH NAMEe, redirect to nr
    logging_keywords.Emil_log_verification    @{msg_check}
    [Teardown]    Run keywords    Common_keywords.set_attenuation_on_multi_port    ports=${Attenuator_Ports_1061_1063}
    ...    value=${value_in_dB}[-1]
    ...    Attenuator_device_config=${att}
    ...    AND    BuiltIn.Log To Console    [ INFO ]: ${TEST_NAME} : COMPLETED

I RAT Blind Handover Redirection
    [Documentation]  Performing I-Rat Handover
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[6]  value=${value_in_dB}[0]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[6] set on port ${Attenuator_Ports_1061_1063}[0]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[2]  value=${value_in_dB}[1]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[1] set on port ${Attenuator_Ports_1061_1063}[2]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[2]  value=${value_in_dB}[2]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[2] set on port ${Attenuator_Ports_1061_1063}[2]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[2]  value=${value_in_dB}[3]
    ...  Attenuator_device_config=${att}
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[3] set on port ${Attenuator_Ports_1061_1063}[2]
    RETURN  ${True}

Inter Frequency Handover TDD TDD CB0012601
    [Documentation]    Performing Inter frequency handover TDD --> TDD
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[0]  value=${value_in_dB}[0]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[0] set on port ${Attenuator_Ports_1061_1063}[0]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[7]  value=${value_in_dB}[0]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[1] set on port ${Attenuator_Ports_1061_1063}[7]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[7]  value=${value_in_dB}[1]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[2] set on port ${Attenuator_Ports_1061_1063}[7]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[7]  value=${value_in_dB}[2]
    ...  Attenuator_device_config=${att}
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[3] set on port ${Attenuator_Ports_1061_1063}[7]
    Sleep  2s
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[7]  value=${value_in_dB}[3]
    ...  Attenuator_device_config=${att}
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[4] set on port ${Attenuator_Ports_1061_1063}[7]
    Sleep  2s
    RETURN  ${True}

Intra Frequency Handover TDD TDD CB0012601
    [Documentation]     performing Intra frequency Handover functionality
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[2]  value=${value_in_dB}[0]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[0] set on port ${Attenuator_Ports_1061_1063}[1]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[0]  value=${value_in_dB}[1]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[1] set on port ${Attenuator_Ports_1061_1063}[0]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[0]  value=${value_in_dB}[2]
    ...  Attenuator_device_config=${att}
    Sleep  2s
    BuiltIn.Log To Console  [ INFO ]: Attenuation value ${value_in_dB}[2] set on port ${Attenuator_Ports_1061_1063}[0]
    Common_keywords.Set_attenuation_on_single_port  port=${Attenuator_Ports_1061_1063}[0]  value=${value_in_dB}[3]
    ...  Attenuator_device_config=${att}
    RETURN  ${True}

Feature Activation CB012601
    [Documentation]    Does Feature activation parameter recommisssion on top of base scf.
    ${Status}    Login Using Selenium
    IF    '${Status}' != "${False}"
        ${NRCell_COUNT}    BuiltIn.Get Length    ${NRCell_list}
        FOR  ${index}  IN RANGE  ${NRCell_COUNT}
            Sbts_Selenium.set_parameter_value    ${NRCell_list}[${index}]
            ...    ${badULRedirectDeprioTimer}
            ...    new_value=${badULRedirectDeprioTimer_5min}
            Sbts_Selenium.add_element    ${NRCell_list}[${index}]    ${ulbler}
            Sbts_Selenium.set_parameter_value    ${NRCell_list}[${index}]
            ...    ${ulBlerThresholdRedirectData}
            ...    new_value=${ulblerPercentage}
            Sbts_Selenium.set_parameter_value    ${NRCell_list}[${index}]
            ...    ${ulBlerThresholdRedirectVoNR}
            ...    new_value=${ulblerPercentage}
            Sbts_Selenium.set_parameter_value    ${NRCell_list}[${index}]
            ...    ${actBadUplinkRadioRedirect}
            ...    new_value=${highUlBlerBased}
        END
        Sbts_Selenium.validate_plan
        Sbts_Selenium.activate_plan
        Logout And Close Browser
        ${Status}    NRREDRT Object Del
    ELSE
        Fatal Error    msg=[ ERROR ]:Selenium login Failed Check you BTS State
    END
    [Teardown]    Run Keyword   BuiltIn.Log To Console    [ INFO ]:Feature CB012601 flag activation completed

Login Using Selenium
    [Documentation]    Loging Web EM on web Driver for selenium operations.
    [Arguments]    ${Url}=https://192.168.255.129    ${UserName}=Nemuadmin    ${Passwd}=nemuuser
    Sbts_Selenium.Login    ${Url}    ${UserName}    ${Passwd}    timeout=60  wait_session_modal_timeout=60
    Sbts_Selenium.enable_virtual_display
    Sbts_Selenium.disable_message_box
    Sbts_Selenium.disable_screen_lock
    RETURN    ${True}

Logout And Close Browser
    Run Keyword And Ignore Error    Sbts_Selenium.close_start_up_view_window    timeout=5
    Run Keyword And Ignore Error    Sbts_Selenium.logout
    Run Keyword And Ignore Error    Sbts_Selenium.disable_virtual_display
    Run Keyword And Ignore Error    Sbts_Selenium.close_browser

NRREDRT Object Del
    [Documentation]    Get the list of NRREDRT object in currect scf and if exist remove all.
    [Arguments]    ${ObjectName}=NRREDRT    ${id}=0
    BuiltIn.Log To Console    [ INFO ]: NRREDRT Object Deletion is Started
    Login Using Selenium
    @{ObjectList}    Sbts_Selenium.get_object_name_list    ${ObjectName}
    IF    ${ObjectList}
        ${ObjectLength}    BuiltIn.Get Length    ${ObjectList}
        FOR    ${I}    IN RANGE    ${0}    ${4}                # ${ObjectLength}
            ${ObjNameIndex}    BuiltIn.Convert To String    ${ObjectList}[${I}]
            Sbts_Selenium.remove_object    ${ObjNameIndex}
            NRREDRT Obj Create
        END
    END
    RETURN    ${True}
    [Teardown]    Run Keywords   BuiltIn.Log To Console    [ INFO ]: NRREDRT Object Deletion is Completed.
    ...    AND    Logout And Close Browser

NRREDRT Obj Create
    [Documentation]    Add NRREDRT object in each cell with priority 1 with nr rat.
    [Arguments]    ${ObjectName}=NRREDRT    ${nr_id}=5    ${etura_id}=6    ${nr_prio}=1    ${eutra_prio}=2
    BuiltIn.Log To Console    [ INFO ]: NRREDRT Object Creation is Started.
    FOR    ${i}   IN    ${NRCell_list}
        @{NRcell}    String.Split String    ${i}    separator=/
        Sbts_Selenium.add_object    ${NRcell}[${-1}]    ${ObjectName}    id_value=${nr_id}
        Sbts_Selenium.set_parameter_value    ${i}/${ObjectName}-${nr_id}    ${redirRat}    new_value=${nr}
        Sbts_Selenium.set_parameter_value    ${i}/${ObjectName}-${nr_id}    ${redirSsbScs}    new_value=${Scs}
        Sbts_Selenium.set_parameter_value  ${i}/${ObjectName}-${nr_id}  ${redirFreqNr}  new_value=${arfcnssbPbch_1062}
        Sbts_Selenium.set_parameter_value    ${i}/${ObjectName}-${nr_id}    ${rediprio_name}    new_value=${nr_prio}

        Sbts_Selenium.add_object    ${NRcell}[${-1}]    ${ObjectName}    id_value=${etura_id}
        Sbts_Selenium.set_parameter_value    ${i}/${ObjectName}-${etura_id}    ${redirRat}    new_value=${eutra}
        Sbts_Selenium.set_parameter_value    ${i}/${ObjectName}-${etura_id}    ${redirPrioBadUlRadio}    new_value=${eutra_prio}
        Sbts_Selenium.set_parameter_value  ${i}/${ObjectName}-${etura_id}    ${redirFreqNr}  new_value=${erfcn_eutra}
        Sbts_Selenium.set_parameter_value  ${i}/${ObjectName}-${etura_id}    ${rediprio_name}   new_value=${eutra_prio}
    END
    Sbts_Selenium.validate_plan
    Sbts_Selenium.activate_plan
    RETURN    ${True}
    [Teardown]    Run Keyword    BuiltIn.Log To Console    [ INFO ]: NRREDRT Object Creation is Completed.
