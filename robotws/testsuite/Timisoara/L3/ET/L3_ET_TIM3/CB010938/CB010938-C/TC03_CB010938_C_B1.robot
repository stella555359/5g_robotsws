*** Settings ***

Force Tags    CLOUD_5G_I_MP_AP_LO
...           VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    5G_RAN    SBTS00    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Resource     CB010938_C_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Start Vm Ethernet Interface    if_name=eth3:TCE        ip_with_mask=10.0.1.11/24
...             AND             Setup Custom IPHY   iphy=${custom-iphy-TC03-C_B1}
...             AND             Setup Custom SCF    scf=${custom-scf-TC03-C_B1}
...             AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach Onair Without Confirmation    lua_cfg=${CURDIR}/config/wts_TC03_C_B1.cfg    check_edaemon_port=True
                                ...    x2_link_start=${false}
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords     Stop Vm Ethernet Interface    if_name=eth3:TCE         ip_with_mask=10.0.1.11/24
...               AND              Setup Custom IPHY   iphy=${iphy-init}
...               AND              Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND              Wait for all cells to be enabled    timeout=480
...               AND              Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${preferences_PCMD}        ${CURDIR}/config/preferences_PCMD

*** Test Cases ***
TC03_CB010938_C_B1_Successful_exchange_of_Chipset_and_RAN_identification_information_from_supporting_UEs_during_UE_Capability_retrieval_ALT

    [Tags]     CRT

    [Documentation]     This user scenario describes the gNB UE Radio Capability retrieval procedure to successfully exchange Chipset and RAN
    ...                 Identification information between UE and Network for supporting UEs. The UE indicates extended chipset version type
    ...                 and sends extended chipset version in UECapabilityInformation. This user scenario is mainly focused on streaming of
    ...                 PCMD UE Information Record from gNB-CU-CP.

    [Setup]       Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND              Start TCE
    ...           AND              Start PCMD

    [Teardown]    Run Keywords    Detach Ue Without Confirmation    ue_id=1    type=switch_off
    ...           AND             Stop PCMD
    ...           AND             Stop TCE in UTE
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    timeout=25
    Sleep     5s

    Setup wireshark       ${preferences_PCMD}
    Verify Tcpdump Log    packet_filter=${UECapabilityEnquiry_Infra_Info}    number_of_messages=1     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UECapabilityInformation_Extended_Chipset_Info}    number_of_messages=1     relation_symbol= >=
    Verify Ngap Messages    packet_filter=${UERadioCapabilityInfoIndication_Extended_Chipset_Info}    number_of_messages=1

    Verify tshark
    ...     alias=PCMD
    ...     packet_filter=${PCMD_extended_chipset}
    ...     pass_criteria= ==1
    ...     pcap_file_path=${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd.pcap
    Sleep   10
