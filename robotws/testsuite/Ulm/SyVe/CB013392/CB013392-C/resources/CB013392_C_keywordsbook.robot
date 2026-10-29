*** Settings ***
Documentation   Keywordbook for CB013392-C
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
Resource   ../../../resources/enb.robot
Resource   ../../../resources/scf_info.robot
Resource   ../../../resources/attenuator_scenario.robot
Resource   ../../../../resources/Common/coam_ulm.robot
Resource   ../../../../resources/Common/tcpdump.robot
Resource   ../../../../resources/Common/testline.robot
Resource   ../../../../resources/Common/gnb.robot
Resource   ../../../../resources/Common/connect.robot
Resource   ../../../resources/sqd64/common_keywords.robot


*** Keywords ***
CB013392_C_TC04_Setup
    ${tc_log_dir}=   testline.Get Testcase Log Directory
    ${target_dir}=    testline.Get Test Suite Config Directory
    ${TL_scf_enb0}=     enb.Get SCF from eNB  enb_id=${enb_id}    resultDir=${target_dir}
    Set Test Variable    ${TL_scf_enb0}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    common_keywords.Set MRBTS/NRBTS ID as Suite Variable
    common_keywords.Get SCF and Warn if Validate Plan Fail
    iperf_processes.Kill all iperf processes on Appserver and UE PC
    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id}  node_type=gnb
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${enb_id}  node_type=enb
    attenuator_scenario.set cell attenuation     ${EnbCell_ID}    ${20}  node_id=${enb_id}  node_type=enb
    taf.ue.Require Ue   UE  capabilities=REAL_QUALCOMM_UE
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${gnb_id}
    ${bts_distName}=    Collections.Get From List    ${bts_distNames}    ${0}
    Set Test Variable  ${bts_distName}
    Set Test Variable  ${nrbts_id_0}    ${bts_distName}
    ${enb_distNames}=    scf_info.Get distNames from eNB SCF    regex=MRBTS-\\d+/LNBTS-\\d+    enb_id=${enb_id}
    ${enb_distName}=    Collections.Get From List    ${enb_distNames}    ${0}
    set test variable  ${enb_distName}
    ${PCI_PCell}=      Get gnb physCellId    ${gnb_id}  ${PCell_ID}
    Set Suite Variable       ${PCI_PCell}
    ${PCI_SCell}=      common_keywords.Get gnb physCellId    ${gnb_id}  ${SCell_ID}
    Set Suite Variable       ${PCI_SCell}
    Set Test Variable      ${actMeasurementProfReselForCA}     pcInSaUlCaSupported
    Perform CB013392-C eNB Delta Commissioning   ${enb_id}
    Perform CB013392-C gNB Delta Commissioning   ${gnb_id}

    Get Measurment Parameter Values


CB013392 C TC Teardown
    [Arguments]
    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump on TestPc   collector=${eth3_collector}
    Run Keyword And Ignore Error    taf.ue.Detach Ue   UE
    Run Keyword And Ignore Error    admin.unblock_cell  dist_name=${bts_distName}/NRCELL-13  connection=${oam_alias}
    [Teardown]    Run Keywords
    ...           Run Keyword and Ignore Error    connect.Teardown OAM Http Session    connection=${oam_alias}
    ...  AND      Run Keyword and Ignore Error    connect.Teardown OAM Http Session    connection=${enb_oam_alias}


Get Measurment Parameter Values
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${oam_alias}=    connect.Setup OAM Http Session    node_id=${gnb_id}
    ${para_list_IAF2}         Create List
    ...      a1MeashoSsbRsrp      a2MeashoSsbRsrp    a2MeashoSsbRsrq   a2MeasReleaseSsbRsrp
    ...      a3MeasSsbRsrp      a5MeasSsbRsrp
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



Perform CB013392-C eNB Delta Commissioning
    [Arguments]     ${enb_id}
    Log To Console  ${\n}Prepare CB013392-C TC04 eNB delta commissioning for eNB-${enb_id}.
    scf.Load Scf    ${TL_scf_enb${enb_id}}
    ${NIDD_VERSION}=    scf.Get Mo Attribute  ${enb_distName}   version
    ${lnbts_id}=  String.Fetch From Right  ${enb_distName}  -
    scf.modify_scf_element   dist_name=${enb_distName}/NRDCDPR-0/ENDCDMEASCONF-2  p_name=carrierFreqNrCell    value=${652416}
    scf.modify_scf_element   dist_name=${enb_distName}/NRDCDPR-0     p_name=enDCpMaxEUTRApowerOffset     value=${3}
    scf.modify_scf_element   dist_name=${enb_distName}/NRDCDPR-0     p_name=enDCpMaxNRpowerOffset        value=${3}

    ${tc_log_directory}=    testline.Get Testcase Log Directory
    scf.save_scf    ${tc_log_directory}/scf_enb${enb_id}_CB013392C_target.xml
    ${target_scf}=   Set Variable   ${tc_log_directory}/scf_enb${enb_id}_CB013392C_target.xml
    ${delta_scf}=    Set Variable   ${tc_log_directory}/delta_scf_enb${gnb_id}_CB013392C_target.json
    scf.calculate_delta_scf  ${target_scf}  ${TL_scf_enb${enb_id}}  ${delta_scf}
    Log To Console    Perform enb delta commissioning for CB013392-C TC02 parameters...
    ${enb_oam_alias}=   connect.Setup OAM http session  node_type=enb  node_id=${enb_id}
    Set Test Variable  ${enb_oam_alias}
    admin.Perform Delta Recommissioning
    ...    delta_file=${delta_scf}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    alias=${enb_oam_alias}
    gnb.Wait Until Node To Be Onair State    node_type=enb   node_id=${enb_id}


Perform CB013392-C gNB Delta Commissioning
    [Arguments]     ${gnb_id}
    Log To Console  ${\n}Prepare CB013392-C TC04 gNB delta commissioning for gNB-${gnb_id}.
    scf.Load Scf    ${TL_scf_gnb${gnb_id}}
    ${NIDD_VERSION}=    scf.Get Mo Attribute  ${bts_distName}   version
    Set Suite Variable    ${NIDD_VERSION}
    ${nrbts_id}=  String.Fetch From Right  ${bts_distName}  -

    # Activate Cell Trace report for gNB
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actCellTraceReport    value=true
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actPCMDReport         value=true
    #disable buffer based SCell Addition
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actBufferBasedSCellAddition    value=disabled
    # General parameters for CB013392
    scf.modify_scf_element   dist_name=${bts_distName}  p_name=actMeasurementProfReselForCA   value=${actMeasurementProfReselForCA}
    scf.add_element_to_scf   dist_name=${bts_distName}  p_name=actMeasProfPowerCoordNSA   value=activated
    scf.modify_scf_element   dist_name=${bts_distName}   p_name=actMeasurementProfile    value=SA+NSA
    scf.modify_scf_element   dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1   p_name=nrMeasPrIafDN    value=NRMEASPR_IAF-2

    scf.remove_list_from_scf         dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a1MeashoSsbRsrp
    ${a1MeashoSsbRsrp_List}   Create Dictionary    a1HysteresishoSsbRsrp    0    a1ThresholdhoSsbRsrp   70
    ...    a1TimeToTriggerhoSsbRsrp      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a1MeashoSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=a1MeashoSsbRsrp   elements=${a1MeashoSsbRsrp_List}
    scf.remove_list_from_scf         dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a2MeashoSsbRsrp
    ${a2MeashoSsbRsrp_List}   Create Dictionary    a2HysteresishoSsbRsrp    0    a2ThresholdhoSsbRsrp   60
    ...    a2TimeToTriggerhoSsbRsrp      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=a2MeashoSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=a2MeashoSsbRsrp   elements=${a2MeashoSsbRsrp_List}
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${PCell_ID}    list_name=measPrMaNSAList
    ${measPrMaNSAList_List1}   Create Dictionary    measPrPriority    1    nrMeasPrMaNSADN   NRMEASPR_MA_NSA-1
    ${measPrMaNSAList_List2}   Create Dictionary    measPrPriority    2    nrMeasPrMaNSADN   NRMEASPR_MA_NSA-2
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=measPrMaNSAList   elements=${measPrMaNSAList_List1}
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${PCell_ID}
    ...    list_name=measPrMaNSAList   elements=${measPrMaNSAList_List2}
    scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=a2MeashoEnabled     value=rsrpCombined

    scf.remove_list_from_scf         dist_name=${bts_distName}/NRCELL-${SCell_ID}    list_name=a2MeashoSsbRsrp
    ${a2MeashoSsbRsrp_List}   Create Dictionary    a2HysteresishoSsbRsrp    0    a2ThresholdhoSsbRsrp   37
    ...    a2TimeToTriggerhoSsbRsrp      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRCELL-${SCell_ID}    list_name=a2MeashoSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRCELL-${SCell_ID}
    ...    list_name=a2MeashoSsbRsrp   elements=${a2MeashoSsbRsrp_List}

    scf.remove_list_from_scf         dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1    list_name=a1MeashoSsbRsrp
    ${a1MeashoSsbRsrp_List}   Create Dictionary    a1HysteresishoSsbRsrp    0    a1ThresholdhoSsbRsrp   75
    ...    a1TimeToTriggerhoSsbRsrp      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1    list_name=a1MeashoSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...    list_name=a1MeashoSsbRsrp   elements=${a1MeashoSsbRsrp_List}
    scf.remove_list_from_scf         dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1    list_name=a1MeashoSsbRsrq
    ${a1MeashoSsbRsrq_List}   Create Dictionary    a1HysteresishoSsbRsrq    0    a1ThresholdhoSsbRsrq   75
    ...    a1TimeToTriggerhoSsbRsrq      ms128
    scf.add_list_to_scf           dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1    list_name=a1MeashoSsbRsrq
    scf.add_item_to_list          dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...    list_name=a1MeashoSsbRsrq   elements=${a1MeashoSsbRsrq_List}
    scf.remove_list_from_scf         dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1    list_name=a2MeashoSsbRsrq
    ${a2MeashoSsbRsrq_List}   Create Dictionary    a2HysteresishoSsbRsrq    0    a2ThresholdhoSsbRsrq   69
    ...    a2TimeToTriggerhoSsbRsrq      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1    list_name=a2MeashoSsbRsrq
    scf.add_item_to_list          dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...    list_name=a2MeashoSsbRsrq   elements=${a2MeashoSsbRsrq_List}

    scf.remove_list_from_scf         dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2    list_name=a2MeashoSsbRsrp
    ${a2MeashoSsbRsrp_List}   Create Dictionary    a2HysteresishoSsbRsrp    4    a2ThresholdhoSsbRsrp   52
    ...    a2TimeToTriggerhoSsbRsrp      ms1024
    scf.add_list_to_scf           dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2    list_name=a2MeashoSsbRsrp
    scf.add_item_to_list          dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...    list_name=a2MeashoSsbRsrp   elements=${a2MeashoSsbRsrp_List}
    scf.remove_list_from_scf         dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2    list_name=a2MeashoSsbRsrq
    ${a2MeashoSsbRsrq_List}   Create Dictionary    a2HysteresishoSsbRsrq    0    a2ThresholdhoSsbRsrq   61
    ...    a2TimeToTriggerhoSsbRsrq      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2    list_name=a2MeashoSsbRsrq
    scf.add_item_to_list          dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...    list_name=a2MeashoSsbRsrq   elements=${a2MeashoSsbRsrq_List}

     scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=pMaxNROwnCell     value=26
     scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=reportAmount     value=infinity
     scf.modify_scf_element      dist_name=${bts_distName}/NRCELL-${PCell_ID}     p_name=reportInterval     value=ms10240

    #Cell trace settings disable E1 F1
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    ...    target_mo_dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2
    scf.remove_mo_with_descendant_mos   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    scf.modify_scf_element   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2   p_name=traceE1Setting   value=none
    scf.modify_scf_element   dist_name=${bts_distName}/NRCTRLTS-1/NRMTRACECU-2   p_name=traceF1Setting   value=none

    ${oam_alias}=   connect.Setup OAM http session  node_type=gnb  node_id=${gnb_id}
    Set Test Variable  ${oam_alias}
    ${number_of_cells}   testline.Get Number Of Cells     cell_type=NRCEL   connection=${oam_alias}
    FOR   ${NRCELL}  IN RANGE  ${1}  ${number_of_cells}
      scf.modify_scf_element   dist_name=${bts_distName}/NRCELL-${NRCELL}  p_name=maxNumScellsDlFr1   value=${3}
    END

    ${tc_log_directory}=    testline.Get Testcase Log Directory
    scf.save_scf    ${tc_log_directory}/scf_gnb${gnb_id}_CB013392C_target.xml
    ${target_scf}=   Set Variable   ${tc_log_directory}/scf_gnb${gnb_id}_CB013392C_target.xml
    ${delta_scf}=    Set Variable   ${tc_log_directory}/delta_scf_gnb${gnb_id}_CB013392C_target.json
    scf.calculate_delta_scf  ${target_scf}  ${TL_scf_gnb${gnb_id}}  ${delta_scf}
    Log To Console    Perform gnb delta commissioning for CB013392-C TC04 parameters...
    admin.Perform Delta Recommissioning
    ...    delta_file=${delta_scf}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    alias=${oam_alias}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    admin.block_cell  dist_name=${bts_distName}/NRCELL-13  connection=${oam_alias}

    # prepare delta for online change IAF-2 a2ThresholdhoSsbRsrq to 68
    scf.remove_list_from_scf         dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2    list_name=a2MeashoSsbRsrq
    ${a2MeashoSsbRsrq_List}   Create dictionary    a2HysteresishoSsbRsrq    0    a2ThresholdhoSsbRsrq   68
    ...    a2TimeToTriggerhoSsbRsrq      ms480
    scf.add_list_to_scf           dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2    list_name=a2MeashoSsbRsrq
    scf.add_item_to_list          dist_name=${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...    list_name=a2MeashoSsbRsrq   elements=${a2MeashoSsbRsrq_List}
    scf.save_scf    ${tc_log_directory}/scf_gnb${gnb_id}_CB013392C_A2_changedRsrq.xml
    ${targetA2Rsrq_scf}=   Set Variable   ${tc_log_directory}/scf_gnb${gnb_id}_CB013392C_A2_changedRsrq.xml
    ${deltaA2Rsrq_scf}=    Set Variable   ${tc_log_directory}/delta_scf_gnb${gnb_id}_CB013392C_A2_changedRsrq.json
    scf.calculate_delta_scf  ${targetA2Rsrq_scf}  ${target_scf}  ${deltaA2Rsrq_scf}
    Set Test Variable      ${deltaA2Rsrq_scf}


online change IAF-2 a2ThresholdhoSsbRsrq to 68
    Log To Console    online change A2 ho rsrq value to 68
    admin.Perform Delta Recommissioning
    ...    delta_file=${deltaA2Rsrq_scf}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    alias=${oam_alias}
    Run Keyword And Ignore Error    admin.unblock_cell  dist_name=${bts_distName}/NRCELL-13  connection=${oam_alias}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}


