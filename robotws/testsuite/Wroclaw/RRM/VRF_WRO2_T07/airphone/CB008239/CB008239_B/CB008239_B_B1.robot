*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    SBTS00    CRT
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Bartosz Grzegorczyk
...              :contact: bartosz.grzegorczyk@nokia.com

Resource     ../CB008239_A/CB008239_A_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8239_B_B1.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/../CB008239_A/config/egate_2c_tdd_sansa_interrat_ho.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Check Radios Availability
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008239_B_B1_Online_modification_of_inter_RAT_ANR_automatic_removal_related_parameters
    [Documentation]    This test case test the  gNB behaviour when there is an online modification of parameters
    ...        related to inter-RAT ANR automatic neighbour object removal mechanism. This test verifies that NRRELE
    ...        is deleted after update of parameter actAutoEutraNbRemoval and performing failing handovers. This test
    ...        don't verify deletion of NRADJECELL object. 5G_RAN_USR_RRM_14683 AC/M

    Attach Ue And Establish Pdu Session And Send B2 Measurement   ue_id=11  meas_id=4
    Verify Created NRADJECELL And NRRELE Objects
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRANR-1    parameter=actAutoEutraNbRemoval    value=true
    Attach Ue And Establish Pdu Session And Send A2 Measurement   ue_id=13  pdu_id=2  gw_id=2  meas_id=1
    Set Amf To Fail Handover And Send B2 Measurement   ue_id=13  meas_id=4
    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRRELE_A-256  moc=NRRELE_A   timeout=300



