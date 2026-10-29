*** Settings ***
Documentation
...    Author: challa.ravali@nokia.com
...    Maintainer: challa.ravali@nokia.com
...    Test Description: This feature is firstly supported in ASIL + APoABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -C is related to O-RAN V5.0 improvements with the use of 3rd party RU.
...    Confluence link: link
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-C/general.robot
...    Review: -
...    AC/REQ: OAM_REQ_RADIO_801, OAM_REQ_RADIO_904, OAM_REQ_RADIO_913, OAM_REQ_RADIO_914, OAM_REQ_RADIO_916,
...    OAM_REQ_RADIO_918, OAM_REQ_RADIO_924, OAM_REQ_RADIO_973, OAM_REQ_WEBEM_1029, OAM_REQ_WEBEM_1032,
...    OAM_REQ_WEBEM_1035, OM_SFS_GEN_FM.3209, OM_SFS_GEN_FM.3255, OAM_REQ_RADIO_801_1, OAM_REQ_RADIO_913_1,
...    OAM_REQ_RADIO_914_1, OAM_REQ_RADIO_916_1, OAM_REQ_RADIO_918_1, OAM_REQ_RADIO_973_1, OAM_REQ_WEBEM_1035_1,
...    OAM_REQ_WEBEM_1029_1, OAM_REQ_WEBEM_1032_1, OAM_REQ_RADIO_904_1, OAM_REQ_RADIO_924_1, OM_GEN_SFS_FM.3209_1,
...    OM_GEN_SFS_FM.3255_1

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
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.sbts.oam.coam.admin
Library    taf.config.scf   WITH NAME  scf
Library    taf.sw.scout    WITH NAME    scout
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library     ./testsuite/Bangalore/ORAN/resources/python/ta_swconfig_recommended/swconfig_recommended.py
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/selenium_keywords.robot

*** Variables ***
@{ALLOWED_ALARMS}    &{4592}    &{10_allowed}    &{7300}    &{4729_allowed}    &{4720}    &{7305}    &{7523}    &{7107}    &{7107_Critical}
...    &{4729_allowed}    &{1500}    &{7304}    &{7308}    &{6202}    &{7308_allowed}
@{ALLOWED_ALARMS_TC07}    &{1807_allowed}
@{ALLOWED_ALARMS_TC08}    &{1868_allowed}
@{ALLOWED_ALARMS_TC09}    &{FAULT_4720}    &{4592_allowed}
@{ALLOWED_ALARMS_TC10}    &{4008_allowed}
@{ALLOWED_ALARMS_TC12}    &{1900_allowed}    &{1806_allowed}
&{1900_allowed}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name=RF Module configuring failed
...         notifier=
&{1806_allowed}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         fault_name=Radio autonomous reset as recovery action
...         notifier=
&{6202}     fault_id=6202
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="Transport layer connection failure in S1 interface"
...         notifier=
&{4008_allowed}     fault_id=4008
...         alarm_id=7112
...         alarm_severity=Critical
...         fault_name="Power level not supported"
...         notifier=
&{1868_allowed}     fault_id=1868
...         alarm_id=7114
...         alarm_severity=Critical
...         fault_name="BTS configuration error (not enough HW for LCR)"
...         notifier=
&{1807_allowed}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
...         fault_name=Invalid frequency channel for the BTS HW
...         notifier=
&{FAULT_4720}    fault_id=4720
...         alarm_id=7115
...         alarm_severity=regex"Warning|Minor|Major"
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=
&{7300}     fault_id=7300
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="No X2 link available"
...         notifier=
&{4592_allowed}     fault_id=4592
...         alarm_id=7652
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{7304}     fault_id=7304
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP endpoint broken"
...         notifier=[1] MRBTS-1/NRBTS-1/SERVEDAMF-1
&{7308}     fault_id=7308
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="Transport layer connection failure in X2 interface"
...         notifier=
&{7308_allowed}     fault_id=7308
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="Transport layer connection failure in X2 interface"
...         notifier=
&{4592}     fault_id=4592
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{1500}     fault_id=1500
...         alarm_id=7240
...         alarm_severity=Minor
...         fault_name="alarm1"
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
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
&{7305}     fault_id=7305
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP setup fail"
...         notifier=[1] MRBTS-1/NRBTS-1/SERVEDAMF-1
&{7523}     fault_id=7523
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Cell Activation timeout at gNB-DU"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7107}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7107_Critical}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=Critical
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{6450}     fault_id=6450
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Diagnostic Files collected"
...         notifier=[1] MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1
&{1868_active}     fault_id=1868
...         alarm_id=7114
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name="BTS configuration error (not enough HW for LCR)"

