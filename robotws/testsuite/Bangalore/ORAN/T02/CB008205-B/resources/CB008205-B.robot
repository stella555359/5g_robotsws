*** Settings ***
Documentation
...    Author: anagha.chenniga@nokia.com
...    Maintainer: anagha.chenniga@nokia.com
...    Test Description: This feature is firstly supported in ASIL + APoABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -C is related to O-RAN V5.0 improvements with the use of 3rd party RU.
...    Confluence link: link
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-B/general.robot
...    Review: -
...    AC/REQ: OAM_REQ_RADIO_815; OAM_REQ_RADIO_816; OAM_REQ_RADIO_817; OAM_REQ_RADIO_818; OAM_REQ_RADIO_863;
...    OAM_REQ_RADIO_864; OAM_REQ_RADIO_866; OAM_REQ_RADIO_869; OAM_REQ_RADIO_879; OAM_REQ_RADIO_871; OAM_REQ_RADIO_876;
...    OAM_REQ_RADIO_877; OAM_REQ_RADIO_961; OAM_REQ_RADIO_968; OAM_REQ_RADIO_969; OAM_REQ_RADIO_970;OAM_REQ_RADIO_971;
...    OAM_REQ_RADIO_881; OAM_REQ_RADIO_972; OAM_REQ_RAT_933; OAM_REQ_RAT_934;

Library    SSHLibrary
Library    Collections
Library    BuiltIn
Library    SeleniumLibrary
Library    Process
Library    String
Library    OperatingSystem
Library    DateTime
Library    taf.analyzer.netconf
Library    taf.collectors.simple
Library    taf.collectors.core
Library    taf.file.pack
Library    taf.sw.scout    WITH NAME    scout
Library     ./testsuite/Bangalore/ORAN/SG02/resources/python/snapshotFileIdentifier.py
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource     ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/selenium_keywords.robot
Resource    startup.robot

*** Variables ***
${MAX_ATTEMPTS}      5
${WAIT_TIME}         120
@{OPT_MODULES_AND_FEATURES_IN_RU_L}=    PRACH-STATIC-CONFIGURATION-SUPPORTED    EAXC-GAIN-CORRECTION    GRANULARITY-TRANSPORT-MEASUREMENT
...    GRANULARITY-EAXC-ID-MEASUREMENT    CONFIGURABLE-FS-OFFSET    o-ran-module-cap    o-ran-uplane-conf    o-ran-compression-factors
@{OPT_FEATURES}=    oranFeatEaxcGainCorrection    oranFeatTxReferenceLevel    oranFeatConfigurableFsOffset    oranFeatStaticPRACHSupport
@{ALLOWED_ALARMS}    &{4592}    &{7305_allowed}    &{7107_allowed}    &{4720}    &{7304}    &{7308}    &{7523}    &{7107_cell2}
...     &{7300}    &{7312_allowed}
@{ALLOWED_ALARMS_TC03}    &{1806_allowed}    &{1900_allowed}    &{4008_allowed}
@{ALLOWED_ALARMS_TC04}    &{1806_allowed}    &{1900_allowed}
@{ALLOWED_ALARMS_TC05}    &{1806_allowed}    &{1900_allowed}
@{ALLOWED_ALARMS_TC06}    &{4673_allowed}
@{ALLOWED_ALARMS_TC07}    &{1807_allowed}
@{ALLOWED_ALARMS_TC08}    &{1807_allowed}
&{7523}     fault_id=7523
...         alarm_id=7107
...         alarm_severity=Minor
...         fault_name="Cell Activation timeout at gNB-DU"
...         notifier=
&{4592}     fault_id=4592
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{7300}     fault_id=7300
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="No X2 link available"
...         notifier=
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
&{7107_cell2}     fault_id=7017
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-2
&{1806}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name=Radio autonomous reset as recovery action
&{1807}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
...         fault_name=Invalid frequency channel for the BTS HW
&{1900}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name=RF Module configuring failed
&{4673}     fault_id=4673
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="Configuration mismatch with O-RU capabilities"
&{1807_allowed}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
...         fault_name=Invalid frequency channel for the BTS HW
...         notifier=
&{4673_allowed}     fault_id=4673
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="Configuration mismatch with O-RU capabilities"
...         notifier=
&{1806_allowed}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         fault_name=Radio autonomous reset as recovery action
...         notifier=
&{1900_allowed}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name=RF Module configuring failed
...         notifier=
&{7319}     fault_id=7319
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="No X2 link available for a specific LTEENB"
...         notifier=
&{4008_allowed}     fault_id=4008
...         alarm_id=7112
...         alarm_severity=Critical
...         fault_name="Power level not supported"
...         notifier=
&{7107_allowed}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=Critical
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7305_allowed}     fault_id=7305
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP setup fail"
...         notifier=
&{7312_allowed}     fault_id=7312
...         alarm_id=7107
...         alarm_severity=Warning
...         fault_name="NgGnbInitFullReset"
...         notifier=
&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1

${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         orusim
${Docker_user_name}			    inbabtslabuser
${Docker_password}			    BT5l@bus3rl0g1n
${NETCONF_TRACE_REMOTE_PATH}=           /tmp/node_FHNET80/tmp/RMOD_L-1_NetconfRpcMessageTrace_0.log
${NETCONF_TRACE_LOCAL_PATH}=            /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${XML_DOCKER_PATH}=                     /home
${EDIT_CMD}=                            edit-config --target running --config=/home/
${RPC_CMD}=                             user-rpc --content /opt/dev/xml
${ORU_SIM_IP}=                          10.44.186.151
${XML_FILES_PATH}=                      /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-B/xml-files
${SCF_PATH}=                            /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-B/resources/configurations
${SUPERVISORD_PATH}                     /var/log/supervisord.log
${CELL_DN}=                             /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${SCF_FILE}						        ${CURDIR}/../configurations/SANSA_scf_ofgesa_cloud.xml
${DELTA_FILE_OLD} 				        ${CURDIR}/../configurations/vlanid_old.json
${DELTA_FILE_NEW}	        	        ${CURDIR}/../configurations/vlanid_new.json
${DELTA_FILE_1}=     			        ${CURDIR}/../configurations/4G_delta_tr_array_nok.json
${DELTA_FILE_2}=     			        ${CURDIR}/../configurations/4G_delta_tr_array_ok.json
${S1LINK}		 				        ${CURDIR}/../configurations/s1link.sh
${X2LINK}		 				        ${CURDIR}/../configurations/x2link.sh
${ACCOUNTS_CONFIGURATION}=    	    	//div[contains(text(),'Accounts configuration')]
${oru_name}                             SSDORU-1
${DEFAULT_ACCOUNT_NAME}=    xranuser
${DEFAULT_ACCOUNT_PASS}=    xran-password
${WebEM IP}                             https://192.168.255.129:443
${url}                                  https://192.168.255.129
${browser}                              Chrome
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CONFIGURATION}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${NETCONF_RADIO_MANAGEMENT_BUTTON}=     //span[contains(text(),'Netconf Radio Management')]
${CONFIGURE_DEFAULT_ACCOUNT_BUTTON}=    //span[contains(text(),'Configure Default Netconf Account')]
${SEND_BUTTON}=                         //span[contains(text(), 'Send')]
${CHECKBOX_RMOD_1}=                     //div[@class="ui-chkbox-box ui-widget ui-state-default"]
${CONFIGURE_RADIO_SUCCEEDED}=           //span[contains(text(), 'Configure netconf radio succeeded')]
${CONFIGURATION_MANAGEMENT_BUTTON}=     //span[contains(text(),'Configuration Management')]
${COMMISSIONING_WIZARD_BUTTON}=         //span[contains(text(),'Commissioning Wizard')]
${PLUS_BUTTON_TRUNK}
...  //button[@class="p-element p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${NETCONF_MESSAGE1}=    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
${NETCONF_MESSAGE2}=    <static-prach-configurations nc:operation="create">
${nrcell}=    MRBTS-1/NRBTS-1/NRCELL-1
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
${INSTALL_OFGESA}				        ${CURDIR}/../configurations/5G_install_ofgesa.sh
${INSTALL_OFGESA_v7}				        ${CURDIR}/../configurations/5G_install_ofgesa_v7.sh
${INSTALL_OFGESA_PRACH_disable}			        ${CURDIR}/../configurations/5G_install_ofgesa_PRACH_disable.sh
${lxc_id}=    0x551a
${ABIO_RPC_cmd}                 user-rpc --content /tmp/
${ORU_container_path}           /tmp/node_${ORU_ID}
${ORU_ID}                       ORU01
${SCF_FILE_PRACH_timeout}     ${CURDIR}/../configurations/SANSA_scf_PRACH_timeout.xml
${INSTALL_OFGESA_TC03}     ${CURDIR}/../configurations/5G_install_ofgesa_get_error.sh
${sw_release}
${host}             127.0.0.1
${username}         ute
${password}         Utepassword@1
${cmd_TC03}=    set-failure name=o-ran-uplane-conf timeout-edit=90
${cmd_TC04_1900}=    set-failure name=o-ran-uplane-conf edit=true
${cmd_TC04_1900_cleared}=    set-failure name=o-ran-uplane-conf edit=false
${cmd_1806}=    set-static-prach-config-error type=TIMEOUT timeout=70
${cmd_TC05_1900}=    set-static-prach-config-error type=ERROR
${cmd_TC05_1900_cleared}=    set-static-prach-config-error type=NONE
&{authentication}   	   id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=       	   &{authentication}
&{default_user}=    	   defaultNetconfAccountName=xranuser
...                    	   defaultNetconfAccountPwd=xran-password


*** Keywords ***
TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Wait Until Mplane Is Connected
    CB008205-B.Netconf File Collection
    Check Get Message For Optional Modules
    Check Information About Optional Features And Modules In Webem

TC_03_Faults Handling During Retrieval Of endpoint-types static-low-level-tx-endpoints And static-low-level-rx-endpoints
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC03}
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Wait Until Mplane Is Connected
    Install OFGESA RU for <get-failure>
    CB008205-B WTSSIM X2 Link Establish
    sleep    500
    ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116
    ...    alarm_severity=Critical
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name=RF Module configuring failed    timeout=600
    Log To Console    Fault 1900 visible
    ADMIN Reset Site
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    CB008205-B.Netconf File Collection
    CB008205-B.Assert Gnb Receive An Error On The Appropriate Message In Oru
    ...    <rpc-error><error-type>application</error-type><error-tag>operation-failed</error-tag><error-severity>error</error-severity>
    Install OFGESA RU
    sleep    100s
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END
    Wait Until Mplane Is Connected
    Channel Bandwidth recommissioning    ${SCF_PATH}/chbw.json
    ADMIN Reset Site
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_TC03}
    CB008205-B WTSSIM X2 Link Establish
    ADMIN Assert Alarm Active    fault_id=1806    alarm_id=7101    alarm_severity=Warning
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name=Radio autonomous reset as recovery action    timeout=360
    Log To Console    Fault 1806 visible
    ADMIN Reset Site
    sleep    300
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END

