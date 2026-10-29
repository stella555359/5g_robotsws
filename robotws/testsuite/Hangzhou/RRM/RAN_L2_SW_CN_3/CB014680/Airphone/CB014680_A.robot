*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB014680
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
Test Timeout      120 minutes
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library     ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_CB014680_A.xml
${AIRPHONE_NAME}      IPHY_CB014680_A.xml
${WTS_NAME}           WTS_CB014680_A.lua
@{LOG_NAME_LIST}      egatelog\    ap_snapshot    gnb_snapshot    sosreport
${bSRS}                              text|2|//*[@name\="bSRS"]
${sCellOperationalMode}              text|dlOnly|//*[@name\="sCellOperationalMode"]
${increasePUSCHPrepTimeULCA}         text|false|//*[@name\="increasePUSCHPrepTimeULCA"]
${actRimPdcchMutingOnSpecialSlot}    text|true|//*[@name\="actRimPdcchMutingOnSpecialSlot"]
${par_of_bsr_name}                   BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001

${pattern}     t2r4_n2_pusch_1layer
${pattern1}    CA_P2_8x4_t2r4_n2
${TTI_TAG}     tti

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=UL_MIMO
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 test_type=UL_MIMO
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id=10 mode=fixed init_quad_pos=2 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id=13 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id=14 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id=15 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id=16 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=UL_MIMO
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

${NOISE_POWER_FOR_RI}=    SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,
...                        -98,-101,-104,-105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

*** Test Cases ***
CB014680_CR_A_case03_Refactoring_user_plane_overload_control
    Step1:Commission the above configuration on WebUI
    Step2:UEs attach to cell
	step3:check PM counter when actStatelessSchedLoadBalancer true
    Step4:disable actStatelessSchedLoadBalancer
	step5:check PM counter when actStatelessSchedLoadBalancer false
	Step6:enable actStatelessSchedLoadBalancer
	step7:check PM counter when actStatelessSchedLoadBalancer true

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}/WTS/${AIRPHONE_NAME}
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}/SCF/${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/SCF/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${bSRS}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    Perform Full Commission And Reach Onair With Log2    ${scfc_path}    ${CONFIG_DIR_PATH}/WTS/${WTS_NAME}    reset_after_commission=${False}
    ...    multi_cells=True
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Step2:UEs attach to cell
    Log To Console   \n----------Step2:UEs attach to cells-------
    Start capture GNB and AP Syslog in 'Step2_UEs_cell' File
#    #FOR    ${num}    IN RANGE    1    17    #34pos
#    #    airphone_execute_egate_command    ${PROFILE${num}}
#    #END
#    FOR    ${i}    IN RANGE    401    451
#        Run Keyword And Ignore Error    Attach UE to cell    ${i}
#        #${pattern1}
#        #${j}    evaluate    ${i}%16+1
#        #airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    10M    1
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    10M    1
#    END
#    FOR    ${i}    IN RANGE    1001    1051
#        Run Keyword And Ignore Error    Attach UE to cell    ${i}
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    10M    1
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    10M    1
#    END
    FOR    ${i}    IN RANGE    1    51
        Run Keyword And Ignore Error    Attach UE to cell    ${i}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    10M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    20M    1
    END
#    FOR    ${i}    IN RANGE    201    251
#        Run Keyword And Ignore Error    Attach UE to cell    ${i}
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    10M    1
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    10M    1
#    END
#    FOR    ${i}    IN RANGE    601    651
#        Run Keyword And Ignore Error    Attach UE to cell    ${i}
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    10M    1
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    10M    1
#    END
#    FOR    ${i}    IN RANGE    801    851
#        Run Keyword And Ignore Error    Attach UE to cell    ${i}
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    10M    1
#        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    10M    1
#    END
    Wait '10s' for stable
    #Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_UEs_cell
	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_UEs_cell' File

step3:check PM counter when actStatelessSchedLoadBalancer true
    Log To Console   \n----------Step3:check PM counter when actStatelessSchedLoadBalancer true-------
    Wait '600s' for stable
    Start capture GNB and AP Syslog in 'Step3_check_PM_counter_when_actStatelessSchedLoadBalancer_true' File
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    #${cell3_FB1}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00028    cell_grp_id=2
    #${cell6_FB1}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00028    cell_grp_id=5
    #${cell3_FB3}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00032    cell_grp_id=2
    #${cell6_FB3}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00032    cell_grp_id=5
    ${M55309C01001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C01001    cell_id=1
    ${M55308C02000}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=1
    ${M55308C27001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C27001    cell_id=1
    ${M55308C00008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=1
    ${M55308C00005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=1
    ${M55309C02001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C02001    cell_id=1
    ${M55308C02002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02002    cell_id=1
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=1
    ${M55308C00006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=1
    #run keyword and continue on failure    should be true    ${cell3_FB1}>350 and ${cell3_FB1}<400
    #run keyword and continue on failure    should be true    ${cell6_FB1}==0
    #run keyword and continue on failure    should be true    ${cell3_FB3}>350 and ${cell3_FB3}<400
    #run keyword and continue on failure    should be true    ${cell6_FB3}==0
    ${NR_5100c_TRUE}    evaluate     8 * (${M55309C01001})/((${M55308C02000} - ${M55308C27001}) * (${M55308C00008}) / (${M55308C00005}))
    ${NR_5101b_TRUE}    evaluate     8 * (${M55309C02001})/((${M55308C02002}) * (${M55308C00009}) / (${M55308C00006}))
    Set Test Variable    ${NR_5100c_TRUE}
    Set Test Variable    ${NR_5101b_TRUE}
    run keyword and continue on failure    should be true    ${NR_5100c_TRUE}>0
    run keyword and continue on failure    should be true    ${NR_5101b_TRUE}>0
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_check_PM_counter_when_actStatelessSchedLoadBalancer_true' File

Step4:disable actStatelessSchedLoadBalancer
    Log To Console   \n----------Step4:disable actStatelessSchedLoadBalancer-------
    #Start capture GNB and AP Syslog in 'Step4_disable_actStatelessSchedLoadBalancer' File
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1    parameter=actStatelessSchedLoadBalancer
    ...    operation=update    value=false    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
    #[Teardown]    Stop capture GNB and AP Syslog in 'Step4:disable actStatelessSchedLoadBalancer' File

step5:check PM counter when actStatelessSchedLoadBalancer false
    Log To Console   \n----------Step5:check PM counter when actStatelessSchedLoadBalancer false-------
    Wait '600s' for stable
    Start capture GNB and AP Syslog in 'Step5_check_PM_counter_when_actStatelessSchedLoadBalancer_false' File
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    #${cell3_FB1}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00028    cell_grp_id=2
    #${cell6_FB1}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00028    cell_grp_id=5
    #${cell3_FB3}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00032    cell_grp_id=2
    #${cell6_FB3}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00032    cell_grp_id=5
    ${M55309C01001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C01001    cell_id=1
    ${M55308C02000}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=1
    ${M55308C27001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C27001    cell_id=1
    ${M55308C00008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=1
    ${M55308C00005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=1
    ${M55309C02001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C02001    cell_id=1
    ${M55308C02002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02002    cell_id=1
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=1
    ${M55308C00006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=1
    #run keyword and continue on failure    should be true    ${cell3_FB1}>350 and ${cell3_FB1}<400
    #run keyword and continue on failure    should be true    ${cell6_FB1}==0
    #run keyword and continue on failure    should be true    ${cell3_FB3}>350 and ${cell3_FB3}<400
    #run keyword and continue on failure    should be true    ${cell6_FB3}==0
    ${NR_5100c_false}    evaluate     8 * (${M55309C01001})/((${M55308C02000} - ${M55308C27001}) * (${M55308C00008}) / (${M55308C00005}))
    ${NR_5101b_false}    evaluate     8 * (${M55309C02001})/((${M55308C02002}) * (${M55308C00009}) / (${M55308C00006}))
    Set Test Variable    ${NR_5100c_false}
    Set Test Variable    ${NR_5101b_false}
    run keyword and continue on failure    should be true    ${NR_5100c_false}>0
    run keyword and continue on failure    should be true    ${NR_5101b_false}>0
    run keyword and continue on failure    should be true    ${NR_5100c_false}*0.9<=${NR_5100c_TRUE}
    run keyword and continue on failure    should be true    ${NR_5101b_false}*0.9<=${NR_5101b_TRUE}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step5_check_PM_counter_when_actStatelessSchedLoadBalancer_false' File

Step6:enable actStatelessSchedLoadBalancer
    Log To Console   \n----------Step6:disable actStatelessSchedLoadBalancer-------
    #Start capture GNB and AP Syslog in 'Step6_disable_actStatelessSchedLoadBalancer' File
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1    parameter=actStatelessSchedLoadBalancer
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
    #[Teardown]    Stop capture GNB and AP Syslog in 'Step6:disable actStatelessSchedLoadBalancer' File

step7:check PM counter when actStatelessSchedLoadBalancer true
    Log To Console   \n----------Step7:check PM counter when actStatelessSchedLoadBalancer true-------
    Wait '600s' for stable
    Start capture GNB and AP Syslog in 'Step7_check_PM_counter_when_actStatelessSchedLoadBalancer_true' File
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    #${cell3_FB1}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00028    cell_grp_id=2
    #${cell6_FB1}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00028    cell_grp_id=5
    #${cell3_FB3}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00032    cell_grp_id=2
    #${cell6_FB3}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    #...    counter_id=M55208C00032    cell_grp_id=5
    ${M55309C01001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C01001    cell_id=1
    ${M55308C02000}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=1
    ${M55308C27001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C27001    cell_id=1
    ${M55308C00008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=1
    ${M55308C00005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=1
    ${M55309C02001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C02001    cell_id=1
    ${M55308C02002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02002    cell_id=1
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=1
    ${M55308C00006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=1
    #run keyword and continue on failure    should be true    ${cell3_FB1}>350 and ${cell3_FB1}<400
    #run keyword and continue on failure    should be true    ${cell6_FB1}==0
    #run keyword and continue on failure    should be true    ${cell3_FB3}>350 and ${cell3_FB3}<400
    #run keyword and continue on failure    should be true    ${cell6_FB3}==0
    ${NR_5100c_TRUE_2}    evaluate     8 * (${M55309C01001})/((${M55308C02000} - ${M55308C27001}) * (${M55308C00008}) / (${M55308C00005}))
    ${NR_5101b_TRUE_2}    evaluate     8 * (${M55309C02001})/((${M55308C02002}) * (${M55308C00009}) / (${M55308C00006}))
    Set Test Variable    ${NR_5100c_TRUE_2}
    Set Test Variable    ${NR_5100c_TRUE_2}
    run keyword and continue on failure    should be true    ${NR_5100c_TRUE_2}>0
    run keyword and continue on failure    should be true    ${NR_5101b_TRUE_2}>0
    run keyword and continue on failure    should be true    ${NR_5100c_false}*0.9<=${NR_5100c_TRUE_2}
    run keyword and continue on failure    should be true    ${NR_5101b_false}*0.9<=${NR_5101b_TRUE_2}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step7_check_PM_counter_when_actStatelessSchedLoadBalancer_true' File

Attach UE to cell
    [Arguments]    ${ue_id}
#    ${pattern}
#    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10
#    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10
#    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    airphone_execute_egate_command    ue_pdu_session_setup ue\=${ue_id} pdu\=1 nwslice\=1
    #${pdu_id}    evaluate    ${ue_id}%10+1
    #${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ue_id=${ue_id}    pdu_id=1     nwslice_id=1
    #${newNum}=    evaluate    ${ue_id}+8
    #Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
    Wait '1s' for stable running2

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
    END

Stop UE DL Traffic
    [Arguments]    ${ue_id}
    airphone_sa_stop_data_traffic    ${ue_id}    DL

Detach UE
    [Arguments]    ${ue_id}
    airphone_sa_detach    ue_id=${ue_id}    timeout=30

Detach All UEs
    FOR    ${i}    IN RANGE    1    11
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

    FOR    ${i}    IN RANGE    51    61
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

Override UEi to DL RANKj and CQIk
    [Arguments]    ${ue_id}    ${ranki}    ${cqii}
    airphone_execute_egate_command
   	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}

Set UEi position
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1

Set UEi position bad
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

Set UEi position bad2
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

Block Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

Unlock Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Unlocked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

get tput from PM counter
    [Arguments]    ${cellid}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+300
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12001
    ...   cell_id=${cellid}
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
    ${PM_counter_UL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12002
    ...   cell_id=${cellid}
    ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
    [Return]    ${DL_throughput}    ${UL_throughput}

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    #add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
    add_txt_node    0x580308:3         #rdActCb014680OlcImprovement
    add_txt_node    0x58026F:1         #rdEnableStatelessSchedLoadBalancer
    add_txt_node    0x580122:1         #rdAllocateMaxSchShareOnMixedSlot
    #add_txt_node    0x58014D:2002      #rdSlotDurationSwitchingOlcPerCent
    #add_txt_node    0x580179:2002      #rdPDSCHSkipSpecialSlotOlcPerCent
    #add_txt_node    0x5800CA:15015015  #rdMaxNumUeTdDl
    #add_txt_node    0x5800CB:15015015  #rdMaxNumUeTdUl
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Perform Full Commission And Reach Onair With Log2
    [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}=1500    ${reset_after_commission}=${False}
    ...             ${wait_bts_timeout}=600    ${wait_rru_timeout}=600    ${L1b}=False    ${multi_cells}=False
    [Documentation]    This keyword will use ${scfc} to do full commission, and use ${wts_config} to start wts process and check onair
    ...    | Input Parameters | Man. | Description |
    ...    | scfc | Yes | SCF file path. |
    ...    | wts_config | Yes | WTS config file |
    ...    | wait_onair_timeout | No | timeout to check onair. Default is 1500 |
    ...    | reset_after_commission | No | Will reset bts after commission.Default is False |
    ...    Examples:
    ...    | Perform Full Commission And Reach Onair | scfc.xml |  wts_config.xml |
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
    Perform Full Commission     ${new_scfc}
    Run Keyword If    '${reset_after_commission}'=='True'     Reset Testline
    FOR    ${loop}    IN RANGE    2
        ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
        Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} >= 1    Fail
        ${remote info}     Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
        run keyword and ignore error    Start Tcpdump    cellSetup${loop}    -i any    ${remote info}
        ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
        Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} >= 1    Fail
        Run Keyword If    '${L1b}' == 'True'
         ...    Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
        ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
         ...    timeout=${wait_onair_timeout}    multi_cells=${multi_cells}
        Run Keyword If    '${onair_status}' == 'True'    Stop Tcpdump       cellSetup${loop}     ${test_log_directory()}
        OperatingSystem.Run    mv ${test_log_directory()}/cellSetup*.pcap ${test_log_directory()}/cellSetup0.pcap
        Return From Keyword If    '${onair_status}' == 'True'
        Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reset Testline
        Run Keyword If    '${onair_status}' == 'False' and ${loop} >= 1    Fail
    END

Wait '${time}' for stable running2
    sleep    ${time}

get UL RT load from PM counter
    [Arguments]    ${cellid}
    #${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    #${remaining_time}     evaluate    ${remaining_time}+300
    #Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_UL_RT_loade_min}=    get_counter_value_from_counter_file_by_grp
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55208C00004
    ...   cell_grp_id=${cellid}
    ${PM_counter_UL_RT_loade_max}=    get_counter_value_from_counter_file_by_grp
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55208C00005
    ...   cell_grp_id=${cellid}
    ${PM_counter_UL_RT_loade_ave}=    get_counter_value_from_counter_file_by_grp
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55208C00006
    ...   cell_grp_id=${cellid}
    [Return]    ${PM_counter_UL_RT_loade_min}    ${PM_counter_UL_RT_loade_max}    ${PM_counter_UL_RT_loade_ave}

get FB1 FB3 coutermeasure from PM counter
    [Arguments]    ${cellid}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_FB1}=    get_counter_value_from_counter_file_by_grp
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55208C00028
    ...   cell_grp_id=${cellid}
    ${PM_counter_FB3}=    get_counter_value_from_counter_file_by_grp
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55208C00032
    ...   cell_grp_id=${cellid}
    [Return]    ${PM_counter_FB1}    ${PM_counter_FB3}

get RIM mitigation from PM counter
    [Arguments]    ${cellid}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_special_muted}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55194C00003
    ...   cell_id=${cellid}
    ${PM_counter_1st_DL_muted}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55194C00281
    ...   cell_id=${cellid}
    ${PM_counter_2st_DL_muted}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55194C00282
    ...   cell_id=${cellid}
    [Return]    ${PM_counter_special_muted}    ${PM_counter_1st_DL_muted}    ${PM_counter_2st_DL_muted}

Start capture gnb and ap syslog in '${file_name}' file2
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file2
    #check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}    syslog_${file_name}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}${file_name}   unzip=TRUE
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_ap.tar.gz