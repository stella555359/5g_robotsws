*** Settings ***

Documentation
...   author: Ravali challa
...   contact: challa.ravali@nokia.com
...   Description: Test case for CB009462

Library    taf.sw.scout    WITH NAME    scout
Resource    ./resources/CB009462_Verification_of_Successful_commissioning_with_O_RAN_MPlane_static_LTE_PRACH_configuration_with_CatM_enabled.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot

Test Setup      Test Setup
Test Teardown   Test Teardown 
Force Tags    CRT  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with Cat-M enabled}    
...     QC_ID_SBTS00=QC_824383

*** Test Cases ***

CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with Cat-M enabled
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    ${out}    set variable
    ...    ${OUTPUT_DIR}/CB009462_O-RAN_M-Plane_static_LTE_PRACH_configuration_with_Cat-M_enabled
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with Cat-M enabled
    #RP Settings
    #FSM Access Close Connection
    [Teardown]    run keywords
    #...    reportingportal_Keywords.Set QC_Tag
    ...    Test Teardown
    #...    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
#FSM Access Close Connection
    #[Arguments]    ${alias}=fsm_access
    #Teardown Enb Fsm Access    alias=${alias}
