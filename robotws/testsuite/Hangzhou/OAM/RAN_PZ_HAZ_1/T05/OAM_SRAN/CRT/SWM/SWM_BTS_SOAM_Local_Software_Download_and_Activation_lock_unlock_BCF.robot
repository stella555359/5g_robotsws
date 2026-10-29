*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Library    hran_tools

Library    taf.sbts.oam.coam.admin


*** Variables ***
${TARGET_SW_NAME}       ${None}                         # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}        /home/ute/btsauto/TARGET_SW/     # Directory for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}       3000                            # Timeout for Download and Activation [sec]
${SW Activation Timeout}                          150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                              420  # Timeout for ping loss during reset
${Ping regain timeout}                            600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                    30  # Test timeout (in minutes)


*** Keywords ***
TC__SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-14664
    ...
    ...  ***********************************************************
    ...  2. Description
    ...  ***********************************************************
    ...  Main purpose of this test is to verify if SW Update will successful when GSM cell is blocked.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************

    [Timeout]    80 minutes
    Set Tags    CA-SWM    PHASE-CRT    OWNER-kamil.osak@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS17    SW-SBTS18    SW-SBTS19    SW-SBTS20    FEATURE-RP000938
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Step1: Check path to SW package
    Step2: Get active and passive SW version
    Step3: Block GSM cell and check fault
    Step4: Start SW update with activation
    Step5: Faults verification
    Step6: Check if reset is not performed
    Step7: Check if BTS is onAir

Step1: Check path to SW package
    [Documentation]    Short description.
    Log Step Header  Step1: Check path to SW package
    ${target_sw_path}  Get sw package from directory  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}

Step2: Get active and passive SW version
    [Documentation]    Short description.
    Log Step Header  Step2: Get active and passive SW version
    Check if sw build already present on active partition  ${TARGET_SW_PATH}
    Log  SW not present on active partition  console=${TRUE}
    Check if sw build already present on passive partition  ${TARGET_SW_PATH}
    Log  SW not present on passive partition  console=${TRUE}

Step3: Block GSM cell and check fault
    [Documentation]    Short description.
    ${GNCEL_param}    taf.sbts.oam.coam.admin.Get Parameters For All    GNCEL
    ${GNCEL_Info}    set variable    ${GNCEL_param}[0]
    log    ${GNCEL_Info}
    ${GNCEL_ID}    Get From Dictionary    ${GNCEL_Info}    id
    #${Value}    Get Dictionary Values    ${GNCEL_Info}
    #${GNCEL_ID}    set variable    ${Value}[3]
    ${GNCEL_blocked}    Run keyword and return status    taf.sbts.oam.coam.admin.Block    ${GNCEL_ID}    timeout=300
    sleep    20s
    Log  Check if fault 49 appeared  console=${TRUE}
    ${expected_alarms}=    Create Dictionary    faultId=49    severity=Critical
    ${expected_patterns}=    Create List    ${expected_alarms}
    ${critical_alarms}=    Create Dictionary    severity=Critical
    ${critical_patterns}=    Create List    ${critical_alarms}
    ${alarms_status}    ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...    expected_patterns=${expected_patterns}    critical_patterns=${critical_patterns}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...    Fail    Failed at expected alarms:${expected_alarms} critical alarms: ${critical_alarms} ignored alarms:${ignored_alarms}
    Run keyword if    ${alarms_return}    Set Test Restriction    Minor alarm found.

Step4: Start SW update with activation
    [Documentation]    Short description.
    Log Step Header  step4: SW update with activation
    Log  Will now perform software update  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_PATH}  True  ${UPDATE_TIMEOUT}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software activation failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable
    ...  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable
    ...  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available
    Wait until keyword succeeds  5 min  10 sec  Fail if connection to infomodel is not available

Step5: Faults verification
    [Documentation]    Short description.
    Log Step Header  Step5: Faults verification
    Log  Check if fault 49 disappeared  console=${TRUE}
    ${expected_alarms}=    Create Dictionary    faultId=49    severity=Critical
    ${expected_patterns}=    Create List    ${expected_alarms}
    ${critical_alarms}=    Create Dictionary    severity=Critical
    ${critical_patterns}=    Create List    ${critical_alarms}
    ${Fault_status}=  Run keyword and return status  Admin Check Active Alarms
    ...  expected_patterns=${expected_patterns}    critical_patterns=${critical_patterns}
    run keyword if  ${Fault_status}==${FALSE}
    ...  Log Important Message  Fault 49 is disappeared.
    ...  ELSE
    ...  fail  Fault 49 still exist

Step6: Check if reset is not performed
    [Documentation]    Short description.
    Log Step Header  Step6: Check if reset is not performed
    Log  Check if BTS is stable for 5 min  console=${TRUE}
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=0  timeout=301
    Log  Reset nor performed. BTS is stable for 5 min.  console=${TRUE}

Step7: Check if BTS is onAir
    [Documentation]    Short description.
    Log Step Header    Step5: Check if BTS is onAir
    Wait until keyword succeeds    ${BTS_ONAIR_TIMEOUT} min    30 sec    Check SBTS SOAM cells and modules
    Check SOAM Active Alarms

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Fail if connection to infomodel is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    ${infomodel_reset_status}  Run keyword and return status  ute_admin_infomodel.Reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    Fail  ${infomodel_reset_status}
