*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  CB006733_Handling_mixed_A1A4_meass_caBackoffTimerUeOh expiry_UE_overheating

Resource   ../5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC002640/resources/keywords_mtk.robot
Resource        ../regression/regression_keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB006733/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005934/resources/keywords.robot
Library    ../5GC001167/resources/pcap_verifiers.py
Library    ../5GC001167/resources/keywords_1167.py    WITH NAME   python_1167
Library    ute_ue



*** Keywords ***
[1]TC18_CB006733_Handling_mixed_A1A4_meass_caBackoffTimerUeOh expiry_UE_overheating
    counters.Wait For Pm Counters Interval    offset=0
    Require Ue                       MediaTekUe   capabilities=REAL_MEDIATEK_UE
    Attenuate All Ports
    Overheating Attach
    trigger Overheating Assistance command from UE
    Overheating Counters
    [Teardown]        ute_ue.Detach Ue   MediaTekUe


