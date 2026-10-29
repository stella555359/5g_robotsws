*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
Resource         ./../common_setup_teardown.robot
*** Variables ***

*** Test Cases ***
Update_Iphy_Xml_Case
    Get IPHY XML File And Swconfig File    ${CURDIR}
    Modify IPHY File And Send to Airphone    ${CURDIR}/iphy.xml
*** Keywords ***
