*** Settings ***
Documentation   This is a keyword file for CB006139 part egate verify
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***



Prepare Egate File For Verification
    [Documentation]    [PRIVATE]    Prepare Egate File For Verification, remove empty lines, strip lines
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${egate_log_file}
    ${contents}    Get File           ${egate_log_file}
    Create File    ${resultDir}/egate.txt
    @{lines}       Split To Lines     ${contents}

    FOR   ${line}    IN    @{lines}
       ${length}    GetLength    ${line}
       IF  ${length} == 0    CONTINUE
       ${line_wo_blanks}     Strip String     ${line}
       Append To File    ${resultDir}/egate.txt    ${line_wo_blanks}\n
    END


Search DL CHANNEL
    [Documentation]    [PRIVATE]    Search DL CHANNEL
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${contents}   ${UE}   ${SubcellId}   ${PhysCellId}   ${SCellIndex}
    ${search_for}  Set Variable
    ...  <DL CHANNEL> [UeId:${UE},SubcellId:${SubcellId},PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
    Log To Console    Check that "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}


Verify Single Egate DL CHANNEL
    [Documentation]    [PRIVATE]    Verify Single Egate DL CHANNEL
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${run}
    Log To Console    \nVerify file egate_trfStart_${run}.txt
    Prepare Egate File For Verification    ${resultDir}/egate_trfStart_${run}.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   IN
    ...   1              53              3
    ...   33             55              5
    ...   32             52              2
    ...   16             51              1
    ...   17             54              4
       Search DL CHANNEL   contents=${contents}   UE=0   SubcellId=${SubcellId}   PhysCellId=${PhysCellId}   SCellIndex=${SCellIndex}
    END


Verify Single Egate SCellIndex 1 Deactivated
    [Documentation]    [PRIVATE]    Verify Single Egate SCellIndex 1 Deactivated
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${run}
    Log To Console    \nVerify file egate_testmode_profile_ue1_${run}.txt
    Prepare Egate File For Verification    ${resultDir}/egate_testmode_profile_ue1_scell1_${run}.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${search_for}  Set Variable   <DL CHANNEL> [UeId:0,SubcellId:16,PhysCellId:51] SCellIndex 1 deactivated successfully at airphone
    Log To Console    Check that "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}


Verify Egate Logs t1
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_AA_ET_TC02_B2_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_deactivation
    ...       :Autor: Sylvia Schneider
    FOR   ${run}   IN
    ...   DL_buffer_monitoring_activated
    ...   DL_buffer_monitoring_deactivated
       Run Keyword And Continue On Failure   Verify Single Egate DL CHANNEL                  ${run}
       Run Keyword And Continue On Failure   Verify Single Egate SCellIndex 1 Deactivated    ${run}
    END


Verify Egate Logs t2
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_AA_ET_TC01_B1_ALT1_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify file egate_trfStart_id1_2.txt
    Prepare Egate File For Verification    ${resultDir}/egate_trfStart_id1_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   IN
    ...   17             54              2
    ...   33             55              3
    ...   16             51              1
       Search DL CHANNEL   contents=${contents}   UE=0   SubcellId=${SubcellId}   PhysCellId=${PhysCellId}   SCellIndex=${SCellIndex}
    END

    Run Keyword And Continue On Failure   Verify Single Egate SCellIndex 1 Deactivated    run=1

    Log To Console    \nVerify file egate_throughput_pusch_pdsch_ue1_3.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_pdsch_ue1_3.txt
    ${line}      Get Lines Containing String     ${contents}     4 cells
    @{temp}      Split String                    ${line}
    ${average_throughput}   Set Variable   ${temp}[8]
    Log To Console    Verify that average_throughput ${average_throughput} > expected value 790
    ${result}   Set Variable If   ${average_throughput} > 790  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed average_throughput ${average_throughput} > expected value 790


Add Line Numbers To Egate Console Log
    [Documentation]    [PRIVATE]    Add Line Numbers To Egate Console Log
    ...       :Autor: Sylvia Schneider
    Log To Console    \nAdd Line Numbers To Egate Console Log
    Run  awk '{print NR "> " $0}' ${resultDir}/egate/egate_console.log > ${resultDir}/egate_console_upd.log


Search For 1 Entry And Return Line Number
    [Documentation]    [PRIVATE]    Search For 1 Entry And Return Line Number
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${search}
    ${found}  Grep File   ${egate_file}       ${search}
    ${line_found}       Get Regexp Matches    ${found}    ^[0-9]*
    ${int_line_found}   Convert To Integer    ${line_found}[0]
    RETURN    ${int_line_found}


Search For Several Entries And Return Line Number Of Specified Occurance
    [Documentation]    [PRIVATE]    Search For Several Entries And Return Line Number Of Specified Occurance
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${search}   ${occurance}
    ${found_list}  Grep File   ${egate_file}       ${search}
    ${found_lines}  Split To Lines   ${found_list}
    ${found}  Set Variable  ${found_lines}[${occurance}]
    ${line_found}       Get Regexp Matches    ${found}    ^[0-9]*
    ${int_line_found}   Convert To Integer    ${line_found}[0]
    RETURN    ${int_line_found}


Verify Egate Logs UE1 t3
    [Documentation]    [PRIVATE]    verify egate logs UE1 t3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify traffic start UE1, 1st measurement period
    ${int_line_trf_start_UE1}   Search For 1 Entry And Return Line Number    trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    Log To Console    UE1 DL traffic started in line ${int_line_trf_start_UE1}
    ${int_line_trf_ready_UE1}   Search For 1 Entry And Return Line Number    ue_stats_nr id=1 scell=0-5 type=pusch,pdsch
    Log To Console    UE1 Ue Stats in line ${int_line_trf_ready_UE1}
    Log To Console    verify UE1 DL CHANNEL after traffic data start and before ue_stats
    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   IN
    ...   17             54              4
    ...   33             55              5
    ...   1              53              3
    ...   32             52              2
    ...   16             51              1
       ${search}  Set Variable
       ...  UeId:0,SubcellId:${SubcellId},PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       Log to console   --search for "${search}"
       ${int_line_dl_channel}   Search For 1 Entry And Return Line Number    ${search}
       Log To Console    ----found in line ${int_line_dl_channel},
       Log To Console    ----verify that line is between traffic data start ${int_line_trf_start_UE1} and ue_stats ${int_line_trf_ready_UE1}
       Run Keyword And Continue On Failure    Should Be True   ${int_line_trf_start_UE1} < ${int_line_dl_channel} < ${int_line_trf_ready_UE1}
    END


Verify Egate Logs t3
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_AA_ET_TC14_B12_Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    ...       :Autor: Sylvia Schneider
    Add Line Numbers To Egate Console Log
    Set Test Variable   ${egate_file}  ${resultDir}/egate_console_upd.log

    Run Keyword And Continue On Failure    Verify Egate Logs UE1 t3

    Log To Console    \nVerify traffic start UE2, 1st measurement period

    ${int_line_PDUsetup_UE2}   Search For 1 Entry And Return Line Number    UE2: Established PDU session ID=1
    Log To Console    UE2 pdu setup in line ${int_line_PDUsetup_UE2}

    ${int_line_ue_stats_UE2_1}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=ue_stats_nr id=2 scell=0-5 type=pusch,pdsch
    ...   occurance=0
    Log To Console    UE2 ScellIndex activation must be before ue stats line ${int_line_ue_stats_UE2_1}

    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   IN
    ...   16             51              1
    ...   32             52              2
       ${search}  Set Variable
       ...  UeId:1,SubcellId:${SubcellId},PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       ${int_line_dl_channel}   Search For Several Entries And Return Line Number Of Specified Occurance
       ...   search=${search}
       ...   occurance=0
       Log To Console    --string "${search}" found in line ${int_line_dl_channel}
       Log To Console    ----verify that line is between established PDU line ${int_line_PDUsetup_UE2} and ue_stats line ${int_line_ue_stats_UE2_1}
       Run Keyword And Continue On Failure    Should Be True   ${int_line_PDUsetup_UE2} < ${int_line_dl_channel} < ${int_line_ue_stats_UE2_1}
    END

    ${int_line_testmode_act_2}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=2 scell=1 testmode=csi_override action=activate profile_id=2
    Log To Console    \nUE2 testmode activate profile 2 in line ${int_line_testmode_act_2}
    ${int_line_testmode_act_1}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=2 scell=1 testmode=csi_override action=activate profile_id=1
    Log To Console    UE2 testmode activate profile 1 in line ${int_line_testmode_act_1}
    ${search}  Set Variable
    ...    UeId:1,SubcellId:16,PhysCellId:51] SCellIndex 1 deactivated successfully at airphone
    ${int_line_scell_deact}   Search For 1 Entry And Return Line Number
    ...    ${search}
    Log To Console    --string "${search}" found in line ${int_line_scell_deact}
    Log To Console    ----verify that line "SCellIndex 1 deactivated successfully" is between "activate profile 2" and "activate profile 1"
    Run Keyword And Continue On Failure    Should Be True   ${int_line_testmode_act_2} < ${int_line_scell_deact} < ${int_line_testmode_act_1}

    Log To Console    \nUE2 1st measurement period after increase traffic
    ${int_line_trdId1_2}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ...   occurance=1
    Log To Console    UE2 traffic_id1 started in line ${int_line_trdId1_2}
    ${int_line_trdId6_1}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=2 pdu=1 qfi=1 trf_id=6 dir=dl mbps=175
    ...   occurance=0
    Log To Console    UE2 traffic_id6 started in line ${int_line_trdId6_1}
    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   ${occurance}  IN
    ...   16             51              1               1
    ...   17             54              3               0
       ${search}  Set Variable
       ...  UeId:1,SubcellId:${SubcellId},PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       ${int_line_dl_channel}   Search For Several Entries And Return Line Number Of Specified Occurance
       ...   search=${search}
       ...   occurance=${occurance}
       Log To Console    --string "${search}" found in line ${int_line_dl_channel}
       Log To Console    ----verify that line is between traffic start UE2 trfid1 ${int_line_trdId1_2} and start UE2 trfid6 ${int_line_trdId6_1}
       Run Keyword And Continue On Failure    Should Be True   ${int_line_trdId1_2} < ${int_line_dl_channel} < ${int_line_trdId6_1}
    END

    Log To Console    \nUE2 2nd measurement period after increase traffic
    ${int_line_trdId1_3}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ...   occurance=2
    Log To Console    UE2 traffic_id1 started in line ${int_line_trdId1_3}
    ${int_line_trdId6_2}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=2 pdu=1 qfi=1 trf_id=6 dir=dl mbps=175
    ...   occurance=1
    Log To Console    UE2 traffic_id6 started in line ${int_line_trdId6_2}
    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   ${occurance}  IN
    ...   17             54              3               1
       ${search}  Set Variable
       ...  UeId:1,SubcellId:${SubcellId},PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       ${int_line_dl_channel}   Search For Several Entries And Return Line Number Of Specified Occurance
       ...   search=${search}
       ...   occurance=${occurance}
       Log To Console    --string "${search}" found in line ${int_line_dl_channel}
       Log To Console    ----verify that line is between traffic start UE2 trfid1 ${int_line_trdId1_3} and start UE2 trfid6 ${int_line_trdId6_2}
       Run Keyword And Continue On Failure    Should Be True   ${int_line_trdId1_3} < ${int_line_dl_channel} < ${int_line_trdId6_2}
    END


