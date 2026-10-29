*** Settings ***
Documentation   Robot Test Suite for feature '5GC002481-CIAB-SyVe Test Only for 5GC000706 Inter-frequency handover via Xn (SA option 2)' \n
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp63' \n
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com' \n
Force Tags      5GC000706    706    RAN_5G_FDD_CRT
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library     String

Library     taf.hw.rf_attenuator              WITH NAME   attenuator
Library     taf.ul.messaging.mtk              WITH NAME   mtk
Library     taf.ue

Library     ute_tshark

Library     5GC000706.py

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot

Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/Mediatek.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/scf_info.robot

Resource    5GC002481_5GC000706_verification.robot
Resource    5GC002481_5GC000706_keywords.robot
Resource    5GC002481_706_Commissioning.robot


Suite Setup     Prepare TL for Testing
Suite Teardown  Save all Logs and Teardown TL


*** Variables ***
${DL_RATE}      20Mbits/sec
${UL_RATE}      5Mbits/sec
${DURATION}     300s
${PROTOCOL}     udp
${UE_ALIAS_1}   UE_1
${LOGS}         X2-C_S1-C_IFs, testSuiteConfigs

*** Test Cases ***
#----------------------------------------------------------------------------------------------------------------------#
5GC000706-C-02_Inter-Band_Inter-gNB_FR1-FDD-to-FR1-FDD_HO_Different_FR1_Bands_Intra-gNB_Inter-Band_HO_to_different_BW_Cell
     [Documentation]    Inter-gNB Inter-Freq SA HO (Inter-Band) between source and target cells configured on different
     ...                FR1 Bands with different bandwidth setting (cells are on 2 different gNBs)
     ...                - Source cell is on FDD, say, 20 MHz (NRBTS/NRCELL/NRCELL_FDD/chBwDl set to 20).
     ...                - Target cell is on FDD of another BW than source, say, 10 MHz (NRBTS/NRCELL/NRCELL_FDD/chBwDl
     ...                set to 10).
     ...                Inter-Frequency Handover via Xn feature is enabled (MRBTS/NRBTS/actInterFreqHoSA = true)
     [Tags]             5GC000706    5GC000706-C    INTER    reconfigWSync    706-C_TC02    706    RAN_5G_FDD_CRT
     [Setup]            Perform Preconditions of Test Scenario

    Start Tcpdump on gNB
    Attach MTK UE, Start and Stop Traffic, Detach    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}
    ...    duration=${DURATION}    protocol=${PROTOCOL}    scenario=5GC000706-C02    ue_alias=${UE_ALIAS_1}
    Stop Tcpdump on gNB
    Verify qc test case

    [Teardown]    Combined Test Teardown
#----------------------------------------------------------------------------------------------------------------------#
5GC000706-C-03_Intra-frequency_Ping_Pong_Inter-gNB_FDD_HO_based_A3_or_A5_measurements_Different_Bandwidth_on_Source_and_Target_Cell
     [Documentation]    To verify A3/A5-event triggered Inter-gNB Intra-Freq SA HO between source and target FDD cells
     ...                configured with different bandwidth.
     [Tags]             5GC000706    5GC000706-C    INTER    reconfigWSync    706-C_TC03    706    RAN_5G_FDD_CRT    RAN_5G_FDD_CIT
     [Setup]            Perform Preconditions of Test Scenario

    Start Tcpdump on gNB
    Attach MTK UE, Start and Stop Traffic, Detach    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}
    ...    duration=${DURATION}    protocol=${PROTOCOL}    scenario=5GC000706-C03    ue_alias=${UE_ALIAS_1}
    Stop Tcpdump on gNB
    Verify qc test case

    [Teardown]    Combined Test Teardown

#----------------------------------------------------------------------------------------------------------------------#

*** Keywords ***
Set gNB cell attenuation
    [Arguments]    ${scenario}=SEN1
    [Documentation]    starts predifined attenuation scenario
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${template}=  Get File  ${CURDIR}/attenuator_scenario_2481_706-C.txt
    ${message}=  Replace Variables  ${template}
    Create File  ${resultSuiteBaseDir}/attenuator_scenario_tl.txt  ${message}
    run attenuator scenario  att=attenuator    att_file=${resultSuiteBaseDir}/attenuator_scenario_tl.txt    scenario=${scenario}

Convert PCAP2PDML
    util.Convert PCAP to PDML    source=${resultTestDir}/gnb${gnb_id_target_cell1}_master/Xn_traces_gnb${gnb_id_target_cell1}_master.pcap
    ...     target=${resultTestDir}/Xn_traces_gnb${gnb_id_target_cell1}_master.pdml
    util.Convert PCAP to PDML    source=${resultTestDir}/gnb${gnb_id_target_cell2}_master/Xn_traces_gnb${gnb_id_target_cell2}_master.pcap
    ...     target=${resultTestDir}/Xn_traces_gnb${gnb_id_target_cell2}_master.pdml
    ${XNAP}=  tcpdump.Get xnap protocol version  ${tcp_file_gnb_target_master}
    set suite variable  ${XNAP}  ${XNAP}


Perform Preconditions of Test Scenario
    [Arguments]    ${ue_alias}=${UE_ALIAS_1}
    Create testcase log directory
    Log Variables
    Log to console    \n
    ${resultTestDir}=    testline.Get testcase log directory
    Set suite variable  ${resultTestDir}
    ${gnb_sw_branch}  Get gNB SW Branch
    Set test variable  ${gnb_sw_branch}
    Log to console    SW Branch: ${gnb_sw_branch}
    IF   '706-C_TC02' in ${TEST TAGS}
    ...                 Set gNB ids    gnb_id_target_cell1=${0}  gnb_id_source=${1}  ru_id_source=${2}  ru_id_target_cell1=${2}
    ...                    gnb_id_target_cell2=${0}  ru_id_target_cell2=${0}
    ...    ELSE IF   '706-C_TC03' in ${TEST TAGS}
    ...                 Set gNB ids    gnb_id_target_cell1=${1}  gnb_id_source=${0}  ru_id_source=${0}  ru_id_target_cell1=${2}
    ...                    gnb_id_target_cell2=${0}  ru_id_target_cell2=${0}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${gnb_id_source}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_id=${gnb_id_target_cell1}
    ${configSuiteDir}=    testline.Get test suite config directory
    gnb.Get SCF from gNB    gnb_id=${gnb_id_source}    target_dir=${configSuiteDir}
    gnb.Get SCF from gNB    gnb_id=${gnb_id_target_cell1}    target_dir=${configSuiteDir}
    IF   '706-C_TC02' in ${TEST TAGS}
            Set NRBTS-ID source and target for 5GC000706-C-02
    ELSE IF    '706-C_TC03' in ${TEST TAGS}
            Set NRBTS-ID source and target for 5GC000706-C-03
            Activate actInterFreqHoSA    actInterFreqHoSA=false  gnb_id=${gnb_id_source}
            Activate actInterFreqHoSA    actInterFreqHoSA=false  gnb_id=${gnb_id_target_cell1}
    END
    Get physCellIds
    Log to console    Source physical cellId ${physCellIdSource}
    Log to console    Target physical cellId1 ${physCellIdTargetCell1}
    Log to console    Target physical cellId2 ${physCellIdTargetCell2}
    Mediatek ADB reboot
    sleep  10s
    taf.ue.Require Ue    ${ue_alias}  capabilities=UE_1
    sleep  10s  reason=wait release of resources
    ${attenuator}=    attenuator.setup_attenuator    attenuator=${tl.attenuators[${0}]}    alias=attenuator
    Log to Console   Set attenuation
    set test variable  ${attenuator}
    Set Attenuator to default    ${attenuator}    ${gnb_id_source}    ${ru_id_source}
    IF    ('X2-C_S1-C_IFs' in '${LOGS}')    tcpdump.Start TCPdump on all eNBs
    setup tshark    eth1
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources before test for all nodes

Set NRBTS-ID source and target for 5GC000706-C-02
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id_source}
    Set test variable  ${nrbts_id_${gnb_id_source}}  ${nrbts_id_1}
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  ${gnb_id_target_cell1}
    Set test variable  ${nrbts_id_${gnb_id_target_cell1}}  ${nrbts_id_0}
    Set test variable  ${nrbts_id_${gnb_id_target_cell2}}  ${nrbts_id_0}
    Log to console    Source gNB: ${nrbts_id_${gnb_id_source}} ${nrbts_id_1}
    Log to console    Target gNB cell1: ${nrbts_id_${gnb_id_target_cell1}} ${nrbts_id_0}
    Log to console    Target gNB cell2: ${nrbts_id_${gnb_id_target_cell2}} ${nrbts_id_0}

Set NRBTS-ID source and target for 5GC000706-C-03
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  ${gnb_id_source}
    Set test variable  ${nrbts_id_${gnb_id_source}}  ${nrbts_id_0}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id_target_cell1}
    Set test variable  ${nrbts_id_${gnb_id_target_cell1}}  ${nrbts_id_1}
    Set test variable  ${nrbts_id_${gnb_id_target_cell2}}  ${nrbts_id_0}
    Log to console    Source gNB: ${nrbts_id_${gnb_id_source}} ${nrbts_id_0}
    Log to console    Target gNB cell1: ${nrbts_id_${gnb_id_target_cell1}} ${nrbts_id_1}
    Log to console    Target gNB cell2: ${nrbts_id_${gnb_id_target_cell2}} ${nrbts_id_0}

Verify qc test case
    [Documentation]   Check A3 reports and based on it check selected target cell for HO
    ...               Check RRC reconfiguration is sent to the UE with reconfigurationWithSync including targetPhysCellId - the new PCell for UE
    ...               Check RACH-ConfigDedicated IE in the CellGroupConfig IE is included in the RRC Reconfiguration
    ...               Check UE perform RLC re-establishment, HO is successful and data traffic after HO isn’t suspended and degraded
    ...               (none of the packets are lost)
    Log to console    Starting TC Verification
    Convert PCAP2PDML
    Check wireshark for ssbSubcarrierSpacing  tcp_file=${tcp_file_gnb_source_master}
    Check wireshark for a3_Offset  tcp_file=${tcp_file_gnb_source_master}
    Check wireshark for ssb_RSRP  tcp_file=${tcp_file_gnb_source_master}
    Check wireshark for mcs_Table  tcp_file=${tcp_file_gnb_source_master}
    Check wireshark for cfra_element  tcp_file=${tcp_file_gnb_source_master}
    Check HandoverRequest cause  tcp_file=${tcp_file_gnb_source_master}
    Check HandoverRequest radioNetwork  tcp_file=${tcp_file_gnb_source_master}
    Check HandoverAcknowledge  tcp_file=${tcp_file_gnb_target_master}
    Check HandoverRequest cause  tcp_file=${tcp_file_gnb_target_master}
    Check HandoverRequest radioNetwork  tcp_file=${tcp_file_gnb_target_master}
    Check HandoverAcknowledge  tcp_file=${tcp_file_gnb_source_master}
    Check MeasGapSetup  tcp_file=${tcp_file_gnb_source_master}
    Check MeasGapRelease  tcp_file=${tcp_file_gnb_source_master}
    Check DrxConfig  tcp_file=${tcp_file_gnb_source_master}
    Check SNSStatusTranfer message  tcp_file=${tcp_file_gnb_source_master}
    Check SNSStatusTranfer message  tcp_file=${tcp_file_gnb_target_master}
    Check UEContextRelease message  tcp_file=${tcp_file_gnb_source_master}
    Check UEContextRelease message  tcp_file=${tcp_file_gnb_target_master}
    Check UEContextReleaseCommand message  tcp_file=${tcp_file_gnb_source_master}
    Check UEContextReleaseComplete message  tcp_file=${tcp_file_gnb_source_master}
    Check RRC Complete message  tcp_file=${tcp_file_gnb_source_master}
    Check rrcRelease  tcp_file=${tcp_file_gnb_source_master}

    IF   '706-C_TC02' in ${TEST TAGS}
            Check InitialUEmessage  tcp_file=${tcp_file_gnb_target_master}
            Check InitialContextSetupRequest message  tcp_file=${tcp_file_gnb_target_master}
            Check InitialContextSetupResponse message  tcp_file=${tcp_file_gnb_target_master}
            Check PathSwitchRequest message  tcp_file=${tcp_file_gnb_source_master}
            Check PathSwitchRequestAck message  tcp_file=${tcp_file_gnb_source_master}
            Check reconfigurationWithSync  tcp_file=${tcp_file_gnb_source_master}
            ...   physCell1=${physCellIdTargetCell1}  physCell2=${physCellIdTargetCell2}
            verify f1xn trace C02  xnap=${XNAP}   pdml_file_path=${resultTestDir}/Xn_traces_gnb0_master.pdml
            Verify f1xn trace Pathswitchsequence  pdml_file_path=${resultTestDir}/Xn_traces_gnb0_master.pdml  xnap=${XNAP}
    ELSE IF    '706-C_TC03' in ${TEST TAGS}
            Check InitialUEmessage  tcp_file=${tcp_file_gnb_source_master}
            Check InitialContextSetupRequest message  tcp_file=${tcp_file_gnb_source_master}
            Check InitialContextSetupResponse message  tcp_file=${tcp_file_gnb_source_master}
            Check PathSwitchRequest message  tcp_file=${tcp_file_gnb_target_master}
            Check PathSwitchRequestAck message  tcp_file=${tcp_file_gnb_target_master}
            Check reconfigurationWithSync  tcp_file=${tcp_file_gnb_source_master}
            ...   physCell1=${physCellIdSource}  physCell2=${physCellIdTargetCell1}
            verify f1xn trace C03   pdml_file_path=${resultTestDir}/Xn_traces_gnb0_master.pdml  xnap=${XNAP}
            Verify f1xn trace Pathswitchsequence  pdml_file_path=${resultTestDir}/Xn_traces_gnb1_master.pdml  xnap=${XNAP}
    END

    hanging_resources.no check of resource nbOfFreeCRNTI
    hanging_resources.Verify resource usage for all nodes

Set gNB ids
    [Arguments]    ${gnb_id_target_cell1}  ${gnb_id_target_cell2}  ${gnb_id_source}  ${ru_id_source}  ${ru_id_target_cell1}
    ...    ${ru_id_target_cell2}    ${du_id_source}=${0}  ${du_id_target}=${0}
    [Documentation]     set test variable for target and source ids
    set test variable  ${gnb_id_target_cell1}  ${gnb_id_target_cell1}
    set test variable  ${gnb_id_target_cell2}  ${gnb_id_target_cell2}
    set test variable  ${gnb_id_source}  ${gnb_id_source}
    set test variable  ${du_id_source}  ${du_id_source}
    set test variable  ${du_id_target}  ${du_id_target}
    set test variable  ${ru_id_source}  ${ru_id_source}
    set test variable  ${ru_id_target_cell1}  ${ru_id_target_cell1}
    set test variable  ${ru_id_target_cell2}  ${ru_id_target_cell2}

Get physCellIds
    [Documentation]     get the physCellId for the testscenario
    ${ru_id_target_cell1}=    Evaluate  ${ru_id_target_cell1}+${1}
    ${physCellIdTargetCell1}  scf_info.Get physCellId  gnb_id=${gnb_id_target_cell1}  nrcell_id=${ru_id_target_cell1}
    set test variable  ${physCellIdTargetCell1}
    ${ru_id_target_cell2}=    Evaluate  ${ru_id_target_cell2}+${1}
    ${physCellIdTargetCell2}  scf_info.Get physCellId  gnb_id=${gnb_id_target_cell2}  nrcell_id=${ru_id_target_cell2}
    set test variable  ${physCellIdTargetCell2}
    ${ru_id_source}=    Evaluate  ${ru_id_source}+${1}
    ${physCellIdSource}  scf_info.Get physCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_source}
    set test variable  ${physCellIdSource}
