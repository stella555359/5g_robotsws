*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    SBTS00    SBTS23R1    CIT    SBTS23R2
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Michal Fluder
...              :contact: michal.fluder@nokia.com

Resource    CB006127_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_scfc.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_6127_A2_4_setup_configuration.json
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_suite_setup_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_xn_2nd_gnb.lua

Suite Teardown    Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_test_end.xml
...               AND             Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_scfc.xml

*** Variables ***
${MEASUREMENT_REPORT_WITH_CGI_REPORT_AND_PROPER_MNC_AND_MCC}=    ${RRC_MEASUREMENT_REPORT} && ${NRRRC_MCC} && ${NRRRC_MNC}
...                                                              && nr-rrc.cgi_Info_element && nr-rrc.physCellId ==
${MEASUREMENT_REPORT_WITH_PROPER_RSRQ_VALUE}=    ${RRC_MEASUREMENT_REPORT} && nr-rrc.measQuantityResults.rsrq == 125 && nr-rrc.physCellId ==
${RECONFIGURATION_REPORT_CGI}=    ${RRC_RECONFIGURATION} && nr-rrc.reportType == reportCGI && nr-rrc.cellForWhichToReportCGI ==

*** Test Cases ***
CB006127_A_A4_SA_ANR_Partial_plan_activation
    [Documentation]    Testcase verifies the gNB behaviour of triggering report NR-CGI measurements on the SA cell selected based on RSRQ threshold.
    ...    This testcase verifies if ANR relations over the limit (value of parameter maxNumAnrNrrelAllowed) are not added after
    ...    HO with report CGI (A_A2). This testcase checks if conflicting objects are not added during delta commissioning and not conflicting
    ...    objects are added (A_A4 partial plan activation).
    ...    5G_RAN_USR_RRM_6823 (A_A2)
    ...    5G_RAN_USR_RRM_6858 (A_A4)

    Wait For Next Full Pm Interval
    Attach Ue And Establish Pdu Session And Perfrom HO   ue_id=1    target_phycell_id=51
    ...                                                  pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Attach Ue And Establish Pdu Session And Perfrom HO   ue_id=2    target_phycell_id=51
    ...                                                  pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  +1  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  +0  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  +1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  +1  NRRCC_NRCGI_REPORT_RECV
    ...    M55153C00001  +2  ATT_HO_NRREL
    ...    M55153C00002  +2  SUCC_HO_NRREL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Created NRREL Object And Verify Traces For Reconfiguration With Report CGI And Measurement Report

    Attach Ue And Establish Pdu Session And Perfrom HO   ue_id=3    target_phycell_id=150
    ...                                                  pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  +0  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  +1  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  +1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  +1  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Wait For Object To Not Exist    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Verify Traces For Reconfiguration With Report CGI And Measurement Report And XN Inter gNB HO
    Try To Create Conflicting And Non Conflicting Objects And Check If Non Conflicting Are Created

*** Keywords ***
Attach Ue And Establish Pdu Session And Perfrom HO
    [Arguments]    ${ue_id}    ${target_phycell_id}    ${pass_regexp}
    Attach UE    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${ue_id}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=200
    Sleep    1s    reason=Waiting for delay request to be processed
    Send Custom Ue Measurement Nr    id=${ue_id}     meas_id=2    index=0    nrs_result=125:125:0    event=A5    phycell_id=${target_phycell_id}
    ...                       nrsrq_nr=125     srsrq_nr=17    pass_regexp=${pass_regexp}

Verify Traces For Reconfiguration With Report CGI And Measurement Report And XN Inter gNB HO
    Verify Tcpdump Log    packet_filter=${MEASUREMENT_REPORT_WITH_PROPER_RSRQ_VALUE} ${CELL_3}
    Verify Tcpdump Log    packet_filter=${MEASUREMENT_REPORT_WITH_CGI_REPORT_AND_PROPER_MNC_AND_MCC} ${CELL_3}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_CGI} ${CELL_3}    number_of_messages=1  relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST}
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}
    Verify Tcpdump Log    packet_filter=${XNAP_SN_STATUS_TRANSFER}
    Verify Tcpdump Log    packet_filter=${XNAP_UE_CONTEXT_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}  number_of_messages=1  relation_symbol= >=

Verify Created NRREL Object And Verify Traces For Reconfiguration With Report CGI And Measurement Report
    &{FIRST_CELL_NRREL} =    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{FIRST_CELL_NRREL}    mcc=311    mnc=489    mncLength=3    gNbId=1    gNbIdLength=22    lcrId=2
    Verify Tcpdump Log    packet_filter=${MEASUREMENT_REPORT_WITH_PROPER_RSRQ_VALUE} ${CELL_2}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${MEASUREMENT_REPORT_WITH_CGI_REPORT_AND_PROPER_MNC_AND_MCC} ${CELL_2}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_CGI} ${CELL_2}    number_of_messages=1  relation_symbol= >=

Try To Create Conflicting And Non Conflicting Objects And Check If Non Conflicting Are Created
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_with_conflicts_to_trigger_A4_scenario.json
    Check If Object Exists   object_name=NRADJGNB_A-3    moc=NRADJGNB_A
    Check If Object Exists   object_name=XNLINK_A-3    moc=XNLINK_A
    Check If Object Doesnt Exist   object_name=NRADJGNB_A-2    moc=NRADJGNB_A
