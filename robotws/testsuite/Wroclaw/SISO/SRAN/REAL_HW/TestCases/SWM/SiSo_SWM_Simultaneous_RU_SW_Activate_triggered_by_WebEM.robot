*** Settings ***
Documentation
  ...  AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-patryk.niewiejski@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3667886/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1 Preconditions Simultaneous RU SW Update
  ...  Preparing TL for testing. Creating TC Variables, downloading SW packages,
  ...  setting parameter actSWRollbackReject to true.
  ...
  ...  Step 2 Perform Simultaneous RU SW Update
  ...  Updating BTS Package with RuSwOnly parameter. All RMODs should update its SW package but BTS package should stay the same.
  ...  All RMODs should reboot simultaneous.
  ...
  ...  Recovery For Simultaneous RU SW Update
  ...  Recovering actSWRollbackReject parameter and BTS SW package.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 15.11.2024 - Initial creation
  ...
Library  ./../../Resources/Python/software.py  WITH NAME  sw


*** Variables ***
# User Variables
${CONFIGURATION_RM_OFFLINE_TIMEOUT}  5min
${CONFIGURATION_RM_ENABLED_TIMEOUT}  5min
${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  15min

# Global Variables
${RECOVERY_actSWRollbackReject}  ${False}
${RECOVERY_SW_UPDATE}  ${False}


*** Keywords ***
TC__SiSo_SWM_Simultaneous_RU_SW_Activate_triggered_by_WebEM
    Set Tags     AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-patryk.niewiejski@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Simultaneous_RU_SW_Activate_triggered_by_WebEM for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Wrapper For Simultaneous RU SW Activate Triggered By WebEM  ${bts_id}
    END
    [Teardown]    Common Test Teardown

Wrapper For Simultaneous RU SW Activate Triggered By WebEM
    [Arguments]  ${bts_id}
    Step 1 Preconditions Simultaneous RU SW Update  ${bts_id}
    Step 2 Perform Simultaneous RU SW Update  ${bts_id}
    [Teardown]  Run Keyword And Continue On Failure  Recovery For Simultaneous RU SW Update  ${bts_id}

Recovery For Simultaneous RU SW Update
    [Documentation]
    ...  Description:
    ...  Recovery action for Simultaneous RU SW Update TC. Recovers parameter actSWRollbackReject to default value (false).
    ...  Recovers RU's and BTS's SW packages to the one form test beginning.
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Recovery For Simultaneous RU SW Update
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

Step 1 Preconditions Simultaneous RU SW Update
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions Simultaneous RU SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    ${frm}=  admin.Get Frm
    ...  connection=${bts_id}

    # Create RMs list
    ${all_rmod_sn_list}  Evaluate  [rmod["serialNumber"] for rmod in ${frm}]
    Set Test Variable  ${ALL_RMOD_SN_LIST}  ${all_rmod_sn_list}

    IF  len(@{ALL_RMOD_SN_LIST})<2  Fail  There has to be at least two RMs available!

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

    # Create dictionary with essential RU info
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
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${bts_id}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
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

Step 2 Perform Simultaneous RU SW Update
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Perform Simultaneous RU SW Update
    ...  style=STEP
    ...  frame=${TRUE}

    # RU SW Only update and reboot verification
    Logging With Timestamp
    ...  message=Waiting for BTS to be ready for SW Update
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Wait SW Update Possible
    ...  connection=${bts_id}
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
    Set Test Variable  ${RECOVERY_SW_UPDATE}  ${True}
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting for RMODs to reboot after SW Update
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
    Logging With Timestamp
    ...  message=All RMODs are in enabled operational state
    ...  style=DONE

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
    ...  connection=${BTS_ID}
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
    ...  node_id=${BTS_ID}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_BTS_VERIFIED_TIMEOUT}
    Logging With Timestamp
    ...  message=All RMs SW Package have been updated. TC passed
    ...  style=PASS
