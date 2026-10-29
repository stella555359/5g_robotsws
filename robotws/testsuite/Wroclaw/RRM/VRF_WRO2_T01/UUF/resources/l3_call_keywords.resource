***Settings***
Documentation
...  Set of L3 Call Keywords for UUF testing. Keywords should be used as UUF's l3 call keyword parameter.

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/l3_call_keywords.resource

***Variables***
@{ues}  ue_1

***Keywords***
Attach Detach Loop
    [Documentation]  Keyword performs attached and dettaches in loop.
    [Arguments]  @{cells_list}  ${loop_count}=10
    
    log to console  Attach/Detach loop has started
    FOR  ${i}  IN RANGE  1  ${loop_count}
        log to console  Loop: ${i}
        detach ues from cell  ${ues}
        sleep  5s
        attach ues to cell  ${ues}
    END

    [Teardown]
    ...    run keyword and ignore error  detach ues from cell  ${ues}

L3Call Loop
    [Documentation]  Keyword performs l3call with ul+dl in loop.
    [Arguments]  @{cells_list}  ${loop_count}=5  ${step_duration}=60s

    Log to console  L3Call ul+dl loop has started
    FOR  ${i}  IN RANGE  1  ${loop_count}
        Log to console  Loop: ${i}
        detach ues from cell  ${ues}
        sleep  5s
        attach ues to cell  ${ues}
        Start ULDL for UEs  ${ues}  duration=${step_duration}
        Await datatransfers finish
        Stop all datatransfers
    END

    [Teardown]  run keywords
    ...  run keyword and ignore error  Stop all datatransfers  AND
    ...  run keyword and ignore error  detach ues from cell  ${ues}
