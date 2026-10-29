*** Settings ***
Documentation     author: ruiyu.han
...               contact: ruiyu.han@nokia-sbell.com
...               squad group: T04
...               feature : CB014095


Library     OperatingSystem
Library     String
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB014095/Resource/query_airphone.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB014095/Resource/variable.py
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

*** Variables ***
${EGATE_PORT}=    20000
${EDAEMON_PORT}=    10000
${WTS_PATH}=    /opt/iphy/latest
${SSH_PORT}=    22
${SSH_PROMPT}=    \$${Empty}
${HOST_IP}=    ${tl.test_pc.default_ssh_connection_details.addr}
${SSH_USERNAME}=    ${tl.test_pc.default_ssh_connection_details.username}
${SSH_PASSWORD}=    ${tl.test_pc.default_ssh_connection_details.password}
@{L3CALL_GP1}     1    2   3    4    5
@{L3CALL_GP2}     6    7   8    9    10
@{L3CALL_GP3}     11   12  13   14   15
@{L3CALL_GP4}     16   17  18   19   20
# @{L3CALL_GP1}     1
# @{L3CALL_GP2}     6
# @{L3CALL_GP3}     11
# @{L3CALL_GP4}     16
${IDLE_UE}    ${False}
${AP_IP}=    192.168.200.129
${AP_USER}=    toor4nsn
${AP_PASSWORD}=    oZPS0POrRieRtu


*** Keywords ***
Case Setup for CB014095
    COAM Login
    Setup egate CB014095    basic.cfg
    ${allowed_faults}    Create List    49    7305    7304
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults}
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    ${pci_freq_dict}    Get PCI and Frequency Dictionary
    set suite variable    ${pci_freq_dict}
    #debug
    # Login egate


Case Teardown for CB014095
    Check Extra Reset From Blackbox
    Wait Until Keyword Succeeds   3x   30s   COAM Login
    Run Keyword If     ${KEYWORD STATUS.count('PASS')}<=0      Catch Snapshot COAM
    # Run Keyword If     ${KEYWORD STATUS.count('PASS')}<=0    stop collect sosreport
    run keyword and ignore error    ADMIN UnBlock NR cell and check status    cell_index=5
    run keyword and ignore error    ADMIN UnBlock NR cell and check status    cell_index=6
    Run Keyword and Ignore Error   COAM Logout
    ${IDLE_UE}    Check If IDLE UE existing
    set suite variable    ${IDLE_UE}
    Run Keyword and Ignore Error   teardown_all_aliases_for_egate
    return from keyword if    ${IDLE_UE}


Setup egate CB014095
    [Arguments]    ${cfgfile}=basic.cfg
    # Install AP packge and wts
    Clear ALL egate logs
    RUN    cd /opt/iphy/latest;./killUTE
    sleep    10s
    COAM Reset Site
    Wait Until Keyword Succeeds    3m    30s   BBMOD Should Be enabled   bbmod_index=1    connection=COAM
    Set rto_min 100 at Gnb
    RUN    cd /opt/iphy/latest;./startUTE &
    Sleep    5s    # Wait for service to start
    configure_ssh_connection_for_wts    host_ip=${HOST_IP}   ssh_username=${SSH_USERNAME}
    ...   ssh_password=${SSH_PASSWORD}   ssh_port=${SSH_PORT}
    setup_egate    egate_port=${EGATE_PORT}    save_egate=True
    ...   ssh_pass=${SSH_PASSWORD}    ssh_host=${HOST_IP}
    ...   ssh_user=${SSH_USERNAME}    alias=egate
    # start collect sosreport
    ute_wtssim.execute_egate_command_and_wait_for_data      cmd=cfg file=/opt/iphy/latest/${cfgfile}   alias=egate    timeout=600s
    ...   pass_regexp=Cell Setup completed

Set rto_min 100 at Gnb
    [Documentation]    Set SCTP rto_min to 100 on GNB 192.168.255.129
    ${GNB_IP}=    Set Variable    192.168.255.129
    ${GNB_USER}=    Set Variable    toor4nsn
    ${GNB_PASS}=    Set Variable    oZPS0POrRieRtu
    ${SSH_OPTS}=    Set Variable    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    OperatingSystem.Run    sshpass -p ${GNB_PASS} ssh ${SSH_OPTS} ${GNB_USER}@${GNB_IP} 'sysctl net.sctp.rto_min=100'
    ${output}=    OperatingSystem.Run    sshpass -p ${GNB_PASS} ssh ${SSH_OPTS} ${GNB_USER}@${GNB_IP} 'cat /proc/sys/net/sctp/rto_min' | tail -1
    Should Be Equal As Strings    ${output.strip()}    100    rto_min is not 100, got: ${output}

start collect sosreport
    [Documentation]    Start sosreport collection from ASIL in background
    RUN    cd /opt/iphy/latest/sosReport_ASIL && nohup ./startTest_ASIL.sh > /tmp/sosReport_start.log 2>&1 &
    Wait Until Keyword Succeeds    10m    10s    check sosreport log contains
    ...    /tmp/sosReport_start.log    Done. You can now start your tests in egate
    Log To Console    sosreport collection started

stop collect sosreport
    [Documentation]    Stop sosreport collection from ASIL in background
    RUN    cd /opt/iphy/latest/sosReport_ASIL && nohup ./stopTest_ASIL.sh > /tmp/sosReport_stop.log 2>&1 &
    Wait Until Keyword Succeeds    30m    30s    check sosreport log matches
    ...    /tmp/sosReport_stop.log    SosReport\\d+_\\d+_complete_UEAPP\\.tgz created
    Log To Console    sosreport collection completed

check sosreport log contains
    [Arguments]    ${log_file}    ${expected}
    ${output}=    RUN    cat ${log_file}
    Should Contain    ${output}    ${expected}

check sosreport log matches
    [Arguments]    ${log_file}    ${pattern}
    ${output}=    RUN    cat ${log_file}
    Should Match Regexp    ${output}    ${pattern}


Check If IDLE UE existing
    ${output}=    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_summary    alias=egate    timeout=5s
    ...   pass_regexp=Idle
    ${idle_count}=    String.Get Regexp Matches    ${output}    (?m)^Idle\\s+(\\d+)    1
    Should Not Be Empty    ${idle_count}    Could not parse Idle count from ue_summary output
    IF    '${idle_count}[0]' != '0'
        Log    IDLE UE(s) found: ${idle_count}[0]    console=True
        RETURN    ${True}
    END
    RETURN    ${False}



Clear ALL egate logs
    run keyword and ignore error    RUN    rm -rf /opt/iphy/latest/*.log*
    run keyword and ignore error    RUN    rm -rf /tmp/sosReport/*
    run keyword and ignore error    RUN    rm -rf /tmp/btslog2/*
    run keyword and ignore error    RUN    sudo rm -rf /tmp/AP_ttiTraces_*



Login egate
    ute_wtssim.setup_egate    egate_port=${EGATE_PORT}    save_egate=True
    ...   ssh_pass=${SSH_PASSWORD}    ssh_host=${HOST_IP}
    ...   ssh_user=${SSH_USERNAME}    alias=egate


Blind_Massive_Bulk_SCell_Release_intra_gNB_CA
    Case Setup for CB014095
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_blind}
    Wait Until Keyword Succeeds    20m    30s    COAM Check All Cells Onair
    ADMIN Block NR cell and check status    cell_index=5
    ADMIN Block NR cell and check status    cell_index=6
    #config 3CC CA with BLIND
    LOOP to Attach SA UE
    Check ALL CA UE Status after CA setup
    #remove nrcell-2
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_2}
    sleep    1min
    Check ALL CA UE Status after Remove scell
    ##multiple stepwise remove scell  remove NRCELL-3
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_3}
    sleep    1min
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    [Teardown]    Case Teardown for CB014095


A1_Oneshot_Massive_Bulk_SCell_Release_intra_gNB_CA
    Case Setup for CB014095
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_A1_ONESHOT}
    Wait Until Keyword Succeeds    20m    30s    COAM Check All Cells Onair
    ADMIN Block NR cell and check status    cell_index=5
    ADMIN Block NR cell and check status    cell_index=6
    Attach SA ALL UE with A1
    Check ALL CA UE Status after CA setup
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_2}
    sleep    40s
    Check ALL CA UE Status after Remove scell
    ADMIN UnBlock NR cell and check status    cell_index=5
    FOR    ${i}    IN     @{L3CALL_GP4}
        RE-CA with MeasId    ue_id=${i}    event=eventA1    phycell_id=53
    END
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp4=CellIndex-0.*CellIndex-1
    ...   ul_pass_regexp_gp4=CellIndex-0.*CellIndex-1
    ##multiple stepwise remove scell
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_5}
    sleep   1min
    Check ALL CA UE Status after Remove scell
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_3}
    sleep   1min
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    [Teardown]    Case Teardown for CB014095


A1_STEPWISE_Massive_Bulk_SCell_Release_intra_gNB_CA_50times
    Case Setup for CB014095
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_A1_STEPWISE}
    Wait Until Keyword Succeeds    20m    30s    COAM Check All Cells Onair
    ADMIN Block NR cell and check status    cell_index=5
    ADMIN Block NR cell and check status    cell_index=6
    Attach SA ALL UE with A1    50times_flag=${True}
    FOR    ${i}    IN RANGE    1    30
        log to console    [INFO]this is ${i} time to A1 CA setup and remove scell...
        sleep   10s
        Check ALL CA UE Status after CA setup
        ...   dl_pass_regexp_gp1=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
        ...   dl_pass_regexp_gp2=CellIndex-0.*CellIndex-1.*CellIndex-2(?!.*CellIndex-)
        ...   dl_pass_regexp_gp3=CellIndex-0.*CellIndex-1.*CellIndex-2(?!.*CellIndex-)
        ...   dl_pass_regexp_gp4=CellIndex-0.*CellIndex-1.*CellIndex-2(?!.*CellIndex-)
        ...   ul_pass_regexp_gp1=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
        ...   ul_pass_regexp_gp2=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
        ...   ul_pass_regexp_gp3=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
        ...   ul_pass_regexp_gp4=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
        Check MeasID For ALL UEs after CA setup for A1 STEPWISE
        COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_2}
        COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_ADD_scell_2}
        sleep    120s
        Check ALL CA UE Status after Remove scell
        ...   dl_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
        ...   dl_pass_regexp_gp2=CellIndex-0.*CellIndex-2(?!.*CellIndex-)
        ...   dl_pass_regexp_gp3=CellIndex-0.*CellIndex-2(?!.*CellIndex-)
        ...   dl_pass_regexp_gp4=CellIndex-0.*CellIndex-2(?!.*CellIndex-)
        ...   ul_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
        ...   ul_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
        ...   ul_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
        ...   ul_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
        Check MeasID For ALL UEs after Remove scell-1 for A1 STEPWISE
        SEND ALL UE A1 MR
    END

    [Teardown]    Case Teardown for CB014095


A4_Oneshot_Massive_Bulk_SCell_Release_intra_gNB_CA
    Case Setup for CB014095
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_A4_ONESHOT}
    Wait Until Keyword Succeeds    20m    30s    COAM Check All Cells Onair
    Attach SA ALL UE with A4
    Check ALL CA UE Status after CA setup
    Check MeasID For ALL UEs after CA setup
    log to console    this is to A4 CA setup and remove scell...
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_2}
    sleep   1min
    Check ALL CA UE Status after Remove scell
    Check MeasID For ALL UEs after Remove scell-1
    FOR    ${i}    IN     @{L3CALL_GP4}
        Wait Until Keyword Succeeds    3x    5s
        ...    RE-CA with MeasId    ue_id=${i}    event=eventA4    phycell_id=54
    END
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp4=CellIndex-0.*CellIndex-1
    ...   ul_pass_regexp_gp4=CellIndex-0.*CellIndex-1
    Check MeasID For ALL UEs after RE-CA
    # ##multiple stepwise remove scell
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_3_5}
    sleep   1min
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    [Teardown]    Case Teardown for CB014095


A4_Stepwise_Massive_Bulk_SCell_Release_intra_gNB_CA
    Case Setup for CB014095
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_A4_STEPWISE}
    Wait Until Keyword Succeeds    20m    30s    COAM Check All Cells Onair
    Attach SA ALL UE with A4
    Check ALL CA UE Status after CA setup
    Check MeasID For ALL UEs after CA setup
    log to console    this is to A4 CA setup and remove scell...
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_2}
    sleep   1min
    Check ALL CA UE Status after Remove scell
    Check MeasID For ALL UEs after Remove scell-1
    FOR    ${i}    IN     @{L3CALL_GP3}    @{L3CALL_GP4}
        Wait Until Keyword Succeeds    3x    5s
        ...    RE-CA with MeasId    ue_id=${i}    event=eventA4    phycell_id=54
    END
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp3=CellIndex-0.*CellIndex-1.*CellIndex-2(?!.*CellIndex-)
    ...   ul_pass_regexp_gp3=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   dl_pass_regexp_gp4=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   ul_pass_regexp_gp4=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    Check MeasID For ALL UEs after RE-CA
    # ##multiple stepwise remove scell
    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_RM_scell_3_5}
    sleep   1min
    Check ALL CA UE Status after Remove scell
    ...   dl_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   dl_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp1=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp2=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp3=CellIndex-0(?!.*CellIndex-)
    ...   ul_pass_regexp_gp4=CellIndex-0(?!.*CellIndex-)
    [Teardown]    Case Teardown for CB014095



Attach SA ALL UE with A1
    [Arguments]    ${phycell_id}=53    ${50times_flag}=${False}
    ${MergedList}=    Create List    @{L3CALL_GP1}    @{L3CALL_GP2}    @{L3CALL_GP3}    @{L3CALL_GP4}

    FOR    ${i}    IN    @{L3CALL_GP1}
        log to console    this is UE_${i}
        run keyword if  ${50times_flag}    ute_wtssim.execute_egate_command_and_wait_for_data
        ...   cmd=ue_param id=${i} ue_nr_capabilities=$UE_Capa_CA_2CC_2566   alias=egate    timeout=5s
        Wait Until Keyword Succeeds    3x    10s    Attach 5G SA UE    ue_id=${i}    dltp=100   ultp=10
    END

    FOR    ${i}    IN    @{L3CALL_GP2}   @{L3CALL_GP3}   @{L3CALL_GP4}
        log to console    this is UE_${i}
        run keyword if  ${50times_flag}    ute_wtssim.execute_egate_command_and_wait_for_data
        ...   cmd=ue_param id=${i} ue_nr_capabilities=$UE_Capa_CA_3CC   alias=egate    timeout=5s
        Wait Until Keyword Succeeds    3x    10s    Attach 5G SA UE    ue_id=${i}    dltp=100   ultp=10
    END

    ${A1_meas_id}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType
    ...    CarrierFreq=${pci_freq_dict['${phycell_id}']}    event_type=EventA1    ue=6

    FOR    ${i}    IN    @{MergedList}
        continue for loop if  '${50times_flag}'=='${False}' and '${i}' in @{L3CALL_GP1}
        log to console    this is UE_${i} send A1 MR
        SEND A1 MR    ue_id=${i}   meas_id=${A1_meas_id}
    END

SEND ALL UE A1 MR
    [Arguments]    ${phycell_id}=53    ${event}=EventA1
    ${MergedList}=    Create List    @{L3CALL_GP1}    @{L3CALL_GP2}    @{L3CALL_GP3}    @{L3CALL_GP4}
    FOR    ${i}    IN     @{MergedList}
        log to console    this is UE_${i} send A1 MR
        ${meas_id}    Wait Until Keyword Succeeds    2min    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['${phycell_id}']}
    ...    event_type=${event}   ue=${i}   rsrp=34
        SEND A1 MR    ue_id=${i}   meas_id=${meas_id}
    END

RE-CA with MeasId
    [Arguments]    ${ue_id}    ${event}=eventA4    ${phycell_id}=52    ${pci_toadd}=54
    ${meas_id}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['${phycell_id}']}
    ...    event_type=${event}   ue=${ue_id}
    run keyword if   '${event}'=='eventA4'
    ...   Wait Until Keyword Succeeds    3x    2s    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_schedule_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 phycell_id=${phycell_id} nrsrp_nr=80   alias=egate    timeout=5s
    ...   pass_regexp=PhysCellId:${pci_toadd}\\] SCellIndex \\d activated successfully at airphone
    ...   ELSE IF  '${event}'=='eventA1'
    ...   Wait Until Keyword Succeeds    3x    2s    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_schedule_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 phycell_id=${phycell_id} srsrp_nr=90   alias=egate    timeout=5s
    ...   pass_regexp=PhysCellId:${pci_toadd}\\] SCellIndex \\d activated successfully at airphone

Check MeasID For ALL UEs after Remove scell-1
    FOR  ${ue_id}    IN    @{L3CALL_GP2}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
         log to console    this is UE_${ue_id} with measid_${measid_A1pcellswitch} for event A1pcellswitch
         log to console    this is UE_${ue_id} with measid_${measid_A2scellrelease} for event A2scellrelease
         log to console    this is UE_${ue_id} with measid_${measid_A2pcellswitch} for event A2pcellswitch
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP3}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         log to console    this is UE_${ue_id} with measid_${measid_A1pcellswitch} for event A1pcellswitch
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         log to console    this is UE_${ue_id} with measid_${measid_A2scellrelease} for event A2scellrelease
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
         log to console    this is UE_${ue_id} with measid_${measid_A2pcellswitch} for event A2pcellswitch
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA1    pci=51    rsrp=120
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    pci=51    rsrp=110
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP4}
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA1    rsrp=120
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    rsrp=110
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    rsrp=120
    END

UE should have no report cfg Id
    [Documentation]    Verify that no matching eventType (optionally filtered by RSRP) exists.
    ...    If pci is provided, check no MeasId for that PCI's CarrierFreq + eventType.
    ...    If pci is None, check no ReportCfgId for the eventType at all.
    [Arguments]    ${ue_id}    ${event_type}    ${pci}=${None}    ${rsrp}=${None}
    ${content}=    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...   pass_regexp=NR MEASUREMENT IDENTITIES:[\\s\\S]*?-----[\\s\\S]*?={10,}
    ...   alias=egate    timeout=5s

    # Extract all ReportCfgIds for the given eventType
    ${report_cfg_pattern}=    Set Variable    (?mi)^(\\d+)\\s+NR\\s+${event_type}\\s+
    ${report_cfg_matches}=    String.Get Regexp Matches    ${content}    ${report_cfg_pattern}    1
    # If no report config found at all, pass directly
    IF    not $report_cfg_matches
        Log    No ReportCfgId found for eventType ${event_type} on UE${ue_id} — as expected    console=True
        RETURN
    END

    # If RSRP is provided, filter report configs by RSRP
    IF    '${rsrp}' != '${None}'
        @{filtered_report_cfg_ids}=    Create List
        FOR    ${report_cfg_id}    IN    @{report_cfg_matches}
            ${trigger_pattern}=    Catenate    SEPARATOR=${EMPTY}
            ...    (?si)UE${ue_id} TRIGGER EVENT for report configuration ${report_cfg_id}:
            ...    (?:(?!TRIGGER EVENT)[\\s\\S])*?${event_type}:
            ...    (?:(?!TRIGGER EVENT)[\\s\\S])*?RSRP ${rsrp}
            ${trigger_matches}=    String.Get Regexp Matches    ${content}    ${trigger_pattern}
            IF    $trigger_matches
                Append To List    ${filtered_report_cfg_ids}    ${report_cfg_id}
            END
        END
    ELSE
        @{filtered_report_cfg_ids}=    Copy List    ${report_cfg_matches}
    END

    # If no matching report config after RSRP filtering, pass
    IF    not $filtered_report_cfg_ids
        ${log_msg}=    Set Variable    No ReportCfgId found for eventType ${event_type} with RSRP ${rsrp} on UE${ue_id} — as expected
        Log    ${log_msg}    console=True
        RETURN
    END

    # If pci is None, the eventType+RSRP should not exist at all — fail
    IF    '${pci}' == '${None}'
        Fail    UE${ue_id} should NOT have ReportCfgId for eventType ${event_type} (RSRP ${rsrp}), but found: ${filtered_report_cfg_ids}
    END

    # pci is provided — check no MeasId for that PCI's CarrierFreq + eventType
    ${CarrierFreq}=    Set Variable    ${pci_freq_dict['${pci}']}
    ${object_id_pattern}=    Set Variable    (?m)^(\\d+)\\s+NR\\s+${CarrierFreq}\\s+
    ${object_id_matches}=    String.Get Regexp Matches    ${content}    ${object_id_pattern}    1
    IF    not $object_id_matches
        ${log_msg}=    Set Variable    No ObjectId found for PCI ${pci} (CarrierFreq ${CarrierFreq}) on UE${ue_id} — as expected
        Log    ${log_msg}    console=True
        RETURN
    END
    ${target_object_id}=    Set Variable    ${object_id_matches}[0]

    # Check that no MeasId exists combining this ObjectId with any matched ReportCfgId
    FOR    ${report_cfg_id}    IN    @{filtered_report_cfg_ids}
        ${meas_id_pattern}=    Set Variable    (?m)^(\\d+)\\s+${target_object_id}\\s+${report_cfg_id}\\s*\\r?$
        ${meas_id_matches}=    String.Get Regexp Matches    ${content}    ${meas_id_pattern}    1
        ${err_msg}=    Catenate
        ...    UE${ue_id} should NOT have MeasId for PCI ${pci}
        ...    (CarrierFreq ${CarrierFreq}) + eventType ${event_type}
        ...    (RSRP ${rsrp}), but found MeasId ${meas_id_matches}
        ...    with ObjectId ${target_object_id} ReportCfgId ${report_cfg_id}!
        Should Be Empty    ${meas_id_matches}    ${err_msg}
    END
    ${log_msg}=    Catenate    No MeasId found for PCI ${pci} (CarrierFreq ${CarrierFreq})
    ...    + eventType ${event_type} (RSRP ${rsrp}) on UE${ue_id} — as expected
    Log    ${log_msg}    console=True

Check MeasID For ALL UEs after Remove scell-1 for A1 STEPWISE
    FOR  ${ue_id}    IN    @{L3CALL_GP2}    @{L3CALL_GP3}    @{L3CALL_GP4}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         log to console    this is UE_${ue_id} with measid_${measid_A1pcellswitch} for event A1pcellswitch
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         log to console    this is UE_${ue_id} with measid_${measid_A2scellrelease} for event A2scellrelease
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
         log to console    this is UE_${ue_id} with measid_${measid_A2pcellswitch} for event A2pcellswitch
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA1    pci=51    rsrp=120
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    pci=51    rsrp=110
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP1}
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA1    rsrp=120
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    rsrp=110
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    rsrp=120
    END


Check MeasID For ALL UEs after CA setup for A1 STEPWISE
    [Arguments]    ${scell_pci}=51    # noqa: ARG01
    log to console    Check MeasID For ALL UEs after CA setup for A1 STEPWISE
    FOR  ${ue_id}    IN    @{L3CALL_GP1}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['51']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['51']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP2}    @{L3CALL_GP3}    @{L3CALL_GP4}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['51']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['51']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END


Check MeasID For ALL UEs after CA setup
    [Arguments]    ${scell_pci}=51
    log to console    Check MeasID For ALL UEs after CA setup
    FOR  ${ue_id}    IN    @{L3CALL_GP2}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP3}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['51']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['51']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP4}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['${scell_pci}']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['${scell_pci}']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END


Check MeasID For ALL UEs after RE-CA
    [Arguments]    ${scell_pci}=54
    FOR  ${ue_id}    IN    @{L3CALL_GP2}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP3}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['52']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA1    pci=51    rsrp=120
        UE should have no report cfg Id    ue_id=${ue_id}    event_type=EventA2    pci=51    rsrp=110
    END

    FOR  ${ue_id}    IN    @{L3CALL_GP4}
         ${measid_A1pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['${scell_pci}']}
    ...    event_type=EventA1   ue=${ue_id}   rsrp=120
         ${measid_A2scellrelease}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['${scell_pci}']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=110
         ${measid_A2pcellswitch}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType    CarrierFreq=${pci_freq_dict['53']}
    ...    event_type=EventA2   ue=${ue_id}   rsrp=120
    END

SEND A1 MR
    [Arguments]    ${ue_id}    ${meas_id}    ${phycell_id}=53
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...     cmd=ue_schedule_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 phycell_id=${phycell_id} srsrp_nr=90
    ...     alias=egate    timeout=5s
    sleep    2s


Attach SA ALL UE with A4
    FOR    ${i}    IN    @{L3CALL_GP1}
        log to console    this is UE_${i}
        Wait Until Keyword Succeeds    3x    10s    Attach 5G SA UE    ue_id=${i}
    END

    FOR    ${i}    IN    @{L3CALL_GP2}
        log to console    this is UE_${i}
        Wait Until Keyword Succeeds    3x    10s    Attach 5G SA UE with A4    ue_id=${i}    carrier_freq=638688    phycell_id=52
    END

    FOR    ${i}    IN    @{L3CALL_GP3}
        log to console    this is UE_${i}
        Wait Until Keyword Succeeds    3x    10s    Attach 5G SA UE with A4    ue_id=${i}    carrier_freq=638688    carrier_freq_2=425070
        ...    phycell_id=52    phycell_id_2=51
    END

    FOR    ${i}    IN    @{L3CALL_GP4}
        log to console    this is UE_${i}
        Wait Until Keyword Succeeds    3x    10s    Attach 5G SA UE with A4    ue_id=${i}    carrier_freq=425070    phycell_id=51
    END


LOOP to Attach SA UE
    FOR    ${i}    IN RANGE    1    21
        log to console    this is UE_${i}
        Attach 5G SA UE    ue_id=${i}
    END

LOOP to Attach NSA UE
    FOR    ${i}    IN RANGE    21    25
        log to console    this is UE_${i}
        Attach 5G NSA UE    ue_id=${i}
    END

Check ALL CA UE Status after CA setup
    [Arguments]     ${dl_pass_regexp_gp1}=CellIndex-0(?!.*CellIndex-)
    ...   ${dl_pass_regexp_gp2}=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   ${dl_pass_regexp_gp3}=CellIndex-0.*CellIndex-1.*CellIndex-2(?!.*CellIndex-)
    ...   ${dl_pass_regexp_gp4}=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp1}=CellIndex-0(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp2}=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp3}=CellIndex-0.*CellIndex-[12](?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp4}=CellIndex-0.*CellIndex-1(?!.*CellIndex-)

    FOR    ${ue_index}    IN   @{L3CALL_GP1}
        Wait Until Keyword Succeeds    3x    5s
        ...   Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp1}
        ...   ul_pass_regexp=${ul_pass_regexp_gp1}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0
    END

    FOR    ${ue_index}    IN   @{L3CALL_GP2}
        Wait Until Keyword Succeeds    3x    5s
        ...  Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp2}
        ...   ul_pass_regexp=${ul_pass_regexp_gp2}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0.*CellIndex-1
    END

    FOR    ${ue_index}    IN   @{L3CALL_GP3}
        Wait Until Keyword Succeeds    3x    5s
        ...  Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp3}
        ...   ul_pass_regexp=${ul_pass_regexp_gp3}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0.*CellIndex-1
    END

    FOR    ${ue_index}    IN    @{L3CALL_GP4}
        Wait Until Keyword Succeeds    3x    5s
        ...  Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp4}
        ...   ul_pass_regexp=${ul_pass_regexp_gp4}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0
    END


Check ALL CA UE Status after Remove scell
    [Arguments]     ${dl_pass_regexp_gp1}=CellIndex-0(?!.*CellIndex-)
    ...   ${dl_pass_regexp_gp2}=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   ${dl_pass_regexp_gp3}=(?s)CellIndex-0.*CellIndex-[12](?!.*CellIndex-)
    ...   ${dl_pass_regexp_gp4}=CellIndex-0(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp1}=CellIndex-0(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp2}=CellIndex-0.*CellIndex-1(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp3}=(?s)CellIndex-0(?!.*CellIndex-)
    ...   ${ul_pass_regexp_gp4}=CellIndex-0(?!.*CellIndex-)

    FOR    ${ue_index}    IN   @{L3CALL_GP1}
        Wait Until Keyword Succeeds    3x    5s
        ...   Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp1}
        ...   ul_pass_regexp=${ul_pass_regexp_gp1}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0
    END

    FOR    ${ue_index}    IN   @{L3CALL_GP2}
        Wait Until Keyword Succeeds    3x    5s
        ...  Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp2}
        ...   ul_pass_regexp=${ul_pass_regexp_gp2}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0.*CellIndex-1
    END

    FOR    ${ue_index}    IN   @{L3CALL_GP3}
        Wait Until Keyword Succeeds    3x    5s
        ...  Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp3}
        ...   ul_pass_regexp=${ul_pass_regexp_gp3}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0.*CellIndex-1
    END

    FOR    ${ue_index}    IN   @{L3CALL_GP4}
        Wait Until Keyword Succeeds    3x    5s
        ...  Check One UE CA Status    ue_id=${ue_index}    dl_pass_regexp=${dl_pass_regexp_gp4}
        ...   ul_pass_regexp=${ul_pass_regexp_gp4}
        # Check One UE CA Status    ue_id=${ue_index}    pass_regexp=CellIndex-0
    END


Check One UE CA Status
    [Arguments]    ${ue_id}    ${dl_pass_regexp}    ${ul_pass_regexp}
    log to console    this is UE_${ue_id} to check CA status
    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_id} type=pusch scell=primary,secondary    pass_regexp=${ul_pass_regexp}
    ...   alias=egate    timeout=1minutes
    Sleep    1s    reason=wait egate console log print
    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_id} type=pdsch scell=primary,secondary    pass_regexp=${dl_pass_regexp}
    ...   alias=egate    timeout=1minutes
    Sleep    1s    reason=wait egate console log print


Attach 5G SA UE
    [Arguments]    ${ue_id}    ${dltp}=100   ${ultp}=1   ${tp_type}=mbps
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal   alias=egate    timeout=5s
    sleep    2s
    Wait Until Keyword Succeeds    2min    20s    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_register id=${ue_id}    alias=egate    timeout=10s   pass_regexp=UE now in NG RM Registered state
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data      cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1   alias=egate    timeout=10s
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=1 ${tp_type}=${dltp}
    ...   alias=egate    timeout=5s
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul trf_id=1 ${tp_type}=${ultp}
    ...   alias=egate    timeout=5s
    sleep    2s


Attach 5G SA UE with A1
    [Arguments]    ${ue_id}    ${phycell_id}=53   ${dltp}=50   ${ultp}=10
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal   alias=egate    timeout=5s
    sleep    5s
    Wait Until Keyword Succeeds    2min    20s    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_register id=${ue_id}    alias=egate    timeout=5s   pass_regexp=UE now in NG RM Registered state
    sleep    5s
    ${output_A1}    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...   alias=egate    timeout=5s
    ...   pass_regexp=measIdToAddModList
    sleep    1s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...     cmd=ue_schedule_measurement_send_nr id=${ue_id} meas_id=1 event=A1 phycell_id=${phycell_id} srsrp_nr=90   alias=egate    timeout=5s
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=1 mbps=${dltp}
    ...   alias=egate    timeout=5s
    ...   pass_regexp=SCellIndex \\d activated successfully at airphone
    sleep    2s
    # ute_wtssim.execute_egate_command_and_wait_for_data
    # ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=2 mbps=10
    # ...   alias=egate    timeout=5s
    # sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul trf_id=1 mbps=${ultp}
    ...   alias=egate    timeout=5s
    sleep    5s

Attach 5G SA UE with A4
    [Arguments]    ${ue_id}    ${carrier_freq}=425070    ${carrier_freq_2}=None   ${phycell_id}=52   ${phycell_id_2}=51   ${dltp}=100   ${uptp}=1
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal   alias=egate    timeout=5s
    sleep    2s
    Wait Until Keyword Succeeds    2min    20s    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_register id=${ue_id}    alias=egate    timeout=5s   pass_regexp=UE now in NG RM Registered state
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data      cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1   alias=egate    timeout=5s
    sleep    2s
    ${meas_id_1}    Wait Until Keyword Succeeds    3x    5s
    ...    Get MeasID by UEID CarrierFreq and eventType   CarrierFreq=${carrier_freq}    event_type=EventA4   ue=${ue_id}
    ${meas_id_2}    run keyword if   '${carrier_freq_2}'!='None'
    ...   Wait Until Keyword Succeeds    3x    5s
    ...   Get MeasID by UEID CarrierFreq and eventType
    ...   CarrierFreq=${carrier_freq_2}    event_type=EventA4
    ...   ue=${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_schedule_measurement_send_nr id=${ue_id} action=SEND_IMMEDIATELY meas_id=${meas_id_1} event=A4 phycell_id=${phycell_id} nrsrp_nr=80
    ...   alias=egate    timeout=5s
    run keyword if   '${carrier_freq_2}'!='None'
    ...   ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_schedule_measurement_send_nr id=${ue_id} action=SEND_IMMEDIATELY meas_id=${meas_id_2} event=A4 phycell_id=${phycell_id_2} nrsrp_nr=80
    ...   alias=egate    timeout=5s
    # ute_wtssim.execute_egate_command_and_wait_for_data
    # ...   cmd=ue_schedule_measurement_send_nr id=${ue_id} action=SEND_IMMEDIATELY meas_id=1 event=A4 phycell_id=${phycell_id} nrsrp_nr=80
    # ...   alias=egate    timeout=5s
    IF    '${carrier_freq_2}' != 'None'
        ${ca_regexp}=    Catenate    SEPARATOR=${EMPTY}
        ...    (?s)(?=.*PhysCellId:${phycell_id}\\] SCellIndex \\d activated successfully at airphone)
        ...    (?=.*PhysCellId:${phycell_id_2}\\] SCellIndex \\d activated successfully at airphone)
        ute_wtssim.execute_egate_command_and_wait_for_data
        ...     cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=1 mbps=${dltp}
        ...     alias=egate    timeout=15s
        ...     pass_regexp=${ca_regexp}
        ute_wtssim.execute_egate_command_and_wait_for_data
        ...     cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=2 mbps=${dltp}   alias=egate    timeout=15s
        ute_wtssim.execute_egate_command_and_wait_for_data
        ...     cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=3 mbps=${dltp}   alias=egate    timeout=15s
        # ute_wtssim.execute_egate_command_and_wait_for_data
        # ...     cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=4 mbps=${dltp}   alias=egate    timeout=15s
        # ute_wtssim.execute_egate_command_and_wait_for_data
        # ...     cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=5 mbps=${dltp}   alias=egate    timeout=15s
    ELSE
        ute_wtssim.execute_egate_command_and_wait_for_data
        ...     cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=1 mbps=${dltp}   alias=egate    timeout=15s
        ...     pass_regexp=PhysCellId:${phycell_id}\\] SCellIndex \\d activated successfully at airphone
    END
    # ute_wtssim.execute_egate_command_and_wait_for_data
    # ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=2 mbps=${dltp}
    # ...   alias=egate    timeout=5s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul trf_id=1 mbps=${uptp}
    ...   alias=egate    timeout=5s
    # sleep    5s
    # Wait Until Keyword Succeeds    3x    10s    Should Have scell successful info    physical_id=${phycell_id}
    # run keyword if   '${carrier_freq_2}'!='default'
    # ...   Wait Until Keyword Succeeds    3x    10s    Should Have scell successful info    physical_id=${phycell_id_2}
    [Teardown]    run keyword if     ${KEYWORD STATUS.count('PASS')}<=0    run keywords
    ...   log to console    [WRN]UE${ue_id} Attach 5G SA UE with A4 failed! will detach and retry...
    ...   AND   ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=${ue_id} pdu=1 trf_id=1 dir=dl  alias=egate    timeout=5s
    # ...   AND   ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=${ue_id} pdu=1 trf_id=2 dir=dl  alias=egate    timeout=5s
    ...   AND   ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=${ue_id} pdu=1 trf_id=1 dir=ul  alias=egate    timeout=5s
    ...   AND   ute_wtssim.execute_egate_command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off  alias=egate    timeout=5s
    ...   AND   sleep   5s

Attach 5G NSA UE
    [Arguments]    ${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data   cmd=ue_attach id=${ue_id}   alias=egate    timeout=5s
    ...    pass_regexp=EPS_ATTACH
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...   alias=egate    timeout=5s   pass_regexp=successful RA
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data      cmd=trf_data_start ue=${ue_id} id=2 dir=dl trf_id=1 mbps=10   alias=egate    timeout=5s
    sleep    2s
    ute_wtssim.execute_egate_command_and_wait_for_data      cmd=trf_data_start ue=${ue_id} id=2 dir=ul trf_id=1 mbps=1   alias=egate    timeout=5s



Make UE to idle on UE
    [Arguments]    ${ue_id}
    Log To Console    NAS normal release in progress
    ute_wtssim.execute_egate_command    cmd=amf_paging_param id=1 default_drx=128 max_paging_retries=1    alias=egate
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release
    ...   pass_regexp=UE Context Release Complete    alias=egate

LOOP to Make UE to idle
    FOR    ${i}    IN RANGE    1    21
        log to console    this is UE_${i}
        Make UE to idle on UE    ue_id=${i}
    END

Paging from AMF on UE
    [Arguments]    ${ue_id}
    Log To Console    Start to paging
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=amf_paging_start id=1 ue=${ue_id}    pass_regexp=reestablishment complete    alias=egate

LOOP to Make AMF Paging
    FOR    ${i}    IN RANGE    1    21
        log to console    this is UE_${i}
        Paging from AMF on UE    ue_id=${i}
    END

Check if cell on air
    [Arguments]    ${bts_host}=192.168.255.129    # noqa: ARG01
    ute_wtssim.execute_egate_command    cmd=enb_x2_link_up enb=1 target=2    alias=egate    timeout=10s
    ...    pass_regexp=is up
    Connect to gnb coam via ssl    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
    [Teardown]    COAM Teardown gnb connections

Kill WTS services
    OperatingSystem.Run    sudo pkill -f './egate.* --port 20000'
    OperatingSystem.Run    sudo pkill -f './edaemon.* --port 22222'



Config WTS for Airphone
    [Documentation]
    ...     Configure WTS with default config file in __init__.py .
    ...     The parameter ``pass_regexp`` can be used to wait for a string in the egate log or ``timeout``.
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...    | cfg_file   | path of wts config file to be used        |
    ...
    ...    *Example*
    ...    -  NSA TL
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Config WTS for Airphone | pass_regexp=SystemInformationBlockType2 updated |
    ...    - SA TL
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Config WTS for Airphone | pass_regexp=SystemInformationBlockType1-NR updated | timeout=600 |
    ...
    [Arguments]   ${pass_regexp}=${None}   ${timeout}=30   ${wts_alias}=ap_egate   ${cfg_file}=${tl.core.cfg_filename}
    ute_wtssim.execute egate command and wait for data   cmd=cfg file=${cfg_file}   pass_regexp=${pass_regexp}
    ...   timeout=${timeout}   alias=${wts_alias}


Send Egate Command and verify output
    [Documentation]
    ...    Same as keyword `ute_wtssim.execute`_ egate command and wait for data.
    ...
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...
    ...    It sends the given ``cmd`` to egate execute.
    ...    ``timeout`` defines the  timeout for this operation.
    ...    ``return_output`` boolean ${False} or ${Ture} indicate whether egate log should be printed out.
    ...    If given regexp ``pass_regexp`` is found in the command response the KW passes whereas if
    ...    the given ``fail_regexp`` is found in the command output the KW fails. The first occurance decides the result.
    ...    If ``return_output`` is True the egate console output will be returned to the caller.
    ...
    ...    | cmd            | Command to execute                                                |
    ...    | timeout        | Timeout for this operation                                        |
    ...    | return_output  | boolean Flag indicating whether egate log should be printed out   |
    ...    | pass_regexp    | Regexp indicating that the command passed                         |
    ...    | fail_regexp    | Regexp indicating that the command failed                         |
    ...    | wts_alias      | alias name to handle egate for ute_wtssim                         |
    ...
    ...    *Example*
    ...    |  `Start WTS for Airphone` |
    ...    |  `Config WTS for Airphone` |
    ...    | wts_ue.Send Egate Command and verify output | cmd=sim_state_disp | pass_regexp=The state is ACTIVE |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${cmd}   ${timeout}=10   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ...   ${wts_alias}=ap_egate
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}   alias=${wts_alias}
    [Return]   ${output}

UE Register
    [Documentation]
    ...    Performs UE registration for the given ``ue_id``.
    ...
    ...    | ue_id          | Specified UE ID                                           |
    ...    | nwslice        | id of the Network Slice containing the requested NSSAI    |
    ...    | pass_regexp    | Regexp indicating that the command passed                 |
    ...    | kwargs         | Optional additional arguments                             |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=1   ${nwslice}=1   ${pass_regexp}=Received REGISTRATION COMPLETE   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ${output}   Send Egate Command and verify output   cmd=ue_register id=${ue_id} nwslice=${nwslice} ${command_args}
    ...   pass_regexp=${pass_regexp}
    BuiltIn.Log   UE${ue_id} registration is successful   console=${P_console}
    [Return]   ${output}


UE PDU Session Setup
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue             | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...
    ...    *Returns*   ue ip
    ...
    [Arguments]   ${ue}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful
    ${output}   Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=${pdu} ue=${ue} nwslice=${nwslice} gw=${gw}
    ...   pass_regexp=${pass_regexp}
    ${pattern}   Catenate   Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...   UE IP address:([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})
    ${ue_ip}   String.Get Regexp Matches   ${output}   ${pattern}   1
    BuiltIn.Log   UE${ue} PDU${pdu} session setup is successful   console=${P_console}
    [Return]   ${ue_ip[0]}

Wait for one counter period
    [Arguments]    ${interval_time}=5min
    ${wait_time}    Get wait value minutes    interval=${interval_time}
    log to console      .....wait ${wait_time}mins+${interval_time}....
    sleep    ${wait_time}min
    sleep    ${interval_time}

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}


Get MeasID A4
    [Documentation]    Get the latest measId for eventA4 corresponding to the specified ssbFrequency
    [Arguments]    ${ssbFrequency}
    ${content}=    OperatingSystem.Get File    /opt/iphy/4.0.35358/egate_console.log

    # Find all rrcReconfiguration messages and get the latest one
    ${rrc_messages}=    String.Get Regexp Matches    ${content}    message c1 : rrcReconfiguration :[\\s\\S]*?(?=message|$)
    ${latest_rrc_msg}=    Set Variable    ${rrc_messages}[-1]

    # Find reportConfigId for eventA4 in the latest message
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d+)[\\s\\S]*?eventId eventA4
    ${report_id_matches}=    String.Get Regexp Matches    ${latest_rrc_msg}    ${reportConfigIdregex}    report_id
    Should Not Be Empty    ${report_id_matches}    No eventA4 reportConfigId found in latest rrcReconfiguration
    ${a4_report_config_id}=    Set Variable    ${report_id_matches}[0]

    # Find measObjectId for the specified ssbFrequency in the latest message
    # Use a simpler approach: match measObjectId number, then check if ssbFrequency appears within reasonable distance
    ${measObjectIdregex}=    Set Variable    measObjectId\\s+(?P<obj_id>\\d+),\\s*measObject\\s+measObjectNR\\s*:[^}]+ssbFrequency\\s+${ssbFrequency}
    ${obj_id_matches}=    String.Get Regexp Matches    ${latest_rrc_msg}    ${measObjectIdregex}    obj_id
    Should Not Be Empty    ${obj_id_matches}    No measObjectId found for ssbFrequency ${ssbFrequency} in latest rrcReconfiguration
    ${target_meas_object_id}=    Set Variable    ${obj_id_matches}[0]

    # Find measId in measIdToAddModList that matches both measObjectId and reportConfigId in the same block
    ${measIdregex}=    Set Variable
    ...    \\{\\s*measId\\s+(?P<meas_id>\\d+),\\s*measObjectId\\s+${target_meas_object_id},\\s*reportConfigId\\s+${a4_report_config_id}\\s*\\}
    ${meas_id_matches}=    String.Get Regexp Matches    ${latest_rrc_msg}    ${measIdregex}    meas_id
    Should Not Be Empty    ${meas_id_matches}    No measId found for measObjectId ${target_meas_object_id} and reportConfigId ${a4_report_config_id}
    ${measIdA4}=    Set Variable    ${meas_id_matches}[0]

    Log    Found measId ${measIdA4} for eventA4 with ssbFrequency ${ssbFrequency}    console=True
    [Return]    ${measIdA4}


Get MeasID by UEID CarrierFreq and eventType
    [Documentation]    Get the measId corresponding to the specified CarrierFreq and eventType, optionally filtered by RSRP value
    [Arguments]    ${CarrierFreq}    ${event_type}    ${ue}=1    ${rsrp}=${None}
    ${content}=    ute_wtssim.execute_egate_command_and_wait_for_data
    ...   cmd=ue_meas_cfg_disp id=${ue} meas_obj_type=nr
    ...   pass_regexp=NR MEASUREMENT IDENTITIES:[\\s\\S]*?-----[\\s\\S]*?={10,}
    ...   alias=egate    timeout=15s

    # Extract ObjectId for the given CarrierFreq from NR MEASUREMENT OBJECTS section
    ${object_id_pattern}=    Set Variable    (?m)^(\\d+)\\s+NR\\s+${CarrierFreq}\\s+
    ${object_id_matches}=    String.Get Regexp Matches    ${content}    ${object_id_pattern}    1
    Should Not Be Empty    ${object_id_matches}    UE${ue} No ObjectId found for CarrierFreq ${CarrierFreq}
    ${target_object_id}=    Set Variable    ${object_id_matches}[0]

    # Extract all ReportCfgIds for the given eventType from NR REPORT CONFIGURATIONS section
    ${report_cfg_pattern}=    Set Variable    (?mi)^(\\d+)\\s+NR\\s+${event_type}\\s+
    ${report_cfg_matches}=    String.Get Regexp Matches    ${content}    ${report_cfg_pattern}    1
    Should Not Be Empty    ${report_cfg_matches}    UE${ue} No ReportCfgId found for eventType ${event_type}

    # If RSRP is provided, filter by RSRP value in TRIGGER EVENT section
    IF    '${rsrp}' != '${None}'
        ${target_report_cfg_id}=    Set Variable    ${None}
        FOR    ${report_cfg_id}    IN    @{report_cfg_matches}
            ${trigger_pattern}=    Catenate    SEPARATOR=${EMPTY}
            ...    (?si)UE${ue} TRIGGER EVENT for report configuration ${report_cfg_id}:
            ...    (?:(?!TRIGGER EVENT)[\\s\\S])*?${event_type}:
            ...    (?:(?!TRIGGER EVENT)[\\s\\S])*?RSRP ${rsrp}
            ${trigger_matches}=    String.Get Regexp Matches    ${content}    ${trigger_pattern}
            IF    $trigger_matches
                ${target_report_cfg_id}=    Set Variable    ${report_cfg_id}
                BREAK
            END
        END
        Should Not Be Equal    ${target_report_cfg_id}    ${None}    UE${ue} No ReportCfgId found for eventType ${event_type} with RSRP ${rsrp}
    ELSE
        ${target_report_cfg_id}=    Set Variable    ${report_cfg_matches}[0]
    END

    # Extract MeasId for the found ObjectId and ReportCfgId from NR MEASUREMENT IDENTITIES section
    ${meas_id_pattern}=    Set Variable    (?m)^(\\d+)\\s+${target_object_id}\\s+${target_report_cfg_id}\\s*\\r?$
    ${meas_id_matches}=    String.Get Regexp Matches    ${content}    ${meas_id_pattern}    1
    Should Not Be Empty    ${meas_id_matches}    UE${ue} No MeasId found for ObjectId ${target_object_id} and ReportCfgId ${target_report_cfg_id}
    ${meas_id}=    Set Variable    ${meas_id_matches}[0]

    ${log_msg}=    Catenate    UE${ue} Found MeasId ${meas_id} for CarrierFreq ${CarrierFreq},
    ...    eventType ${event_type}, RSRP ${rsrp}, (ObjectId ${target_object_id}, ReportCfgId ${target_report_cfg_id})
    Log    ${log_msg}    console=True
    [Return]    ${meas_id}



Should Have scell successful info
    [Documentation]    Get the scell successful info
    [Arguments]    ${physical_id}
    ${result}=    OperatingSystem.Run    tail -n 50 /opt/iphy/latest/egate_console.log
    Should Match Regexp    ${result}    PhysCellId:${physical_id}] SCellIndex \\d activated successfully at airphone

Get PCI and Frequency Dictionary
    [Documentation]    Get a dictionary mapping physCellId to ARFCN for all cells
    ${cell_list}    COAM Get Cell List
    &{pci_freq_dict}    Create Dictionary

    FOR    ${cell}    IN    @{cell_list}
        ${globalCellId}   Set Variable   ${cell['globalCellId']}
        ${physCellId}    ${arfcn}    Get physCellId and ARFCN by Cellid   gloablecellid=${globalCellId}
        Set To Dictionary    ${pci_freq_dict}    ${physCellId}    ${arfcn}
        Log    Cell ${globalCellId}: PCI=${physCellId}, ARFCN=${arfcn}    console=True
    END

    Log    Total cells found: ${pci_freq_dict.keys().__len__()}    console=True
    [Return]    &{pci_freq_dict}


Install AP packge and wts
    [Documentation]    Install Airphone package and WTS esimmode.
    ...    Downloads AP package, backs up configs, runs yaft,
    ...    updates symlinks, restores configs, and installs WTS.
    [Arguments]    ${packagename}=${None}
    IF    '${packagename}' == '${None}'
        ${packagename}=    Get Latest Airphone Version
        Should Not Be Equal    ${packagename}    ${None}    Failed to get latest airphone package from WFT
        Log    Auto-detected latest airphone package: ${packagename}    console=True
    END
    ${ARTIFACTORY_BASE}=    Set Variable    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-airphone-ci-gen-local/Airphone/${packagename}
    ${zip_file}=    Set Variable    AirScale-${packagename}.zip
    ${date}=    Evaluate    __import__('datetime').datetime.now().strftime('%m%d_%H%M')
    ${backup_dir}=    Set Variable    /home/ute/AP/backup/${date}

    # Step 1: Download airphone package
    OperatingSystem.Run    rm -f /home/ute/AirScale-*.zip
    Log    Step 1: Downloading ${zip_file}...    console=True
    OperatingSystem.Run    wget -q -P /home/ute/ ${ARTIFACTORY_BASE}/${zip_file}
    ${exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    /home/ute/${zip_file}
    IF    not ${exists}
        ${log_msg}=    Set Variable    [ERROR] Download failed: /home/ute/${zip_file} does not exist. URL: ${ARTIFACTORY_BASE}/${zip_file}
        Log    ${log_msg}    console=True
        Fail    Download failed: /home/ute/${zip_file} does not exist
    END

    # Step 2: Backup existing files
    Log    Step 2: Backing up files to ${backup_dir}...    console=True
    OperatingSystem.Run    mkdir -p ${backup_dir}
    ${SSH_OPTS}=    Set Variable    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    OperatingSystem.Run    sshpass -p ${AP_PASSWORD} scp ${SSH_OPTS} ${AP_USER}@${AP_IP}:/ffs/run/simmode/iphy.xml ${backup_dir}/
    OperatingSystem.Run    sshpass -p ${AP_PASSWORD} scp ${SSH_OPTS} ${AP_USER}@${AP_IP}:/ffs/run/swconfig.txt ${backup_dir}/
    OperatingSystem.Run    cp /opt/iphy/latest/basic.cfg ${backup_dir}/
    OperatingSystem.Run    cp /opt/iphy/latest/killUTE ${backup_dir}/
    OperatingSystem.Run    cp /opt/iphy/latest/startUTE ${backup_dir}/
    OperatingSystem.File Should Exist    ${backup_dir}/iphy.xml
    OperatingSystem.File Should Exist    ${backup_dir}/swconfig.txt

    # Step 3: YAFT airphone
    Log    Step 3: Starting YAFT flashing...    console=True
    ${yaft_cmd}=    Catenate    SEPARATOR=${SPACE}
    ...    cd /home/ute/BTS_T_YAFT/ && echo ${AP_PASSWORD} |
    ...    python yaft.py -i ${AP_IP} -z /home/ute/${zip_file}
    ...    --ignore_slaves --fpga_update --clean_to_default --ask_for_password
    ${yaft_output}=    OperatingSystem.Run    ${yaft_cmd}
    Should Contain    ${yaft_output}    Flashing done    YAFT flashing failed!
    Log    YAFT flashing completed    console=True

    # Step 4: Create new directory and update symlink
    Log    Step 4: Updating /opt/iphy/latest symlink...    console=True
    OperatingSystem.Run    mkdir -p /opt/iphy/${packagename}
    OperatingSystem.Run    sudo rm -f /opt/iphy/latest
    OperatingSystem.Run    sudo ln -s /opt/iphy/${packagename} /opt/iphy/latest

    # Step 5: Upload config files back to airphone and restore local files
    Log    Step 5: Restoring config files...    console=True
    OperatingSystem.Run    ssh-keygen -f /home/ute/.ssh/known_hosts -R ${AP_IP}

    FOR    ${retry}    IN RANGE    1    4
        Log    Attempt ${retry}/3: Uploading config files to AP...    console=True
        OperatingSystem.Run    sshpass -p ${AP_PASSWORD} ssh ${SSH_OPTS} ${AP_USER}@${AP_IP} 'mkdir -p /ffs/run/simmode'
        OperatingSystem.Run    sshpass -p ${AP_PASSWORD} scp ${SSH_OPTS} ${backup_dir}/iphy.xml ${AP_USER}@${AP_IP}:/ffs/run/simmode/
        OperatingSystem.Run    sshpass -p ${AP_PASSWORD} scp ${SSH_OPTS} ${backup_dir}/swconfig.txt ${AP_USER}@${AP_IP}:/ffs/run/
        OperatingSystem.Run    sshpass -p ${AP_PASSWORD} ssh ${SSH_OPTS} ${AP_USER}@${AP_IP} 'crasign /ffs/run/swconfig.txt'
        ${remote_iphy}=    OperatingSystem.Run    sshpass -p ${AP_PASSWORD} ssh ${SSH_OPTS} ${AP_USER}@${AP_IP} 'cat /ffs/run/simmode/iphy.xml'
        ${contains_ahloa}=    Run Keyword And Return Status    Should Contain    ${remote_iphy}    <cardName>AHLOA</cardName>
        IF    ${contains_ahloa}
            Log    iphy.xml verification passed: <cardName>AHLOA</cardName> found on AP    console=True
            BREAK
        ELSE
            ${log_msg}=    Set Variable    [WARN] Attempt ${retry}/3: iphy.xml does NOT contain <cardName>AHLOA</cardName>, retrying...
            Log    ${log_msg}    console=True
        END
    END
    IF    not ${contains_ahloa}
        Fail    After 3 attempts, iphy.xml on AP still does not contain <cardName>AHLOA</cardName>
    END
    OperatingSystem.Run    sudo cp ${backup_dir}/basic.cfg /opt/iphy/latest/
    OperatingSystem.Run    sudo cp ${backup_dir}/killUTE /opt/iphy/latest/
    OperatingSystem.Run    sudo cp ${backup_dir}/startUTE /opt/iphy/latest/

    # Step 6: Download and extract WTS esimmode
    Log    Step 6: Installing WTS esimmode...    console=True
    OperatingSystem.Run    cd /opt/iphy/latest && sudo wget -r -np -nd -l1 -q -A 'esimmode_WTS_Esim*_sandybridge.tar.bz2' ${ARTIFACTORY_BASE}/
    ${esimmode_file}=    OperatingSystem.Run    ls /opt/iphy/latest/esimmode_WTS_Esim*_sandybridge.tar.bz2 2>/dev/null | head -1
    Should Not Be Empty    ${esimmode_file}    Could not find esimmode package in artifactory for ${packagename}
    OperatingSystem.Run    cd /opt/iphy/latest && sudo tar -jxvf ${esimmode_file}
    Log    AP package ${packagename} and WTS installed successfully    console=True

    OperatingSystem.Run    sudo cp ${backup_dir}/basic.cfg /opt/iphy/latest/
    OperatingSystem.Run    sudo cp ${backup_dir}/killUTE /opt/iphy/latest/
    OperatingSystem.Run    sudo cp ${backup_dir}/startUTE /opt/iphy/latest/


    # Step 7: IP Mapping
    Log    Step 7: Configuring IP mapping...    console=True
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
