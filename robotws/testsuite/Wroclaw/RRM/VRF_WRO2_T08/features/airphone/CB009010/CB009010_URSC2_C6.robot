*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Przemyslaw Sas
...              :contact: przemyslaw.sas@nokia.com

Resource    CB009010_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_9010_URSC2_C6_2AMF.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_ran_sharing_2AMF_SANSA.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_9010_URSC2_C6_2AMF.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB009010_URSC2_SIB1_Transmission_CellReservedForOperatorUse_In_Transient_State_ALT_C6_P34
    [Documentation]    SIB1 is transmitted as the cells come up with configured neutral PLMN (if applicable),
    ...                SA PLMN and NSA PLMN as per the configuration, considering the AMF supported PLMNs,
    ...                including the "cellReservedForOperatorUse" at PLMNIdentityInfo level.
    ...                5G_RAN_USR_RRM_21204
    ...                Additional robustness test, where UE is attaching to cell 1 with PLMN of supported AMF1
    ...                after it's ng link reset.

    SIB1 Verify For PLMN Count With CellReserved Status Before Activation AMFs PLMN Support
    Activate AMFs Support
    SIB1 Verify For PLMN Count With CellReserved Status After Activation AMFs PLMN Support
    Lock Unlock Cell 1
    Loop For Robustness AMF1 Ng Link Reset and UE Attache Check    AMF1 Ng Link Reset and UE Attache Check   ${robustness_loop_number}
