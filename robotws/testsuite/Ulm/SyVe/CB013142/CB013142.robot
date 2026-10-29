*** Settings ***
Documentation   This is a Robot Test Suite for feature 'CB013142' testing
...             Team: 'MN RAN RD VRF ULM 1'
...             Email: 'ou_mn_ran_rd_vrf_ulm_1_53028392@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue
Resource                        CB013142_keywords.robot
Resource                        ../resources/hanging_resources.robot

Suite Setup                     CB013142_keywords.Prepare TL For Testing
Suite Teardown                  CB013142_keywords.Save All Logs And Teardown TL

Test Setup                      CB013142_keywords.Setup Test
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
CB013142_A_ST_TC01_B2_SA_A2_meas_Reconfig_on_PCell_for_PCell_change_using_meas_profile_based_on_UE_PC_upon_SCell_change
    ...             gnb_id=${0}
    ...             p_cell_1=${12}
    ...             s_cell_1=${1}
    ...             s_cell_2=${13}
    ...             capabilities=UE1
    ...             enb_id=${0}
   [Template]       Measurement profile based A2 measurement config for PCell change for SA
   [TAGS]           CB0013142  CB013142-A-01  CB013142_A_ST_TC01_B2_SA_A2
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_28301 USCB013142-A#B2
   ...              current implementation:
   ...              1. attach to TDD pcell - collect logs
   ...              2. FDD scell addition - collect logs
   ...              3. scell change from FDD scell to TDD scell - collect logs

CB013142_C_ST_TC01_B3_NSA_Target_cell_radio_quality_evaluation_during_A2_based_PSCell_change_using_meas_profile
    ...             gnb_id=${1}
    ...             p_cell_1=${4}
    ...             s_cell_1=${2}
    ...             capabilities=UE1
    ...             enb_id=${1}
    ...             enb_cell=${3}
   [Template]       Measurement profile based A2 measurement config for PCell change for NSA
   [TAGS]           CB0013142  CB013142-C-01  CB013142_C_ST_TC01_B3
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_28331 USCB013142-C#B3
   ...              current implementation:

CB013142_D_ST_TC03_B4_NSA_A1_meas_Config_on_SCell_for_PSCell_change_using_NRCELL_config_when_matching_profile_mapping_not_found
    ...             gnb_id=${1}
    ...             p_cell_1=${2}
    ...             s_cell_1=${4}
    ...             capabilities=UE1
    ...             enb_id=${1}
    ...             enb_cell=${3}
   [Template]       A1 meas Config on SCell for PSCell change using NRCELL config for NSA
   [TAGS]           CB0013142  CB013142-D-03  CB013142_D_ST_TC03_B4
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_28496 USCB013142-D#B4
   ...              current implementation:

CB013142_F_ST_TC01_B1_SA_A1_and_A4_config_meas_for_SCell_addition_using_selected_meas_Profile_based_on_one_or_more_criteria
    ...             gnb_id=${0}
    ...             p_cell_1=${1}
    ...             s_cell_1=${4}
    ...             s_cell_2=${11}
    ...             capabilities=UE1
    ...             enb_id=${0}
   [Template]       Attach ue, start traffic and add scells
   [TAGS]           CB0013142  CB013142-F-01  CB013142_F_ST_TC01_B1
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_28496 USCB013142-D#B4
   ...              current implementation:

CB013142_G_ST_TC01_B2_SA_Reconfig_of_A1 meas_on_PCell_for_SCell_Change_using_meas_Profile_upon_setup_of_VoNR
    ...             gnb_id=${0}
    ...             p_cell_1=${1}
    ...             s_cell_1=${4}
    ...             s_cell_2=${13}
    ...             capabilities=UE2
    ...             enb_id=${0}
   [Template]       Attach ue, start VoNR
   [TAGS]           CB0013142  CB013142-G-01  CB013142_G_ST_TC01_B2
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_28496 USCB013142-D#B4
   ...              current implementation:

CB013142_I_ST_TC01_B6_NSA_A1_based_SCell_Addition_based_on_mobility_meas_results_during_PSCell_change_using_Meas_Profile
    ...             gnb_id=${1}
    ...             p_cell_1=${4}
    ...             s_cell_1=${5}
    ...             s_cell_2=${2}
    ...             capabilities=UE1
    ...             enb_id=${1}
    ...             enb_cell=${3}
   [Template]       Measurement Profile Selection During PSCell Change For NSA
   [TAGS]           CB0013142  CB013142-I-01  CB013142_I_ST_TC01_B6
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_29591 USCB013142-I#B6
   ...              current implementation:


*** Keywords ***
Measurement Profile Based A2 Measurement Config For PCell Change For SA
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}  ${enb_id}  ${capabilities}=UE1

    CB013142_keywords.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  enb_id=${enb_id}  capabilities=${capabilities}
    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${32}   node_id=${gnb_id}
    # step1
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    CB013142_keywords.Start UL And DL Traffic On UE
    CB013142_keywords.Stop All Traces  tcpdump_filename=attach_pcell_traces_gnb${gnb_id}.pcap
    # step2
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Set Cell Attenuation  globalcellid=${s_cell_1}   value=${20}   node_id=${gnb_id}
    attenuator_scenario.Set Cell Attenuation  globalcellid=${s_cell_2}   value=${20}   node_id=${gnb_id}
    Sleep  5s
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013142.txt  scenario=scell_addition
    attenuator_scenario.Run Attenuator Scenario By Cell  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  scenario=scell_addition
    Sleep  5s  reason=wait for scell addition
    CB013142_keywords.Stop All Traces  tcpdump_filename=scell_addition_traces_gnb${gnb_id}.pcap
    # step3
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013142.txt  scenario=scell_change
    attenuator_scenario.Run Attenuator Scenario By Cell  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  scenario=scell_change
    Sleep  5s  reason=wait for scell change
    CB013142_keywords.Stop All Traces  tcpdump_filename=scell_change_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    Sleep  5s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes

    CB013142_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown


Measurement Profile Based A2 Measurement Config For PCell Change For NSA
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${enb_id}  ${enb_cell}=1  ${capabilities}=UE1

    CB013142_keywords.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    enb_id=${enb_id}  enb_cell=${enb_cell}  capabilities=${capabilities}
    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    CB013142_keywords.Start Neccessary Traces
    ${ru_id_enb}=    Evaluate  ${enb_cell}-${1}
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    # step1 spcell addition and scell addition
    attenuator.Set ENB All Ports Attenuation  value_in_db=${20}    enb_id=${enb_id}    ru_id=${ru_id_enb}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    Sleep  5s  reason=wait for LTE attach
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${18}   node_id=${gnb_id}
    Sleep  5s  reason=wait for attach
    CB013142_keywords.Start UL And DL Traffic On UE
    Sleep  5s  reason=wait for traffic
    CB013142_keywords.Stop All Traces  tcpdump_filename=attach_pcell_traces_gnb${gnb_id}.pcap
    # step2 pcell change
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013142.txt  scenario=pcell_switch
    attenuator_scenario.Run Attenuator Scenario By Cell  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  scenario=pcell_switch
    CB013142_keywords.Stop All Traces  tcpdump_filename=pcell_change_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes

    CB013142_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown


A1 Meas Config On SCell For PSCell Change Using NRCELL Config For NSA
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${enb_id}  ${enb_cell}=1  ${capabilities}=UE1

    CB013142_keywords.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    enb_id=${enb_id}  enb_cell=${enb_cell}  capabilities=${capabilities}
    ${ru_id_enb}=    Evaluate  ${enb_cell}-${1}
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}

    # step1 spcell addition and scell addition - measprof not used
    hanging_resources.Get Resources Before Test For All Nodes
    CB013142_keywords.Start Neccessary Traces
    attenuator.Set ENB All Ports Attenuation  value_in_db=${20}    enb_id=${enb_id}    ru_id=${ru_id_enb}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    Sleep  2s  reason=wait for LTE attach
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${20}   node_id=${gnb_id}
    Sleep  2s  reason=wait for attach
    CB013142_keywords.Start UL And DL Traffic On UE
    CB013142_keywords.Stop All Traces  tcpdump_filename=measprof_not_used_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    attenuator.Set Attenuator To Max Value

    Commissioning GNB For CB013142 D ST TC03 Part2

    # step2 pcell spcell addition and scell addition - measprof used
    CB013142_keywords.Start Neccessary Traces
    attenuator.Set ENB All Ports Attenuation  value_in_db=${20}    enb_id=${enb_id}    ru_id=${ru_id_enb}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    Sleep  2s  reason=wait for LTE attach
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${20}   node_id=${gnb_id}
    Sleep  2s  reason=wait for attach
    CB013142_keywords.Start UL And DL Traffic On UE
    CB013142_keywords.Stop All Traces  tcpdump_filename=measprof_used_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    Sleep  10s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes
    attenuator.Set Attenuator To Max Value

    CB013142_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown

Attach UE, Start Traffic And Add SCells
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}  ${enb_id}  ${capabilities}=UE1

    CB013142_keywords.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  enb_id=${enb_id}  capabilities=${capabilities}
    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${32}   node_id=${gnb_id}
    # step1
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    CB013142_keywords.Start UL And DL Traffic On UE
    CB013142_keywords.Stop All Traces  tcpdump_filename=attach_pcell_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    Sleep  5s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes

    CB013142_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown

Attach Ue, Start VoNR
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}  ${enb_id}  ${capabilities}=UE1

    CB013142_keywords.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  enb_id=${enb_id}  capabilities=${capabilities}
    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}   value=${25}   node_id=${gnb_id}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    CB013142_keywords.Start UL And DL Traffic On UE
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013142.txt  scenario=vonr
    attenuator_scenario.Run Attenuator Scenario By Cell  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  scenario=vonr
    CB013142_keywords.Stop All Traces  tcpdump_filename=attach_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    CB013142_keywords.Start Neccessary Traces
    taf.ue.Start Voice Call  VC_1  UE_1  0105
    CB013142_keywords.Stop All Traces  tcpdump_filename=vonr_traces_gnb${gnb_id}.pcap
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    Sleep  5s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes

    CB013142_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown

Measurement Profile Selection During PSCell Change For NSA
    [Documentation]    attach ue to pcell (TDD cell) - measurment profile with ue-pc=2 should be used
    ...                scell (FDD cell) addition - measurment profile with ue-pc=3 should be used
    ...                scell (TDD cell) change - measurment profile with ue-pc=2 should be used
    ...                verify tc - check wireshark trace, traffic and pm counter
    [Arguments]        ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}  ${enb_id}  ${enb_cell}=1  ${capabilities}=UE1

    CB013142_keywords.Perform Preconditions Of Test Scenario  gnb_id=${gnb_id}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  enb_id=${enb_id}  enb_cell=${enb_cell}  enb_cell=${enb_cell}  capabilities=${capabilities}
    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    CB013142_keywords.Start Neccessary Traces
    ${ru_id_enb}=    Evaluate  ${enb_cell}-${1}
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    # step1 spcell addition and scell addition
    attenuator.Set ENB All Ports Attenuation  value_in_db=${20}    enb_id=${enb_id}    ru_id=${ru_id_enb}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    Sleep  5s  reason=wait for LTE attach
    attenuator_scenario.Set Cell Attenuation  globalcellid=${s_cell_1}   value=${10}   node_id=${gnb_id}
    Sleep  2s  reason=wait for attach
    CB013142_keywords.Start UL And DL Traffic On UE
    Sleep  5s  reason=wait for traffic
    CB013142_keywords.Stop All Traces  tcpdump_filename=attach_pscell_traces_gnb${gnb_id}.pcap
    # step2 pcell change
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013142.txt  scenario=pscell_switch
    attenuator_scenario.Run Attenuator Scenario By Cell  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  scenario=pscell_switch
    Sleep  5s  reason=wait for pcell change
    CB013142_keywords.Stop All Traces  tcpdump_filename=pcell_change_traces_gnb${gnb_id}.pcap
    # step2 scell addition
    CB013142_keywords.Start Neccessary Traces
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013142.txt  scenario=scell_addition_2
    attenuator_scenario.Run Attenuator Scenario By Cell  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt  scenario=scell_addition_2
    CB013142_keywords.Stop All Traces  tcpdump_filename=scell_addition_traces_gnb${gnb_id}.pcap
    CB013142_keywords.Await UL And DL Traffic
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
    hanging_resources.Get Resources After Test For All Nodes

    CB013142_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013142_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown
