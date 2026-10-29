*** Settings ***
Documentation    This is for feature CB008015 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiangyue.zhou@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/mobility_and_ca_common.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001729/Resources/5GC001729_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Logs.robot

#*** Variables ***
#${NSETAP_WEB_PATH}    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X


*** Keywords ***
Suite Setup For RFS On UTE Cloud
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    Uplaod Default Swconfig File
    run keyword and ignore error    Check And Power on RUs
    run keyword and ignore error    CI_interface.Common Suite Setup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    Upgrade Enb For RFS
    Power Reset eNB After gNB Upgrade for RFS
    Perform gNB Restart And Check on air via rest api
    COAM Wait for gnb ready and cell setup    timeout=20 min
    ${gnb_status_by_sommon_scf}    Run Keyword And Return Status
    ...                                                          Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Set Suite Variable    ${gnb_status_by_sommon_scf}
    run keyword if    not ${gnb_status_by_sommon_scf}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Connect to gnb coam via ssl
#    ${Active_SW_version}    Get Active SW Version
#    Set Suite Variable    ${Active_SW_version}
#    ${stream}    get stream from version    ${Active_SW_version}
#    set suite variable      ${stream}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Set Suite Variable    ${gNb_CuType}    SA+NSA
    Run Keyword And Ignore Error    Clear Temp File Of ELT For MTK

Uplaod Default Swconfig File
    [Documentation]    Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    Cloud DU connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Get SCF File Path
    swconf.Upload swConfig file to asik and crasign    localFilePath=${scf_full_path}/swconfig.txt    asik_alias=ASIK Master
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

Perform gNB Restart And Check on air via rest api
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to restart gnb one time and check gnb on air status.
    ...                Recommend to use this keywoed in TEST SETUP.
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

8015 Suite Setup
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    ${gnb_status_by_sommon_scf}    Run Keyword And Return Status    SISO Coam Suite Setup
    run keyword if    not ${gnb_status_by_sommon_scf}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    Run Keyword If    '${testline_name}'=='7_5_UTE5G402T072'   Run Keyword And Ignore Error    Lock cell on eNB

8015 Suite Teardown
    robot_common_operations.Common Suite Teardown
    Run Keyword If    '${testline_name}'=='7_5_UTE5G402T072'    Run Keyword And Ignore Error    Unlock cell on eNB

8015 Case SetUp
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${PA_value}=0    ${is_commission}=False
    ...            ${AEHC_PA_value}=20
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    ${new_scf}    Run Keyword If    '${is_commission}' =='True'
    ...           Replace String    ${Golden_SCF_Path}    .xml    _CB008015_C.xml
    Run Keyword If    '${new_scf}' != 'None'    Commissioning SCF And Check On Air      scf_path=${new_scf}
    COAM Create log directory
#    Run Keyword If    '${stream}'=='SBTS00'
#    ...                Adjust Attenuation To Trigger Peak Tput    PA1_value=${AEHC_PA_value}
#    ...       ELSE     Modify All Attenuation Ports Value For All RU   value=${PA_value}
#    Sleep    5sec
#    Run Keyword If    '${stream}'=='SBTS23R2'    Modify All Attenuation Ports Value For All RU   value=${PA_value}
#    Sleep    5sec
#    Run Keyword If    '${stream}'=='SBTS23R2'    Modify All Attenuation Ports Value For All RU   value=${PA_value}
    Modify All Attenuation Ports Value For All RU   value=${PA_value}
    Keep only Pcell notbarred for CA testing    pcell_index=${pcell_index}
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${pcell_index}
    set test variable    ${peak_tput_PA_value}    ${PA_value}
    log    ${AEHC_PA_value}

8015 Case TearDown
    [Documentation]    Author:lei.jia@nokia-sbell.com
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If Test Failed    Run Keyword And Ignore Error    COAM Save snapshot via rest api    timeout=${600}
    run keyword and continue on failure    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

Adjust Attenuation To Trigger Peak Tput
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${PA0_value}=0   ${PA1_value}=20
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=1
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=2
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=3
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=4
    Sleep  2sec

Adjust Attenuation To Trigger FDD 3CC
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${scell_index_list}    ${PA0_value}=0
    FOR  ${item}  IN   @{scell_index_list}
        gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=127   RU_id=${item}
        gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=${item}
    END
    sleep    5s

Adjust FDD Attenuation To avoid A2 PCELL switch in T_F CA
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${index_in_sorted_scell_weight_list}    ${PA_value}=15
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=${index_in_sorted_scell_weight_list}
    FOR  ${item}  IN   @{scell_index_list}
        gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=${item}
    END

Keep only Pcell notbarred for CA testing
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    Keep only Pcell to not barred status, and set all other cells to barred status
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${pcell_index}    ${connection}=GNB_OAM
    @{expected_pcell_list}    create list    ${pcell_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}
    ...    connection=${connection}    timeout=${180}

Get First TDD and FDD Index From Sorted Scell Weight List
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                get first TDD scell index and FDD scell index from Weighted Scell Bandwidth list.
    [Arguments]    ${pcell_index}    ${is_need_to_get_weighted_scell_list}=${True}
    Run keyword if    ${is_need_to_get_weighted_scell_list}    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${pcell_index}
    ${Frist_TDD_index_in_sorted_scell_weight_list}    Get Specific Technology Index From Sorted Scell Weight List
    ...          all_scell_sorted_list=${all_scell_sorted_list}     technology=TDD
    ${Frist_FDD_index_in_sorted_scell_weight_list}    Get Specific Technology Index From Sorted Scell Weight List
    ...          all_scell_sorted_list=${all_scell_sorted_list}     technology=FDD
    [Return]    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}

Get Specific Technology Index From Sorted Scell Weight List
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                get first TDD scell index or FDD scell index
    [Arguments]    ${all_scell_sorted_list}    ${technology}=TDD
    ${index}    set variable    0
    FOR    ${item}    IN    @{all_scell_sorted_list}
        ${dict_value}    Get Dictionary Values    ${item}
        exit for loop if    '${dict_value[0]['technology']}'=='${technology}'
        ${index}    evaluate    ${index}+1
    END
    [Return]    ${index}

Sorted Weighted Scell Bandwidth Value After Cell Load Change
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${scell_list}
    FOR    ${item}    IN    @{scell_list}
       ${all_scell_sorted_list}    Remove Scell After Cell Load Change   scell_index=${item}
    END
    Set Test Variable   ${all_scell_sorted_list}

Remove Scell After Cell Load Change
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${scell_index}
    FOR  ${item}  IN  @{all_scell_sorted_list}
      ${index}    Get Index From List    ${all_scell_sorted_list}    ${item}
      ${cell_index}    Get Dictionary Keys    ${all_scell_sorted_list[${index}]}
      ${scell_index_list}    Evaluate    '${cell_index[0]}'.split("+")
      ${status}    Run Keyword And Return Status    Should Contain    ${scell_index_list}    ${scell_index}
      Continue For Loop If    '${status}'=='${False}'
      Remove From List    ${all_scell_sorted_list}    ${index}
    END
    ${all_scell_sorted_list}    Set Variable    ${all_scell_sorted_list}
    [Return]    ${all_scell_sorted_list}

Check Scell Change Success
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                get scell index in message <RRC Reconfiguration>,message filter: f1ap.procedureCode == 12
    [Arguments]     ${log_path}
    Convert CPIF Pcap To Pdml    file_path=${log_path}
    ${new_add_physCellId}    Get Field Value From Pdml
    ...                      filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.sCellToAddModList)
    ...                      xpath=.//nr-rrc.physCellId
    Should Not Be Empty    ${new_add_physCellId}    msg=Scell Change Failure!
    ${release_scell_index}    Get Field Value From Pdml
    ...                       filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.sCellToReleaseList)
    ...                       xpath=.//nr-rrc.SCellIndex
    ${relese_scell_len}    get length   ${release_scell_index}
    Should Be True    ${relese_scell_len}>0
    Set Test Variable     ${new_add_physCellId}

Check MeasId And New Added Pcell Id
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]   ${log_path}    ${scell_index_list}
    Convert Pcap File To pdml    log_path=${log_path}
    ${measId}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 13) && (nr-rrc.measResultServingMOList!=1)
    ...    xpath=.//nr-rrc.measId
    Should Be Equal    ${measId[0]}    ${measId_during_attach}
    ${pcell_physCellId}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.physCellId)
    ...    xpath=.//nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId
    ${scell_physical_cellid_list}    Create List
    FOR  ${item}  IN   @{scell_index_list}
        ${scell_physical_cellid}     Set Variable    ${scell_mapping[${item}]['all_cell_info']['physicalCellId']}
        ${scell_physical_cellid}    convert to string     ${scell_physical_cellid}
        Append To List    ${scell_physical_cellid_list}    ${scell_physical_cellid}
    END
    List Should Contain Value    ${scell_physical_cellid_list}    ${pcell_physCellId[0]}

Check New Added Scell Id After Pcell Change
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}     ${new_scell_list}
    Setup Pcap File   file_path=${log_path}    filter=f1ap.procedureCode == 12
    ${new_scell_physCellId}    Get Field Value From PCAP    field_name=nr-rrc.physCellId
    ...                                                      filter_expression=nr-rrc.sCellToAddModList
    ${new_scell_physCellId}    Remove Duplicates    ${new_scell_physCellId}
    ${scell_physical_cellid_list}    Create List
    FOR  ${item}  IN   @{new_scell_list}
        ${scell_physCellId}    Set Variable   ${scell_mapping[${item}]['all_cell_info']['physicalCellId']}
        ${scell_physCellId}    convert to string     ${scell_physCellId}
        Append To List    ${scell_physical_cellid_list}    ${scell_physCellId}
    END
    Lists Should Be Equal    ${new_scell_physCellId[0]}    ${scell_physical_cellid_list}

Check MeasPCellSwitchSsbRsrp And MeasId During Attach
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}    ${cell_index}    ${pcell_change_method}=A1
    ${ThresholdPCellSwitchSsbRsrp}    Run Keyword If    '${pcell_change_method}'=='A1'
    ...                               Get a1MeasPCellSwitchSsbRsrp From SCF   cell_index=${cell_index}
    ...                       ELSE    Get a2MeasPCellSwitchSsbRsrp From SCF    cell_index=${cell_index}
    Convert Pcap File To pdml    log_path=${log_path}
    ${filter_expression}    Set Variable If    '${pcell_change_method}'=='A1'
    ...    (f1ap.procedureCode == 12) && (nr-rrc.reportConfigToAddModList != 1)&&(nr-rrc.reportConfigToRemoveList == 1) && (nr-rrc.a1_Threshold)
    ...    (f1ap.procedureCode == 12) && (nr-rrc.reportConfigToAddModList != 1)&&(nr-rrc.reportConfigToRemoveList == 1) && (nr-rrc.a2_Threshold)
    ${a1_threshold_xpath}    Set Variable
    ...                                         .//nr-rrc.eventId/nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.measTriggerQuantity.rsrp
    ${a2_threshold_xpath}    Set Variable
    ...                                         .//nr-rrc.eventId/nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.measTriggerQuantity.rsrp
    ${xpath}    Set Variable If    '${pcell_change_method}'=='A1'    ${a1_threshold_xpath}    ${a2_threshold_xpath}
    ${threshold}    Get Field Value From Pdml
    ...    filter_expression=${filter_expression}
    ...    xpath=${xpath}
    List Should Contain Value    ${threshold}    ${ThresholdPCellSwitchSsbRsrp}
    ${index}    Get Index From List    ${threshold}    ${ThresholdPCellSwitchSsbRsrp}
    ${reportConfigId}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.reportConfigToAddModList != 1)&&(nr-rrc.reportConfigToRemoveList == 1)
    ...    xpath=.//nr-rrc.ReportConfigToAddMod_element/nr-rrc.reportConfigId
    ${report_id}    Get From List    ${reportConfigId}    ${index}
    ${reportConfigId_in_measIdToAddModList}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.measIdToAddModList)
    ...    xpath=.//nr-rrc.MeasIdToAddMod_element//nr-rrc.reportConfigId
    List Should Contain Value    ${reportConfigId_in_measIdToAddModList}    ${report_id}
    ${measid_in_measIdToAddModList}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.measIdToAddModList)
    ...    xpath=.//nr-rrc.MeasIdToAddMod_element//nr-rrc.measId
    ${index}    Get Index From List     ${reportConfigId_in_measIdToAddModList}    ${report_id}
    ${measId_during_attach}    Get From List    ${measid_in_measIdToAddModList}    ${index}
    Set Test Variable     ${measId_during_attach}


Check Scell Release Success In CPIF Log
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]     ${log_path}    ${sCellIndex_in_cpif}
    Convert CPIF Pcap To Pdml    file_path=${log_path}
    ${release_scell_index}    Get Field Value From Pdml
    ...                       filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.sCellToReleaseList)
    ...                       xpath=.//nr-rrc.SCellIndex
    Should Not Be Empty    ${release_scell_index}    msg=Scell Release Failure!
    List Should Contain Value    ${release_scell_index}    ${sCellIndex_in_cpif}

Check Scell Addition Process During Attach
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}    ${scell_index_list}    ${scell_technology}    ${pcell_index}
    ${sCellIndex_in_cpif}    Check Scell Addition Success With Expected ScellID    log_path=${log_path}
    ...                                                   scell_index_list=${scell_index_list}
    ...                                                   scell_technology=${scell_technology}
    Run Keyword If    '${scell_technology}'=='TDD'    Check Scell A1 Threshold And Deactivate For TDD Cell
    ...                log_path=${log_path}    pcell_index=${pcell_index}
    ...       ELSE    A1 Threshold Should Be High   log_path=${log_path}    pcell_index=${pcell_index}
    run keyword and ignore error    Check UE not released During Attach     file_path=${log_path}
    [Return]    ${sCellIndex_in_cpif}


Check UE not released During Attach
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to check not released during ue attach from cpif
    ...                ue rnti changes once ue released
    [Arguments]    ${file_path}
    ...    ${filter}=ngap||rrc||f1ap||x2ap
    Logs.Setup Pcap File    file_path=${file_path}
    ...                filter=${filter}
    ${message_filter}    Set Variable    f1ap.procedureCode == 5 && f1ap.C_RNTI
    ${rnti_list}    Get Field Value From Pdml
    ...                                               filter_expression=${message_filter}
    ...                                               xpath=.//f1ap.C_RNTI
    ${rnti_length}    Get Length    ${rnti_list}
    Should Be True 	${rnti_length} < ${3}    msg=rach sevaral times,not a valid result.

