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

Documentation  Set of keywords for feature CB012439 execution

*** Keywords ***
CB012439 Suite Setup
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

B_B2_A2 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    B_B2_A2 Setup Recommissioning
    Verify Bts Is Operational

CB012439_B_B2_A2_IntraFreq_A3A5_Reconfiguration_after_ProtectTimer_Expiry
    Check If There Is Time To Run TC
    B_B2_A2 Main Scenario
    Analyze B_B2_A2    ${LOGS}

B_B2_A2 Main Scenario
    Start Bts Log  btslog
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    10    30
    Sleep    25s
    QXDM.Stop Log Collecting
    ${first_tput_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}
    Set Global Variable    ${LOGS}    ${first_tput_logs}[0][0]
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    [Teardown]    taf.ue.Detach UE    UE_1

Analyze B_B2_A2
    [Arguments]    ${ue_logs}
    Analyze B_B2_A2 UE Logs    ${ue_logs}
    Analyze B_B2_A2 Syslogs    ${LOG_PATH}/${test_name}/btslog
    Verify B_B2_A2 Counters

Common Test Teardown
    Add Scout Scf Id To Test Data
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Passed  Find Suspicious Prints In Passed Test
    Make Snapshot In Case Of Error

B_B2_A2 Teardown
    Log To Console    A_B2_A2 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Set Attenuation    ${CELL_250}     90dB
    B_B2_A2 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

A_B10 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Start Bts Log  btslog
    Verify Bts Is Operational

CB012439_A_B10_Successful_reconfiguration_of_measurements_during_PDU_Session_Resource_Modification
    Check If There Is Time To Run TC
    A_B10 Scenario
    A_B10 Analysis

A_B10 Scenario
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    10    40
    Start Voice Call    VC    UE_1   0105     2s
    Sleep    20s
    QXDM.Stop Log Collecting
    ${ue_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}
    Set Global Variable    ${LOGS}    ${ue_logs}[0][0]
    [Teardown]    taf.ue.Detach UE    UE_1

A_B10 Analysis
    Log To Console   \nStarting Analysis of A_B10 Test Case
    Analyze A_B10 Logs    ${LOGS}
    Log To Console    Analysis passed, waiting for counter verification...
    Verify A_B10 Counters

A_B10 Teardown
    Log To Console    A_B10 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    Set Attenuation    ${CELL_250}     90dB
    Verify Bts Is Operational
    Common Test Teardown

C_B11 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    C_B11 Setup Recommissioning
    Start Bts Log  btslog
    Verify Bts Is Operational

CB012439_C_B11_Mobility_Profile_5QI_Criteria_Based_Measurement_Reconfiguration_After_A1_MR_Handling
    C_B11 Scenario
    Analyze C_B11 Logs   ${LOGS}

C_B11 Teardown
    Log To Console    C_B11 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    Set Attenuation    ${CELL_250}     90dB
    C_B11 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

C_B11 Scenario
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    30    15
    Sleep    4s
    Set Attenuation    ${CELL_250}     10dB
    Sleep    5s
    QXDM.Stop Log Collecting
    ${ue_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}
    Set Global Variable    ${LOGS}    ${ue_logs}[0][0]
    [Teardown]    taf.ue.Detach UE    UE_1

############# Recommissionings #############
B_B2_A2 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50825/NRBTS-50825    measProfProtectTimer=15
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

B_B2_A2 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50825/NRBTS-50825    measProfProtectTimer=0
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

C_B11 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50825/NRBTS-50825    actMeasProfileCa=deactivated
    ...    actMeasurementProfile=deactivated    actMeasurementProfReselForCA=deactivated
    ...    actCAMeasInMeasProf=deactivated
    Add Parameters To Delta       MRBTS-50825/NRBTS-50825/NRCELL-250/NRHOIF-1    a4MeasSCellAddEnabled=none    a4MeasHigherPrioFreqEnabled=none
    Add Parameters To Delta       MRBTS-50825/NRBTS-50825/NRCELL-250/NRHOIF-2    a4MeasSCellAddEnabled=none    a4MeasHigherPrioFreqEnabled=none
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

C_B11 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50825/NRBTS-50825    actMeasProfileCa=SA    actMeasurementProfile=SA
    ...        actMeasurementProfReselForCA=pcInSaUlAndDlCaSupported    actCAMeasInMeasProf=SA
    Add Parameters To Delta       MRBTS-50825/NRBTS-50825/NRCELL-250/NRHOIF-1    a4MeasSCellAddEnabled=rsrp    a4MeasHigherPrioFreqEnabled=rsrp
    Add Parameters To Delta       MRBTS-50825/NRBTS-50825/NRCELL-250/NRHOIF-2    a4MeasSCellAddEnabled=rsrp    a4MeasHigherPrioFreqEnabled=rsrp
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb
