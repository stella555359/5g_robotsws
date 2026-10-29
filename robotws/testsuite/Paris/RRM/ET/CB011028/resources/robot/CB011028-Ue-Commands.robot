*** Settings ***
Documentation     [PURPOSE] Set of keywords used for CB009890 feature tests cases
...                         using only ute_wtssim library
...               http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html
...
...               Automation author           : christophe.samson@nokia.com
...               Automation contact          : christophe.samson@nokia.com
...               Creation Date               : 31-March-2023
...               Modified Date               : 31-March-2023
...               Last Modified by            : christophe.samson@nokia.com

Library         ute_wtssim
Library         taf.wts.runner       WITH NAME    wtsemu
Library         ../python/avg_dl_data.py
Library         ../python/avg_ul_data.py

Library         ../../../resources/DSS/python/robot_extension.py          WITH NAME          robot_extension_CB011028

*** Keywords ***

Get PDSCH and PUSCH ue_stats_nr
   [arguments]     ${ue_id}=1   ${DLthroughput}=0    ${ULthroughput}=0   ${CallType}=NSA
   ${scell_idx}   set variable if    '${CallType}'=='NSA'     8
   ...                                                        0

   ${dltput_contain_kbps}  ${message}=    Run Keyword And Ignore Error    should contain    ${DLthroughput}   k    ignore_case=True
   # run Keyword if      '${dltput_contain_kbps}'=='PASS'     dated log     dl tput value is kbps
   # ...     ELSE                                             dated log     dl tput value is mbps
   ${ultput_contain_kbps}  ${message}=    Run Keyword And Ignore Error    should contain    ${ULthroughput}   k    ignore_case=True
   # run Keyword if      '${ultput_contain_kbps}'=='PASS'     dated log     ul tput value is kbps
   # ...    ELSE                                              dated log     ul tput value is mbps
   ${DLTput_unit}   set variable if    '${DLthroughput}'=='0' or '${dltput_contain_kbps}'=='PASS'     Kbps
   ...                                                                                                Mbps
   ${ULTput_unit}   set variable if    '${ULthroughput}'=='0' or '${ultput_contain_kbps}'=='PASS'     Kbps
   ...                                                                                                Mbps
   ${Ue_Avg_PDSCH_Tput}=    run Keyword if    '${DLthroughput}'!='0'    Get PDSCH ue_stats_nr   ue_id=${ue_id}   scell_idx=${scell_idx}
   ...                                                                                          unit=${DLTput_unit}
   ...  ELSE                set variable   0
   sleep   1s
   ${Ue_Avg_PUSCH_Tput}=    run Keyword if    '${ULthroughput}'!='0'    Get PUSCH ue_stats_nr   ue_id=${ue_id}   scell_idx=${scell_idx}
   ...                                                                                          unit=${ULTput_unit}
   ...  ELSE                set variable   0
   ${msg}  Catenate   Ue_Avg_PDSCH_Tput=${consTraceColor}${Ue_Avg_PDSCH_Tput}${DLTput_unit}${defColor} for ${consTraceColor}ue_id=${ue_id}${defColor}
   Dated log     =======> ${msg}
   ${msg}  Catenate   Ue_Avg_PUSCH_Tput=${consTraceColor}${Ue_Avg_PUSCH_Tput}${ULTput_unit}${defColor} for ${consTraceColor}ue_id=${ue_id}${defColor}
   Dated log     =======> ${msg}
   [return]     ${Ue_Avg_PDSCH_Tput}    ${Ue_Avg_PUSCH_Tput}

Get PDSCH UE Stats for Given CC WA
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    # Log to Console    PDSCH UE stats for given CC
    # wtsemu.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    wtsemu.ue_stats_nr   id=${ue_id}    type=pdsch    scell=${scell_idx}
    ${output}    wtsemu.read_wtsemu_output_until    expected=UE-${ue_id}: NR PDSCH Throughput   timeout=10
    [Return]      ${output}

GET UE PDSCH Stats
   [Arguments]     ${ue_id}=1    ${expected}=NR PDSCH Throughput    ${w_logToConsole}=False
    ${output}    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    # TRY2 : ${output}    wtsemu.read_wtsemu_output_until_re    expected=${expected}   timeout=10
    # TRY3 : ${output}    wtsemu.read_wtsemu_output_until    expected=${expected}   timeout=10
    ${result}    Get Lines Matching Regexp    ${output}    UE-${ue_id}: NR PDSCH Throughput    partial_match=${TRUE}
    Run Keyword if   '${w_logToConsole}' == 'True'    Log to Console    ${output}
    should contain    ${output}    Average
    [Return]      ${output}

Get PDSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    # Log to Console    PDSCH UE stats for given CC
    # wtsemu.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    wtsemu.ue_stats_nr   id=${ue_id}    type=pdsch    scell=${scell_idx}
    wtsemu.Sim Log Set
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET UE PDSCH Stats    ue_id=${ue_id}   expected=Average
    [Return]      ${output}

Get AVG DL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps    ${w_logToConsole}=False
    ${pdsch_ue_stats}    Get PDSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pdsch_ue_stats}    ${unit}
	Run Keyword if   '${w_logToConsole}' == 'True'    Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

GET PUSCH UE Stats
    [Arguments]     ${expected}=NR PUSCH Throughput    ${w_logToConsole}=False
    ${output}    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    # Try2 : ${output}    wtsemu.read_wtsemu_output_until_re    expected=${expected}   timeout=10
    # Try3 : ${output}    wtsemu.read_wtsemu_output_until    expected=${expected}   timeout=10
    ${result}    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    Run Keyword if   '${w_logToConsole}' == 'True'    Log to Console    ${output}
    should contain    ${output}    Average
    [Return]      ${output}

Get PUSCH UE Stats for Given CC WA
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    # Log to Console    PUSCH UE stats for given CC
    wtsemu.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    wtsemu.read_wtsemu_output_until    expected=NR PUSCH Throughput   timeout=10
    [Return]      ${output}

Get PUSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PUSCH UE stats for given CC
    wtsemu.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET PUSCH UE Stats    expected=Average
    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}

Get AVG UL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps      ${w_logToConsole}=False
    ${pusch_ue_stats}    Get PUSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_ul_data.get_avg_ul_data_traffic    ${pusch_ue_stats}    ${unit}
	Run Keyword if   '${w_logToConsole}' == 'True'    Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get PDSCH ue_stats_nr
    [arguments]     ${ue_id}=1    ${scell_idx}=8   ${unit}=Mbps
    # ue_stats_nr id=1 type=pdsch scell=8
    ${status}   ${Ue_PDSCH_Tput}=  robot_extension_CB011028.Run Keyword And Warn On Failure   Get PDSCH UE Stats for Given CC WA    ue_id=${ue_id}
    ...                                                                                                                    scell_idx=${scell_idx}
    ${Ue_Avg_PDSCH_Tput}=  Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=${scell_idx}     unit=${unit}
    # Dated Log new line    ue_stats_nr Egate Cmd Resuls =\n${Ue_PDSCH_Tput}
    # Dated log     =======> Ue_Avg_PDSCH_Tput=${consTraceColor}${Ue_Avg_PDSCH_Tput}${unit}${defColor} for ue_id=${ue_id}
    [return]   ${Ue_Avg_PDSCH_Tput}

Get PUSCH ue_stats_nr
    [arguments]     ${ue_id}=1    ${scell_idx}=8   ${unit}=Mbps
    ${status}   ${Ue_PUSCH_Tput}=  robot_extension_CB011028.Run Keyword And Warn On Failure    Get PUSCH UE Stats for Given CC WA    ue_id=${ue_id}
    ...                                                                                                                     scell_idx=${scell_idx}
    ${Ue_Avg_PUSCH_Tput}=  Get AVG UL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=${scell_idx}     unit=${unit}
    # Dated Log new line    ue_stats_nr Egate Cmd Resuls =\n${Ue_PUSCH_Tput}
    # Dated log     =======> Ue_Avg_PUSCH_Tput=${consTraceColor}${Ue_Avg_PUSCH_Tput}${unit}${defColor} for ue_id=${ue_id}
    [return]   ${Ue_Avg_PUSCH_Tput}

Get PDSCH and PUSCH ue_stats_nr for UEList
   [arguments]     ${UEsList}   ${CallType}=NSA   ${file}=None
   StringTool.printLineWithTitle   title=Get PDSCH and PUSCH ue_stats_nr for UEList
   ${text}=   set Variable   ''
   ${Ue_Avg_PDSCH_All_Tput}    set Variable   0
   ${Ue_Avg_PUSCH_All_Tput}    set Variable   0

   FOR    ${UEcurrent}     IN      @{UEsList}
        # StringTool.printLineWithTitle   Get PDSCH and PUSCH ue_stats_nr for ue_id=${UEcurrent.ue}
        # Dated log   =========> Get PDSCH and PUSCH ue_stats_nr for ue_id=${UEcurrent.ue}
        ${ret}   ${resTput}   Run Keyword And Ignore Error    Get PDSCH and PUSCH ue_stats_nr
        ...                               ue_id=${UEcurrent.ue}
        ...                               DLthroughput=${UEcurrent.DL_throughput}
        ...                               ULthroughput=${UEcurrent.UL_throughput}
        ...                               CallType=${CallType}
        ${Ue_Avg_PDSCH_Tput}=    Set Variable    ${resTput}[0]
        ${Ue_Avg_PUSCH_Tput}=    Set Variable    ${resTput}[1]
        # Traced Sleep   1s   msg=wait to get Get PDSCH and PUSCH ue_stats_nr for ue_id=${UEcurrent.ue}
        Sleep   1s
        ${text}=   set Variable   ${text}; ${Ue_Avg_PDSCH_Tput}; ${Ue_Avg_PUSCH_Tput}
        StringTool.printLineWithTitle  title=-
        ${Ue_Avg_PDSCH_All_Tput}=   Evaluate    str(int(${Ue_Avg_PDSCH_All_Tput})+int(${Ue_Avg_PDSCH_Tput}))
        ${Ue_Avg_PUSCH_All_Tput}=   Evaluate    str(int(${Ue_Avg_PUSCH_All_Tput})+int(${Ue_Avg_PUSCH_Tput}))
        ${DLTput_unit}   set variable if    '${UEcurrent.DL_throughput}'=='0' or '${UEcurrent.DL_throughput}'=='100k'
        ...                                                                      Kbps
        ...                                                                      Mbps
        ${ULTput_unit}   set variable if    '${UEcurrent.UL_throughput}'=='0'    Kbps
        ...                                                                      Mbps
   END
   Run Keyword if    '${file}'!='None'     Log Test Tput results   text=${text}   file=${file}
   ${msg}  Catenate   Ue_Avg_PDSCH_AllTput=${consTraceColor}${Ue_Avg_PDSCH_All_Tput}${DLTput_unit}${defColor}
   Dated log     =======> ${msg}
   ${msg}  Catenate   Ue_Avg_PUSCH_AllTput=${consTraceColor}${Ue_Avg_PUSCH_All_Tput}${ULTput_unit}${defColor}
   Dated log     =======> ${msg}

Get PDSCH and PUSCH ue_stats_nr for MultiUE
   [arguments]    ${CallType}=NSA
   StringTool.printLineWithTitle   title=Get PDSCH and PUSCH ue_stats_nr for MultiUE
   ${throughput}        Get From Dictionary     ${listOfUes[0]}   DL_throughput
   ${UL_throughput}     Get From Dictionary     ${listOfUes[0]}   UL_throughput
   ${ue}                Get From Dictionary     ${listOfUes[0]}   ue
   ${ret}   ${resTput}     Run Keyword And Ignore Error    Get PDSCH and PUSCH ue_stats_nr
   ...                               ue_id=${ue}
   ...                               DLthroughput=${throughput}
   ...                               ULthroughput=${UL_throughput}
   ...                               CallType=${CallType}
   ${Ue_Avg_PDSCH_Tput}=    Set Variable    ${resTput}[0]
   ${Ue_Avg_PUSCH_Tput}=    Set Variable    ${resTput}[1]  
   # Traced Sleep   1s   msg=wait to get Get PDSCH and PUSCH ue_stats_nr for ue_id=${UEcurrent.ue}
   Sleep   1s
   ${throughput}        Get From Dictionary     ${listOfUes[1]}   DL_throughput
   ${UL_throughput}     Get From Dictionary     ${listOfUes[1]}   UL_throughput
   ${ue}                Get From Dictionary     ${listOfUes[1]}   ue
   ${ret}   ${resTput}     Run Keyword And Ignore Error    Get PDSCH and PUSCH ue_stats_nr
   ...                               ue_id=${ue}
   ...                               DLthroughput=${throughput}
   ...                               ULthroughput=${UL_throughput}
   ...                               CallType=${CallType}
   ${Ue_Avg_PDSCH_Tput}=    Set Variable    ${resTput}[0]
   ${Ue_Avg_PUSCH_Tput}=    Set Variable    ${resTput}[1]  
   # Traced Sleep   1s   msg=wait to get Get PDSCH and PUSCH ue_stats_nr for ue_id=${UEcurrent.ue}
   Sleep   1s
   ${throughput}        Get From Dictionary     ${listOfUes[2]}   DL_throughput
   ${UL_throughput}     Get From Dictionary     ${listOfUes[2]}   UL_throughput
   ${ue}                Get From Dictionary     ${listOfUes[2]}   ue
   ${ret}   ${resTput}        Run Keyword And Ignore Error    Get PDSCH and PUSCH ue_stats_nr
   ...                               ue_id=${ue}
   ...                               DLthroughput=${throughput}
   ...                               ULthroughput=${UL_throughput}
   ...                               CallType=${CallType}
   ${Ue_Avg_PDSCH_Tput}=    Set Variable    ${resTput}[0]
   ${Ue_Avg_PUSCH_Tput}=    Set Variable    ${resTput}[1]  
   # Traced Sleep   1s   msg=wait to get Get PDSCH and PUSCH ue_stats_nr for ue_id=${UEcurrent.ue}
   StringTool.printLineWithTitle  title=-

# Get PDSCH and PUSCH ue_stats_nr for UeList "${ue_ids}" for "${CallType}"
Get PDSCH and PUSCH ue_stats_nr for List Of Ue
   [arguments]    ${CallType}=SA
   ${ue_ids}     Create List    1   2   3
   ${is_list}    Evaluate    isinstance(${ue_ids},list)
   ${ue_id_str}    Run Keyword If    '${is_list}'=='True'    Evaluate    ','.join(${ue_ids})
   ${ue_ids}    Set Variable If    '${is_list}'=='True'    ${ue_id_str}    ${ue_ids}
   Log To Console    \nDisplay the tput of pcell and scell for UE${ue_ids}
   StringTool.printLineWithTitle   title=Get PDSCH and PUSCH ue_stats_nr for MultiUE=${ue_ids}
   ${Ue_Avg_PDSCH_Tput}    ${Ue_Avg_PUSCH_Tput}   Get PDSCH and PUSCH ue_stats_nr   ue_id=${ue_ids}
   ...                               DLthroughput=10
   ...                               ULthroughput=10
   ...                               CallType=${CallType}
   StringTool.printLineWithTitle  title=-


Display Multi UE Throughput ???
    [Arguments]    ${ue_ids}
    [Documentation]    This keyword is to display ues tput for pcell and scell
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_ids} | yes | if ue id Continuous, such as 1-2, 10-20. if not, a list [1,3,5] |
    ...
    ...    Examples:
    ...    | Display Multi UE Throughput | 1-2 |  |
    ${is_list}    Evaluate    isinstance(${ue_ids},list)
    ${ue_id_str}    Run Keyword If    '${is_list}'=='True'    Evaluate    ','.join(${ue_ids})
    ${ue_ids}    Set Variable If    '${is_list}'=='True'    ${ue_id_str}    ${ue_ids}
    Log To Console    \nDisplay the tput of pcell and scell for UE${ue_ids}
    ${output}    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_ids} type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
    Log To Console    \n${output}

Display PDSCH and PUSCH ue_stats_nr for UEList
    [Arguments]    ${UEsList}   ${file}=None
    [Documentation]    This keyword is to display ues tput for pcell and scell

    ${w_DISPLAY_ue_stats_nr_15min}    set Variable if   '${ENABLE_CHECK_COUNTERS}' == '1'     True
    ...                                                                                       ${w_DISPLAY_ue_stats_nr_15min}
    Run Keyword if   '${w_DISPLAY_ue_stats_nr_15min}' == 'False'    Get PDSCH and PUSCH ue_stats_nr for UEList
    ...                                                                                 UEsList=${UEsList}   CallType=SA   file=${file}
    ...   ELSE       Run Keywords
    ...                       dated log    Wait 15 minutes to Get PDSCH and PUSCH ue_stats_nr
    ...                 AND   robot_extension_CB011028.Run Keyword And Warn On Failure        robot_extension_CB011028.Run Specific Custom KW
    ...                                  Get PDSCH and PUSCH ue_stats_nr for MultiUE    CallType=SA
    ...                 AND    dated log    End of Wait 15 minutes to Get PDSCH and PUSCH ue_stats_nr

# NSA WA for cqi TM
# enb_endc_param id=1 serving_cell_index_range_scg=5:31
Add Scell Range To NSA
    [Arguments]        ${eNBId}=1            ${alias}=default
    Log To Console    add scell range to NSA...
    wtsemu.enb_endc_param    id=${eNBId}    serving_cell_index_range_scg=8:31

# ex
# Override CSI profile
# csi_override_testmode_nr profile_id=1 cqi=15 cqi_mode=fixed ri=1 ri_mode=fixed
# csi_override_testmode_nr profile_id=1' | pass_regexp='csi_override_testmode_nr Parameters
# and activate CSI profile  ( id = UeId)
# ue_testmode_set_nr id=11 scell=5 testmode=csi_override profile_id=1 action=activate

Associate UEs to testmode
    [Documentation]    :
    ...
    ...    :param id:          specified UE ID
    ...    :param scell:       carrier Aggregation serving cell (carrier component, CC). Primary is for scell index 0.
    ...                        Secondary is for scell indexes 1-7.
    ...    :param testmode:    testmode to be used
    ...    :param profile_id:  test profile id
    ...    :param action:      triggers the activation or the deactivation of the test mode (activate or deactivate)
    ...
    [Arguments]    ${id}    ${testmode}    ${profile_id}    ${action}    ${scell}=0
    wtsemu.ue_testmode_set_nr   id=${id}   scell=${scell}  testmode=${testmode}  profile_id=${profile_id}  action=${action}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    ${action} testmode ${testmode} for UE=${id} scell=${scell} and profile_id ${profile_id}    console=True

Associate Cell to testmode
    [Documentation]    :
    ...
    ...    :param id:          specified UE ID
    ...    :param scell:       carrier Aggregation serving cell (carrier component, CC). Primary is for scell index 0.
    ...                        Secondary is for scell indexes 1-7.
    ...    :param testmode:    testmode to be used
    ...    :param profile_id:  test profile id
    ...    :param action:      triggers the activation or the deactivation of the test mode (activate or deactivate)
    ...
    [Arguments]    ${cell_id}    ${testmode}    ${profile_id}    ${action}    ${gnb}=2       ${alias}=default
    wtsemu.cell_testmode_set_nr   cell_id=${cell_id}  gnb=${gnb}  testmode=${testmode}  profile_id=${profile_id}  action=${action}
    # cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    ${action} testmode ${testmode} for Cell=${cell_id} gnb=${gnb} and profile_id ${profile_id}    console=True

# cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-40,-13,13,40
# cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
# cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
# cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

Override and Activate Cell SRS Beam pos profile
    # [Arguments]        ${profile_id}=1    ${nbCell}=1   ${num_of_ue_positions}=4   ${azimuth}=-40,-13,13,40   ${alias}=default
    [Arguments]        ${profile_id}=1    ${nbCell}=1   ${num_of_ue_positions}=4   ${azimuth}=-70,-19,20,70   ${alias}=default
    Log To Console    Override and Activate Cell SRS Beam pos profile...
    wtsemu.cell_srs_beam_pos_nr    profile_id=${profile_id}  num_of_ue_positions=${num_of_ue_positions}  azimuth=${azimuth}
    ${cmd}=   Catenate   cell_srs_beam_pos_nr profile_id=${profile_id}
    ${pattern}     Set Variable        cell_srs_beam_pos_nr Parameters
    ${output}    wtsemu.cell_srs_beam_pos_nr   profile_id=${profile_id}
    ${output}    wtsemu.Read Wtsemu Output Until Re     expected=${pattern}       timeout=5
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Dated log        ${cmd}
    Log To Console    \n${output}
    ${nbCell_loop}   evaluate    int(${nbCell}+1)
    FOR    ${cell}   IN RANGE   1   ${nbCell_loop}
        BuiltIn.Log     Channel Cell SRS Beam pos for Cell${cell} is updated with num_of_ue_positions=${num_of_ue_positions} azimuth=${azimuth}
        Log To Console    Associate UE to testmode...
        Associate Cell to testmode    cell_id=${cell}    testmode=cell_srs_beam_pos    profile_id=${profile_id}    action=activate    gnb=2
        ...                           alias=${alias}
        Log To Console    set_Cell_SRS_Beam_Testmode_is_ok
    END
    ${cmd}=   Catenate   cell_srs_beam_pos_nr profile_id=${profile_id}
    ${output}    wtsemu.cell_srs_beam_pos_nr   profile_id=${profile_id}
    ${output}    wtsemu.read_wtsemu_output_until_prompt     timeout=5
    Dated log        ${cmd}
    Log To Console    \n${output}

Override and Activate Cell SRS Beam pos profile for CellSetup
    [Arguments]     ${nbCell}=1
    ${cellList}    Create List
    FOR    ${Cell_Id}    IN RANGE    0    ${nbCell}
        ${CellId}    Evaluate    ${Cell_Id} + ${1}
        Append To List      ${cellList}    ${CellId}
    END
    Override and Activate Cell SRS Beam pos profile   profile_id=1   nbCell=${nbCell}  num_of_ue_positions=4   azimuth=-40,-13,13,40


Override and Activate Ue SRS Beam pos profile 1 for all ${totalNbOfUe} Ues
    DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues
    Create ue based srs testmode profile with Ue position
    Activate Ue Based Srs Testmode for ${totalNbOfUe} Ues with Profile 1
    # MU_MIMO_Testmode_8172 for ${totalNbOfUe} Ues

Override and Activate Ue SRS Beam pos profile 2 for all ${totalNbOfUe} Ues
    DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues
    Create ue based srs testmode profile with Ue position
    Activate Ue Based Srs Testmode for ${totalNbOfUe} Ues with Profile 2

Override and Activate Ue SRS Beam pos profile for all ${totalNbOfUe} Ues with 4 Ues per Cell
    DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues
    Create ue based srs testmode profile with Ue position
    Activate Ue Based Srs Testmode For ${totalNbOfUe} Ues with 4 Ues per Cell

Run specific keywords before attach : ${kw Specific Set TestMode}
    return from Keyword if   '${kw Specific Set TestMode}'=='${EMPTY}'
    Run keyword and continue on failure     ${kw Specific Set TestMode}

Run specific keywords after attach : ${kw Specific Set TestMode}
    return from Keyword if   '${kw Specific Set TestMode}'=='${EMPTY}'
    Run keyword and continue on failure     ${kw Specific Set TestMode}

DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues
    wtsemu.ul_sinr_testmode_nr       profile_id=1
    ...                              sinr_target_pucch=-300
    ...                              sinr_target_srs=200
    # ...                              sinr_target_srs=50   # case PUSCH 1Layer
    ...                              noise_srs=-1053
    # for all Ue
    wtsemu.ue_testmode_set_nr        id=1-${totalNbOfUe}
    ...                              testmode=ul_sinr
    ...                              action=activate
    ...                              profile_id=1

    ${cmd}=   Catenate   ul_sinr_testmode_nr profile_id=1
    ${output}    wtsemu.ul_sinr_testmode_nr       profile_id=1
    ${output}    wtsemu.read_wtsemu_output_until_prompt     timeout=5
    Dated log        ${cmd}
    Log To Console    \n${output}

AirPhoneIssueWA_P1
    [Documentation]         Temporary solution to bypass Airphone Issue
    ...                     Warning this KW will get info from original dictionnary (dict_settings_all_ues_global)
    [Arguments]             ${Ue_list}=none
    #argument atendu ${Ue_filtered_list_56}

    Debug Dated Log         Ue_list >>${Ue_list}<<
    FOR    ${current_elem}    IN    @{Ue_list}
        debug dated log    debug current_elem.ue ${current_elem.ue} ////

        # wtsemu.ul_sinr_testmode_nr          profile_id=${current_elem.ue} delete=true
        wtsemu.ul_mimo_srs_beam_pos_nr      profile_id=${current_elem.ue} delete=true
        wtsemu.csi_override_testmode_nr     profile_id=${current_elem.ue} delete=true

    END
    wtsemu.ul_sinr_testmode_nr          profile_id=1 delete=true

AirPhoneIssueWA_P2
    [Documentation]         Temporary solution to bypass Airphone Issue
    ...                     Warning this KW will get info from original dictionnary (dict_settings_all_ues_global)
    [Arguments]             ${Ue_list}=none
    #argument atendu ${Ue_filtered_list_56}

    Debug Dated Log         Ue_list >>${Ue_list}<<
    FOR    ${current_elem}    IN    @{Ue_list}
        debug dated log    debug current_elem.ue ${current_elem.ue} ////
        ${elemMoins1}   Evaluate    ${current_elem.ue}-1    #needed to navigate on dictionnary
                ${nr_cqi}      Get From Dictionary
        ...     ${dict_settings_all_ues_global[${elemMoins1}]}
        ...     cqi
                ${nr_ri}      Get From Dictionary
        ...     ${dict_settings_all_ues_global[${elemMoins1}]}
        ...     ri
        Run Keyword   Override and Activate UE CSI profile  profile_id=${current_elem.ue}   UeId=${current_elem.ue}    nr_cqi=${nr_cqi}
        ...                                                 nr_cqi_mode=fixed    nr_ri=${nr_ri}      nr_ri_mode=fixed
        sleep    1s
    END
    Set Srs beam position    profile_id=5     quad_pos=1    sub_quad_pos=0
	Activate MIMO profile    ue_id=5     profile_id=5
	Wait '2s' for stability
    Set Srs beam position    profile_id=6     quad_pos=3    sub_quad_pos=2
	Activate MIMO profile    ue_id=6     profile_id=6
	Wait '2s' for stability

    # DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues
    wtsemu.ul_sinr_testmode_nr       profile_id=1
    ...                              sinr_target_pucch=-300
    ...                              sinr_target_srs=200
    # ...                              sinr_target_srs=50   # case PUSCH 1Layer
    ...                              noise_srs=-1053
    # for all Ue
    wtsemu.ue_testmode_set_nr        id=1-6
    ...                              testmode=ul_sinr
    ...                              action=activate
    ...                              profile_id=1
    wtsemu.ul_sinr_testmode_nr       profile_id=1

Create ue based srs testmode profile with Ue position
    wtsemu.ue_srs_beam_pos_nr   profile_id=1
    ...                         init_pos=0
    ...                        srsMode=fixed
	wtsemu.ue_srs_beam_pos_nr   profile_id=2
    ...                         init_pos=1
    ...                        srsMode=fixed
    wtsemu.ue_srs_beam_pos_nr   profile_id=3
    ...                         init_pos=2
    ...                        srsMode=fixed
    wtsemu.ue_srs_beam_pos_nr   profile_id=4
    ...                         init_pos=3
    ...                        srsMode=fixed

Check Modulo
    [Arguments]    ${count}
    ${mod}=    Evaluate    (${count}%2)
    [Return]    ${mod}

Activate Ue Based Srs Testmode For ${totalNbOfUe} Ues with Profile 2

    ${UE_even}   set Variable   ${2}
    ${UE_odd}    set Variable   ${1}
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    FOR  ${UEId}  IN RANGE  3   ${totalNbOfUe_1}
        ${mod}  Check Modulo   ${UEId}
        ${UE_even}   Run Keyword if   '${mod}'=='${0}'       Catenate   SEPARATOR=   ${UE_even},${UEId}
        ...            ELSE                                  set Variable    ${UE_even}
        ${UE_odd}    Run Keyword if   '${mod}'!='${0}'       Catenate   SEPARATOR=   ${UE_odd},${UEId}
        ...            ELSE                                  set Variable    ${UE_odd}
    END
    # wtsemu.ue_testmode_set_nr    id=1,3
    # wtsemu.ue_testmode_set_nr    id=1,3,5
    wtsemu.ue_testmode_set_nr    id=${UE_odd}
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=1
    # wtsemu.ue_testmode_set_nr    id=2,4,6
    # wtsemu.ue_testmode_set_nr    id=2,4
    wtsemu.ue_testmode_set_nr    id=${UE_even}
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=4

Activate Ue Based Srs Testmode For ${totalNbOfUe} Ues with Profile 1

    ${UE_even}   set Variable   ${2}
    ${UE_odd}    set Variable   ${1}
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    FOR  ${UEId}  IN RANGE  3   ${totalNbOfUe_1}
        ${mod}  Check Modulo   ${UEId}
        ${UE_even}   Run Keyword if   '${mod}'=='${0}'       Catenate   SEPARATOR=   ${UE_even},${UEId}
        ...            ELSE                                  set Variable    ${UE_even}
        ${UE_odd}    Run Keyword if   '${mod}'!='${0}'       Catenate   SEPARATOR=   ${UE_odd},${UEId}
        ...            ELSE                                  set Variable    ${UE_odd}
    END
    # wtsemu.ue_testmode_set_nr    id=1,3
    # wtsemu.ue_testmode_set_nr    id=1,3,5
    wtsemu.ue_testmode_set_nr    id=${UE_odd}
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=1
    # wtsemu.ue_testmode_set_nr    id=2,4,6
    # wtsemu.ue_testmode_set_nr    id=2,4
    wtsemu.ue_testmode_set_nr    id=${UE_even}
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=2

Activate Ue Based Srs Testmode For ${totalNbOfUe} Ues with 4 Ues per Cell
    dated log      activate ue_testmode_set_nr for 12 Ues where ${totalNbOfUe} Ues are used
    wtsemu.ue_testmode_set_nr    id=1,5,9
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=1
    wtsemu.ue_testmode_set_nr    id=2,6,10
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=2
    wtsemu.ue_testmode_set_nr    id=3,7,11
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=3
    wtsemu.ue_testmode_set_nr    id=4,8,12
    ...                          testmode=ue_srs_beam_pos
    ...                          action=activate
    ...                          profile_id=4


MU_MIMO_Testmode_8172 for ${totalNbOfUe} Ues
    wtsemu.beam_control_testmode_nr  profile_id=1  ueBeamIndexInitial=0,1,2,3,4,5
    ...             beamType=Digital  csirs_bestbeam=1,3  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=2  ueBeamIndexInitial=1,2,3,4,5,0
    ...             beamType=Digital  csirs_bestbeam=5,7  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=3  ueBeamIndexInitial=2,3,4,5,0,1
    ...             beamType=Digital  csirs_bestbeam=9,11  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=4  ueBeamIndexInitial=3,4,5,0,1,2
    ...             beamType=Digital  csirs_bestbeam=13,15  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=5  ueBeamIndexInitial=0,1,2,3,4,5
    ...             beamType=Digital  csirs_bestbeam=0,2  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=6  ueBeamIndexInitial=1,2,3,4,5,0
    ...             beamType=Digital  csirs_bestbeam=4,6  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=7  ueBeamIndexInitial=2,3,4,5,0,1
    ...             beamType=Digital  csirs_bestbeam=8,10  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50

    wtsemu.beam_control_testmode_nr  profile_id=8  ueBeamIndexInitial=3,4,5,0,1,2
    ...             beamType=Digital  csirs_bestbeam=12,14  csirs_rsrp_best=-44,-48  csirs_rsrp_avg=-50
    sleep    1s
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    FOR  ${UEId}  IN RANGE  1   ${totalNbOfUe_1}
        wtsemu.ue_testmode_set_nr  id=${UEId}  testmode=beam_control  action=activate  profile_id=${UEId}  beamaction=attach
        sleep    1s
    END
    # wtsemu.ue_testmode_set_nr  id=1  testmode=beam_control  action=activate  profile_id=1  beamaction=attach
    # sleep    1s
    # wtsemu.ue_testmode_set_nr  id=2  testmode=beam_control  action=activate  profile_id=2  beamaction=attach
    # sleep    1s
    # wtsemu.ue_testmode_set_nr  id=3  testmode=beam_control  action=activate  profile_id=3  beamaction=attach
    # sleep    1s
    # wtsemu.ue_testmode_set_nr  id=4  testmode=beam_control  action=activate  profile_id=4  beamaction=attach
    # sleep    1s
	# wtsemu.ue_testmode_set_nr  id=5  testmode=beam_control  action=activate  profile_id=5  beamaction=attach
    # sleep    1s
    # wtsemu.ue_testmode_set_nr  id=6  testmode=beam_control  action=activate  profile_id=6  beamaction=attach
    # sleep    1s
    # wtsemu.ue_testmode_set_nr  id=7  testmode=beam_control  action=activate  profile_id=7  beamaction=attach
    # sleep    1s
    # wtsemu.ue_testmode_set_nr  id=8  testmode=beam_control  action=activate  profile_id=8  beamaction=attach
    # sleep    1s

Wait '${time}' for stability
    sleep    ${time}

Set Srs beam position
    [Arguments]   ${profile_id}   ${quad_pos}    ${sub_quad_pos}
     wtsemu.ul_mimo_srs_beam_pos_nr   profile_id=${profile_id}     mode=fixed    init_quad_pos=${quad_pos}
     ...                              init_sub_quad_pos=${sub_quad_pos}   step=5    trigger_puxch_update=0
     ...                              test_type=UL_MIMO
     # ...                              test_type=SRS
     Wait '2s' for stability


Activate MIMO profile
    [Arguments]   ${ue_id}    ${profile_id}
    wtsemu.ue_testmode_set_nr    id=${ue_id}    testmode=ul_mimo_srs_beam_pos     action=activate     profile_id=${profile_id}

Activate MIMO profile for all ${totalNbOfUe} Ues
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    # ${dict_settings_all_ues_global} is a global variable initialized in Kw 'Init CB009890 Test Variables'
    FOR  ${UEId}  IN RANGE  1   ${totalNbOfUe_1}
        ${current_UeId}   Evaluate    ${UEId}-1
        # ${quad_pos}      Get From Dictionary
        # ...     ${dict_settings_all_ues_global[${current_UeId}]}
        # ...     quad_pos
        # ${sub_quad_pos}      Get From Dictionary
        # ...     ${dict_settings_all_ues_global[${current_UeId}]}
        # ...     sub_quad_pos
        Run Keyword   Activate MIMO profile   id=${UEId}    profile_id=${UEId}
        Wait '1s' for stability
    END

Set SRS Beam Position for muMIMO for UE pairing for all ${totalNbOfUe} Ues
    Set Srs beam position    profile_id=1     quad_pos=1    sub_quad_pos=0
	Activate MIMO profile    ue_id=1     profile_id=1
	Wait '2s' for stability
    Set Srs beam position    profile_id=2     quad_pos=3    sub_quad_pos=1
	Activate MIMO profile    ue_id=2     profile_id=2
	Wait '2s' for stability
    Set Srs beam position    profile_id=5     quad_pos=1    sub_quad_pos=0
	Activate MIMO profile    ue_id=5     profile_id=5
	Wait '2s' for stability
    Set Srs beam position    profile_id=6     quad_pos=3    sub_quad_pos=2
	Activate MIMO profile    ue_id=6     profile_id=6
	Wait '2s' for stability
    # Set Srs beam position    profile_id=9     quad_pos=1    sub_quad_pos=0
	# Activate MIMO profile    ue_id=9     profile_id=9
    # Set Srs beam position    profile_id=10     quad_pos=3    sub_quad_pos=1
	# Activate MIMO profile    ue_id=10     profile_id=10
    Set Srs beam position    profile_id=3     quad_pos=2    sub_quad_pos=2
	Activate MIMO profile    ue_id=3     profile_id=3
	Wait '2s' for stability
    Set Srs beam position    profile_id=4     quad_pos=0    sub_quad_pos=3
	Activate MIMO profile    ue_id=4     profile_id=4
	Wait '2s' for stability
    # Set Srs beam position    profile_id=7     quad_pos=2    sub_quad_pos=3
	# Activate MIMO profile    ue_id=7     profile_id=7
    # Set Srs beam position    profile_id=8     quad_pos=0    sub_quad_pos=0
	# Activate MIMO profile    ue_id=8     profile_id=8
    # Set Srs beam position    profile_id=11     quad_pos=2    sub_quad_pos=2
	# Activate MIMO profile    ue_id=11     profile_id=11
    # Set Srs beam position    profile_id=12     quad_pos=0    sub_quad_pos=3
	# Activate MIMO profile    ue_id=12     profile_id=12
	DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues

Set SRS Beam Position for muMIMO for UE pairing for CB009890_C for all ${totalNbOfUe} Ues
    Set Srs beam position    profile_id=1     quad_pos=1    sub_quad_pos=0
	Activate MIMO profile    ue_id=1     profile_id=1
	Wait '2s' for stability
    Set Srs beam position    profile_id=2     quad_pos=3    sub_quad_pos=1
	Activate MIMO profile    ue_id=2     profile_id=2
	Wait '2s' for stability
    Set Srs beam position    profile_id=5     quad_pos=1    sub_quad_pos=0
	Activate MIMO profile    ue_id=5     profile_id=5
	Wait '2s' for stability
    Set Srs beam position    profile_id=6     quad_pos=3    sub_quad_pos=2
	Activate MIMO profile    ue_id=6     profile_id=6
	Wait '2s' for stability
    Set Srs beam position    profile_id=9     quad_pos=1    sub_quad_pos=0
	Activate MIMO profile    ue_id=9     profile_id=9
	Wait '2s' for stability
    Set Srs beam position    profile_id=10     quad_pos=3    sub_quad_pos=1
	Activate MIMO profile    ue_id=10     profile_id=10
	Wait '2s' for stability
    Set Srs beam position    profile_id=3     quad_pos=2    sub_quad_pos=2
	Activate MIMO profile    ue_id=3     profile_id=3
	Wait '2s' for stability
    Set Srs beam position    profile_id=4     quad_pos=0    sub_quad_pos=3
	Activate MIMO profile    ue_id=4     profile_id=4
	Wait '2s' for stability
    Set Srs beam position    profile_id=7     quad_pos=2    sub_quad_pos=3
	Activate MIMO profile    ue_id=7     profile_id=7
    Wait '2s' for stability
    Set Srs beam position    profile_id=8     quad_pos=0    sub_quad_pos=0
	Activate MIMO profile    ue_id=8     profile_id=8
	Wait '2s' for stability
    Set Srs beam position    profile_id=11     quad_pos=2    sub_quad_pos=2
	Activate MIMO profile    ue_id=11     profile_id=11
	Wait '2s' for stability
    Set Srs beam position    profile_id=12     quad_pos=0    sub_quad_pos=3
	Activate MIMO profile    ue_id=12     profile_id=12
	Wait '2s' for stability
	DL Set Target Power And Disable Noise For SRS Signals for ${totalNbOfUe} Ues

Override and Activate UE CSI profile
    [Arguments]        ${profile_id}= 1   ${UeId}=1   ${nr_cqi}=15    ${nr_cqi_mode}=fixed  ${cqi_min}=1     ${cqi_max}=15
    ...                      ${nr_ri}=1    ${nr_ri_mode}=fixed
    Log To Console    Override and Activate UE CSI profile [UeId=${UeId}]...
    wtsemu.csi_override_testmode_nr    profile_id=${profile_id}   cqi=${nr_cqi}   cqi_mode=${nr_cqi_mode}   cqi_min=${cqi_min}
    ...                                                           cqi_max=${cqi_max}   ri=${nr_ri}   ri_mode=${nr_ri_mode}
    ${output}     wtsemu.csi_override_testmode_nr    profile_id=${profile_id}
    BuiltIn.Log     Channel State Information for UE${UeId} is updated with cqi=${nr_cqi} cqi_mode=${nr_cqi_mode} ri=${nr_ri} ri_mode=${nr_ri_mode}
    Log To Console   Channel State Information for UE${UeId} is updated with cqi=${nr_cqi} cqi_mode=${nr_cqi_mode} ri=${nr_ri} ri_mode=${nr_ri_mode}
    Log To Console   Associate UE to testmode...
    Associate UEs to testmode    id=${ue_id}    testmode=csi_override    profile_id=${profile_id}    action=activate
    Log To Console    set_UE_CQI_Testmode_is_ok


Override and Activate UE CSI profile for all ${totalNbOfUe} Ues Version1
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    FOR  ${UEId}  IN RANGE  1   ${totalNbOfUe_1}
        Run Keyword   Override and Activate UE CSI profile  profile_id=${UEId}   UeId=${UEId}   nr_cqi=15    nr_cqi_mode=fixed
        ...                                                                                     nr_ri=3      nr_ri_mode=fixed
        sleep    1s
    END

Override and Activate UE CSI profile for all ${totalNbOfUe} Ues
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    # ${dict_settings_all_ues_global} is a global variable initialized in Kw 'Init CB009890 Test Variables'
    FOR  ${UEId}  IN RANGE  1   ${totalNbOfUe_1}
        ${current_UeId}   Evaluate    ${UEId}-1
        ${nr_cqi}      Get From Dictionary
        ...     ${dict_settings_all_ues_global[${current_UeId}]}
        ...     cqi
        ${nr_ri}      Get From Dictionary
        ...     ${dict_settings_all_ues_global[${current_UeId}]}
        ...     ri
        Run Keyword   Override and Activate UE CSI profile  profile_id=${UEId}   UeId=${UEId}   nr_cqi=${nr_cqi}    nr_cqi_mode=fixed
        ...                                                                                     nr_ri=${nr_ri}      nr_ri_mode=fixed
        sleep    1s
    END

Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${totalNbOfUe} Ues
    Override and Activate UE CSI profile for all ${totalNbOfUe} Ues
    Set SRS Beam Position for muMIMO for UE pairing for all ${totalNbOfUe} Ues

Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for CB009890_C for all ${totalNbOfUe} Ues
    Override and Activate UE CSI profile for all ${totalNbOfUe} Ues
    Set SRS Beam Position for muMIMO for UE pairing for CB009890_C for all ${totalNbOfUe} Ues

Stop All Data Transfer
   [Arguments]   ${ue_id}
   [Documentation]	   This Keyword is used to stop all uplink and downlink data trasnfer for an UE bearer combination
   ...                | ue_id | ID of the UE configured in the cfg file |
   wtsemu.trf_data_stop    ue=${ue_id}     pdu=1   dir=dl
   wtsemu.trf_data_stop    ue=${ue_id}     pdu=1   dir=ul
   [Return]

Override Ue Capa
    [Arguments]        ${UeId}   ${ue_capa}
    Log To Console    Override Ue Capa [UeId=${UeId}]...
    # ue_param id=1 ue_nr_capabilities=
    wtsemu.ue_param    id=${UeId}   ue_nr_capabilities=${ue_capa}
    Log To Console    set_UE_UE_Capa_is_ok

Modify Ue Capa PUSCH RANK1 for all ${totalNbOfUe} Ues
    ${totalNbOfUe_1}   Evaluate    ${totalNbOfUe}+1
    # ${dict_settings_all_ues_global} is a global variable initialized in Kw 'Init CB009890 Test Variables'
    FOR  ${UEId}  IN RANGE  1   ${totalNbOfUe_1}
        ${current_UeId}   Evaluate    ${UEId}-1
        Run Keyword      Override Ue Capa    UeId=${UEId}   ue_capa=${ue_nr_capabilities_SRS_w_VOIP_SA_w_PUSCH_OneLayer}
        sleep    1s
    END

Execute egate command
    [Arguments]        ${egate_cmd}
    Log To Console    Execute egate command [${egate_cmd}]...
    wtsemu.${egate_cmd}

# before attach
Set SSB Beam
    wtsemu.beam_control_testmode_nr     profile_id=1      ueBeamIndexInitial=0,1,2,3,4,5      ssbeam_bestbeam=0
    ...                                 ssbeam_rsrp_best=-44      ssbeam_rsrp_avg=-50
    wtsemu.ue_testmode_set_nr           id=1      testmode=beam_control      action=activate
    ...                                 profile_id=1      beamaction=attach

Beamcontrol Beam Recovery
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=1     ${scell_idx}=0     ${best_beam}=0
    Log to Console    Changing Beam
    wtsemu.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=recovery    scell=${scell_idx}
    Run Keyword and continue on failure    Check Rach msg
    Run Keyword and continue on failure    Check best beam      beam_profile_id=${beam_profile_id}       best_beam=${best_beam}

Check best beam
    [Arguments]    ${best_beam}      ${beam_profile_id}=1
    wtsemu.beam_control_testmode_nr      profile_id=${beam_profile_id}
    ${beam_check}       wtsemu.read_wtsemu_output_until_re      expected=csirs_sinr_avg   timeout=15
    ${output}         Get Regexp Matches    ${beam_check}    ssbeam_bestbeam +(\\d+)    1
    ${result}        Convert To Number     ${output[0]}
    Should Be Equal As Numbers      ${result}          ${best_beam}

# after attach
Set SSB Beam Recovery for UE${ue_id:\d+}
    wtsemu.beam_control_testmode_nr     profile_id=2      ueBeamIndexInitial=2,0,1,3,4,5      ssbeam_bestbeam=2
    ...                                 ssbeam_rsrp_best=-45      ssbeam_rsrp_avg=-120
    Beamcontrol Beam Recovery     ue_id=${ue_id}     beam_profile_id=2     best_beam=2

Check Rach msg
    ${output1}        wtsemu.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output1}    Rach Config Common is missing     partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output1}    rrcReconfigurationComplete   partial_match=${TRUE}

