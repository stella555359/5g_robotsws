*** Settings ***
Resource    ../Resources/5GC002546_keywords.robot


Documentation
...   author: Fang Ludan
...   contact: ludan.fang@nokia-sbell.com
...   squad group: MMW_SG1
...   feature : 5GC002546-B


Force Tags    5G_RRM
...    PY36
Suite Setup     Suite preparation for 2546
Suite Teardown   run keyword and ignore error   CA Suite teardown


*** Variables ***

*** Test Cases ***
#Cases[1]5GC002546_A_B1_01_New_CRNTI_pool_allocation_mix_mode_configuration switch on and off_SA
#    [Tags]  CRT_21B   CRT_22R1
#    [Documentation]    author: ludan.fang@nokia-sbell.com
#    ...   check CRNIT pool ID with PCELL and SCELL
#    [Setup]    Common case setup   NSA_SA=SA
#    check CRNTI Pool in snapshot


[1]5GC002546_B_B1_02_Different Scell addition method for F-T CA with 2 SA UE
    [Tags]  CRT_21B   CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
    [Documentation]    author: ludan.fang@nokia-sbell.coms
    ...   step1:change FDD_1 addition mothod blind,FDD_2,FDD_3 addition mothod covBasedA1,activition mothod bufferbased
    ...   step2:change attach cell to FDD_1,Start data transfer,check CA and scell activated,Stop data transfer,check inactivated
    ...   step3:change attach cell to FDD_2,Start data transfer,check CA and scell activated,Stop data transfer,check inactivated
    ...   step2:change attach cell to FDD_3,Start data transfer,check CA and scell activated,Stop data transfer,check inactivated
    ...   if PCELL_ID_1<0 and PCELL_ID_2<0, means there's only one PSCELL in this TL;
    ...   if PCELL_ID_1>0 or PCELL_ID_2>0, there's more than one PSCELL in this TL.
    [Setup]    Common case setup    NSA_SA=SA
    Change addition and activation
    attach to FDD and check CA and check Scell activated inactivated  FDD_ID=${PCELL_ID}
    ...   scell_addition_method=blind

    run keyword if    ${PCELL_ID_1}<0 and ${PCELL_ID_2}<0    Modify sCell addition method to covBasedA1 And Attach    ${PCELL_ID}
    run keyword if    ${PCELL_ID_1}>=0    Modify sCell addition method to covBasedA1 And Attach    ${PCELL_ID_1}
    run keyword if    ${PCELL_ID_2}>=0    Modify sCell addition method to covBasedA1 And Attach    ${PCELL_ID_2}

    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}    is_scf_restore=${False}

#[1]5GC002546_B_B2_07_Scell activation method with bufferAndRLQualityBased for F-T CA with 3 SA UE
#    [Tags]  CIT_21B   CRT_21A
#    [Documentation]    author: ludan.fang@nokia-sbell.coms
#     ...    step1:change FDD_1 addition mothod blind,FDD_2,FDD_3 addition mothod covBasedA1,activition mothod qualitybased
#      ...    step2: change attach cell to FDD_1,Start data transfer,check CA and scell activated
#      ...    step3: change PA made bad,slepp
#    [Setup]    Common case setup    NSA_SA=SA
#    run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Change addition and activation    add_sCellActivationMethod=${deactive_always}
#    Change status for parameter cellBarred on GNB
#    ...  exp_status=notBarred   list_cell_ids=${PCELL_ID}
#    CA_basic_L3_call   scell_addition_method=blind   check_scell_activation=${True}
#    Prepare and start aasyslog   log_name=scell_deactivation.txt
#    Connect to Attenuator
#    Adjust attenuator for specified RU ports    atten_values=${SCELL_BAD_${MRBTS_ID}}    ru_index=${SCELL_RU_INDEX_${MRBTS_ID}}
#    ${sleep_time}  evaluate  int(${sCellDeactivationBadRlqCount})*int(${sCellChannelEstimationPeriod})/1000
#    sleep  ${sleep_time}s
#    sleep  10s
#    Run keyword and ignore error    Stop aasyslog to check scell deactivation   sCelldeactivationMethod=qualitybased
#    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl==100,0     ul_cell_id=${PCELL_ID},${SCELL_ID}
#    ...    exp_ul=50,0   min_tp_check_needed=${false}
#    run keyword and ignore error   Stop data transfer based on direction
#    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}
#    ...    duration=500s  process_num=${TCP_PROCESS_NUMBER}   data_transfer_direction=both
#    Sleep    30s    reason=Wait for traffic to be stable.
#    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl==100,0     ul_cell_id=${PCELL_ID},${SCELL_ID}
#    ...    exp_ul=50,0   min_tp_check_needed=${false}
#
#    [Teardown]    run keywords    run keyword and ignore error    Common case teardown    detach_ue=${True}    is_scf_restore=${False}
#    ...    AND   run keyword and ignore error
#    ...   Adjust attenuator for specified RU ports    atten_values=${SCELL_GOOD_${MRBTS_ID}}    ru_index=${SCELL_RU_INDEX_${MRBTS_ID}}
#    ...   AND   run keyword and ignore error   Stop data transfer based on direction


[1]5GC001390_EA_2_B14_Radio-Link-Quality_Scell-Scheduling-Suspension_for_single_UE-SA_with_CA-FDDFR1-TDD_BufferBased-SCellActvation
    [Tags]  CIT_21B    CIT_TRUNK    CRT_21A    CIT_22R1    CIT_22R2    CRT_22R1    CIT_22R3    CDRT_22R2     CIT_22R4
    ...        CDRT_22R3
    [Documentation]    author: ludan.fang@nokia-sbell.coms
     ...    step1:change FDD_1 addition mothod blind,FDD_2,FDD_3 addition mothod covBasedA1,activition mothod qualitybased
      ...    step2: change attach cell to FDD_1,Start data transfer,check CA and scell activated
      ...    step3: change PA made bad,slepp
    [Setup]    Common case setup    NSA_SA=SA
     run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Change addition and activation    add_sCellActivationMethod=${deactive_always_not}
    Change status for parameter cellBarred on GNB
    ...  exp_status=notBarred   list_cell_ids=${PCELL_ID}
    ${tput_info_cell_1}  CA_basic_L3_call   scell_addition_method=blind   check_scell_activation=${True}
    Connect to Attenuator
    Adjust attenuator for specified RU ports    atten_values=${SCELL_BAD_${MRBTS_ID}}    ru_index=${SCELL_RU_INDEX_${MRBTS_ID}}
    Sleep    40s    reason=Wait for traffic to be stable.

    ${tput_info_cell_2}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}   ul_cell=${PCELL_ID},${SCELL_ID}  tput_duration=60s
    ...    gnb_index=${0}     alias=ASIK Master    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
    ${sleep_time}  evaluate  ${sCellDeactivationBadRlqCount}*(${sCellChannelEstimationPeriod}-6000)/1000
    sleep  ${sleep_time}s
    Connect to Attenuator
    Adjust attenuator for specified RU ports    atten_values=${SCELL_GOOD_${MRBTS_ID}}    ru_index=${SCELL_RU_INDEX_${MRBTS_ID}}
    Sleep    30s    reason=Wait for traffic to be stable.
    ${tput_info_cell_3}  Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl==100,200
    ...    exp_ul=50,0   ul_cell_id=${PCELL_ID},${SCELL_ID}   min_tp_check_needed=${false}
    should be true    ${tput_info_cell_1['${SCELL_ID}']['dl_avg_tput']}>${tput_info_cell_2['${SCELL_ID}']['dl_avg_tput']}
    should be true    ${tput_info_cell_3['${SCELL_ID}']['dl_avg_tput']}>${tput_info_cell_2['${SCELL_ID}']['dl_avg_tput']}
    [Teardown]    run keywords    run keyword and ignore error    Common case teardown    detach_ue=${True}    is_scf_restore=${False}
    ...    AND   run keyword and ignore error
    ...   Adjust attenuator for specified RU ports    atten_values=${SCELL_GOOD_${MRBTS_ID}}    ru_index=${SCELL_RU_INDEX_${MRBTS_ID}}

