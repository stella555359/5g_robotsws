*** Settings ***
Documentation
...  author: dalwang
...  contact: dali.wang@nokia-sbell.com
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Variables   ../../libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001545_AA/Resource/common_license.robot

*** Variables ***

*** Keyword ***
Common Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    ${gnb_release}   Get gnb release
    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM Backup SCF
#    Wait Until Keyword Succeeds   3x   30s   Perform sub-feature SCF   feature_name=CB007308
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Set GNB Oamtls Param
#    Add COAM User at VM
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    COAM WEBUI Whether Close Start Up View Window
    # Set QC Instance ID Test Tag

Common Teardown
    Run Keyword And Ignore Error   COAM Login
#    wait until keyword succeeds     5x    5min   COAM SCF Commission
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Set QC Instance ID Test Tag
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}${/}qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}

Set GNB Oamtls Param
       ${return_oamtls}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...   filter_param=TLS usage towards the operation and maintenance system
    Run Keyword If   '${return_oamtls}'!='off'   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=TLS usage towards the operation and maintenance system  new_value=off
    Validate and Activate Parameter
    CM Upload on NetAct Background

Case Setup
   [Arguments]  ${trigger_type}  ${Fault number}    ${Max_number}=24
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}
    ...                                filter_param=BTS name
    ...                                new_value=MRBTS-${BTS}
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers
     run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Syslog substing trigger
    sleep    2s
    Validate and Activate Parameter
#    sleep    30s
    run keyword and ignore error       wait until keyword succeeds     5x    30s
    ...    selenium_coam.add_element    dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers      timeout=${100}
    sleep    2s
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Fault number
    ...                                new_value=${Fault number}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Trigger type
    ...                                new_value=${trigger_type}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Max number of snapshots due to fault triggers per day
    ...                                new_value=${Max_number}
    Validate and Activate Parameter
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Local symptoms server configuration
    sleep    2s
    Validate and Activate Parameter
    run keyword and ignore error     selenium_coam.add_element    dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Local symptoms server configuration   timeout=${100}
    sleep    2s
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Diagnostic Snapshot destination
    ...                                new_value=lss
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Local symptoms server IP address
    ...                                new_value=${LSS_Server_ip}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Local symptoms server IP port number
    ...                                new_value=${LSS_Server_Port_Num}
    Validate and Activate Parameter
#    Check Fault 4459 Clear Status
    Remove LSS Snapshot


Case Teardown
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Modify Parameter enableDefaultPasswdAlarm
    [Arguments]   ${Active_Value}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/AMGR-1
    ...                                filter_param=Enable default password alarm
    ...                                new_value=${Active_Value}
    Run Keyword And Ignore Error   Validate and Activate Parameter


Modify Parameter actServiceAccountSsh
    [Arguments]   ${Active_Value}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/SECADM-1
    ...                                filter_param=Activate service account SSH
    ...                                new_value=${Active_Value}
    Run Keyword And Ignore Error   Validate and Activate Parameter

Check Fault 4459 Clear Status
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    FOR   ${active_alarm}   IN   @{active_alarms}
       Should Not Be Equal As Strings   ${active_alarm['faultId']}   4459
    END

Check Fault Raise Status
    [Arguments]   ${Fault number}
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    FOR   ${active_alarm}   IN   @{active_alarms}
       ${supplAlarmInfo}   Set Variable If
       ...   '${active_alarm['faultId']}'=='${Fault number}'   ${active_alarm['supplAlarmInfo']}
       ...   '${active_alarm['faultId']}'!='${Fault number}'   ${supplAlarmInfo}
       Exit For Loop If   '${active_alarm['faultId']}'=='${Fault number}'
    END
    Should Not Be Equal As Strings   ${supplAlarmInfo}   NONE

Remove LSS Snapshot
    csn.connect to   hostname=${LSS_Server_ip}   username=${LSS_Server_Username}    password=${LSS_Server_Password}    alias=lss
    csn.execute   command=cd /home/coam/;rm -rf Snapshot_MRBTS-${BTS}_*   connection=lss
    csn.disconnect   connection=lss

Remove Netact Snapshot
    csn.connect to    hostname=${Netact_Server_ip}   username=${Netact_Server_Username}   password=${Netact_Server_Password}    alias=Netact
    ${Snapshot_Output}   csn.execute   command=cd /d/oss/global/diagsnap/ne3sws;rm -rf Snapshot_MRBTS-${BTS}_*   connection=Netact
    csn.disconnect    connection=Netact

#Config LSS Server on WebEM
#    [Arguments]  ${trigger_type}
#    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#    ...                                filter_param=Diagnostic Snapshot destination
#    ...                                new_value=lss
#    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#    ...                                filter_param=Local symptoms server IP address
#    ...                                new_value=${LSS_Server_ip}
#    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#    ...                                filter_param=Local symptoms server IP port number
#    ...                                new_value=${LSS_Server_Port_Num}
#    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#    ...                                filter_param=Fault number
#    ...                                new_value=4459
#    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#    ...                                filter_param=Trigger type
#    ...                                new_value=${trigger_type}
#    Validate and Activate Parameter

Config Netact Server on WebEM
    [Arguments]  ${trigger_type}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Diagnostic Snapshot destination
    ...                                new_value=netact
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Fault number
    ...                                new_value=4459
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Trigger type
    ...                                new_value=${trigger_type}
Check Snapshot Upload to LSS Status
    csn.connect to    hostname=${LSS_Server_ip}   username=${LSS_Server_Username}   password=${LSS_Server_Password}    alias=lss
    ${Snapshot_Output}   csn.execute   command=cd /home/coam/;ls -al | grep Snapshot_MRBTS-${BTS}_*   connection=lss
    Should Not Be Empty   ${Snapshot_Output}
    csn.disconnect    connection=lss

Check Snapshot NOT collected to LSS
    csn.connect to    hostname=${LSS_Server_ip}   username=${LSS_Server_Username}   password=${LSS_Server_Password}    alias=lss
    ${Snapshot_Output}   csn.execute   command=cd /home/coam/;ls -al | grep Snapshot_MRBTS-${BTS}_*   connection=lss
    Should Be Empty   ${Snapshot_Output}
    csn.disconnect    connection=lss

Validate and Activate Parameter
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120

Check Snapshot Upload to Netact
    csn.connect to    hostname=${Netact_Server_ip}   username=${Netact_Server_Username}   password=${Netact_Server_Password}    alias=Netact
    ${Snapshot_Output}   csn.execute   command=cd /d/oss/global/diagsnap/ne3sws;ls -al | grep "Snapshot_MRBTS-${BTS}_*"   connection=Netact
    Should Not Be Empty   ${Snapshot_Output}
    csn.disconnect    connection=Netact

Trigger snapshot by fault4459
    Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
    Check Fault Raise Status    4459
    sleep  15min
    Run Keyword And Ignore Error    Check Snapshot Upload to LSS Status
    Remove LSS Snapshot
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
    Wait Until Keyword Succeeds   3x   20s    Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
    Check Fault 4459 Clear Status

Trigger snapshot by fault61524
    Modify Parameter actServiceAccountSsh    Active_Value=false
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers
    sleep    2s
    Validate and Activate Parameter
#    sleep    30s
    run keyword and ignore error       wait until keyword succeeds     5x    30s
    ...    selenium_coam.add_element    dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers      timeout=${100}
    sleep    2s
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Fault number
    ...                                new_value=61524
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Trigger type
    ...                                new_value=onFaultDetection
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Max number of snapshots due to fault triggers per day
    ...                                new_value=24
    Validate and Activate Parameter
    Modify Parameter actServiceAccountSsh    Active_Value=true
    sleep    10s
    Check Snapshot Upload to LSS Status
    Remove LSS Snapshot
    Modify Parameter actServiceAccountSsh    Active_Value=true

Wait for Cell Onair
    [Arguments]   ${wait_timer}   ${cell_index}
    ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
    ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   selenium_coam.refresh_page
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword if  not ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically
