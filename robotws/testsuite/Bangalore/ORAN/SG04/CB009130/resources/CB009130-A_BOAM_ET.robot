*** Settings ***
Documentation
...    Author: karthik.j@nokia.com
...    Maintainer:
...    Test Description: Test cases to configure multiple bands and carriers with O-RAN compliant LTE Radio Unit
...    Confluence link: link
...    Group in charge:
...    References:
...    QualityCenter:
...    Sample execution:  robot -v CONFIGURATION:$(cat /proc/sys/kernel/hostname |sed 's/-/_/g') -V
...              /home/ute/testline_configuration/$(cat /proc/sys/kernel/hostname |sed 's/-/_/g')/__init__.py
...          -L TRACE -b debug.log -d/home/ute/logs/ /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/general.robot
...    Review:
...    AC/REQ:

Library    Process
Library    OperatingSystem
Library    DateTime
Library    SeleniumLibrary
Library    taf.analyzer.netconf
Library    taf.collectors.simple
Library     taf.collectors.core
Library    taf.sw.scout    WITH NAME    scout

Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/wtssim.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${DELTA_FILE_1}=     			        ${CURDIR}/../configurations/4G_delta_tr_array_nok.json
${DELTA_FILE_2}=     			        ${CURDIR}/../configurations/4G_delta_tr_array_ok.json
${S1LINK}		 				        ${CURDIR}/../configurations/s1link.sh
${INSTALL_OFGESA}				        ${CURDIR}/../configurations/4G_install_ofgesa.sh
${SCF_FILE}						        ${CURDIR}/../configurations/4G_scf_ofgesa_cloud.xml
${DELTA_FILE_OLD} 				        ${CURDIR}/../configurations/vlanid_old.json
${DELTA_FILE_NEW}	        	        ${CURDIR}/../configurations/vlanid_new.json
${ACCOUNTS_CONFIGURATION}=    	    	//div[contains(text(),'Accounts configuration')]
${DEFAULT_ACCOUNT_NAME}=    		    xranuser
${DEFAULT_ACCOUNT_PASS}=    		    xran-password
${WebEM IP}                             https://192.168.255.1:3600
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CONFIGURATION_TAB}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${NETCONF_RADIO_MANAGEMENT_BUTTON}=     //span[contains(text(),'Netconf Radio Management')]
${CONFIGURE_DEFAULT_ACCOUNT_BUTTON}=    //span[contains(text(),'Configure Default Netconf Account')]
${SEND_BUTTON}=                         //span[contains(text(), 'Send')]
${CHECKBOX_RMOD_1}=                     //div[@class="ui-chkbox-box ui-widget ui-state-default"]
${CONFIGURE_RADIO_SUCCEEDED}=           //span[contains(text(), 'Configure netconf radio succeeded')]
${CONFIGURATION_MANAGEMENT_BUTTON}=     //span[contains(text(),'Configuration Management')]
${COMMISSIONING_WIZARD_BUTTON}=         //span[contains(text(),'Commissioning Wizard')]
${PLUS_BUTTON_TRUNK}
...  //button[@class="p-element p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
@{WHITELIST}=    &{FAULT_61649}    &{FAULT_61524}   &{FAULT_61652}   &{FAULT_4654}   &{FAULT_4655}   
...              &{FAULT_4681}    &{FAULT_4720}    &{FAULT_4044}    &{FAULT_4008}
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
&{FAULT_4720}              fault_id=4720
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...                        notifier=
&{FAULT_4044}              fault_id=4044
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Incoherency in cell configuration"
...                        notifier=
&{FAULT_4008}              fault_id=4008
...                        alarm_id=7112
...                        alarm_severity=regex"Warning|Minor|Major|Critical"
...                        fault_name="Power level not supported"
...                        notifier=

@{ALLOWED_ALARMS}    &{6450}    &{4001}    &{4592}   &{6202}
&{6450}     fault_id=6450
...         alarm_id=regex".*"
...         alarm_severity=regex".*"
...         fault_name="Diagnostic Files collected"
...         notifier=regex".*"

&{4001}     fault_id=4383
...         alarm_id=regex".*"
...         alarm_severity=regex".*"
...         fault_name="RAT autonomous reset as recovery action"
...         notifier=regex".*"

&{4592}     fault_id=4592
...         alarm_id=regex".*"
...         alarm_severity=regex".*"
...         fault_name="BTS Reset Cause"
...         notifier=regex".*"

