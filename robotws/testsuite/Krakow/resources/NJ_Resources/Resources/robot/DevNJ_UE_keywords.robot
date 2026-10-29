*** Settings ***
Documentation
...    author: Min Dai
...    contact: min.b.dai@nokia-sbell.com
...    DevNJ UE keywords for SMAWave, Android UE
...    Pilot Cases: testsuite/Nanjing/OAM/Pilot/Pilot_DevNJ_UE_test.robot

Library    taf.ue
Library    taf.transport.ssh
Library    testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_UE.interface.CommonUeInterface  WITH NAME  DevNJ_UE_KW

*** Variables ***
${ADBLogFlag}    True


*** Keywords ***
Set UE Variables
    [Documentation]  This keyword used to setup UE varaibles which loaded from the testline configuration file ue_config.yaml
    ...    !!! Not recommended KW, this KW is reserved for legacy features only, please do not use this KW in new features.
    DevNJ_UE_KW.Set UE Variables

Reboot UEs
    [Documentation]  This keyword used to perform reboot UE operations.
    ...    ue_index :  ue identifier index
    ...
    ...    Example : Reboot UEs  1
    [Tags]    SMAWave    Android
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.Reboot UEs    ${ue_index}

UE Attach Only
    [Documentation]  Normally this keyword is ONLY used for abnormal UE to perform additional attach operation.
    ...    !!! Not recommended KW, this KW is reserved for legacy features only
    ...    Recommend to use 'UE attach and Start ADB Log' to perform attach for regular scenario.
    ...    Please refer to the Pilot case TC04 and TC09 for attach only cases
    ...    ue_index :  ue identifier index
    ...
    ...    Example : UE Attach Only  1
    [Tags]    SMAWave    Android
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.UE Attach Only    ${ue_index}

UE Detach Only
    [Documentation]  Normally this keyword is ONLY used for abnormal UE to perform additional detach operation.
    ...    !!! Not recommended KW, this KW is reserved for legacy features only
    ...    Recommend to use 'Postconditions_ForUE' which detach is included to do UE teardown operation.
    ...    Please refer to the Pilot case TC04 and TC09 for attach only cases
    ...    ue_index :  ue identifier index
    ...
    ...    Example : UE Detach Only  1
    [Tags]    SMAWave    Android
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.UE Detach Only    ${ue_index}

Attach All UEs
    [Documentation]  This keyword used to perform all UE attach operation.
    ...    !!! Not recommended KW, this KW is reserved for legacy features only
    ...    Recommend to use 'UE attach and Start ADB Log' to perform attach for regular scenario.
    ...    Please refer to the Pilot case TC04 and TC09 for attach only cases
    [Tags]    SMAWave    Android
    DevNJ_UE_KW.Attach All UEs

Detach All UEs
    [Documentation]  This keyword used to perform all UE detach operation.
    ...    !!! Not recommended KW, this KW is reserved for legacy features only
    ...    Recommend to use 'Postconditions_ForUE' which detach is included to do UE teardown operation.
    ...    Please refer to the Pilot case TC04 and TC09 for attach only cases
    [Tags]    SMAWave    Android
    DevNJ_UE_KW.Detach All UEs

UE Attach And Start ADB Log
    [Documentation]  This keyword used to perform UE attach operations.
    ...    Note: ADB log for Android is not supported in Drop22, related functions will deliver in the future.
    ...    ue_index :  ue identifier index
    ...
    ...    Example : UE Attach And Start ADB Log  1
    [Tags]    SMAWave    Android
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.UE Attach And Start ADB Log    ${ue_index}

Start and Verify Downlink TCP
    [Documentation]  This keyword used to perform and verify TCP downlink data traffic
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : dl
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Downlink TCP    dl_test  1  dl  120s  80M  tcp  70M  20%
    [Tags]    SMAWave
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}
    DevNJ_UE_KW.Start and Verify Downlink TCP  ${dt_name}  ${ue_index}  ${direction}  ${duration}  ${iperf_throughput}
    ...    ${protocol}  ${dl_expect_tput}  ${dl_deviation}

Start and Verify Uplink TCP
    [Documentation]  This keyword used to perform and verify TCP uplink data traffic
    ...    dt_name : name to be assigned to dats transfer, for compatible with Android, not used for SMAwave
    ...    ue_index : UE identifier index
    ...    direction : ul
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Uplink TCP    ul_test  1  ul  120s  30M  tcp  25M  20%
    [Tags]    SMAWave
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}
    DevNJ_UE_KW.Start and Verify Uplink TCP  ${dt_name}  ${ue_index}  ${direction}  ${duration}  ${iperf_ul_throughput}
    ...    ${protocol}  ${ul_expect_tput}  ${ul_deviation}

Start and Verify Downlink UDP
    [Documentation]  This keyword used to perform and verify UDP downlink data transfer.
    ...    dt_name : name to be assigned to dats transfer
    ...    ue_index : UE identifier index
    ...    direction : dl
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp or udp
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Downlink UDP   dl_test  1  dl  120s  80M  udp  70M  20%
    [Tags]    SMAWave    Android
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}
    DevNJ_UE_KW.Start and Verify Downlink UDP    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_throughput}
    ...    ${protocol}    ${dl_expect_tput}    ${dl_deviation}

Start and Verify Uplink UDP
    [Documentation]  This keyword used to perform and verify UDP uplink data traffic.
    ...    dt_name : name to be assigned to dats transfer
    ...    ue_index : UE identifier index
    ...    direction : ul
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    protocol : tcp or udp
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Start and Verify Uplink UDP  ul_test  1  ul  120s  30M  udp  25M  20%
    [Tags]    SMAWave    Android
    [Arguments]
    ...    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}
    DevNJ_UE_KW.Start and Verify Uplink UDP    ${dt_name}    ${ue_index}    ${direction}    ${duration}    ${iperf_ul_throughput}
    ...    ${protocol}    ${ul_expect_tput}    ${ul_deviation}

Reserve UEs
    [Documentation]  Note: This keyword is only used for Android UE for reserve the UE.
    ...    This KW replaces legacy KW "Reserve All Android UEs"
    ...
    ...    Example : Reserve UEs
    [Tags]    Android
    DevNJ_UE_KW.Reserve UEs

Verify 5G Success And Stop ADB Log
    [Documentation]  This keyword used to stop ADB log, and verify attached 5G cell result via ADB log.
    ...    Note: This KW is always used after the KW "UE Attach And Start ADB Log".
    ...    ue_index : UE index identifier
    ...    lte_cell_index : the cell index which UE attach to
    ...
    ...    Example : Verify 5G success and stop ADB log    ue_index=1    lte_cell_index=1
    [Tags]    Android
    [Arguments]    ${ue_index}    ${lte_cell_index}
    ${result}    DevNJ_UE_KW.Verify 5G success and stop ADB log    ${ue_index}    ${lte_cell_index}
    [Return]    ${result}

Stop ADB Log
    [Documentation]  This keyword used to stop ADB log for all UEs.
    ...    Note: This KW is always used after the KW "UE Attach And Start ADB Log".
    ...
    ...    Example : Stop ADB Log
    [Tags]    Android
    ${result}    DevNJ_UE_KW.Stop ADB Log

Postconditions_ForUE
    [Documentation]  This keyword is to perform SMAWave and Android UE teardown operation.
    ...    It must be called in Teardown section of test case.
    ...
    ...    Example : Postconditions_ForUE
    [Tags]    SMAWave    Android
    DevNJ_UE_KW.Postconditions_ForUE

Start DL Async Process
    [Documentation]    This keyword used to start DL Async process for some specific OAM operation, FOR USER USAGE.
    ...    when data transfer is also ongoing.
    ...    NOTE: Remember to call Postconditions_ForUE do teardown at end of each TC, when you use this KW to start call process.
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M(SMAWave), 800Mbits/sec(Mbits/sec is mandatory for Android UE)
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Start DL Async Process  1  80M  120s
    ...    Example-2 : Start DL Async Process  1  80M  120s  tcp
    ...    Example-3 : Start DL Async Process  1  80M  120s  tcp  downlink_test
    [Tags]    SMAWave    Android
    [Arguments]    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}=udp    ${data_trans_name}=dl_test
    DevNJ_UE_KW.Start DL Async Process    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}    ${data_trans_name}

