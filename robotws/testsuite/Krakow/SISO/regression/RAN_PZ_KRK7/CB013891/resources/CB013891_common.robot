*** Settings ***
Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com

Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords
Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Library     taf.config.scf    WITH NAME    scfcfg
Library     ute_wtssim
Library     ta5g_commissioning
Library     re
Resource    testsuite/Krakow/resources/former_l3_sw2/configurators_cls.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB013891/resources/CB013891_variables.py


*** Keywords ***
Start WTS and Reach Onair State
    ${status}    Set Variable    FAIL
    Wait Until Keyword Succeeds    3 times    5s    Start WTS and Wait For All Cells To Be OnAir
    ${status}    Set Variable    PASS
    [Teardown]    Run Keyword If    '${status}' == 'FAIL'    Run Keywords
    ...    Log to Console    Failed to Reach Onair
    ...    AND    Teardown Egate If Running    log_dir=${SUITE_log_dir}/Suite_Setup/Egate/Failed_attempt/
    ...    AND    Reboot GNB and AP

Start WTS and Wait For All Cells To Be OnAir
    Start WTS and Reach Onair    wts_cfg=${WTS_CFG}    log_dir=${SUITE_log_dir}/Suite_Setup/Egate/    skip_confirmation=yes    skip_x2_link=yes
    gnbcell.Wait For All Cells To Be OnAir    timeout=360s
    Execute Egate Command Ext
    ...    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=X2AP Link with GNB.*is up
    ...    log_msg=Starting X2 Link between ENB-1 and GNB-2

Start Multiple UEs L3 Call And Verify Traffic
    [Arguments]    ${ue_ids}    ${call_type}=SA    ${target_cells}=1
    FOR    ${id}    IN    @{ue_ids}
        Run Keyword If    '${call_type}' == 'SA'     Start SA L3 Call    ue_id=${id}
        ${target_cells}    Run Keyword If    '${call_type}' == 'NSA'    Get Substring    ${id}    0    1
        Run Keyword If    '${call_type}' == 'NSA'    Start NSA L3 Call    ue_id=${id}    target_gnb_cell=${target_cells}
    END
    Sleep    10s    reason=Wait for traffic before verification
    FOR    ${id}    IN    @{ue_ids}
        Run Keyword    Verify ${call_type} UE Traffic Using Bearer Stats    ue_id=${id}
    END

Stop Multiple UEs L3 Call
    [Arguments]    ${ue_ids}    ${call_type}=SA
    FOR    ${id}    IN    @{ue_ids}
        Run Keyword    Stop ${call_type} L3 Call    ue_id=${id}
    END

Start And Stop Multiple UEs L3 Call With Traffic Verification
    [Arguments]    ${ue_ids}=1    ${call_type}=SA    ${target_cells}=1
    FOR    ${id}    IN    @{ue_ids}
        Run Keyword If    '${call_type}' == 'SA'     Start SA L3 Call    ue_id=${id}
        ${target_cells}    Run Keyword If    '${call_type}' == 'NSA'    Get Substring    ${id}    0    1
        Run Keyword If    '${call_type}' == 'NSA'    Start NSA L3 Call    ue_id=${id}    target_gnb_cell=${target_cells}
    END
    Sleep    10s    reason=Wait for traffic before verification
    FOR    ${id}    IN    @{ue_ids}
        Run Keyword    Verify ${call_type} UE Traffic Using Bearer Stats    ue_id=${id}
        Run Keyword    Stop ${call_type} L3 Call    ue_id=${id}
    END

Reset gNB via GUI and Wait For All Cells To Be OnAir
    Reset gNB via GUI
    Sleep    180s    reason=Wait for gNB startup
    Restart WTS and Wait For All Cells To Be OnAir

Restart WTS and Wait For All Cells To Be OnAir
    Execute Egate Command    cmd=reset
    Wait for All Cells to be Configured    timeout=900
    Log to Console    Restarting SimMode with config: ${WTS_CFG}
    Execute Egate Command   cmd=cfg file=${WTS_CFG}    pass_regexp=SimMode is ready    timeout=30
    Log to Console    Waiting for All Cells To Be OnAir
    gnbcell.Wait For All Cells To Be OnAir    timeout=360s
    Execute Egate Command Ext    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=X2AP Link with GNB.*is up
    ...    log_msg=Starting X2 Link between ENB-1 and GNB-2

Configure WTS
    [Arguments]    ${AP_version}=4.0.34507
    ${installer_file}    Set Variable    sandybridge.tar.bz2
    ${installer_path}    Set Variable    /home/ute/robotws
    ${installer_link}    Catenate    SEPARATOR=
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-airphone-ci-gen-local/Airphone/${AP_version}/
    ${result}    Run Process    ls    /opt/wts/latest
    Run Keyword If    ${result.rc} == 0    Run Keywords
    ...    Log to Console    WTS is already installed. Skipping installation.
    ...    AND    Return From Keyword
    Run Process And Expect Success    sudo    mkdir    /opt/wts    /opt/wts/latest
    ...    msg=Error creating directory for wts
    Run Process And Expect Success    wget    --netrc    -r    -np    -nd    --no-verbose    -A    ${installer_file}    ${installer_link}
    ...    msg=Error downloading wts
    Log to Console    Unzipping WTS for AP ${AP_version}...    no_newline=${True}
    Run Process And Expect Success    sudo    tar    -xvf    ${installer_path}/esimmode_WTS*    -C    /opt/wts/latest/
    ...    msg=Error unzipping wts in directory /opt/wts/latest
    Run Process And Expect Success    sudo    chown    -R    ute:ute    /opt/wts/latest/
    ...    msg=Error changing the owner of newly created /opt/wts/latest
    Log to Console    Done

Verify If All UEs Are Still ${state}
    ${TEST_UEs}    Combine Lists    ${TEST_SA_UEs}    ${TEST_NSA_UEs}
    ${active_ues}    Get IDs of Attached UEs From Egate
    Run Keyword If    '${state}' != 'Active' and ${active_ues} == []    Return From Keyword
    Collections.Lists Should Be Equal    ${TEST_UEs}    ${active_ues}

L3 Call With Traffic Verification For Random OAM Operations
    ${egate_active}    Run Keyword And Return Status    Execute egate command    cmd=sim_state_disp    pass_regexp=The state is ACTIVE
    Run Keyword If    not ${egate_active}    Restart WTS and Wait For All Cells To Be OnAir
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_1}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_1}     call_type=NSA    target_cells=1
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_2}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_2}     call_type=NSA    target_cells=2
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_3}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_3}     call_type=NSA    target_cells=3

Combine All UEs List
    ${SA_UEs}     Combine Lists    ${SA_UE_IDS_CELL_1}     ${SA_UE_IDS_CELL_2}     ${SA_UE_IDS_CELL_3}
    ${NSA_UEs}    Combine Lists    ${NSA_UE_IDS_CELL_1}    ${NSA_UE_IDS_CELL_2}    ${NSA_UE_IDS_CELL_3}
    Set Suite Variable    ${SA_UEs}
    Set Suite Variable    ${NSA_UEs}

Lock SFP LANE and Check Alarms
    [Arguments]    ${SFP_DN}
    ta5g_commissioning.perform_parameter_commissioning    parameter=administrativeState    value=Locked    dist_name=${SFP_DN}
    Sleep    60s    reason=Wait for SFP LANE ${SFP_DN} to be locked
    # gnbalarm.Verify Allowed Alarms    allowed_alarms=@{ALLOWED_ALARM_SFP_LANE_LOCKED}    timeout=300s

Unlock SFP LANE and Check Alarms
    [Arguments]    ${SFP_DN}
    ta5g_commissioning.perform_parameter_commissioning    parameter=administrativeState    value=Unlocked    dist_name=${SFP_DN}
    Sleep    30s    reason=Wait for SFP LANE ${SFP_DN} to be unlocked
    # gnbalarm.Verify Allowed Alarms    allowed_alarms=@{ENB_ALLOWED_ALARMS}    timeout=300s

Check Cells Status and Alarms After SFP LANE
    [Arguments]    ${operation}
    ${are_impacted_cells_onair}          Run Keyword And Return Status    gnbcell.Wait For All Cells To Be OnAir    timeout=180s
    ${are_only_allowed_alarms_raised}    Run Keyword And Return Status    Verify Allowed Alarms on gNB    allowed_alarms=@{ENB_ALLOWED_ALARMS}
    Run Keyword If    ${are_only_allowed_alarms_raised} and not ${are_impacted_cells_onair}
    ...               Fail    msg=BTS State Incorrect
    Run Keyword If    not ${are_only_allowed_alarms_raised} and ${are_impacted_cells_onair}
    ...               Fail    msg=BTS State Incorrect
    Run Keyword If    '${operation}' == 'Unlock' and not ${are_impacted_cells_onair}    Run Keywords
    ...           Reset gNB    wait_for_reconnection=False
    ...    AND    Log to Console    Reset Site Perfored due to Alarms still active and Waiting for Cells to be On Air
    ...    AND    Sleep    360s
    ...    AND    gnbcell.Wait For All Cells To Be OnAir    timeout=360s
    Run Keyword If    '${operation}' == 'Unlock'    Verify Allowed Alarms on gNB    allowed_alarms=@{ENB_ALLOWED_ALARMS}
    Run Keyword If    '${operation}' == 'Lock' and not ${are_only_allowed_alarms_raised}
    ...               Verify Allowed Alarms on gNB    allowed_alarms=@{ALLOWED_ALARM_SFP_LANE_LOCKED}

Trigger CB013891 Site Reset Scenario
    ${shuffled_L3_CALL_NETWORK_MODE}    ${seed}    Random List Shuffle    ${L3_CALL_NETWORK_MODE}
    Log to Console    Resetting Site
    Reset gNB via GUI
    Log to Console    Reset Site Performed and Waiting for All Cells To Be OnAir
    Sleep    360s
    gnbcell.Wait For All Cells To Be OnAir    timeout=60s
    Log to Console    All Cells are back OnAir
    Perform ${shuffled_L3_CALL_NETWORK_MODE}[0] L3 Call With Traffic Verification
    Perform ${shuffled_L3_CALL_NETWORK_MODE}[1] L3 Call With Traffic Verification

Trigger CB013891 ${RAT_type} RAT Reset Scenario
    ${shuffled_L3_CALL_NETWORK_MODE}    ${seed}    Random List Shuffle    ${L3_CALL_NETWORK_MODE}
    Run Keyword If    '${RAT_type}' == 'NR'     Start L3 Call    duration=300s    network_mode=LTE
    Run Keyword If    '${RAT_type}' == 'LTE'    Start L3 Call    duration=300s    network_mode=NR
    Run Keyword If    '${RAT_type}' == 'GSM'    Start L3 Call    duration=300s    network_mode=${shuffled_L3_CALL_NETWORK_MODE}[0]
    Log to Console    Triggering ${RAT_type} RAT Reset
    gnbbbu.RAT Reset    rat_type=${RAT_type}
    ${RAT_type_lowercase}    Convert To Lower Case    ${RAT_type}
    Run Keyword If    '${RAT_type}' == 'GSM'    Sleep    20s    reason=Wait for gsmSectorID to be established
    gnbcell.Wait For All Cells Statuses    cell_type=${RAT_type_lowercase}    operational_state=disabled    timeout=360
    Log to Console    ${RAT_type} RAT Reset Performed and Waiting For All Cells To Be OnAir
    Sleep    60s    reason=Wait for other cell IDs to be established
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    Log to Console    All Cells are back OnAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{ENB_ALLOWED_ALARMS}
    Run Keyword If    '${RAT_type}' == 'NR'     Run Keywords
    ...    Verify LTE Call Traffic and Detach UE
    ...    Perform NR L3 Call With Traffic Verification
    Run Keyword If    '${RAT_type}' == 'LTE'     Run Keywords
    ...    Verify NR Call Traffic and Detach UE
    ...    Perform LTE L3 Call With Traffic Verification
    Run Keyword If    '${RAT_type}' == 'GSM'    Run Keywords
    ...    Verify ${shuffled_L3_CALL_NETWORK_MODE}[0] Call Traffic and Detach UE
    ...    Perform ${shuffled_L3_CALL_NETWORK_MODE}[1] L3 Call With Traffic Verification


