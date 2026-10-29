*** Settings ***
Documentation   This is a Robot Verification file for feature: CB007271
...             author:  I_MN_5GSC_PZ_ULM_SQD_63@nokia.com
...             contact: I_MN_5GSC_PZ_ULM_SQD_63@nokia.com
...             Description: Verification checks for CB007271

Library    verification.py

*** Variables ***

${withPMcountersCheck}    true
@{meas_period_instances}=    ${10}  ${25}  ${40}  ${55}
${xnap}  xnap

*** Keywords ***

Set gNB cell attenuation with file
    [Documentation]    [DEPRECATED]
    ...   starts predifined attenuation scenario
    [Arguments]    ${scenario}=SEN1  ${att_file_path}=att_file_path
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${template}=  Get File  ${att_file_path}
    ${message}=  Replace Variables  ${template}
    Create File  ${resultSuiteBaseDir}/CB_attenuator_scenario_tl.txt  ${message}
    run attenuator scenario  att=attenuator  att_file=${resultSuiteBaseDir}/CB_attenuator_scenario_tl.txt  scenario=${scenario}

Set gNB cell attenuation with file per Cell
    [Documentation]    starts predefined attenuation scenario based on new scenario file syntax
    [Arguments]    ${scenario}=SEN1  ${att_file_path}=att_file_path
    Get test suite result base directory
    ${single_scenario}=  att_scen_py.extract_section  ${att_file_path}  ${scenario}
    ${message}=  Replace Variables  ${single_scenario}
    Create File  ${P_resultSuiteBaseDir}/CB_attenuator_scenario_tl.txt  ${scenario}\n${message}
    attenuator_scenario.run attenuator scenario by cell
    ...    att_file=${P_resultSuiteBaseDir}/CB_attenuator_scenario_tl.txt  scenario=${scenario}

Start PM counter
    [Documentation]    :Author:
    ...   Start the counter for gNB
    [Arguments]    ${gnb_id}=${0}
    Log To Console    "PMcounters: Wait certain Measurement Period Starts."
    pmcounters.Wait for a certain Measurement Period to start    gnb_id=${gnb_id}    meas_period_list=${meas_period_instances}

Counter verification
    [Documentation]    :Author: Amr Aboushehata
    ...   Manual test the files
    [Arguments]    ${cell_attach}=${0}    ${cell_ho}=${0}    ${att_gnb_id}=${0}  ${ho_gnb_id}=${0}
    Log To Console    "PMcounters: Wait Current Measurement Period stops."
    pmcounters.Wait until the current Measurement Period stops    gnb_id=${1}
    ${PM_dir_att}=     pmcounters.Collect PM Counter    gnb_id=${att_gnb_id}    collector_alias=gnb${att_gnb_id}_pm_counters
    IF    '${att_gnb_id}'!='${ho_gnb_id}'
        ${PM_dir_ho}=     pmcounters.Collect PM Counter   gnb_id=${ho_gnb_id}    collector_alias=gnb${ho_gnb_id}_pm_counters
        verify pm counters   resultDir_att=${PM_dir_att}  resultDir_ho=${PM_dir_ho}  cell_attach=${cell_attach}  cell_ho=${cell_ho}
    ELSE
        verify pm counters   resultDir_att=${PM_dir_att}  resultDir_ho=${PM_dir_att}  cell_attach=${cell_attach}  cell_ho=${cell_ho}
    END


verify Single DL UL throughput
    [Arguments]    ${Expected_DL_RATE}    ${Expected_UL_RATE}    ${dl_dt_name}=${dl_dt_name}    ${ul_dt_name}=${ul_dt_name}

    taf.ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}
    ...    tput=${Expected_DL_RATE}Mbits/sec     deviation=${DEVIATION}
    taf.ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}
    ...    tput=${Expected_UL_RATE}Mbits/sec    deviation=${DEVIATION}


Check HandoverRequest cause
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=${xnap}.procedureCode == 0    output_type=pdml    pcap_file_path=${tcp_file}
    ${cause}  get elements  ${output}  .//field[@name='${xnap}.HandoverRequest_element']//field[@name='${xnap}.Cause']
    FOR  ${i}  IN   @{cause}
        ${showname}  Get element attribute  ${i}  showname
        log to console  Handover Request: ${showname}
        Should Contain    ${showname}  radioNetwork
    END

