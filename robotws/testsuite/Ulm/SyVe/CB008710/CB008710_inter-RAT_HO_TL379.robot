*** Settings ***
Documentation   This is a Robot Test Suite for feature '5GC000707 Inter RAT Hondover' testing
...             Precondition of this test scenarios:: pm counter interval=5min, tNgRelocOverall=5000, tNgRelocPrep=5000
...             Team: 'MN ECE ULM R&D L3NRT 07 SqdGp62'
...             Email: 'I_ECE_RD_ULM_SQD_62_GMS@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    OperatingSystem
Library    XML

Library    taf.hw.rf_attenuator             WITH NAME   attenuator
Library    taf.transport.ssh                WITH NAME   ssh
Library    taf.ue

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/pmcounters.robot

Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/scf_info.robot


Suite Setup     Prepare TL for Testing
Suite Teardown  Save all Logs and Teardown TL


*** Variables ***
${DL_THROUGHPUT}                 10 Mbits/sec
${UL_THROUGHPUT}                 5 Mbits/sec
${TPUT_DEVIATION}                10%
${WITH_PMCOUNTER_CHECK}          true
${GNB_ID}                        0
${ENB_ID}                        0
${DU_ID}                         0
${RU_ID}                         0
${INITIAL_SCF_FILE_ACTIVATION}   true
${UE_ALIAS_1}                    UE_1
${DURATION}                      120s
${PROTOCOL}                      udp

*** Test Cases ***
CB008710_inter-RAT_HO
    [Documentation]    this TC covers the inter Rat HO
    ...                from 5G cell to 4G cell
    [Tags]             interrat_ho  CB008710_inter-RAT_HO_TL379
    [Setup]            Perform Preconditions of Test Scenario

    Setup UE for interrat HO test and get resources before test
    Start neccessary traces and wait for PM counter interval
    Attach UE and Start UL and DL traffic on UE
    Set gNB cell attenuation to force inter RAT HO  scenario=SEN1
    Stop UL and DL traffic on UE
    Stop all traces
    Verify qc test case
    Detach UE and check resources after test

    [Teardown]    Run Keywords
    ...           Perform Postconditions of Test Scenario
    ...  AND      CCRT Test Cases Teardown


*** Keywords ***
Prepare TL for Testing
    testline.Set Console Output
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Testline Setup for CCRT


Perform Preconditions of Test Scenario
    testline.Create testcase log directory
    gnb.Wait Until Node To Be Onair State   node_id=${GNB_ID}
    ${configSuiteDir}=    testline.Get test suite config directory
    gnb.Get SCF from gNB    gnb_id=${GNB_ID}    target_dir=${configSuiteDir}
    Copy File   ${configSuiteDir}/SCFC_gNB${GNB_ID}_DU.xml  ${configSuiteDir}/SCFC_gNB${GNB_ID}_DU_initial.xml
    gnb.Get swconfig from gNB  gnb_id=${GNB_ID}    target_dir=${configSuiteDir}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${GNB_ID}
    set test variable  ${nrbts_id_${GNB_ID}}  ${nrbts_id_1}
    ${attenuator}=    attenuator.setup_attenuator    attenuator=${tl.attenuators[${0}]}    alias=attenuator
    set test variable  ${attenuator}
    FOR   ${attenuation_port.port_no}  IN  @{tl.attenuators[${0}].attenuation_port_numbers}
          attenuator.set_attenuation    port=${attenuation_port.port_no}    value=${110}    attenuator_device=attenuator
    END
    setup tshark    eth1
#not working - needs to be checked
#    testline.PDU power reset  pdu=${tl.pdus[0]}   pdu_port=${tl.pdus[0].pdu_ports[10]}   time_interval=10
#    sleep  100s  reason=wait for UE reset


Setup UE for interrat HO test and get resources before test
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=APN_irat
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources before test for all nodes


Start neccessary traces and wait for PM counter interval
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=${GNB_ID}
    ...  collector=tcpdump_gnb_${GNB_ID}
    ...  options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422
    tcpdump.Start TCPdump on eNB
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 sctp  collector=tcpdump_testpc_HO_gnb1_enb1
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${GNB_ID}


workaround
    Set gNB cell attenuation to force inter RAT HO  scenario=SEN1
    FOR   ${attenuation_port.port_no}  IN  @{tl.attenuators[${0}].attenuation_port_numbers}
          attenuator.set_attenuation    port=${attenuation_port.port_no}    value=${110}    attenuator_device=attenuator
    END
    attenuator.set_attenuation    port=${tl.gnbs[${GNB_ID}].dus[${DU_ID}].rus[${RU_ID}].attenuation_ports[0]}
    ...  value=${10}    attenuator_device=attenuator
    attenuator.set_attenuation    port=${tl.gnbs[${GNB_ID}].dus[${DU_ID}].rus[${RU_ID}].attenuation_ports[1]}
    ...  value=${10}    attenuator_device=attenuator


Attach UE and Start UL and DL traffic on UE
    attenuator.set_attenuation    port=${tl.gnbs[${GNB_ID}].dus[${DU_ID}].rus[${RU_ID}].attenuation_ports[0]}
    ...  value=${10}    attenuator_device=attenuator
    attenuator.set_attenuation    port=${tl.gnbs[${GNB_ID}].dus[${DU_ID}].rus[${RU_ID}].attenuation_ports[1]}
    ...  value=${10}    attenuator_device=attenuator
    sleep  15s  reason=wait for attach
    workaround
    taf.ue.Attach Ue   ${UE_ALIAS_1}
    sleep  20s  reason=wait for attach
    taf.ue.Start Data Transfer  dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=dl  duration=${DURATION}
    ...    throughput=${DL_THROUGHPUT}    protocol=${PROTOCOL}  packet=1320  buffer=16M
#    taf.ue.Start Data Transfer  dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=ul  duration=${DURATION}
#    ...    throughput=${UL_THROUGHPUT}    protocol=${PROTOCOL}  packet=1320  buffer=16M
    sleep  20s  reason=wait for traffic


Stop UL and DL traffic on UE
    sleep  20s  reason=wait for traffic
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  DL_${UE_ALIAS_1}
#    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  UL_${UE_ALIAS_1}


Stop all traces
    ${tcp_file_gnb}  tcpdump.Stop TCP Dump on gNB Common Unit
    ...  collector=tcpdump_gnb_${GNB_ID}  tcpdump_filename=Xn_traces_gnb_5G_4G.pcap
    set test variable  ${tcp_file_gnb${GNB_ID}}  ${tcp_file_gnb}
    tcpdump.Stop TCPdump on eNB
    ${tcp_file}  tcpdump.Stop Tcpdump on TestPc  collector=tcpdump_testpc_HO_gnb1_enb1
    set test variable  ${tcp_file}  ${tcp_file}


Set gNB cell attenuation to force inter RAT HO
    [Arguments]    ${scenario}=SEN1
    [Documentation]    starts predifined attenuation scnearion
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${template}=  OperatingSystem.Get File  ${CURDIR}/attenuator_scenario_interrat_ho.txt
    ${message}=  Replace Variables  ${template}
    OperatingSystem.Create File  ${resultSuiteBaseDir}/attenuator_scenario_tl.txt  ${message}
    run attenuator scenario  att=attenuator    att_file=${resultSuiteBaseDir}/attenuator_scenario_tl.txt    scenario=${scenario}


Detach UE and check resources after test
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes
    hanging_resources.no check of resource nbOfFreeCRNTI
    hanging_resources.Verify resource usage for all nodes


Check Performance counter
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${GNB_ID}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${GNB_ID}    collector_alias=pm_counters_gnb0
    ${cell_id}=    Evaluate  ${RU_ID}+${1}
    ${cell_id}  convert to string  ${cell_id}

   ${pm_counter_reference_table}=   Create List
    ...   M55125C02001  >  0  Number of inter-Rat HO preparation attempted
    ...   M55125C02002  >  0  Number of successful inter-Rat HO preparation
    ...   M55125C02003  ==  0  Number of inter-Rat HO preparation failures due to radio resources not available
    ...   M55125C02004  ==  0  Number of inter-Rat HO preparation failure
    ...   M55125C02005  ==  0  Number of inter-Rat HO cancellation
    ...   M55125C02006  >  0  Number of successful inter RAT handover executions
    ...   M55125C02007  ==  0  Number of gNB initiated UE context release due to failed inter-RAT HO TNGRELOCoverall timer expiry
    ...   M55125C02008  ==  0  Number of inter-Rat HO preparation failure due to TNGRELOCprep guard timer expiry
    ...   M55125C02009  ==  0  Number of successful inter-Rat HO cancellation

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${cell_id}


Verify qc test case
    [Documentation]   check wireshark messages: check HO messages and correct content
    ...               check traffic: check throughput with deviation
    ...               check hanging resources
    ...               check PM counter
    # check PM counter
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  Check Performance counter
    # check wireshark messages
    Run Keyword And Continue On Failure    Check HandoverRequired  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure    Check HandoverCommand  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure    Check HandoverNotify  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure    Check UEContextReleaseCommand message  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure    Check UEContextReleaseCommand message content  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure    Check UEContextReleaseComplete message  tcp_file=${tcp_file}
    # check traffic
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=DL_${UE_ALIAS_1}  tput=${DL_THROUGHPUT}  deviation=${TPUT_DEVIATION}  omit=${3}  end=${100}
#    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
#    ...  dt_name=UL_${UE_ALIAS_1}  tput=${UL_THROUGHPUT}  deviation=${TPUT_DEVIATION}  omit=${3}  end=${100}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  DL_${UE_ALIAS_1}
#    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  UL_${UE_ALIAS_1}
    # check hanging resources


Check HandoverRequired
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${handovertype}  XML.Get Elements    ${output}    .//field[@name='ngap.HandoverRequired_element']//field[@name='ngap.HandoverType']
    FOR  ${i}  IN   @{handovertype}
       ${rn}  XML.Get Element attribute  ${i}  showname
       IF  '${rn}' == 'HandoverType: fivegs-to-eps (1)'   BREAK
    END
    Should Contain  ${rn}  fivegs-to-eps


Check HandoverCommand
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${HandoverType}  XML.Get Elements    ${output}    .//field[@name='ngap.HandoverCommand_element']//field[@name='ngap.HandoverType']
    FOR  ${i}  IN   @{HandoverType}
       ${rn}  XML.Get Element attribute  ${i}  showname
       IF  '${rn}' == 'HandoverType: fivegs-to-eps (1)'   BREAK
    END
    Should Contain  ${rn}  fivegs-to-eps


Check HandoverNotify
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=s1ap.procedureCode == 2    output_type=pdml    pcap_file_path=${tcp_file}
    ${HandoverNotify}    XML.Get Element count    ${output}    .//field[@name='s1ap.HandoverNotify_element']
    should be true  ${HandoverNotify} > ${0}


Check UEContextReleaseCommand message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 41    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseCommand}    XML.Get Element count    ${output}    .//field[@name='ngap.UEContextReleaseCommand_element']
    should be true  ${UEContextReleaseCommand} > ${0}


Check UEContextReleaseCommand message content
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 41    output_type=pdml    pcap_file_path=${tcp_file}
    ${radioNetwork}    XML.Get Elements    ${output}   .//field[@name='ngap.UEContextReleaseCommand_element']//field[@name='ngap.radioNetwork']
    FOR  ${i}  IN   @{radioNetwork}
        ${showname}  XML.Get Element attribute  ${i}  showname
        log to console  ${showname}
        IF  '${showname}' == 'successful-handover'   BREAK
    END
    Should Contain    ${showname}  successful-handover


Check UEContextReleaseComplete message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 41    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseComplete}    XML.Get Element count
    ...  ${output}    .//field[@showname='successfulOutcome']//field[@name='ngap.UEContextReleaseComplete_element']
    should be true  ${UEContextReleaseComplete} > ${0}


Perform Postconditions of Test Scenario
    teardown tshark
    syve_testline.Save current loads
    ${tc_log_directory}=  Get testcase log directory
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect to UE PC   ${ue_id}=${1}
    Run Keyword And Ignore Error  ssh.execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}


Save all Logs and Teardown TL
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  syve_testline.Testline Teardown for CCRT
    ${suiteBaseDirectory}=  testline.Get test suite result base directory
    Run Keyword And ignore Error    bts_log_analysis.filter logs for all gNBs  btslogpath=${suiteBaseDirectory}
    bts_log_analysis.print filtered btslog in log file
