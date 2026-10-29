*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    QC_358523   QCD_MN_RAN    QCP_RAN_ET

Documentation    :copyright: Nokia

Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot
Resource     ../keywords/logging.robot
Variables   ../5GC001167/feature_variables.py
Library      ta5g_iphy
Library      taf.ul.ettf.setups
Library      testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${scfc}=                                          scfc_AC_B2b.xml

${F1AP_SCELL_TO_ADD_MOD_LIST}=                    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 52 &&
                                             ...  nr-rrc.physCellId == 55

${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=      ngap.pDUSessionResourceModifyResponseTransfer &&
                                             ...  ngap.qosFlowIdentifier == 1

${NR_RRC_A2_MEASUREMENT_FOR_SCELL1_RELEASE}=      (((nr-rrc.a2_Threshold == 1)&& (nr-rrc.reportConfigId == 9)) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 41)) && (nr-rrc.measObjectId == 3)


${NR_RRC_A2_MEASUREMENT_FOR_SCELL2_RELEASE}=      (((nr-rrc.a2_Threshold == 1) && (nr-rrc.reportConfigId == 9)) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 41)) && (nr-rrc.measObjectId == 4)

${NR_RRC_A1_MEASUREMENT_FOR_SCELL_CHANGE}=         (nr-rrc.a1_Threshold == 0) && (nr-rrc.reportConfigId == 10) &&
                                             ...   (nr-rrc.measObjectId == 2) && (nr-rrc.measId == 12)
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640-AC-B2b_CA_Mobility_support_IODT_TDD_TDD_SCell_Addition_Target_PCell_Measurement_Lower_Than_High_Threshold_FDD
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_AC_B2b.xml
      ...         AND          With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
      ...         AND          With Gnb Configuration    commissioning=${scfc}
      ...         AND          Wait For Environment To Stabilize
      ...         AND          Start Default Logging    output_dirpath=${OUTPUT_DIR}
      ...         AND          Reach Onair    lua_cfg=${CURDIR}/config/basic_n71_n41_2A.cfg
    Register UE And Start Data Traffic    ue_id=1    cell_id=4
    Verify ICS On NGAP
    Perform Intra gNB Handover To Cell 1     ue_id=1    a2_meas_id=1    a3_meas_id=5    phycell_id=50   a3_rsrp=75
    Verify Successful 3CC FTT On NGAP And F1AP Messages
    Verify A2 Measurement For SCell Release Is Configured At The UE For Each Of The SCells
    Verify A1 Measurement For SCell Change Is Configured At The UE
    Display DL Traffic Scheduling On All SCells
     [Teardown]    Run Keywords    Stop Default Logging
     ...    AND         Add Scout Scf Id To Test Data

*** Keywords ***
Perform Intra gNB Handover To Cell 1
    [Arguments]    ${ue_id}    ${a2_meas_id}=1    ${a3_meas_id}=5    ${phycell_id}=50    ${a3_rsrp}=75
    Send A2 Measurement To Reconfigure A3    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}
    Send A3 Measurement To Perform UE Handover    ue_id=${ue_id}    phycell_id=${phycell_id}    a3_meas_id=${a3_meas_id}    a3_rsrp=${a3_rsrp}

Send A3 Measurement To Perform UE Handover
    [Arguments]    ${ue_id}     ${phycell_id}    ${a3_meas_id}    ${a3_rsrp}=75
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a3_meas_id} phycell_id\=${phycell_id} nrsrp_nr\=${a3_rsrp} event\=A3
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-*.* to EXT_ENB-*.* performed

Register UE And Start Data Traffic
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}=1    ${gw_id}=1    ${qfi}=1    ${mbps}=175
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} mbps=${mbps} dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} mbps=${mbps} dir=ul
    Wait For Traffic To Stabilize

Verify Successful 3CC FTT On NGAP And F1AP Messages
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}   number_of_messages=${number_of_messages}

Display DL Traffic Scheduling On All SCells
    [Arguments]    ${ue_id}=1    ${scell}=0-3
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} scell=${scell}
        ...          pass_regexp=UE-1: NR PDSCH Throughput

Verify A2 Measurement For SCell Release Is Configured At The UE For Each Of The SCells
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log      packet_filter=${NR_RRC_A2_MEASUREMENT_FOR_SCELL1_RELEASE}   number_of_messages=${number_of_messages}
    Verify Tcpdump Log      packet_filter=${NR_RRC_A2_MEASUREMENT_FOR_SCELL2_RELEASE}   number_of_messages=${number_of_messages}

Verify A1 Measurement For SCell Change Is Configured At The UE
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log      packet_filter=${NR_RRC_A1_MEASUREMENT_FOR_SCELL_CHANGE}   number_of_messages=${number_of_messages}

Wait For Environment To Stabilize
    Sleep    180s
