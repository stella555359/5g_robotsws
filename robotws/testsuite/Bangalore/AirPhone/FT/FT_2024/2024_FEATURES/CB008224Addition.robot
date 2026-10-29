*** Settings ***
Documentation  Script for feature CB008224
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     CONFIGURED

Resource    resources/Keywords/common_keywords.robot
Resource    resources/Keywords/Testcase_KW.robot

Suite Setup        Updated Suite Setup
#Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE1}        1
${UE2}        2
${pattern1}     SCellIndex 1 activated successfully at airphone
${pattern2}     sCellToAddModList


*** Test Cases ***
Make L3 SA call
    Log to Console      Starting the test case\n
    [Setup]     Prepare for CB008224 test Case
    Log to Console      Registering UE\n
    UE Register should be Successful for SA     ${UE2}
    wtsrunner.ue_meas_cfg_disp      id=2     meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr    id=${UE2}   meas_id=1   event=A1    srsrp_nr=100    srsrq_nr=100
    sleep    10s
    Log to Console   Verification of Scell index addition and activation from EGATE LOG\n
    Run Keyword And Ignore Error    Check Pattern in Egate Console Log      ${pattern2}
    Log to Console      Starting DL and UL traffic for UEs\n
    Start and Validate Traffic For CA       UE_ID=${UE2}
    sleep    30s
    Verification of Downlink throughput     id=${UE2}
    sleep    30s
    Verification of Uplink throughput    id=${UE2}
    sleep    10s
    Run Keyword And Ignore Error    Check Pattern in Egate Console Log      ${pattern1}

    Log to Console      \n Starting Tear Down for Test Case\n
##   [Teardown]      Run Keyword And Ignore Error       Common test case tear down
