*** Settings ***
Documentation   This is a Robot Test Suite for feature 'CB007219' testing
...             These user scenario describe the successful setup of inter-band CA, when some of the aggregated cells are configured
...             with an alternative band.
...             Team: 'MN ECE ULM R&D L3NRT 07 SqdGp62'
...             Email: 'I_ECE_RD_ULM_SQD_62_GMS@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library          taf.ue
Resource         ../../resources/Common/pmcounters.robot
Resource         ../resources/syve_testline.robot
Resource         ../resources/hanging_resources.robot
Resource         CB007219_keywords.robot

Suite Setup      CB007219_keywords.Prepare TL for Testing
Suite Teardown   CB007219_keywords.Save all Logs and Teardown TL

Test Setup       CB007219_keywords.Setup test
Test Template    Setup of inter-band CA with alternative bands

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=10 Mbits/sec
...                             UL_THROUGHPUT=5 Mbits/sec
...                             TPUT_DEVIATION=10%
...                             DURATION=60s
...                             PROTOCOL=udp
${WITH_PMCOUNTER_CHECK}         true
${INITIAL_SCF_FILE_ACTIVATION}  true
${UE_ALIAS_1}                   UE_1


*** Test Cases ***
TC25_AA_B14_Interaction_with_A1_measurement_based_PCell_switch
              gnb_id=${0}   p_cell=3  s_cell=10,13  freq_pcell=66  freq_scell=78,78    capabilities=REAL_ANDROID_UE
  [Template]  Setup of inter-band CA with alternative bands
  [TAGS]      CB007219  CB007219_TC25_2.0


*** Keywords ***
Setup of inter-band CA with alternative bands
    [Documentation]    Attach ue to pcell
    ...                Start traffic
    ...                setup scell
    ...                verify tc
    [Arguments]        ${gnb_id}=${0}  ${p_cell}=${1}  ${s_cell}=${2}  ${freq_pcell}=25  ${freq_scell}=66
    ...                ${capabilities}=REAL_MTK

    CB007219_keywords.Perform Preconditions of Test Scenario
    ...  gnb_id=${gnb_id}  p_cell=${p_cell}  s_cell=${s_cell}  freq_pcell=${freq_pcell}  freq_scell=${freq_scell}
    ...  capabilities=${capabilities}
    hanging_resources.Get resources before test for all nodes
    CB007219_keywords.Start neccessary traces
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${gnb_id}
    log to console    ${\n}INFO: UE ${UE_ALIAS_1} of type ${capabilities} is in use
    log to console    ${\n}INFO: Start UE attach to source cell ${p_cell}
    CB007219_keywords.Set gNB cell attenuation to setup cell  globalcellid=${p_cell}   value=${0}   gnbid=${gnb_id}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
  #  sleep  10s  reason=wait for attach
    log to console    ${\n}INFO: UL and DL traffic on UE is started
    CB007219_keywords.Start UL and DL traffic on UE
    sleep  10s  reason=wait for traffic
    log to console    ${\n}INFO: add scells: ${s_cell}
    CB007219_keywords.Set gNB scells attenuation   scells=${s_cell}   value=${0}   gnbid=${gnb_id}
    CB007219_keywords.Await UL and DL traffic
    CB007219_keywords.Stop all traces
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes
    CB007219_keywords.Verify qc test case

    [Teardown]    Run Keywords
    ...           Perform Postconditions of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown
