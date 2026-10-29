*** Settings ***
Resource          ./../CUDU_L2/common_setup_teardown.robot


*** Keywords ***
Send Large Traffic Over DRB1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${dir}=ul
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=40 trf_id=3
    sleep    10s    #sleep for stable traffic

Send Small Traffic Over DRB1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${dir}=ul
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=${dir} trf_id=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=${dir} trf_id=2
    sleep    10s    #sleep for stable traffic

Check Slot For FDD
    [Arguments]    ${log_dir}    ${numOfPrb}    ${pci}    ${slotlist}
    ${value}    Read Csv Columns    ${log_dir}    slot    filter=((${numOfPrb}!=EMPTY)&(physCellId=${pci}))
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${slotlist}

Trigger A1 Scell Addition
   [Arguments]    ${ue_id}=${UE_ID}    ${meas_id}=1    ${srsrp_nr}=85
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}

Check AllowList In TTI
    [Arguments]    ${tti_ul_csv}
    ${list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}    ulCaAllowList.allowList
    Should Be True    len(${list})>0

Check Overlap In TTI
    [Arguments]    ${tti_ul_csv}
    ${list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}    ulPreTdBlockUeData.cs1BlockUeList
    Should Be True    len(${list})>0

Check SlotNum Of UL In TTI
    [Arguments]    ${log_id}    ${physcellid}    ${Numofslot}
    ${list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.dciFormat    physCellId    ["0", ""]    except    ${physcellid}    include    slot    yes
    Should Be True    len(${list})==${Numofslot}

Attach 1st CA UE and send big ULDL traffic
    [Arguments]    ${UE_ID1}    ${1T1F_SCELLS}
    SA Single UE Attach    ${UE_ID1}
    CB012149_resource.Trigger A1 Scell Addition    ${UE_ID1}
    Sleep    2s    reason=Wait for log
    Get And Check Scell Infos    ${1T1F_SCELLS}
    Start SA UE Big DL Traffic Internal    ${UE_ID1}    175
    Start SA UE Big UL Traffic Internal    ${UE_ID1}    170

Attach 1st CA UE and send big DL traffic
    [Arguments]    ${UE_ID1}    ${1T1F_SCELLS}
    SA Single UE Attach    ${UE_ID1}
    CB012149_resource.Trigger A1 Scell Addition    ${UE_ID1}
    Sleep    2s    reason=Wait for log
    Get And Check Scell Infos    ${1T1F_SCELLS}
    Start SA UE Big DL Traffic Internal    ${UE_ID1}    175
    #Start SA UE Big UL Traffic Internal    ${UE_ID1}    170

Attach nonCA UE and send big ULDL traffic
    [Arguments]    ${UE_ID2}
    SA Single UE Attach    ${UE_ID2}
    Sleep    2s    reason=Wait for log
    Start SA UE Big DL Traffic Internal    ${UE_ID2}    175
    Start SA UE Big UL Traffic Internal    ${UE_ID2}    175
    sleep    10s    #sleep for stable traffic

Set Value For UL CELL NOISE testmode
    Log To Console    Set Value For ul_cell_noise_testmode...
    ${cmd1}    Set Variable    ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-710
    ute_wtssim.Execute Egate Command    ${cmd1}
    Sleep    1s    reason=Wait for log
    ${cmd2}    Set Variable    cell_testmode_set_nr gnb=2 cell_id=6 testmode=ul_cell_noise profile_id=1 action=activate
    ute_wtssim.Execute Egate Command    ${cmd2}

Set Value For UL SINR testmode
    [Arguments]    ${UE_ID}
    Log To Console    Set Value For ul_cell_noise_testmode...
    ${cmd1}    Set Variable    ul_sinr_testmode_nr profile_id=2 sinr_target_pusch=-230
    ute_wtssim.Execute Egate Command    ${cmd1}
    Sleep    1s    reason=wait for testmode stable
    ${cmd2}    Set Variable    ue_testmode_set_nr id=${UE_ID} testmode=ul_sinr profile_id=2 action=activate
    ute_wtssim.Execute Egate Command    ${cmd2}
    Sleep    2s    reason=wait for testmode stable

Set Value For UL BLER testmode
    [Arguments]    ${UE_ID}
    Log To Console    Set Value For UL BLER testmode...
    ${cmd1}    Set Variable    bler_testmode_nr profile_id=3 ul_bler=200,200,200,200,200,200,200,200
    ute_wtssim.Execute Egate Command    ${cmd1}
    Sleep    1s    reason=Wait for log
    ${cmd2}    Set Variable    ue_testmode_set_nr id=${UE_ID} scell=1 testmode=bler profile_id=3 action=activate
    ute_wtssim.Execute Egate Command    ${cmd2}

SA 5G PDU Session Release
    [Arguments]    ${ue_id}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_release pdu=${pdu_id} ue=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Successfully released PDU Session    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Successfully released PDU Session    partial_match=${true}
    Log To Console    ${output}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=PDU SESSION ID-${pdu_id} setup/reestablishment complete    timeout=3minutes
    #${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Check CsRnti In TTI
    [Arguments]    ${log_id}=1    ${numofcsrnti}=2
    Log To Console    Check num of cs-rnti
    @{list}=    filter_source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.csRnti    ["0", ""]    except   ulFdSchedData.csRnti    yes
    Should Be True    len(${list})==${numofcsrnti}

Check SLIV On Specific Slot In TTI
    [Arguments]    ${log_id}    ${SLIV}    ${slot}    ${SLIVLIST}
    Log To Console    Check SLIV ${SLIV} On Specific Slot ${slot}
    @{list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.SLIV    slot    ${SLIVLIST}    except    ${slot}    include    ulFdSchedData.SLIV    no
    Should Be True    ${list}[0]==${SLIV}

Check SLIV On Specific Slot In TTI when ASRS triggered
    [Arguments]    ${log_id}    ${SLIV}    ${slot1}    ${slot2}    ${SLIVLIST}
    Log To Console    Check SLIV ${SLIV} On Specific Slot ${slot1} and Specific Slot ${slot2}...
    @{list1}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.SLIV    slot    ${SLIVLIST}    except    ${slot1}    include    ulFdSchedData.SLIV    no
    @{list2}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.SLIV    slot    ${SLIVLIST}    except    ${slot2}    include    ulFdSchedData.SLIV    no
    Should Be True    @{list1}!=[] or @{list2}!=[]

Check Egate Log For CG Status
    [Arguments]    ${CGStatus}=setup
    Log To Console    Check Egate Log For CG Status
    Save Egate Log    ${OUTPUT_DIR}
    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console.log
    ${content_1}=    Grep File    ${egate_console_file}    configuredGrantConfig ${CGStatus}
    Should Contain    ${content_1}    configuredGrantConfig ${CGStatus}

Check Rank In File As Expected
    [Arguments]    ${log_id}    ${physcellid}    ${field_to_check}    ${expected_value}
    Log To Console    Check Data In File As Expected_${physcellid}_${field_to_check}
    @{field_to_check}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ${field_to_check}    physCellId    ["0", "", "0.0"]
    ...    except    ${physcellid}    include    ${field_to_check}    no
    ${field_to_check_value}=    Get From List    ${field_to_check}    0
    ${expected_value}=    Evaluate    "${expected_value}"
    Should Be Equal As Strings    ${field_to_check_value}    ${expected_value}

Check Data In File As Expected
    [Arguments]    ${log_id}    ${physcellid}    ${field_to_check}    ${expected_value}
    Log To Console    Check Data In File As Expected_${physcellid}_${field_to_check}
   @{field_to_check}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ${field_to_check}    physCellId    ["0", "", "0.0"]
    ...    except    ${physcellid}    include    ${field_to_check}    no
    Should Be True    ${field_to_check}[0]==${expected_value}

Check FDD Schedule Is Not Overlap With Tdd Slot
    [Arguments]    ${log_id}    ${dciFormat}    ${field_to_check}    ${expected_value}
    Log To Console    Check Data In File As Expected_${dciFormat}_${field_to_check}
   @{field_to_check}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.dciFormat    slot    ["", "", ""]    except   ["", "", ""]    except    ${field_to_check}    yes
    List Should Not Contain Value    ${field_to_check}    ${expected_value}

Check SLIV is Correct As Expected
    [Arguments]    ${log_id}    ${slotid}    ${expected_value}
    Log To Console    Check SLIV ${expected_value} On Specific Slot ${slotid}
    @{list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.SLIV    slot    ["", "", ""]    except    ${slotid}   include    ulFdSchedData.SLIV    yes
    Should Be True    ${list}[0]==${expected_value}   

Send Large Traffic for DA10
    [Arguments]    ${ue_id}=3    ${pdu_id}=1    ${dir}=ul
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=120 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=120 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=40 trf_id=3
	
Recover Traffic for DA10
    [Arguments]    ${ue_id}=3    ${pdu_id}=1    ${dir}=ul
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=120 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=120 trf_id=2
    sleep    10s    #sleep for stable traffic

Check SLIV On Specific Slot For 1208
    [Arguments]    ${log_id}    ${SLIV1}    ${SLIV2}    ${slot}    ${SLIVLIST}
    Log To Console    Check SLIV ${SLIV1} ${SLIV2} or On Specific Slot ${slot}
    @{list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.SLIV    slot    ${SLIVLIST}    except    ${slot}    include    ulFdSchedData.SLIV    no
    ${slivlist}     Evaluate      list(set(${list}))
    Should Be True    (${slivlist}==${SLIV1})or(${slivlist}==${SLIV2})
	
Check Layer For Cell
    [Arguments]    ${log_dir}    ${pci}    ${rank}
    ${value}    Read Csv Columns    ${log_dir}    ulFdSchedData.numOfLayers    filter=((ulFdSchedData.dciFormat==UL_01)&(physCellId==${pci}))
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${rank}

Check Slot For TDD for 1208
    [Arguments]    ${log_dir}    ${dciFormat}    ${pci}    ${slotlist}
    ${value}    Read Csv Columns    ${log_dir}    slot    filter=((${dciFormat}==UL_01)&(physCellId=${pci}))
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${slotlist}

Send Commond To Trigger UE2 Lower Sinr
    [Arguments]    ${pathloss}=130    ${ue_id}=2
    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pathloss}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=1 action=activate
    sleep    10s    #sleep for sinr stable

Set UL Lower SINR To Trigger ASRS For UE2 and UE3
    [Arguments]    ${pathloss}=133    ${ue1_id}=2    ${ue2_id}=3
    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pathloss}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue1_id} testmode=ul_sinr profile_id=1 action=activate
    sleep    2s    #sleep for sinr stable
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue2_id} testmode=ul_sinr profile_id=1 action=activate
    sleep    5s    #sleep for sinr stable

Trigger UL BLER For Three UEs
    Set Value For UL BLER testmode    ${UE_ID1}
    Set UL Lower SINR To Trigger ASRS For UE2 and UE3

Collect BIP log For Case Debugging
    [Arguments]    ${sleep_time}=2   ${log_id}=1
    Start Gnb BIP Log
    Sleep    ${sleep_time}   reason=Wait for log
    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}

Send Traffic for BB007
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${dir}=ul
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=100 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=100 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=8 trf_id=3
    sleep    10s    #sleep for stable traffic
	
Trigger A1 Addition For BB007
   [Arguments]    ${ue_id}=${UE_ID}    ${meas_id}=1    ${srsrp_nr}=75    ${srsrq_nr}=60    ${phycell_id}=52
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} phycell_id=${phycell_id}

Cancel BLER on PCELL for UE
    [Arguments]    ${UE_ID}=1
    ${cmd}    Set Variable    ue_testmode_set_nr id=${UE_ID} scell=1 testmode=bler profile_id=3 action=deactivate
    ute_wtssim.Execute Egate Command    ${cmd}

Trigger Layer1 To Layer2
    [Arguments]    ${UE_ID}=1
    ${cmd}    Set Variable    ue_testmode_set_nr id=${UE_ID} testmode=ul_sinr profile_id=1 action=deactivate
    ute_wtssim.Execute Egate Command    ${cmd}
	
