*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    8015 Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Resource    Resources/CB007538_Case_Step.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007737/Resources/CB007737_Case_Step.robot

*** Variables ***
${pcell_index}    3

*** Test Cases ***
[1]CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
    [Tags]    Classical    CIT_24R3
    [Timeout]    90m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=SCF_${stream}
    CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
    ...                                                                                                       pcell_index=${pcell_index}
    [Teardown]   8015 Case TearDown
