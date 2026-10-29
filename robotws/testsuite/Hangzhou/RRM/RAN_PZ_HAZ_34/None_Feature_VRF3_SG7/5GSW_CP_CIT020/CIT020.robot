*** Settings ***
Suite Setup    Setup BTS env and set keyword prority
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      Flora Du
...   contact:     Flora.du@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     5GC000704 

Force Tags    5G_RRM
...   PY39

Resource    ./resource/CIT020_keywords.robot

*** Variables ***
@{HO_PARAMS}
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true


*** Test Cases ***
5GSW-CP-CIT020_Verify_Classical_SA_TDD_cmWave_intra-cell_inter-gNB_HO_A3_RSRP_CFRA_is_successful_TestCase
    [Documentation]
    ...    1. The purpose of this test case is to setup vonr call and check inter-frequency Intra-DU handover successful
    ...    2. Test Case Steps:
    ...         cell1 frequency: 633364, cell2 frequency:633372, sim cell frequency: 633364
    ...                     ssb: 633216              ssb:633408                 ssb: 633216
    ...                          CBRA                  CFRA                            CFRA
    ...           pdu1_nwslice1(sd:13714341=d143a5)
    ...           pdu2_nwslice2(sd:13714342=d143a6)
    ...      case step:
    ...         a. UE1 set pdu1 with slice1, UE1 set pdu2 with slice2, UE2 set pdu1 with slice1, UE3 set pdu1 with slice1
	...         b. check 3 UE's ECID when 8281 is enable, check 3 UE's ECID when 8281 is disable and enable the 8281 again
    ...         c. UE1 will use CBRA trigger inter-gnb intra-freq HO, form cell1 HO to sim cell, and from sim cell HO to Cell1
    ...         d. UE2 will use CFRA trigger intra-gnb inter-freq HO, form cell1 HO to cell2, and from cell2 HO to Cell1
    ...         e. UE3 will use CFRA trigger inter-gnb inter-freq HO, form cell2 HO to sim cell, and from sim cell HO to Cell2
	...         f. check 3 UE's ECID when 8281 is enable
    ...         g. check conuter
    ...      case result:
    ...         a. UE1 pdu1 and pdu2 setup successful, UE2 and UE3 setup successful.
	...         b. ECID can be got when 8281 is enable, ECID cannot be got when 8281 is disable
    ...         c. UE1 trigger inter-gnb intra-freq HO successful and traffic is ok
    ...         d. UE2 trigger intra-gnb inter-freq HO successful and traffic is ok
    ...         e. UE3 CFRA trigger inter-gnb inter-freq HO successful and traffic is ok
	...         f. ECID can be got when 8281 is enable
    ...         g. check conuter is right
    [Tags]    D012    QC_
    OnlineParamChange    ${HO_PARAMS}
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    Start UE Attach With Power UE    ue_index=${0}    4G_check=false
    Start L3 Call With Power UE    ue_index=${0}    ul_data_transfer=5    dl_data_transfer=10
    @{direction_component_list}    Create List   UL_L2LO    DL_L2LO
    Check Tput With Power UE    expect_ul_tput=${0}    expect_dl_tput=${0}    duration=10
    ...    direction_component_list=@{direction_component_list}
    Stop Traffic With Power UE     ue_index=${0}    is_detach=True

*** Keywords ***
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

