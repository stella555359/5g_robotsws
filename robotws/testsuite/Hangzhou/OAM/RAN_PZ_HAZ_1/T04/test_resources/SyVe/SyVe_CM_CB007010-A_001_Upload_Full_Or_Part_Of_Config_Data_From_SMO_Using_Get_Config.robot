*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}        ${False}

*** Keywords ***
SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:RAN_ST_CB007010-A_001_CM_Upload full or part of Configuration Data from SMO using get-config operation
    ...  The main steps performed for the test are:
    ...  - Get And Check All CM Data From ONAP
    ...  Pass criteria: Check configuration via get-config from ONAP Netconf, same as on get from NetAct
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.08.2023 - New case
    Set Tags    CA-CM    AUTHOR-bin.7.liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    Log To Console    ${TEST_NAME} start.
    Step 1: Get And Check All CM Data From ONAP

TC Setup
    Log    TC Setup
    Common Test Setup
    Set Test Variable    ${BTS_ID}    ${MRBTS_DN.split("-")[-1]}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    Comment    Run Keyword If    ${Integrate_Need}
    ...    Integrate SBTS To ONAP    ${BTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}

TC Teardown
    Log    TC Teardown
    Common Test Teardown

Check MOs From Netconf
    [Arguments]    ${onap_get_xml}    ${scf_file}
    ${onap_get_content}    L_XML.Parse XML    ${onap_get_xml}
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${managedObject_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject
    ${count}    Get Length    ${managedObject_elements}
    Log    ${count}
    ${not_found_DN}    Create List
    FOR    ${managedObject_element}    IN    @{managedObject_elements}
        ${dn}    L_XML.Get Element Attribute    ${managedObject_element}    distName
        ${xpath}    Transfer SCF DN To Xpath Of ONAP Get Result    ${dn.replace("PLMN-PLMN/","")}
        ${is_found_on_onap}    Run Keyword And Return Status    L_XML.Element Should Exist    ${onap_get_content}    ${xpath}
        Continue For Loop If    ${is_found_on_onap}
        ${tmp_list}    Create List    ${dn}    ${xpath}
        Append To List    ${not_found_DN}    ${tmp_list}
    END
    [Return]    ${not_found_DN}

Step ${index}: Get And Check All CM Data From ONAP
    Log To Console    Step ${index}: Get And Check All CM Data From ONAP
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${BTSFiles}/onap_get_config_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out /tmp/onap_get_config_${time}.xml
    Comment    Exucute One Command On Netconf CLI
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}
    ...    /tmp/onap_get_config_${time}.xml    ${onap_get_file}
    Get File From Simulator To Local    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    onap_get_config_${time}.xml    ${onap_get_file}
    ${NOT_FOUND_DN}    Check MOs From Netconf    ${onap_get_file}    ${BTS_scf_initial}
    Should Be Empty    ${NOT_FOUND_DN}
