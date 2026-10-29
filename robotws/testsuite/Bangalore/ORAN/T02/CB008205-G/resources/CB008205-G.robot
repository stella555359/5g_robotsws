*** Settings ***

Documentation
...    Author: rubina.nath@nokia.com
...    Maintainer: anagha.chenniga@nokia.com
...    Test Description for CB008205: This feature is firstly supported in ASIL + ABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -B is related to NR FDD technology.
...    CB009196-SR: Split covered: CB009196-A/B/C/D positive scenarios for counter verification, SFP monitoring
...    and alarm generation and cancellation for ORAN specific and alarms with unknown fault sources.
...    CB008967-F-SR: Thermal state monitoring for RMOD_O-RU Temperature counters by generating KPI alarms.
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_TITANS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_TITANS_SQD@internal.nsn.com>


Library    String      WITH NAME   str
Library    taf.transport.ssh
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library    taf.analyzer.netconf    WITH NAME    yang
Library    SSHLibrary
Library    Collections
Library    BuiltIn
Library    SeleniumLibrary
Library    Process
Library    String
Library    taf.sw.scout    WITH NAME    scout
Library    taf.analyzer.netconf
Library    ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.selenium.sbts    WITH NAME    soam
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.file.pack
Library     ./testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/selenium_keywords.robot
#Resource    ./testsuite/Bangalore/ORAN/T02/resources/robot/CommonKeywordsResourceFile.robot
Library             OperatingSystem

*** Variables ***

${UPDATE_FILE_PATH}    /home/ute/RF_PCI/2392/Download_gNB_Package
${DIST_NAME}           MRBTS-{}/NRBTS-{}
${LOG_PATH}             /home/ute/results/troubleshooting_logs
${sw_release}
${url}                                  https://192.168.255.129
${browser}                              Chrome
${oru_name}                             SSDORU-1
${DEFAULT_ACCOUNT_NAME}=    xranuser
${DEFAULT_ACCOUNT_PASS}=    xran-password

@{ALLOWED_ALARMS}    &{4592}    &{10_allowed}    &{4729_allowed}        &{4720}    &{7305_allowed}    &{7107_allowed}
...    &{7523_allowed}    &{7304_allowed}    &{7308_allowed}
@{ALLOWED_ALARMS_TC04}    &{4592}    &{10_allowed}    &{4729_allowed}        &{4720}    &{7305_allowed}    &{7107_allowed}
...    &{7523_allowed}    &{7304_allowed}    &{7308_allowed}    &{4588}    &{4587}    &{4586}
&{4592}     fault_id=4592
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{1500}     fault_id=1500
...         alarm_id=7240
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="alarm1"
&{4729_allowed}     fault_id=4729
...         alarm_id=7115
...         alarm_severity=Warning
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="O-RU host key change detected"
&{4729}     fault_id=4729
...         alarm_id=7115
...         alarm_severity=Warning
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="O-RU host key change detected"
&{10_allowed}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="No connection to unit"
&{10}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="No connection to unit"
&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
&{7305_allowed}     fault_id=7305
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP setup fail"
...         notifier=
&{7107_allowed}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=regex"Critical|Minor|Major"
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=
&{7523_allowed}     fault_id=7523
...         alarm_id=7115
...         alarm_severity=Critical
...         fault_name="Cell Activation timeout at gNB-DU"
...         notifier=
&{7304_allowed}     fault_id=7304
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP endpoint broken"
...         notifier=
&{7308_allowed}     fault_id=7308
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="Transport layer connection failure in X2 interface"
...         notifier=

${RSA_FILE}=                            /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-G/Configurations/rsa.pub
${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         orusim
${NETCONF_TRACE_REMOTE_PATH}=           /tmp/node_FHNET80/tmp/RMOD_L-1_RPC.log
${NETCONF_TRACE_LOCAL_PATH}=            /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${XML_DOCKER_PATH}=                     /home
${EDIT_CMD}=                            edit-config --target running --config=/home/
${RPC_CMD}=                             user-rpc --content /opt/dev/xml
${ORU_SIM_IP}=                          10.42.17.69
${SCF_PATH}=                            /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-G/Configurations
${WebEM IP}                             https://192.168.255.1:3600
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${PLUS_BUTTON_TRUNK}
...  //button[@class="p-element p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${PLUS_BUTTON_22R2}    //button[@class="ui-button-secondary ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only"]
${SEND_BUTTON}=                         //span[contains(text(), 'Send')]
${CONFIGURE_RADIO_SUCCEEDED}=           //span[contains(text(), 'Configure netconf radio succeeded')]
${CONFIGURATION}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${NETCONF_RADIO_MANAGEMENT_BUTTON}=     //span[contains(text(),'Netconf Radio Management')]
${ACCOUNTS_CONFIGURATION}=    //div[contains(text(),'Accounts configuration')]
${ADDITIONAL_ACCOUNT_NAME}=    xranuser2
${ADDITIONAL_ACCOUNT_PASS}=    Xran-Password11!!
${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}=    //span[contains(text(),'Configure Additional Netconf Account')]
${UNSECURE_CIPHERS}=    //span[@id="pr_id_3_label"]
${SSH_AUTH_METHOD}=    //span[@id="pr_id_4_label"]
${TRASH_BUTTON}=    //button[@class="p-element delete-account p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${RMOD_PATH}=    MRBTS-1/EQM-1/APEQM-1/RMOD-1
${NETCONF_MESSAGE}=    <config><nacm xmlns="urn:ietf:params:xml:ns:yang:ietf-netconf-acm"><groups><group><name>
...    sudo</name><user-name>xranuser2</user-name></group></groups></nacm></config>
${ACCOUNT_REMOVE_BUTTON}=    //button[@class="p-element p-button-secondary p-button p-component p-button-icon-only ng-star-inserted"]
${INSTALL_OFGESA}				        ${CURDIR}/../Configurations/5G_install_ofgesa.sh
${INSTALL_OFGESA_v7}				        ${CURDIR}/../Configurations/5G_install_ofgesa_v7.sh
${INSTALL_SAMJI_v7}				        ${CURDIR}/../Configurations/5G_install_SAMJI_v7.sh
${SCF_FILE}					        ${CURDIR}/../Configurations/SANSA_scf_ofgesa_cloud.xml
${SCF_FILE_1}					        ${CURDIR}/../Configurations/SANSA_scf_SAMJI_cloud.xml
${DELTA_FILE_OLD} 				        ${CURDIR}/../Configurations/vlanid_old.json
${DELTA_FILE_NEW}         	        	        ${CURDIR}/../Configurations/vlanid_new.json
${X2LINK}		 				        ${CURDIR}/../Configurations/x2link.sh
${X2LINK_SAMJI}		 				        ${CURDIR}/../Configurations/x2link_SAMJI.sh
@{netconf_list_fault_9196C}=     28    21    25    30    16    23    2    4
@{fault_list_9196CFaults}=    4654    61524    4655    4720    4176    61649
...                           1955    1928    1923    1981    2907    2908    4    2
...                           7116    7115    7220    7241    7240    7101    7111    7100
@{sfp_list}=    interface-name    port-number    name    vendor-id    vendor-part    vendor-rev
...             present    serial-no    connector-type    identifier    SFF8472-compliance-code

${BTS_ADDRESS} =           192.168.255.129
${ssh_username}=           toor4nsn
${ssh_password}=           oZPS0POrRieRtu
${password_BTS}=           BT5l@bus3rl0g1n
${value_true}=            true
${value_false}=           false
${connection}=            default
${BTS_ADDRESS_iphy} =      192.168.200.1
${netconf_password}=       netconf
${Netconf_Login_cmd}=      connect --ssh --login netconf --host 127.0.0.1 --port 830
${Backdoor_cmd_apoabio}=          /opt/UE-APP-OAM-oru/service/oran/xml/backdoor/alarm
${Backdoor_alr1_gen}=             fm-test-1-alarm-fid_4.xml
${Backdoor_alr2_gen}=             fm-test-1-alarm-fid_2.xml
${Backdoor_alr1_clr}=             fm-test-1-alarm-fid_4-clearing.xml
${Backdoor_alr2_clr}=             fm-test-1-alarm-fid_2-clearing.xml
${xmlfile_commonline1}=      		 <?xml version="1.0"?>\n<active-alarm-test-list xmlns="urn:o-ran-test:fm:1.0">\n<active-alarms>
${xmlfile_line4_fault21}=    		 <fault-name>EFaultId_IncrBerOnRp3Al</fault-name>\n<fault-id>21</fault-id>
${xmlfile_line6_fault21}=    		 <fault-source>sfp0</fault-source>
${xmlfile_commonline7}=		         <affected-objects>\n<name>Object 1</name>\n</affected-objects>
${xmlfile_commonline10}=   		     <fault-severity>MAJOR</fault-severity>
${xmlfile_commonline11}=     		 <is-cleared>false</is-cleared>\n<fault-text>Fault caused by source 1 affecting 3 objects</fault-text>
${xmlfile_commonline12}=     		 <event-time>2020-08-13T15:13:28+02:00</event-time>\n</active-alarms>\n</active-alarm-test-list>
${xmlfile_commonline13_clear}=       <is-cleared>true</is-cleared>\n</active-alarms>\n</active-alarm-test-list>
${xmlfile_line10_fault25}=   <fault-severity>CRITICAL</fault-severity>
${xmlfile_line4_fault25}=    <fault-name>EFaultId_FrResetRequestedAl</fault-name>\n<fault-id>25</fault-id>
${xmlfile_line4_fault30}=    <fault-name>EFaultId_RfInterfaceFaultyAl</fault-name>\n<fault-id>30</fault-id>
${xmlfile_line4_fault28}=    <fault-name>EFaultId_RfCUPlaneLogicalConnectionFaultyAl</fault-name>\n<fault-id>28</fault-id>
${xmlfile_line6_fault28}=    <fault-source>NR1.TLINK1_1_1</fault-source>
${xmlfile_line4_fault23}=    <fault-name>EFaultId_FrFpgaSwUpdateFailedAl</fault-name>\n<fault-id>23</fault-id>
${xmlfile_line4_fault16}=    <fault-name>EFaultId_FrUnitUnidentifiedA</fault-name>\n<fault-id>16</fault-id>
${xmlfile_commonline6}=      <fault-source>N75N3N1-G-RU</fault-source>

@{faultListofXMLlines21}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault21}    ${xmlfile_line6_fault21}]
...                           ${xmlfile_commonline7}    ${xmlfile_commonline10}     ${xmlfile_commonline11}    ${xmlfile_commonline12}
@{faultListofXMLlines23}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault23}    ${xmlfile_commonline6}
...                           ${xmlfile_commonline7}    ${xmlfile_commonline10}     ${xmlfile_commonline11}    ${xmlfile_commonline12}
@{faultListofXMLlines28}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault28}    ${xmlfile_line6_fault28}
...                           ${xmlfile_commonline7}    ${xmlfile_commonline10}     ${xmlfile_commonline11}    ${xmlfile_commonline12}
@{faultListofXMLlines30}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault30}    ${xmlfile_commonline6}
...                           ${xmlfile_commonline7}    ${xmlfile_commonline10}     ${xmlfile_commonline11}    ${xmlfile_commonline12}
@{faultListofXMLlines16}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault16}    ${xmlfile_commonline6}
...                           ${xmlfile_commonline7}    ${xmlfile_commonline10}     ${xmlfile_commonline11}    ${xmlfile_commonline12}
@{faultListofXMLlines25}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault25}    ${xmlfile_commonline6}
...                           ${xmlfile_commonline7}    ${xmlfile_line10_fault25}     ${xmlfile_commonline11}    ${xmlfile_commonline12}

@{faultListofXMLlines28_clear}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault28}    ${xmlfile_commonline13_clear}
@{faultListofXMLlines21_clear}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault21}    ${xmlfile_commonline13_clear}
@{faultListofXMLlines23_clear}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault23}    ${xmlfile_commonline13_clear}
@{faultListofXMLlines30_clear}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault30}    ${xmlfile_commonline13_clear}
@{faultListofXMLlines16_clear}=     ${xmlfile_commonline1}    ${xmlfile_line4_fault16}    ${xmlfile_commonline13_clear}

${fault21_gen_xmlfilename}=      fm-test-21-alarm.xml
${fault23_gen_xmlfilename}=      fm-test-23-alarm.xml
${fault25_gen_xmlfilename}=      fm-test-25-alarm.xml
${fault28_gen_xmlfilename}=      fm-test-28-alarm.xml
${fault30_gen_xmlfilename}=      fm-test-30-alarm.xml
${fault16_gen_xmlfilename}=      fm-test-16-alarm.xml
${fault21_clear_xmlfilename}=    fm-test-21-alarm-clearing.xml
${fault23_clear_xmlfilename}=    fm-test-23-alarm-clearing.xml
${fault28_clear_xmlfilename}=    fm-test-28-alarm-clearing.xml
${fault30_clear_xmlfilename}=    fm-test-30-alarm-clearing.xml
${fault16_clear_xmlfilename}=    fm-test-16-alarm-clearing.xml

