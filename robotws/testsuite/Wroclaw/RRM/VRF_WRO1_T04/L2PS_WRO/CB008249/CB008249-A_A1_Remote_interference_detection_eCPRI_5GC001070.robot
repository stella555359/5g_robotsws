*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../CB007813/CB007813-B_keywords.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_GSCN_7880.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008249_A_1070_GP_2_50M.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 3
${RI_LOW_POWER_VALUES}=     SEPARATOR=
...                         -140,-140,-139,-138,-137,-136,-135,-134,-133,-132,-131,-130,-128,-126,-124,-122,-120,
...                         -118,-120,-124,-126,-128,-130,-131,-132,-133,-134,-135,-136,-137,-138,-140
${RI_HIGH_POWER_VALUES}=    SEPARATOR=
...                         -135,-130,-120,-115,-110,-110,-110,-110,-110,-110,-110,-110,-110,-55,-55,-60,-60,-65,-70,-75,
...                         -80,-85,-90,-95,-99,-104,-105,-110,-115,-120,-130,-135
${RI_MONITORING_PERIOD}=    5m

*** Test Cases ***
CB008249-A_A1_Remote_interference_detection_eCPRI_5GC001070_GP2_NSA
    Setup X2 Link
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic NSA
    Generate Remote Interference    2    ${RI_LOW_POWER_VALUES}
    Wait For 2 RI Monitoring Periods
    Check If RI Alarm Is Not Present
    Deactivate Remote Interference Testmode    2
    Generate Remote Interference    3    ${RI_HIGH_POWER_VALUES}
    Wait For 2 RI Monitoring Periods
    Check If RI Alarm Is Present
    Deactivate Remote Interference Testmode    3
    Wait For 2 RI Monitoring Periods
    Check If RI Alarm Is Not Present
    [Teardown]    Stop All Data Transfers And Detach UE NSA

*** Keywords ***
Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Start DL and UL Data Traffic NSA
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=50
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=150
    Sleep    30s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}
    Set Test Variable    ${tput_bf_RI}    ${avg_tput}

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11

Wait For 2 RI Monitoring Periods
    Sleep    10m      Wait For 2xRI Monitoring Period

Generate Remote Interference
    [Arguments]    ${ID}    ${RI_PWR}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=${ID} start_symbol_position=0 num_of_symbols=32 noise_power_values=${RI_PWR}
    Sleep    2s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=1 testmode=remote_interference profile_id=${ID} action=activate
    Sleep    10s

Create RI Profiles
    [Arguments]    ${RI_PWR}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=${ID} start_symbol_position=0 num_of_symbols=32 noise_power_values=${RI_PWR}

Deactivate Remote Interference Testmode
    [Arguments]    ${ID}
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=1 testmode=remote_interference profile_id=${ID} action=deactivate
    Sleep    10s

Check If RI Alarm Is Not Present
    Verify If Admin Fault Is Down    fault_id=7525

Check If RI Alarm Is Present
    Verify If Admin Fault Is Up    fault_id=7525

