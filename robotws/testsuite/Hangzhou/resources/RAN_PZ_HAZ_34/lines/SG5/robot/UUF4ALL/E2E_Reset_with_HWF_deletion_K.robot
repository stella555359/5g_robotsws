*** Settings ***
Documentation    Author: annie.hu@nokia-sbell.com
Suite Setup      SG5_Common_Suite_Setup   is_commission=${False}
Suite Teardown   Run Keywords   robot_common_operations.Common Suite Teardown   CI_interface.Common Case Teardown

Force Tags        E2E_KDDI     SG_05

Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Resource     Resource/Reset_with_HWF_common_KW.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${BASIC_SCF}     sg5_basic.xml
&{fault_4459}    faultId=${4459}
&{fault_4655}    faultId=${4655}
&{fault_4654}    faultId=${4654}
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_6502}    faultId=${6502}
&{fault_7523}    faultId=${7523}
&{fault_7100}    faultId=${7100}
&{fault_7115}    faultId=${4592}
&{fault_7107}    faultId=${7319}
&{fault_7300}    faultId=${7300}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4655}   &{fault_4654}   &{fault_61652}   &{fault_61524}   &{fault_6502}
...               &{fault_7523}   &{fault_7100}   &{fault_7115}   &{fault_7107}   &{fault_7300}


*** Test Cases ***
[1]E2E_Reset_with_HWF_deletion
    [Tags]    OWNER_annie.hu@nokia-sbell.com   CRT_23R1
    [Timeout]    900min
    [Setup]    Test case setup
    Set Test Variable    ${test_round}    1
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
        #Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
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
