*** Settings ***
Documentation
...   author: Wu Pengliang
...   contact: pengliang.wu@nokia-sbell.com
...   this script for feature CNI-147150 dynamic ssb generation, purpose to verify dynamic ssb genration beam weight expected
...   as legacy 45/45 or 60/60 or 5g MAX simulation for other asymmetric angle 10/20/30/40/45/50/60

Suite Setup    Common Suit Setup
Suite Teardown    CNI_147150 common Suit Teardown

Resource    ./resources/CNI147150_common_keyword.robot
Variables    ./resources/CNI147150_Params.py


*** Test Cases ***
[1]CNI_147150-B_013_IWK_with_Load_generator_for_EMF_L_10_R_60
    [Documentation]    this case is used to verify EMF and EIRP work well after Dynamic SSB enabled
    ...    online change EIRP will trigger EIRP gain recalculation by CP-RT and send L2PS
    ...    EMF and EIRP counter should updated as well
    [Tags]    CNI-147150-B    T729
    [Setup]    CNI147150 Common Case Setup
    Step0 Test Case Level Gloal Paramter Setting
    Step1 Online Disable actEmfTestMode And actEirpControl
    Wait Until Keyword Succeeds    10min  60s  Step1.1 EMF and EIRP Counter Should Not Update
    Step2 Online Enable actEmfTestMode And actEirpControl Without eirpControlPowerReduction
    Wait Until Keyword Succeeds    10min  60s  Step2.1 Check EMF Counter Updated And EIRP Counter Not Updated
    Step3 Online change eirpControlPowerReduction To Trigger EIRP Control
    Wait Until Keyword Succeeds    10min  60s  Step3.1 Check Both EMF And EIRP Counter Updated
    Step4 Online Disable DynSSB and Compare BEAM EMF With Legacy
    Step5 Online Enalbe Muted SSB And NrBtsBeamRefinementP2
    Step1 Online Disable actEmfTestMode And actEirpControl    if_disable_pmi_and_srs=${False}
    [Teardown]    Run keywords    Enable PMI AND SRS Beam    AND    CNI147150 Common Case Teardown

[1]CNI_147150-A_002_Verify_SSB_and_refined_beam_generation_AQQJ_successfully_with_L_10_R_45_Beamset_2
    [Documentation]    Check Beam weight VS 5gmax
    [Setup]    CNI147150 Common Case Setup
    ${NRCELL_id}    set variable    ${0}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    FOR    ${beamConfig}    IN    @{BeamConfigList}
        Modify Parameter and check beam weight with 5gMax    beamConfig=${beamConfig}    NRCELL_id=${NRCELL_id}
    END
    [Teardown]    CNI147150 Common Case Teardown

[1]CNI_147150-A_005_Verify_SSB_and_refined_beam_generation_AQQJ_successfully_with_L_60_R_10_Beamset_4
    [Documentation]    ssb index check from Spark UE log for beamSet_6_L45_R50
    [Setup]    CNI147150 Common Case Setup
    ${NRCELL_id}    set variable    ${0}
    ${beamConfig}    set variable    beamSet_6_L45_R50
    ${matrix_id}    set variable    ${1}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Modify Parameter and check beam weight with 5gMax    beamConfig=${beamConfig}    actDynSsbBeamGen=${True}
    ...    other_parameter=${PARA_SRS_True}    NRCELL_id=${NRCELL_id}
    Log to console    sleep ${RF_calibration_time}, wait for RF calibration_time
    sleep    ${RF_calibration_time}
    ${log_list_dl}    X65 L3 call and traffic    if_dl=${True}    beamConfig=${beamConfig}
    Log to console    dl:${log_list_dl}
    check UE Tput with MUMIMO    ue_log_list=${log_list_dl}    if_dl=${True}    expected_dl_tput=${1400}
    ${log_list_ul}    X65 L3 call and traffic    if_ul=${True}    beamConfig=${beamConfig}    if_require_ue=${False}
    Log to console    ul:${log_list_ul}
    check UE Tput with MUMIMO    ue_log_list=${log_list_ul}    if_ul=${True}    expected_ul_tput=${100}
    [Teardown]    CNI147150 Common Case Teardown

[1]CNI_147150-B_005_enable_actDynSsbBeamGen_during_BTS_stay_in_Mmimo_muting_power_saving
    [Documentation]    PowerSaving: beamSet_4_L45_R45
    [Setup]    CNI147150 Common Case Setup
    ${NRCELL_id}    set variable    ${0}
    ${beamConfig}    set variable    beamSet_4_L45_R45
    ${matrix_id}    set variable    ${1}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${NRPGRP_NEW}    Update NRPGRP
    ${other_parameter}    Combine Lists    ${PARA_SRS_True}    ${NRPGRP_NEW}    ${PARA_EMF_False}    ${PARA_EIRP_False}
    Modify Parameter and check beam weight with 5gMax    beamConfig=${beamConfig}    NRCELL_id=${NRCELL_id}
    ...    actDynSsbBeamGen=${True}    actNrLBmMimoRTXPowerSaving=${True}    other_parameter=${other_parameter}
    ${cur_time}    DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Log to console    current time: ${cur_time}, sleep ${RF_calibration_time}, wait for RF calibration_time
    sleep    ${RF_calibration_time}
    Check BTS PowerSaving Status    NRCELL_id=${NRCELL_id}    expected_status=reducedEnergySaving
    ${log_list_dl}    X65 L3 call and traffic    if_dl=${True}    beamConfig=${beamConfig}    log_time=80s
    Log to console    dl:${log_list_dl}
    Run Keyword And Ignore Error    Check UE RANK impacted by PowerSaving    ue_log_list=${log_list_dl}
    Check BTS PowerSaving Status    NRCELL_id=${NRCELL_id}    expected_status=notEnergySaving
    [Teardown]    CNI147150 Common Case Teardown

[1]CNI_147150-B_009_IWK_with_DFT_PMI_Beam_should_be_same_as_legacy_with_60_beamset6
    [Documentation]    DFT PMI beam compare with legacy
    [Setup]    CNI147150 Common Case Setup
    ${NRCELL_id}    set variable    ${0}
    ${beamConfig}    set variable    beamSet_6_L60_R60
    ${matrix_id}    set variable    ${1}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    FOR    ${loop}    IN RANGE    ${2}
        Log to console    loop:${loop}
        Setup Commission SCF    bts_host=${gNB_ip}
        Check GNB on air    bts_host=${gNB_ip}
        ${NRPGRP_NEW}    Update NRPGRP    lbpsDuration=1
        ${other_parameter}    Combine Lists    ${PARA_SRS_True}    ${NRPGRP_NEW}    ${PARA_EMF_False}    ${PARA_EIRP_False}
        Run Keyword And Continue On Failure    Modify Parameter and check beam weight with 5gMax
        ...    beamConfig=${beamConfig}    NRCELL_id=${NRCELL_id}
        ...    actDynSsbBeamGen=${False}    actNrLBmMimoRTXPowerSaving=${True}    other_parameter=${other_parameter}
        ${beamWeightNonSsb_false}    beamObj.getNonDynSsbBeamWeight
        Run Keyword And Continue On Failure    Modify Parameter and check beam weight with 5gMax
        ...    beamConfig=${beamConfig}    NRCELL_id=${NRCELL_id}
        ...    actDynSsbBeamGen=${True}    actNrLBmMimoRTXPowerSaving=${True}    other_parameter=${other_parameter}
        ${beamWeightNonSsb_true}    beamObj.getNonDynSsbBeamWeight
        ${result}    run keyword and return status    should be true    ${beamWeightNonSsb_false}==${beamWeightNonSsb_true}
        Run Keyword And Continue On Failure    should be true    ${result}
        Run keyword if    '${result}'=='False'    Save Snapshot    bts_host=${gnb_ip}
    END
    Log to console    sleep ${RF_calibration_time}, wait for RF calibration_time
    sleep    ${RF_calibration_time}
    ${log_list_dl}    X65 L3 call and traffic    if_dl=${True}    beamConfig=${beamConfig}
    Log to console    dl:${log_list_dl}
    check UE Tput with MUMIMO    ue_log_list=${log_list_dl}    if_dl=${True}    expected_dl_tput=${1400}
    ${log_list_ul}    X65 L3 call and traffic    if_ul=${True}    beamConfig=${beamConfig}    if_require_ue=${False}
    Log to console    ul:${log_list_ul}
    check UE Tput with MUMIMO    ue_log_list=${log_list_ul}    if_ul=${True}    expected_ul_tput=${100}
    [Teardown]    CNI147150 Common Case Teardown

[1]CNI_147150-B_010_IWK_with_DFT_PMI_Beam_with_L_20_R_50_beamset4
    [Documentation]    new angle for beamConfig: beamSet4_L20_R50
    [Setup]    CNI147150 Common Case Setup
    ${NRCELL_id}    set variable    ${0}
    ${beamConfig}    set variable    beamSet_4_L20_R50
    ${matrix_id}    set variable    ${1}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Modify Parameter and check beam weight with 5gMax    beamConfig=${beamConfig}    NRCELL_id=${NRCELL_id}
    ...    actDynSsbBeamGen=${True}    actNrLBmMimoRTXPowerSaving=${True}    other_parameter=${PARA_SRS_True}
    Log to console    sleep ${RF_calibration_time}, wait for RF calibration_time
    sleep    ${RF_calibration_time}
    ${log_list_dl}    X65 L3 call and traffic    if_dl=${True}    beamConfig=${beamConfig}
    Log to console    dl:${log_list_dl}
    check UE Tput with MUMIMO    ue_log_list=${log_list_dl}    if_dl=${True}    expected_dl_tput=${1400}
    ${log_list_ul}    X65 L3 call and traffic    if_ul=${True}    beamConfig=${beamConfig}    if_require_ue=${False}
    Log to console    ul:${log_list_ul}
    check UE Tput with MUMIMO    ue_log_list=${log_list_ul}    if_ul=${True}    expected_ul_tput=${100}
    [Teardown]    CNI147150 Common Case Teardown

[1]CNI_147150-A_001_Verify_SSB_and_refined_beam_generation_successfully_with_L_45_R_45_Beamset_1
    [Documentation]    Beamset1_L45_R45
    [Setup]    CNI147150 Common Case Setup
    ${NRCELL_id}    set variable    ${0}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${other_parameter}    Combine Lists    ${PARA_EMF_False}    ${PARA_SRS_False}    ${PARA_EIRP_False}    ${PARA_Beamset1}
    Modify Parameters With Json    input_list=${other_parameter}    connection=beam_para_change
    Check GNB on air    time=5min
    FOR    ${beamConfig}    IN    @{BeamConfigList3}
        Modify Parameter and check beam weight with 5gMax    beamConfig=${beamConfig}    NRCELL_id=${NRCELL_id}
    END
    Recovery Non Beamset1 Configuration
    [Teardown]    CNI147150 Common Case Teardown

*** Keywords ***
Step0 Test Case Level Gloal Paramter Setting
    Log To Console     Step0 Paramter Setting For BasicBeam
    Set Test Variable    ${NRCELL_id}    ${0}
    Set Test Variable    ${beamConfig}    beamSet_6_L60_R60
    Set Test Variable    ${beamConfig_Dyn}    beamSet_6_L30_R60
    ${beam_cfg_lst}    Split String    ${beamConfig}    separator=_
    Set Test Variable    ${BEAM_NUM}    ${beam_cfg_lst[1]}
    Run Keyword If    ${BEAM_NUM} > 5    Set Test Variable    ${BEAM_NUM}    5
    Set Test Variable    ${CELL_DN}    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
