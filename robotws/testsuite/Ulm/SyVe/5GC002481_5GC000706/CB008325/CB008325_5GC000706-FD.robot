*** Settings ***
Documentation   Robot Test Suite for feature CB008325-SR-B_Mobility_SA_Intra/inter_frequency_intra/inter_gNB_mobility \n
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp63' \n
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com' \n
Force Tags      CB008325    CB008325_706    RAN_5G_FDD_CRT
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem

Library    taf.hw.rf_attenuator              WITH NAME   attenuator
Library    taf.ul.messaging.mtk              WITH NAME   mtk
Library    taf.ue

Library    ute_tshark

Library    ../5GC000706.py

Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/tcpdump.robot

Resource    ../../resources/attenuator_scenario.robot
Resource    ../../resources/Mediatek.robot
Resource    ../../resources/hanging_resources.robot
Resource    ../../resources/scf_info.robot
Resource    ../5GC002481_5GC000706_verification.robot
Resource    ../5GC002481_5GC000706_keywords.robot

Resource    CB008325_706_Commissioning.robot


Suite Setup      Prepare TL for Testing
Suite Teardown   Save all Logs and Teardown TL


*** Variables ***
${DL_RATE}      20Mbits/sec
${UL_RATE}      5Mbits/sec
${DEVIATION}    20%
${DURATION}     300s
${PROTOCOL}     udp
${UE_ALIAS_1}   UE_1
${LOGS}         X2-C_S1-C_IFs, testSuiteConfigs

*** Test Cases ***
5GC000706-FD-02_Inter-Frequency_Intra-Band_Intra-gNB-Intra-DU_FR1-FDD-to-FR1-FDD_HO_A3-Event_Trigger
    [Documentation]    Verify A3-event triggered Intra-gNB-Intra-DU Inter-Freq SA HO(Intra-Band) between source and target FDD
    ...                cells within the same gNB-DU i.e. Intra-DU Inter-Freq FDD->FDD HO for a UE in SA Mode.
    [Tags]             CB008325  CB008325_5GC000706  CB008325_5GC000706-FD  INTRA  reconfigWSync  CB008325_706-FD_TC02  RAN_5G_FDD_CRT
    [Setup]            Perform Preconditions of Test Scenario

    Start Tcpdump on gNB
    Attach MTK UE, Start and Stop Traffic, Detach    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}
    ...    duration=${DURATION}    scenario=5GC000706-FDD02    ue_alias=${UE_ALIAS_1}    protocol=${PROTOCOL}
    Stop Tcpdump on gNB
    Verify qc test case

    [Teardown]    5GC002481_5GC000706_keywords.Combined Test Teardown
#----------------------------------------------------------------------------------------------------------------------#

5GC000706-FD-05_Inter-Frequency_Intra-Band_Inter-gNB_FR1-FDD-to-FR1-FDD_HO_A5-Event_Trigger_Interaction_with_DRX_feature_5GC000772
    [Documentation]    Verify A5 event triggered Inter-gNB Inter-Freq FDD->FDD HO for a UE in SA Mode along with the test
    ...                for DRX interaction (i.e. Measurement gaps configuration would release DRX config and vice versa).
    [Tags]             CB008325  CB008325_5GC000706  CB008325_5GC000706-FD  INTER  CB008325_706-FD_TC05  RAN_5G_FDD_CRT
    [Setup]            Perform Preconditions of Test Scenario

    Start Tcpdump on gNB
    Attach MTK UE, Start and Stop Traffic, Detach    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}    ue_alias=${UE_ALIAS_1}
    ...    duration=${DURATION}    scenario=5GC000706-FDD05    protocol=${PROTOCOL}    transfer=${1}
    Configure actCDrx  gnb_id=${gnb_id_source}  nrcell_id=1  actCDrx=false
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${gnb_id_source}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${gnb_id_target}
    attenuator.Set Attenuator to Max Value
    attenuator_scenario.set cell attenuation  globalcellid=${gnb_cellid_source}  value=${20}  node_id=${gnb_id_source}  node_type=gnb
    Attach MTK UE, Start and Stop Traffic, Detach    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}    ue_alias=${UE_ALIAS_1}
    ...    duration=${DURATION}    scenario=5GC000706-FDD05    protocol=${PROTOCOL}    transfer=${2}
    Stop Tcpdump on gNB
    Verify qc test case

    [Teardown]    5GC002481_5GC000706_keywords.Combined Test Teardown
                  Configure actCDrx  gnb_id=${gnb_id_source}  nrcell_id=1  actCDrx=true
                  Load initial gnb scf
                  Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${0}
                  Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${1}
                  Commission delta gnb_scf

