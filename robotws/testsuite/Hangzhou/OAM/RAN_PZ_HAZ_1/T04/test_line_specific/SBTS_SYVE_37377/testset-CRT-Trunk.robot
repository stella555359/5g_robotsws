*** Settings ***
Documentation       Test suite for SBTS37377
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    2h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/CM/CM__CB008824_002_Configure_Baseband_Redundancy_Mode.robot
Resource    ../../test_resources/CM/CM__CB008824_003_Do_Controlled_Switchover.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1028    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SCF_ID}    01
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py


*** Test Cases ***
CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37377_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    1h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    ...    AND    Set Library Search Order    CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    [Teardown]    Run Keywords    CM__CB008824_002_Configure_Baseband_Redundancy_Mode.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB008824_003_Do_Controlled_Switchover
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37377_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    1h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__CB008824_003_Do_Controlled_Switchover
    ...    AND    Set Library Search Order    CM__CB008824_003_Do_Controlled_Switchover
    CM__CB008824_003_Do_Controlled_Switchover
    [Teardown]    Run Keywords    CM__CB008824_003_Do_Controlled_Switchover.Case Special Teardown
    ...    AND    Restore Resource Search Order