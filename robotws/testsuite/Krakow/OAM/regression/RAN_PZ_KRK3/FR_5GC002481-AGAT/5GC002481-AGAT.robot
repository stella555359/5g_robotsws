*** Settings ***
Documentation
...    Author: pawel.wroblewski@nokia.com
...    Maintainer: jakub.siluch@nokia.com
...    Description: Parity tests for feature 5GC000375 which focuses on SFP parameters monitoring (BER, LCV) and
...                 raising proper alarms
...    Team in charge: MN RAN Pz Krk 3 SG
...    Note: test suite assumes that attenuator server is running on raspberry, in case it is not check how to set it
...          with method setup_attenuator_server

Library     ./resources/python_keywords.py
Resource    ./resources/5GC002481-AGAT_CommonKeywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Force Tags  CA_5G_OAM    5G_RAN_FDD    RAN_5G    CRT    STATE_GNB_COMMISSIONED
...   PY36
...     CLOUD_5G_CLASSICAL_ATT_ASIBR_ABIOB4_AHEB_ENB
...     SBTS00__WITH__CONFIGS_Krakow/5GC002481-AGAT/TRUNK/5GC002481_AGAT.yaml
...     RAN_5G_MP__WITH__SBTS22R3__WITH__CONFIGS_Krakow/5GC002481-AGAT/TRUNK/5GC002481_AGAT.yaml
...     SBTS22R4__WITH__CONFIGS_Krakow/5GC002481-AGAT/TRUNK/5GC002481_AGAT.yaml
...     RAN_5G_MP__WITH__SBTS21B__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS21B/5GC002481_AGAT.yaml
...     RAN_5G_MP__WITH__SBTS22R2__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml

Suite Setup      Run Keywords
...             admin_cli.connect_to
...             Perform SW upgrade to same build and reach onAir

Suite Teardown     Run Keyword
...             admin_cli.teardown

Test Teardown    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
${SMOD_att_location}  ${tl.attenuators.port[0]}
${RMOD_att_location}  ${tl.attenuators.port[1]}

*** Test Cases ***
[1]5GC002481-AGAT_Threshold_Parameters_Configuration
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    Set BER alarm thresholds
    ...      berMajorAlarmThreshold=-5
    ...      berMinorAlarmThreshold=-10
    Verify gNB is onAir
    [Teardown]    Run Keywords    Set BER alarm thresholds to default values    AND
    ...           interface.Common step trigger

[1]5GC002481-AGAT_Threshold_Parameters_disabling
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    Set BER alarm thresholds
    ...      berMajorAlarmThreshold=-5
    ...      berMinorAlarmThreshold=0
    Verify gNB is onAir
    [Teardown]    Run Keywords    Set BER alarm thresholds to default values    AND
    ...           interface.Common step trigger

[1]5GC002481-AGAT_Threshold_Parameters_Boundary_Values_Check
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    Try to set BER alarm thresholds and expect validation failure   -15     -15
    Try to set BER alarm thresholds and expect validation failure   -3      -3
    Try to set BER alarm thresholds and expect validation failure   -2      -3
    Try to set BER alarm thresholds and expect validation failure   -14     -16
    Verify gNB is onAir
    [Teardown]    Run Keywords    Set BER alarm thresholds to default values    AND
    ...           interface.Common step trigger

[1]5GC002481-AGAT_BER_Measurement_Interval_Update
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    Set NRPMRNL parameter     miNrSfpRmod     15min
    Verify gNB is onAir
    Set NRPMRNL parameter     miNrSfpRmod     60min
    Verify gNB is onAir
    Set NRPMRNL parameter     miNrSfpRmod     5min
    Verify gNB is onAir
    Set NRPMRNL parameter     miNrSfpBbmod    15min
    Verify gNB is onAir
    Set NRPMRNL parameter     miNrSfpBbmod    60min
    Verify gNB is onAir
    Set NRPMRNL parameter     miNrSfpBbmod    5min
    Verify gNB is onAir
    [Teardown]  Run Keywords
    ...      Set NRPMRNL parameter     miNrSfpRmod    5min   AND
    ...      Set NRPMRNL parameter     miNrSfpBbmod   5min   AND    interface.Common step trigger

[1]5GC002481-AGAT_PM_Counters_Visible_in_WebEM
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    [Documentation]  Consider applying attenuation and verify if counters are >0 in future
    Wait till end of counter retrieval interval
    Verify that RMOD SFP monitoring PM counter are visible in WebEM
    Verify that SMOD SFP monitoring PM counter are visible in WebEM
    [Teardown]    Run Keywords     interface.Common step trigger

[1]5GC02481-AGAT_BER_Reporting_Interval_Reached
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    ${counter_file}=  Get latest raw PM file from BTS
    Verify if raw PM counter file contains counter  ${counter_file}    M55603C00010
    Verify if raw PM counter file contains counter  ${counter_file}    M55603C00011
    Verify if raw PM counter file contains counter  ${counter_file}    M55602C00010
    Verify if raw PM counter file contains counter  ${counter_file}    M55602C00011
    [Teardown]    Run Keywords    interface.Common step trigger

[1]5GC002481-AGAT_Rising_a_Minor_Alarm_SMOD
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    [Setup]  Run keywords
    ...     Setup attenuator client    ${SMOD_att_location}  AND
    ...     Set BER alarm thresholds    -13     -5
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=4476   alarm_id=7115
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms   fault_id=4476   alarm_id=7115
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Set BER alarm thresholds to default values  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Clearing_a_Minor_Alarm_SMOD
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    [Setup]  Run keywords
    ...     Setup attenuator client    ${SMOD_att_location}  AND
    ...     Set BER alarm thresholds    -13     -5
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=4476   alarm_id=7115
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms   fault_id=4476   alarm_id=7115
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Set BER alarm thresholds to default values  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Rising_a_Major_Alarm_SMOD
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    [Setup]  Run keywords
    ...     Setup attenuator client    ${SMOD_att_location}  AND
    ...     Set BER alarm thresholds    -13     -11
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=4476   alarm_id=7116
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms     fault_id=4476    alarm_id=7116
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Set BER alarm thresholds to default values  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Clearing_a_Major_Alarm_SMOD
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    [Setup]  Run keywords
    ...     Setup attenuator client    ${SMOD_att_location}  AND
    ...     Set BER alarm thresholds    -13     -11
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=4476   alarm_id=7116
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms  fault_id=4476    alarm_id=7116
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Set BER alarm thresholds to default values  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_SFP_QSFP_BER_LCV_monitoring_from_webEM_for_ABIO
    [Tags]    CRT__WITH__RAN_5G_MP__WITH__SBTS22R1__WITH__CONFIGS_Krakow/5GC002481-AGAT/SBTS22R1/5GC002481_AGAT.yaml
    [Setup]  Setup attenuator client    ${SMOD_att_location}
    ${bbmod}=  get_bbmod_dist
    Increase attenuation until SFP statistics are updated   hw=${bbmod}
    Verify that BER and BER24hr values are on the same level    hw=${bbmod}
    [Teardown]  Run keywords
    ...     Set attenuation     0  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_SFP_BER_monitoring_from_webUI_for_CPRI-N_RU
    [Setup]  Setup attenuator client    ${RMOD_att_location}
    ${rmod}=  get_rmod_dist
    Increase attenuation until SFP statistics are updated   hw=${rmod}  start_att=11  end_att=15
    Verify that BER and BER24hr values are on the same level    hw=${rmod}
    [Teardown]  Run keywords
    ...     Set attenuation     0  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Rising_a_Minor_Alarm_RMOD
    [Setup]  Setup attenuator client    ${RMOD_att_location}
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=1955  alarm_id=7116  start_att=10.5  end_att=13  step_att=0.1
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms   fault_id=1955   alarm_id=7116
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Clearing_a_Minor_Alarm_RMOD
    [Setup]  Setup attenuator client    ${RMOD_att_location}
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=1955  alarm_id=7116  start_att=10.5  end_att=13  step_att=0.1
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms   fault_id=1955   alarm_id=7116
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Rising_a_Major_Alarm_RMOD
    [Setup]  Setup attenuator client    ${RMOD_att_location}
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=1956  alarm_id=7116  start_att=11  end_att=14.5  step_att=0.1
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms     fault_id=1956    alarm_id=7116
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger

[1]5GC002481-AGAT_Clearing_a_Major_Alarm_RMOD
    [Setup]  Setup attenuator client    ${RMOD_att_location}
    Verify gNB is onAir
    Increase attenuation until alarm occurs     fault_id=1956  alarm_id=7116  start_att=11  end_att=14.5  step_att=0.1
    Set attenuation  0
    Reset site and wait for onAir state
    Verify that alarm is not present in active alarms  fault_id=1956    alarm_id=7116
    [Teardown]    Run keywords
    ...     Set attenuation  0  AND
    ...     Clear SFP statistics if needed    AND    interface.Common step trigger