#----------------------------------------------------------------------------------------------------------------------#
5GC000706-FD-07_Inter-Frequency_Inter-Band_Inter_or_Intra-gNB_FR1-FDD-to-FR1-FDD_HO_A3_or_A5-Event_Trigger
    [Documentation]    A3/A5-Event Triggered Inter-gNB Inter-Freq SA HO(Inter-Band) between source and target FDD cells
    ...                in 2 different gNBs i.e. this is to verify Inter-gNB Inter-Freq (Inter-Band) FDD->FDD HO for a UE
    ...                in SA Mode.
    ...                Inter-Frequency Handover via Xn feature is enabled (MRBTS/NRBTS/actInterFreqHoSA = true) on both
    ...                the gNBs
    [Tags]             CB008325  CB008325_5GC000706  CB008325_5GC000706-FD  INTER  reconfigWSync  CB008325_706-FD_TC07  RAN_5G_FDD_CRT
    ...                RAN_5G_FDD_CIT
    [Setup]            Perform Preconditions of Test Scenario

    Start Tcpdump on gNB
    Attach MTK UE, Start and Stop Traffic, Detach    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}    ue_alias=${UE_ALIAS_1}
    ...    duration=${DURATION}    scenario=5GC000706-FDD07    protocol=${PROTOCOL}
    Stop Tcpdump on gNB
    Verify qc test case

    [Teardown]    5GC002481_5GC000706_keywords.Combined Test Teardown

#----------------------------------------------------------------------------------------------------------------------#

*** Keywords ***
Set gNB cell attenuation
    [Arguments]    ${scenario}=SEN1
    [Documentation]    starts predifined attenuation scenario
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${template}=  OperatingSystem.Get File  ${CURDIR}/attenuator_scenario_8325_706-FD.txt
    ${message}=  Replace Variables  ${template}
    OperatingSystem.Create File  ${resultSuiteBaseDir}/attenuator_scenario_tl.txt  ${message}
    attenuator_scenario.run attenuator scenario by cell  att_file=${resultSuiteBaseDir}/attenuator_scenario_tl.txt    scenario=${scenario}

Perform Preconditions of Test Scenario
    [Arguments]    ${ue_alias}=${UE_ALIAS_1}
    Create testcase log directory
    Log Variables
    Log to console    \n
    ${resultTestDir}=    testline.Get testcase log directory
    Set test variable  ${resultTestDir}
    Log to console    SW Branch: ${gnb_sw_branch}
    IF    'CB008325_706-FD_TC02' in ${TEST TAGS}
        Set gNB ids    gnb_id_target=${0}    gnb_id_source=${0}    ru_id_source=${0}    ru_id_target=${1}
    ELSE IF    'CB008325_706-FD_TC05' in ${TEST TAGS}
        Set gNB ids    gnb_id_target=${0}    gnb_id_source=${1}    ru_id_source=${1}    ru_id_target=${0}
        Commission delta gnb_scf for FD-05
    ELSE IF    'CB008325_706-FD_TC07' in ${TEST TAGS}
        Set gNB ids    gnb_id_target=${0}    gnb_id_source=${1}    ru_id_source=${2}    ru_id_target=${2}
    END
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${gnb_id_source}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${gnb_id_target}
    IF    'CB008325_706-FD_TC07' in ${TEST TAGS}
        Set NRBTS-ID source and target for 5GC000706-FD-07 or 5GC000706-FD-05
    ELSE IF    'CB008325_706-FD_TC05' in ${TEST TAGS}
        Set NRBTS-ID source and target for 5GC000706-FD-07 or 5GC000706-FD-05
    ELSE IF    'CB008325_706-FD_TC02' in ${TEST TAGS}
        Set NRBTS-ID source and target for 5GC000706-FD-02
    END
    gnb.Get SCF from gNB    gnb_id=${gnb_id_source}    target_dir=${configSuiteDir}
    gnb.Get SCF from gNB    gnb_id=${gnb_id_target}    target_dir=${configSuiteDir}
    Get physCellIds
    Log to console    Source physical cellId ${physCellIdSource}
    Log to console    Target physical cellId ${physCellIdTarget}
    sleep  10s
    taf.ue.Require Ue    ${ue_alias}  capabilities=REAL_MTK_UE
    sleep  10s  reason=wait release of resources
    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id_source}  node_type=gnb
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id_target}  node_type=gnb
    attenuator.Set Attenuator to Max Value
    attenuator_scenario.set cell attenuation  globalcellid=${gnb_cellid_source}  value=${20}  node_id=${gnb_id_source}  node_type=gnb
    IF    ('X2-C_S1-C_IFs' in '${LOGS}')    tcpdump.Start TCPdump on all eNBs
    setup tshark    eth1
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources before test for all nodes

Set NRBTS-ID source and target for 5GC000706-FD-02
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  ${gnb_id_source}
    Set test variable  ${nrbts_id_${gnb_id_source}}  ${nrbts_id_0}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id_target}
    Set test variable  ${nrbts_id_${gnb_id_target}}  ${nrbts_id_1}
    Log to console    Source gNB: ${nrbts_id_${gnb_id_source}} ${nrbts_id_0}
    Log to console    Target gNB1: ${nrbts_id_${gnb_id_target}} ${nrbts_id_1}

Set NRBTS-ID source and target for 5GC000706-FD-07 or 5GC000706-FD-05
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  ${gnb_id_target}
    Set test variable  ${nrbts_id_${gnb_id_target}}  ${nrbts_id_0}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id_source}
    Set test variable  ${nrbts_id_${gnb_id_source}}  ${nrbts_id_1}
    Log to console    Source gNB: ${nrbts_id_${gnb_id_source}} ${nrbts_id_1}
    Log to console    Target gNB1: ${nrbts_id_${gnb_id_target}} ${nrbts_id_0}

Verify qc test case
    [Documentation]   Check A3 reports and based on it check selected target cell for HO
    ...               Check RRC reconfiguration is sent to the UE with reconfigurationWithSync including targetPhysCellId - the new PCell for UE
    ...               Check RACH-ConfigDedicated IE in the CellGroupConfig IE is included in the RRC Reconfiguration
    ...               Check UE perform RLC re-establishment, HO is successful and data traffic after HO isn’t suspended and degraded
    ...               (none of the packets are lost)
    log to console    Starting TC Verification
    Convert PCAP2PDML
    IF  'CB008325_5GC000706' in ${TEST TAGS}
        Check wireshark for a3_Offset  tcp_file=${tcp_file_gnb_source_master}
        Check wireshark for ssb_RSRP  tcp_file=${tcp_file_gnb_source_master}
        Check wireshark for mcs_Table  tcp_file=${tcp_file_gnb_source_master}
    END
    IF  'CB008325_706-FD_TC05' in ${TEST TAGS}
        Check InitialUEmessage  tcp_file=${tcp_file_gnb_target_master}
        Check InitialContextSetupRequest message  tcp_file=${tcp_file_gnb_target_master}
        Check InitialContextSetupResponse message  tcp_file=${tcp_file_gnb_target_master}
    ELSE IF  'CB008325_706-FD_TC07' in ${TEST TAGS}
        Check InitialUEmessage  tcp_file=${tcp_file_gnb_target_master}
        Check InitialContextSetupRequest message  tcp_file=${tcp_file_gnb_target_master}
        Check InitialContextSetupResponse message  tcp_file=${tcp_file_gnb_target_master}
    END
    IF  'CB008325_5GC000706' in ${TEST TAGS}  Check wireshark for cfra_element  tcp_file=${tcp_file_gnb_source_master}
    IF  'INTER' in ${TEST TAGS}
        Check HandoverRequest cause  tcp_file=${tcp_file_gnb_source_master}
        Check HandoverRequest radioNetwork  tcp_file=${tcp_file_gnb_source_master}
        Check HandoverAcknowledge  tcp_file=${tcp_file_gnb_target_master}
        Check HandoverRequest cause  tcp_file=${tcp_file_gnb_target_master}
        Check HandoverRequest radioNetwork  tcp_file=${tcp_file_gnb_target_master}
        Check HandoverAcknowledge  tcp_file=${tcp_file_gnb_source_master}
    END
    IF  'CB008325_5GC000706' in ${TEST TAGS}
        Check MeasGapSetup  tcp_file=${tcp_file_gnb_source_master}
        Check MeasGapRelease  tcp_file=${tcp_file_gnb_source_master}
        Check DrxConfig  tcp_file=${tcp_file_gnb_source_master}
    END
    IF  'INTER' in ${TEST TAGS}
        Check SNSStatusTranfer message  tcp_file=${tcp_file_gnb_source_master}
        Check SNSStatusTranfer message  tcp_file=${tcp_file_gnb_target_master}
        Check UEContextRelease message  tcp_file=${tcp_file_gnb_source_master}
        Check UEContextRelease message  tcp_file=${tcp_file_gnb_target_master}
    END
    IF  'CB008325_5GC000706' in ${TEST TAGS}
        Check UEContextReleaseCommand message  tcp_file=${tcp_file_gnb_source_master}
        Check UEContextReleaseComplete message  tcp_file=${tcp_file_gnb_source_master}
    END
    IF  'CB008325_706-FD_TC05' in ${TEST TAGS}
        Check PathSwitchRequest message    tcp_file=${tcp_file_gnb_source_master}
        Check PathSwitchRequestAck message    tcp_file=${tcp_file_gnb_source_master}
        Check wireshark for A5 hysteresis  tcp_file=${tcp_file_gnb_target_master}
        Check RRC Complete message  tcp_file=${tcp_file_gnb_target_master}
    ELSE IF  'CB008325_706-FD_TC07' in ${TEST TAGS}
        Check PathSwitchRequest message    tcp_file=${tcp_file_gnb_target_master}
        Check PathSwitchRequestAck message    tcp_file=${tcp_file_gnb_target_master}
        Check RRC Complete message  tcp_file=${tcp_file_gnb_target_master}
    END
    IF  'reconfigWSync' in ${TEST TAGS}  Check reconfigurationWithSync  tcp_file=${tcp_file_gnb_source_master}
    ...    physCell1=${physCellIdTarget}  physCell2=${physCellIdSource}
    IF  'CB008325_706-FD_TC02' in ${TEST TAGS}
        Check rrcRelease  tcp_file=${tcp_file_gnb_source_master}
        verify f1xn trace FD02  pdml_file_path=${resultTestDir}/Xn_traces_gnb0_master.pdml
    ELSE IF  'CB008325_706-FD_TC07' in ${TEST TAGS}
        Check rrcRelease  tcp_file=${tcp_file_gnb_target_master}
        verify f1xn trace FD07    pdml_file_path=${resultTestDir}/Xn_traces_gnb1_master.pdml  xnap=${XNAP}
        Verify f1xn trace Pathswitchsequence    pdml_file_path=${resultTestDir}/Xn_traces_gnb0_master.pdml  xnap=${XNAP}
    ELSE IF  'CB008325_706-FD_TC05' in ${TEST TAGS}
        Check rrcRelease  tcp_file=${tcp_file_gnb_source_master}
        verify f1xn trace FD05    pdml_file_path=${resultTestDir}/Xn_traces_gnb1_master.pdml  xnap=${XNAP}
        Verify f1xn trace Pathswitchsequence    pdml_file_path=${resultTestDir}/Xn_traces_gnb0_master.pdml  xnap=${XNAP}
    END
    hanging_resources.no check of resource nbOfFreeCRNTI
    hanging_resources.Verify resource usage for all nodes
