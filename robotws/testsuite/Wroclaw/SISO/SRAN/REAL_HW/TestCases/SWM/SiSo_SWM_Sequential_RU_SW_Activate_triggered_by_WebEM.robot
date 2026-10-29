*** Settings ***
Documentation
  ...  AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3993817/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1 Preconditions Sequential RU SW Update
  ...  Preparing TL for testing. Creating TC Variables, downloading SW packages,
  ...  setting parameters actSWRollbackReject to true.
  ...  From SBTS26R1_ENB_9999_250813_000021 parameter change sequentialRuSwUpgrade -> ruPhaseSwActivationResetPolicy and value true -> Sequential.
  ...
  ...  Step 2 Perform Sequential RU SW Update
  ...  Updating BTS Package with RuSwOnly parameter. All RMODs should update its SW package but BTS package should stay the same.
  ...  All RMODs should reboot sequential.
  ...
  ...  Step 3 Verify Sequential RU SW Update
  ...  Validating if all of RMs rebooted after SW update one by one. Simple algorythm checks if any of RMODs changes availabilityStatus to offline,
  ...  then checks if all RMODs are in operationalState enabled. Loop repeats X times where X equals count of RMODs available on TL.
  ...
  ...  Recovery For Sequential RU SW Update
  ...  Recovering actSWRollbackReject and sequentialRuSwUpgrade/ruPhaseSwActivationResetPolicy parameters and BTS SW package.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 15.11.2024 - Initial creation
  ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49354 - Changes introduced in CB013660. Changed parameter name and value.
  ...                 https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49326 - Changes in secyfication, RMOD reset during swupdate process.
  ...
Library  ./../../Resources/Python/software.py  WITH NAME  sw


*** Variables ***
# User Variables
${CONFIGURATION_RM_OFFLINE_TIMEOUT}  5min
${CONFIGURATION_RM_ENABLED_TIMEOUT}  5min
${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  15min

# Global Variables
${RECOVERY_actSWRollbackReject}  ${False}
${RECOVERY_sequentialRuSwUpgrade}  ${False}
${RECOVERY_SW_UPDATE}  ${False}


*** Keywords ***
TC__SiSo_SWM_Sequential_RU_SW_Activate_triggered_by_WebEM
    Set Tags     AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Sequential_RU_SW_Activate_triggered_by_WebEM for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Wrapper For Sequential RU SW Activate Triggered By WebEM  ${bts_id}
    END
    [Teardown]    Common Test Teardown

Wrapper For Sequential RU SW Activate Triggered By WebEM
    [Arguments]  ${bts_id}
    Step 1 Preconditions Sequential RU SW Update  ${bts_id}
    Step 2 Perform Sequential RU SW Update  ${bts_id}
    Step 3 Verify Sequential RU SW Update  ${bts_id}
    [Teardown]  Run Keyword And Continue On Failure  Recovery For Sequential RU SW Update  ${bts_id}

Recovery For Sequential RU SW Update
    [Documentation]
    ...  Description:
    ...  Recovery action for Sequential RU SW Update TC. Recovers parameters actSWRollbackReject and ${RU_SWUPDATE_PARAMETER_NAME} to default value.
    ...  Recovers RU's and BTS's SW packages to the one form test beginning.
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Recovery For Sequential RU SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    # Recover parameter actSWRollbackReject to default value
    IF  ${RECOVERY_actSWRollbackReject}
      Logging With Timestamp
      ...  message=Recovering parameter actSWRollbackReject to false
      ...  style=ONGOING
      ${actSWRollbackReject_succeeded}  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
      ...  connection=${bts_id}
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actSWRollbackReject
      ...  operation=update
      ...  value=false
      IF  ${actSWRollbackReject_succeeded}
        Logging With Timestamp
        ...  message=Set parameter actSWRollbackReject back to false
        ...  style=DONE
      ELSE
        Logging With Timestamp
        ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} recovery failed
        ...  style=ERROR
      END
    END

    # Recover parameter ${RU_SWUPDATE_PARAMETER_NAME} to default value
    IF  ${RECOVERY_sequentialRuSwUpgrade}
      Logging With Timestamp
      ...  message=Recovering parameter ${RU_SWUPDATE_PARAMETER_NAME} to false
      ...  style=ONGOING
      ${sequentialRuSwUpgrade_succeeded}  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
      ...  connection=${bts_id}
      ...  dist_name=MRBTS-${bts_id}/MNL-1
      ...  parameter=${RU_SWUPDATE_PARAMETER_NAME}
      ...  operation=delete
      ...  value=${RU_SWUPDATE_PARAMETER_VALUE}
      IF  ${sequentialRuSwUpgrade_succeeded}
        Logging With Timestamp
        ...  message=Removed parameter ${RU_SWUPDATE_PARAMETER_NAME}
        ...  style=DONE
      ELSE
        Logging With Timestamp
        ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} recovery failed
        ...  style=ERROR
      END
    END

    # Recover RU and BTS SW packages
    IF  ${RECOVERY_SW_UPDATE}
      Logging With Timestamp
      ...  message=Recovering SW package to ${BASE_BTS_SW_PACKAGE}
      ...  style=ONGOING
      ${sw_update_succeeded}  Run Keyword And Return Status  admin.Update Software
      ...  connection=${bts_id}
      ...  sw_package=${BASE_SW_PACKAGE_PATH}
      ...  timeout=4200
      ...  independent_sw_update_type=All
      IF  ${sw_update_succeeded}
        Logging With Timestamp
        ...  message=Recovered SW package
        ...  style=DONE
        Logging With Timestamp
        ...  message=Waiting for OnAir
        ...  style=ONGOING
        Run Keyword And Ignore Error  admin.Assert Every
        ...  connection=${bts_id}
        ...  class_name=RMOD
        ...  availabilityStatus=regex"[Oo]ff\\s?line"
        ...  timeout=${CONFIGURATION_RM_OFFLINE_TIMEOUT}
        Run Keyword And Continue On Failure  admin.Assert Every
        ...  connection=${bts_id}
        ...  class_name=RMOD
        ...  operationalState=regex"(?i)Enabled"
        ...  timeout=${CONFIGURATION_RM_ENABLED_TIMEOUT}
        Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
        ...  node_id=${bts_id}
        ...  expected_BTS_status=OnAir
        ...  HW_check=${TRUE}
        ...  cells_check=${TRUE}
        ...  scf_check=${FALSE}
        ...  timeout=${CONFIGURATION_BTS_VERIFIED_TIMEOUT}
      ELSE
        Logging With Timestamp
        ...  message=SW package recovery failed
        ...  style=ERROR
      END
    END

    Logging With Timestamp
    ...  message=Recovery done
    ...  style=PASS

Step 1 Preconditions Sequential RU SW Update
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions Sequential RU SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    ${frm}=  admin.Get Frm
    ...  connection=${bts_id}
    ${rmod_count}  Get Length  ${frm}
    Set Test Variable  ${RMOD_COUNT}  ${rmod_count}

    # Create RMs list
    ${all_rmod_sn_list}  Evaluate  [rmod["serialNumber"] for rmod in ${frm}]
    Set Test Variable  ${ALL_RMOD_SN_LIST}  ${all_rmod_sn_list}

    IF  len(@{ALL_RMOD_SN_LIST})<2  Fail  There has to be at least two RMs available!

    # Get BTS's SW versions and decide package update to
    ${get_software_info}  admin.Get Software Info
    ...  connection=${bts_id}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    ${passive_sw_version}  sw.Handle Trunk Package  ${get_software_info["Passive SW version"]}
    ${test_bts_sw_package}  sw.Which SW Testpackage To Update  ${active_sw_version}  ${passive_sw_version}
    Set Test Variable  ${BASE_BTS_SW_PACKAGE}  ${active_sw_version}
    Set Test Variable  ${TEST_BTS_SW_PACKAGE}  ${test_bts_sw_package}

    # Download selected SW packages
    Logging With Timestamp
    ...  message=Downloading SW package ${TEST_BTS_SW_PACKAGE} from Artifactory
    ...  style=ONGOING
    ${TEST_SW_PACKAGE_PATH}  sw.Download SW Package  ${TEST_BTS_SW_PACKAGE}
    Set Test Variable  ${TEST_SW_PACKAGE_PATH}  ${TEST_SW_PACKAGE_PATH}
    Logging With Timestamp
    ...  message=SW package ${TEST_BTS_SW_PACKAGE} is saved in ${TEST_SW_PACKAGE_PATH}
    ...  style=DONE
    Logging With Timestamp
    ...  message=Downloading SW package ${BASE_BTS_SW_PACKAGE} from Artifactory
    ...  style=ONGOING
    ${base_sw_package_path}  sw.Download SW Package  ${BASE_BTS_SW_PACKAGE}
    Set Test Variable  ${BASE_SW_PACKAGE_PATH}  ${base_sw_package_path}
    Logging With Timestamp
    ...  message=SW package ${BASE_BTS_SW_PACKAGE} is saved in ${BASE_SW_PACKAGE_PATH}
    ...  style=DONE

    ${rm_dict}  Create Dictionary
    Set Test Variable  ${RM_DICT}  ${rm_dict}
    FOR  ${rmod_sn}  IN  @{ALL_RMOD_SN_LIST}
      ${rm_distname}  Evaluate  next(rmod["id"]["configuration"] for rmod in ${frm} if rmod["serialNumber"] == "${rmod_sn}")
      ${rm_productname}  Evaluate  next(rmod["productName"] for rmod in ${frm} if rmod["serialNumber"] == "${rmod_sn}")
      ${rm_sw_package}  RM Get Active Build Name From RM  ${rmod_sn}
      ${temp_rm_dict}  Create Dictionary
      ...  sw_package=${rm_sw_package}
      ...  productname=${rm_productname}
      ...  distname=${rm_distname}
      Set To Dictionary  ${RM_DICT}  ${rmod_sn}=${temp_rm_dict}
    END

    # Make sure actSWRollbackReject is set true
    ${actSWRollbackReject_value}  Safetly Get Parameter Value  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  actSWRollbackReject  connection=${bts_id}
    Set Test Variable  ${DEFAULT_ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  ${DEFAULT_ACTSWROLLBACKREJECT_VALUE}
      Logging With Timestamp
      ...  message=Parameter actSWRollbackReject is already set to true
      ...  style=DONE
    ELSE
      admin.Perform Parameter Recommissioning
      ...  connection=${bts_id}
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actSWRollbackReject
      ...  operation=update
      ...  value=true
      Logging With Timestamp
      ...  message=Changed parameter actSWRollbackReject to true
      ...  style=DONE
    END
    Set Test Variable  ${RECOVERY_actSWRollbackReject}  ${True}

    #Changes introduced with feature CB013660. Change in parameter name and value.
    ${ru_swupdate_CB013660}  SWM Check If Current SW Build Is Newer Than  SBTS26R1_ENB_9999_250813_000021  bts_id=${BTS_ID}
    ${ru_swupdate_parameter_name}  Set Variable If  ${ru_swupdate_CB013660}  ruPhaseSwActivationResetPolicy  sequentialRuSwUpgrade
    ${ru_swupdate_parameter_value}  Set Variable If  ${ru_swupdate_CB013660}  Sequential  true
    Set Test Variable  ${RU_SWUPDATE_PARAMETER_NAME}  ${ru_swupdate_parameter_name}
    Set Test Variable  ${RU_SWUPDATE_PARAMETER_VALUE}  ${ru_swupdate_parameter_value}

    # Make sure ${RU_SWUPDATE_PARAMETER_NAME} is set ${RU_SWUPDATE_PARAMETER_VALUE}
    ${sequentialRuSwUpgrade_value}  Safetly Get Parameter Value  MRBTS-${bts_id}/MNL-1  ${RU_SWUPDATE_PARAMETER_NAME}  connection=${bts_id}
    Set Test Variable  ${DEFAULT_SEQUENTIALRUSWUPDATE_VALUE}  ${sequentialRuSwUpgrade_value}
    IF  "${DEFAULT_SEQUENTIALRUSWUPDATE_VALUE}"=="${RU_SWUPDATE_PARAMETER_VALUE}"
      Logging With Timestamp
      ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} is already set to ${RU_SWUPDATE_PARAMETER_VALUE}
      ...  style=DONE
    ELSE
      admin.Perform Parameter Recommissioning
      ...  connection=${bts_id}
      ...  dist_name=MRBTS-${bts_id}/MNL-1
      ...  parameter=${RU_SWUPDATE_PARAMETER_NAME}
      ...  operation=update
      ...  value=${RU_SWUPDATE_PARAMETER_VALUE}
      Logging With Timestamp
      ...  message=Changed parameter ${RU_SWUPDATE_PARAMETER_NAME} to ${RU_SWUPDATE_PARAMETER_VALUE}
      ...  style=DONE
    END
    Set Test Variable  ${RECOVERY_sequentialRuSwUpgrade}  ${True}

Step 2 Perform Sequential RU SW Update
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Perform Sequential RU SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Waiting for BTS to be ready for SW Update
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Wait SW Update Possible
    ...  connection=${bts_id}
    Set Test Variable  ${RECOVERY_SW_UPDATE}  ${True}
    Logging With Timestamp
    ...  message=BTS is ready for SW Update
    ...  style=DONE
    Logging With Timestamp
    ...  message=SW Update to package ${TEST_BTS_SW_PACKAGE} with independent_sw_update_type set to RuSwOnly started
    ...  style=ONGOING
    admin.Update Software
    ...  connection=${bts_id}
    ...  sw_package=${TEST_SW_PACKAGE_PATH}
    ...  timeout=4200
    ...  independent_sw_update_type=RuSwOnly
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE

Step 3 Verify Sequential RU SW Update
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3 Verify Sequential RU SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    # Verify reboots
    Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
    ...  node_id=${bts_id}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_BTS_VERIFIED_TIMEOUT}
    ${all_rmods_runtime_dn}  Get Ids For All  RMOD  connection=${bts_id}
    admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${CFG.test_logs_path}/BTSFiles/${BTS_ID}/ims_${BTS_ID}_check_rmods_reset.ims2
    ...  connection=${bts_id}
    Run Keyword And Continue On Failure  STATE Check State And Value In History
    ...  ims2_log_path=${CFG.test_logs_path}/BTSFiles/${BTS_ID}/ims_${BTS_ID}_check_rmods_reset.ims2
    ...  runtime_dn_list=${all_rmods_runtime_dn}
    ...  exp_state_name=availabilityStatus
    ...  exp_state_value=Regex"(?i)Not.?Installed"

    # Verify if all RMODs changed its SW package
    Logging With Timestamp
    ...  message=Checking RMs active SW packages
    ...  style=ONGOING
    ${not_updated_rms}  Create List
    FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
      ${current_rm_sw_package}  RM Get Active Build Name From RM  ${rm_sn}
      ${dict_rm_sw_package}  Get From Dictionary  ${dict_values}  sw_package
      IF  "${current_rm_sw_package}"=="${dict_rm_sw_package}"
        Append To List  ${not_updated_rms}  ${rm_sn}
      ELSE
        Logging With Timestamp
        ...  message=RM ${dict_values["productname"]} (${rm_sn}) behaved appropriately after RU SW update
        ...  style=DONE
      END
    END
    IF  len(@{not_updated_rms})>0  Fail  SW package of RMs @{not_updated_rms} did not change!
    Logging With Timestamp
    ...  message=All RMs updated successfully
    ...  style=DONE

    # Verify if BTS SW package did not change
    Logging With Timestamp
    ...  message=Checking BTS active SW package
    ...  style=ONGOING
    ${get_software_info}  admin.Get Software Info
    ...  connection=${bts_id}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    IF  "${active_sw_version}"!="${BASE_BTS_SW_PACKAGE}"  Fail  SW package of BTS changed!
    Logging With Timestamp
    ...  message=BTS SW package did not change
    ...  style=DONE

    # Verify BTS state
    Logging With Timestamp
    ...  message=Checking BTS states
    ...  style=ONGOING
    Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
    ...  node_id=${bts_id}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_BTS_VERIFIED_TIMEOUT}
    Logging With Timestamp
    ...  message=All RMs SW Package have been updated. TC passed
    ...  style=PASS

Safetly Get Parameter Value
    [Documentation]
    ...  Description:
    ...  Purpose of this KW is to safetly return value of provided parameter. It covers issue with no existing parameter (returns None). Empty
    ...  parameter will be returned as empty string. Fails in case of incorrect path or connection issue.
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | distname     | Yes   | Path of parameter                                                                             |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | parameter    | Yes   | Parameter name                                                                                |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | connection   | No    | Connection alias to WebEM (default: default)                                                  |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+------------------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                                    |
    ...  +=====================+================================================================================================+
    ...  | parameter_value     | String with value of parameter or None if no exists                                            |
    ...  +---------------------+------------------------------------------------------------------------------------------------+
    [Arguments]  ${distname}  ${parameter}  ${connection}=default
    ${distname_parameters}  admin.Get Parameter By Distname  ${distname}  connection=${connection}
    ${does_exist}  Run Keyword And Return Status  Dictionary Should Contain Key  ${distname_parameters[0]['parameters']}  ${parameter}
    IF  not ${does_exist}  Return From Keyword  ${None}
    ${parameter_value}  Get From Dictionary  ${distname_parameters[0]['parameters']}  ${parameter}
    [Return]  ${parameter_value}
