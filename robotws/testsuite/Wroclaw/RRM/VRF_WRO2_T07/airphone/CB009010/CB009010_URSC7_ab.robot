*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           CRT    SBTS00    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Marcin Szulc
...              :contact: marcin.szulc@nokia.com

Resource    CB009010_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/SNSSAI-1  parameter=administrativeState  value=Locked
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_9010_URSC7_ab.json
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scf_before_test.xml
...            AND             Reset Testline And Reach Onair    lua_cfg=${CURDIR}/config/egate_URSC7_ab.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scf_after_test.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...           AND             Setup X2 Links

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB009010_URSC_7a_Handover_Restriction_On_The_Target_For_UEs_Using_PLMN_That_Is_Reserved
    [Documentation]    UE establishes an RRC connection with a specific selectedPLMN on remote gNB. This PLMN is marked as "reserved"
    ...                in the Target cell's SIB1. Subsequently UE reports the target Cell's PCI for handover. Handover Request is received
    ...                from the remote gNB. The handover is rejected by the target cell.
    ...                5G_RAN_USR_RRM_21209

    Set AMF To Use Mobility Restriction List
    Attach Ue And Establish Pdu Session With History List    ue_id=26
    Perform A5 Handover to Real GNB    ue_id=26  pass_regexp=Handover Preparation Failure
    Verify Handover Preparation Failure Message
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1  parameter=hoToCellResForOpUseEnabled  value=true
    Perform A5 Handover to Real GNB    ue_id=26
    Verify Handover Preparation Success Message
