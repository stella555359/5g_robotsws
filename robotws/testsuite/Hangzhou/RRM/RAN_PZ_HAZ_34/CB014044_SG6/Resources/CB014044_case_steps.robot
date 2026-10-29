*** Settings ***
Documentation    CB010708 TA cases common steps
...              Author: xiaoxia.hao@nokia-sbell.com

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044_SG6/Resources/CB014044_common_keywords.robot
Variables     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044_SG6/Resources/CB014044_Variables.py

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
CB014044-C_1_Validation_of_actFdAlgoEnh_for_Non-GBR Bearers_DL_FDD
    Run Keyword And Continue On Failure    Start SA L3 Call And Check Tput    traffic_infor=${CB014044_C_1_3UE_FDD_20MHz}
    ...                                                                    expect_ul_tput=113
    ...                                                                    expect_dl_tput=399
    ...                                                                    cellid=1
    ...                                                                    is_detach=${False}
    ...                                                                    target_avg_percent=0.98
    ...                                                                    min_percent=0.8
    Update 14044 Param Value
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=113
    ...                                                                expect_dl_tput=399
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.98
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0.8
    UPdate RD Paramter for CB014044
    Run Keyword And Continue On Failure    Get And Check NKListBuildAlgoBase Information from Syslog
    Run Keyword And Ignore Error    Capture TTI with gnb logs    cell_index=1    duration=5    bbmod_slots=6
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic And UE Deattach For SA On AP    traffic_infor=${CB014044_C_1_3UE_FDD_20MHz}

CB008242-D_IWK1_Automatic UAC load triggers interactions_automatic UAC upgrade by number of RRC connections
    ${gnb_allowed_fault_8242}   Create List    7533
    Set Test Variable    ${gnb_allowed_fault_8242}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_8242}
    Execute Egate Command    cmd=ue_register id=201
    Sleep    2sec
    Execute Egate Command    cmd=set_pdu_param ue=201 pdu=1 default_qos_flow=1 trf_type=internal
    Sleep    2sec
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=201 nwslice=1
    Sleep    90sec
    Run Keyword And Continue On Failure    check 7533 alarm report On gNB
    Start tcpdump from gNB
    Execute Egate Command    cmd=ue_register id=202
    Sleep    2sec
    Execute Egate Command    cmd=set_pdu_param ue=202 pdu=1 default_qos_flow=1 trf_type=internal
    Sleep    2sec
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=202 nwslice=1
    sleep    300s
    ${log_full_path_ute}    Stop Tcpdump from gNB
    Check uac_BarringFactor Infor From Tcpdump    log_full_path_ute=${log_full_path_ute}
    [Teardown]    run keywords
    ...                  Run Keyword And Ignore Error    Stop Traffic And UE Deattach For SA On AP    traffic_infor=${CB008242_D_2UE_FDD_20MHz}
    ...           AND    Run Keyword And Ignore Error    check 7533 alarm Cancel On gNB

CB008242-C_#B2 Downgrade automatic UAC triggered by PUCCH load
    ${gnb_allowed_fault_8242}   Create List    7533
    Set Test Variable    ${gnb_allowed_fault_8242}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_8242}
    Do SA UE Attach On AP    traffic_infor=${CB008242_D_2UE_FDD_20MHz}
    sleep    150s
    Run Keyword And Continue On Failure    check 7533 alarm report On gNB
    sleep    300s
    Stop Traffic And UE Deattach For SA On AP    traffic_infor=${CB008242_D_2UE_FDD_20MHz}
    sleep    360s
    check 7533 alarm Cancel On gNB
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic And UE Deattach For SA On AP    traffic_infor=${CB008242_D_2UE_FDD_20MHz}

Normal Release is used for the SgNB Release Request message in the UE triggered EN_DC takeback scenario_NR part
    prepare Before Do UE Release UE
    Do NSA UE Attach On AP    traffic_infor=${CNI_125269_FDD_20MHz}
    Force NSA UE Relase On AP    traffic_infor=${CNI_125269_FDD_20MHz}
    Sleep    5min
    Check Normal NSA E_RAB Releases Initiated Counter
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic And UE Deattach For NSA On AP    traffic_infor=${CNI_125269_FDD_20MHz}

CB014044_Verification_FilterConst_From_Compass
    [Arguments]     ${scripts_file}=mutiuetraffic_UL_FDD.lua    ${start_ue_id}=1    ${end_ue_id}=70    ${pdu}=1
    ...             ${test_comments}=TL083_testing_FDD_UL    ${template_name}=14044_KPI_UL
    Run Scripts File On Egate     scripts_file=${scripts_file}
    Sleep    15min
    ${report_timestamps_before}    Test Procedures For KPI Report Case On AP
    Update 14044 Param Value
    ${report_timestamps_after}    Test Procedures For KPI Report Case On AP
    @{all_template_excel_report}    Create List    ${report_timestamps_before}[0]    ${report_timestamps_after}[0]
    Generate And Record KPI Report To Compass And UTE On AP    report_timestamps_list=${all_template_excel_report}    test_comments=${test_comments}
    ...                                                       template_name=${template_name}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic And UE Deattach On Rounds For SA On AP    start_ue_id=${start_ue_id}
    ...                                                                                                  end_ue_id=${end_ue_id}
    ...                                                                                                  pdu=${pdu}