TC_04_Faults Handling During Configuration Of TX RX Array Carriers And low-level-tx rx-endpoints
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC04}
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    CB008205-B.Prepare_Testline_with_OFGESA for PRACH error
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_TC04_1900}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116
        ...    alarm_severity=Critical
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=RF Module configuring failed    timeout=360
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1900 visible
    CB008205-B.Netconf File Collection
    CB008205-B.Assert Gnb Receive An Error On The Appropriate Message In Oru
    ...    <rpc-error><error-type>application</error-type><error-tag>operation-failed</error-tag><error-severity>error</error-severity>
    CB008205-B.Prepare_Testline_with_OFGESA for PRACH error
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_TC04_1900_cleared}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Wait Until Mplane Is Connected
    CB008205-B.Prepare_Testline_with_OFGESA for PRACH timeout
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_1806}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1806    alarm_id=7101    alarm_severity=Warning
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=Radio autonomous reset as recovery action    timeout=360
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1806 visible
    ADMIN Reset Site
    sleep    300
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Wait Until Mplane Is Connected

TC_05_Faults Handling During Configuration Of Static PRACH Patterns To O-RU
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC05}
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    CB008205-B.Prepare_Testline_with_OFGESA for PRACH error
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_TC05_1900}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116
        ...    alarm_severity=Critical
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=RF Module configuring failed    timeout=360
        Run Keyword If   '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1900 visible
    CB008205-B.Netconf File Collection
    CB008205-B.Assert Gnb Receive An Error On The Appropriate Message In Oru
    ...    <rpc-error><error-type>application</error-type><error-tag>operation-failed</error-tag><error-severity>error</error-severity>
    CB008205-B.Prepare_Testline_with_OFGESA for PRACH error
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_TC05_1900_cleared}
    ADMIN Reset Site
    sleep    300
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    CB008205-B.Prepare_Testline_with_OFGESA for PRACH timeout
    CB008205-B.Create SSH Session To ORU and trigger fault    ${cmd_1806}
    CB008205-B WTSSIM X2 Link Establish
    Channel Bandwidth recommissioning    ${SCF_PATH}/chbw.json
    ADMIN Assert Alarm Active    fault_id=1806    alarm_id=7101    alarm_severity=Warning
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name=Radio autonomous reset as recovery action    timeout=360
    Log To Console    Fault 1806 visible
    ADMIN Reset Site
    sleep    300
    CB008205-B WTSSIM X2 Link Establish
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200

TC_06_Capabilities Mismatch Detection
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword    Prepare_Testline_with_V7_OFGESA
    Wait Until Mplane Is Connected
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC06}
    Prepare_Testline_with_OFGESA_PRACH_disabled
    ADMIN Assert Alarm Active    fault_id=4673    alarm_id=7115
    ...    alarm_severity=Minor
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="Configuration mismatch with O-RU capabilities"
    Log To Console    Fault 4673 visible
    CB008205-B.Netconf File Collection
    Check If Static Prach Capability Is Not Supported In O-RU
    Prepare_Testline_with_V7_OFGESA
    ADMIN Assert Alarm Inactive    fault_id=4673    alarm_id=7115
    ...    alarm_severity=Minor
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="Configuration mismatch with O-RU capabilities"
    Wait Until Mplane Is Connected
    Log To Console    Reverting the setup back to ORAN version 5
    Prepare_Testline_with_OFGESA

TC_07_O-RU Out Of Range Frequency Detection
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC07}
    NrarfcnDl Recommissioning    435000
    ADMIN Assert Alarm Active    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Invalid frequency channel for the BTS HW    timeout=360
    Log To Console    Fault 1807 visible
    ADMIN Assert All NRCells Are In Expected State    state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=300
    NrarfcnDl Recommissioning    428000
    ADMIN Assert Alarm Inactive    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Invalid frequency channel for the BTS HW    timeout=360    timeout=360
    Log To Console    Fault 1807 cleared
    ADMIN Assert All NRCells Are In Expected State    state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=300
    NrarfcnUl Recommissioning    400000
    ADMIN Assert Alarm Active    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Invalid frequency channel for the BTS HW    timeout=360
    Log To Console    Fault 1807 visible
    ADMIN Assert All NRCells Are In Expected State    state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=300
    NrarfcnUl Recommissioning    390000
    ADMIN Assert Alarm Inactive    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Invalid frequency channel for the BTS HW    timeout=360    timeout=360
    Log To Console    Fault 1807 cleared
    ADMIN Assert All NRCells Are In Expected State    state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=300
    ADMIN Assert All Rmods Are In Enabled State   timeout=60
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=60
    Log to console   \nCell is in OnAir state##

TC_08_O-RU Out Of Range Bandwidth Detection
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC08}
	    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Channel Bandwidth Delta Recommissioning    ${SCF_PATH}/chBwDl_Ul_30Mhz.json
    ADMIN Assert Alarm Active    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Invalid frequency channel for the BTS HW    timeout=360
    Log To Console    Fault 1807 visible
    ADMIN Assert All NRCells Are In Expected State    state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=300
    sleep    120s
    Channel Bandwidth Delta Recommissioning    ${SCF_PATH}/chBwDl_Ul_20Mhz.json
    ADMIN Assert Alarm Inactive    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Invalid frequency channel for the BTS HW    timeout=360
    Log To Console    Fault 1807 cleared
    ADMIN Assert All NRCells Are In Expected State    state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=300

Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    Run    hostname
    [Documentation]    :Author: Mallikarjuna 
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s

Configure Netconf Credentials
    [Arguments]    @{list}
    taf.sbts.oam.coam.admin.Setup Admin
    configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}
    taf.sbts.oam.coam.admin.Teardown Admin

Prepare_Testline_with_OFGESA for PRACH error
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    Configure Netconf Credentials    @{sudo_list}
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install OFGESA RU
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END

Test Teardown
    Collect SOS report
    CB008205-B.Collect Snapshot

Collect SOS report
    Run     chmod 777 /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    ${output} =    OperatingSystem.Run    pwd
    Run     sudo rm ${output}/SosReport*_UEAPP1.tgz
    Run     /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    Wait Until Created    ${output}/SosReport*_UEAPP1.tgz    400s
    Run     sudo cp ${output}/SosReport*_UEAPP1.tgz ${output}

Collect Snapshot
    taf.sbts.oam.coam.admin.collect_snapshot    target_file_name=${output}/Snapshotfile.zip    connection=suite

Install OFGESA RU for <get-failure>
    Run    chmod +x ${INSTALL_OFGESA_TC03}
    Run    sh ${INSTALL_OFGESA_TC03}
    Log to console    \nInstalling OFGESA radio for test-failure on <get-message>

Supervision notification interval and supervision guard timer overhead recommissioning
    [Arguments]    ${supervision_timer_delta}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${supervision_timer_delta}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=admin_1
    Log To Console    ${\n}Supervision and guard timers recommissioned

Channel Bandwidth recommissioning
    [Arguments]    ${chbw_delta}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${chbw_delta}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=admin_1
    Log To Console    ${\n}Channel Bandwidth UL/DL recommissioned

CB008205-B.Prepare_Testline_with_OFGESA for PRACH timeout
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE_PRACH_timeout}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    Configure Netconf Credentials    @{sudo_list}
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install OFGESA RU
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END

CB008205-B.Trigger Fault 1806 for PRACH timeout
    CB008205-B.Copy Xml And Send Cmd to ORU    o-ran-test-uplane-prach-timeout.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 1900 With Severity Critical
    CB008205-B.Copy Xml And Send Cmd to ORU    o-ran-test-uplane-static-prach-error.xml    ${XML_FILES_PATH}/alarm

CB008205-B.clear Fault 1900 With Severity Critical
    CB008205-B.Copy Xml And Send Cmd to ORU    o-ran-test-uplane-static-prach-error.xml    ${XML_FILES_PATH}/alarm

Copy Xml And Send Cmd to ORU
    [Arguments]    ${file}      ${path}
    Copy Xml And Send Cmd By Netopeer Cli to APOABIO    ${file}    ${path}

FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}

CB008205-B.Trigger Fault 1806 for <get-failure>
    CB008205-B.Copy Xml And Send Cmd to ORU    o-ran-test-set-failure-upconf-edit-timeout.xml    ${XML_FILES_PATH}/alarm

Create SSH Session To ORU and trigger fault
    [Arguments]    ${cmd}
    ${result}=    Run Process    ssh    oru01@192.168.200.1    ${cmd}
    Log to Console    ${result.rc}
    Log to Console    ${result.stdout}
    Log to Console    ${result.stderr}


Prepare_Testline_with_OFGESA
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    Configure Netconf Credentials    @{sudo_list}
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install OFGESA RU
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END

Prepare_Testline_with_V7_OFGESA
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    Configure Netconf Credentials    @{sudo_list}
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install v7 OFGESA RU
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-B WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=900
    Log to console   \nCell is in OnAir state

Prepare_Testline_with_OFGESA_PRACH_disabled
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    Configure Netconf Credentials    @{sudo_list}
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install OFGESA RU with PRACH disabled
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END
    CB008205-B WTSSIM X2 Link Establish
    #ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=900
    Log to console   \nCell is not OnAir state

Install OFGESA RU with PRACH disabled
    Run    chmod +x ${INSTALL_OFGESA_PRACH_disable}
    Run    sh ${INSTALL_OFGESA_PRACH_disable}
    Log to console    \nInstalling modified OFGESA radio with PRACH STATIC configuration disabled

Install v7 OFGESA RU
    Run    chmod +x ${INSTALL_OFGESA_v7}
    Run    sh ${INSTALL_OFGESA_v7}
    Log to console    \nInstalling modified OFGESA radio with ORAN v7

Check VlanId
    ${vlanId}=    ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-*/VLANIF_CONF_M-1
    ...                                                                                parameter=vlanId
    ...                                                                                alias=infomodel_1
    ${vlanId_str}=    Convert to String    ${vlanId}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/../configurations/vlanid_new.json      ${replace}

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

Check Privacy Error
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="main-message"]/h1
    ...                                           timeout=30
    ${privacy_error}    Run Keyword If    ${status}    Get Text    locator=//*[@id="main-message"]/h1
    ${privacy_error}    Run Keyword And Return Status    Should Contain    ${privacy_error}    is not private
    Run Keyword If    ${privacy_error}    Proceed Unsafe Connection

Close BTS Startup View
    ${close}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Close')]
    ...    timeout=100
    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]

Proceed Unsafe Connection
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="details-button"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="details-button"]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="proceed-link"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="proceed-link"]

Go To Netconf Radio Management Tab
    Wait Until Element Is Visible   locator=${CONFIGURATION}
    Click Element   locator=${CONFIGURATION}
    Mouse Over  locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Click Element   locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Wait Until Element Is Visible    locator=${ACCOUNTS_CONFIGURATION}

Configure Default Netconf Account
    selenium.add_oru_account    60
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.send_netconf_configuration

Teardown Enviroment
    Close All Browsers
    Terminate All Processes

Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

CB008205-B WTSSIM X2 Link Establish
     Run    chmod 777 ${X2LINK}
     Run    sh ${X2LINK}
     Log to console   \nEstablishing X2 link...

Common_Precondition
    Docker Container Setup
    ADMIN Perform Commissioning    bts_id=1
    ...                            scf_file=${SCF_PATH}/SCF_NR_FDD.xml
    Wait Until Mplane Is Connected
    Check If Gnb Is In On Air State And If Cell Is Enabled

Check Get Message For Optional Modules
    ${opt_modules_id}    CB008205-B.Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="xpath" xmlns:yanglib
    Should Not Be Empty    ${opt_modules_id}
    ${opt_modules}    CB008205-B.Check Message In Netconf Trace File    ${opt_modules_id}
    Should Contain    ${opt_modules}    <data><yang-library xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-library">
    FOR    ${module}    IN    @{OPT_MODULES_AND_FEATURES_IN_RU_L}
        Should Contain    ${opt_modules}    ${module}
    END

Check Information About Optional Features And Modules In Webem
    Check Under RU_L That All Optional Modules Are Supported
    Check Optional Features Under RMOD_R

Check Under RU_L That All Optional Modules Are Supported
    FOR    ${module}    IN    @{OPT_MODULES_AND_FEATURES_IN_RU_L}
        Check Under RU_L That Module Is Supported  ${module}
    END

Check Under RU_L That Module Is Supported
    [Arguments]    ${module}
    ...            ${parameter}=capabilities
    ...            ${distname}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1
    ${state}    Get Parameters    ${parameter}    ${distname}
    ${state_string}    Convert To String    ${state}
    Should Contain    ${state_string}    ${module}

Check Optional Features Under RMOD_R
    [Arguments]    ${expected_value}=True
    ...            ${distname}=${EQM_PATH}/APEQM_R-1/RMOD_R-1
    FOR    ${feature}    IN    @{OPT_FEATURES}
        ${state}    Get Parameters    ${feature}    ${distname}
        Should Be Equal As Strings    ${state['oRanFeaturesSupport']['${feature}']}    ${expected_value}
    END

Check If Static Prach Capability Is Not Supported In O-RU
    ${module_retrieval_id}    CB008205-B.Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="xpath" xmlns:yanglib
    ...    tail -n 1
    Should Not Be Empty    ${module_retrieval_id}
    ${get_modules}    CB008205-B.Check Message In Netconf Trace File    ${module_retrieval_id}
    Should Not Contain     ${get_modules}
    ...    <rpc-error>
    Should Not Contain     ${get_modules}
    ...    PRACH-STATIC-CONFIGURATION-SUPPORTED

NrarfcnDl Recommissioning
    [Arguments]    ${nrarfcn_dl_value}
    CB008205-B.Parameter Recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1
    ...    parameter=nrarfcnDl
    ...    value=${nrarfcn_dl_value}
    ...    timeout=200
    Log To Console      ${\n}nrarfcnDl recommissioned: ${nrarfcn_dl_value}

NrarfcnUl Recommissioning
    [Arguments]    ${nrarfcn_ul_value}
    CB008205-B.Parameter Recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1
    ...    parameter=nrarfcnUl
    ...    value=${nrarfcn_ul_value}
    ...    timeout=200
    Log To Console      ${\n}nrarfcnUl recommissioned: ${nrarfcn_ul_value}

Channel Bandwidth Delta Recommissioning
    [Arguments]    ${chbw_delta}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${chbw_delta}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=admin_1

Channel Bandwidth Dl Recommissioning
    [Arguments]    ${chbw_dl_value}
    CB008205-B.Parameter Recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1
    ...    parameter=chBwDl
    ...    value=${chbw_dl_value}
    ...    timeout=200
    Log To Console      ${\n}Channel Bandwidth Dl recommissioned: ${chbw_dl_value}

Channel Bandwidth Ul Recommissioning
    [Arguments]    ${chbw_ul_value}
    CB008205-B.Parameter Recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1
    ...    parameter=chBwUl
    ...    value=${chbw_ul_value}
    ...    timeout=200
    Log To Console      ${\n}Channel Bandwidth Ul recommissioned: ${chbw_ul_value}

Docker Container Setup
    Create SSH Session To Docker
    SSHLibrary.write    /root/start.sh
    SSHLibrary.Read Until         root@
    SSHLibrary.Write    supervisorctl status
    ${output}           SSHLibrary.Read Until         root@
    Log To Console      ${\n}Container created
    [Teardown]  Clear SSH Session To Docker

Create SSH Session To Docker
    [Arguments]    ${oran_sim_host_ip}=${ORU_SIM_IP}
    ...            ${alias}=${oran_alias}
    ${oran_sim_host}    Set Variable     ${oran_sim_host_ip}
    Set Global Variable     ${oran_sim_host}
    SSHLibrary.Open Connection
    ...   host=${oran_sim_host}
    ...   alias=${alias}
    ...   timeout=180
    SSHLibrary.Login
    ...   username=ute
    ...   password=@Utepassword1
    SSHLibrary.Write    ssh root@192.168.255.120
    SSHLibrary.Read Until    password:
    SSHLibrary.Write    uteadmin
    SSHLibrary.Read Until    root@
    SSHLibrary.Set Client Configuration        timeout=60
    SSHLibrary.Switch Connection     ${oran_alias}

Clear SSH Session To Docker
    [Arguments]    ${alias}=${oran_alias}
    Run Keyword And Ignore Error  SSHLibrary.Switch Connection  ${alias}
    Run Keyword And Ignore Error  SSHLibrary.Close Connection

Send Cmd To Docker Shell
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write    ${cmd}
    ${output}           SSHLibrary.Read Until         root@
    SSHLibrary.Read Until        root@
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Wait Until Mplane Is Link Down
    [Arguments]    ${timeout}=200
    Get Rmod Id
    Wait Until Keyword Succeeds
    ...                           ${timeout}
    ...                           5
    ...                           Assert Mplane Link Down
    Log    \n+ MPlane is Link Down    console=yes

Assert Mplane Link Down
    ${mplane_status}    CB008205-B.		Check MPlaneLink Status
    Should Be Equal As Strings    ${mplane_status}
    ...                           Link Down

Check Message In Netconf Trace File
    [Arguments]    ${message_to_grep}
    ...            ${local_file_path}=${output}/RMOD_L-1_NetconfRpcMessageTrace.log
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path}
    [Return]    ${output}

Copy Xml To Container
    [Arguments]  ${local_path_to_file}
    ...          ${file_name}
    ...          ${destination_path}=${XML_DOCKER_PATH}
    ...          ${docker_name}=${DOCKER_NAME}
    ${xml_file}    Run    cat ${local_path_to_file}/${file_name}
    Create SSH Session To Docker
    SSHLibrary.Read Until    plwr
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write     ls ${destination_path}
    ${files_in_directory}    SSHLibrary.Read Until    root@
    ${is_file_exist}    BuiltIn.Run keyword and return status    Should Contain
    ...    ${files_in_directory}
    ...    ${file_name}
    Run Keyword If     ${is_file_exist}
    ...              SSHLibrary.write    rm ${destination_path}/${file_name}
    SSHLibrary.write    touch ${destination_path}/${file_name}
    SSHLibrary.Read Until    root@
    SSHLibrary.write    echo '${xml_file}' >> ${destination_path}/${file_name}
    SSHLibrary.Read Until    root@
    [Teardown]  Clear SSH Session To Docker

Copy Xml And Send Cmd By Netopeer Cli
    [Arguments]    ${file_name}
    ...            ${path}
    ...            ${cli_cmd}=${RPC_CMD}
    Copy Xml To Container   ${path}
    ...                     ${file_name}
    Send Command To Detached Screen Netopeer2-cli Session    ${cli_cmd}${file_name}
    Wait Until Message Is Visible In Detached Screen Netopeer2-cli Session    ${cli_cmd}${file_name}    >

ORAN Preconditions
    Test Preconditions Without WTSSIM S1
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    CB008205-B.Set Path In Infomodel

Check Message Id
    [Arguments]    ${message_to_grep}
    ...            ${grep_option}=head -n 1
    ...            ${local_file_path}=${output}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log to console    grep message in netconf trace
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path} | ${grep_option}
    ${output_1}    Fetch From Left    ${output}    "><
    ${message_id}    Fetch From Right    ${output_1}    message-id=
    [Return]   ${message_id}

CB008205-B.Netconf File Collection
    taf.sbts.oam.coam.admin.Setup Admin    name=snapshot
    Run Keyword And Return Status    OperatingSystem.Create Directory    ${output}
    OperatingSystem.Empty Directory    ${output}
    ${snapshot1}=    taf.sbts.oam.coam.admin.collect_snapshot    target_file_name=${output}/Snapshotfile.zip
    ...    timeout=300    connection=snapshot
    sleep    15
    taf.sbts.oam.coam.admin.Teardown Admin    connection=snapshot
    CB008205-B.Extract netconf from snapshot


snapshotFileIdentifier
    @{getWithoutFilerValue}=    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${output}/Snapshotfile.zip
    ...    path=${output}
    ...    fileToBeChecked=NetconfRpcMessageTrace
    [Return]    @{getWithoutFilerValue}

CB008205-B.Extract netconf from snapshot
        @{getWithoutFilerValue}=     snapshotGetWithoutFilter    Snapshotfile.zip    ${output}/    RMOD_L-1_NetconfRpcMessageTrace
        log     ${getWithoutFilerValue}[0]
        log     ${getWithoutFilerValue}[1]
        log     ${getWithoutFilerValue}[2]
        ${netconf_file_path}=    String.Replace string    ${getWithoutFilerValue}[2]    results//    results/
        Extract
   	...    path=${netconf_file_path}
   	...    output_dir=${output}
   	...    .=*.log
        ${netconf_filename}=    OperatingSystem.List Files In Directory    ${output}/    *_NetconfRpcMessageTrace.log
        OperatingSystem.Copy file    ${output}/*_NetconfRpcMessageTrace.log    ${output}/RMOD_L-1_NetconfRpcMessageTrace.log

Clear Logs In Oru
    [Arguments]    ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    > ${supervisord_path}
    SSHLibrary.Read Until    root@
    [Teardown]  Clear SSH Session To Docker

Clear Netconf Traces
    [Arguments]    ${remote_file_path}=/tmp/node_FHNET80/tmp/RMOD_L-1_NetconfRpcMessageTrace_0.log
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    > ${remote_file_path}
    SSHLibrary.Read Until    root@
    [Teardown]    SYSTEM Close SSH Connection To Enb

Check Message In Logs On Oru
    [Arguments]    ${message_to_grep}
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    grep -n '${message_to_grep}' ${supervisord_path}
    ${output}    SSHLibrary.Read Until    root@
    Should Not Be Empty     ${output}
    [Return]    ${output}
    [Teardown]  Clear SSH Session To Docker

Set Path In Infomodel
    ${position}=    ADMIN Get Smod Position
    Run Keyword If    '${position}' == 'left'    Run Keywords
        ...    Set Global Variable    ${EQM_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1    AND
        ...    Set Global Variable    ${MRBTS_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1    AND
        ...    Set Global Variable    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-1    AND
        ...    Set Global Variable    ${NRTS_PATH}    /MRBTS-1/RAT-1/NRTS-1
        ...    ELSE IF    '${position}' == 'right'    Run Keywords
        ...    Set Global Variable    ${EQM_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4    AND
        ...    Set Global Variable    ${MRBTS_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4    AND
        ...    Set Global Variable    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-4    AND
        ...    Set Global Variable    ${NRTS_PATH}    /MRBTS-1/RAT-1/NRTS-4

Parameter Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}=update
    ...            ${skip_parameter_relation_errors}=true
    ...            ${should_activate}=true
    ...            ${timeout}=60
    ...            ${alias}=admin_1
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=${operation}
    ...    value=${value}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    alias=${alias}

Check If Gnb Is In On Air State And If Cell Is Enabled
    Assert All NRCells Are In Expected State    operationalState    regex"Enabled|enabled"    timeout=70
    Assert Mrbts Is In Onair State

Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=NRCEL

Assert Netconf Traces Are Not In Snapshot
    Run    unzip ${OUTPUT_DIR}/Snapshot.zip -d ${OUTPUT_DIR}/Snapshot
    ${snapshot_file_list}    Run     cat ${OUTPUT_DIR}/Snapshot/snapshot_file_list.txt | grep Netconf
    Should Not Contain
    ...    ${snapshot_file_list}
    ...    RMOD_L-1_NetconfRpcMessageTrace.log.xz
    Run    rm -R ${OUTPUT_DIR}/Snapshot

Check Message Id In Oru
    [Arguments]    ${message_to_grep}
    ...            ${grep_option}=head -n 1
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    grep -n '${message_to_grep}' ${supervisord_path} | ${grep_option}
    ${output}    SSHLibrary.Read Until    root@
    ${output_1}    Fetch From Left    ${output}    "><
    ${message_id}    Fetch From Right    ${output_1}    message-id=
    [Return]    ${message_id}
    [Teardown]  Clear SSH Session To Docker

Compare Parameter Values Between O-RU and gNB
    [Arguments]    ${rmod_parameters_mapping}
    ...            ${distname}
    ...            ${empty_model_name}=${FALSE}
    Run Keyword If    ${empty_model_name}
    ...    Check If O-RU Transmits Empty model-name And Modify Parameters Mapping
    FOR    ${gnb_parameter}    IN    @{rmod_parameters_mapping.keys()}
        ${oru_parameter}=    Get From Dictionary    ${rmod_parameters_mapping}    ${gnb_parameter}
        ${oru_value}=    Check Message ID And Get Parameter Value From Netconf Trace File    ${oru_parameter}
        ...    get.*<serial-num/><hardware-rev/><software-rev/><mfg-name/><model-name/>.*/get>
        ${gnb_parameter_value}=    Get Parameters    ${gnb_parameter}    ${distname}
        ${gnb_value}=    Get From Dictionary    ${gnb_parameter_value}    ${gnb_parameter}
        Log To Console    Value of parameter '${gnb_parameter}' read from gNB: ${gnb_value}
        Should Be Equal    ${gnb_value}    ${oru_value}
    END

Check Message ID And Get Parameter Value From Netconf Trace File
    [Arguments]    ${parameter_name}
    ...            ${grep_phrase}
    ${hw_id}    CB008205-B.Check Message Id
    ...    ${grep_phrase}
    ...    tail -n 1
    Should Not Be Empty    ${hw_id}
    ${value}=    Get Parameter Value From Message With The Following Id    ${parameter_name}    ${hw_id}
    [Return]    ${value}

Get Parameter Value From Netconf Trace File
    [Arguments]    ${parameter_name}
    ...            ${grep_option}=tail -1
    ${output}   Run    grep -o '<${parameter_name}>.*</${parameter_name}>' ${NETCONF_TRACE_LOCAL_PATH} | ${grep_option}
    ${value_tmp}=    Fetch From Right    ${output}    <${parameter_name}>
    ${value}=    Fetch From Left    ${value_tmp}    </${parameter_name}>
    Log To Console    Value of parameter '${parameter_name}' read from Netconf trace file: ${value}
    [Return]    ${value}

Get Netconf Trace File From gNB
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${NETCONF_TRACE_REMOTE_PATH}
    ...                                  ${NETCONF_TRACE_LOCAL_PATH}
    Log To Console    Netconf trace file downloaded
    [Teardown]    SYSTEM Close SSH Connection To Enb

Wait Until O-RU Sends Specific Message
    [Arguments]    ${grep_message}    ${confirm_message}
    Wait Until Keyword Succeeds    300 seconds
    ...    5 seconds
    ...    Assert O-RU Sends Specific message    message_to_grep=${grep_message}    message_to_confirm=${confirm_message}

Assert O-RU Sends Specific message
    [Arguments]    ${message_to_grep}
    ...            ${message_to_confirm}
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    grep -n '${message_to_grep}' ${supervisord_path}
    ${output}    SSHLibrary.Read Until    root@
    Should Contain     ${output}    ${message_to_confirm}
    [Teardown]  Clear SSH Session To Docker

Assert Gnb Receive An Error On The Appropriate Message In Oru
    [Arguments]    ${message_TC}
    ${message}=    CB008205-B.Check Message In Netconf Trace File    ${message_TC}
    log to console    ${message_TC}
    log to console    ${message}
    Should Contain    ${message}    ${message_TC}
    Should Contain    ${message}
    ...    <rpc-error>

Send Cmd By Netopeer Cli
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write   rm -f /home/cmd.txt
    SSHLibrary.write   echo connect --ssh --login netconf --host 127.0.0.1 --port 830 > /home/cmd.txt
    SSHLibrary.write   echo ${cmd} >> /home/cmd.txt
    SSHLibrary.write   netopeer2-cli < /home/cmd.txt
    ${res}  ${outp}    Run Keyword And Ignore Error
    ...                SSHLibrary.Read Until     Password:
    Run Keyword If     '${res}' == 'PASS'
    ...                SSHLibrary.write          netconf
    ...  ELSE IF       '${res}' == 'FAIL'        Run Keywords
    ...                SSHLibrary.write          yes
    ...  AND           SSHLibrary.Read Until     Password:
    ...  AND           SSHLibrary.write          netconf
    ${res}  ${outp}    Run Keyword And Ignore Error
    ...                SSHLibrary.Read Until     root@
    Return From Keyword If  '${res}' == 'PASS'   ${outp}
    SSHLibrary.write   yes
    ${output}          SSHLibrary.Read Until     root@
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Assert Rpc Timed Out
    [Arguments]    ${grep_message}
    ${id_1806}    Check Message Id In Oru    ${grep_message}
    ${id_1806}    Catenate    SEPARATOR=    message-id=\    ${id_1806}
    ${id_1806}    Catenate    SEPARATOR=    ${id_1806}    \"
    ${1806_message}    Check Message In Logs On Oru     ${id_1806}
    Should Contain     ${1806_message}    ${grep_message}
    ${passed}=    Run Keyword And Return Status    Should Contain    ${1806_message}    processing timed out
    Run Keyword If    '${passed}' == 'False'    Should Not Contain    ${1806_message}    rpc-reply

Send Cmd By Netopeer Cli Alternative Way
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write   netopeer2-cli
    SSHLibrary.Read Until    >
    Set Client Configuration    newline=CR
    SSHLibrary.write   connect --ssh --login netconf --host 127.0.0.1 --port 830\n\r
    ${output}=    SSHLibrary.Read Until     >
    SSHLibrary.write          netconf
    SSHLibrary.Read Until     >
    SSHLibrary.write    ${cmd}
    ${output}=    SSHLibrary.Read Until     SUCCEED
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Create Detached Screen Netopeer2-cli Session
    Create SSH Session To Docker
    SSHLibrary.write    screen -d -m -S netopeer_screen sudo docker exec -it orusim /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write    screen -list
    ${output}    SSHLibrary.Read Until         root@
    Should Contain    ${output}    netopeer_screen
    [Teardown]    Clear SSH Session To Docker

Remove Detached Screen Netopeer2-cli Session
    Create SSH Session To Docker
    SSHLibrary.write    pkill screen
    SSHLibrary.Read Until         root@
    SSHLibrary.write    screen -list
    ${output}=    SSHLibrary.Read Until         root@
    Should Not Contain    ${output}    netopeer_screen
    [Teardown]    Clear SSH Session To Docker

Send Command To Detached Screen Netopeer2-cli Session
    [Arguments]    ${command}
    Create SSH Session To Docker
    Set Client Configuration    escape_ansi=True
    SSHLibrary.write    screen -S netopeer_screen -p 0 -X stuff '${command}\\r'
    SSHLibrary.Read Until         root@
    [Teardown]    Clear SSH Session To Docker

Wait Until Message Is Visible In Detached Screen Netopeer2-cli Session
    [Arguments]    ${command}    ${message}
    Wait Until Keyword Succeeds
    ...                           30 seconds
    ...                           5 seconds
    ...                           Assert Message Is Visible In Detached Screen Netopeer2-cli Session
    ...                           ${command}
    ...                           ${message}

Assert Message Is Visible In Detached Screen Netopeer2-cli Session
    [Arguments]    ${command}    ${message}
    Create SSH Session To Docker
    SSHLibrary.write    screen -X hardcopy /root/netopeer_screen.log
    SSHLibrary.Read Until         root@
    SSHLibrary.write    grep -v '^$' netopeer_screen.log | grep -v '${command}' | tail -1
    ${output}=    SSHLibrary.Read Until         root@
    Should Contain    ${output}    ${message}
    [Teardown]    Clear SSH Session To Docker

Open Detached Session And Login To Netopeer Server
    Create Detached Screen Netopeer2-cli Session
    Send Command To Detached Screen Netopeer2-cli Session    cd /home
    Send Command To Detached Screen Netopeer2-cli Session    netopeer2-cli
    Wait Until Message Is Visible In Detached Screen Netopeer2-cli Session    netopeer2-cli    >
    Send Command To Detached Screen Netopeer2-cli Session    connect --ssh --login netconf --host 127.0.0.1 --port 830
    Wait Until Message Is Visible In Detached Screen Netopeer2-cli Session
	...    connect --ssh --login netconf --host 127.0.0.1 --port 830
    ...    Password:
    Send Command To Detached Screen Netopeer2-cli Session    netconf
    Wait Until Message Is Visible In Detached Screen Netopeer2-cli Session    Password:    >

Handle Snapshot Loading
    [Documentation]   Attempts to load the snapshot with retries and waits on failure.
    Install OFGESA RU
	FOR    ${i}    IN RANGE    5
        	${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        	${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        	Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword    Install OFGESA RU
        	Sleep   ${WAIT_TIME}
        	Run Keyword If    ${status}     Exit For Loop
        END

Log Failure And Stop Test
    [Documentation]   Logs a failure message and stops the test if retries fail.
    Log To Console   All attempts to load snapshot failed.
    Fail   Snapshot loading failed after ${MAX_ATTEMPTS} attempts.
