*** Settings ***
Documentation
    ...  Main purpose of TC is checking consistant fallback functionality of SBTS SW triggered by RLC method
    ...  Way of fallback: from SBTS17 to FDSW

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${PING_REGAIN_TIMEOUT}  240  # Timeout for ping regain during reset
${MAX_DOWNTIME}  360  # Max time without ping for 'Check If Target Is Stable'
${FALLBACK_TIMEOUT}  300  # Timeout after software fallback


*** Keywords ***
TC__COMPA__SBTS_SOAM_fallback_to_FDSW_RLC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5322
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-5322 - initial creation
    ...  - 18.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6774 - Changes resources path, and ute_infomodel keywords to ute_admin
    ...  - 14.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7228 - SSH Check, Rel4 support, name change
    ...  - 27.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-8124 - Added hran compa setup
    ...  - 01.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9274 - Name changed, ACTIVE/PASSIVE_SW_PATTERN variable removed
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17757 - Teardown All Aliases For Admin added in step4
    ...  - 18.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18602 - Add support for Rescue Console ( >=FDSW18SP)
    ...  - 15.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-18723 - Add KW 'Verify SSH connection and enable if necessary' in Step4
    ...  - 02.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19255 - Add KW 'Wait For Target To Be Reachable' after fallback
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24252 - Remove ute_btssm library and check FDSW version
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 09.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29214 - Watchdog disabled
    ...  - 13.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29303 - Fix RC connection
    ...  - 04.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29664 - Add timeout after software fallback to control the time after sbts reboot
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5322.png

    Set Tags  CA-COMPA  OWNER-daniel.cozma@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  AUTHOR-jaroslaw.piszczala@nokia.com  PHASE-COMPA  PHASE-CRT
    ...  SW-SBTS17  SW-SBTS18  SW-SBTS19  SW-SBTS20  SW-FDSW  FEATURE-RP001145_1SB_FD20  FEATURE-RP001486_1SB_FC66

    Step0: Suite Configuration
    Step1: Check Active And Passive Sw Version
    Step2: Software Fallback
    Step3: Wait Till BTS Is Stable
    Step4: Check Software Version


Step0: Suite Configuration
    Log Step Header  Step0: Suite configuration
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Set Global Variable  ${ACTIVE_SW_PATTERN}  SBTS
    Set Global Variable  ${PASSIVE_SW_PATTERN}  FDSW
    Verify SSH Connection And Enable If Necessary


Step1: Check Active And Passive Sw Version
    Log Step Header  Step1: Check active and passive sw version
    ${active_sw_before}  ${passive_sw_before}  Infomodel Get SW Versions
    Set Tags For Software  SW_BEFORE_FALLBACK  ${active_sw_before}  ${passive_sw_before}
    Check If Software Match Software Pattern  ${active_sw_before}  ${ACTIVE_SW_PATTERN}
    Check If Software Match Software Pattern  ${passive_sw_before}  ${PASSIVE_SW_PATTERN}
    ${sw_match}  Get Regexp Matches  ${passive_sw_before}  FDSW(...)  1
    IF  '${sw_match}[0]'<'18'  Fail  Software is not compatible.


Step2: Software Fallback
    Log Step Header  Step2: Software fallback
    Connect To SMOD  ${SMOD1['TRS_IP']}
    ${sm_variant}  Get SM Variant
    Software Fallback  ${sm_variant[0]}


Step3: Wait Till BTS Is Stable
    Log Step Header  Step3: Wait till BTS is stable
    Sleep  ${FALLBACK_TIMEOUT}s
    Log  Will wait for target to be reachable  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Ping has been regained within timeout ${PING_REGAIN_TIMEOUT} s  console=true
    ELSE
      Fail  Ping has not been regained within timeout ${PING_REGAIN_TIMEOUT} s
    END
    Log  Check if BTS is stable  console=true
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=${MAX_DOWNTIME}  timeout=2100
    IF  ${ping_status}
      Log To Console With Time  BTS is stable after fallback
    ELSE
      FAIL  BTS is not stable after fallback.
    END


Step4: Check Software Version
    Log Step Header  Step4: Check software version
    Verify SSH Connection And Enable If Necessary
    Run Keyword And Ignore Error
    ...  Teardown All Aliases For Admin
    Set Test Variable  ${ADMIN_STARTED}  ${FALSE}
    ${active_sw_after}  ${passive_sw_after}  Get Active And Passive SW Version From Rescue Console
    Set Tags  SW_AFTER_FALLBACK_active-${active_sw_after}
    Set Tags  SW_AFTER_FALLBACK_passive-${passive_sw_after}
    Check If Software Match Software Pattern  ${active_sw_after}  ${PASSIVE_SW_PATTERN}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup


TC Teardown
    Common Test Teardown
