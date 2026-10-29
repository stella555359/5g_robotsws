*** Settings ***
Force Tags    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...           CONFIGURED    5G_RAN    SBTS00    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Resource    ../CUDU_L2/common_setup_teardown.robot
Resource    ../CUDU_L2/common_log_capture.robot
Resource    ../Resources/CB009855_resource.robot
Resource     ../../resources/scripts/libraries_instances.robot
Resource    CB010938_C_Keywords_And_Variables.robot

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/config
${RD}                0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2
${preferences_HO_request}    ${CURDIR}/config/preferences_HO_request
${force_reboot}      ${True}
@{LOG_NAME_LIST}     btslog    egatelog
${WTS_CFG_B6a}       wts_TC04_C_B2.cfg

*** Test Cases ***
TC04_CB010938_C_B2_Extended_chipset_version_supporting_UE_Inter_gNB_HO_between_gNBs_of_same_release_and_version_feature_enabled_in_source_and_target
    [Tags]     CRT

    [Documentation]
    ...    This user scenario describes the source and target gNB behavior during Xn handover (Intra frequency) for UE with mac-
    ...    ParametersCommon/dummy param set to supported. Note: This user scenario behavior is based on User Scenario IFHO-B#B11
    ...    Successful Intra-frequency Inter-gNB handover based on A3/A5 measurements (5G_RAN_USR_RRM_1416).

    [Setup]       Run Keywords     Import Testline Variables For 2 GNBs
    ...           AND              Create Suite Directory
    ...           AND              Backup And Update Iphy Swconfig File    ${custom-iphy-TC04-C_B2}    ${RD}
    ...           AND              log to console    Send scf to gnb2...
    ...           AND              Full Commission SCF File Through Mplane With Admin    ${custom-scf-gnb2-TC04-C_B2}    1    10.0.1.3
    ...           AND              log to console    Send scf to gnb1...
    ...           AND              Full Commission SCF File Through Mplane With Admin    ${custom-scf-gnb1-TC04-C_B2}    1    10.0.1.2
    ...           AND              Reboot TL And Check Configured For 2 GNBs
    ...           AND              Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_B6a}
    ...           AND              Sleep    60s    Wait for interGNB communication interface established stable
#    ...           AND              Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    ...           AND              Create Test Directory
    ...           AND              Suite Setup Start WTS For B6a
    ...           AND              Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND              Start Tcpdump On Remote Interface    alias=remote    log_filename_prefix=GNB2_IPcapture
                                   ...    log_dirpath=${OUTPUT_DIR}/tshark     ssh_ip=10.0.1.3

    [Teardown]    Run Keywords    Detach Ue Without Confirmation    ue_id=1    type=switch_off
    ...           AND             Stop Tcpdump On Remote Interface
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Backup And Update Iphy Swconfig File    ${iphy-init-TC04-C_B2}    ${RD}
    ...           AND             log to console    Send scf to gnb2...
    ...           AND             Full Commission SCF File Through Mplane With Admin    ${scf-gnb2-init-TC04-C_B2}    1    10.0.1.3
    ...           AND             log to console    Send scf to gnb1...
    ...           AND             Full Commission SCF File Through Mplane With Admin    ${scf-gnb1-init-TC04-C_B2}    1    10.0.1.2
    ...           AND             Reboot TL And Check Configured For 2 GNBs
    ...           AND             Common Test Teardown 2

    Wait For Next Full Pm Interval
    Attach UE And Start Traffic For B6a    1
    Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition

    Sleep    20s    Wait for collecting of all traces

    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...    M55124C00025   +1    UE_CHIPSET_VENDOR_NUM_SUP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE}

    Verify Any Counters In File
    ...    M55124C00026   +1    UE_CHIPSET_VENDOR_NUM_SUP_ECHO
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE}

    Report PM Counter    M55124C00025  1           Passed
	Report PM Counter    M55124C00026  1           Passed

    Setup wireshark       ${preferences_HO_request}
    Verify Tcpdump Log    packet_filter=${HO_request_chipset_infra_info_TC04}    number_of_messages=1     relation_symbol= >=

    Verify tshark
    ...     alias=remote
    ...     packet_filter=${UECapabilityEnquiry_Infra_Info_TC04}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT_DIR}/tshark/GNB2_IPcapture.pcap

    Verify tshark
    ...     alias=remote
    ...     packet_filter=${UECapabilityInformation_Chipset_Info_TC04}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT_DIR}/tshark/GNB2_IPcapture.pcap

    Verify tshark
    ...     alias=remote
    ...     packet_filter=${UERadioCapabilityInfoIndication_Chipset_Infra_Info_TC04}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT_DIR}/tshark/GNB2_IPcapture.pcap
