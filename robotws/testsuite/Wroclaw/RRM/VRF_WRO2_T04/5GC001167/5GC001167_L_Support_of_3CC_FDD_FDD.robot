*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ./resources/keywords.robot
Library    ./resources/keywords_1167.py    WITH NAME   python_1167
Library    ./resources/pcap_verifiers.py
Library       testsuite/Wroclaw/RRM/resources/etws_cmas/counters.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/utilities.py

*** Keywords ***
5GC001167-L_Successful_scenarios_PM_counters
    Set Preferred Cell     ${PCELL_106}
    Set Initial Attenuation For Test

    Attach Ue and Collect Counters    counter_list=${C_L}    dict_name=COUNTERS_L    num_of_scells=2
    ...    tput_duration=600s    scells_id=${SCELL_100},${SCELL_101}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55118C07001    ${PCELL_106}
    ...    operator=>=    value=100
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55118C07002    ${SCELL_100}
    ...    operator=>=    value=100
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55118C07002    ${SCELL_101}
    ...    operator=>=    value=100
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55118C07003    ${PCELL_106}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55118C07004    ${PCELL_106}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55138C02501    ${PCELL_106}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55138C02502    ${PCELL_106}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55139C01501    ${PCELL_106}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55139C01502    ${PCELL_106}
    Run Keyword And Continue On Failure    Counter Incremented Successfully    M55118C00033    ${PCELL_106}
    ...    value=2


    #BTS COUNTERS
    Run Keyword And Continue On Failure    Verify Counter Value    M55348C00001    expected_value=2
    Run Keyword And Continue On Failure    Verify Counter Value    M55348C00002    expected_value=1
    Run Keyword And Continue On Failure    Verify Counter Value    M55348C00001    expected_value=2    wait_for_interval=${TRUE}
    Run Keyword And Continue On Failure    Verify Counter Value    M55348C00002    expected_value=1
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}
