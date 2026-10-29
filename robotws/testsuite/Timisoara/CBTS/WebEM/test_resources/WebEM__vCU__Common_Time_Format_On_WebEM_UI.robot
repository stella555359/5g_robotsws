*** Settings ***
Documentation
...  This TC is created to verify timezone on CU in the About Element Manager.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/vcu_WebEM_general.robot


*** Keywords ***
TC__WebEM__vCU__Common_Time_Format_On_WebEM_UI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28389
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28389 - Initial TAT creation
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29228 - Update TC to work on release version greater or equal to 25R3
    ...  06.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29520 - Update TC to work on release version greater than 25R3
    ...  ******************

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB012840

    Step1: Verify Timezone In Operations History On CU
    Step2: Verify Timezone In Historical Alarms On CU
    Step3: Verify Timezone In Performance On CU


Step1: Verify Timezone In Operations History On CU
    Log  \nStep1: Verify Timezone In Operations History On CU  console=true
    Wait Until Element Is Clicked  ${VCU_OPTIONS_MENU}
    Wait Until Element Is Clicked  //*[contains(text(),'Operations History')]
    Sleep  7s  Time for page to be updated
    FOR  ${index}  IN RANGE  1  6
        ${start_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${index}]/td[4]
        Should Match Regexp  ${start_timezone}
        ...                  [0-9]{2}\\.[0-9]{2}\\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$
        ...                  In 'Operations History' start timezone is not correctly. [NOK]
        Log  In 'Operations History' start timezone is set correctly on CU.[OK]  console=true
        ${finished_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${index}]/td[5]
        Should Match Regexp  ${finished_timezone}
        ...                  [0-9]{2}\\.[0-9]{2}\\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$
        ...                  In 'Operations History' finished timezone is not correctly on CU. [NOK]
        Log  In 'Operations History' finished timezone is set correctly on CU.[OK]  console=true
    END


Step2: Verify Timezone In Historical Alarms On CU
    Log  \nStep2: Verify Timezone In Historical Alarms On CU  console=true
    Click Element  ${VCU_ALARMS}
    Wait Until Element Is Clicked  //*[@id="/alarm/historical"]/span
    Sleep  7s  Time for page to be updated
    FOR  ${index}  IN RANGE  1  6
        IF  '${VCU_ACTIVE_SW_RELEASE}' < 'vCUCNF26R1'
            ${appeared_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${index}]/td[2]
        ELSE
            ${appeared_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/p-scroller/div/table/tbody[1]/tr[${index}]/td[2]
        END
        Should Match Regexp  ${appeared_timezone}
        ...                  [0-9]{2}\\.[0-9]{2}\\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$
        ...                  In 'Historical Alarms' appeared timezone is not correctly. [NOK]
        Log  In 'Historical Alarms' appeared timezone is set correctly on CU.[OK]  console=true
        IF  '${VCU_ACTIVE_SW_RELEASE}' < 'vCUCNF26R1'
            ${cleared_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${index}]/td[3]
        ELSE
            ${cleared_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/p-scroller/div/table/tbody[1]/tr[${index}]/td[3]
        END
        Should Match Regexp  ${cleared_timezone}
        ...                  [0-9]{2}\\.[0-9]{2}\\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$
        ...                  In 'Historical Alarms' cleared timezone is not correctly. [NOK]
        Log  In 'Historical Alarms' cleared timezone is set correctly on CU.[OK]  console=true
    END


Step3: Verify Timezone In Performance On CU
    Log  \nStep3: Verify Timezone In Performance On CU  console=true
    Click Element  //*[contains(@aria-label, "Performance")]/i
    Wait Until Element Is Clicked  //*[contains(@class,'mdi mdi-format-list-checks p-button-icon p-button-icon-left ng-star-inserted')]  10  2
    Wait Until Element Is Clicked  //span[contains(text(),'NRCELL')]  10  2
    Wait Until Element Is Clicked  //*[contains(text(),'NR X2-C Interface signalling NRCELL level (NX2CC)')]  10  2
    Wait Until Element Is Clicked  //*[@class="node-content-wrapper ng-star-inserted"]/div/div[2]  10  2
    Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/label[1]/div/p-checkbox/div/div[2]  10  2
    Wait Until Element Is Clicked
    ...  xpath:/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[2]/p-footer/ui-webem-button[1]/p-button/button/span  10  2
    Sleep  7s  Time for page to be updated
    FOR  ${index}  IN RANGE  1  6
        ${counter_timezone}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody[2]/tr[${index}]/td[1]
        Should Match Regexp  ${counter_timezone}
        ...                  [0-9]{2}\\.[0-9]{2}\\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} [A-Z]{3}\\+[0-9]{4}$
        ...                  In 'Performance->Counters' timezone is not correctly. [NOK]
        Log  In 'Performance->Counters' timezone is set correctly on CU.[OK]  console=true
    END


TC Setup
    Common VCU Setup
    VCU WebEM Setup
    Modify Resource Search Order  WebEM__vCU__Common_Time_Format_On_WebEM_UI


TC Teardown
    Common VCU Teardown
    VCU WebEM Teardown