${operation_value}=    update
@{miOranEpeStats_CounterList}=	        M40021C0	M40021C1	M40021C2	M40021C3	M40021C4	M40021C5
...	                                M40021C7	M40021C8	M40021C9	M40021C10	M40021C11       M40021C6
@{miOranTrxStats_CounterList}=	M40027C1     M40027C2     M40027C3 	M40027C4     M40027C5
...                                     M40027C10     M40027C9     M40027C8    M40027C6     M40027C11     M40027C12     M40027C18     M40027C20
...                                     M40027C7     M40027C13     M40027C14     M40027C15     M40027C16    M40027C17    M40027C19
@{miOranRuTxStats_CounterList}=	        M40022C0
@{miRxWindowStats_CounterList}=         M55604C00001    M55604C00002    M55604C00003    M55604C00006    M55604C00007    M55604C00008
...                                     M55604C00009    M55604C00009    M55604C00010    M55604C00011    M55604C00012
${miOranEpeStats_name}=     	    miOranEpeStats
${miOranRuTxStats_name}=       	    miOranRuTxStats
${miOranTrxStats_name}=   	    miOranTrxStats
${miRxWindowStats_name}=            miRxWindowStats
${windowStatsValue}=       	    5min
${windowStatsValue_disable}=        disabled
${NetconfFileName}=                 RMOD_L-1_NetconfRpcMessageTrace.log
${distname_pmmnl}=            	    MRBTS-1/MNL-1/MNLENT-1/PMMNL-1
@{Trx_capabilities}=        TX_TOTAL
@{RuTx_capabilities}=       TX_TOTAL
${miOranRuTxStats_Counter}=     BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['ORTX
${miOranTrxStats_Counter}=    BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST
${miRxWindowStats_Counter}=     BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['RURWS
${miOranEpeStats_Counter}=      BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['OEPE
@{active}=    true    false
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
&{authentication1}   id=1    defaultNetconfAccount=&{default_user}
@{sudo_list1}=       &{authentication1}
${windowvalue}=     		  5min
${miTrRxWindowStats_name}=            miTrRxWindowStats
${miTrRxWindowStats_Counter}=      TRS']['MRBTS-1']['TNLSVC-1']['TNL-2']['ETHSVC-1']['ETHLK-2']['TRRWS
@{miTrRxWindowStats_CounterList}=         M55605C00001    M55605C00002    M55605C00003    M55605C00006    M55605C00007    M55605C00008
...                                     M55605C00009    M55605C00009    M55605C00010    M55605C00011    M55605C00012
${LOGS_PATH}=    /home/ute/results
${delta_file_for_Temps_activate}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-G/Configurations/ORAN_TEMP_CONFG_SR.json
${delta_file_for_Temps_deactivate}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-G/Configurations/ORAN_TEMP_CONFG_DEACTIVATE.json
&{4586}=    fault_id=4586
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=MRBTS-1/EQM-1/APEQM-1/RMOD-1
...         fault_name=The following KPI formula O_RAN_RADIO_TEMPERATURE_MAX>32 has been evaluated to true: ORAN Radio Temp max
...	    notifier=
...         timeout=120
&{4587}=    fault_id=4587
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=MRBTS-1/EQM-1/APEQM-1/RMOD-1
...         fault_name=The following KPI formula O_RAN_RADIO_TEMPERATURE_MIN>32 has been evaluated to true: ORAN Radio Temp min
...	    notifier=
...	    timeout=60
&{4588}=    fault_id=4588
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=MRBTS-1/EQM-1/APEQM-1/RMOD-1
...         fault_name=The following KPI formula O_RAN_RADIO_TEMPERATURE_AVG>32 has been evaluated to true: ORAN Radio Temp Avg
...	    notifier=
...	    timeout=60
@{Active_alarms}=    &{4586}    &{4587}    &{4588}
${distname_featcadm}=    MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1
${parameter_actkpi}=    actKpiAlarms
${value_actkpi}=    true
${BTS_path}=    /home/ute/Logs
${Python_Backdoor}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-G/Configurations
${temp_min}=    60
${temp_max}=    80
${temp_avg}=    70


*** Keywords ***
[1]CB009196-B_Verification_of_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_higher
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Prepare_Testline_with_OFGESA v7
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Netconf File Collection
    CB008205-G.Validating M-plane negotiation    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log


[1]CB009196-C_Handling_of_O-RU_fault_notification_for_faults_28,30,16,25,23_&_21
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA v7
	Log    UnknownSources
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_cmd_apoabio}/${Backdoor_alr1_gen}
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_cmd_apoabio}/${Backdoor_alr2_gen}
    admin.setup_admin
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_cmd_apoabio}/${Backdoor_alr1_clr}
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_cmd_apoabio}/${Backdoor_alr2_clr}
    ${alr}=     admin.get_historic_alarms
    log    ${alr}
    Wait Until Keyword Succeeds     10m    10s    CB008205-G.Check_BTS_State
    Netconf File Collection
    CB008205-G.MessageVerification_alarm    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log    @{netconf_list_fault_9196C}
    Log    ORANFaults
    CB008205-G.Create_alarm_xml    ${fault21_gen_xmlfilename}    @{faultListofXMLlines21}
    CB008205-G.Create_alarm_xml    ${fault23_gen_xmlfilename}    @{faultListofXMLlines23}
    CB008205-G.Create_alarm_xml    ${fault25_gen_xmlfilename}    @{faultListofXMLlines25}
    CB008205-G.Create_alarm_xml    ${fault28_gen_xmlfilename}    @{faultListofXMLlines28}
    CB008205-G.Create_alarm_xml    ${fault30_gen_xmlfilename}    @{faultListofXMLlines30}
    CB008205-G.Create_alarm_xml    ${fault16_gen_xmlfilename}    @{faultListofXMLlines16}
    CB008205-G.Create_alarm_xml    ${fault21_clear_xmlfilename}    @{faultListofXMLlines21_clear}
    CB008205-G.Create_alarm_xml    ${fault23_clear_xmlfilename}    @{faultListofXMLlines23_clear}
    CB008205-G.Create_alarm_xml    ${fault28_clear_xmlfilename}    @{faultListofXMLlines28_clear}
    CB008205-G.Create_alarm_xml    ${fault30_clear_xmlfilename}    @{faultListofXMLlines30_clear}
    CB008205-G.Create_alarm_xml    ${fault16_clear_xmlfilename}    @{faultListofXMLlines16_clear}
    Sleep    10s
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault21_gen_xmlfilename}
    Sleep    60s
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault21_clear_xmlfilename}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault23_gen_xmlfilename}
    Sleep    60s
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault23_clear_xmlfilename}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault16_gen_xmlfilename}
    Sleep    60s
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault16_clear_xmlfilename}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault28_gen_xmlfilename}
    Sleep    60s
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault28_clear_xmlfilename}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault30_gen_xmlfilename}
    Sleep    60s
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    ${alr}=     admin.get_historic_alarms
    log    ${alr}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault30_clear_xmlfilename}
    CB008205-G.Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault25_gen_xmlfilename}
    CB008205-G.Check ActiveFaultandAlarmID    @{fault_list_9196CFaults}
    Sleep    120s
    Wait Until Keyword Succeeds     10m    10s    CB008205-G.Check_BTS_State
    Netconf File Collection
    CB008205-G.MessageVerification_alarm    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log    @{netconf_list_fault_9196C}
    admin.teardown_admin

