*** Settings ***
Library  String
Library  OperatingSystem
Library  Process
Library  SSHLibrary
Library  Collections
Library  DateTime
Library  XML  use_lxml=true
Library  ute_syslog
Library  taf.sw.reporting_portal
Library  ute_pdu
Library  taf.nms.netact  WITH NAME  netact
Library  taf.nms.nom  WITH NAME  nom
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.ue  WITH NAME  ue
Library  taf.hw.rf_attenuator.attenuator  WITH NAME  attenuator
Library  taf.transport.ssh  WITH NAME  ssh
Library  taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi_calculations
Library  taf.sw.scout  WITH NAME  scout
Library  ../resources/python_lib/time_verdict.py
Library  ../resources/python_lib/utilities.py
Library  ../resources/python_lib/tool_ping.py
Resource  taf/rfrl/common_resources/common_step/interface.robot
Resource  taf/rfrl/utilities/dcap/dcap.robot
Resource  ../resources/snapshot_collector.robot
Resource  ../resources/netact.robot
Resource  ../resources/apc.robot
Resource  ../../common_resources/mumin_resource.robot

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  05.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-128 - new framework design based on TAF solutions
...  11.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-134 - add KW "Download Expected SW Package"
...  04.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-175 - adaptation for SBTS22R3
...  13.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-186 - generic solution for sw packages path
...  20.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-204 - add KWs: "Add Flag To Swconfig" and "Execute SSH Command On BTS"
...  11.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  13.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-221 - add verification of availabilityStatus parameter for GNCEL
...  02.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-259 - add workaround solution for ErrorCode: 69 in KW "Collect Snapshot File"
...  06.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-262 - add variable ${SEND_SNAPSHOT_FOR_SCRAMBLING} in KW "Collect Snapshot File"
...  13.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-267 - add KW "Get Reset Counter From Blackbox" and "Get Active Partition"
...  04.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-271 - add variable ${RELEASE} in KW "Get Configuration Details" and
...                                                                 add KW "Move Logs To Burak"
...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-286 - fix KW "Download Expected SW Package" (add support for FSM3)
...  08.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-300 - add KW "Check X2 Link"
...  19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-303 - add KWs "Set VM Time Zone" and "Check VM Time Zone"
...  08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-319 - add KWs "Restart NTP Synchronization On VM" and "Add VM NTP Servers"
...  08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-335 - add KWs "Configuration Reset With HWF", "Get BTS Platform", "Get SMOD Variant"
...  15.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-331 - add KWs "Test Suite Setup", "Test Suite Teardown"
...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-345 - fix KW: "Download Expected SW Package"
...  20.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-346 - add DCAP syslog collection to common resources
...  29.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-269 - add Check SCF Errors to common test setup, moved SCF Backup to that keyword
...  16.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-367 - fix KW: "Generate and Send Configuration ID to ReP"
...  04.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-368 - Added possibility to download SW from BURAK, KW's created:
...  SW Download from WFT, Check if SW Is On Burak, Copy SW from Burak, also  Modified: Download expected SW package
...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-498 - Update KW "Collect RawAlarmHistory Files" and "Collect Swconfig File":
...  collecting files using the SSH command and downloading them to 'results' directory
...  24.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-521 - add KWs: "Check If Cells Configured On Other RMOD",
...                                                                 "Get Cells From Carrier List" and "Get RMOD From Carrier List"
...  01.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-435 - Add KWs: "Check Feature Availability And Value",
...  "Get DETECTION_RESULT For Specified Objects", "Compare DETECTION_RESULT Objects"  and "Remove From RAT List"
...  07.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-557 - Update "Check Feature Availability And Value" to set 'initial_value'
...  to "None" when parameter availability is False
...  12.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-539 - SCF Backup KW timeout increase to 60 seconds
...  15.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-561 - Remove KW "Collect RawAlarmHistory Files" from Teardown
...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-554 - Add KW "Set Parameter To Expected Value"
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${IAV_WCDMA}  //burak2.intra.noklab.net/IAV_WCDMA
${Glo_Ver}  //burak2.intra.noklab.net/Global_veryfication
${IAV_WCDMA_path}  /media/IAV_WCDMA
${Glo_Ver_path}  /media/Global_veryfication
${ENB_ROOT_USER}  toor4nsn
${ENB_ROOT_PASS}  oZPS0POrRieRtu
${MSM_IP}  192.168.255.129
${SKIP_PARAMETER_RELATION_ERRORS}  True
${SHOULD_ACTIVATE}  True
${BTS_expected_states}                 proceduralState=regex"(?i)OnAir", blockingState=regex"(?i)Unblocked"
${RMOD_expected_states}                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${SMOD_expected_states}                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${GSM_expected_state}                  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                    blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${WCDMA_expected_state}                operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...                                    usageState=regex"(?i)Active"
${LTE_expected_state}                  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                    blockingState=regex"(?i)Unblocked"
${NR_expected_state}                   administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                    blockingState=regex"(?i)Unblocked"
${LTE_ps_expected_state}               administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled",
...                                    blockingState=regex"(?i)Unblocked", energySavingState:regex"(?i)energySaving",
${NR_ps_expected_state}                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled",
${artifactory}  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${SW_PACKAGE_DESTINATION}  /tmp/SW_package
@{recomended_flags}  0x1003F=1  0x10040=1  0x10041=5  0x19000A=1  0x480008=1  0x30000F=1  0x1A0020=1  0x200B5=1
...  0x45005A=1  9=1  0x300000=1  0x300001=1  0x30001C=1  0x1A0000=1  0x420000=1  0x480000=1  0x480014=1  0x48001A=1
...  0x480018=1  0x500000=1  0x450000=1


*** Keywords ***
Common Test Setup
    [Documentation]  Set of actions which will be executed before each of test.

    Log  \n\n============== COMMON TEST SETUP ==============  console=${true}
    Check Disk Space    PATH=/home/ute/test_results   SPACE_MB=2048    #2GB
    Verify VM Time Zone
    Set init Variables
    Create Log Directory
    ${status_syslog}  Run Keyword And Return Status  Setup Syslog
    ${status_admin}   Run Keyword And Return Status  Setup Admin
    Wait Until Keyword Succeeds  30s  10s  Get Configuration Details
#    Add Flag To Swconfig  0x450027=1  #"R&D mode" flag valid since 22R3
    IF  ${status_admin} and ${status_syslog}
        Log  ============= PRECONDITIONS CHECK =============  console=${true}
        Check SMODs State  ${SMOD_expected_states}
	    Check RMODs State  ${RMOD_expected_states}
	    Check If ALDs Are Connected And Achieved Expected State