#    Setup Commission SCF    scf_name=_2    timeout=600
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min    interval=180

Step1 Online Disable actEmfTestMode And actEirpControl
    [Arguments]    ${if_disable_pmi_and_srs}=${True}
    Log To Console    Stepx Online Disable actEmfTestMode And actEirpControl And Check Counter
    ${DISABLE_EMF_PARAMS}    update_parameters_dn    cell_dn=${CELL_DN}    nrcellgrp_dn=""    params=${DISABLE_EMF_PARAMS}
    ${disable_emf_and_pmi_srs}    Combine Lists    ${DISABLE_EMF_PARAMS}    ${PARA_PMI_False}    ${PARA_SRS_False}
    ${other_parameter}    set variable if    ${if_disable_pmi_and_srs}    ${disable_emf_and_pmi_srs}    ${DISABLE_EMF_PARAMS}
    Modify Beam Paramters    beamConfig=${beamConfig}    other_parameter=${other_parameter}
    ...    actDynSsbBeamGen=false    actNrLBmMimoRTXPowerSaving=true
    ...    NRCELL_id=${NRCELL_id}     nrBtsBeamRefinementP2=false    beamsMuted=0
    ${emf_info}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    NRBEAM EMF Infor Should Be As Expected    emf_info_list=${emf_info}    expected_emf_num=0    dynSSB=false

Step1.1 EMF and EIRP Counter Should Not Update
    Log To Console    Step1 EMF and EIRP Counter Should Not Update
    ${counter_value_list}    Get BTS Counter For EMF And EIRP    NRCELL_ID=NRCELL-${NRCELL_id}
    Both EMF and EIRP Counter Should Be 0    counter_value_list=${counter_value_list}

Step2 Online Enable actEmfTestMode And actEirpControl Without eirpControlPowerReduction
    Log To Console    Step1 Online Enable actEmfTestMode And actEirpControl Without eirpControlPowerReduction
    ...    Online Change actDynSsbBeamGen For basicBeamSet2 L_10_R_60
    ${ENABLE_EMF_PARAMS}    update_parameters_dn    cell_dn=${CELL_DN}    nrcellgrp_dn=""    params=${ENABLE_EMF_PARAMS}
    Modify Beam Paramters    beamConfig=${beamConfig_Dyn}    other_parameter=${ENABLE_EMF_PARAMS}
    ...    actDynSsbBeamGen=true    actNrLBmMimoRTXPowerSaving=true
    ...    NRCELL_id=${NRCELL_id}    nrBtsBeamRefinementP2=false    beamsMuted=0
    ${emf_info}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    NRBEAM EMF Infor Should Be As Expected    emf_info_list=${emf_info}    expected_emf_num=${BEAM_NUM}    dynSSB=true

Step2.1 Check EMF Counter Updated And EIRP Counter Not Updated
    Log To Console    Step2 Check EMF Counter Updated And EIRP Counter Not Updated
    ${counter_value_list}    Get BTS Counter For EMF And EIRP    NRCELL_ID=NRCELL-${NRCELL_id}
    EMF Counter Should Updated And EIRP Not Updated    counter_value_list=${counter_value_list}

Step3 Online change eirpControlPowerReduction To Trigger EIRP Control
    Log To Console    Step3 Online change eirpControlPowerReduction To Trigger EIRP Control
    ${ENABLE_EIRP_PARAMS}    update_parameters_dn    cell_dn=${CELL_DN}    nrcellgrp_dn=""    params=${ENABLE_EIRP_PARAMS}
    Modify Beam Paramters    beamConfig=${beamConfig_Dyn}    other_parameter=${ENABLE_EIRP_PARAMS}
    ...    actDynSsbBeamGen=true    actNrLBmMimoRTXPowerSaving=true
    ...    NRCELL_id=${NRCELL_id}    nrBtsBeamRefinementP2=false    beamsMuted=0
    ${emf_info}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    NRBEAM EMF Infor Should Be As Expected    emf_info_list=${emf_info}    expected_emf_num=${BEAM_NUM}    dynSSB=true

Step3.1 Check Both EMF And EIRP Counter Updated
    Log To Console    Step3.1 Check Both EMF And EIRP Counter Updated
    ${counter_value_list}    Get BTS Counter For EMF And EIRP    NRCELL_ID=NRCELL-${NRCELL_id}
    Both EMF and EIRP Counter Should Be Updated    counter_value_list=${counter_value_list}

Step4 Online Disable DynSSB and Compare BEAM EMF With Legacy
    Log To Console    Step5 Online Disable DynSSB and Compare BEAM EMF With Legacy
    ${ENABLE_EIRP_PARAMS}    update_parameters_dn    cell_dn=${CELL_DN}    nrcellgrp_dn=""    params=${ENABLE_EIRP_PARAMS}
    Modify Beam Paramters    beamConfig=${beamConfig}    other_parameter=${ENABLE_EIRP_PARAMS}
    ...    actDynSsbBeamGen=true    actNrLBmMimoRTXPowerSaving=true
    ...    NRCELL_id=${NRCELL_id}    nrBtsBeamRefinementP2=false    beamsMuted=0
    ${emf_info_dynssb}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    ${ENABLE_EIRP_PARAMS}    update_parameters_dn    cell_dn=${CELL_DN}    nrcellgrp_dn=""    params=${ENABLE_EIRP_PARAMS}
    Modify Beam Paramters    beamConfig=${beamConfig}    other_parameter=${ENABLE_EIRP_PARAMS}
    ...    actDynSsbBeamGen=false    actNrLBmMimoRTXPowerSaving=true
    ...    NRCELL_id=${NRCELL_id}    nrBtsBeamRefinementP2=false    beamsMuted=0
    ${emf_info_legacy}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    NRBEAM EMF Infor Should Be As Expected    emf_info_list=${emf_info_legacy}    expected_emf_num=${BEAM_NUM}    dynSSB=false
    Legacy and DynSSB EMF Beam Num And Gain Should Be Same    legacy_emf_lst=${emf_info_legacy}   dynssb_emf_lst=${emf_info_dynssb}

Step5 Online Enalbe Muted SSB And nrBtsBeamRefinementP2
    Log To Console    Step5 Online Enalbe Muted SSB And nrBtsBeamRefinementP2
    ${other_parameter}    Combine Lists    ${PARA_csirsBeamMgmt}    ${PARA_DlDynSwitch_False}
    Modify Beam Paramters    beamConfig=${beamConfig}
    ...    actDynSsbBeamGen=false    actNrLBmMimoRTXPowerSaving=false
    ...    NRCELL_id=${NRCELL_id}    nrBtsBeamRefinementP2=true    beamsMuted=12
    ...    other_parameter=${other_parameter}
    ${emf_info_legacy}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    Modify Beam Paramters    beamConfig=${beamConfig}
    ...    actDynSsbBeamGen=True    actNrLBmMimoRTXPowerSaving=false
    ...    NRCELL_id=${NRCELL_id}    nrBtsBeamRefinementP2=true    beamsMuted=12
    ${emf_info_dynssb}     Get NRBEAM_EMF infomation    bts_host=${gNB_ip}    NRCELL_id=${NRCELL_id}
    NRBEAM EMF Infor Should Be As Expected    emf_info_list=${emf_info_dynssb}    expected_emf_num=${BEAM_NUM}    dynSSB=true
    Legacy and DynSSB EMF Beam Num And Gain Should Be Same    legacy_emf_lst=${emf_info_legacy}   dynssb_emf_lst=${emf_info_dynssb}
