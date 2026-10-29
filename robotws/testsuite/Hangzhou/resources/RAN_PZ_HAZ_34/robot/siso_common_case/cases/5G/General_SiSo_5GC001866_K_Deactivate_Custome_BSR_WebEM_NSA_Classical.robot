*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check Installed BSR can be applied by user
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.23.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${BSR_package}=BSR_AQQY_2_H2_ALN60_ARP60_N01_COVERAGE_00388_00001
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console    \nDeactivate custom beam set realization
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate custom beam set realization  p_name=actCustomBsr  value=false
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Basic Beam Set  p_name=basicBeamSet  value=beamSet_2
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Custom Beam Set Name  p_name=customBeamSetName  value=${EMPTY}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks  p_name=numberOfTransmittedSsBlocks
    ...    value=2 beams
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep  60
    Remove not used beam set realization software
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    ${cell_list}    Get All Cell Id
    Get UE From Init File and Make call    cell_list=${cell_list}  duration=${120}
    [Teardown]  Selenium Logout And Close Browser
