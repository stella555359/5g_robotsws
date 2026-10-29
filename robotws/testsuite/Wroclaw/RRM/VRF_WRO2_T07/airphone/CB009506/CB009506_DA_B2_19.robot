*** Settings ***
Force Tags    RAN_5G    RAN_5G_TDD    PY310    CLOUD_5G_I_LO_AP_LO
...           SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS00    SBTS23R4    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Rafal Stezalski, Piotr Bartkowski
...              :contact: rafal.stezalski@nokia.com piotr.bartkowski@nokia.com

Resource    CB009506_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${CURDIR}/config/backup/initial_commissioning.xml
...            AND             Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_CB009506_DA_B2_19.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB009506_DA_B2_19.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009506_DA_B2_19.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${CURDIR}/config/backup/initial_commissioning.xml
...                               delta_scf_filename=delta_CB009506_DA_B2_19.json
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy_initial.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...               AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB009506_DA_B2_19_Robustness_Cell_Block_Unblock_Lock_Unlock_For_Band_N40_Bandwidth_90_MHz
    [Documentation]    This robustness test case performs block/unblock and lock/unlock of cell for NR cell FR1-TDD bandwidth 90Mhz
    ...                with DL/UL traffic supported in n40 band and Scs equal 30 kHz (CB009506-DA-B2 requirement 5G_RAN_USR_RRM_20095).

    Attach Ue And Set Throuput    ue_id=1    number_of_messages=1
    Start UL And DL Traffic    ue_id=1    pdu_id=1
    Verify Both Traffic For UE   ue_id=1

    Lock Single Cell    cell_id=1
    Check If Ue Is Deregistered    cmd=${UE_STAT_CMD}    pass_regexp=${UE_DEACTIVATED}
    Unlock Single Cell    cell_id=1
    Wait For Sib Transmission
    Attach Ue And Set Throuput    ue_id=1    number_of_messages=2
    Start UL And DL Traffic    ue_id=1    pdu_id=1
    Verify Both Traffic For UE    ue_id=1

    Block Single Cell    cell_id=1
    Check If Ue Is Deregistered    cmd=${UE_STAT_CMD}    pass_regexp=${UE_DEACTIVATED}
    Unblock Single Cell    cell_id=1
    Wait For Sib Transmission

    Attach Ue And Set Throuput    ue_id=1    number_of_messages=3
    Start UL And DL Traffic    ue_id=1    pdu_id=1
    Verify Both Traffic For UE    ue_id=1


    Release Pdu Session    ue_id=1    pdu_id=1
    Deregister Ue    ue_id=1
