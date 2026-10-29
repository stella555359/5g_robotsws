*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska , Dan Moldovan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa.lua
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_nia_nea_null.json
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-4
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***

${preferences}          ${CURDIR}/config/preferencesA_B1_3
${filename_f1_e1}       gnb_F1_E1_RRC.pcap

*** Test Cases ***
CB010938_A_B1_3_Activation_Of_Chipset_And_RAN_Identification_Exchange_Functionality_UE_Not_Supporting_SANSA

    Setup Custom UE Radio Capabilities    ue_id=2    ue_nr_capabilities=${CAPABILITIES_WITH_INFRA_INFO}
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
    Attach Ue    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Deregister Ue    ue_id=1-2
    Sleep    10s
    Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false

    Sleep    10s
     Setup wireshark     ${preferences}
     ###    Copy traces
     Copy trace  tshark    ${filename_f1_e1}
     ${ngap_file}  Run    cd ${OUTPUT_DIR}/${TEST_NAME}/tshark;ls core*

     Set Test Variable  ${filename_ngap}    ${ngap_file}
     Copy trace  tshark    ${filename_ngap}

#Verify in
#1. UE Capability Enquiry message for UE-1 does not contain Infra Info: bandEUTRA, ca-BandwidthClassDL-EUTRA, ca-BandwidthClassUL-1. EUTRA.
#2. UE Capability Information message fo UE-1 does not contain Infra Info: bandEUTRA, ca-BandwidthClassDL-EUTRA, ca-BandwidthClassUL-EUTRA.
#3. UE Capability Enquiry message for UE-2 contains Infra Info: bandEUTRA, ca-BandwidthClassDL-EUTRA, ca-BandwidthClassUL-EUTRA.
#4. UE Capability Information message fo UE-2 contains Infra Info: bandEUTRA, ca-BandwidthClassDL-EUTRA, ca-BandwidthClassUL-EUTRA, values
# ... have to be the same as in UE Capability Enquiry message for the same UE.

    Prepare NR RRC columns A_B1_3
    Check NR RRC

#5. UE Radio Capability Info Indication message for UE-1 does not 5. contain Infra Info.
#6. UE Radio Capability Info Indication message for UE-2 contains Infra Info and values are the same as in Enquiry and Information messages
# ... (points 3 and 4 for NR-RRC pcap).

    Prepare NGAP columns A_B1_3
    Check NGAP

