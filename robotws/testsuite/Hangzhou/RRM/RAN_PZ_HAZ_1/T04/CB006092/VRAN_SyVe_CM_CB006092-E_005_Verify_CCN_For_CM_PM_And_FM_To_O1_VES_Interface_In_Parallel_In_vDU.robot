*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for NFTA
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-E_005_Verify_CCN_For_CM_PM_And_FM_To_O1_VES_Interface_In_Parallel_In_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.04.2025, yuyan.xu@nokia-sbell.com
    Step 1: Check Netconf Get All And VES CCN During Perform Delta Commission
    #Step 2: Check Netconf Get And VES CCN During Provision
    Step 3: Check Netconf Get MO And VES CCN During Perform Delta Commission

Step ${index}: Check Netconf Get All And VES CCN During Perform Delta Commission
    Log To Console    Step ${index}: Check Netconf Get All And VES CCN During Perform Delta Commission
    Check Netconf Get And VES CCN During Perform Delta Commission


Step ${index}: Check Netconf Get MO And VES CCN During Perform Delta Commission
    Log To Console    Step ${index}: Check Netconf Get MO And VES CCN During Perform Delta Commission
    ${NETCONF_XPATH}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/NRBTS-${vDU_id}/NRCELL-0
    Set Test Variable    ${NETCONF_XPATH}
    Check Netconf Get And VES CCN During Perform Delta Commission    ${NETCONF_XPATH}

Check Netconf Get And VES CCN During Perform Delta Commission
    [Arguments]    ${onap_get_xpath}=${EMPTY}
    Log    ${onap_get_xpath}
    ##Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${current_value}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${vDU_id}/NRCELL-0    actPcsiOnF2Fdm
    ${actPcsiOnF2Fdm_to_set}    Set Variable If
    ...    '${current_value}'=='true'    false    true
    ${dic_param_value}    Create Dictionary    actPcsiOnF2Fdm=${actPcsiOnF2Fdm_to_set}
    @{para_list}    Create List    actPcsiOnF2Fdm
    @{value_list}    Create List    ${actPcsiOnF2Fdm_to_set}
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${vDU_id}/NRCELL-0
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${value_list[0]}    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    ${time_gap}    Evaluate    random.randint(1,5)    modules=random, sys
    Sleep    ${time_gap}
    ##Get And Check CM Data From ONAP    ${onap_get_xpath}
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    return from keyword
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${param_netact["distName"].replace("PLMN-PLMN/","")}
    ...    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Get And Check CM Data From ONAP
    [Arguments]    ${filter_xpath}=${EMPTY}
    ${time}    Get Time    epoch
    ${cmd}    Set Variable If    '${filter_xpath}'=='${EMPTY}'
    ...    get --out /tmp/TA_CB007010_E_010_${time}.xml    get --filter-xpath ${filter_xpath} --out /tmp/TA_CB007010_E_010_${time}.xml
    ${onap_get_file}    Set Variable    ${TEST_LOG_DIRECTORY}/onap_get_${time}.xml
    ${ret}    Execute NetConf Command On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Get File From Simulator To Local
    ...    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    tmp/TA_CB006092_E_005_${time}.xml    ${onap_get_file}
    ${get_result}    L_XML.Parse XML    ${onap_get_file}
    #delete? ${NETCONF_XPATH}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/NRBTS-${vDU_id}/NRCELL-0
    L_XML.Element Should Exist    ${get_result}    ${NETCONF_XPATH}
    #delete?  Set Test Variable    ${NETCONF_XPATH}

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    vDU Login By Rest
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}

Case Postcondition
    Log To Console    Case Postcondition
#    ${out}   Run Keyword If    ${RECOVERY_FLAG}
#    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
#    Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct