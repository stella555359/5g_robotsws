*** Settings ***
Documentation
...  author:      Dawid Chuchnowski, dawid.chuchnowski@nokia.com, Andrzej Pencak, andrzej.pencak@nokia.com
...  maintainer:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  team:        KRK6

Library     OperatingSystem
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_syslog
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./resources/suite_specific_keywords.robot

Suite Setup    Suite Setup

*** Test Cases ***
CB008967_E_EIF_SFP_SMOD_mean_temperature_monitoring_ASIK
    [Documentation]    Test verifies 40006C2 SBTS_SFP_SM_AVG_TEMPERATURE counter value
    [Setup]  Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=15min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSSfpSMOD    value=15min
    Wait for a next PM interval
    Verify M40006C2 SBTS_SFP_SM_AVG_TEMPERATURE counter value
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSSfpSMOD
    ...    AND    Common Postconditions

CB008967_C_03_ASIK_ABIL_smod_bbmod_internal_temp_rd_counters_present
    [Documentation]    Test verifies SMOD and BBMODs internal temperature RD counters
    [Setup]  Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSSMODTemperature    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSBBMODTemperature    value=5min
    Wait for a next full PM interval
    Check RaD counters
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSSMODTemperature
    ...    AND    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSBBMODTemperature
    ...    AND    Common Postconditions

CB008967_D_01_AMIA_cabinet_fan_speed_available_WebEM
    [Documentation]    This test verifies the availability and consistency of cabinet fan speed data from various sources:
    ...    - Performance Management (PM) Counters
    ...    - Syslog
    ...    - Real-time Measurements
    [Setup]    Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSCabiFan    value=5min
    Start syslog collecting
    Wait for a next full PM interval
    ${pm_counters}=    Get PM counters values
    ...    counters=M40031C0, M40031C1, M40031C2
    ...    localmoid=PLMN-PLMN/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/FAN-2
    Stop syslog
    ${fan_speed_syslog}=    Get cabinet fan speed from syslog
    ${fan_speed_rt_meas}=    Get cabinet fan speed real time measurements
    Compare cabinet fan speeds from all sources    ${pm_counters}    ${fan_speed_rt_meas}    ${fan_speed_syslog}
    Collect snapshot from BTS
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSCabiFan
    ...    AND    Common Postconditions

CB008967_D_08_AMIA_cabinet_fan_speed_available_in_blackbox
    [Documentation]    This test verifies that fan speed is reported in blackbox
    [Setup]    Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSCabiFan    value=5min
    Wait for a next PM interval
    Collect snapshot from BTS
    ${bbox_content}=    Get blackbox temperature file
    ${fan1_speed_list}  ${fan2_speed_list}  Fetch fan speed values from blackbox content    ${bbox_content}
    Check average fan speed    ${fan1_speed_list}    ${fan2_speed_list}
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSCabiFan
    ...    AND    Common Postconditions

CB008967_I_03_ASIR_radio_module_fan_speed_available_WebEM
    [Documentation]    This test verifies PM counters availability via WebEM and their consistency with syslog prints
    [Setup]    Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSASIRMODFan    value=5min
    Wait for a next full PM interval
    ${pm_counters_APHG}=    Get ASIRMOD fan speed counters values    asirmod_id=1
    ${pm_counters_APHA}=    Get ASIRMOD fan speed counters values    asirmod_id=2
    Collect snapshot from BTS
    Get ASIRMODs runtime logs from snaphot    asirmod=APHG
    Get ASIRMODs runtime logs from snaphot    asirmod=APHA
    ${MED_FanSpeed_list}=    Get MED FanSpeed from runtime log
    ${FanSpeed_rpm_list}=    Get FansServiceRpmControlLoop from runtime log
    Compare ASIRMOD fan speed counters with syslog prints
    ...    ${pm_counters_APHG}
    ...    ${pm_counters_APHA}
    ...    ${MED_FanSpeed_list}
    ...    ${FanSpeed_rpm_list}

    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSASIRMODFan
    ...    AND    Common Postconditions

CB008967_I_06_ASIR_radio_module_fan_speed_not_available_WebEM
    [Documentation]    This test verifies that real time measurments are not reported after locking SFP between BBMOD and ASIRMOD
    [Setup]    Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSASIRMODFan    value=5min
    Lock SFP between BBMOD and ASIRMOD
    Wait for next real time measurement reports
    ${rt_meas}=    Get real time measurements dict
    Check that ASIRMOD fan speed is not reported    ${rt_meas}
    [Teardown]    Run keywords
    ...    Unlock SFP between BBMOD and ASIRMOD
    ...    AND    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSASIRMODFan
    ...    AND    Common Postconditions

