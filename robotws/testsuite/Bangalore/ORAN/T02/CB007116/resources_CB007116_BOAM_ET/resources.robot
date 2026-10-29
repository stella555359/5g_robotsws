*** Settings ***
Documentation
...    Author: palepu.ramesh@nokia.com
...    Maintainer: palepu.ramesh@nokia.com
...    Test Description: This test set is designed to verify proper displayed status of E2 link
...    Confluence link: link
...    Group in charge: I_MN_MANO_PZ_OM_EIT_ALL <I_MN_MANO_PZ_OM_EIT_ALL@internal.nsn.com>
...    References:
...    QualityCenter:
...    Sample execution: pybot --variable CONFIGURATION:Wroclaw.XXX -b debug.log -d /home/ute/results/
...    Review:
...    AC/REQ:

Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/T02/CB007116/resources_CB007116_BOAM_ET/admin_infomodel_CB007116.robot

Library    SeleniumLibrary
Library    Process
Library    taf.sbts.oam.coam.admin
Library    taf.config.scf   WITH NAME  scf
Library    ta5g_egate
Library    ta_emss

*** Variables ***
@{ALLOWED_ALARMS}    &{4592}    &{7305}    &{7304}    &{7308}    &{7523}    &{7107}    &{FAULT_61649}    &{FAULT_61524}    &{FAULT_61652}
...    &{FAULT_4654}    &{FAULT_4655}    &{FAULT_4681}    &{7107_cell2}    &{7107_cell3}    &{7107_cell4}    &{7300}
&{4592}     fault_id=4592
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{7305}     fault_id=7305
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP setup fail"
...         notifier=[1] MRBTS-1/NRBTS-1/SERVEDAMF-1
&{7300}     fault_id=7300
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="No X2 link available"
...         notifier=[1] MRBTS-1/NRBTS-1
&{7304}     fault_id=7304
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP endpoint broken"
...         notifier=[1] MRBTS-1/NRBTS-1/SERVEDAMF-1
&{7308}     fault_id=7308
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="Transport layer connection failure in X2 interface"
...         notifier=[1] MRBTS-1/NRBTS-1/SERVEDAMF-1
&{7523}     fault_id=7523
...         alarm_id=7107
...         alarm_severity=Minor
...         fault_name="Cell Activation timeout at gNB-DU"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7107}     fault_id=7017
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7107_cell2}     fault_id=7017
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-2
&{7107_cell3}     fault_id=7017
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-3
&{7107_cell4}     fault_id=7017
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-4
&{6450}     fault_id=6450
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Diagnostic Files collected"
...         notifier=[1] MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1
&{FAULT_61524}             fault_id=61524
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SSH enabled"
...                        notifier=
&{FAULT_61652}             fault_id=61652
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="R&D Service Port enabled"
...                        notifier=
&{FAULT_61649}             fault_id=61649
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex"LMP access via port \\d+"
...                        notifier=
&{FAULT_4654}              fault_id=4654
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Ethernet port security is disabled"
...                        notifier=
&{FAULT_4655}              fault_id=4655
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Service account root access is enabled"
...                        notifier=
&{FAULT_4681}              fault_id=4681
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Sanity Check Error"
...                        notifier=

