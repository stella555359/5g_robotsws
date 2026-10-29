*** Settings ***
Documentation
  ...  AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3898542/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  TC requires at least one tested and not tested RMs. Tested RMs has to be provided in Test Case Variable 'TESTING_RMOD_SN'
  ...  TC does not support multi BTS confiugration. Only single BTS configuration works.
  ...  TC detects active and passive SW package from BTS and decides which testing packages should be downloaded.
  ...  Two SW will be downloaded during TC.
  ...  In case of any timeouts you can overwrite TIME_TO_WAIT_FOR_... variables in your TS
  ...
  ...  Step 1 Preconditions RU And BTS SW Update
  ...  Preparing TL for testing. Checking TC requirements, reating TC Variables, downloading SW packages,
  ...  setting parameter actSWRollbackReject to true
  ...
  ...  Step 2 Update Not Tested RM SW Package
  ...  Setting up parameter disableSWUpdate to true for tested RMs. Updating BTS Package with RuSwOnly parameter.
  ...  From SBTS26R1_ENB_9999_250813_000021 parameter change disableSWUpdate -> upgradePhase and value true -> No upgrade.
  ...  Waiting for FID 23 on tested RMODs for SBTS25R1 but from SBTS25R2 FID 23 changed severity to minor and not visible in WebEM.
  ...  Tested RM's SW package should not change
  ...
  ...  Step 3 Update Tested RM SW Package
  ...  Removing parameter disableSWUpdate/upgradePhase from tested RMs. Updating BTS package with RuSwOnly parameter.
  ...  Waiting for onAir. Tested RM;s SW package should change
  ...
  ...  Step 4 Update All BTS SW Package
  ...  Updating BTS package with All parameter. Waiting for onAir with not additional faults.
  ...  Checking if BTS SW update changed
  ...
  ...  Recovery For RU And BTS SW Activate Triggered By WebEM
  ...  Restores parameters disableSWUpdate/upgradePhase and actSWRollbackReject to values from beginning of TC
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 22.10.2024 - Initial creation
  ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49198  remove test step with FID:23 checking from SBTS25R2
  ...  - 01.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49347  Changes introduced in CB013660. Change in parameter name and value.
  ...
Library  ./../../Resources/Python/software.py  WITH NAME  sw

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
# User Variables
${CONFIGURATION_FID23_TIMEOUT}  5min
${CONFIGURATION_RM_OFFLINE_TIMEOUT}  5min
${CONFIGURATION_RM_ENABLED_TIMEOUT}  5min
${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  15min
${CONFIGURATION_BTS_NOT_PINGABLE_TIMEOUT}  5min
${CONFIGURATION_BTS_PINGABLE_TIMEOUT}  3min
${CONFIGURATION_BTS_ONAIR_TIMEOUT}  15 minutes

# Global Variables
${RECOVERY_disableSWUpdate}  ${False}
${RECOVERY_actSWRollbackReject}  ${False}

*** Keywords ***
TC__SiSo_SWM_RU_and_BTS_SW_activate_triggered_by_WebEM
    Set Tags     AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=RU_and_BTS_SW_activate_triggered_by_WebEM for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    Wrapper For RU And BTS SW Activate Triggered ByWebEM
    [Teardown]    Common Test Teardown
Wrapper For RU And BTS SW Activate Triggered ByWebEM
    Step 1 Preconditions RU And BTS SW Update
    Step 2 Update Not Tested RM SW Package
    Step 3 Update Tested RM SW Package
    Step 4 Update All BTS SW Package
    [Teardown]  Run Keyword And Continue On Failure  Recovery For RU And BTS SW Activate Triggered By WebEM


Recovery For RU And BTS SW Activate Triggered By WebEM
    [Documentation]
    ...  Description:
    ...  Recovery action for RU And BTS SW Activate Triggered By WebEM TC. Recovers parameter actSWRollbackReject to default value (false), and
    ...  removes ${RU_SWUPDATE_PARAMETER_NAME}.
    Logging With Timestamp
    ...  message=Recovery For RU And BTS SW Activate Triggered ByWebEM
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
        ...  message=Parameter sequentialRuSwUpgrade recovery failed
        ...  style=ERROR
      END
    END

    # Remove parameter ${RU_SWUPDATE_PARAMETER_NAME}
    IF  ${RECOVERY_disableSWUpdate}
        Logging With Timestamp
        ...  message=Removing parameter ${RU_SWUPDATE_PARAMETER_NAME}
        ...  style=OUTGOING
        FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
            Continue For Loop If  ${dict_values["affected"]} != ${True}
            ${disableSWUpdate_succeeded}  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
            ...  connection=${BTS_ID}
            ...  dist_name=${dict_values["distname"]}
            ...  parameter=${RU_SWUPDATE_PARAMETER_NAME}
            ...  operation=delete
            ...  value=${RU_SWUPDATE_PARAMETER_VALUE}
            IF  ${disableSWUpdate_succeeded}
              Logging With Timestamp
              ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} for RM ${dict_values["productname"]} (${rm_sn}) has been removed
              ...  style=DONE
            ELSE
              Logging With Timestamp
              ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} for RM ${dict_values["productname"]} (${rm_sn}) couldn't be removed
              ...  style=ERROR
            END
        END
    END
    Logging With Timestamp
    ...  message=Recovery done
    ...  style=PASS


Step 1 Preconditions RU And BTS SW Update
    Logging With Timestamp
    ...  message=Step 1 Preconditions RU And BTS SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    # Check if it is single BTS configuration
    ${number_of_bts}  Get Length  ${CFG.active_bts_list}
    Should Be Equal As Integers  ${number_of_bts}  ${1}  This Test Case supports only single BTS configurations!
    Set Test Variable  ${BTS_ID}  ${CFG.primary_node_bts_id}

    # Check if variable with SN is provided
    Variable Should Exist  ${TESTING_RMOD_SN}  Test variable $\{TESTING_RMOD_SN\} has to be set in Test Suite!
    Set Test Variable  @{AFFECTED_RM_SN_LIST}  @{TESTING_RMOD_SN}

    # Create unaffected RMs list
    ${frm}  admin.Get Frm  connection=${BTS_ID}
    ${unaffected_rm_sn_list}  Evaluate  [rmod["serialNumber"] for rmod in ${frm} if rmod["serialNumber"] not in @{AFFECTED_RM_SN_LIST}]
    Set Test Variable  ${UNAFFECTED_RM_SN_LIST}  ${unaffected_rm_sn_list}

    # Check if exist at least one affectend and uneffected RMs
    IF  len(@{AFFECTED_RM_SN_LIST})<1 or len(@{UNAFFECTED_RM_SN_LIST})<1
    ...  Fail  There has to be at least one tested and one not tested RMs available!

    # Get BTS's SW versions and decide package update to
    ${get_software_info}  admin.Get Software Info
    ...  connection=${BTS_ID}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    ${passive_sw_version}  sw.Handle Trunk Package  ${get_software_info["Passive SW version"]}
    ${test_bts_sw_package}  sw.Which SW Testpackage To Update  ${active_sw_version}  ${passive_sw_version}
    Set Test Variable  ${BASE_BTS_SW_PACKAGE}  ${active_sw_version}
    Set Test Variable  ${TEST_BTS_SW_PACKAGE}  ${test_bts_sw_package}

    # Download selected SW packages
    Logging With Timestamp
    ...  message=Downloading SW package ${TEST_BTS_SW_PACKAGE} from Artifactory
    ...  style=ONGOING
    ${test_sw_package_path}  sw.Download SW Package  ${TEST_BTS_SW_PACKAGE}
    Set Test Variable  ${TEST_SW_PACKAGE_PATH}  ${test_sw_package_path}
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

    # Create dictionary to work on it in later in TC
    ${rm_dict}  Create Dictionary
    Set Test Variable  ${RM_DICT}  ${rm_dict}
    FOR  ${affected_rm_sn}  IN  @{AFFECTED_RM_SN_LIST}
        ${affected_rm_distname}  Evaluate  next(rmod["id"]["configuration"] for rmod in ${frm} if rmod["serialNumber"] == "${affected_rm_sn}")
        ${affected_rm_productname}  Evaluate  next(rmod["productName"] for rmod in ${frm} if rmod["serialNumber"] == "${affected_rm_sn}")
        ${affected_rm__sw_package}  RM Get Active Build Name From RM  ${affected_rm_sn}
        ${affected_rm_dict}  Create Dictionary
        ...  affected=${True}
        ...  sw_package=${affected_rm__sw_package}
        ...  productname=${affected_rm_productname}
        ...  distname=${affected_rm_distname}
        Set To Dictionary  ${RM_DICT}  ${affected_rm_sn}=${affected_rm_dict}
    END
    FOR  ${unaffected_rm_sn}  IN  @{UNAFFECTED_RM_SN_LIST}
        ${unaffected_rm_distname}  Evaluate  next(rmod["id"]["configuration"] for rmod in ${frm} if rmod["serialNumber"] == "${unaffected_rm_sn}")
        ${unaffected_rm_productname}  Evaluate  next(rmod["productName"] for rmod in ${frm} if rmod["serialNumber"] == "${unaffected_rm_sn}")
        ${unaffected_rm_dict}  Create Dictionary
        ...  affected=${False}
        ...  sw_package=${None}
        ...  productname=${unaffected_rm_productname}
        ...  distname=${unaffected_rm_distname}
        Set To Dictionary  ${RM_DICT}  ${unaffected_rm_sn}=${unaffected_rm_dict}
    END

    # Make sure actSWRollbackReject is set true
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${BTS_ID}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
    Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  ${actSWRollbackReject_value}
        Logging With Timestamp
        ...  message=Parameter actSWRollbackReject is already set to true
        ...  style=DONE
    ELSE
        admin.Perform Parameter Recommissioning
        ...  connection=${BTS_ID}
        ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...  parameter=actSWRollbackReject
        ...  operation=update
        ...  value=true
        Logging With Timestamp
        ...  message=Changed parameter actSWRollbackReject to true
        ...  style=DONE
        Set Test Variable  ${RECOVERY_actSWRollbackReject}  ${True}
    END
    ${sw_fault_23_severity_minor}  SWM Check If Current SW Build Is Newer Than  SBTS25R2_ENB_9999_250110_000012  bts_id=${BTS_ID}
    Set Test Variable  ${SW_FAULT_23_SEVERITY_MINOR}  ${sw_fault_23_severity_minor}
    #Changes introduced with feature CB013660. Change in parameter name and value.
    ${ru_swupdate_CB013660}  SWM Check If Current SW Build Is Newer Than  SBTS26R1_ENB_9999_250813_000021  bts_id=${BTS_ID}
    ${ru_swupdate_parameter_name}  Set Variable If  ${ru_swupdate_CB013660}  upgradePhase  disableSWUpdate
    ${ru_swupdate_parameter_value}  Set Variable If  ${ru_swupdate_CB013660}  No upgrade  true
    Set Test Variable  ${RU_SWUPDATE_PARAMETER_NAME}  ${ru_swupdate_parameter_name}
    Set Test Variable  ${RU_SWUPDATE_PARAMETER_VALUE}  ${ru_swupdate_parameter_value}