Start Data Transfer UL DL
    taf.ue.Start Data Transfer    dt_name=DL1    ue_alias=UE    direction=dl
    ...    duration=420s    protocol=tcp   max_segment_size=1300    packet_size=16k
    taf.ue.Start Data Transfer    dt_name=UL1    ue_alias=UE    direction=ul
    ...    duration=420s    protocol=tcp   max_segment_size=1300    packet_size=16k


Verify SgNbAddtion RRCReconfiguration with correct MeasConfigs
    [Documentation]   Verify RRCReconfiguration with meas config mapped from IAF-2, as ue in PowerClass3
    [Arguments]       ${tcp_file}
    ${tc_log_directory}=  testline.Get Testcase Log Directory
    ${packet_filter}=    Set Variable   nsetapx.asn1_MsgId == 3
    ${pdml_file}=    Set Variable       ${tc_log_directory}/RRCReconfiguration_by_SgNBaddtion.pdml
    ute_tshark.read pcap and save to file    filename=${pdml_file}
    ...    packet_filter=${packet_filter}   output_type=pdml     pcap_file_path=${tcp_file}
    ${Xpath_MeasIdToAddMods}=    Set Variable      .//field[@name='nr-rrc.MeasIdToAddMod_element']
    ${Elements_MeasIdToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_MeasIdToAddMods}
    ${measIdToAddMods_length}=  Get Length   ${Elements_MeasIdToAddMods}

    ${Xpath_measId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.measId']
    ${Elements_measIds}    XML.Get Elements    ${pdml_file}    ${Xpath_measId}
    ${Xpath_reportConfigId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_reportConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigId}
    ${Dict_measIdToAdd_reportConfigId}    Create Dictionary
    FOR   ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_measId}=     XML.Get Element attribute   ${Elements_measIds}[${i}]   showname
        ${Elements_reportConfigId}=     XML.Get Element attribute   ${Elements_reportConfigIds}[${i}]   showname
        Set To Dictionary    ${Dict_measIdToAdd_reportConfigId}  ${Elements_reportConfigId}   ${Elements_measId}
    END
    Log To Console      ${Dict_measIdToAdd_reportConfigId}
    ${Xpath_reportConfigToAddMods}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.ReportConfigToAddMod_element']
    ${Elements_reportConfigToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigToAddMods}

    ${Xpath_ReportConfigToAddMods_ConfigId}=      Catenate    SEPARATOR=//
    ...    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_ReportConfigToAddMods_ConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_ReportConfigToAddMods_ConfigId}
    ${Xpath_eventid}=      Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.eventId']
    ${Elements_eventIds}    XML.Get Elements    ${pdml_file}    ${Xpath_eventid}
    ${Dict_reportConfigId_eventId}    Create Dictionary
    set Test Variable    ${A2_counter}     ${0}
    FOR    ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_ReportConfigToAddMods_ConfigId}=     XML.Get Element attribute   ${Elements_ReportConfigToAddMods_ConfigIds}[${i}]   showname
        ${Elements_eventId}=     XML.Get Element attribute   ${Elements_eventIds}[${i}]   showname
        Set To Dictionary    ${Dict_reportConfigId_eventId}     ${Elements_ReportConfigToAddMods_ConfigId}   ${Elements_eventId}

        IF    "${Elements_eventId}" == "eventId: eventA2 (1)" and ${A2_counter}==${0}
        ...    Verify IAF-2 A2 measConfigs    ${pdml_file}     ${Elements_ReportConfigToAddMods_ConfigId}
        IF    "${Elements_eventId}" == "eventId: eventA3 (2)"      Verify IAF-2 A3 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA5 (4)"      Verify IAF-2 A5 measConfigs    ${pdml_file}
    END
    Log To Console     ${Dict_reportConfigId_eventId}
    # get measId for HO A2 and save for later check the report received to be the A2 ho event
    ${A2event_meadId}=    Get From Dictionary   ${Dict_measIdToAdd_reportConfigId}      ${A2event_ConfigId}
    Set Test Variable     ${A2event_meadId}


