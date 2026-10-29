*** Settings ***
Documentation     author: Meng Yan
#...               contact: meng.yan@nokia-sbell.com
...               squad group: 5G_PZ_MMW_HZ_2_SG
Library            OperatingSystem
Library           taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variable ***
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

*** Keywords ***
Connect to ABIO
    csn.connect_to    hostname=${CU_addr}    username=${CU_username}    password=${CU_password}    alias=ABIO

Trigger loki A auto reset
    Connect to ABIO
    ${pidinfo}   csn.Execute
    ...           command=bsh 1:1 ps aux|grep l1_application_nrt|grep -v grep | awk '{print $2}'
    ...           connection=ABIO
    ${pidinfo}    Strip string    ${pidinfo}
    ${status}=    csn.Execute    command=bsh 1:1 kill -11 ${pidinfo}    connection=ABIO
    should be empty    ${status}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

Trigger loki A reset by OAM
    Connect to ABIO
    ${routeinfo}   csn.Execute
    ...           command=bsh 1:1 syscomctl routing list|grep -v grep | awk '{print $1}'
    ...           connection=ABIO
    ${routeinfo}=    Split string    ${routeinfo}   separator=\r\n
    FOR    ${route}    IN    @{routeinfo}
        ${matchdata}    Get Regexp Matches    ${route}    [0-9]+    0
        Run Keyword if    ${matchdata}
        ...    csn.Execute    command=bsh 1:1 syscomctl routing remove ${route}    connection=ABIO
    END
    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

Trigger loki A reset by BTS-OAM
    Connect to ABIO
     ${pidinfo}   csn.Execute
    ...           command=bsh 1:1 ps aux|grep sfp.py|grep -v grep | awk '{print $2}'
    ...           connection=ABIO
    ${pidinfo}    Strip string    ${pidinfo}
    ${status}=    csn.Execute    command=bsh 1:1 kill -11 ${pidinfo}    connection=ABIO
    should be empty    ${status}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

trigger fault report after bts reset
    Connect to ABIO
    ${pidinfo}    csn.Execute
    ...           command=ps aux | grep "FRI" | grep -v grep | awk '{print $2}'
    ...           connection=ABIO
    ${pidinfo}    Strip string    ${pidinfo}
    ${status}=    csn.Execute    command=kill -11 ${pidinfo}    connection=ABIO
    should be empty    ${status}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

Trigger CPUE auto reset
   Connect to ABIO
   ${pidinfo}   csn.Execute
   ...           command=bsh 1:0 lxc-attach -n 0x1734 -- pkill -11 -f '/opt/CCS/CCSDaemonExe' 
   ...           connection=ABIO
   Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

Trigger UPUE auto reset
    Connect to ABIO
    ${pidinfo}   csn.Execute
    ...           command=bsh 1:0 lxc-attach -n 0x1731 -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'
    ...           connection=ABIO
    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

Trigger L2RT auto reset
    Connect to ABIO
    ${pidinfo}   csn.Execute
    ...           command=bsh 1:0 lxc-attach -n 0x1730 -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'
    ...           connection=ABIO
    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO

#*****the follow trigger way exists PR*****
#Trigger CPUE auto reset
   # Connect to ABIO
    #${pidinfo}   csn.Execute
    #...           command=bsh 1:0 systemctl stop hwr-container@CPUE20.service
   # ...           connection=ABIO
   # Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO


#Trigger UPUE auto reset
    #Connect to ABIO
    #${pidinfo}   csn.Execute
    #...           command=bsh 1:0 systemctl stop hwr-container@UPUE20.service
    #...           connection=ABIO
    #Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO


#Trigger L2RT auto reset
    #Connect to ABIO
    #${pidinfo}   csn.Execute
    #...           command=bsh 1:0 systemctl stop hwr-container@L2RT20.service
    #...           connection=ABIO
    #Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#********************************************************************

Check certain alarm raised
    [Arguments]    ${fault_id}
    @{res}    coam.get_active_alarms    connection=GNB_OAM
    FOR    ${i}    IN    @{res}
        ${Found_faultid}    set variable if    '${i['faultId']}' == '${fault_id}'    ${True}    ${False}
        exit for loop if    '${i['faultId']}' == '${fault_id}'
    END
    should be true    ${Found_faultid} == ${True}

Check history alarm raised
    [Arguments]    ${fault_id}
    @{res}    coam.get_historic_alarms    connection=GNB_OAM
    FOR    ${i}    IN    @{res}
        ${Found_faultid}    set variable if    '${i['faultId']}' == '${fault_id}'    ${True}    ${False}
        exit for loop if    '${i['faultId']}' == '${fault_id}'
    END
    should be true    ${Found_faultid} == ${True}

Check certain alarm raised by faultId and faultName
  [Arguments]    ${fault_id}    ${fault_Name}
    @{res}    coam.get_active_alarms    connection=GNB_OAM
    FOR    ${i}    IN    @{res}
        ${Found_faultid}    set variable if    '${i['faultId']}' == '${fault_id}'    ${True}    ${False}
        ${Found_faultName}    set variable if    '${i['faultName']}' == '${fault_Name}'  ${True}    ${False}
        Run keyword if    ${Found_faultid} == ${True}     exit for loop if    ${Found_faultName} == ${True}
    END
    should be true    ${Found_faultid} == ${True}
    should be true    ${Found_faultName} == ${True}

All cells in specified cell group should be onair
    [Arguments]    ${cell_group}  ${connection}=GNB_OAM
    Log to console    Verify all cells are on air
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
    All cells in cell group should be onair    ${cell_from_cellgrp}

All cells in specified cell group should be not_onair
    [Arguments]    ${cell_group}  ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}     ${unlocked}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}   ${disabled}
    END

#All cells in cell group should be not_onair
#    [Documentation]    Author:
#    [Arguments]   ${cell_from_cellgrp}
#    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
#    FOR  ${cell}  IN   @{cell_list}
#        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
#        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}     unlocked
#        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}   disabled
#    END

L1 5G Loki A reset on critical failure
    Trigger loki A auto reset
    Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=2087
    Check_Cell_on_lokiA_not_onair
    Check_Cell_on_lokiB_onair
    Sleep     120s
    Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair  ##about 3~5min

Capacity_core unit 5G L3 SW reset on critical failure
    Trigger CPUE auto reset
    Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=4383
    Check_Cell_on_lokiA_onair
    Check_Cell_on_lokiB_onair
    Sleep     120s
    Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair  ##about 3~5min

Capacity_core unit 5G L2 NRT SW reset on critical failure
    Trigger UPUE auto reset
    Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=4383
    Check_Cell_on_lokiA_onair
    Check_Cell_on_lokiB_onair
    Sleep     120s
    Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair  ##about 3~5min

Capacity_core unit 5G L2 RT SW reset on critical failure
    Trigger L2RT auto reset
    Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=4383
    Check_Cell_on_lokiA_not_onair
    Check_Cell_on_lokiB_onair
    Sleep     120s
    Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair  ##about 3~5min
    

