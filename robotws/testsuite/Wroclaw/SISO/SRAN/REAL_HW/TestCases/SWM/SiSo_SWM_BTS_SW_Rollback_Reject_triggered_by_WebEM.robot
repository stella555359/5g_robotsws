*** Settings ***
Documentation
  ...  AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-patryk.niewiejski@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3667885/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Purpose of this TC is to check CB10780 feature and rollback rejection on dualcore configurations.
  ...  Accordingly to actSWRollbackReject parameter, covers rejecting and accepting rollback, during secondary node is online and offline state.
  ...  Due to test case scenario it is required to run TC on fullrack configuration.
  ...  Tester can set variable CONFIGURATION_FORCE_SW_RECOVERY to false if recovery to base SW is unwanted.
  ...
  ...  Step 1 Preconditions BTS SW Rollback Reject
  ...  Preparing TL for testing. Creating TC Variables, downloading SW packages,
  ...  setting parameter actSWRollbackReject to true, updating to Testpackage
  ...
  ...  Step 2 Turn Off Power Of Secondary Node And Expect FID4352
  ...  Set actSWRollbackReject to true as it is another partition
  ...  Turn off secondary node and expect FID4352
  ...
  ...  Step 3 Perform Rollback Of Primary Core And Expect Rejection
  ...  Wait for BTS ready to SW Update
  ...  Try to rollback primary core
  ...  Expect rollback rejection due to AdminApiProcedureFailureException
  ...
  ...  Step 4 Perform Rollback Of Primary Core Without Rejection
  ...  Set actSWRollbackReject to false
  ...  Perform rollback of primary core
  ...  Wait for no ping next for ping from primary core
  ...  Wait for BTS to be ready for SW Update and operational state is enabled and no offline Availability status
  ...  Verify BTS active SW is BASE one
  ...  Expect FID4352 on secondary node
  ...
  ...  Step 5 Turn On Power Of Secondary Node And Expect FID23
  ...  Turn on secondary node and expect FID23
  ...
  ...  Step 6 Perform Rollback Of Fullrack BTS And Expect Rejection
  ...  Wait for BTS to be ready for SW update
  ...  Try to rollback fullrack BTS
  ...  Expect rollback rejection due to AdminApiProcedureFailureException
  ...
  ...  Step 7 Update Secondary Core To Same SW Build As Primary
  ...  Set actSWRollbackReject to false
  ...  Wait for BTS to bre ready for SW update
  ...  Try to rollback fullrack BTS
  ...  Wait for no ping next for ping
  ...  Wait for BTS to be ready for SW Update and operational state is enabled and no offline Availability status
  ...  Verify BTS active SW is BASE one
  ...  Wait for onAir
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 11.12.2024 - Initial creation
Library  taf.rfrl.common_resources.python.reset_bts_configuration
Library  ./../../Resources/Python/software.py  WITH NAME  sw

*** Variables ***
${CONFIGURATION_FORCE_SW_RECOVERY}  ${True}
${CONFIGURATION_FID23_TIMEOUT}  5min
${CONFIGURATION_RM_OFFLINE_TIMEOUT}  5min
${CONFIGURATION_RM_ENABLED_TIMEOUT}  5min
${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  15min
${CONFIGURATION_BTS_NOT_PINGABLE_TIMEOUT}  5min
${CONFIGURATION_BTS_PINGABLE_TIMEOUT}  3min
${CONFIGURATION_BTS_ONAIR_TIMEOUT}  15 minutes

*** Keywords ***
TC__SiSo_SWM_BTS_SW_Rollback_Reject_triggered_by_WebEM
    [Documentation]
    ...  Description:
    ...  Purpose of this TC is to check CB10780 feature and rollback rejection on dualcore configurations.
    ...  Accordingly to actSWRollbackReject parameter, covers rejecting and accepting rollback, during secondary node is online and offline state.
    ...  Due to test case scenario it is required to run TC on fullrack configuration.
    ...  Tester can set variable CONFIGURATION_FORCE_SW_RECOVERY to false if recovery to base SW is unwanted.
    Set Tags     AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-patryk.niewiejski@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=BTS_SW_Rollback_Reject_triggered_by_WebEM for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
        Wrapper For BTS SW Rollback Reject  ${bts_id}
    END
    [Teardown]    Common Test Teardown


Wrapper For BTS SW Rollback Reject
    [Documentation]
    ...  Description:
    ...  Wrapper KW for BTS SW Rollback Reject TC. Runs each step one by one and provides recovery action.
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Step 1 Preconditions BTS SW Rollback Reject  ${bts_id}
    Step 2 Turn Off Power Of Secondary Node And Expect FID4352  ${bts_id}
    Step 3 Perform Rollback Of Primary Core And Expect Rejection  ${bts_id}
    Step 4 Perform Rollback Of Primary Core Without Rejection  ${bts_id}
    Step 5 Turn On Power Of Secondary Node And Expect FID23  ${bts_id}
    Step 6 Perform Rollback Of Fullrack BTS And Expect Rejection  ${bts_id}
    Step 7 Update Secondary Core To Same SW Build As Primary  ${bts_id}
    [Teardown]  Recovery For BTS SW Rollback Reject  ${bts_id}


Recovery For BTS SW Rollback Reject
    [Documentation]
    ...  Description:
    ...  Recovery action for BTS SW Rollback Reject TC. Recovers parameter actSWRollbackReject to default value (false).
    ...  Recovers RU's and BTS's SW packages to the one form test beginning.
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    # Restore parameter actSWRollbackReject to false
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${bts_id}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
    Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  not ${actSWRollbackReject_value}
        Logging With Timestamp
        ...  message=Parameter actSWRollbackReject is already set to false
        ...  style=DONE
    ELSE
        admin.Perform Parameter Recommissioning
        ...  connection=${bts_id}
        ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
        ...  parameter=actSWRollbackReject
        ...  operation=update
        ...  value=false
        Logging With Timestamp
        ...  message=Changed parameter actSWRollbackReject to false
        ...  style=DONE
    END

    # Restore primary SW
    IF  ${CONFIGURATION_FORCE_SW_RECOVERY}
        # Perform SW Update to testpackage version
        Logging With Timestamp
        ...  message=Recovery SW Update to ${BASE_BTS_SW_PACKAGE} will be performed.
        ...  style=ONGOING
        Logging With Timestamp
        ...  message=Waiting for BTS to be ready for SW Update
        ...  style=ONGOING
        Run Keyword And Continue On Failure  admin.Wait SW Update Possible
        ...  connection=${bts_id}
        Logging With Timestamp
        ...  message=BTS is ready for SW Update
        ...  style=DONE
        Logging With Timestamp
        ...  message=SW Update to package ${BASE_SW_PACKAGE_PATH}
        ...  style=ONGOING
        admin.Update Software
        ...  connection=${bts_id}
        ...  sw_package=${BASE_SW_PACKAGE_PATH}
        ...  timeout=4200
        ...  independent_sw_update_type=All
        Logging With Timestamp
        ...  message=SW Update done
        ...  style=DONE
        Run Keyword And Ignore Error  admin.Wait SW Update Possible
        ...  connection=${bts_id}
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
            ...  connection=${bts_id}
            IF  "${status}"=="PASS"
                IF  "${bts_state}"=="OnAir"  BREAK
            END
            Sleep  30 seconds
        END
        Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
        ...  node_id=${bts_id}
        ...  expected_BTS_status=OnAir
        ...  HW_check=${TRUE}
        ...  cells_check=${TRUE}
        ...  scf_check=${FALSE}
        ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

        ${get_software_info}  admin.Get Software Info  connection=${bts_id}
        ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
        Run Keyword And Continue on Failure  Should Be Equal  ${active_sw_version}  ${BASE_BTS_SW_PACKAGE}
        ...    SW package on BTS did not change after update!

        # Restore parameter actSWRollbackReject to false on another partition
        ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
        ...  connection=${bts_id}
        ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
        Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
        IF  not ${actSWRollbackReject_value}
            Logging With Timestamp
            ...  message=Parameter actSWRollbackReject is already set to false
            ...  style=DONE
        ELSE
            admin.Perform Parameter Recommissioning
            ...  connection=${bts_id}
            ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
            ...  parameter=actSWRollbackReject
            ...  operation=update
            ...  value=false
            Logging With Timestamp
            ...  message=Changed parameter actSWRollbackReject to false
            ...  style=DONE
        END
    END


Step 1 Preconditions BTS SW Rollback Reject
    [Documentation]
    ...  Description:
    ...  Preparing TL for testing. Creating TC Variables, downloading SW packages, setting parameter actSWRollbackReject to true, updating to
    ...  Testpackage
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions BTS SW Rollback Reject
    ...  style=STEP
    ...  frame=${TRUE}

    # Check if it is fullrack BTS configuration
    IF  not ${CFG["NODES"]["${bts_id}"]["dualcore"]}  Fail  Only dualcore configuration is supported!

    # Get BTS's SW versions and decide package update to
    ${get_software_info}  admin.Get Software Info  connection=${bts_id}
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

    # Make sure actSWRollbackReject is set true
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${bts_id}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
    Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  ${actSWRollbackReject_value}
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

    # Perform SW Update to testpackage version
    Logging With Timestamp
    ...  message=BTS SW Package is ${BASE_BTS_SW_PACKAGE}. SW Update to ${TEST_BTS_SW_PACKAGE} will be performed.
    ...  style=ONGOING
    Logging With Timestamp
    ...  message=Waiting for BTS to be ready for SW Update
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Wait SW Update Possible
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=BTS is ready for SW Update
    ...  style=DONE
    Logging With Timestamp
    ...  message=SW Update to package ${TEST_SW_PACKAGE_PATH}
    ...  style=ONGOING
    admin.Update Software
    ...  connection=${bts_id}
    ...  sw_package=${TEST_SW_PACKAGE_PATH}
    ...  timeout=4200
    ...  independent_sw_update_type=All
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE
    Run Keyword And Ignore Error  admin.Wait SW Update Possible
    ...  connection=${bts_id}
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
        ...  connection=${bts_id}
        IF  "${status}"=="PASS"
            IF  "${bts_state}"=="OnAir"  BREAK
        END
        Sleep  30 seconds
    END
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
    ...  node_id=${bts_id}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

    ${get_software_info}  admin.Get Software Info  connection=${bts_id}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    Should Be Equal  ${active_sw_version}  ${TEST_BTS_SW_PACKAGE}  SW package on BTS did not change after update!

    # Make sure actSWRollbackReject is set true
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${bts_id}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
    Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  ${actSWRollbackReject_value}
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


Step 2 Turn Off Power Of Secondary Node And Expect FID4352
    [Documentation]
    ...  Description:
    ...  Set actSWRollbackReject to true as it is another partition. Turn off secondary node and expect FID4352
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Turn Off Power Of Secondary Node And Expect FID4352
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Turning OFF secondary SMOD ${CFG["NODES"]["${bts_id}"]["secondary_sm"]} and waiting for FID 4352 on secondary core
    ...  style=OUTGOING
    PDU Power Off Port By Serial Number
    ...  serial_number=${CFG["NODES"]["${bts_id}"]["secondary_sm"]}
    admin.Assert Alarm Active
    ...  parameters=faultId=4352, configObjectName=regex".*?SMOD-2"
    ...  timeout=300
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Secondary SMOD ${CFG["NODES"]["${bts_id}"]["secondary_sm"]} has been turned off and FID 4352 appeared
    ...  style=DONE


Step 3 Perform Rollback Of Primary Core And Expect Rejection
    [Documentation]
    ...  Description:
    ...  Wait for BTS ready to SW Update. Try to rollback primary core. Expect rollback rejection due to AdminApiProcedureFailureException
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3 Perform Rollback Of Primary Core And Expect Rejection
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Requesting rollback and expecting rejection
    ...  style=OUTGOING
    Run Keyword And Expect Error  STARTS: AdminApiProcedureFailureException  admin.Rollback Software  connection=${bts_id}
    Logging With Timestamp
    ...  message=Rollback failed as expected
    ...  style=DONE


Step 4 Perform Rollback Of Primary Core Without Rejection
    [Documentation]
    ...  Description:
    ...  Set actSWRollbackReject to false. Perform rollback of primary core. Wait for no ping next for ping from primary core. Wait for BTS to be
    ...  ready for SW Update and operational state is enabled and no offline Availability status. Verify BTS active SW is BASE one. Expect FID4352 on
    ...  secondary node
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4 Perform Rollback Of Primary Core Without Rejection
    ...  style=STEP
    ...  frame=${TRUE}

    # Make sure actSWRollbackReject is set false
    Logging With Timestamp
    ...  message=Setting up parameter actSWRollbackReject to false
    ...  style=OUTGOING
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${bts_id}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
    Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  ${actSWRollbackReject_value}
        admin.Perform Parameter Recommissioning
        ...  connection=${bts_id}
        ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
        ...  parameter=actSWRollbackReject
        ...  operation=update
        ...  value=false
        Logging With Timestamp
        ...  message=Changed parameter actSWRollbackReject to false
        ...  style=DONE
    ELSE
        Fail  Parameter actSWRollback should not be set to false at this stage of TC yet!
    END

    Logging With Timestamp
    ...  message=Requesting rollback of primary core
    ...  style=OUTGOING
    admin.Rollback Software  connection=${bts_id}
    Logging With Timestamp
    ...  message=Rollback performed
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting for BTS to be in commissioned, IntegratedToRan or OnAir state
    ...  style=OUTGOING
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
        ...  connection=${bts_id}
        IF  "${status}"=="PASS"
            IF  "${bts_state}"=="Commissioned" or "${bts_state}"=="IntegratedToRan" or "${bts_state}"=="OnAir"
                Logging With Timestamp
                ...  message=BTS reached ${bts_state} state
                ...  style=DONE
                BREAK
            END
        END
        Sleep  30 seconds
    END

    Logging With Timestamp
    ...  message=Waiting for FID 4352 on secondary core
    ...  style=OUTGOING
    admin.Assert Alarm Active
    ...  parameters=faultId=4352, configObjectName=regex".*?SMOD-2"
    ...  timeout=900
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=FID 4352 appeared on secondary core
    ...  style=DONE

    ${get_software_info}  admin.Get Software Info  connection=${bts_id}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    Should Be Equal  ${active_sw_version}  ${BASE_BTS_SW_PACKAGE}  SW package on BTS did not back to ${BASE_BTS_SW_PACKAGE} as expected!
    Logging With Timestamp
    ...  message=SW Package on BTS changed to ${BASE_BTS_SW_PACKAGE} as expected
    ...  style=DONE

Step 5 Turn On Power Of Secondary Node And Expect FID23
    [Documentation]
    ...  Description:
    ...  Turn on secondary node and expect FID23
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 5 Turn On Power Of Secondary Node And Expect FID23
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Turning ON secondary SMOD ${CFG["NODES"]["${bts_id}"]["secondary_sm"]} and waiting for FID 23 on secondary core
    ...  style=OUTGOING
    PDU Power On Port By Serial Number
    ...  serial_number=${CFG["NODES"]["${bts_id}"]["secondary_sm"]}
    admin.Assert Alarm Active
    ...  parameters=faultId=23, configObjectName=regex".*?SMOD-2"
    ...  timeout=${CONFIGURATION_FID23_TIMEOUT}
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Secondary SMOD ${CFG["NODES"]["${bts_id}"]["secondary_sm"]} has been turned off and FID 23 appeared
    ...  style=DONE


Step 6 Perform Rollback Of Fullrack BTS And Expect Rejection
    [Documentation]
    ...  Description:
    ...  Wait for BTS to be ready for SW update. Try to rollback fullrack BTS. Expect rollback rejection due to AdminApiProcedureFailureException
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 6 Perform Rollback Of Fullrack BTS And Expect Rejection
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Requesting rollback and expecting rejection
    ...  style=OUTGOING
    Run Keyword And Expect Error  STARTS: AdminApiProcedureFailureException  admin.Rollback Software  connection=${bts_id}
    Logging With Timestamp
    ...  message=Rollback failed as expected
    ...  style=DONE


Step 7 Update Secondary Core To Same SW Build As Primary
    [Documentation]
    ...  Description:
    ...  Set actSWRollbackReject to false. Wait for BTS to bre ready for SW update. Try to rollback fullrack BTS. Wait for no ping next for ping.
    ...  Wait for BTS to be ready for SW Update and operational state is enabled and no offline Availability status. Verify BTS active SW is BASE one.
    ...  Wait for onAir
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts_id       | Yes   | BTS ID for admin connection                                                                   |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 7 Update Secondary Core To Same SW Build As Primary
    ...  style=STEP
    ...  frame=${TRUE}

    # Make sure actSWRollbackReject is set false
    Logging With Timestamp
    ...  message=Setting up parameter actSWRollbackReject to false
    ...  style=OUTGOING
    ${featcadm_parameters}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  connection=${bts_id}
    ${actSWRollbackReject_value}  Get From Dictionary  ${featcadm_parameters[0]['parameters']}  actSWRollbackReject
    Set Test Variable  ${ACTSWROLLBACKREJECT_VALUE}  ${actSWRollbackReject_value}
    IF  ${actSWRollbackReject_value}
        admin.Perform Parameter Recommissioning
        ...  connection=${bts_id}
        ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
        ...  parameter=actSWRollbackReject
        ...  operation=update
        ...  value=false
        Logging With Timestamp
        ...  message=Changed parameter actSWRollbackReject to false
        ...  style=DONE
    ELSE
        Fail  Parameter actSWRollback should not be set to false at this stage of TC yet!
    END

    Logging With Timestamp
    ...  message=Requesting rollback of dual core
    ...  style=OUTGOING
    admin.Rollback Software  connection=${bts_id}
    Logging With Timestamp
    ...  message=Rollback performed
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting for BTS to be in OnAir state
    ...  style=OUTGOING
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
        ...  connection=${bts_id}
        IF  "${status}"=="PASS"
            IF  "${bts_state}"=="OnAir"
                Logging With Timestamp
                ...  message=BTS reached ${bts_state} state
                ...  style=DONE
                BREAK
            END
        END
        Sleep  30 seconds
    END

    ${get_software_info}  admin.Get Software Info  connection=${bts_id}
    ${active_sw_version}  sw.Handle Trunk Package  ${get_software_info["Active SW version"]}
    Should Be Equal  ${active_sw_version}  ${TEST_BTS_SW_PACKAGE}  SW package on BTS did not change after update!

    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${CONFIGURATION_BTS_VERIFIED_TIMEOUT}  30sec  STATE Verify BTS states
    ...  node_id=${bts_id}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=BTS is onAir and no unexpected alarms are visible
    ...  style=DONE