Trigger CB013891 ${SFP} SFP Lock Unlock Operations
    ${status}    Set Variable    FAIL
    Lock SFP LANE and Check Alarms    SFP_DN=MRBTS-75060/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-${SFP}/LANE-1
    Log to Console    SFP LANE Locked and Trigger Reset Site
    Reset gNB    wait_for_reconnection=False
    Log to Console    Reset Site Performed and Waiting For RUs to be Online
    Sleep    360s
    gnbru.Wait For Radio Unit To Be Online    ru_id=2    timeout=600s
    Log to Console    All Radio Units Online and Waiting For Cells to be Initialized
    Sleep    1200s
    gnbcell.Wait For All Cells Statuses
    ...    operational_state=${{ re.compile(r'enabled|disabled') }}
    ...    availability_status=${{ re.compile(r'online|failed') }}
    ...    cell_type=nr    timeout=360s
    gnbcell.Wait For All Cells Statuses
    ...    operational_state=${{ re.compile(r'enabled|disabled') }}
    ...    availability_status=${{ re.compile(r'online|failed') }}
    ...    cell_type=gsm    timeout=360s
    Run Keyword If    '${SFP}' != '1'    gnbcell.Wait For All Cells Statuses
    ...    operational_state=${{ re.compile(r'enabled|disabled') }}
    ...    availability_status=${{ re.compile(r'online|failed') }}
    ...    cell_type=lte    timeout=360s
    Run Keyword If    '${SFP}' == '1'    Wait For All LTE and NB-IoT Cells Statuses
    Check Cells Status and Alarms After SFP LANE    operation=Lock
    Unlock SFP LANE and Check Alarms    SFP_DN=MRBTS-75060/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-${SFP}/LANE-1
    Check Cells Status and Alarms After SFP LANE    operation=Unlock
    gnbcell.Wait For All Cells To Be OnAir    timeout=360s
    ${status}    Set Variable    PASS

Perform ${network_mode} L3 Call With Traffic Verification
    Log to Console    Perform ${network_mode} L3 Call
    Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    Wait for complete `ute_ue.Require UE`
    Run Keyword If    '${network_mode}' == 'NR'    Adjust APN    ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP    apn_name=5gsakrk
    ...    ELSE    Adjust APN    ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP    apn_name=5gbothkrk
    Sleep    5sec    Wait for APN Adjust Complete
    Run Keyword If    '${network_mode}' == 'NR'    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    ...    ELSE    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    5sec    Wait for Change Network Mode complete
    Run Keyword If    '${network_mode}' == 'NR'    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    NR5G    3
    ...    ELSE    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    3
    Sleep    5sec    Wait for Set Active Bands complete
    Wait Until Keyword Succeeds    10min    30s   Attach UE
    Sleep    5sec    Wait for Attach UE complete
    Wait Until Keyword Succeeds    10min    30s   Start DL Traffic    network_mode=${network_mode}
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Log to Console    Verifying DL Traffic
    Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                         tput=${DEFAULT_TPUT_DL_${network_mode}}
    ...                                         deviation=${DEFAULT_DEVIATION_DL}
    Log to Console    Starting UL Traffic
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL_${network_mode}}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Log to Console    Verifying UL Traffic
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${DEFAULT_TPUT_UL_${network_mode}}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

Start L3 Call
    [Arguments]    ${duration}=${DEFAULT_DATA_TRANSFER_DURATION}    ${network_mode}=NR
    Log to Console    Perform ${network_mode} L3 Call
    Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    Wait for complete `ute_ue.Require UE`
    Run Keyword If    '${network_mode}' == 'NR'    Adjust APN    ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP    apn_name=5gsakrk
    ...    ELSE    Adjust APN    ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP    apn_name=5gbothkrk
    Sleep    5sec    Wait for APN Adjust Complete
    Run Keyword If    '${network_mode}' == 'NR'    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    ...    ELSE    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    5sec    Wait for Change Network Mode complete
    Run Keyword If    '${network_mode}' == 'NR'    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    NR5G    3
    ...    ELSE    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    3
    Sleep    5sec    Wait for Set Active Bands complete
    Wait Until Keyword Succeeds    10min    30s   Attach UE
    Sleep    10sec    Wait for Attach UE complete
    ${UE_INFO}    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    Sleep    5sec    Wait for Get UE Info complete
    Wait Until Keyword Succeeds    10min    30s   Start DL Traffic    network_mode=${network_mode}
    Log to Console    Starting UL Traffic
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${duration}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL_${network_mode}}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8

Verify ${network_mode} Call Traffic and Detach UE
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Log to Console    Verifying DL Traffic
    Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                         tput=${DEFAULT_TPUT_DL_${network_mode}}
    ...                                         deviation=${DEFAULT_DEVIATION_DL}
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Log to Console    Verifying UL Traffic
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${DEFAULT_TPUT_UL_${network_mode}}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}
    ${UE_INFO}    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

Attach UE
    Log to Console    Attaching UE
    ${status}    Run Keyword And Return Status    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    IF    not ${status}
        Log to Console    UE attach failed, trying to recover UE by rebooting it
        ute_ue.Reboot Ue    ${UE_DEFAULT_ALIAS_NAME}      timeout=${170}
        Sleep    10s    Wait for UE Reboot
        Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}
        Sleep    5sec    Wait for complete `ute_ue.Require UE`
        Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
        Sleep    5sec    Wait for complete `ute_ue.Require UE`
        Log to Console    Attaching UE Again
        ${status}    Run Keyword And Return Status    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    END
    Run Keyword If    not ${status}    Fail    UE attach failed even after recovery