Check Scell A1 Threshold And Deactivate For TDD Cell
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}    ${pcell_index}
    A1 Threshold Should Be Low     log_path=${log_path}    pcell_index=${pcell_index}
    ${event_id_list}    Create List    0
    Add Meaurement Configuration For Target Event Id    log_path=${log_path}    event_id_list=${event_id_list}
    ${ReportConfigId_value}    ${MeasId_value}    Delete Measurement Configuration Via RRC Reconfiguration
    ...                                           log_path=${log_path}
    List Should Contain Sub List    ${MeasId_value}    ${measId_list}
    List Should Contain Sub List    ${ReportConfigId_value}    ${reportConfigId_list}

Check Scell Addition Success With Expected ScellID
    [Documentation]    author:lei.jia@nokia-sbell.com
    ...                check scell addition success via cpif with expected scell ids, and return sCellIndex.
    [Arguments]    ${log_path}    ${scell_index_list}    ${scell_technology}
    ${scell_mapping}    Set Variable If    '${scell_technology}'=='TDD'    ${TDD_SCELL_MAPPING}    ${FDD_SCELL_MAPPING}
    Convert Pcap File To pdml    log_path=${log_path}
    ${physcellid_list}    Get Field Value From Pdml
    ...    filter_expression=nr-rrc.rrcReconfiguration_element && nr-rrc.physCellId
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ${physcellid_list}    Remove Duplicates  ${physcellid_list}
    ${scell_physical_cellid_list}    Create List
    FOR  ${scell_index}  IN  @{scell_index_list}
        ${scell_physical_cellid}    Set Variable   ${scell_mapping[${scell_index}]['all_cell_info']['physicalCellId']}
        ${scell_physical_cellid}    convert to string     ${scell_physical_cellid}
        Append To List    ${scell_physical_cellid_list}    ${scell_physical_cellid}
    END
    Run Keyword And Ignore Error    Lists Should Be Equal    ${physcellid_list}    ${scell_physical_cellid_list}
    ...    msg=scell addition failed with ${physcellid_list}!
    ${sCellIndex_in_cpif}    create list
    FOR  ${physcellid}  IN  @{physcellid_list}
        ${sCellIndex}    Get Field Value From Pdml
        ...    filter_expression=nr-rrc.rrcReconfiguration_element && (nr-rrc.physCellId == ${physcellid})
        ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellIndex
        ${sCellIndex_in_cpif}    Combine Lists    ${sCellIndex_in_cpif}    ${sCellIndex}
    END
    ${sCellIndex_in_cpif}    Remove Duplicates    ${sCellIndex_in_cpif}
    [Return]    ${sCellIndex_in_cpif}

Check Bulk Release Procedure In CPIF
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}
    Convert Pcap File To pdml    log_path=${log_path}
    ${nG_Interface}    Get Field Value From Pdml
    ...    filter_expression=ngap.procedureCode == 20
    ...    xpath=.//ngap.nG_Interface
    ...    attribute_name=showname
    Run Keyword And Continue On Failure    Should be Equal AS Strings     ${nG_Interface[0]}    nG-Interface: reset-all (0)

Check Measurement Report Triggered But No RRC Reconfiguration Message
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]     ${log_path}    ${scell_index_list}
    ${pcell_phyCellId}    Set Variable    ${PCELL_MAPPING['physicalCellId']}
    Convert Pcap File To pdml    log_path=${log_path}
    ${rsrp_xpath}    Set Variable    .//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
    ${pcell_rsrp}    Get Field Value From Pdml
    ...    filter_expression=((f1ap.procedureCode == 13) && (nr-rrc.physCellId == ${pcell_phyCellId}))
    ...    xpath=${rsrp_xpath}
    Should Not Be Empty    ${pcell_rsrp}
    FOR  ${item}  IN   @{scell_index_list}
        ${scell_phyCellId}     Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_rsrp}    Get Field Value From Pdml
        ...    filter_expression=((f1ap.procedureCode == 13) && (nr-rrc.physCellId == ${scell_phyCellId}))
        ...    xpath=${rsrp_xpath}
        Should Not Be Empty    ${scell_rsrp}
    END
    ${result}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12)
    ...    xpath=.//nr-rrc.ReportConfigToAddMod_element//nr-rrc.reportConfigId
    Should Be Empty    ${result}

Create a1ThresholdSCellAddSsbRsrp parameters
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${cellid}=1
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    @{a1MeasSCellAddSsbRsrp_value}    create list
    @{a1MeasSCellAddSsbRsrp}    create list
    ${a1MeasSCellAddSsbRsrp_params}    create dictionary    a1ThresholdSCellAddSsbRsrpFDD=None
    ...    a1ThresholdSCellAddSsbRsrpTDD=None
    Append To List    ${a1MeasSCellAddSsbRsrp_value}   ${a1MeasSCellAddSsbRsrp_params}
    &{a1MeasSCellAddSsbRsrp_dict}    Create Dictionary
    ...    dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cellid}
    ...    parameter=a1MeasSCellAddSsbRsrp
    ...    value=${a1MeasSCellAddSsbRsrp_value}
    Append To List    ${a1MeasSCellAddSsbRsrp}    ${a1MeasSCellAddSsbRsrp_dict}
    [Return]    ${a1MeasSCellAddSsbRsrp}

Get a1ThresholdSCellAddSsbRsrp From SCF
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]      ${pcell_index}
    ...              ${connection}=GNB_OAM
#    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
#    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
#    ${a1ThresholdSCellAddSsbRsrpTDD}    Get Variable Value    ${a1ThresholdSCellAddSsbRsrpTDD}
#    ${a1ThresholdSCellAddSsbRsrpFDD}    Get Variable Value    ${a1ThresholdSCellAddSsbRsrpFDD}
#    return from keyword if    '${a1ThresholdSCellAddSsbRsrpTDD}' != 'None' or '${a1ThresholdSCellAddSsbRsrpFDD}' != 'None'
    Connect to gnb coam via ssl
    ${modify_params}    Create a1ThresholdSCellAddSsbRsrp parameters    cellid=${pcell_index}
    ${a1ThresholdSCellAddSsbRsrp_values}    coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    Set Suite Variable    ${a1ThresholdSCellAddSsbRsrpTDD}    ${a1ThresholdSCellAddSsbRsrp_values[0]['value'][0]['a1ThresholdSCellAddSsbRsrpTDD']}
    Set Suite Variable    ${a1ThresholdSCellAddSsbRsrpFDD}    ${a1ThresholdSCellAddSsbRsrp_values[0]['value'][0]['a1ThresholdSCellAddSsbRsrpFDD']}
    log    pcell a1ThresholdSCellAddSsbRsrpTDD is ${a1ThresholdSCellAddSsbRsrpTDD}
    log    pcell a1ThresholdSCellAddSsbRsrpFDD is ${a1ThresholdSCellAddSsbRsrpFDD}

Get a1MeasPCellSwitchSsbRsrp From SCF
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]      ${cell_index}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    &{values}    Create Dictionary    a1HysteresisPCellSwitchSsbRsrp=none    a1ThresholdPCellSwitchSsbRsrp=none
    ...                               a1TimeToTriggerPCellSwitchSsbRsrp=none
    ${values}    Evaluate    [&{values}]
    &{modify_params}    Create Dictionary    dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}
    ...                 parameter=a1MeasPCellSwitchSsbRsrp
    ...                 value=${values}
    ${modify_params}    Evaluate    [&{modify_params}]
    Connect to gnb coam via ssl
    ${a1PCellSwitchSsbRsrp_values}   coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ${a1ThresholdPCellSwitchSsbRsrp}    Set Variable    ${a1PCellSwitchSsbRsrp_values[0]['value'][0]['a1ThresholdPCellSwitchSsbRsrp']}
    [Return]    ${a1ThresholdPCellSwitchSsbRsrp}

Get a2ThresholdSCellRelSsbRsrp From SCF
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]      ${cell_index}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    &{values}    Create Dictionary    a2ThresholdSCellRelSsbRsrp=none
    ${values}    Evaluate    [&{values}]
    &{modify_params}    Create Dictionary    dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}
    ...                 parameter=a2MeasSCellRelSsbRsrp
    ...                 value=${values}
    ${modify_params}    Evaluate    [&{modify_params}]
    Connect to gnb coam via ssl
    ${a2MeasSCellRelSsbRsrp_values}   coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ${a2ThresholdSCellRelSsbRsrp}    Set Variable    ${a2MeasSCellRelSsbRsrp_values[0]['value'][0]['a2ThresholdSCellRelSsbRsrp']}
    [Return]    ${a2ThresholdSCellRelSsbRsrp}

Get a2MeasPCellSwitchSsbRsrp From SCF
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]      ${cell_index}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    &{values}    Create Dictionary    a2HysteresisPCellSwitchSsbRsrp=none    a2ThresholdPCellSwitchSsbRsrp=none
    ...                               a2TimeToTriggerPCellSwitchSsbRsrp=none    pCellSwitchOffsetSsbRsrp=none
    ${values}    Evaluate    [&{values}]
    &{modify_params}    Create Dictionary    dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}
    ...                 parameter=a2MeasPCellSwitchSsbRsrp
    ...                 value=${values}
    ${modify_params}    Evaluate    [&{modify_params}]
    Connect to gnb coam via ssl
    ${a2PCellSwitchSsbRsrp_values}   coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ${a2ThresholdPCellSwitchSsbRsrp}    Set Variable    ${a2PCellSwitchSsbRsrp_values[0]['value'][0]['a2ThresholdPCellSwitchSsbRsrp']}
    [Return]    ${a2ThresholdPCellSwitchSsbRsrp}

Get Pcell Tput Type For UL Layer1
    [Documentation]   Auther:lei.jia@nokia-sbell.com
    [Arguments]       ${ul_layer}=layer1
    ${pcell_technology}    Set Variable    ${pcell_mapping['detail_cells_info']['technology']}
    ${chbw_param_name}    Set Variable If    '${pcell_technology}'=='TDD'    chBw    chBwUl
    ${pcell_chbw}    Set Variable    ${pcell_mapping['detail_cells_info']['${chbw_param_name}']}
    ${check_pcell_tput_type_ul_layer1}    Set Variable    ${pcell_chbw}_${ul_layer}
    [Return]    ${check_pcell_tput_type_ul_layer1}

Generate Pcell Tput Type For Dss Env
    [Documentation]    Author:xiangyue.zhou@noki-sbell.com
    [Arguments]    ${pcell_index}    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}
    ${pcell_lteNrDssMode}    Get lteNrDssMode From SCF    cell_index=${pcell_index}
    ${check_pcell_tput_type}    Set Variable If    '${pcell_lteNrDssMode}'=='DSS_Phase_3'    DSS_Phase_3    ${check_pcell_tput_type}
    ${check_ul_pcell_tput_type}    Set Variable If    '${pcell_lteNrDssMode}'=='DSS_Phase_3'    DSS_Phase_3    ${check_ul_pcell_tput_type}
    [Return]    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}

Generate Scell Tput Type For DSS Env
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${scell_index_list}    ${check_scell_tput_type}
    FOR  ${item}  IN  @{scell_index_list}
        ${scell_lteNrDssMode}    Get lteNrDssMode From SCF    cell_index=${item}
        ${check_scell_tput_type}    Set Variable If    '${scell_lteNrDssMode}'=='DSS_Phase_3'    DSS_Phase_3    ${check_scell_tput_type}
        Exit For Loop If  '${scell_lteNrDssMode}'=='DSS_Phase_3'
    END
    [Return]   ${check_scell_tput_type}

Generate All Cell Tput Type For DSS Env
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]   ${pcell_index}    ${scell_index_list}    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    Generate Pcell Tput Type For Dss Env    pcell_index=${pcell_index}
    ...                         check_pcell_tput_type=${check_pcell_tput_type}
    ...                         check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ${check_scell_tput_type}    Run Keyword If    ${scell_index_list} == ${None}
    ...                Set Variable   ${check_scell_tput_type}
    ...                ELSE    Run Keyword    Generate Scell Tput Type For DSS Env
    ...                scell_index_list=${scell_index_list}
    ...                check_scell_tput_type=${check_scell_tput_type}
    [Return]    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}   ${check_scell_tput_type}

Get lteNrDssMode From SCF
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${cell_index}
    ...            ${connection}=GNB_OAM
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    Connect to gnb coam via ssl    connection=${connection}
    ${lteNrDssMode}    coam_parameter.get_single_value_from_scf_file    parameter=lteNrDssMode    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
    ...                                                         connection=${connection}
    [Return]   ${lteNrDssMode}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Calculate PA Value For Scell with cell edge graceful shutdown
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${log_path}    ${scell_index}
    Generate Pcell And Scell Mapping Info    pcell_index=${scell_index}
    ${rsrp}    Get RSRP From CPIF Log    log_path=${log_path}
    ${port_initial_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    RU_id=${scell_index}
    ${a2ThresholdSCellRelSsbRsrp}    Get a2ThresholdSCellRelSsbRsrp From SCF   cell_index=${scell_index}
    ${median_value}     Evaluate    (int(${a2ThresholdSCellRelSsbRsrp})+${30}-${15})
    ${pa_upddate_value}    Evaluate    int(${rsrp})-int(${median_value})+int( ${port_initial_values[0]})
    [Return]    ${pa_upddate_value}

Get RU ID from Cell id
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_id}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${ru_id}    Get Ru Index From Cell Id Via Admin    cell_id=${cell_id}
    ${ru_id}    Evaluate    int(${ru_id})-1
    [Return]    ${ru_id}

Set PA Value For Pcell In Different Position
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                 2021-09003: Jia Lei updated for postion A which is used for peak tput.
    [Arguments]    ${log_path}    ${pcell_index}    ${pcell_position}=B    ${new_value}=80    ${force_set_pa_value}=NULL
    ${ru_id}    Get RU ID from Cell id    cell_id=${pcell_index}
    ${pa_upddate_value}    Run Keyword If    '${pcell_position}'=='A'
    ...                    Set Variable    0
    ...                    ELSE    Calculate PA Value For Pcell to Modify    ru_id=${ru_id}    log_path=${log_path}
    ...                    pcell_index=${pcell_index}     pcell_position=${pcell_position}    new_value=${new_value}
    Run Keyword If    '${pa_upddate_value}'!='None'    set test variable     ${pa_upddate_value}
    ...                 ELSE
    ...         set test variable    ${pa_upddate_value}    ${new_value}
    ${pa_value_from_pcell_position}    Set Variable If    '${pcell_position}'=='A'    ${peak_tput_PA_value}
    ...                                                                               ${pa_upddate_value}
    # in order to avoid scell rsrp above pcell rsrp(pcell switch), make all RUs RSRP low first in positon C
    Run Keyword If    '${pcell_position}'=='C'    Modify All Attenuation Ports Value For All RU   value=${new_value}
    ${pa_value}    Set Variable If   '${force_set_pa_value}'=='NULL'    ${pa_value_from_pcell_position}    ${force_set_pa_value}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_value}    RU_id=${ru_id}
    Sleep  2sec
