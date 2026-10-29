*** Settings ***
Documentation
...   author: kaihui.fan@nokia-sbell.com
...   squad group: SG4
...   Feature 5GC000955
...   5GC000955 common keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_sfp_and_check.robot

*** Keywords ***
General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Documentation]
    ...    lock and SFP and reset bts, to check cell can be onair or fault 1868 raised after 18 mins.
    [Arguments]   ${bbmod_index}=1  ${connection}=GNB_OAM
    Log to console    Get SFP info
    ${bts_info}=     coam.get_bts_info   detailed_output=${True}  timeout=20    connection=${connection}
    ${bbmod_info}  ${bbmod_and_ports}  ${bbmod_ports_info_dict}  ${SFP_HW_PORTs}  Get Single BBMOD Connected SFP Ports And Info
    ...   ${bts_info}  ${bbmod_index}
    ${bbmod_object}=   get from dictionary  ${bbmod_info}  object_name
    ${bbmod_product}=   get from dictionary  ${bbmod_info}  product_name
    Online Add Objection Sfps And Lanes On Sinlge BBMOD  ${bbmod_object}  ${SFP_HW_PORTs}
    ${sfp_port}   Random Lock Sfp And Lane  ${bbmod_and_ports}  ${bbmod_product}
    log to console   \nExpect Fault 1815 Should Present
    Wait until Keyword Succeeds    10min  30s    Expect Fault Should Present  faultId=1815
    log to console   \nPerform BTS Site Reset
    Perform BTS Site Reset
    log to console   \nExpect All Cells Onair Or Fault 1868 Should Present
    Wait until Keyword Succeeds    20min  60s    Verify All Cells Onair Or 1868 Raised
    UnLock Sfp And Lane  ${sfp_port}  ${bbmod_product}
    log to console   \nExpect All Cells Onair after unlock SFP ${sfp_port}
    Wait until Keyword Succeeds    2min  30s    verify all cells should be onair    cell_type=${cell_type}
    [Teardown]  Online Delete Objection Sfps And Lanes On Sinlge BBMOD  ${bbmod_object}  ${SFP_HW_PORTs}