Verify Egate Logs t3 Throughput
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_AA_ET_TC14_B12_Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    ...       :Autor: Sylvia Schneider
    Get And Verify DL Throughput t3
    Get And Verify UL Throughput t3


Get Average Throughput
    [Documentation]    [PRIVATE]    Get Average Throughput
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${contents}   ${direction}   ${numberOfCells}
    ${line}      Get Lines Containing String     ${contents}     ${numberOfCells}
    @{temp}      Split String                    ${line}
    ${average_throughput}   Set Variable   ${temp}[8]
    Log To Console    average ${direction} throughput ${numberOfCells} is ${average_throughput}
    RETURN   ${average_throughput}


Get And Verify DL Throughput t3
    [Documentation]    [PRIVATE]    Get And Verify DL Throughput t3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget and verify DL throughput values after increase traffic
    Log To Console    verify file egate_throughput_pdsch_ue2_3.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue2_3.txt
    ${average_throughput_DL1}    Get Average Throughput  ${contents}  DL   4 cells
    Log To Console    --- 1st measurement period, DL throughput is ${average_throughput_DL1}

    Log To Console    verify file egate_throughput_pdsch_ue2_5.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue2_5.txt
    ${average_throughput_DL2}    Get Average Throughput  ${contents}  DL   4 cells
    Log To Console    --- 2nd measurement period, DL throughput is ${average_throughput_DL2}

    FOR   ${period}  ${direction}   ${throughput}                ${expected_value}    IN
    ...   1st        DL             ${average_throughput_DL1}    860
    ...   2nd        DL             ${average_throughput_DL2}    770
       Log To Console
       ...    ${period} measurement period: Verify that average_throughput ${direction} ${${throughput}} > expected value ${expected_value}
       ${result}   Set Variable If   ${${throughput}} > ${expected_value}  Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${${throughput}} > expected value ${expected_value}
    END
    Log To Console    Verify that average_throughput DL of 1st measurement period is greater than 2nd measurement period
    ${result}   Set Variable If   ${average_throughput_DL1} > ${average_throughput_DL2}  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_DL1} > ${average_throughput_DL2}


Get And Verify UL Throughput t3
    [Documentation]    [PRIVATE]    Get And Verify UL Throughput t3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget and verify UL throughput values after increase traffic

    Log To Console    verify file egate_throughput_pusch_ue2_3.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_ue2_3.txt
    ${average_throughput_UL1}    Run Keyword And Continue On Failure    Get Average Throughput  ${contents}  UL   1 cell

    Log To Console    verify file egate_throughput_pusch_ue2_5.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_ue2_5.txt
    ${average_throughput_UL2}    Run Keyword And Continue On Failure    Get Average Throughput  ${contents}  UL   2 cells

    FOR   ${period}  ${direction}   ${throughput}                ${expected_value}    IN
    ...   1st        UL             ${average_throughput_UL1}    11
    ...   2nd        UL             ${average_throughput_UL2}    40
       Log To Console
       ...    ${period} measurement period: Verify that average_throughput ${direction} ${${throughput}} > expected value ${expected_value}
       ${result}   Set Variable If   ${${throughput}} > ${expected_value}  Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${${throughput}} > expected value ${expected_value}
    END
    Log To Console    Verify that average_throughput UL of 1st measurement period is smaller than 2nd measurement period
    ${result}   Set Variable If   ${average_throughput_UL1} < ${average_throughput_UL2}  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_UL1} < ${average_throughput_UL2}


Verify Egate Logs t6
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_AA_ET_TC06_B7_SCell_removed_from_SCell_Failed_to_Setup_List_after_SCell_Release
    ...       :Autor: Yasir Mehmood
    Log To Console    \nVerify file egate_trfStart_UE1_id1_2.txt, traffic start UE1, SCell additions
    Prepare Egate File For Verification    ${resultDir}/egate_trfStart_id1_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${SubcellId}   ${PhysCellId}   ${SCellIndex}   IN
    ...   32             52              2
    ...   1              53              3
    ...   16             51              1
    ...   17             54              4
       Search DL CHANNEL   contents=${contents}   UE=0   SubcellId=${SubcellId}   PhysCellId=${PhysCellId}   SCellIndex=${SCellIndex}
    END


Verify Egate Logs EB Throughput
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_EB_ET_TC12_InterGnb_SCell_Addition_CsiRs_Downgrade_MIMO_Robustness_Test
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure    Verify Egate Logs 1st Measurement Period EB Throughput
    Run Keyword And Continue On Failure    Verify Egate Logs 2nd Measurement Period EB Throughput


Verify Egate Logs 1st Measurement Period EB Throughput
    [Documentation]    [PRIVATE]    Verify Egate Logs 1st Measurement Period EB Throughput
    ...       :Autor: Sylvia Schneider
    FOR   ${index}     ${expected_throughput}    IN
    ...   1            520
    ...   2            695
       Log To Console    \nVerify file egate_throughput_pdsch_ue2_${index}.txt from 1st measurement period
       ${contents}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pdsch_ue2_${index}.txt
       ${line}      String.Get Lines Containing String     ${contents}     4 cells
       @{temp}      String.Split String                    ${line}
       ${average_throughput}   Set Variable   ${temp}[8]
       ${output}   Set Variable   average_throughput ${average_throughput} > expected value ${expected_throughput}
       Log To Console    Verify that ${output}
       IF    ${average_throughput} <= ${expected_throughput}
       ...     Run Keyword And Continue On Failure    Fail    failed ${output}
    END


Verify Egate Logs 2nd Measurement Period EB Throughput
    [Documentation]    [PRIVATE]    Verify Egate Logs 2nd Measurement Period EB Throughput
    ...       :Autor: Sylvia Schneider
    &{dict_throughput3}   Create Dictionary
    Log To Console    \nVerify file egate_throughput_pdsch_ue1_3.txt from 2nd measurement period
    ${contents}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pdsch_ue1_3.txt
    FOR    ${search}      ${index}  IN
    ...    4 cells        8
    ...    CellIndex-0    7
    ...    CellIndex-1    7
       ${line}      String.Get Lines Containing String     ${contents}     ${search}
       @{temp}      String.Split String                    ${line}
       ${average_throughput}   Set Variable   ${temp}[${index}]
       Set To Dictionary    ${dict_throughput3}    ${search}    ${average_throughput}
       Log To Console    average_throughput of ${search} is ${average_throughput}
    END
    &{dict_throughput4}   Create Dictionary
    Log To Console    \nVerify file egate_throughput_pdsch_ue1_4.txt from 2nd measurement period
    ${contents}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pdsch_ue1_4.txt
    FOR    ${search}      ${index}  IN
    ...    4 cells        8
    ...    CellIndex-0    7
    ...    CellIndex-1    7
       ${line}      String.Get Lines Containing String     ${contents}     ${search}
       @{temp}      String.Split String                    ${line}
       ${average_throughput}   Set Variable   ${temp}[${index}]
       Collections.Set To Dictionary    ${dict_throughput4}    ${search}    ${average_throughput}
       Log To Console    average_throughput of ${search} is ${average_throughput}
    END

    Set Expected Throughput Values 2nd Measurement Period EB
    ${cell0_throughput_run3}   Collections.Get From Dictionary    ${dict_throughput3}    CellIndex-0
    ${cell1_throughput_run3}   Collections.Get From Dictionary    ${dict_throughput3}    CellIndex-1
    ${4cell_throughput_run3}   Collections.Get From Dictionary    ${dict_throughput3}    4 cells
    ${cell0_throughput_run4}   Collections.Get From Dictionary    ${dict_throughput4}    CellIndex-0
    ${cell1_throughput_run4}   Collections.Get From Dictionary    ${dict_throughput4}    CellIndex-1
    ${4cell_throughput_run4}   Collections.Get From Dictionary    ${dict_throughput4}    4 cells

    FOR    ${run}    IN  3   4
        FOR   ${cell}    IN    cell0   cell1   4cell
           ${msg}   Set Variable
           ...  run-${run} ${cell} average_throughput ${${cell}_throughput_run${run}} > expected value ${expected_${cell}_throughput_run${run}}
           Log To Console    Verify that ${msg}
           IF    ${${cell}_throughput_run${run}} <= ${expected_${cell}_throughput_run${run}}
           ...     Run Keyword And Continue On Failure    Fail    failed ${msg}
        END
    END
    Log To Console    \nCompare throughputs of 2nd measurement period between last but on (run3) and last run (run4)
    FOR    ${cell}         ${param}   ${operation}     IN
    ...    CellIndex-0     cell0      <
    ...    CellIndex-0     cell1      >
    ...    4 cells         4cell      <
       ${msg}   Set Variable   ${cell}: run4 ${${param}_throughput_run4} ${operation} run3 ${${param}_throughput_run3}
       Log To Console    Verify that ${msg}
       ${result}   Set Variable If   ${${param}_throughput_run4} ${operation} ${${param}_throughput_run3}  Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${msg}
    END


Verify Egate Logs EB
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB006139_EB_ET_TC12_InterGnb_SCell_Addition_CsiRs_Downgrade_MIMO_Robustness_Test
    ...       :Autor: Sylvia Schneider
    Add Line Numbers To Egate Console Log
    Set Test Variable   ${egate_file}  ${resultDir}/egate_console_upd.log
    Run Keyword And Continue On Failure    Verify Egate EB Scells 1 And 2 And 3 Are Activated In 1st Measurement Period
    Run Keyword And Continue On Failure    Verify Egate EB Scell 3 Released In 1st Measurement Period
    Run Keyword And Continue On Failure    Verify Egate EB Scell 1 Released In 1st Measurement Period
    Run Keyword And Continue On Failure    Verify Egate EB CSI-RS Downgrade In Scell 2 In 1st Measurement Period

    Run Keyword And Continue On Failure    Verify Egate EB Scells 1 And 3 Are Activated In 2nd Measurement Period
    Run Keyword And Continue On Failure    Verify MIMO Layers In sCellConfigDedicated Scell 1 2 3 In 2nd Measurement Period
    Run Keyword And Continue On Failure    Verify Egate EB Scell 2 Is Activated In 2nd Measurement Period
    Run Keyword And Continue On Failure    Verify Egate EB Scell 2 Released In 2nd Measurement Period
    Run Keyword And Continue On Failure    Verify MIMO Layers In sCellConfigDedicated Scell 2 In 2nd Measurement Period
    Run Keyword And Continue On Failure    Verify Egate EB Scell 2 Activated After 2nd Traffic In 2nd Measurement Period


Verify Egate EB Scells 1 And 2 And 3 Are Activated In 1st Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scells 1 And 2 And 3 Are Activated In 1st Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify Scell1, Scell2, Scell3 activated in 1st measurement period
    ${int_line_scell1_act}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:54] SCellIndex 1 activated successfully at airphone
    Log To Console    -- PhysCellId:54, SCellIndex 1 activated successfully at airphone found in line ${int_line_scell1_act}

    ${int_line_scell2_act}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:56] SCellIndex 2 activated successfully at airphone
    Log To Console    -- PhysCellId:56, SCellIndex 2 activated successfully at airphone found in line ${int_line_scell2_act}

    ${int_line_scell3_act}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:57] SCellIndex 3 activated successfully at airphone
    Log To Console    -- PhysCellId:57,SCellIndex 3 activated successfully at airphone found in line ${int_line_scell3_act}
    ${int_line_trf_start}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ...   occurance=0
    Log To Console    -- trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175 found in line ${int_line_trf_start}
    ${int_line_ue_stats}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=ue_stats_nr id=2 scell=0-5
    ...   occurance=0
    Log To Console    scell activation must be between traffic start line ${int_line_trf_start} and 1st ue stats of UE2 line ${int_line_ue_stats}
    FOR   ${scell}   IN   1   2   3
       Log To Console    ----verify that scell${scell} activate line ${int_line_scell${scell}_act} is inbetween
       Run Keyword And Continue On Failure    Should Be True   ${int_line_trf_start} < ${int_line_scell${scell}_act} < ${int_line_ue_stats}
    END


Verify Egate EB Scell 3 Released In 1st Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scell 3 Released In 1st Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify scell3 released, 1st measurement period
    ${int_line_testmode_scell3_prof2}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=2 scell=3 testmode=csi_override action=activate profile_id=2
    Log To Console    -- ue_testmode_set_nr id=2 scell=3 testmode=csi_override action=activate profile_id=2 in line ${int_line_testmode_scell3_prof2}
    ${int_line_testmode_scell3_prof1}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=2 scell=3 testmode=csi_override action=activate profile_id=1
    Log To Console    -- ue_testmode_set_nr id=2 scell=3 testmode=csi_override action=activate profile_id=1 in line ${int_line_testmode_scell3_prof1}
    ${int_line_scell3_release}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:57] SCellIndex 3 deactivated successfully at airphone
    Log To Console    -- PhysCellId:57, SCellIndex 3 deactivated successfully at airphone in line ${int_line_scell3_release}
    ${msg}   Set Variable
    ...    ${int_line_testmode_scell3_prof2} < PhysCellId:57,SCellIndex 3 deactivated ${int_line_scell3_release} < ${int_line_testmode_scell3_prof1}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_testmode_scell3_prof2} < ${int_line_scell3_release} < ${int_line_testmode_scell3_prof1}


Verify Egate EB Scell 1 Released In 1st Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scell 1 Released In 1st Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify scell1 released, 1st measurement period
    ${int_line_testmode_scell1_prof2}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=2 scell=1 testmode=csi_override action=activate profile_id=2
    Log To Console    -- ue_testmode_set_nr id=2 scell=1 testmode=csi_override action=activate profile_id=2 in line ${int_line_testmode_scell1_prof2}
    ${int_line_testmode_scell1_prof1}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=2 scell=1 testmode=csi_override action=activate profile_id=1
    Log To Console    -- ue_testmode_set_nr id=2 scell=1 testmode=csi_override action=activate profile_id=1 in line ${int_line_testmode_scell1_prof1}
    ${int_line_scell1_release}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:54] SCellIndex 1 deactivated successfully at airphone
    Log To Console    -- PhysCellId:54, SCellIndex 1 deactivated successfully at airphone in line ${int_line_scell1_release}
    ${msg}   Set Variable
    ...    ${int_line_testmode_scell1_prof2} < PhysCellId:54, SCellIndex 1 deactivated ${int_line_scell1_release} < ${int_line_testmode_scell1_prof1}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_testmode_scell1_prof2} < ${int_line_scell1_release} < ${int_line_testmode_scell1_prof1}


Verify Egate EB CSI-RS Downgrade In Scell 2 In 1st Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB CSI-RS Downgrade in Scell 2 In 1st Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nPCI-57 and PCI-54 are added with CSI-RS downgrade in SCELL-2 (PCI 56) after PCI-54 is added
    ${int_line_trf_start}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ...   occurance=1
    Log To Console    -- trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175 found in line ${int_line_trf_start}

    ${int_line_scell1_act}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:57] SCellIndex 1 activated successfully at airphone
    Log To Console    -- PhysCellId:57, SCellIndex 1 activated successfully at airphone found in line ${int_line_scell1_act}

    ${int_line_scell2}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=sCellIndex 2,
    ...   occurance=1
    Log To Console    -- "sCellIndex 2," found in line ${int_line_scell2}

    ${msg}   Set Variable
    ...    ${int_line_trf_start} < SCell 1 activated ${int_line_scell1_act} < ${int_line_scell2}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_trf_start} < ${int_line_scell1_act} < ${int_line_scell2}

    ${int_line_nzpReleaseList}   Search For 1 Entry And Return Line Number
    ...    nzp-CSI-RS-ResourceToReleaseList
    Log To Console    -- nzp-CSI-RS-ResourceToReleaseList in line ${int_line_nzpReleaseList}
    ${msg}   Set Variable
    ...    "sCellIndex 2," ${int_line_scell2} < nzp-CSI-RS-ResourceToReleaseList ${int_line_nzpReleaseList}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_scell2} < ${int_line_nzpReleaseList}

    ${int_line_scell3_act}   Search For 1 Entry And Return Line Number
    ...    UeId:1,SubcellId:[0-9][0-9],PhysCellId:54] SCellIndex 3 activated successfully at airphone
    Log To Console    -- PhysCellId:54, SCellIndex 3 activated successfully at airphone found in line ${int_line_scell3_act}
    ${msg}   Set Variable
    ...    nzp-CSI-RS-ResourceToReleaseList ${int_line_nzpReleaseList} < activate Scell3 ${int_line_scell3_act}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_nzpReleaseList} < ${int_line_scell3_act}

    Verify EB nzp-CSI-RS List


Verify EB nzp-CSI-RS List
    [Documentation]    [PRIVATE]    Verify EB nzp-CSI-RS list
    ...       :Autor: Sylvia Schneider
    Log To Console    Verify nzp-CSI-RS-ResourceToReleaseList and nzp-CSI-RS-ResourceSetToAddModList are present
    ${egate_logfile}   OperatingSystem.Get File    ${resultDir}/egate/egate_console.log
    ${all_nzp}   String.Split String     ${egate_logfile}           nzp-CSI-RS-ResourceToReleaseList
    ${sCellIndex_tmp}   Set Variable      ${all_nzp}[-1]
    ${all_csi}   String.Split String      ${sCellIndex_tmp}       csi-IM-ResourceToReleaseList
    ${all_csi_tmp}      Set Variable      ${all_csi}[0]
    ${tmp1}      String.Replace String   ${all_csi_tmp}     \n     ${EMPTY}
    ${tmp2}      String.Replace String     ${tmp1}   ${SPACE}    ${EMPTY}
    ${search}    Set Variable
    ...   {182,183},nzp-CSI-RS-ResourceSetToAddModList{{nzp-CSI-ResourceSetId0,nzp-CSI-RS-Resources{0,181}}},
    Log To Console    \nverify nzp-CSI-RS-ResourceToReleaseList contains "${search}"
    ${item_present}     Run Keyword And Return Status    Should Contain    ${tmp2}     ${search}
    IF  '${item_present}'=='False'    Fail   "${search${search_id}}" not present


Verify Egate EB Scells 1 And 3 Are Activated In 2nd Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scells 1 And 3 Are Activated In 2nd Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify Scell1, Scell3 activated in 2nd measurement period
    ${int_line_scell1_act}   Search For 1 Entry And Return Line Number
    ...    UeId:0,SubcellId:[0-9][0-9],PhysCellId:55] SCellIndex 1 activated successfully at airphone
    Log To Console    -- PhysCellId:55, SCellIndex 1 activated successfully at airphone found in line ${int_line_scell1_act}

    ${int_line_scell3_act}   Search For 1 Entry And Return Line Number
    ...    UeId:0,SubcellId:[0-9][0-9],PhysCellId:57] SCellIndex 3 activated successfully at airphone
    Log To Console    -- PhysCellId:57, SCellIndex 3 activated successfully at airphone found in line ${int_line_scell3_act}

    ${int_line_trf_start}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ...   occurance=0
    Log To Console    -- trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175 found in line ${int_line_trf_start}
    ${int_line_ue_stats}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=ue_stats_nr id=1 scell=0-5
    ...   occurance=0
    Log To Console    -- ue_stats_nr id=1 scell=0-5 1st time found in line ${int_line_trf_start}
    Log To Console    scell activation must be between traffic start line ${int_line_trf_start} and 1st ue stats of UE1 line ${int_line_ue_stats}
    FOR   ${scell}   IN   1   3
       Log To Console    ----verify that scell${scell} activate line ${int_line_scell${scell}_act} is inbetween
       Run Keyword And Continue On Failure    Should Be True   ${int_line_trf_start} < ${int_line_scell${scell}_act} < ${int_line_ue_stats}
    END


Verify MIMO Layers In sCellConfigDedicated Scell 1 2 3 In 2nd Measurement Period
    [Documentation]    [PRIVATE]    Verify MIMO Layers In sCellConfigDedicated Scell 1 2 3 In 2nd Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify MIMO Layers In sCellConfigDedicated Scell 1 2 3 In 2nd Measurement Period
    ${egate_logfile}   OperatingSystem.Get File    ${resultDir}/egate/egate_console.log
    ${all}   String.Split String     ${egate_logfile}           trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ${all_1st_traffic}   Set Variable      ${all}[1]
    ${tmp1}      String.Replace String   ${all_1st_traffic}     \n     ${EMPTY}
    ${tmp2}      String.Replace String     ${tmp1}   ${SPACE}    ${EMPTY}
    ${search}   Set Variable   sCellIndex1,sCellConfigDedicated{pdsch-ServingCellConfigsetup:{nrofHARQ-ProcessesForPDSCHn16,maxMIMO-Layers2},
    Log To Console    "${search}" present
    ${item_present}     Run Keyword And Return Status    Should Contain    ${tmp2}     ${search}
    IF  '${item_present}'=='False'    Fail   "${search}" not present


Verify Egate EB Scell 2 Is Activated In 2nd Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scell 2 Is Activated In 2nd Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify Scell 2 Is Activated after MIMO Layers In 2nd Measurement Period
    ${int_line_scell2_act}   Search For 1 Entry And Return Line Number
    ...    UeId:0,SubcellId:[0-9][0-9],PhysCellId:54] SCellIndex 2 activated successfully at airphone
    Log To Console    -- PhysCellId:54, SCellIndex 2 activated successfully at airphone in line ${int_line_scell2_act}
    ${int_line_scell3_act}   Search For 1 Entry And Return Line Number
    ...    UeId:0,SubcellId:[0-9][0-9],PhysCellId:57] SCellIndex 3 activated successfully at airphone
    ${int_line_ue_stats}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=ue_stats_nr id=1 scell=0-5
    ...   occurance=0
    Log To Console    -- ue_stats_nr id=1 scell=0-5 1st time found in line ${int_line_ue_stats}
    Log To Console    -- scell2 activation must be between scell3 activation ${int_line_scell3_act} and 1st ue stats of UE1 line ${int_line_ue_stats}
    Run Keyword And Continue On Failure    Should Be True   ${int_line_scell3_act} < ${int_line_scell2_act} < ${int_line_ue_stats}


Verify Egate EB Scell 2 Released In 2nd Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scell 2 Released In 2nd Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify scell2 released, 2nd measurement period
    ${int_line_testmode_scell2_prof2}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=2
    Log To Console    -- ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=2 in line ${int_line_testmode_scell2_prof2}
    ${int_line_testmode_scell2_prof1}   Search For 1 Entry And Return Line Number
    ...    ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=1
    Log To Console    -- ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=1 in line ${int_line_testmode_scell2_prof1}
    ${int_line_scell2_release}   Search For 1 Entry And Return Line Number
    ...   UeId:0,SubcellId:[0-9][0-9],PhysCellId:54] SCellIndex 2 deactivated successfully at airphone
    Log To Console    -- PhysCellId: 54 ,SCellIndex 2 deactivated successfully at airphone in line ${int_line_scell2_release}
    ${msg}   Set Variable
    ...    ${int_line_testmode_scell2_prof2} < SCellIndex 2 deactivated ${int_line_scell2_release} < ${int_line_testmode_scell2_prof1}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_testmode_scell2_prof2} < ${int_line_scell2_release} < ${int_line_testmode_scell2_prof1}


Verify MIMO Layers In sCellConfigDedicated Scell 2 In 2nd Measurement Period
    [Documentation]    [PRIVATE]    Verify MIMO Layers In sCellConfigDedicated Scell 2 In 2nd Measurement Period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify MIMO Layers In sCellConfigDedicated Scell 1
    ${egate_logfile}   Get File    ${resultDir}/egate/egate_console.log
    ${all}   Split String     ${egate_logfile}           trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ${all_2nd_traffic}   Set Variable      ${all}[2]
    ${tmp1}      Replace String   ${all_2nd_traffic}     \n     ${EMPTY}
    ${tmp2}      Replace String     ${tmp1}   ${SPACE}    ${EMPTY}
    ${search}   Set Variable   sCellIndex1,sCellConfigDedicated{pdsch-ServingCellConfigsetup:{nrofHARQ-ProcessesForPDSCHn16,maxMIMO-Layers4},
    Log To Console    "${search}" present
    ${item_present}     Run Keyword And Return Status    Should Contain    ${tmp2}     ${search}
    IF  '${item_present}'=='False'    Fail   "${search}" not present


Verify Egate EB Scell 2 Activated After 2nd Traffic In 2nd Measurement Period
    [Documentation]    [PRIVATE]    Verify Egate EB Scell 2 Activated After 2nd Traffic In 2nd Measurement Period
    ...       :Autor: Sylvia Schneider
    ${int_line_trf_start}   Search For Several Entries And Return Line Number Of Specified Occurance
    ...   search=trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ...   occurance=1
    Log To Console    -- trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175 found in line ${int_line_trf_start}

    ${int_line_scell2_act}   Search For 1 Entry And Return Line Number
    ...    UeId:0,SubcellId:[0-9][0-9],PhysCellId:56] SCellIndex 2 activated successfully at airphone
    Log To Console    -- PhysCellId:56, SCellIndex 2 activated successfully at airphone in line ${int_line_scell2_act}
    ${msg}   Set Variable
    ...    ${int_line_trf_start} < SCellIndex 2 activated ${int_line_scell2_act}
    Log To Console    ----verify that ${msg}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${int_line_trf_start} < ${int_line_scell2_act}
