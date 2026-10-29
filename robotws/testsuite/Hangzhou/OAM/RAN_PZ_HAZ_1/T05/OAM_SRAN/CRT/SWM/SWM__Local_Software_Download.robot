*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Library    Collections
#Library    hran_file_operations


*** Variables ***
${Target SW name}       ${None}                      # SW package name. If not given, TC will choose newest package in a directory.
${Target SW dir}        /home/ute/btsauto/TARGET_SW  # Directory for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW Download Timeout}  1800                          # Given in seconds; That is a timeout for SW download and activation (without reset)
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)


*** Keywords ***
TC__SWM__Local_Software_Download
        [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7167
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC should perform software download without activation.
    ...  After that BTS state shall be verified.
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 08.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-7167 - Initial creation
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 10.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17435 - swpackage_search_status comparison changed from True to PASS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_Download_TAT-7167.png#
    ...

    Set Tags    CA-SWM    PHASE-CIT    OWNER-kamil.osak@nokia.com    AUTHOR-sebastian.burniak@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com    GROUP_IN_CHARGE-WRO_7_Vrf    SW-SBTS17    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP001486_RP000938    FEATURE-RP001145_RP000938    FEATURE-RP001809    FEATURE-RP002035
    ...    FEATURE-RP001966    FEATURE-RP002179

    Set R&D flag to debug enable
    step1: Find path to SW package
    step2: Check SW versions before sw download
    step3: SW download
    step4: Check sw versions after sw download and verify them
    step5: Check BTS State
    Check software download progress is complete
    Recover BTS

step1: Find path to SW package
    [Documentation]    Short description.
    Log Step Header  step1: Find path to SW package
    ${swpackage_search_status}  ${Target SW path}=  Run keyword and ignore error  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run keyword if    not '${swpackage_search_status}'=='PASS'  Set test norun  SW package search failed
    Run Keyword If  '${Target SW path}'== ${None}   Set test norun  No sw package available
    Set test variable  ${Target SW path}
    ${Chosen SW Release Name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${Target SW path}
    Set test variable  ${Chosen SW Release Name}
    Log  Chosen software package is: ${Chosen SW Release Name}  console=${TRUE}

step2: Check SW versions before sw download
    [Documentation]    Short description.
    Log Step Header  step2: Check SW versions
    ${Active SW before}   Infomodel Get Active SW Version
    ${Passive SW before}  Infomodel Get Passive SW Version
    ${Planned SW before}  Infomodel Get Planned SW Version
    Set test variable  ${Active SW before}
    Set test variable  ${Passive SW before}
    Set test variable  ${Planned SW before}
    Log  Active software package is: ${Active SW before}  console=${TRUE}
    Log  Passive software package is: ${Passive SW before}  console=${TRUE}
    Log  Planned software package is: ${Planned SW before}  console=${TRUE}

step3: SW download
    [Documentation]    Short description.
    Log Step Header  step3: SW download
    Log  Will now perform software download  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  False  ${SW Download Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software download failed: ${sw_update_msg}

step4: Check sw versions after sw download and verify them
    [Documentation]    Short description.
    Log Step Header  step4: Check sw versions after sw download and verify them
    ${Active SW after}   Infomodel Get Active SW Version
    ${Passive SW after}  Infomodel Get Passive SW Version
    ${Planned SW after}  Infomodel Get Planned SW Version
    Log  Active software package is: ${Active SW after}, expected: ${Active SW before}  console=${TRUE}
    Log  Passive software package is: ${Passive SW after}, expected: ${Passive SW before}  console=${TRUE}
    Log  Planned software package is: ${Planned SW after}, expected: ${Chosen SW Release Name}  console=${TRUE}

    ${Active_sw_check_status}  Run keyword and return status  Should be equal as strings  ${Active SW before}  ${Active SW after}
    ${Passive_sw_check_status}  Run keyword and return status  Should be equal as strings  ${Passive SW before}  ${Passive SW after}
    ${Planned sw check status}  Run keyword and return status  Should Match Regexp  ${Chosen SW Release Name}  (?i).*${Planned SW after}(?!T[12]).*
    Run keyword if    not ${Active sw check status}  Set Test Failed  Active software has a unexpected value
    Run keyword if    not ${Passive sw check status}  Set Test Failed  Passive software has a unexpected value
    Run keyword if    not ${Planned sw check status}  Set Test Failed  Planned software has a unexpected value

step5: Check BTS State
    [Documentation]    Short description.
    Log Step Header  step5: Check BTS State
    ${bts_proceduralStatus_onAir}  Verify BTS proceduralState  OnAir
    ${modules_working}  Verify modules states
    ${cells_GSM_onair}  Verify GSM cells states
    ${cells_WCDMA_onair}  Verify WCDMA cells states
    ${cells_LTE_onair}  Verify LTE cells states

    Run keyword if    not ${bts_proceduralStatus_onAir} and ${modules_working} and ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}
    ...  Set Test Failed  BTS status verification failed

    ${alarm_check}  Run keyword and return status  Admin Check Active Alarms
    Run Keyword If  ${alarm_check}  Set Test Restriction  Unexpected alarms are present

Check software download progress is complete
    [Documentation]    Short description.
    ${syslog_path}=  Run   ls -lt /tmp/btslog2/SYSLOG_SMOD1_UDP_* | head -n 1 | awk '{print $9}'
    Run     cp ${syslog_path} /tmp/enb_syslog_syslog.log
    Sleep  5
#    Analysis_process_indicator_from_syslog
    ${string}=  Run   grep 'endSwDownload(): isDone=1, isFail=0' /tmp/enb_syslog_syslog.log
    Log  ${string}
    ${string}=  Run   grep 'endSwDownload(): update download progress to 100 after successful of download.' /tmp/enb_syslog_syslog.log
    Log  ${string}
    Run     rm -rf /tmp/enb_syslog_syslog.log

Set R&D flag to debug enable
    [Documentation]    Short description.
    Log Step Header  Set R&D flag to debug enable
    set test variable  ${SWCONFIG_FLAGS1}  0x1003F=1
    set test variable  ${SWCONFIG_FLAGS2}  0x10040=1
    ${SWCONFIG_FLAGS}  create list  ${SWCONFIG_FLAGS1}  ${SWCONFIG_FLAGS2}
    set test variable  ${SWCONFIG_FLAGS}
    Add Swconfig Flags  ${SWCONFIG_FLAGS}
    Reset testline

Add Swconfig Flags
    [Documentation]  Adds swconfig flags from passed list, and performs reset.
    [Arguments]  ${flag_list}
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    Run Remote Linux Command  cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt_ori
    Run Remote Linux Command  echo ' ' >> /ffs/run/swconfig.txt
    FOR  ${FLAG}  IN  @{flag_list}
      Run Remote Linux Command    echo ${FLAG} >> /ffs/run/swconfig.txt
      log to console with time  Added flag:${FLAG}
    END

Reset testline
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.run keyword in background  Reset  timeout=300
    log to console with time  Check if reset is performed
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    log to console with time  Reset completed. Waiting for eNB to be pingable...
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for reset  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after Reset
    Log  BTS is stable after Reset.  console=${TRUE}

Recover BTS
    [Documentation]    Short description.
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    Run Remote Linux Command  mv /ffs/run/swconfig.txt_ori /ffs/run/swconfig.txt
    Reset testline
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states
