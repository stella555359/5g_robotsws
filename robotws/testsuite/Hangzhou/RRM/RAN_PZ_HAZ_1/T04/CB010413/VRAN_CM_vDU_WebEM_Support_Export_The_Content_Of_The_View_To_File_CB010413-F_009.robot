*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot



*** Keywords ***
VRAN_CM_vDU_WebEM_Support_Export_The_Content_Of_The_View_To_File_CB010413-F_009
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for RAN_ST_CB010413_009-F_vDU_vCU_WebEM support export the content of the view to a file.docx
    ...    Only check partial parameters on vDU of this case.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.08.2024 - New case.
    Log To Console    ${TEST_NAME} start.    console=${True}
    Step 1: Check Data Between Exported File And WebPage Of VNFC Status
    Step 2: Check Data Between Exported File And WebPage Of Cells Status
    Step 3: Check Data Between Exported File And WebPage Of Network Slicing Status
    Step 4: Check Files Exported From ALD Status Are Not Empty

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Get Vairables For This Case

Case Postcondition
    Log To Console    \n Case Postcondition
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Logout And Close WEBEM
    Common Test Teardown For AIC
    SSHLibrary.Close All Connections

Transfer CSV File
    [Arguments]    ${csv_file}
    ${f_content}    OperatingSystem.Get File    ${csv_file}    encoding=UTF-8-sig
    Comment    ${f_content}    Replace String    ${f_content}    \u2013    -
    ${head_line}    Fetch From Left    ${f_content}    \n
    log to console    ${head_line.strip()}
    ${data_rows}    Set Variable    ${f_content.replace("${head_line}","").strip()[:-1].split('"\\n')}
    Log List    ${data_rows}
    ${col_names}    Split String    ${head_line.strip().upper()}    ,
    ${row_values}    Create List
    FOR    ${row}    IN    @{data_rows}
        Should Start With    ${row}    "
        ${values}    Split String    ${row[1:].strip()}    ","
        Append To List    ${row_values}    ${values}
    END
    [Return]    ${col_names}    ${row_values}

vDu WebEM Get Detail Table Row Datas Of Clicked Element
    ${detals_table_elements}    Selenium2Library.Get WebElements    //ui-webem-details-section
    ${detals_row_elements}    Selenium2Library.Get WebElements    //ui-webem-detail-data-row
    ${dic_data}    Create Dictionary
    FOR    ${element}    IN    @{detals_row_elements}
        ${row_text}    Selenium2Library.Get Text    ${element}
        ${key_value}    Split String    ${row_text}    :
        Set To Dictionary    ${dic_data}    ${key_value[0].strip().upper()}    ${key_value[1].strip()}
    END
    Log Dictionary    ${dic_data}
    [Return]    ${dic_data}

vDU WebEM Get Row Datas Of Object Randomly
    Run Keyword And Continue On Failure    Wait Until Element Is Visible    //p-card
    ${web_elements}    Selenium2Library.Get WebElements    //p-card
    ${p_card_count}    Get Length    ${web_elements}
    Return From Keyword If    '${p_card_count}'=='0'
    ${index}    Evaluate    random.randint(0, ${p_card_count-1})    modules=random, sys
    Click Element    ${web_elements[${index}]}
    Open Details Panel
    ${dic_data}    vDu WebEM Get Detail Table Row Datas Of Clicked Element
    [Return]    ${dic_data}

vDU WebEM Get gNB vDU Properties
    vDU WebEM Go To By Site Bar Menu    Status    Site Properties
    ${row_count}    Selenium2Library.Get Element Count    //vdu-status-properties-panel//tr
    ${dic_vDU_properties}    Create Dictionary
    FOR    ${i}    IN RANGE    ${1}    ${row_count+1}
        ${key}    Selenium2Library.Get Text    //vdu-status-properties-panel//tr[${i}]/td[1]
        ${value}    Selenium2Library.Get Text    //vdu-status-properties-panel//tr[${i}]/td[2]
        Set To Dictionary    ${dic_vDU_properties}    ${key}    ${value}
    END
    [Return]    ${dic_vDU_properties}

Get Vairables For This Case
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123    ${TEST_LOG_DIRECTORY}
    Log Variables
    ${dic_vDU_properties}    vDU WebEM Get gNB vDU Properties
    Set Test Variable    ${MRBTS_NAME}    ${dic_vDU_properties["Name"].strip()}
    Set Test Variable    ${MRBTS_ID}    ${dic_vDU_properties["MRBTS ID"].strip()}
    ${TEST_DATAS}    Create Dictionary    VNFC Status=VNFC_status    Radio Modules Status=Radio_modules_status
    ...    Cells Status=Cells_status    Network Slicing Status=Network_Slicing_status
    Set Test Variable    ${TEST_DATAS}

Check Row Values
    [Arguments]    ${val_web}    ${col_index}    ${row_values}
    ${is_val_found}    Set Variable    ${False}
    FOR    ${row_value}    IN    @{row_values}
        ${is_val_found}    Run Keyword And Return Status    Should Be Equal As Strings    ${val_web}    ${row_value[${col_index}]}    ignore_case=True
        Exit For Loop If    ${is_val_found}
    END
    Should Be True    ${is_val_found}

Check Exported File Of ALD Status Is Not Empty
    [Arguments]    ${header}
    Wait Element Visible And Click    //p-button[@id="export-button"]/button
    Sleep    3s
    ${rc}    ${output}    Run And Return Rc And Output    ls ${TEST_LOG_DIRECTORY} | grep ${header} | grep .csv
    Should Match Regexp    ${output}    ${header}_MRBTS-${MRBTS_ID}_${MRBTS_NAME}_\[0-9\]\{8\}-\[0-9\]\{4\}.csv
    File Should Not Be Empty    ${TEST_LOG_DIRECTORY}/${output.strip()}

Step ${index}: Check Data Between Exported File And WebPage Of ${page}
    Log To Console    Step ${index}: Check Data Between Exported File And WebPage Of ${page}
    ${header}    Get From Dictionary    ${TEST_DATAS}    ${page}
    vDU WebEM Go To By Site Bar Menu    Status    ${page}
    ${dic_data}    vDU WebEM Get Row Datas Of Object Randomly
    Selenium2Library.Click Button    //p-button[@id="export-button"]/button
    Sleep    3s
    ${rc}    ${output}    Run And Return Rc And Output    ls ${TEST_LOG_DIRECTORY} | grep ${header} | grep .csv
    Should Match Regexp    ${output}    ${header}_MRBTS-${MRBTS_ID}_${MRBTS_NAME}_\[0-9\]\{8\}-\[0-9\]\{4\}.csv
    ${col_names}    ${row_values}    Transfer CSV File    ${TEST_LOG_DIRECTORY}/${output.strip()}
    Log List    ${col_names}
    Log List    ${row_values}
    ${param_names}    Get Dictionary Keys    ${dic_data}
    FOR    ${param_name}    IN    @{param_names}
        ${col_index}    Get Index From List    ${col_names}    ${param_name}
        ${val_web}    Set Variable    ${dic_data["${param_name}"]}
        ${ret}    Run Keyword And Return Status    Check Row Values    ${val_web}    ${col_index}    ${row_values}
    END

Step ${index}: Check Files Exported From ALD Status Are Not Empty
    Log To Console    Step ${index}: Check Files Exported From ALD Status Are Not Empty
    vDU WebEM Go To By Site Bar Menu    Status    ALD Status
    Wait Element Visible And Click    ${RET_STATUS_VIEW}
    Check Exported File Of ALD Status Is Not Empty    RET_status
    Wait Element Visible And Click    ${RAE_STATUS_VIEW}
    Check Exported File Of ALD Status Is Not Empty    RAE_status
    Wait Element Visible And Click    ${MHA_STATUS_VIEW}
    Check Exported File Of ALD Status Is Not Empty    MHA_status
