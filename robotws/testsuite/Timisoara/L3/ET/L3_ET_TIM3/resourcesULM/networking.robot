*** Settings ***

Documentation   This resource file provides keywords to wait until a network element
...             is or becomes (un-)reachable within a period of time.


*** Keywords ***
Wait Until Ping Failed
    [Arguments]    ${ip_addr}=${None}  ${iterations}=${30}  ${ping_count}=${2}  ${ping_deadline}=${4}  ${interval}=${1}
    [Documentation]
    ...
    ...     This KW is a wrapper around linux ping command.
    ...     It waits based on the given arguments until the ``ip_addr`` becomes unreachable.
    ...     Therefore the KW calls the ping command ``iterations`` times with argument -c (``ping_count``),
    ...     -w (``ping_deadline``) and -i (``interval``) and checks the exit code.
    ...     The KW fails if the network element is still reachable.
    ...
    ...     For detailled information about the used ping options check the ping man page.
    ...
    FOR     ${iter}     IN RANGE    ${iterations}
        ${rc}=    Run and return rc    ping ${ip_addr} -c ${ping_count} -w ${ping_deadline} -i ${interval}
        Exit For Loop If    ${rc}>0
    END
    Should Not Be Equal As Integers     ${iter+1}     ${iterations}     values=${False}
    ...     msg=Ping didn't fail within expected deadline/repetitions


Wait Until Ping Succeeds
    [Arguments]    ${ip_addr}=${None}  ${iterations}=${10}  ${ping_count}=${2}  ${ping_deadline}=${4}  ${interval}=${1}
    [Documentation]
    ...
    ...     This KW is a wrapper around linux ping command.
    ...     It waits based on the given arguments until the ``ip_addr`` becomes reachable.
    ...     Therefore the KW calls the ping command ``iterations`` times with argument -c (``ping_count``),
    ...     -w (``ping_deadline``) and -i (``interval``) and checks the exit code.
    ...     The KW fails if the network element is still unreachable.
    ...
    ...     For detailled information about the used ping options check the ping man page.
    ...
    FOR     ${iter}     IN RANGE    ${iterations}
        ${rc}=    Run and return rc    ping ${ip_addr} -c ${ping_count} -w ${ping_deadline} -i ${interval}
        Exit For Loop If    ${rc}==0
    END
    Should Not Be Equal As Integers     ${iter+1}     ${iterations}     values=${False}
    ...     msg=Ping deadline expired or until count probes are answered or some error notification from network occur

