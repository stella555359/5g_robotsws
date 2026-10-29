*** Settings ***
Documentation    TC__SBTS__CM__SMOD_Plug_and_Play
Variables   tc_variables/sbts__cm__smod_plug_and_play_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${TARGET_BTS_SW}                  # Target BTS SW build to be used for BTS SW Update, in format: SBTS00_ENB_9999_251013_000006
                                  # If not defined, automatic detection based on Single run form selection
${FORCE_TARGET_BTS_SW_DL}  False  # Flag used to force download of target BTS build from WFT based on CM tags & selected build from
                                  # CM Single Run form, in order to be used for BTS SW Update.
                                  # In offline running, you need to define ENB_BUILD variable in argfile.txt, in order to select target build which
                                  # will be downloaded and used on BTS
${SN_OF_NEW_SYSTEM_MODULE}        # Serial Number of the new System Module to be used in PnP scenario
${CONFIG_RESET_KPI}        600    # Max allowed duration for Configuration Reset KPI, in seconds
${BTS_MAX_WAIT_TIME}       7200   # Max wait time for BTS to reach OnAir state after PnP start, in seconds
${AUTOCONNECTION_OPTION}   HWID   # Option to be used for Autoconnection in PnP scenario. Possible values: HWID, SiteID or DHCP. Default value: HWID
                                  # In case of DHCP, DHCP_SERVER_IP_ADDRESS, DHCP_SERVER_USER and DHCP_SERVER_PASSWORD parameters must be defined
${DHCP_SERVER_IP_ADDRESS}         # DHCP Server IP Address, to be used in case of AUTOCONNECTION_OPTION set to DHCP
${DHCP_SERVER_USER}               # DHCP Server User, to be used in case of AUTOCONNECTION_OPTION set to DHCP
${DHCP_SERVER_PASSWORD}           # DHCP Server Password, to be used in case of AUTOCONNECTION_OPTION set to DHCP
${BTS_MPLANE_IP_ADDRESS}          # BTS M-Plane IP Address, to be used in case of AUTOCONNECTION_OPTION set to DHCP; If not defined, test will
                                  # automatically read the M-Plane IP Address from the BTS and check if this IP is present in the DHCP configuration
                                  # on the DHCP server; If it is not present, test will fail
${BTS_HARDWARE_ADDRESS}           # BTS HARDWARE (MAC) Address, to be used in case of AUTOCONNECTION_OPTION set to DHCP (ex: 78:f9:b4:dd:40:51);
                                  # If not defined, test will automatically read the MAC Address from the BTS and check if this MAC is present
                                  # in the DHCP configuration on the DHCP server; If it is not present, test will fail

*** Keywords ***
TC__SBTS__CM__SMOD_Plug_and_Play
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29904
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for SMOD Plug and Play, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get Target SW for BTS SW Update
    ...    - if TARGET_BTS_SW variable is defined, that SW build is used
    ...    - if TARGET_BTS_SW variable is not defined, automatic detection based on Single run form selection
    ...  - get all BTS info needed for SW Update
    ...    - BTS ID, BTS mplane IP address, localIpPrefixLength value, primary vlanid value, IPRT gateway ip that matches BTS mplane ip
    ...  - get BTS Configuration Plan from NetAct and Update it
    ...    - upload current BTS configuration to NetAct
    ...    - export BTS Configuration Plan from NetAct to VM
    ...    - update BTS Configuration Plan:
    ...      - replace all  PLMN id=[0-9]* containing operation="update" with operation="create"
    ...      - remove AutoConnSiteID and AutoConnHWID if existing
    ...      - depending on AUTOCONNECTION_OPTION variable value:
    ...          - add AutoConnSiteID with SiteID equal to new Configuration Plan name
    ...          - or add AutoConnHWID with SN of new System Module
    ...      - set maintenanceRegionId to PNP
    ...      - remove INTEGRATE MO if existing and add a new one with proper values
    ...    - save updated Configuration Plan for PNP to VM
    ...  - de-integrate BTS from GUI and Prepare Unified PNP coam Site
    ...    - de-integrate BTS from NetAct GUI
    ...    - prepare Unified PNP coam Site with updated Configuration Plan
    ...  - perform BTS Reset Configuration
    ...    - start and wait for BTS to be not reachable and then reachable again
    ...    - start TCPDUMP capture on BTS
    ...  - start Plug and Play scenario and wait for On Air state
    ...    - enable Ethernet Port Security and SSH Service on BTS
    ...    - set Autoconnection Parameters and enable Autoconnection and Autoconfiguration Services on BTS; in case of SiteID or DHCP option,
    ...      set also Autoconnection Site ID
    ...    - wait for BTS to exit Rescue Console
    ...    - wait for BTS to reach Commissioned|Configured|OnAir state
    ...    - stop and save TCPDUMP capture files from BTS to VM
    ...    - save PNP Report and verify its contents for BTS
    ...    - wait for BTS to reach On Air State, checking states and alarms
    ...  - check BTS KPIs after Plug and Play scenario completion
    ...    - BTS Reset Configuration, Autoconnection Service and Autoconfiguration Service KPIs are checked
    ...  - check final BTS state and alarms
    ...  - check final number and state of Cells and RMs
    ...  Pass criteria: SMOD Plug and Play works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29904 - [CB007500] New TC for scenario CB007500_ST_05_01_PNP start with
    ...  configuration reset to D&RSW by DHCP-less
    ...  - 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30192 - [CB007500] New option for PNP: SiteID
    ...  - 18.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30303 - [CB007500] New option for PNP: with DHCP

    Set Tags    CA-CM    OWNER-ancuta.muresan@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-CRT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get Target SW for BTS SW Update
    Step 4: Get all BTS info needed for SW Update
    Step 5: Get BTS Configuration Plan from NetAct and Update it
    Step 6: De-integrate BTS from GUI and Prepare Unified PNP coam Site
    Step 7: Perform BTS Reset Configuration
    Step 8: Start Plug and Play scenario and wait for On Air state
    Step 9: Check BTS KPIs after Plug and Play scenario completion
    Step 10: Check final BTS state
    Step 11: Check final BTS alarms
    Step 12: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

TC Preconditions
    ${smod_sn_status}=  Run Keyword And Return Status  Should Not Be Empty  ${SN_OF_NEW_SYSTEM_MODULE}
    Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'HWID' and not ${smod_sn_status}  Run Keywords
    ...  Log  SN_OF_NEW_SYSTEM_MODULE parameter is not defined.  level=ERROR
    ...  AND  Fail  SN_OF_NEW_SYSTEM_MODULE must be defined when AUTOCONNECTION_OPTION is 'HWID'.

    Run Keyword If  '${AUTOCONNECTION_OPTION}' not in ['HWID','SiteID','DHCP']  Run Keywords
    ...  Log  AUTOCONNECTION_OPTION has invalid value '${AUTOCONNECTION_OPTION}'.  level=ERROR
    ...  AND  Fail  AUTOCONNECTION_OPTION must be 'HWID', 'SiteID' or 'DHCP'.

    Return From Keyword If  '${AUTOCONNECTION_OPTION}' != 'DHCP'

    ${dhcp_ip_status}=  Run Keyword And Return Status  Should Not Be Empty  ${DHCP_SERVER_IP_ADDRESS}
    ${dhcp_user_status}=  Run Keyword And Return Status  Should Not Be Empty  ${DHCP_SERVER_USER}
    ${dhcp_pass_status}=  Run Keyword And Return Status  Should Not Be Empty  ${DHCP_SERVER_PASSWORD}

    Run Keyword If  not (${dhcp_ip_status} and ${dhcp_user_status} and ${dhcp_pass_status})  Run Keywords
    ...  Log  DHCP server parameters are incomplete.  level=ERROR
    ...  AND  Fail  DHCP_SERVER_IP_ADDRESS, DHCP_SERVER_USER and DHCP_SERVER_PASSWORD must be defined when AUTOCONNECTION_OPTION is 'DHCP'.

    Validate DHCP configuration on the DHCP server

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    Log  Step ${index}: Check ${when} BTS state  console=True
    rfs_admin.Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    rfs_admin.Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}   600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get from Admin

    Log  Step ${index}: Check ${when} BTS alarms  console=True
    rfs_frame_rfs_common.Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias_local.upper()}_CRITICAL_ALARMS']}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get Target SW for BTS SW Update
    Log  Step ${index}: Get Target SW for BTS SW Update  console=True

    Log  Get Target SW build for BTS ${alias_local}  console=True
    Run Keyword If  '${FORCE_TARGET_BTS_SW_DL}' == 'True'
    ...  rfs_general.NetAct Import SW build from WFT to Netact
    ...  ELSE
    ...  rfs_general.NetAct Import SW build from WFT to Netact  package_name=${TARGET_BTS_SW}

    ${package_release_list}=  String.Split String  string=${Target Package Name}  separator=_
    ${package_release}=  Collections.Get From List  ${package_release_list}  0
    Set Test Variable  ${package_name}  ${Target Package Name}
    Set Test Variable  ${package_release}

Step ${index}: Get all BTS info needed for SW Update
    Log  Step ${index}: Get all BTS info needed for SW Update  console=True

    ${BTS_id}=  rfs_frame_rfs_common.Admin Get BTS ID from SCF  scf=${${alias_local.lower()}_scf_initial}
    ${BTS_mplane_ip}=  Get Variable Value  ${${alias_local.upper()}}[${alias_local.upper()}_OAM_IP_ADDRESS]
    ${IPIF_number}  ${localIpPrefixLength}=  Get corresponding mplane IPIF number and localIpPrefixLength value from SCF
    ...  BTS_mplane_ip=${BTS_mplane_ip}
    ${primary_vlanid}=  Get primary vlanid value from SCF  IPIF_number=${IPIF_number}
    ${iprt_gateway_ip}=  Get IPRT gateway ip that matches BTS mplane ip  BTS_mplane_ip=${BTS_mplane_ip}

    Set Test Variable  ${BTS_id}
    Set Test Variable  ${BTS_mplane_ip}
    Set Test Variable  ${localIpPrefixLength}
    Set Test Variable  ${primary_vlanid}
    Set Test Variable  ${iprt_gateway_ip}

Step ${index}: Get BTS Configuration Plan from NetAct and Update it
    Log  Step ${index}: Get BTS Configuration Plan from NetAct and Update it  console=True

    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${BTS_id}  alias=Netact_node

    rfs_general.NetAct Export BTS Configuration Plan to VM  local_dir=${Test Results Dir}/NetActLogs  file_name=automation_MRBTS-${BTS_id}_initial.xml
    ...  dist_names=PLMN-PLMN/MRBTS-${BTS_id}  alias=${alias_local}

    Update BTS Configuration Plan  scf_path=${Test Results Dir}/NetActLogs/automation_MRBTS-${BTS_id}_initial.xml  alias=${alias_local}

Step ${index}: De-integrate BTS from GUI and Prepare Unified PNP coam Site
    Log  Step ${index}: De-integrate BTS from GUI and Prepare Unified PNP coam Site  console=True

    Log  Start to De-integrate BTS ${alias_local} from GUI  console=True
    ${deintegration_logs}=  netact.DeIntegrate MRBTS From NetAct  dist_name=${MRBTS_dn}  alias=Netact_node
    Log  De-integrate BTS ${alias_local} from GUI succesfully performed!  console=True

    Sleep  10s  reason=Wait for De-integration to be fully processed in NetAct

    rfs_general.NetAct Prepare Unified PNP coam Site  plan_name=${pnp_plan_name}  input_file=${scf_pnp_name}
    ...  local_dir=${Test Results Dir}/NetActLogs  alias=${alias_local}

Step ${index}: Perform BTS Reset Configuration
    Log  Step ${index}: Perform BTS Reset Configuration  console=True

    ${BTS_TECH_IP_address}=  Set Variable  ${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias_local}' == 'Master'  None  ${${alias_local.upper()}}[${alias_local.upper()}_PC_IP_ADDRESS]

    Log  Perform "BTS Reset Configuration" on BTS ${alias_local}  console=True

    Get RESET timestamp info  when=start_config_reset

    coam.Reset Configuration  remove_operator_certificates=False  remove_user_account_credentials=False  timeout=800  connection=${alias_local}
    ...  detailed_output=True  reset_type=ConfigurationWithDiagnosticAndRecoverySw

    rfs_general.Wait For Target To Be Not Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=300  remote_host=${remote_host_ip}
    rfs_general.Wait For Target To Be Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=600  remote_host=${remote_host_ip}

    Log  BTS ${alias_local} Reset Configuration completed!  console=True

    Get RESET timestamp info  when=end_config_reset

    Start Capture TCPDUMP on BTS  alias=${alias_local}  capture_file_name=pnp_tcpdump_capture.pcap

    Log  Establish connection to BTS ${alias_local} after Reset Configuration  console=True
    ${result}=  Run Keyword And Return Status  rc.Connect To  ip_address=192.168.255.129  port=443  username=Nemuadmin  password=nemuuser
    ...  auto_discover=True  secure=True  name=default
    Run Keyword If  ${result}
    ...  Log  Connection to BTS ${alias_local} successfully established!  console=True
    ...  ELSE  Run Keywords
    ...  rc.Download Technical Logs  path=${Test Results Dir}/NetActLogs  timeout=100  connection=default
    ...  AND  Log  Could not establish connection to BTS. Check technical logs saved at ${Test Results Dir}/NetActLogs for more details.  level=ERROR
    ...  AND  Fail  Could not establish connection to BTS. Check technical logs saved at ${Test Results Dir}/NetActLogs for more details.

    Set Test Variable  ${RC_CONNECTION}  True

Step ${index}: Start Plug and Play scenario and wait for On Air state
    Log  Step ${index}: Start Plug and Play scenario and wait for On Air state  console=True

    ${BTS_TECH_IP_address}=  Set Variable  ${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias_local}' == 'Master'  None  ${${alias_local.upper()}}[${alias_local.upper()}_PC_IP_ADDRESS]
    ${Commissioned_Configured_OnAir}=  Set Variable  regex"Commissioned|commissioned|Configured|configured|OnAir|onAir"

    Enable Ethernet Port Security and SSH Service on BTS  alias=${alias_local}
    Set Autoconnection Parameters and Enable Autoconnection and Autoconfiguration Services on BTS  alias=${alias_local}

    Log  Wait for BTS ${alias_local} to exit Rescue Console  console=True
    ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${BTS_MAX_WAIT_TIME}s  5s
    ...  Wait for BTS to exit Rescue Console  alias=${alias_local}

    Run Keyword If  ${sw_installation_failed}  Run Keywords
    ...  Log Long String  Autoconfiguration Status: 'Software installation failed'. Check technical logs saved at ${Test Results Dir}/NetActLogs
    ...  for more details.  level=ERROR
    ...  AND
    ...  Fail  Autoconfiguration Status:'Software installation failed'. Check technical logs saved at ${Test Results Dir}/NetActLogs for more details.
    ...  ELSE IF  not ${status}  Run Keywords
    ...  Log  BTS ${alias_local} did not exit Rescue Console within ${BTS_MAX_WAIT_TIME} seconds.  console=True
    ...  AND  Fail  BTS ${alias_local} did not exit Rescue Console within ${BTS_MAX_WAIT_TIME} seconds.

    Log  Wait for BTS ${alias_local} to reach Commissioned|Configured|OnAir state  console=True
    rfs_general.Wait For Target To Be Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}

    Stop And Save TCPDUMP capture files from BTS to VM  alias=${alias_local}  capture_file_name=pnp_tcpdump_capture.pcap
    ...  destination_path=${Test Results Dir}/NetActLogs

    Wait Until Keyword Succeeds  3x  60s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias_local}  infomodel_reset=False
    Set Test Variable  ${RC_CONNECTION}  False

    rfs_admin.Admin Check BTS Procedural and Blocking states  ${Commissioned_Configured_OnAir}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias_local}
    Log  BTS ${alias_local} site - proceduralState: Commissioned|Configured|OnAir, blockingState: Unblocked, as expected!  console=True

    Save PNP Report  local_dir=${Test Results Dir}/NetActLogs  file_name=pnp-report-final.txt  alias=${alias_local}
    Verify PNP Report contents for BTS  local_dir=${Test Results Dir}/NetActLogs
    ...  file_name=pnp-report-final.txt  alias=${alias_local}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_autoconfiguration_service_UTC}  ${BTS_MAX_WAIT_TIME}
    rfs_admin.Check cells availability status online  ${alias_local}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias_local} cell(s) status:\n - operationalState=Enabled  console=True

    Log  Check BTS ${alias_local} alarms:  console=True
    rfs_frame_rfs_common.Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias_local.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias_local} site - expected, ignored and critical alarms checked  console=True

    Get RESET timestamp info  when=end_autoconfiguration_service

    Sleep  5s  reason=Wait a bit before saving PNP Report

    Save PNP Report  local_dir=${Test Results Dir}/NetActLogs  file_name=pnp-report-onair-state.txt  alias=${alias_local}

Step ${index}: Check BTS KPIs after Plug and Play scenario completion
    Log  Step ${index}: Check BTS KPIs after Plug and Play scenario completion  console=True

    Log  Check BTS KPIs after Plug and Play scenario completion for BTS ${alias_local}  console=True
    Log  BTS Reset Configuration, Autoconnection Service and Autoconfiguration Service KPIs are checked  console=True

    Check BTS KPI  start_time=${date_timestamp_start_config_reset_UTC}  end_time=${date_timestamp_end_config_reset_UTC}
    ...  operation_description=Configuration Reset  expected_value=${CONFIG_RESET_KPI}

    Check BTS KPI  start_time=${date_timestamp_start_autoconnection_service_UTC}  end_time=${date_timestamp_end_autoconnection_service_UTC}
    ...  operation_description=Autoconnection Service

    Check BTS KPI  start_time=${date_timestamp_start_autoconfiguration_service_UTC}  end_time=${date_timestamp_end_autoconfiguration_service_UTC}
    ...  operation_description=Autoconfiguration Service

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    rfs_frame_rfs_soam_taf.RFS Test Case Final Checks

Validate DHCP configuration on the DHCP server
    ${dhcp_server_reachable}=  Run Keyword And Return Status
    ...  rfs_general.Wait For Target To Be Reachable TAF  hostname=${DHCP_SERVER_IP_ADDRESS}  timeout=10
    Run Keyword If  not ${dhcp_server_reachable}  Run Keywords
    ...  Log  DHCP server ${DHCP_SERVER_IP_ADDRESS} is unreachable.  level=ERROR
    ...  AND  Fail  Cannot connect to DHCP server ${DHCP_SERVER_IP_ADDRESS}. Check network connectivity.

    ${BTS_mplane_ip}=  Get BTS M-Plane IP
    ${BTS_HW_address}=  Get BTS Hardware Address  BTS_mplane_ip=${BTS_mplane_ip}

    ${DHCP_CONFIG_FILE}=  Set Variable  /etc/dhcp/dhcpd.conf
    ${dhcp_output}=  Get DHCP Configuration  config_file=${DHCP_CONFIG_FILE}
    ${dhcp_file_path}=  Set Variable  ${Test Results Dir}/NetActLogs/dhcp_output.txt
    Create File  ${dhcp_file_path}  ${dhcp_output}

    ${items_to_check}=  Create List  ${BTS_mplane_ip}  ${BTS_HW_address}
    ${commented_entries}=  Create List
    ${missing_entries}=  Create List

    FOR  ${item}  IN  @{items_to_check}
        ${rc_item_exists}  ${output_item_exists}=  Run And Return Rc and Output
        ...  grep "${item}" /home/ute/Downloads/dhcp_output.txt

        IF  ${rc_item_exists} == 1
            Append To List  ${missing_entries}  ${item}
        ELSE
            ${rc_item_commented}  ${output_item_commented}=  Run And Return Rc and Output
            ...  grep "^[[:space:]]*#.*${item}" ${dhcp_file_path}
            ${rc_item_uncommented}  ${output_item_uncommented}=  Run And Return Rc and Output
            ...  grep "^[[:space:]].*${item}" ${dhcp_file_path}

            Run Keyword If  ${rc_item_uncommented} == 0
            ...  Continue For Loop
            ...  ELSE IF  ${rc_item_commented} == 0
            ...  Append To List  ${commented_entries}  ${item}
        END
    END

    Run Keyword If  ${missing_entries} or ${commented_entries}
    ...  Report DHCP Validation Failures  missing=${missing_entries}  commented=${commented_entries}  config_file=${DHCP_CONFIG_FILE}

    Restart DHCP Service on DHCP server

Get BTS M-Plane IP
    [Documentation]  Returns the BTS M-Plane IP, fetching it from the device if not provided.

    ${ip}=  Run Keyword If  '${BTS_MPLANE_IP_ADDRESS}' == ''
    ...  Get Variable Value  ${${alias_local.upper()}}[${alias_local.upper()}_OAM_IP_ADDRESS]
    ...  ELSE  Set Variable  ${BTS_MPLANE_IP_ADDRESS}
    ${stripped_ip}=  String.Strip String  ${ip}

    [Return]  ${stripped_ip}

Get BTS Hardware Address
    [Arguments]  ${BTS_mplane_ip}
    [Documentation]  Returns the BTS Hardware Address, fetching it from the device if not provided.

    ${hw_address}=  Run Keyword If  '${BTS_HARDWARE_ADDRESS}' == ''
    ...  rfs_frame_rfs_soam_taf.Execute Command on SM via SSH TAF
    ...  command=ifconfig `ip -o addr show | awk -v ip="${BTS_mplane_ip}" '$4 ~ ip {print $2}' | tail -n 1` | grep ether | awk '{print $2}'
    ...  target_ip=${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]
    ...  ELSE  Set Variable  ${BTS_HARDWARE_ADDRESS}
    ${stripped_hw}=  String.Strip String  ${hw_address}

    [Return]  ${stripped_hw}

Get DHCP Configuration
    [Documentation]  Retrieves the DHCP configuration content from the server.

    [Arguments]  ${config_file}
    ${command}=  Set Variable  sudo grep -E 'host|hardware ethernet|fixed-address' -A 2 ${config_file}
    ${output}=  rfs_frame_rfs_soam_taf.Execute Command on SM via SSH TAF  command=${command}
    ...  target_ip=${DHCP_SERVER_IP_ADDRESS}  port=22  target_username=${DHCP_SERVER_USER}  target_password=${DHCP_SERVER_PASSWORD}
    ${output_status}=  Run Keyword And Return Status  Should Be Empty  ${output}
    Run Keyword If  ${output_status}  Run Keywords
    ...  Log  DHCP configuration is empty or unavailable.  level=ERROR
    ...  AND  Fail  Failed to retrieve DHCP configuration from ${DHCP_CONFIG_FILE} on ${DHCP_SERVER_IP_ADDRESS}.

    [Return]  ${output}

Report DHCP Validation Failures
    [Documentation]  Logs and fails the test with a detailed DHCP validation error message.

    [Arguments]  ${missing}  ${commented}  ${config_file}
    ${error_message}=  Create Long String  DHCP validation failed!\n
    ...  - Missing entries: ${missing}\n
    ...  - Commented entries: ${commented}\n
    ...  Please fix the entries in ${config_file} on DHCP server ${DHCP_SERVER_IP_ADDRESS}.

    Log  ${error_message}  level=ERROR
    Fail  ${error_message}

Restart DHCP Service on DHCP server

    ${command}=  Set Variable  sudo systemctl restart dhcpd
    rfs_frame_rfs_soam_taf.Execute Command on SM via SSH TAF  command=${command}  target_ip=${DHCP_SERVER_IP_ADDRESS}  port=22
    ...  target_username=${DHCP_SERVER_USER}  target_password=${DHCP_SERVER_PASSWORD}

Get corresponding mplane IPIF number and localIpPrefixLength value from SCF
    [Arguments]  ${BTS_mplane_ip}

    ${SCF_dns}=  rfs_scf.Get All Dist Names Of Specific Class  mo_class=com.nokia.srbts.tnl:IPADDRESSV4  alias=${alias_local}

    FOR  ${dn}  IN  @{SCF_dns}

        ${localIpAddr_value}=  scf.Get Value From Scf  dist_name=${dn}  p_name=localIpAddr
        Continue For Loop If  '${localIpAddr_value}' != '${BTS_mplane_ip}'

        ${dn_list}=  String.Split String  string=${dn}  separator=/

        FOR  ${elem}  IN  @{dn_list}
            ${IPIF_number}=  Run Keyword If  'IPIF' in '${elem}'
            ...  Set Variable  ${elem}

            Exit For Loop If  '${IPIF_number}' != 'None'
        END

        ${localIpPrefixLength_value}=  scf.Get Value From Scf  dist_name=${dn}  p_name=localIpPrefixLength
        ${localIpPrefixLength_value}=  Evaluate  int(${localIpPrefixLength_value})

        Exit For Loop

    END

    [Return]  ${IPIF_number}  ${localIpPrefixLength_value}

Get primary vlanid value from SCF
    [Arguments]  ${IPIF_number}

    ${mplane_IPIF_dn_list}=  rfs_scf.Get All Dist Names By Pattern from SCF  pattern=/${IPIF_number}$  alias=${alias_local}
    ${mplane_IPIF_dn}=  Collections.Get From List  ${mplane_IPIF_dn_list}  0
    ${interfaceDN_value}=  scf.Get Value From Scf  dist_name=${mplane_IPIF_dn}  p_name=interfaceDN
    ${vlanid_value}=  scf.Get Value From Scf  dist_name=${interfaceDN_value}  p_name=vlanId
    ${vlanid_value}=  Evaluate  int(${vlanid_value})

    [Return]  ${vlanid_value}

Get IPRT gateway ip that matches BTS mplane ip
    [Arguments]  ${BTS_mplane_ip}

    ${SCF_dns}=  rfs_scf.Get All Dist Names Of Specific Class  mo_class=com.nokia.srbts.tnl:IPRT  alias=${alias_local}

    FOR  ${dn}  IN  @{SCF_dns}

        ${gateway_value}=  scf.Get Value From Scf  dist_name=${dn}  p_name=gateway
        ${gateway_value_split}=  String.Split String  ${gateway_value}  .
        ${first_three_oct_gateway}=  Set Variable  ${gateway_value_split[0]}.${gateway_value_split[1]}.${gateway_value_split[2]}
        ${BTS_mplane_ip_split}=  String.Split String  ${BTS_mplane_ip}  .
        ${first_three_oct_mplane_ip}=  Set Variable  ${BTS_mplane_ip_split[0]}.${BTS_mplane_ip_split[1]}.${BTS_mplane_ip_split[2]}

        Exit For Loop If  '${first_three_oct_gateway}' == '${first_three_oct_mplane_ip}'

    END

    [Return]  ${gateway_value}

Update BTS Configuration Plan
    [Arguments]  ${scf_path}  ${alias}

    Set Test Variable  ${scf_pnp_path}  ${Test Results Dir}/NetActLogs/automation_MRBTS-${BTS_id}_pnp.xml
    Set Test Variable  ${scf_pnp_name}  automation_MRBTS-${BTS_id}_pnp.xml
    Set Test Variable  ${pnp_plan_name}  automation_MRBTS-${BTS_id}_pnp

    Log  Start to Update BTS ${alias} Configuration Plan  console=True
    scf.Load Scf  ${scf_path}

    ${PLMN_dn_list}=  rfs_scf.Get All Dist Names By Pattern from SCF  pattern=PLMN-PLMN*  scf_path=${scf_path}  load_scf=False
    FOR  ${dn}  IN  @{PLMN_dn_list}

        rfs_scf.Delete Mo Attribute from SCF  dist_name=${dn}  attribute=id  scf_path=${scf_path}  load_scf=False
        rfs_scf.Set Mo Attribute from scf  dist_name=${dn}  attribute=operation  value=create  scf_path=${scf_path}  load_scf=False

    END

    ${MRBTS_dn_list}=  rfs_scf.Get All Dist Names Of Specific Class  mo_class=MRBTS  scf_path=${scf_path}  load_scf=False
    ${MRBTS_dn}=  Collections.Get From List  ${MRBTS_dn_list}  0
    Set Test Variable  ${MRBTS_dn}

    ${AutoConnSiteID_value}=  Run Keyword And Return Status
    ...  scf.Get Value From Scf  dist_name=${MRBTS_dn}  p_name=AutoConnSiteID
    Run Keyword If  ${AutoConnSiteID_value}
    ...  rfs_scf.SCF Remove Element from SCF  dist_name=${MRBTS_dn}  p_name=AutoConnSiteID  scf_path=${scf_path}  load_scf=False

    ${AutoConnHWID_value}=  Run Keyword And Return Status
    ...  scf.Get Value From Scf  dist_name=${MRBTS_dn}  p_name=AutoConnHWID
    Run Keyword If  ${AutoConnHWID_value}
    ...  rfs_scf.SCF Remove Element from SCF  dist_name=${MRBTS_dn}  p_name=AutoConnHWID  scf_path=${scf_path}  load_scf=False

    Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'HWID'
    ...  rfs_scf.SCF Add Element to SCF  dist_name=${MRBTS_dn}  p_name=AutoConnHWID  value=${SN_OF_NEW_SYSTEM_MODULE}  scf_path=${scf_path}
    ...  load_scf=False
    ...  ELSE IF  '${AUTOCONNECTION_OPTION}' == 'SiteID' or '${AUTOCONNECTION_OPTION}' == 'DHCP'
    ...  rfs_scf.SCF Add Element to SCF  dist_name=${MRBTS_dn}  p_name=AutoConnSiteID  value=${pnp_plan_name}  scf_path=${scf_path}
    ...  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${MRBTS_dn}  p_name=$maintenanceRegionId  value=PNP  scf_path=${scf_path}  load_scf=False

    ${integrate_mo_dn}=  Set Variable  ${MRBTS_dn}/INTEGRATE-1
    ${integrate_mo_dn_list}=  rfs_scf.Get All Dist Names By Pattern from SCF  pattern=${integrate_mo_dn}  scf_path=${scf_path}  load_scf=False

    Run Keyword If  ${integrate_mo_dn_list}
    ...  rfs_scf.SCF Remove Element from SCF  dist_name=${integrate_mo_dn}  p_name=${None}  scf_path=${scf_path}  load_scf=False

    rfs_scf.SCF Add Object to SCF  class_name=INTEGRATE  dist_name=${integrate_mo_dn}  version=INT_01  operation=create  scf_path=${scf_path}
    ...  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${integrate_mo_dn}  p_name=hostNameEm  value=${BTS_mplane_ip}  scf_path=${scf_path}  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${integrate_mo_dn}  p_name=hostNameNe3sws  value=${BTS_mplane_ip}  scf_path=${scf_path}  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${integrate_mo_dn}  p_name=ipVersion  value=IPv4  scf_path=${scf_path}  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${integrate_mo_dn}  p_name=plannedSWReleaseVersion  value=${package_name}
    ...  scf_path=${scf_path}  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${integrate_mo_dn}  p_name=securityMode  value=no TLS  scf_path=${scf_path}  load_scf=False
    rfs_scf.SCF Add Element to SCF  dist_name=${integrate_mo_dn}  p_name=systemReleaseVersion  value=${package_release}  scf_path=${scf_path}
    ...  load_scf=False

    scf.Save SCF  file_path=${scf_pnp_path}
    Log  Update BTS ${alias} Configuration Plan succesfully performed! Updated SCF can be found here: ${scf_pnp_path}  console=True

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Enable Ethernet Port Security and SSH Service on BTS
    [Arguments]  ${alias}

    Log  Enable Ethernet Port Security and SSH Service on BTS ${alias}  console=True
    ${result_eth_port}=  Run Keyword And Return Status  rc.Enable Ethernet Port Security  timeout=60  connection=default
    ${result_ssh_service}=  Run Keyword And Return Status  rc.Enable SSH Service  timeout=60  connection=default
    ${fail_message}=  Create Long String  Could not enable Ethernet Port Security and/or SSH Service on BTS. Check technical logs saved at
    ...  ${Test Results Dir}/NetActLogs for more details.

    Run Keyword If  ${result_eth_port} and ${result_ssh_service}
    ...  Log  Enable Ethernet Port Security and SSH Service succesfully enabled!  console=True
    ...  ELSE  Run Keywords
    ...  rc.Download Technical Logs  path=${Test Results Dir}/NetActLogs  timeout=100  connection=default
    ...  AND  Log  ${fail_message}  level=ERROR
    ...  AND  Fail  ${fail_message}

Set Autoconnection Parameters and Enable Autoconnection and Autoconfiguration Services on BTS
    [Arguments]  ${alias}

    ${netact_http_ip_address}=  Evaluate  socket.gethostbyname('${NETACT['URL']}')  modules=socket

    Log  Set Autoconnection Parameters on BTS ${alias}  console=True

    Log  Autoconnection Parameters are:  console=True
    Run Keyword If  '${AUTOCONNECTION_OPTION}' != 'DHCP'
    ...  Log Long String
    ...  - primary_ip_address: ${BTS_mplane_ip}\n
    ...  - primary_prefix_length: ${localIpPrefixLength}\n
    ...  - primary_gateway: ${iprt_gateway_ip}\n
    ...  - vlan_id: ${primary_vlanid}\n
    ...  - identification_entity_ip_address: ${netact_http_ip_address}
    Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'SiteID' or '${AUTOCONNECTION_OPTION}' == 'DHCP'
    ...  Log  ${SPACE}- autoconnection_site_id: ${pnp_plan_name}  console=True

    ${result_set_autoconnection}=  Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'DHCP'  Run Keyword And Return Status
    ...  rc.Set Autoconnection  connection=default  scenario=private network with DHCP
    ...  ELSE  Run Keyword And Return Status
    ...  rc.Set Autoconnection  primary_ip_address=${BTS_mplane_ip}  primary_prefix_length=${localIpPrefixLength}  primary_gateway=${iprt_gateway_ip}
    ...  connection=default  vlan_id=${primary_vlanid}  scenario=private network manual  identification_entity_ip_address=${netact_http_ip_address}

    Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'DHCP'
    ...  Sleep  10s  reason=Wait a bit before setting Site Identification

    ${result_set_site_identification}=  Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'SiteID' or '${AUTOCONNECTION_OPTION}' == 'DHCP'
    ...  Run Keyword And Return Status  rc.Set Site Identification  autoconnection_site_id=${pnp_plan_name}  connection=default
    ...  ELSE  Set Variable  NA

    Run Keyword If  '${AUTOCONNECTION_OPTION}' == 'SiteID' and ${result_set_site_identification} and ${result_set_autoconnection}
    ...  Log  Autoconnection Parameters succesfully set!  console=True
    ...  ELSE IF  '${AUTOCONNECTION_OPTION}' == 'DHCP' and ${result_set_site_identification} and ${result_set_autoconnection}
    ...  Log  Autoconnection Parameters succesfully set!  console=True
    ...  ELSE IF  '${AUTOCONNECTION_OPTION}' == 'HWID' and ${result_set_autoconnection}
    ...  Log  Autoconnection Parameters succesfully set!  console=True
    ...  ELSE  Run Keywords
    ...  rc.Download Technical Logs  path=${Test Results Dir}/NetActLogs  timeout=100  connection=default
    ...  AND  Log Long String  Could not set Autoconnection Parameters on BTS. Check technical logs saved at
    ...  ${Test Results Dir}/NetActLogs for more details.  level=ERROR
    ...  AND  Fail  Could not set Autoconnection Parameters on BTS. Check technical logs saved at ${Test Results Dir}/NetActLogs for more details.

    Log  Enable Autoconnection and Autoconfiguration Services on BTS ${alias}  console=True

    Get RESET timestamp info  when=start_autoconnection_service
    ${result_enable_autoconnection}=  Run Keyword And Return Status  rc.Enable Autoconnection Service  connection=default

    Get RESET timestamp info  when=start_autoconfiguration_service
    ${result_enable_autoconfiguration}=  Run Keyword And Return Status  rc.Enable Autoconfiguration Service  connection=default

    Run Keyword If  ${result_enable_autoconnection} and ${result_enable_autoconfiguration}
    ...  Log  Autoconnection and Autoconfiguration Services succesfully enabled!  console=True
    ...  ELSE  Run Keywords
    ...  rc.Download Technical Logs  path=${Test Results Dir}/NetActLogs  timeout=100  connection=default
    ...  AND  Log Long String  Could not enable Autoconnection and/or Autoconfiguration Services on BTS. Check technical logs saved at
    ...  ${Test Results Dir}/NetActLogs for more details.  level=ERROR
    ...  AND  Fail  Could not enable Autoconnection and/or Autoconfiguration Services on BTS. Check technical logs saved at
    ...  ${Test Results Dir}/NetActLogs for more details.

Wait for BTS to exit Rescue Console
    [Arguments]  ${alias}

    Set Test Variable  ${sw_installation_failed}  False
    ${BTS_TECH_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${status}=  Run Keyword And Return Status
    ...  rfs_general.Wait For Target To Be Not Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=300  remote_host=${remote_host_ip}

    Return From Keyword If  ${status}  True

    ${status}  ${autoconfiguration_report}=  Run Keyword And Ignore Error
    ...  rc.Download Autoconfiguration Report  path=${Test Results Dir}/NetActLogs  connection=default
    Run Keyword If  '${status}' == 'FAIL'  Fail

    ${report}=  OperatingSystem.Get File  ${autoconfiguration_report}

    ${report_status}=  Run Keyword And Return Status  Should Contain  ${report}  Autoconfiguration Status: 'Software installation failed'
    ${AutoconfigStatus}=  Run Keyword If  ${report_status}
    ...  String.Get Lines Containing String  ${report}  Autoconfiguration Status: 'Software installation failed'
    ...  ELSE  Fail

    ${AutoconfigStatus}=  String.Get Line  ${AutoconfigStatus}  -1
    ${AutoconfigStatus_timestamp}=  String.Split String  string=${AutoconfigStatus}  separator=
    ${AutoconfigStatus_timestamp}=  Set Variable  ${AutoconfigStatus_timestamp[0]}
    ${AutoconfigStatus_datetime}=  DateTime.Convert Date  ${AutoconfigStatus_timestamp}  result_format=timestamp
    ${AutoconfigStatus_time}=  DateTime.Subtract Date From Date  ${AutoconfigStatus_datetime}  ${date_timestamp_start_autoconfiguration_service_UTC}

    Run Keyword If  ${AutoconfigStatus_time} > 0  Run Keywords
    ...  Set Test Variable  ${sw_installation_failed}  True
    ...  AND  rc.Download Technical Logs  path=${Test Results Dir}/NetActLogs  timeout=100  connection=default
    ...  AND  Return From Keyword  True
    ...  ELSE  Fail

Start Capture TCPDUMP on BTS
    [Arguments]  ${alias}  ${capture_file_name}

    Set Test Variable  ${STOP_TCPDUMP}  False

    Remove TCPDUMP files from BTS  alias=${alias}

    Log  Start Capture TCPDUMP on BTS ${alias}  console=True

    Set Test Variable  ${tcpdump_num_of_files}  3
    ${command}=  Create Long String  tcpdump -i any -s 0 -n -nn -C 35 -W ${tcpdump_num_of_files}
    ...  -w /ffs/run/config/toor4nsn/${capture_file_name} > /tmp/tcpdump.log 2>&1 &

    rfs_frame_rfs_soam_taf.Send Command on SM via SSH TAF  command=${command}
    ...  target_ip=${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]

    Log  TCPDUMP capture started on BTS ${alias}, capturing to file: /ffs/run/config/toor4nsn/${capture_file_name}  console=True

Stop Capture TCPDUMP on BTS
    [Arguments]  ${alias}

    Log  Stop Capture TCPDUMP on BTS ${alias}  console=True

    ${command}=  Set Variable  kill `pgrep tcpdump`
    rfs_frame_rfs_soam_taf.Execute Command on SM via SSH TAF  command=${command}
    ...  target_ip=${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]

    Log  TCPDUMP capture stopped on BTS ${alias}  console=True

Stop And Save TCPDUMP capture files from BTS to VM
    [Arguments]  ${alias}  ${capture_file_name}  ${destination_path}

    Stop Capture TCPDUMP on BTS  alias=${alias}

    Log  Save TCPDUMP capture files from BTS ${alias} to VM  console=True

    FOR  ${num}  IN RANGE  0  ${tcpdump_num_of_files}
        rfs_general.Save BTS File  alias=${alias_local}  BTS_file_names=${capture_file_name}${num}
        ...  BTS_source_paths=/ffs/run/config/toor4nsn/${capture_file_name}${num}  BTS_destination_path=${destination_path}
    END

    Remove TCPDUMP files from BTS  alias=${alias}

    Set Test Variable  ${STOP_TCPDUMP}  True

Remove TCPDUMP files from BTS
    [Arguments]  ${alias}

    Log  Remove TCPDUMP files from BTS ${alias}  console=True

    ${command}=  Set Variable  rm /ffs/run/config/toor4nsn/*.pcap*
    rfs_frame_rfs_soam_taf.Execute Command on SM via SSH TAF  command=${command}
    ...  target_ip=${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]

    Log  TCPDUMP files removed from BTS ${alias}  console=True

Save PNP Report
    [Arguments]  ${local_dir}  ${file_name}  ${alias}

    Log  Save PNP Report to file ${local_dir}/${file_name} for BTS ${alias}  console=True
    coam.Get PNP Report  output_file_name=${local_dir}/${file_name}  connection=${alias}
    Log  PNP Report saved to file ${local_dir}/${file_name}  console=True

Verify PNP Report contents for BTS
    [Arguments]  ${local_dir}  ${file_name}  ${alias}

    Log  Verify PNP Report contents for BTS ${alias}  console=True

    OperatingSystem.File Should Exist  ${local_dir}/${file_name}
    ${Report}=  OperatingSystem.Get File  ${local_dir}/${file_name}

    Should Contain  ${Report}  Identification requested
    Should Contain  ${Report}  Identification finished
    Should Contain  ${Report}  Software download requested
    Should Contain  ${Report}  Software activation finished successfully
    Should Contain  ${Report}  Configuration plan activation success

    Log  The following entries were found in PNP Report for BTS ${alias}:  console=True
    ${IdRequest}=  String.Get Lines Containing String  ${Report}  Identification requested
    ${IdRequest}=  String.Get Line  ${IdRequest}  -1
    ${IdFinished}=  String.Get Lines Containing String  ${Report}  Identification finished
    ${IdFinished}=  String.Get Line  ${IdFinished}  -1
    ${SWDownloadRequest}=  String.Get Lines Containing String  ${Report}  Software download requested
    ${SWDownloadRequest}=  String.Get Line  ${SWDownloadRequest}  -1
    ${SWActivationFinish}=  String.Get Lines Containing String  ${Report}  Software activation finished successfully
    ${SWActivationFinish}=  String.Get Line  ${SWActivationFinish}  -1
    ${ConfigPlanActivation}=  String.Get Lines Containing String  ${Report}  Configuration plan activation success
    ${ConfigPlanActivation}=  String.Get Line  ${ConfigPlanActivation}  -1

    Log  Identification requested line: ${IdRequest}  console=True
    Log  Identification finished line: ${IdFinished}  console=True
    Log  Software download requested line: ${SWDownloadRequest}  console=True
    Log  Software activation finished successfully line: ${SWActivationFinish}  console=True
    Log  Configuration plan activation success line: ${ConfigPlanActivation}  console=True

    ${IdFinised_timestamp}=  String.Split String  string=${IdFinished}  separator=
    ${IdFinished_timestamp}=  Set Variable  ${IdFinised_timestamp[0]}
    ${IdFinished_datetime}=  DateTime.Convert Date  ${IdFinished_timestamp}  result_format=timestamp

    Set Test Variable  ${date_timestamp_end_autoconnection_service_UTC}  ${IdFinished_datetime}

    Log  UTC end_autoconnection_service_point_timestamp: ${date_timestamp_end_autoconnection_service_UTC}  console=True

Check BTS KPI
    [Arguments]  ${start_time}  ${end_time}  ${operation_description}  ${expected_value}=default

    ${actual_value}=  DateTime.Subtract Date From Date  ${end_time}  ${start_time}  number
    Log  ${operation_description} KPI is: ${actual_value} seconds  console=True

    Return From Keyword If  '${expected_value}' == 'default'

    Run Keyword If  ${actual_value} > ${expected_value}  Run Keywords
    ...  Log Long String  ${operation_description} KPI check failed! Expected maximum: ${expected_value} seconds, but actual is: ${actual_value}
    ...  seconds.  level=WARN
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  ${operation_description} KPI check failed! Expected maximum: ${expected_value} seconds, but actual is: ${actual_value} seconds.
    ...  ELSE
    ...  Log Long String  ${operation_description} KPI check passed! Expected maximum: ${expected_value} seconds, actual is: ${actual_value}
    ...  seconds.  console=True

Particular Teardown
    Run Keyword If  '${STOP_TCPDUMP}' == 'False'
    ...  Stop And Save TCPDUMP capture files from BTS to VM  alias=${alias_local}  capture_file_name=pnp_tcpdump_capture.pcap
    ...  destination_path=${Test Results Dir}/NetActLogs
    Run Keyword If  '${RC_CONNECTION}' == 'True'
    ...  rc.Teardown  connection=default

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