${PATH}                                              /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB007116/configurations_CB007116_BOAM_ET
${ADD_NRRIC}                                         ${PATH}/Add_NRRIC.json
${ADD_NRE2LINK}                                      ${PATH}/Add_NRE2LINK.json
${RIC_AND_E2LINK_CONFIGURED}                         ${PATH}/RIC_AND_E2LINK.json
${DELTA_2}                                           /configuration/Reconfiguration_with_reset.json
${LOCKING}                                           ${PATH}/Locking.json
${UNLOCKING}                                         ${PATH}/Unlocking.json
${SCF}                                               /home/ute/testline_init_results/configs/scfc.xml
${SCF_WITH_E2LINK}                                   ${PATH}/SCF_onair.xml
${WEBEM_IP}                                          https://192.168.255.1:3600
${WELCOME_SCREEN_USERNAME_INPUT}=                    //*[@id="login-username"]
${WELCOME_SCREEN_PASS_INPUT}=                        //*[@id="login-password"]
${WELCOME_SCREEN_LOGIN_BTN}=                         //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                                   //ui-button[@a-text="Confirm"]
${NRNEARRTRIC_REACTANGEL}=                           //div[@title="NRNEARRTRIC-1"]
${GRAY_DIODE}=                                       //*[starts-with(@class,"gray-diode") and @title='Not configured']
${RED_DIODE_DETAILED}                                //*[@class="red-diode site-widget-diode parameter-diode"]/
...    ancestor::div[@aria-label="NRNEARRTRIC 1"]
${GREEN_DIODE_DETAILED}                              //*[@class="green-diode site-widget-diode parameter-diode"]/
...    ancestor::div[@aria-label="NRNEARRTRIC 1"]
${RED_DIODE_SITE}                                    //*[@class="red-diode square-diode"]/
...    ancestor::div[@class="nrnearrtric-component system-subcolumn-block default-system-subcolumn-block"]
${GREEN_DIODE_SITE}                                  //*[@class="green-diode square-diode"]/
...    ancestor::div[@class="nrnearrtric-component system-subcolumn-block default-system-subcolumn-block"]
${NRE2_INSTANCE_NOT_CONFIGURED}=                     //*[@title="No NR E2 link instance configured"]
${NRNEARRTRIC_IP}=                                   //td[contains(text(), '10.0.1.150')]
${NO_VISIBLE}=                                       -
${ACTIVE}=                                           active
${NO_ACTIVE}=                                        inactive
${ADMINISTRATIVE_STATE_UNLOCKED}=                    Unlocked
${ADMINISTRATIVE_STATE_LOCKED}=                      Locked
${NEMUADMIN_NAME}                                    Nemuadmin
${NEMUADMIN_PASSWORD}                                nemuuser
${LOCKED_ICON}                                       //div[@class="locked-icon"]
${CONFIGURATION}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${BTS_ADDRESS}=    192.168.255.129
${BTS_PORT}=        443
${USE_SSL}=        True
${EPCSIM_CFG_PATH}=     /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB007116/configurations_CB007116_BOAM_ET/basic_setup.cfg

*** Keywords ***
[1][1.0]CB007116-5G-A_Changing_of_NRE2LINK_status_via_delta_recommissioning
    taf.sbts.oam.coam.admin.setup_admin
    ...    bts_host=${BTS_ADDRESS}
    ...    alias=default
    sleep    5
    taf.sbts.oam.coam.admin.get_current_scf_file    file_name=scfc.xml    timeout=60    local_dir_path=/home/ute/testline_init_results/configs
    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    sleep    100
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${ADD_NRRIC}
    ...    timeout=700
    ...    skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    sleep    100
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${ADD_NRE2LINK}
    ...    timeout=300
    ...    skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.setup admin    bts_host=${BTS_ADDRESS}    bts_port=${ADMIN_PORT}    use_ssl=${USE_SSL}    alias=reset
    taf.sbts.oam.coam.admin.Reset    timeout=600    connection=reset
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.teardown admin    alias=reset
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     e2LinkStatus    enb_id=1
    Log To Console    \nValue of e2LinkStatus: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['e2linkstatus']}"=="inactive"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: E2AP link is active
    Run     chmod 777 /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB007116/configurations_CB007116_BOAM_ET/setup.sh
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        Run     /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB007116/configurations_CB007116_BOAM_ET/setup.sh
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END
    Log To Console    \nRIC configuration successful-Cells are on-air
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     e2LinkStatus    enb_id=1
    Log To Console    \nValue of e2LinkStatus: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['e2linkstatus']}"=="active"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: E2AP link is inactive
    Log To Console    \nE2AP link is active
    Log To Console    \nRevert setup to original
    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.teardown admin    alias=default


[1][2.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_properly_configured_and_connection_is_established
    taf.sbts.oam.coam.admin.setup_admin
    ...    bts_host=${BTS_ADDRESS}
    ...    alias=default
    sleep    5
    taf.sbts.oam.coam.admin.get_current_scf_file    file_name=scfc.xml    timeout=60    local_dir_path=/home/ute/testline_init_results/configs
    Run Keyword And Continue On Failure    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    ADMIN Assert All Bbmods Are In Enabled State
    ADMIN Assert All Rmods Are In Enabled State
    Configure RIC And Onair
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     e2LinkStatus    enb_id=1
    Log To Console    \nValue of e2LinkStatus: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['e2linkstatus']}"=="active"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: E2AP link is inactive
    Log To Console    \nRevert setup back to original
    Run Keyword And Continue On Failure    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.teardown admin    alias=default


[1][3.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_not_estabilished
    taf.sbts.oam.coam.admin.setup_admin
    ...    bts_host=${BTS_ADDRESS}
    ...    alias=default
    sleep    5
    taf.sbts.oam.coam.admin.get_current_scf_file    file_name=scfc.xml    timeout=60    local_dir_path=/home/ute/testline_init_results/configs
    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${ADD_NRRIC}
    ...    timeout=700
    ...    skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    sleep    200
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${ADD_NRE2LINK}
    ...    timeout=300
    ...    skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.setup admin    bts_host=${BTS_ADDRESS}    bts_port=${ADMIN_PORT}    use_ssl=${USE_SSL}    alias=reset
    taf.sbts.oam.coam.admin.Reset    timeout=600    connection=reset
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.teardown admin    alias=reset
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     e2LinkStatus    enb_id=1
    Log To Console    \nValue of e2LinkStatus: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['e2linkstatus']}"=="inactive"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: E2AP link is active
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     administrativeState    enb_id=1
    Log To Console    \nValue of administrativeState: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['administrativestate']}"=="Unlocked"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: administrativeState is locked
    Log To Console    \nRevert setup to original
    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.teardown admin    alias=default


[1][4.0]CB007116-5G-A_Locking_and_unlocking_of_NRE2LINK
    taf.sbts.oam.coam.admin.setup_admin
    ...    bts_host=${BTS_ADDRESS}
    ...    alias=default
    sleep    5
    taf.sbts.oam.coam.admin.get_current_scf_file    file_name=scfc.xml    timeout=60    local_dir_path=/home/ute/testline_init_results/configs
    Run Keyword And Continue On Failure    ADMIN Perform Commissioning
    ...                         bts_id=${OUT_MRBTS_ID}
    ...                         scf_file=${SCF}
    ...                         alias=default
    ...                         skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    ADMIN Assert All Bbmods Are In Enabled State
    ADMIN Assert All Rmods Are In Enabled State
    Configure RIC And Onair
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     e2LinkStatus    enb_id=1
    Log To Console    \nValue of e2LinkStatus: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['e2linkstatus']}"=="active"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: E2AP link is inactive
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${LOCKING}
    ...    timeout=300
	sleep    100
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     administrativeState    enb_id=1
    Log To Console    \nValue of administrativeState: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['administrativestate']}"=="Locked"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: administrativeState is unlocked
    sleep    100
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${UNLOCKING}
    ...    timeout=300
    sleep    100
    ${NRNEARRTRIC_attr}=     get object attributes    NRE2LINK-1     administrativeState    enb_id=1
    Log To Console    \nValue of administrativeState: ${NRNEARRTRIC_attr}
    ${link_status}=    Run Keyword If    "${NRNEARRTRIC_attr['administrativestate']}"=="Unlocked"    Set variable  ${True}
    ...    ELSE    Set variable  ${False}
    Should Be True    ${link_status}    msg=ERR: administrativeState is locked

Reactangle Should Status Site View '${STATUS_DIODE}' '${STATUS_E2LINK}' '${STATUS_ADMINISTRATIVE_STATE}'
    Login To Web Element Manager
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Wait Until Element Is Visible
    ...    locator=${NRNEARRTRIC_REACTANGEL}
    ...    timeout=20
    Wait Until Element Is Visible
    ...    locator=${STATUS_DIODE}
    ...    timeout=20
    SELENIUM Click Enable Element
    ...    locator=${NRNEARRTRIC_REACTANGEL}
    E2 RIC IP '10.0.1.150'
    E2 Link Status '${STATUS_E2LINK}'
    E2 Link Administrative State '${STATUS_ADMINISTRATIVE_STATE}'

Reactangle Should Status Under Detailed Site View '${STATUS_DIODE}' '${STATUS_E2LINK}' '${STATUS_ADMINISTRATIVE_STATE}'
    Wait Until Element Is Visible
    ...    locator=//div[@class="site-widget-container NRNEARRTRIC_A"]
    ...    timeout=20
    Wait Until Element Is Visible
    ...    locator=${STATUS_DIODE}
    ...    timeout=20
    Wait Until Element Is Visible
    ...    locator=//span[@title="IP: 10.0.1.150"]
    ...    timeout=20
    SELENIUM Click Enable Element
    ...    locator=//div[@class="site-widget-container NRNEARRTRIC_A"]
    E2 RIC IP '10.0.1.150'
    E2 Link Status '${STATUS_E2LINK}'
    E2 Link Administrative State '${STATUS_ADMINISTRATIVE_STATE}'
    Close All Browsers

Go To Detailed Site View
    SELENIUM Click Enable Element
    ...    locator=//li[@heading="Detailed Site View"]

E2 RIC IP '${ADDRESS}'
    Wait Until Element Is Visible    //*[starts-with(@class,"parameter-name ng-binding") and contains(text(),"NR near-RT RIC IP address:")]
    ...    timeout=20
    ${String}    Get Text    //tr[@class="ng-scope"][1]/td[2]
    Should Be Equal   ${String}    ${ADDRESS}

E2 Link Status '${STATUS}'
    Wait Until Element Is Visible    //*[starts-with(@class,"parameter-name ng-binding") and contains(text(),"E2 link status:")]    timeout=20
    ${String}    Get Text    //tr[@class="ng-scope"][2]/td[2]
    Should Be Equal   ${String}    ${STATUS}

E2 Link Administrative State '${STATUS}'
    Wait Until Element Is Visible   //*[starts-with(@class,"parameter-name ng-binding") and contains(text(),"E2 link administrative state:")]
    ...    timeout=20
    ${String}    Get Text    //tr[@class="ng-scope"][3]/td[2]
    Should Be Equal   ${String}    ${STATUS}

Configure RIC And Onair
    Log To Console    \nStart Configure RIC
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${RIC_AND_E2LINK_CONFIGURED}
    ...    skip_parameter_relation_errors=True
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.setup admin    bts_host=${BTS_ADDRESS}    bts_port=${ADMIN_PORT}    use_ssl=${USE_SSL}    alias=reset
    taf.sbts.oam.coam.admin.Reset    timeout=600    connection=reset
    Wait For RMOD And BBMOD Reach Operational State
    taf.sbts.oam.coam.admin.Teardown admin    alias=reset
    Run     chmod 777 /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB007116/configurations_CB007116_BOAM_ET/setup.sh
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        Run     /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB007116/configurations_CB007116_BOAM_ET/setup.sh
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END
    Log To Console    \nRIC configuration successful-Cells are on-air
    Sleep    300s


#Setup admin
    #bts_host=${BTS_ADDRESS}
    #...            bts_port=${BTS_PORT}
    #...            use_ssl=${USE_SSL}
    #sleep    5

Reset RIC And Onair
    Run    killall -9 egate
    Run    sudo killall -9 edaemon

Wait For RMOD And BBMOD Reach Operational State
    Log To Console    \nWait For RMOD And BBMOD Enabled
    Wait Until Keyword Succeeds   500   100
    ...          ADMIN INFOMODEL Check Parameter Value
    ...          dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...          dict_param=operationalState
    ...          value=enabled
    Wait Until Keyword Succeeds   900   100
    ...          ADMIN INFOMODEL Check Parameter Value In Dictionary
    ...          dist_name=/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1
    ...          dict_name=stateInfo
    ...          dict_param=operationalState
    ...          value=Enabled

