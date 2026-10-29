*** Settings ***
Documentation
...  The purpose of this test case is to check procedure of Radio Unit SW update during fail safe mode.

Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_fail_safe.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***
${RMOD_SN}  # Radio Unit serial number is required!

*** Keywords ***
TC__SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
    [Documentation]
        ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46794
        ...
        ...  *****************
        ...  Basic information
        ...  *****************
        ...  The purpose of this test case is to check procedure of Radio Unit SW update during fail safe mode.
        ...  Standard, T1 and T2 SW packages are required to run this TC.
        ...  SW is downloaded from http://files.ute.nsn-rdnet.net/builds/enb/base/
        ...  TC enables Fail Safe Mode and verify faults 2934 reporting after fail safe mode activation.
        ...  TC disables Fail Safe Mode without resetting RM and performs SW update to downloaded package.
        ...  TC verifies clear alarms and check On Air status.
        ...  IMPORTANT:
        ...  TC works with RU families: 5.1*, 6.2* tested on AHFII.
        ...
        ...  ******************
        ...  History of changes
        ...  ******************
        ...  - 06.05.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46794 - Initial creation

        Set Tags
        ...    OWNER-patryk.niewiejski@nokia.com
        ...    AUTHOR-patryk.niewiejski@nokia.com
        ...    MAINTAINER-patryk.niewiejski@nokia.com
        ...    FEATURE-CB011039

        step1: Preconditions
        step2: Fail Safe Mode Activation
        step3: Fail Safe Mode Deactivation Without Reboot
        step4: Download SW Package And Perform SW Update
        step5: BTS State Verification

step1: Preconditions
    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}

    Set Test Variable  ${RECOVERY}  ${FALSE}
    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !
    Verify Serial Number  ${RMOD_SN}
    Log To Console  RMOD with SN -> ${RMOD_SN} found in HW Configuration


step2: Fail Safe Mode Activation
    Log To Console  --------------------
    Log To Console  step2: Fail Safe Mode Activation
    Log To Console  --------------------${\n}

    ca_BSRF_fail_safe.Enable Fail Safe Mode For RM  ${RMOD_SN}
    Set Test Variable  ${RECOVERY}  ${TRUE}
    Wait Until Keyword Succeeds  3min  10sec  Check Fail Safe mode For RM  ${RMOD_SN}  Enabled

    Log To Console  RMOD ${RMOD_SN} state validation
    ${all_rm_info}=  admin.Get FRM
    FOR  ${rm_info}  IN  @{all_rm_info}
        Continue For Loop If  "${rm_info["serialNumber"]}"!="${RMOD_SN}"
        Set Test Variable  ${RMOD_DIST_NAME}  ${rm_info["id"]["internal"]}
    END
    Wait Until Keyword Succeeds  5min  10sec
    ...  admin.Assert  RMOD  ${RMOD_DIST_NAME}  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)Off\\s?line"

    Log To Console  Alarms Critical 2934 checking
    Wait Until Keyword Succeeds  1min  10sec  admin.Assert Alarm Active  faultId=2934, severity=Critical

step3: Fail Safe Mode Deactivation Without Reboot
    Log To Console  --------------------
    Log To Console  step3: Fail Safe Mode Deactivation Without Reboot
    Log To Console  --------------------${\n}

    ca_BSRF_fail_safe.Disable Fail Safe Mode For RM  ${RMOD_SN}  forced_reboot=${False}
    Wait Until Keyword Succeeds  3min  10sec  Check Fail Safe mode For RM  ${RMOD_SN}  Disabled

step4: Download SW Package And Perform SW Update
    Log To Console  --------------------
    Log To Console  step4: Download SW Package And Perform SW Update
    Log To Console  --------------------${\n}

    ${sw_version}=  Get BTS SW Version
    # Detect T1/T2 package
    ${t1_package_detected}=  Evaluate  "T1" in "${sw_version}"
    ${t2_package_detected}=  Evaluate  "T2" in "${sw_version}"
    # Get SW Branch name
    ${sw_branch}=  Evaluate  "SBTS00" if "_9999_" in "${sw_version}" else "${sw_version}".split("_")[0]
    # Remove T1/T2 suffix if present
    ${sw_version}=  Run Keyword If  ${t1_package_detected}  Remove String  ${sw_version}  T1
    ...  ELSE IF  ${t2_package_detected}  Remove String  ${sw_version}  T2
    ...  ELSE  Set Variable  ${sw_version}
    # Choose package to download
    ${sw_package}=  Run Keyword If  ${t1_package_detected}  Set Variable  ${sw_version}_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ...  ELSE IF  ${t2_package_detected}  Set Variable  ${sw_version}_release_BTSSM_downloadable_A54.zip
    ...  ELSE  Set Variable  ${sw_version}_release_BTSSM_downloadable_testpackage_T1_A54.zip
    Log To Console  SW package selected to update is ${sw_package}. Downloading in progress...
    # Download package
    ${wft_url}=  Set Variable
    ...  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/${sw_branch}/${sw_version}/${sw_package}
    ${wget_rc}    ${wget_output}=  Run and Return RC and Output  wget -c -P /home/ute/Downloads ${wft_url}
    Log    ${wget_output}
    Run Keyword If  ${wget_rc} != 0  Fail  Unable to download SW package: ${wft_url}

    Log To Console  Waiting for BTS SW Update to be possible
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  15min  10sec  admin.Wait SW Update Possible
    Log To Console  Updating BTS to package ${sw_package}
    admin.Update Software  /home/ute/Downloads/${sw_package}  timeout=3600

    Log To Console  SW update completed. Waiting for no ping from BTS
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5min  10sec  Run keyword and expect error  1 != 0
    ...  BTS Address Is Pingable   192.168.255.1

    Log To Console  Waiting for onAir
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  15min  30sec  Verify BTS states
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  15min  10sec  admin.Wait SW Update Possible

    Log To Console  BTS SW version verification
    ${sw_to_validate}=  Remove String  ${sw_package}  _release_BTSSM_downloadable  _testpackage_  _A54  .zip
    ${sw_version_updated}=  Get BTS SW Version
    Should Be Equal  ${sw_to_validate}  ${sw_version_updated}  msg=SW on BTS after update does not equal downloaded one

step5: BTS State Verification
    Log To Console  --------------------
    Log To Console  step5: BTS State Verification
    Log To Console  --------------------${\n}

    Log To Console  RMOD ${RMOD_SN} state validation
    Wait Until Keyword Succeeds  5min  10sec  admin.Assert  RMOD  ${RMOD_DIST_NAME}  operationalState=regex"(?i)Enabled"
    Log To Console  Alarms Critical 2934 checking
    Wait Until Keyword Succeeds  2min  10sec  admin.Assert Alarm Inactive  faultId=2934, severity=Critical
    Verify BTS states

BTS Address Is Pingable
    [Arguments]  ${host_ip_addr}
    ${rc}=    Run And Return Rc     ping -c 1 ${host_ip_addr}
    should be equal as integers     ${rc}    0

BTS is OnAir
   ${mrbts_state}=    admin.Get MRBTS State
   Should Be True    '${mrbts_state}' == 'OnAir'

Get BTS SW Version
    ${sw_info}=  admin.Get Software Info
    ${lte_sw_version}=  Get From Dictionary  ${sw_info}  Active LTE RAT version
    ${is_trunk}=  Set Variable  "_ENB_9999_" in "${lte_sw_version}"
    ${sw_version}=  Run Keyword If  ${is_trunk}  Evaluate  "_".join(["SBTS00"] + "${lte_sw_version}".split("_")[1:])
    ...  ELSE  Set Variable  ${lte_sw_version}
    [Return]  ${sw_version}

Recovery Action
    Run Keyword And Ignore Error  ca_BSRF_fail_safe.Disable Fail Safe Mode For RM  ${RMOD_SN}

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RECOVERY}  Recovery Action
    Common Test Teardown
