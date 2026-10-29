*** Settings ***
Documentation   This is a keyword file for CB006139 DA part egate verify
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

verify egate logs DA_B3
    [Documentation]    [PRIVATE]    verify egate logs DA_B3
    ...       :Autor: Sylvia Schneider
    add line numbers to egate console log
    set test variable   ${egate_file}  ${resultDir}/egate_console_upd.log

    verify egate logs UE1 DA_B3
    verify egate logs UE2 DA_B3
    get and verify throughput DA_B3
    verify nzp-CSI-RS list


search for all DL CHANNEL of UE${ue_id}
    [Documentation]    [PRIVATE]    search for all DL CHANNEL of a defined UE
    ...       :Autor: Sylvia Schneider
    ${egate_ue_id}    Evaluate   ${ue_id}-1
    ${search}    Set Variable   DL CHANNEL> [UeId:${egate_ue_id},
    ${found_list}  Grep File   ${egate_file}       ${search}
    RETURN     ${found_list}


search for 1 entry in DL CHANNEL list
    [Documentation]    [PRIVATE]    search for 1 entry in DL CHANNEL list
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${DL_CHANNEL}   ${search}
    ${found}  Get Lines Containing String   ${DL_CHANNEL}       ${search}
    ${line_found}       Get Regexp Matches    ${found}    ^[0-9]*
    ${int_line_found}   convert to integer    ${line_found}[0]
    RETURN    ${int_line_found}


verify egate logs UE1 DA_B3
    [Documentation]    [PRIVATE]    verify egate logs UE1 DA_B3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify traffic start UE1
    ${int_line_trf_start_UE1}   search for 1 entry and return line number    trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    Log To Console    UE1 DL traffic started in line ${int_line_trf_start_UE1}
    ${int_line_trf_ready_UE1}   search for 1 entry and return line number    ue_stats_nr id=1 scell=0-5 type=pdsch
    Log To Console    UE1 Ue Stats in line ${int_line_trf_ready_UE1}

    ${DL_CHANNEL_UE1}   search for all DL CHANNEL of UE1
    Log To Console    verify UE1 DL CHANNEL after traffic data start and before ue_stats
    FOR   ${PhysCellId}   ${SCellIndex}   IN
    ...   55              4
    ...   57              5
    ...   52              2
    ...   51              1
    ...   53              3
       ${search}  set variable
       ...  PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       Log to console   --search for "${search}"
       ${int_line_dl_channel}   search for 1 entry in DL CHANNEL list  ${DL_CHANNEL_UE1}   ${search}
       Log To Console    ----found in line ${int_line_dl_channel},
       Log To Console    ----verify that line is between traffic data start ${int_line_trf_start_UE1} and ue_stats ${int_line_trf_ready_UE1}
       run keyword and continue on failure    should be true   ${int_line_trf_start_UE1} < ${int_line_dl_channel} < ${int_line_trf_ready_UE1}
    END


verify egate logs UE2 DA_B3
    [Documentation]    [PRIVATE]    verify egate logs UE2 DA_B3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify traffic start UE2

    ${DL_CHANNEL_UE2}   search for all DL CHANNEL of UE2

    ${int_line_trf_start_UE2}   search for 1 entry and return line number    trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    Log To Console    UE2 DL traffic started in line ${int_line_trf_start_UE2}
    ${int_line_trf_ready_UE2}   search for 1 entry and return line number    trf_data_stop ue=2 pdu=1 qfi=1 dir=dl
    Log To Console    UE2 DL traffic data stop ${int_line_trf_ready_UE2}
    Log To Console    verify UE1 DL CHANNEL after traffic data start and before trf_data_stop
    FOR   ${PhysCellId}   ${SCellIndex}   IN
    ...   57              3
    ...   52              2
    ...   51              1
       ${search}  set variable
       ...  PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       Log to console   --search for "${search}"
       ${int_line_dl_channel}   search for 1 entry in DL CHANNEL list  ${DL_CHANNEL_UE2}   ${search}
       Log To Console    ----found in line ${int_line_dl_channel},
       Log To Console    ----verify that line is between traffic data start ${int_line_trf_start_UE2} and ue_stats ${int_line_trf_ready_UE2}
       run keyword and continue on failure    should be true   ${int_line_trf_start_UE2} < ${int_line_dl_channel} < ${int_line_trf_ready_UE2}
    END

    ${search}  set variable   ue_testmode_set_nr id=2 scell=2 testmode=csi_override action=activate profile_id=2
    ${int_line_act_prof2}   search for 1 entry and return line number    ${search}
    Log To Console    --search for "${search}"\n----found in line ${int_line_act_prof2}
    ${search}  set variable   PhysCellId:52] SCellIndex 2 deactivated successfully at airphone
    ${int_line_deact}   search for 1 entry in DL CHANNEL list  ${DL_CHANNEL_UE2}   ${search}
    Log To Console    --search for "${search}"\n----found in line ${int_line_deact}
    Log To Console    ----verify that line is after activate profile_id=2 ${int_line_act_prof2}
    run keyword and continue on failure    should be true   ${int_line_act_prof2} < ${int_line_deact}

    ${search}  set variable   PhysCellId:55] SCellIndex 2 activated successfully at airphone
    ${int_line_dl_channel}   search for 1 entry in DL CHANNEL list  ${DL_CHANNEL_UE2}   ${search}
    Log To Console    --search for "${search}"\n----found in line ${int_line_dl_channel}
    Log To Console    ----verify that line is after SCellIndex 2 deactivated ${int_line_deact}
    run keyword and continue on failure    should be true   ${int_line_deact} < ${int_line_dl_channel}