Check HandoverRequest radioNetwork
    [Arguments]    ${tcp_file}
    ${output}  ute_tshark.read pcap  packet_filter=${xnap}.procedureCode == 0  output_type=pdml  pcap_file_path=${tcp_file}
    ${radioNetwork}    get elements    ${output}  .//field[@name='${xnap}.HandoverRequest_element']//field[@name='${xnap}.radioNetwork']
    FOR  ${i}  IN   @{radioNetwork}
       ${showname}  Get element attribute  ${i}  showname
       log to console  Handover Request: ${showname}
       Should Contain    ${showname}  handover-desirable-for-radio-reasons
    END

Check HandoverAcknowledge
    [Arguments]    ${tcp_file}
    ${output}  ute_tshark.read pcap  packet_filter=${xnap}.procedureCode == 0  output_type=pdml  pcap_file_path=${tcp_file}
    ${releasecomplete}  Get Element count  ${output}
    ...    .//field[@name='${xnap}.successfulOutcome_element']//field[@showname='HandoverRequestAcknowledge']
    should be true  ${releasecomplete} > ${0}

Check PathSwitchRequest message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${tcp_file}
    ${PathSwitchRequest}    Get Element count    ${output}    .//field[@name='ngap.PathSwitchRequest_element']
    should be true  ${PathSwitchRequest} > ${0}

Check PathSwitchRequestAck message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${tcp_file}
    ${PathSwitchRequestAck}  Get Element count  ${output}
    ...    .//field[@showname='successfulOutcome']//field[@name='ngap.PathSwitchRequestAcknowledge_element']
    should be true  ${PathSwitchRequestAck} > ${0}

Check UEContextRelease message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap  packet_filter=${xnap}.procedureCode == 6  output_type=pdml  pcap_file_path=${tcp_file}
    ${UEContextRelease}    Get Element count    ${output}    .//field[@name='${xnap}.UEContextRelease_element']
    should be true  ${UEContextRelease} > ${0}

Check UEContextReleaseComplete message for the nokiaf1ap
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=nokiaf1ap.procedureCode == 6  output_type=pdml  pcap_file_path=${tcp_file}
    ${UEContextReleaseComplete}    Get Element count    ${output}
    ...    .//field[@name='nokiaf1ap.successfulOutcome_element']//field[@name='nokiaf1ap.UEContextReleaseComplete_element']
    should be true  ${UEContextReleaseComplete} > ${0}

Check SNSStatusTranfer message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=${xnap}.procedureCode == 1    output_type=pdml    pcap_file_path=${tcp_file}
    ${SNStatusTransfer}    Get Element count    ${output}    .//field[@name='${xnap}.SNStatusTransfer_element']
    should be true  ${SNStatusTransfer} > ${0}

Check UEContextReleaseCommand message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseCommand}    Get Element count    ${output}    .//field[@name='f1ap.UEContextReleaseCommand_element']
    should be true  ${UEContextReleaseCommand} > ${0}

Check UEContextReleaseComplete message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseComplete}    Get Element count    ${output}
    ...    .//field[@showname='successfulOutcome']//field[@name='f1ap.UEContextReleaseComplete_element']
    should be true  ${UEContextReleaseComplete} > ${0}

Check rrcRelease
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${rrcRelease}    Get element count    ${output}    .//field[@name='nr-rrc.rrcRelease_element']
    should be true  ${rrcRelease} > ${0}

Check Scell Addition for nokiaf1ap
    [Arguments]    ${tcp_file}    ${added_cells_count}=1
    ${output}    ute_tshark.read pcap    packet_filter=nokiaf1ap.procedureCode ==12  output_type=pdml  pcap_file_path=${tcp_file}
    ${ScellAdd}  Get Element count  ${output}    .//field[@name='nr-rrc.sCellToAddModList']
    should be true  ${ScellAdd} >= ${added_cells_count}
    ${ScellAdd_elem}    Get elements    ${output}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    ${ScellFreq_elem}    Get elements    ${output}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.FreqBandIndicatorNR']
    ${ScellMIMO_elem}    Get elements    ${output}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.maxMIMO_Layers']
    Log to Console   Checking SCell addition. The added SCell is:
    FOR  ${i}   IN   @{ScellAdd_elem}
         ${showname}     Get element attribute    ${i}    showname
         Log to Console   SCell ${showname}
    END

    FOR  ${i}   IN   @{ScellFreq_elem}
         ${showname}     Get element attribute    ${i}    showname
         Log to Console   SCell ${showname}
    END

    FOR  ${i}   IN   @{ScellMIMO_elem}
         ${showname}     Get element attribute    ${i}    showname
         Log to Console   SCell ${showname}
    END

