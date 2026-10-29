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
Resource    ../resources/Mediatek.robot



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
${DURATION}                      60s
${PROTOCOL}                      udp
${source_cell_1}                 1
${target_cell_1}                 2

*** Test Cases ***
CB008710_inter-RAT_HO
    [Documentation]    this TC covers the inter Rat HO
    ...                from 5G cell to 4G cell
    [Tags]             interrat_ho  CB008710_inter-RAT_HO
    [Setup]            Perform Preconditions of Test Scenario

    Setup UE for interrat HO test and get resources before test
    Start neccessary traces and wait for PM counter interval
    Attach UE and Start UL and DL traffic on UE
    attenuator_scenario.Set Cell Attenuation  globalcellid=${target_cell_1}  value=${10}  node_id=${GNB_ID}
    sleep  5s  reason=wait for UE reset
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

Find UE_id for capability
   [Documentation]  searches for the mobile with given capability, returns the corresponding index in tl.ues list
   [Arguments]   ${ue_capability}
    FOR   ${index}  ${mobile}  IN ENUMERATE  @{tl.ues}
      IF  '${ue_capability}' in ${mobile.capabilities}
        RETURN  ${index}
      END
    END

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
    attenuator_scenario.Register All Attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${GNB_ID}
    ${ue_id}  Find UE_id for capability  ue_capability=APN_irat
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect to UE PC   ue_id=${ue_id}
    Mediatek.Disable MTK Bands  ${ue_id}
    Commissioning SBTS

Setup UE for interrat HO test and get resources before test
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=APN_irat
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources before test for all nodes

Start neccessary traces and wait for PM counter interval
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=${GNB_ID}
    ...  collector=tcpdump_gnb_${GNB_ID}
    ...  options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 sctp  collector=tcpdump_testpc_HO_gnb1_enb1
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${GNB_ID}

Commissioning SBTS
    [Arguments]        ${gnb_id}=${0}
    [Documentation]    Commissioning of gnb-0 for CB013859_A0, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  01

    Log To Console  Start commissioning for gnb-${gnb_id}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:${nrbts_nidd}\$:actSliceAwareScheduler=true
    ...  modify:MRBTS-403951/LNBTS-453951\$:actMroInterRatUtran=true
    ...  modify:${nrbts_nidd}/NRCELL-1\$:a1MeashoEnabledSA=rsrp
    ...  modify:${nrbts_nidd}/NRCELL-1\$:a2MeashoEnabledSA=rsrp
    ...  modify:${nrbts_nidd}/NRCELL-1\$:a1ThresholdhoSsbRsrpSA=80
    ...  modify:${nrbts_nidd}/NRCELL-1/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8106
    ...  modify:${nrbts_nidd}/SERVEDAMF-1\$:amfIPAddress$=10.27.223.136
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrNGCC=5min

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    Sleep  60s  reason=wait release of resources

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-2  connection=${oam_alias}
    admin.Block Cell  dist_name=MRBTS-403951/LNBTS-453951/LNCEL-1  connection=${oam_alias}
    admin.Block Cell  dist_name=MRBTS-403951/LNBTS-453951/LNCEL-2  connection=${oam_alias}
    admin.Block Cell  dist_name=MRBTS-403951/LNBTS-453951/LNCEL-4  connection=${oam_alias}

Attach UE and Start UL and DL traffic on UE
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_cell_1}  value=${40}  node_id=${GNB_ID}
    sleep  15s  reason=wait for attach
    taf.ue.Attach Ue   ${UE_ALIAS_1}
    sleep  20s  reason=wait for attach
    taf.ue.Start Data Transfer  dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=dl  duration=${DURATION}
    ...    throughput=${DL_THROUGHPUT}    protocol=${PROTOCOL}  packet=1320  buffer=16M
    taf.ue.Start Data Transfer  dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=ul  duration=${DURATION}
    ...    throughput=${UL_THROUGHPUT}    protocol=${PROTOCOL}  packet=1320  buffer=16M
    sleep  20s  reason=wait for traffic

Stop UL and DL traffic on UE
    sleep  20s  reason=wait for traffic
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  DL_${UE_ALIAS_1}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  UL_${UE_ALIAS_1}

Stop all traces
    ${tcp_file_gnb}  tcpdump.Stop TCP Dump on gNB Common Unit
    ...  collector=tcpdump_gnb_${GNB_ID}  tcpdump_filename=Xn_traces_gnb_5G_4G.pcap
    set test variable  ${tcp_file_gnb${GNB_ID}}  ${tcp_file_gnb}
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
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=UL_${UE_ALIAS_1}  tput=${UL_THROUGHPUT}  deviation=${TPUT_DEVIATION}  omit=${3}  end=${100}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  DL_${UE_ALIAS_1}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  UL_${UE_ALIAS_1}
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
    ${ue_id}  Find UE_id for capability  ue_capability=APN_irat
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect to UE PC   ue_id=${ue_id}
    Run Keyword And Ignore Error  ssh.execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}
    Mediatek.Enable MTK Bands  ue_id=${ue_id}

Save all Logs and Teardown TL
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  syve_testline.Testline Teardown for CCRT
    ${suiteBaseDirectory}=  testline.Get test suite result base directory
    Run Keyword And ignore Error    bts_log_analysis.filter logs for all gNBs  btslogpath=${suiteBaseDirectory}
    bts_log_analysis.print filtered btslog in log file
