*** Settings ***
Documentation    Suite description
#Library     OperatingSystem
#Library     taf.analyzer.pdml
#Library     CSI_in_pcap.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/1348_kw.py
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    alarm_verification
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot


*** Keywords ***
Cell unlock 10659
    [Arguments]  ${dist_name_1}=MRBTS-51006/NRBTS-51006/NRCELL-1
    Make connection
    coam.unblock_cell     dist_name=${dist_name_1}  timeout=100  detailed_output=True  connection=cOAM
    Sleep                30s

Cell lock 10659
   [Arguments]  ${dist_name_1}=MRBTS-51006/NRBTS-51006/NRCELL-1
   Make connection
   coam.block_cell     dist_name=${dist_name_1}  timeout=100  detailed_output=True  connection=cOAM
   Log to console     Cell blocked succesfully

Decrease radio conditions
    FOR    ${index}   IN RANGE    1     8
       ${attenuate}=   Evaluate    ${index} * 6
       Log to console  Set - ${attenuate} dB
       Set attenuation and check  lines=@{lines_gNB_153_AHLOA_3}    value=${attenuate}
	END

Increase radio conditions
    @{reverse_list}=    Evaluate  list(range(7,0,-1))
    FOR    ${index}   IN     @{reverse_list}
       ${attenuate}=   Evaluate    ${index} * 6
       Log to console  Set - ${attenuate} dB
       Set attenuation and check  lines=@{lines_gNB_153_AHLOA_3}    value=${attenuate}
	END
Decrease radio conditions AHLOA
    FOR    ${index}   IN RANGE    1     8
       ${attenuate}=   Evaluate    ${index} * 6
       Log to console  Set - ${attenuate} dB
       Set attenuation and check  lines=@{lines_gNB_153_AHLOA_1}    value=${attenuate}
	END

Increase radio conditions AHLOA
    @{reverse_list}=    Evaluate  list(range(7,0,-1))
    FOR    ${index}   IN     @{reverse_list}
       ${attenuate}=   Evaluate    ${index} * 6
       Log to console  Set - ${attenuate} dB
       Set attenuation and check  lines=@{lines_gNB_153_AHLOA_1}    value=${attenuate}
	END

Delta commision additional parameters
    [Arguments]  ${cell_1_path}=MRBTS-51006/NRBTS-51006/NRCELL-1
    Initialise delta store
    Add param to delta       ${cell_1_path}       actAdaptiveReTxResMcs           value=true
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}


Read counters value 10659
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55303C00028
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM counters 10659
    log to console      Verify PM counters values, wait 200 seconds
    Sleep  200s
    ${counters}         Read Counters Value 10659
    ${counter_check}    check_counters_8662    ${counters}
    Should be True      ${counter_check}

Test case scenario
    [Arguments]        ${cell_lock}=False
    Setup attenuators
    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_3}     value=0
    Attach UE SA for test
    Start ULDL UDP SA    200Mbits/sec   50MBits/sec
    Start New L1L2 Logs
    Decrease radio conditions
    Sleep  20s
    Run keyword if     ${cell_lock}     Cell lock scenario
    Increase radio conditions
    Sleep   30s
    Stop Data Transfer    DT_DL_SA
    Stop Data Transfer    DT_UL_SA
    Run keyword and ignore error    Detach Ue   UE_2
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Verify reserved MCS for uplink

Cell lock scenario
    Cell lock 10659
    Delta commision additional parameters
    Cell unlock 10659

Update Software If Necessary
    admin.connect_to  bts_host=192.168.255.129
    ${is_23_active}=    check_if_sw_incompatible_alarm_occurred
    log to console    is 23 active: ${is_23_active}
    Run keyword if    ${is_23_active}    Perform update with burak