#    Run Keyword If    '${pcell_position}'=='A'    Run Keyword If    '${stream}'=='SBTS00'
#    ...    Adjust Attenuation To Trigger Peak Tput

Calculate PA Value For Pcell to Modify
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${ru_id}    ${log_path}    ${pcell_index}    ${pcell_position}=B    ${new_value}=80
    ${rsrp}    Get RSRP From CPIF Log    log_path=${log_path}
    ${pa_upddate_value}    set variable    ${rsrp}
    return from keyword if    '${rsrp}'=='None'
    ${port_initial_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    RU_id=${ru_id}
    Get a1ThresholdSCellAddSsbRsrp From SCF   pcell_index=${pcell_index}
    ${median_value}     Run Keyword If  '${pcell_position}'=='B'
    ...                 Evaluate    (int(${a1ThresholdSCellAddSsbRsrpTDD})+int(${a1ThresholdSCellAddSsbRsrpFDD}))/2
    ...                 ELSE IF    '${pcell_position}'=='C'
    ...                 Evaluate    int(${a1ThresholdSCellAddSsbRsrpFDD})-int(${10})
    ...                 ELSE IF    '${pcell_position}'=='new_position'
    ...                 Evaluate    (int(${a1ThresholdSCellAddSsbRsrpTDD})+int(${new_value}))/2
    ...                 ELSE        Fail    msg=wrong pcell position,can't set PA value.
    ${pa_upddate_value}    Evaluate    int(${rsrp})-int(${median_value})+int( ${port_initial_values[0]})
    [Return]    ${pa_upddate_value}

Modify All Attenuation Ports Value For All RU
    [Documentation]   lei.jia@nokia-sbell.com
    ...           Modify all atteuation ports for all RUs defined in init.py
    ...           :param ${value}: <list> or <string>, it can be several values or only one.
    ...           for example:
    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
    ...           if ${value} = 10, it will set all ports under RU to value 10.
    [Arguments]    ${value}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
       ${RU_id}    evaluate    ${ru_index} - 1
       gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...    value=${value}   RU_id=${RU_id}
    END

Convert Pcap File To pdml
    [Documentation]    author:xiaoxia@nokia-sbell.com
    [Arguments]    ${log_path}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ${old_log_path}    Get Variable Value    ${old_log_path}
    return from keyword if    '${log_path}' == '${old_log_path}'
    Convert CPIF Pcap To Pdml    file_path=${log_path}
    ...                          tshark_path=${tshark_path}
    ...                          filter=${filter}
    ...                          command_template=${command_template}
    set test variable    ${old_log_path}    ${log_path}

Get RSRP From CPIF Log
    [Documentation]    author:lei.jia@nokia-sbell.com
    [Arguments]    ${log_path}
    ${pcell_phyCellId}    Set Variable    ${PCELL_MAPPING['detail_cells_info']['physicalCellId']}
    Convert Pcap File To pdml    log_path=${log_path}
    ${rsrp_xpath}    Set Variable    .//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
    ${rsrp_str}    Get Field Value From Pdml
    ...    filter_expression=((f1ap.procedureCode == 13) && (nr-rrc.physCellId == ${pcell_phyCellId})) && (nr-rrc.measResultServingMOList == 1)
    ...    xpath=${rsrp_xpath}
    ${rsrp}    set variable if     len(${rsrp_str})>0    ${rsrp_str}[0]    None
    [Return]    ${rsrp}

Get RSRQ From CPIF Log
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}
    ${pcell_phyCellId}    Set Variable    ${PCELL_MAPPING['detail_cells_info']['physicalCellId']}
    Convert Pcap File To pdml    log_path=${log_path}
    ${rsrq_xpath}    Set Variable    .//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrq
    ${rsrq_str}    Get Field Value From Pdml
    ...    filter_expression=((f1ap.procedureCode == 13) && (nr-rrc.physCellId == ${pcell_phyCellId})) && (nr-rrc.measResultServingMOList == 1)
    ...    xpath=${rsrq_xpath}
    ${rsrq}    set variable    ${rsrq_str}[0]
    [Return]    ${rsrq}

A1 Threshold Should Be Low
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]       ${log_path}    ${pcell_index}=2
    Get a1ThresholdSCellAddSsbRsrp From SCF   pcell_index=${pcell_index}
    Convert Pcap File To pdml    log_path=${log_path}
    ${a1_threshold_xpath}    Set Variable
    ...                                         .//nr-rrc.eventId/nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.measTriggerQuantity.rsrp
    ${a1_threshold}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.a1_Threshold)
    ...    xpath=${a1_threshold_xpath}
    Should Be True    "${a1_threshold[0]}"=="${a1ThresholdSCellAddSsbRsrpFDD}"

A1 Threshold Should Be High
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]       ${log_path}    ${pcell_index}=2
    Get a1ThresholdSCellAddSsbRsrp From SCF   pcell_index=${pcell_index}
    Convert Pcap File To pdml    log_path=${log_path}
#    ${a1_threshold}    Get A1 Threshold Value    log_path=${log_path}
    ${a1_threshold_xpath}    Set Variable
    ...                                         .//nr-rrc.eventId/nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.measTriggerQuantity.rsrp
    ${a1_threshold}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.reportConfigToAddModList != 1) && (nr-rrc.a1_Threshold)
    ...    xpath=${a1_threshold_xpath}
#    Should Be True    "${a1_threshold[0]}"=="${a1ThresholdSCellAddSsbRsrpTDD}"
    List Should Contain Value    ${a1_threshold}    ${a1ThresholdSCellAddSsbRsrpTDD}


Modify weightForSCellSelection Value To Trigger New Weight Sorted
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ${tdd_scell_list}    Get Dictionary Keys   ${TDD_SCELL_MAPPING}
    ${fdd_scell_list}    Get Dictionary Keys   ${FDD_SCELL_MAPPING}
    ${value}    Set Variable    10
    @{params_to_modify}    Create List
    FOR    ${item}    IN    @{tdd_scell_list}
        ${value}    Convert To String    ${value}
        &{params_to_modify_dict}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${item}
        ...                                              parameter=weightForSCellSelection    value=${value}
        ${value}    Evaluate    ${value}+40
        Append To List    ${params_to_modify}    ${params_to_modify_dict}
    END
    ${init_value}    Set Variable    10
    ${value}    Evaluate    ${value}-60
    ${value}    Set Variable If     ${value}<0    ${init_value}    ${value}
    FOR    ${item}    IN    @{fdd_scell_list}
        ${value}    Convert To String    ${value}
        &{params_to_modify_dict}   Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${item}
        ...                                             parameter=weightForSCellSelection    value=${value}
        ${value}    Evaluate    ${value}+30
        Append To List    ${params_to_modify}    ${params_to_modify_dict}
    END
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Online Modification weightForSCellSelection value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${cell_index}=2    ${value}=10    ${connection}=GNB_OAM    ${gnb_index}=0
    ${value}    Convert To String    ${value}
    &{params_to_modify_dict}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...                                              parameter=weightForSCellSelection    value=${value}
    ${params_to_modify}    Evaluate    [&{params_to_modify_dict}]
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Online Modification a1ThresholdSCellAddSsbRsrpTDD value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]   ${value}=10    ${pcell_index}=1    ${connection}=GNB_OAM    ${gnb_index}=0
    ...            ${a1ThresholdSCellAddSsbRsrpFDD}=68
    ${value}    Convert To String    ${value}
    &{value}   Create Dictionary    a1HysteresisSCellAddSsbRsrp=0  a1ThresholdSCellAddSsbRsrpFDD=${a1ThresholdSCellAddSsbRsrpFDD}
    ...                             a1ThresholdSCellAddSsbRsrpTDD=${value}
    ...                             a1TimeToTriggerSCellAddSsbRsrp=320ms
    &{a1MeasSsbRsrp}    Evaluate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}','parameter': 'a1MeasSCellAddSsbRsrp','value':[&{value}]}
    ${params_to_modify}    Create List    ${a1MeasSsbRsrp}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Online Modification a2MeashoSsbRsrq value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]   ${value}=10    ${scell_index}=1    ${connection}=GNB_OAM    ${gnb_index}=0
    ${value}    Convert To String    ${value}
    &{value}   Create Dictionary    a2HysteresishoSsbRsrq=0  a2HysteresishoSsbRsrq=${value}  a2TimeToTriggerhoSsbRsrq=ms480
    &{a2MeashoSsbRsrq}    Evaluate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${scell_index}', 'parameter': 'a2MeashoSsbRsrq','value':[&{value}]}
    ${params_to_modify}    Create List    ${a2MeashoSsbRsrq}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify maxNumOfSCellAlloc Value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${cell_list}    ${value}     ${connection}=GNB_OAM    ${gnb_index}=0
    ${value}    Convert To String    ${value}
    @{params_to_modify}    Create List
    FOR  ${item}  IN   @{cell_list}
        &{params_to_modify_dict}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${item}
        ...                         parameter=maxNumOfSCellAlloc    value=${value}
        Append To List    ${params_to_modify}    ${params_to_modify_dict}
    END
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Enable PRB blanking releated parameters For Specific FDD cell
    [Documentation]    Author:lei@nokia-sbell.com
    [Arguments]    ${scell_index_list}    ${scell_technology}   ${nbrOfBlankedPRB_value}=8     ${connection}=GNB_OAM    ${gnb_index}=0
    Run Keyword If    '${scell_technology}'=='TDD'    log to console    \nINFO: PRB blanking can only be enabled for FDD cells.
    ...                    ELSE    Enable PRB blanking releated parameters
    ...                    scell_index_list=${scell_index_list}    scell_technology=${scell_technology}
    ...                    nbrOfBlankedPRB_value=${nbrOfBlankedPRB_value}    connection=${connection}    gnb_index=${gnb_index}

Enable PRB blanking releated parameters
    [Documentation]    Author:lei@nokia-sbell.com
    [Arguments]    ${scell_index_list}    ${nbrOfBlankedPRB_value}=4     ${connection}=GNB_OAM    ${gnb_index}=0
    @{params_to_modify}    Create List
    FOR  ${cellid}  IN   @{scell_index_list}
        ${prbblanking_params}    Catenate
        ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}', 'parameter': 'actPRBBlanking, 'value': 'true},
        ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}', 'parameter': 'nbrOfBlankedPRBsHighEdgeDL',
        ...    'value': '${nbrOfBlankedPRB_value}'},
        ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}', 'parameter': 'nbrOfBlankedPRBsHighEdgeUL',
        ...     'value': '${nbrOfBlankedPRB_value}'},
        ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}', 'parameter': 'nbrOfBlankedPRBsLowEdgeDL',
        ...     'value': '${nbrOfBlankedPRB_value}'},
        ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}', 'parameter': 'nbrOfBlankedPRBsLowEdgeUL',
        ...     'value': '${nbrOfBlankedPRB_value}'}
        Append To List    ${params_to_modify}    ${prbblanking_params}
    END
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Diasble PRB blanking releated parameters
    [Documentation]    Author:lei@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    @{params_to_modify}    Create List
    ${gnb_nr_cell_id_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    FOR    ${cell_index}    IN    @{all_cell_ids}
        &{prbblanking_params}    Create Dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
        ...    parameter=actPRBBlanking    value=false
        Append To List    ${params_to_modify}    ${prbblanking_params}
    END
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get PRB for FDD cell
    [Documentation]  Author: Jia Lei
    ...              Description: caculate FDD PRBs from channal bandwidth
    [Arguments]     ${scell_index}
    ${scell_technology}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['detail_cells_info']['technology']}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${chbw}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
    ${chbw_prb} =    run keyword if    '${chbw}' == '5MHz'    set variable    ${25}
    ...    ELSE IF    '${chbw}' == '10MHz'    set variable    ${52}
    ...    ELSE IF    '${chbw}' == '15MHz'    set variable    ${79}
    ...    ELSE IF    '${chbw}' == '20MHz'    set variable    ${106}
    ...    ELSE       Log    Error: FDD channel bandwidth is larger than 20M, please confirm it.
    [Return]    ${chbw_prb}

Make_L3_Call_And_Check_Tput
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${is_do_require_ue}=${False}
    ...            ${get_attach_cell_index_needed}=${False}
    ...            ${is_wireshark_log_capture}=${True}
    ...            ${wireshark_log_prefix}=ca_attach
    ...            ${4G_check}=${False}
    ...            ${reset_sol}=none
    ...            ${sleep_interval}=30 sec
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=2400M
    ...            ${start_traffic_duration}=600
    ...            ${select_scell_index}=${None}
    ...            ${target_DL_avg_percent}=0.9
    ...            ${target_UL_avg_percent}=0.8
    ...            ${min_DL_percent}=0.5
    ...            ${min_UL_percent}=0.5
    ...            ${check_pcell_tput_type}=peak
    ...            ${check_scell_tput_type}=peak
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${check_pcell_tput}=${True}
    ...            ${check_scell_tput}=${True}
    ...            ${is_need_stop_traffic}=${True}
    ...            ${duration}=180
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${whether_collect_tput}=${True}
    ...            ${interface}=-i any -s 0 -p
    ...            ${dl_process_num}=2
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${cpif_log_path}    Start UE Attach With Power UE    is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                                wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                4G_check=${4G_check}
    ...                                                reset_sol=${reset_sol}
    ...                                                sleep_interval=${sleep_interval}
    ...                                                get_attach_cell_index_needed=${get_attach_cell_index_needed}
    ...                                                is_do_require_ue=${is_do_require_ue}
    ...                                                interface=${interface}
