*** Settings ***
Documentation
    ...  Open Operations History menu and check if Operation name, Operation source, Operation target, Start time, Finished time
    ...  User name, Session ID, IP address and Status are visible.
    ...  Check the number of operation history to be <= 100.
    ...  Sort the operation history table.
    ...  Trigger block/unblock cell on vDU and check operation history.
    ...  Reset vDU and check operation history after vDU startup..

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Mandatory. Time for vDU to be onAir after reset.


*** Keywords ***
TC__WebEM__vDU__BTS_EM_Operation_History_for_gNB_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25055
    ...
    ...  ******************
    ...  - 11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25055 - Initial TAT creation
    ...  - 27.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28775 - Check NMS action if needed
    ...  - 31.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28949 - Check for Trigger reset operation in more lines

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB009444

    Step1:Check Operations History Menu
    Step2:Check The Number Of Operation History
    Step3:Sort The Operation History Table
    Step4:Trigger Block/unblock Cell On VDU And Check Operation History
    Step5:Reset VDU And Check Operation History After VDU Startup


Step1:Check Operations History Menu
    Log  \nStep1:Check Operations History menu  console=true
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}
    Wait Until Element Is Clicked  //*[contains(text(), "Operations History")]
    Log  Operations History is open![OK]  console=true
    Sleep  5s  This sleep is for page to be uploaded.
    ${title_list}  Create List  Operation name  Operation source  Operation target  Start time  Finished time  User name  Session ID  IP address
    ...  Status
    FOR  ${title}  IN  @{title_list}
        Page Should Contain Element  //*[contains(text(), "${title}")]
        Log  ${title} is visible on Operation History page![OK]  console=true
    END


Step2:Check The Number Of Operation History
    Log  \nStep2:Check the number of operation history  console=true
    Page Should Contain Element  //*[contains(text(), "Display up to 100 operations")]
    Log  "Display up to 100 operations" message is visible![OK]  console=true
    ${number_of_operations}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Set Test Variable  ${NUMBER_OF_OPERATIONS}
    IF  ${NUMBER_OF_OPERATIONS} <= 100
        Log  Number of operations in Operation History is ${NUMBER_OF_OPERATIONS}![OK]
    ELSE
        Fail  Number of operations in Operation History is ${NUMBER_OF_OPERATIONS} and should be <= 100![NOK]
    END


Step3:Sort The Operation History Table
    Log  \nStep3:Sort the operation history table  console=true
    ${last_operation_date_before}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[4]
    ${last_day_before}  ${last_month_before}  Fetch Date And Month  ${last_operation_date_before}
    ${first_operation_date_before}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${NUMBER_OF_OPERATIONS}]/td[4]
    ${first_day_before}  ${first_month_before}  Fetch Date And Month  ${first_operation_date_before}
    IF  '${last_day_before}' >= '${first_day_before}' or '${last_month_before}' >= '${first_month_before}'
        Log  All operations are arranged by time default, descending![OK]  console=true
    ELSE
        Fail  All operations are not arranged by time default, descending![NOK]
    END
    Click Element  //*[contains(@class, "p-datatable-table ng-star-inserted")]/thead/tr/th[4]/p-sorticon/i
    ${last_operation_date_after}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[4]
    ${last_day_after}  ${last_month_after}  Fetch Date And Month  ${last_operation_date_after}
    ${first_operation_date_after}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${NUMBER_OF_OPERATIONS}]/td[4]
    ${first_day_after}  ${first_month_after}  Fetch Date And Month  ${first_operation_date_after}
    IF  '${last_day_after}' <= '${first_day_after}' or '${last_month_after}' <= '${first_month_after}'
        Log  All operations are arranged by time ascending![OK]  console=true
    ELSE
        Fail  All operations are not arranged by time ascending![NOK]
    END
    Click Element  //*[contains(@class, "p-datatable-table ng-star-inserted")]/thead/tr/th[4]/p-sorticon/i
    ${last_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[4]
    ${last_day}  ${last_month}  Fetch Date And Month  ${last_operation_date}
    ${first_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${NUMBER_OF_OPERATIONS}]/td[4]
    ${first_day}  ${first_month}  Fetch Date And Month  ${first_operation_date}
    IF  '${last_day}' >= '${first_day}' or '${last_month}' >= '${first_month}'
        Log  All operations are arranged by time descending![OK]  console=true
    ELSE
        Fail  All operations are not arranged by time descending![NOK]
    END


Step4:Trigger Block/unblock Cell On VDU And Check Operation History
    Log  \nStep4:Trigger block/unblock cell on vDU and check operation history  console=true
    Click Element  ${VDU_SITE_VIEW}
    Sleep  5s  This sleep is for page to be uploaded.
    Log  Site View menu is open![OK]  console=true
    ${cell_id}  Get Text  //*[@id="cell_column"]/div[2]/div/vdu-site-view-radio-module-tile/div/div/div[1]/div/vdu-site-view-vdu-cell-tile/div/div[2]
    ${cell_options}  Catenate  SEPARATOR=  //*[@id="cell_column"]/div[2]/div/vdu-site-view-radio-module-tile/div/div/div[1]/div/vdu-site-view-
    ...  vdu-cell-tile/div/div[3]/ui-webem-button-with-menu/ui-webem-button/p-button/button/span[1]
    Click Element  ${cell_options}
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Block Cell')]
    Wait Until Element Is Visible  //*[@class="main-content"]/as-split/div[2]/div/div/vdu-site-view/p-confirmdialog/div/div  30
    Wait Until Element Is Clicked  //*[contains(@class, 'p-confirm-dialog-accept')]  90  10
    Wait Until Keyword Succeeds  300s  5s
    ...  Check The Specific Cell From VDU  ${cell_id}  blocking_state=${BLOCKED}
    Log  Block cell was performed, cell ${cell_id} is Blocked and Disabled![OK]  console=true
    Click Element  ${cell_options}
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Unblock Cell')]
    Wait Until Element Is Visible  //*[@class="main-content"]/as-split/div[2]/div/div/vdu-site-view/p-confirmdialog/div/div  30
    Wait Until Element Is Clicked  //*[contains(@class, 'p-confirm-dialog-accept')]  90  10
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  blocking_state=${UNBLOCKED}  operational_state=${ENABLED}
    Log  Unblock cell was performed, all cells are Online and Enabled![OK]  console=true
    Verify Operation History After Cell Block/unblock


Step5:Reset VDU And Check Operation History After VDU Startup
    Log  \nStep5:Reset vDU and check operation history after vDU startup  console=true
    Click Element  ${VDU_DASHBOARD}
    Log  Dashboard is open![OK]  console=true
    Reset VDU From VDU WebEM  ${RECOVERY_TIMEOUT}
    Verify Operation History After VDU Reset


Fetch Date And Month
    [Arguments]  ${operation_date}

    ${day}  Fetch From Left  ${operation_date}  .
    ${date_without_day}  Fetch From Right  ${operation_date}  ${day}.
    ${month}  Fetch From Left  ${date_without_day}  .

    [Return]  ${day}  ${month}


Verify Operation History After Cell Block/unblock
    Log  Verify operation history after cell block/unblock  console=true
    Click Element  ${VDU_OPTIONS_MENU}
    Wait Until Element Is Clicked  //*[contains(text(), "Operations History")]
    Sleep  5s  This sleep is for page to be uploaded.
    Log  Operation History is open![OK]  console=true
    ${unblock_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[1]
    IF  '${unblock_operation_name}' == 'Cell unblock'
        Log  ${unblock_operation_name} operation is visible in Operations History![OK]  console=true
    ELSE
        Fail  Cell unblock operation is not visible in Operations History![NOK]
    END
    ${unblock_operation_status}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[9]
    IF  '${unblock_operation_status}' == 'Successful'
        Log  ${unblock_operation_status} for cell unblock is visible in Operations History![OK]  console=true
    ELSE
        Fail  Successful for cell unblock is not visible in Operations History![NOK]
    END
    ${unblock_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[4]
    ${test_date}  DateTime.Get Current Date  result_format=%d.%m.%Y
    Set Test Variable  ${TEST_DATE}
    Should Contain  ${unblock_operation_date}  ${TEST_DATE}  Start time for Cell Unblock is not visible!
    ${block_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[1]
    IF  '${block_operation_name}' == 'Cell block'
        Log  ${block_operation_name} operation is visible in Operations History![OK]  console=true
    ELSE
        Fail  Cell block operation is not visible in Operations History![NOK]
    END
    ${block_operation_status}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[9]
    IF  '${block_operation_status}' == 'Successful'
        Log  ${block_operation_status} for cell unblock is visible in Operations History![OK]  console=true
    ELSE
        Fail  Successful for cell unblock is not visible in Operations History![NOK]
    END
    ${block_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[4]
    Should Contain  ${block_operation_date}  ${TEST_DATE}  Start time for Cell Block is not visible!


Verify Operation History After VDU Reset
    Log  Verify operation history after vDU reset  console=true
    ${nms_connection}  Check If vDU Is Connected To NMS
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}
    Wait Until Element Is Clicked  //*[contains(text(), "Operations History")]
    Sleep  5s  This sleep is for page to be uploaded.
    Log  Operation History is open![OK]  console=true
    IF  ${nms_connection}
        Verify Operation History After vDU Reset With NMS Connected
    ELSE
        Verify Operation History After vDU Reset Without NMS Connected
    END


Verify Operation History After vDU Reset With NMS Connected
    ${nms_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[1]
    IF  '${nms_operation_name}' == 'NE3S_UPLOAD_FM'
        Log  ${nms_operation_name} is visible in Operations History![OK]  console=true
    ELSE
        Fail  NE3S_UPLOAD_FM is not visible in Operations History![NOK]
    END
    ${nms_operation_status}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[9]
    IF  '${nms_operation_status}' == 'Successful'
        Log  ${nms_operation_status} for NE3S_UPLOAD_FM is visible in Operations History![OK]  console=true
    ELSE
        Fail  Successful for NE3S_UPLOAD_FM is not visible in Operations History![NOK]
    END
    ${nms_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[4]
    Should Contain  ${nms_operation_date}  ${TEST_DATE}  Start time for NE3S_UPLOAD_FM is not visible!
    FOR  ${index}  IN RANGE  2  5
        ${operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${index}]/td[1]
        ${last_index}  Set Variable  ${index}
        IF  '${operation_name}' == 'NE3S_UPLOAD_FM'
            CONTINUE
        ELSE IF  '${operation_name}' == 'Trigger reset operation'
            Log  ${operation_name} is visible in Operations History![OK]  console=true
            BREAK
        ELSE
            Fail  NE3S_UPLOAD_FM or Trigger reset operation is not visible in Operations History![NOK]
        END
    END
    ${reset_operation_status}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${last_index}]/td[9]
    IF  '${reset_operation_status}' == 'Successful'
        Log  ${reset_operation_status} for reset vDU is visible in Operations History![OK]  console=true
    ELSE
        Fail  Successful for reset vDU is not visible in Operations History![NOK]
    END
    ${reset_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${last_index}]/td[4]
    Should Contain  ${reset_operation_date}  ${TEST_DATE}  Start time for vDU Reset is not visible!
    ${unblock_index}  Evaluate  ${last_index} + 1
    ${unblock_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${unblock_index}]/td[1]
    IF  '${unblock_operation_name}' == 'Cell unblock'
        Log  ${unblock_operation_name} operation is still visible in Operations History![OK]  console=true
    ELSE
        Fail  Cell unblock operation is not still visible in Operations History![NOK]
    END
    ${block_index}  Evaluate  ${unblock_index} + 1
    ${block_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${block_index}]/td[1]
    IF  '${block_operation_name}' == 'Cell block'
        Log  ${block_operation_name} operation is still visible in Operations History![OK]  console=true
    ELSE
        Fail  Cell block operation is not still visible in Operations History![NOK]
    END


Verify Operation History After vDU Reset Without NMS Connected
    ${reset_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[1]
    IF  '${reset_operation_name}' == 'Trigger reset operation'
        Log  ${reset_operation_name} is visible in Operations History![OK]  console=true
    ELSE
        Fail  Trigger reset operation is not visible in Operations History![NOK]
    END
    ${reset_operation_status}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[9]
    IF  '${reset_operation_status}' == 'Successful'
        Log  ${reset_operation_status} for reset vDU is visible in Operations History![OK]  console=true
    ELSE
        Fail  Successful for reset vDU is not visible in Operations History![NOK]
    END
    ${reset_operation_date}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[4]
    Should Contain  ${reset_operation_date}  ${TEST_DATE}  Start time for vDU Reset is not visible!
    ${unblock_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[1]
    IF  '${unblock_operation_name}' == 'Cell unblock'
        Log  ${unblock_operation_name} operation is still visible in Operations History![OK]  console=true
    ELSE
        Fail  Cell unblock operation is not still visible in Operations History![NOK]
    END
    ${block_operation_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[3]/td[1]
    IF  '${block_operation_name}' == 'Cell block'
        Log  ${block_operation_name} operation is still visible in Operations History![OK]  console=true
    ELSE
        Fail  Cell block operation is not still visible in Operations History![NOK]
    END

Check If vDU Is Connected To NMS
    ${nms_parameters}  vdu.Get NMS
    ${status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${nms_parameters}  N/A
    IF  ${status}
        Log  vDU is connected to NMS!  console=true
        RETURN  ${TRUE}
    ELSE
        Log  vDU is not connected to NMS!  console=true
        RETURN  ${FALSE}
    END


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__BTS_EM_Operation_History_for_gNB_vDU


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
