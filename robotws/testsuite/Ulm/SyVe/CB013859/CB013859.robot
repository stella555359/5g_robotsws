*** Settings ***
Documentation   This is a Robot Test Suite for feature: CB013859
...             CB013859 Carrier Aggregation support based on slice ID configuration
...             Team: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue
Resource                        CB013859_keywords.robot
Resource                        ../resources/hanging_resources.robot

Suite Setup                     CB013859_keywords.Prepare TL For Testing
Suite Teardown                  CB013859_keywords.Save All Logs And Teardown TL

Test Setup                      CB013859_keywords.Setup Test
Test Template                   Setup of inter-band CA with alternative bands

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=1500 Mbits/sec
...                             UL_THROUGHPUT=250 Mbits/sec
...                             TPUT_DEVIATION=90%
...                             DURATION=30s
...                             PROTOCOL=udp
${WITH_PMCOUNTER_CHECK}         true
${INITIAL_SCF_FILE_ACTIVATION}  true
${UE_ALIAS_1}                   X80
${UE_ALIAS_2}                   MTK

*** Test Cases ***
CB013859_A_RE_TC03_B3_UE_connection_setup_single_slice
    ...             gnb_id_0=${0}
    ...             p_cell_1=${1}
    ...             s_cell_1=${10}
    ...             s_cell_2=${4}
    ...             s_cell_3=${15}
    ...             capabilities1=UE1
    ...             capabilities2=UE2
    ...             test_case=A03
   [Template]       Measurement profile based A2 measurement config for PCell change for SA
   [TAGS]           CB013859_A03  CB013859
   [Documentation]  This user scenario describes the successful carrier aggregation configuration for the UE with PDU sessions with single
   ...              slice. UE is configured with SCells supporting only the specific slice and with SCells supporting all the slices which
   ...              are supported by the PCell. A1 based SCell addition is activated, and buffer-based SCell addition is deactivated.

CB013859_A_RE_TC04_B5_UE_conn_setup_PDU_with_multiple_slices_some_not_supp_scells
    ...             gnb_id_0=${0}
    ...             p_cell_1=${1}
    ...             s_cell_1=${10}
    ...             s_cell_2=${4}
    ...             s_cell_3=${15}
    ...             capabilities1=UE1
    ...             test_case=A04
   [Template]       UE Connection Setup Multiple Slices Some Not Supp Scells
   [TAGS]           CB013859_A04  CB013859
   [Documentation]  This user scenario describes the successful carrier aggregation configuration for the UE with PDU sessions with multiple
   ...              slices, where some slices are not supported by SCells. If the slice of PDU is not supported by the SCell, the default
   ...              resource group is used.
   ...              this TC covers user scenario 5G_RAN_USR_RRM_30638, 5G_PM_2650
   ...              current implementation:

CB013859_B_RE_TC06_IWK_5_interworking_A6_based_SCell_swap_F_to_F
    ...             gnb_id_0=${0}
    ...             p_cell_1=${10}
    ...             s_cell_1=${1}
    ...             s_cell_2=${15}
    ...             s_cell_3=${19}
    ...             s_cell_target_2=${18}
    ...             s_cell_target_3=${21}
    ...             capabilities1=UE1
   [Template]       Scell Swap Scenario
   [TAGS]           CB013859_B06  CB013859
   [Documentation]  This user scenario describes the successful operation of the A6 based SCell swap for the UE with PDU
   ...              sessions with multiple slices, where some slices are not supported by SCells. The SCell swap pair
   ...              doesn’t support all the slices of the UE.

CB013859_B_RE_TC07_IWK_6_interworking_inter_gNB_CA
    ...             gnb_id_0=${0}
    ...             gnb_id_1=${1}
    ...             p_cell_1=${1}
    ...             s_cell_1=${101}
    ...             s_cell_2=${102}
    ...             s_cell_3=${104}
    ...             ext_s_cell_1=${1}
    ...             ext_s_cell_2=${2}
    ...             ext_s_cell_3=${4}
    ...             capabilities1=UE1
   [Template]       IWK Interworking Inter GNB CA
   [TAGS]           CB013859_B07  CB013859
   [Documentation]  This user scenario describes the successful inter-gNB CA SCell addition for the UE with PDU sessions with multiple
   ...              slices, where some slices are not supported by SCells. If the slice of PDU is not supported by the ext-SCell, the
   ...              default resource group is used.
   ...              this TC covers user scenario 5G_RAN_USR_RRM_30668, 5G_PM_2650

*** Keywords ***
Measurement Profile Based A2 Measurement Config For PCell Change For SA
    [Documentation]    Starting Execution CB013859_A03 Part1, Qualcomm slicing check
    ...                Part 1: With Qualcomm all 3 Scells shall be attached, since slice std3 is allowed
    ...                Part 2: With MTK only 2 Scells shall be attached, since slice std3 is not allowed
    [Arguments]        ${gnb_id_0}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}   ${s_cell_3}  ${capabilities1}=UE1  ${capabilities2}=UE2
    ...                ${test_case}=A03

    CB013859_keywords.Perform Preconditions Of Test Scenario  gnb_id_0=${gnb_id_0}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  s_cell_3=${s_cell_3}

    Set Test Variable  ${Part}  ${1}
    CB013859_keywords.Execution CB013859  ue_alias=${capabilities1}  test=${test_case}
    CB013859_keywords.Verify Qc Test Case

    Set Test Variable  ${Part}  ${2}
    CB013859_keywords.Execution CB013859  ue_alias=${capabilities2}  test=${test_case}
    CB013859_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013859_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown  node_type=sbts

UE Connection Setup Multiple Slices Some Not Supp Scells
    [Documentation]    Starting Execution CB013859_A04 Qualcomm slicing check
    ...                all 3 Scells shall be attached, since all Scells have default ressource group enabled
    [Arguments]        ${gnb_id_0}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}   ${s_cell_3}  ${capabilities1}=UE1  ${test_case}=A04

    CB013859_keywords.Perform Preconditions Of Test Scenario  gnb_id_0=${gnb_id_0}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  s_cell_3=${s_cell_3}

    Set Test Variable  ${Part}  ${1}
    CB013859_keywords.Execution CB013859  ue_alias=${capabilities1}  test=${test_case}
    CB013859_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013859_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown  node_type=sbts

Scell Swap Scenario
    [Documentation]    Starting Execution CB013859_A03 Part1, Qualcomm slicing check
    ...                Part 1: With Qualcomm all 3 Scells shall be attached, since slice std3 is allowed
    ...                Part 2: With MTK only 2 Scells shall be attached, since slice std3 is not allowed
    [Arguments]        ${gnb_id_0}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}   ${s_cell_3}  ${s_cell_target_2}  ${s_cell_target_3}  ${capabilities1}=UE1

    CB013859_keywords.Perform Preconditions Of Test Scenario  gnb_id_0=${gnb_id_0}  p_cell_1=${p_cell_1}  s_cell_1=${s_cell_1}
    ...    s_cell_2=${s_cell_2}  s_cell_3=${s_cell_3}  s_cell_target_2=${s_cell_target_2}  s_cell_target_3=${s_cell_target_3}

    Set Test Variable  ${Part}  ${1}
    Set Test Variable  ${ue_alias}  ${capabilities1}
    taf.ue.Require UE  ${ue_alias}  capabilities=${capabilities1}
