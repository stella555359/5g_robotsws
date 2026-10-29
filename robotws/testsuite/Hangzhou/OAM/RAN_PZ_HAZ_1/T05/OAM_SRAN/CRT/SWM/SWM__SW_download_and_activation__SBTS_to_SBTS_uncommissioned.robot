*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_pdu.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Library    taf.sbts.oam.coam.admin
Library    OperatingSystem

*** Variables ***
${Target SW name}           ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${Target SW dir}            /home/ute/btsauto/TARGET_SW     # Directory sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW Update Timeout}        3000       # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}        600        # Timeout for ping loss during reset
${Ping regain timeout}      600        # Timeout for ping regain during reset
${DISABLE_RMODS}            ${False}   # Should RMODS be disabled during SW update
${RM_DETECTION_TIMEOUT}     15min      # Timeout for all connected RMs detection (in minutes)
${Test_Timeout}                        # Test timeout (in minutes)
${ip_addr}                  192.168.255.129

*** Keywords ***
TC__SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-4858
    ...
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...
    ...  TC for SW download and activation of the uncommissioned BTS
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 01.06.2017 - initial creation
    ...  - 02.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8071 - add verify BTS proceduralState in Common Test Setup,
         ...   delete step1: check proceduralstatus of the sbts
    ...  - 10.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-10834 - add Step 5 Check active alarms
    ...  - 14.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14473 - Added checking if all RMs detected
    ...  - 15.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15166 - Added variable Test_Timeout
    ...  - 27.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15077 - Added DISABLE_RMODS option
    ...  - 28.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15189 - Added support for dual core configurations
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 05.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16765 - change RMOD detection method after update (!=NotInstalled)
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 17.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17659 - Add 'Check if all radio modules are available' as Precondition
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17943 - Moves KW:'Check if all radio modules are available'to ca_swm_general.robot
    ...  - 30.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19468 - Skips RMOD connected to port 6 of FSMF
    ...  - 05.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19503 - Adds checkong if all RMODs are disabled after disabling all RMODs in step3
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_update_uncommissioned_SBTS17.png#

    #[Timeout]    ${Test_Timeout} minutes
    Set Tags    CA-SWM    PHASE-CIT    OWNER-dominik.tredota@nokia.com    AUTHOR-sebastian.burniak@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com    GROUP_IN_CHARGE-WRO_7_Vrf    SW-SBTS17    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP001307_RP000923    FEATURE-RP0001145_RP000923


    step0: prepare BTS to uncommission
    step1: Find path to SW package
    step2: Check SW versions
    step3: SW update
    step4: Check SW versions
    step5: import SCF
    step6: cancel fault 23 and get onair

step0: prepare BTS to uncommission
    [Documentation]    Short description.
    Log Step Header    step0: prepare BTS to uncommission
    #_Get Scf By Admin    /home/ute/BACK_SCF.xml
    _Get Scf By Admin default    /home/ute/BACK_SCF.xml
    Change parameter to disconnect netact with BTS
    run keyword and ignore error    taf.sbts.oam.coam.admin.Reset Configuration
    ...    remove_operator_certificates=False
    ...    remove_user_account_credentials=False
    ...    alias=default    timeout=800    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    sleep    9min
    Run keyword and ignore error    Software update from FDSW    sw_pkg_path=${SW_path_T2_package}     ip_addr=${ip_addr}
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${ip_address}  min_uptime=180  max_downtime=0  timeout=181
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin
    Run keyword and ignore error    Teardown Infomodel
    sleep    9min
    Run Keyword And Continue On Failure  Start Admin    bts_host=${ip_addr}
    Run Keyword And Continue On Failure    Start Infomodel     bts_host=${ip_addr}

step${number_step}: Check SW versions
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${number_step}: <description>

    Log Step Header   step${number_step}: Check SW versions
    Check SW version  ${number_step}
#    Run Keyword If  ${SMOD2_exists} and '${number_step}'=='2'  Validate SW Version Before Update On ESM
#    Run Keyword If  ${SMOD2_exists} and '${number_step}'=='4'  Validate SW Version After Update On ESM

step1: Find path to SW package
    [Documentation]    Short description.
    Log Step Header   step1: Find path to SW package
    hran_general.Find path to SW package

step3: SW update
    [Documentation]    Short description.
    Log Step Header   step3: SW update
    sleep    10 s
    Run Keyword If  ${DISABLE_RMODS}  Disable all RMODs
    Log  Will now perform software update  console=${TRUE}
#    ${esm_updater}  Run Keyword If  ${SMOD2_exists}  taf.sbts.oam.coam.admin.Run keyword in background
#    ...    Update Software  ${Target SW path}  True  ${SW Update Timeout}
#    ...  alias=esm
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  True  ${SW Update Timeout}
    Run Keyword If  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    Log  Update procedure ended${\n}Waiting for ping loss  console=${TRUE}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    ...  timeout=${Ping loss timeout}
    Run Keyword If  ${ping loss status}==${False}  Set Test Failed  Ping has not been lost within timeout
    Log  Waiting for ping regain  console=${TRUE}
    ${ping_regain_status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}
    ...  timeout=${Ping regain timeout}
    Run Keyword If  ${ping_regain_status}==${False}  Set Test Failed  Ping has not been regained within timeout
#    Run Keyword If  ${SMOD2_exists}  Validate ESM Update  ${esm_updater}
    Log  Checking if BTS is stable after update  console=${TRUE}
    ${bts_stability_check}  Run keyword and return status  Check if target is stable  ip=${SMOD1['TRS_IP']}
    ${Admin working state}  hran_admin.Reset admin and infomodel connection if broken
    Run keyword if    not ${Admin working state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

step5: import SCF
    [Documentation]    Short description.
    ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}  Infomodel Get SW Versions  module=MSM
    @{sw_temp}    split string    ${ACTIVE_SW_BEFORE_MASTER}    _
    ${current_release}  set variable    ${sw_temp[0]}
#    ${release}    Get Substring    ${current_release}   4
    ${release}=    Evaluate    "${current_release}"[4:]
    Run Keyword If    '${ip_addr}' == '192.168.255.129'    Import Configuration by release  sw_release=${release}
    ...    ELSE      Import Configuration by release for remote BTS    ${local_scf_storage}     sw_release=${release}
    wait until keyword Succeeds  5min  30s  Change parameter to disconnect netact with BTS

step6: cancel fault 23 and get onair
    [Documentation]    Short description.
    ${is_fault_active_ESM}    set variable    FALSE
    Run keyword if    ${SMOD2_exists}    Critical Fault 23 Verification on ESM
    sleep    2min
    Run keyword if    '${is_fault_active_ESM}'=='TRUE'
    ...    Wait Until Keyword Succeeds    90min    5min    sw update     ${sw_pkg_path}
    Run keyword if    '${is_fault_active_ESM}'=='TRUE'  Reset admin and infomodel connection if broken
    No Fault 23 on SBTS by multi upgrade    sw_pkg_path=${Target SW path}
    wait until keyword Succeeds     5min     30s
    ...    Change parameter to connect netact with BTS

Custom Setup
    [Documentation]    Short description.
    TC Setup
#    Run Keyword If  ${SMOD2_exists}  Setup ESM Admin Connections
    Set Test Variable  ${RMODS_TURNED_OFF}   ${False}

Connected to D&RSW BTS by RC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_address}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${fdsw_version}: <description>
    ...        ${auto_discover}: <description>
    ...        ${secure}: <description>
    ...        ${name}: <description>
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser  ${fdsw_version}=fdsw21c
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    taf.fdsw.rc.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Log  FDSW RC Connected to BTS successfully with IP ${ip_address}
    CB007500_enable_SSH_Access_On_RC

CB007500_enable_SSH_Access_On_RC
    [Documentation]    Short description.
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    taf.fdsw.rc.enable_ethernet_port_security
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    taf.fdsw.rc.enable_ssh_service
Custom Teardown
    [Documentation]    Short description.
#    wait until keyword succeeds    15min    30s    _Perform Full Commision By Admin      /home/ute/BACK_SCF.xml    ${BTS_INFO.ID}
#    wait until keyword succeeds    10min    30s    Check BTS State By Admin    OnAir
    TC Teardown
    Run Keyword If  ${SMOD2_exists}  Teardown ESM Admin Connections
    Run Keyword If  ${RMODS_TURNED_OFF}  _Enable RMODs

Disable all RMODs
    [Documentation]    Short description.
    Disable RMODS
    Set Test Variable  ${RMODS_TURNED_OFF}  ${True}
    ${status}  Run keyword and return status  Wait until keyword succeeds  3 min  20 sec  Check if all needed radio modules are not available
    Run keyword if    not ${status}  Fail  Not all RMODs are disabled

_Enable RMODs
    [Documentation]    Short description.
    Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=SBTS
    Setup MSM Admin Connections For Teardown
    RMODs Online Verification
    [Teardown]  Run Keywords  Teardown MSM Admin Connections  AND  Teardown scf Parser

Setup MSM Admin Connections For Teardown
    [Documentation]    Short description.
    ${esm_admin}  Run Keyword And Return Status
    ...  taf.sbts.oam.coam.admin.Setup Admin  admin_api_log_dir=${BTS Files}/rmods_teardown
    ute_admin_infomodel.Setup Infomodel
    ...  address=${SMOD1['TRS_IP']}  port=443  use_ssl=True  admin_api_log_dir=${BTS Files}/rmods_teardown
    ${esm_admin_infomodel}  Run Keyword And Return Status  ute_admin_infomodel.Connect Infomodel

Teardown MSM Admin Connections
    [Documentation]    Short description.
    ute_admin_infomodel.Teardown Infomodel
    taf.sbts.oam.coam.admin.Teardown Admin

Setup ESM Admin Connections
    [Documentation]    Short description.
    ${esm_admin}  Run Keyword And Return Status
    ...  taf.sbts.oam.coam.admin.Setup Admin  admin_api_log_dir=${BTS Files}  remote_host=${PC_IP2}  alias=esm
    Run keyword if    not ${esm_admin}  Set test blocked  ESM Admin connection did not start
    ute_admin_infomodel.Setup Infomodel
    ...  address=${SMOD1['TRS_IP']}  port=443  use_ssl=True  admin_api_log_dir=${BTS Files}/  remote_host=${PC_IP2}  alias=esm
    ${esm_admin_infomodel}  Run Keyword And Return Status  ute_admin_infomodel.Connect Infomodel  alias=esm
    Run keyword if    not ${esm_admin_infomodel}  Set test blocked  ESM Admin infomodel connection did not start

Teardown ESM Admin Connections
    [Documentation]    Short description.
    Save Infomodel Log    filename=${BTS Files}/IM/InfoModel_ESM_log.ims2  timeout=300  alias=esm
    ute_admin_infomodel.Teardown Infomodel  alias=esm
    taf.sbts.oam.coam.admin.Teardown Admin  alias=esm
    Run Keyword And Ignore Error  Run and return rc and output  mv ssh_forwarder_log ${BTS Files}/

Validate ESM Update
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${update_task}: <description>
    [Arguments]  ${update_task}
    Validate Update Procedure On ESM  ${update_task}
    Validate Ping Regain After Update On ESM

Validate Update Procedure On ESM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${update_task}: <description>
    [Arguments]  ${update_task}
    Log  Validate Update Procedure On ESM  console=${TRUE}
    ${esm_sw_update_result}  ${esm_sw_update_msg}  Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Collect Keyword Result  ${update_task}
    Run Keyword If  '${esm_sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${esm_sw_update_msg}

Validate Ping Regain After Update On ESM
    [Documentation]    Short description.
    Log  Validate Ping Regain After Update On ESM  console=${TRUE}
    ${esm_ping_regain_status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  remote_host=${PC_IP2}  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if    not ${esm_ping_regain_status}  Set Test Failed  ESM ping has not been regained within timeout

Validate SW Version ${when} Update On ESM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${when}: <description>
    Log  Validate SW Version ${when} Update On ESM  console=${TRUE}
    ${software_info}  _Get SW Version For SMOD  alias=esm
    ${sw_release_name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${Target SW path}
    ${sw_number}  Should match regexp  ${sw_release_name}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    Run Keyword If  '${when}'=='Before'  Should Not Contain  ${software_info}  ${sw_number}
    ...    ELSE IF  '${when}'=='After'   Should Contain      ${software_info}  ${sw_number}

RMODs Online Verification
    [Documentation]    Short description.
    Run Keyword If  ${RMODS_TURNED_OFF}  Change power outlets state  ${RMODS}  ${True}
    Set Test Variable  ${RMODS_TURNED_OFF}  ${False}
    Run Keyword If  ${SMOD2_exists}   Wait until keyword succeeds  5 min  30 sec    Synchronize SMODs
    Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20 sec  Check if all needed radio modules are available

Check if all needed radio modules are not available
    [Documentation]    Short description.
    #Assert Every    RMOD    availabilityStatus=NotInstalled
    taf.sbts.oam.coam.admin.Assert Every    RMOD    operationalState=regex"[Dd]isabled"
    ${scf_rmods}=           Get Radios
    ${scf_count_rmods}=     Get length  ${scf_rmods}
    ${status_rmod_on_rf6}   Check if RMOD connected to port 6 on FSMF
    ${rmod_on_rf6}          Set variable if  ${status_rmod_on_rf6}  1  0
    ${scf_count_rmods}      Evaluate  ${scf_count_rmods}-${rmod_on_rf6}
    ${runtime_rmods}=       taf.sbts.oam.coam.admin.Get ids for all  RMOD
    ${final_status}=        Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run keyword if    not ${final_status}  Fail  Some of RMODs are still online

Check if all needed radio modules are available
    [Documentation]    Short description.
    #Assert Every    RMOD    availabilityStatus!=NotInstalled
    taf.sbts.oam.coam.admin.Assert Every    RMOD    operationalState=regex"[Ee]nabled"
    ${scf_rmods}=           Get Radios
    ${scf_count_rmods}=     Get length  ${scf_rmods}
    ${status_rmod_on_rf6}   Check if RMOD connected to port 6 on FSMF
    ${rmod_on_rf6}          Set variable if  ${status_rmod_on_rf6}  1  0
    ${scf_count_rmods}      Evaluate  ${scf_count_rmods}-${rmod_on_rf6}
    ${runtime_rmods}=       taf.sbts.oam.coam.admin.Get ids for all  RMOD
    ${final_status}=        Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run keyword if    not ${final_status}  Fail  Not all radio modules are available

Check if RMOD connected to port 6 on FSMF
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${FALSE}: <description>
    ${sm_variant}  Get SM variant
    Return from keyword if  '${sm_variant[0]}'!='FSMF'  ${FALSE}
    ${scf}                  Parse Xml  ${COMMISSIONING_PATH}
    ${cablink_obj}          Get elements  ${scf}  .//managedObject[@class="com.nokia.srbts.eqm:CABLINK"]
    FOR  ${cablink}  IN  @{cablink_obj}
        ${is_rmod_secondEndpointDN}  Run keyword and return status  Element Text Should Match  ${cablink}  *RMOD-*  .//p[@name="secondEndpointDN"]
        ${is_smod_firsEndpointDN}  Run keyword and return status  Element Text Should Match  ${cablink}  *SMOD-*  .//p[@name="firstEndpointDN"]
        ${is_port_6}  Run keyword if  ${is_rmod_secondEndpointDN} and ${is_smod_firsEndpointDN}
        ...  Run keyword and return status  Element Text Should Match  ${cablink}  6  .//p[@name="firstEndpointPortId"]
        Return from keyword if  ${is_port_6}  ${TRUE}
    END
    [Return]  ${FALSE}

TC_Custom Setup
    [Documentation]    Short description.
    Custom Setup

TC_Custom Teardown
    [Documentation]    Short description.
    Custom Teardown
