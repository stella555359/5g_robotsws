*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    5G_RAN    SBTS00    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Resource     CB010938_B_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Log to console    Start Vm Ethernet Interfaces
...             AND             Run    ${VM_ETH_IFACES}
...             AND             Run    ${VM_ETH_IFACES_2}
...             AND             Setup Custom IPHY   iphy=${custom-iphy-TC11-C_PMO}
...             AND             Setup Custom SCF    scf=${custom-scf-TC11-B_PMO}
...             AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/wts_TC11_B_PMO.cfg    check_edaemon_port=True
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords     Setup Custom IPHY   iphy=${iphy-init}
...               AND              Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND              Wait for all cells to be enabled    timeout=480
...               AND              Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${preferences_HO_request}        ${CURDIR}/config/preferences_HO_request

*** Test Cases ***
TC11_CB010938_PMO_User_Scenario_Infra_vendor_info_mismatch_after_UE_enters_the_cell_via_Xn_handover_ERR_ROBUSTNESS

    [Tags]     CRT

    [Documentation]     This user scenario describes exchange of Chipset and RAN Identification, as a result of Infra vendor info mismatch after
    ...                 UE enters the cell via Xn handover.

    [Teardown]    Detach Ue Without Confirmation    ue_id=1    type=switch_off

    Wait For Next Full Pm Interval
    Execute Egate Command   cmd=gnb_param id=3 sib1_period=80    pass_regexp=eNB 3 cell 1: SystemInformationBlockType1-NR updated
    Sleep     5s
    Execute Egate Command   cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Sleep     5s
    Attach Ue    ue_id=1
    Sleep     5s
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Establish Pdu Session   ue_id=1    pdu_id=1    gw_id=1
    Sleep     5s
    Execute Egate Command   cmd=ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=30
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Sleep     5s
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Execute Egate Command   cmd=ue_capability_enquiry id=1 band_eutra=200,201,202 ca_bandwidth_class_dl_eutra=5,0,0 ca_bandwidth_class_ul_eutra=5,5,5
    Sleep     5s
    Execute Egate Command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep     15s

    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...    M55124C00027   +2    UE_CHIPSET_VENDOR_RECV_ERR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}

    Verify Any Counters In File
    ...    M55124C00028   +1    UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}

    Report PM Counter    M55124C00027  2           Passed
    Report PM Counter    M55124C00028  1           Passed

    Setup wireshark       ${preferences_HO_request}
    Verify Tcpdump Log    packet_filter=${HO_request_chipset_infra_info_TC11}    number_of_messages=1     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UECapabilityEnquiry_Infra_Info_TC11}    number_of_messages=1     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UECapabilityInformation_Chipset_Info_TC11}    number_of_messages=1     relation_symbol= >=
    Verify Ngap Messages    packet_filter=${UERadioCapabilityInfoIndication_Chipset_Infra_Info_TC11}    number_of_messages=1

    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
