# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/18 17:33

    # Step 1: power off/on ru to update soap file
    ${ru_index_list}    Get All RU Index
    Perform RU Power Off And On    ru_index_list=${ru_index_list}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END

    # Step2: support check single core or dual core
    ${smod_list}    coam.get_all_items_by_class_name    class_name=SMOD    connection=GNB_OAM
    ${left_or_right}    coam.get_smod_position    connection=GNB_OAM
    ${smod_length}    Get Length    ${smod_list}
    Run Keyword If    '${smod_length}'=='2'    Run Keywords
    ...    Check RU Info From Target Core    position=left    check_soap_file=${True}    AND
    ...    Check RU Info From Target Core    position=right    check_soap_file=${True}
    Run Keyword If    '${smod_length}'=='1'
    ...    Check RU Info From Target Core    position=${left_or_right}    check_soap_file=${True}
