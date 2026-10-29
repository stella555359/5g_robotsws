*** Settings ***
Documentation    Suite for TL280

Resource        ../features/CB010214/TestCases/CB010214-C-SR.robot

Resource        ../common_resources/applications_running_with_root/common_keywords.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        ../common_resources/alarms/alarm.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/mantaray/mantaray.robot
Resource        ../common_resources/variables/variables.robot
Library         ../common_resources/robot_extensions/robot_extensions.py

Force Tags      CA_VRF_WRO3
...             STATE_SW_UPLOADED
...             CLOUD_5G_CLASSICAL_ASIM_ABIQ_AHLOA_WRO_TRS
...             AVG_EXE_TIME=150
...             RESPONSIBLE_TESTER=

Test Timeout    66h

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${FINAL_CHECK}=     True       #Check BTS status and alarms. Possible settings: True, False
${NetAct_name}=     srnclab1015

*** Test Cases ***
[1]CB010214-C_btsEMRestrictAccSession_modification-local_users
    [Tags]
    CB010214-C_btsEMRestrictAccSession_modification-local_users

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Change Ethernet Port Security Enabled To True CLASSICAL
    Run Keyword And Ignore Error                  add_headline_to_output_file
    Run Keyword And Continue On Failure           Wait Until BTS Reach Configured Or OnAir State

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
	Run Keyword And Ignore Error                  copy_files_of_nmap_results
	Run Keyword And Ignore Error                  Copy Report Txt File To Output Directory
	Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

Test Setup NMS
    Common Gathering Logs for Test Setup
    Integrate BTS to MantaRay without TLS    NMS_HOST=${SRNCLAB1015}    LAB_NAME=${NetAct_name}

Test Teardown NMS
    Deintegrate BTS from MantaRay    LAB_NAME=${NetAct_name}
    Wait until BTS reach Configured or OnAir state
    Common Gathering Logs for Test Teardown
