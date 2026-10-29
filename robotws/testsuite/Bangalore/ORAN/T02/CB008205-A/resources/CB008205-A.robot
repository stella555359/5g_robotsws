*** Settings ***
Documentation
...    Author: challa.ravali@nokia.com; usha.m_m@nokia.com
...    Maintainer: challa.ravali@nokia.com
...    Test Description: This feature is firstly supported in ASIM/ASIL + ABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -A is related to LTE FDD technology.
...    Confluence link: link
...    Group in charge:I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-A/general.robot
...    Review: -
...    AC/REQ: LTE_OPR_REQ_25526; LTE_OPR_REQ_25527; LTE_OPR_REQ_25528; LTE_OPR_REQ_25529; LTE_OPR_REQ_21108;
...    LTE_OPR_REQ_30383; LTE_OPR_REQ_33798; LTE_OPR_REQ_30387; LTE_OPR_REQ_33820; LTE_OPR_REQ_33810; LTE_OPR_REQ_29567;
...    LTE_OPR_REQ_30855; LTE_OPR_REQ_28273; LTE_OPR_REQ_33767; LTE_OPR_REQ_33777; LTE_OPR_REQ_33778; LTE_OPR_REQ_33779;
...    LTE_OPR_REQ_33780; LTE_OPR_REQ_30420; LTE_OPR_REQ_34471; LTE_OPR_REQ_34473
...    SRAN_SFS_SISO_1816 requirement for TC_02_Retrieval of O-RU YANG optional features and modules

Library    SSHLibrary
Library    BuiltIn
Library    SeleniumLibrary
Library    Process
Library    ute_fsmaccess
Library    DateTime
Library    Collections
Library    FtpLibrary
Library    OperatingSystem
Library    Screenshot
Library    String
Library    Telnet
Library    taf.sbts.oam.coam.admin
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library    taf.sw.scout    WITH NAME    scout
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf   WITH NAME  scf
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/selenium_keywords.robot
#Resource    startup.robot
Library     ./testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Library    taf.file.pack

*** Variables ***
@{OPT_MODULES_AND_FEATURES_IN_RU_L}=    PRACH-STATIC-CONFIGURATION-SUPPORTED    EAXC-GAIN-CORRECTION    GRANULARITY-TRANSPORT-MEASUREMENT
...    GRANULARITY-EAXC-ID-MEASUREMENT    CONFIGURABLE-FS-OFFSET    o-ran-module-cap    o-ran-uplane-conf    o-ran-compression-factors
@{OPT_FEATURES}=    oranFeatEaxcGainCorrection    oranFeatTxReferenceLevel    oranFeatConfigurableFsOffset    oranFeatStaticPRACHSupport
@{ALLOWED_ALARMS}=    &{4592}        &{FAULT_4681}    &{FAULT_4720}    &{4592_allowed}    &{10_allowed}    &{6202_allowed}
@{ALLOWED_ALARMS_TC06}    &{4673_allowed}
@{ALLOWED_ALARMS_TC04_and_TC05}    &{1806_allowed}    &{1900_allowed}
@{ALLOWED_ALARMS_TC03}    &{1806_allowed}    &{1900_allowed}    &{4008_allowed}
&{4592}     fault_id=4592
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{10_allowed}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         fault_name="No connection to unit"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
&{6202_allowed}     fault_id=6202
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="Transport layer connection failure in S1 interface"
...         notifier=
&{4592_allowed}     fault_id=4592
...         alarm_id=7652
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{7300}     fault_id=7300
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="No X2 link available"
...         notifier=
&{1806}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         alarm_resource=[1] MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
...         fault_name=Radio autonomous reset as recovery action
&{1807}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
...         fault_name=Invalid frequency channel for the BTS HW
&{1807_allowed}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
...         fault_name=Invalid frequency channel for the BTS HW
...         notifier=
&{1900}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
...         fault_name=RF Module configuring failed
&{4673}     fault_id=4673
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="Configuration mismatch with O-RU capabilities"
&{4673_allowed}     fault_id=4673
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Configuration mismatch with O-RU capabilities"
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
&{1868_active}     fault_id=1868
...         alarm_id=7114
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name="BTS configuration error (not enough HW for LCR)"
&{1868_allowed}     fault_id=1868
...         alarm_id=7114
...         alarm_severity=Critical
...         fault_name="BTS configuration error (not enough HW for LCR)"
...         notifier=
&{1982_active}     fault_id=1982
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
...         fault_name="RF Module External Alarm and Control lines configuration failed"
&{1982_allowed}     fault_id=1982
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="RF Module External Alarm and Control lines configuration failed"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
&{1806_allowed}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         fault_name=Radio autonomous reset as recovery action
...         notifier=
&{4044}     fault_id=4044
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
...         fault_name=Incoherency in cell configuration
&{4008}     fault_id=4008
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
...         fault_name=Power level not supported
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
&{FAULT_4720}    fault_id=4720
...         alarm_id=7115
...         alarm_severity=regex"Warning|Minor|Major"
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=
&{4720_allowed}     fault_id=4720
...         alarm_id=7655
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=
&{FAULT_4681}    fault_id=4681
...         alarm_id=7115
...         alarm_severity=regex"Warning|Minor|Major"
...         fault_name="Diagnostic Check Error"
...         notifier=
&{4681_allowed}     fault_id=4681
...         alarm_id=7652
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name="Diagnostic Check Error"
...         notifier=
&{4008_allowed}     fault_id=4008
...         alarm_id=7112
...         alarm_severity=Critical
...         fault_name="Power level not supported"
...         notifier=

${APOABIO_IP}                           192.168.200.1
${APOABIO_user}                         toor4nsn
${APOABIO_pass}                         oZPS0POrRieRtu
${ABIO_RPC_cmd}                         user-rpc --content /tmp/
${ORU_container_path}                   /tmp/node_${ORU_ID}
${ORU_ID}                               ORU01
${lxc_id}                               0x551a
${S1LINK}                               ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/s1link.sh
${Remove_S1LINK}                        ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/Remove_s1link.sh
${INSTALL_OFGESA}                       ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/4G_install_ofgesa.sh
${SCF_FILE}                             ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/SCF_LTE_FDD.xml
${DELTA_FILE_OLD}                       ./testsuite/Bangalore/ORAN/T02/CB008205-A/resources/configurations/vlanid_old.json
${DELTA_FILE_NEW}                       ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/vlanid_new.json
${INSTALL_OFGESA_v7}                    ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/4G_install_ofgesa_v7.sh
${INSTALL_OFGESA_PRACH_disable}         ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/4G_install_ofgesa_PRACH_disable.sh
${INSTALL_OFGESA_TC03}                  ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/4G_install_ofgesa_get_error.sh
${SCF_FILE_PRACH_timeout}               ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/SCF_PRACH_TIMEOUT.xml
${INSTALL_OFGESA_supported_cells_0}     ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/4G_install_ofgesa_supported_cells_0.sh
${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         orusim
${Docker_user_name}			            inbabtslabuser
${Docker_password}			            BT5l@bus3rl0g1n
${NETCONF_TRACE_REMOTE_PATH}=           /tmp/node_FHNET80/tmp/RMOD_L-1_NetconfRpcMessageTrace_0.log
${EDIT_CMD}=                            edit-config --target running --config=/home/
${RPC_CMD}=                             user-rpc --content /opt/dev/xml
${XML_FILES_PATH}=                      ./testsuite/Bangalore/ORAN/T02/CB008205-A/xml-files
${SCF_PATH}=                            ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations
${CELL_DN}=                             /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-1
${MAX_NUM_CAR}=                         max-num-component-carriers
${MIN_BW_CAR}=                          min-carrier-bandwidth-dl
${MAX_POWER}=                           max-power-per-pa-antenna
${MIN_POWER}=                           min-power-per-pa-antenna
${DELTA_FILE_1}=                        ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/configurations/4G_delta_tr_array_nok.json
${DELTA_FILE_2}=                        ./testsuite/Bangalore/ORAN/T02/CB008205-A/configurations/4G_delta_tr_array_ok.json
${ACCOUNTS_CONFIGURATION}=              //div[contains(text(),'Accounts configuration')]
${DEFAULT_ACCOUNT_NAME}=                xranuser
${DEFAULT_ACCOUNT_PASS}=                xran-password
${WebEM IP}                             https://192.168.255.129:443
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${url}                                  https://192.168.255.129
${browser}                              Chrome
${sw_release}                           SBTS25R2
${oru_name}                             SSDORU-1
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${CONFIGURATION}=                       //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
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
${nrcell}=    MRBTS-1/NRBTS-1/NRCELL-1
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
${TC5_M1}=    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:
${TC5_M2}=    base:1.0"><static-prach-configurations nc:operation="create">
${TC4_M1}=    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><user-
${TC4_M2}=    plane-configuration xmlns="urn:o-ran:uplane-conf:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
${TC3_M1}=    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree">
${TC3_M2}=    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0">
${host}             127.0.0.1
${username}         ute
${password}         Utepassword@1
${cmd_TC03}=    set-failure name=o-ran-uplane-conf timeout-edit=90
${cmd_TC04_1900}=    set-failure name=o-ran-uplane-conf edit=true
${cmd_TC04_1900_cleared}=    set-failure name=o-ran-uplane-conf edit=false
${cmd_1806}=    set-static-prach-config-error type=TIMEOUT timeout=70
${cmd_TC05_1900}=    set-static-prach-config-error type=ERROR
${cmd_TC05_1900_cleared}=    set-static-prach-config-error type=NONE
${cmd_TC05_timeout}=    set-static-prach-config-error type=TIMEOUT timeout=70
&{authentication}   	   id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=       	   &{authentication}
&{default_user}=    	   defaultNetconfAccountName=xranuser
...                    	   defaultNetconfAccountPwd=xran-password


*** Keywords ***

TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    CB008205-A.Netconf File Collection
    Check Get Message For Optional Modules
    Check Information About Optional Features And Modules In Webem
    sleep    5

TC_03_Faults Handling During Retrieval Of endpoint-types, static-low-level-tx-endpoints And static-low-level-rx-endpoints
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC03}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Wait Until Mplane Is Connected
    Install OFGESA RU for <get-failure>
    ADMIN Assert All Rmods Are In Enabled State   timeout=600
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116
        ...    alarm_severity=Critical
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=RF Module configuring failed    timeout=360
        Run Keyword If   '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1900 visible
    CB008205-A.Netconf File Collection
    CB008205-A.Assert Gnb Receive An Error On The Appropriate Message In Oru
    ...    <rpc-error><error-type>application</error-type><error-tag>operation-failed</error-tag><error-severity>error</error-severity>
    ADMIN Reset Site
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    Install OFGESA RU
    sleep    100s
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    timeout=600
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Wait Until Mplane Is Connected
    CB008205-A.Remove S1 Link
    ADMIN Assert All Cells Are In Disabled State   timeout=1200
    CB008205-A.Prepare_Testline_with_OFGESA for PRACH timeout
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_TC03}
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1806    alarm_id=7101    alarm_severity=Warning
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=Radio autonomous reset as recovery action    timeout=360
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN Reset Site
    sleep    300
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END

