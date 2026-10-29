*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_common.robot
Library    ../Resource/compare_oib_excel.py

*** Variables ***
${WEB_DOWNLOAD_DIR}    ${OUTPUT_DIR}

*** Keyword ***
PM_Check_OIB_Functionality_and_Content
    Step1: PM_Open Object Information Browser
    Step2: PM_Look For and Click Search Button
    Step3: PM_Export PM Measurement
    Step4: PM_Export PM Counter
    Step5: PM_Do Check on Parameters

Step1: PM_Open Object Information Browser
    selenium_netact.open_sub_page    category_xpath=//span[text()='User Assistance']
    ...    page_xpath=//span[text()='Object Information Browser']   page_name=OIB
    Sleep    6s

Step2: PM_Look For and Click Search Button
    #click 'Measurement'
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_1"]
    #fill in 'Radio'
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.write_value_and_enter   input_xpath=//*[@id="quickSearchValue"]   value=Radio
    #click 'search'
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="searchBtnDiv"]
    Sleep    6s
    #clear search result
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="clearsearchBtn"]

Step3: PM_Export PM Measurement
    #click 'Measurement'
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_1"]
    Sleep    6s
    #fill in '5G'
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.write_value_and_enter   input_xpath=//*[@id="neDropDown"]
    ...   value=Nokia AirScale BTS 5G (nokgnb)
    Sleep    4s
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="suggestion:suggest"]/tbody/tr/td[2]
    Sleep    20s
    Wait Until Keyword Succeeds   120s   10s   Check Ajax Status
    #export NIDD_RELEASE Measurement
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="releaseDropDowncomboboxField"]
    ...   value=${NIDD_RELEASE}
    Sleep    6s
    Wait Until Keyword Succeeds   120s   10s   Check Ajax Status
    Sleep    6s
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="pmdataTable:exportpanel"]/span
    Sleep    6s
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="etype_panel"]/tbody/tr[3]/td/div[2]/label
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="etype_panel"]/tbody/tr[7]/td/div[2]/label
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="exportAllBtn"]
    Sleep    6s

Step4: PM_Export PM Counter
    #click 'Measurement'
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_2"]
    Sleep    6s
    #fill in '5G'
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value   input_xpath=//*[@id="neDropDown"]
    ...   value=Nokia AirScale BTS 5G (nokgnb)
    Sleep    4s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="suggestion:suggest"]/tbody/tr/td[2]
    Sleep    6s
    Wait Until Keyword Succeeds   120s   10s   Check Ajax Status
    #export NIDD_RELEASE Counter
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="releaseDropDowncomboboxField"]
    ...   value=${NIDD_RELEASE}
    Sleep    6s
    Wait Until Keyword Succeeds   120s   10s   Check Ajax Status
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="pmdataTable:exportpanel"]/span
    Sleep    6s
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="etype_panel"]/tbody/tr[3]/td/div[2]/label
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="etype_panel"]/tbody/tr[7]/td/div[2]/label
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="exportAllBtn"]
    Sleep    6s

Step5: PM_Do Check on Parameters
    Set Test Variable    ${xpath_1}    //*[@id="cuscolumns_panel"]/tbody/tr[2]/td/table/tbody/tr[7]/td[1]/label
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="pmdataTable:colsetpanel"]/span
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=${xpath_1}
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="apply"]
    Sleep    6s
    Wait Until Keyword Succeeds   120s   10s   Check Ajax Status
    Wait Until Keyword Succeeds    3times    10s    selenium_netact.Click Button   button_xpath=//*[@id="pmdataTable:wrList:2:2:pmDetailId"]
    Run keyword and ignore error    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="aibDetail"]/div[1]/div[1]
    Sleep    10s
    ${row_num}=    Set Variable    0
    FOR    ${i}    IN RANGE    1    50    1
       ${context}=    selenium_netact.get_elem_text   elem_xpath=//*[@id="aibDetail"]/div[${i}]/div[1]
       Run Keyword If   'Description' in '${context}'   Run Keyword   Exit For Loop
    END
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="closeButton"]

Case Setup: PM_Check_OIB_Functionality_and_Content
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}

Case Teardown: PM_Check_OIB_Functionality_and_Content
    # Remove File    ${WEB_DOWNLOAD_DIR}/MOC_Content_from_com.nokia.srbts.nrbts-${NIDD_VERSION}-CM.xml
    # Remove File    ${WEB_DOWNLOAD_DIR}/Objects_com.nokia.srbts.nrbts_${NIDD_VERSION}_Currentpagedata.xls
    # Remove File    ${WEB_DOWNLOAD_DIR}/Parameters_com.nokia.srbts.nrbts_${NIDD_VERSION}_Currentpagedata.xls
    Run Keyword And Ignore Error    selenium_netact.Logout
    Run Keyword And Ignore Error    selenium_coam.Logout
    Run Keyword And Ignore Error    Common Case Teardown
