*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Force Tags      RF50

Resource        ./resources/main_kw.robot
Resource        ./resources/wts_kw.robot
Resource        ./resources/l3call_kw.robot
Library         ta5g_throughput
Library         testsuite.Krakow.RRM.Airphone.CB012511.resources.egate_CB012511  WITH NAME  Validation

Test Setup        Generic Test Setup 2APs    check_ap_bh_ip2=${True}
Test Teardown     Generic Test Teardown 2APs    do_not_stop_egate=${True}

*** Variables ***
${EXPECTED_DL_TPUT}    100
${EXPECTED_UL_TPUT}    50
${START_UE_ID}         1
${END_UE_ID}           12
${START_TRF_ID}        1
${END_TRF_ID}          1
${TPUT}                100mbps
${BACKGROUND_TPUT}     1mbps
${ITER_TPUT_VALID}     18
${ITER_TPUT_STAB}      2160
${EGATE_PORT}          20000
${DIR}                 bidir
${UE_ID_STRING}        1-12
${UE_ID_CB014169}      11-15,21-25,31-35,41-45,51-55,61-65,71-75,81-85,91-95
${trf_duration}        300
@{MAIN_UEs}            11    21    31    41    51    61    71    81    91
@{UE_100}              11    31    51
@{UE_50}               21    41    61
@{UE_FDD}              71    81    91


*** Test Cases ***
Cell_Lock_Unlock_With_L3_Call
    [Documentation]         Test case with Block and Unblock Cells procedure
    Log To Console          Start Lock and Unlock All Cells Procedure
    Cells.Lock All Cells                administrative_state={True}
    Wait Until Keyword Succeeds         5x    1s    Cells.Verify All Cells Are Locked
    Sleep    60s
    Cells.Unlock All Cells              administrative_state={True}
    Wait Until Keyword Succeeds         5x    1s    Cells.Verify All Cells Are OnAir
    Sleep    60s
    Wait for gNB To Be Ready
    Start SA L3Call 2APs

Radio_Lock_Unlock_With_L3_Call
    [Documentation]         Test case with Lock and Unlock Radio Units via WebEM procedure
    Log To Console          Start Lock and Unlock All Radios Procedure
    Radio.Lock All Radio Unit
    Wait Until Keyword Succeeds         5x    1s    Radio.Verify Radio Unit Is Locked
    Sleep    60s
    Radio.Unlock All Radio Unit
    Wait Until Keyword Succeeds         5x    1s    Radio.Verify Radio Unit Is Unlocked
    Sleep    60s
    Wait for gNB To Be Ready
    Start SA L3Call 2APs

Radio_Module_Reset_With_L3_call
    [Documentation]         Test case with Reset Radio Units procedure
    Log To Console          Start All Radios Reset Procedure
    Radio.Reset All Radio Unit
    Log To Console          Waiting for OnAir after Radio units reset
    Radio.Wait For Radio Unit To Be Online  timeout=180
    Wait for gNB To Be Ready
    Start SA L3Call 2APs

CB012511_AP_A3_General_SiSo_stability_with_L3Call
    ${UE_LIST}=    Validation.Create UE List    1,7

    Validation.Setup All Egate Connections    ue_ids=${UE_LIST}
    ...                                       egate_port=${EGATE_PORT}    directions=${DIR}

    FOR    ${id}    IN    @{UE_LIST}
        UE Register 2AP                       single_ue_id=${id}
        Start Traffic For SA UEs              single_ue_id=${id}    dir=${DIR}    start_trf_id=${START_TRF_ID}
        ...                                   end_trf_id=${END_TRF_ID}    mbps=${TPUT}
    END
    Run Keyword And Continue On Failure       Validation.Validate Bearer Stats for UEs
    ...                                       ue_ids=${UE_LIST}
    ...                                       expected_tput_dl=${EXPECTED_DL_TPUT}
    ...                                       expected_tput_ul=${EXPECTED_UL_TPUT}
    ...                                       directions=${DIR}    iterations=${ITER_TPUT_STAB}
    FOR    ${id}    IN    @{UE_LIST}
        Stop Traffic For SA UEs               single_ue_id=${id}
    END

CB012511_AP_A3_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    ${UE_LIST}=    Validation.Create UE List    ${UE_ID_STRING}

    Validation.Setup All Egate Connections        ue_ids=${UE_LIST}
    ...                                           egate_port=${EGATE_PORT}    directions=${DIR}

    FOR    ${id}    IN    @{UE_LIST}
        UE Register 2AP                           single_ue_id=${id}
        Start Traffic For SA UEs                  single_ue_id=${id}    dir=${DIR}    start_trf_id=${START_TRF_ID}
        ...                                       end_trf_id=${END_TRF_ID}    mbps=${TPUT}
        Run Keyword And Continue On Failure       Validation.Validate Bearer Stats for UEs
        ...                                       ue_ids=${id}
        ...                                       expected_tput_dl=${EXPECTED_DL_TPUT}
        ...                                       expected_tput_ul=${EXPECTED_UL_TPUT}
        ...                                       directions=${DIR}    iterations=${ITER_TPUT_VALID}
        Stop Traffic For SA UEs                   single_ue_id=${id}
    END

CB012511_AP_A3_Common_SiSo_Call_Multi_UE_throughput_testing
    Start SA L3Call 2APs

Site_Reset_With_L3_Call
    [Documentation]         Test case with Site Reset procedure
    Log To Console          Start Site Reset Procedure
    Du.Reset Bts
    Execute Egate Command    cmd=stop    #Remove after improvement from AP CNI
    Execute Egate Command    cmd=reset    #Remove after improvement from AP CNI
    Stop Edaemon and Egate processes    #Remove after improvement from AP CNI
    Log To Console           Waiting for OnAir after BBMOD reset
    #Du.Wait For Site To Be OnAir    #Add after improvement from AP CNI
    Wait for gNB To Be Ready
    Teardown All Aliases For Wts    #Remove after improvement from AP CNI
    Test Case Setup          reach_on_air=without_x2_link    #Remove after improvement from AP CNI
    Sleep    60s
    Start SA L3Call 2APs

SR_STABILITY_L3CALL
    ${UE_LIST}=    Create List
    FOR    ${i}    IN RANGE    1    13
        ${UE}=    Set Variable    ${i}
        Append To List    ${UE_LIST}    ${UE}
    END
    UE Register 2AP             start_ue_id=1    end_ue_id=13
    Start Traffic For SA UEs    start_ue_id=1    end_ue_id=13    dir=dl
    ...                         start_trf_id=1    end_trf_id=2    mbps=10mbps
    Start Traffic For SA UEs    start_ue_id=1    end_ue_id=13    dir=ul
    ...                         start_trf_id=1    end_trf_id=2    mbps=10mbps
    Log To Console              Waiting 10 min
    Sleep    600s
    Expected Throughput For List Of Ues Should Be Reached    ues_list=${UE_LIST}    throughput=10
    ...                                                      direction=dl    selection_type=average
    ...                                                      retry=20    margin=0.15
    Expected Throughput For List Of Ues Should Be Reached    ues_list=${UE_LIST}    throughput=10
    ...                                                      direction=ul    selection_type=average
    ...                                                      retry=20    margin=0.15
    Stop Traffic For SA UEs     start_ue_id=${START_UE_ID}    end_ue_id=${END_UE_ID}

CB014169_General_SiSo_Call_Multi_UE_throughput_testing
    CB014169 Start SA L3Call 2APs


*** Keywords ***
Start SA L3Call 2APs
    ${UE_LIST}=    Validation.Create UE List    ${UE_ID_STRING}

    Validation.Setup All Egate Connections    ue_ids=${UE_LIST}
    ...                                       egate_port=${EGATE_PORT}    directions=${DIR}

    UE Register 2AP                           start_ue_id=${START_UE_ID}    end_ue_id=${END_UE_ID}

    Start Traffic For SA UEs                  start_ue_id=${START_UE_ID}    end_ue_id=${END_UE_ID}    dir=${DIR}
    ...                                       start_trf_id=${START_TRF_ID}    end_trf_id=${END_TRF_ID}    mbps=${TPUT}

    Run keyword And Continue On Failure       Validation.Validate Bearer Stats for UEs    ue_ids=${UE_LIST}
    ...                                       expected_tput_dl=${EXPECTED_DL_TPUT}
    ...                                       expected_tput_ul=${EXPECTED_UL_TPUT}
    ...                                       directions=${DIR}    iterations=${ITER_TPUT_VALID}

    Stop Traffic For SA UEs                   start_ue_id=${START_UE_ID}    end_ue_id=${END_UE_ID}

CB014169 Start SA L3Call 2APs
    @{UE_LIST}=    Validation.Create UE List    ${UE_ID_CB014169}

    FOR    ${ue_id}    IN    @{UE_LIST}
        UE Register 2AP                       single_ue_id=${ue_id}
    END
    sleep    2
    FOR    ${ue_id}    IN    @{UE_LIST}
        Log to console    ${ue_id}
        ${ue_id_str}    Convert To String    ${ue_id}
        IF    $ue_id_str in $UE_100
            Start Traffic For Single UE    ue_id=${ue_id}    dir=dl   start_trf_id=1    end_trf_id=4    mbps=110mbps
            Start Traffic For Single UE    ue_id=${ue_id}    dir=ul
            ...                            start_trf_id=${START_TRF_ID}    end_trf_id=${END_TRF_ID}    mbps=${BACKGROUND_TPUT}
        ELSE IF    $ue_id_str in $UE_50
            Start Traffic For Single UE    ue_id=${ue_id}    dir=dl   start_trf_id=1    end_trf_id=2    mbps=110mbps
            Start Traffic For Single UE    ue_id=${ue_id}    dir=ul
            ...                            start_trf_id=${START_TRF_ID}    end_trf_id=${END_TRF_ID}    mbps=${BACKGROUND_TPUT}
        ELSE IF    $ue_id_str in $UE_FDD
            Start Traffic For Single UE    ue_id=${ue_id}    dir=dl   start_trf_id=1    end_trf_id=1    mbps=10mbps
            Start Traffic For Single UE    ue_id=${ue_id}    dir=ul
            ...                            start_trf_id=${START_TRF_ID}    end_trf_id=${END_TRF_ID}    mbps=${BACKGROUND_TPUT}
        ELSE
            Start Traffic For Single UE    ue_id=${ue_id}    dir=bidir
            ...                            start_trf_id=${START_TRF_ID}    end_trf_id=${END_TRF_ID}    mbps=${BACKGROUND_TPUT}
        END
    END
    Log to console    Sleeping after starting traffic
    sleep    30
    &{EXPECTED_DL_TPUTS}=    Create Dictionary
    ...    11=440    21=220    31=440    41=220    51=440    61=220
    ...    71=10    81=10    91=10
    Validation.Validate UE Stats for UEs      expected_tput_dl=&{EXPECTED_DL_TPUTS}
    ...                                       expected_tput_ul=1
    ...                                       ue_ids=${MAIN_UEs}
    ...                                       duration=${trf_duration}    directions=bidir
