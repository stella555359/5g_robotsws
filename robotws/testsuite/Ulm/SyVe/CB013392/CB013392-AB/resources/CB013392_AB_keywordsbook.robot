*** Settings ***
Documentation   Keywordbook for CB013392-A
Library    OperatingSystem
Library    String
Library    XML        use_lxml=True
Library    Collections
Library    taf.sbts.oam.coam.admin           WITH NAME    admin
Library    taf.config.scf                    WITH NAME    scf
Library    taf.ue
Library    ute_tshark




Resource   ../../../resources/attenuator.robot
Resource   ../../../resources/iperf_processes.robot
Resource   ../../../resources/attenuator_scenario.robot
Resource   ../../../../resources/Common/coam_ulm.robot
Resource   ../../../../resources/Common/tcpdump.robot
Resource   ../../../../resources/Common/testline.robot
Resource   ../../../../resources/Common/gnb.robot
Resource   ../../../../resources/Common/connect.robot
Resource   ../../../resources/sqd64/common_keywords.robot
Resource   ../../../resources/scf_info.robot


*** Keywords ***
CB013392_A_TC02_Setup
    ${tc_log_dir}=   Get testcase log directory
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    common_keywords.Set MRBTS/NRBTS ID as Suite Variable
    common_keywords.Get SCF and Warn if Validate Plan Fail
    iperf_processes.Kill all iperf processes on Appserver and UE PC
    set test variable  ${PCell_ID}      12
    set test variable  ${PCell_frequenceNR}     78
    set test variable  ${SCell_ID}      3
    set test variable  ${SCell_frequenceNR}    66
    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id}  node_type=gnb
    attenuator_scenario.Set cell attenuation     ${PCell_ID}  ${20}
    attenuator_scenario.Set cell attenuation     ${SCell_ID}  ${70}
    taf.ue.Require Ue   UE_1  capabilities=UE_1
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${0}
    ${bts_distName}=    Collections.Get From List    ${bts_distNames}    ${0}
    set test variable  ${bts_distName}
    set test variable  ${nrbts_id_0}    ${bts_distName}
    ${PCI_PCell}=      Get gnb physCellId    ${gnb_id}  ${PCell_ID}
    Set Suite Variable       ${PCI_PCell}
    ${PCI_SCell}=      common_keywords.Get gnb physCellId    ${gnb_id}  ${SCell_ID}
    Set Suite Variable       ${PCI_SCell}
    Set Test Variable      ${actMeasurementProfReselForCA}     pcInSaUlCaSupported
    Set Test Variable      ${sCellOperationalMode}      dlAndUl
    Get Measurment Parameter Values
    Perform CB013392-AB Delta Commissioning   ${gnb_id}
    ${enb_alias}  connect.Setup OAM http Session  node_type=enb  node_id=${enb_id}
    admin.block_all_cells  rat=LTE  timeout=${30}  connection=${enb_alias}


CB013392_B_TC02_Setup
    ${tc_log_dir}=   Get testcase log directory
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    common_keywords.Set MRBTS/NRBTS ID as Suite Variable
    common_keywords.Get SCF and Warn if Validate Plan Fail
    iperf_processes.Kill all iperf processes on Appserver and UE PC
    set test variable  ${PCell_ID}      10
    set test variable  ${PCell_frequenceNR}     78
    set test variable  ${SCell_ID}      3
    set test variable  ${SCell_frequenceNR}    5
    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id}  node_type=gnb
    attenuator_scenario.Set cell attenuation     ${PCell_ID}  ${20}
    attenuator_scenario.Set cell attenuation     ${SCell_ID}  ${90}
    taf.ue.Require Ue   UE_2  capabilities=MTK
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${0}
    ${bts_distName}=    Collections.Get From List    ${bts_distNames}    ${0}
    set test variable  ${bts_distName}
    set test variable  ${nrbts_id_0}      ${bts_distName}
    ${PCI_PCell}=      common_keywords.Get gnb physCellId    ${gnb_id}  ${PCell_ID}
    Set Suite Variable       ${PCI_PCell}
    ${PCI_SCell}=      common_keywords.Get gnb physCellId    ${gnb_id}  ${SCell_ID}
    Set Suite Variable       ${PCI_SCell}
    Set test Variable      ${actMeasurementProfReselForCA}     pcInSaUlAndDlCaSupported
    Set test Variable      ${sCellOperationalMode}      dlOnly
    Get Measurment Parameter Values
    Perform CB013392_TMO_B_TC02 Delta Commissioning   ${gnb_id}


CB013392 A TC Teardown
    [Arguments]
    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump on TestPc   collector=${eth3_collector}
    Run Keyword And Ignore Error    taf.ue.Detach Ue   UE_1
    admin.UNblock_cell  dist_name=${bts_distName}/NRCELL-11  connection=${oam_alias}
    ${enb_alias}  connect.Setup OAM http Session  node_type=enb  node_id=${enb_id}
    admin.unblock_all_cells  rat=LTE  timeout=${30}  connection=${enb_alias}
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM Http Session    connection=${oam_alias}


CB013392 B TC Teardown
    [Arguments]
    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump on TestPc   collector=${eth3_collector}
    Run Keyword And Ignore Error    taf.ue.Detach Ue   UE_2
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM Http Session    connection=${oam_alias}


Get Measurment Parameter Values
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${oam_alias}=    connect.Setup OAM Http Session    node_id=${gnb_id}
    ${para_list_IAF2}         Create List
    ...      a1MeashoSsbRsrp      a2MeashoSsbRsrp    a2MeashoSsbRsrq   a3MeasSsbRsrp      a5MeasSsbRsrp
    ${Values_Value_list_IAF2}     admin.Get Parameter By Dist Name
    ...                                  dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...                                  parameter_list=${para_list_IAF2}
    ...                                  connection=${oam_alias}
    Set Suite Variable       ${Values_Value_list_IAF2}
    ${para_list_IEF1}         Create List    a3MeasSsbRsrp      a5MeasSsbRsrp
    ${Values_Value_list_IEF1}     admin.Get Parameter By Dist Name
    ...                                  dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1
    ...                                  parameter_list=${para_list_IEF1}
    ...                                  connection=${oam_alias}
    Set Suite Variable       ${Values_Value_list_IEF1}
    ${para_list_IRF2}         Create List      eutraB2MeashoRsrp    b2Threshold1hoRsrp
    ${Values_Value_list_IRF2}     admin.Get Parameter By Dist Name
    ...                                  dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-2
    ...                                  parameter_list=${para_list_IRF2}
    ...                                  connection=${oam_alias}
    Set Suite Variable       ${Values_Value_list_IRF2}


Perform CB013392-AB Delta Commissioning
    [Arguments]     ${gnb_id}
    Log To Console  ${\n}Prepare CB013392-A TC02 delta commissioning for gNB-${gnb_id}.
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${NIDD_VERSION}=    scf.Get Mo Attribute  ${bts_distName}   version
    Set Suite variable    ${NIDD_VERSION}
    ${nrbts_id}=  string.Fetch From Right  ${bts_distName}  -

    # Activate Cell Trace report for gNB
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actCellTraceReport    value=true
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actPCMDReport         value=true
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actBufferBasedSCellAddition         value=disabled

    # General parameters for CB013392
    scf.modify_scf_element   dist_name=${bts_distName}  p_name=actMeasurementProfReselForCA   value=${actMeasurementProfReselForCA}
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actMeasurementProfile    value=SA+NSA

    scf.add_element_to_scf  dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRREL-${sCell_ID}
    ...    p_name=sCellAdditionMethod   value=covBasedA1
    scf.add_element_to_scf  dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRREL-${sCell_ID}
    ...    p_name=sCellOperationalMode   value=${sCellOperationalMode}

    ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session  node_type=gnb  node_id=${gnb_id}
    set test variable  ${oam_alias}
    ${number_of_cells}   testline.Get Number Of Cells     cell_type=NRCEL   connection=${oam_alias}
    FOR   ${NRCELL}  IN RANGE  ${1}  ${number_of_cells}
      scf.modify_scf_element   dist_name=${bts_distName}/NRCELL-${NRCELL}  p_name=maxNumScellsDlFr1   value=${3}
    END

    scf.remove_list_from_scf      dist_name=${bts_distName}/NRDU-1   list_name=carrierAggregationSupportList
    ${carrierAggregationSupport_List}   Create List    ca_Fdd_Fdd   ca_Fr1Tdd_Any_Sa    ca_Fr1Tdd_Fdd_Sa_WithUl
    ...    ca_Fr1Tdd_Fdd_Sa      ca_Fr1Tdd_Sa
    scf.add_list_to_scf           dist_name=${bts_distName}/NRDU-1    list_name=carrierAggregationSupportList
    scf.add_elements_to_list    dist_name=${bts_distName}/NRDU-1
    ...    list_name=carrierAggregationSupportList   elements=${carrierAggregationSupport_List}

    scf.modify_scf_element   dist_name=${bts_distName}/NRDU-1  p_name=dlToUlContributionRatio    value=${50}
    scf.modify_scf_element   dist_name=${bts_distName}/NRDU-1  p_name=fr1UlCaPreferred    value=ulCaPreferred

    scf.remove_list_from_scf         dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasSCellAddSsbRsrp_List}   Create dictionary    a1HysteresisSCellAddSsbRsrp    0    a1ThresholdSCellAddSsbRsrpFDD   67
    ...    a1ThresholdSCellAddSsbRsrpTDD    68     a1TimeToTriggerSCellAddSsbRsrp      320ms
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a1MeasSCellAddSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=a1MeasSCellAddSsbRsrp   elements=${a1MeasSCellAddSsbRsrp_List}

    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=a2MeashoEnabledSA     value=rsrpCombined
    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=pMaxNROwnCell     value=31
    scf.remove_list_from_scf      dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=a2MeashoSsbRsrpSA
    ${a2MeashoSsbRsrpSA_List}   Create dictionary    a2HysteresishoSsbRsrpSA      16    a2HysteresisHoSsbRsrpVoNr   0
    ...    a2ThresholdhoSsbRsrpSA    60     a2ThresholdHoSsbRsrpVoNr   36     a2TimeToTriggerhoSsbRsrpSA     ms320
    ...    a2TimeToTriggerHoSsbRsrpVoNr     ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a2MeashoSsbRsrpSA
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=a2MeashoSsbRsrpSA
    ...    elements=${a2MeashoSsbRsrpSA_List}

    scf.remove_list_from_scf      dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=a2MeashoSsbRsrqSA
    ${a2MeashoSsbRsrqSA_List}   Create dictionary    a2HysteresishoSsbRsrqSA     0   a2ThresholdhoSsbRsrqSA    66
    ...    a2TimeToTriggerhoSsbRsrqSA     ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a2MeashoSsbRsrqSA
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=a2MeashoSsbRsrqSA
    ...    elements=${a2MeashoSsbRsrqSA_List}

    #Cell trace settings disable E1 F1
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    ...    target_mo_dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2
    scf.remove_mo_with_descendant_mos   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    scf.modify_scf_element   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2   p_name=traceE1Setting   value=none
    scf.modify_scf_element   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2   p_name=traceF1Setting   value=none

    ${tc_log_directory}=    Get testcase log directory
    scf.save_scf    ${tc_log_directory}/scf_gnb${gnb_id}_CB013392A_target.xml
    ${target_scf}=   Set Variable   ${tc_log_directory}/scf_gnb${gnb_id}_CB013392A_target.xml
    ${delta_scf}=    Set Variable   ${tc_log_directory}/delta_scf_gnb${gnb_id}_CB013392A_target.json
    scf.calculate_delta_scf  ${target_scf}  ${TL_scf_gnb${gnb_id}}  ${delta_scf}
    Log To Console    Perform delta commissioning for CB013392-A TC02 parameters...
    admin.Perform Delta Recommissioning
    ...    delta_file=${delta_scf}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    alias=${oam_alias}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    admin.block_cell  dist_name=${bts_distName}/NRCELL-11  connection=${oam_alias}


Perform CB013392_TMO_B_TC02 Delta Commissioning
    [Arguments]     ${gnb_id}
    Log To Console  ${\n}Prepare CB013392-A TC02 delta commissioning for gNB-${gnb_id}.
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${NIDD_VERSION}=    scf.Get Mo Attribute  ${bts_distName}   version
    Set Suite variable    ${NIDD_VERSION}
    ${nrbts_id}=  string.Fetch From Right  ${bts_distName}  -

    ${eNodeBId}=  scf_info.Get MRBTS-Id  enb_id=0

    # Activate Cell Trace report for gNB
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actCellTraceReport    value=true
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actPCMDReport         value=true

    #disable buffer based SCell Addition
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actBufferBasedSCellAddition    value=disabled
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actOverheatingAssistance    value=false
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=sCellActivationMethod    value=blind

    ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session  node_type=gnb  node_id=${gnb_id}
    set test variable  ${oam_alias}
    ${number_of_cells}   testline.Get Number Of Cells     cell_type=NRCEL   connection=${oam_alias}
    FOR       ${NRCELL}  IN RANGE  ${1}  ${number_of_cells}
        scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${NRCELL}     p_name=sCellDeactivationTimerGNB     value=infinity
    END

    # General parameters for CB013392
    scf.add_element_to_scf   dist_name=${bts_distName}  p_name=actMeasurementProfReselForCA   value=${actMeasurementProfReselForCA}
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actMeasurementProfile    value=SA+NSA

    scf.add_element_to_scf  dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRREL-${sCell_ID}
    ...    p_name=sCellAdditionMethod   value=covBasedA1
    scf.add_element_to_scf  dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRREL-${sCell_ID}
    ...    p_name=sCellOperationalMode   value=${sCellOperationalMode}

    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=a1MeasSCellAddEnabled     value=rsrp
    ${list_exists}=    scf.is_list_in_object    dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=a1MeasSCellAddSsbRsrp
    IF    ${list_exists}    scf.remove_list_from_scf    dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasSCellAddSsbRsrp_List}   Create dictionary    a1HysteresisSCellAddSsbRsrp    0    a1ThresholdSCellAddSsbRsrpFDD   67
    ...    a1ThresholdSCellAddSsbRsrpTDD    68     a1TimeToTriggerSCellAddSsbRsrp      320ms
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a1MeasSCellAddSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=a1MeasSCellAddSsbRsrp   elements=${a1MeasSCellAddSsbRsrp_List}

    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=a2MeashoEnabledSA     value=rsrpCombined
    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=pMaxNROwnCell     value=31
    scf.remove_list_from_scf      dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=a2MeashoSsbRsrpSA
    ${a2MeashoSsbRsrpSA_List}   Create dictionary    a2HysteresishoSsbRsrpSA      16    a2HysteresisHoSsbRsrpVoNr   0
    ...    a2ThresholdhoSsbRsrpSA    60     a2ThresholdHoSsbRsrpVoNr   36     a2TimeToTriggerhoSsbRsrpSA     ms320
    ...    a2TimeToTriggerHoSsbRsrpVoNr     ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a2MeashoSsbRsrpSA
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=a2MeashoSsbRsrpSA
    ...    elements=${a2MeashoSsbRsrpSA_List}

    ${list_exists}=    scf.is_list_in_object    dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=a2MeashoSsbRsrqSA
    IF    ${list_exists}    scf.remove_list_from_scf      dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=a2MeashoSsbRsrqSA
    ${a2MeashoSsbRsrqSA_List}   Create dictionary    a2HysteresishoSsbRsrqSA     0   a2ThresholdhoSsbRsrqSA    66
    ...    a2TimeToTriggerhoSsbRsrqSA     ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a2MeashoSsbRsrqSA
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=a2MeashoSsbRsrqSA
    ...    elements=${a2MeashoSsbRsrqSA_List}

    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=a5MeasEnabled     value=rsrp

    ${list_exists}=    scf.is_list_in_object    dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=measPrMaSAList
    IF    ${list_exists}    scf.remove_list_from_scf      dist_name=${bts_distName}/NRCELL-${PCell_ID}   list_name=measPrMaSAList
    ${measPrMaSA_List1}   Create dictionary    measPrPriority     4   nrMeasPrMaSADN    NRMEASPR_MA_SA-1
    ${measPrMaSA_List2}   Create dictionary    measPrPriority     5   nrMeasPrMaSADN    NRMEASPR_MA_SA-2
    ${measPrMaSA_List3}   Create dictionary    measPrPriority     100   nrMeasPrMaSADN    NRMEASPR_MA_SA-3
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=measPrMaSAList
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=measPrMaSAList
    ...    elements=${measPrMaSA_List1}
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=measPrMaSAList
    ...    elements=${measPrMaSA_List2}
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}     list_name=measPrMaSAList
    ...    elements=${measPrMaSA_List3}

    scf.add_element_to_scf   dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRREL-${SCell_ID}  p_name=sCellAdditionMethod   value=covBasedA1
    scf.add_element_to_scf   dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRREL-${SCell_ID}  p_name=sCellOperationalMode   value=dlOnly

    #modification on NRCELL--${PCell_ID}/NRHOIF-5 (5 hardcoded as NRHOIF-5 in initial SCF for N78,
    #only Cell 11 in the gNO-0, which is PowerClass2 to be used for verification purpose of this feature)
    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5     p_name=a3MeasEnabled     value=rsrp
    ${list_exists}=    scf.is_list_in_object    dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5   list_name=a3MeasSsbRsrp
    IF    ${list_exists}    scf.remove_list_from_scf
    ...    dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5   list_name=a3MeasSsbRsrp
     ${a3MeasSsbRsrp_List}   Create dictionary    a3HysteresisSsbRsrp     0   a3OffsetSsbRsrp    3
    ...    a3TimeToTriggerSsbRsrp     ms100
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5    list_name=a3MeasSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5     list_name=a3MeasSsbRsrp
    ...    elements=${a3MeasSsbRsrp_List}

    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5     p_name=a5MeasEnabled     value=rsrp
    ${list_exists}=    scf.is_list_in_object    dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5   list_name=a5MeasSsbRsrp
    IF    ${list_exists}    scf.remove_list_from_scf
    ...    dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5   list_name=a5MeasSsbRsrp
     ${a5MeasSsbRsrp_List}   Create dictionary    a5HysteresisSsbRsrp     0   a5Threshold1SsbRsrp    50
    ...    a5Threshold2SsbRsrp      80    a5TimeToTriggerSsbRsrp     ms100     a5TimeToTriggerSsbRsrpVoNr     ms100
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5    list_name=a5MeasSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}/NRHOIF-5     list_name=a5MeasSsbRsrp
    ...    elements=${a5MeasSsbRsrp_List}

    #modify SCell para a2MeasSCellRelEnabled to none
    scf.modify_scf_element  dist_name=${bts_distName}/NRCELL-${SCell_ID}    p_name=a2MeasSCellRelEnabled   value=none

    #enable B2MeashoEnabled=rsrp in NRHOIR-1 object
    scf.modify_scf_element      dist_name=${bts_distName}/NRHOIR-1      p_name=b2MeashoEnabled     value=rsrp
    scf.add_element_to_scf     dist_name=${bts_distName}/NRHOIR-1      p_name=b2Threshold1hoRsrp    value=60
    scf.add_element_to_scf     dist_name=${bts_distName}/NRHOIR-1      p_name=b2Threshold1hoRsrpVoNr     value=35
    scf.add_element_to_scf     dist_name=${bts_distName}/NRHOIR-1      p_name=b2Threshold1hoRsrq     value=50
    scf.add_element_to_scf     dist_name=${bts_distName}/NRHOIR-1      p_name=b2Threshold1hoRsrqVoNr     value=50
    scf.add_element_to_scf     dist_name=${bts_distName}/NRHOIR-1      p_name=eutraFreqQOffsetRange     value=0dB

    ${eutraB2MeashoRsrp_List}   Create dictionary    b2HysteresishoRsrp     2   b2HysteresishoRsrpVoNr    2
    ...    b2Threshold2hoRsrp     30      b2Threshold2hoRsrpVoNr      18
    ...    b2TimeToTriggerhoRsrp     ms480     b2TimeToTriggerhoRsrpVoNr     ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRHOIR-1    list_name=eutraB2MeashoRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRHOIR-1      list_name=eutraB2MeashoRsrp
    ...    elements=${eutraB2MeashoRsrp_List}

    ${eutraB2MeashoRsrqp_List}   Create dictionary    b2HysteresishoRsrq     0   b2HysteresishoRsrqVoNr    0
    ...    b2Threshold2hoRsrq     2      b2Threshold2hoRsrqVoNr      2
    ...    b2TimeToTriggerhoRsrq     ms480     b2TimeToTriggerhoRsrqVoNr     ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRHOIR-1    list_name=eutraB2MeashoRsrq
    scf.add_item_to_list          dist_name=${bts_distName}/NRHOIR-1      list_name=eutraB2MeashoRsrq
    ...    elements=${eutraB2MeashoRsrqp_List}

    #Cell trace settings disable E1 F1
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    ...    target_mo_dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2
    scf.remove_mo_with_descendant_mos   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    scf.modify_scf_element   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2   p_name=traceE1Setting   value=none
    scf.modify_scf_element   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2   p_name=traceF1Setting   value=none

    ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session  node_type=gnb  node_id=${gnb_id}
    set test variable  ${oam_alias}
    ${tc_log_directory}=    Get testcase log directory
    scf.save_scf    ${tc_log_directory}/scf_gnb${gnb_id}_CB013392B_TMO_target.xml
    ${target_scf}=   Set Variable   ${tc_log_directory}/scf_gnb${gnb_id}_CB013392B_TMO_target.xml
    ${delta_scf}=    Set Variable   ${tc_log_directory}/delta_scf_gnb${gnb_id}_CB013392B_TMO_target.json
    scf.calculate_delta_scf  ${target_scf}  ${TL_scf_gnb${gnb_id}}  ${delta_scf}
    Log To Console    Perform delta commissioning for CB013392-B TC02 parameters...
    admin.Perform Delta Recommissioning
    ...    delta_file=${delta_scf}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    alias=${oam_alias}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}


Start Data Transfer UL DL
    [Arguments]       ${ue_alias}
    taf.ue.Start Data Transfer    dt_name=DL1    ue_alias=${ue_alias}    direction=dl
    ...    duration=420s    protocol=tcp   max_segment_size=1300    packet_size=16k
    taf.ue.Start Data Transfer    dt_name=UL1    ue_alias=${ue_alias}    direction=ul
    ...    duration=420s    protocol=tcp   max_segment_size=1300    packet_size=16k


Verify CA triggered by A1 and RRCReconfiguration with correct MeasConfigs
    [Documentation]   verify:
    ...               1. Verify RRCReconfiguration with meas config mapped from IAF-2, as ue in PowerClass3
    ...               2. Verify CA after receiving A1 report
    [Arguments]       ${tcp_file}
    ${tc_log_directory}=  Get testcase log directory
    ${packet_filter}=    Set Variable   (nsetapx.asn1_MsgId == 21) && (nr-rrc.sCellToAddModList == 1)
    ${pdml_file}=    Set Variable       ${tc_log_directory}/UL_DL_CA_by_A1.pdml
    ute_tshark.read pcap and save to file    filename=${pdml_file}
    ...    packet_filter=${packet_filter}   output_type=pdml     pcap_file_path=${tcp_file}
    Verify RRCReconfiguration with meas config mapped from Power Class criterion      ${pdml_file}
    Verify CA after receiving A1 report      ${pdml_file}


Verify RRCReconfiguration with meas config mapped from Power Class criterion
    [Documentation]    check that configured Intra-freq A2, A3/A5 events in RRCReconfiguration msg,
    ...        maps measurement profile (NRMEASPR_IAF-2), as UE uses bandCombination n66&n78,
    ...        which is power class 3.
    [Arguments]       ${pdml_file}
    ${Xpath_MeasIdToAddMods}=    set variable      .//field[@name='nr-rrc.MeasIdToAddMod_element']
    ${Elements_MeasIdToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_MeasIdToAddMods}
    ${measIdToAddMods_length}=  Get length   ${Elements_MeasIdToAddMods}

    ${Xpath_measId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.measId']
    ${Elements_measIds}    XML.Get Elements    ${pdml_file}    ${Xpath_measId}
    ${Xpath_reportConfigId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_reportConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigId}
    ${Dict_measIdToAdd_reportConfigId}    Create Dictionary
    FOR   ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_measId}=     XML.Get Element attribute   ${Elements_measIds}[${i}]   showname
        ${Elements_reportConfigId}=     XML.Get Element attribute   ${Elements_reportConfigIds}[${i}]   showname
        Collections.Set To Dictionary    ${Dict_measIdToAdd_reportConfigId}  ${Elements_reportConfigId}   ${Elements_measId}
    END
    Log To Console      ${Dict_measIdToAdd_reportConfigId}
    ${Xpath_reportConfigToAddMods}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.ReportConfigToAddMod_element']
    ${Elements_reportConfigToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigToAddMods}

    ${Xpath_ReportConfigToAddMods_ConfigId}=      Catenate    SEPARATOR=//
    ...    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_ReportConfigToAddMods_ConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_ReportConfigToAddMods_ConfigId}
    ${Xpath_eventid}=      Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.eventId']
    ${Elements_eventIds}    XML.Get Elements    ${pdml_file}    ${Xpath_eventid}
    ${Dict_reportConfigId_eventId}    Create Dictionary
    FOR    ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_ReportConfigToAddMods_ConfigId}=     XML.Get Element attribute   ${Elements_ReportConfigToAddMods_ConfigIds}[${i}]   showname
        ${Elements_eventId}=     XML.Get Element attribute   ${Elements_eventIds}[${i}]   showname
        Collections.Set To Dictionary    ${Dict_reportConfigId_eventId}   ${Elements_eventId}     ${Elements_ReportConfigToAddMods_ConfigId}
        IF    "${Elements_eventId}" == "eventId: eventA2 (1)"      Verify IAF-2 A2 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA3 (2)"      Verify IAF-2 A3 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA5 (4)"      Verify IAF-2 A5 measConfigs    ${pdml_file}
    END
    Log To Console     ${Dict_reportConfigId_eventId}

    ${A2_reportConfigId}=      Get From Dictionary   ${Dict_reportConfigId_eventId}    eventId: eventA2 (1)
    ${A2event_meadId}=      Get From Dictionary   ${Dict_measIdToAdd_reportConfigId}    ${A2_reportConfigId}
    set test variable     ${A2event_meadId}


Verify IAF-2 A2 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA2 configured mapping correctly to the gnb configuration
    [Arguments]       ${pdml_file}
    ${IAF2_a2HysteresishoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2HysteresishoSsbRsrp']}
    ${IAF2_a2ThresholdhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2ThresholdhoSsbRsrp']}
    ${IAF2_a2TimeToTriggerhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2TimeToTriggerhoSsbRsrp']}

    ${Xpath_reportConfigToAddModA2}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA2_element']
    ${Xpath_Rsrp}=    set variable    field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A2measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA2}      ${Xpath_Rsrp}
    ${Element_A2measTriggerRsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_A2measTriggerRsrp}
    ${Element_A2measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A2measTriggerRsrp}[0]   show
    ${status_A2_rsrp}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A2measTriggerRsrp_show}"=="${IAF2_a2ThresholdhoSsbRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA2_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA2}    ${Xpath_hysteresis}
    ${Element_eventA2_hysteresis}    XML.Get Elements    ${pdml_file}    ${Xpath_eventA2_hysteresis}
    ${Element_eventA2_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA2_hysteresis}[0]   showname
    ${status_A2_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA2_hysteresis_showname}     ${IAF2_a2HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A2timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA2}     ${Xpath_timeToTrigger}
    ${Element_A2timeToTrigger}    XML.Get Elements    ${pdml_file}    ${Xpath_A2timeToTrigger}
    ${Element_A2timeToTrigger_showname}    XML.Get Element attribute   ${Element_A2timeToTrigger}[0]   showname
    ${status_A2_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A2timeToTrigger_showname}      ${IAF2_a2TimeToTriggerhoSsbRsrp}

    ${status_A2}=    evaluate    ${status_A2_rsrp} and ${status_A2_hysteresis} and ${status_A2_timeToTrigger}
    IF    not '${status_A2}'    Fail    A2 shall be configured by IAF-2 as ue in pc3, but it's not.


Verify IAF-2 A3 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA3 configured mapping correctly to the gnb configuration
    [Arguments]       ${pdml_file}
    ${IAF2_a3HysteresisSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a3MeasSsbRsrp'][0]['a3HysteresisSsbRsrp']}
    ${IAF2_a3OffsetSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a3MeasSsbRsrp'][0]['a3OffsetSsbRsrp']}
    ${IAF2_a3TimeToTriggerSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a3MeasSsbRsrp'][0]['a3TimeToTriggerSsbRsrp']}

    ${Xpath_reportConfigToAddModA3}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA3_element']
    ${Xpath_a3OffsetRsrp}=    set variable    field[@name='nr-rrc.measTriggerQuantityOffset.rsrp']
    ${Xpath_A3measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}      ${Xpath_a3OffsetRsrp}
    ${Element_A3measTriggerRsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_A3measTriggerRsrp}
    ${Element_A3measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A3measTriggerRsrp}[0]   show
    ${status_A3_rsrp}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A3measTriggerRsrp_show}"=="${IAF2_a3OffsetSsbRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA3_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}    ${Xpath_hysteresis}
    ${Element_eventA3_hysteresis}    XML.Get Elements    ${pdml_file}    ${Xpath_eventA3_hysteresis}
    ${Element_eventA3_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA3_hysteresis}[0]   showname
    ${status_A3_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA3_hysteresis_showname}     ${IAF2_a3HysteresisSsbRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A3timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}     ${Xpath_timeToTrigger}
    ${Element_A3timeToTrigger}    XML.Get Elements    ${pdml_file}    ${Xpath_A3timeToTrigger}
    ${Element_A3timeToTrigger_showname}    XML.Get Element attribute   ${Element_A3timeToTrigger}[0]   showname
    ${status_A3_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A3timeToTrigger_showname}      ${IAF2_a3TimeToTriggerSsbRsrp}

    ${status_A3}=    evaluate    ${status_A3_rsrp} and ${status_A3_hysteresis} and ${status_A3_timeToTrigger}
    IF    not '${status_A3}'    Fail    A3 shall be configured by IAF-2 as ue in pc3, but it's not.


Verify IAF-2 A5 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA5 configured mapping correctly to the gnb configuration
    [Arguments]       ${pdml_file}
    ${IAF2_a5HysteresishoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a5MeasSsbRsrp'][0]['a5HysteresisSsbRsrp']}
    ${IAF2_a5Threshold1SsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a5MeasSsbRsrp'][0]['a5Threshold1SsbRsrp']}
    ${IAF2_a5Threshold2SsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a5MeasSsbRsrp'][0]['a5Threshold2SsbRsrp']}
    ${IAF2_a5TimeToTriggerhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a5MeasSsbRsrp'][0]['a5TimeToTriggerSsbRsrp']}

    ${Xpath_reportConfigToAddModA5}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA5_element']
    ${Xpath_Threshold1Rsrp}=    set variable    field[@name='nr-rrc.a5_Threshold1']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold1Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_A5measTriggerThreshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold1Rsrp}[0]   show
    ${status_A5_rsrp1}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold1Rsrp_show}"=="${IAF2_a5Threshold1SsbRsrp}"

    ${Xpath_Threshold2Rsrp}=    set variable    field[@name='nr-rrc.a5_Threshold2']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold2Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_A5measTriggerThreshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold2Rsrp}[0]   show
    ${status_A5_rsrp2}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold2Rsrp_show}"=="${IAF2_a5Threshold2SsbRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA5_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}    ${Xpath_hysteresis}
    ${Element_eventA5_hysteresis}    XML.Get Elements    ${pdml_file}    ${Xpath_eventA5_hysteresis}
    ${Element_eventA5_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA5_hysteresis}[0]   showname
    ${status_A5_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA5_hysteresis_showname}      ${IAF2_a5HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A5timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}     ${Xpath_timeToTrigger}
    ${Element_A5timeToTrigger}    XML.Get Elements    ${pdml_file}    ${Xpath_A5timeToTrigger}
    ${Element_A5timeToTrigger_showname}    XML.Get Element attribute   ${Element_A5timeToTrigger}[0]   showname
    ${status_A5_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A5timeToTrigger_showname}       ${IAF2_a5TimeToTriggerhoSsbRsrp}

    ${status_A5}=    evaluate    ${status_A5_rsrp1} and ${status_A5_rsrp2} and ${status_A5_hysteresis} and ${status_A5_timeToTrigger}
    IF    not '${status_A5}'    Fail    A5 shall be configured by IAF-2 as ue in pc3, but it's not.


Verify CA after receiving A1 report
    [Documentation]    check that sCell added as expected DL directions
    [Arguments]       ${pdml_file}
    ${Xpath_sCellToAddModList}=    set variable
    ...    .//field[@name='nr-rrc.rrcReconfiguration_element']//field[@name='nr-rrc.sCellToAddModList']

    ${Xpath_physCellId}=    set variable      field[@name='nr-rrc.physCellId']
    ${Xpath_sCell_physCellId}=    Catenate    SEPARATOR=//    ${Xpath_sCellToAddModList}      ${Xpath_physCellId}
    ${Element_sCell_physCellId}    XML.Get Elements    ${pdml_file}    ${Xpath_sCell_physCellId}
    ${Element_sCell_physCellId_show}    XML.Get Element attribute   ${Element_sCell_physCellId}[0]   show
    ${status_sCell_physCellId}  Run Keyword And Return Status    Should Be True
    ...   "${Element_sCell_physCellId_show}"=="${PCI_SCell}"
    IF    not '${status_sCell_physCellId}'    Fail    sCell ${PCI_SCell} expected but ${Element_sCell_physCellId_show} added

    ${Xpath_downlinkConfigCommon}=    set variable      field[@name='nr-rrc.downlinkConfigCommon_element']
    ${Xpath_uplinkConfigCommon}=    set variable      field[@name='nr-rrc.uplinkConfigCommon_element']
    ${Xpath_frequenceNR}=    set variable      field[@name='nr-rrc.FreqBandIndicatorNR']
    ${Xpath_sCell_downlink_frequenceNR}=    Catenate    SEPARATOR=//
    ...    ${Xpath_sCellToAddModList}      ${Xpath_downlinkConfigCommon}      ${Xpath_frequenceNR}
    ${Xpath_sCell_uplink_frequenceNR}=    Catenate    SEPARATOR=//
    ...    ${Xpath_sCellToAddModList}      ${Xpath_uplinkConfigCommon}      ${Xpath_frequenceNR}
    Verify CA sCell downlink frequency      ${pdml_file}     ${Xpath_sCell_downlink_frequenceNR}
    IF   "${sCellOperationalMode}"=="dlAndUl"
    ...    Verify CA sCell uplink frequency        ${pdml_file}     ${Xpath_sCell_uplink_frequenceNR}


Verify CA sCell downlink frequency
    [Arguments]       ${pdml_file}     ${Xpath_downlink}
    ${Element_sCell_downlink_frequenceNR}    XML.Get Elements    ${pdml_file}    ${Xpath_downlink}
    ${Element_sCell_downlink_frequenceNR_show}    XML.Get Element attribute   ${Element_sCell_downlink_frequenceNR}[0]   show
    ${status_sCell_downlink_frequenceNR}  Run Keyword And Return Status    Should Be True
    ...   "${Element_sCell_downlink_frequenceNR_show}"=="${SCell_frequenceNR}"
    IF    not '${status_sCell_downlink_frequenceNR}'    Fail    Scell downlink frequence wrong.


Verify CA sCell uplink frequency
    [Arguments]       ${pdml_file}     ${Xpath_uplink}
    ${Element_sCell_uplink_frequenceNR}    XML.Get Elements    ${pdml_file}    ${Xpath_uplink}
    ${Element_sCell_uplink_frequenceNR_show}    XML.Get Element attribute   ${Element_sCell_uplink_frequenceNR}[0]   show
    ${status_sCell_uplink_frequenceNR}  Run Keyword And Return Status    Should Be True
    ...   "${Element_sCell_uplink_frequenceNR_show}"=="${SCell_frequenceNR}"
    IF    not '${status_sCell_uplink_frequenceNR}'    Fail    Scell uplink frequence wrong.


Verify A2 report and RRCReconfiguration with correct MeasConfigs activated after A2
    [Documentation]   verify:
    ...               1. Verify A2 report received, rsrq in the report satisfies respCombined secondary quantity evaluation
    ...               2. Verify RRCReconfiguration with meas config correctly mapped, i.e.
    ...                  A1 from IAF-2 as ue in pc3
    ...                  inter-Freq A3/A5 IEF-1 selection is based on target frequency in NRHOIF as pc2
    ...                  inter-RAT B2d from IRF-2 as ue in pc3
    [Arguments]       ${tcp_file}
    ${tc_log_directory}=  Get testcase log directory
    ${packet_filter}=    Set Variable   nsetapx.asn1_MsgId == 23
    ${A2_pdml_file}=    Set Variable       ${tc_log_directory}/A2_Report.pdml
    ute_tshark.read pcap and save to file    filename=${A2_pdml_file}
    ...    packet_filter=${packet_filter}   output_type=pdml     pcap_file_path=${tcp_file}
    ${packet_filter}=    Set Variable   nsetapx.asn1_MsgId == 21
    ${RRCReconfig_pdml_file}=    Set Variable       ${tc_log_directory}/RRCReconfig_byA2.pdml
    ute_tshark.read pcap and save to file    filename=${RRCReconfig_pdml_file}
    ...    packet_filter=${packet_filter}   output_type=pdml     pcap_file_path=${tcp_file}
    Verify A2 report received with rsrq satisfies respCombined evaluation     ${A2_pdml_file}
    Verify RRCReconfiguration with meas config A1 A3/A5 B2 correctly mapped      ${RRCReconfig_pdml_file}


Verify A2 report received with rsrq satisfies respCombined evaluation
     [Documentation]   Verify A2 report received, where the rsrq in the report satisfies respCombined secondary quantity
     ...               evaluation, i.e. rsrq shall satisfy a2ThresholdhoSsbRsrq value in IAF-2
    [Arguments]       ${pdml_file}
    ${Xpath_measId}=    set variable
    ...      .//field[@name='nr-rrc.measurementReport_element']//field[@name='nr-rrc.measId']
    ${MeasId_list}    XML.Get Elements    ${pdml_file}    ${Xpath_measId}
    ${MeasId}  Get From List  ${MeasId_list}  -1
    ${MeasId_showname}     XML.Get Element attribute   ${MeasId}    showname
    IF    '${A2event_meadId}'!='${MeasId_showname}'    Fail    A2 report expected but received not A2.

    ${Xpath_measResult}=     set variable   .//field[@name='nr-rrc.measurementReport_element']//field[@name='nr-rrc.measResultServingCell_element']
    ${Xpath_physCellIds}=      Catenate    SEPARATOR=//    ${Xpath_measResult}    field[@name='nr-rrc.physCellId']
    ${Elements_physCellId}    XML.Get Elements    ${pdml_file}    ${Xpath_physCellIds}
    ${Xpath_physCellIds_rsrp}=      Catenate    SEPARATOR=//    ${Xpath_measResult}
    ...     field[@name='nr-rrc.cellResults_element']//field[@name='nr-rrc.measQuantityResults.rsrp']
    ${Elements_physCellIds_rsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_physCellIds_rsrp}
    ${Xpath_physCellIds_rsrq}=      Catenate    SEPARATOR=//    ${Xpath_measResult}
    ...     field[@name='nr-rrc.cellResults_element']//field[@name='nr-rrc.measQuantityResults.rsrq']
    ${Elements_physCellIds_rsrq}    XML.Get Elements    ${pdml_file}    ${Xpath_physCellIds_rsrq}
    ${Elements_physCellId_length}=  Get length   ${Elements_physCellId}
    FOR   ${i}    IN RANGE    0    ${Elements_physCellId_length}
        ${physCellId}=     XML.Get Element attribute   ${Elements_physCellId}[${i}]    show
        ${Element_physCellIds_rsrp_show}=     XML.Get Element attribute   ${Elements_physCellIds_rsrp}[${i}]    show
        ${Element_physCellIds_rsrq_show}=     XML.Get Element attribute   ${Elements_physCellIds_rsrq}[${i}]    show
        IF    "${physCellId}" == "${PCI_PCell}"    Verify A2 report satisfies rsrpCombined criterion
        ...      ${Element_physCellIds_rsrp_show}      ${Element_physCellIds_rsrq_show}
    END


Verify A2 report satisfies rsrpCombined criterion
     [Documentation]    Verify in A2 report: ${rsrp} recieved < IAF2_a2ThresholdhoSsbRsrp and
     ...                ${rsrq} recieved < IAF2_a2ThresholdhoSsbRsrp
     [Arguments]       ${rsrp}     ${rsrq}
    ${IAF2_a2ThresholdhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2ThresholdhoSsbRsrp']}
    IF    '${rsrp}'>'${IAF2_a2ThresholdhoSsbRsrp}'
    ...    Fail    A2 report rsrp value "${rsrp}" not small than IAF-2 a2ThresholdhoSsbRsrp="${IAF2_a2ThresholdhoSsbRsrp}".
    ${IAF2_a2ThresholdhoSsbRsrq}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrq'][0]['a2ThresholdhoSsbRsrq']}
    IF    '${rsrq}'>'${IAF2_a2ThresholdhoSsbRsrq}'
    ...    Fail    A2 report rsrq value "${rsrq}" not small than IAF-2 a2ThresholdhoSsbRsrq="${IAF2_a2ThresholdhoSsbRsrq}"..


Verify RRCReconfiguration with meas config A1 A3/A5 B2 correctly mapped
    [Documentation]    Verify RRCReconfiguration with meas config correctly mapped, i.e.
    ...                A1 from IAF-2 as ue in pc3
    ...                inter-Freq A3/A5 IEF-1 selection is based on target frequency in NRHOIF as pc2
    ...                inter-RAT B2d from IRF-2 as ue in pc3
    [Arguments]       ${pdml_file}
    ${Xpath_MeasIdToAddMods}=    set variable      .//field[@name='nr-rrc.measIdToAddModList']//field[@name='nr-rrc.MeasIdToAddMod_element']
    ${Elements_MeasIdToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_MeasIdToAddMods}
    ${measIdToAddMods_length}=  Get length   ${Elements_MeasIdToAddMods}

    ${Xpath_measId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.measId']
    ${Elements_measIds}    XML.Get Elements    ${pdml_file}    ${Xpath_measId}
    ${Xpath_reportConfigId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_reportConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigId}
    ${Dict_measIdToAdd_reportConfigId}    Create Dictionary
    FOR   ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_measId}=     XML.Get Element attribute   ${Elements_measIds}[${i}]   showname
        ${Elements_reportConfigId}=     XML.Get Element attribute   ${Elements_reportConfigIds}[${i}]   showname
        Collections.Set To Dictionary    ${Dict_measIdToAdd_reportConfigId}   ${Elements_measId}  ${Elements_reportConfigId}
    END
    Log To Console      ${Dict_measIdToAdd_reportConfigId}
    ${Xpath_reportConfigToAddMods}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.ReportConfigToAddMod_element']
    ${Elements_reportConfigToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigToAddMods}
    ${Xpath_ReportConfigToAddMods_ConfigId}=      Catenate    SEPARATOR=//
    ...    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_ReportConfigToAddMods_ConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_ReportConfigToAddMods_ConfigId}
    ${Xpath_eventid}=      Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.eventId']
    ${Elements_eventIds}    XML.Get Elements    ${pdml_file}    ${Xpath_eventid}
    ${Dict_reportConfigId_eventId}    Create Dictionary
    FOR    ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_ReportConfigToAddMods_ConfigId}=     XML.Get Element attribute   ${Elements_ReportConfigToAddMods_ConfigIds}[${i}]   showname
        ${Elements_eventId}=     XML.Get Element attribute   ${Elements_eventIds}[${i}]   showname
        Collections.Set To Dictionary    ${Dict_reportConfigId_eventId}   ${Elements_ReportConfigToAddMods_ConfigId}   ${Elements_eventId}
        IF    "${Elements_eventId}" == "eventId: eventA1 (0)"      Verify IAF-2 A1 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA3 (2)"      Verify IEF-1 A3 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA5 (4)"      Verify IEF-1 A5 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventB2 (1)"      Verify IRF-2 B2 measConfigs    ${pdml_file}
    END
    Log to Console     ${Dict_reportConfigId_eventId}


Verify IAF-2 A1 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA1 configured mapping correctly to the IAF-2
    [Arguments]       ${pdml_file}
    ${IAF2_a1HysteresishoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a1MeashoSsbRsrp'][0]['a1HysteresishoSsbRsrp']}
    ${IAF2_a1ThresholdhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a1MeashoSsbRsrp'][0]['a1ThresholdhoSsbRsrp']}
    ${IAF2_a1TimeToTriggerhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a1MeashoSsbRsrp'][0]['a1TimeToTriggerhoSsbRsrp']}

    ${Xpath_reportConfigToAddModA1}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA1_element']
    ${Xpath_Rsrp}=    set variable    field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A1measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA1}      ${Xpath_Rsrp}
    ${Element_A1measTriggerRsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A1measTriggerRsrp}
    ${Element_A1measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A1measTriggerRsrp}   show
    ${status_A1_rsrp}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A1measTriggerRsrp_show}"=="${IAF2_a1ThresholdhoSsbRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA1_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA1}    ${Xpath_hysteresis}
    ${Element_eventA1_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA1_hysteresis}
    ${Element_eventA1_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA1_hysteresis}   showname
    ${status_A1_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA1_hysteresis_showname}     ${IAF2_a1HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A1timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA1}     ${Xpath_timeToTrigger}
    ${Element_A1timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A1timeToTrigger}
    ${Element_A1timeToTrigger_showname}    XML.Get Element attribute   ${Element_A1timeToTrigger}   showname
    ${status_A1_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A1timeToTrigger_showname}      ${IAF2_a1TimeToTriggerhoSsbRsrp}

    ${status_A1}=    evaluate    ${status_A1_rsrp} and ${status_A1_hysteresis} and ${status_A1_timeToTrigger}
    IF    not ${status_A1}    Fail    A1 shall be configured by IAF-2 as ue in pc3, but it's not.

Verify IEF-1 A3 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA3 configured mapping correctly to the IEF-1
    [Arguments]       ${pdml_file}
    ${IEF1_a3HysteresisSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a3MeasSsbRsrp'][0]['a3HysteresisSsbRsrp']}
    ${IEF1_a3OffsetSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a3MeasSsbRsrp'][0]['a3OffsetSsbRsrp']}
    ${IEF1_a3TimeToTriggerSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a3MeasSsbRsrp'][0]['a3TimeToTriggerSsbRsrp']}

    ${Xpath_reportConfigToAddModA3}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA3_element']
    ${Xpath_a3OffsetRsrp}=    set variable    field[@name='nr-rrc.measTriggerQuantityOffset.rsrp']
    ${Xpath_A3measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}      ${Xpath_a3OffsetRsrp}
    ${Element_A3measTriggerRsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A3measTriggerRsrp}
    ${Element_A3measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A3measTriggerRsrp}   show
    ${status_A3_rsrp}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A3measTriggerRsrp_show}"=="${IEF1_a3OffsetSsbRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA3_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}    ${Xpath_hysteresis}
    ${Element_eventA3_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA3_hysteresis}
    ${Element_eventA3_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA3_hysteresis}   showname
    ${status_A3_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA3_hysteresis_showname}     ${IEF1_a3HysteresisSsbRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A3timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}     ${Xpath_timeToTrigger}
    ${Element_A3timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A3timeToTrigger}
    ${Element_A3timeToTrigger_showname}    XML.Get Element attribute   ${Element_A3timeToTrigger}   showname
    ${status_A3_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A3timeToTrigger_showname}      ${IEF1_a3TimeToTriggerSsbRsrp}

    ${status_A3}=    evaluate    ${status_A3_rsrp} and ${status_A3_hysteresis} and ${status_A3_timeToTrigger}
    IF    not ${status_A3}    Fail    A3 shall be configured by IEF-1 as target frequency in NRHOIF in pc2, but it's not.


Verify IEF-1 A5 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA5 configured mapping correctly to the IEF-1
    [Arguments]       ${pdml_file}
    ${IEF1_a5HysteresishoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a5MeasSsbRsrp'][0]['a5HysteresisSsbRsrp']}
    ${IEF1__a5Threshold1SsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a5MeasSsbRsrp'][0]['a5Threshold1SsbRsrp']}
    ${IEF1__a5Threshold2SsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a5MeasSsbRsrp'][0]['a5Threshold2SsbRsrp']}
    ${IEF1__a5TimeToTriggerhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IEF1[0]['parameters']['a5MeasSsbRsrp'][0]['a5TimeToTriggerSsbRsrp']}

    ${Xpath_reportConfigToAddModA5}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA5_element']
    ${Xpath_Threshold1Rsrp}=    set variable    field[@name='nr-rrc.a5_Threshold1']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold1Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A5measTriggerThreshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold1Rsrp}   show
    ${status_A5_rsrp1}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold1Rsrp_show}"=="${IEF1__a5Threshold1SsbRsrp}"

    ${Xpath_Threshold2Rsrp}=    set variable    field[@name='nr-rrc.a5_Threshold2']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold2Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A5measTriggerThreshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold2Rsrp}   show
    ${status_A5_rsrp2}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold2Rsrp_show}"=="${IEF1__a5Threshold2SsbRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA5_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}    ${Xpath_hysteresis}
    ${Element_eventA5_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA5_hysteresis}
    ${Element_eventA5_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA5_hysteresis}   showname
    ${status_A5_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA5_hysteresis_showname}      ${IEF1_a5HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A5timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}     ${Xpath_timeToTrigger}
    ${Element_A5timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A5timeToTrigger}
    ${Element_A5timeToTrigger_showname}    XML.Get Element attribute   ${Element_A5timeToTrigger}   showname
    ${status_A5_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A5timeToTrigger_showname}       ${IEF1__a5TimeToTriggerhoSsbRsrp}

    ${status_A5}=    evaluate    ${status_A5_rsrp1} and ${status_A5_rsrp2} and ${status_A5_hysteresis} and ${status_A5_timeToTrigger}
    IF    not ${status_A5}    Fail    A5 shall be configured by IEF-1 as target frequency in NRHOIF in pc2, but it's not.


Verify IRF-2 B2 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventB2 configured mapping correctly to the IRF-2
    [Arguments]       ${pdml_file}
    ${IRF2_b2HysteresishoRsrp}=   Set Variable
    ...   ${Values_Value_list_IRF2[0]['parameters']['eutraB2MeashoRsrp'][0]['b2HysteresishoRsrp']}
    ${IRF2_b2Threshold2hoRsrp}=   Set Variable
    ...   ${Values_Value_list_IRF2[0]['parameters']['eutraB2MeashoRsrp'][0]['b2Threshold2hoRsrp']}
    ${IRF2_b2TimeToTriggerhoRsrp}=   Set Variable
    ...   ${Values_Value_list_IRF2[0]['parameters']['eutraB2MeashoRsrp'][0]['b2TimeToTriggerhoRsrp']}
    ${oam_alias}   connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ${IRF2_b2Threshold1hoRsrp}   coam_ulm.Get SCF Single Value From Current Xml File   alias=${oam_alias}
    ...   dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IRF-2   parameter=b2Threshold1hoRsrp

    ${Xpath_reportConfigToAddModB2}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventB2_element']
    ${Xpath_Rsrp1}=    set variable
    ...    field[@name='nr-rrc.b2_Threshold1']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_B2measTriggerRsrp1}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModB2}      ${Xpath_Rsrp1}
    ${Element_B2measTriggerRsrp1}    XML.Get Element    ${pdml_file}    ${Xpath_B2measTriggerRsrp1}
    ${Element_B2measTriggerRsrp1_show}    XML.Get Element attribute   ${Element_B2measTriggerRsrp1}   show
    ${status_B2_rsrp1}  Run Keyword And Return Status    Should Be True
    ...   "${Element_B2measTriggerRsrp1_show}"=="${IRF2_b2Threshold1hoRsrp}"

    ${Xpath_Rsrp2}=    set variable
    ...    field[@name='nr-rrc.b2_Threshold2EUTRA']//field[@name='nr-rrc.measTriggerQuantityEUTRA.rsrp']
    ${Xpath_B2measTriggerRsrp2}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModB2}      ${Xpath_Rsrp2}
    ${Element_B2measTriggerRsrp2}    XML.Get Element    ${pdml_file}    ${Xpath_B2measTriggerRsrp2}
    ${Element_B2measTriggerRsrp2_show}    XML.Get Element attribute   ${Element_B2measTriggerRsrp2}   show
    ${status_B2_rsrp2}  Run Keyword And Return Status    Should Be True
    ...   "${Element_B2measTriggerRsrp2_show}"=="${IRF2_b2Threshold2hoRsrp}"

    ${Xpath_hysteresis}=    set variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventB2_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModB2}    ${Xpath_hysteresis}
    ${Element_eventB2_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventB2_hysteresis}
    ${Element_eventB2_hysteresis_showname}    XML.Get Element attribute   ${Element_eventB2_hysteresis}   showname
    ${status_B2_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventB2_hysteresis_showname}     ${IRF2_b2HysteresishoRsrp}dB

    ${Xpath_timeToTrigger}=    set variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_B2timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModB2}     ${Xpath_timeToTrigger}
    ${Element_B2timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_B2timeToTrigger}
    ${Element_B2timeToTrigger_showname}    XML.Get Element attribute   ${Element_B2timeToTrigger}   showname
    ${status_B2_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_B2timeToTrigger_showname}      ${IRF2_b2TimeToTriggerhoRsrp}

    ${status_B2}=    evaluate    ${status_B2_rsrp1} and ${status_B2_rsrp2} and ${status_B2_hysteresis} and ${status_B2_timeToTrigger}
    IF    not ${status_B2}    Fail    B2 shall be configured by IRF-2 as ue in pc3, but it's not.


Stop all the traffic
    [Documentation]    stop all the running traffic
    @{Data_alias}   create list    DL1    UL1
    common_keywords.Stop Data Transfers    data_alias=${Data_alias}