${RSA_FILE}=                            ./testsuite/Bangalore/ORAN/T02/CB008205-C/configurations/rsa.pub
${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         orusim
${Docker_user_name}			    inbabtslabuser
${Docker_password}			    BT5l@bus3rl0g1n
${NETCONF_TRACE_REMOTE_PATH}=           /tmp/node_FHNET80/tmp/RMOD_L-1_RPC_0.log
${NETCONF_TRACE_LOCAL_PATH}=            /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${CONFIGURATION}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${XML_DOCKER_PATH}=                     /home
${EDIT_CMD}=                            edit-config --target running --config=/home/
${RPC_CMD}=                             user-rpc --content /opt/dev/xml
${ORU_SIM_IP}=                          10.42.17.69
${SCF_PATH}=                            ./testsuite/Bangalore/ORAN/T02/CB008205-C/configurations
${WebEM IP}                             https://192.168.255.1:3600
${url}                                  https://192.168.255.129
${browser}                              Chrome
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${oru_name}                             SSDORU-1
${CELL_DN}=                             /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-1
${DEFAULT_ACCOUNT_NAME}=    xranuser
${DEFAULT_ACCOUNT_PASS}=    xran-password
${ADDITIONAL_ACCOUNT_NAME}=    xranuser2
${ADDITIONAL_ACCOUNT_PASS}=    Xran-Password11!!
${RMOD_PATH}=    MRBTS-1/EQM-1/APEQM-1/RMOD-1
${NETCONF_MESSAGE1}=    <config><nacm xmlns="urn:ietf:params:xml:ns:yang:ietf-netconf-acm"><groups><group><name>####</name>
${NETCONF_MESSAGE2}=    <user-name>xranuser2</user-name></group></groups></nacm></config>
${SCF_FILE}						        ${CURDIR}/../configurations/SANSA_scf_ofgesa_cloud.xml
${SCF_FILE_LTE}                                                 ${CURDIR}/../configurations/SCF_LTE_FDD.xml
${DELTA_FILE_OLD} 				        ${CURDIR}/../configurations/vlanid_old.json
${DELTA_FILE_NEW}	        	        ${CURDIR}/../configurations/vlanid_new.json
${INSTALL_OFGESA}			        /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-C/configurations/5G_install_ofgesa.sh
${INSTALL_OFGESA_LTE}			        /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-C/configurations/4G_install_ofgesa.sh
${INSTALL_OFGESA_supported_cells_0}            ./testsuite/Bangalore/ORAN/T02/CB008205-C/configurations/4G_install_ofgesa_supported_cells_0.sh
${X2LINK}				        /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-C/configurations/x2link.sh
${S1LINK}				        /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-C/configurations/s1link.sh
${XML_FILES_PATH}                             ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/Airphone_backdoor_commands
${lxc_id}=    0x551a
${ABIO_RPC_cmd}                 user-rpc --content /tmp/
${ORU_container_path}           /tmp/node_${ORU_ID}
${ORU_ID}                       ORU01
${sw_config_recommended}    ./testsuite/Bangalore/ORAN/resources/python/ta_swconfig_recommended/swconfig_recommended_CLOUD.txt
${sw_release}
${results_dir}
${timeout}
${APOABIO_IP}=    192.168.200.1
${APOABIO_user}=    oru01
${host}             127.0.0.1
${username}         ute
${password}         Utepassword@1
${cmd_TC04}             SEPARATOR=
...    active-alarm-test-list active-alarms[1]/fault-name=test_alarm1500 active-alarms[1]/
...    fault-id=1500 active-alarms[1]/fault-source=OFGESA active-alarms[1]/affected-objects[1]/
...    name=Object1 active-alarms[1]/affected-objects[2]/name=Object2 active-alarms[1]/
...    affected-objects[3]/name=Object3 active-alarms[1]/fault-severity=MINOR active-alarms[1]/
...    is-cleared=false active-alarms[1]/fault-text=alarm1 active-alarms[1]/event-time=2020-08-13T15:13:28+02:00
&{authentication}   	   id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=       	   &{authentication}
&{default_user}=    	   defaultNetconfAccountName=xranuser
...                    	   defaultNetconfAccountPwd=xran-password
&{add_user}=        	   additionalNetconfAccountName=xranuser2
...                 	   additionalNetconfAccountPwd=Xran-Password11!!
...                 	   additionalNetconfAccountType=sudo
&{public_key}=             publicKeySshServerFormat=RSA
...                        publicKeySshServerValue=${RSA_key_pub}
${RSA_key_pub}             SEPARATOR=
...    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq0zYDQMbyxGStuKhNZ+n1Uf/kECIBpKyIcK4HacD8lZLzPUb5syq
...    /H8mISVrR8ZHapj5WdCTPzwYUDkCjhPZWuj5UY+FI1Lg5rEFyYlMe6tM+u0rls94mACscUWsM6Xl7FO6V1VW33VJ
...    14GrxxKPqNGq4UeKtqsh14Ze45Tag3H6XuSiswj98JeK6lI4f4PaADvTrWMJew/JLN/eWAn4cEilh2x574OuRIdPOBnEM98gKsliirdVB/02QukcXxwcjh
...    ++8rR/SWusk45MV+ZvP0K6mgLHEq3iM99VPD9DkZ1b5NXuEXy5MiJHjPZnSaS50pw/ZUe071Vnl6AcKvtsfQIDAQAB
@{sudo_list_add}=          &{authentication_add}
&{authentication_add}   	   id=1    defaultNetconfAccount=&{default_user}    additionalNetconfAccount=&{add_user}
@{sudo_list_RSA_key}=      &{authentication_RSA}
&{authentication_RSA}              id=1    targetDN=${oru_name}    authentifierSshServer=&{public_key}    defaultNetconfAccount=&{default_user}
${cmd_TC03}=    modify_keystore_private_key
${cmd_TC12_1900}=    set-failure name=o-ran-performance-management edit=true
${cmd_TC12_1900_cleared}=    set-failure name=o-ran-performance-management edit=false
${cmd_TC12_1806}=    set-failure name=o-ran-performance-management timeout-edit=90

*** Keywords ***
TC_01_Access group configuration during O-RU startup
    swConfig    swconfigfilepath=${sw_config_recommended}
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=1500
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    CB008205-C.Configure Additional Netconf Account
    CB008205-C.Wait Until Mplane Is Connected
    Sleep    120s
    Verify Access Group Created
    Check Logged In With Additional Account
    Check SSH Session Closed After Configuration

TC_02_SSD configuration for Netconf radio WebEM support
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Configure Default Netconf Account In Webem With SSH Auth    @{sudo_list_RSA_key}
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200

TC_03_O-RU_SSH_public_key_change_detection_on_O-DU
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    taf.sbts.oam.coam.admin.Setup Admin    alias=alarm_history
    Configure Netconf Account In Webem With SSH Public key change    @{sudo_list}
    Run Process    ssh    toor4nsn@192.168.200.1    reboot
    Sleep    240s
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Configure Netconf Account In Webem With SSH Public key change    @{sudo_list}
        Install OFGESA RU
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    Configure Netconf Account In Webem With SSH Public key change    @{sudo_list}
    Create SSH Session To ORU    ${cmd_TC03}
    Run Process    ssh    toor4nsn@192.168.200.1    reboot
    Log to console    Waiting for AP to be reachable 250s
    Sleep    250s
    Configure Netconf Account In Webem With SSH Public key change    @{sudo_list}
    sleep    20s
    ADMIN Assert All Rmods Are In Enabled State   timeout=400
    ${a}=    taf.sbts.oam.coam.admin.Get Raw Alarm History File    timeout=120    connection=alarm_history    detailed_output=True
    ${b}=    taf.sbts.oam.coam.admin.Collect Raw Alarm History File    target_file_name=Raw_alarm_history
    ...    timeout=120    connection=alarm_history    detailed_output=True
    ${c}=    taf.sbts.oam.coam.admin.Get Alarm History    timeout=30    connection=alarm_history    detailed_output=True
    log    ${c}
    log to console    ${c}[requestMessage]
    taf.sbts.oam.coam.admin.Teardown Admin    alias=alarm_history
    OperatingSystem.Copy file    Raw_alarm_history    ${out}/Raw_alarm_history.txt
    ${fault_4729}=    Convert To Integer    4729
    ${len}=    Run keyword and continue on failure    Get Length    ${c}[requestMessage]
    FOR    ${i}	   IN RANGE    ${len}
        Sleep	2s
        ${status}=	Run Keyword And Return Status	Should Be Equal    ${c}[requestMessage][${i}][faultId]    ${fault_4729}
        Run Keyword If    '${status}' == 'True'    Log to console    Fault 4729 seen
    END
    Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
    Log To Console    Fault 4729:O-RU host key change detected  visible
    ADMIN Assert All Rmods Are In Enabled State   timeout=900
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-C WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    ADMIN Assert Alarm Inactive    fault_id=4729
        ...    alarm_id=7115
        ...    alarm_severity=Minor
        ...    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
        ...    fault_name="O-RU host key change detected"
        ...    timeout=60

TC_04_Vendor_specific_fault_simulation_on_O-RU
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Trigger Fault 1500 With Severity Minor
    Assert Fault 1500
    Site reset along with x2 link creation
    CB008205-C.Wait Until Mplane Is Connected    timeout=300
    ADMIN Assert Alarm Inactive    fault_id=1500    alarm_id=7240    alarm_severity=Minor    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="alarm1"

TC_07_O-RU Out Of Range Frequency Detection
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA_LTE
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC07}
    EarfcnDL Recommissioning    700
    ADMIN Assert Alarm Active    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Invalid frequency channel for the BTS HW"    timeout=360
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=60
    EarfcnDL Recommissioning    300
    ADMIN Assert Alarm Inactive    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Invalid frequency channel for the BTS HW"    timeout=360
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=60
    EarfcnUL Recommissioning    18700
    ADMIN Assert Alarm Active    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Invalid frequency channel for the BTS HW"    timeout=360
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=60
    EarfcnUL Recommissioning    18300
    ADMIN Assert Alarm Inactive    fault_id=1807    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Invalid frequency channel for the BTS HW"    timeout=360
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=60

