*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           CONFIGURED    CIT    RAN_5G_FDD    RAN_5G    PY310
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Sebastian Maslak, Przemyslaw Sas
...              :contact: sebastian.maslak@nokia.com

Resource    CB006127_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_scfc.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_x2_2nd_gnb.lua
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_6127_A1_A3_setup_configuration.json
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_suite_setup_delta.xml
...            AND             Setup X2 Link    initiator_device=1    complementary_device=3
...            AND             Perform Parameter Commissioning    parameter=actX2ConfigTransfer    value=true
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_scfc.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_test_end.xml
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***

CB006127_A_A3_CB007225_A_B1_B2_NSA_ANR_Partial_plan_activation
    [Tags]    SBTS00    SBTS23R1    SBTS22R4

    [Documentation]    This Test Case verifies That Gnb Sends X2AP EN-DC Configuration Transfer Reply.
    ...    Additionaly testcase verifies the gNB behaviour of triggering report NR-CGI measurements
    ...    on the cell selected based RSRQ thresholds. (A_A1)
    ...    This testcase verify the gNB-CU-CP behaviour (with NSA ANR enabled) when network plan update is received from CU-OAM. (A_A3)
    ...    Conflict indicates the violation of conditions as mentioned in 5G_CP_ARC_ALG_1379 while gNB-CU-CP process the network plan update.
    ...    5G_RAN_USR_RRM_4890 (A_A1)
    ...    5G_RAN_USR_RRM_4893 (A_A3)
    ...    Additionaly, this TC verifies that gNB sends X2AP EN-DC Configuration Transfer Reply with appropriate address when RAN Sharing is enabled
    ...    New plmn and its address are set in delta_7225_A_B2.json
    ...    Requested address cannot be the one that is used for X2
    ...    In reply message this new ip address must be assiged to the requested plmn

    ${Gnb_Tac}=  Get Admin Object Parameter Value    parameter_name=${FIVE_GS_TAC}    moc=${FIVE_GS_TAC_MOC}
    ${Gnb_X2_Address}=  Get Admin Object Parameter Value    parameter_name=${LOCAL_IP_ADDRESS}    moc=${LOCAL_IP_ADDRESS_MOC}
    Trigger X2ap Endc Configuration Transfer    enbid=1    source_enbid=0x12345    source_enb_plmnid=311:489    source_enb_tac=200
    ...                                         en_gnbid=2    target_gnb_tac=${Gnb_Tac}
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    packet_filter=${ENDC_CONFIGURATION_TRANSFER}
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    packet_filter=(${ENDC_CONFIGURATION_TRANSFER_RECEIVED}) && (s1ap.transportLayerAddressIPv4 == ${Gnb_X2_Address})

    Wait For Next Full Pm Interval
    Attach UE To Enb And Gnb And Perform HO    ue_id=1    cell_id=51
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    &{SECOND_CELL_NRREL}=    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{SECOND_CELL_NRREL}    mcc=311    mnc=489    mncLength=3    gNbId=1    gNbIdLength=22    lcrId=2
    Send Custom Ue Measurement Nr    id=1    meas_id=2    index=0    nrs_result=125:125:0    event=A5    phycell_id=150
    ...                       nrsrq_nr=125    srsrq_nr=17
    Verify Created NRADJNRCELL And NRREL Objects
    Verify Successful Inter Gnb Pscell Change
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  +1  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  +0  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  +1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  +1  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55147C01001  +1  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  +0  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  +1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  +1  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Attach UE To Enb And Gnb And Perform HO    ue_id=2    target_cell=2    cell_id=50
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  +0  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  +1  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  +1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  +1  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Prepare Environment For X2AP EN-DC Configuration Transfer Reply
    ${New_Ip_Addr}=  Get Admin Object Parameter Value From Sorted List
    ...    parameter_name=${LOCAL_IP_ADDRESS}    moc=${LOCAL_IP_ADDRESS_MOC}    index=1
    Trigger X2ap Endc Configuration Transfer    enbid=1    source_enbid=0x12345    source_enb_plmnid=999:999    source_enb_tac=200
    ...    en_gnbid=2    target_gnb_tac=${Gnb_Tac}
    Verify Ngap Messages    packet_filter=${ENDC_CONFIGURATION_TRANSFER}    number_of_messages=2
    Verify Ngap Messages    packet_filter=(${ENDC_CONFIGURATION_TRANSFER_RECEIVED}) && (s1ap.transportLayerAddressIPv4 == ${New_Ip_Addr})

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_6127_A1_A3_add_conflict_NRREL.json
    Check If Object Doesnt Exist   object_name=NRREL-2    moc=NRREL_A

*** Keywords ***
Verify Successful Inter Gnb Pscell Change
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_CHANGE_REQUIRED}
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_CHANGE_CONFIRM}
    Verify Ngap Messages    packet_filter=${SN_STATUS_TRANSFER} && ip.src == 10.0.1.2
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_ADDITION_REQUEST}
    Verify Loopback Messages    packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE} && nr-rrc.physCellId == 150
    Verify Loopback Messages    packet_filter=${X2AP_SGNB_RECONFIGURATION_COMPLETE}
    Verify Loopback Messages    packet_filter=${SN_STATUS_TRANSFER}
    Verify Ngap Messages    packet_filter=${X2AP_UE_CONTEXT_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Created NRADJNRCELL And NRREL Objects
    Wait For Object To Exist    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Wait For Object To Exist    object_name=NRCELL_A-2/NRREL_A-${NRREL_ID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    &{NRADJNRCELL}=    Get Managed Object    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A
    &{NRREL}=    Get Managed Object    object_name=NRCELL_A-2/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{NRREL}    mcc=${NRADJNRCELL.gnbPlmn.mcc}    mnc=${NRADJNRCELL.gnbPlmn.mnc}
    ...                            mncLength=${NRADJNRCELL.gnbPlmn.mncLength}    gNbId=3    gNbIdLength=${NRADJNRCELL.gNbIdLength}
    ...                            lcrId=${NRADJNRCELL.lcrId}
    Verify Created NRADJNRCELL Object    NRADJNRCELL=&{NRADJNRCELL}    mcc=311    mnc=489    mncLength=3    physCellId=150    cellDepType=SA+NSA
    ...                                  nrarfcn=636666    ssbFrequency=636576    gNbId=3    gNbIdLength=22    lcrId=1

Attach UE To Enb And Gnb And Perform HO
    [Arguments]    ${ue_id}    ${cell_id}    ${target_cell}=1
    Attach UE To Enb And Gnb    ue_id=${ue_id}    target_cell=${target_cell}
    Send Custom Ue Measurement Nr    id=${ue_id}    meas_id=2    index=0    nrs_result=125:125:0    event=A5    phycell_id=${cell_id}
    ...                              nrsrq_nr=68    srsrq_nr=17

Prepare GNB Tac And Ip Addresses Variables

Prepare Environment For X2AP EN-DC Configuration Transfer Reply
    Teardown Egate And Collect Logs    logs_dirpath=/home/ute/tempcfg
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_6127_A1_A3_EN_DC_configuration.json
    Trigger Site Reset
    Check Radios Availability
    Reach Onair    lua_cfg=${CURDIR}/../../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