TC_04_Faults Handling During Configuration Of TX RX Array Carriers And low-level-tx rx-endpoints
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC04_and_TC05}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    CB008205-A.Remove S1 Link
    ADMIN Assert All Cells Are In Disabled State   timeout=1200
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_TC04_1900}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116
        ...    alarm_severity=Critical
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=RF Module configuring failed    timeout=360
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1900 visible
    CB008205-A.Netconf File Collection
    CB008205-A.Assert Gnb Receive An Error On The Appropriate Message In Oru
    ...    <rpc-error><error-type>application</error-type><error-tag>operation-failed</error-tag><error-severity>error</error-severity>
    sleep    100
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_TC04_1900_cleared}
    ADMIN Reset Site
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
    END
    ADMIN Assert Alarm Inactive    fault_id=1900    alarm_id=7116
    ...    alarm_severity=Critical
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name=RF Module configuring failed    timeout=360
    sleep    300
    CB008205-A.Prepare_Testline_with_OFGESA for PRACH timeout
    CB008205-A.Remove S1 Link
    ADMIN Assert All Cells Are In Disabled State   timeout=1200
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_1806}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1806    alarm_id=7101    alarm_severity=Warning
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=Radio autonomous reset as recovery action    timeout=360
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1806 visible
    ADMIN Reset Site

