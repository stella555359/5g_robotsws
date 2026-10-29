*** Settings ***
Documentation
...           Description : Test Cases for CB009051

Library    ute_ue                    WITH NAME    ue
Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.collectors.pmcounters   WITH NAME    pm
Library      ../../resources/pm_analyze.py          WITH NAME      pm_analyze
Resource     ../../resources/sg_radio_perf/robot/preconditions.robot
Resource     ../../resources/pm_collection.robot

#Force Tags    QCD_MN_RAN    QCP_RAN_ST     CA_RAN_PZ_NPS

*** Variables ***
${enb_id}=    0
${ue_alias}=    UE_1
${ue_capa}=    REAL_ANDROID_UE
${meas_period_gnb}=    5
${meas_period_enb}=    15
${additional_time_sec}=    60
${DEBUG_MODE_CONSOLE}=    ${True}
${M8013C133_expected}=    ${1}
${M8013C134_expected}=    ${2}
${M8013C135_expected}=    ${2}


*** Test cases ***
[1][1.0] CB009051_SR_A_2_AB101_LTE_FDD_Initial_Context_Setup_segmentation
    [Setup]    Get Scout Bts Name
    [Teardown]    Set Scout Confid Id

    pm_collection.Wait For Next Measurement Period
    ...    meas_period_in_minute=${meas_period_enb}
    ...    additional_waiting_time_sec=10
    ...    enb=${enb_id}

    ue.require_ue    ue_alias=${ue_alias}    capabilities=${ue_capa}
    ue.detach_ue    ue_alias=${ue_alias}
    #ue.reboot_ue    ${ue_alias}
    #ue.software_reset    ${ue_alias}    timeout=90
    ue.attach_ue    ue_alias=${ue_alias}
    sleep      60s
    ue.detach_ue    ue_alias=${ue_alias}

    ue.attach_ue    ue_alias=${ue_alias}
    sleep      60s
    ue.detach_ue    ue_alias=${ue_alias}

    pm_collection.Wait For Next Measurement Period
    ...    meas_period_in_minute=${meas_period_enb}
    ...    additional_waiting_time_sec=${additional_time_sec}
    ...    enb=${enb_id}

    ${M8013C133}=    Get Counter Value    counter_name=M8013C133    enb_id=${enb_id}
    ${M8013C134}=    Get Counter Value    counter_name=M8013C134    enb_id=${enb_id}
    ${M8013C135}=    Get Counter Value    counter_name=M8013C135    enb_id=${enb_id}

    Log To Console    \nM8013C133 = LTE_UE_CAP_INFO_SEG_SUCC : ${M8013C133} ; expected : ${M8013C133_expected}
    Log To Console    M8013C134 = LTE_UE_CAP_INFO_SEG_MAX : ${M8013C134} ; expected : ${M8013C134_expected}
    Log To Console    M8013C135 = LTE_UE_CAP_INFO_SEG_AVG : ${M8013C135} ; expected : ${M8013C135_expected}

    Should Be Equal    ${M8013C133}    ${M8013C133_expected}
    Should Be Equal    ${M8013C134}    ${M8013C134_expected}
    Should Be Equal    ${M8013C135}    ${M8013C135_expected}
