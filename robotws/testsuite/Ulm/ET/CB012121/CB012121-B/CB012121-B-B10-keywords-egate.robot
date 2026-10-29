*** Settings ***
Documentation   This is a keyword file for CB012121-B-B10 egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

send 2 times A3 with phycell_id 51 and 49
    [Documentation]    [PRIVATE]    send 2 times A3 with phycell_id 51 and 49
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    send A3  ue_id=${ue_id}   phycell_id=51   nrsrp_nr=58   nrsrq_nr=50   meas_id=5   log=1
    sleep  3s
    send A3  ue_id=${ue_id}   phycell_id=49   nrsrp_nr=58   nrsrq_nr=50   meas_id=5   log=1


send B2 and A3 with check
    [Documentation]    [PRIVATE]    send B2 and A3 with check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    send B2 no check              ue_id=${ue_id}
    sleep  3s
    send A3 and check             ue_id=${ue_id}   log=3