TC_05_Faults Handling During Configuration Of Static PRACH Patterns To O-RU
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC04_and_TC05}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    CB008205-A.Remove S1 Link
    ADMIN Assert All Cells Are In Disabled State   timeout=1200
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_TC05_timeout}
    ADMIN Reset Site
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    sleep    300
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_TC05_1900}
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116
        ...    alarm_severity=Critical
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name=RF Module configuring failed    timeout=360
        Run Keyword If   '${status}' == 'True'    Exit For Loop
    END
    Log To Console    Fault 1900 visible
    CB008205-A.Netconf File Collection
    CB008205-A.Assert Gnb Receive An Error On The Appropriate Message In Oru
	...    <rpc-error><error-type>application</error-type><error-tag>operation-failed</error-tag><error-severity>error</error-severity>
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_TC05_1900_cleared}
    ADMIN Reset Site
    sleep    300
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN Assert Alarm Inactive    fault_id=1900    alarm_id=7116
    ...    alarm_severity=Critical
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name=RF Module configuring failed    timeout=360
    sleep    300
	Wait Until Mplane Is Connected
    CB008205-A.Prepare_Testline_with_OFGESA for PRACH timeout
    CB008205-A.Remove S1 Link
    ADMIN Assert All Cells Are In Disabled State   timeout=1200
    CB008205-A.Create SSH Session To ORU and trigger fault    ${cmd_1806}
    FOR    ${i}	   IN RANGE    2
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
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
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END

TC_06_Capabilities Mismatch Detection
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC06}
    Prepare_Testline_with_V7_OFGESA
    Wait Until Mplane Is Connected
    Prepare_Testline_with_OFGESA_PRACH_disabled
    ADMIN Assert Alarm Active    fault_id=4673    alarm_id=7115
    ...    alarm_severity=Minor
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="Configuration mismatch with O-RU capabilities"    timeout=360
    Log To Console    Fault 4673 visible
    ADMIN Reset Site
    sleep    300
    CB008205-A.Netconf File Collection
    Check If Static Prach Capability Is Not Supported In O-RU
    Prepare_Testline_with_V7_OFGESA
    ADMIN Assert Alarm Inactive    fault_id=4673    alarm_id=7115
    ...    alarm_severity=Minor
    ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="Configuration mismatch with O-RU capabilities"    timeout=360
    Wait Until Mplane Is Connected

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
    Install OFGESA RU
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    Change VlanId
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log to console   \nCell is in OnAir state

Configure Netconf Credentials
    [Arguments]    @{list}
    taf.sbts.oam.coam.admin.Setup Admin
    configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}
    taf.sbts.oam.coam.admin.Teardown Admin

CB008205-A.Netconf File Collection
    taf.sbts.oam.coam.admin.Setup Admin    name=snapshot
    Run Keyword And Return Status    OperatingSystem.Create Directory    ${output}
    OperatingSystem.Empty Directory    ${output}
    ${snapshot1}=    taf.sbts.oam.coam.admin.collect_snapshot    target_file_name=${output}/Snapshotfile.zip
    ...    timeout=300    connection=snapshot
    sleep    15
    taf.sbts.oam.coam.admin.Teardown Admin    connection=snapshot
    CB008205-A.Extract netconf from snapshot


snapshotFileIdentifier
    @{getWithoutFilerValue}=    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${output}/Snapshotfile.zip
    ...    path=${output}
    ...    fileToBeChecked=NetconfRpcMessageTrace
    [Return]    @{getWithoutFilerValue}

CB008205-A.Extract netconf from snapshot
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
        OperatingSystem.Copy file    ${output}/${netconf_filename}[0]    ${output}/RMOD_L-1_NetconfRpcMessageTrace.log

Prepare_Testline_with_V7_OFGESA
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    Configure Netconf Credentials    @{sudo_list}
    Install V7 OFGESA RU
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install V7 OFGESA RU
        sleep    100s
    END
    Change VlanId
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log to console   \nCell is in OnAir state

Check VlanId
    ${vlanId}=    ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-*/VLANIF_CONF_M-1
    ...    parameter=vlanId
    ...    alias=infomodel_1
    ${vlanId_str}=    Convert to String    ${vlanId}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/../configurations/vlanid_new.json      ${replace}

Change VlanId
    ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

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

CB008205-A WTSSIM S1 Link Establish
     Run    chmod 777 ${S1LINK}
     Run    sh ${S1LINK}
     Log to console   \nEstablishing S1 link...

CB008205-A.Remove S1 Link
     Run    chmod 777 ${Remove_S1LINK}
     Run    sh ${Remove_S1LINK}
     Log to console   \nRemovinging S1 link...

CB008205-A.Trigger for o-ran-test-set-failure-upconf-edit-ko backdoor command
    CB008205-A.Copy Xml And Send Cmd to ORU    o-ran-test-set-failure-upconf-edit-ko.xml    ${XML_FILES_PATH}/alarm

CB008205-A.clear Fault 1900 sending o-ran-test-set-failure-upconf-edit-ok
    CB008205-A.Copy Xml And Send Cmd to ORU    o-ran-test-set-failure-upconf-edit-ok.xml    ${XML_FILES_PATH}/alarm

CB008205-A.Trigger Fault 1806 timeout with o-ran-test-set-failure-upconf-edit-timeout
    CB008205-A.Copy Xml And Send Cmd to ORU    o-ran-test-set-failure-upconf-edit-timeout.xml    ${XML_FILES_PATH}/alarm

CB008205-A.Trigger for PRACH timeout
    CB008205-A.Copy Xml And Send Cmd to ORU    prach-timeout.xml    ${XML_FILES_PATH}/alarm

CB008205-A.TC05_clear Fault 1900 With Severity Critical
    CB008205-A.Copy Xml And Send Cmd to ORU    o-ran-test-uplane-static-prach-error.xml    ${XML_FILES_PATH}/alarm

CB008205-A.Trigger Fault 1806 for PRACH timeout
    CB008205-A.Copy Xml And Send Cmd to ORU    prach-timeout.xml    ${XML_FILES_PATH}/alarm

CB008205-A.TC_05_Trigger Fault 1900 With Severity Critical
    CB008205-A.Copy Xml And Send Cmd to ORU    o-ran-test-uplane-static-prach-error.xml    ${XML_FILES_PATH}/alarm

CB008205-A.Trigger Fault 1806 for <get-failure>
    CB008205-A.Copy Xml And Send Cmd to ORU    o-ran-test-set-failure-upconf-get-timeout.xml    ${XML_FILES_PATH}/alarm

Install OFGESA RU for <get-failure>
    Run    chmod +x ${INSTALL_OFGESA_TC03}
    Run    sh ${INSTALL_OFGESA_TC03}
    Log to console    \nInstalling OFGESA radio for test-failure on <get-message>

Prepare_Testline_with_OFGESA_PRACH_disabled
    Install OFGESA RU with PRACH disabled
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=600
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU with PRACH disabled
        sleep    100s
    END
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-A WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Log to console   \nCell is in OnAir state

Install OFGESA RU with PRACH disabled
    Run    chmod +x ${INSTALL_OFGESA_PRACH_disable}
    Run    sh ${INSTALL_OFGESA_PRACH_disable}
    Log to console    \nInstalling modified OFGESA radio with PRACH STATIC configuration disabled

Assert Gnb Receive An Error On The Appropriate Message In Oru
    [Arguments]    ${message_TC}
    ${message}=    CB008205-A.Check Message In Netconf Trace File    ${message_TC}
    log to console    ${message_TC}
    log to console    ${message}
    Should Contain    ${message}    ${message_TC}
    Should Contain    ${message}
    ...    <rpc-error>

Check Message In Netconf Trace File
    [Arguments]    ${message_to_grep}
    ...            ${local_file_path}=${output}/RMOD_L-1_NetconfRpcMessageTrace.log
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path}
    [Return]    ${output}


Check If Static Prach Capability Is Not Supported In O-RU
    ${module_retrieval_id}    CB008205-A.Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="xpath" xmlns:yanglib
    ...    tail -n 1
    Should Not Be Empty    ${module_retrieval_id}
    ${get_modules}    CB008205-A.Check Message In Netconf Trace File    ${module_retrieval_id}
    Should Not Contain     ${get_modules}
    ...    <rpc-error>
    Should Not Contain     ${get_modules}
    ...    PRACH-STATIC-CONFIGURATION-SUPPORTED


Check Message Id
    [Arguments]    ${message_to_grep}
    ...            ${grep_option}=head -n 1
    ...            ${local_file_path}=${output}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log to console    grep message in netconf trace
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path} | ${grep_option}
    ${output_1}    Fetch From Left    ${output}    "><
    ${message_id}    Fetch From Right    ${output_1}    message-id=
    [Return]   ${message_id}


CB008205-A.Prepare_Testline_with_OFGESA for PRACH timeout
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE_PRACH_timeout}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    Configure Netconf Credentials    @{sudo_list}
    ADMIN Assert All Rmods Are In Enabled State   timeout=900
    Change VlanId
    sleep    10

Install v7 OFGESA RU
    Run    chmod +x ${INSTALL_OFGESA_v7}
    Run    sh ${INSTALL_OFGESA_v7}
    Log to console    \nInstalling modified OFGESA radio with ORAN v7

Install OFGESA RU with Support Specified Number Of Cells to 0
    Run    chmod +x ${INSTALL_OFGESA_supported_cells_0}
    Run    sh ${INSTALL_OFGESA_supported_cells_0}
    Log to console    \nInstalling modified OFGESA radio with modified max supported cell configuration to 0

Prepare Enviroment
    Chmod Chromedriver
    Run Xvfb
    Export DISPLAY

Go To Netconf Radio Management Tab
    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over  locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Click Element   locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Wait Until Element Is Visible    locator=${ACCOUNTS_CONFIGURATION}

Configure Default Netconf Account
    selenium.add_oru_account    60
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.send_netconf_configuration


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

Test Teardown
    Collect SOS report
    CB008205-A.Collect Snapshot

Collect SOS report
    Run     chmod 777 /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    ${output} =    OperatingSystem.Run    pwd
    Run     sudo rm ${output}/SosReport*_UEAPP1.tgz
    Run     /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    Wait Until Created    ${output}/SosReport*_UEAPP1.tgz    400s
    Run     sudo cp ${output}/SosReport*_UEAPP1.tgz ${output}

Collect Snapshot
    taf.sbts.oam.coam.admin.collect_snapshot    target_file_name=${output}/Snapshotfile.zip    connection=suite

