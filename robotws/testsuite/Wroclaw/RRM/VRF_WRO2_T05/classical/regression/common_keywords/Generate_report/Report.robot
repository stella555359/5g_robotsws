*** Settings ***
Documentation    Author: Marek Jozwik
...              Using Create_Report will create Report.xlxs file with list of 'not yet automated TC's'

Library    Collections
Library    resources/Python_keywords.py
Resource     resources/Report_keywords.robot
Variables    resources/variables.py
*** Variables ***

${98_auto}    98 \u2013 To Be Automated
${file_1}    Report20A.xlsx
${file_2}    Report19B.xlsx
${file_3}    Report20B.xlsx
${file_4}    Report5G00.xlsx
${file_5}    Report20A_RGT.xlsx
${file_6}    Report19B_RGT.xlsx
${file_7}    Report20B_RGT.xlsx
${file_8}    Report5G00_RGT.xlsx

*** Test Cases ***

Create_Report
    [Tags]    Report
    ${xml_output}=    get_data    ${url_data}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G20A    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_1}
    new_entry    ${sorted_TC_list}    ${file_1}

Create_Report_19B
    [Tags]    Report_19B
    ${xml_output}=    get_data    ${url_data}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G19B    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_2}
    new_entry    ${sorted_TC_list}    ${file_2}

Create_Report_20B
    [Tags]    Report_20B
    ${xml_output}=    get_data    ${url_data}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G20B    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_3}
    new_entry    ${sorted_TC_list}    ${file_3}

Create_Report_5G00
    [Tags]    Report_00
    ${xml_output}=    get_data    ${url_data}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G00    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_4}
    new_entry    ${sorted_TC_list}    ${file_4}

Create_Report_RGT
    [Tags]    Report_RGT
    ${xml_output}=    get_data    ${url_data2}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G20A    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_5}
    new_entry    ${sorted_TC_list}    ${file_5}

Create_Report_19B_RGT
    [Tags]    Report_19B_RGT
    ${xml_output}=    get_data    ${url_data2}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G19B    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_6}
    new_entry    ${sorted_TC_list}    ${file_6}

Create_Report_20B_RGT
    [Tags]    Report_20B_RGT
    ${xml_output}=    get_data    ${url_data2}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G20B    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_7}
    new_entry    ${sorted_TC_list}    ${file_7}

Create_Report_5G00_RGT
    [Tags]    Report_00__RGT
    ${xml_output}=    get_data    ${url_data2}
    ${sorted_TC_list}=    Get data from list    ${xml_output}    5G00    ${98_auto}
    ${occurence_list}=    Prepare list of TCs    ${sorted_TC_list}
    create_xml    ${occurence_list}    ${file_8}
    new_entry    ${sorted_TC_list}    ${file_8}
