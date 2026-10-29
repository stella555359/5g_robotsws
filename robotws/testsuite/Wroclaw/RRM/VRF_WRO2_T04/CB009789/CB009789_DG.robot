*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_2vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G    PY310    CRT
...           NoResUsage    RF50


Documentation    :copyright: Nokia
...              :authors: Piotr Pondel
...              :contact: piotr.pondel@nokia.com

Resource    ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB009789_Keywords.robot
Resource    ./resources/CB009789_variables.robot
Library    ./resources/CB009789.py
Library    ta5g_ue_measurements
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_testline_management
Library    ta5g_cell_operations

Suite Setup    Run Keywords    Enable Cloud
...            AND             Run Os Command    cmd=pip install --upgrade ta5g_setups_and_teardowns
...            AND             Get Scfc File Aic    output_filepath=${OUTPUT_DIR}/initial_commissioning_cu.xml
...            AND             Get Scfc File Du Aic    path=${OUTPUT_DIR}
...            AND             Get Iphy Xml File
...            AND             Run Keyword If    ${SETUP_TL}
...                                Deploy Multi Cpcell
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Update And Put Iphy Xml Aic    input_filepath=${CURDIR}/config/iphy.xml
...                                output_dirpath=${OUTPUT_DIR}/initial_commissioning
...            AND             Perform Commissioning Vcu Aic    path_to_plan_file=${CURDIR}/config/default/SCFC_CU_CB009789.xml
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                                scfc_filepath=${CURDIR}/config/default/SCFC_DU1_CB009789.xml
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                                scfc_filepath=${CURDIR}/config/default/SCFC_DU2_CB009789.xml    vdu=2
...            AND             Run Keyword If    ${ADDITIONAL_RESET}    Trigger Test Line Reset
...            AND             Start Additional Vm Ethernet Interfaces
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/airphone/egate_4c_tdd_sansa_aic.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Setup Test Line Aic
...                                   perform_full_commissioning=${RESTORE_DEFAULT_CONFIG}
...                                   iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                                   scfc_filepath_cu=${OUTPUT_DIR}/initial_commissioning_cu.xml
...                                   scfc_filepath_du1=${OUTPUT_DIR}/initial_commissioning_du1.xml
...                                   scfc_filepath_du2=${OUTPUT_DIR}/initial_commissioning_du2.xml
...                                   output_dirpath=${OUTPUT_DIR}/initial_commissioning
...               AND             Stop Additional Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs


Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Test Cases ***
CB009789_DG_5GC002198_A_B1_1_ENDC_PCI_Resolution_And_Neighbour_Relation_Addition_Intra_GNB_UE_Based_Without_MeNB_Coordination_No_SRB3
    [Documentation]    This user scenario describes the gNB behaviour for the automatic addition of new Inter Frequency,
    ...                Intra-gNB Intra-NR Neighbour for EN-DC without MeNB coordination

    [Setup]    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND              Perform Parameter Commissioning Aic    parameter=srb3SupportEnabled    value=false

    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=${NSA_UE1_CELL1}
    Attach Ue To Enb And Gnb    ue_id=${NSA_UE1_CELL1}
    Wait For postSgnbAdditionAckProcedure Finish On gNB And Check UE Capabilities

    Send Custom Ue Measurement Nr    id=${NSA_UE1_CELL1}    meas_id=3    event=A2    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Custom Ue Measurement Nr    id=${NSA_UE1_CELL1}    meas_id=6    event=A5    srsrq_nr=1
    ...                              srsrp_nr=1    ssinr_nr=1    phycell_id=53    nrsrq_nr=122    nrsrp_nr=122
    ...                              nsinr_nr=122    pass_regexp=Proxy \\(eNB 2 cell 4\\) reported successful RA

    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}
    Verify Ngap Messages             packet_filter=${DRX_SETUP}
    ...                              number_of_messages=1    relation_symbol=>=
    Verify Ngap Messages             packet_filter=${X2AP_SGNB_ADDITION_REQUEST}
    ...                              number_of_messages=1    relation_symbol=>=
    Verify Ngap Messages             packet_filter=${X2AP_SGNB_MODIFICATION_CONFIRM}
    ...                              number_of_messages=1    relation_symbol=>=
    Wait For Object To Exist Aic     dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-${EXPECTED_NRREL_OBJECTID_1ST}

    [Teardown]    Run Keywords      ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${NSA_UE1_CELL1}
    ...           AND               Perform Parameter Commissioning Aic
    ...                                 parameter=srb3SupportEnabled
    ...                                 value=true
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009789_DG_5GC002198_A_B2_2_ENDC_PCI_Resolution_And_Neighbour_Relation_Addition_Inter_GNB_UE_Based_With_MeNB_Coordination_SRB3
    [Documentation]    This user scenario describes the gNB behaviour for the automatic addition of new Inter Frequency,
    ...                Inter-gNB Neighbour for EN-DC without MeNB coordination

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue To Enb And Gnb         ue_id=${NSA_UE2_CELL1}
    Wait For postSgnbAdditionAckProcedure Finish On gNB And Check UE Capabilities

    Send Custom Ue Measurement Nr    id=${NSA_UE2_CELL1}    meas_id=3    event=A2    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Custom Ue Measurement Nr    id=${NSA_UE2_CELL1}    meas_id=6    event=A5    srsrq_nr=1    srsrp_nr=1
    ...                              ssinr_nr=1    phycell_id=52    nrsrq_nr=122    nrsrp_nr=122    nsinr_nr=122
    ...                              pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA

    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}
    Verify Ngap Messages             packet_filter=${DRX_SETUP}
    ...                              number_of_messages=1    relation_symbol=>=
    Verify Ngap Messages             packet_filter=${X2AP_SGNB_ADDITION_REQUEST}
    ...                              number_of_messages=1    relation_symbol=>=
    Verify Ngap Messages             packet_filter=${X2AP_SGNB_MODIFICATION_CONFIRM}
    ...                              number_of_messages=1    relation_symbol=>=
    Wait For Object To Exist Aic     dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-${EXPECTED_NRREL_OBJECTID_2ND}

    [Teardown]    Run Keywords      ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${NSA_UE2_CELL1}
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009789_DG_5GC001296_A_B3_1_Successful_Intra_Frequency_Intra_Du_PCI_Resolution_And_Neighbour_Addition_SRB3
    [Documentation]    This test case verifies the gNB behaviour when UE or gNB have SRB3 capability
    ...                and UE report A5 measurement from second cell of the same gNB which is not exist in NRREL.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE To Enb And Gnb  ue_id=${NSA_UE3_CELL1}
    Wait For postSgnbAdditionAckProcedure Finish On gNB And Check UE Capabilities

    Send A5 Event To Trigger Ho    ue_id=${NSA_UE3_CELL1}    phycell_id=51
    ...                            pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA

    Wait For Object To Exist Aic    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-${FIRST_NRREL_ID}
    ...                             timeout=${NRREL_OBJECT_CREATION_TIME}

    Verify Ngap Messages    packet_filter=${SgNBModifReq_RRCReconf}
    Verify Ngap Messages    packet_filter=${SgNBModif_RRC_ReconfCompl}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NRRRC_Reconf_reconfigurationWithSync}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NRRRC_ReconfComp}
    Verify Tcpdump Log    packet_filter=${NRRRC_MeasReap} && ${NRRRC_MCC} && ${NRRRC_MNC}

    [Teardown]    Run Keywords      ta5g_ue_mobility.Detach Ue    ue_id=${NSA_UE3_CELL1}
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009789_DG_5GC001085_D1_Intra_frequency_inter_gNB_neighbor_relation_addition_no_existing_Xn_success_case
    [Documentation]    Testcase verifies the situation where the ANR functionality is activated
    ...                and there unknown PCIs only in the measurement report, one of them meets
    ...                the pre-defined threshold for consideration for ANR based addition of NRREL.
    ...                There is no existing Xn connection between vDUs. Intra-frequency inter-gNB handover
    ...                using this NRREL is possible.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Wait Until Keyword Succeeds    2x    100ms    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE1_CELL1}
    Establish Pdu Session With Traffic    ue_id=${SA_UE1_CELL1}    pdu_id=1    gw_id=1

    Send A5 Event To Trigger Ho    ue_id=${SA_UE1_CELL1}    phycell_id=54
    ...                            pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Verify Created NRADJECELL And NRRELE Objects
    Verify Created XNLINK And NRADJGNB Objects

    Verify Ngap Messages           packet_filter=${XN_SETUP_RESPONSE}    number_of_messages=1
    Verify Ngap Messages           packet_filter=${XNAP_HANDOVER_REQUEST} && nr-rrc.drx_Config == 1
    ...                            number_of_messages=1    relation_symbol=>=
    Verify Ngap Messages           packet_filter=${XNAP_HANDOVER_REQUEST_ACK} && ${RRC_RECONFIGURATION}
    ...                            number_of_messages=1
    Verify Ngap Messages           packet_filter=${NGAP_PATH_SWITCH_REQUEST}    number_of_messages=1
    Verify Ngap Messages           packet_filter=${NGAP_PATH_SWITCH_REQUEST_ACK}    number_of_messages=1

    [Teardown]    Run Keywords      Deregister Ue Without Confirmation    ue_id=${SA_UE1_CELL1}
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009789_DG_CB008239_A_B7_1_New_Inter_RAT_Neighbour_Object_Successful_Addition_To_Network_Plan_File
    [Documentation]    This user scenario describes the gNB behaviour for the automatic addition
    ...    of new inter-RAT Neighbour for SA
    ...    5G_RAN_USR_RRM_14657, 5G_RAN_USR_RRM_14658

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue And Establish Pdu Session And Send B2 Measurement   ue_id=${SA_UE2_CELL1}   meas_id=7
    ...    pass_regexp=UE1\: Successful handover from EXT_ENB-2.1 to ENB-3.1
    Verify Traces For EUTRA CGI Measurement Report Configuration And InterRAT HO
    Verify Created NRADJECELL And NRRELE Objects

    Attach Ue And Establish Pdu Session And Send B2 Measurement   ue_id=${SA_UE3_CELL1}   meas_id=7
    ...    pass_regexp=UE2\: Successful handover from EXT_ENB-2.1 to ENB-3.1
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}    timeout=120  number_of_messages=2

   	[Teardown]    Run Keywords      Deregister Ue Without Confirmation    ue_id=${SA_UE2_CELL1}
   	...           AND               Deregister Ue Without Confirmation    ue_id=${SA_UE3_CELL1}
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
