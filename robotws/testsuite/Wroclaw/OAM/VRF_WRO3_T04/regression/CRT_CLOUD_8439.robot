*** Settings ***
Documentation    Suite for testing 6524 on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/CB006524/TestCases/CB006524-CR.robot
Resource        ../../cloud_common_resources/connections/connections.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot

Library         SSHLibrary

Suite Teardown   Suite Teardown

*** Test Cases ***
6524-B_geoRedCnf_disabling_enabling_and_dryrun
    [Tags]     TL8439    6524-B
    GeoRedCnf_disabling_enabling_and_dryrun

6524-E_Activation_and_Deactivation_via_georedundancy_commands_stress_test
    [Tags]     TL8439    6524-E
    Activation_and_Deactivation_via_georedundancy_commands_stress_test

6524-A_Change_between_vCU_geo_red_N+1_and_vCU_geo_red_1+1
    [Tags]    TL8439    6524-A
    Change_between_vCU_geo_red_N+1_and_vCU_geo_red_1+1

6524-A_Georedundancy_activation_deactivation_and_configuration_on_paired_vCU
    [Tags]    TL8439    6524-A
    Georedundancy_activation_deactivation_and_configuration_on_paired_vCU

6524-A_Report_of_CNF-CNF_interface_failure_fault
    [Tags]    TL8439    6524-A
    Report_of_CNF-CNF_interface_failure_fault

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO4
    ...                             input_logs_dir=${None}
    ...							    remote_host=${LMP_VDU_IP}
    ...							    log_purpose=cloud_snapshot_vDU
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO4
    ...                             input_logs_dir=${None}
    ...							    remote_host=${LMP_VCU_IP}
    ...							    log_purpose=cloud_snapshot_vCU
    ...                             collect_NOP=${True}