#	    Check ALDs State  ${ALD_expected_states}
	    common.Check BTS State  ${BTS_expected_states}
	    Check If NLWG Cells Are OnAir
	    Check If Unexpected Alarms Are Raised  ${skip_fault}
	    Log  =========== PRECONDITIONS CHECK OK ============  console=${true}
	END
    Start Watchdog  ${skip_fault}
    Run Keyword And Ignore Error  Workaround For Empty NETACT_ID
    Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${NETACT_ID}.py
    Mount Burak Network Drive
#    Run Keyword And Ignore Error  DCAP Syslog Setup
    Check SCF Errors
    Set Dist Name For Objects
    Setup Mumin
    Log  =========== COMMON TEST SETUP DONE ============  console=${true}


Check Disk Space
    [Documentation]  Keyword checks if there is at least the specified amount (in MB) of free disk space in given path.
    [Arguments]    ${PATH}=/home/ute/test_results   ${SPACE_MB}=2048

    ${free_space}  Run  df -BM --output=avail ${PATH} | sed 1d | sed -e 's/M//'
    IF  ${free_space}<${SPACE_MB}  Fatal Error  ${free_space}MB available in ${PATH} - expected at least ${SPACE_MB}MB


Verify VM Time Zone
    [Arguments]  ${timezone}=Europe/Bucharest

    ${verdict}  Run Keyword And Return Status  Check VM Time Zone  ${timezone}
    IF  not ${verdict}
        Set VM Time Zone  ${timezone}
        Check VM TimeZone  ${timezone}
    END


Set VM Time Zone
    [Arguments]  ${expected_timezone}

    ${regex}  Set Variable  Time zone:\\s(?P<timezone>[a-zA-Z/]*)\\s\\((?P<time>.*)\\)
    ${timedatectl}  Run  timedatectl
    ${result}  Get Regexp Matches  ${timedatectl}  ${regex}  timezone  time
    ${timezone}  ${time}  Set Variable  ${result[0]}
    IF  '${timezone}'!='${expected_timezone}'
        Log To Console  Changing VM time zone: ${timezone} to ${expected_timezone}
        Run  sudo timedatectl set-timezone "${expected_timezone}"
        Sleep  70s
    END


Check VM Time Zone
    [Arguments]  ${expected_timezone}

    ${regex}  Set Variable  Time zone:\\s(?P<timezone>[a-zA-Z/]*)\\s\\((?P<time>.*)\\)
    ${timedatectl}  Run  timedatectl
    ${result}  Get Regexp Matches  ${timedatectl}  ${regex}  timezone  time
    ${timezone}  ${time}  Set Variable  ${result[0]}
    Should Be True  '${timezone}'=='${expected_timezone}'


Set init Variables
    ${TESTLINE_NAME}  Evaluate  "${CONFIGURATION}".split(".")[1]
    Set Suite Variable  ${TESTLINE_NAME}
    Set Suite Variable  ${TOPOLOGY}  ${tl.tl_cloud_topology}
    Set Suite Variable  ${ENB_MPLANE_IP}  ${tl.enbs[0].oam_ip.v4}
    ${enb_qty}  Get Length  ${tl.enbs}
    IF  '${enb_qty}'=='${1}'
        Set Suite Variable  ${VM1_IP}  ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ELSE IF  '${enb_qty}'=='${2}'
        Set Suite Variable  ${VM1_IP}  ${tl.test_pcs[0].default_ssh_connection_details.addr}
        Set Suite Variable  ${VM2_IP}  ${tl.test_pcs[1].default_ssh_connection_details.addr}
    END
    Set Suite Variable  ${enb_qty}  ${enb_qty}


Create Log Directory
    [Arguments]  ${test_results}=/home/ute/test_results

    ${now}  Run  date +%F_%H-%M-%S
    ${TEST_NAME}  Evaluate  '${TEST_NAME}'.replace(' ','_')
    ${LOG_DIR}  Join Path  ${test_results}  ${now}_${TEST_NAME}
    Create Directory  ${LOG_DIR}
    Set Test Variable  ${RESULTS}  ${LOG_DIR}
    Log To Console  Test result path: ${RESULTS}


Get Configuration Details
    [Documentation]  Shows actual configuration on ENB basing on config files
    ...              Author: krystian.gordziejewski@nokia.com
    ...              EDIT: Refactored to avoid obsolete-to-be infomodel library - Author: artur.lebek@nokia.com
    ...              EDIT: Add more parameters - Author: tomasz.marchewka@nokia.com
    [Arguments]  ${ute_admin_alias}=default

    ${bts_info}  admin.get bts info  connection=${ute_admin_alias}
    Set Suite Variable  ${ACTIVE_SW_VERSION}  ${bts_info['swInfo']['swVersion']}
    ${regex}  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)_(ENB|FSM3)_(?P<version>\\d{4})
    ${result}  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  product  postfix
    ${result_version}  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  version
    ${product}  ${postfix}  Set Variable  ${result[0]}
    ${product}  Convert To Uppercase  ${product}
    ${postfix}  Convert To Uppercase  ${postfix}
    Set Suite Variable  ${SW_TYPE}  ${product}${postfix}
    IF  '${result_version[0]}'=='0000'
        Set Suite Variable  ${RELEASE}  ${SW_TYPE}
    ELSE IF  '${result_version[0]}'=='9999'
        Set Suite Variable  ${RELEASE}  SBTS00
    END
    Set Suite Variable  ${MRBTS_ID}  ${bts_info['mrbtsID']}
    Run Keyword And Ignore Error  Set Suite Variable  ${NRBTS_ID}  ${bts_info['nrBtsId']}
    Get BTS Platform
    ${rats}  Detect RATs
    Set Suite Variable  ${rats}
    Log  Common Module Composition: ${SMOD_COMPOSITION}  console=${true}
    Log  MRBTS ID: ${MRBTS_ID}  console=${true}
    Log  BTS name: ${bts_info['name']}  console=${true}
    Log  Active Software Version: ${ACTIVE_SW_VERSION}  console=${true}
    Log  Testline: ${TESTLINE_NAME}  console=${true}
    Log  Topology: ${TOPOLOGY}  console=${true}


Get BTS Platform
    ${fcmVariant_list}  Get SMOD Variant
    ${SMOD_qty}  Get Length  ${fcmVariant_list}
    IF  '${SMOD_qty}'=='${1}'
        ${BTS_TYPE}  Set Variable  singlecore
    ELSE IF  '${SMOD_qty}'=='${2}'
        ${BTS_TYPE}  Set Variable  dualcore
    END
    IF  '${SMOD_qty}'=='${1}'
        ${smod_composition}  Set Variable  ${fcmVariant_list}[0]
    ELSE IF  '${SMOD_qty}'=='${2}'
        ${smod_composition}  Set Variable  ${fcmVariant_list}[0]+${fcmVariant_list}[1]
    END
    Set Suite Variable  ${BTS_TYPE}
    Set Suite Variable  ${SMOD_COMPOSITION}


Get LNBTS ID
    ${LNBTS_DN}  admin.Get Id For Current  LNBTS
    ${LNBTS_ID}  Evaluate  re.search(r'LNBTS_R-(\\d+)','''${LNBTS_DN}''').group(1)  re

    RETURN  ${LNBTS_ID}


Get SMOD Variant
    ${SMOD_info}  admin.Get Parameters For All  SMOD
    ${fcmVariant_list}  Create List
    FOR  ${SMOD}  IN  @{SMOD_info}
        ${fcmVariant}  Evaluate  '${SMOD['fcmVariant']}'.replace(' ','')
        Append To List  ${fcmVariant_list}  ${fcmVariant}
    END

    RETURN  ${fcmVariant_list}


Mount Burak Network Drive
    [Documentation]  This keyword mount network drive: IAV_WCDMA and Global_veryfication on VM.
    ...  **Author:** tomasz.marchewka@nokia.com

    Run  sudo mkdir /media/IAV_WCDMA
    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=sranwro6,password=wro6pass,domain=noklab,users,nounix ${IAV_WCDMA} ${IAV_WCDMA_path}
    Run  sudo mkdir /media/Global_veryfication
    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=plwr4gsfe,password=ltesfe4@,domain=noklab,users,nounix ${Glo_Ver} ${Glo_Ver_path}


Setup Syslog
    [Arguments]  ${log_dir}=${RESULTS}/syslog

    Run Keyword And Ignore Error  ute_syslog.Teardown All Aliases For Syslog
    Wait Until Keyword Succeeds  5m  30s  ute_syslog.start syslog  log_dir=${log_dir}  log_name=SYSLOG.log  file_limit=104857600  # 100MB
    ...  add_line_number=True  alias=ute_syslog


Setup Admin
    [Arguments]  ${admin_api_log_dir}=${RESULTS}/admin_api/  ${ute_admin_alias}=default

    Run Keyword And Ignore Error  Teardown Admin  alias=${ute_admin_alias}
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  192.168.255.129
    ...  admin_api_log_dir=${admin_api_log_dir}  update_interval=500  alias=${ute_admin_alias}
    Set Suite Variable  ${ute_admin_alias}  default


Add Flag To Swconfig
    [Documentation]  Keyword add expected flag to swconfig file.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Add Flag To Swconfig  0x450027=1
    ...
    [Arguments]  ${flag}

    ${status}  Execute SSH Command On BTS  command=cat /rom/swconfig.txt | grep ${flag}
    ${status}  Run Keyword And Return Status  Should Be Empty  ${status}
    IF  ${status}
        Log  Adding swconfig flag: ${flag}  console=${true}
        Execute SSH Command On BTS  command=echo ${flag} >> /rom/swconfig.txt
        Execute SSH Command On BTS  command=crasign /rom/swconfig.txt
        admin.reset site  timeout=700
	    Check SMODs State  ${SMOD_expected_states}
	    Check RMODs State  ${RMOD_expected_states}
	    Check ALDs State  ${ALD_expected_states}
	    common.Check BTS State  ${BTS_expected_states}
	    Check If NLWG Cells Are OnAir
	END


Execute SSH Command On BTS
    [Documentation]  Keyword dedicated for ssh command sending (KW base on taf.transport.ssh library).
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Execute SSH Command On BTS  command=ddal -s ddal_reboot_graceful
    ...
    [Arguments]  ${command}

    ssh.connect_to  hostname=${MSM_IP}  username=${ENB_ROOT_USER}  password=${ENB_ROOT_PASS}
    ${msg}  Run Keyword And Return  ssh.execute  command=${command}
    ssh.Disconnect

    RETURN  ${msg}


DCAP Syslog Setup
    ${graceful_cell_test}  Run keyword and return status  Should Contain  ${TEST_NAME}  Graceful  ignore_case=True
    IF  ${graceful_cell_test}==${FALSE}
        dcap.Start DCAP on UTE VM
        dcap.DCAP Start tracing eNB
    END


Test Suite Setup
    [Documentation]  Set of actions which will be executed before each of test suite.

    Log  \n\n============== TEST SUITE SETUP ==============  console=${true}
    Run keyword and ignore error  APC Control  ON  ALL
    Wait Until Keyword Succeeds  10min  30s  Check If SMOD Is Pingable
    Full Check After Start-up
    Log  =========== TEST SUITE SETUP DONE ============  console=${true}


Test Suite Teardown
    [Documentation]  Set of actions which will be executed after each of test suite.

    Run Keyword If All Tests Passed  APC Control  OFF  ALL


#####################
### TEST TEARDOWN ###
#####################


Common Test Teardown
    [Documentation]  Set of actions which will be executed after each of test.
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}

    Log  \n============ COMMON TEST TEARDOWN =============  console=${true}
    Collect Snapshot File  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Collect Syslog Files
#    Collect RawAlarmHistory Files
    Collect Swconfig File
#    Swconfig Validator  ${RESULTS}/swconfig.txt
    Run Keyword And Ignore Error  interface.Common step trigger
    Run Keyword And Ignore Error  Move Logs To Burak
    Run Keyword And Ignore Error  Generate and Send Configuration ID to ReP
    Stop Watchdog And Check Alarms
    Collect Mumin Logs
    Teardown Mumin
#    Run Keyword And Ignore Error  DCAP Syslog Teardown

    [Teardown]  Teardown Admin  alias=${ute_admin_alias}
    Log  ========== COMMON TEST TEARDOWN DONE ==========\n  console=${true}


Collect Snapshot File
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=False

    Log  Snapshot collecting  console=${true}
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SNAPSHOT_PATH}  Set Variable  ${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}_${timestamp}.zip
    Run Keyword And Ignore Error  Collect Snapshot  target_file_name=${SNAPSHOT_PATH}  timeout=1500
    IF  ${SEND_SNAPSHOT_FOR_SCRAMBLING}==${True}
    ...  Run Keyword And Ignore Error  Check and Send Snapshot to Server CLASSICAL TRSSEC  snapshot_path=${SNAPSHOT_PATH}


Collect Syslog Files
    [Arguments]  ${destination}=${RESULTS}/syslog/syslog.tar.gz

    Log  Syslog collecting  console=${true}
    ute_syslog.Collect Syslog Results  destination=${destination}  unzip=False  alias=ute_syslog

    [Teardown]  ute_syslog.Teardown All Aliases For Syslog


Collect Swconfig File
    Log  swconfig collecting  console=${true}
    ssh.Connect to  ${MSM_IP}  ${ENB_ROOT_USER}  ${ENB_ROOT_PASS}
    ssh.Download File  /ffs/run/swconfig.txt  ${RESULTS}/swconfig.txt

    [Teardown]  ssh.Disconnect


Collect RawAlarmHistory Files
    Log  RawAlarmHistory collecting  console=${true}
    ssh.Connect to  ${MSM_IP}  ${ENB_ROOT_USER}  ${ENB_ROOT_PASS}
    ssh.Download File  /tmp/RawAlarmHistory.txt  ${RESULTS}/RawAlarmHistory.txt

    [Teardown]  ssh.Disconnect

Swconfig Validator
    [Arguments]  ${swconfig_path}

    Log  swconfig flag validating  console=${true}
    ${SMOD_flags}  Create List
    ${var}  OperatingSystem.Get File  ${swconfig_path}
    @{var_list}  Split To Lines  ${var}
    FOR  ${item}  IN  @{var_list}
        ${flag}  Get Variable Value  ${item}
        ${flag}  Evaluate  '${flag}'.replace(' ','')
        ${status}  ${flag}  Run Keyword And Ignore Error  Should Match Regexp  ${flag}  ^\\d+[a-zA-Z0-9\.]*=\\d+
        IF  '${status}'=='PASS'  Append To List  ${SMOD_flags}  ${flag}
    END
    ${warn_flags}  Create List
    FOR  ${item}  IN  @{SMOD_flags}
        ${status}  ${msg}  Run Keyword And Ignore Error  List Should Contain Value  ${recomended_flags}  ${item}
        IF  '${status}'=='FAIL'
            Log  Flag: ${item} is not in recommended swconfig.txt  WARN
            Append To List  ${warn_flags}  ${item}
        END
    END
    ${qty}  Get Length  ${warn_flags}
    IF  ${qty}==${0}
        Log  On BTS there is no unexpected flag(s)  console=${true}
    ELSE IF  ${qty}>${0}
        Log  ${qty} unexpected flag(s) found  console=${true}
    END


Move Logs To Burak
    [Arguments]  ${source}=${RESULTS}

    ${date}  DateTime.Get Current Date  result_format=%d%m%Y  exclude_millis=True
    ${destination}  Set Variable  /media/Global_veryfication/UTE_logs/${MRBTS_ID}/${date}/${RELEASE}
    Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  mkdir -p ${destination}
    Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  cp -r ${source} ${destination}


#Generate and Send Configuration ID to ReP
#    scout.Setup Scout  scout_testline_name=${TESTLINE_NAME}  environment=production
#    scout.Request Scf
#    [Teardown]  scout.Teardown Scout Api


Generate and Send Configuration ID to ReP
    [Documentation]  Sends request to Scout to fetch new SCF. Returns Scout SCF id.
    ...
    ...  +-----------------------+---------+----------------------------------------------------------------------+
    ...  | Variable              | Value   | Description                                                          |
    ...  +=======================+=========+======================================================================+
    ...  | use_scout_internal_id | False   | If you use single run, collected SCF file will be analyzed in Scout  |
    ...  |                       |         | and the analysis will be send to Reporting Portal (default value).   |
    ...  +-----------------------+---------+----------------------------------------------------------------------+
    ...  | use_scout_internal_id | True    | If you want to report outside robot tests. Include returned Scout SCF|
    ...  |                       |         | id in report send to Reporting Portal.                               |
    ...  +-----------------------+---------+----------------------------------------------------------------------+
    ...
    [Arguments]  ${timeout}=60

    ${process_status}  Run  ps -ef | grep CM_EXECUTION_ID
    ${is_ute_run}  Run Keyword And Return Status  Should Match Regexp  ${process_status}  CM_RESERVATION_ID
    scout.Setup Scout  scout_testline_name=${TESTLINE_NAME}  environment=production
    IF  ${is_ute_run}
        ${scout_scf_id}  scout.Request Scf  use_scout_internal_id=${False}  timeout=${timeout}
    ELSE
        ${scout_scf_id}  scout.Request Scf  use_scout_internal_id=${True}  timeout=${timeout}
    END
    IF  not ${is_ute_run}  taf.sw.reporting_portal.Add To Test Data  data={"tc_execution_id": "${scout_scf_id}"}

    [Teardown]  scout.Teardown Scout Api

DCAP Syslog Teardown
    ${graceful_cell_test}  Run keyword and return status  Should Contain  ${TEST_NAME}  Graceful  ignore_case=True
    IF  ${graceful_cell_test}==${FALSE}
        dcap.DCAP Stop tracing and collect results  with_name=dcap_syslog
        dcap.Stop DCAP on UTE VM
    END

###################
### CHECK STATE ###
###################

Check If NLWG Cells Are OnAir
    [Arguments]  ${GSM_AvailabilityStatus_check}=True

    ${GSM_DEPLOYED}  admin.Get Ids For All  GNCEL
    ${WCDMA_DEPLOYED}  admin.Get Ids For All  WNCEL
    ${LTE_DEPLOYED}  admin.Get Ids For All  LNCEL
    ${NR_DEPLOYED}  admin.Get Ids For All  NRCEL
    ${PSGRP_DEPLOYED}  admin.Get Managed Objects  PSGRP_A
    ${NRPGRP_DEPLOYED}  admin.Get Managed Objects  NRPGRP_A
    IF  ${GSM_DEPLOYED}!=[]
        Log  Checking GSM cell(s)
        Check GNCELs  ${GSM_AvailabilityStatus_check}
	END
    IF  ${WCDMA_DEPLOYED}!=[]
        Log  Checking WCDMA cell(s)
        Check WNCELs
    END
    IF  ${LTE_DEPLOYED}!=[] and ${PSGRP_DEPLOYED}==[]
        Log  Checking LTE cell(s)
        Check LNCELs
    ELSE IF  ${LTE_DEPLOYED}!=[] and ${PSGRP_DEPLOYED}!=[]
        Log  Checking LTE cell(s) under PSGRP and other(s)
        Check PowerSaving LNCELS And Return Status
    END
    IF  ${NR_DEPLOYED}!=[] and ${NRPGRP_DEPLOYED}==[]
        Log  Checking NR cell(s)
        Check NRCELs
    ELSE IF  ${NR_DEPLOYED}!=[] and ${NRPGRP_DEPLOYED}!=[]
        Log  Checking NR cell(s) under NRPGRP and other(s)
        Check PowerSaving NRCELS And Return Status
    END


Check GNCELs
    [Arguments]  ${GSM_AvailabilityStatus_check}

    IF  ${GSM_AvailabilityStatus_check}
        ${GSM_status}  Run Keyword And Return Status  Run Keywords
        ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  GNCEL  ${GSM_expected_state}
        ...  AND  Wait Until Keyword Succeeds   3min  30s  Check State on GNCELs  availabilityStatus  None
    ELSE
        ${GSM_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  GNCEL  ${GSM_expected_state}
    END
    IF  ${GSM_status} == True
        Log  All GNCEL(s) are OnAir  console=${true}
    ELSE
        Fail  msg=At least one GNCEL has not reached OnAir state within 20 minutes
    END


Check State on GNCELs
    [Documentation]  Workaround keyword due to lack of support for availabilityStatus parameter by admin.assert
    ...
    ...  **Example of simple usage:**
    ...  Wait Until Keyword Succeeds  3min  30s  Check State on GNCELs  availabilityStatus  None
    ...
    [Arguments]  ${parameter}  ${expected_state}

    ${gncel_params}  admin.get managed objects  GNCEL_R
    FOR  ${gncel}  IN  @{gncel_params}
       IF  '${gncel['parameters']['${parameter}']}'=='${expected_state}'
           Should Be Equal As Strings  ${gncel['parameters']['${parameter}']}  ${expected_state}  ignore_case=True
       END
    END


Check WNCELs
    ${WCDMA_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  WNCEL  ${WCDMA_expected_state}
    IF  ${WCDMA_status} == True
        Log  All WNCEL(s) are OnAir  console=${true}
    ELSE
        Fail  msg=At least one WNCEL has not reached OnAir state within 20 minutes
    END


Check LNCELs
    ${LTE_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  LNCEL  ${LTE_expected_state}
    IF  ${LTE_status} == True
        Log  All LNCEL(s) are OnAir  console=${true}
    ELSE
        Fail  msg=At least one LNCEL has not reached OnAir state within 20 minutes
    END


Check NRCELs
    ${NR_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  NRCEL  ${NR_expected_state}
    IF  ${NR_status} == True
        Log  All NRCEL(s) are OnAir  console=${true}
    ELSE
        Fail  msg=At least one NRCEL has not reached OnAir state within 20 minutes
    END


Check PowerSaving LNCELS And Return Status
    [Documentation]    Keyword verify if LTE cells that are included to PSGRP, have energy saving state,
    ...    if no cells will be added to not energy saving list, and verified if not energy saving.

    ${not_ps_cells}  ${ps_cells}  Return PS And Not PS LTE Cells
    Set Test Variable  @{not_ps_cells}
    Set Test Variable  @{ps_cells}
    FOR  ${cell}  IN  @{ps_cells}
      ${LTE_ps_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  10sec  5s  admin.assert  LNCEL  ${cell}  ${LTE_ps_expected_state}
      Set Variable  ${LTE_ps_status}
      IF  ${LTE_ps_status}!=True  Append To List  ${not_ps_cells}  ${cell}
    END
    IF  ${LTE_ps_status} == True  Log To Console  Cell(s) under PSGRP in energySaving state
    FOR  ${cell}  IN  @{not_ps_cells}
       ${not_ps_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert  LNCEL  ${cell}  ${LTE_expected_state}
       Set Variable  ${not_ps_status}
    END

    RETURN  ${LTE_ps_status}  ${not_ps_status}


Check PowerSaving NRCELS And Return Status
    [Documentation]    Keyword verify if NR cells that are included to NRPGRP, have energy saving state,
    ...    if no cells will be added to not energy saving list, and verified if not energy saving.

    ${not_ps_cells}  ${ps_cells}  Return PS And Not PS NR Cells
    Set Test Variable  @{not_ps_cells}
    Set Test Variable  @{ps_cells}
    FOR  ${cell}  IN  @{ps_cells}
      ${NR_ps_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  10sec  5s  admin.assert  NRCEL  ${cell}  ${NR_ps_expected_state}
      Set Variable  ${NR_ps_status}
      IF  ${NR_ps_status}!=True  Append To List  ${not_ps_cells}  ${cell}
    END
    IF  ${NR_ps_status} == True  Log To Console  Cell(s) under NRPGRP in energySaving state
    FOR  ${cell}  IN  @{not_ps_cells}
       ${not_ps_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert  NRCEL  ${cell}  ${NR_expected_state}
       Set Variable  ${not_ps_status}
    END

    RETURN  ${NR_ps_status}  ${not_ps_status}


Check SMODs State
    [Arguments]  ${SMOD_expected_states}

    ${SMOD_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  SMOD  ${SMOD_expected_states}
    IF  ${SMOD_status} == True
        Log  All SMOD(s) have expected state  console=${true}
    ELSE
        Fail  msg=At least one SMOD has not reached expected state within 20 minutes
    END


Check RMODs State
    [Arguments]  ${RMOD_expected_states}

    ${RMOD_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.Assert Every  RMOD  ${RMOD_expected_states}
    IF  ${RMOD_status} == True
        Log  All RMOD(s) have expected state  console=true
    ELSE
        Fail  msg=At least one RMOD has not reached expected state within 20 minutes
    END


Check If ALDs Are Connected And Achieved Expected State
    ${ALD_DETECTED}  admin.get ids for all  ALD
    IF  ${ALD_DETECTED}!=[]
        Log  Checking ALD(s)
        Check ALDs State  ${ALD_expected_states}
    END


Check ALDs State
    [Arguments]  ${ALD_expected_states}

    ${ALD_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  30s  admin.assert every  ALD  ${ALD_expected_states}
    IF  ${ALD_status} == True
        Log  All ALD(s) have expected state  console=${true}
    ELSE
        Fail  msg=At least one ALD has not reached expected state within 5 minutes
    END


Check Dedicated ALD State
    [Arguments]  ${ret_or_mha}  ${ALD_expected_states}

    ${ALD_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  30s  admin.assert  ALD  ${ret_or_mha}  ${ALD_expected_states}
    ${ALD_R}  Evaluate  re.search(r'ALD_R-(\\d+)','''${ret_or_mha}''').group(0)  re
    IF  ${ALD_status} == True
        Log  ${ALD_R} have expected state  console=${true}
    ELSE
        Fail  msg=${ALD_R} has not reached expected state within 5 minutes
    END


Check BTS State
    [Arguments]  ${BTS_expected_states}

    ${BTS_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  BTS  ${BTS_expected_states}
    IF  ${BTS_status} == True
        Log  BTS has reached expected state  console=${true}
    ELSE
        Fail  msg=BTS has not reached expected state within 20 minutes
    END


Check BBPOOL State
    [Arguments]  ${BBPOOL_DN}  ${expected_operationalState}

    ${BBPOOLs}  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{BBPOOLs}
        ${bbpool_r}  Evaluate  re.search(r'BBPOOL_R-(\\d+)','''${bbpool}''').group(0)  re
        ${operationalState}  Evaluate  "${bbpool['parameters']['operationalState']}".upper()
        IF  '${bbpool['distName']}'=='${BBPOOL_DN}'
            Should Be True  '${operationalState}'=='${expected_operationalState}'
            Log To Console  ${bbpool_r} operationalState: ${operationalState}
        END
    END


Check X2 Link
    [Documentation]  Keyword check if parameter x2LinkStatus is equal Available.
    ...  **Author:** tomasz.marchewka@nokia.com

    ${LTEENB_L}  admin.get managed objects  LTEENB_L
    FOR  ${i}  IN  @{LTEENB_L}
        Should Be True  '${i['parameters']['x2LinkStatus']}'=='Available'
    END


Full Check After Start-up
    [Arguments]  ${alias}=startup

    Wait Until Keyword Succeeds  5min  30s  admin.setup admin  192.168.255.129
    ...  admin_api_log_dir=/home/ute/test_results/TurnOnBTS/admin_api/  alias=${alias}
    ${SMOD_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  SMOD  ${SMOD_expected_states}  ${alias}
    IF  ${SMOD_status}  Log To Console  \nAll SMOD(s) have expected state
    ${RMOD_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  RMOD  ${RMOD_expected_states}  ${alias}
    IF  ${RMOD_status}  Log To Console  All RMOD(s) have expected state
    ${BTS_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  BTS  ${BTS_expected_states}  ${alias}
    IF  ${RMOD_status}  Log To Console  BTS has reached expected state
    ${ALD_DETECTED}  admin.get ids for all  ALD  ${alias}
    ${ALD_status}  IF  ${ALD_DETECTED}!=[]  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5min  30s  admin.assert every  ALD  ${ALD_expected_states}  ${alias}
    IF  ${ALD_status}  Log To Console  All ALD(s) have expected state
    ${GSM_DEPLOYED}  admin.get ids for all  GNCEL  ${alias}
    ${WCDMA_DEPLOYED}  admin.get ids for all  WNCEL  ${alias}
    ${LTE_DEPLOYED}  admin.get ids for all  LNCEL  ${alias}
    ${NR_DEPLOYED}  admin.get ids for all  NRCEL  ${alias}
    ${GSM_onAir}  IF  ${GSM_DEPLOYED}!=[]  Wait Until Keyword Succeeds  20min  30s  admin.assert every  GNCEL  ${GSM_expected_state}  ${alias}
    IF  ${GSM_onAir}  Log To Console  All GNCEL(s) are OnAir
    ${WCDMA_onAir}  IF  ${WCDMA_DEPLOYED}!=[]  Wait Until Keyword Succeeds  20min  30s  admin.assert every  WNCEL  ${WCDMA_expected_state}  ${alias}
    IF  ${WCDMA_onAir}  Log To Console  All WNCEL(s) are OnAir
    ${LTE_onAir}  IF  ${LTE_DEPLOYED}!=[]  Wait Until Keyword Succeeds  20min  30s  admin.assert every  LNCEL  ${LTE_expected_state}  ${alias}
    IF  ${LTE_onAir}  Log To Console  All LNCEL(s) are OnAir
    ${NR_onAir}  IF  ${NR_DEPLOYED}!=[]  Wait Until Keyword Succeeds  20min  30s  admin.assert every  NRCEL  ${NR_expected_state}  ${alias}
    IF  ${NR_onAir}  Log To Console  All NRCEL(s) are OnAir
    admin.teardown admin  alias=${alias}


Check SCF Errors
    [Documentation]  Keyword checks if there are errors in active SCF file

    ${status}  ${error}  Run Keyword And Ignore Error  Validate SCF
    IF  '${status}' == 'FAIL'  Log  SCF ERROR DETECTED, ERROR MESSAGE: ${error}  WARN


Validate SCF
    [Documentation]  Keyword Validates SCF file

    SCF Backup
    admin.Validate Scf Online  ${RESULTS}/SCF_BACKUP.xml


########################
### GENERAL KEYWORDS ###
########################


SCF Backup
    [Documentation]  This keyword saves current commissioning file

    admin.get current scf file  ${RESULTS}  SCF_BACKUP.xml  timeout=60
    Log  SCF backup path: ${RESULTS}/SCF_BACKUP.xml  console=${True}


BTS Software Update
    [Arguments]  ${SW_PACKAGE_PATH}

    Log  SW update is ongoing...  console=${true}
    ${msg}  admin.update software  ${SW_PACKAGE_PATH}  ${SHOULD_ACTIVATE}  timeout=1800
    IF  '${msg}'=='Software update has been completed'
        Log  ${msg}  console=${True}
    ELSE
        Fail  Software update has been failed
    END


Download Expected SW Package
    [Documentation]  This keyword download expected software package.
    ...  Needed input variable, example: -v SW_PACKAGE:SBTS00_ENB_9999_220327_000002
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Download Expected SW Package  ${SW_PACKAGE}
    [Arguments]  ${SW_PACKAGE}

    ${free_space}  Run  df -BM --output=avail /tmp | sed 1d | sed -e 's/M//'
    IF  ${free_space}<9000  Fatal Error  ${free_space}MB available in /tmp - expected at least 9000MB
    ${verdict}  Run Keyword And Return Status  Should Contain  ${SW_PACKAGE}  SBTS
    IF  ${verdict}==False  Fail  msg=There is no input variable SW_PACKAGE
    ${if_FSM3}  Run Keyword And Return Status  Should Contain  ${SW_PACKAGE}  FSM3
    ${regex}  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)_(ENB|FSM3)_(?P<version>\\d{4})
    ${result}  Get Regexp Matches  ${SW_PACKAGE}  ${regex}  product  postfix
    ${product}  ${postfix}  Set Variable  ${result[0]}
    ${sw_type}  Set Variable  ${product}${postfix}
    IF  '${if_FSM3}'=='True'
        ${full_url}  Set Variable  ${artifactory}/${sw_type}_FSM3/${SW_PACKAGE}/${SW_PACKAGE}_release_BTSSM_downloadable_A54.zip
    ELSE IF  '${if_FSM3}'=='False'
        ${full_url}  Set Variable  ${artifactory}/${sw_type}/${SW_PACKAGE}/${SW_PACKAGE}_release_BTSSM_downloadable_A54.zip
    END
    Log  SW package downloading...  console=${true}
    ${SW_Split}  Split String  ${full_url}  /
    ${SW_is_on_burak}  Run Keyword And Return Status  Check if SW Is On Burak  ${sw_type}  ${if_FSM3}  ${SW_Split[-1]}
    IF  ${SW_is_on_burak}
        ${SW_PACKAGE_PATH}  Set Variable  /tmp/SW_package/${SW_Split[-1]}
    ELSE
        ${SW_PACKAGE_PATH}  SW Download From WFT  ${full_url}
    END

    RETURN  ${SW_PACKAGE_PATH}


SW Download From WFT
    [Arguments]  ${full_url}

    ${status}  Run Keyword And Return Status  Run  wget --no-proxy ${full_url} -P ${SW_PACKAGE_DESTINATION} | tee -a wget_log
    IF  ${status} == False  Fail  msg=SW package download failed
    ${ignore}  ${package_name}  Split String From Right  ${full_url}  separator=/  max_split=1
    ${SW_PACKAGE_PATH}  Set Variable  ${SW_PACKAGE_DESTINATION}/${package_name}

    RETURN  ${SW_PACKAGE_PATH}


Check if SW Is On Burak
    [Documentation]  This keyword uses the approtriate "Copy from Burak" kw to check and copy the software
    [Arguments]  ${sw_type}  ${if_FSM3}  ${SW_name_with_A54.zip}

    IF  ${if_FSM3}
        ${sw_path}  Copy FSM3 SW from Burak  ${sw_type}  ${SW_name_with_A54.zip}
    ELSE
        ${sw_path}  Copy AirScale SW from Burak  ${sw_type}  ${SW_name_with_A54.zip}
    END


Copy FSM3 SW from Burak
    [Documentation]  This keyword copies given SW from Burak, fails if SW is not present on burak
    [Arguments]  ${sw_type}  ${SW_name_with_A54}

    IF  '${sw_type}'=='SBTS00'
        ${burak_path}  Set variable  /media/Global_veryfication/[1] SW/SBTS/SBTS00_FSM3
#   ELSE IF  '${sw_type}'=='SBTS23R3'
#        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R3_FMS3
    ELSE IF  '${sw_type}'=='SBTS23R2'
        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R2_FSMF
    ELSE IF  '${sw_type}'=='SBTS23R1'
        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R1_FSMF
    ELSE
        Fail
    END
    Run  sudo mkdir ${SW_PACKAGE_DESTINATION} && sudo chmod 777 ${SW_PACKAGE_DESTINATION}
    Run  sudo scp -T "${burak_path}/${SW_name_with_A54}" ${SW_PACKAGE_DESTINATION}
    OperatingSystem.File Should Exist  ${SW_PACKAGE_DESTINATION}/${SW_name_with_A54}


Copy AirScale SW from Burak
    [Documentation]  This keyword copies given SW from Burak, fails if SW is not present on burak
    [Arguments]  ${sw_type}  ${SW_name_with_A54}

    IF  '${sw_type}'=='SBTS00'
        ${burak_path}  Set variable  /media/Global_veryfication/[1] SW/SBTS/SBTS00
    ELSE IF  '${sw_type}'=='SBTS23R3'
        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R3
    ELSE IF  '${sw_type}'=='SBTS23R2'
        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R2
    ELSE IF  '${sw_type}'=='SBTS23R1'
        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R1
    ELSE IF  '${sw_type}'=='SBTS22R4'
        ${burak_path}  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS22R4
    ELSE
        Fail
    END
    Run  sudo mkdir ${SW_PACKAGE_DESTINATION} && sudo chmod 777 ${SW_PACKAGE_DESTINATION}
    Run  sudo scp -T "${burak_path}/${SW_name_with_A54}" ${SW_PACKAGE_DESTINATION}
    OperatingSystem.File Should Exist  ${SW_PACKAGE_DESTINATION}/${SW_name_with_A54}


Check If SMOD Is Pingable
    [Arguments]  ${wait_time}=5min

    Wait Until Keyword Succeeds  ${wait_time}  15s  Check If Host Is Reachable  IP=${MSM_IP}

Check If Host Is Reachable
    [Arguments]  ${IP}

    ${result}  Run  ping -c 5 -w 10 ${IP}
    ${status}  Run Keyword And Return Status  Should Contain  ${result}  5 packets transmitted, 5 received
    IF  ${status} == False  Fail  msg=Host is not pingable


Check Admin Readiness
    [Arguments]    ${retry}=40s    ${retry_interval}=20s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Check System Module Port    ${MSM_IP}    positive

Check System Module Port
    [Arguments]  ${IP}  ${ping}

    ${output}  Run  nmap -p 443 ${IP}
    IF  '${ping}'=='positive'
        Should Contain  ${output}  443/tcp open  Port 443 on BTS is not open after expected time
    ELSE IF  '${ping}'=='negative'
        Should Not Contain  ${output}  443/tcp open  Port 443 on BTS is still open after expected time
    END


SW Package Delete
    [Documentation]  Cleanup action for KW: Download Expected SW Package.
    ...  **Author:** tomasz.marchewka@nokia.com

    Run  sudo rm -r ${SW_PACKAGE_DESTINATION}
    Log  SW package has been deleted  console=${true}

Get Active Partition
    [Documentation]  Keyword returns active partition.
    ...  **Author:** tomasz.marchewka@nokia.com

    ssh.connect_to  hostname=${MSM_IP}  username=${ENB_ROOT_USER}  password=${ENB_ROOT_PASS}
    ssh.send command  command=uboot_env get active_partition
    ${output}  ssh.read output
    ${active_partition_id}  Get Regexp Matches  ${output}  \\d+
    ${active_partition_id}  Convert To Integer  ${active_partition_id[0]}
    ssh.Disconnect

    RETURN  ${active_partition_id}


Set Feature On Expected Value
    [Documentation]  This keyword check if feature have expected value if no, this keyword change it.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Set Feature On Expected Value  parameter=actAldSwUpdate  value=true
    [Arguments]  ${parameter}  ${value}

    ${feature_list}  admin.get managed objects  FEATCADM_A
    FOR  ${ITEM}  IN  @{feature_list}
        ${feature_status}  Set Variable If  '${ITEM['parameters']['${parameter}']}'=='${True}'  true
    END
    IF  '${value}'=='true' and '${feature_status}'=='true'
        Log  Parameter ${parameter} is set on: ${feature_status}  console=${true}
    ELSE IF  '${value}'=='true' and '${feature_status}'!='true'
        Log  Parameter ${parameter} is set on: false. Expected value: true. => Featrue activation.  console=${true}
        Turn ON Or OFF Feature  ${parameter}  ${value}
    ELSE IF  '${value}'=='false' and '${feature_status}'=='true'
        Log  Parameter ${parameter} is set on: true. Expected value: false. => Feature deactivation.  console=${true}
        Turn ON Or OFF Feature  ${parameter}  ${value}
    ELSE
        Log  Parameter ${parameter} is set on: false  console=${true}
    END

    RETURN  ${feature_status}


Turn ON Or OFF Feature
    [Documentation]
    [Arguments]  ${parametr}  ${value}

    ${FEATCADM_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    admin.perform parameter recommissioning  ${FEATCADM_DN}  ${parametr}  update  ${value}  ${SKIP_PARAMETER_RELATION_ERRORS}


Set Timezone
    [Documentation]  Change timezone via recommissioning
    ...  **Example of simple usage:**
    ...  Set Timezone  (GMT+2) Europe/Bucharest
    [Arguments]  ${expected_timezone}

    Log  Set timeZone to ${expected_timezone} (restart needed)  console=${true}
    ${sw_splited}  Split String  ${active_sw_version}
    ${sw_prefix}  Get From List  ${sw_splited}  0
    ${contains}  Evaluate  "FSM3" in """${sw_prefix}"""
    ${sw_prefix_short}  Get Substring  ${sw_prefix}  0  6
    ${TIME_DN}  Set Variable If  '${sw_prefix_short}'=='SBTS24'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...  '${sw_prefix_short}'!='SBTS24' and '${contains}'=='True'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...  '${sw_prefix_short}'!='SBTS24' and '${contains}'=='False'  MRBTS-${MRBTS_ID}/MNL-1
    #${TIME_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    admin.perform parameter recommissioning  ${TIME_DN}  timeZone  update  ${expected_timezone}  ${SKIP_PARAMETER_RELATION_ERRORS}  timeout=600


Get BTS Timezone
    ${timezone}  admin.get bts time zone

    RETURN  ${timezone}


Perform RAT Reset
    [Documentation]  This keyword performs RAT reset procedure.
    ...  **Example of simple usage:**
    ...  Perform RAT Reset  rat_type=WCDMA  timeout=300  #rat_type=5G/LTE/WCDMA/GSM
    ...
    [Arguments]  ${rat_type}  ${timeout}

    Log To Console  ${rat_type} rat reset...
    admin.rat reset  rat_type=${rat_type}  timeout=${timeout}


Block Selected Cell
    [Arguments]  ${cell_dn}  ${timeout}

    ${cell_r}  Get Regexp Matches  ${cell_dn}  (GN|WN|LN|NR)CE(L|LL)_R-\\d+
    Log To Console  Blocking ${cell_r[0]}...
    admin.block cell  dist_name=${cell_dn}  timeout=${timeout}


Unblock Selected Cell
    [Arguments]  ${cell_dn}  ${timeout}

    ${cell_r}  Get Regexp Matches  ${cell_dn}  (GN|WN|LN|NR)CE(L|LL)_R-\\d+
    Log To Console  Unblocking ${cell_r[0]}...
    admin.unblock cell  dist_name=${cell_dn}  timeout=${timeout}


Block All Cells
    [Arguments]  ${rat}  ${timeout}

    Log To Console  Blocking all ${rat} cells...
    admin.block all cells  rat=${rat}  timeout=${timeout}


Unblock All Cells
    [Arguments]  ${rat}  ${timeout}

    Log To Console  Unblocking all ${rat} cells...
    admin.unblock all cells  rat=${rat}  timeout=${timeout}


Detect RATs
    ${bts_info}  admin.get bts info
    ${rats}  Create List
    FOR  ${rat}  IN  @{bts_info['ratState']}
        IF  '${bts_info['ratState']['${rat}']}'=='ALL_ENABLED'  Append To List  ${rats}  ${rat}
    END

    RETURN  ${rats}


Get BTS Name
    ${bts_info}  admin.get bts info
    ${bts_name}  Get From Dictionary  ${bts_info}  name

    RETURN  ${bts_name}


######################
### RESER COUNTERS ###
######################


Get Reset Counter From Blackbox
    [Documentation]  Keyword returns actual reset counter number from blackbox file.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${host}=toor4nsn@${MSM_IP}  ${COLLECT_BLACKBOX_FILE}=${False}  ${iteration}=none

    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${active_partition}  Get Active Partition
    ${connect_to_bts}  Set Variable  sshpass -p ${ENB_ROOT_PASS} ssh ${host}
    #${blackbox_path}  Set Variable  /ffs/fs${active_partition}/config/lifedata/blackbox
	${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    ${sw_prefix2}  Get From List  ${sw_splited}  1
    Set Test Variable  ${sw_prefix}
    IF  '${sw_prefix}'=='SBTS24R2'
        ${blackbox_path}  Set Variable  /ffs/fs${active_partition}/config/lifedata/blackbox
    ELSE IF  '${sw_prefix}'=='SBTS24R3'
        ${blackbox_path}  Set Variable  /ffs/fs${active_partition}/config/lifedata/blackbox
    ELSE IF  '${sw_prefix}'=='SBTS25R1'
        ${blackbox_path}  Set Variable  /ffs/fs${active_partition}/config/lifedata/blackbox
    ELSE IF  '${sw_prefix2}'=='FSM3'
        ${blackbox_path}  Set Variable  /ffs/fs${active_partition}/config/lifedata/blackbox
    ELSE
        ${blackbox_path}  Set Variable  /ffs/fs${active_partition}/logs/lifetimedata/blackbox
    END
    ${cat_command}  Set Variable  cat ${blackbox_path}
    ${blackbox_txt}  Run  ${connect_to_bts} ${cat_command}
    ${regex}  Set Variable  (?i)(RESET\\sCOUNTER:\\s(?P<reset_counter_number>\\d+))
    ${reset_counter_number}  Get Regexp Matches  ${blackbox_txt}  ${regex}  reset_counter_number
    ${reset_counter_number}  Convert To Integer  ${reset_counter_number[0]}
    Log To Console  RESET COUNTER: ${reset_counter_number}
    IF  ${COLLECT_BLACKBOX_FILE}==${True} and '${iteration}'!='none'
        Append To File  ${RESULTS}/${iteration}/blackbox_${timestamp}.txt  ${blackbox_txt}
    ELSE IF  ${COLLECT_BLACKBOX_FILE}==${True} and '${iteration}'=='none'
        Append To File  ${RESULTS}/blackbox_${timestamp}.txt  ${blackbox_txt}
    END

    RETURN  ${reset_counter_number}

# below keywords returning as output configuration IDs

Get RMODs
    ${bts_info}  admin.get bts info
    ${rmods}  Create List
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        Append To List  ${rmods}  ${item['id']['configuration']}
    END
    Set Test Variable  ${rmods}
