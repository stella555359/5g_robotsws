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

Documentation  Set of keywords for feature CB014045 execution

*** Variables ***
@{B_B1_ATTENUATIONS}    34  44  54
@{A_B4_ATTENUATIONS}    29  34  39  44  48  54  58  63  68  72

*** Keywords ***
CB014045 Suite Setup
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
    ${cell_list}=   Create list    ${CELL_291}    ${CELL_292}    ${CELL_293}    ${CELL_295_298}    ${CELL_294_297}    ${CELL_296_299}
    Set Global Variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${GNB_CELLS}
    FOR    ${cell}    IN    ${cell_list}
      Set Attenuation    ${cell}    90dB
    END
    Sleep  2s

Attach Ue And Start Ping
    [Arguments]    ${attenuation}    ${ping_time}=180    ${cell}=${CELL_291}
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

B_B1 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Verify Bts Is Operational


CB014045-B_B1_ALT3_UE_Full_buffer_throughput_verification_FDD_SA
    @{tputs_disabled}=    Check Throughputs    dl  350    @{B_B1_ATTENUATIONS}
    Start Bts Log  btslog
    Log To Console    \nEnabling CB014045 feature on Cell 291
    B_B1 Feature Recommissioning    DL
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    @{tputs_enabled}=    Check Throughputs    dl    350    @{B_B1_ATTENUATIONS}
    Confirm Feature Not Affecting Throughputs    ${tputs_disabled}[0]  ${tputs_disabled}[1]  ${tputs_disabled}[2]
    ...                                          ${tputs_enabled}[0]   ${tputs_enabled}[1]   ${tputs_enabled}[2]
    Check For Syslog Print During Feature Activation    ${LOG_PATH}/${test_name}/btslog
    [Teardown]    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1

Common Test Teardown
    Add Scout Scf Id To Test Data
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Passed  Find Suspicious Prints In Passed Test
    Make Snapshot In Case Of Error

B_B1 Teardown
    Log To Console    B_B1 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Set Attenuation    ${CELL_291}     90dB
    B_B1 Feature Recommissioning    disabled
    Verify Bts Is Operational
    Common Test Teardown

Check Throughputs
    [Arguments]    ${dir}    ${load}    @{attenuations}
    Attach Ue And Start Ping    ${attenuations[0]}
    @{tput_avgs}=    Create List
    FOR    ${attenuation}    IN    @{attenuations}
        Set Attenuation    ${CELL_291}     ${attenuation}dB
        ${tput_data}=     Run Throughput    ${dir}    ${load}
        Append To List    ${tput_avgs}    ${tput_data}
    END
    Wait Until Keyword Succeeds   3x   6sec    taf.ue.Detach UE    UE_1
    RETURN    @{tput_avgs}

Run Throughput
    [Arguments]    ${dir}    ${load}
    taf.ue.Start Data Transfer
        ...     dt_name=DT_${dir}
        ...     ue_alias=UE_1
        ...     direction=${dir}
        ...     duration=65s
        ...     throughput=${load}Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    60s
    ${tput_stats}=  taf.ue.Get Data Transfer Statistics    dt_name=DT_${dir}    omit=30
    Run Keyword And Ignore Error   taf.ue.Stop Data Transfer    dt_name=DT_${dir}
    RETURN    ${tput_stats}

A_B4 Setup
    Set TESTNAME Without Spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    A_B4 Setup Recommissioning
    Verify Bts Is Operational

CB014045-A_B4_Uplink_LA_gains_with_Single_UE_in_256QAM_FDD_SA
    ${tputs_disabled}=    Check Throughputs    ul  100    @{A_B4_ATTENUATIONS}
    B_B1 Feature Recommissioning    UL
    Sleep    10s
    ${tputs_enabled}=    Check Throughputs    ul  100    @{A_B4_ATTENUATIONS}
    Confirm Uplink Througput Gain After Enabling Feature    ${tputs_disabled}  ${tputs_enabled}

A_B4 Teardown
    Log To Console    A_B4 Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Set Attenuation    ${CELL_291}     90dB
    A_B4 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

############# Recommissionings #############
B_B1 Feature Recommissioning
    [Arguments]    ${value}
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50829/NRBTS-50829/NRCELL-291    actLaEnhanceEfficiencyLatency=${value}
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

A_B4 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829    actExtSchedWeightAndPrefWrrAlg=LegacyRange_lowComplexityWrr
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRCELL-291    actUlSlotAgg=Disabled    actUlDftSOfdm=false
    ...    actUlTransPreEnhHo=false    actLaEnhanceEfficiencyLatency=disabled
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-1    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-2    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-3    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-4    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-5    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-6    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-7    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-8    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-9    schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-10   schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-11   schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-12   schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-13   schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-14   schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-15   schedulWeight=99
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-16   schedulWeight=99

    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb


A_B4 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829    actExtSchedWeightAndPrefWrrAlg=ExtendedRange_LegacyWrr
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRCELL-291    actUlSlotAgg=Enabled_VoNr    actUlDftSOfdm=true
    ...    actUlTransPreEnhHo=true    actLaEnhanceEfficiencyLatency=disabled
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-1    schedulWeight=120
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-2    schedulWeight=140
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-3    schedulWeight=120
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-4    schedulWeight=110
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-5    schedulWeight=105
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-6    schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-7    schedulWeight=140
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-8    schedulWeight=130
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-9    schedulWeight=115
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-10   schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-11   schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-12   schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-13   schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-14   schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-15   schedulWeight=101
    Add Parameters To Delta    dist_name=MRBTS-50829/NRBTS-50829/NRDRB-16   schedulWeight=101
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb
