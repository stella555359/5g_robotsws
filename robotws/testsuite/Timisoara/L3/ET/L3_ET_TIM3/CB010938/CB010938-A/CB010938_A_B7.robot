*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska;Dan Moldovan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reset Testline
...             AND             Check Radios Availability
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_pcmd_activation.json
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sa.lua
...             AND             Start Server Interface
...             AND             Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...             AND             Setup PCMD

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-4
...              AND            Teardown PCMD
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB010938_A_B7_1_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_PCMD_Trace
    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_HAS_SPECIAL_ALGO}
    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
    Perform Exit Idle Mode    ue_id=1

    ## UE Info Record contains chipset info with correct values in pcmd_records log
    log to console    Start test
    Wait for PCMD Records    1    UeInfoTraceRecord    30

    log to console    Add record
    Add record for verification
    ...     record_name_with_alias=UeInfoTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/UeInfoTraceRecord.yaml


    Perform Records Verification