Step 2 Update Not Tested RM SW Package
    Logging With Timestamp
    ...  message=Step 2 Update Not Tested RM SW Package
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Setting up parameter ${RU_SWUPDATE_PARAMETER_NAME} to ${RU_SWUPDATE_PARAMETER_VALUE} for each tested RM
    ...  style=ONGOING
    FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
        Continue For Loop If  ${dict_values["affected"]} != ${True}
        admin.Perform Parameter Recommissioning
        ...  connection=${BTS_ID}
        ...  dist_name=${dict_values["distname"]}
        ...  parameter=${RU_SWUPDATE_PARAMETER_NAME}
        ...  operation=update
        ...  value=${RU_SWUPDATE_PARAMETER_VALUE}
        Logging With Timestamp
        ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} for RM ${dict_values["productname"]} (${rm_sn})
        ...  message_2=has been set to ${RU_SWUPDATE_PARAMETER_VALUE}
        ...  style=DONE
    END
    Set Test Variable  ${RECOVERY_disableSWUpdate}  ${True}

    Logging With Timestamp
    ...  message=Waiting for BTS to be ready for SW Update
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Wait SW Update Possible
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=BTS is ready for SW Update
    ...  style=DONE
    Logging With Timestamp
    ...  message=SW Update to package ${TEST_BTS_SW_PACKAGE} with independent_sw_update_type set to RuSwOnly started
    ...  style=ONGOING
    admin.Update Software
    ...  connection=${BTS_ID}
    ...  sw_package=${TEST_SW_PACKAGE_PATH}
    ...  timeout=4200
    ...  independent_sw_update_type=RuSwOnly
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting for RMODs to reboot after SW Update
    ...  style=ONGOING
    Run Keyword And Ignore Error  admin.Assert Any
    ...  connection=${BTS_ID}
    ...  class_name=RMOD
    ...  availabilityStatus=regex"[Oo]ff\\s?line"
    ...  timeout=${CONFIGURATION_RM_OFFLINE_TIMEOUT}
    Run Keyword And Continue On Failure  admin.Assert Every
    ...  connection=${BTS_ID}
    ...  class_name=RMOD
    ...  operationalState=regex"(?i)Enabled"
    ...  timeout=${CONFIGURATION_RM_ENABLED_TIMEOUT}
    Logging With Timestamp
    ...  message=All RMODs are in enabled operational state
    ...  style=DONE

    # Verify alaram 23 visible on affected RMODs
    IF  ${SW_FAULT_23_SEVERITY_MINOR}
        Logging With Timestamp
        ...  message=Fault 23 changed severity to minor and not visible in WebEM
        ...  style=INFO
    ELSE
        Logging With Timestamp
        ...  message=Waiting for critical fault 23 on each tested RM
        ...  style=ONGOING
    END
    FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
        Exit For Loop If  ${SW_FAULT_23_SEVERITY_MINOR}
        Continue For Loop If  ${dict_values["affected"]} != ${True}
        Run Keyword And Continue on Failure  admin.Assert Alarm Active
        ...  connection=${BTS_ID}
        ...  faultId=23, severity=Critical, configObjectName==regex".*${dict_values["distname"]}"
        ...  timeout=${CONFIGURATION_FID23_TIMEOUT}
        Logging With Timestamp
        ...  message=Critical alarm FID:23 is active on RM ${dict_values["productname"]} (${rm_sn})
        ...  style=DONE
    END

    # Verify if affected RMOD did not change SW package
    Logging With Timestamp
    ...  message=Verifing SW package change of tested RMs
    ...  style=ONGOING
    FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
        Continue For Loop If  ${dict_values["affected"]} != ${True}
        ${current_rm_sw_package}  RM Get Active Build Name From RM  ${rm_sn}
        ${dict_rm_sw_package}  Get From Dictionary  ${dict_values}  sw_package
        IF  "${current_rm_sw_package}"!="${dict_rm_sw_package}"
          Fail  SW package of tested RM ${dict_values["productname"]} (${rm_sn}) changed from '${dict_rm_sw_package}' to '${current_rm_sw_package}'!
        ELSE
          Logging With Timestamp
          ...  message=RM ${dict_values["productname"]} (${rm_sn}) did not change SW package after update with parameter
          ...  message_2=${RU_SWUPDATE_PARAMETER_NAME} set to ${RU_SWUPDATE_PARAMETER_VALUE}
          ...  style=DONE
        END
    END


Step 3 Update Tested RM SW Package
    Logging With Timestamp
    ...  message=Step 3 Update Tested RM SW Package
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Removing parameter ${RU_SWUPDATE_PARAMETER_NAME} for each tested RM
    ...  style=ONGOING
    FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
        Continue For Loop If  ${dict_values["affected"]} != ${True}
        admin.Perform Parameter Recommissioning
        ...  connection=${BTS_ID}
        ...  dist_name=${dict_values["distname"]}
        ...  parameter=${RU_SWUPDATE_PARAMETER_NAME}
        ...  operation=delete
        ...  value=${RU_SWUPDATE_PARAMETER_VALUE}
        Logging With Timestamp
        ...  message=Parameter ${RU_SWUPDATE_PARAMETER_NAME} for RM ${dict_values["productname"]} (${rm_sn}) has been removed
        ...  style=DONE
    END
    Set Test Variable  ${RECOVERY_disableSWUpdate}  ${False}

    Logging With Timestamp
    ...  message=Waiting for BTS to be ready for SW Update
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Wait SW Update Possible
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=BTS is ready for SW Update
    ...  style=DONE
    Logging With Timestamp
    ...  message=SW Update to package ${TEST_BTS_SW_PACKAGE} with independent_sw_update_type set to RuSwOnly started
    ...  style=ONGOING
    admin.Update Software
    ...  connection=${BTS_ID}
    ...  sw_package=${TEST_SW_PACKAGE_PATH}
    ...  timeout=4200
    ...  independent_sw_update_type=RuSwOnly
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting for RMODs to reboot after SW Update
    ...  style=ONGOING
    Run Keyword And Ignore Error  admin.Assert Any
    ...  connection=${BTS_ID}
    ...  class_name=RMOD
    ...  availabilityStatus=regex"[Oo]ff\\s?line"
    ...  timeout=${CONFIGURATION_RM_OFFLINE_TIMEOUT}
    Run Keyword And Continue On Failure  admin.Assert Every
    ...  connection=${BTS_ID}
    ...  class_name=RMOD
    ...  operationalState=regex"(?i)Enabled"
    ...  timeout=${CONFIGURATION_RM_ENABLED_TIMEOUT}
    Logging With Timestamp
    ...  message=All RMODs are in enabled operational state
    ...  style=DONE

    Run Keyword And Ignore Error  admin.Wait SW Update Possible
    ...  connection=${BTS_ID}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
    ...  node_id=${BTS_ID}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_BTS_VERIFIED_TIMEOUT}

    # Verify if affected RMOD changed SW package
    Logging With Timestamp
    ...  message=Verifing SW package change of tested RMs
    ...  style=ONGOING
    FOR  ${rm_sn}  ${dict_values}  IN  &{RM_DICT}
        Continue For Loop If  ${dict_values["affected"]} != ${True}
        ${current_rm_sw_package}  RM Get Active Build Name From RM  ${rm_sn}
        ${dict_rm_sw_package}  Get From Dictionary  ${dict_values}  sw_package
        IF  "${current_rm_sw_package}"=="${dict_rm_sw_package}"
            Fail  SW package of tested RM ${dict_values["productname"]} (${rm_sn}) did not change from '${dict_rm_sw_package}'!
        ELSE
            Logging With Timestamp
            ...  message=RM ${dict_values["productname"]} (${rm_sn}) behaved appropriately after RU SW update
            ...  style=ONGOING
        END
    END


