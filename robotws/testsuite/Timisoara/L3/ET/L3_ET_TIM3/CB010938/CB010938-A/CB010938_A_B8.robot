*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska; Dan Moldovan
...              :contact: katarzyna.wisniewska@nokia.com

Resource    CB010938_Keywords_And_Variables.robot
Variables   ./config/Capabilities.py



Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_SA_deployment_null.json
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sa.lua
...             AND             Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-4
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords  Perform Parameter Commissioning    parameter=actChipsetAndRanInfoExchange  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

#${preferences}          ${CURDIR}/config/preferencesA_B2_1
${filename_f1_e1}       gnb_F1_E1_RRC.pcap

*** Test Cases ***
CB010938_A_B8_1_Runtime_Update_Of_UE_Chipset_Info
    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_NO_SPECIAL_ALGO}
    Attach UE And Establish PDU Session And Release UE Context    ue_id=1    pdu_id=1    gw_id=1
    Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${UE_SUPPORTS_AND_NO_SPECIAL_ALGO_UPDATED_DUMMY4}
    Attach UE With Registration Type    ue_id=1    registration_type=MobilityRegistrationUpdting
    Sleep    5s

#    Setup wireshark     ${preferences}
     ###    Copy traces
     Copy trace  tshark    ${filename_f1_e1}
     ${ngap_file}  Run    cd ${OUTPUT_DIR}/${TEST_NAME}/tshark;ls core*

     Set Test Variable  ${filename_ngap}    ${ngap_file}
     Copy trace  tshark    ${filename_ngap}

### NR RRC ###
#   1.UE Capability Enquiry is present twice and contains Infra Info with correct value
#   2.UE Capability Information is present twice. Both messages has dummy=supported and different chipset version.
#   Infra info is absent.

    Prepare NR RRC columns A_b2

    Check NR RRC A_B8

    ### NGAP ###
#   3. Initial Context Setup Request, Registration accept message is present and UE Capabilities IE is absent.
#   4. VUERadioCapabilityInfoIndication message is present twice. In both messages Infra Info is absent, dummy=supported,
#    but dummy4 structures have different values. The same as in UE CapabilityInformation messages.

    Prepare NGAP columns A_B2

    Check NGAP A_B8
