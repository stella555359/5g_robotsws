*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Variables ***

*** Keywords ***
4G_RRM__SBTS_Inter_site_eNB_carrier_aggregation_Multicommissioning_Common
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this test case is to perform commissionig on all cooperating BTSes, within tested
    ...    feature, at same time. It is checked that after planned commissioning all SBTS services (from all RATs) have
    ...    expected states and no unexpected alarms are visible.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.08.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
    COAM Commission with scf file  scf_file_path=${SCF_Path}    timeout=600
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Run Keyword And Ignore Error    Close Start Up View Window    timeout=5
    ${actDLCAggr}    Get Single Parameter Value on WebUI  dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}
    ...    filter_param=Activation of downlink carrier aggregation
    should be equal as strings    '${actDLCAggr}'   'true'
    ${actInterEnbDLCAggr}    Get Single Parameter Value on WebUI  dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}
    ...    filter_param=Activate inter-eNB DL carrier aggregation
    should be equal as strings    '${actInterEnbDLCAggr}'   'true'
