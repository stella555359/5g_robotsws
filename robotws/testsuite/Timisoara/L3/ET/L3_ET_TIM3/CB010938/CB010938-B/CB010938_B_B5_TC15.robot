*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: George Medesan
...              :contact: george.medesan@nokia.com

Resource     CB010938_B_Keywords_And_Variables.robot

Suite Setup      Run Keywords    Get Scfc File    output_filepath=/home/ute/initial_commissioning.xml
...              AND             Setup Custom SCF    scf=${custom-scf-TC15}
...              AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...              AND             Reach OnAir    lua_cfg=${CURDIR}/config/basic_setup_TC15.cfg   check_edaemon_port=True
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup       Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown   Send Full Commissioning    input_filepath=/home/ute/initial_commissioning.xml

*** Test Cases ***
TC15_CB010938_B_B5_Inter_RAT_Handover_from_5G_to_LTE_of_vendor_information_exchange_supporting_UE
    [Documentation]
    ...    This user scenario describes the source gNB behavior during Inter RAT handover from 5G to LTE for UE with
    ...    mac-ParametersCommon/dummy param set to supported.

    Attach UE And Establish PDU Session    ue_id=1    pdu_id=2    gw_id=1
    Perform InterRAT HO
    Verify Tcpdump Log    packet_filter=${HandoverRequiredFilter}