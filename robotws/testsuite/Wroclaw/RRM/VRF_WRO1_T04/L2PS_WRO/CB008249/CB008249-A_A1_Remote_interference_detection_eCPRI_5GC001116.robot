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
    ...                        scfc_filename=full_CB008249_A_1116_GP_6_0ms_50M.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 3
${RI_LOW_POWER_VALUES}=     SEPARATOR=
...                         -112,-114,-113,-112,-110,-108,-105,-108,-110,-115,-117,-120,-125,-130,-135,-140
...                         -112,-114,-113,-112,-110,-108,-105,-108,-110,-115,-117,-120,-125,-130,-135,-140
${RI_HIGH_POWER_VALUES}=    SEPARATOR=
...                         -100,-97,-95,-92,-90,-89,-85,-81,-78,-77,-75,-73,-70,-67,-65,-60,-52,-55,-60,-64,-68,-72,
...                         -76,-80,-84,-88,-91,-94,-97,-99,-100,-101
${RI_MONITORING_PERIOD}=    5m

*** Test Cases ***
CB008249-A_A1_Remote_interference_detection_eCPRI_5GC001116_GP6_0ms_SA
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic
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
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=50
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=100
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    60s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}
    Set Test Variable    ${tput_bf_RI}    ${avg_tput}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Wait For 2 RI Monitoring Periods
    Sleep    10m      Wait For 2xRI Monitoring Period

Generate Remote Interference
    [Arguments]    ${ID}    ${RI_PWR}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=${ID} start_symbol_position=0 num_of_symbols=32 noise_power_values=${RI_PWR}
    Sleep    2s
    Execute Egate Command    cmd=cell_testmode_set_nr gnb=2 cell_id=1 testmode=remote_interference profile_id=${ID} action=activate
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

