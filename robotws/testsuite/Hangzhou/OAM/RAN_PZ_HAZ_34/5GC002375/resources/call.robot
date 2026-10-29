*** Settings ***
Documentation   This is common keyword for 5GC001681 cases coam parts.
...              Squard: HZ SG7

#Resource   ${CURDIR}/../../../../resources/sites/Hangzhou/robot/android_common_keyword.robot
Resource   ../../common/L3_Call.robot
Resource   ../../common/enb.robot

*** Variables ***
${iperf_port}   ${tl.ues[0].iperf_details.port}
@{test_cells}   ${0}   ${1}

*** Keywords ***
Setup MultiCell Call
    [Arguments]   ${duration}=180
    ${ue_type}   Get UE Type   ue_info=${ue_info}
    Run Keyword   Setup MultiCell Call ${ue_type}   duration=${duration}

#Setup MultiCell Call Viavi
#    [Arguments]   ${duration}=180
#    E500 precondition
#    Wait Until Keyword Succeeds   3 times   10s   tm500_remote.Connect to  ip=${TM500_IP}  command_port=${TM500_PORT}  alias=${tm500_alias}
#    :FOR   ${cell}   IN   @{test_cells}
#    \   Set Enb Cell Attach Index   ${cell}
#    \   ${hw_connect_script}   ${cell_search_script}   ${attach_script}   _Set Viavi script path   ${CURDIR}/../E500_${cell}_scripts
#    \   Wait Until Keyword Succeeds   3 times   1m   Connect HW and Initialize   ${hw_connect_script}   ${tm500_alias}
#    \   Perform Cell Search   ${cell_search_script}   ${tm500_alias}
#    \   Log to console   Cell search done, start Viavi UE attach
#    \   ${response}   ${ue_ip}   Viavi UE l3 call   ${attach_script}
#    \   Start DL traffic via iperf on Appserver   ${ue_ip}   ${duration}   ${iperf_port}   10M   1400
#    \   Sleep   ${duration}s
#    \   E500 detach   ${CURDIR}/../E500_${cell}_scripts/NSA_5G_UEdetach.txt