&{6202}     fault_id=6202
...         alarm_id=regex".*"
...         alarm_severity=regex".*"
...         fault_name="Transport layer connection failure in S1 interface"
...         notifier=regex".*"

&{[1][3.0] TC_01 O-RU capability to support LTE cells frequency}
...    QC_ID_FL00=QC_539593

&{[1][3.0] TC_03 O-RU capability to support LTE cells bandwidth}
...    QC_ID_FL00=QC_539594

&{[1][3.0] TC_04 O-RU capability to support LTE cell power of the single cell carrier}
...    QC_ID_FL00=QC_539595

&{[1][3.0] TC_02 O-RU capability to support LTE cells using the same TX array}
...    QC_ID_FL00=QC_539596

&{[1][3.0] TC_05 O-RU capability to support LTE cell total gain of all cell carriers}
...    QC_ID_FL00=QC_539597


*** Keywords ***
CB009130-A-TC_01_O-RU_capability_to_support_LTE_cells_frequency
    Log to console    \n CB009130-A-TC_01_O-RU_capability_to_support_LTE_cells_frequency
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    LOGGING Start Syslog Enb
    ...    ip=${LOGGING_ENB_IP}
    ...    log_dir=${OUTPUT_DIR}
    ...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    ...    alias=timestamp_analysis

    Prepare_Testline_with_OFGESA

    LOGGING Stop Syslog Enb
    ...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    ...    log_dir=${OUTPUT_DIR}
    ...    alias=timestamp_analysis
    LTE1701 Move And Unzip Syslog

    Netconf File Collection
    Netconf Message validation TC_01


CB009130-A-TC_02_O-RU_capability_to_support_LTE_cells_using_the_same_TX_array
    Log to console    \n CB009130-A-TC_02_O-RU_capability_to_support_LTE_cells_using_the_same_TX_array
    LOGGING Start Syslog Enb
    ...    ip=${LOGGING_ENB_IP}
    ...    log_dir=${OUTPUT_DIR}
    ...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    ...    alias=timestamp_analysis

    Prepare_Testline_with_OFGESA

    ADMIN Perform Delta Recommissioning
    ...    delta_file=${DELTA_FILE_1}
    ...    skip_parameter_relation_errors=True
    ADMIN Assert No Unexpected Active Alarms
    ##Alarm 4044 should present (Incoherency in cell configuration)

    ADMIN Perform Delta Recommissioning
    ...    delta_file=${DELTA_FILE_2}
    ...    skip_parameter_relation_errors=True
    ADMIN Assert All Cells Are In Enabled State    timeout=300
    ADMIN Assert No Unexpected Active Alarms
    ##Alarm 4044 should NOT present (Incoherency in cell configuration)

    LOGGING Stop Syslog Enb
    ...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    ...    log_dir=${OUTPUT_DIR}
    ...    alias=timestamp_analysis
    LTE1701 Move And Unzip Syslog

    Netconf File Collection
    Netconf Message validation TC_02


CB009130-A-TC_03_O-RU_capability_to_support_LTE_cells_bandwidth
    Log to console    \n CB009130-A-TC_03_O-RU_capability_to_support_LTE_cells_bandwidth
    #LOGGING Start Syslog Enb
    #...    ip=${LOGGING_ENB_IP}
    #...    log_dir=${OUTPUT_DIR}
    #...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    #...    alias=timestamp_analysis

    #Prepare_Testline_with_OFGESA

    #LOGGING Stop Syslog Enb
    #...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    #...    log_dir=${OUTPUT_DIR}
    #...    alias=timestamp_analysis
    #LTE1701 Move And Unzip Syslog

    Netconf File Collection
    Netconf Message validation TC_03
    

CB009130-A-TC_04_O-RU_capability_to_support_cell_power_of_the_single_cell_carrier
    Log to console    \n CB009130-A-TC_04_O-RU_capability_to_support_cell_power_of_the_single_cell_carrier
    #LOGGING Start Syslog Enb
    #...    ip=${LOGGING_ENB_IP}
    #...    log_dir=${OUTPUT_DIR}
    #...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    #...    alias=timestamp_analysis

    #Prepare_Testline_with_OFGESA

    #LOGGING Stop Syslog Enb
    #...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    #...    log_dir=${OUTPUT_DIR}
    #...    alias=timestamp_analysis
    #LTE1701 Move And Unzip Syslog

    Netconf File Collection
    Netconf Message validation TC_04

CB009130-A-TC_05_O-RU_capability_to_support_LTE_cell_total_gain_of_all_cell_carriers
    Log to console    \n CB009130-A-TC_05_O-RU_capability_to_support_LTE_cell_total_gain_of_all_cell_carriers
    LOGGING Start Syslog Enb
    ...    ip=${LOGGING_ENB_IP}
    ...    log_dir=${OUTPUT_DIR}
    ...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    ...    alias=timestamp_analysis

    Prepare_Testline_with_OFGESA

    Log to console    \nCommmisioning unsupported pMax vlaue for LNCEL-1 BAND-1
    ADMIN Perform Parameter Recommissioning
    ...     dist_name=MRBTS-1/LNBTS-1/LNCEL-1
    ...     parameter=pMax
    ...     value=431
    ...     operation=update
    ...     skip_parameter_relation_errors=${TRUE}
    ...     should_activate=${TRUE}
    ADMIN Assert No Unexpected Active Alarms
    ##Alarm 4008 should present (PowerLevelNotSupported)
    
    Log to console    \nCommmisioning supported pMax vlaue for LNCEL-1 BAND-1
    ADMIN Perform Parameter Recommissioning
    ...     dist_name=MRBTS-1/LNBTS-1/LNCEL-1
    ...     parameter=pMax
    ...     value=231
    ...     operation=update
    ...     skip_parameter_relation_errors=${TRUE}
    ...     should_activate=${TRUE}
    ADMIN Assert All Cells Are In Enabled State    timeout=300
    ADMIN Assert No Unexpected Active Alarms
    ##Alarm 4008 should NOT present (PowerLevelNotSupported)

    LOGGING Stop Syslog Enb
    ...    log_name=${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis
    ...    log_dir=${OUTPUT_DIR}
    ...    alias=timestamp_analysis
    LTE1701 Move And Unzip Syslog

    Netconf File Collection
    Netconf Message validation TC_05

LTE1701 Move And Unzip Syslog
    [Documentation]
    ...    Author: Karol Wierzbinski
    Move File
    ...    ${OUTPUT DIR}/${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis.tar.gz
    ...    ${OUTPUT DIR}/${TEST_NAME}/
    Run
    ...    tar -xzf ${OUTPUT DIR}/${TEST_NAME}/${LOGGING_ENB_SYSLOG_LOGNAME}_timestamp_analysis.tar.gz -C ${OUTPUT DIR}/${TEST_NAME}


Prepare_Testline_with_OFGESA
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    Add Default Netconf Account
    Install OFGESA RU
    ADMIN Assert All Rmods Are In Enabled State   timeout=900
    Change VlanId
    CB009130-A WTSSIM S1 Link Establish
    ADMIN Assert All Cells Are In Enabled State    timeout=900
    Log to console   \nCell is in OnAir state

Install OFGESA RU
     Run    chmod +x ${INSTALL_OFGESA}
     Run    sh ${INSTALL_OFGESA}
     Log to console    \nInstalling OFGESA radio

Add Default Netconf Account
    Prepare Enviroment
    Login To Web Element Manager
    Go To Netconf Radio Management Tab
    Configure Default Netconf Account In Webem
    Teardown Enviroment
    Log    \n+ Default Netconf Account Added    console=yes

Prepare Enviroment
    Chmod Chromedriver
    Run Xvfb
    Export DISPLAY

Login To Web Element Manager
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Set Selenium Implicit Wait    5
    Open Browser    ${WebEM IP}   chrome
    Check Privacy Error
    Proceed Unsafe Connection
    Run Keyword And Ignore Error    Maximize Browser Window
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Password    locator=${INPUT_PASSWORD_FIELD}
    ...               password=${password}
    Click Element   locator=${LOGIN_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=100
    Click Element    locator=${CONFIRM_BUTTON}
    Close BTS Startup View

Go To Netconf Radio Management Tab
    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over  locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Click Element   locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Wait Until Element Is Visible    locator=${ACCOUNTS_CONFIGURATION}

Configure Default Netconf Account In Webem
    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
    Click Element    ${PLUS_BUTTON_TRUNK}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
    Input Text    locator=account-name
    ...           text=${name}
    Input Password   locator=account-pwd
    ...              password=${password}
    Input Password   locator=confirm-account-pwd
    ...              password=${password}

    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=20

Check Privacy Error
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="main-message"]/h1
    ...                                           timeout=30
    ${privacy_error}    Run Keyword If    ${status}    Get Text    locator=//*[@id="main-message"]/h1
    ${privacy_error}    Run Keyword And Return Status    Should Contain    ${privacy_error}    is not private
    Run Keyword If    ${privacy_error}    Proceed Unsafe Connection

Proceed Unsafe Connection
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="details-button"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="details-button"]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="proceed-link"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="proceed-link"]

Close BTS Startup View
    ${close}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Close')]
    ...    timeout=100
    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]

Chmod Chromedriver
    Run  sudo chmod +x /usr/bin/chromedriver

Run Xvfb
    Start Process  /usr/bin/Xvfb :99 -screen 0 1920x1080x16   shell=yes

Export DISPLAY
    Set Environment Variable  DISPLAY  :99

Teardown Enviroment
    Close All Browsers
    Terminate All Processes

Check VlanId
    ${vlanId}=    ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-*/VLANIF_CONF_M-1
    ...                                                                                parameter=vlanId
    ...                                                                                alias=infomodel_1
    ${vlanId_str}=    Convert to String    ${vlanId}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/../configurations/vlanid_new.json      ${replace}

Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

CB009130-A Test Preconditions
    Log    \n+ Common Test Preconditions started    console=yes
    Log Variables
    Set New Project
    LOGGING Start Logging
    ${out_mrbts_id}=    ADMIN Get Id For Current BTS
    Set Test Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id}
    ADMIN Add Allowed Alarms    faults_list=@{WHITELIST}
    Log    \n+ Common Test Preconditions finished    console=yes

CB009130-A WTSSIM S1 Link Establish
     Run    chmod 777 ${S1LINK}
     Run    sh ${S1LINK}
     Log to console   \nEstablishing S1 link...

Netconf File Collection
    Log to console   \n Netconf log collection Started
    ${executor}    Create Dictionary    host=${RADIO_ENB_TRANSPORT_IP_ADDRESS}
	...     user=${RADIO_ENB_SSH_LOGIN}    password=${RADIO_ENB_SSH_PASSWORD}
    taf.collectors.simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    taf.collectors.core.setup_collectors    names=coredump
    sleep    30s
    taf.collectors.core.collect_collectors    names=coredump    target_dir=${OUTPUT_DIR}/${TEST_NAME}/
    taf.collectors.core.teardown_collectors    names=coredump
    Run    tar -zxvf ${OUTPUT_DIR}/${TEST_NAME}/coredump/coredump1.log.tgz -C ${OUTPUT_DIR}/${TEST_NAME}/coredump
    Move File    ${OUTPUT_DIR}/${TEST_NAME}/coredump/RMOD_L-1_NetconfRpcMessageTrace.log
                    ...    ${OUTPUT_DIR}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log to console   \n Netconf log collection completed


Netconf Message validation TC_01
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${OUTPUT_DIR}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}
    @{min-supported-frequency-dl}=    create List
    @{min-supported-frequency-ul}=    create List
	@{max-supported-frequency-dl}=    create List
    @{max-supported-frequency-ul}=    create List
    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-dl")}' != '[]'
		...    Append To List    ${min-supported-frequency-dl}    ${entry.message.xml.findall(".//min-supported-frequency-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-ul")}' != '[]'
		...    Append To List    ${min-supported-frequency-ul}    ${entry.message.xml.findall(".//min-supported-frequency-ul")}
		    Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-supported-frequency-dl")}' != '[]'
		...    Append To List    ${max-supported-frequency-dl}    ${entry.message.xml.findall(".//max-supported-frequency-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-ul")}' != '[]'
		...    Append To List    ${max-supported-frequency-ul}    ${entry.message.xml.findall(".//max-supported-frequency-ul")}
    END
	Parameter Check    ${min-supported-frequency-dl}    2110000000
 	Parameter Check    ${min-supported-frequency-ul}    1920000000
 	Parameter Check    ${min-supported-frequency-dl}    1805000000
	Parameter Check    ${min-supported-frequency-ul}    1710000000
	Parameter Check    ${max-supported-frequency-dl}    2170000000
 	Parameter Check    ${max-supported-frequency-ul}    1980000000
 	Parameter Check    ${max-supported-frequency-dl}    1880000000
	Parameter Check    ${max-supported-frequency-ul}    1785000000
    Log to console   --\n Netconf log verification completed\n-- 

Netconf Message validation TC_02
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${OUTPUT_DIR}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}
    @{max-num-component-carriers}=    create List
    @{max-power-per-pa-antenna}=    create List
    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-num-component-carriers")}' != '[]'
		...    Append To List    ${max-num-component-carriers}    ${entry.message.xml.findall(".//max-num-component-carriers")}
    END
	Parameter Check    ${max-num-component-carriers}    2
     Log to console   --\n Netconf log verification completed\n-- 

Netconf Message validation TC_03
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${OUTPUT_DIR}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}
    @{min-carrier-bandwidth-dl}=    create List
    @{min-carrier-bandwidth-ul}=    create List
  	@{max-carrier-bandwidth-dl}=    create List
    @{max-carrier-bandwidth-ul}=    create List
    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-carrier-bandwidth-dl")}' != '[]'
		...    Append To List    ${min-carrier-bandwidth-dl}    ${entry.message.xml.findall(".//min-carrier-bandwidth-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-carrier-bandwidth-ul")}' != '[]'
		...    Append To List    ${min-carrier-bandwidth-ul}    ${entry.message.xml.findall(".//min-carrier-bandwidth-ul")}
		    Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-carrier-bandwidth-dl")}' != '[]'
		...    Append To List    ${max-carrier-bandwidth-dl}    ${entry.message.xml.findall(".//max-carrier-bandwidth-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-carrier-bandwidth-ul")}' != '[]'
		...    Append To List    ${max-carrier-bandwidth-ul}    ${entry.message.xml.findall(".//max-carrier-bandwidth-ul")}
    END
	Parameter Check    ${min-carrier-bandwidth-dl}    10000000
 	Parameter Check    ${min-carrier-bandwidth-ul}    10000000
 	Parameter Check    ${min-carrier-bandwidth-dl}    10000000
	Parameter Check    ${min-carrier-bandwidth-ul}    10000000
	Parameter Check    ${max-carrier-bandwidth-dl}    20000000
 	Parameter Check    ${max-carrier-bandwidth-ul}    20000000
 	Parameter Check    ${max-carrier-bandwidth-dl}    20000000
	Parameter Check    ${max-carrier-bandwidth-ul}    20000000
     Log to console   --\n Netconf log verification completed\n-- 

Netconf Message validation TC_04
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${OUTPUT_DIR}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}
    @{min-power-per-pa-antenna}=    create List
    @{max-power-per-pa-antenna}=    create List
    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-power-per-pa-antenna")}' != '[]'
		...    Append To List    ${min-power-per-pa-antenna}    ${entry.message.xml.findall(".//min-power-per-pa-antenna")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-power-per-pa-antenna")}' != '[]'
		...    Append To List    ${max-power-per-pa-antenna}    ${entry.message.xml.findall(".//max-power-per-pa-antenna")}
    END
	Parameter Check    ${min-power-per-pa-antenna}    23.1
 	Parameter Check    ${max-power-per-pa-antenna}    49.5
      Log to console   --\n Netconf log verification completed\n-- 
      
 
Netconf Message validation TC_05
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${OUTPUT_DIR}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}
    @{max-gain}=    create List
    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//max-gain[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-gain")}' != '[]'
		...    Append To List    ${max-gain}    ${entry.message.xml.findall(".//max-gain")}
    END
	Parameter Check    ${max-gain}    43.0
 	Parameter Check    ${max-gain}    44.8
      Log to console   --\n Netconf log verification completed\n-- 


Nested Looping
    [Arguments]    ${I}    ${value}
	@{parameter-check}=    create list
	FOR    ${line}    IN    @{I}
        Run Keyword If     '${line.text}'=='${value}'    Append To List    ${parameter-check}    ${line.text}
	END
	[RETURN]    ${parameter-check}


Parameter Check
	[Arguments]    ${parameter-check}    ${val}
	${final_band}=    create list
    FOR    ${I}    IN    @{parameter-check}
	    Log    ${I}
        ${aa}=    Nested Looping    ${I}	${val}
		${final_band}=    combine lists    ${aa}    ${final_band}
    END
	${len}=    get length    ${final_band}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=	scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only1}=${CONFIGURATION}

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    ${tl_name_only}=    Split string    ${tl_name_only1}     separator=.    max_split=2	
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only[1]}

    ${scout_testline_name}=    Set Variable    ${tl_name_only[1]}
    ${external_scf_id}=	Wait Until Keyword Succeeds	2min	10s	Request Scout SCF	${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

QC_Update
    RP Settings
    Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting
    reportingportal_Keywords.Set QC_Tag

Test Postconditions
    Log    \n+ Common Test Postconditions started    console=yes
    ADMIN Assert No Unexpected Active And Historical Alarms
    WTSSIM Teardown Egate And Edaemons
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions finished    console=yes
