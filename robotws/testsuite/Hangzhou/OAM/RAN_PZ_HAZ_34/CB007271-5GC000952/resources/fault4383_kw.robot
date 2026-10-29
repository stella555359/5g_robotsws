*** Settings ***
Library     Collections
Library     String
Library     OperatingSystem
Library   taf.transport.ssh   WITH NAME   csn
Library     taf.sbts.oam.coam.admin   WITH NAME   sbts
Library     counter_ops.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot


*** Variables ***
${proc1}    /opt/CCS/CCSDaemonExe

*** Keywords ***
Fault 4383 load counter SMOD
    [Arguments]  ${count}=3
    FOR    ${INDEX}  IN RANGE    0   ${count}
       log to console  activating and deactivating Fault with Alarm for the ${INDEX} time
       Fault 4383 cycle SMOD
    END

Fault 4383 cycle SMOD
   ${virtual_node}=     Check where proc is located
   log to console    ${virtual_node}
   log to console   starting Fault 4383 cycle
   Connect Ssh To Asix
   Virtual Node Should Be Available     ${virtual_node}      connection=asix
   Process On Virtual Node Should Be Running ASIX  ${proc1}   ${virtual_node}     connection=asix
   Kill Process On Virtual Node ASIX    ${virtual_node}
   sleep   1min
#   run keyword unless  '${gnb_release}' == 'SBTS22R3'    Kill Process On Virtual Node ASIX    0x1511
   wait until keyword succeeds   10min      10s    Fault With Alarm Should Be Present   FaultID=4383     AlarmID=7101
   wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
   wait until keyword succeeds  1000      5    Fault With Alarm Should Not Be Present    FaultID=4383   AlarmID=7101
   log to console  Fault 4383 cycle done
   [Teardown]  Disconnect Ssh From Asix

Fault 4383 4th SMOD
   ${virtual_node}=     Check where proc is located
   log to console    ${virtual_node}
   log to console   starting trigger Fault 4383
   Connect Ssh To Asix
   Virtual Node Should Be Available     ${virtual_node}      connection=asix
   Process On Virtual Node Should Be Running ASIX  ${proc1}   ${virtual_node}     connection=asix
   Kill Process On Virtual Node ASIX    ${virtual_node}
   sleep   1min
#   run keyword unless  '${gnb_release}' == 'SBTS22R3'    Kill Process On Virtual Node ASIX    0x1511
   wait until keyword succeeds    10min      10s   Fault With Alarm Should Be Present   FaultID=4383     AlarmID=7101
   log to console  Fault 4383 cycle done
   [Teardown]  Disconnect Ssh From Asix

Check where proc is located
    Connect Ssh To Asix
    ${virtual_nodes}    csn.Execute    command=lxc-ls    connection=asix
    @{virtual_nodes_list}=    Get regexp matches   ${virtual_nodes}    0x151[012345]
    FOR    ${virtual_node}  IN    @{virtual_nodes_list}
        ${current_virtual_node}=   set variable    ${virtual_node}
        csn.Send command    command=lxc-attach -n ${virtual_node} -- ps aux    connection=asix
        ${processes}=    csn.Read Output    connection=asix
        ${status}=    run keyword and return status    should match regexp    ${processes}    ${proc1}
        exit for loop if   '${status}'=='True'
    END
    [Return]  ${current_virtual_node}
   [Teardown]  Disconnect Ssh From Asix

Virtual Node Should Be Available
    [Arguments]
    ...    ${virtual_node}
    ...    ${connection_ssh}=asik
    ${list_VNs}    Get Virtual Nodes
    @{list_VNs_list}    Split String    ${list_VNs}    ${SPACE}
    collections.List Should Contain Value    ${list_VNs_list}    ${virtual_node}

Get Virtual Nodes
    ${virtual_nodes}    csn.Execute    command=lxc-ls    connection=asix
    [Return]    ${virtual_nodes}

Get Processes From Virtual Node ASIX
    [Arguments]
    ...    ${virtual_node}=0x1510
    ...    ${connection_ssh}=asik
    csn.Send command    command=lxc-attach -n ${virtual_node} -- ps aux    connection=asix
    ${VN_processes}    csn.Read Output    connection=asix
    [Return]    ${VN_processes}

Process On Virtual Node Should Be Running ASIX
    [Arguments]
    ...    ${process_command}
    ...    ${vn_address}=0x1510
    ...    ${connection_ssh}=asix

    ${VN_processes}    Get Processes From Virtual Node ASIX    ${vn_address}    connection_ssh=asik
    ${process}      string.Get Lines Matching Pattern   ${VN_processes}      *${proc1}*
    Should Not Be Empty    ${process}
    Extract PID from process    ${process}

Kill Process On Virtual Node ASIX
    [Arguments]
    ...    ${vn_address}=0x1510
    ...    ${connection_ssh}=asix
    ...    ${pid}=${pid}
    csn.Execute    command=lxc-attach -n ${vn_address} -- kill -9 ${pid}    connection=${connection_ssh}

Extract PID from process
    [Arguments]
    ...     ${process}
    ${strip1}  fetch from left    ${process}      0.
    ${strip2}  remove string   ${strip1}   root
    ${pid}  strip string    ${strip2}
    set test variable  ${pid}