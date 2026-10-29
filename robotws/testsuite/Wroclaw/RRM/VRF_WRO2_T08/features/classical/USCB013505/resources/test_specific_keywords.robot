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
Library     testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/qualcomm/qpm_lk.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

Documentation  Set of keywords for feature USCB013505 execution

*** Keywords ***
USCB013505 Suite Setup
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
    ${cell_list}=   Create list    ${CELL_250}    ${CELL_252}    ${CELL_253}    ${CELL_254}
    Set Global Variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${GNB_CELLS}
    FOR    ${cell}    IN    ${cell_list}
      Set Attenuation    ${cell}    90dB
    END
    Sleep  2s

Attach Ue And Start Ping
    [Arguments]    ${attenuation}    ${ping_time}=180    ${cell}=${CELL_250}
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

TC01_USCB013505_SR_A_B1_EPIC_Feature_Activation
    ${ue_logs_disabled}    ${ue_logs_enabled}=    A_B1 Main Scenario
    Analyze A_B1    ${ue_logs_disabled}    ${ue_logs_enabled}

A_B1 Main Scenario
    ${ue_logs_disabled}=    Run Downlink Throughput    disabled
    Feature Enabling Recommissioning    true
    Sleep    20s
    ${ue_logs_enabled}=    Run Downlink Throughput    enabled
    RETURN    ${ue_logs_disabled}    ${ue_logs_enabled}

Run Downlink Throughput
    [Arguments]    ${feature_status}    ${attenuation}=6    ${tput_time_seconds}=130
    Set Attenuation   ${CELL_250}   ${attenuation}db
    taf.ue.Attach UE    UE_1
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     apn=n26wro
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=${tput_time_seconds}s
        ...     throughput=420Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    QXDM.Start Log Collecting
    ${sleep_time}=    Evaluate    ${tput_time_seconds} - 10
    Sleep    ${sleep_time}s
    QXDM.Stop Log Collecting
    ${tput_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_feature_${feature_status}
    [Teardown]    Run Keywords    taf.ue.Stop Data Transfer    dt_name=DT_DL    AND    taf.ue.Detach UE    UE_1
    RETURN    ${tput_logs}[0][0]

Analyze A_B1
    [Arguments]    ${ue_logs_disabled}    ${ue_logs_enabled}
    Log To Console  \nAnalyzing logs for A_B1 scenario...
    Log To Console  \nFeature Disabled Results:
    ${tput_disabled}    ${avg_mcs_disabled}    ${avg_rb_disabled}=    Analyze Throughput logs    ${ue_logs_disabled}
    Log To Console  \nFeature Enabled Results:
    ${tput_enabled}     ${avg_mcs_enabled}     ${avg_rb_enabled}=    Analyze Throughput logs    ${ue_logs_enabled}
    Compare A_B1 Results    ${tput_disabled}    ${avg_mcs_disabled}    ${avg_rb_disabled}
    ...                     ${tput_enabled}     ${avg_mcs_enabled}     ${avg_rb_enabled}

Common Test Teardown
    Log To Console    Test Teardown
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    Set Attenuation    ${CELL_250}     90dB
    Verify Bts Is Operational
    Add Scout Scf Id To Test Data
    WATCHDOG.Stop Watching Alarms
    Feature Enabling Recommissioning    false
    Run Keyword If Test Passed  Find Suspicious Prints In Passed Test
    Make Snapshot In Case Of Error

B_B1 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Feature Enabling Recommissioning    true    21
    Verify Bts Is Operational
    Wait Until Counter Collection Time
    Start Bts Log  btslog

TC04_USCB013505_SR_B_B1_EPIC_MCS_Threshold
    ${ue_logs}=    Run Downlink Throughput    enabled   40    250
    Analyze B_B1    ${ue_logs}

Analyze B_B1
    [Arguments]    ${ue_logs}
    Check Mcs    ${ue_logs}
    Verify B_B1 Counters

Feature Enabling Recommissioning
    [Arguments]    ${feature_status}    ${mcs_threshold}=5
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-50825/NRBTS-50825/NRCELL-250    list_name=eirpControl
    ...    actEpic=${feature_status}    epicMcsThreshold=${mcs_threshold}    minGuaranteedBudgetRatio=1
    ...    minGuaranteedBudgetRatioMode=actualEirpBudgetRatio    minSignificantNormalizedBeamGain=-20
    ...    numOfSegmentAzimuthEdges=4    numOfSegmentElevationEdges=2    schedulWeightFactorEnabled=true
    ...    segmentAzimuthEdge0=-35    segmentAzimuthEdge1=-10    segmentAzimuthEdge2=10
    ...    segmentAzimuthEdge3=35    segmentElevationEdge0=10    segmentElevationEdge1=0    smoothingEffect=medium
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb
