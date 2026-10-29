*** Settings ***
Documentation
    ...  This TC is created to verify the retrieval of all PM Raw Data from the last 24 Hours via M2M Interface, from vCU.
    ...  Generate the token and login.
    ...  Get PM Raw Data with curl command.
    ...  Verify if generated folder(All_PM_Data) contains the next 2 files:
    ...  customer-reports-cmdTrace.txt, resultMapping.json
    ...  and at least one xml.gz file
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot


*** Keywords ***
TC__WebEM__vCU__Get_All_Raw_Data_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25170
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  04.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25170 - Initial TAT creation
    ...  31.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26365 - fix for keyword used from another library (vCU related)
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB007823

    Step 1: Get VCU PM Raw Data
    Step 2: Verify VCU All_PM_Data Files


Step 1: Get VCU PM Raw Data
    Log  \nStep 1: Get vCU PM Raw Data.  console=true
    ${curl_output}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/counters/rawDataFiles  Bearer  ${TOKEN}  --output All_PM_Data.zip
    Set Test Variable  ${CURL_OUTPUT}
    Log  PM Raw Data collected!  console=true


Step 2: Verify VCU All_PM_Data Files
    Log  \nStep 2: Verify vCU All_PM_Data files.  console=true
    Create Directory  ${TEST_RESULTS_DIR}/All_PM_Data
    Run  mv All_PM_Data.zip ${TEST_RESULTS_DIR}
    Run  unzip ${TEST_RESULTS_DIR}/All_PM_Data.zip -d ${TEST_RESULTS_DIR}/All_PM_Data
    Verify if at least one xml.Gz File Exists In VCU All_PM_Data Folder
    OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/All_PM_Data/customer-reports-cmdTrace.txt
    OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/All_PM_Data/resultMapping.json
    Log  All necessary files exist in All_PM_Data folder. [OK]  console=true


Verify If At Least One Xml.Gz File Exists In VCU All_PM_Data Folder
    ${files_list}  OperatingSystem.List Files In Directory  ${TEST_RESULTS_DIR}/All_PM_Data  absolute=True
    FOR  ${file}  IN  @{files_list}
        ${status_file_name}  Run Keyword And Return Status
        ...  Should Match Regexp  ${file}  .*\.xml\.gz
        Run Keyword If  ${status_file_name}
        ...  Return From Keyword
    END
    Fail  There are no xml.gz files in All_PM_Data folder. [NOK]


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Get_All_Raw_Data_By_M2M_Interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