Start UL Async Process
    [Documentation]    This keyword used to start UL Async process for some specific OAM operation, FOR USER USAGE.
    ...    when data transfer is also ongoing.
    ...    NOTE:Remember to call Postconditions_ForUE do teardown at end of each TC, when you use this KW to start call process.
    ...    index : UE identifier index
    ...    T-Put : desired data transfer throughput, format should be e.g 80M(SMAWave), 800Mbits/sec(Mbits/sec is mandatory for Android UE)
    ...    Tput_dura : data transfer duration in robot time string format
    ...    protocol : tcp or udp
    ...    data_trans_name : data transfer name for android UE
    ...
    ...    Example-1 : Start UL Async Process  1  30M  180s
    ...    Example-2 : Start UL Async Process  1  30M  180s  tcp
    ...    Example-3 : Start UL Async Process  1  30M  180s  tcp  uplink_test
    [Tags]    SMAWave    Android
    [Arguments]    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}=udp    ${data_trans_name}=ul_test
    DevNJ_UE_KW.Start UL Async Process    ${index}    ${T-Put}    ${Tput_dura}    ${protocol}    ${data_trans_name}

Calculate and Verify DL Async Tput
    [Documentation]  This keyword used to calculate and verify Async DL T-Put with deviation, FOR USER USAGE.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...                  format should be e.g 80M(SMAWave), 800Mbits/sec(Mbits/sec is mandatory for Android UE)
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion,android ue not used.
    ...    data_trans_name : data transfer name for android UE
    ...    protocol : tcp or udp
    ...
    ...    Example-1 : Calculate and Verify DL Async Tput  1  180M  30%  120s
    ...    Example-2 : Calculate and Verify DL Async Tput  1  180M  30%  120s  downlink_test
    [Tags]    SMAWave    Android
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${data_trans_name}=dl_test    ${protocol}=udp
    DevNJ_UE_KW.Calculate and Verify DL Async Tput    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${data_trans_name}    ${protocol}

Calculate and Verify UL Async Tput
    [Documentation]  This keyword used to calculate and verify Async UL T-Put with deviation, FOR USER USAGE.
    ...    index : UE identifier index
    ...    expect_tput : desired average data transfer throughput
    ...                  format should be e.g 80M(SMAWave), 800Mbits/sec(Mbits/sec is mandatory for Android UE)
    ...    deviation : acceptable deviation, format should be similar to 20%
    ...    Tput_dura : time interval which will be used for smawave waiting the async process completion,android ue not used.
    ...    data_trans_name : data transfer name for android UE
    ...    protocol : tcp or udp
    ...
    ...    Example-1 : Calculate and Verify UL Async Tput  1  30M  20%  120s
    ...    Example-2 : Calculate and Verify UL Async Tput  1  180M  30%  120s  uplink_test
    [Tags]    SMAWave    Android
    [Arguments]    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${data_trans_name}=ul_test    ${protocol}=udp
    DevNJ_UE_KW.Calculate and Verify UL Async Tput    ${index}    ${expect_tput}    ${deviation}    ${Tput_dura}    ${data_trans_name}    ${protocol}

Is Exception UE
    [Documentation]  check UE type by ADB device type
    ...    :param ue_index
    ...
    ...    Example : Is Exception UE    ue_index=1
    [Tags]    Android
    [Arguments]    ${ue_index}
    ${isExceptionUE}    DevNJ_UE_KW.Is Exception UE    ${ue_index}
    [Return]    ${isExceptionUE}

Android DL Traffic with CMD
    [Documentation]  This keyword used to perform and verify Android UE UDP downlink data transfer without UE Manager
    ...    ue_index : ue index
    ...    duration : data transfer duration in robot time string format
    ...    iperf_throughput : desired data transfer throughput, format should be e.g 80M
    ...    dl_expect_tput : desired average data transfer throughput
    ...    dl_deviation : acceptable deviation, format should be similar to 20%
    ...    window_size : window size foe cmd, default is 20M
    ...
    ...    Example : Android DL Traffic with CMD  1  120s  80M  70M  20%
    [Tags]    Android
    [Arguments]
    ...    ${ue_index}    ${duration}    ${iperf_throughput}
    ...    ${dl_expect_tput}    ${dl_deviation}    ${window_size}=20m
    DevNJ_UE_KW.Android DL Traffic with CMD    ${ue_index}    ${duration}    ${iperf_throughput}
    ...    ${dl_expect_tput}    ${dl_deviation}    ${window_size}=20m

Android UL Traffic with CMD
    [Documentation]  This keyword used to perform and verify Android UE UDP uplink data transfer without UE Manager
    ...    ue_index : ue index
    ...    duration : data transfer duration in robot time string format
    ...    iperf_ul_throughput : desired data transfer throughput, format should be e.g 80M
    ...    ul_expect_tput : desired average data transfer throughput
    ...    ul_deviation : acceptable deviation, format should be similar to 20%
    ...
    ...    Example : Android UL Traffic with CMD  1  120s  30M  25M  20%
    [Tags]    Android
    [Arguments]
    ...    ${ue_index}    ${duration}    ${iperf_ul_throughput}
    ...    ${ul_expect_tput}    ${ul_deviation}
    DevNJ_UE_KW.Android UL Traffic with CMD    ${ue_index}    ${duration}    ${iperf_ul_throughput}
    ...    ${ul_expect_tput}    ${ul_deviation}

Get Frequency Locking Information
    [Documentation]  This keyword used to get the currently locked frequency.
    ...    Returned locked frequency: {'4G': {'xfcn': '1650', 'pci': '310'}, '5G': {'xfcn': '636200', 'scs': '1'}}
    ...    No frequency locked: {'4G': None, '5G': None}
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    [Tags]    SMAWave
    [Arguments]    ${ue_index}
    ${result}    DevNJ_UE_KW.Get Frequency Locking Information    ${ue_index}
    [Return]    ${result}

Lock 4G or 5G Frequency
    [Documentation]
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    [Tags]    SMAWave
    [Arguments]    ${ue_index}  ${tech}  ${xfcn}  ${4g_pci_or_5g_scs}
    DevNJ_UE_KW.Lock 4G or 5G Frequency    ${ue_index}  ${tech}  ${xfcn}  ${4g_pci_or_5g_scs}

Unlock 4G or 5G Frequency
    [Documentation]
    ...    Note : Before using this kW, please ensure that the scanning mode selected on the UE web page is full frequency band !!
    ...
    ...    Example : testsuite/Nanjing/OAM/Pilot/Pilot_SMAwave_Lock_Frequency_Test.robot
    [Tags]    SMAWave
    [Arguments]    ${ue_index}  ${tech}
    DevNJ_UE_KW.Unlock 4G or 5G Frequency    ${ue_index}  ${tech}

Check ADB devices and reboot UEPC
    [Documentation]   Sometimes Android UE is ADB offline status, use this KW to reboot UEPC as a workaround.
    ...    Note : This KW is used only for Android Traffic with CMD case, and use it after "Reboot UEs".
    ...    index : UE identifier index
    ...
    ...    Example : Check ADB devices and reboot UEPC    ue_index=1
    [Tags]    Android
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.Check ADB devices and reboot UEPC    ${ue_index}

Fetch UE Address
    [Documentation]  This keyword used to get UE IP address after attach operation.
    ...    Note: for SMAWave, please ensure comd service restart otherwise can't obtain assigned address.
    ...    index : UE identifier index
    ...
    ...    Example : Fetch UE Addr    ue_index=1
    [Tags]    SMAWave    Android
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.Fetch UE Address    ${ue_index}

Set UE SA Mode Disable
    [Documentation]  This keyword used to disable SMAWave UE SA mode, this KW is used for NSA BTS mode.
    ...    Note: By default, SMAWave is SA enabled mode. The SA switch will be automatically set to enable after rebooting UE.
    ...    index : UE identifier index
    ...
    ...    Example : Set UE SA Mode Disable   ue_index=1
    [Tags]    SMAWave
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.Set UE SA Mode Disable    ${ue_index}

Set UE SA Mode Enable
    [Documentation]  This keyword used to enable SMAWave UE SA mode, this KW is used for SA BTS mode.
    ...    Note: By default, SMAWave is SA enabled mode. The SA switch will be automatically set to enable after rebooting UE.
    ...    index : UE identifier index
    ...
    ...    Example : Set UE SA Mode Enable   ue_index=1
    [Tags]    SMAWave
    [Arguments]    ${ue_index}
    DevNJ_UE_KW.Set UE SA Mode Enable    ${ue_index}

Set APN
    [Documentation]  This keyword is used to set SMAWave UE APN.
    ...    apn_name : name of APN
    ...    ue_index : UE identifier index
    ...
    ...    Example : Set UE SA Mode Enable   ue_index=1
    [Tags]    SMAWave
    [Arguments]    ${apn_name}  ${ue_index}
    DevNJ_UE_KW.set apn    ${apn_name}    ${ue_index}

Verify Attached Cell ID
    [Documentation]  This keyword is used to verify attached CELL ID.
    ...    cell_id : ID of expected Cell
    ...    ue_index : UE identifier index
    ...
    ...    Example : Set UE SA Mode Enable   ue_index=1
    [Tags]    SMAWave
    [Arguments]    ${cell_id}  ${ue_index}
    DevNJ_UE_KW.verify attached cell id    ${cell_id}    ${ue_index}