get and verify throughput DA_B3
    [Documentation]    [PRIVATE]    get and verify throughput DA_B3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget and verify DL throughput value
    Log To Console    verify file egate_throughput_pdsch_ue2_3.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue2_3.txt
    ${average_throughput_DL}    get average throughput  ${contents}  DL   4 cells
    Log To Console    --- DL throughput is ${average_throughput_DL}
    Log To Console    Verify that average_throughput DL is greater than 1200 Mbit/s
    ${result}   Set Variable If   ${average_throughput_DL} > 1200  Passed   Failed
    IF    '${result}'=='Failed'
    ...   Run Keyword And Continue On Failure    Fail    failed ${average_throughput_DL} > 1200

    Log To Console    \nget and verify UL throughput value
    Log To Console    verify file egate_throughput_pusch_ue2_3.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_ue2_3.txt
    ${average_throughput_UL}    Get Average Throughput  ${contents}  UL   1 cell
    Log To Console    --- UL throughput is ${average_throughput_UL}
    Log To Console    Verify that average_throughput UL is greater than 13 Mbit/s
    ${result}   Set Variable If   ${average_throughput_UL} > 13  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_UL} > 13


verify nzp-CSI-RS list
    [Documentation]    [PRIVATE]    verify nzp-CSI-RS list
    ...       :Autor: Sylvia Schneider
    ${egate_file}   Get File    ${resultDir}/egate/egate_console.log
    ${all_sCellIndex2}   Split String     ${egate_file}           sCellIndex 2,
    ${sCellIndex_tmp}   Set Variable      ${all_sCellIndex2}[-1]
    ${all_sCellIndex}   Split String      ${sCellIndex_tmp}       sCellIndex 3,

    ${search2}   Set Variable   nzp-CSI-RS-ResourceSetToAddModList{{nzp-CSI-ResourceSetId0,nzp-CSI-RS-Resources{0,181}}
    ${search3}   Set Variable
    ...     nzp-CSI-RS-ResourceToReleaseList{182,183},nzp-CSI-RS-ResourceSetToAddModList{{nzp-CSI-ResourceSetId0,nzp-CSI-RS-Resources{0,181}}
    FOR   ${index}     ${search_id}     IN
    ...   0            2
    ...   1            3
       Log To Console    \nverify nzp-CSI-RS list sCellIndex ${search_id} contains "${search${search_id}}"
       ${sCellIndex_tmp}      Set Variable      ${all_sCellIndex}[${index}]
       ${tmp1}      Replace String   ${sCellIndex_tmp}     \n     ${EMPTY}
       ${tmp2}      Replace String     ${tmp1}   ${SPACE}    ${EMPTY}
       ${item_present}     Run Keyword And Return Status    Should Contain    ${tmp2}     ${search${search_id}}
       IF  '${item_present}'=='False'    Fail   "${search${search_id}}" not present
    END


verify egate logs DA_B12
    [Documentation]    [PRIVATE]    verify egate logs DA_B12
    ...       :Autor: Sylvia Schneider
    add line numbers to egate console log
    set test variable   ${egate_file}  ${resultDir}/egate_console_upd.log
    verify DL_CHANNEL UE1
    verify uplinkTxSwitching-r16 setup and sCellToAddModList


verify DL_CHANNEL UE1
    [Documentation]    [PRIVATE]    verify DL_CHANNEL UE1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1
    ${DL_CHANNEL_UE1}   search for all DL CHANNEL of UE1

    ${int_line_trf_start_UE1}   search for 1 entry and return line number
    ...    trf_data_start ue=1 dir=dl trf_id=1 protocol=udp ack_mode=off cl_trf_stats=on mbps=175 pdu=1 qfi=1
    Log To Console    UE1 DL traffic started in line ${int_line_trf_start_UE1}
    ${int_line_csi_overwrite}   search for 1 entry and return line number
    ...    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=1 ri_mode=fixed ri=3 pmi_mode=fixed pmi=0
    Log To Console    csi_override_testmode ${int_line_csi_overwrite}
    Log To Console    verify UE1 DL CHANNEL after traffic data start and csi_overwrite_testmode
    FOR   ${PhysCellId}   ${SCellIndex}   IN
    ...   52              2
    ...   51              1
    ...   53              3
       ${search}  set variable
       ...  PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       Log to console   --search for "${search}"
       ${int_line_dl_channel}   search for 1 entry in DL CHANNEL list  ${DL_CHANNEL_UE1}   ${search}
       Log To Console    ----found in line ${int_line_dl_channel},
       Log To Console    ----verify that line is between traffic data start ${int_line_trf_start_UE1} and ue_stats ${int_line_csi_overwrite}
       run keyword and continue on failure    should be true   ${int_line_trf_start_UE1} < ${int_line_dl_channel} < ${int_line_csi_overwrite}
    END

    ${search}  set variable   ue_testmode_set_nr id=1 scell=3 testmode=csi_override action=activate profile_id=2
    ${int_line_act_prof2}   search for 1 entry and return line number    ${search}
    Log To Console    --search for "${search}"\n----found in line ${int_line_act_prof2}
    ${search}  set variable   PhysCellId:53] SCellIndex 3 deactivated successfully at airphone
    ${int_line_deact}   search for 1 entry in DL CHANNEL list  ${DL_CHANNEL_UE1}   ${search}
    Log To Console    --search for "${search}"\n----found in line ${int_line_deact}
    Log To Console    ----verify that line is after activate profile_id=2 ${int_line_act_prof2}
    run keyword and continue on failure    should be true   ${int_line_act_prof2} < ${int_line_deact}


verify uplinkTxSwitching-r16 setup and sCellToAddModList
    [Documentation]    [PRIVATE]    verify uplinkTxSwitching-r16 setup and sCellToAddModList
    ...       :Autor: Sylvia Schneider
    ${egate_file}   Get File    ${resultDir}/egate/egate_console.log

    ${split_uplinkTx}             Set Variable   uplinkTxSwitching-r16 setup :
    ${split_sCellIndex}           Set Variable   sCellToAddModList
    ${search_uplinkTx_detail}     Set Variable   {uplinkTxSwitchingPeriodLocation-r16TRUE,uplinkTxSwitchingCarrier-r16carrier1}
    ${search_sCellIndex_detail}   Set Variable   {sCellIndex3,sCellConfigCommon{physCellId54,
    ${text_uplinkTx}              Set Variable   uplinkTxSwitching-r16 setup
    ${text_sCellIndex}            Set Variable   sCellToAddModList

    FOR    ${topic}    IN     uplinkTx    sCellIndex
       Log To Console    \nverify ${text_${topic}} contains "${search_${topic}_detail}"
       ${all_split}   Split String     ${egate_file}           ${split_${topic}}
       ${tmp1}   Set Variable      ${all_split}[-1]
       ${tmp2}                 Replace String   ${tmp1}   \n          ${EMPTY}
       ${egate_string}    Replace String   ${tmp2}                    ${SPACE}    ${EMPTY}
       ${item_present}     Run Keyword And Return Status    Should Contain    ${egate_string}     ${search_${topic}_detail}
       IF  '${item_present}'=='False'    Fail   "${search_${topic}_detail}" not present
    END


verify egate logs DA_B1
    [Documentation]    [PRIVATE]    verify egate logs DA_B1
    ...       :Autor: Sylvia Schneider
    add line numbers to egate console log
    set test variable   ${egate_file}  ${resultDir}/egate_console_upd.log
    verify DL_CHANNEL UE1 DA_B1 4SCell activation
    verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 53
    verify DL_CHANNEL UE1 DA_B1 activate PhysCellId 52
    verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 52
    verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 55
    verify DL_CHANNEL UE1 DA_B1 activate PhysCellId 52 again
    get and verify throughput DA_B1 after 4SCell activation
    get and verify throughput DA_B1 after last SCell addition PhysCellId 52
    verify DA_B1 rrc message of 1st add PhysCellId 52 SCellIndex 2 maxMIMO for PCell
    verify DA_B1 rrc message of 2nd add PhysCellId 52 SCellIndex 2 maxMIMO for PCell and SCell


verify DL_CHANNEL UE1 DA_B1 4SCell activation
    [Documentation]    [PRIVATE]    verify DL_CHANNEL UE1 DA_B1 4SCell activation
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1 4SCell activation phyCellId 53,55,51,54
    ${DL_CHANNEL_UE1}   search for all DL CHANNEL of UE1
    ${int_line_csi_override_cqi1}   Search For 1 Entry And Return Line Number
    ...    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=1 ri_mode=fixed ri=3 pmi_mode=fixed pmi=0
    Log To Console    csi override cqi=1 started in line ${int_line_csi_override_cqi1}
    ${int_line_ul_traffic}   search for 1 entry and return line number
    ...    trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=ul mbps=12
    Log To Console    UL traffic started in line ${int_line_ul_traffic}
    Log To Console    verify UE1 DL CHANNEL after traffic data start and csi_overwrite_testmode
    FOR   ${PhysCellId}   ${SCellIndex}   IN
    ...   53              2
    ...   55              4
    ...   51              1
    ...   54              3
       ${search}  set variable
       ...  PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       Log to console   --search for "${search}"
       ${int_line_dl_channel}   Search For 1 Entry In DL CHANNEL List  ${DL_CHANNEL_UE1}   ${search}
       Log To Console    ----found in line ${int_line_dl_channel},
       Log To Console    ----verify that line is between traffic data start ${int_line_csi_override_cqi1} and ue_stats ${int_line_ul_traffic}
       Run Keyword And Continue On Failure    Should Be True   ${int_line_csi_override_cqi1} < ${int_line_dl_channel} < ${int_line_ul_traffic}
    END


verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 53
    [Documentation]    [PRIVATE]    verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 53
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1 deactivation phyCellId 53
    ${search}   Set Variable   ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=2
    ${act_prof2}   search for several entries and return line number of specified occurance   search=${search}   occurance=0
    Log To Console    1st entry "testmode activate profile 2" started in line ${act_prof2}
    ${search}   Set Variable   ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=1
    ${act_prof1}   search for several entries and return line number of specified occurance   search=${search}   occurance=0
    Log To Console    1st entry "testmode activate profile 1" started in line ${act_prof1}
    ${search}   Set Variable   PhysCellId:53] SCellIndex 2 deactivated successfully at airphone
    ${int_line_deact_53_2}   search for 1 entry and return line number    ${search}
    Log To Console    "${search}" found in line ${int_line_deact_53_2}
    Log To Console    ----verify that line is between activate profile2 ${act_prof2} and activate profile1 ${act_prof1}
    run keyword and continue on failure    should be true   ${act_prof2} < ${int_line_deact_53_2} < ${act_prof1}


verify DL_CHANNEL UE1 DA_B1 activate PhysCellId 52
    [Documentation]    [PRIVATE]   verify DL_CHANNEL UE1 DA_B1 activate PhysCellId 52
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1 activation phyCellId 52
    ${search}   Set Variable   trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ${trdId1_mbps175_2nd}   search for several entries and return line number of specified occurance   search=${search}   occurance=1
    Log To Console    2nd entry "${search}" found in line ${trdId1_mbps175_2nd}
    ${search}   Set Variable   trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=7
    ${int_line_trfid1_7mbps}   search for 1 entry and return line number    ${search}
    Log To Console    "${search}" found in line ${int_line_trfid1_7mbps}
    ${search}   Set Variable   PhysCellId:52] SCellIndex 2 activated successfully at airphone
    ${int_line_act_52_2}   search for several entries and return line number of specified occurance   search=${search}   occurance=0
    Log To Console    "${search}" found in line ${int_line_act_52_2}
    Log To Console
    ...    ----verify that line is between 2nd traffic start 175mbps ${trdId1_mbps175_2nd} and reduce traffic 7mbps ${int_line_trfid1_7mbps}
    run keyword and continue on failure    should be true   ${trdId1_mbps175_2nd} < ${int_line_act_52_2} < ${int_line_trfid1_7mbps}


verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 52
    [Documentation]    [PRIVATE]    verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 52
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1 deactivation phyCellId 52
    ${search}   Set Variable   ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=2
    ${act_prof2}   search for several entries and return line number of specified occurance   search=${search}   occurance=1
    Log To Console    2nd entry "testmode activate profile 2" started in line ${act_prof2}
    ${search}   Set Variable   ue_testmode_set_nr id=1 scell=2 testmode=csi_override action=activate profile_id=1
    ${act_prof1}   search for several entries and return line number of specified occurance   search=${search}   occurance=1
    Log To Console    2nd entry "testmode activate profile 1" started in line ${act_prof1}
    ${search}   Set Variable   PhysCellId:52] SCellIndex 2 deactivated successfully at airphone
    ${int_line_deact_52_2}   search for 1 entry and return line number    ${search}
    Log To Console    "${search}" found in line ${int_line_deact_52_2}
    Log To Console    ----verify that line is between activate profile2 ${act_prof2} and activate profile1 ${act_prof1}
    run keyword and continue on failure    should be true   ${act_prof2} < ${int_line_deact_52_2} < ${act_prof1}


verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 55
    [Documentation]    [PRIVATE]    verify DL_CHANNEL UE1 DA_B1 deactivate PhysCellId 55
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1 deactivation phyCellId 55
    ${search}   Set Variable   ue_testmode_set_nr id=1 scell=4 testmode=csi_override action=activate profile_id=2
    ${act_prof2}   search for 1 entry and return line number    ${search}
    Log To Console    "${search}" found in line ${act_prof2}
    ${search}   Set Variable   ue_testmode_set_nr id=1 scell=4 testmode=csi_override action=activate profile_id=1
    ${act_prof1}   search for 1 entry and return line number    ${search}
    Log To Console    "${search}" found in line ${act_prof1}
    ${search}   Set Variable   PhysCellId:55] SCellIndex 4 deactivated successfully at airphone
    ${int_line_deact_55_4}   search for 1 entry and return line number    ${search}
    Log To Console    "${search}" found in line ${int_line_deact_55_4}
    Log To Console    ----verify that line is between activate profile2 ${act_prof2} and activate profile1 ${act_prof1}
    run keyword and continue on failure    should be true   ${act_prof2} < ${int_line_deact_55_4} < ${act_prof1}


verify DL_CHANNEL UE1 DA_B1 activate PhysCellId 52 again
    [Documentation]    [PRIVATE]   verify DL_CHANNEL UE1 DA_B1 activate PhysCellId 52 again
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify DL_CHANNEL UE1 activation phyCellId 52 again
    ${search}   Set Variable   PhysCellId:52] SCellIndex 2 activated successfully at airphone
    ${int_line_act_52_2}   search for several entries and return line number of specified occurance   search=${search}   occurance=1
    Log To Console    "${search}" found in line ${int_line_act_52_2}
    ${search}   Set Variable   trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ${trdId1_mbps175_3rd}   search for several entries and return line number of specified occurance   search=${search}   occurance=2
    Log To Console    3rd entry "${search}" found in line ${trdId1_mbps175_3rd}
    Log To Console    ----verify that line is after 3rd entry "${search}" ${trdId1_mbps175_3rd}
    run keyword and continue on failure    should be true   ${trdId1_mbps175_3rd} < ${int_line_act_52_2}


