*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_common.robot

*** Variables ***
@{check_column}
...   Alarm number   Adaptation   Release   Alarm text   Alarm type   Probable cause
...   Meaning   Effect   Instructions   Severity information

&{search_xpath}
# ...   Look for=//input[@id='quickSearchValue']
...   Alarm number=//input[@id='advPage:alarm_number']
...   Alarm text=//input[@id='advPage:alarm_text']
...   Alarm type=//input[@id='advPage:alarm_type']
...   Probable cause=//input[@id='advPage:probable_cause']
# ...   Meaning=//input[@id='advPage:alarm_meaning']
# ...   Effect=//input[@id='advPage:alarm_effect']
...   Supplementary information fields=//input[@id='advPage:alarm_sup_info_fields']
# ...   Instructions=//input[@id='advPage:alarm_instructions']
...   Severity information=//input[@id='advPage:alarm_severity_info']
# ...   Cancelling=//input[@id='advPage:alarm_cancelling']

&{search_value}
# ...   Look for=problem
...   Alarm number=710
...   Alarm text=PROBLEM
...   Alarm type=equipment
...   Probable cause=Indeterminate
# ...   Meaning=hardware
# ...   Effect=network
...   Supplementary information fields=cells
# ...   Instructions=X2U
...   Severity information=Critical
# ...   Cancelling=cancelled

*** Keywords ***
FM_Check_OIB_Functionality_and_Content
    Step1: Switch To Alarms Page
    Step2: Check Alarm Details
    Step3: Check Search Operation

Case Setup: FM_Check_OIB_Functionality_and_Content
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
    selenium_netact.open_sub_page    category_xpath=//span[text()='User Assistance']
    ...    page_xpath=//span[text()='Object Information Browser']   page_name=OIB
    Sleep   15s

Case Teardown: FM_Check_OIB_Functionality_and_Content
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   Common Case Teardown

Step1: Switch To Alarms Page
    #Enter into the Alarms Page
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="tabBar__topLevel_4"]
    selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_4"]
    Sleep   10s
    #Select Adaptation
    selenium_netact.write_value_and_enter   input_xpath=//*[@id="neDropDown"]   value=Nokia AirScale BTS 5G (com.nokia.nrbts)
    Sleep   10s
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="suggestion:suggest"]/tbody/tr/td[2]
    selenium_netact.Click Button   button_xpath=//*[@id="suggestion:suggest"]/tbody/tr/td[2]
    Sleep   10s
    ${check_adaption} =   selenium_netact.execute_script   script_cmd=return document.querySelector('#neDropDown').value
    Should Be Equal   ${check_adaption}   Nokia AirScale BTS 5G (com.nokia.nrbts)
    #Select Release
    #Click Drop Down List Button
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="releaseDropDowncomboboxField"]
    selenium_netact.write_value_and_enter   input_xpath=//*[@id="releaseDropDowncomboboxField"]   value=${NIDD_RELEASE}
    Sleep   10s
    #Check NIDD Version
    ${check_version}   selenium_netact.Get Element Attribute   elem_xpath=//*[@id="releaseDropDowncomboboxField"]   attr_name=value
    Log To Console   \nPage Objects: Check NIDD Verison: ${check_version}

    #Set items per page
    selenium_netact.write_value_and_enter   input_xpath=//*[@id="amdataTable:cpageSize"]   value=200
    Sleep   10s
    #Check Total Alarm Number
    ${ALARM_NUMBER}   selenium_netact.execute_script   script_cmd=return document.getElementById('resultsCount').firstElementChild.textContent
    ${ALARM_NUMBER}   Strip String   ${ALARM_NUMBER}
    Set Test Variable   ${ALARM_NUMBER}
    Log To Console   Alarm Total Number: ${ALARM_NUMBER}

    #Set Column Settings to Select All
    selenium_netact.Click Button   button_xpath=//a[@id="amdataTable:colsetpanel"]
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="divColSetting"]
    selenium_netact.Click Button   button_xpath=//*[@id="defaultBtn"]
    Sleep   10s
    selenium_netact.Click Button   button_xpath=//*[@id="selectall"]
    Sleep   10s
    selenium_netact.Click Button   button_xpath=//*[@id="apply"]
    sleep   10s
    Wait Until Keyword Succeeds   20s   5s   Check Ajax Status

    #Export Excel
    selenium_netact.Click Button   button_xpath=//*[@id="amdataTable:exportpanel"]
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="divExpSetting"]
    Sleep   10s
    selenium_netact.Click Button   button_xpath=//*[@id="defaultExpBtn"]
    Sleep   10s
    selenium_netact.Click Button   button_xpath=//*[@id="export_xls"]
    Sleep   10s
    selenium_netact.Click Button   button_xpath=//*[@id="exportAllBtn"]
    sleep   10s
    OperatingSystem.File Should Exist   path=${OUTPUT_DIR}/Alarms_com.nokia.nrbts_${NIDD_RELEASE}_Alldata.xls

Step2: Check Alarm Details
    Download_NIDD_Alarm_Manual_Page
    ...   domain=${DomainName}
    ...   product=${ProductName}
    ...   productRelease=${ProductRelName}
    ...   file_path=${OUTPUT_DIR}/ManualPagesExport_${NIDD_RELEASE}.zip
    OperatingSystem.Run   unzip -o ${OUTPUT_DIR}/ManualPagesExport_${NIDD_RELEASE}.zip -d ${OUTPUT_DIR}/ManualPagesExport_${NIDD_RELEASE}/
    ${alarm_check_number}   OperatingSystem.Run   ls -l ${OUTPUT_DIR}/ManualPagesExport_${NIDD_RELEASE}/ | grep "^-" | wc -l
    ${alarm_check_number}   Strip String   ${alarm_check_number}
    Should Be Equal   ${alarm_check_number}   ${ALARM_NUMBER}

    ${table_data}   Get Table All Data
    ${table_header}   Remove From List   ${table_data}   0
    FOR   ${column}    IN RANGE    len(@{table_header})
    # \   ${status}   Get Index From List   ${check_column}   ${table_header[${column}]}
    # \   Continue For Loop If   '${status}'=='-1'
       Continue For Loop If   '${table_header[${column}]}' not in ${check_column}
       Check Row Data Not Empty    ${table_data}   ${column}
    END

    Set Test Variable   ${ALL_TABLE_HEADER}   ${table_header}
    Set Test Variable   ${ALL_TABLE_DATA}   ${table_data}
    Sleep   10s

Get Table All Data
    ${js_script}   Set Variable   let rows = document.getElementById("amdataTable:wrList").rows; let table_data = [];
    ${js_script}   Set Variable   ${js_script} for (let i = 0; i < rows.length; i++) { let cells = rows[i].cells; let row_data = [];
    ${js_script}   Set Variable   ${js_script} for (let j = 0; j < cells.length; j++) { let value = cells[j].textContent; row_data.push(value);}
    ${js_script}   Set Variable   ${js_script} table_data.push(row_data);} return table_data;
    ${table_data}   selenium_netact.execute_script   script_cmd=${js_script}
    [Return]   ${table_data}

Check Row Data Not Empty
    [Arguments]   ${table_data}   ${column}
    FOR   ${row_data}   IN   @{table_data}
       Should Not Be Empty   ${row_data[${column}]}
    END

Step3: Check Search Operation
    selenium_netact.Click Button   button_xpath=//*[@id='genToAdvSearch']
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id='advSearchPanel']
    Sleep   10s

    FOR   ${key}   IN   @{search_value.keys()}
       Check Search Operation Condition   ${key}   ${search_xpath['${key}']}   ${search_value['${key}']}
    END

Check Search Operation Condition
    [Arguments]   ${key}   ${search_xpath}   ${search_value}
    selenium_netact.Click Button   button_xpath=//*[@id='advPage:clearsearchAdvBtn']
    Sleep   10s
    Wait Until Keyword Succeeds   20s   5s   Check Ajax Status
    selenium_netact.write_value_and_enter   input_xpath=${search_xpath}  value=${search_value}
    Sleep   10s
    Wait Until Keyword Succeeds   20s   5s   Check Ajax Status
    ${get_count}   selenium_netact.execute_script   script_cmd=return document.getElementById('resultsCount').firstElementChild.textContent
    ${get_count}   Strip String   ${get_count}
    ${column}   Run Keyword If   '${key}'=='Look for'   Set Variable   -1
    ...   ELSE   Get Index From List   ${ALL_TABLE_HEADER}   ${key}

    ${check_count}   Get Table Data Expected Count   table_data=${ALL_TABLE_DATA}   look_for=${search_value}   column=${column}
    Log To Console   ${key}: (search: ${search_value})(true: ${get_count})(check: ${check_count})
    Run Keyword If   '${check_count}'!='0'   Should Be Equal As Integers   ${get_count}   ${check_count}

Get Table Data Expected Count
    [Arguments]   ${table_data}   ${look_for}   ${column}
    ${count}   Set Variable   ${0}
    FOR   ${row_data}   IN   @{table_data}
       ${status}   Run Keyword If   '${column}'=='-1'   Check Row Data Expected   row_data=${row_data}   look_for=${look_for}
       ...   ELSE   Run Keyword And Return Status    Should Contain   ${row_data[${column}]}   ${look_for}
       ${count}   Set Variable If   ${status}   ${count+1}
       ...   not ${status}   ${count}
    END
    [Return]   ${count}

Check Row Data Expected
    [Arguments]   ${row_data}   ${look_for}
    ${status}   Set Variable   ${False}
    FOR   ${cell_data}   IN   @{row_data}
       Continue For Loop If   '${cell_data.find('${look_for}')}'=='-1'
       ${status}   Set Variable If
       ...   '${cell_data.find('${look_for}')}'!='-1'   ${True}
       ...   '${cell_data.find('${look_for}')}'=='-1'   ${False}
       Exit For Loop If   '${cell_data.find('${look_for}')}'!='-1'
    END
    [Return]   ${status}

