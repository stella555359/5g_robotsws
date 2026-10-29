*** Settings ***
Documentation
    ...  Main purpose of TC is checking rollback functionality of SBTS SW
    ...  Way of rollback: from SBTS SOAM to FDSW

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${MAX_DOWNTIME_TIMEOUT}  300  # maximum time in seconds that BTS can continuously be unavailable after rollback
# cannot be longer than timeout for whole KW - min_uptime (1200-300= 900 second)


*** Keywords ***
TC__COMPA__SBTS_SOAM_rollback_to_FDSW
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5048
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5048 - initial creation
    ...  - 18.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-6774 - Changes resources path, and ute_infomodel keywords to ute_admin
    ...  - 01.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9274 - Name changed, ACTIVE/PASSIVE_SW_PATTERN variable removed
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17757 - Teardown All Aliases For Admin added in step4
    ...  - 17.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18382 - Add support for Rescue Console ( >=FDSW18SP)
    ...  - 08.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18720 - Copy variable max_downtime from Step3 {max_downtime_timeout) to Variables
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24252 - Remove ute_btssm library and check FDSW version
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5048.png

    Set Tags  CA-COMPA  CA_SWM  OWNER-daniel.cozma@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  AUTHOR-jaroslaw.piszczala@nokia.com  PHASE-COMPA
    ...  PHASE-CRT  SW-SBTS17  SW-SBTS18  SW-SBTS19  SW-FDSW  FEATURE-RP000912  FEATURE-RP001145_1SB_FD20  FEATURE-RP001486_1SB_FC66

    Step1: Check Active And Passive Sw Version
    Step2: Software Rollback
    Step3: Wait Till BTS Is Stable
    Step4: Check Software Version


Step1: Check Active And Passive Sw Version
    Log Step Header  Step1: Check active and passive sw version
    Set Global Variable  ${ACTIVE_SW_PATTERN}  SBTS
    Set Global Variable  ${PASSIVE_SW_PATTERN}  FDSW
    ${active_sw_before}  ${passive_sw_before}  Infomodel Get SW Versions
    Set Tags For Software  SW_BEFORE_ROLLBACK  ${active_sw_before}  ${passive_sw_before}
    Check If Software Match Software Pattern  ${active_sw_before}  ${ACTIVE_SW_PATTERN}
    Check If Software Match Software Pattern  ${passive_sw_before}  ${PASSIVE_SW_PATTERN}
    ${sw_match}  Get Regexp Matches  ${passive_sw_before}  FDSW(...)  1
    Run Keyword If  '${sw_match}[0]'<'18'
    ...  Fail  Software is not compatible.


Step2: Software Rollback
    Log Step Header  Step2: Software rollback
    ${rollback_status}  Run Keyword And Return Status
    ...  Rollback Software
    Run Keyword If  ${rollback_status}
    ...  Log To Console With Time  Software rollback ended successfully
    ...  ELSE
    ...  FAIL  Software rollback was not performed.


Step3: Wait Till BTS Is Stable
    Log Step Header  Step3: Wait till BTS is stable
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=${MAX_DOWNTIME_TIMEOUT}  timeout=1200
    Run Keyword If  ${ping_status}
    ...  Log To Console With Time  BTS is stable after rollback
    ...  ELSE
    ...  FAIL  BTS is not stable after rollback.


Step4: Check Software Version
    Log Step Header  Step4: Check software version
    Run Keyword And Ignore Error
    ...  Teardown All Aliases For Admin
    Set Test Variable  ${ADMIN_STARTED}  ${FALSE}
    ${active_sw_after}  ${passive_sw_after}  Get Active And Passive SW Version From Rescue Console
    Set Tags For Software  SW_BEFORE_ROLLBACK  ${active_sw_after}  ${passive_sw_after}
    Check If Software Match Software Pattern  ${active_sw_after}  ${PASSIVE_SW_PATTERN}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