counter create
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    PM.create PM collector
    ...  name=gnb_pm_counters
    ...  webservice=${webservice}
    ...  for_last=1 hour
    ...  intervals=15
    PM.setup_collectors
    ...  names=gnb_pm_counters
    PM.collect_collectors
    ...  names=gnb_pm_counters     target_dir=/home/ute/results
    PM.teardown_collectors
    ...  names=gnb_pm_counters

counter analyser
  ${pi_list}=  Create List
  ...  M8087C11
  ...  M8087C13
  ...  M8087C15
  ...  M8087C17
  ...  M8087C19
  ...  M8087C21
  ${pi_dict}=  get_pi_value
  ...  pi_list=${pi_list}
  ...  pi_dir=/home/ute/results/gnb_pm_counters/
  ...  pi_file_pattern=PM*
  Log  ${pi_dict}

Check Get Message For Optional Modules
    ${opt_modules_id}    CB008205-A.Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="xpath" xmlns:yanglib
    Should Not Be Empty    ${opt_modules_id}
    ${opt_modules}    CB008205-A.Check Message In Netconf Trace File    ${opt_modules_id}
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

EarfcnDL Recommissioning
    [Arguments]    ${earfcn_dl_value}
    Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_FDD-0
    ...    parameter=earfcnDL
    ...    value=${earfcn_dl_value}
    ...    timeout=200
    Log To Console      ${\n}earfcnDL recommissioned: ${earfcn_dl_value}

EarfcnUL Recommissioning
    [Arguments]    ${earfcn_ul_value}
    Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_FDD-0
    ...    parameter=earfcnUL
    ...    value=${earfcn_ul_value}
    ...    timeout=200
    Log To Console      ${\n}earfcnUL recommissioned: ${earfcn_ul_value}

Channel Bandwidth Delta Recommissioning
    [Arguments]    ${chbw_delta}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${chbw_delta}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=admin_1
    Log To Console    ${\n}Channel Bandwidth recommissioned

Pmax Recommissioning
    [Arguments]    ${pmax_value}
    Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1/LNCEL-1
    ...    parameter=pMax
    ...    value=${pmax_value}
    ...    timeout=200
    Log To Console      ${\n}pMax recommissioned: ${pmax_value}

EcpriMonitoring Recommissioning
    [Arguments]    ${ecpriMonitoring_value}
    Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1/PMRNL-1
    ...    parameter=mteCPRIMonitoring
    ...    value=${ecpriMonitoring_value}
    ...    timeout=200
    Log To Console      ${\n}EcpriMonitoring recommissioned: ${ecpriMonitoring_value}

Trigger Fault 1900 With Severity Critical
    Copy Xml And Send Cmd to ORU    o-ran-pm-ko.xml    ${XML_FILES_PATH}/alarm

clear Fault 1900 With Severity Critical
    Copy Xml And Send Cmd to ORU    o-ran-pm-ok.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 1806 for Performance management timeout
    Copy Xml And Send Cmd to ORU    o-ran-pm-edit-timeout.xml    ${XML_FILES_PATH}/alarm

Copy Xml And Send Cmd to ORU
    [Arguments]    ${file}      ${path}
    Copy Xml And Send Cmd By Netopeer Cli to APOABIO    ${file}    ${path}

Supervision notification interval and supervision guard timer overhead recommissioning
    [Arguments]    ${supervision_timer_delta}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${supervision_timer_delta}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=admin_1
    Log To Console    ${\n}Supervision and guard timers recommissioned

Create SSH Session To ORU and trigger fault
    [Arguments]    ${cmd}
    ${result}=    Run Process    ssh    oru01@192.168.200.1    ${cmd}
    Log to Console    ${result.rc}
    Log to Console    ${result.stdout}
    Log to Console    ${result.stderr}


Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    Run    hostname
    [Documentation]    :Author: Mallikarjuna
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s


FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}