[1]CB009196_Verification_of_miOranRuTxStats_miOranTrxStats_miOranEpeStats_and_miRxWindowStats_counters_activation
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA v7
    Log    Activation of all counters and checking values reported for each counter
    admin.setup_admin
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranTrxStats_name}    ${windowStatsValue}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miRxWindowStats_name}    ${windowStatsValue}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranRuTxStats_name}    ${windowStatsValue}
    FOR    ${i}	   IN RANGE    3
        Sleep	20s
        ${status}=	Run Keyword And Return Status	CB008205-G.Check_BTS_State
        Run Keyword If    '${status}' == 'True'    Exit For Loop
        CB008205-G WTSSIM X2 Link Establish
    END
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miOranTrxStats_Counter}    @{miOranTrxStats_CounterList}
	Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miRxWindowStats_Counter}    @{miRxWindowStats_CounterList}
	Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miOranEpeStats_Counter}    @{miOranEpeStats_CounterList}
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check   ${miOranRuTxStats_Counter}   @{miOranRuTxStats_CounterList}
	Log    Deactivation of all counters and checking value reported should be 0
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranTrxStats_name}    ${windowStatsValue_disable}
	CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miRxWindowStats_name}    ${windowStatsValue_disable}
	CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue_disable}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranRuTxStats_name}    ${windowStatsValue_disable}
	Wait Until Keyword Succeeds     2m    10s    CB008205-G.Check_BTS_State
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miOranTrxStats_Counter}    @{miOranTrxStats_CounterList}
	Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miRxWindowStats_Counter}    @{miRxWindowStats_CounterList}
	Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miOranEpeStats_Counter}    @{miOranEpeStats_CounterList}
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check   ${miOranRuTxStats_Counter}   @{miOranRuTxStats_CounterList}
    Log    Validation of logs
    Netconf File Collection
    CB008205-G.Netconf_MessageVerification_9196related_messages    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log    @{Trx_capabilities}
    CB008205-G.Netconf_MessageVerification_9196related_messages    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log    @{RuTx_capabilities}
    admin.teardown_admin

CB010918_A_Verification_of_delay_parameters_and_performance_activation_and deactivation_as per_IOT_profile.
    Prepare_Testline_with_SAMJI v7
    admin.setup_admin
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miRxWindowStats_name}    ${windowvalue}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranTrxStats_name}    ${windowvalue}
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miRxWindowStats_Counter}    @{miRxWindowStats_CounterList}
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miOranTrxStats_Counter}    @{miOranTrxStats_CounterList}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miRxWindowStats_name}    ${windowStatsValue_disable}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranTrxStats_name}    ${windowStatsValue_disable}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miTrRxWindowStats_name}    ${windowvalue}
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    CB008205-G.Counter_Value_Check    ${miTrRxWindowStats_Counter}    @{miTrRxWindowStats_CounterList}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miTrRxWindowStats_name}    ${windowStatsValue_disable}
    admin.teardown_admin

Perform Parameter Recommissioning
    [Arguments]    ${parameter_dist_name}    ${parameter_name}     ${value}
    admin.perform_parameter_recommissioning
    ...    dist_name=${parameter_dist_name}
    ...    parameter=${parameter_name}
    ...    operation=${operation_value}
    ...    value=${value}
    ...    skip_parameter_relation_errors=${value_true}
    ...    should_activate=${value_true}
    ...    timeout=300
    Sleep    60s

Netconf_MessageVerification_9196related_messages
    [Arguments]    ${netconf_file}    @{message}
    ${pm}=    netconf_get_value     ${netconf_file}    rpc    edit-config    measurement-object
    FOR    ${i}    IN    @{message}
        ${Value to check}    Evaluate    '${i}' in [item[1][0] for item in ${pm}]
        run keyword and continue on failure   Should Be True    ${Value to check}
    END
    ${pm1}=    netconf_get_value    ${netconf_file}    rpc    edit-config    active
    ${len1}=    BuiltIn.Get Length    ${pm1}
    FOR    ${i}    IN    @{active}
        ${Value to check}    Evaluate    '${i}' in [item[1][0] for item in ${pm1}]
        run keyword and continue on failure   Should Be True    ${Value to check}
    END
    ${a}=    validate_netconf_reply_message    ${netconf_file}    edit-config    ok
    run keyword and continue on failure    Should not be empty    ${a}

Counter_Value_Check
    [Arguments]    ${path}    @{ListofCountervalues}
    ${counter_List}=    admin.get_pm_counters_by_dist_name    timeout=300
    log    ${counter_List['${path}']}
    FOR   ${count1}	IN	@{ListofCountervalues}
    	Run Keyword and Continue On Failure    Should Not Be Empty    ${counter_List['${path}']}[${count1}]}    0
        log    ${counter_List['${path}']}[${count1}]}
    END
    Sleep   60

Check_BTS_State
    ${bts_state}=    admin.get_mrbts_state
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

Check ActiveFaultandAlarmID
    [Arguments]    @{fault_list}
    ${alr}=     admin.get_active_alarms
    log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        run keyword and continue on failure    should contain any    ${Alrstring}    @{fault_list}
    END