CB008967_I_13_ASIR_radio_module_fan_speed_available_CLI
    [Documentation]    This test verifies ASIRMOD fan speed measurements compliance with syslog
    [Setup]    Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSASIRMODFan    value=5min
    Wait for next real time measurement reports
    ${rt_meas}=    Get asirmods fan speed real time measurements
    Collect snapshot from BTS
    Get ASIRMODs runtime logs from snaphot    asirmod=APHG
    Get ASIRMODs runtime logs from snaphot    asirmod=APHA
    ${MED_FanSpeed_list}=    Get MED FanSpeed from runtime log
    ${FanSpeed_rpm_list}=    Get FansServiceRpmControlLoop from runtime log
    Compare ASIRMOD fan speed measurements with syslog prints
    ...    ${rt_meas}
    ...    ${MED_FanSpeed_list}
    ...    ${FanSpeed_rpm_list}

    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSASIRMODFan
    ...    AND    Common Postconditions

CB008967_AI_01_ASIR_radio_module_internal_temp_available
    [Documentation]    Test verifies ASIR internal temperature RD counters
    [Setup]  Run keywords
    ...    Common Preconditions
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSASIRMODTemperature    value=5min
    Wait for a next full PM interval
    Check ASIRMOD RaD counters
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSASIRMODTemperature
    ...    AND    Common Postconditions

CB008967_F_22_Cabinet_M40031_fan_speed_counters_KPI_alarm_trigger_and_snapshot_collection_ASIK
    [Documentation]    Test verifies KPI analyzer triggered alarms for Cabinet Fan Speed counters
    [Setup]  Run keywords
    ...    Common Preconditions
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSCabiFan   value=5min
    Wait for a next full PM interval
    ${pm_counters}=    Get PM counters values
    ...    counters=M40031C0, M40031C1, M40031C2
    ...    localmoid=PLMN-PLMN/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/FAN-2
    Configure first KPI analyzer alarm
    Sleep    120s
    Check alarm 4588 was raised and snaphot collected
    Configure KPI analyzer alarm    faultID=4588    formulaDescription=Cabinet_fan_speed_formula_2
    ...    triggeringFormula=100*SBTS_CAB_AVG_FANSPEED/SBTS_CAB_MAX_FANSPEED >= 30
    Sleep    120s
    Check KPI analyzer alarm was raised    faultID=4588    formulaDescription=Cabinet_fan_speed_formula_2
    ...    triggeringFormula=100*SBTS_CAB_AVG_FANSPEED/SBTS_CAB_MAX_FANSPEED >= 30
    Configure KPI analyzer alarm    faultID=4588    formulaDescription=Cabinet_fan_speed_formula_3
    ...    triggeringFormula=SBTS_CAB_AVG_FANSPEED-SBTS_CAB_MAX_FANSPEED > 0
    Sleep    120s
    Check KPI analyzer alarm was not raised    faultID=4588    formulaDescription=Cabinet_fan_speed_formula_3
    ...    triggeringFormula=SBTS_CAB_AVG_FANSPEED-SBTS_CAB_MAX_FANSPEED > 0
    Configure KPI analyzer alarm    faultID=4587    formulaDescription=Cabinet_fan_speed_formula_4
    ...    triggeringFormula=SBTS_CAB_AVG_FANSPEED <=100 AND SBTS_CAB_MAX_FANSPEED <= 100
    Sleep    120s
    Check KPI analyzer alarm was raised    faultID=4587    formulaDescription=Cabinet_fan_speed_formula_4
    ...    triggeringFormula=SBTS_CAB_AVG_FANSPEED <=100 AND SBTS_CAB_MAX_FANSPEED <= 100
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSCabiFan
    ...    AND    Deconfigure KPI analyzer
    ...    AND    Common Postconditions