get and verify throughput DA_B1 after 4SCell activation
    [Documentation]    [PRIVATE]    get and verify throughput DA_B1 after 4SCell activation
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget and verify DL throughput value after 4SCell activation
    Log To Console    verify file egate_throughput_pdsch_ue1_1.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue1_1.txt
    ${average_throughput_DL}    get average throughput  ${contents}  DL   5 cells
    Log To Console    Verify that average_throughput DL is greater than 300 Mbit/s
    IF    ${average_throughput_DL} <= 300
    ...   Run Keyword And Continue On Failure    Fail    failed ${average_throughput_DL} > 300

    Log To Console    \nget and verify UL throughput value after 4SCell activation
    Log To Console    verify file egate_throughput_pusch_ue1_1.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_ue1_1.txt
    ${average_throughput_UL}    get average throughput  ${contents}  UL   2 cells
    Log To Console    Verify that average_throughput UL is greater than 10 Mbit/s
    IF    ${average_throughput_UL} <= 10
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_UL} > 10


get and verify throughput DA_B1 after last SCell addition PhysCellId 52
    [Documentation]    [PRIVATE]    get and verify throughput DA_B1 after last SCell addition PhysCellId 52
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget and verify throughput DA_B1 after last SCell addition PhysCellId 52
    Log To Console    verify file egate_throughput_pdsch_ue1_8.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue1_8.txt
    ${average_throughput_DL}    get average throughput  ${contents}  DL   4 cells
    Log To Console    Verify that average_throughput DL is greater than 800 Mbit/s
    IF    ${average_throughput_DL} <= 800
    ...   Run Keyword And Continue On Failure    Fail    failed ${average_throughput_DL} > 800


verify DA_B1 rrc message of 1st add PhysCellId 52 SCellIndex 2 maxMIMO for PCell
    [Documentation]    [PRIVATE]    verify DA_B1 rrc message of 1st add PhysCellId 52 SCellIndex 2 maxMIMO for PCell
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify DA_B1 rrc message of 1st add PhysCellId 52 SCellIndex 2 maxMIMO for PCell
    ${egate_file}   Get File    ${resultDir}/egate/egate_console.log
    ${end_mimo}    Set Variable   PhysCellId:52] SCellIndex 2 activated successfully at airphone
    ${rrc_start}   Set Variable   message c1 : rrcReconfiguration :
    ${end_mimo_split}    Split String     ${egate_file}           ${end_mimo}
    ${rrc_start_split}   Split String     ${end_mimo_split}[0]          ${rrc_start}
    ${rrc}  Set Variable   ${rrc_start_split}[-1]

    ${search}   Set Variable   maxMIMO-Layers 2
    Log To Console    ---verify rrc message PCell part: "${search}" contained before sCellToAddModList
    ${sCellToAddModList_split}   Split String     ${rrc}   sCellToAddModList
    ${MIMO_PCell}   Set Variable   ${sCellToAddModList_split}[0]
    ${item_present}     Run Keyword And Return Status    Should Contain    ${MIMO_PCell}     ${search}
    IF  not ${item_present}    Fail   "${search}" not present