Send Cmd By Netopeer Cli xranuser APoabio
    [Arguments]    ${value}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS_iphy}
    SSHLibrary.Login    username=${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.write    lxc-attach -n 0x551a
    SSHLibrary.Read    delay=10s
    SSHLibrary.write    ip netns exec ORU01 /opt/UE-APP-OAM-oru/service/netopeer2/netopeer2-cli\r\n
    SSHLibrary.Read    delay=10s
    SSHLibrary.write    connect --ssh --login netconf --host 127.0.0.1\r\n
    ${output}=    SSHLibrary.Read     delay=2s
    Log   ${output}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output}    Are you sure you want to continue connecting
    Run Keyword if    '${contains}' == 'True'    SSHLibrary.write   yes\r\n
    SSHLibrary.Read    delay=3s
    SSHLibrary.write   netconf\r\n
    SSHLibrary.Read    delay=2s
    SSHLibrary.write    user-rpc --content ${value}\r\n
    SSHLibrary.Read    delay=10s
    SSHLibrary.Close All Connections

MessageVerification_alarm
    [Arguments]    ${netconf_file}    @{listoffaults}
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    fault-id
    ${len}=    Get Length    ${al}
    FOR    ${i}    IN RANGE    ${len}
        run keyword and continue on failure    should contain any    ${al}[${i}]    @{listoffaults}
    END
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    is-cleared
    FOR    ${i}    IN RANGE    ${len}
        run keyword and continue on failure    should contain any    ${al}[${i}]    true    false
    END
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    fault-severity
    FOR    ${i}    IN RANGE    ${len}
        run keyword and continue on failure    should contain any    ${al}[${i}]    MINOR    MAJOR    CRITICAL
    END

Create_alarm_xml
    [Arguments]    ${alarmfilelistsent}    @{alarm_list_sent}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS_iphy}
    SSHLibrary.Login    username=${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.write    lxc-attach -n 0x551a
    SSHLibrary.Read     delay=10s
    SSHLibrary.write    cd ${Backdoor_cmd_apoabio}
    SSHLibrary.Read     delay=10s
    SSHLibrary.write    rm -rf ${alarmfilelistsent}
    SSHLibrary.Read     delay=10s
    SSHLibrary.write    touch ${alarmfilelistsent}
    SSHLibrary.write    ls -lrt
    SSHLibrary.Read     delay=10s
    Sleep    10s
    FOR    ${i}    IN    @{alarm_list_sent}
        SSHLibrary.write    echo -e '${i}' >> ${alarmfilelistsent}
        SSHLibrary.Read     delay=10s
    END
    SSHLibrary.Close All Connections

Validating M-plane negotiation
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value    ${netconf_file}    rpc    get    operational-info
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    supported-mplane-version
    run keyword and continue on failure   Should not be empty    ${a}
    Log to console  ${a}
    ${b}=  Get Dictionary Values  ${a[0][2]}
    Log to console  ${b}
    Should Be True    @{b} > ['5.0.0']
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    retrieve-file-list    logical-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    retrieve-file-list    file-name-filter
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc-reply    status    file-list
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    local-logical-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    remote-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    public-key
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    algorithm
    run keyword and continue on failure   Should not be empty    ${trb}
    FOR    ${i}    IN    @{sfp_list}
        ${var}=    validate_netconf_reply_message      ${netconf_file}     get    port-transceiver-data     ${i}
        run keyword and continue on failure   Should not be empty    ${var}
        log    ${var}
    END
    ${trb}=    netconf_get_value     ${netconf_file}    notification    eventTime    eventTime
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    local-logical-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    remote-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    status
    run keyword and continue on failure   Should not be empty    ${trb}

Netconf File Collection
    admin.Setup Admin    name=snapshot
    #Run Keyword And Return Status    OperatingSystem.Create Directory    /home/ute/results/
    OperatingSystem.Empty Directory    ${out}
    ${snapshot1}=    admin.collect_snapshot    target_file_name=${out}/Snapshotfile.zip
    ...    timeout=300    connection=snapshot
    sleep    15
    admin.Teardown Admin    connection=snapshot
    CB008205-G.Extract netconf from snapshot


snapshotFileIdentifier
    @{getWithoutFilerValue}=    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${out}/Snapshotfile.zip
    ...    path=${out}
    ...    fileToBeChecked=NetconfRpcMessageTrace
    [Return]    @{getWithoutFilerValue}

Extract netconf from snapshot
        @{getWithoutFilerValue}=     snapshotGetWithoutFilter    Snapshotfile.zip    ${out}/    RMOD_L-1_NetconfRpcMessageTrace
        log     ${getWithoutFilerValue}[0]
        log     ${getWithoutFilerValue}[1]
        log     ${getWithoutFilerValue}[2]
        ${netconf_file_path}=    String.Replace string    ${getWithoutFilerValue}[2][0]    results//    results/
        Extract
   	...    path=${netconf_file_path}
   	...    output_dir=${out}
   	...    .=*.log
        ${netconf_filename}=    OperatingSystem.List Files In Directory    ${out}/    BTS1_2018_RMOD_L-1_RPC.log
        OperatingSystem.Copy file    ${out}/BTS1_2018_RMOD_L-1_RPC.log    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log

Test Setup
    Remove Files    /home/ute/results/troubleshooting_logs/*
    Remove Files    /home/ute/results/snapshot/*.zip
    #admin.Teardown All Aliases For Admin
    admin.Setup Admin    name=suite
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    Watch alarms           allowed_alarms=${allowed_alarms}
    ...                    interval=10 sec
    delete_files_netconf
    sleep    60

Collect SOS report
    Run     chmod 777 /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    ${output} =    OperatingSystem.Run    pwd
    Run     sudo rm ${output}/SosReport*_UEAPP.tgz
    Run     /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    Wait Until Created    ${output}/SosReport*_UEAPP.tgz    600s
    Run     sudo cp ${output}/SosReport*_UEAPP.tgz ${out}/

Collect Snapshot
    admin.collect_snapshot    target_file_name=${out}/Snapshotfile.zip    connection=suite

snapshot
        classical.login    https://192.168.255.129    Nemuadmin    nemuuser  timeout=180    download_dir=/home/ute/results/snapshot    version=25R2
        ...    browser=Firefox
        Log To Console    Snapshot collection
        classical.snapshot_collection_settings    All log files    Local
        ${snapshot1}=    classical.collect_snapshot    snapshot_waiting_timeout=240
        Copy File    ${snapshot1}	/home/ute/results/Snapshot1.zip
        sleep    15
        ${troubleshootinglog_file_1}=    taf.transport.ssh.File Exists    /home/ute/results/snapshot_dest/Snapshot1.zip   runtime_DEFAULT.log
        Should Be True    '${runtime_DEFAULT_1}'=='True'
        sleep    10
        Netconf File Collection
        Netconf_Message_validation
        delete_files_netconf
        sleep    60
        Log To Console    Snapshot cancellation inbetween
        classical.collect_snapshot    snapshot_waiting_timeout=3
        classical.cancel_collect_snapshot
        sleep    10
        Copy File    /home/ute/results/snapshot/*partial.zip    /home/ute/results/snapshot_dest/Snapshot_partial.zip
        sleep    15
        ${troubleshootinglog_file_2}=    taf.transport.ssh.File Exists    /home/ute/results/snapshot_dest/Snapshot_partial.zip
        ...    runtime_DEFAULT.log
        Run Keyword And Ignore Error    Should Be True    '${troubleshootinglog_file_2}'=='False'
        sleep    10
        Netconf File Collection
        Netconf_Message_validation
        delete_files_netconf
        sleep    60
        Log To Console    Snapshot collection
        ${snapshot3}=    classical.collect_snapshot    snapshot_waiting_timeout=120
        Copy File    ${snapshot3}	/home/ute/results/snapshot_dest/Snapshot3.zip
        ${troubleshootinglog_file_3}=    taf.transport.ssh.File Exists    /home/ute/results/snapshot_dest/Snapshot3.zip    runtime_DEFAULT.log
        Should Be True    '${troubleshootinglog_file_3}'=='True'
        sleep    10
        Netconf File Collection
        Netconf_Message_validation
        delete_files_netconf
        classical.Logout
        classical.close_browser

Test Teardown
    Log to console   \n--Tear down-End Test--\n
    Collect SOS report
    CB008205-G.Collect Snapshot
    #admin.teardown_admin

Prepare_Testline_with_OFGESA v7
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
       ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    admin.setup_admin
    CB008205-G.Configure Netconf Credentials    @{sudo_list1}
    admin.teardown_admin
    Install OFGESA RU
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install OFGESA RU
        sleep    100s
    END
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        Run    sudo pkill egate
        Run    sudo pkill edaemon
        CB008205-G WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=100
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    run keyword and continue on failure    Should Be True    '${status}' == 'True'
    Log to console   \nCell is in OnAir state

Prepare_Testline_with_SAMJI v7
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE_1}
       ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    admin.setup_admin
    CB008205-G.Configure Netconf Credentials    @{sudo_list1}
    admin.teardown_admin
    Install SAMJI RU
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    ${status}    Exit For Loop
        Install SAMJI RU
        sleep    100s
    END
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    FOR    ${i}	   IN RANGE    5
        ${vlan_id_change_status}=	Run Keyword And Return Status    Change VlanId
        Run Keyword If    ${vlan_id_change_status}    Exit For Loop
    END
    FOR    ${i}	   IN RANGE    5
        Run    sudo pkill egate
        Run    sudo pkill edaemon
        CB008205-G WTSSIM X2 Link SAMJI Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=100
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    run keyword and continue on failure    Should Be True    '${status}' == 'True'
    Log to console   \nCell is in OnAir state








Check VlanId
    ${vlanId}=    ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-*/VLANIF_CONF_M-1
    ...                                                                                parameter=vlanId
    ...                                                                                alias=infomodel_1
    ${vlanId_str}=    Convert to String    ${vlanId}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/../Configurations/vlanid_new.json      ${replace}

Configure Default Netconf Account
    selenium.add_oru_account    60
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.send_netconf_configuration

Install OFGESA RU
    OperatingSystem.Run    chmod +x ${INSTALL_OFGESA_v7}
    sleep    7
    OperatingSystem.Run    sh ${INSTALL_OFGESA_v7}
    sleep    7
    Log to console    \nInstalling OFGESA radio

Install SAMJI RU
    OperatingSystem.Run    chmod +x ${INSTALL_SAMJI_v7}
    sleep    7
    OperatingSystem.Run    sh ${INSTALL_SAMJI_v7}
    sleep    7
    Log to console    \nInstalling OFGESA radio

Add Default Netconf Account
    Prepare Environment
    Login To Web Element Manager
    Go To Netconf Radio Management Tab
    Configure Default Netconf Account In Webem
    Teardown Environment
    Log    \n+ Default Netconf Account Added    console=yes

Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

CB008205-G WTSSIM X2 Link Establish
    OperatingSystem.Run    chmod 777 ${X2LINK}
    OperatingSystem.Run    sh ${X2LINK}
     Log to console   \nEstablishing X2 link...

CB008205-G WTSSIM X2 Link SAMJI Establish
    OperatingSystem.Run    chmod 777 ${X2LINK_SAMJI}
    OperatingSystem.Run    sh ${X2LINK_SAMJI}
     Log to console   \nEstablishing X2 link...

Verify Access Group Created
    ${message}=    Check Message In Netconf Trace File    ${NETCONF_MESSAGE}
    Should Contain    ${message}    ${NETCONF_MESSAGE}
    Should Contain    ${message}    <ok/></rpc-reply>

Check Logged In With Additional Account
    ${message}=    Check Message In Netconf Trace File    Password authentication (host "172.22.0.2", user "xranuser2").
    Should Contain    ${message}    Password authentication (host "172.22.0.2", user "xranuser2").
    Should Contain    ${message}    Authentication successful

Check SSH Session Closed After Configuration
    ${message_id}=    Check Message Id    ${NETCONF_MESSAGE}
    ${message_id_close}=    Check Message Id    <close-session xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"/></rpc>
    Should Be True    ${message_id} < ${message_id_close}

Generate New SSH Public Key
    ${output}=    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh
    ${warning}=    Run Keyword And Return Status
    ...    Should Contain    ${output}    [WRN]
    Run Keyword If    ${warning}
    ...    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh

Check Unsecure Ciphers Field
    Wait Until Element Is Visible    locator=${UNSECURE_CIPHERS}
    Click Element    locator=${UNSECURE_CIPHERS}
    Wait Until Element Is Visible    locator=//span[contains(text(),'false')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'true')]
    Click Element    locator=//span[contains(text(),'false')]

Check SSH Auth Methods
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'No authentication')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Public key based')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Deactivation of SSH')]
    Click Element    locator=//span[contains(text(),'No authentication')]

Click Deactivate SSH Validation
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Deactivation of SSH')]
    Click Element    locator=//span[contains(text(),'Deactivation of SSH')]

Delete Current Netconf Account
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Click Element    locator=${TRASH_BUTTON}
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Switch To No SSH Auth
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'No authentication')]
    Click Element    locator=//span[contains(text(),'No authentication')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Continue')]
    ...                              timeout=20
    Click Element    locator=//span[contains(text(),'Continue')]

Deactivate SSH Public Key Validation
    Click Deactivate SSH Validation
    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Run Keyword If    '${account_configured}' == 'True'    Run Keyword    Click Element    locator=${TRASH_BUTTON}
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Remove Netconf Accounts From Gnb Using Webem
    Clear Netconf Account Configuration
    ADMIN Reset Site
    ADMIN Assert All Bbmods Are In Enabled State    timeout=180

Clear Netconf Account Configuration
    Prepare Environment
    Login To Web Element Manager
    Go To Netconf Radio Management Tab
    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Run Keyword If    '${account_configured}' == 'True'    Run Keyword    Click Element    locator=${TRASH_BUTTON}
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Go To Netconf Radio Management Tab
    Wait Until Element Is Visible   locator=${CONFIGURATION}
    Click Element   locator=${CONFIGURATION}
    Mouse Over  locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Click Element   locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Wait Until Element Is Visible    locator=${ACCOUNTS_CONFIGURATION}

Check Remove Additional Account
    Wait Until Element Is Visible    locator=${ACCOUNT_REMOVE_BUTTON}
    Click Element    locator=${ACCOUNT_REMOVE_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Click Element    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Wait Until Element Is Visible    locator=//div[contains(text(),'Additional netconf account')]
    Input Text    locator=additional-netconf-account-name
    ...           text=${ADDITIONAL_ACCOUNT_NAME}
    Input Password   locator=additional-netconf-account-pwd
    ...              password=${ADDITIONAL_ACCOUNT_PASS}
    Input Password   locator=confirm-additional-netconf-account-pwd
    ...              password=${ADDITIONAL_ACCOUNT_PASS}

Configure Additional Netconf Account In Webem
    [Arguments]    ${name}=${ADDITIONAL_ACCOUNT_NAME}
    ...            ${password}=${ADDITIONAL_ACCOUNT_PASS}
    ...            ${check_remove}=False
    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Run Keyword If   '${account_configured}' == 'False'   Run Keyword   Configure Default Netconf Account In Webem Without Sending The Configuration
    Click Element
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    Wait Until Element Is Visible    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Click Element    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Wait Until Element Is Visible    locator=//div[contains(text(),'Additional netconf account')]
    Input Text    locator=additional-netconf-account-name
    ...           text=${name}
    Input Password   locator=additional-netconf-account-pwd
    ...              password=${password}
    Input Password   locator=confirm-additional-netconf-account-pwd
    ...              password=${password}
    Run Keyword If    ${check_remove}    Run Keyword    Check Remove Additional Account
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Configure Default Netconf Account In Webem Without Sending The Configuration
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

Configure Default Netconf Account In Webem
    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
    ...            ${disable_ssh_auth}=False
    Run Keyword If    ${disable_ssh_auth}
    ...    Click Deactivate SSH Validation
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

Configure Default Netconf Account In Webem With SSH Auth
    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Public key based')]
    Click Element    locator=//span[contains(text(),'Public key based')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Continue')]
    ...                              timeout=20
    Click Element    locator=//span[contains(text(),'Continue')]
    Click Element    ${PLUS_BUTTON_TRUNK}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
    Input Text    locator=oru-targerDN
    ...           text=${RMOD_PATH}
    Input Text    locator=ssh-server-host-public-key-format-identifier
    ...           text=RSA
    ${rsa_key}=    Get File    ${RSA_FILE}
    Input Text    locator=ssh-server-host-public-key-value
    ...           text=${rsa_key}
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

Assert Fault 1500
    ADMIN Assert Alarm Active    &{1500}    timeout=30
    Log To Console    Fault 1500 visible
    ${object_dict}    admin.Get Parameters    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/ORUF_L-1
    ...    alias=${ADMIN_ALIAS}
    ${object_str}    Convert To String    ${object_dict}
    Should Contain    ${object_str}    'faultId': 1500
    Should Contain    ${object_str}    'faultType': 'VendorSpecific'
    Should Contain    ${object_str}    'faultSeverity': 'Minor'
    Should Contain    ${object_str}    'affectedObjects': ['Object 1', 'Object 2', 'Object 3']
    Assert Fault 1500 Does Not Contain Meaning And Instruction

Assert Fault 1500 Does Not Contain Meaning And Instruction
    Prepare Environment
    Login To Web Element Manager
    Wait Until Element is Visible
    ...    locator=//i[@class="status-bar-small-text-icon fa fa-bell"]    timeout=60
    Click Element
    ...    locator=//i[@class="status-bar-small-text-icon fa fa-bell"]
    Open Details Panel If Is Closed
    Wait Until Element is Visible
    ...    locator=//td[contains(text(),'ORAN RU VENDOR SPECIFIC INFORMATION')]    timeout=60
    Click Element
    ...    locator=//td[contains(text(),'ORAN RU VENDOR SPECIFIC INFORMATION')]
    Wait Until Element is Visible
    ...    locator=//td[contains(text(),'Alarm details')]    timeout=60
    SeleniumLibrary.Capture Page Screenshot
    Element Should Not Be Visible
    ...    locator=//span[contains(text(),'Meaning:')]
    Element Should Not Be Visible
    ...    locator=//span[contains(text(),'Instruction:')]
    Close Browser
    Teardown Environment

Chmod Chromedriver
    OperatingSystem.Run  sudo chmod +x /usr/bin/chromedriver

Teardown Environment
    Close All Browsers
    Terminate All Processes

Set Plus Button Based On The Release
    ${status}=    Run Keyword And Return Status    Should Contain Any    ${OUT_ACTIVE_SW}    22R2
    Run Keyword If    ${status}    Set Suite Variable    ${PLUS_BUTTON}    ${PLUS_BUTTON_22R2}
    Run Keyword Unless    ${status}    Set Suite Variable    ${PLUS_BUTTON}    ${PLUS_BUTTON_TRUNK}

Close BTS Startup View
    ${close}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Close')]
    ...    timeout=100
    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]

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

Open Details Panel If Is Closed
    ${DetPanelOpen}    Run Keyword And Return Status    Page Should Not Contain Element
    ...    locator=//wf-panel[@class="details-panel view-panel ng-isolate-scope ng-hide"]
    ${DetPanelClose}    Run Keyword And Return Status    Page Should Contain Element
    ...    locator=//wf-panel[@class="details-panel view-panel ng-isolate-scope ng-hide"]
    Run Keyword If    ${DetPanelClose}    Click Element
    ...    locator=//ui-button[@class="show-panel-button ng-scope ng-isolate-scope ui-tooltip-source"]
    Log    DetPanelOpen=${DetPanelOpen} DetPanelClose=${DetPanelClose}

Get Parameters
    [Arguments]    ${parameter}
    ...            ${dist_name}
    ${out_parameters_dict}    admin.Get Parameters
    ...             dist_name=${dist_name}
    ...    pattern=${parameter}
    ...            ${alias}=admin_1
    ...    timeout=20
    [Return]    ${out_parameters_dict}