Step 4 Update All BTS SW Package
    Logging With Timestamp
    ...  message=Step 4 Update All BTS SW Package
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Waiting for BTS to be ready for SW Update
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Wait SW Update Possible
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=BTS is ready for SW Update
    ...  style=DONE
    Logging With Timestamp
    ...  message=SW Update to package ${TEST_BTS_SW_PACKAGE} with independent_sw_update_type set to All started
    ...  style=ONGOING
    admin.Update Software
    ...  connection=${BTS_ID}
    ...  sw_package=${TEST_SW_PACKAGE_PATH}
    ...    timeout=4200
    ...    independent_sw_update_type=All
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting for BTS to reboot and became onAir
    ...  style=ONGOING
    Run Keyword And Ignore Error  STATE BTS Address Is NOT Pingable
    ...  host_ip_addr=192.168.255.1
    ...  timeout=${CONFIGURATION_BTS_NOT_PINGABLE_TIMEOUT}
    ...  bts_id=${bts_id}
    Run Keyword And Ignore Error  STATE BTS Address Is Pingable
    ...  host_ip_addr=192.168.255.1
    ...  timeout=${CONFIGURATION_BTS_PINGABLE_TIMEOUT}
    ...  bts_id=${bts_id}
    WHILE  ${True}  limit=${CONFIGURATION_BTS_ONAIR_TIMEOUT}
        ${status}  ${bts_state}  Run Keyword And Ignore Error  admin.Get Mrbts State
        ...  connection=${BTS_ID}
        IF  "${status}"=="PASS"
            IF  "${bts_state}"=="OnAir"  BREAK
        END
        Sleep  30 seconds
    END
    Run Keyword And Ignore Error  admin.Wait SW Update Possible
    ...  connection=${BTS_ID}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  1min  STATE Verify BTS states
    ...  node_id=${BTS_ID}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_BTS_VERIFIED_TIMEOUT}

    Logging With Timestamp
    ...  message=Checking if BTS updated correctyly
    ...  style=OUTGOING
    ${get_software_info}  admin.Get Software Info
    ...  connection=${BTS_ID}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    Should Be Equal  ${active_sw_version}  ${TEST_BTS_SW_PACKAGE}  SW package is ${active_sw_version} and did not update to ${TEST_BTS_SW_PACKAGE}
    Logging With Timestamp
    ...  message=BTS SW Package has been updated to ${TEST_SW_PACKAGE_PATH}. So did all RMODs. TC passed
    ...  style=PASS
