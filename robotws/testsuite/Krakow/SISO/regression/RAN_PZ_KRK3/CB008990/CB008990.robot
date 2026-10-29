*** Settings ***
Documentation    CB008990
...              authors: Lukasz Rzodeczko, Szymon Laba
...              maintainer: Szymon Laba
...              contact: szymon.laba@nokia.com
...              The purpose of test suite is test RU faults 1904 and 1907 on RF6.1 (eScorpio) family

Library          testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB008990.resources.resources.RuFaults
Resource         taf/rfrl/bts/robot/gnb.robot
Resource         taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource         taf/rfrl/ue/robot/REAL_UE.robot
Variables        taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown                 Common Suite Teardown

Test Setup                     Common Preconditions With Watching Alarms
Test Teardown                  Common Postconditions With Watching Alarms


*** Variables ***
&{array_carrie_ant_dfe1}       NR79090.TX_3_1000_3549=antenna1a
...                            NR79090.TX_4_1000_3549=antenna2a
...                            NR79090.TX_3_1000_34515=antenna1a
...                            NR79090.TX_4_1000_34515=antenna2a

&{array_carrie_ant_dfe2}       NR79090.TX_7_1000_3549=antenna5a
...                            NR79090.TX_8_1000_3549=antenna6a
...                            NR79090.TX_7_1000_34515=antenna5a
...                            NR79090.TX_8_1000_34515=antenna6a

${dfe1_ip}                     192.168.101.2
${dfe2_ip}                     192.168.101.3
${number_of_iteration}         1

*** Test Cases ***

[1][1.0] 2_DFE no TX Data fault activation
    FOR    ${index}    IN RANGE    ${number_of_iteration}
        Wait 300s to stabilze after startup
        ${dfe}    Generate random string    1    12
        Check_if_fault_1907_appeared    dfe_ip=${dfe${dfe}_ip}   carrier_ant_dict=&{array_carrie_ant_dfe${dfe}}  randomize_tx=False
        ...   iteration_number=${index}
    END
    Require Ue   ue_alias=Smawave    capabilities=Smawave
    Attach Ue    Smawave
    Start Data Transfer    DT_1    Smawave    UL    protocol=udp    throughput=170Mbits/sec    packet=1400B
    Sleep    30s    reason=To stabilize data transfer
    Stop Data Transfer    DT_1
    Detach Ue    Smawave

[1][1.0] 1_DFE-Beamer link fault activation
    FOR    ${index}    IN RANGE    ${number_of_iteration}
        Wait 300s to stabilze after startup
        ${dfe}    Generate random string    1    12
        Check_if_fault_1904_appeared    interface=arb0p${dfe}     iteration_number=${index}
    END
    Require Ue   ue_alias=Smawave    capabilities=Smawave
    Attach Ue    Smawave
    Start Data Transfer    DT_1    Smawave    UL    protocol=udp    throughput=170Mbits/sec    packet=1400B
    Sleep    30s    reason=To stabilize data transfer
    Stop Data Transfer    DT_1
    Detach Ue    Smawave

*** Keywords ***
Wait ${time}s to stabilze after startup
    Sleep    ${time}    reason=To stabilize after startup
