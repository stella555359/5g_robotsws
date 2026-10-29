*** Settings ***
Documentation     Contains 5GC000782-A feature test cases
Resource        ../Common_Keywords_782_A_B.robot

Suite Setup      Suite Setup    feature_folder=5GC000782-A
Suite Teardown   Suite Teardown
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Variables ***
${wireshark_filter_tc_2}               ${CURDIR}/Resources/TC_2_wireshark_filter_file.txt
${wireshark_filter_tc_12}              ${CURDIR}/Resources/TC_12_wireshark_filter_file.txt

*** Test Cases ***
5GC000782_A_2_Gnb_Selects_Zuc_Algorithm_Ul_Data
    [Documentation]     Verify that gNB selects ZUC(nea3-128) algorithm having high priority
    ...                 and UL user data is ciphered & deciphered at UE and gNB respectively
    [Tags]    CIT
    [Setup]    Test Setup    config_scenario=ZUC_Algo
    Attach UE and Perform Sgnb Addition
    Start UL and DL Data Transfer And Verify Throughput on Default Bearer
    UE Detach   ${UE_ID_1}
    Verify ciphering messages in pcap    ${wireshark_filter_tc_2}

5GC000782_A_12_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Documentation]     Verify that SgNB addition reject is received by MeNB when UE supports ciphering Algorithm
    ...                 as SNOW3G(nea1-128) and ZUC(nea3-128) but gNB support only AES(nea2-128)
    [Tags]    CRT
    [Setup]    Test Setup    config_scenario=sgnb_reject
    Attach UE and Sgnb Addition fails
    UE Detach   ${UE_ID_2}
    Verify ciphering messages in pcap    ${wireshark_filter_tc_12}

*** Keywords ***
Execute Delta Commissioning
   [Arguments]    ${config_scenario}
   run keyword if    '${config_scenario}' == 'ZUC_Algo'    Execute Delta Commissioning for ZUC_Algo
   run keyword if    '${config_scenario}' == 'sgnb_reject'    Execute Delta Commissioning for Sgnb Reject

Execute Delta Commissioning for ZUC_Algo
    [Documentation]    The ciphering algorithm are as follows -
    ...                nea0:Null ciphering algorithm, nea1_128:SNOW 3G-based algorithm
    ...                nea2_128:AES-based algorithm, nea3_128:ZUC-based algorithm
    ...   The values that can be given is from 0-9, where 0 has the least precedence and 9 has the highest precedence
    ...   Based on what UE also supports and the precedence given in Gnb, the Gnb selects the ciphering algorithm
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.add_list_parameters_to_delta    dist_name=${NRBTS_DISTNAME}    list_name=cipherPrefL    nea0=1
    ...    nea1_128=4    nea2_128=6    nea3_128=8
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Execute Delta Commissioning for Sgnb Reject
    [Documentation]    The ciphering algorithm are as follows -
    ...                nea0:Null ciphering algorithm, nea1_128:SNOW 3G-based algorithm
    ...                nea2_128:AES-based algorithm, nea3_128:ZUC-based algorithm
    ...   The values that can be given is from 0-9, where 0 has the least precedence and 9 has the highest precedence
    ...   Here,UE supports only Snow3G and ZUC, whereas the same is disabled at Gnb side.Hence, Gnb rejects the Sgnb Addition.
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.add_list_parameters_to_delta    dist_name=${NRBTS_DISTNAME}    list_name=cipherPrefL    nea0=0
    ...    nea1_128=0    nea2_128=8    nea3_128=0
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

