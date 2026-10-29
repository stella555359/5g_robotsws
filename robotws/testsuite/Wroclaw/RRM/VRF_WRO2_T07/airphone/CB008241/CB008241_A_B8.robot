*** Settings ***
Force Tags    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CLOUD_5G_I_LO_AP_LO    CONFIGURED    RAN_5G_TDD
...           RAN_5G    PY310    SBTS00    SBTS23R1    CRT    SBTS23R2    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :contact: marcin.plawny@nokia.com

Resource    CB008241_Keywords.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Start NSA Vm Ethernet Interfaces
...            AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/../
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy_TDD_FDD.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_multi_anr.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scf_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_multi_anr_config.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop NSA Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...               AND             Wait For Testline Icmp Echo Replies And Ssh Services
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${OUTPUT_DIR}/../new_iphy.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008241_A_B8_Successful_Intra_Frequency_Intra_Du_NSA_HO_To_Inter_Frequency_Intra_Du_SA_ANR_Created_Object
    [Documentation]    This test case verifies NSA Intra Frequency Intra Gnb handover to NRREL that was created via CB008241 feature

    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=1    meas_id=5
    Wait And Verify Created NRREL Object    gnb_id=1
    Attach UE To Enb And Gnb    ue_id=11
    Wait For postSgnbAdditionAckProcedure Finish On gNB And Check UE Capabilities
    Send Custom Ue Measurement Nr    id=11    meas_id=3    event=A2    get_ue_meas_cfg=1
    ...                              srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    Sleep    3s  reason=Waiting for A5 measurement report setup
    Send Ue Measurement Nr    ue_id=11    meas_id=6    get_ue_meas_cfg=1    index=0    nrs_result=68:19:0    event=A5    phycell_id=51
    ...                       nrsrp_nr=68    srsrp_nr=19    srsrq_nr=19    pass_regexp=UE11: Proxy \\(eNB 2 cell 2\\) reported successful RA

    Verify Ngap Messages    packet_filter=${SgNBModifReq_NRCGI_MeasSetup}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${SgNBModifReq_ReconfigurationWithSync}
    Verify Ngap Messages    packet_filter=${SgNBModifConf_Prep_ReconfComp}
    Verify Ngap Messages    packet_filter=${SgNBModifReqAck_SCell_Change}
    Verify Ngap Messages    packet_filter=${SgNBModifConf_SCell_Change_Completed}

*** Variables ***
${SgNBAdditionReqWithCGIReportingENDC}=    ${X2AP_SGNB_ADDITION_REQUEST} && nr-rrc.nr_CGI_Reporting_ENDC == 0
${SgNBModifReq_NRCGI_MeasSetup}=    ${X2AP_SGNB_MODIFICATION_REQUIRED} && nr-rrc.cellForWhichToReportCGI == 51
${SgNBModifReq_ReconfigurationWithSync}=    ${X2AP_SGNB_MODIFICATION_REQUIRED} && ${RECONFIGURATION_WITH_SYNC} && x2ap.procedureCode == 30
...                                         && ${SPCELL_CONFIG_AND_PHYS_CELL_ID} && x2ap.radioNetwork == 0
${SgNBModifConf_Prep_ReconfComp}=    ${X2AP_SGNB_MODIFICATION_CONFIRM} && ${RRC_RECONFIGURATION_COMPLETE} && x2ap.MeNBtoSgNBContainer == 40
${SgNBModifConf_SCell_Change_Completed}=    ${X2AP_SGNB_MODIFICATION_CONFIRM} && !${RRC_RECONFIGURATION_COMPLETE}
${SgNBModifReqAck_SCell_Change}=    ${X2AP_SGNB_MODIFICATION_CONFIRM} && !(x2ap.RRC_Config_Ind == delta-config) && !x2ap.MeNBtoSgNBContainer
${SPCELL_CONFIG_AND_PHYS_CELL_ID}=    nr-rrc.spCellConfigCommon_element && nr-rrc.physCellId == 51

*** Keywords ***
Start NSA Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Stop NSA Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}

Wait For postSgnbAdditionAckProcedure Finish On gNB And Check UE Capabilities
    Verify Ngap Messages    packet_filter=${SgNBAdditionReqWithCGIReportingENDC}
