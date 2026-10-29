*** Settings ***
Documentation  Tests for dedicated_storage_device_during_startup

Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/infomodel.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/verdicts.robot
Library    SSHLibrary


*** Keywords ***
TC__LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24715
    ...  ******************
    ...  Author: Stepan Radysh
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.01.2023 - TAT-24715 - TC created, version 1.0
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 28.07.2023 - TAT-25859 - Determine variant of MSM and adjust SSH command and variables accordingly, change test variables to all caps
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This Test Case check if folder /logs are mounted to dedicated storage device in supported HW
    ...  (list of supported HW is specified in requirement BTS_E2E_TRBL_870.)
    ...  Supported HW: ASIB(A102 and newest HW variants), ASIL, ASOE, ASIM.
    ...  *******************
    ...  Test case flowchart:  flowchart will be added untill 08.03.23
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-stepan.radysh@okia.com    MAINTAINER-stepan.radysh@okia.com
    ...    GROUP_IN_CHARGE-WRO_5_Vrf    PHASE-CRT    SW-SBTS23R2    FEATURE-CB008390-A

    Step 0: Preconditions
    Step 1: Connect via ssh
    Step 2: Check /ffs/run/logs mounted to dedicated storage device and permission control
    Step 3: Compare values

Step 0: Preconditions
    [Documentation]
    ...  Settting variables for connecting to BTS via SSH
    ...  Setting variables for execute commands via SSH

    Log    \nStep 0: Preconditions   console=${True}
    Set Test Variable  ${IP}  192.168.255.129
    Set Test Variable  ${CHECK_PREMISSION_CONTROL}  ls -la /ffs/run/ | grep logs
    Set Test Variable  ${PASSWORD}  oZPS0POrRieRtu
    Set Test Variable  ${USER_NAME}  toor4nsn
    Decide if MSM is ASIB ASOE ASIL ASOH ASOG or ASIM and use respective KW for setting variables

Decide if MSM is ASIB ASOE ASIL ASOH ASOG or ASIM and use respective KW for setting variables
    [Documentation]    Sets variables which depend on variant of master SM
    ${sm_variant}=    Get SM variant
    Run Keyword If    '${sm_variant}' == 'ASIB' or '${sm_variant}' == 'ASOE' or '${sm_variant}' == 'ASIL'  Case ASIB ASOE or ASIL
            ...    ELSE IF    '${sm_variant}' == 'ASIM'   Case ASIM
            ...    ELSE IF  '${sm_variant}' == 'ASOH AirScale Core'   Case ASOH
            ...    ELSE IF  '${sm_variant}' == 'ASOG AirScale Core'   Case ASOG
            ...    ELSE    Fail

Case ASOH
    [Documentation]    Sets variables for ASOH
    Set Test Variable  ${CHECK_SYSINFO}  zcat /var/log/sysinfo.gz | head && lsblk /dev/mmcblk0 -o NAME,SIZE,TYPE,PARTLABEL,MOUNTPOINT | grep mmcblk0p7
    Set Test Variable  ${PARTITION_NAME}  mmcblk0p7
    Set Test Variable  ${PARTITION_SIZE}  2.1G

Case ASOG
    [Documentation]    Sets variables for ASOH
    Set Test Variable  ${CHECK_SYSINFO}  zcat /var/log/sysinfo.gz | head && lsblk /dev/mmcblk0 -o NAME,SIZE,TYPE,PARTLABEL,MOUNTPOINT | grep mmcblk0p7
    Set Test Variable  ${PARTITION_NAME}  mmcblk0p7
    Set Test Variable  ${PARTITION_SIZE}  2.1G

Case ASIB ASOE or ASIL
    [Documentation]    Sets variables for ASIB ASOE or ASIL master SM
    Set Test Variable  ${CHECK_SYSINFO}  zcat /var/log/sysinfo.gz | head && lsblk /dev/sda -o NAME,SIZE,TYPE,PARTLABEL,MOUNTPOINT | grep sda7
    Set Test Variable  ${PARTITION_NAME}  sda7
    Set Test Variable  ${PARTITION_SIZE}  1000M

Case ASIM
    [Documentation]    Sets variables for ASIM master SM
    Set Test Variable  ${CHECK_SYSINFO}  zcat /var/log/sysinfo.gz | head && lsblk /dev/mmcblk0 -o NAME,SIZE,TYPE,PARTLABEL,MOUNTPOINT | grep mmcblk0p7
    Set Test Variable  ${PARTITION_NAME}  mmcblk0p7
    Set Test Variable  ${PARTITION_SIZE}  1.2G

Get SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is primary core, second (if exist) - secondary core
    ...
    ...  | **Author:** iuliia.taupeka@nokia.com
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (ASIB|ASOE|ASIL|ASIM|ASOH AirScale Core|ASOG AirScale Core)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant[0]}

Step 1: Connect via ssh
    [Documentation]
    ...    Connect via SSH and execute required commands

    Log    \nStep 1: Connect via ssh   console=${True}
    SSHLibrary.Open Connection    ${IP}
    SSHLibrary.Login    ${USER_NAME}    ${PASSWORD}
    ${DEDICATED_DEVICE}    SSHLibrary.Execute Command  ${CHECK_SYSINFO}
    Log    ${DEDICATED_DEVICE}    console=${True}
    Set Test Variable    ${DEDICATED_DEVICE}
    ${PERMISSION_CONTROL}  SSHLibrary.Execute Command  ${CHECK_PREMISSION_CONTROL}
    SSHLibrary.Close Connection
    Log    ${PERMISSION_CONTROL}    console=${True}
    Set Test Variable    ${PERMISSION_CONTROL}

Step 2: Check /ffs/run/logs mounted to dedicated storage device and permission control
    [Documentation]
    ...    Commands check if folder logs have size, type, moutpoint and permission control

    Log    \nStep 2: Check /ffs/run/logs mounted to dedicated storage device and permission control    console=${True}
    ${dedicated_device_fetched}=    Fetch From Right  ${DEDICATED_DEVICE}  -
    ${DEDICATED_DEVICE_LISTED}    Split String    ${dedicated_device_fetched}
    Set Test Variable    ${DEDICATED_DEVICE_LISTED}
    Log    NAME is ${DEDICATED_DEVICE_LISTED[0]}, \nSIZE is ${DEDICATED_DEVICE_LISTED[1]}, \nMOUNTPOINT is ${DEDICATED_DEVICE_LISTED[-1]}
    ${PERMISSION_CONTROL_LISTED}    Split String    ${PERMISSION_CONTROL}
    Set Test Variable    ${PERMISSION_CONTROL_LISTED}

Step 3: Compare values
    [Documentation]
    ...    Check if folder logs have correct size, type, mountpoin and permission control according to requirement BTS_E2E_TRBL_870

    Log    \nStep 3: Compare values  console=${True}
    Run Keyword If  '${DEDICATED_DEVICE_LISTED[0]}'=='${PARTITION_NAME}'    Log    Name for dedicated partition is correct    console=${True}
    ...  ELSE  verdicts.Set Test Failed  dedicated partition is not ${PARTITION_NAME}.  ${TRUE}
    Run Keyword If  '${DEDICATED_DEVICE_LISTED[1]}'=='${PARTITION_SIZE}'    Log   Size for dedicated partition is correct    console=${True}
    ...  ELSE  verdicts.Set Test Failed  Size is not equal to ${PARTITION_SIZE}.  ${TRUE}
    Run Keyword If  '${DEDICATED_DEVICE_LISTED[-1]}'=='/srv/nfs/ffs:run:logs'    Log    Mountpoint for dedicated partition is correct  console=${True}
    ...  ELSE  verdicts.Set Test Failed  mountpoint is not /srv/nfs/ffs:run:logs.  ${TRUE}
    Run Keyword If  '${PERMISSION_CONTROL_LISTED[0]}'=='drwxrwx--t'    Log    Permission control for folder "logs" is correct    console=${True}
    ...  ELSE  verdicts.Set Test Failed  permission control is not drwxrwx--t.  ${TRUE}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
