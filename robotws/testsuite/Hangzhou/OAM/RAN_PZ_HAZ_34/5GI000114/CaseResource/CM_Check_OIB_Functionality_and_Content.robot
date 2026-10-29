*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot
#Library    ../Resource/compare_oib_excel.py

*** Variables ***
${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}

*** Keyword ***
CM_Check_OIB_Functionality_and_Content
    Step1: Open Object Information Browser
    Step2: Look For and Click Search Button
    Step3: Click Radio Button and Export
    Step4: Click Column Settings and Check
    Step5: Do Check on Parameters
    # Step6: Do Compare NetAct with NIDD

Step1: Open Object Information Browser
    selenium_netact.open_sub_page    category_xpath=//span[text()='User Assistance']
    ...    page_xpath=//span[text()='Object Information Browser']   page_name=OIB
    Sleep   6s

Step2: Look For and Click Search Button
    #Page Objects
    # Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button    //*[@id="tabBar__topLevel_0"]/table/tbody/tr/td[2]/a
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_0"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="quickSearchValue"]   value=CPU
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="searchBtnDiv"]
    Sleep   6s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="clearsearchBtn"]
    # Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button    //*[@id="tabBar__topLevel_0"]/table/tbody/tr/td[2]/a
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_0"]
    Sleep   6s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="neDropDown"]
    ...   value=Nokia AirScale BTS 5G (com.nokia.srbts.nrbts)
    Sleep   4s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="suggestion:suggest"]/tbody/tr/td[2]
    Sleep   20s
    #Click Drop Down List Button
    selenium_netact.Click Button   button_xpath=//*[@id="releaseDropDowncomboboxButton"]
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="releaseDropDownlist"]
    ${count}   selenium_netact.execute_script   script_cmd=return document.getElementById('releaseDropDownlist').childElementCount
    ${check_nidd}   Set Variable If
    ...   ${NIDD_RELEASE.find('CLA')}!=-1   ${NIDD_RELEASE[:-3]}
    ...   ${NIDD_RELEASE.find('CLA')}==-1   ${NIDD_RELEASE}

    FOR   ${index}    IN RANGE    ${count}
       ${temp_version}   selenium_netact.execute_script
       ...   script_cmd=return document.getElementById('releaseDropDownlist').children[${index}].textContent
       Run Keyword If   ${temp_version.find('${check_nidd}')}!=-1   Set Test Variable   ${NIDD_VERSION}   ${temp_version}
       Exit For Loop If   ${temp_version.find('${check_nidd}')}!=-1
    END
    Sleep   5s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="releaseDropDowncomboboxField"]
    ...   value=${NIDD_VERSION}
    Sleep   5s
    #Check NIDD Version
    ${check_version}   selenium_netact.Get Element Attribute   elem_xpath=//*[@id="releaseDropDowncomboboxField"]   attr_name=value
    Log To Console   \nPage Objects: Check NIDD Verison: ${check_version}

Step3: Click Radio Button and Export
    #Click MOC Export Button
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:moc_tree_region:export_panel"]/a/img
    Sleep   6s
    #Click Table
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:tableTab"]/span
    #Click Objects Export Button
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:moc_table_region:exportEnvImg"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="export_all"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="export_xls"]
    Sleep   3s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="exportAllBtn"]
    Sleep   6s

Step4: Click Column Settings and Check
    #Click Column Settings Button
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:moc_table_region:colsetpanel"]/span
    #Select OMeS ID
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:moc_table_region:sctColumns:4"]
    #Select Level ID
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:moc_table_region:sctColumns:5"]
    #Click Apply Button
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabForm:moc_table_region:apply"]
    Sleep   5s
    #Click LTEENB
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button
    ...   button_xpath=//*[@id="tabForm:moc_table_region:wrList:2:2:mocDetailId"]
    Sleep   5s
    #Get Objects Details
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="tabForm:moc_table_region:aibDetail"]/div[1]/div[2]
    Sleep   5s
    #Click Close Button
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="closeButton"]

Step5: Do Check on Parameters
    #Page Parameters
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="tabBar__topLevel_3"]/table/tbody/tr/td[2]/a
    Sleep   10s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="neDropDown"]
    ...   value=Nokia AirScale BTS 5G (com.nokia.srbts.nrbts)
    Sleep   4s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="suggestion:suggest"]/tbody/tr/td[2]
    Sleep   6s
    #Click Drop Down List Button
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value_and_enter   input_xpath=//*[@id="releaseDropDowncomboboxField"]
    ...   value=${NIDD_VERSION}
    Sleep   5s
    #Check NIDD Version
    ${check_version}   selenium_netact.Get Element Attribute   elem_xpath=//*[@id="releaseDropDowncomboboxField"]   attr_name=value
    Log To Console   \nPage Parameters: Check NIDD Verison: ${check_version}
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="cmdataTable:colsetpanel"]/span
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="sctColumns:4"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="sctColumns:5"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="apply"]
    Sleep   6s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="cmdataTable:exportpanel"]/span
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="export_all"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="export_xls"]
    Sleep   3s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="exportAllBtn"]
    Sleep   6s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="cmdataTable:wrList:14:14:detailId0"]
    Run keyword and ignore error    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="aibDetail"]/div[5]/div[2]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.get_elem_text   elem_xpath=//*[@id="aibDetail"]/div[5]/div[2]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="closeButton"]
    Sleep   6s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="genToAdvSearch"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.write_value   input_xpath=//*[@id="advPage:object_id"]   value=X2C
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="advPage:searchAdvBtnDiv"]
    Sleep   6s
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="advPage:clearsearchAdvBtn"]
    Wait Until Keyword Succeeds   3times   10s   selenium_netact.Click Button   button_xpath=//*[@id="advPage:advSearchToGen"]
    Sleep   6s

# Step6: Do Compare NetAct with NIDD
#    @{NetAct_list}=   Create list   Parameter name   Description   Required on creation
#    @{NIDD_list}=   Create list   Parameter Name   Description   Required on creation
#    @{NetAct}=   Create list   ${WEB_DOWNLOAD_DIR}/Parameters_com.nokia.srbts.nrbts_${nidd_version}_Alldata.xls   sheet1   Abbreviated name
#    ...   ${NetAct_list}
#    @{NIDD}=   Create list   ${WEB_DOWNLOAD_DIR}/Excel_Parameter_Report_NRBTS_5G19_1901_011_1.0.0_noHidden_W1904.4.xlsm   Parameters   Abbreviation
#    ...   ${NIDD_list}
#    Run Keyword And Ignore Error   compare_oib     @{NetAct}   @{NIDD}   False
#    Sleep   6s

Case Setup: CM_Check_OIB_Functionality_and_Content
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}

Case Teardown: CM_Check_OIB_Functionality_and_Content
    Run Keyword And Ignore Error   Remove Files
    ...   ${WEB_DOWNLOAD_DIR}/MOC_Content_from_com.nokia.srbts.nrbts-${nidd_version}-CM.xml
    ...   ${WEB_DOWNLOAD_DIR}/Objects_com.nokia.srbts.nrbts_${nidd_version}_Alldata.xls
    ...   ${WEB_DOWNLOAD_DIR}/Parameters_com.nokia.srbts.nrbts_${nidd_version}_Alldata.xls
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
