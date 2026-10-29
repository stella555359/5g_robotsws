*** Settings ***
Documentation   This is a Robot Test Suite for feature '5GC000704_Intra-frequency-HO-procedure-via-Xn_FDD' testing V1.0.
...             Precondition of this test scenarios: NRREL object are correct configured
...             At the moment it is prossible to change the target and source cell with the keyword: Set gNB ids
...             13.09.23: The feature 5GC000704 will be tested in Ulm only on ABIP - related feature for ABIP introduction CB008325
...             Team: 'MN ECE ULM R&D L3NRT 07 SqdGp62'
...             Email: 'I_ECE_RD_ULM_SQD_62_GMS@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    XML
Library    OperatingSystem
Library    Collections
Library    String

Library    taf.ue
Library    taf.hw.rf_attenuator               WITH NAME    attenuator

Library    ute_tshark

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/pmcounters.robot

Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/hw_info.robot
Resource    ../resources/scf_info.robot


Suite Setup      Prepare TL for Testing
Suite Teardown   Save all Logs and Teardown TL
Test Teardown    Combined Test Teardown


*** Variables ***
${DL_throughput}                 5 Mbits/sec
${UL_throughput}                 2 Mbits/sec
${Tput_deviation}                8%
${initial_scf_file_activation}   true
${xnap}                          xnap
${WITH_PMCOUNTER_CHECK}          true
${UE_ALIAS_1}                    UE_1


*** Test Cases ***
5GC000704_A_TC02_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_based_on_A3_measurements_CBRA
    [Documentation]    UE for which A3 measurements have been configured sends a A3 measurement report and gNB performs handover
    ...                based on the measurement report to a cell in the same gNB-DU. The UE performs contention-based random access.
    [Tags]             5GC000704  5GC000704-A  CBRA  CBRA-704-A  704  704-A_TC02  CB008325  CB008325_704  CB008325_704-A_TC02
    [Setup]            Perform Preconditions of Test Scenario

    hanging_resources.Get resources before test for all nodes
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=REAL_MTK_UE
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${source_node_id}
    taf.ue.Detach Ue   UE_1
    Start Tcpdump on gNB
    taf.ue.Attach Ue   UE_1
    Start UL and DL Traffic  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    sleep  5s
    Set gNB cell attenuation  scenario=SEN1
    Stop DL and UL Traffic and check throughput  Tput_deviation=${Tput_deviation}  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    Stop Tcpdump on gNB
    taf.ue.Detach Ue   UE_1
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes
    Verify qc test case


5GC000704_A_TC03_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_based_on_A3_measurements_CFRA
    [Documentation]    UE for which A3 measurements have been configured sends a A3 measurement report and gNB performs handover
    ...                based on the measurement report to a cell in the same gNB-DU. The UE performs contention-free random access.
    [Tags]             5GC000704  5GC000704-A  CFRA  CFRA-704-A  704  704-A_TC03  CB008325  CB008325_704  CB008325_704-A_TC03
    [Setup]            Perform Preconditions of Test Scenario

    hanging_resources.Get resources before test for all nodes
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=REAL_MTK_UE
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${source_node_id}
    taf.ue.Detach Ue   UE_1
    Start Tcpdump on gNB
    taf.ue.Attach Ue   UE_1
    Start UL and DL Traffic  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    sleep  5s
    Set gNB cell attenuation  scenario=SEN1
    Stop DL and UL Traffic and check throughput  Tput_deviation=${Tput_deviation}  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    Stop Tcpdump on gNB
    taf.ue.Detach Ue   UE_1
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes
    Verify qc test case


5GC000704_B_TC05_Successful_Intra_frequency_Inter_gNB_handover_based_on_A3_A5_measurements_CBRA
    [Documentation]    UE for which A3 and A5 measurements have been configured sends a A3 or a A5 measurement report and gNB performs handover
    ...                based on the measurement report to a cell in a neighbour gNB. The UE performs contention-based random access.
    [Tags]             5GC000704  5GC000704-B  CBRA  CBRA-704-B  704  704-B_TC05  CB008325  CB008325_704  CB008325_704-B_TC05
    [Setup]            Perform Preconditions of Test Scenario

    hanging_resources.Get resources before test for all nodes
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=REAL_MTK_UE
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${source_node_id}
    taf.ue.Detach Ue   UE_1
    Start Tcpdump on gNB
    taf.ue.Attach Ue   UE_1
    Start UL and DL Traffic  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    sleep  5s
    Set gNB cell attenuation  scenario=SEN2
    Stop DL and UL Traffic and check throughput  Tput_deviation=${Tput_deviation}  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    Stop Tcpdump on gNB
    taf.ue.Detach Ue   UE_1
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes
    Verify qc test case


5GC000704_B_TC07_Successful_Intra_frequency_Inter_gNB_handover_based_on_A3_A5_measurements_Multiple_QOS_CFRA
    [Documentation]    UE for which A3 and A5 measurements have been configured sends a A3 or a A5 measurement report and gNB performs handover
    ...                based on the measurement report to a cell in a neighbour gNB. The UE performs contention-free access.
    [Tags]             5GC000704  5GC000704-B  CFRA  CBRA-704-B  704  704-B_TC07  CB008325  CB008325_704  CB008325_704-B_TC07
    [Setup]            Perform Preconditions of Test Scenario

    hanging_resources.Get resources before test for all nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${source_node_id}
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=REAL_MTK_UE
    taf.ue.Detach Ue   UE_1
    Start Tcpdump on gNB
    taf.ue.Attach Ue   UE_1
    Start UL and DL Traffic  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    sleep  5s
    Set gNB cell attenuation  scenario=SEN2
    Stop DL and UL Traffic and check throughput  Tput_deviation=${Tput_deviation}  DL_throughput=${DL_throughput}  UL_throughput=${UL_throughput}
    Stop Tcpdump on gNB
    taf.ue.Detach Ue   UE_1
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes
    Verify qc test case


*** Keywords ***
Prepare TL for Testing
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Testline Setup for CCRT
    ${configSuiteDir}=    testline.Get test suite config directory
    gnb.Get SCF from gNB    gnb_id=${0}    target_dir=${configSuiteDir}
    gnb.Get SCF from gNB    gnb_id=${1}    target_dir=${configSuiteDir}
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  gnb_id=${0}
    set suite variable  ${nrbts_id_0}   ${nrbts_id_0}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  gnb_id=${1}
    set suite variable  ${nrbts_id_1}   ${nrbts_id_1}
    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=0
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=1
    Commissioning gNB  gnb_id=${0}  amf=${2}  nea0=${1}  nea1_128=${0}  nea2_128=${0}  nea3_128=${0}  actIntraFreqHoSA=true
    Commissioning gNB  gnb_id=${1}  amf=${2}  nea0=${1}  nea1_128=${0}  nea2_128=${0}  nea3_128=${0}  actIntraFreqHoSA=true


Commissioning gNB
    [Documentation]    Commissioning of gnb for 5GC000704
    [Arguments]    ${gnb_id}=${0}  ${amf}=${2}  ${nea0}=${1}  ${nea1_128}=${0}  ${nea2_128}=${0}  ${nea3_128}=${0}  ${actIntraFreqHoSA}=true

    ${configSuiteDir}=    testline.Get test suite config directory
    scf_info.Set MNL version string for branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ${gnb_sw_branch}  testline.Get gNB SW Branch
    Log to console  gNB ${gnb_id} SW branch: ${gnb_sw_branch}
    Log to Console  Start commissioning for gnb ${gnb_id}
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}\$:actIntraFreqHoSA=${actIntraFreqHoSA}
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/SERVEDAMF-${amf}\$:administrativeState=Locked
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRPMRNL-1\$:miNrRelReportCu=5min
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}\$:cipherPrefL:nea0=${nea0}
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}\$:cipherPrefL:nea1_128=${nea1_128}
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}\$:cipherPrefL:nea2_128=${nea2_128}
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}\$:cipherPrefL:nea3_128=${nea3_128}

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  OperatingSystem.Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_DU_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}
    admin.teardown   connection=${oam_alias}

Set gNB cell attenuation
    [Arguments]    ${scenario}=SEN1
    [Documentation]    starts predifined attenuation scenario
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${template}=  Get File  ${CURDIR}/attenuator_scenario_704.txt
    ${message}=  Replace Variables  ${template}
    OperatingSystem.Create File  ${resultSuiteBaseDir}/attenuator_scenario_tl.txt  ${message}
    run attenuator scenario by cell  att_file=${resultSuiteBaseDir}/attenuator_scenario_tl.txt    scenario=${scenario}

Perform Preconditions of Test Scenario
    testline.Create testcase log directory
    IF  '5GC000704-A' in ${TEST TAGS}
    ...                Set gNB ids  target_node_id=${1}  source_node_id=${1}  source_cell=1  target_cell=3
    ...   ELSE IF   '5GC000704-B' in ${TEST TAGS}
    ...                Set gNB ids  target_node_id=${0}  source_node_id=${1}  source_cell=1  target_cell=1
    gnb.Wait Until Node To Be Onair State   node_id=${source_node_id}
    IF  '5GC000704-B' in ${TEST TAGS}
    ...   gnb.Wait Until Node To Be Onair State   node_id=${target_node_id}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${source_node_id}
    set test variable  ${nrbts_id_${source_node_id}}  ${nrbts_id_1}
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  ${target_node_id}
    set test variable  ${nrbts_id_${target_node_id}}  ${nrbts_id_0}
    ${configSuiteDir}=    testline.Get test suite config directory
    gnb.Get SCF from gNB    gnb_id=${source_node_id}    target_dir=${configSuiteDir}
    gnb.Get swconfig from gNB  gnb_id=${source_node_id}    target_dir=${configSuiteDir}
    IF  'CBRA-704-B' in ${TEST TAGS}
             gnb.Get SCF from gNB    gnb_id=${target_node_id}    target_dir=${configSuiteDir}
             gnb.Get swconfig from gNB  gnb_id=${target_node_id}    target_dir=${configSuiteDir}
    END
    ${physCellIdTarget}=  scf_info.Get physCellId  gnb_id=${target_node_id}  nrcell_id=${target_cell}
    Set Test Variable     ${physCellIdTarget}
    ${physCellIdSource}=  scf_info.Get physCellId  gnb_id=${source_node_id}  nrcell_id=${source_cell}
    Set Test Variable     ${physCellIdSource}
    Get globalCellID from target and source Cell
    Commissioning gNB for HO  gnb_id=${source_node_id}  cbraPreamblesPerSsb=n64  nrcell_id=${source_cell}
    IF  'CBRA' in ${TEST TAGS}
    ...  Commissioning gNB for HO  gnb_id=${target_node_id}  cbraPreamblesPerSsb=n64  nrcell_id=${target_cell}
    IF  'CFRA' in ${TEST TAGS}
    ...  Commissioning gNB for HO  gnb_id=${target_node_id}  cbraPreamblesPerSsb=n4   nrcell_id=${target_cell}

    setup tshark    eth1
    Set Attenuator to Max Value
    attenuator_scenario.Set cell attenuation  globalcellid=${source_cell}  value=${20}  node_id=${source_node_id}  node_type=${source_node_type}

Set gNB ids
    [Arguments]    ${target_node_id}  ${source_node_id}  ${source_cell}  ${target_cell}
    [Documentation]     set test vairable for target and source ids
    set test variable  ${target_node_id}    ${target_node_id}
    set test variable  ${source_node_id}    ${source_node_id}
    set test variable  ${target_node_type}  gnb
    set test variable  ${source_node_type}  gnb
    set test variable  ${source_cell}       ${source_cell}
    set test variable  ${target_cell}       ${target_cell}

Commissioning gNB for HO
    [Documentation]    Commissioning of gnb for TC07 CB8309
    [Arguments]        ${gnb_id}=${source_node_id}  ${cbraPreamblesPerSsb}=n64  ${nrcell_id}=${1}
    ${configSuiteDir}=    testline.Get test suite config directory
    scf_info.Set MNL version string for branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ${gnb_sw_branch}  testline.Get gNB SW Branch
    Log to console  gNB ${gnb_id} SW branch: ${gnb_sw_branch}
    Log to Console  Start commissioning for gnb for HO ${gnb_id}
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml


    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a3MeasEnabled=rsrp
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:cbraPreamblesPerSsb=${cbraPreamblesPerSsb}
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:actDl256Qam=true
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:sMeasConfigSsbRsrp=10
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70

    IF    '5GC000704-B' in ${TEST TAGS}
    ...  Append To List  ${GNB_PARAMS_IN_SCF}
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a5MeasEnabled=rsrp
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a5MeasSsbRsrp:a5Threshold1SsbRsrp=71
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a5MeasSsbRsrp:a5Threshold2SsbRsrp=66
    ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}\$:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms320

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_${nrcell_id}_HO_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${nrcell_id}_HO_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${nrcell_id}_HO_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  OperatingSystem.Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${nrcell_id}_HO_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${nrcell_id}_HO_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}
    admin.teardown   connection=${oam_alias}


Get globalCellID from target and source Cell
    [Documentation]     get the globalcellid for the testscenario
    ${globalCellIDTarget}=    Evaluate  ${nrbts_id_${target_node_id}}*${16384}+${target_cell}
    set test variable  ${globalCellIDTarget}
    ${globalCellIDSource}=    Evaluate  ${nrbts_id_${source_node_id}}*${16384}+${source_cell}
    set test variable  ${globalCellIDSource}


Start Tcpdump On gNB
    [Documentation]     starts tcpdump on source and target gNB
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=${source_node_id}  collector=gnb_source_master
    ...                options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=${target_node_id}  collector=gnb_target_master
    ...                options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422


Stop Tcpdump On gNB
    [Documentation]     stops tcpdump on source and target gNB
    ${tcp_file_gnb_source}   tcpdump.Stop TCP Dump on gNB Common Unit  collector=gnb_source_master
    ...        tcpdump_filename=Xn_traces_gnb_source.pcap
    ${tcp_file_gnb_target}   tcpdump.Stop TCP Dump on gNB Common Unit  collector=gnb_target_master
    ...        tcpdump_filename=Xn_traces_gnb_target.pcap
    Set Test Variable  ${tcp_file_gnb${source_node_id}}  ${tcp_file_gnb_source}
    Set Test Variable  ${tcp_file_gnb${target_node_id}}  ${tcp_file_gnb_target}


Start UL and DL Traffic
    [Arguments]    ${DL_throughput}  ${UL_throughput}
    [Documentation]     start DL/UL Traffic on default PDU and second PDU
    taf.ue.Start Data Transfer    DT_11    UE_1    DL    duration=1800s    throughput=${DL_throughput}    protocol=udp  packet_size=1000
    ...  port=${tl.appserver.iperf_details.ports[0]}
    taf.ue.Start Data Transfer    DT_12    UE_1    UL    duration=1800s    throughput=${UL_throughput}    protocol=udp  packet_size=1000
    ...  port=${tl.appserver.iperf_details.ports[1]}
#    taf.ue.connect_additional_pdn  ue_alias=UE_1  pdn=${tl.core.pdns[0].apn}
#    Run Keyword And Continue On Failure  taf.ue.Create Bearer Alias    alias=PDU2C    qci=1    pdn=${tl.core.pdns[0].apn}
#    taf.ue.Start Data Transfer    DT_21    UE_1    DL    bearer_alias=PDU2C    packet_size=1000
#    ...    duration=1800s    throughput=${DL_throughput}    protocol=udp  port=${tl.appserver.iperf_details.ports[2]}
#    taf.ue.Start Data Transfer    DT_22    UE_1    UL    bearer_alias=PDU2C    packet_size=1000
#    ...    duration=1800s    throughput=${UL_throughput}    protocol=udp  port=${tl.appserver.iperf_details.ports[3]}

Stop DL and UL Traffic and check throughput
    [Arguments]    ${Tput_deviation}  ${DL_throughput}  ${UL_throughput}
    [Documentation]     Stop DL/UL Traffic and check throughput with given deviation
    taf.ue.Stop Data Transfer    DT_11
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation  DT_11
    ...        tput=${DL_throughput}  deviation=${Tput_deviation}
    taf.ue.Stop Data Transfer    DT_12
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation  DT_12
    ...  tput=${UL_throughput}  deviation=${Tput_deviation}
#    taf.ue.Stop Data Transfer    DT_21
#    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation  DT_21
#    ...        tput=${DL_throughput}  deviation=${Tput_deviation}
#    taf.ue.Stop Data Transfer    DT_22
#    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation  DT_22
#    ...  tput=${UL_throughput}  deviation=${Tput_deviation}


Verify qc test case
    [Documentation]   Check A3 reports and based on it check selected target cell for HO
    ...               Check RRC reconfiguration is sent to the UE with reconfigurationWithSync including targetPhysCellId - the new PCell for UE
    ...               Check RACH-ConfigDedicated IE in the CellGroupConfig IE is included in the RRC Reconfiguration
    ...               Check UE perform RLC re-establishment, HO is successful and data traffic after HO isnt suspended and
    ...               degraded (none of the packets are lost)
    testline.Get testcase log directory
    ${xnap}=  IF  '5GC000704-B' in ${TEST TAGS}  tcpdump.Get xnap protocol version  ${tcp_file_gnb${source_node_id}}
#   PM counter is not working - preinvest startet --> therefore ignore error
#    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Ignore Error
#    ...  Check Performance counter  nrcell_id=${nrbts_id_${source_node_id}}
#### Pronto PR720045 open ...therefore the counter will not be checked at the moment
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  Check Performance counter
    IF  '5GC000704-B' in ${TEST TAGS}  set suite variable  ${xnap}   ${xnap}
    Check wireshark for RRCReconfiguration  physCell=${physCellIdTarget}  tcp_file=${tcp_file_gnb${source_node_id}}
    Check wireshark for ssbSubcarrierSpacing  tcp_file=${tcp_file_gnb${source_node_id}}
    Check wireshark for a3_Offset  tcp_file=${tcp_file_gnb${source_node_id}}
    Check wireshark for hysteresis  tcp_file=${tcp_file_gnb${source_node_id}}
    Check wireshark for timeToTrigger  tcp_file=${tcp_file_gnb${source_node_id}}
    Check wireshark for ssb_RSRP  tcp_file=${tcp_file_gnb${source_node_id}}
    Check wireshark for mcs_Table  tcp_file=${tcp_file_gnb${source_node_id}}
    IF  '5GC000704-A' in ${TEST TAGS}  Check RRC Complete message  tcp_file=${tcp_file_gnb${source_node_id}}
    IF  'CFRA' in ${TEST TAGS}  Check wireshark for cfra_element  tcp_file=${tcp_file_gnb${source_node_id}}
    IF  '5GC000704-B' in ${TEST TAGS}  Run Keywords
    ...                Check HandoverRequest cause  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check HandoverRequest radioNetwork  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check HandoverAcknowledge  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check HandoverRequest cause  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check HandoverRequest radioNetwork  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check HandoverAcknowledge  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check physCellId for intergNBHO gNB1  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check wireshark for ssbSubcarrierSpacing  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check wireshark for a3_Offset  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check wireshark for hysteresis  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check wireshark for timeToTrigger  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check wireshark for ssb_RSRP  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check SNSStatusTranfer message  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check SNSStatusTranfer message  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check UEContextRelease message  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check UEContextRelease message  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check UEContextReleaseCommand message  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check UEContextReleaseComplete message  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check PathSwitchRequest message  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check PathSwitchRequestAck message  tcp_file=${tcp_file_gnb${target_node_id}}
    ...   AND          Check wireshark for A5 hysteresis  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check wireshark for A5 timeToTrigger  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check wireshark for a5_Threshold1  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check wireshark for a5_Threshold2  tcp_file=${tcp_file_gnb${source_node_id}}
    ...   AND          Check wireshark for a5_Threshold1 rsrp  tcp_file=${tcp_file_gnb${source_node_id}}
    #for later use already included
    #Check wireshark for ssbFrequency  tcp_file=${tcp_file_gnb1_slave}
    #IF  '5GC000704-B' in ${TEST TAGS}
    #        Check physCellId for intergNBHO gNB0  tcp_file=${tcp_file_gnb0}
    #        Check wireshark for ssbFrequency  tcp_file=${tcp_file_gnb0}
    #END
    hanging_resources.no check of resource nbOfFreeCRNTI
    hanging_resources.Verify resource usage for all nodes

Check Performance counter
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${source_node_id}
    ${PM_dir_gnb_s}=  pmcounters.Collect PM Counter    gnb_id=${source_node_id}    collector_alias=pm_counters_gnb_s
    ${PM_dir_gnb_t}=  IF  '5GC000704-B' in ${TEST TAGS}  pmcounters.Collect PM Counter
    ...                                                              gnb_id=${target_node_id}  collector_alias=pm_counters_gnb_t

   ${pm_counter_reference_table}=   Create List
    ...   M55153C00004  ==  0  Number of inter-Rat HO preparation failures due to radio resources not available

    pmcounters.Verify PM Counter Reference Table
    ...                   reference_table=${pm_counter_reference_table}
    ...                   pm_dir=${PM_dir_gnb_s}
    ...                   distname_suffix=NRCELL-${source_cell}/PLMN-PLMN/NRCI-${globalCellIDTarget}/PLMN-PLMN/MCC-540/MNC-01


Check wireshark for RRCReconfiguration
    [Arguments]    ${physCell}  ${tcp_file}
    ${output}  ute_tshark.Read PCAP
    ...        packet_filter=(nokiaf1ap.procedureCode==12&& nokiaf1ap.id == 50)||(nokiaf1ap.procedureCode==7&& nokiaf1ap.id == 50)
    ...        output_type=pdml  pcap_file_path=${tcp_file}
    ${physCellId}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    Should Not Be Empty  ${physCellId}
    FOR  ${i}  IN   @{physCellId}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain  ${showname}  ${physCell}
    END


Check wireshark for ssbFrequency
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${ssbFrequency}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.measObjectNR_element']//field[@name='nr-rrc.ssbFrequency']
    FOR  ${i}  IN   @{ssbFrequency}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  176210
    END


Check wireshark for ssbSubcarrierSpacing
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${ssbSubcarrierSpacing}    XML.Get Elements
    ...  ${output}    .//field[@name='nr-rrc.measObjectNR_element']//field[@name='nr-rrc.ssbSubcarrierSpacing']
    FOR  ${i}  IN   @{ssbSubcarrierSpacing}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  kHz15
    END


Check wireshark for a3_Offset
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${a3_Offset}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventTriggered_element']//field[@name='nr-rrc.a3_Offset']
    FOR  ${i}  IN   @{a3_Offset}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  rsrp
    END


Check wireshark for hysteresis
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${hysteresis}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventTriggered_element']//field[@name='nr-rrc.hysteresis']
    FOR  ${i}  IN   @{hysteresis}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  0
    END


Check wireshark for timeToTrigger
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${timeToTrigger}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventA3_element']//field[@name='nr-rrc.timeToTrigger']
    FOR  ${i}  IN   @{timeToTrigger}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  ms320
    END


Check wireshark for ssb_RSRP
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${ssb_RSRP}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.s_MeasureConfig']//field[@name='nr-rrc.ssb_RSRP']
    FOR  ${i}  IN   @{ssb_RSRP}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  0
    END


Check wireshark for mcs_Table
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${mcs_Table}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.mcs_Table']
    FOR  ${i}  IN   @{mcs_Table}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  qam256
    END


Check wireshark for cfra_element
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${cfra_element}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.uplink_element']//field[@name='nr-rrc.cfra_element']
    FOR  ${i}  IN   @{cfra_element}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  cfra
    END


Check RRC Complete message
    [Arguments]    ${tcp_file}
    ${output1}  ute_tshark.Read PCAP  packet_filter=nokiaf1ap.procedureCode == 12||nokiaf1ap.procedureCode == 7  output_type=pdml
    ...         pcap_file_path=${tcp_file}
    ${rrc}    XML.Get Element Count
    ...  ${output1}    .//field[@name='nr-rrc.rrcReconfiguration_element']//field[@showname='rrcReconfiguration']
    ${output2}  ute_tshark.Read PCAP  packet_filter=nokiaf1ap.procedureCode == 13  output_type=pdml  pcap_file_path=${tcp_file}
    ${rrc_complete}    XML.Get Element Count
    ...  ${output2}    .//field[@name='nr-rrc.rrcReconfigurationComplete_element']//field[@showname='rrcReconfigurationComplete']
    Should Be True  ${rrc_complete} == ${rrc}


Check HandoverRequest cause
    [Arguments]    ${tcp_file}
    ${output}  ute_tshark.Read PCAP  packet_filter=${xnap}.procedureCode == 0  output_type=pdml  pcap_file_path=${tcp_file}
    ${cause}  XML.Get Element    ${output}    .//field[@name='${xnap}.HandoverRequest_element']//field[@name='${xnap}.Cause']
    ${showname}  XML.Get Element Attribute  ${cause}  showname
    Should Contain  ${showname}  radioNetwork


Check HandoverRequest radioNetwork
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=${xnap}.procedureCode == 0    output_type=pdml    pcap_file_path=${tcp_file}
    ${radioNetwork}    XML.Get Element    ${output}    .//field[@name='${xnap}.HandoverRequest_element']//field[@name='${xnap}.radioNetwork']
    ${showname}  XML.Get Element Attribute  ${radioNetwork}  showname
    Should Contain  ${showname}  handover-desirable-for-radio-reasons


Check HandoverAcknowledge
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=${xnap}.procedureCode == 0    output_type=pdml    pcap_file_path=${tcp_file}
    ${releasecomplete}    XML.Get Element Count
    ...  ${output}    .//field[@name='${xnap}.successfulOutcome_element']//field[@showname='HandoverRequestAcknowledge']
    Should Be True  ${releasecomplete} > ${0}


Check physCellId for intergNBHO gNB1
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7&& nokiaf1ap.id == 50
    ...          output_type=pdml    pcap_file_path=${tcp_file}
    ${physCellId}    XML.Get Element    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    ${showname}  XML.Get Element Attribute  ${physCellId}  showname
    Should Contain  ${showname}  ${physCellIdTarget}

Check physCellId for intergNBHO gNB0
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7&& nokiaf1ap.id == 50    output_type=pdml
    ...          pcap_file_path=${tcp_file}
    ${physCellId}    XML.Get Element    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    ${showname}  XML.Get Element Attribute  ${physCellId}  showname
    Should Contain  ${showname}  ${physCellIdTarget}


Check SNSStatusTranfer message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=${xnap}.procedureCode == 1    output_type=pdml    pcap_file_path=${tcp_file}
    ${SNStatusTransfer}    XML.Get Element Count    ${output}    .//field[@name='${xnap}.SNStatusTransfer_element']
    Should Be True  ${SNStatusTransfer} > ${0}


Check UEContextRelease message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=${xnap}.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextRelease}    XML.Get Element Count    ${output}    .//field[@name='${xnap}.UEContextRelease_element']
    Should Be True  ${UEContextRelease} > ${0}


Check UEContextReleaseCommand message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseCommand}    XML.Get Element Count    ${output}    .//field[@name='nokiaf1ap.UEContextReleaseCommand_element']
    Should Be True  ${UEContextReleaseCommand} > ${0}


Check UEContextReleaseComplete message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseComplete}    XML.Get Element Count
    ...  ${output}    .//field[@showname='successfulOutcome']//field[@name='nokiaf1ap.UEContextReleaseComplete_element']
    Should Be True  ${UEContextReleaseComplete} > ${0}


Check PathSwitchRequest message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${tcp_file}
    ${PathSwitchRequest}    XML.Get Element Count    ${output}    .//field[@name='ngap.PathSwitchRequest_element']
    Should Be True  ${PathSwitchRequest} > ${0}


Check PathSwitchRequestAck message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${tcp_file}
    ${PathSwitchRequestAck}    XML.Get Element Count
    ...  ${output}    .//field[@showname='successfulOutcome']//field[@name='ngap.PathSwitchRequestAcknowledge_element']
    Should Be True  ${PathSwitchRequestAck} > ${0}


Check wireshark for A5 hysteresis
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${hysteresis}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventA5_element']//field[@name='nr-rrc.hysteresis']
    FOR  ${i}  IN   @{hysteresis}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  0
    END


Check wireshark for A5 timeToTrigger
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${timeToTrigger}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventA5_element']//field[@name='nr-rrc.timeToTrigger']
    FOR  ${i}  IN   @{timeToTrigger}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  ms320
    END


Check wireshark for a5_Threshold1
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${a5_Threshold1}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.a5_Threshold1']//field[@name='nr-rrc.rsrp']
    FOR  ${i}  IN   @{a5_Threshold1}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  71
    END

Check wireshark for a5_Threshold2
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${a5_Threshold2}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.a5_Threshold2']//field[@name='nr-rrc.rsrp']
    FOR  ${i}  IN   @{a5_Threshold2}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        log to console  ${showname}
        Should Contain    ${showname}  66
    END


Check wireshark for a5_Threshold1 rsrp
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${rsrp}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventA5_element']//field[@name='nr-rrc.a5_Threshold1']
    FOR  ${i}  IN   @{rsrp}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        Should Contain  ${showname}  rsrp
    END


Perform Postconditions of Test Scenario
    taf.ue.Detach Ue   UE_1
    teardown tshark
    Set Attenuator to Max Value
    syve_testline.Save current loads
    ${resultTestDir}=    testline.Get testcase log directory
    FOR    ${filename}   IN   iperf*.txt  moler*.log  pyro_server*.log
        Run Keyword And Ignore Error
        ...   OperatingSystem.Move Files   ${OUTPUT_DIR}/${filename}  ${resultTestDir}
    END


Combined Test Teardown
    [Documentation]
    ...    Performs the postconditions of each TC and adds a CCRT.

    Perform Postconditions of Test Scenario
    syve_testline.CCRT Test Cases Teardown


Save all Logs and Teardown TL
    testline.Get test suite log directory
    IF  '${initial_scf_file_activation}' == 'true'  syve_testline.Testline Teardown for CCRT
    ${suiteBaseDirectory}=  testline.Get test suite result base directory
    Run Keyword And ignore Error  bts_log_analysis.filter logs for all gNBs  btslogpath=${suiteBaseDirectory}
