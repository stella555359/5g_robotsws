*** Settings ***
Library     OperatingSystem
Library     ta_attenuator
Library     taf.ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf.admin
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.qxdm_log_collector.QxdmLogCollector  WITH NAME  QXDM
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.bts_utils
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaStore.py
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     DateTime
Library     testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/qualcomm/qpm_lk.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

Documentation  Set of keywords for feature CB011147 execution

*** Keywords ***
CB011147 Suite Setup
    Testsuite Setup Recommissioning
    Wait Until Keyword Succeeds   2x   10sec   Get QXDM License
    Wait Until Keyword Succeeds   2x   10sec   QXDM.Setup
    QXDM.Set Logging Filter   C:/auto/sebkowa.dmc
    Prepare Ue
    Set Initial Attenuation


Get QXDM License
    Get 5g QXDM And Qcat License
    ...  username=tomasz.sobania@nokia.com
    ...  password=Tsob123,.
    ...  ue_id=${0}

Prepare Ue
    taf.ue.Require UE    UE_1    capabilities=REAL_ANDROID_UE
    taf.ue.Detach UE     UE_1
    Sleep    5s

Attach And Return Ip
    [Arguments]    ${attenuation}    ${cell}
    Set Attenuation   ${cell}   ${attenuation}db
    @{args}=    Create List     IP
    taf.ue.Attach UE    UE_1
    ${ip}=    taf.ue.Get Ue Info    UE_1     infos_list=@{args}
    Log to Console    \nUE Attached!
    RETURN    ${ip}

Set Initial Attenuation
    ${cell_list}=   Create list    ${CELL_190}    ${CELL_196}    ${CELL_193}    ${CELL_197}    ${CELL_999}
    Set Global Variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${GNB_CELLS}
    FOR    ${cell}    IN    ${cell_list}
      Set Attenuation    ${cell}    90dB
    END
    Sleep  2s

Change Attenuation Gradually
    [Arguments]    ${cell}    ${starting_attenuation}    ${target_attenuation}    ${step}
    FOR    ${attenuation}    IN RANGE    ${starting_attenuation}    ${target_attenuation}    ${step}
        Set Attenuation    ${cell}     ${attenuation}dB
    END

Attach Ue And Start Ping
    [Arguments]    ${attenuation}    ${ping_time}=180    ${cell}=${CELL_190}
    Set Attenuation   ${cell}   ${attenuation}db
    @{args}=    Create List     IP
    taf.ue.Attach UE    UE_1
    ${ip}=    taf.ue.Get Ue Info    UE_1     infos_list=@{args}
    ${appserver}=    ssh.Connect To    hostname=10.45.168.53    username=5g    password=2019H@slo
    Set Global Variable  ${APPSERVER}  ${appserver}
    ssh.Send Command    command=ping -w${ping_time} ${ip}    connection=${APPSERVER}
    RETURN    ${ip}


Unblock Cells After TC
    [Arguments]    @{cells}
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    FOR    ${cell}    IN    @{cells}
        taf.admin.Unblock Cell  dist_name=MRBTS-50819/${cell}    connection=${admin_alias}
    END
    [Teardown]    taf.admin.Teardown Admin    alias=${admin_alias}

Block Cells Before TC
    [Arguments]    @{cells}
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    FOR    ${cell}    IN    @{cells}
        taf.admin.Block Cell  dist_name=MRBTS-50819/${cell}    connection=${admin_alias}
    END
    [Teardown]    taf.admin.Teardown Admin    alias=${admin_alias}

Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Wait For Nr Cells On Air
    WATCHDOG.Check Detected Alarms

A_B1 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Verify Bts Is Operational
    Start Bts Log  btslog

007_CB011147_A_B1_ALT6_Activation_of_A4_Inter_freq_measurements_after_RRCResume_procedure
    Log To Console    \nStep 1: UE attach
    Start Tcpdump On CU    filename=${test_name}_step01_attach.pcap
    QXDM.Start Log Collecting
    ${ip}=    Attach And Return Ip    attenuation=0    cell=${CELL_190}
    Sleep    30s    reason=wait for inactive timer
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step01_attach.pcap
    ${step01_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step01_attach
    Analyze Ab1 Testcase Phase 1    ${step01_uelog}[0][0]
    Log To Console    \nStep 2: Ping UE to wake it from inactive state
    Start Tcpdump On CU    filename=${test_name}_step02_wake_from_inactive.pcap
    QXDM.Start Log Collecting
    ${appserver}=    ssh.Connect To    hostname=10.45.168.53    username=5g    password=2019H@slo
    Set Global Variable  ${APPSERVER}  ${appserver}
    ssh.Send Command    command=ping -w60 ${ip}    connection=${APPSERVER}
    Sleep    90s    reason=gather some rrcreconfigs
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step02_wake_from_inactive.pcap
    ${step02_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step02_wake_from_inactive
    Analyze Ab1 Testcase Phase 2    ${step02_uelog}[0][0]
    [Teardown]    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1

Common Test Teardown
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    Add Scout Scf Id To Test Data
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Passed  Find Suspicious Prints In Passed Test
    Make Snapshot In Case Of Error

A_B1 Teardown
    Log To Console    A_B1 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Set Attenuation    ${CELL_190}     90dB
    Verify Bts Is Operational
    Common Test Teardown

A_IWK1 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_IWK1 Setup Recommissioning
    Verify Bts Is Operational
    Start Bts Log  btslog

041_CB011147_A_IWK1_A4_measurements_are_activated_after_a4Retrytimer_expiry_with_A1_based_traffic_steering
    Log To Console    \nStep 1: UE attach and a1 steering trigger during retryTimer
    Start Tcpdump On CU    filename=${test_name}_step01_attach_a1_steering_during_retry.pcap
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    35    ping_time=70
    Sleep    10s
    Set Attenuation    ${CELL_190}     0dB
    Sleep    23s
    Set Attenuation    ${CELL_190}     23dB
    Sleep    1s
    Set Attenuation    ${CELL_190}     0dB
    Sleep    60s
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step01_attach_a1_steering_during_retry.pcap
    ${step01_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step01_attach_a1_steering_during_retry
    taf.ue.Detach UE    UE_1
    Analyze Iwk1 Testcase Step 1    ${step01_uelog}[0][0]
    Sleep    5s
    Log To Console    \nStep 2: UE attach and a1 steering trigger during supervisionTimer
    Start Tcpdump On CU    filename=${test_name}_step02_attach_a1_steering_during_supervision.pcap
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    30    ping_time=80
    Sleep    1s
    Set Attenuation    ${CELL_190}     0dB
    Sleep    80s
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step02_attach_a1_steering_during_supervision.pcap
    ${step02_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step02_attach_a1_steering_during_supervision
    Analyze Iwk1 Testcase Step 2    ${step02_uelog}[0][0]
    [Teardown]    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1

A_IWK1 Teardown
    Log To Console    A_IWK1 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Set Attenuation    ${CELL_190}     90dB
    A_IWK1 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_IWK7 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_IWK7 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194
    Start Bts Log  btslog

054_CB011147_A_IWK7_A2_measurement_report_for_mobility_to_trigger_inter-freq_A3_A5_configuration_while_a4SupervisionTimer_is_running
    Log To Console    \nStep 1: UE attach and a2 trigger during retryTimer
    Start Tcpdump On CU    filename=${test_name}_step01_attach_a2_during_retry.pcap
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    0
    Sleep    9s
    Set Attenuation    ${CELL_190}     40dB
    Sleep    14s
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step01_attach_a2_during_retry.pcap
    ${step01_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step01_attach_a2_during_retry

    Log To Console    \nStep 2: Trigger A1 and then A2 during supervision timer
    Start Tcpdump On CU    filename=${test_name}_step02_a1_a2_during_supervision.pcap
    QXDM.Start Log Collecting
    Set Attenuation    ${CELL_190}     0dB
    Sleep    6s
    Set Attenuation    ${CELL_190}     40dB
    Sleep    20s
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step02_a1_a2_during_supervision.pcap
    ${step02_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step02_a1_a2_during_supervision

    Log To Console    \nStep 3: Handover to cell 193
    Start Tcpdump On CU    filename=${test_name}_step03_193_HO.pcap
    QXDM.Start Log Collecting
    Set Attenuation    ${CELL_193}     0dB
    Change Attenuation Gradually    ${CELL_190}    40   60    2
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step03_193_HO.pcap
    ${step03_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step03_193_HO

    Analyze Iwk7 Testcase Step 1    ${step01_uelog}[0][0]
    Analyze Iwk7 Testcase Step 2    ${step02_uelog}[0][0]
    Analyze Iwk7 Testcase Step 3    ${LOG_PATH}/${test_name}_step03_193_HO.pcap
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...           Unblock Cells After TC    NRBTS-50819/NRCELL-194

A_IWK7 Teardown
    Log To Console    A_IWK7 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    A_IWK7 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_B3 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_B3_B9 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    Start Bts Log  btslog

CB011147_A_B3_ALT2_Handling_of_a4RetryTimer_expiry_A4_inter-freq_meas_for_mobility_to_higher_prio_NR_activated
    Log To Console    Step 01: attach and 3CC CA
    QXDM.Start Log Collecting
    Attach And Return Ip    attenuation=0    cell=${CELL_190}
    ${attach_time}=    test_specific_keywords.Get Time
    Set Attenuation    ${CELL_193}     0dB
    Set Attenuation    ${CELL_196}     0dB
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=180s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    24s
    QXDM.Stop Log Collecting
    ${step01_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step01_attach_3cc_ca
    Log To Console    Step 02: scell removals
    Wait Certain Time After Attach    ${attach_time}    65
    QXDM.Start Log Collecting
    Log To Console    removing Cell 193 from CA
    Set Attenuation    ${CELL_193}     60dB
    Sleep    20s
    Log To Console    removing Cell 196 from CA
    Set Attenuation    ${CELL_196}     60dB
    Sleep    30s
    QXDM.Stop Log Collecting
    ${step02_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step02_scell_removals
    Log To Console    Analyzing logs...
    Analyze A_B3 Testcase Step 01    ${step01_uelog}[0][0]
    Analyze A_B3 Testcase Step 02    ${step02_uelog}[0][0]
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...           Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195

A_B3 Teardown
    Log To Console    A_B3 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    A_B3_B9 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_B9 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_B3_B9 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    Start Bts Log  btslog

057_CB011147_A_B9_Last_Scell_release_leading_to_reactivation_of_A4_Inter_frequency_measurements_for_Scell_addition
    QXDM.Start Log Collecting
    Attach And Return Ip    attenuation=0    cell=${CELL_190}
    Set Attenuation    ${CELL_193}     0dB
    Set Attenuation    ${CELL_196}     0dB
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=90s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    8s
    Log To Console    removing Cell 193 from CA
    Set Attenuation    ${CELL_193}     60dB
    Sleep    12s
    Log To Console    removing Cell 196 from CA
    Set Attenuation    ${CELL_196}     60dB
    Sleep    60s
    QXDM.Stop Log Collecting
    ${step02_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_ue_logs

    Analyze A_B9 Testcase    ${step02_uelog}[0][0]
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...           Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195

A_B9 Teardown
    Log To Console    A_B9 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    A_B3_B9 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_B2 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_B2 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194
    Start Bts Log  btslog

020_CB011147_A_B2_ALT2_a4RetryTimer_expiry_with_activation_of_RSRP_and_RSRQ
    Log To Console    Step01: Attach and 2CC CA
    QXDM.Start Log Collecting
    Attach And Return Ip    attenuation=0    cell=${CELL_190}
    ${attach_time}=    test_specific_keywords.Get Time
    Set Attenuation    ${CELL_193}     0dB
    Sleep    5s
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=150s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    25s
    QXDM.Stop Log Collecting
    ${step01_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step01
    Wait Certain Time After Attach    ${attach_time}    70
    Log To Console    Step02: Remove 193 from CA
    QXDM.Start Log Collecting
    Set Attenuation    ${CELL_193}     90dB
    Sleep    70s
    QXDM.Stop Log Collecting
    ${step02_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step02
    Log To Console    Analyzing logs...
    Analyze A_B2 Testcase Step 01    ${step01_uelog}[0][0]
    Analyze A_B2 Testcase Step 02    ${step02_uelog}[0][0]
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...           Unblock Cells After TC    NRBTS-50819/NRCELL-194

A_B2 Teardown
    Log To Console    A_B2 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    A_B2 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_EC2 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_EC2 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-99    NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999
    Start Bts Log  btslog

CB011147_A_EC2_ALT2_No_A4_config_at_a4RetryTimer_expiry_a4MeasActBlockTimer_is_running_at_a4RetryTimer_expiry
    QXDM.Start Log Collecting
    Start Tcpdump On CU    filename=${test_name}_A_EC2.pcap
    Set Attenuation    ${CELL_190}     0dB
    taf.ue.Attach UE    UE_1
    ${attach_time}=    test_specific_keywords.Get Time
    Set Attenuation    ${CELL_193}     0dB
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=300s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Wait Certain Time After Attach    ${attach_time}    50
    Set Attenuation    ${CELL_193}     90dB
    Sleep    150s
    QXDM.Stop Log Collecting
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_A_EC2.pcap
    ${a_ec2_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_ue_log
    Log To Console    Analyzing logs...
    Analyze A_EC2 Testcase    ${a_ec2_uelog}[0][0]
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...     Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-99    NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999

A_EC2 Teardown
    Log To Console    A_EC2 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    A_EC2 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_IWK3 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_IWK3 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    Start Bts Log  btslog

050_CB011147_A_IWK3_Mixing_A1-based_and_A4-based_SCell_Candidates_for_FR1_CA_SCell_Addition
    Log To Console    A_IWK3 phase 1 starting
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    38    60
    Sleep    4s
    Set Attenuation    ${CELL_193}     0dB
    Set Attenuation    ${CELL_196}     0dB
    Set Attenuation    ${CELL_190}     0dB
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=80s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    70s
    QXDM.Stop Log Collecting
    ${a_iwk3_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_a_iwk3_phase1_ue_log
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    taf.ue.Detach UE    UE_1
    Analyze Iwk3 Testcase Phase 1    ${a_iwk3_uelog}[0][0]

    Log To Console    Phase 2 recommissioning ongoing...
    A_IWK3 Phase 2 Recommissioning
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Set Attenuation    ${CELL_190}     90dB
    Sleep    10s

    Log To Console    A_IWK3 phase 2 starting - with steering
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    38    60
    Sleep  6s
    Set Attenuation    ${CELL_193}     0dB
    Set Attenuation    ${CELL_196}     0dB
    Set Attenuation    ${CELL_190}     16dB
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=180s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    30s
    Set Attenuation    ${CELL_190}     0dB
    Sleep    95s
    QXDM.Stop Log Collecting
    ${a_iwk3_p2_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_a_iwk3_phase2_ue_log
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    Analyze Iwk3 Testcase Phase 2    ${a_iwk3_p2_uelog}[0][0]
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...           Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195

A_IWK3 Teardown
    Log To Console    A_IWK3 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    A_IWK3 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

######    RECOMMISSIONINGS    ######

Testsuite Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    actHigherPrioFreqHoForCA=SA    drbRrcInactInactivityTimerSA=20
    ...      drbInactivityTimerSA=20    srbInactivityTimerSA=20    rrcInactPreferredStateEnabled=true    actDrbDrx=true
    ...      actHigherPrioFreqHo=SA    actRrcInactState=intra-gNB    rrcInactIMMSteeringEnabled=true   maxUeRrcInactTime=15
    ...      rrcInactLocationReportEnabled=false    tRanPagingGuard=4    actIdleMMSteering=true
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=5000    a4RetryTimer=5
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=5   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99    idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190   actCDrx=true    idleMMSteeringWRREnabledSec=DL CA aware
    ...                      voNRNrDrxDN=MRBTS-50819/NRBTS-50819/NRDRX-2    a2MeashoEnabledSA=rsrp
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringPercentageOfUes=100    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999   idleMMSteeringWRREnabledSec=DL CA aware
    ...                      idleMMSteeringAlgo=non CA aware    idleMMSteeringWRREnabled=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRPLMNSET_SA-1    ranAC=1

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrp

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasHigherPrioFreqEnabled=rsrp
    ...                      a4PriorityForHigherPrioFreqHo=1
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1
    ...               list_name=a4MeasSsbRsrp    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=34    a4TimeToTriggerSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSCellAddSsbRsrp
    ...    a4HysteresisSCellAddSsbRsrp=0    a4ThresholdSCellAddSsbRsrp=60    a4TimeToTriggerSCellAddSsbRsrp=ms40
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasHigherPrioFreqEnabled=rsrp
    ...                      a4PriorityForHigherPrioFreqHo=2
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3
    ...               list_name=a4MeasSsbRsrp    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=35    a4TimeToTriggerSsbRsrp=ms40
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasHigherPrioFreqEnabled=rsrp
    ...                      a4PriorityForHigherPrioFreqHo=3
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4
    ...               list_name=a4MeasSsbRsrp    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=36    a4TimeToTriggerSsbRsrp=ms40
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasHigherPrioFreqEnabled=rsrp
    ...                      a4PriorityForHigherPrioFreqHo=4
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5
    ...               list_name=a4MeasSsbRsrp    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=37    a4TimeToTriggerSsbRsrp=ms40
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrp
    ...                      a4PriorityForHigherPrioFreqHo=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12
    ...               list_name=a4MeasSsbRsrp    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=38    a4TimeToTriggerSsbRsrp=ms40


    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

Testsuite Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    drbInactivityTimerSA=1000    srbInactivityTimerSA=500    actDrbDrx=false
    ...    actHigherPrioFreqHo=none    actRrcInactState=none    rrcInactIMMSteeringEnabled=true    actIdleMMSteering=false
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=actHigherPrioFreqHoForCA
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=rrcInactPreferredStateEnabled
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=rrcInactIMMSteeringEnabled
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=maxUeRrcInactTime
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=drbRrcInactInactivityTimerSA
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=rrcInactLocationReportEnabled
    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819    param_name=tRanPagingGuard
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=3
    ...               a4MeasActBlockTimer=0  a4MeasMaxNumber=0   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=10000    a4RetryTimer=3
    ...               a4MeasActBlockTimer=0  a4MeasMaxNumber=0   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=10000    a4RetryTimer=3
    ...               a4MeasActBlockTimer=0  a4MeasMaxNumber=0   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=10000    a4RetryTimer=3
    ...               a4MeasActBlockTimer=0  a4MeasMaxNumber=0   a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5

    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99    param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199   param_name=idleMMSteeringWRREnabledSec
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999   param_name=idleMMSteeringWRREnabledSec

    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197   param_name=idleMMSteeringAlgo
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198   param_name=idleMMSteeringAlgo

    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197   param_name=idleMMSteeringPercentageOfUes
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198   param_name=idleMMSteeringPercentageOfUes

    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197   param_name=idleMMSteeringWRREnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198   param_name=idleMMSteeringWRREnabled
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99    idleMMSteeringWRREnabled=false
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199   idleMMSteeringWRREnabled=false
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999   idleMMSteeringWRREnabled=false

    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    param_name=a4PeriodicMeasControlSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199    param_name=a4PeriodicMeasControlSA
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasHigherPrioFreqEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4MeasSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4PriorityForHigherPrioFreqHo

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    actCDrx=false
    ...                      voNRNrDrxDN=MRBTS-50819/NRBTS-50819/NRDRX-0    a2MeashoEnabledSA=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasSCellAddEnabled=rsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrpCombined
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrqCombined

    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasHigherPrioFreqEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    param_name=a4MeasSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    param_name=a4PriorityForHigherPrioFreqHo
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasHigherPrioFreqEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    param_name=a4MeasSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    param_name=a4PriorityForHigherPrioFreqHo
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasHigherPrioFreqEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    param_name=a4MeasSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    param_name=a4PriorityForHigherPrioFreqHo
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasHigherPrioFreqEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   param_name=a4MeasSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   param_name=a4PriorityForHigherPrioFreqHo
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   list_name=a4MeasSCellAddSsbRsrp
    ...               a4ThresholdSCellAddSsbRsrp=55    a4HysteresisSCellAddSsbRsrp=0    a4TimeToTriggerSCellAddSsbRsrp=ms40

    Add Param Delete To Delta    dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRPLMNSET_SA-1    param_name=ranAC

    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK1 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actA1HoPrefNRLayer=SA+NSA    actHigherPrioFreqHo=SA+NSA
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    a1MeashoPrefNRLayerEnabledSA=rsrp
    ...    a4MeasHigherPrioFreqMaxReactSA=0    reportAmountHoPrefNRLayerSA=r1
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999    list_name=a4PeriodicMeasControlNSA
    ...    a4Fr1SupervisionTimer=4000    a4Fr2SupervisionTimer=6000    a4RetryTimer=10    a4MeasMaxNumber=5
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeashoPrefNRLayerSsbRsrpSA
    ...    a1HysteresisSsbRsrp=0    a1ThresholdhoSsbRsrp=66    a1TimeToTriggerhoSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a2MeasRedirectSsbRsrp    a2ThresholdRedirectSsbRsrp=34
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a2MeashoSsbRsrpSA    a2ThresholdhoSsbRsrpSA=36
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a4PeriodicMeasControlSA    a4Fr1SupervisionTimer=10000    a4RetryTimer=20

    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK1 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actA1HoPrefNRLayer=none    actHigherPrioFreqHo=SA
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    cellDepType=SA+NSA    reportAmountHoPrefNRLayerSA=r2
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=a4MeasHigherPrioFreqMaxReactSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-99    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-199    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999    param_name=a4PeriodicMeasControlNSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=a1MeashoPrefNRLayerSsbRsrpSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=a1MeashoPrefNRLayerEnabledSA
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a2MeasRedirectSsbRsrp    a2ThresholdRedirectSsbRsrp=47
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a2MeashoSsbRsrpSA    a2ThresholdhoSsbRsrpSA=49
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a4PeriodicMeasControlSA    a4Fr1SupervisionTimer=5000    a4RetryTimer=5

    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK7 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a2MeashoSsbRsrpSA    a2ThresholdhoSsbRsrpSA=56
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a4PeriodicMeasControlSA    a4Fr1SupervisionTimer=10000    a4RetryTimer=10

    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK7 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a2MeashoSsbRsrpSA    a2ThresholdhoSsbRsrpSA=49
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    list_name=a4PeriodicMeasControlSA    a4Fr1SupervisionTimer=5000    a4RetryTimer=5

    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_B3_B9 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4ThresholdSsbRsrp=127
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    list_name=a4MeasSsbRsrp
    ...    a4ThresholdSsbRsrp=127
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=196
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    a2MeasSCellRelEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    a2MeasSCellRelEnabled=rsrp
    Add List Parameters To Delta    dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=a2MeasSCellRelSsbRsrp
    ...    a2HysteresisSCellRelSsbRsrp=0    a2ThresholdSCellRelSsbRsrp=34    a2TimeToTriggerSCellRelSsbRsrp=320ms
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_B3_B9 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSCellAddSsbRsrp
    ...    a4ThresholdSCellAddSsbRsrp=34
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    list_name=a4MeasSCellAddSsbRsrp
    ...    a4ThresholdSCellAddSsbRsrp=38
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    a2MeasSCellRelEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a2MeasSCellRelEnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a2MeasSCellRelSsbRsrp
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb


A_B2 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSCellAddSsbRsrq
    ...    a4HysteresisSCellAddSsbRsrq=0    a4ThresholdSCellAddSsbRsrq=49    a4TimeToTriggerSCellAddSsbRsrq=ms40
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    a2MeasSCellRelEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=a2MeasSCellRelSsbRsrp
    ...    a2HysteresisSCellRelSsbRsrp=0    a2ThresholdSCellRelSsbRsrp=34    a2TimeToTriggerSCellRelSsbRsrp=2560ms

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=127    a4TimeToTriggerSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=127    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_B2 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4MeasSCellAddSsbRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    a2MeasSCellRelEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a2MeasSCellRelSsbRsrp

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=34    a4TimeToTriggerSsbRsrp=ms40
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    param_name=a4MeasSsbRsrq
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_EC2 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=196
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSCellAddSsbRsrq
    ...    a4HysteresisSCellAddSsbRsrq=0    a4ThresholdSCellAddSsbRsrq=49    a4TimeToTriggerSCellAddSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a4PeriodicMeasControlSA
    ...    a4Fr1SupervisionTimer=5000    a4Fr2SupervisionTimer=6000    a4MeasActBlockTimer=120    a4MeasMaxNumber=5
    ...    a4RetryTimer=5    a4RetryTimerMultCa=5
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    a2MeasSCellRelEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=a2MeasSCellRelSsbRsrp
    ...    a2HysteresisSCellRelSsbRsrp=0    a2ThresholdSCellRelSsbRsrp=34    a2TimeToTriggerSCellRelSsbRsrp=2560ms

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=127    a4TimeToTriggerSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=127    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    list_name=a4MeasSsbRsrq
    ...    a4HysteresisSsbRsrq=0    a4ThresholdSsbRsrq=49    a4TimeToTriggerSsbRsrq=ms40
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_EC2 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4MeasSCellAddSsbRsrq
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a4PeriodicMeasControlSA
    ...    a4Fr1SupervisionTimer=5000    a4Fr2SupervisionTimer=6000    a4MeasActBlockTimer=0    a4MeasMaxNumber=5
    ...    a4RetryTimer=5    a4RetryTimerMultCa=5
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    a2MeasSCellRelEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a2MeasSCellRelSsbRsrp

    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4HysteresisSsbRsrp=0    a4ThresholdSsbRsrp=34    a4TimeToTriggerSsbRsrp=ms40
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    param_name=a4MeasSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    param_name=a4MeasSsbRsrq
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK3 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based    A1-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4ThresholdSsbRsrp=127          a4HysteresisSsbRsrp=0               a4TimeToTriggerSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    list_name=a4MeasSsbRsrp
    ...    a4ThresholdSsbRsrp=127          a4HysteresisSsbRsrp=0               a4TimeToTriggerSsbRsrp=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a3MeasEnabled=none    a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=none
    ...                           a3MeasEnabled=none    a5MeasEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=196    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...    dlSCellConfigLevel=20    a1MeashoPrefNRLayerEnabledSA=rsrp    a4MeasHigherPrioFreqMaxReactSA=10
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1ThresholdSCellAddSsbRsrpFDD=57
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeashoSsbRsrpSA
    ...    a1ThresholdhoSsbRsrpSA=53
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeashoPrefNRLayerSsbRsrpSA
    ...    a1HysteresisSsbRsrp=0    a1ThresholdhoSsbRsrp=74    a1TimeToTriggerhoSsbRsrp=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    a2MeasSCellRelEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    a2MeasSCellRelEnabled=rsrp
    Add List Parameters To Delta    dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=a2MeasSCellRelSsbRsrp
    ...    a2HysteresisSCellRelSsbRsrp=0    a2ThresholdSCellRelSsbRsrp=34    a2TimeToTriggerSCellRelSsbRsrp=320ms
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a4PeriodicMeasControlSA
    ...    a4Fr1SupervisionTimer=10000    a4Fr2SupervisionTimer=6000    a4MeasActBlockTimer=0    a4MeasMaxNumber=5
    ...    a4RetryTimer=2    a4RetryTimerMultCa=5
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK3 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}    actA1HoPrefNRLayer=none
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    list_name=a4MeasSsbRsrp
    ...    a4ThresholdSsbRsrp=60          a4HysteresisSsbRsrp=0               a4TimeToTriggerSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    list_name=a4MeasSsbRsrp
    ...    a4ThresholdSsbRsrp=55          a4HysteresisSsbRsrp=0               a4TimeToTriggerSsbRsrp=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a3MeasEnabled=rsrp    a5MeasEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasHigherPrioFreqEnabled=rsrp
    ...                           a3MeasEnabled=rsrp    a5MeasEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...                           dlSCellConfigLevel=20    a1MeashoPrefNRLayerEnabledSA=none
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1ThresholdSCellAddSsbRsrpFDD=44
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeashoSsbRsrpSA
    ...    a1ThresholdhoSsbRsrpSA=57
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=a1MeashoPrefNRLayerSsbRsrpSA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=a4MeasHigherPrioFreqMaxReactSA
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    a2MeasSCellRelEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a2MeasSCellRelEnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a2MeasSCellRelSsbRsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a4PeriodicMeasControlSA
    ...    a4Fr1SupervisionTimer=5000    a4Fr2SupervisionTimer=6000    a4MeasActBlockTimer=0    a4MeasMaxNumber=5
    ...    a4RetryTimer=5    a4RetryTimerMultCa=5
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_IWK3 Phase 2 Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actA1HoPrefNRLayer=SA
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb
