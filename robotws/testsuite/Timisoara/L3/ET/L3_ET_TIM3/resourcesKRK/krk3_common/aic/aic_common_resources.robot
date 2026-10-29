*** Settings ***
Documentation
...  authors:      Kacper Witek, kacper.witek@nokia.com
...                Krystian Krakowski, krystian.krakowski@nokia.com
...  maintainers:  Kacper Witek, kacper.witek@nokia.com
...                Krystian Krakowski, krystian.krakowski@nokia.com
...                Mateusz Zachwieja, mateusz.zachwieja@nokia.com

Library    OperatingSystem
Library    Process
Library    DateTime
Library    Collections
Library    String
Library    XML
Library    ute_fsmaccess
Library    ./IphyExtension.py  WITH NAME  ta5g_iphy
Library    ./RunnerExtension.py  WITH NAME  wtsrunner
Library    ./SSHExtension.py  WITH NAME  ssh
Library    taf.gnb.oam.coam.vdu.interface.vdu  WITH NAME  vdu
Library    taf.gnb.oam.coam.cu.interface.cu  WITH NAME  vcu
Library    taf.hw.fhgw.cli.interface.cli  WITH NAME  fhgwcli
Library    testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.aic.resources.common_vcu.vCU    WITH NAME    pyvcu
Library    testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.aic.resources.common_vdu.vDU    WITH NAME    pyvdu

Resource   ocp_resources.robot
Variables   variables.py


*** Keywords ***
AiC Common Test Setup
    Set timestamp

Set timestamp
    ${date_now}=  Get current date
    ${date_UTC}=  Get current date  time_zone=UTC
    ${TIMESTAMP}=  Convert date  ${date_now}  result_format=%Y%m%d-%H%M%S
    ${TIMESTAMP_RFC3339}=  Convert date  ${date_UTC}  result_format=%Y-%m-%dT%H:%M:%SZ
    Set test variable  ${TIMESTAMP}
    Set test variable  ${TIMESTAMP_RFC3339}

Start L3 call SA
    [Arguments]  ${id}=1  ${pdu}=1  ${gw}=1
    Register UE  id=${id}
    Setup PDU session  id=${id}  pdu=${pdu}  gw=${gw}
    ${trf_id_dl}=  Evaluate  (${id} - 1) * 2 + 1
    ${trf_id_ul}=  Evaluate  (${id} - 1) * 2 + 2
    Start traffic  ue=${id}  pdu=${pdu}  qfi=1  dir=dl  trf_id=${trf_id_dl}  protocol=udp  mbps=10
    Start traffic  ue=${id}  pdu=${pdu}  qfi=1  dir=ul  trf_id=${trf_id_ul}  protocol=udp  mbps=10

Stop L3 call SA
    [Arguments]  ${id}=1  ${pdu}=1
    Stop traffic   ue=${id}  pdu=${pdu}  qfi=1  dir=dl
    Stop traffic   ue=${id}  pdu=${pdu}  qfi=1  dir=ul
    Release UE PDU session  ue=${id}  pdu=${pdu}
    Deregister UE  id=${id}  ue_deregister_type=switch_off  by=ue

Send Delta Plan VCU
    [Arguments]    ${delta_vcu}=None
    Log    \nStart setup    console=True
    Set Suite Variable    ${DELTA_VCU}    ${delta_vcu}
    pyvcu.Update And Activate Delta Plan    ${DELTA_VCU}

AiC Common Suite Setup
    Configure UTE ETH3
    Get TL config
    Start WTS
    Wait for cell setup
    Wait for SIBs

Get vDU vnfc pods
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${vdu_vnfcs}=  vdu.Get pods info  vdu_connection=${oam_du}[connection_name]
    [Return]  ${vdu_vnfcs}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Check if all vDU vnfcs and expected are enabled and on line
    [Arguments]  @{list_of_names_expected}
    ${list_of_available_vnfc}=  Create list

    ${vdu_vnfcs}=  Get vDU vnfc pods
    FOR  ${vnfc}  IN  @{vdu_vnfcs}
        Should be equal as strings  ${vnfc}[availability_status]  on line
        ...    msg=DU: Availability status for ${vnfc}[instance]/${vnfc}[name] is ${vnfc}[availability_status]
        Should be equal as strings  ${vnfc}[operational_state]  enabled
        ...    msg=DU: Operational state for ${vnfc}[instance]/${vnfc}[name] is ${vnfc}[operational_state]

        Append to list  ${list_of_available_vnfc}  ${vnfc}[name]
    END

    ${stringlist}=  Catenate  SEPARATOR=\n  @{list_of_available_vnfc}
    FOR  ${expected_vnfc}  IN  @{list_of_names_expected}
        Should contain  ${stringlist}  ${expected_vnfc}  msg=Expected vnfc ${expected_vnfc} not found in available pods
    END

Get vCU vnfc pods
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${vcu_vnfcs}=  vcu.Get vnfcs states  connection=${oam_cu}[alias]
    [Return]  ${vcu_vnfcs}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

Check if all vCU vnfcs and expected are enabled and on line
    [Arguments]  @{list_of_names_expected}
    ${list_of_available_vnfc}=  Create list

    ${vcu_vnfcs}=  Get vCU vnfc pods
    FOR  ${vnfc}  IN  @{vcu_vnfcs}
        Should be equal as strings  ${vnfc}[availability_status]  on line
        ...    msg=CU: Availability status for ${vnfc}[instance]/${vnfc}[name] is ${vnfc}[availability_status]
        Should be equal as strings  ${vnfc}[operational_state]  enabled
        ...    msg=CU: Operational state for ${vnfc}[instance]/${vnfc}[name] is ${vnfc}[operational_state]

        Append to list  ${list_of_available_vnfc}  ${vnfc}[name]
    END

    ${stringlist}=  Catenate  SEPARATOR=\n  @{list_of_available_vnfc}
    FOR  ${expected_vnfc}  IN  @{list_of_names_expected}
        Should contain  ${stringlist}  ${expected_vnfc}  msg=Expected vnfc ${expected_vnfc} not found in available pods
    END

Get vdu operational state
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${vdu_data}=  vdu.Get vdu state data  vdu_connection=${oam_du}[connection_name]
    [Return]  ${vdu_data}[operational_state]
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Vdu operational state should be in one of states
    [Arguments]  @{list_of_expected_states}  ${oam_du}=${OAM_DU}
    ${vdu_operational_state}=  Get vdu operational state  ${oam_du}
    List should contain value  ${list_of_expected_states}  ${vdu_operational_state}
    Log to console  DU: Operational state is ${vdu_operational_state}

Vdu operational state should be
    [Arguments]  ${expected_state}  ${oam_du}=${OAM_DU}
    ${vdu_operational_state}=  Get vdu operational state  ${oam_du}
    Should be equal as strings  ${expected_state}  ${vdu_operational_state}
    Log to console  DU: Operational state is ${expected_state}

Wait for expected state
    [Arguments]  ${expected_state}  ${timeout}=180s  ${oam_du}=${OAM_DU}
    Wait until keyword succeeds  ${timeout}  30s  Vdu operational state should be  ${expected_state}  ${oam_du}

Get CU SW version
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master_cu}=${MASTER_CU}  ${namespace_cu}=${NAMESPACE_CU}
    ssh.Connect to  &{master_cu}
    ${output}=  ssh.Execute
    ...  helm list -n ${namespace_cu} | grep -Po "aic-v(c|d)u-(cnf-)?\\K\\d{1,2}.\\d{3}.\\d{1,4}" -m1
    ...  connection=${master_cu}[alias]
    Log to console  CU: ${output}
    [Return]  ${output}
    [Teardown]  ssh.Disconnect  connection=${master_cu}[alias]

Get DU SW version
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master_du}=${MASTER_DU}  ${namespace_du}=${NAMESPACE_DU}
    ssh.Connect to  &{master_du}
    ${output}=  ssh.Execute
    ...  helm list -n ${namespace_du} | grep -Po "aic-v(c|d)u-(cnf-)?\\K\\d{1,2}.\\d{3}.\\d{1,4}" -m1
    ...  connection=${master_du}[alias]
    Log to console  DU: ${output}
    [Return]  ${output}
    [Teardown]  ssh.Disconnect  connection=${master_du}[alias]

Get info from vDU TargetBD file
    [Arguments]  ${rru_type}=${RRU_type}
    Get RRU version from vDU TargetBD file
    Get SW filename from vDU TargetBD file  ${rru_type}

Get RRU version from vDU TargetBD file
    ${RRU_version}=  Find in vDU TargetBD file  ${PATTERN_SWVERSION}
    Set suite variable  ${RRU_version}

Get SW filename from vDU TargetBD file
    [Arguments]    ${RRU_type}
    ${pattern}=  Replace string  ${PATTERN_SWFILENAME}  RRU_TYPE  ${RRU_type}
    ${RRU_SW_filename}=  Find in vDU TargetBD file  ${pattern}
    Set suite variable  ${RRU_SW_filename}

Find in vDU TargetBD file
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${pattern}  ${master_du}=${MASTER_DU}  ${namespace_du}=${NAMESPACE_DU}
    ${master}=  ssh.Connect to  &{master_du}
    ${command}=  Catenate
    ...  oc exec -it ute-${namespace_du}-oamfh-0 -n ${namespace_du} -c ctr-${namespace_du}-oamfh --
    ...  find /ffs/run/RFSW -type f -name "TargetBD*.xml" -exec grep -m1 -Po ${pattern} {} +
    ${output}  ssh.Execute  ${command}    connection=${master_du}[alias]
    [Return]  ${output}
    [Teardown]  ssh.Disconnect  connection=${master_du}[alias]

Get FHGW SW release
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${fhgw}=${FHGW}
    fhgwcli.Connect to  &{fhgw}
    ${fhgw_release}=  fhgwcli.FHGW get SW release  ${fhgw}[alias]
    Log to console  FHGW: ${fhgw_release}
    [Return]  ${fhgw_release}
    [Teardown]  fhgwcli.Disconnect  ${fhgw}[alias]

Get AP SW release
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${ap}=${AP}
    ssh.Connect to  &{ap}
    ${output}=  ssh.Execute  head -n1 /ffs/run/TargetBD*xml  connection=${ap}[alias]
    ${version}=  Get regexp matches  ${output}  cbtsSoftwareReleaseVersion="5G_([\\d\.]+)"  1
    Log to console  AP: ${version}[0]
    [Teardown]  ssh.Disconnect  connection=${ap}[alias]

Change fhuc vlans in vdu scf
    [Arguments]  ${du_scf}  ${fhuc_vlans}=${FHUC_VLANS}
    ${new_du_scf}=  Set variable  ${TEMPDIR}/du_scf_new.xml

    ${xml}=  Parse XML  ${du_scf}
    ${index}=  Set variable  ${1}
    FOR  ${fhuc_vlan}  IN  @{fhuc_vlans}
        ${dist_name}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}
        ${string_fhuc_vlan}=  Convert to string  ${fhuc_vlan}
        Set elements text  ${xml}  ${string_fhuc_vlan}  xpath=.//managedObject[@distName='${dist_name}']/p[@name='vlanId']
        ${index}=  Evaluate  ${index} + 1
    END
    Save XML  ${xml}  ${new_du_scf}

    [Return]  ${new_du_scf}

Activate CU and DU plan
    # TODO: API exception 507 - insufficient storage - 3 plans exceeded
    [Arguments]  ${cu_scf}=${CU_SCF}  ${du_scf}=${DU_SCF}  ${change_scf_fhuc}=${False}
    [Timeout]  15m
    ${cu_plan_id}=  Set variable  ${None}
    ${du_plan_id}=  Set variable  ${None}

    ${du_scf}=  Run keyword if  ${change_scf_fhuc}  Change fhuc vlans in vdu scf  ${du_scf}
    ...         ELSE  Set variable  ${du_scf}

    ${status_cu}=  Create dictionary  status=not_started
    ${status_du}=  Create dictionary  status=not_started
    FOR  ${i}  IN RANGE  9999
        ${cu_operation}  ${cu_plan_id} =  Run keyword if  "${status_cu}[status]" in ["failure", "not_started"]  Activate CU plan  ${cu_scf}
        ...  ELSE  Set variable  ${cu_operation}  ${cu_plan_id}
        ${du_operation}  ${du_plan_id} =  Run keyword if  "${status_du}[status]" in ["failure", "not_started"]  Activate DU plan  ${du_scf}
        ...  ELSE  Set variable  ${du_operation}  ${du_plan_id}
        ${status_cu}=  Run keyword if  "${status_cu}[status]" != "success"
        ...  Wait until keyword succeeds  7m  20s  Get status of activating CU plan  ${cu_plan_id}  ${cu_operation}[id]
        ...  ELSE  Set variable  ${status_cu}
        ${status_du}=  Run keyword if  "${status_du}[status]" != "success"
        ...  Wait until keyword succeeds  7m  20s  Get status of activating DU plan  ${du_plan_id}  ${du_operation}[id]
        ...  ELSE  Set variable  ${status_du}
        Exit for loop if  "${status_cu}[status]" == "${status_du}[status]" == "success"
        Sleep  20s
    END
    [Return]  ${status_cu}  ${status_du}

Activate CU plan
    [Arguments]  ${scf_file}
    ${plan_id}=  Upload CU plan  ${scf_file}
    Validate CU plan  ${plan_id}
    ${activation_operation}=  CU plan activation  ${plan_id}
    [Return]  ${activation_operation}  ${plan_id}

Upload CU plan
    [Arguments]  ${scf_file}
    ${upload_state}=  Upload CU plan file  ${scf_file}
    ${operation_state}=  Wait until keyword succeeds  1m  5s  Uploading CU plan should be successful  ${upload_state}
    Log to console  ${\n}CU: uploaded plan
    [Return]  ${operation_state}[plan_id]

Upload CU plan file
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${scf_file}  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${upload_state}=  vcu.Upload plan file  ${scf_file}  connection=${oam_cu}[alias]
    [Return]  ${upload_state}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

Uploading CU plan should be successful
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${upload_state}  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${operation_state}=  vcu.Get operation state of uploading plan  ${upload_state}[action_id]  connection=${oam_cu}[alias]
    Should be equal  ${operation_state}[status]  success  ignore_case=True
    [Return]  ${operation_state}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

Validate CU plan
    [Arguments]  ${plan_id}
    ${validation_state}=  CU plan validation  ${plan_id}
    ${operation_state}=  Wait until keyword succeeds  1m  5s
    ...  Validating plan on CU should be successful  ${plan_id}  ${validation_state}[action_id]
    Log to console  CU: validated plan
    [Return]  ${operation_state}

CU plan validation
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${validation_state}=  vcu.Plan validation  ${plan_id}  connection=${oam_cu}[alias]
    [Return]  ${validation_state}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

Validating plan on CU should be successful
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${operation_id}  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${operation_state}=  vcu.Get operation state of validating plan  ${plan_id}  ${operation_id}  connection=${oam_cu}[alias]
    Should be equal  ${operation_state}[status]  success  ignore_case=True
    [Return]  ${operation_state}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

CU plan activation
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${activation_state}=  vcu.Plan activation  ${plan_id}  connection=${oam_cu}[alias]
    Log to console  CU: activating plan...
    [Return]  ${activation_state}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

Get status of activating CU plan
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${operation_id}  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${operation_state}=  Wait until keyword succeeds  5m  10s
    ...  vcu.Get operation state of activating plan  ${plan_id}  ${operation_id}  connection=${oam_cu}[alias]
    Run keyword if  "${operation_state}[status]" == "failure"
    ...  Run keyword if  "Get validation errors" in "${operation_state}[error_message]"  Fail  Validation errors in CU plan.
    Run keyword if  "${operation_state}[status]" == "success"
    ...  Log to console  CU: plan activated successfully
    [Return]  ${operation_state}
    [Teardown]  vcu.Disconnect  connection=${oam_cu}[alias]

Activate DU plan
    [Arguments]  ${scf_file}
    ${plan_id}=  Upload DU plan  ${scf_file}
    Validate DU plan  ${plan_id}
    ${activation_operation}=  DU plan activation  ${plan_id}
    [Return]  ${activation_operation}  ${plan_id}

Upload DU plan
    [Arguments]  ${scf_file}
    ${upload_state}=  Upload DU plan file  ${scf_file}
    ${operation_state}=  Wait until keyword succeeds  1m  5s  Uploading DU plan should be successful  ${upload_state}
    Log to console  ${\n}DU: uploaded plan
    [Return]  ${operation_state}[plan_id]

Upload DU plan file
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${scf_file}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${upload_state}=  vdu.Upload plan  ${scf_file}  vdu_connection=${oam_du}[connection_name]
    [Return]  ${upload_state}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Uploading DU plan should be successful
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${upload_state}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${operation_state}=  vdu.Get upload plan operation status  ${upload_state}[action_id]  vdu_connection=${oam_du}[connection_name]
    Should be equal  ${operation_state}[status]  success  ignore_case=True
    [Return]  ${operation_state}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Validate DU plan
    [Arguments]  ${plan_id}
    ${validation_state}=  DU plan validation  ${plan_id}
    ${operation_state}=  Wait until keyword succeeds  1m  5s
    ...  Validating plan on DU should be successful  ${plan_id}  ${validation_state}[action_id]
    Log to console  DU: validated plan
    [Return]  ${operation_state}

DU plan validation
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${validation_state}=  vdu.Validate plan  ${plan_id}  vdu_connection=${oam_du}[connection_name]
    [Return]  ${validation_state}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Validating plan on DU should be successful
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${operation_id}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${operation_state}=  vdu.Get validate plan operation status  ${plan_id}  ${operation_id}  vdu_connection=${oam_du}[connection_name]
    Should be equal  ${operation_state}[status]  success  ignore_case=True
    [Return]  ${operation_state}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

DU plan activation
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${activation_state}=  vdu.Activate plan  ${plan_id}  vdu_connection=${oam_du}[connection_name]
    Log to console  DU: activating plan...
    [Return]  ${activation_state}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Get status of activating DU plan
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${plan_id}  ${operation_id}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${operation_state}=  Wait until keyword succeeds  5m  10s
    ...  vdu.Get activate plan operation status  ${plan_id}  ${operation_id}  vdu_connection=${oam_du}[connection_name]
    Run keyword if  "${operation_state}[status]" == "failure"
    ...  Run keyword if  "Get validation errors" in "${operation_state}[error_message]"  Fail  Validation errors in DU plan.
    Run keyword if  "${operation_state}[status]" == "success"
    ...  Log to console  DU: plan activated successfully
    [Return]  ${operation_state}
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Apply AP configuration
    [Arguments]  ${iphy_xml}  ${swconfig}
    Modify iphy.xml from template  ${iphy_xml}
    Upload iphy.xml to AP
    Upload swconfig to AP  ${swconfig}

Modify iphy.xml from template
    [Arguments]  ${rru_type}=${RRU_type}  ${rru_sw_filename}=${RRU_SW_filename}  ${rru_version}=${RRU_version}  ${rrh_vlan}=${RRH_VLAN}
    ...  ${iphy_xml_template}=${CURDIR}/iphy_template_${rru_type}.xml  ${output_xml}=${OUTPUT DIR}/iphy.xml
    ${xml}=  Parse XML  ${iphy_xml_template}
    Set elements text  ${xml}  ${rru_sw_filename}  xpath=.//soap-config/software/file/name
    Set elements text  ${xml}  ${rru_version}  xpath=.//soap-config/software/file/version
    Set elements text  ${xml}  ${rru_version}  xpath=.//RE/identity/bldVersion
    Set elements text  ${xml}  ${rru_version}  xpath=.//RE/identity/buildversion
    Set elements text  ${xml}  ${rrh_vlan}  xpath=.//optlink/preferredVlanId
    Save XML  ${xml}  ${output_xml}

Upload iphy.xml to AP
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${rru_type}=${RRU_type}  ${iphy_xml}=${OUTPUT DIR}/iphy.xml  ${ap}=${AP}
    ssh.Connect To  &{ap}
    ssh.Upload file  ${iphy_xml}  /rom/simmode/iphy_${rru_type}.xml  connection=${ap}[alias]
    ssh.Execute  ln -sf iphy_${rru_type}.xml /rom/simmode/iphy.xml  connection=${ap}[alias]
    Log to console  ${\n}AP: iphy.xml modified
    [Teardown]  ssh.Disconnect  connection=${ap}[alias]

Upload swconfig to AP
    [Arguments]  ${swconfig}=${CURDIR}/AP_swconfig.txt
    ta5g_iphy.Put iphy swconfig file  input_filepath=${swconfig}

Reboot AP and wait until it is ready
    [Arguments]  ${ap}=${AP}
    AP system-module-reboot
    Log to console  ${\n}AP: system-module-reboot
    ute_fsmaccess.Wait until host is unavailable  ${ap}[hostname]  timeout=3min
    Log to console  AP: down
    ute_fsmaccess.Wait for host ssh  host=${ap}[hostname]
    Log to console  AP: ssh ready
    Wait until AP boards are ready  5min
    Log to console  AP: all boards are ready
    # TODO: Check something similar to ip, in two cells these IPs are not available
    # Wait for AP RU address assignment
    # Log to console  AP: RU address assigned
    Log to console  AP: ready

AP system-module-reboot
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${ap}=${AP}
    ssh.Connect To  &{AP}
    ${output}=  ssh.Send command  system-module-reboot  connection=${ap}[alias]
    [Teardown]  ssh.Disconnect  connection=${ap}[alias]

Wait until AP boards are ready
    [Arguments]  ${timeout}=5min
    Wait until keyword succeeds    ${timeout}    20s    AP boards should be ready

AP boards should be ready
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${ap}=${AP}  ${check_ap_lo_boards}=${CHECK_AP_LO_BOARDS}
    ssh.Connect To  &{AP}
    ${adets_output}=  ssh.Execute  ${check_ap_lo_boards}  ${ap}[alias]
    ${matches}=  Get regexp matches  ${adets_output}  (?:FSM5_FCT|FSM5_FSP1)\\s+(\\w+)  1
    Should contain X times  ${matches}  ready  2  msg=Not all units are ready.${\n}${adets_output}
    ${matches}=  Get regexp matches  ${adets_output}  \\[0x\\d+\\]\\s+(\\w+)  1
    Should contain X times  ${matches}  ready  4  msg=Not all CPUs are ready.${\n}${adets_output}
    [Teardown]  ssh.Disconnect  connection=${ap}[alias]

Wait for AP RU address assignment
    [Arguments]    ${interface}=etha01.257
    Wait until keyword succeeds  5min  10s  AP RU should have address assigned

AP RU should have address assigned
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${ap}=${AP}
    ssh.Connect To  &{ap}
    ${output}=  ssh.Execute  ip a show dev etha01.257  connection=${ap}[alias]
    ${ip_address}=  Get regexp matches  ${output}  (?<\=inet )[\\d.\\/]+(?\=\\s+)
    Should not be empty  ${ip_address}
    [Teardown]  ssh.Disconnect  connection=${ap}[alias]

Wait until RMODs availability status is 'on line'
    [Arguments]  ${retry}=5m  ${retry_interval}=5s
    Wait until keyword succeeds  ${retry}  ${retry_interval}  Verify RMODs availability status is 'on line'
    Log to console  DU: All RMODs are \'on line\'

Verify RMODs availability status is 'on line'
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${rmods_statuses}=  vdu.Get RMODs status  vdu_connection=${oam_du}[connection_name]
    FOR  ${status}  IN  @{rmods_statuses}
        Dictionary should contain item  ${status}  availability_status  on line  msg=RMOD status is not \'on line\':${\n}${status}
    END
    [Teardown]  vdu.Disconnect  ${oam_du}[connection_name]

Wait until F1 link is available
    [Arguments]  ${retry}=5m  ${retry_interval}=5s
    Wait until keyword succeeds  ${retry}  ${retry_interval}  F1 link should be available

F1 link should be available
    ${du_state}=  Get DU state
    Should be equal  ${du_state}[f1_link_status][available]  ${1}
    Log to console  CU: F1 link is available

Wait until RMODs are available
    [Arguments]  ${number_of_rmods}  ${retry}=5m  ${retry_interval}=5s
    Wait until keyword succeeds  ${retry}  ${retry_interval}  RMODs should be online  ${number_of_rmods}

RMODs should be online
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${number_of_rmods}  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${vdu_rmods}=  vdu.Get rmods summary  vdu_connection=${oam_du}[connection_name]
    Should be true  ${vdu_rmods}[availability_status][on_line] >= ${number_of_rmods}
    Log to console  DU: All RMODs are online
    [Teardown]  vdu.Disconnect  vdu_connection=${oam_du}[connection_name]

Get DU state
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${du_state}=  vcu.Get du state  connection=${oam_cu}[alias]
    [Return]  ${du_state}
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Start WTS
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${timeout}=30  ${wts}=${WTS}  ${wts_cfg}=${WTS_CFG}
    ssh.connect_to  &{wts['host']}
    wtsrunner.Configure WTSemu edaemon  &{wts['edaemon']}
    wtsrunner.Configure WTSemu egate  &{wts['egate']}
    wtsrunner.Start WTSemu
    ...  egate_console_ip=${wts}[host][hostname]
    ...  egate_port=${wts}[egate][port]
    wtsrunner.Configure  file=${wts_cfg}
    wtsrunner.Read wtsemu Output Until Re  CHANGE STATE: STARTED  timeout=${timeout}
    Log to console  WTS: STARTED

Setup NG link
    Lock NG link
    Wait until NG link is Locked
    Unlock NG link
    Wait until NG link is Unlocked
    Wait until wts NG link is up

Lock NG link
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${ng_links_ids}=  Create list  1
    ${status}=  Wait until keyword succeeds  1m  5s
    ...  vcu.Lock NG links  ng_links_ids=${ng_links_ids}  connection=${oam_cu}[alias]
    [Return]  ${status}
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Unlock NG link
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${ng_links_ids}=  Create list  1
    ${status}=  Wait until keyword succeeds  1m  5s
    ...  vcu.Unlock NG links  ng_links_ids=${ng_links_ids}  connection=${oam_cu}[alias]
    [Return]  ${status}
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Wait until NG link is ${expected_state}
    Wait until keyword succeeds  1m  5s  NG link should be ${expected_state}
    Log to console  vCU: NG link ${expected_state}

NG link should be ${expected_state}
    Get current plan file  path=${OUTPUT DIR}/cu_plan.xml  include_runtime_data=${True}
    ${amf_state}=  XML.Get element text  ${OUTPUT DIR}/cu_plan.xml
    ...  xpath=.//*[\@class\="com.nokia.srbts.nrbts:SERVEDAMF"]/*[\@name\="administrativeState"]
    Should be equal  ${amf_state}  ${expected_state}
    [Teardown]  Remove file  ${OUTPUT DIR}/cu_plan.xml

Get current plan file
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${path}  ${include_runtime_data}=${False}  ${timeout}=30  ${oam_cu}=${OAM_CU}  ${connection}=${oam_cu}[alias]
    vcu.Connect to  &{oam_cu}
    vcu.Get current plan file
    ...  path=${path}
    ...  include_runtime_data=${include_runtime_data}
    ...  timeout=${timeout}
    ...  connection=${connection}
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Wait until wts NG link is up
    [Arguments]  ${timeout}=30
    wtsrunner.Read WTSemu output until re  expected=NG link is Up  timeout=${timeout}
    Log to console  WTS: NG link is Up

Wait for cell setup
    [Arguments]  ${timeout}=600
    Log to console  WTS: Waiting for cell setup...
    wtsrunner.Read wtsemu Output Until Re  Airphone: Cell Setup completed  timeout=${timeout}
    Log to console  WTS: Cell setup completed

Wait for SIBs
    [Arguments]  ${timeout}=15
    Repeat keyword  3 times  wtsrunner.Read wtsemu Output Until Re  SystemInformationBlockType[123]-NR updated  timeout=${timeout}
    Log to console  WTS: SIB-NR type 1, 2, 3 updated

Register UE
    [Arguments]  ${id}=1
    wtsrunner.ue_register  id=${id}
    wtsrunner.Read wtsemu Output Until Re  REGISTRATION COMPLETE  timeout=15
    Log to console  WTS: REGISTRATION COMPLETE for UE-${id}

Setup PDU session
    [Arguments]  ${id}=1  ${pdu}=1  ${gw}=1
    wtsrunner.set_pdu_param  ue=${id}  pdu=${pdu}  trf_type=internal
    wtsrunner.ue_pdu_session_setup  pdu=${pdu}  gw=${gw}  ue=${id}  nwslice=1
    wtsrunner.Read wtsemu Output Until Re  Initial Context Setup Successful  timeout=15
    Log to console  WTS: Initial Context Setup Successful for UE-${id}

Start traffic
    [Arguments]  &{kwargs}
    wtsrunner.trf_data_start  &{kwargs}
    wtsrunner.Read wtsemu Output Until Re  Started (Downlink|Uplink) Internal traffic Receiver on Ue:${kwargs}[ue]  timeout=2
    Log to console  WTS: Started ${kwargs}[dir] traffic for UE-${kwargs}[ue]

Stop traffic
    [Arguments]  &{kwargs}
    wtsrunner.trf_data_stop  &{kwargs}
    # TODO: v to be changed to 'Stopped ...' after WTS fix for dir=ul/refactor this KW
    wtsrunner.Read wtsemu Output Until Re  (Stopping|Stopped) (Downlink|Uplink) Internal traffic on Ue:${kwargs}[ue]  timeout=2
    Log to console  WTS: Stopped ${kwargs}[dir] traffic for UE-${kwargs}[ue]
    wtsrunner.qfi_stats  ue=${kwargs}[ue]  pdu=${kwargs}[pdu]  qfi=${kwargs}[qfi]  dir=${kwargs}[dir]
    wtsrunner.Read wtsemu Output Until Re  \=+\\n[\\s\\S]+\\n\=+  timeout=2

Release UE PDU session
    [Arguments]  &{kwargs}
    wtsrunner.ue_pdu_session_release  &{kwargs}
    wtsrunner.Read wtsemu Output Until Re  Successfully released PDU Session  timeout=5
    Log to console  WTS: PDU session released for UE-${kwargs}[ue]

Deregister UE
    [Arguments]  &{kwargs}
    wtsrunner.ue_deregister  &{kwargs}
    wtsrunner.Read wtsemu Output Until Re  UE${kwargs}[id]: detached  timeout=10
    Log to console  WTS: UE-${kwargs}[id] detached

Wait until WTS state is ACTIVE
    Wait until keyword succeeds  2 min  15 s  WTS state should be active

WTS state should be ACTIVE
    wtsrunner.Sim State Disp
    wtsrunner.Read wtsemu Output Until Re    expected=CHANGE STATE: ACTIVE    timeout=15
    Log to console  WTS: ACTIVE

Get CU parameters
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${dist_name}  ${oam_cu}=${OAM_CU}  ${connection}=${oam_cu}[alias]
    vcu.Connect to  &{oam_cu}
    ${output}=  vcu.Get parameters  ${dist_name}  connection=${connection}
    Log  ${output}  console=True  repr=True
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Get CU state
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${status}=  vcu.Get CU state  connection=${oam_cu}[alias]
    [Return]  ${status}
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Verify average ul and dl data rate is above expected margin
    [Arguments]  ${ue_id}=1  ${expected_rate}=10  ${margin}=0.95  ${pdu}=1
    wtsrunner.Verify average data rate is above expected margin  ue_id=${ue_id}  dir=dl
    ...    expected_rate_mbps=${expected_rate}  margin=${margin}  pdu=${pdu}
    wtsrunner.Verify average data rate is above expected margin  ue_id=${ue_id}  dir=ul
    ...    expected_rate_mbps=${expected_rate}  margin=${margin}  pdu=${pdu}

Copy wts egate console log if exist
    [Arguments]  ${path}  ${wts_path}=/opt/wts/latest
    Run process  /bin/bash  -c
    ...  [[ -e '${wts_path}/egate_console.log' ]] && cp '${wts_path}/egate_console.log' '${path}/egate_console.log'

Read WTSemu output until prompt and save to file
    [Arguments]  ${filename}=${OUTPUT DIR}/egate_console_last.log  ${timeout}=30
    ${egate_output}=  wtsrunner.Read wtsemu output until prompt  timeout=${timeout}
    Create file  ${filename}  content=${egate_output}
    [Return]  ${egate_output}

Get DU sessions list
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_du}=${OAM_DU}
    vdu.Connect to  &{oam_du}
    ${sessions_list}=  vdu.Get sessions list  vdu_connection=${oam_du}[connection_name]
    Log  ${sessions_list}  console=True  repr=True
    [Return]  ${sessions_list}
    [Teardown]  vdu.Disconnect  ${oam_du}[connection_name]

Write content to file
    [Arguments]  ${path}  ${content}
    ${date_now}=  Get current date
    ${date}=  Convert date  ${date_now}  result_format=%Y%m%d-%H%M%S
    Create file  ${path}_${date}.log  ${content}

Get TL config
    [Arguments]  ${filename}=${None}
    ${tl}=  Get variable value  $tl
    Run keyword if  "${tl}" == "${None}"  Get TL config from file  ${filename}
    Variable should exist  $tl  msg=Please execute test with parameter -V or set proper filename

    Set suite variable  ${NAMESPACE_CU}  ${tl.cloud_hostings[0].namespace}
    Set suite variable  ${NAMESPACE_DU}  ${tl.cloud_hostings[1].namespace}
    Set suite variable  &{MASTER_CU}
    ...  hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...  alias=cu_master
    Set suite variable  &{MASTER_DU}
    ...  hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...  alias=du_master
    Set suite variable  &{OAM_CU}
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  secure=${True}
    ...  alias=cu_admin
    Set suite variable  &{OAM_DU}
    ...  host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...  secure=${True}
    ...  connection_name=du_admin
    # TODO: Check if rrh_vlan is updated to newest init.py version with preffered vlan id
    Set suite variable  ${RRH_VLAN}  ${tl.ues[0].preferred_vlan_id}
    Set suite variable    ${AP_IP}    192.168.200.1
    ${FHUC_VLANS}=  Get variable value  ${tl.gnbs[0].dus[0].fhuc_vlans}  ${None}
    Set suite variable  ${FHUC_VLANS}

Get TL config from file
    [Arguments]  ${filename}=${None}
    Run keyword and return if  ${filename} != ${None}  Import variables  ${filename}
    ${hostname}=   Run  hostname | tr \"-\" \"_\"
    ${tl_config}=  Set variable  /home/ute/testline_configuration/${hostname}
    Import variables  ${tl_config}

Connect to already running WTS instance
    [Arguments]  ${wts}=${WTS}
    wtsrunner.Start WTSemu
    ...  egate_console_ip=${wts}[host][hostname]
    ...  egate_port=${wts}[egate][port]

Configure UTE ETH3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