TC_08_O-RU Out Of Range Bandwidth Detection
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA_LTE
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC08}
    Channel Bandwidth Delta Recommissioning    ${SCF_PATH}/Delta_Configuration_Ch_BW_5MHz.json
    ADMIN Assert Alarm Active    &{1868_active}    timeout=360
    Log To Console    Fault 1868 visible
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=180
    Channel Bandwidth Delta Recommissioning    ${SCF_PATH}/Delta_Configuration_Ch_BW_20MHz.json
    ADMIN Assert Alarm Inactive    &{1868_active}    timeout=360
    Log To Console    Fault 1868 cleared
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=180

TC_09_LTE Cell Number Support In O-RU
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA_LTE
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC09}
    Log To Console    /n Configure O-RU To Support Specified Number Of Cells from 1 to 0 /n
    Install OFGESA RU with Support Specified Number Of Cells to 0
    ADMIN Assert All Cells Are In Enabled State    timeout=900
    FOR    ${i}	   IN RANGE    2
        ${status}=	Run Keyword And Return Status    ADMIN Assert Alarm Active    fault_id=4044    alarm_id=7655
        ...    alarm_severity=Minor
        ...    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
        ...    fault_name="Configuration error: Incoherency in cell configuration"    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
        CB008205-C WTSSIM S1 Link Establish
        ADMIN Assert All Cells Are In Enabled State    timeout=600
    END
    Log To Console    /n Configure O-RU To Support Specified Number Of Cells from 0 to 1 /n
    Install OFGESA RU for CB008205-A
    ADMIN Reset Site
    ADMIN Assert All Cells Are In Enabled State    timeout=900
    ADMIN Assert Alarm Inactive    fault_id=4044    alarm_id=7655
    ...    alarm_severity=Minor
    ...    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Configuration error: Incoherency in cell configuration"    timeout=360

TC_10_LTE Cell Power Configuration Support In O-RU
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC10}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA_LTE
    Pmax Recommissioning    300
    ADMIN Assert Alarm Active    fault_id=4008    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Power level not supported"    timeout=360
    Log To Console    Fault 4008 visible
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=60
    Pmax Recommissioning    400
    ADMIN Assert Alarm Inactive    fault_id=4008    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Power level not supported"    timeout=360
    Log To Console    Fault 4008 cleared
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=60
    Pmax Recommissioning    500
    ADMIN Assert Alarm Active    fault_id=4008    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Power level not supported"    timeout=360
    Log To Console    Fault 4008 visible
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"disabled|Disabled"
    ...            timeout=60
    Pmax Recommissioning    400
    ADMIN Assert Alarm Inactive    fault_id=4008    alarm_id=7112    alarm_severity=Critical    alarm_resource=[1] MRBTS-1/LNBTS-1/LNCEL-1
    ...    fault_name="Power level not supported"    timeout=360
    Log To Console    Fault 4008 cleared
    ADMIN Assert Cell With Cell Id Is In Expected State
    ...            cell_id=${CELL_DN}
    ...            state_type=operationalState
    ...            expected_state=regex"enabled|Enabled"
    ...            timeout=60

TC_11_Activation, Deactivation And Interval Change Of O-RU LTE eCPRI Monitoring
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA_LTE
    EcpriMonitoring Recommissioning    15min
    sleep    1200
    counter create
    counter analyser
    EcpriMonitoring Recommissioning    30min
    sleep     2500
    counter create
    counter analyser
    EcpriMonitoring Recommissioning    disabled
    sleep     1200
    counter create
    counter analyser
    EcpriMonitoring Recommissioning    15min
    ADMIN Reset Site
    sleep     2500
    counter create
    counter analyser
    EcpriMonitoring Recommissioning    disabled

TC_12_O-RU_LTE eCPRI Monitoring Failure And Timeout Scenarios
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC12}
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA_LTE
    CB008205-C.Create SSH Session To ORU and trigger fault    ${cmd_TC12_1900}
    EcpriMonitoring Recommissioning    15min
    FOR    ${i}	   IN RANGE    2
        ${status}=	Run Keyword And Return Status    ADMIN Assert Alarm Active    fault_id=1900    alarm_id=7116    alarm_severity=Critical
        ...    alarm_resource=[1] MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
        ...    fault_name="RF Module configuring failed"    timeout=360
        Run Keyword If    '${status}' == 'True'    Exit For Loop
        CB008205-C.Create SSH Session To ORU and trigger fault    ${cmd_TC12_1900}
    END
    Log To Console    Fault 1900 visible
    CB008205-C.Create SSH Session To ORU and trigger fault    ${cmd_TC12_1900_cleared}
    ADMIN Reset Site
    sleep    100
    ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=1200
    Log to console   \nCell is in OnAir state
    Log to console   \nSending pm timeout through backoor command
    CB008205-C.Create SSH Session To ORU and trigger fault    ${cmd_TC12_1806}
    sleep    5
    EcpriMonitoring Recommissioning    disabled
    ADMIN Assert Alarm Active    fault_id=1806    alarm_id=7101    alarm_severity=Warning
    ...    alarm_resource=[1] MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
    ...    fault_name="Radio autonomous reset as recovery action"    timeout=360
    Log To Console    Fault 1806 visible
    ADMIN Reset Site
    sleep    100
    ADMIN Assert All Cells Are In Enabled State    timeout=900
    Log to console   \nCell is in OnAir state

Create SSH Session To ORU and trigger fault
    [Arguments]    ${cmd}
    Create SSH Session To ORU    ${cmd}

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

EcpriMonitoring Recommissioning
    [Arguments]    ${ecpriMonitoring_value}
    Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1/PMRNL-1
    ...    parameter=mteCPRIMonitoring
    ...    value=${ecpriMonitoring_value}
    ...    timeout=200
    Log To Console      ${\n}EcpriMonitoring recommissioned: ${ecpriMonitoring_value}

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

Test Teardown
    Collect SOS report
    CB008205-C.Collect Snapshot

Configure Netconf Credentials
    [Arguments]    @{list}
    taf.sbts.oam.coam.admin.Setup Admin
    configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}
    taf.sbts.oam.coam.admin.Teardown Admin

Pmax Recommissioning
    [Arguments]    ${pmax_value}
    Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1/LNCEL-1
    ...    parameter=pMax
    ...    value=${pmax_value}
    ...    timeout=200
    Log To Console      ${\n}pMax recommissioned: ${pmax_value}

Collect SOS report
    Run     chmod 777 /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    ${output} =    OperatingSystem.Run    pwd
    Run     sudo rm ${output}/SosReport*_UEAPP.tgz
    Run     /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    Wait Until Created    ${output}/SosReport*_UEAPP.tgz    400s
    Run     sudo cp ${output}/SosReport*_UEAPP.tgz ${out}

Collect Snapshot
    taf.sbts.oam.coam.admin.collect_snapshot    target_file_name=${out}/Snapshotfile.zip    connection=suite


Copy Xml And Send Cmd to ORU
    [Arguments]    ${file}      ${path}
    Copy Xml And Send Cmd By Netopeer Cli to APOABIO    ${file}    ${path}

Trigger Fault 1500 With Severity Minor
        Create SSH Session To ORU    ${cmd_TC04}
        sleep    10

Create SSH Session To ORU
    [Arguments]    ${cmd}
    ${result}=    Run Process    ssh    oru01@192.168.200.1    ${cmd}
    Log to Console    ${result.rc}
    Log to Console    ${result.stdout}
    Log to Console    ${result.stderr}

Install OFGESA RU with Support Specified Number Of Cells to 0
    Run    chmod +x ${INSTALL_OFGESA_supported_cells_0}
    Run    sh ${INSTALL_OFGESA_supported_cells_0}
    Log to console    \nInstalling modified OFGESA radio with modified max supported cell configuration to 0

Configure Netconf Account In Webem With SSH Public key change
    [Arguments]    @{list}
    taf.sbts.oam.coam.admin.Setup Admin
    configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=DeactivationOfSSHPublicKeyValidationAtFirstConnection
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}
    taf.sbts.oam.coam.admin.Teardown Admin


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

Prepare_Testline_with_OFGESA
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    sleep    10
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    sleep    60
    Configure Netconf Credentials    @{sudo_list}
    sleep    10
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install OFGESA RU
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN Assert All Rmods Are In Enabled State   timeout=900
    Change VlanId
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-C WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END

Prepare_Testline_with_OFGESA_LTE
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    sleep    10
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE_LTE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    sleep    60
    Configure Netconf Credentials    @{sudo_list}
    sleep    10
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        Install OFGESA RU for CB008205-A
        Configure Netconf Credentials    @{sudo_list}
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Rmods Are In Enabled State   timeout=900
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END
    ADMIN Assert All Rmods Are In Enabled State   timeout=900
    Change VlanId
    FOR    ${i}	   IN RANGE    3
        Sleep	2s
        CB008205-C WTSSIM S1 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=LNCEL    timeout=200
        Run Keyword If    '${status}' == 'True'    Exit For Loop
    END

