*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Library         DateTime
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000630/resources/functions_630.py
Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tput_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000630/resources/tput_counters.py


*** Variables ***
@{tputs_in_mbits}    4  11  30  75  250  750  1500


*** Keywords ***
Check Average Tput From Last PM Interval
    [Arguments]    ${ue}
    ${avg_tput}   Get Average Throughput   dt_name=DT_DL_${ue}   tput_collection_src=control_app
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    [Return]   ${avg_tput}
