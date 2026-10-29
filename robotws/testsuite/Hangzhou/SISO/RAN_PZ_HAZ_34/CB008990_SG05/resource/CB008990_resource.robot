*** Settings ***
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006277 in 5G22R1 program

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-80168_SG05/Resource/CNI-80168_Common_KW.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-80168_SG05/Variable/variable_CNI-80168.py
Library     CB008990_keyword.py

*** Keywords ***
Ecpri_RU_DFE_no_TX_Data_fault_activation_Fault1904_AQQL
    Triger fault 1904 on expected RU
    log to console    verify alarm exist
    Wait until keyword succeeds    2min    2sec    Expect Fault Should Present on WebUI    faultId=1904
    log to console    RU Should Be Offline
    Wait until keyword succeeds    5min    2sec    RU Should Be Offline
    log to console    Verify all cells should be onair
    Wait until keyword succeeds    10min    1min    Verify all cells should be onair

Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation_Fault1981_AQQL
    ${carrie_name}    Get carrier name from RU
    Set Test Variable    ${carrier_tx_list}    ${carrie_name}[1]
    log to console    ${carrier_tx_list}
    Set Test Variable    ${carrier_tx}    ${carrier_tx_list['Carrier name'][0]}
    Triger fault 1981 on expected RU    carrier_tx=${carrier_tx}
    log to console    verify alarm exist
#    Wait until keyword succeeds    2min    2sec    Expect Fault Should Present on WebUI    faultId=1981
    #5G AHS REQ updated due to customer PR 04211816
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable    ${split_version}[0]
    Run Keyword If    '${stream}' >= 'SBTS25R2'
    ...    Wait until keyword succeeds    2min    2sec    Expect Fault Should Present on WebUI    faultId=1907
    ...    ELSE    Wait until keyword succeeds    2min    2sec    Expect Fault Should Present on WebUI    faultId=1981
    log to console    RU Should Be Offline
    Wait until keyword succeeds    5min    2sec    RU Should Be Offline
    log to console    Verify all cells should be onair
    Wait until keyword succeeds    10min    1min    Verify all cells should be onair

Triger fault 1904 on expected RU
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master    ${node_id}=1
    log to console    Triger fault 1904 on expected RU
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    Connect To Node Via RU Connection    node_id=1    ru_index=${ru_index}
    Execute one command on specified Node    node_id=1    cmd=ifconfig arb0p1 down
    csn.disconnect    connection=node_${node_id}
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Triger fault 1981 on expected RU
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master    ${node_id}=1    ${carrier_tx}=none
    log to console    Triger fault 1981 on expected RU
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    Connect To Node Via RU Connection    node_id=1    ru_index=${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=node_${node_id}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable
    ...    echo "/ action create CarrierFaultInjection /dfe0"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/dfe0 action break_tx_data_transmission "${carrier_tx}" "antenna1a"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=node_${node_id}
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Execute one command on specified Node
    [Arguments]    ${cmd}    ${node_id}
    ${sudo}    csn.execute    command=which sudo    connection=node_${node_id}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable    ${sudo} ${cmd}
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    sleep    2s

Get carrier name from RU
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master
    log to console    Get carrier name from RU
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    Connect To Node Via RU Connection    node_id=1    ru_index=${ru_index}
    ${output}    csn.execute    command=sudo bfcali -stat    connection=RU_${ru_index}
    ${carrie_name}    get_ru_carrier_name    input=${output}
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${carrie_name}
    [Teardown]    csn.disconnect    connection=ASIK Master
