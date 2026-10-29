*** Settings ***

Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SA_FS_ECPRI_MMWV_TDD
...    Author: Ulm SQD 68
...    Contact: I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com
...    Description: CB008285's part of 5GC000425-Y "L2 Performance Counters", adds support for the L2-PS/LO/HI PM counters defined in 5G17A
...    related to 425 functionality (HARQ, RACH, TA, Basic MAC/RLC/PDCP)
...    IMPORTANT: due to the work split not all 5GC000425-Y's PM counters tested by ET Ulm
...    NOTE: for the sake of simplicity the "online" reporting is done directly from verification routines
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../L2/resources/robot/test_setup.robot
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/tracing.robot
Resource   ../5GC000425/resources/5GC000425_scenario_modifications.robot
Resource   ../5GC000425/resources/5GC000425_scenario_validations.robot



Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}            ${20}
${pm_reporting_interval}          5min
${relative_json_path}             ../../5GC000425/5GC000425_Y_MMWV_SA.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}



*** Test Cases ***

5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INI_64TBL_MCS_xx
    [Tags]  CRT
    common_keywords.Run Test Scenario
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_INI_64TBL_MCS_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_SUC_INI_64TBL_MCS_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_SUC_ANY_64TBL_MCS_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_INI_VOL_64TBL_MCSxx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_INIRE_VOL_64TBL_MCSxx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For CNI155634__PDSCH_INIRE_VOL_64TBL_MCSxx
    tracing.Check For Errors In Syslog


5GC000425_Y_UP_PMCounter__KPI__DL_RLC_PDU_D_RBR_H_QOS_GRP_xx
    [Tags]  CRT
    common_keywords.Run Test Scenario
    5GC000425_scenario_validations.Generate Verdict On scenario_2 For 5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2
    5GC000425_scenario_validations.Generate Verdict On scenario_2 For KPI__DL_RLC_PDU_D_RBR_H_QOS_GRP_xx and KPI__DL_RLC_VOL_D_RBR_H_QOS_GRP_xx
    tracing.Check For Errors In Syslog


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    # IMPORTANT: do not forget to comment *** Keyword ***
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable
    ...    /home/ute/logs/5GC000425_Y_MMWV_SA/2026-01-16T11-02-27-F/5GC000425_Y_MMWV_SA/SBTS00_ENB_9999_260115_000004/20260116_110307
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Set Test Variable   ${pmc_index}    ${0}
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_INI_64TBL_MCS_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_SUC_INI_64TBL_MCS_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_SUC_ANY_64TBL_MCS_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_INI_VOL_64TBL_MCSxx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For ULHARQ__PUSCH_CP_INIRE_VOL_64TBL_MCSxx
    5GC000425_scenario_validations.Generate Verdict On scenario_2 For 5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2
    5GC000425_scenario_validations.Generate Verdict On scenario_2 For KPI__DL_RLC_PDU_D_RBR_H_QOS_GRP_xx And KPI__DL_RLC_VOL_D_RBR_H_QOS_GRP_xx
    5GC000425_scenario_validations.Generate Verdict On scenario_1 For CNI155634__PDSCH_INIRE_VOL_64TBL_MCSxx
