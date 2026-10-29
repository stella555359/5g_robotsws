*** Settings ***
Documentation
...  This TC is changing mrbtsId twice on vDU and PM files from /mnt/services/SS_OAM/PMSTAT/(pm_result_files_3GPP/pm_result_files/pm_report_files)
...  must be deleted. vDU is resetting after each change.
...  The purpose of this TC is to clean up PM reports on vDU.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vDU__Clean_Up_PM_Files
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28816
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28816 - TC creation
    ...  - 08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29532 - Specify vdu library
    ...  - 24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29610 - Refactor pod name construction

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf

    Step1: Change Vdu MRBTS Id
    Step2: Check PM Files Are Deleted On Vdu


Step1: Change Vdu MRBTS Id
    Log  \nStep1: Change Vdu MRBTS Id  console=true
    ${dummy_bts_id}  Evaluate  int(${VDU_MRBTS_ID})+1

    ${scf_content}  vdu.Get Scf
    ${scf_content}  Convert To String  ${scf_content}
    Create File  ${TEST_RESULTS_DIR}/Initial_SCF.xml  ${scf_content}
    ${scf_content}  Replace String  ${scf_content}  MRBTS-${VDU_MRBTS_ID}  MRBTS-${dummy_bts_id}
    Create File  ${TEST_RESULTS_DIR}/SCF_with_dummy_mrbtsId.xml  ${scf_content}
    vdu.Perform Commissioning  ${TEST_RESULTS_DIR}/SCF_with_dummy_mrbtsId.xml

    ${ip_adresses}  Create List  ${VDU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=180s
    ${ping_reestablished_status}  Run Keyword And Return Status  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Wait Until Keyword Succeeds  1200  10s  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}

    Set Test Variable  ${DUMMY_BTS_ID}


Step2: Check PM Files Are Deleted On Vdu
    Log  \nStep2: Check PM Files Are Deleted On Vdu  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oampm
    ${pm_reports_directories}  Create List  pm_result_files_3GPP  pm_result_files  pm_report_files
    FOR  ${directory}  IN  @{pm_reports_directories}
        ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VDU_CRAN} -c ${oampm_container_name}
        ...  -- ls -la /mnt/services/SS_OAM/PMSTAT/${directory} | grep MRBTS-${VDU_MRBTS_ID}
        SSHLibrary.Write  ${get_pm_reports_comm}
        ${pm_reports}  SSHLibrary.Read Until Prompt
        ${xml_gz_files}  Get Regexp Matches  ${pm_reports}  .*\\.xml\\.gz
        Should Be Empty  ${xml_gz_files}  There are still PM reports in /mnt/services/SS_OAM/PMSTAT/${directory} location.
    END

    [Teardown]  SSHLibrary.Close Connection


Restore MRBTS Id
    Log  \nRestore MRBTS Id  console=true
    vdu.Perform Commissioning  ${TEST_RESULTS_DIR}/Initial_SCF.xml
    ${ip_adresses}  Create List  ${VDU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=300s
    ${ping_reestablished_status}  Run Keyword And Return Status  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Wait Until Keyword Succeeds  1200  10s  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__Clean_Up_PM_Files


TC Teardown
    Restore MRBTS Id
    Run Keyword And Ignore Error  Remove File  ${TEST_RESULTS_DIR}/Initial_SCF.xml
    Run Keyword And Ignore Error  Remove File  ${TEST_RESULTS_DIR}/SCF_with_dummy_mrbtsId.xml
    Common VDU Teardown