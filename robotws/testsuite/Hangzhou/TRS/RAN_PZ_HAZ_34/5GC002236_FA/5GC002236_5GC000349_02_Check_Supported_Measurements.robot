# #*** Settings ***
# #Force Tags    PY36
# #Documentation
# #...   author: zheyuan.chen@nokia-sbell.com
# #...   contact: zheyuan.chen@nokia-sbell.com
# #
# #Suite Setup       Suite Setup
# #Suite Teardown    Suite Teardown
# #
# #Resource    resources/trans_comm.robot
# #Resource    resources/trans_pm.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #
# #*** Variable ***
# #@{transport_counters}    M51300C1    M51352C0    M51301C0    M51322C0    M51321C0    M51324C0    M51302C0
# #@{TCPcounter_id}    M51325C0    M51325C1    M51325C2    M51325C3
# #
# #*** Test Cases ***
# #[1]5GC002236_5GC000349_02_Check_Supported_Measurements
# #    [Documentation]
# #    ...    This test case is used to test product shall support TCP_UDP statistics
# #    ...    -26.10.2020,zheyuan.chen@nokia-sbell.com,case draft
# #    [Tags]    CRT_20B    5GC002236_349
# #    [Setup]
# #    Step1: Check BTS Should Be Normal
# #    Change Counter Generation to 5min
# #    Check Counter Function In Navigation Panel
# #    Check PM Counter In TCP/UDP
# #    [Teardown]    CI_interface.Common Case Teardown
# #
# #
# #*** Keywords ***
# #Check Counter Function In Navigation Panel
# #    Log To Console    Check Counter Function In Navigation Panel
# #    WEBUI Login
# #    FOR    ${items}    IN    @{transport_counters}
# #         ${transport_counters_dict}    selenium_coam.get_transport_counters    counter_id=${items}
# #         ${values}    get dictionary values    ${transport_counters_dict}
# #         should not be empty    ${values}
# #    END
# #    [Teardown]    WEBUI Logout
# #
# #Check PM Counter In TCP/UDP
# #    Log To Console    Check PM Counter In TCP/UDP
# #    WEBUI Login
# #    FOR    ${item}    IN    @{TCPcounter_id}
# #         ${counter_dict}    selenium_coam.get_transport_counters    counter_id=${item}
# #         ${values}    get dictionary values    ${counter_dict}
# #         should be true    int(@{values}[-1]) > 0
# #    END
# #    sleep    10min
# #    FOR    ${item}    IN    @{TCPcounter_id}
# #         ${counter_dict}    selenium_coam.get_transport_counters    counter_id=${item}
# #         ${values}    get dictionary values    ${counter_dict}
# #         should be true    int(@{values}[-1]) > 0
# #    END
# #    [Teardown]    WEBUI Logout
# #
# #Suite Setup
# #    TRANS Common Setup
# #    ${PM_FILE_LOCATION}   Set Variable  ${DU_PM_FILE_LOCATION}
# #    Set Suite Variable  ${PM_FILE_LOCATION}
# #    ${PM_FILE_PATTERN}   Set Variable  ${DU_PM_FILE_PATTERN}
# #    Set Suite Variable  ${PM_FILE_PATTERN}
# #
# #Suite Teardown
# #    TRANS Common Teardown