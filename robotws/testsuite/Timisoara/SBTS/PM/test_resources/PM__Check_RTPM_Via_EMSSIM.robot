*** Settings ***
Documentation
...  This TC is starting EMSSIM session and waits for RTPM data files to be generated.
...  NMS must be disconnected before setting up EMSS.
...  RTPM parameters are activated through EMSSIM session.
...  Once RTPM data files are generated, they are combined into .pl human readable file which must contain
...  MRBTS ID and RTPM counters.

Library  ta_emss
Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${SITE_RESET_TIMEOUT}  600  #Timeout for Site Reset operation to be finished.
${RESTORE_TIMEOUT}  1200  #Timeout for SBTS to reach on air state after sbts reboot.


*** Keywords ***
TC__PM__Check_RTPM_Via_EMSSIM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29682
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29682 - Initial TAT creation
    ...  - 27.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30095 - Add watchdog alarms

    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  FEATURE-CB010969

    Step1: Activate RTPM And Save RTPM Data File
    Step2: Check RTPM Data File


Step1: Activate RTPM And Save RTPM Data File
    Log  \nStep1: Activate RTPM And Save RTPM Data File  console=true
    Rtpm Activate  bts_id=${BTS_ID}
    Rtpm Clean  bts_id=${BTS_ID}
    Log  Wait for RTPM files to be generated.  console=true
    Wait For Rtpm After Test  bts_id=${BTS_ID}
    Run Emssim Command  rtpm_parse  bts_id=${BTS_ID}
    Rtpm Deactivate  bts_id=${BTS_ID}


Step2: Check RTPM Data File
    Log  \nStep2: Check RTPM Data File  console=true
    Run  cp /home/flexi${BTS_ID}/UPLOADS/KEYSTATS/RTPM/RTPM_Data.pl ${BTS_FILES}/RTPM_Data.pl
    ${rtpm_data_file_location}  Set Variable  ${BTS_FILES}/RTPM_Data.pl
    Log  ${rtpm_data_file_location} is verified to contain MRBTS ID and PM counters.  console=true
    ${mrbts_id_exists}  Run  grep -E MRBTS-${BTS_ID} -m 1 -o ${rtpm_data_file_location}
    ${counters_exist}  Run  grep -E "\\"M[0-9]+\\"\\s=>\\s\\{" -m 1 -o /home/flexi${BTS_ID}/UPLOADS/KEYSTATS/RTPM/RTPM_Data.pl
    Should Not Be Empty  ${mrbts_id_exists}  ${rtpm_data_file_location} does not contain MRBTS-${BTS_ID}.
    Should Not Be Empty  ${counters_exist}  ${rtpm_data_file_location} does not contain RTPM counters.


Start Emss Simulator
    Disable Firewalls
    ${nms_state}  Get Nms State
    ${manager_info_is_empty}  Run Keyword And Return Status  Should Be Empty  ${nms_state}[0][managerInfo]
    IF  not ${manager_info_is_empty}
        Remove Ne3adapt File From SBTS
        coam.Reset Site  timeout=${SITE_RESET_TIMEOUT}
        Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30s  Admin Check All Required State
        Log  SBTS is on air after reset.  console=true
    END
    Log  Start Emss Simulator  console=true
    Setup Emss  bts_id=${BTS_ID}  bts_ip=${MPLANE_IP}


Disable Firewalls
    Run  sudo iptables -P INPUT ACCEPT
    Run  sudo iptables -P OUTPUT ACCEPT
    Run  sudo iptables -P FORWARD ACCEPT
    Run  sudo iptables -F


Remove Ne3adapt File From SBTS
    Log  Remove Ne3adapt File From SBTS  console=true
    Open Connection To Primary Core
    SSHLibrary.Execute Command  rm /rom/config/ne3sadapt/configs/ne3sadaptdata.db

    [Teardown]  SSHLibrary.Close Connection


Stop Emss Simulator
    Log  Stop Emss Simulator  console=true
    Teardown Emss  bts_id=${BTS_ID}


TC Setup
    Common Test Setup  tc_name=PM__Check_RTPM_Via_EMSSIM
    Start Emss Simulator


TC Teardown
    Stop Emss Simulator
    Common Test Teardown