Start DL Traffic
    [Arguments]    ${network_mode}=NR
    Log to Console    Starting DL Traffic
    ${status}    Run Keyword And Return Status    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL_${network_mode}}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8
    IF    not ${status}
        Log to Console    Cannot start DL traffic, trying to recover UE by rebooting it and reattach
        ute_ue.Reboot Ue    ${UE_DEFAULT_ALIAS_NAME}      timeout=${170}
        Sleep    10s    Wait for UE Reboot
        Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}
        Sleep    5sec    Wait for complete `ute_ue.Require UE`
        Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
        Sleep    5sec    Wait for complete `ute_ue.Require UE`
        ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
        Sleep    5sec    Wait for complete `ute_ue.Attach UE`
        Log to Console    Starting DL Traffic Again
        ${status}    Run Keyword And Return Status    ute_ue.Start Data Transfer    dt_name=DT_DL
        ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
        ...                           direction=dl
        ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
        ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
        ...                           throughput=${DEFAULT_TPUT_DL_${network_mode}}
        ...                           protocol=${DEFAULT_PROTOCOL}
        ...                           parallel_streams=8
    END
    Run Keyword If    not ${status}    Fail    Start DL Traffic Failed Even After Recovery

Trigger Blocking and Unblocking All Cells By Frequency Band
    ${shuffled_bands_list}    ${seed}    Random Dict Shuffle    ${Bands_list}
    FOR    ${band}    ${cells_list}    IN    &{shuffled_bands_list}
        ${shuffled_L3_CALL_NETWORK_MODE}    ${seed}    Random List Shuffle    ${L3_CALL_NETWORK_MODE}
        ${in_use_l3_call_network_mode}    Set Variable If
        ...    '${band}' == 'b3'	NR
        ...    '${band}' == 'n3'    LTE
        ...    '${band}' != 'n3' and '${band}' != 'e3'    ${shuffled_L3_CALL_NETWORK_MODE}[0]
        Start L3 Call    duration=300s    network_mode=${in_use_l3_call_network_mode}
        Log To Console    Blocking all cells in band ${band}
        FOR    ${cell_id}    IN    @{cells_list}
            gnbcell.Block Cell    cell_id=${cell_id}
            gnbcell.Wait For Cell Statuses    operational_state=disabled    availability_status=offline
            ...    blocking_state=blocked    timeout=1200s    cell_id=${cell_id}
            Log To Console    Blocked cell_id-${cell_id}
            Sleep    5s
        END
        Verify ${in_use_l3_call_network_mode} Call Traffic and Detach UE
        Log To Console    Unblocking all cells in band ${band}
        FOR    ${cell_id}    IN    @{cells_list}
            gnbcell.Unblock Cell    cell_id=${cell_id}
            gnbcell.Wait For Cell Statuses    operational_state=enabled    blocking_state=unblocked    timeout=1200s    cell_id=${cell_id}
            Log To Console    Unblocked cell_id-${cell_id}
            Sleep    5s
        END
    END

Trigger Blocking and Unblocking All Cells By RAT
    ${shuffled_RAT_list}    ${seed}    Random List Shuffle    ${RAT_list}
    FOR    ${RAT_type}    IN    @{shuffled_RAT_list}
        ${shuffled_L3_CALL_NETWORK_MODE}    ${seed}    Random List Shuffle    ${L3_CALL_NETWORK_MODE}
        ${RAT_type_lowercase}    Convert To Lower Case    ${RAT_type}
        ${in_use_l3_call_network_mode}    Set Variable If
        ...    '${RAT_type}' == 'NR'	 LTE
        ...    '${RAT_type}' == 'LTE'    NR
        ...    '${RAT_type}' == 'GSM'    ${shuffled_L3_CALL_NETWORK_MODE}[0]
        Start L3 Call    duration=300s    network_mode=${in_use_l3_call_network_mode}
        Log To Console    Blocking all cells in RAT ${RAT_type}
        gnbcell.Block All Cells from RAT    rat=${RAT_type}
        Sleep    2s
        gnbcell.Wait For All Cells Statuses    operational_state=disabled    availability_status=offline
        ...    blocking_state=blocked    timeout=1200s    cell_type=${RAT_type_lowercase}
        Log To Console    All cells in RAT ${RAT_type} blocked
        Verify ${in_use_l3_call_network_mode} Call Traffic and Detach UE
        Log To Console    Unblocking all cells in RAT ${RAT_type}
        gnbcell.Unblock All Cells from RAT    rat=${RAT_type}
        Sleep    2s
        gnbcell.Wait For All Cells Statuses    operational_state=enabled
        ...    blocking_state=unblocked    timeout=1200s    cell_type=${RAT_type_lowercase}
        Log To Console    All cells in RAT ${RAT_type} unblocked
        Remove Values From List    ${shuffled_L3_CALL_NETWORK_MODE}    ${in_use_l3_call_network_mode}
    END

Trigger Blocking and Unblocking All Cells Except Designated L3 Call Cell
    Log To Console    Blocking all cells
    gnbcell.Block All Cells from RAT    rat=NR
    gnbcell.Block All Cells from RAT    rat=LTE
    gnbcell.Block All Cells from RAT    rat=GSM
    gnbalarm.Verify Alarm is Active    fault_name=Cell blocked    fault_id=49    alarm_id=7102    severity=Critical
    gnbcell.Wait For All Cells Statuses    operational_state=disabled    availability_status=offline    blocking_state=blocked    timeout=1200s
    Log To Console    Unblocking NRCELL-1
    gnbcell.Unblock Cell    cell_id=1
    Log To Console    Unblocked NRCELL-1
    gnbcell.Wait For Cell Statuses    operational_state=enabled    blocking_state=unblocked    timeout=1200s    cell_id=1
    Perform NR L3 Call With Traffic Verification
    Log To Console    Blocking back NRCELL-1
    gnbcell.Block Cell    cell_id=1
    Log To Console    Blocked NRCELL-1
    gnbcell.Wait For Cell Statuses    operational_state=disabled    availability_status=offline
    ...    blocking_state=blocked    timeout=1200s    cell_id=1
    Log To Console    Unblocking LNCEL-41
    gnbcell.Unblock Cell    cell_id=41
    Log To Console    Unblocked LNCEL-41
    gnbcell.Wait For Cell Statuses    operational_state=enabled    blocking_state=unblocked    timeout=1200s    cell_id=41
    Perform LTE L3 Call With Traffic Verification
    Log To Console    Blocking back LNCEL-41
    gnbcell.Block Cell    cell_id=41
    Log To Console    Blocked LNCEL-41
    gnbcell.Wait For Cell Statuses    operational_state=disabled    availability_status=offline
    ...    blocking_state=blocked    timeout=1200s    cell_id=41
    Log To Console    Unblocking all cells
    gnbcell.Unblock All Cells from RAT    rat=NR
    gnbcell.Unblock All Cells from RAT    rat=LTE
    gnbcell.Unblock All Cells from RAT    rat=GSM
    gnbalarm.Verify Alarm is not Active    fault_name=Cell blocked    fault_id=49    alarm_id=7102    severity=Critical
    gnbcell.Wait For All Cells Statuses    operational_state=enabled    blocking_state=unblocked    timeout=1200s
    Log To Console    All cells unblokced

Wait For All LTE and NB-IoT Cells Statuses
    gnbcell.Wait For Cell Statuses
    ...    operational_state=disabled
    ...    availability_status=failed
    ...    cell_id=70    cell_type=lte    timeout=360s
    gnbcell.Wait For Cell Statuses
    ...    operational_state=disabled
    ...    availability_status=failed
    ...    cell_id=71    cell_type=lte    timeout=360s
    gnbcell.Wait For Cell Statuses
    ...    operational_state=disabled
    ...    availability_status=offline
    ...    cell_id=72    cell_type=lte    timeout=360s

Upload SCF and Wait For All Cells to Be OnAir
    Fix and Upload SCF    scf=/home/ute/testline_configuration/7_7_TSPY060/${ENB_BRANCH}/GNB0_SCF.xml
    ...    skip_errors=no    activate=yes    timeout=600
    gnbcell.Wait For All Cells To Be OnAir    timeout=360

Change Custom Allowed Alarms
    [Arguments]    ${NEW_CUSTOM_ALLOWED_ALARM_LIST}
    @{CUSTOM_ALLOWED_ALARMS}    Set Variable    ${NEW_CUSTOM_ALLOWED_ALARM_LIST}
    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}