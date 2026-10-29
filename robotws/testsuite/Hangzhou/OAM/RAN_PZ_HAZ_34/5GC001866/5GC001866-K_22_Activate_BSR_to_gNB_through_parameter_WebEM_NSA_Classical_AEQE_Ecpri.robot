*** Settings ***
Suite Setup      SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout     60min
Resource    Resource/5GC001866-K_Common_KW.robot
Resource    ../common/coam_resource.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot


Documentation
...   author: Annie Hu
...   contact: annie.hu@nokia-sbell.com
...   squad group: SG_05
...   Feature 5GC001866-K Beamset realization

Force Tags     5G_RAN_TDD
...    PY36

*** Variables ***
${if_pdl_check}    False

*** Test Cases ***
[1][1.0] 5GC001866-K_22_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical_AEQE_Ecpri
    [Tags]    CDRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Selenium Login And Disable Screen Lock
    Get BTS Id online
    ${fault_list}    Create List    7529
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    "Step1" Download BSR package
    "Step2" Enable feature 1866
    "Step3" Activate BSR through WebEM
    "Step4" Check gNB and Cell onAir
    "Step5" Check Inused BSR
    "Step6" Check If there is new alarm
    [Teardown]    1866 Test Teardown

*** Keywords ***
1866 Test Teardown
    Connect to gnb coam via ssl
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    SISO Coam Test Teardown