Verify IAF-2 A2 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA2 configured mapping correctly to the gnb configuration
    [Arguments]       ${pdml_file}     ${MeasEventConfigId}
    ${IAF2_a2HysteresishoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2HysteresishoSsbRsrp']}
    ${IAF2_a2ThresholdhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2ThresholdhoSsbRsrp']}
    ${IAF2_a2TimeToTriggerhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2TimeToTriggerhoSsbRsrp']}

    ${IAF2_a2HysteresisReleaseSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeasReleaseSsbRsrp'][0]['a2HysteresisReleaseSsbRsrp']}
    ${IAF2_a2ThresholdReleaseSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeasReleaseSsbRsrp'][0]['a2ThresholdReleaseSsbRsrp']}
    ${IAF2_a2TimeToTriggerReleaseSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeasReleaseSsbRsrp'][0]['a2TimeToTriggerReleaseSsbRsrp']}

    ${Xpath_reportConfigToAddModA2}=    set variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA2_element']
    ${Xpath_Rsrp}=    set variable    field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A2measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA2}      ${Xpath_Rsrp}
    ${Elements_A2measTriggerRsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_A2measTriggerRsrp}

    FOR    ${Element_A2measTriggerRsrp}    IN   @{Elements_A2measTriggerRsrp}
        ${Element_A2measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A2measTriggerRsrp}   show
        ${status_A2_horsrp}  Run Keyword And Return Status    should be true
        ...   "${Element_A2measTriggerRsrp_show}"=="${IAF2_a2ThresholdhoSsbRsrp}"
        IF     ${status_A2_horsrp}     Set Test Variable    ${A2Event_ConfigId}    ${MeasEventConfigId}
        ${status_A2_releasersrp}  Run Keyword And Return Status    Should Be True
        ...   "${Element_A2measTriggerRsrp_show}"=="${IAF2_a2ThresholdReleaseSsbRsrp}"
        ${status_A2_rsrp}    Evaluate    ${status_A2_horsrp} or ${status_A2_releasersrp}
    END

    Set Test Variable      ${A2_counter}   ${{ ${A2_counter}+1 }}

    ${Xpath_hysteresis}=    Set Variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA2_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA2}    ${Xpath_hysteresis}
    ${Elements_eventA2_hysteresis}    XML.Get Elements    ${pdml_file}    ${Xpath_eventA2_hysteresis}
    FOR     ${Element_eventA2_hysteresis}     IN     @{Elements_eventA2_hysteresis}
        ${Element_eventA2_hysteresis_showname}    XML.Get Element Attribute   ${Element_eventA2_hysteresis}   showname
        ${status_A2_hohysteresis}  Run Keyword And Return Status    Should Contain
        ...   ${Element_eventA2_hysteresis_showname}     ${IAF2_a2HysteresishoSsbRsrp}dB
        ${status_A2_releasehysteresis}  Run Keyword And Return Status    Should Contain
        ...   ${Element_eventA2_hysteresis_showname}     ${IAF2_a2HysteresisReleaseSsbRsrp}dB
        ${status_A2_hysteresis}    Evaluate    ${status_A2_hohysteresis} or ${status_A2_releasehysteresis}
    END

    ${Xpath_timeToTrigger}=    Set Variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A2timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA2}     ${Xpath_timeToTrigger}
    ${Elements_A2timeToTrigger}    XML.Get Elements    ${pdml_file}    ${Xpath_A2timeToTrigger}
    FOR    ${Element_A2timeToTrigger}    IN    @{Elements_A2timeToTrigger}
        ${Element_A2timeToTrigger_showname}    XML.Get Element Attribute   ${Element_A2timeToTrigger}   showname
        ${status_A2_hotimeToTrigger}  Run Keyword And Return Status    Should contain
        ...   ${Element_A2timeToTrigger_showname}      ${IAF2_a2TimeToTriggerhoSsbRsrp}
        ${status_A2_releasetimeToTrigger}  Run Keyword And Return Status    Should contain
        ...   ${Element_A2timeToTrigger_showname}      ${IAF2_a2TimeToTriggerReleaseSsbRsrp}
        ${status_A2_timeToTrigger}    Evaluate   ${status_A2_hotimeToTrigger} or ${status_A2_releasetimeToTrigger}
    END

    ${status_A2}=    Evaluate    ${status_A2_rsrp} and ${status_A2_hysteresis} and ${status_A2_timeToTrigger}
    IF    not '${status_A2}'     Fail    A2 shall be configured by IAF-2 as ue in pc3, but it's not.


Verify IAF-2 A3 measConfigs
    [Documentation]    verify in RRCReconfig msg the eventA3 configured mapping correctly to the gnb configuration
    [Arguments]       ${pdml_file}
    ${IAF2_a3HysteresisSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a3MeasSsbRsrp'][0]['a3HysteresisSsbRsrp']}
    ${IAF2_a3OffsetSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a3MeasSsbRsrp'][0]['a3OffsetSsbRsrp']}
    ${IAF2_a3TimeToTriggerSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a3MeasSsbRsrp'][0]['a3TimeToTriggerSsbRsrp']}

    ${Xpath_reportConfigToAddModA3}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA3_element']
    ${Xpath_a3OffsetRsrp}=    Set Variable    field[@name='nr-rrc.measTriggerQuantityOffset.rsrp']
    ${Xpath_A3measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}      ${Xpath_a3OffsetRsrp}
    ${Element_A3measTriggerRsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A3measTriggerRsrp}
    ${Element_A3measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A3measTriggerRsrp}   show
    ${status_A3_rsrp}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A3measTriggerRsrp_show}"=="${IAF2_a3OffsetSsbRsrp}"

    ${Xpath_hysteresis}=    Set Variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA3_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}    ${Xpath_hysteresis}
    ${Element_eventA3_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA3_hysteresis}
    ${Element_eventA3_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA3_hysteresis}   showname
    ${status_A3_hysteresis}  Run Keyword And Return Status    should contain
    ...   ${Element_eventA3_hysteresis_showname}     ${IAF2_a3HysteresisSsbRsrp}dB

    ${Xpath_timeToTrigger}=    Set Variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A3timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}     ${Xpath_timeToTrigger}
    ${Element_A3timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A3timeToTrigger}
    ${Element_A3timeToTrigger_showname}    XML.Get Element attribute   ${Element_A3timeToTrigger}   showname
    ${status_A3_timeToTrigger}  Run Keyword And Return Status    should contain
    ...   ${Element_A3timeToTrigger_showname}      ${IAF2_a3TimeToTriggerSsbRsrp}

    ${status_A3}=    Evaluate    ${status_A3_rsrp} and ${status_A3_hysteresis} and ${status_A3_timeToTrigger}
    IF    not ${status_A3}    Fail    A3 shall be configured by IAF-2 as ue in pc3, but it's not.


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

    ${Xpath_reportConfigToAddModA5}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA5_element']
    ${Xpath_Threshold1Rsrp}=    Set Variable    field[@name='nr-rrc.a5_Threshold1']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold1Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A5measTriggerThreshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold1Rsrp}   show
    ${status_A5_rsrp1}  Run Keyword And Return Status    should be true
    ...   "${Element_A5measTriggerThreshold1Rsrp_show}"=="${IAF2_a5Threshold1SsbRsrp}"

    ${Xpath_Threshold2Rsrp}=    Set Variable    field[@name='nr-rrc.a5_Threshold2']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold2Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A5measTriggerThreshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold2Rsrp}   show
    ${status_A5_rsrp2}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold2Rsrp_show}"=="${IAF2_a5Threshold2SsbRsrp}"

    ${Xpath_hysteresis}=    Set Variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA5_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}    ${Xpath_hysteresis}
    ${Element_eventA5_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA5_hysteresis}
    ${Element_eventA5_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA5_hysteresis}   showname
    ${status_A5_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA5_hysteresis_showname}      ${IAF2_a5HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    Set Variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A5timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}     ${Xpath_timeToTrigger}
    ${Element_A5timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A5timeToTrigger}
    ${Element_A5timeToTrigger_showname}    XML.Get Element attribute   ${Element_A5timeToTrigger}   showname
    ${status_A5_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A5timeToTrigger_showname}       ${IAF2_a5TimeToTriggerhoSsbRsrp}

    ${status_A5}=    Evaluate    ${status_A5_rsrp1} and ${status_A5_rsrp2} and ${status_A5_hysteresis} and ${status_A5_timeToTrigger}
    IF    not ${status_A5}    Fail    A5 shall be configured by IAF-2 as ue in pc3, but it's not.


