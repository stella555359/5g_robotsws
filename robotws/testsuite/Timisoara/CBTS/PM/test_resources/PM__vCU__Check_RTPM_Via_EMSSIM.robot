*** Settings ***
Documentation
...  This TC is starting EMSSIM session and waits for RTPM data files to be generated.
...  NMS must be disconnected before setting up EMSS.
...  RTPM parameters are activated through EMSSIM session.
...  Once RTPM data files are generated, they are combined into .pl human readable file which must contain
...  MRBTS ID and RTPM counters.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vCU__Check_RTPM_Via_EMSSIM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29682
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29682 - Initial TAT creation

    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  FEATURE-CB009067

    Step1: Activate RTPM And Save RTPM Data File
    Step2: Check RTPM Data File


Step1: Activate RTPM And Save RTPM Data File
    Log  \nStep1: Activate RTPM And Save RTPM Data File  console=true
    Rtpm Activate  bts_id=${VCU_MRBTS_ID}
    Rtpm Clean  bts_id=${VCU_MRBTS_ID}
    Log  Wait for RTPM files to be generated.  console=true
    Wait For Rtpm After Test  bts_id=${VCU_MRBTS_ID}
    Run Emssim Command  rtpm_parse  bts_id=${VCU_MRBTS_ID}
    Rtpm Deactivate  bts_id=${VCU_MRBTS_ID}


Step2: Check RTPM Data File
    Log  \nStep2: Check RTPM Data File  console=true
    Run  cp /home/flexi${VCU_MRBTS_ID}/UPLOADS/KEYSTATS/RTPM/RTPM_Data.pl ${TEST_RESULTS_DIR}/RTPM_Data.pl
    ${rtpm_data_file_location}  Set Variable  ${TEST_RESULTS_DIR}/RTPM_Data.pl
    Log  ${rtpm_data_file_location} is verified to contain MRBTS ID and PM counters.  console=true
    ${mrbts_id_exists}  Run  grep -E MRBTS-${VCU_MRBTS_ID} -m 1 -o ${rtpm_data_file_location}
    ${counters_exist}  Run  grep -E "\\"M[0-9]+\\"\\s=>\\s\\{" -m 1 -o /home/flexi${VCU_MRBTS_ID}/UPLOADS/KEYSTATS/RTPM/RTPM_Data.pl
    Should Not Be Empty  ${mrbts_id_exists}  ${rtpm_data_file_location} does not contain MRBTS-${VCU_MRBTS_ID}.
    Should Not Be Empty  ${counters_exist}  ${rtpm_data_file_location} does not contain RTPM counters.


TC Setup
    Common VCU Setup
    Modify Resource Search Order  PM__vCU__Check_RTPM_Via_EMSSIM
    Start Emss Simulator  ${VCU_MRBTS_ID}  ${VCU_OAM_IP}


TC Teardown
    Stop Emss Simulator  ${VCU_MRBTS_ID}
    Common VCU Teardown