*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage    PY310

Documentation    :copyright: Nokia
...              :authors: Sebastian Maslak
...              :contact: sebastian.maslak@nokia.com
...              Please keep in mind that Online modification will be delivered under CB008242-G subfeature,
...              after that please change in Suit setup the order of Reach Onair and Find Scfc And Send Delta Commissioning
...              Keywords.

Resource    CB008242_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8242.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_8242.json

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008242_A_IWK1_Rise_Auto_UAC_Overload_CU_Became_ON
    [Documentation]    This test scenario explaining how to perform test of the gNB behaviour when C-plane detects
    ...                CU overload and overload are switched off. The gNB sets the C-plane gNB-CU overload trigger as ACTIVE in all cells with
    ...                automatic UAC configured and starts broadcast max automatic UAC configuration in SIB1 for them.
    ...                Also checks proper incrementation of TIME_AUTO_UAC_OVL, TIME_AUTO_UAC and TIME_AUTO_UAC_MAX counters.
    ...                5G_RAN_USR_RRM_23767(IWK1);5G_RAN_USR_RRM_23768(IWK2);5G_PM_1525;5G_PM_1526;5G_PM_1527

    Perform CPLANE OVL Activation Via R&D Mechanism
    Verify Network Access Rate Reduction
    Wait For StartUacBarringTimerOverload From All Cells And Verify SIB1 Changes Due Overload Condition
    Verify Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cells
    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55164C00001  >50  TIME_AUTO_UAC_OVL
    ...    M55164C00002  >50  TIME_AUTO_UAC
    ...    M55164C00003  >50  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55164C00001  >50  TIME_AUTO_UAC_OVL
    ...    M55164C00002  >50  TIME_AUTO_UAC
    ...    M55164C00003  >50  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55164C00001  >50  TIME_AUTO_UAC_OVL
    ...    M55164C00002  >50  TIME_AUTO_UAC
    ...    M55164C00003  >50  TIME_AUTO_UAC_MAX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Perform CPLANE OVL Dectivation Via R&D Mechanism
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
