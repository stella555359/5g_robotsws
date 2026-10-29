*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage    PY310

Documentation    :copyright: Nokia
...              :authors: Marcin Szulc
...              :contact: marcin.szulc@nokia.com

Resource    CB008242_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8242_DU_ovl.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_8242_DU_ovl.json

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008242_A_IWK3_Start_Max_Automatic_UAC_Triggered_By_Overload_GNB_DU
    [Documentation]    This test case describes the GNB behaviour when gNB-DU detects overload.
    ...                The gNB-DU sets the gNB-DU overload trigger as ACTIVE in all cells with overload automatic
    ...                UAC trigger configured and starts broadcast max automatic UAC configuration in SIB1 for them.
    ...                Requirement ID: 5G_RAN_USR_RRM_23769.

    Enter Overload State On GNB-DU
    Verify Network Access Rate Reduction DU
    Wait For StartUacBarringTimerOverload From All Cells And Verify SIB1 Changes Due Overload Condition
    Verify Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cells
    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55164C00001  >51  TIME_AUTO_UAC_OVL
    ...    M55164C00002  >51  TIME_AUTO_UAC
    ...    M55164C00003  >51  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55164C00001  >20  TIME_AUTO_UAC_OVL
    ...    M55164C00002  >20  TIME_AUTO_UAC
    ...    M55164C00003  >20  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55164C00001  >120  TIME_AUTO_UAC_OVL
    ...    M55164C00002  >120  TIME_AUTO_UAC
    ...    M55164C00003  >120  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Exit Overload State On GNB-DU
    Wait For StartUacBarringTimerOverload From All Cells And Verify SIB1 Changes Due Overload Condition Off
    Verify No Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cells
    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55164C00001  0  TIME_AUTO_UAC_OVL
    ...    M55164C00002  0  TIME_AUTO_UAC
    ...    M55164C00003  0  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55164C00001  0  TIME_AUTO_UAC_OVL
    ...    M55164C00002  0  TIME_AUTO_UAC
    ...    M55164C00003  0  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55164C00001  0  TIME_AUTO_UAC_OVL
    ...    M55164C00002  0  TIME_AUTO_UAC
    ...    M55164C00003  0  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