Check VlanId
    ${vlanId}=    ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-*/VLANIF_CONF_M-1
    ...                                                                                parameter=vlanId
    ...                                                                                alias=infomodel_1
    ${vlanId_str}=    Convert to String    ${vlanId}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/../configurations/vlanid_new.json      ${replace}

CB008205-C WTSSIM S1 Link Establish
     Run    chmod 777 ${S1LINK}
     Run    sh ${S1LINK}
     Log to console   \nEstablishing S1 link...

Install OFGESA RU
    Run    chmod +x ${INSTALL_OFGESA}
    sleep    10
    Run    sh ${INSTALL_OFGESA}
    sleep    10
    Log to console    \nInstalling OFGESA radio

Install OFGESA RU for CB008205-A
    Run    chmod +x ${INSTALL_OFGESA_LTE}
    sleep    10
    Run    sh ${INSTALL_OFGESA_LTE}
    sleep    10
    Log to console    \nInstalling OFGESA radio

Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

CB008205-C WTSSIM X2 Link Establish
     Run    chmod 777 ${X2LINK}
     Run    sh ${X2LINK}
     Log to console   \nEstablishing X2 link...

Common_Precondition
    Docker Container Setup
    ADMIN Perform Commissioning    bts_id=1
    ...                            scf_file=${SCF_PATH}/SCF_NR_FDD.xml
    Wait Until Mplane Is Connected
    Check If Gnb Is In On Air State And If Cell Is Enabled

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

Verify Access Group Created
    ${NETCONF_MESSAGE}=    Catenate    SEPARATOR=    ${NETCONF_MESSAGE1}    ${NETCONF_MESSAGE2}
    ${message}=    CB008205-C.Check Message In Netconf Trace File    ${NETCONF_MESSAGE}
    Should Contain    ${message}    ${NETCONF_MESSAGE}
    Should Contain    ${message}    <ok/></rpc-reply>

Check Logged In With Additional Account
    ${message}=    CB008205-C.Check Message In Netconf Trace File    Password authentication (host "::ffff:172.22.8.2", user "xranuser2").
    Should Contain    ${message}    Password authentication (host "::ffff:172.22.8.2", user "xranuser2").
    Should Contain    ${message}    Authentication successful

Check SSH Session Closed After Configuration
    ${NETCONF_MESSAGE}=    Catenate    SEPARATOR=    ${NETCONF_MESSAGE1}    ${NETCONF_MESSAGE2}
    ${message_id}=    CB008205-C.Check Message Id    ${NETCONF_MESSAGE}
    ${message_id_close}=    CB008205-C.Check Message Id    <close-session xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"/></rpc>
    Should Be True    ${message_id} < ${message_id_close}

Generate New SSH Public Key
    ${output}=    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh
    ${warning}=    Run Keyword And Return Status
    ...    Should Contain    ${output}    [WRN]
    Run Keyword If    ${warning}
    ...    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh

FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}

Click Deactivate SSH Validation
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Deactivation of SSH')]
    Click Element    locator=//span[contains(text(),'Deactivation of SSH')]

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

Site reset along with x2 link creation
    taf.sbts.oam.coam.admin.Reset Site   timeout=600
    ...                     wait_for_reconnection=True
    ...                     detailed_output=false
    ...                     connection=${ADMIN_ALIAS}
    sleep    100   # sleep time is to wait for start up window after site reset
    ADMIN Assert All Bbmods Are In Enabled State    timeout=600
    CB008205-C.Configure Default Netconf Account
    CB008205-C.Wait Until Mplane Is Connected    timeout=300
    FOR    ${i}	   IN RANGE    7
        CB008205-C WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=300
        Run Keyword If    ${status}    Exit For Loop
    END

Delete the additional netconf account
    selenium.add_oru_account    60
    selenium.delete_oru_account    ${oru_name}

Configure Default Netconf Account
    Configure Netconf Credentials    @{sudo_list}

Configure Additional Netconf Account
    Configure Netconf Credentials    @{sudo_list_add}

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

