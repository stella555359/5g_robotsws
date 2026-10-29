*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Shekhar
...              :contact: Shekhar.vijay_Barewar@nokia.com

Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py


*** Variables ***

*** Keywords ***
Check Blind SCell Addition and Small BWP in SCell
    [Arguments]   ${loc_BW}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*scellIdx.*  timeout=15
    BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}
Start Big DL Data Transfer And Check SCell Activation for the Blind Scell Added with 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=175       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=175       trf_id=2
	sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=175       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=175       trf_id=4
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=175       trf_id=5
    sleep   5s
    sleep   15s    reason=Wait for successful traffic start
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*CellIndex.*  timeout=15
    Get Lines Matching Regexp    ${output}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
Verify DL Tput For 2CC
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${350}
    Should Be True    ${scell_tput} > ${450}	
Verify UL and DL ScheduledUes with counter_vDU
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}    ${pi_file_pattern}
    ${path}   Set Variable    /home/ute/logs/CB008541/${TEST_NAME}/gnb_pm_counters
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_1}>=1
    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_2}>=1	
Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -2
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}