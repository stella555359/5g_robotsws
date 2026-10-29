*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS23R2    PY310
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Przemyslaw Sas
...              :contact: przemyslaw.sas@nokia.com

Resource    CB007582_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB007582_D_D2.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_CB007582_D_D2.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB007582_D_D2_SA_Cell_Activation_Failure_For_SA_Service_When_NG_Link_Is_Unavailable
    [Documentation]    This scenario addresses fault and alarm reporting for SA type cell when cell activation
    ...                encounter failure because of unavailable Ng link. It is used to replace the legacy 7103.
    ...                REQ_ID 5G_RAN_USR_RRM_5434

    Lock Single Cell    cell_id=1  timeout=60
    Lock Single Cell    cell_id=2  timeout=60
    Set AMF To Ignore Requests
    Drop NG Link
    Unlock Single Cell    cell_id=1  timeout=60
    Unlock Single Cell    cell_id=2  timeout=60
    Wait For Alarm To Be Up    alarm_id=${cell_service_problem_alarm}  timeout=300  severity=Critical
    Wait For Fault To Be Up    fault_id=${cell_service_problem_fault}
