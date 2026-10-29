*** Settings ***
Documentation
...    Module files

*** Keywords ***
L3 Call with traffic
    [Arguments]    ${acceptable_tput_percentage}=0.7    &{kwargs}
    ${serialno}      Get From Dictionary     ${kwargs}    serialno
    ${pci}          Get From Dictionary     ${kwargs}    pci
    ${ul_tput}      Get From Dictionary     ${kwargs}    ul_tput
    ${dl_tput}      Get From Dictionary     ${kwargs}    dl_tput
    ${ul_port}      Get From Dictionary     ${kwargs}    ul_port
    ${dl_port}      Get From Dictionary     ${kwargs}    dl_port
    ${duration}      Get From Dictionary     ${kwargs}    duration
    ${remote_status}    Run keyword And Return Status    Dictionary Should Contain Key    ${kwargs}    remote_hostname
    ${remote_hostname}    Run Keyword If    ${remote_status}    Get From Dictionary     ${kwargs}    remote_hostname
    ...    ELSE    Set Variable    ${EMPTY}
    ${remote_username}    Run Keyword If    ${remote_status}    Get From Dictionary     ${kwargs}    remote_username
    ...    ELSE    Set Variable    ${EMPTY}
    ${remote_password}    Run Keyword If    ${remote_status}    Get From Dictionary     ${kwargs}    remote_password
    ...    ELSE    Set Variable    ${EMPTY}
    ${status}    Run keyword And Return Status    Dictionary Should Contain Key    ${kwargs}    reset_sol
    ${reset_sol}      Run Keyword If    ${status}    Get From Dictionary     ${kwargs}    reset_sol
    ...    ELSE    Set Variable    ${False}
    Run Keyword If    '${reset_sol}'=='${True}'    Commercial UE Operation    reboot    serialno=${serialno}
    Commercial UE Operation    attach    serialno=${serialno}    expected_pci=${pci}    forced=${True}
    ${ul_bandwidth}    Evaluate    ${ul_tput}+20
    ${dl_bandwidth}    Evaluate    ${dl_tput}+20
    ${traffic_duration}    Evaluate    ${duration}+120
    Commercial UE Operation    start traffic    serialno=${serialno}
    ...  IperfOptions=-u -i 1 -t ${traffic_duration} -b ${dl_bandwidth}M -p ${dl_port} -l 1400  direction=dl
    ...  remote_hostname=${remote_hostname}   remote_username=${remote_username}    remote_password=${remote_password}
    Commercial UE Operation    start traffic    serialno=${serialno}
    ...  IperfOptions=-u -i 1 -t ${traffic_duration} -b ${ul_bandwidth}M -p ${ul_port} -l 1400  direction=ul
    ...  remote_hostname=${remote_hostname}   remote_username=${remote_username}    remote_password=${remote_password}
    sleep    ${duration}s
    ${real_ultput}=    Commercial UE Operation    get    serialno=${serialno}  item=ultput
    ${real_dltput}=    Commercial UE Operation    get    serialno=${serialno}  item=dltput
    ${check_ul}    Evaluate    ${ul_tput} * ${acceptable_tput_percentage}
    ${check_dl}    Evaluate    ${dl_tput} * ${acceptable_tput_percentage}
    Should Be True    ${real_ultput} > ${check_ul}
    Should Be True    ${real_dltput} > ${check_dl}
    [Teardown]    Run Keywords    Run Keyword And Continue On Failure
    ...  Commercial UE Operation    stop traffic    serialno=${serialno}
    ...  IperfOptions=-u -i 1 -t ${traffic_duration} -b ${dl_bandwidth}M -p ${dl_port}    direction=dl
    ...  remote_hostname=${remote_hostname}   remote_username=${remote_username}    remote_password=${remote_password}
    ...  AND    Run Keyword And Continue On Failure
    ...  Commercial UE Operation    stop traffic    serialno=${serialno}
    ...  IperfOptions=-u -i 1 -t ${traffic_duration} -b ${ul_bandwidth}M -p ${ul_port}    direction=ul
    ...  remote_hostname=${remote_hostname}   remote_username=${remote_username}    remote_password=${remote_password}
    ...  AND    Commercial UE Operation    detach    serialno=${serialno}