Check Scell Release
    [Arguments]    ${tcp_file}    ${released_cells_count}=2 items
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${ScellRelease}  Get Element count  ${output}  .//field[@name='nr-rrc.sCellToReleaseList']
    should be true  ${ScellRelease} >= 1
    ${ScellRelease_elem}    get element    ${output}    .//field[@name='nr-rrc.sCellToReleaseList']
    ${showname}  get element attribute  ${ScellRelease_elem}  showname
    log to console  ${showname}
    Should Contain  ${showname}  sCellToReleaseList: ${released_cells_count}

Check Scell Release for nokiaf1ap
    [Arguments]    ${tcp_file}    ${released_cells_count}=1 item
    ${output}    ute_tshark.read pcap    packet_filter=nokiaf1ap.procedureCode == 7  output_type=pdml  pcap_file_path=${tcp_file}
    ${ScellRelease}  Get Element count  ${output}  .//field[@name='nr-rrc.sCellToReleaseList']
    should be true  ${ScellRelease} >= 1
    ${ScellRelease_elem}    get elements   ${output}    .//field[@name='nr-rrc.sCellToReleaseList']

    FOR  ${i}   IN   @{ScellRelease_elem}
         ${showname}   Get element attribute    ${i}    showname
         log to console    ${showname}
         Should Contain  ${showname}  sCellToReleaseList: ${released_cells_count}
    END

Check wireshark for RRCReconfiguration
    [Arguments]    ${physCell}  ${tcp_file}
    ${output}  ute_tshark.read pcap  packet_filter=f1ap.procedureCode == 12  output_type=pdml  pcap_file_path=${tcp_file}
    ${physCellId_count}  Get Element count  ${output}  .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    should be true  ${physCellId_count} >= 1
    ${physCellId}    get elements    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    Should not be empty  ${physCellId}
    FOR  ${i}  IN   @{physCellId}
         ${showname}  Get element attribute  ${i}  showname
         log to console  ${showname}
         Should Contain  ${showname}  ${physCell}
    END

Check RRC Complete message
    [Arguments]    ${tcp_file}
    ${output1}  ute_tshark.read pcap  packet_filter=f1ap.procedureCode == 12||f1ap.procedureCode == 7  output_type=pdml  pcap_file_path=${tcp_file}
    ${rrc}    Get Element count
    ...  ${output1}    .//field[@name='nr-rrc.rrcReconfiguration_element']//field[@showname='rrcReconfiguration']
    ${output2}  ute_tshark.read pcap  packet_filter=f1ap.procedureCode == 13  output_type=pdml  pcap_file_path=${tcp_file}
    ${rrc_complete}    Get Element count
    ...  ${output2}    .//field[@name='nr-rrc.rrcReconfigurationComplete_element']//field[@showname='rrcReconfigurationComplete']
    should be true  ${rrc_complete} == ${rrc}

Check wireshark for cfra_element
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${cfra_element}    get elements    ${output}    .//field[@name='nr-rrc.uplink_element']//field[@name='nr-rrc.cfra_element']
    FOR  ${i}  IN   @{cfra_element}
         ${showname}  Get element attribute  ${i}  showname
         log to console  ${showname}
         Should Contain    ${showname}  cfra
    END

Check MeasGapSetup
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${measGapConfig}    Get elements    ${output}    .//field[@name='nr-rrc.measGapConfig_element']//field[@name='nr-rrc.setup_element']
    ${measGapConfig_count}  Get Element count  ${output}  .//field[@name='nr-rrc.measGapConfig_element']//field[@name='nr-rrc.setup_element']
    should be true  ${measGapConfig_count} >= 1
    FOR  ${i}  IN   @{measGapConfig}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  setup
    END

