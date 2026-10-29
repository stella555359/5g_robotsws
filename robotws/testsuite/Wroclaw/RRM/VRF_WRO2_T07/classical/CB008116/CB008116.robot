*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the TESTSUITE file for feature CB008116


Library         taf.sbts.oam.coam.admin    WITH NAME    coam
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/keywords_8116.robot


Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline            AND
...              Initialise Attenuator


*** Test Cases ***
CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and AES IP algorithm.
    CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO

CB008116-A_2_Integrity_Protection_in_DL_with_SNOW_3G_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and SNOW 3G algorithm.
    CB008116-A_2_Integrity_Protection_in_DL_with_SNOW_3G_IP_algorithm_ASIB_ABIO

CB008116-A_3_Integrity_Protection_in_DL_with_ZUC_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and ZUC algorithm.
    CB008116-A_3_Integrity_Protection_in_DL_with_ZUC_IP_algorithm_ASIB_ABIO

CB008116-A_4_Integrity_Protection_in_UL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in UL direction and AES IP algorithm
    CB008116-A_4_Integrity_Protection_in_UL_with_AES_IP_algorithm_ASIB_ABIO
