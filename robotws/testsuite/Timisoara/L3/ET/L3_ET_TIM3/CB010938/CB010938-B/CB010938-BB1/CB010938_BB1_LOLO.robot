*** Settings ***
Force Tags    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...           CONFIGURED    5G_RAN    SBTS00    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Radu Turcu
...              :contact: radu.turcu@nokia.com

Resource    ./../../CUDU_L2/common_setup_teardown.robot
Resource    ./../../CUDU_L2/common_log_capture.robot
Resource    ./../../Resources/CB009855_resource.robot
Resource     ./../../../resources/5G_SW_WRO_Keywords.robot
#Library      ta5g_setups_and_teardowns

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/Config
${SCF_PATH}          ${CURDIR}/Config
${IPHY_3T2F}         ${CURDIR}/Config/iphy_3T2F.xml
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2
${SCF_CB10938_BB1_gnb1}    ${SCF_PATH}/CB010938_GNB1.xml
${SCF_CB10938_BB1_gnb2}    ${SCF_PATH}/CB010938_GNB2.xml
${IPHY_4T6F}            ${CURDIR}/Config/iphy_4T6F.xml
${WTS_CFG_CB010938_BB1}           CB010938_basic_setup.cfg
${preferences_XNAP}        ${CURDIR}/Config/preferences_XNAP
#${HO_request}    (nr-rrc.c1 == 0) && (xnap.XnAP_PDU == 0)
${HO_request}      xnap.HandoverRequest_element

${HO_request_BTS}   (((((((((((((xnap) && (nr-rrc.bandEUTRA == 200)) && (nr-rrc.ca_BandwidthClassDL_EUTRA == 0)) &&
...    (nr-rrc.ca_BandwidthClassUL_EUTRA == 3)) && (nr-rrc.bandEUTRA == 201)) && (nr-rrc.ca_BandwidthClassDL_EUTRA == 0))
...    && (nr-rrc.ca_BandwidthClassDL_EUTRA == 0)) && (nr-rrc.ca_BandwidthClassUL_EUTRA == 4)) && (nr-rrc.bandEUTRA == 202))
...    && (nr-rrc.mAC_ParametersCommon.dummy == 0)) && (nr-rrc.burstLength == 1)) && (nr-rrc.maxSimultaneousResourceSetsPerCC == 5))
...    && (nr-rrc.maxConfiguredResourceSetsPerCC == 37)) && (nr-rrc.maxConfiguredResourceSetsAllCC == 12)

${UECapabilityEnquiry_Infra_Info_TCBB1}    nr-rrc.ueCapabilityEnquiry_element

*** Test Cases ***
TC01_CB010938_B_B1_UE_Inter_gNB_handover_between_gNBs_of_same_release_and_version_feature_enabled_in_both_source_and_target_gNBs
    [Documentation]
    ...    This user scenario describes the source and target gNB behavior during Xn handover (Intra frequency) for UE
    ...    with mac-ParametersCommon/dummy param set to supported.

    [Setup]       Run Keywords     Import Testline Variables For 2 GNBs
    ...           AND              Create Suite Directory
    ...           AND              Backup And Update Iphy Swconfig File    ${IPHY_4T6F}    ${RD}
    ...           AND              log to console    Send scf to gnb2...
    ...           AND              Full Commission SCF File Through Mplane With Admin    ${SCF_CB10938_BB1_gnb2}    1    10.0.1.3
    ...           AND              log to console    Send scf to gnb1...
    ...           AND              Full Commission SCF File Through Mplane With Admin    ${SCF_CB10938_BB1_gnb1}    1    10.0.1.2
    ...           AND              Reboot TL And Check Configured For 2 GNBs
    ...           AND              Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_CB010938_BB1}
    ...           AND              Sleep    60s    Wait for interGNB communication interface established stable
    ...           AND              Create Test Directory
    ...           AND              Suite Setup Start WTS For B6a
    ...           AND              Setup wireshark       ${preferences_XNAP}
    ...           AND              Sleep    60s    Wait for interGNB communication interface established stable
    ...           AND              Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND              Start Tcpdump On Remote Interface    alias=remote    log_filename_prefix=GNB2_IPcapture
                                   ...    log_dirpath=${OUTPUT_DIR}/tshark     ssh_ip=10.0.1.3
    ...           AND              Sleep    60s    Wait for wait for all traces

    [Teardown]    Run Keywords    Stop Tcpdump On Remote Interface
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Common Test Teardown 2

    Attach UE And Start Traffic For B6a    1
    Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition
    Sleep    60s    Wait for wait for all traces
    Verify Tcpdump Log    packet_filter=${HO_request_BTS}    number_of_messages=1      relation_symbol= ==
    Verify tshark
    ...     alias=remote
    ...     packet_filter=${UECapabilityEnquiry_Infra_Info_TCBB1}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT_DIR}/tshark/GNB2_IPcapture.pcap


*** Keywords ***

Setup wireshark
    [Arguments]       ${preferences}
    Run  chmod 777 /home/ute/.config/wireshark/preferences
    ${output1}  Run  cp -f ${preferences} /home/ute/.config/wireshark/preferences
    Should Not Contain  ${output1}  No such file or directory

Verify Ngap Messages
    [Documentation]    Verification of captured messages transfered with NGAP protocol (NG interface: between GnB and AMF, WTS eth3).
    ...                By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}


Attach UE And Start Traffic For B8a
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    #step1
    CB009855_resource.Check Whether UE In CA Mode    1    4
    Run Keyword And Continue On Failure    Start DL Traffic    1    12
    Run Keyword And Continue On Failure    Start UL Traffic    1    1
    Wait Untill Scell Activated    3    1
    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell
    Stop DL Traffic    1    12
    Stop UL Traffic    1    1
    Sleep    3s    wait traffic stop..
    Wait Untill Scell Deactivated    3    1

Attach UE And Start Traffic For B6a
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    #step1
    Run Keyword And Continue On Failure    Start DL Traffic    1    4
    Run Keyword And Continue On Failure    Start UL Traffic    1    1
    Sleep    10s    wait traffic average
    Traffic Display
#    Wait Untill Scell Activated    4    1
#    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell    1    4    600



Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition
    [Arguments]    ${ue_id}=1    ${target_pci}=58
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=10 phycell_id=${target_pci} nrsrp_nr=40
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Inter-eNB handover from EXT_ENB-2.4 to EXT_ENB-3.9 performed    timeout=3min
#    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell    1    4    600


Suite Setup Start WTS For B6a
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${WTS_CFG_CB010938_BB1}
    UE SIB Decoding Should Be Successful
#    Check All Cells Received SIB2


Modify Swconfig File Parameters for 2gnb
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x4B000F=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'

Traffic Display
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
    sleep    5s    #for traffic
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
