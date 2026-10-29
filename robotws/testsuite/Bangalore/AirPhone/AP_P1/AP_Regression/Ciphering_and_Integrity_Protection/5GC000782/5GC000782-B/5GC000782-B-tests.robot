*** Settings ***
Documentation     Contains 5GC000782-B feature test cases
Resource        ../Common_Keywords_782_A_B.robot

Suite Setup      Suite Setup    feature_folder=5GC000782-B
Suite Teardown   Suite Teardown
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Variables ***
${wireshark_filter_tc_7}               ${CURDIR}/Resources/TC_7_wireshark_filter_file.txt
${wireshark_filter_tc_14}              ${CURDIR}/Resources/TC_14_wireshark_filter_file.txt

*** Test Cases ***
5GC000782_B_7_Gnb_Selects_Snow3g_Algorithm_Ul_Dl_data
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
     ...          Also verify that DL & UL traffic is ciphered & diciphered at gNB & UE
    [Tags]    CIT
    [Setup]    Test Setup    config_scenario=Snow3G_Algorithm
    Attach UE and Perform Sgnb Addition
    Start UL and DL Data Transfer And Verify Throughput on Default Bearer
    UE Detach   ${UE_ID_1}
    Verify ciphering messages in pcap    ${wireshark_filter_tc_7}

5GC000782_B_14_Gnb_Selects_Aes_Algorithm_Ul_Dl_data
    [Documentation]  This TC verify that gNB selects AES ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL&DL traffic is ciphered & diciphered at gNB & UE
    [Tags]    CRT
    [Setup]    Test Setup    config_scenario=AES_Algorithm
    Attach UE and Perform Sgnb Addition
    Start UL and DL Data Transfer And Verify Throughput on Default Bearer
    UE Detach   ${UE_ID_1}
    Verify ciphering messages in pcap    ${wireshark_filter_tc_14}

*** Keywords ***
Execute Delta Commissioning
   [Arguments]    ${config_scenario}
   run keyword if    '${config_scenario}' == 'Snow3G_Algorithm'    Execute Delta Commissioning for Snow3G Algorithm
   run keyword if    '${config_scenario}' == 'AES_Algorithm'    Execute Delta Commissioning for AES Algorithm

Execute Delta Commissioning for Snow3G Algorithm
    [Documentation]    The ciphering algorithm are as follows -
    ...                nea0:Null ciphering algorithm, nea1_128:SNOW 3G-based algorithm
    ...                nea2_128:AES-based algorithm, nea3_128:ZUC-based algorithm
    ...   The values that can be given is from 0-9, where 0 has the least precedence and 9 has the highest precedence
    ...   Based on what UE also supports and the precedence given in Gnb, the Gnb selects the ciphering algorithm
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.add_list_parameters_to_delta    dist_name=${NRBTS_DISTNAME}    list_name=cipherPrefL    nea0=5
    ...    nea1_128=9    nea2_128=7    nea3_128=8
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Execute Delta Commissioning for AES Algorithm
    [Documentation]    The ciphering algorithm are as follows -
    ...                nea0:Null ciphering algorithm, nea1_128:SNOW 3G-based algorithm
    ...                nea2_128:AES-based algorithm, nea3_128:ZUC-based algorithm
    ...   The values that can be given is from 0-9, where 0 has the least precedence and 9 has the highest precedence
    ...   Based on what UE also supports and the precedence given in Gnb, the Gnb selects the ciphering algorithm
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.add_list_parameters_to_delta    dist_name=${NRBTS_DISTNAME}    list_name=cipherPrefL    nea0=1
    ...    nea1_128=7    nea2_128=9    nea3_128=8
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
