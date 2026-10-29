*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    SBTS00    CRT
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Adrian Wojtyna, Bartosz Grzegorczyk
...              :contact: adrian.wojtyna@nokia.com, bartosz.grzegorczyk@nokia.com

Resource     ../CB008239_A/CB008239_A_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8239_B_B3.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/../CB008239_A/config/egate_2c_tdd_sansa_interrat_ho.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Check Radios Availability
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008239_B_B3_Delta_Plan_activation_from_OAM_for_CB008239
    [Documentation]    This user scenario describes the gNB behaviour when there is a delta plan update from CU-OAM
    ...    and inter-RAT ANR functionality for SA is enabled and there are conflicts detected
    ...    5G_RAN_USR_RRM_14680

    Attach Ue And Establish Pdu Session And Send B2 Measurement   ue_id=11    meas_id=4
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO
    Sleep    60s  reason=Waiting for creation of ANR objects
    Find Scfc And Send Delta Commissioning    scfc_filename=WrongDelta_8239_B_B3.json
    Verify Created NRADJECELL And NRRELE Objects
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01501  +1  NMOCU_ANR_NRRELE_ADD
    ...    M55147C01502  +0  NMOCU_ANR_NRRELE_OVER_LIMIT
    ...    M55124C07001  +1  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  +1  NRRCC_EUTRACGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

