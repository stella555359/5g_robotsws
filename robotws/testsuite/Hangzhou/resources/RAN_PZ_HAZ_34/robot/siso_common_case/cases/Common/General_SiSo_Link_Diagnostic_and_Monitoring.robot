*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Variables ***

*** Keywords ***
General_SiSo_Link_Diagnostic_and_Monitoring
    ${sfpLinks}    coam.get_sfp_links    connection=GNB_OAM
    ${connected_links}    set variable    ${sfpLinks['connected']}
    ${not_connected_links}    set variable    ${sfpLinks['notConnected']}
    ${num}    Get Length    ${connected_links}
    FOR    ${index}    IN RANGE    ${num}
        Get SFP Detail Info    link_info=${connected_links[${index}]}
        Get SFP Monitoring Parameters value    link_info=${connected_links[${index}]}    status=connected
    END
    ${num}    Get Length    ${not_connected_links}
    FOR    ${index}    IN RANGE    ${num}
        Get SFP Detail Info    link_info=${not_connected_links[${index}]}
        Get SFP Monitoring Parameters value    link_info=${not_connected_links[${index}]}    status=notConnected
    END
