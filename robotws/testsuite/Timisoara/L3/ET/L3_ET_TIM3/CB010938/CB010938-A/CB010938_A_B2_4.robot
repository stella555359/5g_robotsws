*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska, Moldovan Dan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sa.lua
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-4
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

${preferences}          ${CURDIR}/config/preferencesA_B2_1
${filename_f1_e1}       gnb_F1_E1_RRC.pcap

*** Test Cases ***

CB010938_A_B2_4_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_UE_Missing_Dummy4_Structure
    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_HAS_SPECIAL_ALGO_MISSING_DUMMY4}
    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
    Perform Exit Idle Mode    ue_id=1

    sleep  15
     Setup wireshark     ${preferences}
     ###    Copy traces
     Copy trace  tshark    ${filename_f1_e1}
     ${ngap_file}  Run    cd ${OUTPUT_DIR}/${TEST_NAME}/tshark;ls core*

     Set Test Variable  ${filename_ngap}    ${ngap_file}
     Copy trace  tshark    ${filename_ngap}


    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C00025   +0    UE_CHIPSET_VENDOR_NUM_SUP
    ...    M55124C00026   +0    UE_CHIPSET_VENDOR_NUM_SUP_ECHO
    ...    M55124C00027   +2    UE_CHIPSET_VENDOR_RECV_ERR
    ...    M55124C00028   +0    UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}

### NR RRC ###
#   1.UE Capability Enquiry message is present twice and both messages contain Infra info with correct values.
#   2.UE Capability Information is present twice and both messages contain Infra Info (values the same as in Enquiry), dummy = supported,
#     but dummy4 structure under band41 (first band from the list) is absent.

    Prepare NR RRC columns A_b2

    Check NR RRC A_B2_4

### NGAP ###
#   3.UERadioCapabilityInfoIndication message is present twice and both messages contain Infra Info (values the same as in Enquiry),
#     dummy=supported, dummy4 absent.

    Prepare NGAP columns A_B2

    Check NGAP A_B2_4