verify DA_B1 rrc message of 2nd add PhysCellId 52 SCellIndex 2 maxMIMO for PCell and SCell
    [Documentation]    [PRIVATE]    verify DA_B1 rrc message of 2nd add PhysCellId 52 SCellIndex 2 maxMIMO for PCell and SCell
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify DA_B1 rrc message of 2nd add PhysCellId 52 SCellIndex 2 maxMIMO for PCell and SCell
    ${egate_file}   Get File    ${resultDir}/egate/egate_console.log
    ${end_mimo}    Set Variable   PhysCellId:52] SCellIndex 2 activated successfully at airphone
    ${rrc_start}   Set Variable   message c1 : rrcReconfiguration :
    ${end_mimo_split}    Split String     ${egate_file}           ${end_mimo}
    ${rrc_start_split}   Split String     ${end_mimo_split}[1]          ${rrc_start}
    ${rrc}  Set Variable   ${rrc_start_split}[-1]

    ${search}   Set Variable   maxMIMO-Layers 4
    Log To Console    ---verify rrc message PCell part: "${search}" contained before sCellToAddModList
    ${sCellToAddModList_split}   Split String     ${rrc}   sCellToAddModList
    ${MIMO_PCell}   Set Variable   ${sCellToAddModList_split}[0]
    ${item_present}     Run Keyword And Return Status    Should Contain    ${MIMO_PCell}     ${search}
    IF  not ${item_present}    Fail   "${search}" not present

    Log To Console    ---verify rrc message MIMO switch for sCellIndex 3 contains "${search}"
    ${sCell3_split}   Split String     ${rrc}   sCellIndex 3,
    ${item_present}     Run Keyword And Return Status    Should Contain    ${sCell3_split}[1]     ${search}
    IF  not ${item_present}    Fail   "${search}" not present
