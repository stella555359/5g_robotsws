*** Settings ***
Documentation       Test suite for SBTS11227
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    20h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource  ../../test_resources/SyVe/SRAN_SyVe_CB007518-A_001_Online_Configuring_Predefined_RU_Then_Connect_To_BTS_With_Automatic_Installation.robot
Resource  ../../test_resources/SyVe/SRAN_SyVe_CB007518-A_004_BTS_Startup_With_Predefined_RU_Then_Connect_To_BTS_With_Manual_Installation.robot
Resource  ../../test_resources/CM/CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SCF_ID}    01
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py


*** Test Cases ***
[1] SRAN_SyVe_CB007518-A_001_CM_SR_Online_Configuring_Pre-defined_RU_And_Then_Connect_To_BTS_With_Automatic_Installation
    [Tags]    QC_243884  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Run Keywords
    ...    Set Library Search Order    SRAN_SyVe_CB007518-A_001_Online_Configuring_Predefined_RU_Then_Connect_To_BTS_With_Automatic_Installation
    ...    AND    SRAN_SyVe_CB007518-A_001_Online_Configuring_Predefined_RU_Then_Connect_To_BTS_With_Automatic_Installation.Test Setup
    SRAN_SyVe_CB007518-A_001_CM_SR_Online_Configuring_Pre-defined_RU_And_Then_Connect_To_BTS_With_Automatic_Installation
    [Teardown]    SRAN_SyVe_CB007518-A_001_Online_Configuring_Predefined_RU_Then_Connect_To_BTS_With_Automatic_Installation.Test Teardown

[1] SRAN_SyVe_CB007518-A_004_CM_SR_BTS_Startup_With_Pre-defined_RU_And_Then_Connect_To_BTS_With_Manual_Installation
    [Tags]    QC_243885  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Run Keywords
    ...    Set Library Search Order    SRAN_SyVe_CB007518-A_004_BTS_Startup_With_Predefined_RU_Then_Connect_To_BTS_With_Manual_Installation
    ...    AND    SRAN_SyVe_CB007518-A_004_BTS_Startup_With_Predefined_RU_Then_Connect_To_BTS_With_Manual_Installation.Test Setup
    SRAN_SyVe_CB007518-A_004_CM_SR_BTS_Startup_With_Pre-defined_RU_And_Then_Connect_To_BTS_With_Manual_Installation
    [Teardown]    SRAN_SyVe_CB007518-A_004_BTS_Startup_With_Predefined_RU_Then_Connect_To_BTS_With_Manual_Installation.Test Teardown

[1] CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    [Tags]    QC_243886  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Run Keywords
    ...    Set Library Search Order    CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    ...    AND    CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime.Test Setup
    CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    [Teardown]    CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime.Test Teardown