Check MeasGapRelease
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${measGapConfig}    get elements    ${output}    .//field[@name='nr-rrc.measGapConfig_element']//field[@name='nr-rrc.release_element']
    ${measGapConfig_count}  Get Element count  ${output}  .//field[@name='nr-rrc.measGapConfig_element']//field[@name='nr-rrc.release_element']
    should be true  ${measGapConfig_count} >= 1
    FOR  ${i}  IN   @{measGapConfig}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  release
    END

Check HandoverRequired Type
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${HandoverType}    Get elements    ${output}    .//field[@name='ngap.HandoverRequired_element']//field[@name='ngap.HandoverType']
    FOR  ${i}  IN   @{HandoverType}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  fivegs-to-eps (1)
    END

Check HandoverRequired radionetwork
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${radionetwork}    Get elements    ${output}    .//field[@name='ngap.HandoverRequired_element']//field[@name='ngap.radioNetwork']
    FOR  ${i}  IN   @{radionetwork}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  ng-inter-system-handover-triggered (32)
    END

Check MobilityfromNRcommand eutracell
    [Arguments]    ${tcp_file}
    IF    '${Harmonization}'=='7_15_UTE5GTL367'    Set Test Variable  ${cell_contain}  67
    ...    ELSE      set test variable  ${cell_contain}  51
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${eutra_physCellid}  Get elements  ${output}  .//field[@name='nr-rrc.mobilityFromNRCommand_element']//field[@name='lte-rrc.targetPhysCellId']
    FOR  ${i}  IN   @{eutra_physCellid}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  ${cell_contain}
    END

Check UEcontextrelease reason
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 41    output_type=pdml    pcap_file_path=${tcp_file}
    ${radionetwork}  Get elements  ${output}  .//field[@name='ngap.UEContextReleaseCommand_element']//field[@name='ngap.radioNetwork']
    FOR  ${i}  IN   @{radionetwork}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  successful-handover (2)
    END


Check ScramblingID on PCell
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 5    output_type=pdml    pcap_file_path=${tcp_file}
    ${scramblingID}    Get elements  ${output}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.scramblingID0']
    FOR  ${i}  IN  @{scramblingID}
        ${showname}  Get element attribute  ${i}  showname
        log to console  ScramblingID: ${showname}
        Should Contain    ${showname}  ${PHYSCELLIDSOURCEPCELL}
    END

Check ScramblingID on PCell for nokiaf1ap
    [Arguments]    ${cell_ids}    ${tcp_file}
    ${output}    ute_tshark.read pcap  packet_filter=nokiaf1ap.procedureCode == 12  output_type=pdml  pcap_file_path=${tcp_file}
    ${scramblingID}    get elements  ${output}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.scramblingID0']
    FOR  ${i}  IN  @{scramblingID}
        ${show}  Get element attribute    ${i}    show
        Should Contain   ${cell_ids}   ${show}
    END


Check DU UE ID
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 11    output_type=pdml    pcap_file_path=${tcp_file}
    ${ue_id_elements}    Get elements    ${output}    .//field[@name='f1ap.GNB_DU_UE_F1AP_ID']
    RETURN  ${ue_id_elements}

Check Measurement Report
    [Arguments]    ${tcp_file}    ${cell_ids}
    ${output}    ute_tshark.read pcap  packet_filter=nokiaf1ap.procedureCode == 13  output_type=pdml  pcap_file_path=${tcp_file}
    ${Meas_Report}    get elements    ${output}  .//field[@name='nr-rrc.measResultServingCell_element']//field[@name='nr-rrc.physCellId']
    FOR  ${i}  IN   @{Meas_Report}
        ${show}  Get element attribute  ${i}  show
        Should Contain    ${cell_ids}   ${show}
    END

Check wireshark for a3_Offset for nokiaf1ap
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap  packet_filter=nokiaf1ap.procedureCode == 7  output_type=pdml  pcap_file_path=${tcp_file}
    ${a3_Offset}    get elements  ${output}  .//field[@name='nr-rrc.eventTriggered_element']//field[@name='nr-rrc.a3_Offset']
    FOR  ${i}  IN   @{a3_Offset}
        ${showname}  Get element attribute    ${i}    showname
        Should Contain    ${showname}  rsrp
    END
