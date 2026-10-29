*** Settings ***
Library    taf.ul.gnb.bip.collection   WITH NAME   bip_collection
Library    Collections
Library    taf.selenium.sbts  WITH NAME  selenium_coam
Documentation
...    This file contains general keywords used for testing Feature CB009823.

*** Keywords ***
Set Tdd Frame
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_set_special_slot_1116.json
    Sleep    120s

Configure Rimrs Framework-1
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_enabe_actNrRim_framework_1_for_1116.json

Keep transmission RIMRS
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_max_Rs_Detect_Duration_Without_Ri.json

Configure Rimrs Framework-1_1208
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_enabe_actNrRim_framework_1_for_1208.json

Set Tdd Frame_1208
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_set_special_slot_1208.json

Enable actDisableEcpriUlScalingEnh
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_enable_actDisableEcpriUlScalingEnh.json

Enable actRinCmFmReport
    Configure    ${CURDIR}/config/delta_enable_actRimCmFmReport.yaml

Prepare Rimrs Testmode For 1208 FS
   ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=22222 numRsSetId=1 rimRsType=rsType1AndType2
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 rsPattern2Period=25
    ...     \ repetitionRsType1=2 repetitionRsType2=2 rim_framework=framework_1 factorRsSequence=1 factorRsSequenceRS2=1 globalF0ForRs=633390
    ...     \ offsetRsSequence=1 offsetRsSequenceRS2=1 startFreqOffsetForRs=20,70 numRsType1SetId=1048576 numRsType2SetId=1048576
    Execute Egate Command     cmd=${rim_rs_profile1}

Start Data Traffic In DL and UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}      ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl}

Prepare Rimrs Testmode For 1116 FS
   ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=22222 numRsSetId=1 rimRsType=rsType1AndType2
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50 rsPattern2Period=25
    ...     \ repetitionRsType1=2 repetitionRsType2=2 rim_framework=framework_1 factorRsSequence=1 factorRsSequenceRS2=1 globalF0ForRs=633390
    ...     \ offsetRsSequence=1 offsetRsSequenceRS2=1 startFreqOffsetForRs=20,70 numRsType1SetId=524288 numRsType2SetId=524288
    Execute Egate Command     cmd=${rim_rs_profile1}

Activate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Deactivate RI
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=deactivate

Activate RIMRS
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate

Deactivate RIMRS
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=deactivate

Cellect BIPlogs
    [Arguments]    ${file_name}    ${pdml_file}
    Start L1l2bip Mirroring
    Sleep    10s
    Stop L1l2bip Mirroring    file_name=${file_name}
    Convert pcap file to pdml    file_name=${file_name}    pdml_file=${pdml_file}

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${file_name}    ${pdml_file}
    Log to console    Converting pcap to pdml
    ${tshark_cmd} =    Catenate    tshark
    ...    -r ${OUTPUT_DIR}/l1l2bip/${file_name}
    ...    -Y "(dldata_pdschsendreql1sw) && !(3gpp.rnti == 65535)"
    ...    -T pdml > ${pdml_file}
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Verify If Mitigation Stopped And Transsmission PDSCH Is Visible In Muting Slots
    [Arguments]    ${pdml_file}    @{slots_to_check}
    ${error_message}=    check_dl_mitigation_stopped    ${pdml_file}    ${slots_to_check}
    Run Keyword If    '${error_message}' != 'None'    Fail    ${error_message}

Verify If Mitigation Started And Transsmission PDSCH Is Not Visible In Muting Slots
    [Arguments]    ${pdml_file}    @{slots_to_check}
    ${error_message}=    check_dl_mitigation_started    ${pdml_file}    ${slots_to_check}
    Run Keyword If    '${error_message}' != 'None'    Fail    ${error_message}

Wait For RS2 To Be Detected
    Selenium Coam Login And Disable Screen Lock
    Check RS2 Detection

Selenium Coam Login And Disable Screen Lock
    [Arguments]    ${download_dir}=${OUTPUT_DIR}
    ...            ${timeout}=${60}
    ...            ${url}=https://192.168.255.129
    ...            ${username}=Nemuadmin
    ...            ${password}=nemuuser
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Verify PM Counters For RIMRS
    [Arguments]    ${ul_symbols}    ${average_RSSI}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00001
    ...    value=${ul_symbols}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00002
    ...    value=300
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00003
    ...    value=300
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
   Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00281
    ...    value=300
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
   Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00005
    ...    value=1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
   Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00006
    ...    value=1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00009
    ...    value=${average_RSSI}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00010
    ...    value=${average_RSSI}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00011
    ...    value=${average_RSSI}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00012
    ...    value=${average_RSSI}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00013
    ...    value=${average_RSSI}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}

Verify If Pm Counters Are Not Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00001
    ...    value=0
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00002
    ...    value=0
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