#    taf.ue.Reboot  ${ue_alias}
    taf.ue.Detach UE   ${ue_alias}
    Sleep  20s  reason=wait release of resources
    hanging_resources.Get Resources Before Test For All Nodes
    CB013859_keywords.Start Tracing
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        Log To Console    \nPMcounters: Wait for next Measurement Period to start.
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id_0}
    END

    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}  value=${50}  node_id=${gnb_id_0}
    taf.ue.Attach UE   ${ue_alias}  timeout=180
    Sleep  20s  reason=Wait for RRC Release, UE idle mode
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013859.txt  scenario=SEN_CB013859_A03
    attenuator_scenario.Run Attenuator Scenario By Cell  scenario=SEN_CB013859_A03  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt
    ${dl_dt_name}    ${ul_dt_name}=    CB013859_keywords.Start UL And DL Traffic  dl_throughput=${TRAFFIC.DL_THROUGHPUT}
    ...                                ul_throughput=${TRAFFIC.UL_THROUGHPUT}  duration_dl=${TRAFFIC.DURATION}  duration_ul=${TRAFFIC.DURATION}
    ...                                ue_alias=${ue_alias}
    CB013859_keywords.Stop Tracing And Save As    tcp_file=CB013859_scell_addition

    CB013859_keywords.Start Tracing
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013859.txt  scenario=SEN_CB013859_A06_scell_swap
    attenuator_scenario.Run Attenuator Scenario By Cell
    ...	 scenario=SEN_CB013859_A06_scell_swap  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt
    CB013859_keywords.Await UL And DL Traffic  dl_dt_name=DT_DL_${Part}  ul_dt_name=DT_UL_${Part}
    CB013859_keywords.Stop Tracing And Save As    tcp_file=CB013859_scell_swap
    taf.ue.Detach UE   ${ue_alias}
    attenuator.Set Attenuator To Max Value
    hanging_resources.Get Resources After Test For All Nodes


    CB013859_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013859_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown  node_type=sbts

IWK Interworking Inter GNB CA
    [Documentation]    Starting Execution CB013859_B07
    ...                all 3 Scells on the second gNB shall be attached, since all Scells have default ressource group enabled
    [Arguments]        ${gnb_id_0}  ${gnb_id_1}  ${p_cell_1}  ${s_cell_1}  ${s_cell_2}  ${s_cell_3}  ${ext_s_cell_1}  ${ext_s_cell_2}
    ...                ${ext_s_cell_3}  ${capabilities1}=UE1

    CB013859_keywords.Perform Preconditions Of Test Scenario  gnb_id_0=${gnb_id_0}  gnb_id_1=${gnb_id_1}  p_cell_1=${p_cell_1}
    ...                s_cell_1=${s_cell_1}  s_cell_2=${s_cell_2}  s_cell_3=${s_cell_3}  ext_s_cell_1=${ext_s_cell_1}
    ...                ext_s_cell_2=${ext_s_cell_2}  ext_s_cell_3=${ext_s_cell_3}

    Set Test Variable  ${Part}  ${1}
    Set Test Variable  ${ue_alias}  ${capabilities1}
    taf.ue.Require UE  ${ue_alias}  capabilities=${ue_alias}
#    taf.ue.Reboot  ${ue_alias}
    taf.ue.Detach UE   ${ue_alias}
    Sleep  20s  reason=wait release of resources
    hanging_resources.Get Resources Before Test For All Nodes
    CB013859_keywords.Start Tracing
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        Log To Console    \nPMcounters: Wait for next Measurement Period to start.
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id_0}
    END
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}  value=${50}  node_id=${gnb_id_0}
    taf.ue.Attach UE   ${ue_alias}  timeout=180
    Sleep  20s  reason=Wait for RRC Release, UE idle mode
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013859.txt  scenario=SECTION SEN_CB013859_B07
    attenuator_scenario.Run Attenuator Scenario By Cell
    ...                 scenario=SECTION SEN_CB013859_B07  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt
    ${dl_dt_name}    ${ul_dt_name}=    CB013859_keywords.Start UL And DL Traffic  dl_throughput=${TRAFFIC.DL_THROUGHPUT}
    ...                                ul_throughput=${TRAFFIC.UL_THROUGHPUT}  duration_dl=${TRAFFIC.DURATION}  duration_ul=${TRAFFIC.DURATION}
    ...                                ue_alias=${ue_alias}
    CB013859_keywords.Await UL And DL Traffic  dl_dt_name=DT_DL_${Part}  ul_dt_name=DT_UL_${Part}
    CB013859_keywords.Stop Tracing And Save As    tcp_file=UE1_CB013859_B07
    taf.ue.Detach UE   ${ue_alias}
    attenuator.Set Attenuator To Max Value
    hanging_resources.Get Resources After Test For All Nodes
    CB013859_keywords.Verify Qc Test Case

    [Teardown]    Run Keywords
    ...           CB013859_keywords.Perform Postconditions Of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown  node_type=sbts
