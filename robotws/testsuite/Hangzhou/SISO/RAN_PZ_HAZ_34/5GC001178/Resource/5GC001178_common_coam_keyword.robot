*** Settings ***
Documentation
...    author: chu xiangsheng
...    contact: xiangsheng.chu@nokia-sbell.com
...    Group: HGZ_SG6
Library    taf.transport.ssh	WITH NAME	csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot

*** Variables ***

*** Keywords ***

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    COAM Check GNB cell on air

Case Teardown
    [Timeout]      5min
    COAM Teardown gnb connections
    mtk.UE Attach    ue_alias=UE_0

