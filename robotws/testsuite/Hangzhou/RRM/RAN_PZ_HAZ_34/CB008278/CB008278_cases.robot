*** Settings ***
Documentation      author: Bin Wang
...                contact: bin.3.wang@nokia-sbell.com

Suite Setup       KW.TestSuilt.Start
Suite Teardown    KW.TestSuilt.Stop
Test Timeout         300 min


Resource           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008278/Resources/CB008278_Resources.robot

*** Test Cases ***
[1]CB008278-D_003_F+2T_DL_F+T_UL_CA_CB008406_AWPQZ
    [Documentation]     This case is to verify the test of FDD + 2TDD DL and FDD + TDD UL Carrier Aggregation with
    ...                 TDD SCell configured as chbw 10MHz and framestructure CB008406 in SA mode.
    [Tags]     AWPQZ
    [Setup]    TestCase.Start
    [Teardown]  Teardown case
    TC.CB008278-D_003_F+2T_DL_F+T_UL_CA_CB008406_AWPQZ

[1]CB008278-C_003_3T+1F_DL_CA_5GC001116_0ms_AWPQZ
    [Documentation]     This case is to verify the test of 3TDD + FDD DL Carrier Aggregation with TDD as Pcell
    ...                 and PCell configured as chbw 10MHz and framestructure 5GC001116_0ms in SA mode.
    [Tags]     AWPQZ
    [Setup]    TestCase.Start
    [Teardown]  Teardown case
    TC.CB008278-C_003_3T+1F_DL_CA_5GC001116_0ms_AWPQZ

[1]CB008278-B_004_UE_attach_and_traffic_5GC001116_0ms_AWPQZ
    [Documentation]     This case is to verify the test of UE attach and traffic with NRCell configured as chbw 10MHz
    ...                 and framestructure 5GC001116_0ms in SA mode.
    [Tags]     AWPQZ
    [Setup]    TestCase.Start
    [Teardown]  Teardown case
    TC.CB008278-B_004_UE_attach_and_traffic_5GC001116_0ms_AWPQZ

[1]CB008278-F_006_UE_attach_and_traffic_coreset0_on_3symbols_cce_split_CB008406_AWPQZ
    [Documentation]     This case is to verify the test of UE attach and traffic with NRCell configured as chbw 10MHz
    ...                 and framestructure CB008406 in SA mode. The coreset0 duration is 3 symbols and cce split is enabled.
    [Tags]     AWPQZ
    [Setup]    TestCase.Start
    [Teardown]  Teardown case
    TC.CB008278-F_006_UE_attach_and_traffic_coreset0_on_3symbols_cce_split_CB008406_AWPQZ

[1]CB008278-B_001_General_SiSo_BTS_Template_Commissioning_AWPQZ
     [Documentation]     This case is to check if not commissioned eNB/gNB can be correctly configured using BTS Template,
    ...                  verify Managed Object Class in WebUI and update parameters via WebUI.
    [Tags]     AWPQZ
    [Setup]    TestCase.Start
    [Teardown]  Teardown case
    TC.CB008278-B_001_General_SiSo_BTS_Template_Commissioning_AWPQZ