Configure Default Netconf Account In Webem With SSH Auth
    [Arguments]    @{list}
    taf.sbts.oam.coam.admin.Setup Admin
    configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=PublicKeyBased
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}
    taf.sbts.oam.coam.admin.Teardown Admin

Assert Fault 1500
    ADMIN Assert Alarm Active    fault_id=1500    alarm_id=7240    alarm_severity=Minor    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="alarm1"    timeout=30
    Log To Console    Fault 1500 visible


Assert Fault 1500 Does Not Contain Meaning And Instruction
    Login To Web Element Manager    ${url}    ${CUSTOMER_LOGIN}    ${CUSTOMER_PASSWORD}
    ...            ${sw_release}    ${browser}
    ${alarm_info}=    selenium.get_active_alarm_detailed_info    1500    60
    ${alarm_details}=    Get From Dictionary    ${alarm_info}    Alarm details
    LOG    ${alarm_details}
    Dictionary Should Not Contain key    ${alarm_details}    Meaning
    Dictionary Should Not Contain key    ${alarm_details}    Instruction
    ${alarm_str}    Convert To String    ${alarm_info}
    Should Contain    ${alarm_str}    'Fault ID/Name': '1500 alarm1'
    Should Contain    ${alarm_str}    'Severity': 'Minor'
    Should Contain    ${alarm_str}    'Extra info': 'Object1; Object2; Object3'
    Teardown Environment

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
    ${out_parameters_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    alias=admin_1
    ...    timeout=20
    [Return]    ${out_parameters_dict}

Get Rmod Id
    ${rmod_id}    ADMIN Get Id For Current    RMOD
    ${dist_name_string}    Convert To String    ${rmod_id}
    ${dist_name}    Get Substring    ${dist_name_string}    2    -2
    Set Global Variable    ${dist_name}

Check MPlaneLink Status
    ${act_mPlane}   CB008205-C.Check Parameter Under Rmod    mPlaneLinkStatus
    [Return]    ${act_mPlane}

Check Parameter Under Rmod
    [Arguments]    ${parameter}
    ${out_parameters_dict}    CB008205-C.Get Parameters    ${parameter}    ${dist_name}
    ${parameter_status}   Set Variable    ${out_parameters_dict}[${parameter}]
    [Return]    ${parameter_status}

Wait Until Mplane Is Connected
    [Arguments]    ${timeout}=800
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=${timeout}
    CB008205-C.Get Rmod Id
    Wait Until Keyword Succeeds
    ...                           ${timeout}
    ...                           5
    ...                           CB008205-C.Assert Mplane Connected
    Log    \n+ MPlane is Connected    console=yes

Assert Mplane Connected
    ${mplane_status}     CB008205-C.Check MPlaneLink Status
    Should Be Equal As Strings    ${mplane_status}
    ...                           Connected

Add Default Netconf Account Without Teardown
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${sw_release}    ${browser}    ${oru_name}    ${account_name}    ${account_pwd}
    ...            ${confirm_account_pwd}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${sw_release}    ${browser}
    selenium.configure_default_netconf_account    ${oru_name}    ${account_name}    ${account_pwd}
    ...    ${confirm_account_pwd}
	selenium.send_netconf_configuration
    Log    \n+ Default Netconf Account Added    console=yes

Channel Bandwidth Delta Recommissioning
    [Arguments]    ${chbw_delta}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${chbw_delta}
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=180
    ...    alias=admin_1
    Log To Console    ${\n}Channel Bandwidth recommissioned

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
    CB008205-C.Set Path In Infomodel
    ${sw_release}=    taf.sbts.oam.coam.admin.get_sw_release_name    connection=suite

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

Reset Site And Prepare Oru
    ADMIN Perform Commissioning    bts_id=1
    ...                            scf_file=${SCF_PATH}/SCF_NR_FDD.xml
    Docker Container Setup
    Wait Until Mplane Is Connected

Assert Mrbts Is In Onair State
    [Arguments]    ${timeout}=50
    ...            ${alias}=admin_1
    ${mrbts_state}    taf.sbts.oam.coam.admin.Get Mrbts State    timeout=${timeout}
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