Send Big Traffic For DL and UL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1 
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=10 trf_id=4
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=170 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=2 trf_id=2
    sleep    10s    #sleep for stable traffic
	
Send Small Traffic For UL and DL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=dl trf_id=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=dl trf_id=2
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=dl trf_id=3
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=ul trf_id=1
    sleep    10s    #sleep for stable traffic

Send small or big traffic For UL
    [Arguments]    ${ue_id}=3    ${mbps}=170
    Log To Console    will send UL traffic ${mbps}mbps......
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${mbps} trf_id=1
    
Recover Traffic For UL and DL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=170 trf_id=1
    sleep    10s    #sleep for stable traffic

Set Value For Large UL BLER testmode
    [Arguments]    ${UE_ID}    ${scell}=0
    Log To Console    Set Value For UL BLER testmode...
    ${cmd1}    Set Variable    bler_testmode_nr profile_id=3 ul_bler=200,1000,200,1000,200,1000,200,1000
    ute_wtssim.Execute Egate Command    ${cmd1}
    Sleep    1s    reason=Wait for log
    ${cmd2}    Set Variable    ue_testmode_set_nr id=${UE_ID} testmode=bler action=activate profile_id=3 scell=${scell}
    ute_wtssim.Execute Egate Command    ${cmd2}
