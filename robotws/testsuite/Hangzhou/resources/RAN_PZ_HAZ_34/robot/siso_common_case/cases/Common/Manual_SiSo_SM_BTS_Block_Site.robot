*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_SM_BTS_Block_Site
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify bts block/unblock functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.10.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${stream}    get stream from version    ${Active_SW_version}
    ${boundary}    get the boundary of stream    stream=${stream}
	selenium_coam.block_site
	Wait Until Keyword Succeeds    10min    30s    COAM Check GNB RU status
	sleep  60
	Wait Until Keyword Succeeds    10min    30s    Cell Status Info Should Be Disabled    cell_type=${cell_type}    boundary=${boundary}
	Wait until keyword succeeds    10min    30s    Expect Fault Should Present on WebUI    faultId=50
	selenium_coam.unblock_site
	Wait Until Keyword Succeeds    10min    30s    COAM Check GNB RU status
    sleep  360
	Wait Until Keyword Succeeds    10min    30s    Cell Status Info Should Be Enable   cell_type=${cell_type}    boundary=${boundary}
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent on WebUI    faultId=50