#    ${cpif_log_path}    Set Variable    ${attach_info['cpif_log_path']}
#    ${attach_cell_index}    Set Variable     ${attach_info['attach_cell_index']}
#    Should Be Equal    ${pcell_index}    ${attach_cell_index}
#    Run Keyword And Continue On Failure    Start L3 Call Data Transfer
#    ...                                    ul_data_transfer=${ul_data_transfer}
#    ...                                    dl_data_transfer=${dl_data_transfer}
#    ...                                    duration=${start_traffic_duration}
    Run Keyword And Continue On Failure    Start L3 Call With Power UE
    ...                                    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    duration=${start_traffic_duration}
    ...                                    dl_process_num=${dl_process_num}
    Run Keyword And Ignore error    Check Iperf Progress on APP server
    Run Keyword And Continue On Failure    Check Tput For CA Group    ue_type=${ue_type}
    ...                                           addition_scell_index_list=${select_scell_index}
    ...                                           target_DL_avg_percent=${target_DL_avg_percent}
    ...                                           target_UL_avg_percent=${target_UL_avg_percent}
    ...                                           min_DL_percent=${min_DL_percent}
    ...                                           min_UL_percent=${min_UL_percent}
    ...                                           check_pcell_tput_type=${check_pcell_tput_type}
    ...                                           check_scell_tput_type=${check_scell_tput_type}
    ...                                           check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                           check_pcell_tput=${check_pcell_tput}
    ...                                           check_scell_tput=${check_scell_tput}
    ...                                           duration=${duration}
    ...                                           scell_mapping=${scell_mapping}
    ...                                           whether_collect_tput=${whether_collect_tput}
    Run Keyword If    '${is_need_stop_traffic}'=='${True}'    Run Keyword And Ignore Error    Stop Traffic With Power UE
#    [Return]    ${cpif_log_path}    ${attach_cell_index}
    [Return]    ${cpif_log_path}

Check Iperf Progress on APP server
    [Documentation]    Author:lei.jia@nokia-sbell.com
    Log to console    \nCheck Iperf Progress on APP server
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.send_command    command=ps -ef | grep iperf     connection=APPserver    timeout=120
    ${output}    csn.read_output    size=1000    connection=APPserver
    ${iperf_tput} =    get regexp matches    ${output}    \\b(\\d+)M\\b
    ${tput_num}=      get length     ${iperf_tput}
    ${total_iperf_traffic}    run keyword if    ${tput_num}
    ...    Get Total Iperf traffic on Appserver    iperf_tput=${iperf_tput}
    ...    ELSE    set variable    0
    Log to console    \nTotal traffic on Appserver is: ${total_iperf_traffic}M!
    [Teardown]    csn.disconnect    connection=APPserver

Get Total Iperf traffic on Appserver
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${iperf_tput}
    @{iperf_value_list}    create list
    FOR  ${item}  IN   @{iperf_tput}
        ${item}    Remove String    ${item}    M
        ${integer_item}    convert to integer    ${item}
        append to list    ${iperf_value_list}    ${integer_item}
    END
    ${total_iperf_traffic} =    evaluate    sum(${iperf_value_list})
    [Return]    ${total_iperf_traffic}

Cell AdministrativeState Modification via rest api
    [Documentation]    author:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_index}=${PCELL_ID}    ${cell_administrativeState}=Locked
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...             ${mr_bts_id}=${tl.gnbs[0].instance_id}
    ${cell_administrativeState_parameter}    Catenate
    ...    {'parameter': 'administrativeState', 'dist_name': 'MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}',
    ...     'value': '${cell_administrativeState}'}
    ${update_param_list}    Evaluate    [${cell_administrativeState_parameter}]
    Wait Until Keyword Succeeds   3 min    20 sec    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=600

Power Reset eNB After gNB Upgrade for RFS
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${unit_index}=${0}
    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
    BuiltIn.Log    Reset eNB via Power off and On
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
    Sleep    5sec
    pdu.power_on    port=${enb_pdu_port}    pdu_device=enb_pdu

Upgrade Enb For RFS
    [Arguments]    ${timeout}=${1800}     ${connection}=enblte
    ${status}    Run Keyword And Return Status    Connect to eNB via ssl
    run keyword if     not ${status}    run keywords    Power Reset eNB After gNB Upgrade for RFS    AND    Sleep    5min   AND
    ...                                                 Connect to eNB via ssl
    ${enb_active_version}    Get Active SW Version    connection=${connection}
    return from keyword if    '${enb_active_version}' == '${Active_SW_version}' or '${stream}'!='SBTS00'
    LOG TO CONSOLE    ${SPACE*2}try to upgrade eNB again.
    ${bts_stream}    ${bts_version}    Split String From Right    ${Active_SW_version}    ENB     1
    ${sw_path}    CI_commssion.Get SW file Path    build=${stream}_ENB${bts_version}    stream=${stream}
    Sleep    5s
    taf.sbts.oam.coam.admin.update_software     sw_package=${sw_path}     should_activate=True    timeout=${timeout}   connection=${connection}
    Sleep    30s
    LOG TO CONSOLE   ${SPACE*2}eNB upgrade is done.

Wireshark setup Before Run case
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    Get NSETAP_X File And Copy To Wireshark Path
    Configure Wireshark NSETAP_X Protocol    port_number=20500,20501,49392,49151,49148,15010-15014

Start wireshark capture from gNB
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}=tcpdump_tcp    ${interface}=br1    ${alias}=ASIK Master
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${alias}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump tcp -i ${interface} -w /tmp/${filename}.pcap     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${filename}    connection_alias=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop wireshark capture from gNB
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}=tcpdump_tcp    ${logpath}=${TS_CASE_LOG_PATH}    ${alias}=ASIK Master
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}_${timestamp}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Check ReportRecord Infor From Tcpdump
    [Arguments]     ${log_full_path_ute}
    @{reportRecords_infor_a}    Create list     csiReportRecord    caSCellCsiReportRecord    beamReportRecord
    ...                                      caSCellBeamReportRecord    pwrHeadroomRecord    directionOfArrivalRecord
    @{reportRecords_target_infor_check_traceId}    Create list    00:00:01    00:00:02
    FOR    ${reportRecord_infor}    IN    @{reportRecords_infor_a}
            Setup Pcap File    file_path=${log_full_path_ute}     filter=ntrstr
            ${traceId_infor}    Get Field Value From PCAP    field_name=nsetapx.traceId
            ...                                              filter_expression=nsetapx.${reportRecord_infor}
            ${traceId_infor}    Remove Duplicates    ${traceId_infor}
            run keyword and continue on failure     Check ReportRecord Infor Is Correct    traceId_infor=${traceId_infor}
            ...                                                     reportRecords_target_infor=${reportRecords_target_infor_check_traceId}
    END
    @{reportRecords_infor_c}    Create list    gnb_cu_up_Id    gnb_du_Id    gnb_cu_Id_element    ueCallType
    @{reportRecords_target_infor_check_ueCallType}    Create list    0
    FOR    ${reportRecord_infor}    IN    @{reportRecords_infor_c}
            Setup Pcap File    file_path=${log_full_path_ute}     filter=ntrstr && nsetapx.ueCallType
            ${traceId_infor}    Get Field Value From PCAP    field_name=nsetapx.ueCallType
            ...                                              filter_expression=nsetapx.${reportRecord_infor}
            ${traceId_infor}    Remove Duplicates    ${traceId_infor}
            run keyword and continue on failure     Check ReportRecord Infor Is Correct    traceId_infor=${traceId_infor}
            ...                                                reportRecords_target_infor=${reportRecords_target_infor_check_ueCallType}
    END

Check ReportRecord Infor Is Correct
    [Arguments]    ${traceId_infor}    ${reportRecords_target_infor}
    ${traceId_infor_length}    Get Length    ${traceId_infor}
    Should Be True    ${traceId_infor_length}>0
    FOR    ${traceId}    IN    @{traceId_infor}
        ${traceId}    Remove Duplicates    ${traceId}
        List Should Contain Sub List    ${reportRecords_target_infor}    ${traceId}
    END

CB008015_A_Common_Test_Steps
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}=1
    ...            ${index_in_sorted_scell_weight_list}=0
    ...            ${is_do_require_ue}=${False}
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=2000M
    ...            ${start_traffic_duration}=600
    ...            ${scell_index_list}=${None}
    ...            ${check_pcell_tput}=${True}
    ...            ${check_scell_tput}=${True}
    ...            ${check_pcell_tput_type}=peak
    ...            ${check_scell_tput_type}=peak
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9
    ...            ${target_UL_avg_percent}=0.9
    ...            ${min_DL_percent}=0.8
    ...            ${min_UL_percent}=0.8
    ...            ${is_do_scell_lock}=${False}
    ...            ${is_do_scell_unlock}=${False}
    ...            ${is_do_PA_adjust_for_pcell}=${False}
    ...            ${pcell_position}=B
    ...            ${is_need_stop_traffic}=${True}
    ...            ${duration}=180
    ...            ${force_set_pa_value}=NULL
    ${scell_index_list}    ${scell_technology}    Run Keyword If    '${check_scell_tput}'=='${True}'
    ...                    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=${index_in_sorted_scell_weight_list}
    ${check_pcell_tput_type}     ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                         Generate All Cell Tput Type For DSS Env
    ...                         pcell_index=${pcell_index}
    ...                         scell_index_list=${scell_index_list}
    ...                         check_pcell_tput_type=${check_pcell_tput_type}
    ...                         check_scell_tput_type=${check_scell_tput_type}
    ...                         check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ${cpif_log_path}    Make_L3_Call_And_Check_Tput
    ...                 is_do_require_ue=${is_do_require_ue}
    ...                 ul_data_transfer=${ul_data_transfer}
    ...                 dl_data_transfer=${dl_data_transfer}
    ...                 start_traffic_duration=${start_traffic_duration}
    ...                 select_scell_index=${scell_index_list}
    ...                 target_DL_avg_percent=${target_DL_avg_percent}
    ...                 target_UL_avg_percent=${target_UL_avg_percent}
    ...                 min_DL_percent=${min_DL_percent}
    ...                 min_UL_percent=${min_UL_percent}
    ...                 check_pcell_tput=${check_pcell_tput}
    ...                 check_scell_tput=${check_scell_tput}
    ...                 check_pcell_tput_type=${check_pcell_tput_type}
    ...                 check_scell_tput_type=${check_scell_tput_type}
    ...                 check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                 is_need_stop_traffic=${is_need_stop_traffic}
    ...                 duration=${duration}
    Set Test Variable    ${cpif_log_path}
#    Set Test Variable    ${attach_cell_index}
#    ${sCellIndex_in_cpif}    Run Keyword If    '${check_scell_tput}' == '${True}'    Run Keyword And Continue On Failure
#    ...               Check Scell Addition Process During Attach     log_path=${cpif_log_path}
#    ...                                                              scell_index_list=${scell_index_list}
#    ...                                                              scell_technology=${scell_technology}
#    ...                                                              pcell_index=${pcell_index}
#    ...    ELSE        Run Keyword And Continue On Failure    Check No Scell Addition    log_path=${cpif_log_path}   log_type=cpif
#    Set Test Variable    ${sCellIndex_in_cpif}
    Run Keyword If    '${is_do_scell_lock}'=='${True}'    Perform SCell Lock     cell_idx=${scell_index_list[0]}
    Run Keyword If    '${is_do_scell_unlock}'=='${True}'    Perfrom Scell Unlock
    Run Keyword If    '${is_do_PA_adjust_for_pcell}'=='${True}'    Set PA Value For Pcell In Different Position
    ...               log_path=${cpif_log_path}    pcell_index=${pcell_index}    pcell_position=${pcell_position}
    ...               force_set_pa_value=${force_set_pa_value}


Perform SCell Lock
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${cell_idx}
    ${cell_group_idx}    Set Variable
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Perform cell lock via rest api    cell_idx=${cell_idx}
    Sleep    10s
    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_idx}    cell_group_idx=${cell_idx}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Perfrom Scell Unlock
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ${tdd_scell_list}    Get Dictionary Keys    ${TDD_SCELL_MAPPING}
    ${fdd_scell_list}    Get Dictionary Keys    ${FDD_SCELL_MAPPING}
    ${all_scell_list}    Combine Lists    ${tdd_scell_list}    ${fdd_scell_list}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    FOR    ${item}    IN    @{all_scell_list}
        Run keyword and ignore error     Perform cell unlock via rest api    cell_idx=${item}
        Sleep    10s
        Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Unlocked    cell_idx=${item}    cell_group_idx=${item}
    END
   [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Perform BBMOD reset via webui
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]     ${abil_index}=1
    COAM Navigate to login page via webUI
    selenium_coam.reset_abil    abil_index=${abil_index}
    wait until keyword succeeds    2min    1s    Check BBMOD status Is Disable    abil_index=${abil_index}
    [Teardown]     run keyword and ignore error    run keywords    COAM selenium logout

Check BBMOD status Is Disable
    [Documentation]   Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]     ${abil_index}
    ${abil_info}    selenium_coam.get_abil_info     abil_index=${abil_index}
    Should Be Equal   ${abil_info['Status']['Availability status']}    off line
    Should Be Equal   ${abil_info['Status']['Operational state']}    disabled

Enable CB007235 parameters
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ${params_to_modify}    Catenate
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}', 'parameter': 'actCellTraceReport', 'value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}', 'parameter': 'actMDTTraceReport', 'value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}', 'parameter': 'actPCMDReport','value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}', 'parameter': 'actSubscriberTraceReport','value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3', 'parameter': 'actUlSrsBm','value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3', 'parameter': 'actDlSrsBm','value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-4', 'parameter': 'actUlSrsBm','value': 'true'},
    ...    {'dist_name': 'MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-4', 'parameter': 'actDlSrsBm','value': 'true'}
    ${params_to_modify}    Evaluate     [${params_to_modify}]
    Connect to gnb coam via ssl    connection=${connection}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Update UE Attach Cell Index on SA Mode
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${attach_cell_index}    ${connection}=GNB_OAM    ${timeout}=180
    run keyword and ignore error   COAM Teardown gnb connections
    run keyword and ignore error    Connect to gnb coam via ssl
    @{expected_cell_list}    create list    ${attach_cell_index}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_cell_list}    connection=${connection}
    ...                                              timeout=${timeout}
    Sleep    90s    Wait for calibration setup
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Lock cell on eNB
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    ...                Descrition：Block/Unblock cell from LTE, while NR call is ongoing, verify NR call is continue.
    [Arguments]     ${enb_connection}=enblte    ${enb_index}=${0}    ${timeout}=600
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    enblte.block    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-501/LNCEL_R-0
        ...    connection=${enb_connection}    timeout=${timeout}
    [Teardown]    run keyword and ignore error    Enblte close down

Unlock cell on eNB
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    ...                Descrition：Block/Unblock cell from LTE, while NR call is ongoing, verify NR call is continue.
    [Arguments]     ${enb_connection}=enblte    ${enb_index}=${0}    ${timeout}=600
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    enblte.unblock    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-501/LNCEL_R-0
    ...    connection=${enb_connection}    timeout=${timeout}
    [Teardown]    run keyword and ignore error    Enblte close down

Check And Power on RUs
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END