CB008967_F_24_ASiR_M40032_fan_speed_counters_KPI_alarm_trigger_and_snapshot_collection_ASIK
    [Documentation]    Test verifies KPI analyzer triggered alarms for ASIRMOD Fan Speed counters
    [Setup]  Run keywords
    ...    Common Preconditions
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSASIRMODFan  value=5min
    Wait for a next full PM interval
    ${pm_counters}=    Get PM counters values
    ...    counters=M40032C0, M40032C1, M40032C2
    ...    localmoid=PLMN-PLMN/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-1/FAN-1
    Configure first ASIRMOD KPI analyzer alarm
    Sleep    120s
    Check alarm 4579 was raised and snaphot collected
    Configure KPI analyzer alarm    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_2
    ...    triggeringFormula=SBTS_ASIR_MIN_FANSPEED+SBTS_ASIR_MAX_FANSPEED <0
    Sleep    120s
    Check KPI analyzer alarm was not raised    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_2
    ...    triggeringFormula=SBTS_ASIR_MIN_FANSPEED+SBTS_ASIR_MAX_FANSPEED <0
    Configure KPI analyzer alarm    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_3
    ...    triggeringFormula=100*SBTS_ASIR_AVG_FANSPEED/SBTS_ASIR_MAX_FANSPEED+SBTS_ASIR_MAX_TEMPERATURE >-3
    Sleep    120s
    Check KPI analyzer alarm was raised    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_3
    ...    triggeringFormula=100*SBTS_ASIR_AVG_FANSPEED/SBTS_ASIR_MAX_FANSPEED+SBTS_ASIR_MAX_TEMPERATURE >-3
    Configure KPI analyzer alarm    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_4
    ...   triggeringFormula=SBTS_ASIR_AVG_FANSPEED==0 OR SBTS_ASIR_MAX_TEMPERATURE+SBTS_ASIR_MAX_AMBI_TEMPERATURE>-9299.3
    Sleep    120s
    Check KPI analyzer alarm was raised    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_4
    ...   triggeringFormula=SBTS_ASIR_AVG_FANSPEED==0 OR SBTS_ASIR_MAX_TEMPERATURE+SBTS_ASIR_MAX_AMBI_TEMPERATURE>-9299.3
    Configure KPI analyzer alarm    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_5
    ...   triggeringFormula=SBTS_ASIR_AVG_FANSPEED>0 AND SBTS_ASIR_MAX_TEMPERATURE >=120
    Sleep    120s
    Check KPI analyzer alarm was not raised    faultID=4579    formulaDescription=ASIRMOD_fan_speed_formula_5
    ...   triggeringFormula=SBTS_ASIR_AVG_FANSPEED>0 AND SBTS_ASIR_MAX_TEMPERATURE >=120
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSASIRMODFan
    ...    AND    Deconfigure KPI analyzer
    ...    AND    Common Postconditions


*** Keywords ***
Set thermal state monitoring counter interval
    [Arguments]    ${parameter}    ${value}
    [Documentation]     This keyword sets CB008967 counter activation parameters to requested time interval
    ...     :param parameter: one of CB008967 Thermal state monitoring counters' parameter
    ...     :param value: interval for counters' reporting
    Change Parameter On DU
    ...    name=${parameter}
    ...    value=${value}
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/PMMNL-1

Deconfigure thermal state monitoring counter parameter
    [Arguments]    ${parameter}
    [Documentation]     This keyword deconfigures CB008967 counter activation parameters
    ...     :param parameter: one of CB008967 Thermal state monitoring counters' parameter
    Change Parameter On DU
    ...    name=${parameter}
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/PMMNL-1
    ...    value=disabled
    ...    operation=update

Deconfigure KPI analyzer
    [Documentation]     This keyword deconfigures CB008967 KPI analyzer
    Change Parameter On DU
    ...    name=actKpiAlarms
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/FEATCADM-1
    ...    value=false
    ...    operation=update

Verify M40006C2 SBTS_SFP_SM_AVG_TEMPERATURE counter value
    [Documentation]     This keyword verifies M40006C2 counter
    ${pm_counter_file}=    	Get Next Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M40006C2    20-60    Mean temperature of an SFP inserted into an SMOD (SBTS_SFP_SM_AVG_TEMPERATURE)
    ...    M40006C3    1-17     Duration of one measurement period for measurement M40006 (SBTS_SFPSM_DURATION)
    ...    local_moid=LMN-PLMN/MRBTS-77122/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-26
    ...    file_path=${pm_counter_file}

Check M40031 SBTS Cabinet Fan Monitoring PM counters
    [Documentation]     This keyword verifies M40031 counters' values
    ${pm_counter_file}=    	Get Next Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M40031C0    1-100    SBTS_CAB_MIN_FANSPEED
    ...    M40031C1    1-100    SBTS_CAB_MAX_FANSPEED
    ...    M40031C2    1-100    SBTS_CAB_AVG_FANSPEED
    ...    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/FAN-2
    ...    file_path=${pm_counter_file}

Set measurement reporting interval
    [Arguments]    ${value}
    [Documentation]     This keyword sets PM counter reporting time interval to 15min
    ...     :param value: reportingIntervalPm interval
    Change Parameter On DU
    ...    name=reportingIntervalPm
    ...    value=${value}
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/PMCADM-1

Wait for next real time measurement reports
    Sleep    5min    reason=Wait for next real time measurement reports

Lock SFP between BBMOD and ASIRMOD
    [Documentation]     This keyword locks SFP between BBMOD and APHG
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-77122/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-4/LANE-1
    ...  param_name=administrativeState  param_value=Locked  skip_parameter_relation_errors=true  operation=update
    ...  timeout=300

Unlock SFP between BBMOD and ASIRMOD
    [Documentation]     This keyword unlocks SFP between BBMOD and APHG
    Change Parameter On DU
    ...    name=administrativeState
    ...    internal_dist_name=MRBTS-77122/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-4/LANE-1
    ...    value=Unlocked
    ...    operation=update
