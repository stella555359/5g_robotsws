*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO

Resource         CB013233_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with all config files with rad_params
...                 AND     Start Log   btslog
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run keywords
...                 UE Deregister should be Successful    ${sa_ue_id1}
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log   btslog    snapshot    sosreport


Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     The user scenario targets the skipping DRX configuration in ICS for
...                               SA UE that is a candidate for activation inter-freq A4 measurements for CA.
...
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26633
...                               CB_FIM_49169
...                               CB_FIM_49165
...                               CB_FIM_49166



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/A_B201_ALT_2/wts_6733_vonr.cfg
${SCFC}             scfc_CB006733_BOO_AP_LOO_VoNR.xml
${AP_XML}           ${CURDIR}/config/A_B201_ALT_2/iphy_xml_6733.xml
${rad_params}       0x890091=1

${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${4}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1

${TEST_NAME}     TC1
${CELL_ID}    4


*** Test Cases ***
CB013233-A#B201_ALT2_No_DRX_setup_during_ICS_for_SA_UE_inter_freq_A4_measurements_for_CA_T_F
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    log to console   "SA UE attach "
    Start Log    cprt
    Change UE location   ${sa_ue_id1}    2    ${CELL_ID}
    ${ue_rnti}    UE Register should be Successful with DRX    ${sa_ue_id1}
    Trigger High DL Traffic SA without sleep  ue_id=${sa_ue_id1}    dl_rate=750   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High UL Traffic SA  ue_id=${sa_ue_id1}    ul_data=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Send A4 Measurement
    sleep   10s
    Verify Traffic on both PCell and Scell    ${sa_ue_id1}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Verify DRXcycle not present in F1AP_UEContextSetupRequest     ${path1}   ${ue_rnti}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=     Get Latest Unpacked Full Pm Counters File Classical  output_dirpath=${OUTPUT DIR}/pmcounter1
    Run Keyword and Continue on Failure     Link SCOUT SCF to Configuration ID for Reporting
    Verify Any Counters In File
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >100   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}

*** Keywords ***
Verify Traffic on both PCell and Scell
    [Arguments]   ${ue_id}
    ${pcell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=dl   cell_type=pcell  scell_index=0
    ${scell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=dl   cell_type=scell  scell_index=1

Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
     wtsrunner.ue_stats_nr     id=${ue_id} type=${type} scell=${scell_index} format=long
    ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
    ...                     timeout=30
#     ${output}    Read WTS Output Until Pattern Matches    CellIndex-0    40
#    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}


Send A4 Measurement
    sleep   1s
    wtsrunner.script   file=${CURDIR}/config/a4_meas.txt
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=rrcReconfigurationComplete    timeout=100

UE Register should be Successful with DRX
    [Arguments]   ${ue_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_session_ID}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log     ${crnti_value}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${ue_id}    nwslice=${nwslice_ID}    gw=${gw_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Initial Context Setup Successful for UE    timeout=30
    should not contain   ${output}   drx-Config setup
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=drx-SlotOffset    timeout=30
    ${output1}         Get Lines Matching Regexp    ${output}    drx-onDurationTimer    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-InactivityTimer    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms80
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerDL    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerUL    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-LongCycleStartOffset     partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms160
    BuiltIn.Log                first_ue_register_is_ok with DRX
    [Return]    ${crnti_value}

Change UE location
    [Arguments]   ${ue_id}   ${enb_id}   ${cell_id}
    wtsrunner.ue_change_location    id=${ue_id}  enb=${enb_id}  cell=${cell_id}

Trigger High DL Traffic SA without sleep
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
            Run Keyword if    ${loop}==0       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=${dl_rate_reminder}   ack_mode=off  cl_trf_stats=on
            Run Keyword if    ${loop}>0        wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=175   ack_mode=off  cl_trf_stats=on
            ${TRF_ID}=      Evaluate     ${TRF_ID}+1
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

