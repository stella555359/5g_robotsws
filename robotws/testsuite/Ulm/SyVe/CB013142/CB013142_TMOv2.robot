*** Settings ***
Documentation   This is a Robot Test Suite for feature 'CB013142' testing
...             Team: 'MN RAN RD VRF ULM 1'
...             Email: 'ou_mn_ran_rd_vrf_ulm_1_53028392@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue
Resource                        CB013142_keywords_TMOv2.robot
Resource                        ../resources/hanging_resources.robot

Suite Setup                     CB013142_keywords_TMOv2.Prepare TL For Testing
Suite Teardown                  CB013142_keywords_TMOv2.Save All Logs And Teardown TL

Test Setup                      CB013142_keywords_TMOv2.Setup Test
Test Template                   Setup of inter-band CA with alternative bands

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=200 Mbits/sec
...                             UL_THROUGHPUT=50 Mbits/sec
...                             TPUT_DEVIATION=10%
...                             DURATION=30s
...                             PROTOCOL=udp
${WITH_PMCOUNTER_CHECK}         true
${INITIAL_SCF_FILE_ACTIVATION}  true
${UE_ALIAS_1}                   UE_1

${A2THRESPCELLSWITCH_MEASPR_1}  65
${A2THRESPCELLSWITCH_MEASPR_2}  66

*** Test Cases ***

CB013142_F_ST_TC01_B1_SA_A1_and_A4_config_meas_for_SCell_addition_using_selected_meas_Profile_based_on_one_or_more_criteria
    ...             gnb_id=${0}
    ...             p_cell_1=${4}
    ...             s_cell_1=${7}
    ...             s_cell_2=${10}
    ...             capabilities=UE_1
    ...             enb_id=${0}
   [Template]       Attach ue, start traffic and add scells
   [TAGS]           CB0013142_TMOv2  CB013142-F-01_TMOv2  CB013142_F_ST_TC01_B1_TMOv2
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_28496 USCB013142-D#B4
   ...              current implementation:

*** Keywords ***

Attach UE, Start Traffic And Add SCells
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}  ${enb_id}  ${capabilities}=UE1

    CB013142_keywords_TMOv2.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  enb_id=${enb_id}  capabilities=${capabilities}
    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    CB013142_keywords_TMOv2.Start Neccessary Traces
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${32}   node_id=${gnb_id}
    # step1
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    CB013142_keywords_TMOv2.Start UL And DL Traffic On UE
    CB013142_keywords_TMOv2.Stop All Traces  tcpdump_filename=attach_pcell_traces_gnb${gnb_id}.pcap
    CB013142_keywords_TMOv2.Await UL And DL Traffic
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    Sleep  5s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes

    CB013142_keywords_TMOv2.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords_TMOv2.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown
