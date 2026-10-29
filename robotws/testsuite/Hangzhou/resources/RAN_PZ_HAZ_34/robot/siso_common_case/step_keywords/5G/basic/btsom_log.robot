*** Settings ***
Documentation    This is common keywords for siso RU related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.transport.ssh   WITH NAME   csn
Resource      taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Keywords ***
Check 5G inter Loki IQ data routing via Btsom Log
    [Arguments]    ${alias}=asik_conn
    ${output}    Check Btsom Log file on ASIK    filter=isEcpriIqForwardingEnabled
    Should Contain    ${output}    isEcpriIqForwardingEnabled: boolean = true

Check Btsom Log file on ASIK
    [Documentation]    Author:jie-jessy.li@nokia-sbell.com
    [Arguments]    ${alias}=asik_conn    ${logfolder}=fct-0a_aasyslog  ${filter}=None
    Connect to Common Unit Master     alias=${alias}
    ${status}    Run Keyword And Return Status    csn.assert file exists    remote_path=/tmp/startup_BTSOM.log    connection=${alias}
    ${command}    Set Variable If    '${status}'=='True'    cat /tmp/startup_BTSOM.log |grep -i '${filter}'
    ...                              '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz |grep -i '${filter}'
    ${output}    csn.execute    command=${command}    connection=${alias}
    csn.disconnect    connection=${alias}
    [Return]    ${output}
