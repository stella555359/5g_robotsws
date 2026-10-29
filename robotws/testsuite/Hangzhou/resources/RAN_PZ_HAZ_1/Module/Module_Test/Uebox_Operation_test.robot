*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test cases

Library    ../Traffic_UEBox_Operation.py

Force Tags        RAN_VRF_HAZ1

Test Timeout      30 minutes

*** Variables ***

${Dingli_ue}    262033100012214
${Spark_ue_on_guangyong_pc}     262033100013372,262033100013373
@{Spark_plans}    Ping


*** Test Cases ***
TC01_General_UE_Service_test_for_Spark
    [Tags]    CRT    TC01

    Set Suite Variable    ${testue}    ${Spark_ue_on_guangyong_pc}
    Set Suite Variable    ${LogName}    Case01
    Set Suite Variable    ${LogPath}    c:\\uelogs
    # log to console   ${tl.appserver.iperf_details.ssh_connection_details}

    # Traffic Uebox Operation    operation=start log    ue_imsi=${testue}    LogPath=${LogPath}    LogName=${LogName}
    # Traffic UEBox Operation    operation=detach    ue_imsi=${testue}
    # Traffic UEBox Operation    operation=attach    ue_imsi=${testue}

    # # upload udp service
    # Traffic Uebox Operation    operation=start ul traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-u -t 1000 -i 1 -b 10m -p 50001
    # Sleep  30s
    # Traffic Uebox Operation    operation=stop ul traffic  ue_imsi=${testue}

    # # upload tcp service
    # Traffic Uebox Operation    operation=start ul traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-t 1000 -i 1 -b 10m -p 50001
    # Sleep  30s
    # Traffic Uebox Operation    operation=stop ul traffic  ue_imsi=${testue}

    # # download udp service
    # Traffic Uebox Operation    operation=start dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-t 1000 -i 1 -b 10m -p 50001
    # Sleep  20s
    # Traffic Uebox Operation    operation=stop dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-

    # # download tcp service
    # Traffic Uebox Operation    operation=start dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-t 1000 -i 1 -b 10m -p 50001
    # Sleep  20s
    # Traffic Uebox Operation    operation=stop dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-

    # # Voice Call
    # Traffic Uebox Operation    operation=start voice call  ue_imsi=${testue}  Number=6688
    # Sleep  10s
    # Traffic Uebox Operation    operation=stop voice call  ue_imsi=${testue}

    # # Test Plans
    # Traffic Uebox Operation    operation=start testplan    ue_imsi=${testue}    TestPlans=${Spark_plans}
    # Sleep  20s
    # Traffic Uebox Operation    operation=stop testplan    ue_imsi=${testue}

    # Traffic Uebox Operation    operation=stop log    ue_imsi=${testue}
    # Traffic Uebox Operation    operation=fetch log    ue_imsi=${testue}   LogPath=${LogPath}    LogName=${LogName}
    # ...    LocalDire=local_log_1

    # # AT CMD and Custom CMD
    # Traffic Uebox Operation    operation=exec custom cmd  ue_imsi=${testue}
    # ...    jsoncmd={"CMD": "AutoDivideSet", "Param": {"Enabled": 1, "Size": "100", "Type": 1}}
    Traffic Uebox Operation    operation=exec at cmd  ue_imsi=${testue}    atcmd=AT+CIMI    SuccStr=OK    retry_times=3


TC02_General_UE_Service_test_for_Dingli
    [Tags]    CRT    TC01

    Set Suite Variable    ${testue}    ${Dingli_ue}
    Set Suite Variable    ${LogName}    Case02
    Set Suite Variable    ${LogPath}    c:\\uelogs
    # log to console   ${tl.appserver.iperf_details.ssh_connection_details}

    # Run Keyword And Ignore Error  Traffic UEBox Operation  stop log  ue_imsi=${testue}
    # Traffic Uebox Operation    operation=start log    ue_imsi=${testue}    LogPath=${LogPath}    LogName=${LogName}
    # Traffic Uebox Operation    operation=detach    ue_imsi=${testue}
    # Traffic Uebox Operation    operation=attach    ue_imsi=${testue}

    # # upload udp service
    # Traffic UEBox Operation    operation=start ul traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-u -t 1000 -i 1 -b 10m -p 50001
    # Sleep  30s
    # Traffic UEBox Operation    operation=stop ul traffic  ue_imsi=${testue}

    # # upload tcp service
    # Traffic UEBox Operation    operation=start ul traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-t 1000 -i 1 -b 10m -p 50001
    # Sleep  30s
    # Traffic UEBox Operation    operation=stop ul traffic  ue_imsi=${testue}

    # # download udp service
    # Traffic UEBox Operation    operation=start dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-t 1000 -i 1 -b 10m -p 50001
    # Sleep  20s
    # Traffic UEBox Operation    operation=stop dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-

    # # download tcp service
    # Traffic UEBox Operation    operation=start dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-   IperfOptions=-t 1000 -i 1 -b 10m -p 50001
    # Sleep  20s
    # Traffic UEBox Operation    operation=stop dl traffic  ue_imsi=${testue}    remote_hostname=10.69.9.58
    # ...    remote_username=ute    remote_password=qqwweeRR0-

    # # Voice Call
    # Traffic Uebox Operation    operation=start voice call  ue_imsi=${testue}  Number=6688
    # Sleep  10s
    # Traffic Uebox Operation    operation=stop voice call  ue_imsi=${testue}

    # # Test Plans
    # Traffic UEBox Operation    operation=start testplan    ue_imsi=${testue}    TestPlansLocation=c:\\ta\\udp_ul.tpl
    # Sleep  20s
    # Traffic UEBox Operation    operation=stop testplan    ue_imsi=${testue}

    # Traffic Uebox Operation    operation=stop log    ue_imsi=${testue}
    # Traffic Uebox Operation    operation=fetch log    ue_imsi=${testue}   LogPath=${LogPath}    LogName=${LogName}
    # ...    LocalDire=local_log_2

    # AT CMD and Custom CMD
    # Traffic Uebox Operation    operation=exec custom cmd  ue_imsi=${testue}
    # ...    jsoncmd={"CMD": "GetAttachStatus", "EQIndex": 5}
    Traffic Uebox Operation    operation=exec at cmd  ue_imsi=${testue}    atcmd=AT+CIMI    SuccStr=OK
