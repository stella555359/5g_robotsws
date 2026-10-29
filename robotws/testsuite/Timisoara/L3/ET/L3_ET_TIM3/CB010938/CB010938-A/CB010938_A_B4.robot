*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska, Dan Moldovan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py


Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sa.lua
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-4
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

${preferences}          ${CURDIR}/config/preferencesA_B2_1
${filename_f1_e1}       gnb_F1_E1_RRC.pcap

*** Test Cases ***
CB010938_A_B4_1_Deactivation_Of_Chipset_And_RAN_Identification_Exchange_Functionality
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_NO_SPECIAL_ALGO}
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=2    ue_nr_capabilities=${UE_SUPPORTS_AND_NO_SPECIAL_ALGO}
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=3    ue_nr_capabilities=${UE_SUPPORTS_AND_NO_SPECIAL_ALGO_NO_DUMMY4}
        ...    AND             Attach UE    ue_id=1
        ...    AND             Establish PDU Session    ue_id=1   pdu_id=1    gw_id=1
        ...    AND             Attach UE And Establish PDU Session And Release UE Context    ue_id=2    pdu_id=2    gw_id=2

    Sleep    2s
    Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
    Include UE Radio Capabilities in ICSReq    ue_id=2    ue_capabilities=auto
    Perform Exit Idle Mode    ue_id=2
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3   pdu_id=3    gw_id=3

    Sleep    10s
     Setup wireshark     ${preferences}
     ###    Copy traces
     Copy trace  tshark    ${filename_f1_e1}
     ${ngap_file}  Run    cd ${OUTPUT_DIR}/${TEST_NAME}/tshark;ls core*

     Set Test Variable  ${filename_ngap}    ${ngap_file}
     Copy trace  tshark    ${filename_ngap}

### NR RRC ###
#   1.UE Capability Enquiry message is present three times:
#     For UE-1 and UE-2 contains Infra Info with correct values as in previous test cases.
#   2.UE Capability Information is present three times:
#     For UE-1 and UE-2 Infra Info is absent, but contains dummy=supported and chipset info with correct values.

    Prepare NR RRC columns A_b2

    Check NR RRC A_B4_1

    ### NGAP ###
#   3. UERadioCapabilityInfo Indication is present three times (only three times).
#      For UE-1 and UE-2 contains dummy=supported and chipset info with the same values as in UECapabilityInformation.
#      For UE-3 dummy=supported, but dummy4 structure is absent.
#   4. Verify that in Initial Context Setup Request, Service accept message UE Radio Capability IE is present and
#       contains dummy=supported and dummy4 structure.
#   5. Verify that there is no additional capabilities enquiry for Initial Context Setup Request, Service accept procedure,
#      so there is not additional UE Radio Capability Info Indication message for UE-2.

    Prepare NGAP columns A_B2

    Check NGAP A_B4_1
