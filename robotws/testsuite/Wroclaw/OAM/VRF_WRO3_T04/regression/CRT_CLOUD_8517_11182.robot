*** Settings ***
Documentation    Suite for testing 9857 on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/CB0011182/TestCases/CB0011182_CR.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Library         String
Library         SSHLibrary
Library         Collections
Library         OperatingSystem

Suite Setup      Suite Setup
Suite Teardown   Suite Teardown

Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***

[1]CB011182-CR-G_Kubernetes_API_Access_Control_RANNIC_SW_Controller_Secret_Access
    [Tags]
    CB011182-CR-G_Kubernetes_API_Access_Control_RANNIC_SW_Controller_Secret_Access
*** Keywords ***
Suite Setup
    Run Keyword and Ignore Error    Create Object with Single Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${primary_param_value}     hw_type=vDU
    Run Keyword and Ignore Error    Create Object with Single Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${primary_param_value}     hw_type=vCU

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Run Keyword if Test Failed    logs.Common Gathering Logs for Test Teardown
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=vCU
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=vCU
    Run Keyword if Test Failed    Delete All Certificates    hw_type=vCU
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=vDU
    Run Keyword if Test Failed    Delete All Certificates    hw_type=vDU

Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO4
    ...                             input_logs_dir=${None}
    ...                             remote_host_vDU=${LMP_VDU_IP}
    ...                             remote_host_vCU=${LMP_VCU_IP}
    ...                             mandatory_log_types=__snapshot_vDU__,__snapshot_vCU__
    ...                             collect_NOP=${True}