Verify A2 report and RRCReconfiguration with correct MeasConfigs activated after A2
    [Documentation]   verify:
    ...               1. Verify A2 report received, rsrq in the report satisfies respCombined secondary quantity evaluation
    ...               2. Verify RRCReconfiguration with meas config correctly mapped, i.e.
    ...                  A1 from IAF-2 as ue in pc3
    ...                  inter-Freq A3/A5 IEF-1 selection is based on target frequency in NRHOIF as pc2
    ...                  inter-RAT B2d from IRF-2 as ue in pc3
    [Arguments]       ${tcp_file}
    ${tc_log_directory}=  testline.Get Testcase Log Directory
    ${packet_filter}=    Set Variable   nsetapx.asn1_MsgId == 19
    ${A2s_pdml_file}=    Set Variable       ${tc_log_directory}/A2_Report.pdml
    ute_tshark.read pcap and save to file    filename=${A2s_pdml_file}
    ...    packet_filter=${packet_filter}   output_type=pdml     pcap_file_path=${tcp_file}
    ${packet_filter}=    Set Variable   nsetapx.asn1_MsgId == 7
    ${RRCReconfig_pdml_file}=    Set Variable       ${tc_log_directory}/RRCReconfig_byA2.pdml
    ute_tshark.read pcap and save to file    filename=${RRCReconfig_pdml_file}
    ...    packet_filter=${packet_filter}   output_type=pdml     pcap_file_path=${tcp_file}
    Verify A2 report sent repeatly since respCombined secondary quantity evaluation NOT satisfied     ${A2s_pdml_file}
    Verify RRCReconfiguration with meas config A1 A3/A5 B2 correctly mapped      ${RRCReconfig_pdml_file}


Verify A2 report sent repeatly since respCombined secondary quantity evaluation NOT satisfied
     [Documentation]   Verify A2 report received, where the rsrq in the report satisfies respCombined secondary quantity
     ...               evaluation, i.e. rsrq shall satisfy a2ThresholdhoSsbRsrq value in IAF-2
    [Arguments]       ${pdml_file}
    ${Xpath_measId}=    Set Variable
    ...      .//field[@name='nr-rrc.measurementReport_element']//field[@name='nr-rrc.measId']
    ${MeasIds}    XML.Get Elements    ${pdml_file}    ${Xpath_measId}
    ${MeasIds_length}=   Get length   ${MeasIds}
    FOR   ${i}    IN RANGE    0    ${MeasIds_length}
        ${MeasId_showname}=     XML.Get Element attribute   ${MeasIds}[${i}]   showname
        IF    '${A2event_meadId}'!='${MeasId_showname}'    Fail    A2 report expected but received not A2.
    END


    ${Xpath_measResult}=     Set Variable   .//field[@name='nr-rrc.measurementReport_element']//field[@name='nr-rrc.measResultServingCell_element']
    ${Xpath_physCellIds}=      Catenate    SEPARATOR=//    ${Xpath_measResult}    field[@name='nr-rrc.physCellId']
    ${Elements_physCellId}    XML.Get Elements    ${pdml_file}    ${Xpath_physCellIds}
    ${Xpath_physCellIds_rsrp}=      Catenate    SEPARATOR=//    ${Xpath_measResult}
    ...     field[@name='nr-rrc.resultsSSB_Cell_element']//field[@name='nr-rrc.measQuantityResults.rsrp']
    ${Elements_physCellIds_rsrp}    XML.Get Elements    ${pdml_file}    ${Xpath_physCellIds_rsrp}
    ${Xpath_physCellIds_rsrq}=      Catenate    SEPARATOR=//    ${Xpath_measResult}
    ...     field[@name='nr-rrc.resultsSSB_Cell_element']//field[@name='nr-rrc.measQuantityResults.rsrq']
    ${Elements_physCellIds_rsrq}    XML.Get Elements    ${pdml_file}    ${Xpath_physCellIds_rsrq}
    ${Elements_physCellId_length}=  Get length   ${Elements_physCellId}
    FOR   ${i}    IN RANGE    0    ${Elements_physCellId_length}
        ${physCellId}=     XML.Get Element attribute   ${Elements_physCellId}[${i}]    show
        ${Element_physCellIds_rsrp_show}=     XML.Get Element attribute   ${Elements_physCellIds_rsrp}[${i}]    show
        ${Element_physCellIds_rsrq_show}=     XML.Get Element attribute   ${Elements_physCellIds_rsrq}[${i}]    show
        IF    "${physCellId}" == "${PCI_PCell}"    Verify A2 report NOT satisfies rsrpCombined criterion
        ...      ${Element_physCellIds_rsrp_show}      ${Element_physCellIds_rsrq_show}
    END


Verify A2 report NOT satisfies rsrpCombined criterion
     [Documentation]    Verify in A2 report: ${rsrp} recieved < IAF2_a2ThresholdhoSsbRsrp and
     ...                ${rsrq} recieved < IAF2_a2ThresholdhoSsbRsrp
     [Arguments]       ${rsrp}     ${rsrq}
    ${IAF2_a2ThresholdhoSsbRsrp}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrp'][0]['a2ThresholdhoSsbRsrp']}
    IF    '${rsrp}'>'${IAF2_a2ThresholdhoSsbRsrp}'
    ...    Fail    A2 report rsrp value "${rsrp}" not small than IAF-2 a2ThresholdhoSsbRsrp="${IAF2_a2ThresholdhoSsbRsrp}".
    ${IAF2_a2ThresholdhoSsbRsrq}=   Set Variable
    ...   ${Values_Value_list_IAF2[0]['parameters']['a2MeashoSsbRsrq'][0]['a2ThresholdhoSsbRsrq']}
    IF    '${rsrq}'<'${IAF2_a2ThresholdhoSsbRsrq}'
    ...    Fail    A2 report rsrq value "${rsrq}" not small than IAF-2 a2ThresholdhoSsbRsrq="${IAF2_a2ThresholdhoSsbRsrq}"..


Verify RRCReconfiguration with meas config A1 A3/A5 B2 correctly mapped
    [Documentation]    Verify RRCReconfiguration with meas config correctly mapped, i.e.
    ...                A1 from IAF-2 as ue in pc3
    ...                inter-Freq A3/A5 IEF-1 selection is based on target frequency in NRHOIF as pc2
    ...                inter-RAT B2d from IRF-2 as ue in pc3
    [Arguments]       ${pdml_file}
    ${Xpath_MeasIdToAddMods}=    Set Variable      .//field[@name='nr-rrc.measIdToAddModList']//field[@name='nr-rrc.MeasIdToAddMod_element']
    ${Elements_MeasIdToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_MeasIdToAddMods}
    ${measIdToAddMods_length}=  Get Length   ${Elements_MeasIdToAddMods}

    ${Xpath_measId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.measId']
    ${Elements_measIds}    XML.Get Elements    ${pdml_file}    ${Xpath_measId}
    ${Xpath_reportConfigId}=      Catenate    SEPARATOR=//    ${Xpath_MeasIdToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_reportConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigId}
    ${Dict_measIdToAdd_reportConfigId}    Create Dictionary
    FOR   ${i}    IN RANGE    0    ${measIdToAddMods_length}
        ${Elements_measId}=     XML.Get Element Attribute   ${Elements_measIds}[${i}]   showname
        ${Elements_reportConfigId}=     XML.Get Element Attribute   ${Elements_reportConfigIds}[${i}]   showname
        Collections.Set To Dictionary    ${Dict_measIdToAdd_reportConfigId}   ${Elements_measId}  ${Elements_reportConfigId}
    END
    Log To Console      ${Dict_measIdToAdd_reportConfigId}
    ${Xpath_reportConfigToAddMods}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.ReportConfigToAddMod_element']
    ${Elements_reportConfigToAddMods}    XML.Get Elements    ${pdml_file}    ${Xpath_reportConfigToAddMods}
    ${Xpath_ReportConfigToAddMods_ConfigId}=      Catenate    SEPARATOR=//
    ...    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.reportConfigId']
    ${Elements_ReportConfigToAddMods_ConfigIds}    XML.Get Elements    ${pdml_file}    ${Xpath_ReportConfigToAddMods_ConfigId}
    ${ConfigToAddMods_length}=  Get Length   ${Elements_ReportConfigToAddMods}
    ${Xpath_eventid}=      Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddMods}    field[@name='nr-rrc.eventId']
    ${Elements_eventIds}    XML.Get Elements    ${pdml_file}    ${Xpath_eventid}
    ${Dict_reportConfigId_eventId}    Create Dictionary
    FOR    ${i}    IN RANGE    0    ${ConfigToAddMods_length}
        ${Elements_ReportConfigToAddMods_ConfigId}=     XML.Get Element attribute   ${Elements_ReportConfigToAddMods_ConfigIds}[${i}]   showname
        ${Elements_eventId}=     XML.Get Element attribute   ${Elements_eventIds}[${i}]   showname
        Set To Dictionary    ${Dict_reportConfigId_eventId}   ${Elements_ReportConfigToAddMods_ConfigId}   ${Elements_eventId}
        IF    "${Elements_eventId}" == "eventId: eventA1 (0)"      Verify IAF-2 A1 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA3 (2)"      Verify IEF-1 A3 measConfigs    ${pdml_file}
        IF    "${Elements_eventId}" == "eventId: eventA5 (4)"      Verify IEF-1 A5 measConfigs    ${pdml_file}
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

    ${Xpath_reportConfigToAddModA1}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA1_element']
    ${Xpath_Rsrp}=    set variable    field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A1measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA1}      ${Xpath_Rsrp}
    ${Element_A1measTriggerRsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A1measTriggerRsrp}
    ${Element_A1measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A1measTriggerRsrp}   show
    ${status_A1_rsrp}  Run Keyword And Return Status    should be true
    ...   "${Element_A1measTriggerRsrp_show}"=="${IAF2_a1ThresholdhoSsbRsrp}"

    ${Xpath_hysteresis}=    Set Variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA1_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA1}    ${Xpath_hysteresis}
    ${Element_eventA1_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA1_hysteresis}
    ${Element_eventA1_hysteresis_showname}    XML.Get Element Attribute   ${Element_eventA1_hysteresis}   showname
    ${status_A1_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA1_hysteresis_showname}     ${IAF2_a1HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    Set Variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A1timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA1}     ${Xpath_timeToTrigger}
    ${Element_A1timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A1timeToTrigger}
    ${Element_A1timeToTrigger_showname}    XML.Get Element Attribute   ${Element_A1timeToTrigger}   showname
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

    ${Xpath_reportConfigToAddModA3}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA3_element']
    ${Xpath_a3OffsetRsrp}=    Set Variable    field[@name='nr-rrc.measTriggerQuantityOffset.rsrp']
    ${Xpath_A3measTriggerRsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}      ${Xpath_a3OffsetRsrp}
    ${Element_A3measTriggerRsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A3measTriggerRsrp}
    ${Element_A3measTriggerRsrp_show}    XML.Get Element attribute   ${Element_A3measTriggerRsrp}   show
    ${status_A3_rsrp}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A3measTriggerRsrp_show}"=="${IEF1_a3OffsetSsbRsrp}"

    ${Xpath_hysteresis}=    Set Variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA3_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}    ${Xpath_hysteresis}
    ${Element_eventA3_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA3_hysteresis}
    ${Element_eventA3_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA3_hysteresis}   showname
    ${status_A3_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA3_hysteresis_showname}     ${IEF1_a3HysteresisSsbRsrp}dB

    ${Xpath_timeToTrigger}=    Set Variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A3timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA3}     ${Xpath_timeToTrigger}
    ${Element_A3timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A3timeToTrigger}
    ${Element_A3timeToTrigger_showname}    XML.Get Element Attribute   ${Element_A3timeToTrigger}   showname
    ${status_A3_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A3timeToTrigger_showname}      ${IEF1_a3TimeToTriggerSsbRsrp}

    ${status_A3}=    Evaluate    ${status_A3_rsrp} and ${status_A3_hysteresis} and ${status_A3_timeToTrigger}
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

    ${Xpath_reportConfigToAddModA5}=    Set Variable
    ...    .//field[@name='nr-rrc.reportConfigToAddModList']//field[@name='nr-rrc.eventA5_element']
    ${Xpath_Threshold1Rsrp}=    Set Variable    field[@name='nr-rrc.a5_Threshold1']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold1Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A5measTriggerThreshold1Rsrp}
    ${Element_A5measTriggerThreshold1Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold1Rsrp}   show
    ${status_A5_rsrp1}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold1Rsrp_show}"=="${IEF1__a5Threshold1SsbRsrp}"

    ${Xpath_Threshold2Rsrp}=    Set Variable    field[@name='nr-rrc.a5_Threshold2']//field[@name='nr-rrc.measTriggerQuantity.rsrp']
    ${Xpath_A5measTriggerThreshold2Rsrp}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}      ${Xpath_Threshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp}    XML.Get Element    ${pdml_file}    ${Xpath_A5measTriggerThreshold2Rsrp}
    ${Element_A5measTriggerThreshold2Rsrp_show}    XML.Get Element attribute   ${Element_A5measTriggerThreshold2Rsrp}   show
    ${status_A5_rsrp2}  Run Keyword And Return Status    Should Be True
    ...   "${Element_A5measTriggerThreshold2Rsrp_show}"=="${IEF1__a5Threshold2SsbRsrp}"

    ${Xpath_hysteresis}=    Set Variable    field[@name='nr-rrc.hysteresis']
    ${Xpath_eventA5_hysteresis}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}    ${Xpath_hysteresis}
    ${Element_eventA5_hysteresis}    XML.Get Element    ${pdml_file}    ${Xpath_eventA5_hysteresis}
    ${Element_eventA5_hysteresis_showname}    XML.Get Element attribute   ${Element_eventA5_hysteresis}   showname
    ${status_A5_hysteresis}  Run Keyword And Return Status    Should Contain
    ...   ${Element_eventA5_hysteresis_showname}      ${IEF1_a5HysteresishoSsbRsrp}dB

    ${Xpath_timeToTrigger}=    Set Variable    field[@name='nr-rrc.timeToTrigger']
    ${Xpath_A5timeToTrigger}=    Catenate    SEPARATOR=//    ${Xpath_reportConfigToAddModA5}     ${Xpath_timeToTrigger}
    ${Element_A5timeToTrigger}    XML.Get Element    ${pdml_file}    ${Xpath_A5timeToTrigger}
    ${Element_A5timeToTrigger_showname}    XML.Get Element attribute   ${Element_A5timeToTrigger}   showname
    ${status_A5_timeToTrigger}  Run Keyword And Return Status    Should Contain
    ...   ${Element_A5timeToTrigger_showname}       ${IEF1__a5TimeToTriggerhoSsbRsrp}

    ${status_A5}=    Evaluate    ${status_A5_rsrp1} and ${status_A5_rsrp2} and ${status_A5_hysteresis} and ${status_A5_timeToTrigger}
    IF    not ${status_A5}    Fail    A5 shall be configured by IEF-1 as target frequency in NRHOIF in pc2, but it's not.


Stop all the traffic
    [Documentation]    stop all the running traffic on all 3 active PDUs, detach both UEs
    @{Data_alias}   Create List     UL1   DL1
    common_keywords.Stop Data Transfers    data_alias=${Data_alias}
