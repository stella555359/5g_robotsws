
*** Settings ***
Library         String
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         Collections
Library         Selenium2Library
Library         DateTime
Library         XML  use_lxml=true
Library         taf.sw.syslog   WITH NAME   taf_syslog
Library         taf.sw.reporting_portal
Library         ute_pdu
Library         taf.nms.netact  WITH NAME  netact
Library         taf.nms.nom  WITH NAME  nom
Library         taf.sbts.oam.coam.admin  WITH NAME  admin
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi_calculations
Library         taf.sw.scout  WITH NAME  scout
Library         ../resources_mem/python_lib/time_verdict.py
Library         ../resources_mem/python_lib/utilities.py
Library         ../resources_mem/python_lib/tool_ping.py
Library         ../resources_mem/python_lib/LogFilesLibrary.py
Library         ../resources_mem/python_lib/cloud_uuf_keywords.py
Library         ../../common_resources/scfchecker/EECheck.py
Library         ../resources_mem/python_lib/suite_utils.py
Library         taf.rfrl.common_resources.reporting_portal.bts_metadata
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        ../resources_mem/snapshot_collector.robot
Resource        ../resources_mem/netact.robot
Resource        ../resources_mem/apc.robot
Resource        ../resources_mem/memory.robot
Resource        ../resources_mem/cbrs.robot
Resource        ../resources_mem/watchdog_cloud.robot
Resource        ../resources_mem/ocp_logs_collector/ocp_logs_collector.robot
Resource        ../resources_mem/LCM_operator/LCM_operator.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot

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
...  08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-335 - add KWs "Configuration Reset With HWF", "Get BTS Platform", and "Get SMOD Variant"
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
...  29.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-568 - Rework "Detect RATs" KW to exclude only RATs without any cells
...  08.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-567 - improve "Set Parameter To Expected Value" to support managed objects dist_name
...                                                                 with one "/" (for example MRBTS-${MRBTS_ID}/LNBTS-101003)
...  22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-565 - Add KWs "RMOD Chain Detection", "Map RMOD To Chain Index",
...  "Get RMOD Chain Position", "Find Cablinks In Chain For Specified RMOD" and "Find Cablinks Related To RMOD"
...  30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-575 - Rework KW "Resolve Locked Cells Group" to consider locked cells not disabled cells
...  24.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-585 - Rework KWs "Check If NLWG Cells Are OnAir" and
...  "Check LNCEL/NRCELL OnAir Or EnergySaving State" to work with concurrent mode testline
...  21.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-595 - Add KW "Set shutdownWindow To Be Not Higher Than Preferred Value"
...                                                                 under "Common Suite Setup"
...  06.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-602 - Add KW "Get RESET_HISTORY Timestamp"
...  06.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-603 - Add KWs "Get RUs Supporting ${wanted_feature}", "Get RUs Parameters Values",
...                                                                 "Compare RUs upTime And resetCounter" and "Ensure Managed Objects Are Created"
...  23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-610 - Rework and rename KW "Compare RUs upTime And resetCounter" to "Compare RUs upTime"
...  30.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-611 - Add new KW "Disable BTSLog On VM" under "Common Suite Setup"
...  10.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-609 - Add new KW "Turn off deepsleep single 5G RU"
...                                                                 and update KW "Run keyword except for FSMF"
...  19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-618 - Add new KWs "BBMOD Mapping" and "Get Resettable BBMOD"; small enhancements to KWs
...                                                               "Check SMODs State", "Check BBMODs State", "Check RMODs State" and "Check BTS State"
...  07.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAW-621 - Rework KW "Common Suite Setup" to support automated NetAct lab selection in
...                                                                 reworked KW "Workaround For Empty NETACT_ID"
...  20.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAW-619 - Add ne KW - Check if BBMOD is connected to RMOD, Verifies if the specified BBMOD
...                                                                 is connected to the provided RMOD.
...  03.02.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-15694 - quickfix for KW "Get Reset Counter From Blackbox" due to CNI-93026
...  11.02.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-14200 - Ignore IoT cell during PS and check if IoT host cell is in PS
...  10.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-16404 - Add KW "Resolve Blocked Rat"
...  21.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-17426 - ADD KWs "Images Onboarding", "Create CCR Certs On Core"
...                                                                           and "Login To CCR"
...  07.04.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-17667 - ADD KWs "Common Test Setup Cloud" and "Common Test Teardown Cloud"
...  06.05.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-17663 - Inject Registry into Values-Override_CLOUD
...  06.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23345 - Rework keywords for NetAct integration:
...                                                                           modify "Common Suite Setup" and "Common Test Setup"
...  06.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23345 - Rework keywords for NetAct integration:
...                                                                           modify "Common Suite Setup" and "Common Test Setup"
...  08.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22171 - Modify "Generate and Send Configuration ID to ReP"
...  08.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-25621 - Modify KW "Resolve Blocked Rat"
...  02.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26870 - Modify KWs "Get memory usage for unit" and "Check Memory Usage On FHS"
...  16.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23885 - Modify KW "Remove Existing Charts"
...  26.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22855 - Add KW "Get RMODs Connected To BBMOD Through FHS" and add ${BTS_NAME}
...                                                                           to "Get Configuration Details" as suite variable
...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-32760 - Remove CBRS related keywords from test suits after 101001 relocation
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${VM_UTE_LOGIN}=  ute
${VM_UTE_PASS}=  uteUTE!
${IAV_WCDMA}  //burak2.intra.noklab.net/IAV_WCDMA
${Glo_Ver}  //burak2.intra.noklab.net/Global_veryfication
${IAV_WCDMA_path}  /media/IAV_WCDMA
${Glo_Ver_path}  /media/Global_veryfication
${ENB_ROOT_USER}=  toor4nsn
${ENB_ROOT_PASS}=  oZPS0POrRieRtu
${MSM_IP}=  192.168.255.129
${ESM_IP}=  192.168.255.119
${UNIT_USER}=   serviceuser
${UNIT_PASS}=   Pl(FzaYj5~c5;q
${SKIP_PARAMETER_RELATION_ERRORS}=  True
${SHOULD_ACTIVATE}=  True
@{UDP ports}=  51000  51001  51003  50011
${BTS_expected_states}=                 proceduralState=regex"(?i)OnAir", blockingState=regex"(?i)Unblocked"
${BTS_expected_state_notCommissioned}=  proceduralState=regex"(?i)NotCommissioned"
${SMOD_expected_states}=                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${BBMOD_expected_states}=               administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${RMOD_expected_states}=                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${ALD_expected_states}=                 administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${GSM_expected_state}=                  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                     blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${WCDMA_expected_state}=                operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...                                     usageState=regex"(?i)Active"
${LTE_expected_state}=                  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                     blockingState=regex"(?i)Unblocked"
${NR_expected_state}=                   administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                     blockingState=regex"(?i)Unblocked"
${LTE_ps_expected_state}=               administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled",
...                                     blockingState=regex"(?i)Unblocked", energySavingState:regex"(?i)energySaving",
${NR_ps_expected_state}=                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled",
...                                     blockingState=regex"(?i)Unblocked", energySavingState:regex"(?i)energySaving",
${sw_server}=   https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local
${lterel}=  https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${artifactory}=  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${SW_PACKAGE_DESTINATION}  /tmp/SW_package
@{recomended_flags}=  0x1003F=1  0x10040=1  0x10041=5  0x19000A=1  0x480008=1  0x30000F=1  0x1A0020=1  0x200B5=1
...  0x45005A=1  9=1  0x300000=1  0x300001=1  0x30001C=1  0x1A0000=1  0x420000=1  0x480000=1  0x480014=1  0x48001A=1
...  0x480018=1  0x500000=1  0x450000=1
@{recomended_flags_ald}=  0x1003F=1  0x10040=1  0x10041=5  0x19000A=1  0x480008=1  0x30000F=1  0x1A0020=1  0x200B5=1
...  0x45005A=1  9=1  0x300000=1  0x300001=1  0x30001C=1  0x1A0000=1  0x420000=1  0x480000=1  0x480014=1  0x48001A=1
...  0x480018=1  0x500000=1  0x450000=1  0x48001B=1  317=1  245=2  252=2
@{recomended_flags_mem}=  0x1003F=1  0x10040=1  0x10041=5  0x19000A=1  0x480008=1  0x30000F=1  0x1A0020=1  0x200B5=1
...  0x45005A=1  9=1  0x300000=1  0x300001=1  0x30001C=1  0x1A0000=1  0x420000=1  0x480000=1  0x480014=1  0x48001A=1
...  0x480018=1  0x500000=1  0x450000=1  0x100A9=60  0x100AC=4194304
${fix_cmd}  kubectl get node | grep -v NAME | awk '{print $1}' | xargs -I {} ssh -o StrictHostKeyChecking=no  {}
...         "cat /etc/inputrc | grep 'set enable-bracketed-paste off' ||
...         echo 'set enable-bracketed-paste off' | sudo tee -a /etc/inputrc"

*** Keywords ***

###################
### SUITE SETUP ###
###################

Common Suite Setup
    [Arguments]  ${ute_admin_alias}=default
    Check Disk Space    PATH=/home/ute/test_results   SPACE_MB=2048    #2GB
    Custom Robot Log Level
    Verify VM Time Zone
    Set init Variables
    Mount Burak Network Drive
    Disable BTSLog On VM
    Start Test Suite Time
    Set Suite Variable  ${INTEGRATED_TO_NETACT}  ${FALSE}
    ${INTEGRATE_NETACT}  Get Variable Value  ${INTEGRATE_NETACT}
    ${INTEGRATE_NETACT}  Evaluate  str(${INTEGRATE_NETACT}).upper()=='TRUE'
    Set Suite Variable    ${INTEGRATE_NETACT}
    Set Suite Variable    ${ute_admin_alias}    default
    Setup Admin    admin_api_log_dir=/home/ute/test_results/admin_api/suite_setup
    Wait Until Keyword Succeeds  30s  10s  Get Configuration Details
    Run Keyword If  ${INTEGRATE_NETACT}  Run Keywords
    ...           Run Keyword And Ignore Error  Workaround For Empty NETACT_ID
    ...    AND    Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${NETACT_ID}.py
    ${NETACT_ID_value}  Get Variable Value  ${NETACT_ID}
    Run Keyword If  '${NETACT_ID_value}'=='None' and ${INTEGRATE_NETACT}
    ...              Run Keywords  Log  NetAct integration will be skipped  WARN
    ...                       AND  Set Suite Variable  ${INTEGRATE_NETACT}  ${FALSE}
    Set Radio Memory Threshold    40%    PLANS_DIR=/home/ute/test_results/suite_setup/plans
    Set shutdownWindow To Be Not Higher Than Preferred Value
    admin.Teardown Admin  alias=${ute_admin_alias}
    Check EE Activation Feature On BTS

Start Test Suite Time
    ${start_suite_time}  Get Current Time
    Set Suite Variable  ${start_suite_time}

Verify Suite Duration
    [Documentation]  Keywords returns if the test suite duration limit has been reached.
    [Arguments]  ${timeout_in_hours}
    ${now}  Get Current Time
    ${verdict}  Check Suite Duration  ${start_suite_time}  ${now}  ${timeout_in_hours}
    [Return]  ${verdict}

##################
### TEST SETUP ###
##################

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
    Run Keyword If  ${status_admin} and ${status_syslog}  Run Keywords
    ...  Log  ============= PRECONDITIONS CHECK =============  console=${true}
    ...  AND  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
#	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
	...  AND  Log  =========== PRECONDITIONS CHECK OK ============  console=${true}
    alarms.Start Watchdog  ${skip_fault}
    ${INTEGRATE_NETACT}  Get Variable Value  ${INTEGRATE_NETACT}
    ${INTEGRATE_NETACT}  Evaluate  str(${INTEGRATE_NETACT}).upper()=='TRUE'
    Set Test Variable    ${INTEGRATE_NETACT}
    Set Test Variable    ${INTEGRATED_TO_NETACT}  ${FALSE}
    Run Keyword If  ${INTEGRATE_NETACT}  Run Keywords
    ...           Run Keyword And Ignore Error  Workaround For Empty NETACT_ID
    ...    AND    Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${NETACT_ID}.py
    ${NETACT_ID_value}  Get Variable Value  ${NETACT_ID}
    Run Keyword If  '${NETACT_ID_value}'=='None'
    ...             Set Test Variable  ${INTEGRATE_NETACT}  ${FALSE}
    ...       ELSE  Set Test Variable  ${INTEGRATE_NETACT}  ${INTEGRATE_NETACT}
    Run Keyword If  not ${INTEGRATE_NETACT}
    ...             Log  NetAct integration will be skipped  WARN
    Mount Burak Network Drive
#    Run Keyword And Ignore Error  DCAP Syslog Setup
    Check SCF Errors
    Set Dist Name For Objects
    Log  =========== COMMON TEST SETUP DONE ============  console=${true}

Common Test Setup - MEMORY
    [Documentation]  Set of actions which will be executed before each of test.
    Log  \n\n============== COMMON TEST SETUP ==============  console=${true}
    Check Disk Space    PATH=/home/ute/test_results   SPACE_MB=2048    #2GB
    Create Log Directory
    Set Suite Variable    ${ute_admin_alias}    default
    Set Test Variable  ${TEST_SUITE_TEST_NAME}  ${TEST_NAME}
#    Check SCF Errors
    Log  =========== COMMON TEST SETUP DONE ============  console=${true}

Check Disk Space
    [Documentation]  Keyword checks if there is at least the specified amount (in MB) of free disk space in given path.
    [Arguments]    ${PATH}=/home/ute/test_results   ${SPACE_MB}=2048
    ${free_space}    Run    df -BM --output=avail ${PATH} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${free_space}<${SPACE_MB}
    ...  Fatal Error  ${free_space}MB available in ${PATH} - expected at least ${SPACE_MB}MB

Custom Robot Log Level
    ${req_change}  Run Keyword And Return Status  Variable Should Exist  ${SET_LOGLEVEL}
    Run Keyword If  '${SUITE NAME}'=='memory' or '${SUITE NAME}'=='memory SMOD BBMOD' and not ${req_change}
    ...    Run Keyword  Set Custom Log Level  INFO    #ZTR
    ...    ELSE IF  ${req_change}  Set Custom Log Level  ${SET_LOGLEVEL}

Verify VM Time Zone
    [Arguments]  ${timezone}=Poland
    ${verdict}=  Run Keyword And Return Status  Check VM Time Zone  ${timezone}
    Run Keyword If  not ${verdict}  Run Keywords
    ...  Set VM Time Zone  ${timezone}
    ...  AND  Check VM TimeZone  ${timezone}

Set VM Time Zone
    [Arguments]  ${expected_timezone}
    ${regex}=  Set Variable  Time zone:\\s(?P<timezone>[a-zA-Z/]*)\\s\\((?P<time>.*)\\)
    ${timedatectl}=  Run  timedatectl
    ${result}=  Get Regexp Matches  ${timedatectl}  ${regex}  timezone  time
    ${timezone}  ${time}=  Set Variable  ${result[0]}
    Run Keyword If  '${timezone}'!='${expected_timezone}'  Run Keywords
    ...  Log To Console  Changing VM time zone: ${timezone} to ${expected_timezone}
    ...  AND  Run  sudo timedatectl set-timezone "${expected_timezone}"
    ...  AND  Sleep  70s

Check VM Time Zone
    [Arguments]  ${expected_timezone}
    ${regex}=  Set Variable  Time zone:\\s(?P<timezone>[a-zA-Z/]*)\\s\\((?P<time>.*)\\)
    ${timedatectl}=  Run  timedatectl
    ${result}=  Get Regexp Matches  ${timedatectl}  ${regex}  timezone  time
    ${timezone}  ${time}=  Set Variable  ${result[0]}
    Should Be True  '${timezone}'=='${expected_timezone}'

Restart NTP Synchronization On VM
    [Arguments]  ${regex}=(?P<Active>.+Active: )(?P<status>.+)
    Add VM NTP Servers
    Run  sudo timedatectl set-ntp yes
    Run  sudo systemctl start ntp
    Log To Console  Waiting 60s
    Sleep  60s
    ${sync_status}  Run  sudo service ntp status | grep Active
    ${result}  Get Regexp Matches  ${sync_status}  ${regex}  status
    Log To Console  VM NTP server status: ${result[0]}

Add VM NTP Servers
    [Arguments]  ${ntp.conf}=/etc/ntp.conf
    Run  sudo chmod 777 ${ntp.conf}
    Run  echo 'server 10.42.129.251 iburst' >> ${ntp.conf}
    Run  echo 'server 10.42.162.252 iburst' >> ${ntp.conf}
    Run  echo 'server 10.42.248.70 iburst' >> ${ntp.conf}

Get Adjusted Timestamp
    [Arguments]  ${time_offset}
    ${curr_timestamp}    Get Current Date    result_format=%Y%m%dT%H%M%SZ
    ${timestamp_adjusted}    Subtract Time From Date    ${curr_timestamp}    ${time_offset}    result_format=%Y%m%dT%H%M%SZ
    [Return]    ${timestamp_adjusted}

Set init Variables
    ${TESTLINE_NAME}    Evaluate   "${CONFIGURATION}".split(".")[1]
    Set Suite Variable    ${TESTLINE_NAME}
    Set Suite Variable    ${TOPOLOGY}       ${tl.tl_cloud_topology}
    Set Suite Variable    ${ENB_MPLANE_IP}  ${tl.enbs[0].oam_ip.v4}
    ${enb_qty}    Get Length    ${tl.enbs}
    Run Keyword If    '${enb_qty}'=='${1}'
    ...           Set Suite Variable    ${VM1_IP}     ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...    ELSE IF    '${enb_qty}'=='${2}'    Run Keywords
    ...           Set Suite Variable    ${VM1_IP}     ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...    AND    Set Suite Variable    ${VM2_IP}     ${tl.test_pcs[1].default_ssh_connection_details.addr}
    Set Suite Variable  ${enb_qty}  ${enb_qty}

Create Log Directory
    [Arguments]    ${test_results}=/home/ute/test_results
    ${now}    Run    date +%F_%H-%M-%S
    ${TEST_NAME}    Evaluate    '${TEST_NAME}'.replace(' ','_')
    ${LOG_DIR}   Join Path    ${test_results}  ${now}_${TEST_NAME}
    Create Directory    ${LOG_DIR}
    Set Test Variable    ${RESULTS}  ${LOG_DIR}
    Log To Console    Test result path: ${RESULTS}

Get Configuration Details
    [Documentation]  Shows actual configuration on ENB basing on config files
    ...              Author: krystian.gordziejewski@nokia.com
    ...              EDIT: Refactored to avoid obsolete-to-be infomodel library - Author: artur.lebek@nokia.com
    ...              EDIT: Add more parameters - Author: tomasz.marchewka@nokia.com
    [Arguments]  ${ute_admin_alias}=default
    ${bts_info}=  admin.get bts info  connection=${ute_admin_alias}
    Set Suite Variable  ${ACTIVE_SW_VERSION}  ${bts_info['swInfo']['swVersion']}
    ${regex}=  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)_(ENB|FSM3)_(?P<version>\\d{4})
    ${result}=  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  product  postfix
    ${result_version}=  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  version
    ${product}  ${postfix}=  Set Variable  ${result[0]}
    ${product}=  Convert To Uppercase  ${product}
    ${postfix}=  Convert To Uppercase  ${postfix}
    Set Suite Variable  ${SW_TYPE}  ${product}${postfix}
    Run Keyword If  '${result_version[0]}'=='0000'  Set Suite Variable  ${RELEASE}  ${SW_TYPE}
    ...    ELSE IF  '${result_version[0]}'=='9999'  Set Suite Variable  ${RELEASE}  SBTS00
    Set Suite Variable  ${MRBTS_ID}  ${bts_info['mrbtsID']}
    Set Suite Variable  ${BTS_NAME}  ${bts_info['name']}
    Run Keyword And Ignore Error  Set Suite Variable  ${NRBTS_ID}  ${bts_info['nrBtsId']}
    Get BTS Platform
    ${rats}  Detect RATs
    Set Suite Variable  ${rats}
    Log  Common Module Composition: ${SMOD_COMPOSITION}  console=${true}
    Log  MRBTS ID: ${MRBTS_ID}  console=${true}
    Log  BTS name: ${BTS_NAME}  console=${true}
    Log  Active Software Version: ${ACTIVE_SW_VERSION}  console=${true}
    Log  Testline: ${TESTLINE_NAME}  console=${true}
    Log  Topology: ${TOPOLOGY}  console=${true}

Get BTS Platform
    ${fcmVariant_list}  Get SMOD Variant
    ${SMOD_qty}  Get Length  ${fcmVariant_list}
    ${BTS_TYPE}  Run Keyword If  '${SMOD_qty}'=='${1}'  Set Variable  singlecore
    ...                 ELSE IF  '${SMOD_qty}'=='${2}'  Set Variable  dualcore
    ${smod_composition}  Run Keyword If  '${SMOD_qty}'=='${1}'  Set Variable  ${fcmVariant_list}[0]
    ...                         ELSE IF  '${SMOD_qty}'=='${2}'  Set Variable  ${fcmVariant_list}[0]+${fcmVariant_list}[1]
    Set Suite Variable  ${BTS_TYPE}
    Set Suite Variable  ${SMOD_COMPOSITION}

Get SMOD Variant
    ${SMOD_info}=  admin.Get Parameters For All  SMOD
    ${fcmVariant_list}  Create List
    FOR  ${SMOD}  IN  @{SMOD_info}
        ${fcmVariant}  Evaluate  '${SMOD['fcmVariant']}'.replace(' ','')
        Append To List  ${fcmVariant_list}  ${fcmVariant}
    END
    [Return]  ${fcmVariant_list}

Mount Burak Network Drive
    [Documentation]  This keyword mount network drive: IAV_WCDMA and Global_veryfication on VM.
    ...  **Author:** tomasz.marchewka@nokia.com
    Run  sudo mkdir /media/IAV_WCDMA
    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=sranwro6,password=wro6pass,domain=noklab,users,nounix ${IAV_WCDMA} ${IAV_WCDMA_path}
    Run  sudo mkdir /media/Global_veryfication
    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=plwr4gsfe,password=ltesfe4@,domain=noklab,users,nounix ${Glo_Ver} ${Glo_Ver_path}

Setup Syslog
    [Arguments]  ${log_dir}=${RESULTS}/syslog
    ${results}=    Run Process    ${CURDIR}/killSyslog.sh    shell=True    stdout=PIPE    stderr=PIPE
    Log    ${results.rc}
    Run Keyword And Ignore Error  taf_syslog.Teardown All Aliases For Syslog
    Wait Until Keyword Succeeds  5m  30s  taf_syslog.start syslog  log_dir=${log_dir}  log_name=SYSLOG.log  file_limit=104857600  # 100MB
    ...  add_line_number=True  alias=taf_syslog

Setup Admin
    [Arguments]  ${admin_api_log_dir}=${RESULTS}/admin_api/    ${ute_admin_alias}=default
    Run Keyword And Ignore Error  Teardown Admin  alias=${ute_admin_alias}
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_api_log_dir}    update_interval=500    alias=${ute_admin_alias}
    Set Suite Variable  ${ute_admin_alias}  default

Setup Admin - Concurrent
    [Arguments]  ${admin_api_log_dir}=${RESULTS}/admin_api_concurrent/    ${alias}=concurrent
    Run Keyword And Ignore Error  Teardown Admin  alias=${alias}
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  bts_host=10.42.20.163  admin_api_log_dir=${admin_api_log_dir}
    ...    update_interval=500  alias=${alias}

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
    Run Keyword If  ${status}  Run Keywords
    ...  Log  Adding swconfig flag: ${flag}  console=${true}
    ...  AND  Execute SSH Command On BTS  command=echo ${flag} >> /rom/swconfig.txt
    ...  AND  Execute SSH Command On BTS  command=crasign /rom/swconfig.txt
    ...  AND  admin.reset site  timeout=700
	...  AND  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir

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
    [Return]  ${msg}

Turn ON BTS And Wait Until OnAir
    Log  \n\n============== BTS SWITCHING ON AND WAIT UNTIL ONAIR ==============  console=${true}
    APC Control  ON  ALL
    Check If SMOD Is Pingable  wait_time=1min
    Full Check After Start-up
    Log  \n\n=========== BTS SWITCHING ON AND WAIT UNTIL ONAIR - DONE ==========  console=${true}

Turn ON BTS
    ${if_bts_on}  Run Keyword And Return Status  Check If SMOD Is Pingable  wait_time=30s
    Run Keyword If  not ${if_bts_on}  Turn ON BTS And Wait Until OnAir

Turn OFF BTS
    Log  \n\n============== BTS SWITCHING OFF ==============  console=${true}
    APC Control  OFF  ALL
    Log  \n\n=========== BTS SWITCHING OFF - DONE ==========  console=${true}

DCAP Syslog Setup
    ${graceful_cell_test}  Run keyword and return status  Should Contain  ${TEST_NAME}  Graceful  ignore_case=True
    Run Keyword If  not ${graceful_cell_test}  Run keywords
    ...       dcap.Start DCAP on UTE VM
    ...  AND  dcap.DCAP Start tracing eNB

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

### Setup CBRS ###
Setup CBRS certificates and SAS simulator
    ${CBRS_alias}    Set Variable     CBRS_alias
    ${CBRS_admin_log_path}    Set Variable     /home/ute/test_results/CBRS_admin_log_path/
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${CBRS_admin_log_path}   update_interval=500  alias=${CBRS_alias}
    Log to console      ==Setup CBRS certification and start SAS simulator==
    Get SAS Gerrit Repository
    Setup OpenSSL Certifier
    Prepare And Install CBRS Certificates on BTS    alias=${CBRS_alias}
    Prepare And Install Certificates on SASSim
    Start SAS Process
    Check If NLWG Cells Are OnAir
    admin.teardown admin    alias=${CBRS_alias}

#####################
### TEST TEARDOWN ###
#####################

Common Suite Teardown
    Setup Admin    admin_api_log_dir=/home/ute/test_results/admin_api/suite_teardown
    Set Radio Memory Threshold    50%    PLANS_DIR=/home/ute/test_results/suite_teardown/plans
    admin.Teardown Admin  alias=${ute_admin_alias}

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
#    Run Keyword And Ignore Error  DCAP Syslog Teardown
    [Teardown]  Teardown Admin  alias=${ute_admin_alias}
    Log  ========== COMMON TEST TEARDOWN DONE ==========\n  console=${true}

Common Test Teardown - MEMORY
    [Documentation]  Set of actions which will be executed after each of test.
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Log  \n============ COMMON TEST TEARDOWN =============  console=${true}
    ${STOP_AND_FIX}  Run Keyword And Return Status  Variable Should Exist  ${CRITICAL_FAULT_DETECTED}
    Run Keyword If  ${STOP_AND_FIX}  Collect Snapshot File  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword And Ignore Error  interface.Common step trigger
    Run Keyword And Ignore Error  Move Logs To Burak
    Run Keyword And Ignore Error  Generate and Send Configuration ID to ReP
#    Run Keyword And Ignore Error  DCAP Syslog Teardown
    [Teardown]  Run Keyword If  ${CONCURRENT}  Run Keywords
    ...  admin.Teardown Admin  alias=${ute_admin_alias}  AND  admin.Teardown Admin  alias=concurrent
    ...  ELSE  admin.Teardown Admin  alias=${ute_admin_alias}
    Log  ========== COMMON TEST TEARDOWN DONE ==========\n  console=${true}

Collect Snapshot File
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=False
    Log  Snapshot collecting  console=${true}
    ${timestamp}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SNAPSHOT_PATH}=  Set Variable  ${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}_${timestamp}.zip
    Run Keyword And Ignore Error  Collect Snapshot  target_file_name=${SNAPSHOT_PATH}  timeout=1500
    Run Keyword And Ignore Error  Run Keyword If  ${SEND_SNAPSHOT_FOR_SCRAMBLING}==${True}
    ...  Check and Send Snapshot to Server CLASSICAL TRSSEC  snapshot_path=${SNAPSHOT_PATH}

Collect Syslog Files
    [Arguments]    ${destination}=${RESULTS}/syslog/syslog.tar.gz
    Log  Syslog collecting  console=${true}
    taf_syslog.Collect Syslog Results  destination=${destination}  unzip=False  alias=taf_syslog
    [Teardown]  taf_syslog.Teardown All Aliases For Syslog

Collect Swconfig File
    Log  swconfig collecting  console=${true}
    ssh.Connect to    ${MSM_IP}    ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
    ssh.Download File    /ffs/run/swconfig.txt    ${RESULTS}/swconfig.txt
    [Teardown]    ssh.Disconnect

Collect RawAlarmHistory Files
    Log  RawAlarmHistory collecting  console=${true}
    ssh.Connect to   ${MSM_IP}    ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
    ssh.Download File    /tmp/RawAlarmHistory.txt    ${RESULTS}/RawAlarmHistory.txt
    [Teardown]    ssh.Disconnect

Swconfig Validator
    [Arguments]  ${swconfig_path}
    Log  swconfig flag validating  console=${true}
    ${SMOD_flags}=  Create List
    ${var}=  OperatingSystem.Get File  ${swconfig_path}
    @{var_list}=  Split To Lines  ${var}
    FOR  ${item}  IN  @{var_list}
        ${flag}=  Get Variable Value  ${item}
        ${flag}=  Evaluate  '${flag}'.replace(' ','')
        ${status}  ${flag}=  Run Keyword And Ignore Error  Should Match Regexp  ${flag}  ^\\d+[a-zA-Z0-9\.]*=\\d+
        Run Keyword If  '${status}'=='PASS'  Append To List  ${SMOD_flags}  ${flag}
    END
    ${warn_flags}=  Create List
    FOR  ${item}  IN  @{SMOD_flags}
        ${status}  ${msg}=  Run Keyword And Ignore Error  List Should Contain Value  ${recomended_flags}  ${item}
        Run Keyword If  '${status}'=='FAIL'  Run Keywords
        ...  Log  Flag: ${item} is not in recommended swconfig.txt  WARN
        ...  AND  Append To List  ${warn_flags}  ${item}
    END
    ${qty}=  Get Length  ${warn_flags}
    Run Keyword If  ${qty}==${0}
    ...  Log  On BTS there is no unexpected flag(s)  console=${true}
    ...  ELSE IF  ${qty}>${0}
    ...  Log  ${qty} unexpected flag(s) found  console=${true}

Move Logs To Burak
    [Arguments]    ${source}=${RESULTS}
    ${date}=  DateTime.Get Current Date  result_format=%d%m%Y  exclude_millis=True
    ${destination}=  Set Variable  /media/Global_veryfication/UTE_logs/${MRBTS_ID}/${date}/${RELEASE}
    Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  mkdir -p ${destination}
    ${status}  ${rc_and_output}  Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  cp -r ${source} ${destination}
    ${folder_name}  Evaluate  '${source}'.split('/')[-1]
    Run Keyword If  '${rc_and_output}[0]'=='${0}'  Run Keywords  Log To Console  Logs moved to ${destination}/${folder_name}
    ...    AND    Run  rm -r ${source}

Move TEF Logs To Burak
    ${TEST_NAME}=  Evaluate  '${TEST_NAME}'.replace(' ','_')
    ${date}=  DateTime.Get Current Date  result_format=%d%m%Y  exclude_millis=True
    ${destination}=  Set Variable  /media/Global_veryfication/UTE_logs/${MRBTS_ID}/${date}/${TEST_NAME}
    Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  mkdir -p ${destination}
    ${source}=  Run  find ${RESULTS}/${TEST_NAME} -name "Loop_?.tar.gz"
    ${cp_result}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  3min  30s
    ...  OperatingSystem.Run And Return Rc And Output  cp -r ${source} ${destination}
    Run Keyword If  ${cp_result} == True
    ...  Log  Logs successfully copied to burak  console=${true}
    ...  ELSE
    ...  Log  Copying logs to burak failed or there are failed iterations to analyze  console=${true}

#Generate and Send Configuration ID to ReP
#    scout.Setup Scout  scout_testline_name=${TESTLINE_NAME}  environment=production
#    scout.Request Scf
#    [Teardown]  scout.Teardown Scout Api

Generate and Send Configuration ID to ReP
    [Documentation]  Sends request to Scout to fetch new SCF. Returns Scout SCF id.
    ${bts_params}  Create Dictionary  admin_connection=${ute_admin_alias}
    ...                               scout_bts_name=${TESTLINE_NAME}
    Add BTS Metadata To Report  bts_params=${bts_params}

DCAP Syslog Teardown
    ${graceful_cell_test}  Run keyword and return status  Should Contain  ${TEST_NAME}  Graceful  ignore_case=True
    Run Keyword If  not ${graceful_cell_test}  Run keywords
    ...       dcap.DCAP Stop tracing and collect results  with_name=dcap_syslog
    ...  AND  dcap.Stop DCAP on UTE VM

###################
### CHECK STATE ###
###################
Check If NLWG Cells Are OnAir
    [Arguments]  ${GSM_AvailabilityStatus_check}=True
    ${is_concurrent}  Run Keyword And Return Status  Should Be True  ${CONCURRENT}
    ${GSM_DEPLOYED}=    admin.get ids for all  GNCEL
    ${WCDMA_DEPLOYED}=  admin.get ids for all  WNCEL
    ${LTE_DEPLOYED}=    admin.get ids for all  LNCEL
    ${NR_DEPLOYED}=     admin.get ids for all  NRCEL
    ${LTE_DEPLOYED_CONCURRENT}  Run Keyword If  ${is_concurrent}  admin.get ids for all  LNCEL  connection=concurrent
                                ...       ELSE  Create List
    ${NR_DEPLOYED_CONCURRENT}   Run Keyword If  ${is_concurrent}  admin.get ids for all  NRCEL  connection=concurrent
                                ...       ELSE  Create List
    Run Keyword If  ${GSM_DEPLOYED}!=[]    Check GNCELs  ${GSM_AvailabilityStatus_check}
    Run Keyword If  ${WCDMA_DEPLOYED}!=[]  Check WNCELs
    Run Keyword If  ${LTE_DEPLOYED}!=[] and ${LTE_DEPLOYED_CONCURRENT}!=[]
    ...             Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  lte  all
    ...    ELSE IF  ${LTE_DEPLOYED}!=[]
    ...             Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  lte
    ...    ELSE IF  ${LTE_DEPLOYED_CONCURRENT}!=[]
    ...             Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  lte  concurrent
    Run Keyword If  ${NR_DEPLOYED}!=[] and ${NR_DEPLOYED_CONCURRENT}!=[]
    ...             Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  nr  all
    ...    ELSE IF  ${NR_DEPLOYED}!=[] and ${MRBTS_ID}==8793    Run Keywords
    ...             Wait Until Keyword Succeeds  4min  30s    Check X2 Link
    ...    AND      Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  nr
    ...    ELSE IF  ${NR_DEPLOYED}!=[]
    ...             Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  nr
    ...    ELSE IF  ${NR_DEPLOYED_CONCURRENT}!=[]
    ...             Wait Until Keyword Succeeds  10min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  nr  concurrent

Check LNCEL/NRCELL OnAir Or EnergySaving State
    [Arguments]    ${rat}  ${to_check}=regular
    ${concurrent_cell_list}  Run Keyword If  'concurrent' in $to_check or 'all' in $to_check
                             ...             admin.get cells info  cell_type=${rat}  connection=concurrent
                             ...       ELSE  Create List
    ${regular_cell_list}     Run Keyword If  'regular' in $to_check or 'all' in $to_check  admin.get cells info  ${rat}
                             ...       ELSE  Create List
    ${cell_list}  Combine Lists  ${regular_cell_list}
                  ...            ${concurrent_cell_list}
    FOR  ${cell}  IN  @{cell_list}
        ${cell_id}              Evaluate  '${cell}[id][configuration]'.split('/')[-1]
        ${cell_num}             Evaluate  '${cell}[id][configuration]'.split('-')[-1]
        ${administrativeState}  Evaluate  '${cell}[status][administrativeState]'.lower()
        ${availabilityStatus}   Evaluate   ${cell}[status].get('availabilityStatus', "None").lower()
        ${blockingState}        Evaluate  '${cell}[status][blockingState]'.lower()
        ${operationalState}     Evaluate  '${cell}[status][operationalState]'.lower()
        ${energySavingState}    Evaluate  '${cell}[energySavingState]'.lower()
        ${energy_saving}        Evaluate   bool(re.match(r"\\b(?:reduced)?(?:energy|switching)(?:saving|off\\w*|on\\w*)", $energySavingState))  re
        ${unblocked_and_unlocked}  Evaluate  '${administrativeState}'=='unlocked' and '${blockingState}'=='unblocked'
        ${iotState}    Evaluate  '${cell}[technology]'
        ${iot}    Evaluate    bool(re.search(r".*IoT.*", "${iotState}"))
        ${hostCellEnergySavingState}    Run Keyword If  ${iot}    Check EnergySavingstate IoT host cell    ${cell_num}
        ${on_air}    Evaluate   ${unblocked_and_unlocked} and '${availabilityStatus}'=='none' and '${operationalState}'=='enabled'
        Should Be True  ${on_air} or ${energy_saving} or ${iot}  msg=${cell_id} is not on air nor in energy saving state
        Run Keyword If    ${iot}    Should Be True    ${on_air} or ${hostCellEnergySavingState}
        ...    msg=${cell_id} IoT cell is not OnAir nor in energy saving state
    END
    Run Keyword If    '${rat}'=='nr'    Log To Console    All NRCELL(s) are OnAir and/or in EnergySaving
    ...    ELSE IF    '${rat}'=='lte'   Log To Console    All LNCEL(s) are OnAir and/or in EnergySaving

Check EnergySavingstate IoT host cell
    [Arguments]  ${iotCellid}
    ${lncel_l}  Get Managed Objects  LNCEL_L
    FOR  ${object}  IN  @{lncel_l}
        ${object_id}    Evaluate    '${object['parameters']['nbIotLinkedCellId']}'
        Continue For Loop If    '${iotCellid}'!='${object_id}'
        ${hostCellEnergySaving}    Evaluate    '${object['parameters']['stateInfo']['energySaving']}'
        ${hostCellEnergySavingState}    Evaluate    '${hostCellEnergySaving}'=='energySaving'
    END
    [Return]    ${hostCellEnergySavingState}

#Check If NLWG Cells Are OnAir
#    [Arguments]  ${GSM_AvailabilityStatus_check}=True
#    ${GSM_DEPLOYED}=    admin.get ids for all  GNCEL
#    ${WCDMA_DEPLOYED}=  admin.get ids for all  WNCEL
#    ${LTE_DEPLOYED}=    admin.get ids for all  LNCEL
#    ${NR_DEPLOYED}=     admin.get ids for all  NRCEL
#    ${PSGRP_DEPLOYED}=  admin.get managed objects  PSGRP_A
#    ${NRPGRP_DEPLOYED}=  admin.get managed objects  NRPGRP_A
#
#    Run Keyword If  ${GSM_DEPLOYED}!=[]  Run Keywords
#    ...  Log  Checking GSM cell(s)
#    ...  AND  Check GNCELs  ${GSM_AvailabilityStatus_check}
#
#    Run Keyword If  ${WCDMA_DEPLOYED}!=[]  Run Keywords
#    ...  Log  Checking WCDMA cell(s)
#    ...  AND  Check WNCELs
#
#    Run Keyword If  ${LTE_DEPLOYED}!=[] and ${PSGRP_DEPLOYED}==[]  Run Keywords
#    ...  Log  Checking LTE cell(s)
#    ...  AND  Check LNCELs
#    ...  ELSE IF  ${LTE_DEPLOYED}!=[] and ${PSGRP_DEPLOYED}!=[]  Run Keywords
#    ...  Log  Checking LTE cell(s) under PSGRP and other(s)
#    ...  AND  Check PowerSaving LNCELS And Return Status
#
#    Run Keyword If  ${NR_DEPLOYED}!=[] and ${NRPGRP_DEPLOYED}==[]  Run Keywords
#    ...  Log  Checking NR cell(s)
#    ...  AND  Check NRCELs
#    ...  ELSE IF  ${NR_DEPLOYED}!=[] and ${NRPGRP_DEPLOYED}!=[]  Run Keywords
#    ...  Log  Checking NR cell(s) under NRPGRP and other(s)
#    ...  AND  Check PowerSaving NRCELS And Return Status

Check GNCELs
    [Arguments]  ${GSM_AvailabilityStatus_check}
    ${GSM_status}=  Run Keyword If  ${GSM_AvailabilityStatus_check}  Run Keyword And Return Status  Run Keywords
    ...       Wait Until Keyword Succeeds  20min  30s  admin.assert every  GNCEL  ${GSM_expected_state}
    ...  AND  Wait Until Keyword Succeeds   3min  30s  Check State on GNCELs  availabilityStatus  None
    ...  ELSE  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  GNCEL  ${GSM_expected_state}
    Run Keyword If  ${GSM_status} == True
    ...  Log  All GNCEL(s) are OnAir  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one GNCEL has not reached OnAir state within 20 minutes

Check State on GNCELs
    [Documentation]  Workaround keyword due to lack of support for availabilityStatus parameter by admin.assert
    ...
    ...  **Example of simple usage:**
    ...  Wait Until Keyword Succeeds  3min  30s  Check State on GNCELs  availabilityStatus  None
    ...
    [Arguments]  ${parameter}  ${expected_state}
    ${gncel_params}=  admin.get managed objects  GNCEL_R
    FOR  ${gncel}  IN  @{gncel_params}
       Run Keyword If  ${gncel['parameters']['${parameter}']}=='${expected_state}'
       ...  Should Be Equal As Strings  ${gncel['parameters']['${parameter}']}  ${expected_state}  ignore_case=True
    END

Check WNCELs
    ${WCDMA_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  WNCEL  ${WCDMA_expected_state}
    Run Keyword If  ${WCDMA_status} == True
    ...  Log  All WNCEL(s) are OnAir  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one WNCEL has not reached OnAir state within 20 minutes

Check LNCELs
    ${LTE_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  LNCEL  ${LTE_expected_state}
    Run Keyword If  ${LTE_status} == True
    ...  Log  All LNCEL(s) are OnAir  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one LNCEL has not reached OnAir state within 20 minutes

Check NRCELs
    ${NR_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  admin.assert every  NRCEL  ${NR_expected_state}
    Run Keyword If  ${NR_status} == True
    ...  Log  All NRCEL(s) are OnAir  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one NRCEL has not reached OnAir state within 20 minutes

Check PowerSaving LNCELS And Return Status
    [Documentation]    Keyword verify if LTE cells that are included to PSGRP, have energy saving state,
    ...    if no cells will be added to not energy saving list, and verified if not energy saving.
    ${not_ps_cells}  ${ps_cells}  Return PS And Not PS LTE Cells
    Set Test Variable  @{not_ps_cells}
    Set Test Variable  @{ps_cells}
    FOR  ${cell}  IN  @{ps_cells}
      ${LTE_ps_status}=  Run Keyword And Return Status  admin.assert  LNCEL  ${cell}  ${LTE_ps_expected_state}  timeout=2s
      Set Variable  ${LTE_ps_status}
      Run Keyword If  ${LTE_ps_status}!=True
      ...  Append To List  ${not_ps_cells}  ${cell}
    END
    Run Keyword If  ${LTE_ps_status} == True
    ...  Log To Console  Cell(s) under PSGRP in energySaving state
    ${not_ps_cells_len}=  Get Length  ${not_ps_cells}
    Run Keyword If  '${not_ps_cells_len}'>'0'  Check If Not All LTE Cells Added To PSGRP  ${not_ps_cells}
    ...  ELSE  Log  All LTECEL(s) are in PSGRP  console=${true}


Check If Not All LTE Cells Added To PSGRP
    [Arguments]  ${not_ps_cells}
    FOR  ${cell}  IN  @{not_ps_cells}
       ${not_ps_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  10min  30s  admin.assert  LNCEL  ${cell}  ${LTE_expected_state}
       Set Variable  ${not_ps_status}
    END
    Run Keyword If  ${not_ps_status}   Log to console  Not PS LTE Cell(s) On Air
    ...  ELSE
    ...  Fail  msg=At least one LTE CELL has not reached OnAir state

Check PowerSaving NRCELS And Return Status
    [Documentation]    Keyword verify if NR cells that are included to NRPGRP, have energy saving state,
    ...    if no cells will be added to not energy saving list, and verified if not energy saving.
    ${not_ps_cells}  ${ps_cells}  Return PS And Not PS NR Cells
    Set Test Variable  @{not_ps_cells}
    Set Test Variable  @{ps_cells}
    FOR  ${cell}  IN  @{ps_cells}
      ${NR_ps_status}=  Run Keyword And Return Status  admin.assert  NRCEL  ${cell}  ${NR_ps_expected_state}  timeout=2s
      Set Variable  ${NR_ps_status}
      Run Keyword If  ${NR_ps_status}!=True
      ...  Append To List  ${not_ps_cells}  ${cell}
    END
    Run Keyword If  ${NR_ps_status} == True
    ...  Log To Console  Cell(s) under NRPGRP in energySaving state
    ${not_ps_cells_len}=  Get Length  ${not_ps_cells}
    Run Keyword If  '${not_ps_cells_len}'>'0'  Check If Not All NR Cells Added To NRPGRP  ${not_ps_cells}
    ...  ELSE  Log To Console  All NRCEL(s) are in NRPGRP  console=${true}

Check If Not All NR Cells Added To NRPGRP
    [Arguments]  ${not_ps_cells}
    FOR  ${cell}  IN  @{not_ps_cells}
       ${not_ps_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  10min  30s  admin.assert  NRCEL  ${cell}  ${NR_expected_state}
       Set Variable  ${not_ps_status}
    END
    Run Keyword If  ${not_ps_status}   Log to console  Not PS Cell(s) On Air
    ...  ELSE
    ...  Fail  msg=At least one NRCEL has not reached OnAir state

Check SMODs State
    [Arguments]  ${SMOD_expected_states}  ${timeout}=20min  ${interval}=30s
    ${SMOD_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  ${interval}
    ...  admin.assert every  SMOD  ${SMOD_expected_states}
    Run Keyword If  ${SMOD_status} == True
    ...  Log  All SMOD(s) have expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one SMOD has not reached expected state within ${timeout}

Check BBMODs State
    [Arguments]  ${BBMOD_expected_states}  ${timeout}=20min  ${interval}=30s
    ${BBMOD_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  ${interval}
    ...  admin.assert every  BBMOD  ${BBMOD_expected_states}
    Run Keyword If  ${BBMOD_status} == True
    ...  Log  All BBMOD(s) have expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one BBMOD has not reached expected state within ${timeout}

Check RMODs State
    [Arguments]  ${RMOD_expected_states}  ${timeout}=20min  ${interval}=30s
    ${RMOD_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  ${interval}
    ...  admin.assert every  RMOD  ${RMOD_expected_states}
    Run Keyword If  ${RMOD_status} == True
    ...  Log  All RMOD(s) have expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one RMOD has not reached expected state within ${timeout}

Check If ALDs Are Connected And Achieved Expected State
    ${rmod_sleep_states}  Create List
    ${rmods_list}=  admin.get managed objects  RMOD_A
    ${ALD_DETECTED}=  admin.get ids for all  ALD
    FOR  ${item}  IN  @{rmods_list}
        ${parameters}=  Get From Dictionary  ${item}  parameters
        ${energySavingMode}=  Get From Dictionary  ${parameters}  energySavingMode
        Append To List   ${rmod_sleep_states}  ${energySavingMode}
    END
    ${contains_sleep}=  Evaluate  'DEEPSLEEP' in ${rmod_sleep_states}
    Run Keyword If  ${ALD_DETECTED}!=[] and ${contains_sleep}  Run Keywords
    ...  Log  Checking ALD(s)
    ...  AND  Check ALDs When EnergySaving Mode Enabled
    ...  ELSE IF  ${ALD_DETECTED}!=[] and '${contains_sleep}'!= 'True'
    ...  Check ALDs State  ${ALD_expected_states}

Check ALDs When EnergySaving Mode Enabled
    ${cell_list}    admin.get cells info    lte
    ${ALDs_list}=  admin.Get Managed Objects  RETU_L
    FOR  ${item}  IN  @{ALDs_list}
        ${availabilityStatus}   Evaluate   '${item}[parameters][stateInfo][availabilityStatus]'.lower()
        ${operationalState}     Evaluate  '${item}[parameters][stateInfo][operationalState]'.lower()
        ${available}  Evaluate  '${availabilityStatus}'=='online' and '${operationalState}'=='enabled'
        ${unAvailable}  Evaluate  '${availabilityStatus}'=='offline' and '${operationalState}'=='disabled'
        Should Be True  '${available}' or '${unAvailable}'
    END
    Log  Few RU(s) have energySavingMode DEEPSLEEP, ALD(s) states could be impacted  console=${true}


Check ALDs State
    [Arguments]  ${ALD_expected_states}
    ${ALD_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  30s  admin.assert every  ALD  ${ALD_expected_states}
    Run Keyword If  ${ALD_status} == True
    ...  Log  All ALD(s) have expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one ALD has not reached expected state within 5 minutes

Check Dedicated ALD State
    [Arguments]  ${ret_or_mha}  ${ALD_expected_states}
    ${ALD_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  30s  admin.assert  ALD  ${ret_or_mha}  ${ALD_expected_states}
    ${ALD_R}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ret_or_mha}''').group(0)  re
    Run Keyword If  ${ALD_status} == True
    ...  Log  ${ALD_R} have expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=${ALD_R} has not reached expected state within 5 minutes

Check BTS State
    [Arguments]  ${BTS_expected_states}  ${timeout}=20min  ${interval}=30s
    ${BTS_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  ${interval}
    ...  admin.assert every  BTS  ${BTS_expected_states}
    Run Keyword If  ${BTS_status} == True
    ...  Log  BTS has reached expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=BTS has not reached expected state within ${timeout}

Check ENB
    [Arguments]  ${type}=admin  ${skip_states_check}=false
    Run Keyword And Continue On Failure  Run Keyword If  '${skip_states_check}'=='false'  Check If Cells OnAir Or PowerSaving Enabled  alias=${alias}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Run Keyword If  '${type}'=='netact'  Wait Until Keyword Succeeds  10x  30s  Check If Alarms From ENB and NetAct Are The Same

Check BBPOOL State
    [Arguments]  ${BBPOOL_DN}  ${expected_operationalState}
    ${BBPOOLs}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{BBPOOLs}
        ${bbpool_r}=  Evaluate  re.search(r'BBPOOL_R-(\\d+)','''${bbpool}''').group(0)  re
        ${operationalState}=  Evaluate  "${bbpool['parameters']['operationalState']}".upper()
        Run Keyword If  '${bbpool['distName']}'=='${BBPOOL_DN}'  Run Keywords
        ...  Should Be True  '${operationalState}'=='${expected_operationalState}'
        ...  AND  Log To Console  ${bbpool_r} operationalState: ${operationalState}
    END

Check BBMOD State
    [Arguments]  ${dn}  ${expected_operationalState}  ${expected_availabilityStatus}
    ${bb}  admin.get fbb info
    ${current_operationalState}  Evaluate
    ...  [bbmod['status']['operationalState'] for bbmod in ${bb} if str('${dn}')[-1] == str(bbmod['id']['configuration'])[-1]]
    ${current_availabilityStatus}  Evaluate
    ...  [bbmod['status'].get('availabilityStatus', 'NONE') for bbmod in ${bb} if str('${dn}')[-1] == str(bbmod['id']['configuration'])[-1]]
    Should Be Equal As Strings    ${current_operationalState[0].upper()}      ${expected_operationalState}
    Should Be Equal As Strings    ${current_availabilityStatus[0].upper()}    ${expected_availabilityStatus}
    Log To Console  States for ${dn} operationalState:${current_operationalState[0].upper()},    no_newline=true
    Log To Console  ${SPACE}availabilityStatus:${current_availabilityStatus[0].upper()}

Count Expected BBMODs
    [Arguments]  ${expected_BBMOD}
    ${BBMOD_parameters}  admin.get managed objects  BBMOD_R
    ${BBMOD_count}  Evaluate  sum(1 for bbmod in ${BBMOD_parameters} if '${expected_BBMOD}' in bbmod['parameters']['productName'])
    [Return]  ${BBMOD_count}

Check X2 Link
    [Documentation]  Keyword check if parameter x2LinkStatus is equal Available.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ${LTEENB_L}=  admin.get managed objects  LTEENB_L
    FOR  ${i}  IN  @{LTEENB_L}
        Should Be True  '${i['parameters']['x2LinkStatus']}'=='Available'
    END

Check S1 Link
    [Documentation]  Keyword check if parameter s1LinkStatus is equal available.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ${LNMME_A}=  admin.get managed objects  LNMME_A
    FOR  ${i}  IN  @{LNMME_A}
        Should Be True  '${i['parameters']['s1LinkStatus']}'=='available'
    END

Resolve Locked Cells Group
    [Documentation]
    ...    Keyword checks if there are any locked Cells Group left from previous test.
    ...    Author: aleksandra.trojak@nokia.com, jakub.hirny@nokia.com
    [Arguments]  ${PLANS_DIR}=${RESULTS}/plans
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${locked_cells}  Create List
    ${delta}  Set Variable  locked_cells
    admin.create delta  ${delta}
    Log To Console  Checking for locked Cells Group
    ${cells_list}  admin.get cell list
    ${cells}  Combine Lists  ${cells_list['cells']['lte']}
                      ...    ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{cells}
        ${values}  Get Dictionary Values  ${cell}
        ${cell_states}           Get From Dictionary  ${cell}         status
        ${administrativeState}   Get From Dictionary  ${cell_states}  administrativeState
        ${administrativeState_upper}  Evaluate  "${administrativeState}".upper()
        Continue For Loop If  '${administrativeState_upper}'!='LOCKED'
        ${desired_value}  Set Variable If  'NRCELL' in $cell['id']['configuration']  Unlocked  unlocked
        Append To List  ${locked_cells}  ${cell['id']['configuration']}
        admin.append parameter update to delta  ${cell['id']['configuration']}  administrativeState  ${desired_value}  ${delta}
    END
    admin.get delta  ${delta}
    ${json_path}  Set Variable  ${PLANS_DIR}/cells_unlock_${current_date}.json
    Run Keyword If  ${locked_cells}!=[]  Run Keywords
    ...             Log To Console  Found locked cell(s). Unlocking ${locked_cells}...
    ...        AND  admin.save delta  ${json_path}  ${delta}
    ...        AND  admin.perform delta recommissioning  ${json_path}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}

Resolve Blocked Cells
    [Documentation]
    ...    Keyword checks if there are any blocked cells left from previous test.
    ...    Author: jakub.hirny@nokia.com
    Log To Console  Checking for blocked cells
    ${cells_list}  admin.get cell list
    ${cells}  Combine Lists  ${cells_list['cells']['lte']}
                      ...    ${cells_list['cells']['wcdma']}
                      ...    ${cells_list['cells']['gsm']}
                      ...    ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{cells}
        ${values}  Get Dictionary Values  ${cell}
        ${cell_states}    Get From Dictionary  ${cell}         status
        ${blockingState}  Get From Dictionary  ${cell_states}  blockingState
        ${blockingState_upper}  Evaluate  "${blockingState}".upper()
        Run Keyword If  '${blockingState_upper}'=='BLOCKED'    Run Keywords
        ...       Log To Console  Unblocking cell: ${cell['id']['configuration']}
        ...  AND  admin.Unblock cell  ${cell['id']['configuration']}  timeout=360
    END

Resolve Locked RMOD
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}          Get From Dictionary  ${rmod}         status
        ${administrativeState}  Get From Dictionary  ${rmod_states}  administrativeState
        ${administrativeState_upper}  Evaluate  "${administrativeState}".upper()
        Run Keyword If  '${administrativeState_upper}'=='LOCKED'    Run Keywords
        ...       Log To Console  Unlocking RMOD: ${rmod['id']['configuration']}
        ...  AND  admin.unlock  ${rmod['id']['configuration']}  timeout=240
        ...  AND  Wait Until Keyword Succeeds  80s  10s  Assert  RMOD  ${rmod['id']['configuration']}  administrativeState=regex"(?i)Unlocked"
    END

Resolve Blocked RAT
    FOR  ${rat}  IN  @{rats}
        ${rat_managed_object}  Set Variable If  '${rat.upper()[0]}'=='G'  GNBCF_R  '${rat.upper()[0]}'=='N'  NRBTS_R  ${rat.upper()[0]}NBTS_R
        ${rat_object}  Get Managed Objects  ${rat_managed_object}
        ${rat_blockingState}  Get From Dictionary  ${rat_object[0]['parameters']}  blockingState
        ${rat_is_unblocked}  Run Keyword And Return Status  Should Be Equal As Strings  ${rat_blockingState.upper()}  UNBLOCKED
        Continue For Loop If  ${rat_is_unblocked}
        Log To Console  Unblocking ${rat.upper()}...
        admin.Unblock Rat  ${rat.upper()}
        ${rat_object}  Get Managed Objects  ${rat_managed_object}
        ${rat_blockingState}  Get From Dictionary  ${rat_object[0]['parameters']}  blockingState
        Should Be Equal As Strings  ${rat_blockingState.upper()}  UNBLOCKED
    END

Resolve Locked BBMOD
    ${bts_info}  admin.get bts info
    FOR  ${bbmod}  IN  @{bts_info['basebandModules']}
        ${bbmod_states}         Get From Dictionary  ${bbmod}         status
        ${administrativeState}  Get From Dictionary  ${bbmod_states}  administrativeState
        ${administrativeState_upper}  Evaluate  "${administrativeState}".upper()
        Run Keyword If  '${administrativeState_upper}'=='LOCKED'    Run Keywords
        ...       Log To Console  Unlocking BBMOD: ${bbmod['id']['configuration']}
        ...  AND  admin.unlock  ${bbmod['id']['configuration']}  timeout=240
        ...  AND  Wait Until Keyword Succeeds  80s  10s  Assert  BBMOD  ${bbmod['id']['configuration']}  administrativeState=regex"(?i)Unlocked"
    END

Resolve Blocked BTS
    ${mrbts_object}  Get Managed Objects  MRBTS_M
    FOR  ${item}  IN  @{mrbts_object}
        ${mrbts_state}  Get From Dictionary  ${item['parameters']}  stateInfo
        ${blockingState_upper}  Evaluate  "${mrbts_state['blockingState']}".upper()
    END
    Run Keyword If  '${blockingState_upper}'=='BLOCKED'  Run Keywords
    ...  Log  BTS was not unblocked in previous iteration.\nUnblocking now...\n  WARN
    ...  AND  admin.Unblock  timeout=600
    ...  AND  Check SMODs State  ${SMOD_expected_states}
    ...  AND  Check RMODs State  ${RMOD_expected_states}
    ...  AND  Check If ALDs Are Connected And Achieved Expected State
    ...  AND  Check BTS State  ${BTS_expected_states}
    ...  AND  Check If NLWG Cells Are OnAir

Full Check After Start-up
    [Arguments]  ${alias}=startup
    Wait Until Keyword Succeeds  5min  30s  admin.setup admin  admin_api_log_dir=/home/ute/test_results/TurnOnBTS/admin_api/  alias=${alias}
    ${SMOD_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  SMOD  ${SMOD_expected_states}  ${alias}
    Run Keyword If  ${SMOD_status}  Log To Console  \nAll SMOD(s) have expected state
    ${RMOD_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  RMOD  ${RMOD_expected_states}  ${alias}
    Run Keyword If  ${RMOD_status}  Log To Console  All RMOD(s) have expected state
    ${BTS_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  BTS  ${BTS_expected_states}  ${alias}
    Run Keyword If  ${BTS_status}  Log To Console  BTS has reached expected state
    ${ALD_DETECTED}  admin.get ids for all  ALD  ${alias}
    ${ALD_status}  Run Keyword If  ${ALD_DETECTED}!=[]  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5min  30s  admin.assert every  ALD  ${ALD_expected_states}  ${alias}
    Run Keyword If  ${ALD_status}  Log To Console  All ALD(s) have expected state
    ${GSM_DEPLOYED}    admin.get ids for all  GNCEL  ${alias}
    ${WCDMA_DEPLOYED}  admin.get ids for all  WNCEL  ${alias}
    ${LTE_DEPLOYED}    admin.get ids for all  LNCEL  ${alias}
    ${NR_DEPLOYED}     admin.get ids for all  NRCEL  ${alias}
    ${GSM_onAir}  Run Keyword If  ${GSM_DEPLOYED}!=[]
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  GNCEL  ${GSM_expected_state}  ${alias}
    Run Keyword If  ${GSM_onAir}  Log To Console  All GNCEL(s) are OnAir
    ${WCDMA_onAir}  Run Keyword If  ${WCDMA_DEPLOYED}!=[]
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  WNCEL  ${WCDMA_expected_state}  ${alias}
    Run Keyword If  ${WCDMA_onAir}  Log To Console  All WNCEL(s) are OnAir
    ${LTE_onAir}  Run Keyword If  ${LTE_DEPLOYED}!=[]
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  LNCEL  ${LTE_expected_state}  ${alias}
    Run Keyword If  ${LTE_onAir}  Log To Console  All LNCEL(s) are OnAir
    ${NR_onAir}  Run Keyword If  ${NR_DEPLOYED}!=[]
    ...  Wait Until Keyword Succeeds  20min  30s  admin.assert every  NRCEL  ${NR_expected_state}  ${alias}
    Run Keyword If  ${NR_onAir}  Log To Console  All NRCEL(s) are OnAir
    [Teardown]  Run Keyword And Ignore Error  admin.teardown admin  alias=${alias}

Check SCF Errors
    [Documentation]  Keyword checks if there are errors in active SCF file
    ${status}  ${error}  Run Keyword And Ignore Error  Validate SCF with Backup
    Run Keyword If  '${status}' == 'FAIL'
    ...  Log  SCF ERROR DETECTED, ERROR MESSAGE: ${error}  WARN

Validate SCF with Backup
    [Documentation]  Keyword Validates SCF file
    SCF Backup
    admin.Validate Scf Online  ${RESULTS}/SCF_BACKUP.xml

Check FHSs State
    [Documentation]  Keyword checks states of FHSs and compares them with expected states
    ${bts_info}  Get BTS Info
    ${fhss}  Set Variable  ${bts_info['fhs']}
    FOR  ${fhs}  IN  @{fhss}
        ${fhs_states}  Get from dictionary  ${fhs}  stateInfo
        ${operational_state}=  Get from dictionary  ${fhs_states}  operationalState
        ${administrative_state}=  Get from dictionary  ${fhs_states}  administrativeState
    END
    FOR  ${fhs_expected_operational_state}  IN  ${operational_state}
        Should Be Equal As Strings  ${operational_state}  enabled  ignore_case=True
    END
    FOR  ${fhs_expected_administrative_state}  IN  ${administrative_state}
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
    END
    Run Keyword If  '${fhs_expected_operational_state}'=='${operational_state}'
    ...  Run Keyword If  '${fhs_expected_administrative_state}'=='${administrative_state}'
    ...  Log  All FHS(s) have expected state  console=${true}
    ...  ELSE
    ...  Fail  msg=At least one FHS has not reached expected state

Check Feature Availability And Value
    [Arguments]  ${parameter}  ${value_to_set}  ${feature_under}=FEATCADM
    [Documentation]  Keyword checks parameter availability and current value in object under MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/xxxxx-1
    ...              (for example: FEATCADM, MPLANENW, SECADM, TRBLCADM) and checks if given ${value_to_set} is possible to set.
    ...              Results are returned in dictionary ${parameter_dict} with exemplary items:
    ...              {'availability': 'True', 'initial_value': 'true', 'possible_to_set': 'True'}.
    ...              Example of usage:
    ...              Check Feature Availability And Value  parameter=actRatResetEnhancement  value_to_set=true
    Log To Console  == Checking ${parameter} availability and value ==
    ${parameter_dict}  Create Dictionary
    ${object_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/${feature_under}-1
    ${managed_object}    Get Managed Objects    ${feature_under}_A
    FOR  ${item}  IN  @{managed_object}
        ${parameter_value}  Run Keyword And Ignore Error  Set Variable If  '${item['parameters']['${parameter}']}'=='${True}'  true
        ...  '${item['parameters']['${parameter}']}'=='${False}'  false  ${item['parameters']['${parameter}']}
    END
    ${availability}  Set Variable If  '${parameter_value[0]}'=='PASS'  True  False
    Set To Dictionary  ${parameter_dict}  availability  ${availability}
    Run Keyword If  ${availability}  Set To Dictionary  ${parameter_dict}  initial_value  ${parameter_value[1]}
    ...       ELSE  Set To Dictionary  ${parameter_dict}  initial_value  None
    ${parameter_state}  Run Keyword If  ${availability}  Run Keyword And Return Status
    ...             Should Be Equal As Strings  ${parameter_value[1]}  ${value_to_set}
    ${validity_check}  Run Keyword If  '${parameter_state}'=='False'
    ...             Run Keyword And Ignore Error  Run Keywords
    ...             Allow Fault In Watchdog  faultID=4340  #Previously downloaded plan [planId] was overwritten by a new plan [planId]
    ...        AND  admin.Perform Parameter Recommissioning  ${object_DN}  ${parameter}  update  ${value_to_set}  should_activate=False
    ...    ELSE IF  '${parameter_state}'=='True'  Run Keywords
    ...             Log To Console  ${parameter} initial_value (${parameter_value[1]}) is the same as planned value (${value_to_set})
    ...        AND  Set Variable  None
    Run Keyword If  '${parameter_state}'=='False'  Run Keywords
    ...             Run Keyword And Ignore Error  admin.Perform Parameter Recommissioning  ${object_DN}  ${parameter}  update  ${parameter_value[1]}
    ...        AND  Run Keyword And Ignore Error  Wait For Inactive Fault  faultID=4340  timeout=10 sec
    ...        AND  Disallow Fault In Watchdog  faultID=4340  #Previously downloaded plan [planId] was overwritten by a new plan [planId]
    ${possible_to_set}  Run Keyword If  ${availability}
    ...             Run Keyword And Return Status  Should Not Contain Any  '${validity_check}'  in this release  it is required that
    ${possible_to_set}  Set Variable If  ${availability} and '${parameter_state}'=='True'  True  ${possible_to_set}
    Set To Dictionary  ${parameter_dict}  possible_to_set  ${possible_to_set}
    ${in_this_release}  Run Keyword And Return Status  Should Contain  '${validity_check}'  in this release
    ${is_required_that}  Run Keyword And Return Status  Should Contain  '${validity_check}'  it is required that
    Run Keyword If  '${availability}'=='False'  Log  Parameter ${parameter} is not available on ${RELEASE} release  WARN
    ...    ELSE IF  ${in_this_release}  Log  Setting ${parameter} value to ${value_to_set} is not possible on ${RELEASE} release  WARN
    ...    ELSE IF  ${is_required_that}  Log  Setting ${parameter} value to ${value_to_set} requires some other parameter change  WARN
    Log To Console  Results for ${parameter} are: ${parameter_dict}
    Log To Console  == Check is done ==
    [Return]  ${parameter_dict}

Get DETECTION_RESULT For Specified Objects
    [Arguments]  ${objects_list}
    [Documentation]  Keyword gets all DETECTION_RESULT managed objects and returns objects for specified list.
    ...              Example of usage:    Get DETECTION_RESULT For Specified Objects  objects_list=${enhanced_capable}
    ${managed_detection}  Get Managed Objects  DETECTION_RESULT
    ${detection_objects}  Create List
    ${detection_dict}  Create Dictionary
    FOR  ${item}  IN  @{managed_detection}
        ${string}  ${ignore}  Split String From Right  ${item['distName']}  separator=/  max_split=1
        Append To List  ${detection_objects}  ${item['distName']}
        Set To Dictionary  ${detection_dict}  ${string}  ${item['distName']}
    END
    ${detection_objects_copy}  Combine Lists  ${detection_objects}
    FOR  ${item}  IN  @{objects_list}
        ${from_detection_dict}  Get From Dictionary  ${detection_dict}  ${item}
        Remove Values From List  ${detection_objects_copy}  ${from_detection_dict}
    END
    FOR  ${item}  IN  @{detection_objects_copy}
        Remove Values From List  ${detection_objects}  ${item}
    END
    [Return]  ${detection_objects}

Compare DETECTION_RESULT Objects
    [Arguments]  ${set_one}  ${set_two}
    [Documentation]  Keyword compares sets of two lists for differences between them and returns ${set_two} containing
    ...              only items that are different from ${set_one}.
    ...              Detected differences will be logged as warning.
    ...              If there were no differences between lists returned ${set_two} will be empty.
    ...              Example of usage:    Compare DETECTION_RESULT Objects  ${detection_before_reset}  ${detection_after_reset}
    ${set_one_dict}  Create Dictionary
    FOR  ${item}  IN  @{set_one}
        ${object_string}  ${detection_string}  Split String From Right  ${item}  separator=/  max_split=1
        Set To Dictionary  ${set_one_dict}  ${object_string}  ${detection_string}
        Remove Values From List  ${set_two}  ${item}
    END
    FOR  ${item}  IN  @{set_two}
        ${object_string}  ${detection_string}  Split String From Right  ${item}  separator=/  max_split=1
        ${from_set_one_dict}  Get From Dictionary  ${set_one_dict}  ${object_string}
        Log  Detected change in DETECTION_RESULT for ${object_string} (${from_set_one_dict} --> ${detection_string}).  WARN
    END
    [Return]  ${set_two}

Check if BBMOD is connected to RMOD
    [Documentation]  Keyword check if a BBMOD is connected to a specific RMOD
    ...  **Example of simple usage:** ${variable} = Check if BBMOD is connected to RMOD    ABIA    FXEB
    ...  **Description:** Verifies if the specified BBMOD is connected to the provided RMOD. It return:
    ...  True  - if the connection exists.
    ...  False - if the connection does not exist.
    [Arguments]    ${defined_bbmode_name}    ${defined_rmod_name}
    ${bts_info}  admin.Get BTS Info
    ${words_split}    Create List
    Log    Checking if RMOD: ${defined_rmod_name} is connected to BBMOD: ${defined_bbmode_name}
    FOR  ${bbmod_item}  IN  @{bts_info['basebandModules']}
         ${object}=  Set Variable    ${bbmod_item['id']['configuration']}
         ${connected_radios}  Create List
        ${connected_radios_names}    Create List
        FOR  ${item}  IN  @{bts_info['cables']}
            ${matched_connection}  Run Keyword And Return Status  Should Contain  '${item['firstEndPointId']['configuration']}'  ${object}
            ${matched_second}  Run Keyword And Return Status  Should Contain  '${item['secondEndPointId']['runtime']}'  RMOD
            ${rmodNum}    Set Variable    ${item['secondEndPointId']['runtime']}
            Run Keyword If  ${matched_connection} and ${matched_second}
            ...        Append To List  ${connected_radios}  ${rmodNum}
        END
        ${words}=    Set Variable    ${bbmod_item['productName']}
        ${words} =    Convert To String    ${words}
        ${words_split}=    Split String    ${words}    ${SPACE}
        ${bbmod_name}=    Set Variable    ${words_split[0]}
        FOR    ${radio}    IN    @{connected_radios}
            ${radioTemp}  ${ignore}  Split String From Right  ${radio}  separator=/  max_split=1
            FOR    ${radioItem}    IN    @{bts_info['radioModules']['rmod']}
                Run Keyword If  '${radioTemp}' == '${radioItem['id']['runtime']}'
                ...    Append To List    ${connected_radios_names}    ${radioItem['productName']}
            END
        END
        FOR    ${radio_in}    IN    @{connected_radios_names}
            Run Keyword If    '${defined_bbmode_name}'=='${bbmod_name}' and '${defined_rmod_name}'=='${radio_in}'  Run Keywords
            ...    Log To Console    Object ${object} named ${bbmod_name} is connected to: ${connected_radios_names}
            ...    AND    Return From Keyword    True
        END
    END
    Return From Keyword    False

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
    ${msg}=  admin.update software  ${SW_PACKAGE_PATH}  ${SHOULD_ACTIVATE}  timeout=1800
    Run Keyword If  '${msg}'=='Software update has been completed'
    ...  Log  ${msg}  console=${True}
    ...  ELSE  Fail  Software update has been failed

Download Expected SW Package
    [Documentation]  This keyword download expected software package.
    ...  Needed input variable, example: -v SW_PACKAGE:SBTS00_ENB_9999_220327_000002
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Download Expected SW Package  ${SW_PACKAGE}
    ...
    [Arguments]  ${SW_PACKAGE}
    ${free_space}=  Run  df -BM --output=avail /tmp | sed 1d | sed -e 's/M//'
    Run Keyword If  ${free_space}<9000
    ...  Fatal Error  ${free_space}MB available in /tmp - expected at least 9000MB
    ${verdict}=  Run Keyword And Return Status  Should Contain  ${SW_PACKAGE}  SBTS
    Run Keyword If  ${verdict}==False  Fail  msg=There is no input variable SW_PACKAGE
    ${if_FSM3}=  Run Keyword And Return Status  Should Contain  ${SW_PACKAGE}  FSM3
    ${regex}=  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)_(ENB|FSM3)_(?P<version>\\d{4})
    ${result}=  Get Regexp Matches  ${SW_PACKAGE}  ${regex}  product  postfix
    ${product}  ${postfix}=  Set Variable  ${result[0]}
    ${sw_type}=  Set Variable  ${product}${postfix}
    ${full_url}=  Run Keyword If  '${if_FSM3}'=='True'
    ...  Set Variable  ${artifactory}/${sw_type}_FSM3/${SW_PACKAGE}/${SW_PACKAGE}_release_BTSSM_downloadable_A54.zip
    ...  ELSE IF  '${if_FSM3}'=='False'
    ...  Set Variable  ${artifactory}/${sw_type}/${SW_PACKAGE}/${SW_PACKAGE}_release_BTSSM_downloadable_A54.zip
    Log  SW package downloading...  console=${true}
    ${SW_Split}=  Split String  ${full_url}  /
    ${SW_is_on_burak}  Run Keyword And Return Status  Check if SW Is On Burak  ${sw_type}  ${if_FSM3}  ${SW_Split[-1]}
    ${SW_PACKAGE_PATH}=  Run Keyword If  ${SW_is_on_burak}  Set Variable  /tmp/SW_package/${SW_Split[-1]}
    ...  ELSE  SW Download From WFT  ${full_url}
    [Return]  ${SW_PACKAGE_PATH}

SW Download From WFT
    [Arguments]  ${full_url}
    ${status}  Run Keyword And Return Status  Run  wget --no-proxy ${full_url} -P ${SW_PACKAGE_DESTINATION} | tee -a wget_log
    Run Keyword If  ${status} == False  Fail  msg=SW package download failed
    ${ignore}  ${package_name}=  Split String From Right  ${full_url}  separator=/  max_split=1
    ${SW_PACKAGE_PATH}=  Set Variable  ${SW_PACKAGE_DESTINATION}/${package_name}
    [Return]  ${SW_PACKAGE_PATH}

Check if SW Is On Burak
    [Documentation]  This keyword uses the approtriate "Copy from Burak" kw to check and copy the software
    [Arguments]  ${sw_type}  ${if_FSM3}  ${SW_name_with_A54.zip}
    ${sw_path}=  Run Keyword If  ${if_FSM3}  Copy FSM3 SW from Burak  ${sw_type}  ${SW_name_with_A54.zip}
    ...  ELSE  Copy AirScale SW from Burak  ${sw_type}  ${SW_name_with_A54.zip}

Copy FSM3 SW from Burak
    [Documentation]  This keyword copies given SW from Burak, fails if SW is not present on burak
    [Arguments]  ${sw_type}  ${SW_name_with_A54}
    ${burak_path}=  Run Keyword if  '${sw_type}'=='SBTS00'  Set variable  /media/Global_veryfication/[1] SW/SBTS/SBTS00_FSM3
#    ...  ELSE IF  '${sw_type}'=='SBTS23R3'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R3_FMS3
    ...  ELSE IF  '${sw_type}'=='SBTS23R2'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R2_FSMF
    ...  ELSE IF  '${sw_type}'=='SBTS23R1'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R1_FSMF
    ...  ELSE  Fail
    Run  sudo mkdir ${SW_PACKAGE_DESTINATION} && sudo chmod 777 ${SW_PACKAGE_DESTINATION}
    Run  sudo scp -T "${burak_path}/${SW_name_with_A54}" ${SW_PACKAGE_DESTINATION}
    OperatingSystem.File Should Exist  ${SW_PACKAGE_DESTINATION}/${SW_name_with_A54}

Copy AirScale SW from Burak
    [Documentation]  This keyword copies given SW from Burak, fails if SW is not present on burak
    [Arguments]  ${sw_type}  ${SW_name_with_A54}
    ${burak_path}=  Run Keyword if  '${sw_type}'=='SBTS00'  Set variable  /media/Global_veryfication/[1] SW/SBTS/SBTS00
    ...  ELSE IF  '${sw_type}'=='SBTS23R3'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R3
    ...  ELSE IF  '${sw_type}'=='SBTS23R2'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R2
    ...  ELSE IF  '${sw_type}'=='SBTS23R1'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS23R1
    ...  ELSE IF  '${sw_type}'=='SBTS22R4'  Set Variable  /media/Global_veryfication/[1] SW/SBTS/SBTS22R4
    ...  ELSE  Fail
    Run  sudo mkdir ${SW_PACKAGE_DESTINATION} && sudo chmod 777 ${SW_PACKAGE_DESTINATION}
    Run  sudo scp -T "${burak_path}/${SW_name_with_A54}" ${SW_PACKAGE_DESTINATION}
    OperatingSystem.File Should Exist  ${SW_PACKAGE_DESTINATION}/${SW_name_with_A54}

Check If SMOD Is Pingable
    [Arguments]  ${wait_time}=5min
    Wait Until Keyword Succeeds  ${wait_time}  15s  Check If Host Is Reachable  IP=${MSM_IP}

Check If SMOD Is Not Pingable
    Wait Until Keyword Succeeds  3min  10s  Check If Host Is Not Reachable  IP=${MSM_IP}

Check If Host Is Reachable
    [Arguments]  ${IP}
    ${result}  Run  ping -c 5 -w 10 ${IP}
    ${status}=  Run Keyword And Return Status  Should Contain  ${result}  5 packets transmitted, 5 received
    Run Keyword If  ${status} == False  Fail  msg=Host is not pingable

Check If Host Is Not Reachable
    [Arguments]  ${IP}
    ${result}  Run  ping -c 5 -w 10 ${IP}
    ${status}=  Run Keyword And Return Status  Should Contain  ${result}   packets transmitted, 0 received
    Run Keyword If  ${status} == False  Fail  msg=Host is still pingable

Check Admin Readiness
    [Arguments]    ${retry}=40s    ${retry_interval}=20s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Check System Module Port    ${MSM_IP}    positive

Check System Module Port
    [Arguments]    ${IP}    ${ping}
    ${output}    Run     nmap -p 443 ${IP}
    Run Keyword If    '${ping}'=='positive'    Should Contain        ${output}    443/tcp open    Port 443 on BTS is not open after expected time
    ...    ELSE IF    '${ping}'=='negative'    Should Not Contain    ${output}    443/tcp open    Port 443 on BTS is still open after expected time

SW Package Delete
    [Documentation]  Cleanup action for KW: Download Expected SW Package.
    ...  **Author:** tomasz.marchewka@nokia.com
    Run  sudo rm -r ${SW_PACKAGE_DESTINATION}
    Log  SW package has been deleted  console=${true}

Log In Frame
    [Arguments]    ${text}
    ${output}    Return Text In Frame    ${text}
    Log To Console    \n${output}

String Generator
    [Documentation]  This keyword generate a string with a desired length from the given chars
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Input Parameters:**
    ...
    ...  +---------------+-----------------------------------------------------------+
    ...  | Parameter     | Description                                               |
    ...  +===============+===========================================================+
    ...  | ascii_letters | Lowercase and uppercase ASCII characters                  |
    ...  +---------------+-----------------------------------------------------------+
    ...  | digits        | Numbers from 0 to 9                                       |
    ...  +---------------+-----------------------------------------------------------+
    ...  | punctuation   | Special characters - punctuation                          |
    ...  +---------------+-----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  ${value}=  String Generator  ascii_letters=${True}  digits=${True}  punctuation=${True}  length=${12}
    ...  ${value}=  String Generator  ascii_letters=${False}  digits=${True}  punctuation=${False}  length=${8}
    ...  ${value}=  String Generator  ascii_letters=${True}  digits=${True}  punctuation=${False}  length=${6}
    ...
    [Arguments]  ${ascii_letters}  ${digits}  ${punctuation}  ${length}
    ${generated_string}=  Run Keyword If  '${ascii_letters}'=='${true}' and '${digits}'=='${true}' and '${punctuation}==${true}'
    ...  String With Ascii Letters Digits Punctuation  ${length}
    ...  ELSE IF  ${ascii_letters}==${false} and ${digits}==${true} and ${punctuation}==${false}
    ...  String With Digits  ${length}
    ...  ELSE IF  ${ascii_letters}==${true} and ${digits}==${true} and ${punctuation}==${false}
    ...  String With Ascii Letters Digits  ${length}
    [Return]  ${generated_string}

String With Ascii Letters Digits Punctuation
    [Arguments]  ${length}
    ${char_pool}=  Evaluate  string.ascii_letters + string.punctuation + string.digits  modules=string
    ${string}=  Convert To List   ${char_pool}
    ${generate_random}=  Evaluate   random.sample(${string}, ${length})  modules=random
    ${generated_string}=  Evaluate  "".join(${generate_random})  modules=string
    ${generated_string}=  Set Variable  ${generated_string}
    [Return]  ${generated_string}

String With Digits
    [Arguments]  ${length}
    ${generated_string}=  Generate Random String  ${length}  [NUMBERS]
    [Return]  ${generated_string}

String With Ascii Letters Digits
    [Arguments]  ${length}
    ${generated_string}=  Generate Random String  ${length}  [LETTERS][NUMBERS]
    [Return]  ${generated_string}

Generate Random Number With Range
    [Arguments]  ${start_range}  ${end_range}
    ${generated_value}=  Evaluate  random.randint(${start_range}, ${end_range})  modules=random
    [Return]  ${generated_value}

Get Active Partition
    [Documentation]  Keyword returns active partition.
    ...  **Author:** tomasz.marchewka@nokia.com
    ssh.connect_to  hostname=${MSM_IP}  username=${ENB_ROOT_USER}  password=${ENB_ROOT_PASS}
    ssh.send command  command=uboot_env get active_partition
    ${output}=  ssh.read output
    ${active_partition_id}=  Get Regexp Matches  ${output}  \\d+
    ${active_partition_id}=  Convert To Integer  ${active_partition_id[0]}
    ssh.Disconnect
    [Return]  ${active_partition_id}

Set Feature On Expected Value
    [Documentation]  This keyword check if feature have expected value if no, this keyword change it.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Set Feature On Expected Value  parameter=actAldSwUpdate  value=true
    ...
    [Arguments]  ${parameter}  ${value}
    ${feature_list}=  admin.get managed objects  FEATCADM_A
    FOR  ${ITEM}  IN  @{feature_list}
        ${feature_status}=  Set Variable If  '${ITEM['parameters']['${parameter}']}'=='${True}'  true
    END
    [Return]  ${feature_status}
    Run Keyword If  '${value}'=='true' and '${feature_status}'=='true'
    ...  Log  Parameter ${parameter} is set on: ${feature_status}  console=${true}
    ...  ELSE IF  '${value}'=='true' and '${feature_status}'!='true'  Run Keywords
    ...  Log  Parameter ${parameter} is set on: false. Expected value: true. => Featrue activation.  console=${true}
    ...  AND
    ...  Turn ON Or OFF Feature  ${parameter}  ${value}
    ...  ELSE IF  '${value}'=='false' and '${feature_status}'=='true'  Run Keywords
    ...  Log  Parameter ${parameter} is set on: true. Expected value: false. => Feature deactivation.  console=${true}
    ...  AND
    ...  Turn ON Or OFF Feature  ${parameter}  ${value}
    ...  ELSE
    ...  Log  Parameter ${parameter} is set on: false  console=${true}

Turn ON Or OFF Feature
    [Documentation]
    [Arguments]  ${parametr}  ${value}
    ${FEATCADM_DN}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    admin.perform parameter recommissioning  ${FEATCADM_DN}  ${parametr}  update  ${value}  ${SKIP_PARAMETER_RELATION_ERRORS}

Check If GPS Is Configured
    [Documentation]  Keyword checks if there is GPS configured on BTS.
    ...  **Author:** tomasz.marchewka@nokia.com
    ${sync}=  admin.get bts sync source status
    ${syncInputTypes}=  Create List
    FOR  ${item}  IN  @{sync['syncSourceInfo']}
        Append To List  ${syncInputTypes}  ${item['syncInputType']}
    END
    ${qty}=  Count Values In List  ${syncInputTypes}  ${expected_syncInputType}
    Run Keyword If  ${qty}==${0}  Fail  msg=There is no GPS in configuration

Get NMS State
    [Documentation]  Keyword returns given stateInfo parameter of NE3SADAPT object.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${parameter}
    ${sessions}=  admin.get managed objects  SESSION
    ${NE3SADAPT_parameters}=  Create List
    FOR  ${i}  IN  @{sessions}
        Run Keyword If  '${i['parameters']['type']}'=='NE3SADAPT'  Append To List  ${NE3SADAPT_parameters}  ${i}
    END
    FOR  ${i}  IN  @{NE3SADAPT_parameters}
        ${NMS_parameter_value}=  Set Variable  ${i['parameters']['stateInfo']['${parameter}']}
    END
    [Return]  ${NMS_parameter_value}

Set Timezone
    [Documentation]  Change timezone via recommissioning
    ...  **Example of simple usage:**
    ...  Set Timezone  (GMT+1) Europe/Warsaw
    ...
    [Arguments]  ${expected_timezone}
    Log  Set timeZone to ${expected_timezone} (restart needed)  console=${true}
    ${TIME_DN}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    admin.perform parameter recommissioning  ${TIME_DN}  timeZone  update  ${expected_timezone}  ${SKIP_PARAMETER_RELATION_ERRORS}  timeout=600

Get BTS Timezone
    ${timezone}=  admin.get bts time zone
    [Return]  ${timezone}

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
    ${cell_r}=  Get Regexp Matches  ${cell_dn}  (GN|WN|LN|NR)CE(L|LL)_R-\\d+
    Log To Console  Blocking ${cell_r[0]}...
    admin.block cell  dist_name=${cell_dn}  timeout=${timeout}

Unblock Selected Cell
    [Arguments]  ${cell_dn}  ${timeout}
    ${cell_r}=  Get Regexp Matches  ${cell_dn}  (GN|WN|LN|NR)CE(L|LL)_R-\\d+
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

Get Representative CellName
    [Arguments]  ${cell_dn}
    ${cell_parameters}  Run Keyword If  'LNCEL' in $cell_dn    admin.get cells info    cell_type=lte
    ...                      ELSE IF    'NRCELL' in $cell_dn   admin.get cells info    cell_type=nr
    ${cellName}  Evaluate  [cell_param['cellName'] for cell_param in ${cell_parameters} if '${cell_dn}' == cell_param['id']['configuration']]
    [Return]  ${cellName[0]}

Get Representative Cell _R
    [Arguments]  ${cell_dn}
    ${cell_parameters}  Run Keyword If  'LNCEL' in $cell_dn    admin.get cells info    cell_type=lte
    ...                      ELSE IF    'NRCELL' in $cell_dn   admin.get cells info    cell_type=nr
    ...                      ELSE IF    'WNCEL' in $cell_dn    admin.get cells info    cell_type=wcdma
    ...                      ELSE IF    'GNCEL' in $cell_dn    admin.get cells info    cell_type=gsm
    ${cell_dn_r}  Evaluate  [cell_param['id']['internal'] for cell_param in ${cell_parameters} if '${cell_dn}' == cell_param['id']['configuration']]
    [Return]  ${cell_dn_r[0]}

Detect RATs
    ${bts_info}  admin.get bts info
    ${rats}    Create List
    FOR  ${rat}  IN  @{bts_info['ratState']}
        Run Keyword If  '${bts_info['ratState']['${rat}']}'!='NO_CELLS'
        ...  Append To List  ${rats}  ${rat}
    END
    [Return]  ${rats}

Get BTS Name
    ${bts_info}  admin.get bts info
    ${bts_name}  Get From Dictionary  ${bts_info}  name
    [Return]  ${bts_name}

Configuration Reset With HWF
    [Arguments]  ${config_path}=/ffs/run/config
    [Documentation]  Reset configuration by removing /config folder on system module active partition.
    ...  **Author:** tomasz.marchewka@nokia.com
    Run Keyword If  '${BTS_TYPE}'=='singlecore'  Run Keywords
    ...  Log To Console  Removing folder ${config_path} on MSM active partition with reboot
    ...  AND  Run  sshpass -p ${ENB_ROOT_PASS} ssh ${ENB_ROOT_USER}@${MSM_IP} 'rm -r ${config_path}; reboot; exit'
    ...  ELSE IF  '${BTS_TYPE}'=='dualcore'  Run Keywords
    ...  Log To Console  Removing folder ${config_path} on MSM active partition with reboot
    ...  AND  Run  sshpass -p ${ENB_ROOT_PASS} ssh ${ENB_ROOT_USER}@${MSM_IP} 'rm -r ${config_path}; reboot; exit'
    ...  AND  Log To Console  Removing folder ${config_path} on ESM active partition with reboot
    ...  AND  Run  ssh ute@${VM2_IP} "sshpass -p ${ENB_ROOT_PASS} ssh ${ENB_ROOT_USER}@${ESM_IP} 'rm -r ${config_path}; reboot; exit'"

Check If Cells Configured On Other RMOD
    [Arguments]    ${given_rmod}
    ${rmods_list}  admin.get frm
    ${deployed_cells}  Create List
    ${rmods_cells_mapping}  Create Dictionary
    FOR  ${rmod}  IN  @{rmods_list}
        ${carrierList}  Get From Dictionary  ${rmod}  carrierList
        ${cells_from_carrier_list}  Get Cells From Carrier List  ${carrierList}
        Exit For Loop If  '${rmod['id']['configuration']}'=='${given_rmod}'
    END
    ${deployed_cells}  Combine Lists  ${cells_from_carrier_list}
    ${cells_list}  admin.get cell list
    ${cells}  Combine Lists    ${cells_list['cells']['lte']}
                      ...      ${cells_list['cells']['wcdma']}
                      ...      ${cells_list['cells']['gsm']}
                      ...      ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{cells}
        ${carrierList}  Get From Dictionary  ${cell}  carrierList
        ${rmods_from_carrier_list}  Get RMOD From Carrier List  ${carrierList}
        Set To Dictionary  ${rmods_cells_mapping}  ${cell['id']['configuration']}  ${rmods_from_carrier_list}
    END
    FOR  ${cell}  IN  @{deployed_cells}
        ${rmod_from_dict}  Get From Dictionary  ${rmods_cells_mapping}  ${cell}
        Remove Values From List  ${rmod_from_dict}  ${given_rmod}
        ${not_empty}  Run Keyword And Return Status  Should Not Be Empty  ${rmod_from_dict}
        Exit For Loop If  ${not_empty}
    END
    [Return]  ${not_empty}

Get Cells From Carrier List
    [Arguments]  ${given_carrierlist}
    ${cells_from_carrier_list}  Create List
    FOR  ${item}  IN  @{given_carrierlist}
        ${string}  ${ignore}  Split String From Right  ${item['id']['configuration']}  separator=/  max_split=1
        Append To List  ${cells_from_carrier_list}  ${string}
    END
    ${cells_from_carrier_list}  Remove Duplicates  ${cells_from_carrier_list}
    [Return]  ${cells_from_carrier_list}

Get RMOD From Carrier List
    [Arguments]  ${given_carrierlist}
    ${rmods_from_carrier_list}  Create List
    FOR  ${item}  IN  @{given_carrierlist}
        ${string}  ${ignore}  Split String From Right  ${item['antennaLineId']['configuration']}  separator=/  max_split=1
        Append To List  ${rmods_from_carrier_list}  ${string}
    END
    ${rmods_from_carrier_list}  Remove Duplicates  ${rmods_from_carrier_list}
    [Return]  ${rmods_from_carrier_list}

Remove From RAT List
    [Arguments]  ${technology}
    [Documentation]  Keyword removes indicated technology/technologies from available RATs list.
    ...              There will be no changes made if all RATs from list are selected.
    ...              Example of usage:    Remove From RAT List  WG
    ${to_be_removed}  Create List
    ${rats_copy}  Copy List  ${rats}
    ${wcdma_chosen}  Run Keyword And Return Status  Should Contain  ${technology}  W  ignore_case=${True}
    ${gsm_chosen}    Run Keyword And Return Status  Should Contain  ${technology}  G  ignore_case=${True}
    ${lte_chosen}    Run Keyword And Return Status  Should Contain  ${technology}  L  ignore_case=${True}
    ${nr_chosen}     Run Keyword And Return Status  Should Contain  ${technology}  N  ignore_case=${True}
    FOR  ${item}  IN  @{rats}
        Run Keyword If  ${${item}_chosen}  Append To list  ${to_be_removed}  ${item}
    END
    ${invalid}  Run Keyword And Return Status  Lists Should Be Equal  ${to_be_removed}  ${rats}
    FOR  ${item}  IN  @{to_be_removed}
        Run Keyword If  not ${invalid}  Run Keywords
        ...       Log To Console  == Removing '${item}' from RATs list ==
        ...  AND  Remove Values From List  ${rats_copy}  ${item}
        ...  AND  Set Test Variable  ${rats}  ${rats_copy}
    END
    Run Keyword If  ${invalid}  Log  Removal of ${to_be_removed} would result in empty RATs list. No changes were made.  WARN

Set Parameter To Expected Value
    [Documentation]  Keyword checks if parameter under given dist_name has expected value and if not, changes it.
    ...              Example of usage:
    ...              Set Parameter To Expected Value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...                                               parameter=activateOranO1NetconfService
    ...                                               expected_value=false
    [Arguments]  ${dist_name}  ${parameter}  ${expected_value}  ${operation}=update
    ${slash_count}  Get Count  ${dist_name}  /
    ${string}  Run Keyword If  ${slash_count}!=0
    ...        Split String From Right  ${dist_name}  separator=/  max_split=1
    ...  ELSE  Split String From Right  ${dist_name}  separator=-  max_split=1
    ${object}  Run Keyword If  ${slash_count}!=0
    ...        Fetch From Left   ${string[1]}  marker=-
    ...  ELSE  Fetch From Right  ${string[0]}  marker=-
    ${object_a}  admin.Get Managed Objects  ${object}_A
    FOR  ${item}  IN  @{object_a}
        ${parameter_value}  Set Variable If  '${item['parameters']['${parameter}']}'=='True'  true
        ...  '${item['parameters']['${parameter}']}'=='False'  false  ${item['parameters']['${parameter}']}
    END
    Run Keyword If  '${operation}'=='delete'  Run Keywords
    ...           Log To Console
    ...           Deleting parameter "${parameter}"
    ...      AND  admin.Perform Parameter Recommissioning  dist_name=${dist_name}
    ...                                                    parameter=${parameter}
    ...                                                    operation=${operation}
    ...                                                    value=${expected_value}
    ...  ELSE IF  '${parameter_value}'!='${expected_value}'  Run Keywords
    ...           Log To Console
    ...           Parameter "${parameter}" is set to: ${parameter_value}. Expected value: ${expected_value}. => Changing to expected value.
    ...      AND  admin.Perform Parameter Recommissioning  dist_name=${dist_name}
    ...                                                    parameter=${parameter}
    ...                                                    operation=${operation}
    ...                                                    value=${expected_value}
    ...     ELSE  Log To Console
    ...           Parameter "${parameter}" is already set to expected value: ${parameter_value}

Ensure parameter on all RMODs
    [Arguments]    ${parameter_name}    ${desired_value}
    ${change_value}    Set Variable     change_value
    ${admin_log_path}    Set Variable     /home/ute/test_results/admin_api_deep/
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_log_path}  update_interval=500  alias=${change_value}
    ${origin_list_rmods}    Create List
    ${origin_parameter_name}    Create List
    ${origin_values}    Create List
    ${rmod_par_list}=  admin.get managed objects    RMOD_A    connection=${change_value}
    FOR  ${par}  IN  @{rmod_par_list}
        ${rmod_dist_name}=    Get From Dictionary    ${par}    distName
        IF  'BTS_CONF' not in $rmod_dist_name  CONTINUE  # For RMOD with GSM cells, there is additional MO under /MRBTS-1/RAT-1/GTS-1/SCF-1/RMOD_A-x
        ${parameters}=    Get From Dictionary    ${par}    parameters
        ${par_value}=    Get From Dictionary    ${parameters}   ${parameter_name}
        ${ignore}   ${rmod_a}=    Split String From Right    ${rmod_dist_name}   separator=SCF-1/
        ${rmod}=    Replace String    ${rmod_a}    search_for=_A    replace_with=
        Run Keyword If    '${par_value}'!='${desired_value}'    Run Keywords
        ...      Log to console    Change parameter ${parameter_name} to ${desired_value} on ${rmod}
        ...      AND     Append To List    ${origin_list_rmods}    ${rmod}
        ...      AND     Append To List    ${origin_parameter_name}     ${parameter_name}
        ...      AND     Append To List    ${origin_values}     ${par_value}
        ...      AND    admin.Perform Parameter Recommissioning     dist_name=${rmod}
        ...                                                         parameter=${parameter_name}
        ...                                                         operation=update
        ...                                                         value=${desired_value}
        ...                                                         connection=${change_value}
    END
    Set Suite Variable    ${origin_list_rmods}
    Set Suite Variable    ${origin_parameter_name}
    Set Suite Variable    ${origin_values}
    [Teardown]  Run Keyword And Ignore Error  admin.teardown admin    alias=${change_value}

Restore parameter on all RMODs
    [Documentation]    This is a continuation of KW: Ensure parameter on all RMODs.
    ...     The KW restores parameter changed in Ensure parameter on all RMODs.
    ${change_value}    Set Variable     change_value
    ${admin_log_path}    Set Variable     /home/ute/test_results/admin_api_deep/
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_log_path}   update_interval=500  alias=${change_value}
    ${origin_RMOD_par}=    Get Length    ${origin_list_rmods}
    FOR    ${index}    IN RANGE    ${origin_RMOD_par}
        Log to console    Restoring ${origin_parameter_name}[${index}] to ${origin_values}[${index}] on ${origin_list_rmods}[${index}]
        admin.Perform Parameter Recommissioning    dist_name=${origin_list_rmods}[${index}]
        ...                                        parameter=${origin_parameter_name}[${index}]
        ...                                        operation=update
        ...                                        value=${origin_values}[${index}]
        ...                                        connection=${change_value}
    END
    [Teardown]  Run Keyword And Ignore Error  admin.teardown admin    alias=${change_value}


Ensure NORMAL value on all RMODs
    ${actRadio_value}       Set Variable     actRadio_value
    ${admin_log_path}  Set Variable     /home/ute/test_results/admin_api_deep_sleep/
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_log_path}  update_interval=500  alias=${actRadio_value}
    ${feature_list}=  admin.get managed objects  FEATCADM_A     connection=${actRadio_value}
    ${parameters}=    Get From Dictionary    ${feature_list[0]}    parameters
    ${actRadio_par}=  Get From Dictionary    ${parameters}    actRadioDeepSleepTimeSchedule
    ${FEATCADM_DN}=    Set Variable      MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Run Keyword If    '${actRadio_par}'!='False'    Run Keywords
        ...      Log to console    Change parameter actRadioDeepSleepTimeSchedule to FALSE
        ...      AND    admin.Perform Parameter Recommissioning     dist_name=${FEATCADM_DN}
        ...                                                         parameter=actRadioDeepSleepTimeSchedule
        ...                                                         operation=update
        ...                                                         value=false
        ...                                                         connection=${actRadio_value}
        ...     ELSE    Log To Console  Parameter actRadioDeepSleepTimeSchedule is already set to false
    Set Suite Variable    ${actRadio_par}
    Ensure parameter on all RMODs      energySavingMode     NORMAL
    ${RMOD_status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds  10min  30s  admin.assert every    RMOD    ${RMOD_expected_states}    alias=${actRadio_value}
    [Teardown]  Run Keyword And Ignore Error  admin.teardown admin    alias=${actRadio_value}


Restore parameters value on all RMODs
    Restore parameter on all RMODs
    ${restore_value}       Set Variable     restore_value
    ${admin_log_path}  Set Variable     /home/ute/test_results/admin_api_restore_value
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_log_path}  update_interval=500  alias=${restore_value}
    ${FEATCADM_DN}=    Set Variable      MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Run Keyword If    '${actRadio_par}'!='False'    Run Keywords
        ...      Log to console    Change parameter actRadioDeepSleepTimeSchedule to ${actRadio_par}
        ...      AND    admin.Perform Parameter Recommissioning     dist_name=${FEATCADM_DN}
        ...                                                         parameter=actRadioDeepSleepTimeSchedule
        ...                                                         operation=update
        ...                                                         value=true
        ...                                                         connection=${restore_value}
    [Teardown]  Run Keyword And Ignore Error  admin.teardown admin    alias=${restore_value}

Turn off deepsleep single 5G RU
    [Documentation]  Turns off deepsleep when there is single radio with 5G cells that have deepsleep feature on.
    ...    Applied on MRBTS 8036.
    common.Ensure NORMAL value on all RMODs
    Run Keyword If  ${SETUP_ONAP}==False    Run Keywords
    ...    Log To Console  BTS Reset site...
    ...    AND    admin.reset site  timeout=700
    ...    AND    Wait Until Keyword Succeeds  10min  30s  Check If SMOD Is Pingable
    ...    AND    Full Check After Start-up

Run keyword except for FSMF
    [Arguments]      ${keyword_arg}
    Run Keyword If  '${SMOD_COMPOSITION}'!='FSMF' and '${SMOD_COMPOSITION}'!='FSMF+FSMF' and '${MRBTS_ID}'!='8036'
    ...      Run Keyword    ${keyword_arg}
    ...      ELSE   Log To Console  Keyword skipped - ${SMOD_COMPOSITION}

Set shutdownWindow To Be Not Higher Than Preferred Value
    [Documentation]  Keyword checks if shutdownWindow value for LNBTS or NRBTS is higher than ${preferred_shutdownWindow}. If it is, then
    ...              preferred_shutdownWindow is set instead with shutdownStepAmount calculated accordingly.
    ...              If given ${preferred_shutdownWindow} is in allowed range (6-180) but not divisable by 6, then it is set to be lower closest
    ...              number divisable by 6. Otherwise it is set to 60 by default.
    [Arguments]  ${preferred_shutdownWindow}=60
    ${is_supported_value}  Evaluate  6 <= ${preferred_shutdownWindow} <= 180
    ${reminder}  Evaluate  ${preferred_shutdownWindow} % 6
    ${preferred_shutdownWindow}  Run Keyword If  ${is_supported_value} and ${reminder} != 0  Evaluate      ${preferred_shutdownWindow} - ${reminder}
    ...                                 ELSE IF  ${is_supported_value}                       Set Variable  ${preferred_shutdownWindow}
    ...                                    ELSE                                              Set Variable  60
    FOR  ${rat}  IN  @{rats}
        Continue For Loop If  'wcdma' in $rat or 'gsm' in $rat
        ${params_change_list}  Create List
        ${prefixBTS}  Set Variable If  'lte' in $rat  LN  NR
        ${param_list}  admin.get managed objects  ${prefixBTS}BTS_A
        ${prefixBTS_DistName}        Set Variable If  'lte' in $rat  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ${shutdownWindow_value}      Set Variable  ${param_list[0]['parameters']['shutdownWindow']}
        ${shutdownStepAmount_value}  Set Variable  ${param_list[0]['parameters']['shutdownStepAmount']}
        ${shutdownWindow_needs_change}  Evaluate  ${shutdownWindow_value} > ${preferred_shutdownWindow}
        ${shutdownWindow_change}     Set Variable If  ${shutdownWindow_needs_change}  ${preferred_shutdownWindow}  ${shutdownWindow_value}
        ${rd}  Evaluate  int(${shutdownWindow_change}/6)
        ${shutdownStepAmount_change}  Set Variable If  ${shutdownWindow_change} / ${shutdownStepAmount_value} < 6  ${rd}  ${shutdownStepAmount_value}
        &{p1}  Create Dictionary  parameterName=shutdownWindow  operation=update  value=${shutdownWindow_change}
        &{p2}  Create Dictionary  parameterName=shutdownStepAmount  operation=update  value=${shutdownStepAmount_change}
        Run Keyword If  ${shutdownWindow_needs_change}  Append To List  ${params_change_list}  ${p1}  ${p2}
        Run Keyword If  ${params_change_list} != []  Run Keywords
        ...          Log To Console
        ...          Setting shutdownWindow=${shutdownWindow_change} and shutdownStepAmount=${shutdownStepAmount_change} under ${prefixBTS_DistName}
        ...     AND  admin.perform_object_recommissioning  dist_name=${prefixBTS_DistName}
        ...                                                parameter=${params_change_list}
        ...                                                operation=update
        ...                                                skip_parameter_relation_errors=${FALSE}
        ...                                                should_activate=${True}
    END

Ensure Managed Objects Are Created
    [Arguments]  ${object}  ${expected_amount}=1
    ${managed}  Get Managed Objects  ${object}
    Length Should Be  ${managed}  ${expected_amount}
    [Return]  ${managed}

Get RESET_HISTORY Timestamp
    ${reset_history}  Get Managed Objects  RESET_HISTORY
    ${reset_timestamp_dict}  Create Dictionary
    FOR  ${item}  IN  @{reset_history}
        ${fct}  Set Variable If  '/BTS_L-1/' in $item['distName']  FCT-1011  FCT-2011
        ${timestamp}  Set Variable  ${item['parameters']['resetHistoryItems'][0]['timestamp']}
        Set To Dictionary  ${reset_timestamp_dict}  ${fct}  ${timestamp}
    END
    [Return]  ${reset_timestamp_dict}

Disable BTSLog On VM
    [Documentation]  Keyword sends kill signal to BTSLog process.
    ${disable_btslog_status}  Run Keyword And Return Status  Variable Should Exist  ${DISABLE_BTSLOG}
    ${DISABLE_BTSLOG}  Run Keyword If  ${disable_btslog_status}  Evaluate  "${DISABLE_BTSLOG}".upper()
                       ...                                 ELSE  Set Variable  TRUE
    ${sigkill_result}  Run Keyword If  "${DISABLE_BTSLOG}"!="FALSE"  Run  pgrep -i btslog | xargs -rt kill -9
    Run Keyword If  "${sigkill_result}"!="None" and "${sigkill_result}"!=""  Log To Console  === BTS Log was running and is now disabled ===

BBMOD Mapping
    ${bts_info}  admin.get bts info
    ${bbmods_mapping}  Create Dictionary
    FOR  ${item}  IN  @{bts_info['basebandModules']}
        Set To Dictionary  ${bbmods_mapping}  ${item['id']['internal']}  ${item['id']['configuration']}
    END
    [Return]  ${bbmods_mapping}

Mapping RMOD To RMOD_R
    ${bts_info}=  admin.get bts info
    ${RMOD_to_RMOD_R}=  Create Dictionary
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        Set To Dictionary  ${RMOD_to_RMOD_R}  ${item['id']['configuration']}  ${item['id']['internal']}
    END
    [Return]    ${RMOD_to_RMOD_R}

Get Resettable BBMOD
    ${BBMOD_parameters}  Get Managed Objects  BBMOD_R
    ${BBMOD_R_valid}     Create List
    FOR  ${bbmod}  IN  @{BBMOD_parameters}
        Continue For Loop If  'FBBC' in $bbmod['parameters']['productName']
        Run Keyword If  '${bbmod['parameters']['geranSupport']}'=='False' and '${bbmod['parameters']['utranSupport']}'=='False'
        ...  Append To List  ${BBMOD_R_valid}  ${bbmod['distName']}
    END
    [Return]  ${BBMOD_R_valid}

Get memory usage for unit
     [Arguments]    ${SM_ip_adress}   ${container_name}  ${unit_user}    ${unit_ip_adress}    ${unit_password}    ${alias_test}
     ${get_mem_usage_cmd}=    Set Variable    free | grep Mem | awk '{ print int($3/$2 * 100) "%"}'
     SSHLibrary.Open Connection    ${SM_ip_adress}    alias=${alias_test}    timeout=10s
     SSHLibrary.Login    ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
     SSHLibrary.Write    lxc-attach -n ${container_name}
     SSHLibrary.Read Until    root@FHNET
     SSHLibrary.Write    ssh -oStrictHostKeyChecking=no ${unit_user}@${unit_ip_adress}
     SSHLibrary.Read Until    You are about to access a private system
     SSHLibrary.Write    ${unit_password}
     ${loginOutput}=    SSHLibrary.Read
     ${match}=    Evaluate    bool(re.search(r".*Permission denied.*", '''${loginOutput}'''))  re
     Run Keyword If    ${match}   Run Keywords
     ...          Log To Console    Removing known_hosts file...
     ...          AND    SSHLibrary.Write    rm /user/toor4nsn/.ssh/*
     ...          AND    Log To Console    Connecting again to FHS
     ...          AND    SSHLibrary.Read Until    root@FHNET
     ...          AND    SSHLibrary.Write    ssh -oStrictHostKeyChecking=no ${unit_user}@${unit_ip_adress}
     ...          AND    SSHLibrary.Read Until    You are about to access a private system
     ...          AND    SSHLibrary.Write    ${unit_password}
     ${logged_to_fhs}  Run Keyword And Return Status  SSHLibrary.Read Until  ${unit_user}@fhs
     IF  not ${logged_to_fhs}  RETURN  None
     SSHLibrary.Write    ${get_mem_usage_cmd}
     ${cmd_output}=    SSHLibrary.Read Until Regexp   \\d%
     ${cmd_output_splitted}=  Split String  ${cmd_output}  \n
     ${usage_result}=  Convert To Integer    ${cmd_output_splitted[-1][0:-1]}
     [Return]   ${usage_result}
     [Teardown]  SSHLibrary.Close Connection

Check Memory Usage On FHS
    [Arguments]   ${set_memory_threshold_value}
    ${FHS_memory_usage}=       Set Variable     FHS_memory
    ${admin_log_path_FHS}=     Set Variable     /home/ute/test_results/admin_api_fhs_memory/
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_log_path_FHS}  update_interval=500  alias=${FHS_memory_usage}
    ${FHS_list}=  admin.get managed objects    FHS_L     connection=${FHS_memory_usage}
    FOR  ${i}  IN   ${FHS_list}
        ${parameters}=    Get From Dictionary    ${FHS_list[0]}    parameters
        ${FHS_dist_name_L}=    Get From Dictionary    ${FHS_list[0]}   distName
        ${FHS_dist_name}=    Replace String    ${FHS_dist_name_L}   search_for=_L    replace_with=
        ${FHS_dist_splited}     Split String  ${FHS_dist_name}  /
        ${FHS_name}   Set Variable    ${FHS_dist_splited[-1]}
        ${FHS_ipAdrress}=  Get From Dictionary    ${parameters}    ipAddress
        ${FHS_primaryControllerDN}=  Get From Dictionary    ${parameters}   primaryControllerDN
        ${BTS_1_or_4}=  Evaluate  re.search(r'BTS-(\\d+)','''${FHS_primaryControllerDN}''').group(1)  re
        ${actual_usage_result}    Run Keyword If    '${BTS_1_or_4}'=='1'
        ...             Get memory usage for unit   ${MSM_IP}  0x1018   ${UNIT_USER}  ${FHS_ipAdrress}  ${UNIT_PASS}   ${FHS_memory_usage}
        ...    ELSE     Get memory usage for unit   ${ESM_IP}  0x2018   ${UNIT_USER}  ${FHS_ipAdrress}  ${UNIT_PASS}   ${FHS_memory_usage}
        ${actual_usage_result}    Run Keyword If  '${actual_usage_result}'!='None'
        ...             Set Variable  ${actual_usage_result}
        ...    ELSE IF  '${BTS_1_or_4}'=='1'
        ...             Get memory usage for unit   ${MSM_IP}  0x1018   ${ENB_ROOT_USER}  ${FHS_ipAdrress}  ${ENB_ROOT_PASS}   ${FHS_memory_usage}
        ...    ELSE     Get memory usage for unit   ${ESM_IP}  0x2018   ${ENB_ROOT_USER}  ${FHS_ipAdrress}  ${ENB_ROOT_PASS}   ${FHS_memory_usage}
        Log To Console  Memory usage on ${FHS_dist_name} is ${actual_usage_result}%
        Run Keyword If  ${actual_usage_result}>${set_memory_threshold_value}
        ...      Fail  msg=Memory usage above normal on ${FHS_name}- ${actual_usage_result}%
    END
    [Teardown]  admin.teardown admin    alias=${FHS_memory_usage}

######################
### RESER COUNTERS ###
######################
Clear Reset Counter
    [Documentation]   This keyword connect to system module via SSH and set to 0 reset counter
    SSHLibrary.Open Connection  ${MSM_IP}
    SSHLibrary.Login  ${ENB_ROOT_USER}  ${ENB_ROOT_PASS}
    ${ssh_command}=  SSHLibrary.Execute Command  uboot_env -r set reset_counter=0
	[Teardown]    SSHLibrary.Close Connection

Check Reset Counter
    [Documentation]   This keyword connect to system module via SSH and return actual reset counter
    SSHLibrary.Open Connection    ${MSM_IP}
    SSHLibrary.Login    ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
    ${ssh_command}=    SSHLibrary.Execute Command  uboot_env -r get reset_counter
    ${reset_count}=  Should Match Regexp  ${ssh_command}  \\d+
    ${reset_count_before_action}=  Convert To Number  ${reset_count}
	[Teardown]    SSHLibrary.Close Connection
    [Return]   ${reset_count_before_action}

Get Reset Counter From Blackbox
    [Documentation]  Keyword returns actual reset counter number from blackbox file.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${host}=toor4nsn@192.168.255.129  ${COLLECT_BLACKBOX_FILE}=${False}  ${iteration}=none
    ${timestamp}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${active_partition}=  Get Active Partition
    ${connect_to_bts}=  Set Variable  sshpass -p ${ENB_ROOT_PASS} ssh ${host}
    ${blackbox_paths}  Create List  /ffs/fs${active_partition}/config/lifedata/blackbox
    ...                             /ffs/fs${active_partition}/logs/lifetimedata/blackbox
    FOR  ${blackbox_path}  IN  @{blackbox_paths}
        ${blackbox_txt}=  Run  ${connect_to_bts} cat ${blackbox_path}
        Exit For Loop If  not 'No such file or directory' in $blackbox_txt
    END
    ${regex}=  Set Variable  (?i)(RESET\\sCOUNTER:\\s(?P<reset_counter_number>\\d+))
    ${reset_counter_number}=  Get Regexp Matches  ${blackbox_txt}  ${regex}  reset_counter_number
    ${reset_counter_number}=  Convert To Integer  ${reset_counter_number[0]}
    Log To Console  RESET COUNTER: ${reset_counter_number}
    Run Keyword If  ${COLLECT_BLACKBOX_FILE}==${True} and '${iteration}'!='none'
    ...    Append To File  ${RESULTS}/${iteration}/blackbox_${timestamp}.txt  ${blackbox_txt}
    ...    ELSE IF  ${COLLECT_BLACKBOX_FILE}==${True} and '${iteration}'=='none'
    ...    Append To File  ${RESULTS}/blackbox_${timestamp}.txt  ${blackbox_txt}
    [Return]  ${reset_counter_number}

Load JSON File
    [Documentation]  Keyword reads json file content and return data.
    [Arguments]  ${json_path}
    ${file}=  OperatingSystem.Get File  ${json_path}
    ${body}=  Evaluate  ${file}
    [Return]  ${body}

Get LNBTS ID
    ${LNBTS_DN}=  admin.get id for current  LNBTS
    ${LNBTS_ID}=  Evaluate  re.search(r'LNBTS_R-(\\d+)','''${LNBTS_DN}''').group(1)  re
    [Return]  ${LNBTS_ID}

# below keywords returning as output configuration IDs

Get RMODs
    ${bts_info}=  admin.get bts info
    ${rmods}=  Create List
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        Append To List  ${rmods}  ${item['id']['configuration']}
    END
    Set Test Variable  ${rmods}

Get BBMODs
    ${bts_info}  admin.get bts info
    ${bbmods}  Create List
    FOR  ${item}  IN  @{bts_info['basebandModules']}
        Append To List  ${bbmods}  ${item['id']['configuration']}
    END
    Set Test Variable  ${bbmods}

Get GNSSEs
    ${bts_info}  admin.get bts info
    ${gnsses}  Create List
    FOR  ${item}  IN  @{bts_info['gnsse']}
        ${status}  Run Keyword And Return Status  Append To List  ${gnsses}  ${item['id']['configuration']}
        Run Keyword If  not ${status}  Log  ${item['id']['internal'][-9:]} - the device is not commissioned    WARN
    END
    [Return]  ${gnsses}
#    Set Test Variable  ${gnsses}

#Shared ALDs check
#    [Documentation]  This keyword checks if second testline with shared multiret is reachable by mplane
#    ...  If second TL is pingable than ALDs are grouped for shared and non-shared
#    ...  **Author:** tomasz.januszkiewicz@nokia.com
#    ...  **Example of simple usage:**
#    ...
#    ...  Shared ALDs check    ALL    ${MRBTS_ID}
#    [Arguments]  ${ALD_R_RETs}    ${bts2_shared}
#    #  Mplane IPs for second TLs 10.42.182.114, 10.42.64.215, 10.42.18.55
#    ${second_bts_marquez}=    Run Keyword And Return Status  Check If Host Is Reachable    10.42.182.114
#    ${second_bts_rins}=    Run Keyword And Return Status  Check If Host Is Reachable    10.42.64.215
#    ${second_bts_binder}=    Run Keyword And Return Status  Check If Host Is Reachable    10.42.18.55
#    ${bts2_shared_int}=    convert to integer    ${bts2_shared}
#    ${shared_rets_list}=  Create List
#    ${nonsharedrets}=  Create List
#    #  Serial of shared multiret between Marquez and Binder
#    ${shared_rets_marquez}=  Set Variable  I0M2617205
#    #  Serial of shared multiret between Binder and Rins
#    ${shared_rets_rins}=  Set Variable  E4K1927343G
#    ${ald_parameters}=  admin.get managed objects  ALD_R
#    FOR  ${serial}  IN  @{ald_parameters}
#        ${serial_var}=  Set Variable  ${serial['parameters']['serialNumber']}
#        ${serial_sub}=   Get Substring  ${serial_var}  0  10
#        ${serial_marquez}=  Run Keyword And Return Status  Should Contain  ${shared_rets_marquez}  ${serial_sub}
#        ${serial_rins}=  Run Keyword And Return Status  Should Contain  ${shared_rets_rins}  ${serial_sub}
#        Run Keyword If  ${serial_marquez}==${TRUE} and '${bts2_shared_int}'=='5046' and '${second_bts_marquez}'=='True'
#        ...  Append To List  ${shared_rets_list}  ${serial['distName']}
#        Run Keyword If  ${serial_rins}==${TRUE} and '${bts2_shared_int}'=='5046' and '${second_bts_rins}'=='True'
#        ...  Append To List  ${shared_rets_list}  ${serial['distName']}
#        Run Keyword If  ${serial_rins}==${TRUE} and '${bts2_shared_int}'=='9040' and '${second_bts_binder}'=='True'
#        ...  Append To List  ${shared_rets_list}  ${serial['distName']}
#    END
#    log to console    Active, shared multirets: ${shared_rets_list}
#    FOR  ${serial_ald}  IN  @{ald_parameters}
#        ${serial_ald_var}=  Set Variable  ${serial_ald['distName']}
#        ${serial_shared}=  Run Keyword And Return Status  Should Contain  ${shared_rets_list}  ${serial_ald_var}
#        Run Keyword If  ${serial_shared}==${FALSE}
#        ...  Append To List  ${nonsharedrets}  ${serial_ald['distName']}
#    END
#    log to console    Inactive shared multirets and not-shared ALDs between second BTS: ${nonsharedrets}
#    log to console    Verify Shared multirets state during second BTS OnAir
#    FOR  ${ret_shared}  IN  @{shared_rets_list}
#        Check Dedicated ALD State  ${ret_shared}  ${ALD_expected_states}
#    END
#    log to console    Verify inactive shared multirets and not-shared ALDs state
#    FOR  ${ret}  IN  @{nonsharedrets}
#        Check Dedicated ALD State  ${ret}  ${ALD_expected_state_powerOff}
#    END

######################
### RMODs RELATED ###
######################
RMOD Chain Detection
    [Documentation]  Keyword gets list of all RMODs and checks if any are in chain and sets two dictionaries as test variables:
    ...              ${AVAILABLE_CHAINS_INDEX} consisting of chain index number as KEY and subdictionary with RMOD=chain_position as VALUE;
    ...              ${RMOD_TO_CHAIN_INDEX_MAPPING} consisting of RMOD as KEY and its corresponding chain index as VALUE.
    ...              If there are no RMODs in chain in configuration, then both dictionaries will be empty.
    ...              ***
    ...              Returned values example:
    ...              ${AVAILABLE_CHAINS_INDEX}={1: {'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-99': '1', 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-90': '2',
    ...                                        'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-91': '3', 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-92': '4'},
    ...                                        2: {'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-88': '1', 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-80': '2',
    ...                                        'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-81': '3'}}
    ...              ${RMOD_TO_CHAIN_INDEX_MAPPING}={'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-99': 1, 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-90': 1,
    ...                                             'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-91': 1, 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-92': 1,
    ...                                             'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-88': 2, 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-80': 2,
    ...                                             'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-81': 2}
    ${AVAILABLE_CHAINS_INDEX}       Create Dictionary
    ${RMOD_TO_CHAIN_INDEX_MAPPING}  Create Dictionary
    Set Test Variable  ${AVAILABLE_CHAINS_INDEX}
    Set Test Variable  ${RMOD_TO_CHAIN_INDEX_MAPPING}
    Get RMODs
    ${chain_counter}  Set Variable  ${1}
    FOR  ${rmod}  IN  @{rmods}
        ${chain_dict}  Get RMOD Chain Position  ${rmod}
        Continue For Loop If  '${rmod}' not in $chain_dict
        ${was_mapped}  Map RMOD To Chain Index  ${chain_dict}  ${chain_counter}
        Continue For Loop If  not ${was_mapped}
        Set To Dictionary  ${AVAILABLE_CHAINS_INDEX}  ${chain_counter}  ${chain_dict}
        ${chain_counter}  Set Variable  ${chain_counter+1}
    END

Map RMOD To Chain Index
    [Documentation]  This KW is intended to work with "RMOD Chain Detection" and variables it generates.
    ...              It takes RMOD from specified chain dictionary and maps it to corresponding chain index.
    [Arguments]  ${chain_dict}  ${chain_counter}
    ${was_mapped}  Set Variable  False
    FOR  ${rmod}  IN  @{chain_dict}
        Continue For Loop If  '${rmod}' in $RMOD_TO_CHAIN_INDEX_MAPPING
        Set To Dictionary  ${RMOD_TO_CHAIN_INDEX_MAPPING}  ${rmod}  ${chain_counter}
        ${was_mapped}  Set Variable  True
    END
    [Return]  ${was_mapped}

Get RMOD Chain Position
    [Documentation]  Keyword checks if given RMOD is connected to other RMOD(s) through cablink and returns dictionary
    ...              with each RMOD as key and their position in chain as value.
    ...              If given RMOD is not in chain, then returned dictionary is empty.
    ...              ***
    ...              Example of use:    Get RMOD Chain Position  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-91
    ...              ***
    ...              Returned value example:
    ...              ${chain_position}={'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-99': '1', 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-90': '2',
    ...                                 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-91': '3', 'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-92': '4'}
    [Arguments]  ${rmod_id}
    ${bts_info}  admin.get bts info
    ${bts_cables}  Get From Dictionary  ${bts_info}  cables
    ${chain_position}   Create Dictionary
    ${cablink_dict}     Create Dictionary
    ${first_in_chain}     Create List
    ${further_in_chain}   Create List
    ${cablinks_in_chain}  Create List
    FOR  ${connection}  IN  @{bts_cables}
        ${1st_is_rmod}  Run Keyword And Return Status  Should Contain  ${connection['firstEndPointId']['configuration']}   RMOD
        ${2nd_is_rmod}  Run Keyword And Return Status  Should Contain  ${connection['secondEndPointId']['configuration']}  RMOD
        Continue For Loop If  not ${1st_is_rmod} and not ${2nd_is_rmod}
        ${cablink_id}  Fetch From Right  ${connection['id']['configuration']}  marker=/
        ${1st_string}  ${ignore}  Split String From Right  ${connection['firstEndPointId']['configuration']}   separator=/  max_split=1
        ${2nd_string}  ${ignore}  Split String From Right  ${connection['secondEndPointId']['configuration']}  separator=/  max_split=1
        ${endpoints_list}  Create List  ${1st_string}  ${2nd_string}
        Set To Dictionary  ${cablink_dict}  ${cablink_id}  ${endpoints_list}
        Run Keyword If  not ${1st_is_rmod}
        ...             Append To List  ${first_in_chain}     ${2nd_string}
        ...       ELSE  Run Keywords
        ...             Append To List  ${further_in_chain}   ${1st_string}  ${2nd_string}
        ...        AND  Append To List  ${cablinks_in_chain}  ${cablink_id}
    END
    ${selected_cablinks}  Run Keyword If  '${rmod_id}' in $further_in_chain
    ...                                   Find Cablinks In Chain For Specified RMOD  ${rmod_id}  ${cablink_dict}  ${cablinks_in_chain}
    ...                             ELSE  Create List
    FOR  ${cablink}  IN  @{selected_cablinks}
        ${endpoints}  Get From Dictionary  ${cablink_dict}  ${cablink}
        Continue For Loop If  '${endpoints[0]}' not in $first_in_chain and '${endpoints[1]}' not in $first_in_chain
        Run Keyword If  '${endpoints[0]}' in $first_in_chain  Run Keywords
        ...             Set To Dictionary  ${chain_position}  ${endpoints[0]}  1
        ...        AND  Set To Dictionary  ${chain_position}  ${endpoints[1]}  2
        ...       ELSE  Run Keywords
        ...             Set To Dictionary  ${chain_position}  ${endpoints[1]}  1
        ...        AND  Set To Dictionary  ${chain_position}  ${endpoints[0]}  2
        Remove Values From List  ${further_in_chain}   ${endpoints[0]}  ${endpoints[1]}
        Remove Values From List  ${selected_cablinks}  ${cablink}
    END
    ${selected_cablinks_length}  Get Length  ${selected_cablinks}
    ${removed_cablink}  Set Variable If  ${selected_cablinks}!=[]  ${selected_cablinks[0]}
    Run Keyword If  ${selected_cablinks_length}==2  Remove Values From List  ${selected_cablinks}  ${selected_cablinks[0]}
    FOR  ${cablink}  IN  @{selected_cablinks}
        ${endpoints}  Get From Dictionary  ${cablink_dict}  ${cablink}
        ${1st_endpoint_in_chain_position}  Set Variable If  '${endpoints[0]}' in $chain_position  True  False
        ${2nd_endpoint_in_chain_position}  Set Variable If  '${endpoints[1]}' in $chain_position  True  False
        #### Previous loop ensured that there are two RMODs in chain_position with values 1 and 2 respectively.
        #### If any endpoint of selected cablink is in chain_position (indicating that previous RMOD from chain is already found),
        #### then the other endpoint needs to be set as key with value 3.
        Run Keyword If  ${1st_endpoint_in_chain_position}  Run Keywords
        ...             Set To Dictionary  ${chain_position}  ${endpoints[1]}  3
        ...        AND  Remove Values From List  ${further_in_chain}  ${endpoints[1]}
        ...    ELSE IF  ${2nd_endpoint_in_chain_position}  Run Keywords
        ...             Set To Dictionary  ${chain_position}  ${endpoints[0]}  3
        ...        AND  Remove Values From List  ${further_in_chain}  ${endpoints[0]}
        Exit For Loop If  ${selected_cablinks_length}<2
        ${chain_position_length}  Get Length  ${chain_position}
        ${removed_cablink_endpoints}  Get From Dictionary  ${cablink_dict}  ${removed_cablink}
        ${1st_endpoint_in_chain_position}  Set Variable If  '${removed_cablink_endpoints[0]}' in $chain_position  True  False
        ${2nd_endpoint_in_chain_position}  Set Variable If  '${removed_cablink_endpoints[1]}' in $chain_position  True  False
        Run Keyword If  ${1st_endpoint_in_chain_position}  Run Keywords
        ...             Set To Dictionary  ${chain_position}  ${removed_cablink_endpoints[1]}  ${chain_position_length+1}
        ...        AND  Remove Values From List  ${further_in_chain}  ${removed_cablink_endpoints[1]}
        ...    ELSE IF  ${2nd_endpoint_in_chain_position}  Run Keywords
        ...             Set To Dictionary  ${chain_position}  ${removed_cablink_endpoints[0]}  ${chain_position_length+1}
        ...        AND  Remove Values From List  ${further_in_chain}  ${removed_cablink_endpoints[0]}
        ${chain_position_length}  Get Length  ${chain_position}
        ${1st_endpoint_in_further_in_chain}  Set Variable If  '${endpoints[0]}' in $further_in_chain  True  False
        ${2nd_endpoint_in_further_in_chain}  Set Variable If  '${endpoints[1]}' in $further_in_chain  True  False
        Run Keyword If  ${1st_endpoint_in_further_in_chain}
        ...             Set To Dictionary  ${chain_position}  ${endpoints[0]}  ${chain_position_length+1}
        ...    ELSE IF  ${2nd_endpoint_in_further_in_chain}
        ...             Set To Dictionary  ${chain_position}  ${endpoints[1]}  ${chain_position_length+1}
    END
    [Return]  ${chain_position}

Find Cablinks In Chain For Specified RMOD
    [Documentation]  This KW is intended to work with "Get RMOD Chain Position" and variables it generates.
    ...              It takes given RMOD and finds cablinks only for its chain and returns them in a list ${cablinks_related_to_rmod_id}.
    [Arguments]  ${rmod_id}  ${cablink_dict}  ${cablinks_in_chain}
    ${cablinks_related_to_rmod_id}  Create List
    ${rmod_id_list}  Create List  ${rmod_id}
    ${cablinks_amount}  Get Length  ${cablink_dict}
    FOR  ${object}  IN RANGE  1  ${cablinks_amount}*2
        ${related_to_rmod_id}  Find Cablinks Related To RMOD  ${rmod_id_list}  ${cablink_dict}  ${cablinks_in_chain}
        ${cablink}  Set Variable  ${related_to_rmod_id['cablink']}
        ${rmod_id}  Set Variable  ${related_to_rmod_id['rmod']}
        Exit For Loop If  ${cablink}==[] and ${rmod_id}==[]
        ${rmod_id_list}  Combine Lists  ${rmod_id}
        ${cablinks_related_to_rmod_id}  Combine Lists  ${cablinks_related_to_rmod_id}  ${cablink}
        Remove Values From List  ${cablinks_in_chain}  @{cablink}
    END
    [Return]  ${cablinks_related_to_rmod_id}

Find Cablinks Related To RMOD
    [Documentation]  This KW is intended to work with "Find Cablinks In Chain For Specified RMOD" and variables it generates.
    ...              It gets RMOD(s) from given list, looks for them in cablink endpoints and returns cablink and RMOD connected to other endpoint.
    [Arguments]  ${rmod_id_list}  ${cablink_dict}  ${cablinks_in_chain}
    ${objects_related_to_rmod_id}  Create Dictionary
    ${rmod_id_list_length}  Get Length  ${rmod_id_list}
    ${related_cablinks_list}  Create List
    ${related_rmods_list}     Create List
    FOR  ${cablink}  IN  @{cablinks_in_chain}
        ${endpoints}  Get From Dictionary  ${cablink_dict}  ${cablink}
        Run Keyword If  '${rmod_id_list[0]}' in $endpoints  Append To List  ${related_cablinks_list}  ${cablink}
        ...       ELSE  Continue For Loop If  ${rmod_id_list_length}==1
        Run Keyword If  '${rmod_id_list[0]}' in $endpoints[0]
        ...             Append To List  ${related_rmods_list}  ${endpoints[1]}
        ...    ELSE IF  '${rmod_id_list[0]}' in $endpoints[1]
        ...             Append To List  ${related_rmods_list}  ${endpoints[0]}
        Continue For Loop If  ${rmod_id_list_length}==1
        Continue For Loop If  '${rmod_id_list[1]}' not in $endpoints
        Append To List  ${related_cablinks_list}  ${cablink}
        Run Keyword If  '${rmod_id_list[1]}' in $endpoints[0]
        ...             Append To List  ${related_rmods_list}  ${endpoints[1]}
        ...       ELSE  Append To List  ${related_rmods_list}  ${endpoints[0]}
    END
    Set To Dictionary  ${objects_related_to_rmod_id}  rmod=${related_rmods_list}  cablink=${related_cablinks_list}
    [Return]  ${objects_related_to_rmod_id}

Get RUs Supporting ${wanted_feature}
    ${frm}  admin.get frm
    ${RU_L}  Get Managed Objects  RU_L
    ${rus_supporting_feature}  Create List
    ${serial_to_ru_l_mapping}  Create Dictionary
    FOR  ${item}  IN  @{RU_L}
        ${wanted_feature_status}  Get From Dictionary  ${item['parameters']['supportedFeature']}  ${wanted_feature}
        Run Keyword If  '${wanted_feature_status}' == 'True'  Append To List  ${rus_supporting_feature}  ${item['distName']}
        Set To Dictionary  ${serial_to_ru_l_mapping}  ${item['parameters']['serialNumber']}  ${item['distName']}
    END
    ${rmod_and_ru_mapped}  Run Keyword And Return Status  Variable Should Exist  ${RMOD_AND_RU_L_DICT}
    ${RMOD_AND_RU_L_DICT}  Create Dictionary
    FOR  ${item}  IN  @{frm}
        Continue For Loop If  ${rmod_and_ru_mapped}
        ${rmod_l}  Get From Dictionary  ${serial_to_ru_l_mapping}  ${item['serialNumber']}
        Set To Dictionary  ${RMOD_AND_RU_L_DICT}  ${rmod_l}  ${item['id']['configuration']}  ${item['id']['configuration']}  ${rmod_l}
    END
    Run Keyword If  not ${rmod_and_ru_mapped}  Set Test Variable  ${RMOD_AND_RU_L_DICT}
    [Return]  ${rus_supporting_feature}

Get RUs Parameters Values
    [Documentation]  Keyword gets values of specified parameters from RU(s) and returns a dictionary containing specified RU distName as key
    ...              and subdictionary (parameter: value) as value.
    ...              If there's no list of specified RUs given then dictionary with parameters for all RUs available in configuration is returned.
    ...              *** Example of returned dictionary format: ***
    ...              {'/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1': '{'upTime': '1234', 'resetCounter': '1234'}'}
    [Arguments]  ${parameters_list}  ${specified_RUs_list}=All_RUs
    ${specified_RUs_list}  Run Keyword If  'All_RUs' in $specified_RUs_list  Create List  ${specified_RUs_list}
    ...                              ELSE  Set Variable  ${specified_RUs_list}
    ${ru_l_dict}  Create Dictionary
    ${RU_L}  Get Managed Objects  RU_L
    ${RUs_amount}  Get Length  ${RU_L}
    ${uptime_needed}  Run Keyword And Return Status  List Should Contain Value  ${parameters_list}  upTime
    ${up_time}  Run Keyword If  ${uptime_needed}  Wait Until Keyword Succeeds  12x  10s
                                    ...           Ensure Managed Objects Are Created  object=UP_TIME  expected_amount=${RUs_amount}
                                    ...     ELSE  Create List
    ${ru_uptime_dict}  Create Dictionary
    FOR  ${item}  IN  @{up_time}
        Set To Dictionary  ${ru_uptime_dict}  ${item['distName']}  ${item['parameters']['upTime']}
    END
    FOR  ${item}  IN  @{RU_L}
        Continue For Loop If  'All_RUs' not in $specified_RUs_list and '${item['distName']}' not in @{specified_RUs_list}
        ${parameters_dict}  Evaluate  {param: ${item['parameters']}.get(param) for param in ${parameters_list}}
        Run Keyword If  ${uptime_needed}  Set To Dictionary  ${parameters_dict}  upTime  ${ru_uptime_dict['${item['distName']}/UP_TIME-1']}
        Set To Dictionary  ${ru_l_dict}  ${item['distName']}  ${parameters_dict}
    END
    [Return]  ${ru_l_dict}

Compare RUs upTime
    [Documentation]  Keyword compares values of two dictionaries composed of RU_L distName and subdictionary of upTime and returns a dictionary
    ...              composed of RU_L distName as key and subdictionary of upTime_diff as value.
    ...              *** Example of input dictionary correct format: ***
    ...              {/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1: {upTime: 1234}}
    [Arguments]  ${before_reset}  ${after_reset}
    ${diff_detected}  Create Dictionary
    FOR  ${ru}  IN  @{after_reset}
        ${parameters_diff}    Create Dictionary
        ${parameters}         Get From Dictionary  ${after_reset}  ${ru}
        ${params_to_compare}  Get From Dictionary  ${before_reset}  ${ru}
        ${upTime_diff}        Evaluate  ${parameters['upTime']} - ${params_to_compare['upTime']}
        Set To Dictionary  ${parameters_diff}  upTime_diff  ${upTime_diff}
        Set To Dictionary  ${diff_detected}    ${ru}        ${parameters_diff}
    END
    [Return]  ${diff_detected}

Get RMODs Connected To BBMOD Through FHS
    [Documentation]  KW returns a list of RMODs that are connected to given BBMOD through FHS with a given protocol.
    ...              Supported ${radio_protocol} values: OBSAI, CPRI and eCPRI (case insensitive).
    ...              Supported formats of ${given_bbmod}: 'internal', 'runtime' or 'configuration' name.
    ...              Returned RMOD names are in 'configuration' format.
    [Arguments]  ${given_bbmod}  ${radio_protocol}==ALL
    ${protocol}  Set Variable If  '${radio_protocol.upper()}'=='OBSAI'  RP3
    ...                           '${radio_protocol.upper()}'=='CPRI'   CPRI
    ...                           '${radio_protocol.upper()}'=='ECPRI'  Eth
    ...                           Link
    ${rmods_on_fhs}     Create List
    ${bbmods_with_fhs}  Create Dictionary
    ${mapped_bbmods}    Create Dictionary
    ${mapped_rmods}     Create Dictionary
    ${get_bts_info}       admin.Get BTS Info
    ${cablink_prameters}  admin.Get Parameters For All  CABLINK
    #map bbmods ids to configuration
    FOR  ${bbmod}  IN  @{get_bts_info['basebandModules']}
        Set To Dictionary  ${mapped_bbmods}  ${bbmod['id']['internal']}       ${bbmod['id']['configuration']}
        ...                                  ${bbmod['id']['runtime']}        ${bbmod['id']['configuration']}
        ...                                  ${bbmod['id']['configuration']}  ${bbmod['id']['configuration']}
    END
    #map rmods ids to configuration
    FOR  ${rmod}  IN  @{get_bts_info['radioModules']['rmod']}
        Set To Dictionary  ${mapped_rmods}   ${rmod['id']['internal']}        ${rmod['id']['configuration']}
    END
    ${given_bbmod}  Get From Dictionary  ${mapped_bbmods}  ${given_bbmod}
    #map bbmods with fhs
    FOR  ${cablink}  IN  @{cablink_prameters}
        IF  'FHS' not in $cablink['secondEndpointDN']  CONTINUE
        ${empty_list}  Create List
        ${converted_bbmod}  Get From Dictionary  ${mapped_bbmods}  ${cablink['firstEndpointDN']}
        ${fhs_list_from_dict}  Pop From Dictionary  ${bbmods_with_fhs}  ${converted_bbmod}  default=${empty_list}
        IF  '${cablink['secondEndpointDN']}' not in $fhs_list_from_dict  Append To List  ${fhs_list_from_dict}  ${cablink['secondEndpointDN']}
        Set To Dictionary  ${bbmods_with_fhs}  ${converted_bbmod}  ${fhs_list_from_dict}
    END
    IF  '${given_bbmod}' not in $bbmods_with_fhs  Return From Keyword  ${rmods_on_fhs}
    #get rmods with given protocol connected to fhs
    FOR  ${cablink}  IN  @{cablink_prameters}
        IF  '${protocol}' not in $cablink['cablinkType'] or 'FHS' not in $cablink['firstEndpointDN']  CONTINUE
        ...           ELSE IF  $cablink['firstEndpointDN'] not in $bbmods_with_fhs['${given_bbmod}']  CONTINUE
        ${converted_rmod}  Get From Dictionary  ${mapped_rmods}  ${cablink['secondEndpointDN']}
        IF  '${converted_rmod}' not in $rmods_on_fhs  Append To List  ${rmods_on_fhs}  ${converted_rmod}
    END
    [Return]  ${rmods_on_fhs}

#------------------------------------------CLOUD START---------------------------------------
Get Names And Status From Helm List
    [Documentation]    Description:    KW getting actual chart names and statuses
    ...                Input:          SSH connection.
    ...                Output:         Return list of dictionaries exmp. [{Name:'vcu8780-prerequisite', Status:'deployed'}]
    [Arguments]  ${conn}
    ${charts_output}=  ssh.Execute  helm list -A -a --output json  connection=${conn}
    ${cleaned_output}=  Strip String  ${charts_output}
    ${charts_json_data}=  Evaluate  json.loads('${cleaned_output}')
    ${deployed_charts}=  Create List
    FOR  ${item}  IN  @{charts_json_data}
        ${name}=  Get From Dictionary  ${item}  name
        ${status}=  Get From Dictionary  ${item}  status
        ${chart}=  Get From Dictionary  ${item}  chart
        ${dict_item}=  Create Dictionary  Name=${name}  Status=${status}  Chart=${chart}
        Append To List  ${deployed_charts}  ${dict_item}
    END
    [Return]  ${deployed_charts}

Get Required Charts From HelmChart Directory
    [Arguments]  ${hw_type}  ${helm_chart_path}  ${connection}=admin
    [Documentation]    Description:    KW get required .tgz chart files that will be installed from HelmChart folder
    ...                Input:          helm_chart_path=/var/home/core/0.250.26816_upgrade/HelmChart/
    ...                                connection=admin
    ...                Output:         Ordered list of charts files .tgz (order: prep; prereq; main)
    ${ls_helm}=  ssh.Execute  cd ${helm_chart_path} && ls  ${connection}
    @{splited_ls_helm}=  Split String  ${ls_helm}
    ${aic_files}=  Evaluate  [file for file in ${splited_ls_helm} if file.startswith('aic-${hw_type}')]
    ${needed_charts}=  Get Slice From List  ${aic_files}  0  3
    ${last_two_charts}=  Get Slice From List  ${needed_charts}  -2
    ${main_chart}=  Get Slice From List  ${needed_charts}  0  -2
    @{charts_to_be_installed}=  Create List  ${last_two_charts[0]}  ${last_two_charts[1]}  @{main_chart}
    Set Test Variable  ${charts_to_be_installed}
    Log  ${charts_to_be_installed}  console=${true}
    [Return]  ${charts_to_be_installed}

Download required software files
    [Arguments]  ${SW_PACKAGE}  ${ssh_conn}  ${operation_type}  ${conversion}=${True}  ${onboarding}=${True}
    [Documentation]    Description:    KW download sw package, onboardingApp and conversionApp
    ...                Input:          robot -v SW_PACKAGE:vCUCNF00_0.250.27021
    ...                                connection=admin
    ...                Output:        Return paths with downloaded fiels: package_path | onversionApp_path | onboardingApp_path
    ${release}=  Fetch From Left  ${SW_PACKAGE}  marker=_
    Set Test Variable  ${release}  ${release}
    ${sw_version}=  Fetch From Right  ${SW_PACKAGE}  marker=_
    ${vcu_package_url}=  Set Variable  ${sw_artifactory}/${release}/${SW_PACKAGE}/${SW_PACKAGE}-amd64.zip
    ${conversionApp_path}=  Set Variable  ${None}
    ${onboardingApp_path}=  Set Variable  ${None}
    Log    ${vcu_package_url}    console=${true}
    IF  ${conversion} and ${onboarding}
        ${conversionApp_url}=  Set Variable  ${sw_artifactory}/${release}/${SW_PACKAGE}/artifacts/conversionApp-${sw_version}-amd64.tar.gz
        ${onboardingApp_url}=  Set Variable  ${sw_artifactory}/${release}/${SW_PACKAGE}/artifacts/onBoardingApp.tgz
    END
    Set Test Variable  ${target_path}  /var/home/core/${sw_version}_cli
    ${package_path}=  Set Variable  ${target_path}/${SW_PACKAGE}.zip
    IF  ${conversion} and ${onboarding}
          Set Test Variable  ${conversionApp_path}  ${target_path}/conversionApp-${sw_version}-amd64.tar.gz
          Set Test Variable  ${onboardingApp_path}  ${target_path}/onBoardingApp-${sw_version}.tgz
    END
    ${storage_dir_dic}=     create_storage_dir_dictionary    ${operation_type}    /var/home/core/${sw_version}_cli
    Set Test Variable  ${storage_dir}    ${storage_dir_dic}
#    #vCU_package_Download
    ssh.Execute  mkdir ${storage_dir}[${operation_type}]  connection=${ssh_conn}
    Decorate Print  Downloading of ${SW_PACKAGE} Started
    ${output_package_download}=  ssh.Execute  curl -u ca_vrf_wro3_t01:WRO1pass! -o ${package_path} ${vcu_package_url}  connection=${ssh_conn}
    Log  ${output_package_download}  console=${true}
    Check If File Downloaded  ${package_path}
#    conversionApp_Download
    IF  ${conversion} and ${onboarding}
        Decorate Print  Downloading of conversionApp Started
        ${output_conApp}=  ssh.Execute  curl -u ca_vrf_wro3_t01:WRO1pass! -o ${conversionApp_path} ${conversionApp_url}  connection=${ssh_conn}
        Log    curl -o ${conversionApp_path} ${conversionApp_url}    console=${true}
        Log  ${output_conApp}  console=${true}
        Check If File Downloaded  ${conversionApp_path}
    #onBoardingApp_Download
        Decorate Print  Downloading of onBoardingApp Started
        ${output_onBoarApp}=  ssh.Execute  curl -u ca_vrf_wro3_t01:WRO1pass! -o ${onboardingApp_path} ${onboardingApp_url}  connection=${ssh_conn}
        Log    curl -o ${onboardingApp_path} ${onboardingApp_url}    console=${true}
        Log  ${output_onBoarApp}  console=${true}
        Check If File Downloaded  ${onboardingApp_path}
    END
    [Return]  ${package_path}  ${conversionApp_path}  ${onboardingApp_path}

Unpack required software files
    [Arguments]  ${package_path}=${None}  ${conversionApp_path}=${None}  ${onboardingApp_path}=${None}
    ...           ${storage_dir}=${None}   ${conn}=${None}   ${uprg_roll}=upgrade
    [Documentation]    Description:    KW unpack sw packages for vcu/vdu, onBoardingApp, convertionApp
    ...                Input:          package_path=/path/to/each/package
    ...                                storage_dir=/path/under/which/zipped/packages/stored
    ...                                SW_PACKAGE:vCUCNF00_0.250.27004
    Decorate Print  Unpackign Of Downloaded Files Started
    ${unzip_package_output}=  ssh.Execute  cd ${storage_dir} && unzip -q ${package_path}  connection=${conn}
    ssh.Assert Exit Status  0  connection=${conn}
    IF  '${hw}'=='vCU' and '${uprg_roll}'=='rollaback'
        ssh.Execute  cd ${storage_dir} && unzip -q ${rollback_sw}-amd64.zip  connection=${conn}
    ELSE IF  '${hw}'=='vCU' and '${uprg_roll}'=='upgrade'
        ssh.Execute  cd ${storage_dir} && unzip -q ${SW_VCU}-amd64.zip  connection=${conn}
    ELSE IF  '${hw}'=='vDU' and '${uprg_roll}'=='rollaback'
        ssh.Execute  cd ${storage_dir} && unzip -q ${rollback_sw}-amd64.zip  connection=${conn}
    ELSE IF  '${hw}'=='vDU' and '${uprg_roll}'=='upgrade'
        ssh.Execute  cd ${storage_dir} && unzip -q ${SW_VDU}-amd64.zip  connection=${conn}
    END
    ssh.Assert Exit Status  0  connection=${conn}
    Log  ${package_path}: UNZIPPED  console=${true}
    ${Status}  Run keyword and return status  Should Contain  ${conversionApp_path}  /var/home/core  ignore_case=True
    IF   ${Status}
        ${unpack_convertionApp_output}=  ssh.Execute  cd ${storage_dir} && tar -xvzf ${conversionApp_path}  connection=${conn}
        ssh.Assert Exit Status  0  connection=${conn}
    END
    ${Status}  Run keyword and return status  Should Contain  ${onboardingApp_path}  /var/home/core  ignore_case=True
    IF  ${Status}
        ${unpack_onBoardingApp_output}=  ssh.Execute  cd ${storage_dir} && tar -xvzf ${onboardingApp_path}  connection=${conn}
        ssh.Assert Exit Status  0  connection=${conn}
        Log  ${onboardingApp_path}: UNPACKED  console=${true}
    END

Image Onboarding
   [Arguments]  ${hw_type}  ${downloaded_path}  ${conn}
   [Documentation]    Description:    KW copy images.OCP and loadImages.sh from onBoardingApp to Images, and run loadImages.sh
   ...                 **Example of simple usage:**
   ...                 Image Onboarding  hw_type=vDU/vCU  downloaded_path=/var/home/core/  conn=connection
   ...
   Decorate Print  Copy image.properties.OCP And loadImages.sh To Images
   ssh.Execute  cd ${downloaded_path}; cp onBoardingApp/images.properties.OCP onBoardingApp/loadImages.sh Image  connection=${conn}
   ssh.Assert Exit Status  0  connection=${conn}
   ${output}=  Run Keyword If  '${hw_type}'=='vCU'  Run Keywords
   ...  ssh.Execute  cd ${downloaded_path}/Image && ./loadImages.sh -n ${CRAN_VCU}  connection=${conn}
   ...  AND  Log  cd ${downloaded_path}/Image && ./loadImages.sh -n ${CRAN_VCU}  console=${true}
   ...  ELSE IF  '${hw_type}'=='vDU'  Run Keywords
   ...  ssh.Execute  cd ${downloaded_path}/Image && ./loadImages.sh -n ${CRAN_VDU}  connection=${conn}
   ...  AND  Log  cd ${downloaded_path}/Image && ./loadImages.sh -n ${CRAN_VDU}  console=${true}
   Log   ${output}  console=${true}
   ssh.Assert Exit Status  0  connection=${conn}
   Log  image.properties.OCP and loadImages.sh have been copied to Images And Load Images Installed  console=${true}

Convert Values Override For Different Clusters
    [Arguments]  ${hw_type}  ${conn}
    [Documentation]     Description:    KW copy default values override from repo, convert it and stores on the core
    ...                 Input:          conn=${connection}
#   Unpack cnf_userinput_conversion
    ${list_of_files}=  ssh.Execute  cd ${storage_dir}[upgrade]/conversionApp && ls  connection=${conn}
    @{splited_list_of_files}=  Split String  ${list_of_files}
    ${tar_gz_files}=  Evaluate  [file for file in ${splited_list_of_files} if file.endswith('.tar.gz')]
    Log  ${tar_gz_files}  console=${true}
    ${unpack_cnf_user_inpt}=  ssh.Execute  cd ${storage_dir}[upgrade]/conversionApp && tar -xvzf ${tar_gz_files[0]}  connection=${conn}
    ssh.Assert Exit Status  0  connection=${conn}
#   Upload values-override from repo to core
    ssh.Execute  mkdir ${storage_dir}[upgrade]/valuesToBeConverted  connection=${conn}
    ${output}=  ssh.Upload File  ${charts_to_convert}  ${storage_dir}[upgrade]/valuesToBeConverted   connection=${conn}
    ssh.Assert Exit Status  0  connection=${conn}
#    Upload values-override from repo to core END
    Set Test Variable  ${main_chart}  ${storage_dir}[upgrade]/valuesToBeConverted/main.yaml
    Set Test Variable  ${prep_chart}  ${storage_dir}[upgrade]/valuesToBeConverted/preparation.yaml
    Set Test Variable  ${prereq_chart}  ${storage_dir}[upgrade]/valuesToBeConverted/prerequisites.yaml
    ${conv_main_cm}=  Run Keyword If  '${hw_type}'=='vCU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${main_chart} -t values-override.aic-vcu.tpl -o main_new.yaml
    ...  ELSE IF  '${hw_type}'=='vDU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${main_chart} -t values-override.aic-vdu.tpl -o main_new.yaml
    ${conv_prep_cm}=  Run Keyword If  '${hw_type}'=='vCU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prep_chart} -t values-override.aic-vcu-cluster-preparation.tpl -o prep_new.yaml
    ...  ELSE IF  '${hw_type}'=='vDU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prep_chart} -t values-override.aic-vdu-cluster-preparation.tpl -o prep_new.yaml
    ${conv_preq_cm}=  Run Keyword If  '${hw_type}'=='vCU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prereq_chart} -t values-override.aic-vcu-prerequisite.tpl -o prereq_new.yaml
    ...  ELSE IF  '${hw_type}'=='vDU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prereq_chart} -t values-override.aic-vdu-prerequisite.tpl -o prereq_new.yaml
    ${commands_for_convertion}=  Create List  ${conv_main_cm}  ${conv_prep_cm}  ${conv_preq_cm}
    Log  ${commands_for_convertion}  console=${true}
    Decorate Print  Converting Of Values Override
    FOR  ${command}  IN  @{commands_for_convertion}
        ssh.Execute  cd ${storage_dir}[upgrade]/conversionApp && ${command}  connection=${conn}
        Log  Executing ${command}  console=${true}
        ssh.Assert Exit Status  0  connection=${conn}
    END
    ssh.Execute  touch ${storage_dir}[upgrade]/valuesToBeConverted/conversion_done.txt  connection=${conn}
    ssh.Assert Exit Status  0  connection=${conn}

Check If All Cells On Air
    [Arguments]  ${hw_type}  ${connection}
    [Documentation]     Description:    KW checks cell(s) states on vCU or vDU, depends on 'hw_type' value.
    ...                 **Example of simple usage:**
    ...                 Check If All Cells On Air  hw_type=vCU  connection=admin_connection
    ...
    ${cells_summary}=  Run Keyword If  "${hw_type}"=="vCU"  vcu_admin.Get Cells Statuses  connection=${connection}
    ...  ELSE IF  "${hw_type}"=="vDU"  Get Vdu Cells Status  vdu_connection=${connection}
    Should Not Be Empty  ${cells_summary}    Error: The cells_summary variable is empty. Cell objects might not have been created yet
    Set Test Variable   ${cells_summary}
    Run Keyword If  "${hw_type}"=="vCU"  Check Cell States On vCU  ${cells_summary}
    ...  ELSE IF  "${hw_type}"=="vDU"  Check Cell States On vDU  ${cells_summary}


Check Cell States On vCU
    [Arguments]  ${cells_info}
    FOR  ${state}  IN  @{cells_info}
        ${administration_state}=  Get From Dictionary  ${state}  administrative_state
        ${operational_state}=  Get From Dictionary  ${state}  operational_state
        ${administration_state}=  Evaluate  "${administration_state}".upper()
        ${operational_state}=  Evaluate  "${operational_state}".upper()
        Should Be True  '${operational_state}'=='ENABLED' and '${administration_state}'=='UNLOCKED'
    END

Check Cell States On vDU
    [Arguments]  ${cells_info}
    FOR  ${state}  IN  @{cells_info}
        ${administration_state}=  Get From Dictionary  ${state}  administrative_state
        ${operational_state}=  Get From Dictionary  ${state}  operational_state
        ${blocking_state}=  Get From Dictionary  ${state}  blocking_state
        ${availability_status}=  Get From Dictionary  ${state}  availability_status
        ${procedural_status}=  Get From Dictionary  ${state}  procedural_status
        ${blocking_state}=  Evaluate  "${blocking_state}".upper()
        ${availability_status}=  Evaluate  "${availability_status}".upper()
        ${procedural_status}=  Evaluate  "${procedural_status}".upper
        ${administration_state}=  Evaluate  "${administration_state}".upper()
        ${operational_state}=  Evaluate  "${operational_state}".upper()
        Should Be True  '${operational_state}'=='ENABLED' and '${administration_state}'=='UNLOCKED' and '${blocking_state}'=='UNBLOCKED'
        ...  and '${availability_status}'=='ON LINE' and '${procedural_status}'=='CONFIGURED'
    END

Install Or Upgrade Charts
    [Arguments]  ${hw}  ${cran}  ${helm_dir_path}  ${chart_name}  ${helm_chart_path}
    ...          ${path_to_yaml_file}  ${operation}=install  ${conn}=admin  ${timeout}=200
    [Documentation]     Description: KW Install Or Upgrade Charts Depends On *operation* Argument
    ...                 **Example of simple usage:**
    ...                 Install Or Upgrade Charts  ${helm_dir_path}  ${chart_name}  ${helm_chart_path}  ${path_to_yaml_file}  ${operation}
    ...
    Decorate Print  ${operation} ${hw}${chart_name}
    Sleep  60s
    ${output}=  ssh.Execute
    ...  command=cd ${helm_dir_path} && helm ${operation} ${chart_name} ${helm_chart_path} -f ${path_to_yaml_file} -n ${cran}
    ...  connection=${conn}
    ...  timeout=${timeout}
    Log  cd ${helm_dir_path} && helm ${operation} ${chart_name} ${helm_chart_path} -f ${path_to_yaml_file} -n ${cran}  console=${true}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=admin

Remove Existing Charts
    [Arguments]  ${hw_type}  ${chart_name}  ${conn}
    [Documentation]    Description:    KW get charts names, set them in apropriate order (main, prereq, prep) and removes charts
    ...                Input:          hw_type=vCU
    Decorate Print  Removing Existing Charts
    ${ordred_charts_all}=  Create List    1    2    3
    ${deployed_charts}=  Get Names And Status From Helm List  ${conn}
    ${charts}=  Evaluate  [chart['Name'] for chart in @{deployed_charts} if chart['Name'].startswith('${hw_type}')]
    FOR  ${i}  IN  @{charts}
        Run Keyword If  not '${i}'.endswith('preparation') and not '${i}'.endswith('prerequisite')  Set List Value    ${ordred_charts_all}  0  ${i}
        Run Keyword If  '${i}'.endswith('prerequisite')  Set List Value    ${ordred_charts_all}  1  ${i}
        Run Keyword If  '${i}'.endswith('preparation')  Set List Value    ${ordred_charts_all}   2  ${i}
    END
    Set Test Variable   ${ordred_charts_all}
    ${helm_uninstall_output}=  Run Keyword If  '${chart_name}'=='main' and '${hw_type}'=='vcu'
    ...  ssh.Execute  helm uninstall ${ordred_charts_all[0]} -n ${CRAN_VCU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='preparation' and '${hw_type}'=='vcu'
    ...  ssh.Execute  helm uninstall ${ordred_charts_all[2]} -n ${CRAN_VCU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='prerequisite' and '${hw_type}'=='vcu'
    ...  ssh.Execute  helm uninstall ${ordred_charts_all[1]} -n ${CRAN_VCU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='main' and '${hw_type}'=='vdu'
    ...  ssh.Execute  helm uninstall ${ordred_charts_all[0]} -n ${CRAN_VDU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='preparation' and '${hw_type}'=='vdu'
    ...  ssh.Execute  helm uninstall ${ordred_charts_all[2]} -n ${CRAN_VDU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='prerequisite' and '${hw_type}'=='vdu'
    ...  ssh.Execute  helm uninstall ${ordred_charts_all[1]} -n ${CRAN_VDU}  connection=${conn}
    Log   ${helm_uninstall_output}  console=${true}
    ssh.Assert Exit Status  0  connection=${conn}
    ${helm_uninstall_output}=  Run Keyword If  '${chart_name}'=='all' and '${hw_type}'=='vcu'
    ...  Delete All Charts  ${CRAN_VCU}  ${ordred_charts_all}  ${conn}
    ...  ELSE IF  '${chart_name}'=='all' and '${hw_type}'=='vdu'
    ...  Delete All Charts  ${CRAN_VDU}  ${ordred_charts_all}  ${conn}

Delete All Charts
    [Arguments]  ${cran}  ${list_of_charts}  ${conn}
    FOR  ${chart}  IN  @{list_of_charts}
        ${helm_uninstall_output}=  ssh.Execute  helm uninstall ${chart} -n ${cran}  connection=${conn}
        Log  ${helm_uninstall_output}  console=${true}
        ssh.Assert Exit Status  0  connection=${conn}
        Sleep    10s
    END

Decorate Print
    [Arguments]  ${print}
    Log to console    \n========================================
    Log  ${print}  console=${True}
    Log to console    ========================================

Check If File Downloaded
    [Arguments]  ${file_path}
    [Documentation]
    ${file_exists}  ssh.File Exists  ${file_path}  connection=admin
    Should Be True  ${file_exists}
    Log  ${file_path}: EXIST  console=${true}

Check Alarm List On vCU/vDU
    [Arguments]  ${hw_type}
    ${alarms}=  Run Keyword If  '${hw_type}'=='vCU'  Get Active Alarms From vCU
    ...  ELSE IF  '${hw_type}'=='vDU'  Get Active Alarms from vDU
    ${active_alarms}=  Get From Dictionary  ${alarms}  total
    Run Keyword If  '${active_alarms}'=='0'  Log To Console  No Visible Alarms On ${hw_type}
    ...  ELSE  Fail  Alarm(s) Visible On ${hw_type}

Check If Charts Deployed
    [Documentation]    Description:    KW checks if all charts are deployed
     ...                 **Example of simple usage:**
    ...                  Check If Charts Deployed  ${deployed_charts}
    ...
    [Arguments]  ${charts_list}
    ${all_deployed}=  Set Variable  True
    FOR  ${chart}  IN  @{charts_list}
        ${name}=  Get From Dictionary  ${chart}  Name
        ${status}=  Get From Dictionary  ${chart}  Status
        Should Be Equal  ${status}  deployed
        Log  ${name}: deployed  console=${true}
    END

Check Pre Post Status
    [Arguments]   ${save_status_cm}  ${bts_id}  ${hw_type}  ${pre_post}  ${conn}
    [Documentation]    Description:    KW checks phase statuses for vCU or vDU, depends on hw_type argument
    ...                 **Example of simple usage:**
    ...                  Check Pre Post Status  save_status_cm=${save_status_command}  bts_id=${MRBTS}  hw_type=vDU
    ...                  ${pre_post}=precheck  conn=${ssh_conn}
    ...
    ${phase_statuses}=  Create List
    ${status_output}=  ssh.Execute  ${save_status_cm} | tee -a /var/home/core/Logs/${pre_post}_inter_${hw_type}_${MRBTS}  connection=${conn}
    Log  ${status_output}  console=${true}
    ${output}=  ssh.Execute  cd /var/home/core/Logs/ && grep 'Phase:' ${pre_post}_inter_${hw_type}_${bts_id} | awk '{print $2}'  connection=${conn}
    ${cleaned_output}=  Strip String  ${output}
    Append To List  ${phase_statuses}  ${cleaned_output}
    ${phase_statuses}=  Split String  ${phase_statuses}[0]  \r\n
    Run Keyword If  'Failed' in ${phase_statuses}  Fail  Phase status: FAILED
    ssh.Assert Exit Status  0  connection=${conn}

Login To CCR
    [Documentation]  Description: KW logins to chosen ccr based on ccr_location and
    ...              hw_type arguments.
    ...              **Example of simple usage:**
    ...              Login To CCR  ccr_url=url_of_ccr  crts_dir=path_to_dir_with_cets  ccr_location=wl/wg  hw_type=vcu/vdu
    ...
    [Arguments]  ${ccr_url}  ${certs_dir}  ${ccr_location}  ${hw_type}  ${ssh_connection}
    ${ccr_wl_vdu_pass}=  Set Variable  ObCV0W80KGzzazO1aCRKDU25DozYU338
    ${ccr_wg_vdu_pass}=  Set Variable  zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9
    ${ccr_wl_vcu_pass}=  Set Variable  biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR
    ${ccr_wg_vcu_pass}=  Set Variable  swqgJTZSPBt4XHcfgeyz8DErRyXjgj5R
    Run Keyword If  '${ccr_location}'=='wl' and '${hw_type}'=='vcu'
    ...  ssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wl_vcu_pass}
    ...  connection=${ssh_connection}
    ...  ELSE IF  '${ccr_location}'=='wl' and '${hw_type}'=='vdu'
    ...  ssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wl_vdu_pass}
    ...  connection=${ssh_connection}
    ...  ELSE IF  '${ccr_location}'=='wg' and '${hw_type}'=='vcu'
    ...  ssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wg_vcu_pass}
    ...  connection=${ssh_connection}
    ...  ELSE IF  '${ccr_location}'=='wg' and '${hw_type}'=='vdu'
    ...  ssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wg_vdu_pass}
    ...  connection=${ssh_connection}
    ssh.Assert Exit Status  0  connection=${ssh_connection}

Create CCR Certs On Core
    [Documentation]  Description: KW uploads ccrcert.sh to core. Ensures ccrcerrt.sh is executable.
    ...              And execute it.
    [Arguments]    ${ssh_connection}
    ${cert_script}=  Set Variable  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T01/resources_mem/ccrcert.sh
    ${output}=  ssh.Upload File  ${cert_script}  /var/home/core/ccrcert.sh  connection=${ssh_connection}
    Log   ${output}  console=${true}
    ${file_exist}=  ssh.Execute  test -f "/var/home/core/ccrcert.sh" && echo OK || echo FAIL  connection=${ssh_connection}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK
    ssh.Execute  chmod 777 /var/home/core/ccrcert.sh  connection=${ssh_connection}
    ${output}=  ssh.Execute  bash /var/home/core/ccrcert.sh  connection=${ssh_connection}
    ssh.Assert Exit Status  0  connection=${ssh_connection}
    Log  ${output}  console=${true}

Images Onboarding
    [Arguments]  ${hw_type}  ${ccr_location}  ${operation_type}
    [Documentation]  Description: KW load images, for vCU/vDU depends on hw_type argument.
    ...              Tags loaded images and push them to chosen ccr depends on ccr_location argument.
    ...              **Example of simple usage:**
    ...              Images Onboarding  hw_type=vcu/vdu  ccr_location=wl/wg
    ...
    Log  Delete Existing Images  console=${True}
    ssh.Execute  podman image rm -a  connection=${ssh_conn}
    ${ccr}=  Set Variable  ccr-${ccr_location}-vrf-${hw_type}-01.wroclaw.nsn-rdnet.net:443/${hw_type}/
    ${ccr_url}=  Set Variable  https://ccr-${ccr_location}-vrf-${hw_type}-01.wroclaw.nsn-rdnet.net:443/${hw_type}/
    ${certs_dir_path}=  Set Variable  /var/home/core/vrfrepos/
    ${image_path}=  Set Variable  ${storage_dir}[${operation_type}]/Image/${hw_type}-image.tar
    ${output}=  ssh.Execute  podman load -i ${image_path}  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Create CCR Certs On Core    ${ssh_conn}
    Login To CCR  ccr_url=${ccr_url}  certs_dir=${certs_dir_path}  ccr_location=${ccr_location}  hw_type=${hw_type}  ssh_connection=${ssh_conn}
    ${output}=  ssh.Execute  podman image list --format "{{.Repository}} {{.Tag}} {{.ID}}"  connection=${ssh_conn}
    ${cleaned_output}=  Strip String  ${output}
    ${images_data}=  Split String  ${cleaned_output}  \r\n
    ${grouped_images}=  Create List
    ${repository_paths}=    Create List
    FOR  ${image}  IN  @{images_data}
        ${parts}=  Split String  ${image}
        ${repo}=  Set Variable  ${parts}[0]
        ${repo}=  Replace String  ${repo}  localhost/  ${EMPTY}
        ${tag}=  Set Variable  ${parts}[1]
        ${image_id}=  Set Variable  ${parts}[2]
        ${image_dict}=  Create Dictionary  repo=${repo}  tag=${tag}  image_id=${image_id}
        ${repo_path}=    Set Variable    ${ccr}${repo}:${tag}
        Append To List    ${repository_paths}    ${repo_path}
        Append To List    ${grouped_images}      ${image_dict}
      END
    FOR  ${image}  IN  @{grouped_images}
        ${output}=  ssh.Execute  podman tag ${image}[image_id] ${ccr}${image}[repo]:${image}[tag]  connection=${ssh_conn}
        Log  podman tag ${image}[image_id] ${ccr}${image}[repo]:${image}[tag]  console=${true}
        Log  ${output}  console=${true}
        ssh.Assert Exit Status  0  connection=${ssh_conn}
        ${output}=  ssh.Execute  podman push ${ccr}${image}[repo]:${image}[tag] --cert-dir=${certs_dir_path}  connection=${ssh_conn}
        Log  ${output}  console=${true}
        ssh.Assert Exit Status  0  connection=${ssh_conn}
    END
    Set Suite Variable    ${IMAGE_PATH_LIST}    ${repository_paths}
    ${output}=  ssh.Execute  podman image rm -a  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    [Teardown]  ssh.Execute  podman image rm -a  connection=${ssh_conn}

Check If SW Exist On Artifactory
    [Arguments]  ${hw_type}  ${sw_package}
    ${release}=  Fetch From Left  ${sw_package}  marker=_
    ${cmd_to_check_sw}=  Run Keyword If  '${hw_type}'=='vCU'  Set Variable
    ...  curl -s -u ca_vrf_wro3_t01:WRO1pass! ${sw_artifactory}/${release} | grep ${SW_VCU} | wc -l
    ...  ELSE IF  '${hw_type}'=='vDU'  Set Variable
    ...  curl -s -u ca_vrf_wro3_t01:WRO1pass! ${sw_artifactory}/${release} | grep ${SW_VDU} | wc -l
    #execution
    ${output}=  ssh.Execute  ${cmd_to_check_sw}  connection=${ssh_conn}
    ${cleaned_output}=  Strip String  ${output}
    Run Keyword If  '${cleaned_output}'=='1'  Log   The SW exists on the artifactory    console=${true}
    ...  ELSE IF  '${cleaned_output}'=='0'  Log    The SW doesn't exist on the artifactory  console=${true}

Check if unzip and wget installed
   [Arguments]    ${ssh_connection}
   ${unzip_path}=  Set Variable    /var/usrlocal/bin/unzip
   ${wget_path}=  Set Variable     /var/usrlocal/bin/wget
   ${unzip_prepare}=  Set Variable    /var/home/core/unzip_prepare/unzip
   ${wget_prepare}=  Set Variable    /var/home/core/wget_prepare/wget
   ${unzip_curl}=  Set Variable    https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/kuafu/tools/unzip
   ${wget_curl}=  Set Variable    https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/kuafu/tools/wget
   ${unzip_pre_check}=  Run Keyword And Return Status  Check If File Downloaded  ${unzip_path}
   ${wget_pre_check}=  Run Keyword And Return Status  Check If File Downloaded  ${wget_path}
   Run keyword if  ${unzip_pre_check}!=True  Run Keywords
   ...    Log To Console  Unzip doesn't exist. Unzip preparing started
   ...    AND  ssh.Execute  mkdir /var/home/core/unzip_prepare  connection=${ssh_connection}
   ...    AND  ssh.Execute  curl -o ${unzip_prepare} ${unzip_curl}  connection=${ssh_connection}
   ...    AND  ssh.Execute  chmod 777 ${unzip_prepare}  connection=${ssh_connection}
   ...    AND  ssh.Execute  sudo mv ${unzip_prepare} /var/usrlocal/bin  connection=${ssh_connection}
   ...    AND  Check If File Downloaded  ${unzip_path}
   ...    AND  ssh.Execute  rm -r /var/home/core/unzip_prepare  connection=${ssh_connection}
   Run keyword if  ${wget_pre_check}!=True  Run Keywords
   ...    Log To Console  wget doesn't exist. Wget preparing started
   ...    AND  ssh.Execute  mkdir /var/home/core/wget_prepare  connection=${ssh_connection}
   ...    AND  ssh.Execute  curl -o ${wget_prepare} ${wget_curl}  connection=${ssh_connection}
   ...    AND  ssh.Execute  chmod 777 ${wget_prepare}  connection=${ssh_connection}
   ...    AND  ssh.Execute  sudo mv ${wget_prepare} /var/usrlocal/bin  connection=${ssh_connection}
   ...    AND  Check If File Downloaded  ${wget_path}
   ...    AND  ssh.Execute  rm -r /var/home/core/wget_prepare  connection=${ssh_connection}

CCR injection CLI
    [Arguments]  ${ccr_location_cli}
    [Documentation]  Description: KW updates registry in main and prerequisite values-override.yaml files using
    ...              update_CLI_registry keyword from cloud_uuf_keywords.py.
    ...              **Example of simple usage:**
    ...              CCR injection CLI  ${ccr_location_cli}
    ${hw_conv}=  Convert To Lower Case  ${hw}
    ${ccr_cli}=  Set Variable  "ccr-${ccr_location_cli}-vrf-${hw_conv}-01.wroclaw.nsn-rdnet.net:443/${hw_conv}"
    Set Suite Variable  ${vcu_main_path}  /home/ute/testline_configuration/${hostname}/values_override/vCU/main.yaml
    Set Suite Variable  ${vcu_prereq_path}  /home/ute/testline_configuration/${hostname}/values_override/vCU/prerequisites.yaml
    Set Suite Variable  ${vdu_main_path}  /home/ute/testline_configuration/${hostname}/values_override/vDU/main.yaml
    Set Suite Variable  ${vdu_prereq_path}  /home/ute/testline_configuration/${hostname}/values_override/vDU/prerequisites.yaml
    Run keyword if  '${hw}'=='vCU'  Run keywords
    ...  Log To Console  vCU CCR registry updating
    ...  AND  update_CLI_registry    path=${vcu_main_path}    registry_link=${ccr_cli}
    ...  AND  Update_CLI_registry    path=${vcu_prereq_path}    registry_link=${ccr_cli}
    Run keyword if  '${hw}'=='vDU'  Run keywords
    ...  Log To Console  vDU CCR registry updating
    ...  AND  update_CLI_registry    path=${vdu_main_path}    registry_link=${ccr_cli}
    ...  AND  update_CLI_registry    path=${vdu_prereq_path}    registry_link=${ccr_cli}

Create Test Log Directories
    [Arguments]    ${test_results}=/home/ute/test_results    ${running_test_name}=${Empty}
    ...            ${pass_logs_collection}=${False}          ${second_vcu}=${False}
    ${now}    Run    date +%F_%H-%M-%S
    ${test_short_name}    get_test_name    ${running_test_name}
    ${LOG_DIR}   get_log_dir    ${test_results}  ${now}_${test_short_name}  ${pass_logs_collection}
    Create Directory     ${log_dir}
#    Set Test Variable    ${RESULTS}  ${LOG_DIR}
    Create Directory     ${log_dir}/vCU
    Create Directory     ${log_dir}/vDU
    Run Keyword If       ${second_vcu}           Create Directory     ${log_dir}/vCU2
    Log To Console    Test result path: ${log_dir}
    [Return]  ${log_dir}

Set Passed Logs Collected
    [Arguments]    ${iteration_test_name}=${Empty}
    ${name}    Set Variable If    "${iteration_test_name}"=="${Empty}"   ${TEST_NAME}    ${iteration_test_name}
    ${exists}    Get Variable Value    ${passed_logs_status}    ${None}
    Run Keyword If    "${exists}"=="${None}"    Set Test Variable    &{passed_logs_status}    ${name}=${True}    ELSE
    ...    Set To Dictionary    ${passed_logs_status}    ${name}=${True}
    Log    dict: ${passed_logs_status}    console=True

Collect Snapshot From vCU2
    [Arguments]  ${log_dir}
    ${temp_conn}=    Connect to ADMIN  hw_type=vCU  custom_LMP_addr=${tl.gnbs[1].cu.oam_http_connection_details.addr}
    Log  Snapshot collection started   console=True
    vcu_admin.get_local_snapshot    directory=${log_dir}    compressed=${True}    operation_timeout=600        connection=${temp_conn}
    Log              Snapshot collection ended   console=True
    [Teardown]      vcu_admin.disconnect    connection=${temp_conn}

Collect Logs
    [Arguments]  ${hw_type}  ${non_upgraded_cnf}=${Empty}  ${iteration_test_name}=${Empty}  ${pass_logs_collection}=${False}
    ...          ${namespace}=${Empty}  ${second_vcu}=${False}
    ${log_dir}   Create Test Log Directories
    ...  /home/ute/test_results/${hw_type}_cli_tests
    ...  ${iteration_test_name}
    ...  ${pass_logs_collection}
    ...  ${second_vcu}
    Run Keyword If    ${second_vcu}
    ...  Run Keyword And Ignore Error    Collect Snapshot From vCU2    log_dir=${log_dir}/vCU2
    Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${log_dir}/${hw_type}  hw_type=${hw_type}
    Run Keyword If  '${non_upgraded_cnf}' != '${Empty}'
    ...  Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${log_dir}/${non_upgraded_cnf}  hw_type=${non_upgraded_cnf}
    ${ns}  Set Variable if  '${hw_type}'=='vDU'  ${CRAN_VDU}  ${CRAN_VCU}
    ${ns}  Set Variable if  '${namespace}' != '${Empty}'    ${namespace}    ${ns}
    ${k8s_ip}    Set Variable if  '${hw_type}'=='vDU'   ${SSH_VDU_IP}       ${SSH_VCU_IP}
    ${nop_logs}  Set Variable if  '${hw_type}'=='vDU'   ${True}  ${False}
    Gather Logs From OCP And Send To VM
    ...  ${ns}
    ...  ${k8s_ip}
    ...  ${log_dir}/${hw_type}
    ...  ${SSH_K8S_USERNAME}
    ...  ${SSH_K8S_PASSWORD}
    ...  ${nop_logs}
    ${namespace}  Set Variable if  '${non_upgraded_cnf}'=='vDU'  ${CRAN_VDU}  ${CRAN_VCU}
    ${k8s_ip}  Set Variable if  '${non_upgraded_cnf}'=='vDU'  ${SSH_VDU_IP}  ${SSH_VCU_IP}
    ${nop_logs}  Set Variable if  '${non_upgraded_cnf}'=='vDU'  ${True}  ${False}
    Run Keyword If  '${non_upgraded_cnf}' != '${Empty}'
    ...  Gather Logs From OCP And Send To VM
    ...  ${namespace}
    ...  ${k8s_ip}
    ...  ${log_dir}/${non_upgraded_cnf}
    ...  ${SSH_K8S_USERNAME}
    ...  ${SSH_K8S_PASSWORD}
    ...  ${nop_logs}
    Run Keyword If  ${second_vcu}
    ...  Gather Logs From OCP And Send To VM
    ...  ${NAMESPACE_vCU2}
    ...  ${SSH_K8S_VCU2_IP}
    ...  ${log_dir}/vCU2
    ...  ${SSH_K8S_USERNAME}
    ...  ${SSH_K8S_PASSWORD}
    ...  ${False}
    Run Keyword If    ${pass_logs_collection}    Set Passed Logs Collected    ${iteration_test_name}


Common Test Setup Cloud
    [Documentation]  Set of actions which will be executed before each of test.
    show_environ
    Log  \n\n============== COMMON TEST SETUP CLOUD ==============  console=${true}
    ${hw}=    Get Substring    ${TEST_NAME}    -3
    Set Suite Variable  ${hw}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    ${ccr_image}    get_ccr_image_path_list_variable    CCR_IMAGE_PATH_LIST
    Set Suite Variable    ${CCR_IMAGE_PATH_LIST}     ${ccr_image}
    ${rollback_ccr_image}    get_ccr_image_path_list_variable    ROLLBACK_CCR_IMAGE_PATH_LIST
    Set Suite Variable    ${ROLLBACK_CCR_IMAGE_PATH_LIST}     ${rollback_ccr_image}

    ${cloud_execution}=  check_if_cloud_execution
    Run Keyword If    ${cloud_execution}    Get Target SW From CM Artifacts

    ${admin_connection}=  Connect to ADMIN  hw_type=${hw}
    Set Suite Variable  ${admin_connection}

    ${ssh_conn}=    Connect To Admin via SSH    hw_type=${hw}
    Set Test Variable    ${ssh_conn}

    ssh.Execute  ${fix_cmd}  connection=${ssh_conn}
    ${output}=  ssh.Execute  oc login --username=nokiaadmin --password=nokiaadmin  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Check if unzip and wget installed    ${ssh_conn}

    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Suite Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}

    Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Check Alarm List On vCU/vDU  ${hw}
    Log  =========== COMMON TEST SETUP DONE ============  console=${true}

Common Test Teardown Cloud
    [Documentation]  Set of actions which will be executed after each of test.
    Log  \n============ COMMON TEST TEARDOWN CLOUD =============  console=${true}
    Run Keyword And Ignore Error  Disconnect from ADMIN  ${admin_connection}  hw_type=${hw}
    Run Keyword And Ignore Error  Disconnect from ADMIN via SSH    ${ssh_conn}  hw_type=${hw}
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!
    Log  ========== COMMON TEST TEARDOWN DONE ==========\n  console=${true}

Collect Logs From Passed Execution If Needed
    [Arguments]      ${iteration_test_name}=${Empty}    ${namespace}=${Empty}
    ${is_passed_logs_collected}    Get Passed Logs Collected Status    ${iteration_test_name}
    Run Keyword If    not ${is_passed_logs_collected}
    ...    Collect Logs  ${hw}  ${non_upgraded_cnf}  ${iteration_test_name}  ${True}  ${namespace}

Remove Storage Dir
    ${pattern}=    Set Variable    (?i)(MantaRay|MR)
    ${is_mr}=  Get Regexp Matches    ${TEST_NAME}    ${pattern}
    IF  'MR' not in ${is_mr} and 'MantaRay' not in ${is_mr}
        ${ssh_conn}=    Connect To Admin via SSH    hw_type=${hw}
        FOR  ${operation_type}  IN  @{storage_dir}
            ${path_to_remove}=    Get From Dictionary   ${storage_dir}  ${operation_type}
            Run Keyword And Ignore Error  ssh.Execute  rm -r ${path_to_remove}  connection=${ssh_conn}
            Run Keyword And Ignore Error  ssh.Assert Exit Status  0  connection=${ssh_conn}
        END
        Set Suite Variable    ${CCR_IMAGE_PATH_LIST}              ${None}
        Set Suite Variable    ${ROLLBACK_CCR_IMAGE_PATH_LIST}     ${None}
    END
    [Teardown]    Run Keyword And Ignore Error    Disconnect from ADMIN via SSH    ${ssh_conn}  hw_type=${hw}

Get Target SW From CM Artifacts
    ${vcu}=    get_sw_from_artifacts  vcu_cnf
    Set Suite Variable    ${SW_VCU}    ${vcu}
    ${vdu}=    get_sw_from_artifacts  vdu_cnf
    Set Suite Variable    ${SW_VDU}    ${vdu}

Common Test Setup MantaRay Cloud
    [Documentation]  Set of actions which will be executed before each of test.
    [Arguments]  ${deploy_deletion}=${None}
    Log  Common Test Setup MantaRay Cloud  console=${True}
    #######################################################
    #COMMON PART
    #######################################################
    ${vcu_deployed}=  Set Variable    None
    ${vdu_deployed}=  Set Variable    None
    ${sw_release_CU}=  Split String    ${VCU_SW_VERSION}    _
    ${sw_release_CU}=  Get From List    ${sw_release_CU}    0
    ${sw_release_DU}=  Split String    ${VDU_SW_VERSION}    _
    ${sw_release_DU}=  Get From List    ${sw_release_DU}    0
    Set Test Variable  ${sw_release_DU}
    Set Test Variable  ${sw_release_CU}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    Set Test Variable  ${cu_25R2_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF25R2/scf_cu.xml
    Set Test Variable  ${cu_25R3_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF25R3/scf_cu.xml
    Set Test Variable  ${cu_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu.xml
    Set Test Variable  ${du_25R2_scf}   /home/ute/testline_configuration/${hostname}/vDUCNF25R2/scf_du.xml
    Set Test Variable  ${du_25R3_scf}   /home/ute/testline_configuration/${hostname}/vDUCNF25R3/scf_du.xml
    Set Test Variable  ${du_trunk_scf}  /home/ute/testline_configuration/${hostname}/vDUCNF00/scf_du.xml
    ${hw}=  Get Substring  ${TEST_NAME}  -3
    Set Suite Variable  ${hw}
    ${ssh_conn}=  Connect To Admin via SSH  hw_type=${hw}
    Set Test Variable  ${ssh_conn}
    ssh.Execute  ${fix_cmd}  connection=${ssh_conn}
    ${output}=  ssh.Execute  oc login --username=nokiaadmin --password=nokiaadmin  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Check if unzip and wget installed  ${ssh_conn}
    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Suite Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    ${lab}=  Get Integrated Lab Name From Core  connection=${ssh_conn}
    #######################################################
    #CHARTS DELETION
    #######################################################
    IF  ${deploy_deletion}==${True}
        IF  '${lab}'=='None'
            mantaray.Remove Existing Charts  hw_type=vcu  chart_name=all  conn=${ssh_conn}
            mantaray.Remove Existing Charts  hw_type=vdu  chart_name=all  conn=${ssh_conn}
        ELSE IF  '${lab}'!='None'
            mantaray.Deintegrate Cloud Server from NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${lab}  hw_type=vCU  force_deintegrate=${True}
            mantaray.Deintegrate Cloud Server from NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${lab}  hw_type=vDU  force_deintegrate=${True}
            mantaray.Remove Existing Charts  hw_type=vcu  chart_name=all  conn=${ssh_conn}
            mantaray.Remove Existing Charts  hw_type=vdu  chart_name=all  conn=${ssh_conn}
        END
        mantaray.Integrate Cloud Server with NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vCU
        mantaray.Integrate Cloud Server with NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vDU
    #######################################################
    #NOP DEPLOYMENT IF NEEDED
    #######################################################
        ${deployed_charts}=  Get Names And Status From Helm List  ${ssh_conn}
        ${rannic}=  Evaluate  [chart['Name'] for chart in @{deployed_charts} if chart['Name'].startswith('ran-nic-sw-controller')]
        ${nokia_sync}=  Evaluate  [chart['Name'] for chart in @{deployed_charts} if chart['Name'].startswith('nokia-sync-operator')]
        ${rannic_len}=  Get Length  ${rannic}
        ${nokia_sync_len}=  Get Length  ${nokia_sync}
        IF  '${rannic_len}'=='0'
            Perform CNF Deployment    nop_type=ran-nic-sw-controller    sw_version=${RANNIC_SW_VERSION}-amd64
            ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}
        END
        IF  '${nokia_sync_len}'=='0'
            Perform CNF Deployment    nop_type=nokia-sync-operator      sw_version=${NOKIA_SYNC_VERSION}-amd64
            ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}
        END
    #######################################################
    #VCU - DEPLOYMENT
    #######################################################
        IF  '${hw}'=='vCU'
            mantaray.Perform CNF Deployment   hw_type=${hw}  sw_version=${VCU_DP_SW}-amd64
            ...  nms_lab_number=${NMS_LAB}    nms_lab_ip=${NMS_LAB_IP}  ccr_name=${CCR_NAME}
            Wait Until Keyword Succeeds       10min  30s  vcu_operations.VCU Pod Status Should Be Normal
            ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
            Set Test Variable  ${admin_connection_vcu}
            Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
            ...  vcu_admin.Perform Commissioning  scf_file=${cu_trunk_scf}  connection=${admin_connection_vcu}
            ...  ELSE IF  '${sw_release_CU}'=='vCUCNF25R2'
            ...  vcu_admin.Perform Commissioning  scf_file=${cu_25R2_scf}  connection=${admin_connection_vcu}
            IF  '${MRBTS}'=='8877'
                Wait Until Keyword Succeeds  2min  30s  certificates.Update CMP Server Settings  hw_type=${hw}  pre-connection=${admin_connection_vcu}
                Initialize Certificate   hw_type=${hw}  pre-connection=${admin_connection_vcu}
            END
        END
    #######################################################
    #VDU - DEPLOYMENT
    #######################################################
        IF  '${non_upgraded_cnf}'=='vDU'
            mantaray.Perform CNF Deployment   hw_type=${non_upgraded_cnf}  sw_version=${VDU_DP_SW}-amd64
            ...  nms_lab_number=${NMS_LAB}    nms_lab_ip=${NMS_LAB_IP}  ccr_name=${CCR_NAME}
            Wait Until Keyword Succeeds       10min  30s  vdu_operations.VDU Pod Status Should Be Normal
            ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=${non_upgraded_cnf}
            Set Test Variable  ${admin_connection_vdu}
            Run Keyword If  (('${sw_release_DU}'=='vDUCNF25R3') or ('${sw_release_DU}'=='vDUCNF00'))
            ...  vdu_admin.Perform Commissioning  scf_file=${du_trunk_scf}  vdu_connection=${admin_connection_vdu}
            ...  ELSE IF  '${sw_release_DU}'=='vDUCNF25R2'
            ...  vdu_admin.Perform Commissioning  scf_file=${du_25R2_scf}  vdu_connection=${admin_connection_vdu}
            IF  '${MRBTS}'=='8877'
                 Wait Until Keyword Succeeds  2min  30s  certificates.Update CMP Server Settings
                 ...  hw_type=${non_upgraded_cnf}  pre-connection=${admin_connection_vdu}
                 Initialize Certificate   hw_type=${non_upgraded_cnf}  pre-connection=${admin_connection_vdu}
            END
            ${vdu_deployed}=  Set Variable  ${True}
            ${vcu_deployed}=  Set Variable  ${True}
        END
        ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
        Set Suite Variable  ${admin_connection_vcu}
        ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=vDU
        Set Suite Variable  ${admin_connection_vdu}
        Wait Until Keyword Succeeds  35min  30s  Check If All Cells On Air  hw_type=vDU  connection=${admin_connection_vdu}
        ${vdu_deployed}=  Set Variable  ${True}
        Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection_vcu}
        ${vcu_deployed}=  Set Variable  ${True}
    END
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
    Set Suite Variable  ${admin_connection_vcu}
    ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=vDU
    Set Suite Variable  ${admin_connection_vdu}
    IF  '${hw}'=='vCU'
        Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
        Check Alarm List On vCU/vDU  ${hw}
    ELSE IF  '${hw}'=='vDU'
        Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vdu}
        Check Alarm List On vCU/vDU  ${hw}
    END

    IF    ${vcu_deployed}==${True} and ${vdu_deployed}==${True}
        Set Suite Variable  ${deploy_deletion}    ${False}
    END
    Log  =========== COMMON TEST SETUP DONE ============  console=${true}

Get Integrated Lab Name From Core
    [Arguments]  ${connection}
    ${output}=  ssh.Execute  ls /etc/docker/certs.d/  connection=${connection}
    ${regex}=  Set Variable  (?<=srnclab)\\d{4}(?=lcm\\.srnblr\\.nsn-rdnet\\.net:8443)
    ${filtred_regex}=  Split String  ${output}  \r\n
    ${nms}=  Get Regexp Matches  ${filtred_regex}[0]  ${regex}
    ${nms_len}=  Get Length  ${nms}
    ${nms_lab}=  Run Keyword If  '${nms_len}'!='0'  Set Variable  ${nms_lab}
    [Return]  ${nms_lab}

Cloud Setup Blue Green
    [Arguments]    ${deploy_deletion}=${None}  ${additional_values}=${False}
    Log  \nCloud Setup Blue Green
    ${vcu_deployed}=   Set Variable    ${None}
    ${sw_release_CU}=  Split String    ${VCU_SW_VERSION}    _
    ${sw_release_CU}=  Get From List   ${sw_release_CU}    0
    Set Test Variable  ${sw_release_CU}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    Set Test Variable  ${cu_25R2_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF25R2/scf_cu.xml
    Set Test Variable  ${cu_25R3_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF25R3/scf_cu.xml
    Set Test Variable  ${cu_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu.xml
    ${hw}=  Get Substring  ${TEST_NAME}  -3
    Set Suite Variable  ${hw}
    ${ssh_conn}=  Connect To Admin via SSH  hw_type=${hw}
    Set Test Variable  ${ssh_conn}
    ssh.Execute  ${fix_cmd}  connection=${ssh_conn}
    ${output}=  ssh.Execute  oc login --username=nokiaadmin --password=nokiaadmin  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Suite Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    IF  ${deploy_deletion}
        ${lab}=  Get Integrated Lab Name From Core  connection=${ssh_conn}
    #    #######################################################
        mantaray.Deintegrate Cloud Server from NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vCU  force_deintegrate=${True}
        mantaray.Remove Existing Charts  hw_type=vcu  chart_name=all  conn=${ssh_conn}
        Delete Namespace  hw_type=vcu  namespace=${CRAN_VCU}99  connection=${ssh_conn}
        Delete Namespace  hw_type=vcu  namespace=${CRAN_VCU}  connection=${ssh_conn}
        Delete Namespace  hw_type=vcu  namespace=${CRAN_VCU}1  connection=${ssh_conn}
        Run Keyword And Ignore Error  nms.Delete Plan  plan_name=${MRBTS_CU}_auto_upgrade_plan
        Run Keyword And Ignore Error  nms.Delete Plan  plan_name=${MRBTS}_rollback_before_${sw_version}
        mantaray._Enable Credential Management Feature  nms_lab_ip=${NMS_LAB_IP}
        Integrate Cloud Server with NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vCU
        Perform CNF Deployment  hw_type=vCU   sw_version=${VCU_DP_SW}-amd64
        ...                     nms_lab_number=${NMS_LAB}   nms_lab_ip=${NMS_LAB_IP}  ccr_name=${CCR_NAME}  blue_green=${True}
        Wait Until Keyword Succeeds  10min  30s  vcu_operations.VCU Pod Status Should Be Normal
        ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
        Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_trunk_scf}  connection=${admin_connection_vcu}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF25R3'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_25R3_scf}  connection=${admin_connection_vcu}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF25R2'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_25R2_scf}  connection=${admin_connection_vcu}
        Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection_vcu}
        mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  blue_green=${True}
        ${vcu_deployed}=  Set Variable  ${True}
    ELSE
        ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
    END
    IF  ${additional_values}
        ${upue_amount}=  Count Upue Instances  connection=${admin_connection_vcu}
        Should Be Equal  '${upue_amount}'  '11'
        Log  Amount Of UPUE is ${upue_amount}  console=${True}
    END
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    IF    ${vcu_deployed}==${True}
        Set Suite Variable  ${deploy_deletion}  ${False}
    END
    Log  \nCloud Setup Blue Green - END console=${True}

Count Upue Instances
    [Arguments]  ${connection}=${None}
    ${vnfcs}=  vcu_admin.get_vnfcs_states  connection=${connection}
    ${upue_list}=  Create List
    FOR  ${vnfc}  IN  @{vnfcs}
       ${vnfcs_r}=  Get From Dictionary  ${vnfc}    name
       ${match}=    Get Regexp Matches   ${vnfcs_r}    .*upue.*
       Run Keyword IF  ${match} != []  Append To List  ${upue_list}  ${match}[0]
    END
    ${upue_amount}=  Get Length  ${upue_list}
    [Return]  ${upue_amount}

Set Save Status Command As Test Variable
    [Arguments]    ${ssh_conn}  ${namespace}
    ${main_chart_name}=     Get Main Chart Name    ${ssh_conn}  ${namespace}
    Set Test Variable  ${save_status_command}  helm test ${main_chart_name} --filter "name=upgrade-pre-check" -n ${CRAN_VCU}

Turn ON/Off PDU Port
    [Arguments]  ${pdu_ip}  ${pdu_port}  ${pdu_model}  ${operation}
    [Documentation]    Description:    This keyword switching of selected port on EPC, based on given values.
    ...                Input:          ${pdu_ip}    - PDU IP address.
    ...                                ${pdu_port}  - PDU port number to be switched off.
    ...                                ${pdu_model} - PDU model.
    ...                                ${operation} - Operation to be performed on PDU. Options: 'on' or 'off'.
    ...                Author:         roscislaw.szuminski@nokia.com
    Log  \n| PORT: ${pdu_port} | PDU: ${pdu_ip} | - Turning ${operation}  console=${True}
    ute_pdu.Setup PDU       host=${pdu_ip}      model=${pdu_model}  alias=pdu
    IF  '${operation}'=='off'
        ute_pdu.Pdu Outlet Off  outlet=${pdu_port}  alias=pdu
        Sleep    15
        ute_pdu.Pdu outlet should be   outlet=${pdu_port}    status=off  alias=pdu
    ELSE IF  '${operation}'=='on'
        ute_pdu.Pdu Outlet On  outlet=${pdu_port}  alias=pdu
        Sleep    10
        ute_pdu.Pdu outlet should be   outlet=${pdu_port}    status=on  alias=pdu
    END
    Log  | PORT: ${pdu_port} | PDU: ${pdu_ip} | - Turned ${operation}   console=${True}

Check If Rmod Reach Expected State
    [Documentation]    Description:    This keyword verify if rmod operational state is as expected, based on ${expected_state}.
    ...                Input:          ${rmod_dist_name}  - Dist name of rmod "MRBTS-8877/EQM-1/APEQM-1/RMOD-5".
    ...                                ${vdu_connection}  - Connection to vdu.
    ...                                ${expected_state}  - The state that will be verified
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${rmod_dist_name}  ${vdu_connection}  ${expected_state}
    Log  \nChecking If ${rmod_dist_name} is ${expected_state}   console=${True}
    ${rmod_statuses}=  vdu_admin.get_rmods_status   vdu_connection=${vdu_connection}
    FOR  ${rmod_status}  IN   @{rmod_statuses}
        ${dist_name}=  Get From Dictionary   ${rmod_status}[dist_names]    config
        IF  '${dist_name}'=='${rmod_dist_name}'
             ${operational_state}=  Get From Dictionary   ${rmod_status}  operational_state
                 Should Be True   '${operational_state}'=='${expected_state}'
        END
    END
    Log  ${rmod_dist_name} Operational State == ${expected_state}   console=${True}

Get Rmod Active Sw Version
    [Documentation]    Description:    This keyword gets active sw version for selected rmod.
    ...                Input:          ${rmod_dist_name}  - Dist name of rmod "MRBTS-8877/EQM-1/APEQM-1/RMOD-5".
    ...                                ${vdu_connection}  - Connection to vdu.
    ...                Output:         ${active_rmod_sw_build} - Active rmod version "RF.FRM5.trunk24.20250926.020".
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${rmod_dist_name}   ${vdu_connection}
    Log  \Checking Active Sw Version For | ${rmod_dist_name} |  console=${True}
    ${rmod_statuses}=  vdu_admin.get_rmods_status   vdu_connection=${vdu_connection}
    FOR  ${rmod_status}  IN   @{rmod_statuses}
        ${dist_name}=  Get From Dictionary   ${rmod_status}[dist_names]    config
        IF  '${dist_name}'=='${rmod_dist_name}'
            ${active_rmod_sw_build}=  Get From Dictionary   ${rmod_status}  active_sw_build
        END
    END
    Log  ${rmod_dist_name} Current Sw Version: | ${active_rmod_sw_build} |  console=${True}
    [Return]   ${active_rmod_sw_build}

Get Rmod Active Sw Version Component
    [Documentation]    Description:    This keyword gets sw version component, based on rmod sw version.
    ...                Input:          ${rmod_sw_build}  - Rmod sw version "RF.FRM5.trunk24.20250926.020".
    ...                Output:         ${rmod_sw_build_component} - Rmod sw version component "RF.FRM5".
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${rmod_sw_build}
    Log  \Getting Rmod Sw Version Component For: | ${rmod_sw_build} |  console=${True}
    ${rmod_sw_build_components}=  Split String    ${rmod_sw_build}    .
    ${rmod_sw_build_component}=   Set Variable  ${rmod_sw_build_components}[0].${rmod_sw_build_components}[1]
    Log  \Rmod Sw Version Component: | ${rmod_sw_build_component} |  console=${True}
    [Return]    ${rmod_sw_build_component}

Get Expected Rmod Sw Build After Update
    [Documentation]    Description:    This keyword retrieves the software version of a specific rmod from the WFT system,
    ...                                based on the specified VDU build.
    ...                Input:          ${rmod_sw_build_component}  - Rmod sw version "RF.FRM5.trunk24.20250926.020".
    ...                                ${vdu_sw_build}  - Vdu sw build.
    ...                Output:         ${rmod_sw_version_after_upgr} - Rmod sw version from work flow tool.
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${rmod_sw_build_component}  ${vdu_sw_build}
    ${api_link}=  Set Variable  "https://wft.int.net.nokia.com:8091/api/v1/CRAN/CI_CRAN/builds/${vdu_sw_build}/sub_builds/configuration.json"
    ${cmd}=       Set Variable   curl -s --netrc-file /home/ute/.netrc ${api_link}
    ${rmod_sw_version_after_upgr}=   Set Variable
    ${output}=    Run Process    bash    -c    ${cmd}    stdout=PIPE    stderr=PIPE
    ${json_text}=    Strip String    ${output.stdout}
    ${data}=    Evaluate    json.loads('''${json_text}''')    modules=json
    FOR  ${sub_build}  IN   @{data}[object]
        ${version}=  Get From Dictionary   ${sub_build}    version
        IF  '${rmod_sw_build_component}' in '${version}'
            ${rmod_sw_version_after_upgr}=   Set Variable    ${version}
        END
    END
    Log    Rmod Sw Version After Upgrade Should Be: | ${rmod_sw_version_after_upgr} |  console=${True}
    [Return]  ${rmod_sw_version_after_upgr}

Get Radio Info From Init
    [Documentation]    Description:    The keyword retrieves information from __init__.py, about the IP address,
    ...                                port, and EPC model to which the radio module is connected, and SN of radio module.
    ...                Output:         Nested dictionary with radio serial number as the key
    ...                                1M211010137': {'ip': '10.44.206.82', 'model': 'EPC', 'port': 5}
    ...                Author:         roscislaw.szuminski@nokia.com
     ${rmods_sn_dict}=     Create Dictionary
     ${rmodn_apc_info}=    Create Dictionary
     FOR  ${rm}  IN  @{tl.gnbs[0].dus[0].rus}
         Set To Dictionary    ${rmodn_apc_info}    ip                    ${rm.pdu_port.pdu.addr}
         Set To Dictionary    ${rmodn_apc_info}    port                  ${rm.pdu_port.port_no}
         Set To Dictionary    ${rmodn_apc_info}    model                 ${rm.pdu_port.pdu.model}
         Set To Dictionary    ${rmods_sn_dict}     ${rm.serial_number}   ${rmodn_apc_info}
     END
    [Return]    ${rmods_sn_dict}

Map RMOD Serial Numbers To Dist Names
    [Documentation]    Description:    The keyword retrieves information from admin, about the serial number of the radio module,
    ...                                and dist_name.
    ...                Output:         Dictionary with serial number as the key, and rmod dn as value
    ...                                1M211010137': 'MRBTS-8877/EQM-1/APEQM-1/RMOD-3'
    ...                Author:         roscislaw.szuminski@nokia.com
    ${admin_connection}=       Connect to ADMIN  hw_type=vDU
    Set Suite Variable         ${admin_connection}
    ${rmod_info}=              Get Rmods Status  vdu_connection=${admin_connection}
    ${cloud_SN_list_rmods}=    Create List
    ${rmods_mapping_cloud}=    Create Dictionary
    FOR  ${item}  IN  @{rmod_info}
        Set To Dictionary  ${rmods_mapping_cloud}  ${item['serial_number']}  ${item['dist_names']['config']}
    END
    ${rmods_mapping_cloud}=  Set Variable  ${rmods_mapping_cloud}
    [Return]  ${rmods_mapping_cloud}

Get Cells From Selected Rmod
    [Documentation]    Description:    This keyword gets cell(s) from selected rmod.
    ...                Input:          ${rmod_dn}     - Rmod dist name "MRBTS-8700/EQM-1/APEQM-1/RMOD-1".
    ...                                ${connection}  - Vdu connection.
    ...                Output:         ${selected_rmod_cells} - List of cells under selected rmod, ['41', '42'].
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]   ${rmod_dn}=${None}  ${connection}=${None}
    ${rmod_statuses}=  vdu_admin.get_rmods_status   vdu_connection=${connection}
    FOR  ${rmod_status}  IN   @{rmod_statuses}
       ${dist_name}=  Get From Dictionary   ${rmod_status}[dist_names]    config
       IF  '${dist_name}'=='${rmod_dn}'
           ${selected_rmod_cells}=  Get From Dictionary   ${rmod_status}  cell_ids
       END
    END
    [Return]  ${selected_rmod_cells}

Check Deep Sleep On Selected Rmod Vdu
    [Documentation]    Description:    This keyword checks if state of selected rmod is changed to expected.
    ...                Input:          ${selected_rmod} - Rmod dist name "MRBTS-8700/EQM-1/APEQM-1/RMOD-1".
    ...                                ${expected_operational_state} - Expected operational state: 'ENABLED' or 'DISABLED'.
    ...                                ${expected_deep_sleep_state}  - Expected deep sleep state: 'SLEEP'
    ...                                ${connection} - vDU connection
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${selected_rmod}  ${expected_operational_state}  ${expected_deep_sleep_state}  ${connection}
    Log   Wait For Deep Sleep For: ${selected_rmod}   console=${True}
    ${rmod_statuses}=  vdu_admin.get_rmods_status   vdu_connection=${connection}
    FOR  ${rmod_status}  IN   @{rmod_statuses}
        ${dist_name}=  Get From Dictionary   ${rmod_status}[dist_names]    config
        IF  '${dist_name}'=='${selected_rmod}'
            ${deep_sleep_state}=  Get From Dictionary   ${rmod_status}  power_state
            ${operational_state}=  Get From Dictionary   ${rmod_status}  operational_state
            ${deep_sleep_state}=  Evaluate  "${deep_sleep_state}".upper()
            ${operational_state}=    Evaluate  "${operational_state}".upper()
            Should Be True  '${operational_state}'=='${expected_operational_state}' and '${deep_sleep_state}'=='${expected_deep_sleep_state}'
        END
     END

Create NRPGR For Power Saving vDU
    [Documentation]    Description:    This keyword creates NRPGRP object with configured parameters for power saving.
    ...                Input:          ${selected_cells} - Cell or list of cells, which will be set for power saving.
    ...                                ${connection}     - vDU connection
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]   ${selected_cells}=${None}  ${connection}=${None}
     ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
     ${PLANS_DIR}    Set Variable    ${RESULTS}/plans
     ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRPGRP-0
     admin.create delta  ${delta_create_nrpgrp}
     admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  15  ${delta_create_nrpgrp}
     admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
     ${lbpsCellList}=  Create Dictionary
     FOR  ${cell}  IN  @{selected_cells}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=100
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
     END
     Get Time And Date With Minute Offset  3minutes  60minutes
     ${lbpsPeriodList}=  Create Dictionary
     Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
     Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=120
     Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
     Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
     Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
     admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
     Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
     admin.get delta  ${delta_create_nrpgrp}
     admin.save delta  ${PLANS_DIR}/delta_create_nrpgrp_5GC000431.json  ${delta_create_nrpgrp}
     Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
     vdu_admin.Perform Delta Recommissioning    delta_file=${PLANS_DIR}/delta_create_nrpgrp_5GC000431.json    vdu_connection=${connection}

Delete NRPGRP Objects
    [Documentation]  Remove old NRPGRP objects from BTS.
    [Arguments]   ${connection}=${None}
    ${nrpgrp_dn}=  Set Variable    MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRPGRP-0
    ${delta_gpoup_obj}=  Set Variable  gpoup_del
    ${PLANS_DIR}    Set Variable    ${RESULTS}/plans
    admin.create delta  ${delta_gpoup_obj}
    admin.append managed object to delta  ${nrpgrp_dn}  delete  delta_id=${delta_gpoup_obj}
    admin.get delta  ${delta_gpoup_obj}
    admin.save delta  ${RESULTS}/delete_gpoup_obj.json  delta_id=${delta_gpoup_obj}
    Sleep    30s
    vdu_admin.Perform Delta Recommissioning    delta_file=${RESULTS}/delete_gpoup_obj.json    vdu_connection=${connection}
    Log   ${nrpgrp_dn} Deleted  console=${True}

Check Power Saving NR Vdu
    [Arguments]  ${cells}  ${expected_operational_state}  ${expected_energy_saving_state}  ${connection}
    Log   Wait For Energy Saving For NRCELS: ${cells}  console=${True}
    FOR  ${cell}  IN  @{selected_ru_cells}
        ${cells_info}=  vdu_admin.get_cell_specific_info  cell_id=${cell}   vdu_connection=${connection}
        ${energy_saving}=      Get From Dictionary  ${cells_info}  energySavingState
        ${operational_state}=  Get From Dictionary  ${cells_info}[basicCell]  operationalState
        ${energy_saving_state}=  Evaluate  "${energy_saving}".upper()
        ${operational_state}=    Evaluate  "${operational_state}".upper()
        Should Be True  '${operational_state}'=='${expected_operational_state}' and '${energy_saving_state}'=='${expected_energy_saving_state}'
    END

Set Feature Under Given Object
    [Documentation]  Keyword sets indicated valuse for chosen feature under given object, object should be given as
    ...  in the dist name form
    ...  Example of usage:
    ...  Set Feature Under Given Object  ${distName_of_the_object}  ${feature_flag}  ${feature_flag_value}
    ...
    [Arguments]  ${object_DN}  ${feature_flags}  ${value}  ${connection}
    ${PLANS_DIR}    Set Variable    ${RESULTS}/plans
    ${feature_flag_delta}=  Set Variable  ${feature_flags}_${value}
    admin.create delta  ${feature_flag_delta}
    Check Activation Flags  ${feature_flags}  ${value}  ${feature_flag_delta}    ${object_DN}
    admin.get delta  ${feature_flag_delta}
    admin.save delta  ${PLANS_DIR}/delta_${feature_flags}_${value}.json  ${feature_flag_delta}
    IF     '${hw}'=='vCU'
    vcu_admin.Perform Delta Recommissioning    delta_file=${PLANS_DIR}/delta_${feature_flags}_${value}.json    connection=${connection}
    END
    IF     '${hw}'=='vDU'
    vdu_admin.Perform Delta Recommissioning    delta_file=${PLANS_DIR}/delta_${feature_flags}_${value}.json    vdu_connection=${connection}
    END

Check Activation Flags
    [Documentation]  The keyword checks whether a single flag or multiple flags were passed.
    ...  If a single value was passed, its type is changed to a list.
    ...
    [Arguments]  ${feature_flags}  ${value}  ${feature_flag_delta}  ${object_DN}
    ${flags_before}=  Set Variable  ${feature_flags}
    ${flags}=  Set Variable    ${feature_flags}
    ${flags}=  Run Keyword If  $flags.__class__ != list  Evaluate  "${flags}".split()
    ...  ELSE  Set Variable  ${flags_before}
    FOR  ${flag}  IN  @{flags}
        Log To Console  Set ${flag} on ${value}
        admin.append parameter update to delta  ${object_DN}  ${flag}  ${value}  ${feature_flag_delta}
    END

Get Time And Date With Minute Offset
    [Arguments]  ${increase_time}=3 minutes  ${minutes_from_increased_time}=0 minutes
    [Documentation]  Keyword returns date and time with 3 minutes offset
    ${time}=  Get Time  epoch
    ${time_with_offset}=  Add Time To Date  ${time}  ${increase_time}
    ${day}=  Convert Date  ${time_with_offset}  result_format=%a
    ${start_hour}=  Convert Date  ${time_with_offset}  result_format=%H
    ${start_minutes}=  Convert Date  ${time_with_offset}  result_format=%M
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${minutes_from_increased_time}
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${day}
    Set Test Variable  ${start_hour}
    Set Test Variable  ${start_minutes}
    Set Test Variable  ${time_with_offset}
    Set Test Variable  ${end_time}
    Set Test Variable  ${end_hour}
    Set Test Variable  ${end_minutes}

Radio Modules Sharing Status
    [Arguments]  ${connection}=${None}
    [Documentation]    Description:    The keyword verifies if rmods have configured rf sharing.
    ...                Output:         Two lists with shared and not shared rmods.
    ...                Author:         roscislaw.szuminski@nokia.com
    ${shared_rmods}=  Create List
    ${not_shared_rmods}=  Create List
    ${rmods_info}=  get_current_plan_objects   class_name=RMOD  vdu_connection=${connection}
    FOR   ${rmod_info}  IN  @{rmods_info}[objects]
         ${rmod_dn}=   Get From Dictionary   ${rmod_info}    distName
         ${sharing_info}=  Get From Dictionary   ${rmod_info}    json_repr
         ${rmod_shared_dict}=  Evaluate    json.loads('''${sharing_info}''')    json
         ${key_exists}=  Run Keyword And Return Status    Dictionary Should Contain Key    ${rmod_shared_dict}   sharingConfig
         IF  not ${key_exists}
            Append To List  ${not_shared_rmods}  ${rmod_dn}
         ELSE IF  ${key_exists}
            ${sharing_enabled}=  Get From Dictionary   ${rmod_shared_dict}[sharingConfig]  sharingEnabled
            IF  ${sharing_enabled}
                Append To List  ${shared_rmods}  ${rmod_dn}
            ELSE IF  not ${sharing_enabled}
                Append To List  ${not_shared_rmods}  ${rmod_dn}
            END
         END
    END
    [Return]   ${not_shared_rmods}  ${shared_rmods}

Mantaray vDU Deployment
    [Documentation]    Description:    The keyword removes all charts on the server, and delete cnf object from selected lab,
    ...                                than perfomr mantaray deployment.
    ...                Input:          ${NMS_LAB_IP} = cmwas node ip of selected NMS Lab
    ...                                ${NMS_LAB}    = id number of selected NMS Lab, for example: 1028
    ...                                ${VDU_DP_SW}  = vDU sw version.
    ...                                ${CCR_NAME}   = name of CCR used for deployment. Default is project1
    ...                                ${deploy_deletion} = deployment flag
    ...                Output:         Two lists with shared and not shared rmods.
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]   ${NMS_LAB_IP}  ${NMS_LAB}  ${VDU_DP_SW}  ${CCR_NAME}  ${deploy_deletion}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    ${sw_release_DU}=  Split String    ${VDU_DP_SW}    _
    ${sw_release_DU}=  Get From List    ${sw_release_DU}    0
    Set Test Variable  ${sw_release_DU}
    Set Test Variable  ${du_25R2_scf}   /home/ute/testline_configuration/${hostname}/vDUCNF25R2/scf_du.xml
    Set Test Variable  ${du_trunk_scf}  /home/ute/testline_configuration/${hostname}/vDUCNF00/scf_du.xml
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=vDU
    IF    ${deploy_deletion}
         ${ssh_conn}=  Connect To Admin via SSH  hw_type=vDU
         Set Test Variable  ${ssh_conn}
         mantaray.Remove Existing Charts  hw_type=vdu  chart_name=all  conn=${ssh_conn}
         mantaray.Deintegrate Cloud Server from NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}    hw_type=vDU  force_deintegrate=${True}
         mantaray.Integrate Cloud Server with NMS    nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}    hw_type=vDU
         mantaray.Perform CNF Deployment   hw_type=vDU  sw_version=${VDU_DP_SW}-amd64
         ...  nms_lab_number=${NMS_LAB}    nms_lab_ip=${NMS_LAB_IP}  ccr_name=${CCR_NAME}
         Wait Until Keyword Succeeds       10min  30s  vdu_operations.VDU Pod Status Should Be Normal
         ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=vDU
         Set Test Variable  ${admin_connection_vdu}
         Run Keyword If  (('${sw_release_DU}'=='vDUCNF25R3') or ('${sw_release_DU}'=='vDUCNF00'))
         ...  vdu_admin.Perform Commissioning  scf_file=${du_trunk_scf}  vdu_connection=${admin_connection_vdu}
         ...  ELSE IF  '${sw_release_DU}'=='vDUCNF25R2'
         ...  vdu_admin.Perform Commissioning  scf_file=${du_25R2_scf}  vdu_connection=${admin_connection_vdu}
         ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=vDU
         Set Suite Variable  ${admin_connection_vdu}
         Wait Until Keyword Succeeds  35min  30s  Check If All Cells On Air  hw_type=vDU  connection=${admin_connection_vdu}
    END

Get Charts Names From OCP
    [Documentation]    Description:    Keyword returns ordered list of names of the charts deployen at ocp server.
    ...                Input:          ${hw_type}    = Type of hw vcu or vdu
    ...                                ${connection} = connection to ocp server
    ...                Output:         ${ordered_charts} = ['vcu', 'vcu-prerequisite', 'vcu-cluster-preparation']
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${hw_type}  ${connection}
    ${ordred_charts_all}=  Create List
    ${deployed_charts}=    Get Names And Status From Helm List  ${connection}
    ${charts}=  Evaluate   [chart['Name'] for chart in @{deployed_charts} if chart['Name'].startswith('${hw_type}')]
    FOR  ${i}  IN  @{charts}
        Run Keyword If  not '${i}'.endswith('preparation') and not '${i}'.endswith('prerequisite')  Insert Into List  ${ordred_charts_all}  0  ${i}
        Run Keyword If  '${i}'.endswith('prerequisite')  Insert Into List  ${ordred_charts_all}  1  ${i}
        Run Keyword If  '${i}'.endswith('preparation')   Insert Into List  ${ordred_charts_all}  2  ${i}
    END
    [Return]  ${ordred_charts_all}

Get CNF LCM Operator And Deploy On Lab
    [Arguments]    ${lcm_version}    ${nop_type}    ${lab_ip}    ${hw_type}=vCU    ${id}=${Empty}
    Integrate Cloud Server with NMS  nms_lab_ip=${lab_ip}  nms_lab_number=${NMS_LAB}  hw_type=${hw_type}  id=${id}
    Perform CNF Deployment    nop_type=${nop_type}    sw_version=${lcm_version}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

Cloud Setup CNF LCM Operator Blue Green
    [Arguments]    ${lcm_deployment}=${None}
    Log  \nCloud Setup LCM Blue Green
    ${vcu_deployed}=   Set Variable    ${None}
    ${sw_release_CU}=  Split String    ${VCU_DP_SW}    _
    ${sw_release_CU}=  Get From List   ${sw_release_CU}    0
    Set Test Variable  ${sw_release_CU}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    Set Test Variable  ${cu_26R1_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF26R1/scf_cu.xml
    Set Test Variable  ${cu_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu.xml
    ${hw}=  Get Substring  ${TEST_NAME}  -3
    Set Suite Variable  ${hw}
    ${ssh_conn}=  Connect To Admin via SSH  hw_type=${hw}
    Set Test Variable  ${ssh_conn}
    ssh.Execute  ${fix_cmd}  connection=${ssh_conn}
    ${output}=  ssh.Execute  oc login --username=nokiaadmin --password=nokiaadmin  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Suite Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    ${current_date}      Get Current Date  result_format=%d_%m_%Y_%H_%M
    Set Test Variable    ${CURRENT_DATE}                     ${current_date}
    Set Test Variable    ${lcm_config_files_path}       /home/ute/testline_configuration/${hostname}/LCM_MR_PLANS
    Set Test Variable    ${deployment_xml_file_name}    ${MRBTS_CU}_deployment_bg.xml
    Set Test Variable    ${namespace_xml_file_name}     ${MRBTS_CU}_namespace_bg.xml
    Set Test Variable    ${MR_DEPLOYMENT_PLAN_NAME}     ${MRBTS_CU}_DEPLOYMENT_BG_auto_${CURRENT_DATE}
    Set Test Variable    ${MR_NAMESPACE_PLAN_NAME}      ${MRBTS_CU}_CREATE_BG_NAMESPACE_auto_${CURRENT_DATE}
    Set Test Variable    ${MR_DEPLOYMENT_PLAN_PATH}     ${lcm_config_files_path}/${deployment_xml_file_name}
    Set Test Variable    ${BLUE_NAMESPACE}     ${CRAN_VCU}
    Set Test Variable    ${GREEN_NAMESPACE}    ${CRAN_VCU}green
    Set Test Variable    ${CLOUD_DIST_NAME}    PLMN-PLMN/CLOUD-${MRBTS_CU}
    Set Test Variable    ${BLUE_DIST_NAME}     ${CLOUD_DIST_NAME}/NAMESPACE-${BLUE_NAMESPACE}/RANCNF-1
    Set Test Variable    ${GREEN_DIST_NAME}    ${CLOUD_DIST_NAME}/NAMESPACE-${GREEN_NAMESPACE}/RANCNF-1
    @{RANCNF_DIST_NAMES}    Create List    ${BLUE_DIST_NAME}  ${GREEN_DIST_NAME}
    Set Test Variable       ${RANCNF_DIST_NAMES}
    @{RANCNF_NAMESPACE}     Create List    ${BLUE_NAMESPACE}  ${GREEN_NAMESPACE}
    Set Test Variable       ${RANCNF_NAMESPACE}
    @{K8S_IPs}              Create List    ${SSH_K8S_VCU_IP}
    Set Test Variable       ${K8S_IPs}
    @{MRBTS_CUs}            Create List    ${MRBTS_CU}
    Set Test Variable       ${MRBTS_CUs}
    IF    ${NMS_LAB} in ${TAMPERE_LABS}
        Set test Variable    ${IMAGE_REGISTRY}    srnclab${NMS_LAB}lcm.srntre.nsn-rdnet.net:8443/${CCR_NAME}
    ELSE
        Set test Variable    ${IMAGE_REGISTRY}    srnclab${NMS_LAB}lcm.srnblr.nsn-rdnet.net:8443/${CCR_NAME}
    END
    IF  ${lcm_deployment}
        Log    \nPreparing LCM operator console=${True}
        Get CNF LCM Operator And Deploy On Lab  ${CNF_LCM_OPERATOR_SW_RELEASE}  cnf-lcm-operator-vcu  ${NMS_LAB_IP}
        Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD_DIST_NAME}
        Prepare XML LCM Deployment Plan Before Upload To MR  ${MR_DEPLOYMENT_PLAN_PATH}  ${IMAGE_REGISTRY}  ${VCU_DP_SW}-amd64
        Import Configuration Plan To Lab
        ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${deployment_xml_file_name}    local_dir=${lcm_config_files_path}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME}    ui_values=${True}
        Perform RANCNF Deployment Via LCM Operator
        ...  sw_version=${VCU_DP_SW}-amd64
        ...  nms_lab_ip=${NMS_LAB_IP}
        ...  nms_lab_number=${NMS_LAB}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME}
        ...  dist_names=${BLUE_DIST_NAME}
        ...  parameters=${PARAMETERS}
        ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
        Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_trunk_scf}  connection=${admin_connection_vcu}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF26R1'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_26R1_scf}  connection=${admin_connection_vcu}
        Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection_vcu}
        Start Cloud Watchdog   hw_type=${hw}
        Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
        mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  blue_green=${True}
    END
    IF    ${lcm_deployment}==${True}
        Set Suite Variable  ${lcm_deployment}  ${False}
    END
    Log  \nCloud Setup LCM Blue Green - END console=${True}

Cloud Setup Geo Redundancy VCU
    [Arguments]    ${lcm_deployment}=${None}
    Log  \nCloud Setup LCM  console=${True}
    Set Suite Variable    ${MRBTS_CU2}    ${tl.gnbs[1].cu.global_bts_id}
    Set Suite Variable    ${CRAN_VCU2}    ${tl.gnbs[1].cloud_deployment.cloud_hosting.namespace}
    Set Suite Variable    ${SSH_K8S_VCU2_IP}    ${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Set Suite Variable    ${LMP_VCU2_IP}        ${tl.gnbs[1].cu.oam_http_connection_details.addr}
    ${vcu_deployed}=   Set Variable    ${None}
    ${sw_release_CU}=  Split String    ${VCU_DP_SW}    _
    ${sw_release_CU}=  Get From List   ${sw_release_CU}    0
    Set Test Variable  ${sw_release_CU}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    Set Test Variable  ${cu_26R1_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF26R1/scf_cu.xml
    Set Test Variable  ${cu_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu.xml
    Set Test Variable  ${cu2_26R1_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF26R1/scf_cu2.xml
    Set Test Variable  ${cu2_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu2.xml
    Set Suite Variable  ${MRBTS_CU1}  ${MRBTS_CU}
    Set Suite Variable  ${LMP_VCU_IP1}  ${LMP_VCU_IP}
    ${hw}=  Get Substring  ${TEST_NAME}  -3
    Set Suite Variable  ${hw}
    ${ssh_conn}=  Connect To Admin via SSH  hw_type=${hw}
    Set Test Variable  ${ssh_conn}
    ssh.Execute  ${fix_cmd}  connection=${ssh_conn}
    ${output}=  ssh.Execute  oc login --username=nokiaadmin --password=nokiaadmin  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Suite Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    ${current_date}      Get Current Date  result_format=%d_%m_%Y_%H_%M
    Set Test Variable    ${CURRENT_DATE}                     ${current_date}
    Set Test Variable    ${lcm_config_files_path}            /home/ute/testline_configuration/${hostname}/LCM_MR_PLANS
    Set Test Variable    ${deployment_xml_file_name}         ${MRBTS_CU}_deployment_bg.xml
    Set Test Variable    ${MR_DEPLOYMENT_PLAN_NAME}          ${MRBTS_CU}_DEPLOYMENT_BG_auto_${CURRENT_DATE}
    Set Test Variable    ${deployment_xml_file_name_vcu2}    ${MRBTS_CU2}_deployment_bg.xml
    Set Test Variable    ${MR_DEPLOYMENT_PLAN_NAME_vcu2}     ${MRBTS_CU2}_DEPLOYMENT_BG_auto_${CURRENT_DATE}
    Set Test Variable    ${MR_DEPLOYMENT_PLAN_PATH}          ${lcm_config_files_path}/${deployment_xml_file_name}
    Set Test Variable    ${MR_DEPLOYMENT_PLAN_PATH_vcu2}     ${lcm_config_files_path}/${deployment_xml_file_name_vcu2}
    Set Test Variable    ${NAMESPACE_vCU1}      ${CRAN_VCU}
    Set Test Variable    ${NAMESPACE_vCU2}      ${CRAN_VCU2}
    Set Test Variable    ${CLOUD_DIST_NAME}     PLMN-PLMN/CLOUD-${MRBTS_CU}
    Set Test Variable    ${CLOUD2_DIST_NAME}    PLMN-PLMN/CLOUD-${MRBTS_CU2}
    Set Test Variable    ${VCU1_DIST_NAME}      ${CLOUD_DIST_NAME}/NAMESPACE-${NAMESPACE_vCU1}/RANCNF-1
    Set Test Variable    ${VCU2_DIST_NAME}      ${CLOUD2_DIST_NAME}/NAMESPACE-${NAMESPACE_vCU2}/RANCNF-1
    @{RANCNF_DIST_NAMES}    Create List    ${VCU1_DIST_NAME}  ${VCU2_DIST_NAME}
    Set Test Variable       ${RANCNF_DIST_NAMES}
    @{RANCNF_NAMESPACE}     Create List    ${NAMESPACE_vCU1}  ${NAMESPACE_vCU2}
    Set Test Variable       ${RANCNF_NAMESPACE}
    @{K8S_IPs}              Create List    ${SSH_K8S_VCU_IP}  ${SSH_K8S_VCU2_IP}
    Set Test Variable       ${K8S_IPs}
    @{MRBTS_CUs}            Create List    ${MRBTS_CU}        ${MRBTS_CU2}
    Set Test Variable       ${MRBTS_CUs}
    IF    ${NMS_LAB} in ${TAMPERE_LABS}
        Set test Variable    ${IMAGE_REGISTRY}    srnclab${NMS_LAB}lcm.srntre.nsn-rdnet.net:8443/${CCR_NAME}
    ELSE
        Set test Variable    ${IMAGE_REGISTRY}    srnclab${NMS_LAB}lcm.srnblr.nsn-rdnet.net:8443/${CCR_NAME}
    END
    IF  ${lcm_deployment}
        Log    \nPreparing LCM operator for ${CRAN_VCU}   console=${True}
        Get CNF LCM Operator And Deploy On Lab  ${CNF_LCM_OPERATOR_SW_RELEASE}  cnf-lcm-operator-vcu  ${NMS_LAB_IP}
        Set Suite Variable  ${MRBTS_CU}  ${MRBTS_CU2}
        Log    \nPreparing LCM operator for ${CRAN_VCU2}   console=${True}
        Get CNF LCM Operator And Deploy On Lab
        ...  lcm_version=${CNF_LCM_OPERATOR_SW_RELEASE}
        ...  nop_type=cnf-lcm-operator-vcu
        ...  lab_ip=${NMS_LAB_IP}
        ...  hw_type=vCU
        ...  id=2
        Set Suite Variable  ${MRBTS_CU}  ${MRBTS_CU1}
        Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD_DIST_NAME}
        Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD2_DIST_NAME}
        Prepare XML LCM Deployment Plan Before Upload To MR  ${MR_DEPLOYMENT_PLAN_PATH}  ${IMAGE_REGISTRY}  ${VCU_DP_SW}-amd64
        Prepare XML LCM Deployment Plan Before Upload To MR  ${MR_DEPLOYMENT_PLAN_PATH_vcu2}  ${IMAGE_REGISTRY}  ${VCU_DP_SW}-amd64
        Log    \nImporting configuration plans into srnclab${NMS_LAB}   console=${True}
        Import Configuration Plan To Lab
        ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${deployment_xml_file_name}    local_dir=${lcm_config_files_path}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME}    ui_values=${True}
        Import Configuration Plan To Lab
        ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${deployment_xml_file_name_vcu2}    local_dir=${lcm_config_files_path}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME_vcu2}    ui_values=${True}
#        vcu1
        Log    \nStarting ${CRAN_VCU} deployment   console=${True}
        Perform RANCNF Deployment Via LCM Operator
        ...  sw_version=${VCU_DP_SW}-amd64
        ...  nms_lab_ip=${NMS_LAB_IP}
        ...  nms_lab_number=${NMS_LAB}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME}
        ...  dist_names=${VCU1_DIST_NAME}
        ...  parameters=${PARAMETERS}
        ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
        Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_trunk_scf}  connection=${admin_connection_vcu}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF26R1'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_26R1_scf}  connection=${admin_connection_vcu}
        sleep  30s
        vcu_admin.update_service_account_password    username=georesiliency    password=${Empty}
        ...                                          new_password=Nokia@123    connection=${admin_connection_vcu}
        vcu_admin.update_cmp_server_settings    ref_number=5330    psk_key=fnAR-zMMi-4pVz-mwrG
        ...                                     timeout=60               connection=${admin_connection_vcu}
        vcu_admin.disconnect    connection=${admin_connection_vcu}
        ${admin_connection_vcu}=  Connect to ADMIN  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
        mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  blue_green=${True}
        Log    \nThe ${CRAN_VCU} deployed successfully   console=${True}

#        vcu2
        Log    \nStarting ${CRAN_VCU2} deployment   console=${True}
        Perform RANCNF Deployment Via LCM Operator
        ...  sw_version=${VCU_DP_SW}-amd64
        ...  nms_lab_ip=${NMS_LAB_IP}
        ...  nms_lab_number=${NMS_LAB}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME_vcu2}
        ...  dist_names=${VCU2_DIST_NAME}
        ...  parameters=${PARAMETERS}
        ${admin_connection_vcu2}=  Connect to ADMIN  password=nemuuser  hw_type=vCU  custom_LMP_addr=${LMP_VCU2_IP}
        Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
        ...  vcu_admin.Perform Commissioning  scf_file=${cu2_trunk_scf}  connection=${admin_connection_vcu2}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF26R1'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu2_26R1_scf}  connection=${admin_connection_vcu2}
        sleep  30s
        vcu_admin.update_service_account_password    username=georesiliency    password=${Empty}
        ...                                          new_password=Nokia@123    connection=${admin_connection_vcu2}
        vcu_admin.update_cmp_server_settings    ref_number=5330    psk_key=fnAR-zMMi-4pVz-mwrG
        ...                                     timeout=60               connection=${admin_connection_vcu2}
        vcu_admin.disconnect    connection=${admin_connection_vcu2}
        ${admin_connection_vcu2}=  Connect to ADMIN  hw_type=vCU  custom_LMP_addr=${LMP_VCU2_IP}
        Set Test Variable  ${admin_connection_vcu2}
        Set Suite Variable  ${MRBTS_CU}  ${MRBTS_CU2}
        Set Suite Variable  ${LMP_VCU_IP}  ${LMP_VCU2_IP}
        mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  blue_green=${True}
        Log    \nThe ${CRAN_VCU2} deployed successfully   console=${True}

        Set Suite Variable  ${MRBTS_CU}  ${MRBTS_CU1}
        Set Suite Variable  ${LMP_VCU_IP}  ${LMP_VCU_IP1}
        Log    \nPerforming ${CRAN_VCU} and ${CRAN_VCU2} site reset   console=${True}
        vcu_admin.reset_cu  connection=${admin_connection_vcu}
        vcu_admin.reset_cu  connection=${admin_connection_vcu2}
        sleep  5m  reason=Waiting 5 minutes for all alarms to clear.
        Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection_vcu}
        Log    \nChecking active alarms   console=${True}
        ${vCU1_alarms}     vcu_admin.get_active_alarms  connection=${admin_connection_vcu}
        ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
        ${vCU1_active_alarms}=  Get From Dictionary  ${vCU1_alarms}  total
        Run Keyword If  '${vCU1_active_alarms}'=='0'  Log To Console  No Visible Alarms On ${hw}
        ...  ELSE  Fail  Alarm(s) Visible On ${hw}
        ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
        Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
        ...  ELSE  Fail  Alarm(s) Visible On vCU2
    END
    IF    ${lcm_deployment}==${False}
        ${admin_connection_vcu}=     Connect to ADMIN  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
        ${admin_connection_vcu2}=    Connect to ADMIN  hw_type=vCU  custom_LMP_addr=${LMP_VCU2_IP}
        Set Test Variable  ${admin_connection_vcu2}
    END
    IF    ${lcm_deployment}==${True}
        Set Suite Variable  ${lcm_deployment}  ${False}
    END
    Log  \nCloud Setup LCM - END console=${True}

Perform RANCNF Rollback
    [Arguments]  ${nms_lab_ip}  ${rollback_plan_name}    ${delete_rollback_plan}=${True}
    Log    Starting rollback    console=${True}
    netact.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ssh.connect_to  hostname=${nms_lab_ip}  username=omc  password=Medsql!_1893
    ${command}  Set Variable  racclimx.sh -op RANCNF_Rollback -planName ${rollback_plan_name} -distribution true -feedbackLevel parameterLevel -v
    ssh.execute  command=${command}
    Log  Rollback has been finished  console=${True}
    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error  ssh.Disconnect  AND
    ...           Run Keyword If  ${delete_rollback_plan}      netact.Delete Plan    plan_name=${rollback_plan_name}    AND
    ...           netact.Delete Node    service_name=cmwas

Provision Create Namespace Plan To Cloud
    [Arguments]    ${nms_lab_ip}    ${plan_name}    ${dist_names}
    netact.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    netact.Provision Plan
    ...    plan_name=${plan_name}
    ...    dist_names=${dist_names}
    ...    create_backup_plan=${False}
    ...    provisioning_operation=activate
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    netact.Delete Plan  ${plan_name}    AND
    ...    netact.Delete Node    service_name=cmwas

Integrate MRBTS With NMS Lab
    [Arguments]    ${release}    ${mr}    ${mrbts_address}    ${dist_name}
    netact.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    netact.Integrate Mrbts With Netact
    ...    release=${release}
    ...    mr=${mr}
    ...    mrbts_address=${mrbts_address}
    ...    dist_name=${dist_name}
    ...    security_mode=no TLS
    [Teardown]    netact.Delete Node    service_name=cmwas

Upload Cloud Configuration
    [Arguments]    ${nms_lab_ip}    ${dist_name}
    netact.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    netact.Upload Configuration    ${dist_name}
    [Teardown]    netact.Delete Node    service_name=cmwas

Ensure File Exists On Container
    [Documentation]    Description:    The keyword ensure that specified file exists on chosen container
    ...                Input:          ${ns} = the namespace where file need to be checked
    ...                                ${pod_sub_name}    =    part of the name of the container e.g. "oamext" in po-cran5-oamext-0
    ...                                ${file_path}  =    path where the file neeed to be checked
    ...                                ${file_name}   = file need to be checked
    ...                Author:         anna.niedzwiecka@nokia.com
    [Arguments]    ${ns}    ${pod_sub_name}   ${file_path}   ${file_name}
    Log  \Getting Pods info For: ${ns}
    ${comm_get_pods}=   Set Variable    kubectl get pods -n ${ns} | grep ${pod_sub_name} | awk '{print $1}' | tr -d '\r\n'
    ${get_spec_pod}=   ssh.Execute    ${comm_get_pods}    connection=${ssh_conn}
    ${comm_desc_pods}=    Set Variable   kubectl describe pod ${get_spec_pod} -n ${ns}| grep CONTAINER | grep ctr | awk '{print $2}' | tr -d '\r\n'
    ${get_ctr_name}=   ssh.Execute    ${comm_desc_pods}    connection=${ssh_conn}
    ${separated_string}=      Replace String    ${get_ctr_name}   ctr-   \nctr-
    ${lines}=    Split String    ${separated_string}    \n
    ${crt_list}=   Remove From List  ${lines}    0
    ${ctr_pattern}=    Set Variable      .*${pod_sub_name}
    ${matches_ctr}=    Evaluate    [item for item in ${lines} if re.match(r"${ctr_pattern}", item)]    modules=re
    Should Not Be Empty   ${matches_ctr}   msg=The container does not exist
    ${selected_ctr}=   Set Variable     ${matches_ctr[0]}
    ${comm_find_file}=    Set Variable
    ...    kubectl exec -it -n ${ns} ${get_spec_pod} -c ${selected_ctr} -- find ${file_path} -name ${file_name} -type f -size +0c
    ${find_file}=   ssh.Execute    ${comm_find_file}    connection=${ssh_conn}
    Should Not Be Empty   ${find_file}    msg=The file ${file_name} does not exist in ${file_path}


Cloud Setup CNF LCM Operator Blue Green vCU1 and vCU2
    [Arguments]    ${lcm_deployment}=${None}
    Log  \nCloud Setup LCM  console=${True}
    Set Suite Variable    ${MRBTS_CU2}      ${tl.gnbs[2].cu.global_bts_id}
    Set Suite Variable    ${CRAN_VCU2}      ${tl.gnbs[2].cloud_deployment.cloud_hosting.namespace}
    Set Suite Variable    ${LMP_VCU2_IP}    ${tl.gnbs[2].cu.oam_http_connection_details.addr}
    Set Suite Variable    ${LMP_VCU1_IP}    ${LMP_VCU_IP}
    ${vcu_deployed}=   Set Variable         ${None}
    ${sw_release_CU}=  Split String         ${VCU_DP_SW}    _
    ${sw_release_CU}=  Get From List        ${sw_release_CU}    0
    Set Test Variable  ${sw_release_CU}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable       ${hostname}
    Set Test Variable        ${cu_26R1_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF26R1/scf_cu-single.xml
    Set Test Variable        ${cu_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu-single.xml
    Set Test Variable        ${cu2_26R1_scf}   /home/ute/testline_configuration/${hostname}/vCUCNF26R1/scf_cu2-single.xml
    Set Test Variable        ${cu2_trunk_scf}  /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu2-single.xml
    Set Suite Variable       ${MRBTS_CU1}  ${MRBTS_CU}
    ${hw}=  Get Substring    ${TEST_NAME}  -3
    Set Suite Variable       ${hw}
    ${ssh_conn}=  Connect To Admin via SSH  hw_type=${hw}
    Set Test Variable  ${ssh_conn}
    ssh.Execute  ${fix_cmd}  connection=${ssh_conn}
    ${output}=  ssh.Execute  oc login --username=nokiaadmin --password=nokiaadmin  connection=${ssh_conn}
    Log  ${output}  console=${true}
    ssh.Assert Exit Status  0  connection=${ssh_conn}
    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Suite Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    ${current_date}         Get Current Date  result_format=%d_%m_%Y_%H_%M
    Set Test Variable       ${CURRENT_DATE}                     ${current_date}
    Set Test Variable       ${lcm_config_files_path}            /home/ute/testline_configuration/${hostname}/LCM_MR_PLANS
    Set Test Variable       ${deployment_xml_file_name}         ${MRBTS_CU}_deployment_bg.xml
    Set Test Variable       ${MR_DEPLOYMENT_PLAN_NAME}          ${MRBTS_CU}_DEPLOYMENT_BG_auto_${CURRENT_DATE}
    Set Test Variable       ${namespace_xml_file_name}          ${MRBTS_CU}_namespace_bg.xml
    Set Test Variable       ${MR_NAMESPACE_PLAN_NAME}           ${MRBTS_CU}_CREATE_BG_NAMESPACE_auto_${CURRENT_DATE}
    Set Test Variable       ${deployment_xml_file_name_vcu2}    ${MRBTS_CU2}_deployment_bg.xml
    Set Test Variable       ${MR_DEPLOYMENT_PLAN_NAME_vcu2}     ${MRBTS_CU2}_DEPLOYMENT_BG_auto_${CURRENT_DATE}
    Set Test Variable       ${namespace_xml_file_name_vcu2}     ${MRBTS_CU2}_namespace_bg.xml
    Set Test Variable       ${MR_NAMESPACE_PLAN_NAME_vcu2}      ${MRBTS_CU2}_CREATE_BG_NAMESPACE_auto_${CURRENT_DATE}
    Set Test Variable       ${MR_DEPLOYMENT_PLAN_PATH}          ${lcm_config_files_path}/${deployment_xml_file_name}
    Set Test Variable       ${MR_DEPLOYMENT_PLAN_PATH_vcu2}     ${lcm_config_files_path}/${deployment_xml_file_name_vcu2}
    Set Test Variable       ${NAMESPACE_vCU1}                   ${CRAN_VCU}
    Set Test Variable       ${NAMESPACE_vCU2}                   ${CRAN_VCU2}
    Set Test Variable       ${CLOUD_DIST_NAME}                  PLMN-PLMN/CLOUD-${MRBTS_CU}
    Set Test Variable       ${VCU1_DIST_NAME}                   ${CLOUD_DIST_NAME}/NAMESPACE-${NAMESPACE_vCU1}/RANCNF-1
    Set Test Variable       ${VCU1_DIST_NAME_GREEN}             ${CLOUD_DIST_NAME}/NAMESPACE-${NAMESPACE_vCU1}green/RANCNF-1
    Set Test Variable       ${VCU2_DIST_NAME}                   ${CLOUD_DIST_NAME}/NAMESPACE-${NAMESPACE_vCU2}/RANCNF-1
    Set Test Variable       ${VCU2_DIST_NAME_GREEN}             ${CLOUD_DIST_NAME}/NAMESPACE-${NAMESPACE_vCU2}green/RANCNF-1
    Set Test Variable       ${SSH_K8S_VCU2_IP}     ${SSH_K8S_VCU_IP}
    @{RANCNF_DIST_NAMES}    Create List    ${VCU1_DIST_NAME}  ${VCU1_DIST_NAME_GREEN}  ${VCU2_DIST_NAME}  ${VCU2_DIST_NAME_GREEN}
    Set Test Variable       ${RANCNF_DIST_NAMES}
    @{RANCNF_NAMESPACE}     Create List    ${NAMESPACE_vCU1}  ${NAMESPACE_vCU1}green   ${NAMESPACE_vCU2}  ${NAMESPACE_vCU2}green
    Set Test Variable       ${RANCNF_NAMESPACE}
    @{K8S_IPs}              Create List    ${SSH_K8S_VCU_IP}
    Set Test Variable       ${K8S_IPs}
    @{MRBTS_CUs}            Create List    ${MRBTS_CU}
    Set Test Variable       ${MRBTS_CUs}
    IF    ${NMS_LAB} in ${TAMPERE_LABS}
        Set test Variable    ${IMAGE_REGISTRY}    srnclab${NMS_LAB}lcm.srntre.nsn-rdnet.net:8443/${CCR_NAME}
    ELSE
        Set test Variable    ${IMAGE_REGISTRY}    srnclab${NMS_LAB}lcm.srnblr.nsn-rdnet.net:8443/${CCR_NAME}
    END
    IF  ${lcm_deployment}
        Log    \nPreparing LCM operator for ${CRAN_VCU}   console=${True}
        Get CNF LCM Operator And Deploy On Lab  ${CNF_LCM_OPERATOR_SW_RELEASE}  cnf-lcm-operator-vcu  ${NMS_LAB_IP}
        Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD_DIST_NAME}
        Prepare XML LCM Deployment Plan Before Upload To MR  ${MR_DEPLOYMENT_PLAN_PATH}  ${IMAGE_REGISTRY}  ${VCU_DP_SW}-amd64
        Prepare XML LCM Deployment Plan Before Upload To MR  ${MR_DEPLOYMENT_PLAN_PATH_vcu2}  ${IMAGE_REGISTRY}  ${VCU_DP_SW}-amd64
        Log    \nImporting configuration plans into srnclab${NMS_LAB}   console=${True}
        Import Configuration Plan To Lab
        ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${deployment_xml_file_name}    local_dir=${lcm_config_files_path}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME}    ui_values=${True}
        Import Configuration Plan To Lab
        ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${deployment_xml_file_name_vcu2}    local_dir=${lcm_config_files_path}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME_vcu2}    ui_values=${True}
##        vcu1
        Log    \nStarting ${CRAN_VCU} deployment   console=${True}
        Perform RANCNF Deployment Via LCM Operator
        ...  sw_version=${VCU_DP_SW}-amd64
        ...  nms_lab_ip=${NMS_LAB_IP}
        ...  nms_lab_number=${NMS_LAB}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME}
        ...  dist_names=${VCU1_DIST_NAME}
        ...  parameters=${PARAMETERS}
        ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
        Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_trunk_scf}  connection=${admin_connection_vcu}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF26R1'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu_26R1_scf}  connection=${admin_connection_vcu}
        sleep  30s
        mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  blue_green=${True}
        Log    \nThe ${CRAN_VCU} deployed successfully   console=${True}
#        vcu2
        Log    \nStarting ${CRAN_VCU2} deployment   console=${True}
        Perform RANCNF Deployment Via LCM Operator
        ...  sw_version=${VCU_DP_SW}-amd64
        ...  nms_lab_ip=${NMS_LAB_IP}
        ...  nms_lab_number=${NMS_LAB}
        ...  plan_name=${MR_DEPLOYMENT_PLAN_NAME_vcu2}
        ...  dist_names=${VCU2_DIST_NAME}
        ...  parameters=${PARAMETERS}
        ${admin_connection_vcu2}=  Connect to ADMIN  password=nemuuser  hw_type=vCU  custom_LMP_addr=${LMP_VCU2_IP}
        Set Test Variable  ${admin_connection_vcu2}
        Run Keyword If  (('${sw_release_CU}'=='vCUCNF25R3') or ('${sw_release_CU}'=='vCUCNF00'))
        ...  vcu_admin.Perform Commissioning  scf_file=${cu2_trunk_scf}  connection=${admin_connection_vcu2}
        ...  ELSE IF  '${sw_release_CU}'=='vCUCNF26R1'
        ...  vcu_admin.Perform Commissioning  scf_file=${cu2_26R1_scf}  connection=${admin_connection_vcu2}
        sleep  30s
        Set Suite Variable  ${MRBTS_CU}  ${MRBTS_CU2}
        Set Suite Variable  ${LMP_VCU_IP}  ${LMP_VCU2_IP}
        mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  blue_green=${True}
        Log    \nThe ${CRAN_VCU2} deployed successfully   console=${True}
        Set Suite Variable  ${MRBTS_CU}  ${MRBTS_CU1}
        Set Suite Variable  ${LMP_VCU_IP}  ${LMP_VCU2_IP}
        Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection_vcu}
        Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection_vcu2}
        Log    \nChecking active alarms   console=${True}
        ${vCU1_alarms}     vcu_admin.get_active_alarms  connection=${admin_connection_vcu}
        ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
        ${vCU1_active_alarms}=  Get From Dictionary  ${vCU1_alarms}  total
        Run Keyword If  '${vCU1_active_alarms}'=='0'  Log To Console  No Visible Alarms On ${hw}
        ...  ELSE  Fail  Alarm(s) Visible On ${hw}
        ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
        Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
        ...  ELSE  Fail  Alarm(s) Visible On vCU2
    END
    IF    ${lcm_deployment}==${False}
        ${admin_connection_vcu}=     Connect to ADMIN  hw_type=vCU
        Set Test Variable  ${admin_connection_vcu}
        ${admin_connection_vcu2}=    Connect to ADMIN  hw_type=vCU  custom_LMP_addr=${LMP_VCU2_IP}
        Set Test Variable  ${admin_connection_vcu2}
    END
    IF    ${lcm_deployment}==${True}
        Set Suite Variable  ${lcm_deployment}  ${False}
    END
    Log  \nCloud Setup LCM - END console=${True}

Prepare Switchover Plan
    [Arguments]    ${standby_vcu_mrbts_id}    ${id}
    ${srn}             Set Variable If  ${NMS_LAB} in ${TAMPERE_LABS}  tre  blr
    ${WEB_URL}         Set Variable    https://srnclab${NMS_LAB}lbwas.srn${srn}.nsn-rdnet.net/
    ${current_date}    Get Current Date  result_format=%d_%m_%Y_%H_%M
    ${plan_name}       Set Variable    vCU${standby_vcu_mrbts_id}_switchover_auto_${current_date}
    netact.Add WEB URL    ${WEB_URL}    ${NMS_USERNAME}    ${NMS_PASSWORD}    alias=${NMS_LAB}
    ${mo_id}=             Set Variable                        PLMN-PLMN/MRBTS-${standby_vcu_mrbts_id}/MNL-1/CMD-1
    ${actual_conf}=       netact.Get Actual Configuration     alias=${NMS_LAB}
    ${plan_conf}=         netact.Create Plan Configuration    ${plan_name}      vCU_switchover    alias=${NMS_LAB}
    ${managed_object}=    netact.Get Managed Object           ${actual_conf}    ${mo_id}          alias=${NMS_LAB}
    ${managed_object}=    netact.Create Managed Object        ${plan_conf}      com.nokia.srbts.mnl:SETVNFACTIVITYREQ
    ...                                                       ${managed_object.meta_version}    ${MO_ID}/SETVNFACTIVITYREQ-${id}
    ...                                                       CREATE     targetVnfActivity=2    alias=${NMS_LAB}
    Log    Managed Object: ${managed_object}    console=${TRUE}
    [Return]      ${plan_name}
    [Teardown]    netact.Clean All    alias=${NMS_LAB}


Perform Switchover
    [Arguments]  ${vcu_mrbts_id}  ${operation_id}
    ${plan_name}    Prepare Switchover Plan    standby_vcu_mrbts_id=${vcu_mrbts_id}    id=${operation_id}
    Log    Performing switchover  console=${True}
    netact.Add Node    service_name=cmwas    hostname=${NMS_LAB_IP}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    netact.Provision Plan
    ...    plan_name=${plan_name}
    ...    dist_names=PLMN-PLMN/MRBTS-${vcu_mrbts_id}
    ...    create_backup_plan=${False}
    ...    provisioning_operation=activate
    Sleep  2m
    Log    Switchover ends  console=${True}
    [Teardown]    netact.Delete Node    service_name=cmwas

Delete Namespace From Server
    [Arguments]    ${server_ip}    ${namespaces}
    Set Test Variable  ${SSH_VCU_IP}  ${server_ip}
    ${ssh_temp_conn}=  Connect To Admin via SSH  hw_type=vCU
    FOR  ${namespace}  IN  @{namespaces}
        Log  deleting namespace '${namespace}' from the server ${server_ip}
        ${output}=  ssh.Execute    kubectl delete namespaces ${namespace}    connection=${ssh_temp_conn}
        Log  ${output}  console=${true}
    END
    [Teardown]    Disconnect from ADMIN via SSH    ${ssh_temp_conn}    hw_type=vCU

RNCNF Cleanup
    FOR    ${dist_name}  IN  @{RANCNF_DIST_NAMES}
        Log To Console    Terminating ${dist_name}
        Run Keyword And Ignore Error    Terminate RANCNF    nms_lab_ip=${NMS_LAB_IP}    dist_names=${dist_name}
    END
    FOR    ${IP}  IN  @{K8S_IPs}
        Delete Namespace From Server  server_ip=${IP}  namespaces=${RANCNF_NAMESPACE}
    END
    FOR    ${CU}  IN  @{MRBTS_CUs}
        Set Test Variable    ${MRBTS_CU}    ${CU}
        Log To Console  Terminating cnf-lcm-operator on the PLMN-PLMN/CLOUD-${MRBTS_CU}
        Terminate CNF  nms_lab_ip=${NMS_LAB_IP}   nop_type=cnf-lcm-operator-vcu
        Upload Cloud Configuration    ${NMS_LAB_IP}    PLMN-PLMN/CLOUD-${MRBTS_CU}
        Log To Console  De-integrating the PLMN-PLMN/CLOUD-${MRBTS_CU} from the srnclab${NMS_LAB}
        Deintegrate Cloud Server from NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vCU
    END
