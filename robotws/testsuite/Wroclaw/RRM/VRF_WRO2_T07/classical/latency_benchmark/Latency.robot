*** Settings ***
Documentation
...   author: Karol Pichurski
...   contact: karol.pichurski@nokia.com
...
...   This test calculate: latency of Nsa Setup and Release, latency of Nsa Handover
...   and interruption time of Downlink and Uplink with Handover.


Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library         resources/keywords_latency.py
Variables       resources/keywords_latency.py


Suite Setup      Run Keywords
...              Prepare_testline            AND
...              Setup and check preconditions in scf    params_to_check=${setup_params}

Suite Teardown          Setup and check preconditions in scf    params_to_check=${default_params}


*** Test Cases ***
Analyze_NSA_Call_Setup_and_Release_Latency
    Analyze_NSA_Call_Setup_and_Release_Latency

Analyze_NSA_Handover_Latency
    Analyze_NSA_Handover_Latency

Analyze_NSA_Handover_Interruption_Time
    Analyze_NSA_Handover_Interruption_Time