Login To Web Element Manager
    [Arguments]    ${login}
    ...            ${password}
    Set Selenium Implicit Wait    5
    Open Browser    ${WebEM IP}
    ...             chrome
    Run Keyword And Ignore Error    Maximize Browser Window
    ${priv_error}=    Run Keyword And Return Status    Element Should Be Visible
    ...                                                locator=//button[contains(text(), "Advanced")]
    Run Keyword If    ${priv_error}==True    Proceed Through Privacy Error
    Input Text    locator=${WELCOME_SCREEN_USERNAME_INPUT}
    ...           text=${login}
    Input Text    locator=${WELCOME_SCREEN_PASS_INPUT}
    ...               text=${password}
    Click Element
    ...       locator=${WELCOME_SCREEN_LOGIN_BTN}
    Wait Until Element Is Visible
    ...       locator=${CONFIRM_BUTTON}
    ...       timeout=40
    Click Element    locator=${CONFIRM_BUTTON}
    ${timing}=    Run Keyword And Return Status    Wait Until Element Is Visible    locator=//button[contains(text(),'Close')]    timeout=40
    Run Keyword If    '${timing}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]
    ${plug}=    Run Keyword And Return Status    Element Should Be Visible    locator=//h4[@title="Plug and Play"]
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Cancel')]

SELENIUM Reset Site
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=//ui-button[@a-text="Reset Site"]
    SELENIUM Pop Confirm Reset

SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
    SELENIUM Mouse Over Visible Element
    ...    locator=//span[contains(text(),'Site Runtime View')]
    SELENIUM Click Visible Element
    ...    locator=//span[contains(text(),'Detailed Site View')]

SELENIUM Go Site View
    SELENIUM Click Visible Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
    SELENIUM Mouse Over Visible Element
    ...    locator=//span[contains(text(),'Site Runtime View')]
    SELENIUM Click Visible Element
    ...    locator=//span[contains(text(),'Site View')]

SELENIUM Click Enable Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=60s
    Wait Until Element Is Enabled
    ...    locator=${locator}
    ...    timeout=${timeout}
    Wait Until Keyword Succeeds  120  1
    ...    Click Element
    ...    locator=${locator}

SELENIUM Input Text In Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${text}
    ...    ${timeout}=10s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Input Text
    ...    locator=${locator}
    ...    text=${text}

SELENIUM Click Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=15s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Click Element
    ...    locator=${locator}

Proceed Through Privacy Error
    Click Element    locator=//button[contains(text(), "Advanced")]
    Wait Until Element Is Visible    locator=//a[@id="proceed-link"]
    Click Element    locator=//a[@id="proceed-link"]

SELENIUM Mouse Over Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=10s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Mouse Over
    ...    locator=${locator}

Prepare Enviroment
    Install Chromedriver
    Run Xvfb
    Export DISPLAY

Run Xvfb
    Start Process
    ...    command=/usr/bin/Xvfb :99 -screen 0 1920x1080x16
    ...    shell=yes

Install Chromedriver
    Run
    ...    command=sudo cp /home/ute/trunk/selenium/chromedriver /usr/bin
    Run
    ...    command=sudo chmod +x /usr/bin/chromedriver

Export DISPLAY
    Set Environment Variable  DISPLAY  :99

Test Postconditions CB007116
    Log     \n+ Clear BTS Started     console=yes
    Close All Browsers
    Test Postconditions

Test Preconditions CB007116
    Log    \n+ Common Test Preconditions started    console=yes
    Log Variables
    Set New Project
    LOGGING Start Logging
    ${out_mrbts_id}=    ADMIN Get Id For Current BTS
    Set Test Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id}
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Log    \n+ Common Test Preconditions finished    console=yes
    Prepare Enviroment

Check locked icon
    Wait Until Element Is Visible
    ...    locator=${LOCKED_ICON}
    ...    timeout=60

Check locked icon disappearing
    Element Should Not Be Visible    locator=${LOCKED_ICON}



