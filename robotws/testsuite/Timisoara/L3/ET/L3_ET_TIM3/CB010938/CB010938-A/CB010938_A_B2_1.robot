*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska, Moldovan Dan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py
Library             taf.sw.scout                                           WITH NAME    scout_s


Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sa.lua
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-4
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND            Get SCF Id By Scout

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

${preferences}          ${CURDIR}/config/preferencesA_B2_1
${filename_f1_e1}       gnb_F1_E1_RRC.pcap

*** Test Cases ***
CB010938_A_B2_1_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_UE_Supporting
    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_HAS_SPECIAL_ALGO}
    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
    Perform Exit Idle Mode    ue_id=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C00025   +1    UE_CHIPSET_VENDOR_NUM_SUP
    ...    M55124C00026   +1    UE_CHIPSET_VENDOR_NUM_SUP_ECHO
    ...    M55124C00027   +0    UE_CHIPSET_VENDOR_RECV_ERR
    ...    M55124C00028   +0    UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}

     Setup wireshark     ${preferences}
     ###    Copy traces
     Copy trace  tshark    ${filename_f1_e1}
     ${ngap_file}  Run    cd ${OUTPUT_DIR}/${TEST_NAME}/tshark;ls core*

     Set Test Variable  ${filename_ngap}    ${ngap_file}
     Copy trace  tshark    ${filename_ngap}

### NR RRC ###
#   1.Only one UE Capability Enquiry message is present and contains correct Infra Info.
#   2.Only one UE Capability Information message is present and contains Infra Info (same values as in Enquiry),
#   dummy=supported and dummy4 structure is present and has correct values

    Prepare NR RRC columns A_b2

    Check NR RRC A_B2

### NGAP ###
#   3.There is only one UERadioCapabilityInfoIndication message and contains Infra Info (the same as in Enquiry) and dummy=supported and
#   dummy4 structure (the same as in UE CapabilityInformation)3. .
#   4. Initial Context Setup Request with Service accept message is present and contains UE capability as IE with Infra Info
#   (the same as in Enquiry), dummy=supported, dummy4 structure (the same as before).

    Prepare NGAP columns A_B2

    Check NGAP A_B2


#CB010938_A_B2_2_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_UE_Supporting_No_Special_Algorithms
#    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_NO_SPECIAL_ALGO}
#    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
#    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
#    Perform Exit Idle Mode    ue_id=1
#    Wait For Next Full Pm Interval
#    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
#    Verify Any Counters In File
#    ...    M55124C00025   +1    UE_CHIPSET_VENDOR_NUM_SUP
#    ...    M55124C00026   +0    UE_CHIPSET_VENDOR_NUM_SUP_ECHO
#    ...    M55124C00027   +0    UE_CHIPSET_VENDOR_RECV_ERR
#    ...    M55124C00028   +0    UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${PM_COUNTER_FILE}
#
#CB010938_A_B2_3_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_UE_Supporting_Invalid_Values
#    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_HAS_SPECIAL_ALGO_INVALID_DUMMY4}
#    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
#    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
#    Perform Exit Idle Mode    ue_id=1
#    Wait For Next Full Pm Interval
#    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
#    Verify Any Counters In File
#    ...    M55124C00025   +0    UE_CHIPSET_VENDOR_NUM_SUP
#    ...    M55124C00026   +0    UE_CHIPSET_VENDOR_NUM_SUP_ECHO
#    ...    M55124C00027   +1    UE_CHIPSET_VENDOR_RECV_ERR
#    ...    M55124C00028   +0    UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${PM_COUNTER_FILE}
#
#CB010938_A_B2_4_Successful_Exchange_Of_Chipset_And_RAN_Identification_Information_During_UE_Capability_Retrieval_UE_Missing_Dummy4_Structure
#    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_HAS_SPECIAL_ALGO_MISSING_DUMMY4}
#    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
#    Include UE Radio Capabilities in ICSReq    ue_id=1    ue_capabilities=auto
#    Perform Exit Idle Mode    ue_id=1
#    Wait For Next Full Pm Interval
#    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
#    Verify Any Counters In File
#    ...    M55124C00025   +0    UE_CHIPSET_VENDOR_NUM_SUP
#    ...    M55124C00026   +0    UE_CHIPSET_VENDOR_NUM_SUP_ECHO
#    ...    M55124C00027   +1    UE_CHIPSET_VENDOR_RECV_ERR
#    ...    M55124C00028   +0    UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${PM_COUNTER_FILE}



*** Keywords ***
Get SCF Id By Scout
    [Timeout]    3 minutes
    [Arguments]    ${bts_id}=${TESTLINE_NAME}    ${no_ute}=${False}
    scout_s.setup_scout    ${bts_id}
    ${scf_id}    scout_s.request_scf    use_scout_internal_id=${no_ute}
    Log to Console   scf id is: ${scf_id}
    [Return]    ${scf_id}
    [Teardown]    scout_s.teardown_scout_api
