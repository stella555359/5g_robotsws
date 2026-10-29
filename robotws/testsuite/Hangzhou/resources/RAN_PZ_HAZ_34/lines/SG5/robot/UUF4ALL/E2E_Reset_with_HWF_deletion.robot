*** Settings ***
Documentation    Author: annie.hu@nokia-sbell.com
Suite Setup      SG5_Common_Suite_Setup   is_commission=${False}
Suite Teardown   CI_interface.Common Case Teardown

Force Tags        E2E_22R1     SG_05

Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Resource     Resource/Reset_with_HWF_common_KW.robot



*** Variables ***
${BASIC_SCF}     sg5_basic.xml



*** Test Cases ***
E2E_Reset_with_HWF_deletion
    [Documentation]    author: annie.hu@nokia-sbell.com
    [Timeout]    900min
    [Setup]    Test case setup
    Set Test Variable    ${test_round}    20
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    FOR    ${count}    IN RANGE    ${test_round}
        Modify Swconfig File   para_update=${swconfig_list}
        run keyword and ignore error    COAM Teardown gnb connections
        Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
#       start btslog capture  name=btslog
        coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM
        sleep   8min
        Verify TMO Gnb Ready And All Cell On Air
        Check_gNB_Startup_log
        Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        Run Keyword If   '${enb_length}'!='${0}'  Connect to eNB via ssl   enb_index=${0}  connection=enblte_0
        Run Keyword If   '${enb_length}'!='${0}'  coam.reset_site    connection=enblte_0
        Run Keyword If   '${enb_length}'!='${0}'  sleep   5min
        Run Keyword If   '${enb_length}'!='${0}'  Wait until keyword succeeds    2 min    20 sec
                            ...             Verify Enb All Cell On Air    enb_index=${0}
        #Run Keyword If   '${enb_length}'!='${0}'  Connect to eNB via ssl   enb_index=${0}  connection=enblte_0
        #Run Keyword If   '${enb_length}'!='${0}'  Run Keyword And Continue On Failure
                            #...   Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}  connection=enblte_0
        #Run Keyword If   '${enb_length}'!='${0}'  Run Keyword And Continue On Failure
                       #...  Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}  connection=enblte_0
    END
    [Teardown]   robot_common_operations.Common Case Teardown



*** Keywords ***