Get Rmod Id
    ${rmod_id}    ADMIN Get Id For Current    RMOD
    ${dist_name_string}    Convert To String    ${rmod_id}
    ${dist_name}    Get Substring    ${dist_name_string}    2    -2
    Set Global Variable    ${dist_name}

Check MPlaneLink Status
    ${act_mPlane}   Check Parameter Under RMOD    RU M-Plane link status
    [Return]    ${act_mPlane}

Check Parameter Under Rmod
    [Arguments]    ${parameter}
    ${out_parameters_dict}    Get Parameters    ${parameter}    ${dist_name}
    ${parameter_status}   Set Variable    ${out_parameters_dict}[${parameter}]
    [Return]    ${parameter_status}

Wait Until Mplane Is Connected
    [Arguments]    ${timeout}=200
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=${timeout}
    Get Rmod Id
    Wait Until Keyword Succeeds
    ...                           ${timeout}
    ...                           5
    ...                           Assert Mplane Connected
    Log    \n+ MPlane is Connected    console=yes

Assert Mplane Connected
    ${mplane_status}     Check MPlaneLink Status
    Should Be Equal As Strings    ${mplane_status}
    ...                           Connected

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

ORAN Preconditions
    Test Preconditions Without WTSSIM S1
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Set Path In Infomodel
    ${sw_release}=    admin.get_sw_release_name    connection=suite

Check Message Id
    [Arguments]    ${message_to_grep}
    ...            ${grep_option}=head -n 1
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path} | ${grep_option}
    ${output_1}    Fetch From Left    ${output}    "><
    ${output_2}    Fetch From Right    ${output_1}    message-id=
    ${message_id}    Fetch From Right    ${output_2}    "
    [Return]   ${message_id}
    [Teardown]    SYSTEM Close SSH Connection To Enb

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


Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    OperatingSystem.Run    hostname
    [Documentation]    :Author: Mallikarjuna 
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    String.Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s

Assert Mrbts Is In Onair State
    [Arguments]    ${timeout}=50
    ...            ${alias}=admin_1
    ${mrbts_state}    admin.Get Mrbts State    timeout=${timeout}
    ...                                        alias=${alias}
    Should Contain    ${mrbts_state}    OnAir

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

Check Message In Netconf Trace File
    [Arguments]    ${message_to_grep}
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -A1 '${message_to_grep}' ${local_file_path}
    [Return]    ${output}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Configure Netconf Credentials
    [Arguments]    @{list}
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}

[1]CB008967-F-SR_To_verify_different_TEMP_values_with_backdoor_command_for_certain_time_and_check_for_faults
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA v7
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC04}
    Log to console   \nPerforming Parameter Recommissioning
    admin.setup_admin
    CB008205-G.Perform Parameter Recommissioning    ${distname_featcadm}    ${parameter_actkpi}    ${value_actkpi}
    CB008205-G.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue}
    FOR    ${i}	   IN RANGE    3
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=100
        Run Keyword If    '${status}' == 'True'    Exit For Loop
        Run    sudo pkill egate
        Run    sudo pkill edaemon
        CB008205-G WTSSIM X2 Link Establish
    END
    run keyword and continue on failure    Should Be True    '${status}' == 'True'
    CB008205-G.Check_BTS_State
    CB008205-G.Perform delta commissioning for kpialarmtrigger for all temperatures    ${delta_file_for_Temps_activate}
    Trigger Backdoor cmd via py_script
    FOR    ${item}    IN    @{Active_alarms}
         Log    ${item}
         CB008205-G.ADMIN Assert Alarm Active    ${item['fault_id']}    ${item['alarm_id']}    ${item['alarm_severity']}
		 ...    ${item['alarm_resource']}    ${item['fault_name']}    ${item['timeout']}
    END
    Log to console     ${Active_alarms}
    Perform delta commissioning for kpialarmtrigger for all temperatures    ${delta_file_for_Temps_deactivate}
    FOR    ${item}    IN    @{Active_alarms}
         Log    ${item}
         CB008205-G.ADMIN Assert Alarm Inactive    ${item['fault_id']}    ${item['alarm_id']}    ${item['alarm_severity']}
		 ...    ${item['alarm_resource']}    ${item['fault_name']}    ${item['timeout']}
    END
    CB008205-G.ADMIN Get Historic Minor Alarms

*** Keywords ***

Perform delta commissioning for kpialarmtrigger for all temperatures
    Log to console    \nTemperature counter related formulas are commissioned in kpiAlarmTriggers
    [Arguments]    ${delta_file_for_Temps}
    admin.perform_delta_recommissioning    delta_file=${delta_file_for_Temps}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180

Trigger Backdoor cmd via py_script
    Log to console    Trigger Backdoor cmd
    OperatingSystem.Run    chmod 777 ${Python_Backdoor}/Backdoorscript.py
    OperatingSystem.Run    python ${Python_Backdoor}/Backdoorscript.py ${temp_min} ${temp_max} ${temp_avg}
    sleep    500s

ADMIN Assert Alarm Active
    Log to console    Check the KPI alarms in Active Alarms
    [Arguments]    ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_severity}
    ...            ${alarm_resource}
    ...            ${fault_name}
    ...            ${timeout}
    admin.assert_alarm_active    parameters=faultId=${fault_id}
    ...                                     alarmId=${alarm_id}
    ...                                     severity=${alarm_severity}
    ...                                     alarmingResource=${alarm_resource}
    ...                                     faultName=${fault_name}
    ...                                     timeout=${timeout}

ADMIN Assert Alarm Inactive
    Log to console    Check KPI alarms in Active Alarms are cleared
    [Arguments]    ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_severity}
    ...            ${alarm_resource}
    ...            ${fault_name}
    ...            ${timeout}
    admin.assert_alarm_inactive    parameters=faultId=${fault_id}
    ...                                            alarmId=${alarm_id}
    ...                                            severity=${alarm_severity}
    ...                                            alarmingResource=${alarm_resource}
    ...                                            faultName=${fault_name}
    ...                                            timeout=${timeout}

ADMIN Get Historic Alarms
    [Arguments]    ${severity}=${None}
    ...            ${load_history}=${False}
    admin.get_historic_alarms    severity=${severity}
    ...                          load_history=${load_history}

ADMIN Get Historic Minor Alarms
    Log to console    Check Historical Minor Alarms
    ${out_alarms_objects_list}=    CB008205-G.ADMIN Get Historic Alarms   severity=Minor
    [Return]    ${out_alarms_objects_list}