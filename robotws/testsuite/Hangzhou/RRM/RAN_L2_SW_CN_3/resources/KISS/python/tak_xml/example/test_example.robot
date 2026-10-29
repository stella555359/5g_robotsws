*** Settings ***
Resource     ../../../robot/common_resource.robot

*** Test Cases ***
Read
    ${btsid}    read_xml    ${CURDIR}${/}scfc.xml     text|//*[@name\='btsId']

Modify
    ${modify_list}    create list    text|222|//*[@name\='btsId']        text|333|//*[@name\='btsName']   
    modify_xml   ${CURDIR}${/}scfc.xml     ${CURDIR}${/}scfc_mod0.xml        ${modify_list}  
add
    add_xml_element    ${CURDIR}${/}scfc.xml     ${CURDIR}${/}scfc_mod1.xml    <a>added</a>|//*[@name\='btsId']   

remove
    remove_xml_element     ${CURDIR}${/}scfc.xml     ${CURDIR}${/}scfc_mod2.xml    //*[@name\='btsId'] 

evaluate
    ${ret}    evaluate_xml_xpath    ${CURDIR}${/}scfc.xml     //*[@name\='btsId']
