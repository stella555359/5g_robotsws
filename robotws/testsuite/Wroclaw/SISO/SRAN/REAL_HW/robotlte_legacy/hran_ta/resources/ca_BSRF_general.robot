*** Settings ***
Documentation  Maintainers: anna.maciejewska@nokia.com, mateusz.kawka@nokia.com

Library    SSHLibrary

#Library    SeleniumLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource   ca_BSRF_radio_operation.robot

*** Variables ***

${GNCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked", usageState=regex"(?i)Active"
${WNCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", usageState=regex"(?i)Active"
${LNCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
${NRCEL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
${DEGRADED_CELL_REGEX}  availabilityStatus=regex"[Dd]egraded"
${DEGRADED_CELL_REGEX_2}  availabilityStatus(.*)[Dd]egraded

*** Keywords ***
Show UE Table
    [Documentation]
    ...  This KW prints data collected from UE as a table.
    ...  KW can gather information in two ways.
    ...  Default is API ( mainly use "Get UE Info KW" )
    ...  The other way is to use ADB output.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW prints data collected from `Get UE Info` keyword as a table.
    ...  | Additionally KW print UE Manager Mobile version.
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To get: version of UE Manager Mobile, airplane mode, mobile data and APN name
    ...  | it is necessary to set up SSH connection(build-in).
    ...  | SSH connection is closing in KW teardown
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | method           | No   | API or ADB method to gather information             |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Show UE Table  9488ee88  method=adb

    [Arguments]  ${ue_serial}  ${method}=api

    ${infos_list}  Create List
    ${formatted_infos_list}  Create List
    ${info_labels_list}  Create List

    Append To List  ${info_labels_list}  Cell ID  IP  APN  Model  Signal strength  Android version
    ...  IMEI  MCC  MNC  LAC  NAA  Mobile data  Airplane mode

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${adb_output}  Run Keyword If  '${method}'=='adb'
    ...  Get Raw ADB Output  ${ue_serial}

    ${status}  ${cell_id}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  CELL_ID  ${adb_output}  ${method}
    ${cell_id}  Set Variable If  '${status}'=='FAIL'  Unknown  ${cell_id}
    Append To list  ${infos_list}  ${cell_id}
    ${status}  ${ip}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  IP  ${adb_output}  ${method}
    ${ip}  Set Variable If  '${status}'=='FAIL'  Unknown  ${ip}
    Append To list  ${infos_list}  ${ip}
    ${apn_name}  Get APN Name From UE  ${ue_serial}
    Append To List  ${infos_list}  ${apn_name}
    ${status}  ${model}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  DEVICE_MODEL  ${adb_output}  ${method}
    ${model}  Set Variable If  '${status}'=='FAIL'  Unknown  ${model}
    Append To list  ${infos_list}  ${model}
    ${status}  ${signal_strength}  Run Keyword And Ignore Error
    ...  Get UE Signal Strength  ${ue_serial}
    ${signal_strength}  Set Variable If  '${status}'=='FAIL'  Unknown  ${signal_strength}
    Append To list  ${infos_list}  ${signal_strength}
    ${status}  ${android_ver}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  ANDROID_VER  ${adb_output}  ${method}
    ${android_ver}  Set Variable If  '${status}'=='FAIL'  Unknown  ${android_ver}
    Append To list  ${infos_list}  ${android_ver}
    ${status}  ${imei}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  IMEI  ${adb_output}  ${method}
    ${imei}  Set Variable If  '${status}'=='FAIL'  Unknown  ${imei}
    Append To list  ${infos_list}  ${imei}
    ${status}  ${mcc}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  MCC  ${adb_output}  ${method}
    ${mcc}  Set Variable If  '${status}'=='FAIL'  Unknown  ${mcc}
    Append To list  ${infos_list}  ${mcc}
    ${status}  ${mnc}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  MNC  ${adb_output}  ${method}
    ${mnc}  Set Variable If  '${status}'=='FAIL'  Unknown  ${mnc}
    Append To list  ${infos_list}  ${mnc}
    ${status}  ${lac}  Run Keyword And Ignore Error
    ...  Get Info From UE  ${ue_serial}  LAC  ${adb_output}  ${method}
    ${lac}  Set Variable If  '${status}'=='FAIL'  Unknown  ${lac}
    Append To list  ${infos_list}  ${lac}

    ${naa_version}  Set Variable  adb -s ${ue_serial} shell dumpsys package com.nokia.android.application | grep versionName
    ${mobile_data_status}  Set Variable  adb -s ${ue_serial} shell settings get global mobile_data
    ${airplane_status}  Set Variable  adb -s ${ue_serial} shell settings get global airplane_mode_on
    ${naa_version_raw}  sshLibrary.Execute Command  ${naa_version}
    ${mobile_data_raw}  sshLibrary.Execute Command  ${mobile_data_status}
    ${airplane_mode_raw}  sshLibrary.Execute Command  ${airplane_status}
    ${naa_version_raw}  Convert To String  ${naa_version_raw}
    ${naa_version_raw}  Replace String  ${naa_version_raw}  \r  ${EMPTY}
    ${naa_version_raw}  Replace String  ${naa_version_raw}  ${SPACE}  ${EMPTY}
    ${status}  ${naa_version}  Run Keyword And Ignore Error  Evaluate  '${naa_version_raw}'.split('=')[1]
    ${naa_version}  Set Variable If  '${status}'=='FAIL'  Unavailable  ${naa_version}
    ${mobile_data_raw}  Convert To String  ${mobile_data_raw}
    ${mobile_data_raw}  Replace String  ${mobile_data_raw}  \r  ${EMPTY}
    ${mobile_data}  Set Variable If  '${mobile_data_raw}'=='1'  Enabled  Disabled
    ${airplane_mode_raw}  Convert To String  ${airplane_mode_raw}
    ${airplane_mode_raw}  Replace String  ${airplane_mode_raw}  \r  ${EMPTY}
    ${airplane_mode}  Set Variable If  '${airplane_mode_raw}'=='0'  Off  On

    Append To List  ${infos_list}  ${naa_version}
    Append To List  ${infos_list}  ${mobile_data}
    Append To List  ${infos_list}  ${airplane_mode}

    FOR  ${info}  ${label}  IN ZIP  ${infos_list}  ${info_labels_list}
        ${spaces}          Evaluate  int(16-len(str('${label}')))
        ${formatted_info}  Evaluate  ' '*${spaces} + '| ' + str('${info}')
        Append To List  ${formatted_infos_list}  ${formatted_info}
    END

    Log to console  ${\n}*********** < ${ue_serial} > ***********
    Log to console  Cell ID ${formatted_infos_list}[0]
    Log to console  IP ${formatted_infos_list}[1]
    Log to console  APN ${formatted_infos_list}[2]
    Log to console  Model ${formatted_infos_list}[3]
    Log to console  Signal strength ${formatted_infos_list}[4]
    Log to console  Android version ${formatted_infos_list}[5]
    Log to console  IMEI ${formatted_infos_list}[6]
    Log to console  MCC ${formatted_infos_list}[7]
    Log to console  MNC ${formatted_infos_list}[8]
    Log to console  LAC ${formatted_infos_list}[9]
    Log to console  NAA ${formatted_infos_list}[10]
    Log to console  Mobile data ${formatted_infos_list}[11]
    Log to console  Airplane mode ${formatted_infos_list}[12]${\n}

    [Teardown]  sshlibrary.Close Connection

Get Info From UE
    [Documentation]
    ...  KW is used to choose wheter to use API or ADB method
    ...  to get specific information from UE
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${ue_serial}  ${info}  ${adb_output}  ${method}

    ${info}  Run Keyword If  '${method}'=='api'
    ...  Get UE Info  ${ue_serial}  ${info}
    ...  ELSE
    ...  Get Adb UE Info  ${info}  ${adb_output}

    [Return]  ${info}

Get Raw ADB Output
    [Documentation]
    ...  KW gets UE info output via adb
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | Information contained in the output:
    ...  | Cell ID, IP address, MNC, MCC
    ...  | LAC, Android version and IMEI
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To get UE information, it is necessary to set up SSH connection (build-in KW).
    ...  | Connection may be set earlier in test, so optional parameter `ssh_connect` is given
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | ssh_connect      | No   | Set "True" to make new ssh connection               |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get Raw ADB Output  9488ee88  ssh_connect=True

    [Arguments]  ${ue_serial}  ${ssh_connect}=False

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Run Keyword If  '${ssh_connect}'=='True'  Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${naa_info_cmd}  Set Variable
    ...  adb -s ${ue_serial} logcat -d | grep "all cell info" | tail -1
    ${ip_address_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell ip route | awk '{print $9}'
    ${imei_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell service call iphonesubinfo 1 | awk -F "'" '{print $2}' | sed '1 d' | tr -d '.' | awk '{print}' ORS=
    ${device_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell getprop | grep -E 'ro.product.model|ro.build.version.release'

    ${adb_output_2}  sshLibrary.Execute Command  ${ip_address_cmd}
    ${adb_output_3}  sshLibrary.Execute Command  ${imei_cmd}
    ${adb_output_4}  sshLibrary.Execute Command  ${device_cmd}

    FOR  ${i}  IN RANGE  3
        ${adb_output}    sshLibrary.Execute Command  ${naa_info_cmd}
        ${status}  Run Keyword And Return Status  Should Not Be Empty  ${adb_output}
        Exit For Loop If  '${status}'=='True'
    END

    ${adb_output}  Catenate  ${adb_output}  ${adb_output_2}  ${adb_output_3}  ${adb_output_4}
    ${adb_output}  Replace String Using Regexp  ${adb_output}  \\r|\\n|adb  ${EMPTY}

    Run Keyword If  '${ssh_connect}'=='True'  sshlibrary.Close Connection

    [Return]  ${adb_output}

Get ADB Ue Info
    [Documentation]
    ...  KW gets specific UE info from ADB output
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW gets specific information from UE based on ADB output.
    ...  | ADB output must be gather with KW "Get Raw ADB Output".
    ...  | KW works by extracting info from raw adb string using regex.
    ...  | Possible UE Info passed as `ue_info` argument:
    ...  | CELL_ID, LAC, MCC, MNC, IMEI, DEVICE_MODEL, ANDROID_VER
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To get UE information, it is necessary to set up SSH connection (build-in KW).
    ...  | Connection may be set earlier in test, so optional parameter `ssh_connect` is given
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_info          | Yes  | Specifiec info to be extracted                      |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | adb_output       | Yes  | Output from KW "Get Raw ADB Output"                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get ADB Ue Info  CELL_ID  raw_output

    [Arguments]  ${ue_info}  ${adb_output}

    ${info}  Run Keyword If  '${ue_info}'=='CELL_ID'
    ...  Evaluate  re.search(r'(?:(?<=cid=)|(?<=ci=))\\d+', '${adb_output}').group(0)  re
    ...  ELSE IF   '${ue_info}'=='IP'
    ...  Evaluate  re.search(r'\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}', '${adb_output}').group(0)  re
    ...  ELSE IF  ('${ue_info}'=='LAC') or ('${ue_info}'=='TAC')
    ...  Evaluate  re.search(r'(?:(?<=lac=)|(?<=tac=))\\d+', '${adb_output}').group(0)  re
    ...  ELSE IF  '${ue_info}'=='MCC'
    ...  Evaluate  re.search(r'(?<=mccString=)\\d+', '${adb_output}').group(0)  re
    ...  ELSE IF  '${ue_info}'=='MNC'
    ...  Evaluate  re.search(r'(?<=mncString=)\\d+', '${adb_output}').group(0)  re
    ...  ELSE IF  '${ue_info}'=='IMEI'
    ...  Evaluate  re.search(r'[0-9]{15}', '${adb_output}').group(0)  re
    ...  ELSE IF  '${ue_info}'=='DEVICE_MODEL'
    ...  Evaluate  re.search(r'(?<=SM-)[\\w]+', '${adb_output}').group(0)  re
    ...  ELSE IF  '${ue_info}'=='ANDROID_VER'
    ...  Evaluate  re.search(r'(?<=\\[)\\d{1}\\.\\d{1}\\.\\d{1}', '${adb_output}').group(0)  re

    [Return]  ${info}

Get UE Signal Strength
    [Documentation]
    ...  KW returns signal strength for UE
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW returns signal strength based on ADB output.
    ...  | Signal strength depends on the technology to which cell is attached.
    ...  | For LTE RSSI signal value is given directly from adb
    ...  | For WCDMA and GSM value is calculated based on ASU level.
    ...  | To get UE information, it is necessary to set up SSH connection (build-in KW).
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get UE Signal Strength  9488ee88

    [Arguments]  ${ue_serial}

    ${network_type_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell getprop gsm.network.type | awk -F"," '{print $1}' | sed 's/\r//g'
    ${network_type}  sshLibrary.Execute Command  ${network_type_cmd}
    Return From Keyword If  '${network_type}'=='Unknown'  Unknown
    ${nr}  Set Variable If  'LTE' in '${network_type}'  10  2

    ${signal_strength_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell dumpsys telephony.registry | grep -i -m1 signalstrength | awk '{print $${nr}}'

    ${adb_output}  sshLibrary.Execute Command  ${signal_strength_cmd}

    ${signal_strength}  Run Keyword If  '${nr}'=='2'  Evaluate  int(${adb_output})*2-113
    ...  ELSE  Set Variable  ${adb_output}

    [Return]  ${signal_strength}

Restart Nokia Android Application
    [Documentation]
    ...  This KW restarts UE Manager on UE.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW restarts NAA app on UE.
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To restart NAA app, it is necessary to set up SSH connection (build-in KW).
    ...  | SSH connection is closing in KW teardown
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Restart Nokia Android Application  9488ee88

    [Arguments]  ${ue_serial}

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${naa_force_stop}  Set Variable  adb -s ${ue_serial} shell am force-stop com.nokia.android.application
    ${naa_start}  Set Variable  adb -s ${ue_serial} shell am start -n com.nokia.android.application/.NaaActivity
    ${naa_enable}  Set Variable  adb -s ${ue_serial} shell su -c pm enable com.nokia.android.application

    ${stop_output}  sshLibrary.Execute Command  ${naa_force_stop}
    Sleep  3s

    FOR  ${i}  IN RANGE  5
        ${start_output}  ${rc}  sshLibrary.Execute Command  ${naa_start}  return_rc=True
        ${start_output}  Replace String Using Regexp  ${start_output}  \\r|\\n  ${EMPTY}
        Sleep  10s
        Run Keyword If  'not exist' in '${start_output}'  Run Keywords
        ...  sshLibrary.Execute Command  ${naa_enable}
        ...  AND  Continue For Loop
        Continue For Loop If  ${rc}!=0
        ${status}  Run Keyword And Return Status  Should Contain  ${start_output}  Starting
        Exit For Loop If  '${status}'=='True'
    END

    [Teardown]  sshlibrary.Close Connection

Reboot UE
    [Documentation]
    ...  This KW reboots UE by ADB
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW reboots UE by ADB command.
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To reboot UE, it is necessary to set up SSH connection (build-in KW).
    ...  | SSH connection is closing in KW teardown
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Reboot UE  9488ee88

    [Arguments]  ${ue_serial}

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${reboot_cmd}  Set Variable  adb -s ${ue_serial} reboot
    sshLibrary.Execute Command  ${reboot_cmd}
    Sleep  60s

    [Teardown]  sshlibrary.Close Connection

Make Data Transfer

    [Documentation]
    ...  This KW performs downlink and uplink data transfer and verifies if the value is within the range.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  Perform uplink and downlink data transfer between UE and FTP to measure the throughput.
    ...  Average throughput achieved during the data transfer is then compared with the provided values for
    ...  lower and upper limit of expected throughput.
    ...
    ...  If the value is within this range of accepted values, keyword succeeds.
    ...  If the value is outside this range -- either below the lower or above the upper limit, keyword fails.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | Parameters    | Man. | Description                                                                 |
    ...  +===============+======+=============================================================================+
    ...  | ue_serial     | Yes  | UE serial as visible in adb devices command's output.                       |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | duration      | Yes  | Duration that defines for how long the data transfer should be executed.    |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | protocol      | Yes  | | Defines the protocol over which the transfer will be executed.            |
    ...  |               |      | | Expected values: tcp or udp.                                              |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | ftp_label     | Yes  | | ftp on which data transfer will be perform                                |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | bandwidth     | Yes  | | Applies only to data transfers performed over udp,                        |
    ...  |               |      | | defines the bandwidth for iperf client.'bits/sec','Kbits/sec",'Mbits/sec' |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | dl_max        | Yes  | | Upper limit expressed in bits for the expected average throughput         |
    ...  |               |      | | achieved during downlink data transfer.'bits/sec','Kbits/sec",'Mbits/sec' |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | dl_min        | Yes  | | Lower limit expressed in bits for the expected average throughput         |
    ...  |               |      | | achieved during downlink data transfer.'bits/sec','Kbits/sec",'Mbits/sec' |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | ul_max        | Yes  | | Upper limit expressed in bits for the expected average throughput         |
    ...  |               |      | | achieved during uplink data transfer.'bits/sec','Kbits/sec",'Mbits/sec'   |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | ul_min        | Yes  | | Lower limit expressed in bits for the expected average throughput         |
    ...  |               |      | | achieved during uplink data transfer.'bits/sec','Kbits/sec",'Mbits/sec'   |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Make PS call  5478cdf  20s  udp  FTP_1  22Mbits/sec  21Mbits/sec  16Mbits/sec  6.8Mbits/sec  3Mbits/sec



    [Arguments]  ${ue_serial}  ${duration}  ${protocol}  ${ftp_label}  ${bandwidth}  ${dl_max}  ${dl_min}  ${ul_max}  ${ul_min}

    Log To Console  Starting Downlink Data Transfer via ${ftp_label}, please wait !${\n}
    Start Data Transfer  DT1  ${ue_serial}  DL  duration=${duration}  throughput=${bandwidth}  protocol=${protocol}  app_server=${ftp_label}
    #Check Data Transfer Is Alive  DT1
    Run Keyword And Ignore Error  Await Data Transfer Finish  DT1
    Log To Console  Stopping and calculating Downlink Data Transfer !${\n}
    ${DL_status}  ${DL_verif}  Run Keyword And Ignore Error  Verify Average Throughput  DT1  ${dl_min}  ${dl_max}
    Run Keyword If  '${DL_status}'=='FAIL'  Run Keyword And Continue On Failure  Fail  ${DL_verif}${\n}
    ...  ELSE IF  '${DL_status}'=='PASS'  Log To Console  Average Downlink Throughput is in desired range: ${dl_min} <-> ${dl_max}${\n}
    Log To Console  Starting Uplink Data Transfer via ${ftp_label}, please wait !${\n}
    Start Data Transfer  UT1  ${ue_serial}  UL  duration=${duration}  throughput=${bandwidth}  app_server=${ftp_label}
    #Check Data Transfer Is Alive  UT1
    Run Keyword And Ignore Error  Await Data Transfer Finish  UT1
    Log To Console  Stopping and calculating Uplink Data Transfer !${\n}
    ${UL_status}  ${UL_verif}  Run Keyword And Ignore Error  Verify Average Throughput  UT1  ${ul_min}  ${ul_max}
    Run Keyword If  '${UL_status}'=='FAIL'  Run Keyword And Continue On Failure  Fail  ${UL_verif}${\n}
    ...  ELSE IF  '${UL_status}'=='PASS'  Log To Console  Average Uplink Throughput is in desired range: ${ul_min} <-> ${ul_max}${\n}


Recover UEs
    [Documentation]
    ...  Recover UE by turning airplane mode off and enabling data transfer.
    ...
    ...  | **Author:** anna.maciejewska@nokia.com
    ...
    ...  +------------+------+-----------------------------+
    ...  | Parameters | Man. | Description                 |
    ...  +============+======+=============================+
    ...  | ue_sn_list | Yes  | List of UEs serial numbers  |
    ...  +------------+------+-----------------------------+
    ...
    ...  **EXAMPLE**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Recover UEs  ${ue_sn_list}
    ...
    ...
    [Arguments]  ${ue_sn_list}

    FOR  ${ue_serial}  IN  @{ue_sn_list}
        Attach Ue  ${ue_serial}
        Sleep  5s
        Turn Mobile Data On  ${ue_serial}
    END

Make Call
    [Documentation]
    ...  Perform a voice call from UE to a given number.
    ...
    ...  | **Author:** anna.maciejewska@nokia.com
    ...
    ...  | **Full description:**
    ...  If the voice call is properly started and terminated within expected duration, keyword succeeds.
    ...  Otherwise, keyword fails with a message explaining the reason of failure.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | Parameters    | Man. | Description                                                                 |
    ...  +===============+======+=============================================================================+
    ...  | ue_serial     | Yes  | UE serial as visible in adb devices command's output.                       |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | number        | Yes  | Phone number to call                                                        |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...  | duration      | Yes  | Duration that defines for how long voice call should be executed.           |
    ...  +---------------+------+-----------------------------------------------------------------------------+
    ...
    ...  **EXAMPLE**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Make Call  ${ue_serial}  ${phone_number}  10
    ...
    ...
    [Arguments]  ${ue_serial}  ${number}  ${duration}
    Start Voice Call  VOICE_${ue_serial}  ${ue_serial}  ${number}  ${duration}
    Await Voice Call Finish  VOICE_${ue_serial}

Check Mobile Data Mode
    [Arguments]  ${ue_serial}
    [Documentation]
    ...  KW checks mobile data mode on UE by ADB
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW checks mobile data mode on UE by ADB command.
    ...  | KW returns value "On" or "Off".
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To check mobile data mode, it is necessary to set up SSH connection (build-in KW).
    ...  | SSH connection is closing in KW teardown
    ...  | KW fails if return code is != 0
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check Mobile Data Mode  9488ee88

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${mobile_data_status}  Set Variable  adb -s ${ue_serial} shell settings get global mobile_data
    ${mobile_data_raw}  ${rc}  sshLibrary.Execute Command  ${mobile_data_status}  return_rc=True
    Should be equal  ${rc}  ${0}
    ${mobile_data_raw}  Convert To String  ${mobile_data_raw}
    ${mobile_data_raw}  Replace String  ${mobile_data_raw}  \r  ${EMPTY}
    ${mobile_data}  Set Variable If  '${mobile_data_raw}'=='1'  On  Off

    sshlibrary.Close Connection

    [Return]  ${mobile_data}

Check Airplane Mode
    [Arguments]  ${ue_serial}
    [Documentation]
    ...  KW checks airplane mode on UE by ADB
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW checks airplane mode on UE by ADB command.
    ...  | KW returns value "On" or "Off".
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To check airplane mode, it is necessary to set up SSH connection (build-in KW).
    ...  | SSH connection is closing in KW teardown.
    ...  | KW fails if return code is != 0
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check Airplane Mode  9488ee88

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${airplane_status}  Set Variable  adb -s ${ue_serial} shell settings get global airplane_mode_on
    ${airplane_mode_raw}  ${rc}  sshLibrary.Execute Command  ${airplane_status}  return_rc=True
    Should be equal  ${rc}  ${0}
    ${airplane_mode_raw}  Convert To String  ${airplane_mode_raw}
    ${airplane_mode_raw}  Replace String  ${airplane_mode_raw}  \r  ${EMPTY}
    ${airplane_mode}  Set Variable If  '${airplane_mode_raw}'=='0'  Off  On

    sshlibrary.Close Connection

    [Return]  ${airplane_mode}

Toggle Airplane Mode On-Off ADB
    [Documentation]
    ...  KW toggle airplane mode on-off on UE by ADB
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW switches airplane mode on-off on UE by ADB command.
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To toggle airplane mode, it is necessary to set up SSH connection (build-in KW).
    ...  | SSH connection is closing in KW teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Toggle Airplane Mode On-Off ADB  9488ee88

    [Arguments]  ${ue_serial}

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${airplane_put}  Set Variable  adb -s ${ue_serial} shell settings put global airplane_mode_on
    ${airplane_set}  Set Variable  adb -s ${ue_serial} shell am broadcast -a android.intent.action.AIRPLANE_MODE

    ${put1_otp}  sshLibrary.Execute Command  ${airplane_put} 1
    ${set_otp}   sshLibrary.Execute Command  ${airplane_set}
    Sleep  5s
    ${put0_otp}  sshLibrary.Execute Command  ${airplane_put} 0
    ${set2_otp}  sshLibrary.Execute Command  ${airplane_set}
    Sleep  5s

Toggle Mobile Data On-Off ADB
    [Documentation]
    ...  KW toggle mobile data on-off on UE by ADB
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW switches mobile data on-off on UE by ADB command.
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | To toggle mobile data, it is necessary to set up SSH connection (build-in KW).
    ...  | SSH connection is closing in KW teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Toggle Mobile Data On-Off ADB  9488ee88

    [Arguments]  ${ue_serial}

    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get UEPC Connection Info  ${ue_serial}

    Try Connect Via SSH  ${uepc_ip}  ${uepc_login}  ${uepc_password}

    ${mobile_data_off}  Set Variable  adb -s ${ue_serial} shell svc data disable
    ${mobile_data_on}   Set Variable  adb -s ${ue_serial} shell svc data enable

    ${off_otp}  sshLibrary.Execute Command  ${mobile_data_off}
    Sleep  5s
    ${on_otp}  sshLibrary.Execute Command  ${mobile_data_on}
    Sleep  5s

    [Teardown]  sshlibrary.Close Connection

Get UEPC Connection Info
    [Arguments]  ${ue_serial}
    [Documentation]
    ...  KW for receive IP, login and password for UEPC from ue_config.yaml file for given UE serial.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW receives IP, login and password for UEPC
    ...  | KW returns 3 values in order: IP, login, password.
    ...  | UE serial number is passed in `ue_serial` parameter.
    ...  | KW works only if "Import Variables  path_to_ue_config.yaml" is given
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | ue_serial        | Yes  | Serial number of UE                                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get UEPC Connection Info  9488ee88

    ${all_ues}  Get From Dictionary  ${UE_POOLS['AndroidUePool']}  inline_config

    ${ue}  Get From Dictionary  ${all_ues}  ${ue_serial}

    ${uepc_ip}  Set Variable  ${ue['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip']}
    ${uepc_login}  Set Variable  ${ue['CONSTRUCTOR_PARAMETERS']['configuration']['login']}
    ${uepc_password}  Set Variable  ${ue['CONSTRUCTOR_PARAMETERS']['configuration']['password']}

    [Return]  ${uepc_ip}  ${uepc_login}  ${uepc_password}

Verify Serial Number
    [Documentation]
    ...  KW checks if serial number given by user is visible on the RMODs list.
    ...  This list is generated by KW "Get Parameters For All  RMOD"
    ...  If SN is no visible on the BTS, test is set to NoRun
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | sn               | Yes  | Serial number of RMOD                               |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify Serial Number  K9175107169

    [Arguments]  ${serial_number}  ${alias}=default
    ${rmods}=  admin.Get Parameters For All  RMOD  ${alias}=default
    FOR  ${rmod}  IN  @{rmods}
      Return From Keyword If  '${rmod.serialNumber}'=='${serial_number}'   ${rmod}
    END
    Fail  Serial Number ${serial_number} not found in HW Configuration ! Test set to Fail !

Get Software Release
    [Documentation]
    ...  KW checks and returns SW release from active or passive partition.
    ...  Argument only_release decides if a full name or only release will be returned.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | partition        | Yes  | Active or Passive or All                                         |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | only_release     | No   | Only release e.g. SBTS21A or full release name, default True     |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${active_sw}  Get Software Release  Active  only_release=False

    [Arguments]  ${partition}  ${alias}=default  ${only_release}=${TRUE}

    ${all_software}  admin.Get Software Info  alias=${alias}
    ${active_sw}  Get From Dictionary  ${all_software}  Active SW version
    ${passive_sw}  Get From Dictionary  ${all_software}  Passive SW version
    ${active_sw_sliced}  Evaluate  ('_'.join('${active_sw}'.split('_')[0:1]))
    ${passive_sw_sliced}  Evaluate  ('_'.join('${passive_sw}'.split('_')[0:1]))

    Run Keyword If  '${partition}'=='Active' and ${only_release}==${TRUE}     Return From Keyword  ${active_sw_sliced}
    ...  ELSE IF    '${partition}'=='Passive' and ${only_release}==${TRUE}    Return From Keyword  ${passive_sw_sliced}
    ...  ELSE IF    '${partition}'=='All' and ${only_release}==${TRUE}        Return From Keyword  ${active_sw_sliced}  ${passive_sw_sliced}
    ...  ELSE IF    '${partition}'=='Active' and ${only_release}==${FALSE}    Return From Keyword  ${active_sw}
    ...  ELSE IF    '${partition}'=='Passive' and ${only_release}==${FALSE}   Return From Keyword  ${passive_sw}
    ...  ELSE IF    '${partition}'=='All' and ${only_release}==${FALSE}       Return From Keyword  ${active_sw}  ${passive_sw}

Try Connect Via SSH
    [Documentation]
    ...  KW tries to connect via ssh by opening the connection and logging in.
    ...  In case of failure, it retries the connection as many times as the user declares.
    ...  Default attempts value is 3.
    ...  Default wait time between tries is 10s.
    ...  KW returns list with statuses.
    ...  The first index indicates whether opening the connection was successful.
    ...  The second index indicates whether logging was successful.
    ...  If opening was successful but logging wasn't, ssh connection is closing.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | uepc_ip          | Yes  | UEPC IP to connect                                               |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | uepc_login       | Yes  | UEPC Login name to connect                                       |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | uepc_password    | Yes  | UEPC Password to connect                                         |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | attempts         | No   | Attempts connection, default is 3                                |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Try Connect Via SSH  10.44.123.124  admin  password

    [Arguments]  ${uepc_ip}  ${uepc_login}  ${uepc_password}  ${attempts}=${3}  ${wait}=${10}


    ${tmp_list}  Create List

    ${status_1}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${attempts}x  ${wait}s  sshlibrary.Open Connection  ${uepc_ip}
    Append to list  ${tmp_list}  ${status_1}

    ${status_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${attempts}x  ${wait}s  sshlibrary.Login  ${uepc_login}  ${uepc_password}
    Append to list  ${tmp_list}  ${status_2}

    Run Keyword If  '${tmp_list}[1]'=='False'  sshlibrary.Close Connection

    Run Keyword If  False in ${tmp_list}  Fail  Cannot connect with UEPC ${uepc_ip}


Get APN Name From UE
    [Documentation]
    ...  KW returns currently set APN from android UE via adb
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | ue_serial        | Yes  | UE serial                                                        |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  ${apn_name}  Get APN Name From UE  b2f8b881

    [Arguments]  ${ue_serial}

    ${model}  Get UE Product Name Via ADB  ${ue_serial}

    ${apn}  Run Keyword If  'J2' in '${model}'  _Get APN For Samsung J2 Via ADB  ${ue_serial}
    ...  ELSE IF  'J5' in '${model}'  _Get APN For Samsung J5 Via ADB  ${ue_serial}

    ${apn_name}  Set Variable If  '${apn}' not in ['srn-lte-jaguar','ap4.hetran']  Unknown  ${apn}

    [Return]  ${apn_name}

_Get APN For Samsung J5 Via ADB
    [Documentation]
    ...  KW returns currently set APN from Samsung J5 via adb
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${ue_serial}

    ${cmd}  Set Variable  adb -s ${ue_serial} shell "su -c content query --uri content://telephony/carriers/preferapn"
    ${status}  ${output}  Run Keyword And Ignore Error  sshlibrary.Execute Command  ${cmd}  timeout=20s
    Return From Keyword If  '${status}'!='PASS'  Unavailable

    ${output}  Remove String  ${output}  \r  \n
    ${status}  ${apn}  Run Keyword And Ignore Error  evaluate  re.search(r'(?<=apn=).*?(?=,)', '${output}' ).group(0)  re

    ${apn}  Set Variable If  '${status}'=='FAIL'  Unknown  ${apn}

    [Return]  ${apn}

_Get APN For Samsung J2 Via ADB
    [Documentation]
    ...  KW returns currently set APN from Samsung J2 via adb
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${ue_serial}

    ${apn_id_dict}  Create Dictionary  3323=ap4.hetran  3322=srn-lte-jaguar

    ${cmd_id}  Set Variable
    ...  adb -s ${ue_serial} shell "su -c cat /data/user_de/0/com.android.providers.telephony/shared_prefs/preferred-apn.xml" | grep value

    ${status}  ${output}  Run Keyword And Ignore Error  sshlibrary.Execute Command  ${cmd_id}  timeout=20s
    Return From Keyword If  '${status}'!='PASS'  Unavailable

    ${output}  Remove String  ${output}  \r  \n

    ${status}  ${apn_id}  Run Keyword And Ignore Error  evaluate  re.search(r'(?<=value=").*?(?=")', '${output}' ).group(0)  re
    Return From Keyword If   '${status}'=='FAIL'  Unknown

    ${apn_id}  Set Variable If  '${apn_id}' not in ['3322','3323']  Unknown  ${apn_id}

    Return From Keyword If   '${apn_id}'=='Unknown'  Unknown
    ${apn_name}  Get From Dictionary  ${apn_id_dict}  ${apn_id}

    [Return]  ${apn_name}

Set APN On UE
    [Documentation]
    ...  KW sets required APN on android UE Samsung J5 via adb
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | ue_serial        | Yes  | UE serial                                                        |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | required_apn     | Yes  | required APN to set                                                       |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  ${apn_name}  Set APN on UE  b2f8b881

    [Arguments]  ${ue_serial}  ${required_apn}

    ${model}  Get UE Product Name Via ADB  ${ue_serial}

    ${apn}  Run Keyword If  'J2' in '${model}'  _Set APN on Samsung J2 Via ADB  ${ue_serial}  ${required_apn}
    ...  ELSE IF  'J5' in '${model}'  _Set APN on Samsung J5 Via ADB  ${ue_serial}  ${required_apn}

_Set APN on Samsung J5 Via ADB
    [Documentation]
    ...  KW sets required APN on android UE Samsung J5 via adb
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${ue_serial}  ${required_apn}

    ${apns_dict}  Create Dictionary

    ${available_apns_cmd}  Set Variable   adb -s ${ue_serial} shell "su -c content query --uri content://telephony/carriers/current"
    ${status}  ${output}  Run Keyword And Ignore Error  sshlibrary.Execute Command  ${available_apns_cmd}  timeout=10s
    Run Keyword If  '${status}'!='PASS'  Run Keywords
    ...  Log to console  Setting APN ${required_apn} for UE ${ue_serial} failed, cannot execute adb command !
    ...  AND  Return From Keyword

    ${output}  Remove String  ${output}  \r  \n
    @{lines}  Split String  ${output}  Row
    Remove From List  ${lines}  0

    FOR  ${line}  IN  @{lines}
        ${status}  ${apn_name}  Run Keyword And Ignore Error  evaluate  re.search(r'(?<=apn=).*?(?=,)', '${line}' ).group(0)  re
        ${apn_id}=  evaluate  re.search(r'(?<=_id=).*?(?=,)', '${line}' ).group(0)  re
        Run Keyword If  '${status}'=='FAIL'  Run Keywords
        ...  Log to console  Cannot read output from UE ! APN not set !${\n}
        ...  AND  Return From Keyword
        Set To Dictionary  ${apns_dict}  ${apn_name}  ${apn_id}
    END

    ${status}  ${apn_id_to_set}  Run Keyword And Ignore Error  Get From Dictionary  ${apns_dict}  ${required_apn}
    Run Keyword if  '${status}'=='FAIL'  Run Keywords
    ...  Log to console  APN ${required_apn} is not added on the UE ${ue_serial} in Settings -> Mobile Networks -> Access Points Name !${\n}
    ...  AND  Return From Keyword
    ${apn_set_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell "su -c content insert --uri content://telephony/carriers/preferapn --bind apn_id:i:${apn_id_to_set}"
    ${rc}  sshlibrary.Execute Command  ${apn_set_cmd}  return_stdout=False  return_rc=True  timeout=10s
    Run Keyword If  '${rc}'!='0'  Log to console  Setting APN ${required_apn} for UE ${ue_serial} failed !${\n}

_Set APN On Samsung J2 Via ADB
    [Documentation]
    ...  KW sets required APN on android UE Samsung J2 via adb
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${ue_serial}  ${required_apn}

    ${apn_id_dict}  Create Dictionary  ap4.hetran=3323  srn-lte-jaguar=3322
    ${apn_id_to_set}  Get From Dictionary  ${apn_id_dict}  ${required_apn}

    ${apn_set_cmd}  Set Variable
    ...  adb -s ${ue_serial} shell "su -c content insert --uri content://telephony/carriers/preferapn --bind apn_id:i:${apn_id_to_set}"
    ${status}  ${output}  Run Keyword And Ignore Error  sshlibrary.Execute Command  ${apn_set_cmd}  timeout=10s
    Run Keyword If  '${status}'!='PASS'
    ...  Log to console  Cannot read output from UE ! APN ${required_apn} not set for UE ${ue_serial} !

Get UE Product Name Via ADB
    [Documentation]
    ...  KW returns android UE product name via ADB.
    ...  SSH connection to UEPC must be opened before use !
    ...  Recommended KW is "Try Connect Via SSH"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | ue_serial        | Yes  | UE serial                                                        |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  ${apn_name}  Get UE Product Name Via ADB  b2f8b881

    [Arguments]  ${ue_serial}

    ${pn_cmd}  Set Variable   adb -s ${ue_serial} shell getprop ro.product.model
    ${output}  sshlibrary.Execute Command  ${pn_cmd}
    ${product_name}  Remove String  ${output}  \r  \n

    [Return]  ${product_name}

Login To WebEM Via Selenium
    [Documentation]
    ...  KW login to WebEM via Nemuadmin user.
    ...  Default port for connection is 443
    ...  KW skips all pop-ups after login.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | port             | No  | port for connection to WebEM, default 443                         |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Login To WebEM Via Selenium  #port=443

#    [Arguments]  ${port}=443

    Log To Console  Opening Chrome browser in headless mode !${\n}

    Set Screenshot Directory    EMBED
    ${chrome_params}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method    ${chrome_params}    add_argument    --no-sandbox
    Call Method    ${chrome_params}    add_argument    --headless
    Call Method    ${chrome_params}    add_argument    --disable-extensions
    Call Method    ${chrome_params}    add_argument    --disable-gpu
    Call Method    ${chrome_params}    add_argument    --ignore-certificate-errors
    Create Webdriver    Chrome    chrome_options=${chrome_params}

    Maximize Browser Window
    Go To  https://192.168.255.129

    Log to console  Chrome opened in headless mode !${\n}
    Run Keyword And Ignore Error  Click Button  //button[@id='details-button']
    Sleep  3s
    Run Keyword And Ignore Error  Click Element  //a[@id='proceed-link']
    Sleep  10s
    Log To Console  Entering login credentials...${\n}
    Wait Until Keyword Succeeds  5x  5 s  Input Text  login-username  Nemuadmin
    Wait Until Keyword Succeeds  5x  5 s  Input Password  login-password  nemuuser
    #Wait Until Keyword Succeeds  5x  5 s
    #...  Click Element  xpath=/html/body/login-root/div/login/div/div/div[1]/p-card/div/div[2]/div/form/div[4]/p-togglebutton/div/span[2]
    #Wait Until Keyword Succeeds  5x  5 s  Input Text  Port  ${port}
    Press Keys  login-password  RETURN
    Wait Until Keyword Succeeds  1m  5s
    ...  Location Should Be  https://192.168.255.129/#/bts-status/site-view
    Log To Console  Going through pop-ups...${\n}
    Wait Until Page Contains Element
    ...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    ...  timeout=30s
    Wait Until Keyword Succeeds  5x  5 s
    ...  Click Button
    ...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5x    5 s    Click Button    //*[contains(text(),'Close')]

    Log to console  Login To WebEM Via Selenium successful !${\n}

Check And Repair Google Chrome And Chrome Driver Compatibility
    [Documentation]
    ...  KW checks version of Google Chrome and Chrome Drivers
    ...  If Chrome driver version doesn't match for Google Chrome
    ...  compatible Chrome Driver is installed on VM.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Check And Repair Google Chrome And Chrome Driver Compatibility

    ${gc_version}  Run  google-chrome --version
    Log to console  ${gc_version}
    ${gc_version}  Evaluate  re.search(r'(\\d+)..*', '${gc_version}' ).group(1)  re
    ${gc_version}  Convert To Integer  ${gc_version}

    ${cd_version}  Run  chromedriver --version
    Log to console  ${cd_version}
    ${cd_version}  Evaluate  re.search(r'(\\d+)..*', '${cd_version}' ).group(1)  re
    ${cd_version}  Convert To Integer  ${cd_version}

    ${install_cmd}  Set Variable  sudo apt install -y --allow-downgrades ute-chromedriver=${gc_version}

    Run Keyword If  ${gc_version}!=${cd_version}  Run Keywords
    ...  Log to console  Versions are not compatible, installing Chrome Driver ${gc_version} !
    ...  AND  Run  ${install_cmd}
    ...  AND  Sleep  3s
    ...  ELSE  Run Keywords  Log to console  Versions are compatible !
    ...  AND  Return From Keyword

    ${cd_version}  Run  chromedriver --version
    ${cd_version}  Evaluate  re.search(r'(\\d+)..*', '${cd_version}' ).group(1)  re
    ${cd_version}  Convert To Integer  ${cd_version}
    Run Keyword If  ${cd_version}==${gc_version}  Log to console  Installation Chrome Driver ${gc_version} successful !${\n}
    ...  ELSE  Run Keywords
    ...  Log to console  Chrome driver ${gc_version} installation unsuccessful!${\n}
    ...  AND  Fail  Chrome driver ${gc_version} installation unsuccessful!${\n}

Check If All Cells Are OnAir
    [Documentation]
    ...  KW checks if all cells on BTS are onAir.
    ...  Default timeout is set to 10 second
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | alias            | No   | Alias for connection to AdminAPI                                 |
    ...  | timeout          | No   | Timeout for assertion response                                   |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Check If All Cells Are onAir  timeout=20

    [Arguments]  ${alias}=default  ${timeout}=10

    ${gncel_list}  admin.Get Ids For All  GNCEL  alias=${alias}
    ${wncel_list}  admin.Get Ids For All  WNCEL  alias=${alias}
    ${lncel_list}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  alias=${alias}
    ${nrcel_list}  admin.Get Ids For All  NRCEL  alias=${alias}


    Run Keyword If  len(${lncel_list})!=0  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  LTE  ${timeout}  ${alias}

    Run Keyword If  len(${nrcel_list})!=0  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  NR  ${timeout}  ${alias}

    Run Keyword If  len(${wncel_list})!=0  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  WCDMA  ${timeout}  ${alias}

    Run Keyword If  len(${gncel_list})!=0  Run Keyword And Continue On Failure
    ...  Check If All Cells For RAT Are OnAir  GSM  ${timeout}  ${alias}

Check If Cell Is OnAir
    [Documentation]
    ...  KW checks if cell with runtime_id on BTS are onAir.
    ...  Default timeout is set to 10 second
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${rat}  ${id}  ${timeout}=10  ${alias}=default

    Run Keyword If  '${rat}'=='GSM'  Run Keywords
    ...  admin.Assert  GNCEL  ${id}
    ...  ${GNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  Assert No For Specified Cell  GNCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}
    ...  ELSE IF  '${rat}'=='WCDMA'  Run Keywords
    ...  admin.Assert  WNCEL  ${id}
    ...  ${WNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  Assert No For Specified Cell  WNCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}
    ...  ELSE IF  '${rat}'=='LTE'  Run Keywords
    ...  admin.Assert  LNCEL  ${id}
    ...  ${LNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  Assert No For Specified Cell  LNCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}
    ...  ELSE IF  '${rat}'=='NR'  Run Keywords
    ...  admin.Assert  NRCEL  ${id}
    ...  ${NRCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  Assert No For Specified Cell  NRCEL  ${id}  ${DEGRADED_CELL_REGEX_2}  ${alias}

Assert No For Specified Cell
    [Documentation]
    ...  KW checks if specified cell doesn't contain
    ...  a parameter with value given by regex
    ...  KW passes if parameters dict doesn't match regex
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${rat}  ${id}  ${regex}  ${alias}

    ${params}  admin.Get Parameters For  ${rat}  ${id}  alias=${alias}
    Should Not Match Regexp  str(${params})  ${regex}

Check If All Cells For RAT Are OnAir
    [Documentation]
    ...  KW checks if cells for RAT are onAir.
    ...  Default timeout is set to 10 second
    ...
    ...  | **Author:** mateusz.kawka@nokia.com

    [Arguments]  ${rat}  ${timeout}=10  ${alias}=default

    Run Keyword If  '${rat}'=='GSM'  Run Keywords
    ...  admin.Assert Every  GNCEL
    ...  ${GNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  admin.Assert No  GNCEL
    ...  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}
    ...  ELSE IF  '${rat}'=='WCDMA'  Run Keywords
    ...  admin.Assert Every  WNCEL
    ...  ${WNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  admin.Assert No  WNCEL
    ...  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}
    ...  ELSE IF  '${rat}'=='LTE'  Run Keywords
    ...  admin.Assert Every  LNCEL
    ...  ${LNCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  admin.Assert No  LNCEL
    ...  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}
    ...  ELSE IF  '${rat}'=='NR'  Run Keywords
    ...  admin.Assert Every  NRCEL
    ...  ${NRCEL_ONAIR_REGEX}  timeout=${timeout}  alias=${alias}
    ...  AND  admin.Assert No  NRCEL
    ...  ${DEGRADED_CELL_REGEX}  timeout=${timeout}  alias=${alias}

Get RU DistName For Serial Number
    [Documentation]
    ...  KW returns RU runtime distname (id) based on serial number
    ...  KW can return full (default) or short distname
    ...  Short means e.g. RMOD_R-3
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${rmod_sn}  ${short_name}=False  ${alias}=default

    ${all_ru_params}  admin.Get Parameters For All  RMOD  alias=${alias}
    FOR  ${rmod}  IN  @{all_ru_params}
        Continue For Loop If  '${rmod_sn}'!='${rmod['serialNumber']}'
        ${rmod_distname}  Set Variable  ${rmod['id']}
    END

    ${rmod_conf_name}  Evaluate  '${rmod_distname}'.split('/')[-1]

    Return From Keyword If  ${short_name}  ${rmod_conf_name}

    [Return]  ${rmod_distname}

Get RU Serial Number For DistName
    [Documentation]
    ...  KW returns RU serial number based on distname (id)
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    [Arguments]  ${rmod_id}  ${alias}=default

    ${rmod_params}  admin.Get Parameters For All  RMOD  alias=${alias}
    FOR  ${rmod}  IN  @{rmod_params}
        Continue For Loop If  '${rmod['id']}'!='${rmod_id}'
        ${rmod_sn}  Set Variable  ${rmod['serialNumber']}
    END

    [Return]  ${rmod_sn}

Log Tx Power For All RU
    [Documentation]
    ...  KW returns TX power for all RUs in configuration
    ...  Depending on the method, KW prints power for carriers or carriers and antenna lines
    ...  If `hran_radio` is set as method:
    ...  For RU < 6.0 - power for LWG carriers (using hran_radio)
    ...  For RU >= 6.0 - power for all RU antenna lines (DAPD)
    ...  If `dapd` is set as method:
    ...  For RU < 5.1 - power for all LWG carriers (using hran_radio)
    ...  For RU >= 5.1 - power for all RU antenna lines (DAPD)
    ...  If `frmon` is set as method:
    ...  For RU < 5.1 - power for all LWG carriers (using hran_radio)
    ...  For RU >= 5.1 - power for all NLWG carriers (frmon)
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | print_table      | No   | True of false if want table with power in console logs           |
    ...  | method           | No   | default `hran_radio`, other option: `dapd` and `frmon`           |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Log Tx Power For All RU  method=dapd

    [Arguments]  ${print_table}=True  ${method}=hran_radio
    ${desired_hw_release}  Set Variable If  '${method}'!='hran_radio'  5.1  6.0
    ${radio_distname_list}=  admin_im.Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${radio_distname}  IN  @{radio_distname_list}
        ${hw_release}  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${radio_distname.radioModuleHwReleaseCode}').group(0)  re
        ${ref_radio_object}  admin_im.Query Infomodel  get object ${radio_distname.dist_name}/REF-*
        ${im_radio_object}   admin_im.Query Infomodel  get object ${ref_radio_object.distName}
        Run Keyword If  (${hw_release}>=${desired_hw_release} and '${method}'=='dapd')
        ...  Run Keywords
        ...  Log to console  ${\n}TX-Power for ${im_radio_object.serialNumber} via DAPD
        ...  AND  Get DAPD TX Power For All Pipes  ${im_radio_object.serialNumber}  print_table=${print_table}
        ...  AND  Continue For Loop
        ...  ELSE IF  (${hw_release}>=${desired_hw_release} and ('${method}'=='frmon' or '${method}'=='hran_radio'))
        ...  Run Keywords
        ...  Log to console  ${\n}TX-Power for ${im_radio_object.serialNumber} via FRMON
        ...  AND  Get FRMON Power For All Carriers  ${im_radio_object.serialNumber}  TX  print_table=${print_table}
        ...  AND  Continue For Loop
        ${im_module_object}  Query Infomodel  get object ${im_radio_object.masterAgentDN}
        ${module_address}  Set Variable If
        ...  '${im_module_object.ipAddress}'=='192.168.255.7' and '474767A' in '${im_module_object.productCode}'
        ...  fct-4a  ${im_module_object.ipAddress}
        Log to console  ${\n}TX-Power for ${im_radio_object.serialNumber} via hran_radio
        ${tx_power_dict}  Get Tx Power  ${im_radio_object.ipAddress}  ${module_address}  ${im_radio_object.productName}
        ...  print_to_report=${print_table}
    END

Get Cells Mapping By RMOD Id
    [Documentation]
    ...  KW returns all cells for technology deployed on given RMOD.
    ...  KW returns correctly cells deployed on RMOD in chaining configuration, unlike Get Cell Mapping By Module ID
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | rat              | Yes  | GSM/WCDMA/LTE/NR                                                 |
    ...  | radio_id         | Yes  | Radio ID from runtime                                            |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Get Cells Mapping By RMOD Id  rat=NR  radio_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-3

    [Arguments]  ${rat}  ${radio_id}  ${alias}=default

    ${whole_list}  admin.Get Cell List  alias=${alias}

    ${rat_cells}  Evaluate  (${whole_list}\['cells']['${rat.lower()}'])

    ${ids_list}  Create List
    FOR  ${rat_cell}  IN  @{rat_cells}
        Run Keyword If  '${rat}'=='LTE'
        ...  Continue For Loop If  'iot' in '${rat_cell['technology'].lower()}'
        ${carriers_list}  Evaluate  (${rat_cell}\['carrierList'])
        ${status}  _Carrier List Iterator For Cells Mapping  ${carriers_list}  ${radio_id}
        Continue For Loop If  '${status}'=='False'
        ${cell_id}  Evaluate  (${rat_cell}\['id']['internal'])
        Append To List  ${ids_list}  ${cell_id}
    END

    ${list_of_cell}=  Remove Duplicates  ${ids_list}

    [Return]  ${list_of_cell}

_Carrier List Iterator For Cells Mapping
    [Arguments]  ${carrier_list}  ${radio_id}

    FOR  ${carrier}  IN  @{carrier_list}
        ${antennaline}  Get From Dictionary  ${carrier}  antennaLineId
        ${rmod_id}  Evaluate  (${antennaline}\['internal'][0:-9])
        ${status}  Set Variable If  '${rmod_id}'=='${radio_id}'  True  False
        Return From Keyword If  '${status}'=='True'  ${status}
    END

    [Return]  ${status}

Get All Cells Mapping By RMOD Id
    [Documentation]
    ...  KW returns all cells for all technology deployed on given RMOD.
    ...  KW returns correctly cells deployed on RMOD in chaining configuration, unlike Get Cell Mapping By Module ID
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | radio_id         | Yes  | Radio ID from runtime                                            |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Get All Cells Mapping By RMOD Id  radio_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-3

    [Arguments]  ${radio_id}

    ${nr_cells}  Get Cells Mapping By RMOD Id  NR  ${radio_id}
    ${lte_cells}  Get Cells Mapping By RMOD Id  LTE  ${radio_id}
    ${wcdma_cells}  Get Cells Mapping By RMOD Id  WCDMA  ${radio_id}
    ${gsm_cells}  Get Cells Mapping By RMOD Id  GSM  ${radio_id}

    ${all_cells}  Combine Lists  ${nr_cells}  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}

    [Return]  ${all_cells}

#Setup TAF Admin
#    [Documentation]
#    ...  KW setup session to admin api using taf library.
#    ...
#    ...  | **Author:** mateusz.kawka@nokia.com
#    ...  | **Maintainer:** mateusz.kawka@nokia.com
#    ...
#    ...  **Input Parameters:**
#    ...
#    ...  +------------------+------+------------------------------------------------------------------+
#    ...  | Parameter        | Man. | Description                                                      |
#    ...  +==================+======+==================================================================+
#    ...  | bts_host         | No   | Host IP, local or remote (mplane)                                |
#    ...  +------------------+------+------------------------------------------------------------------+
#    ...  | connection_name  | No   | Connection name for `name` argument  (alias)                     |
#    ...  +------------------+------+------------------------------------------------------------------+
#    ...
#    ...  **Example of simple usage:**
#    ...
#    ...  .. code-block:: robotframework
#    ...
#    ...  Setup TAF Admin  bts_host=10.13.23.249  connection_name=vm_1
#
#    [Arguments]  ${bts_host}=192.168.255.129  ${connection_name}=default
#
#    ${release}  Get Software Version From ENB
#    ${status}  ${connection}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  10s
#    ...  admin.Setup Admin  admin_api_log_dir=${BTS Files}/coam_admin  bts_host=${bts_host}  bts_port=443
#    ...  use_ssl=True  name=${connection_name}  release=${release}
#    Run Keyword If  '${status}'=='FAIL'
#    ...  Fail  Admin connection from TAF library did not start after 5 attempts!
#    ...  ELSE  Log to console  Connection to Admin via TAF library successfully established!${\n}
#
#    Set Test Variable  ${connection}

#Time To Sleep
#    [Documentation]  KW checks how much time has been left to collect PM Counters.
#    ...  This was introduced to shorten the waiting time for collecting PM Counters.
#    ...  It's possible due to the fact that the PM Counters are collected at predeterminated times.
#    ...  For example: For 15 minutes measurement interval the reports are scheduled at 00:15h, 00:30h, 00:45h, 01:00h, etc.
#    ...  For example: For 720 minutes measurement interval the reports are scheduled at 12:00h and 24:00h.
#
#    [Arguments]  ${int}  ${additional_offset}=${0}
#
#    ${minutes}=  Get Time  minutes
#    ${hours}=  Get Time  hours
#    ${minutes}=  Convert Time  ${minutes}
#    ${hours}=  Convert Time  ${hours}
#    ${hours_to_minutes}=  Run Keyword If  ${int}==360 or ${int}==720 or ${int}==1440  Evaluate  int(${hours}*60+${minutes})
#    ${time}=  Run Keyword If  ${int}==15 and 0<=${minutes}<=13  Evaluate  int(17-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==15 and 14<=${minutes}<=28  Evaluate  int(32-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==15 and 29<=${minutes}<=43  Evaluate  int(47-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==15 and 44<=${minutes}<=58  Evaluate  int(62-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==15 and ${minutes}>=59  Evaluate  int(18+${additional_offset})
#    ...  ELSE IF  ${int}==30 and 0<=${minutes}<=28  Evaluate  int(32-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==30 and 29<=${minutes}<=58  Evaluate  int(62-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==30 and ${minutes}>=59  Evaluate  int(33+${additional_offset})
#    ...  ELSE IF  ${int}==60 and 0<=${minutes}<=58  Evaluate  int(62-${minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==60 and ${minutes}>=59  Evaluate  int(63+${additional_offset})
#    ...  ELSE IF  ${int}==360 and 0<=${hours_to_minutes}<=358  Evaluate  int(362-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==360 and 359<=${hours_to_minutes}<=718  Evaluate  int(722-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==360 and 719<=${hours_to_minutes}<=1078  Evaluate  int(1082-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==360 and 1079<=${hours_to_minutes}<=1438  Evaluate  int(1442-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==360 and {hours_to_minutes}>=359  Evaluate  int(363+${additional_offset})
#    ...  ELSE IF  ${int}==720 and 0<=${hours_to_minutes}<=718  Evaluate  int(722-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==720 and 719<=${hours_to_minutes}<=1438  Evaluate  int(1442-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==720 and {hours_to_minutes}>=1439  Evaluate  int(1443+${additional_offset})
#    ...  ELSE IF  ${int}==1440 and 0<=${hours_to_minutes}<=1438  Evaluate  int(1442-${hours_to_minutes}+${additional_offset})
#    ...  ELSE IF  ${int}==1440 and {hours_to_minutes}>=1439  Evaluate  int(1443+${additional_offset})
#    ...  ELSE  Fail  Cannot set correct time to sleep !
#
#    ${date}  Get Current Date
#    ${time_to_verdict}  Add Time To Date  ${date}  ${time} minutes  result_format=%H:%M  exclude_millis=True
#
#    [Return]  ${time}  ${time_to_verdict}

Check If All Cells And Modules Are OnAir
    [Documentation]
    ...  KW checks if all cells and modules on BTS are onAir.
    ...  Default timeout is set to 10 second
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | alias            | No   | Alias for connection to AdminAPI                                 |
    ...  | timeout          | No   | Timeout for assertion response                                   |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Check If All Cells And Modules Are onAir  timeout=20

    [Arguments]  ${alias}=default  ${timeout}=10

    Check If All Cells Are OnAir  timeout=${timeout}  alias=${alias}
    admin.Assert Every    RMOD    operationalState=regex"(?i)Enabled"  timeout=${timeout}  alias=${alias}
    admin.Assert Every    SMOD    operationalState=regex"(?i)Enabled"  timeout=${timeout}  alias=${alias}


Check Required Mrbts State
    [Arguments]  ${required_state}  ${alias}=default
    [Documentation]
    ...  KW checks if BTS state is equal required state.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${state}  admin.Get Mrbts State  alias=${alias}

    Run Keyword If  '${state}'!='${required_state}'
    ...  Fail  Actual state -> ${state}, required -> ${required_state}
    ...  ELSE  Log To Console  MRBTS reached required state -> ${required_state}

Get FaultID Occurrences
    [Arguments]  ${fault_id}
    [Documentation]
    ...  KW returns faultId occurences
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${counter}  Set Variable  ${0}
    ${alarms}  admin.Get Alarms
    FOR  ${alarm}  IN  @{alarms}
        Continue For Loop If  '${alarm['faultId']}'!='${fault_id}'
        ${counter}  Set Variable  ${counter+1}
    END

    [Return]  ${counter}

Check FaultId Occurrences
    [Arguments]  ${fault_id}  ${expected_occurences}
    [Documentation]
    ...  KW checks if faultId occurences is equal to expected
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${occurences}  Get FaultID Occurrences  ${fault_id}
    Should Be Equal As Integers  ${expected_occurences}  ${occurences}

Set RD Flags On RMOD
    [Arguments]  ${rmod_sn}  ${flags}
    [Documentation]
    ...  KW sets desired flags to RMOD using rad -mpw command
    ...  After that RMOD reboot is preformed.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    Log to console  Opening connection to RU with SN ${rmod_sn}!${\n}
    Open Connection To Radio Module With Serial Number  ${rmod_sn}

    FOR  ${flag}  ${value}  IN ZIP  ${flags.keys()}  ${flags.values()}
        SSHLibrary.Write  rad -mpw ${flag} ${value}
        ${output}  SSHLibrary.Read  delay=1s
        ${status}  Run Keyword And Return Status  Should Contain  ${output}  written succesfully
        Log To Console  ${output}
    END

    SSHLibrary.Write  reboot
    Log To Console  ${\n}RMOD is rebooting now !${\n}


Check If Current Build Is Newer Than
    [Arguments]    ${build}    ${alias}=default
    [Documentation]
    ...  KW checks if given build is newer/higher than active software on BTS
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${current_sw}  Get Software Release  Active    only_release=False    alias=${alias}
    ${current_sw}  Get Regexp Matches  ${current_sw}  \\d+
    ${curr}    Evaluate    [int(number) for number in ${current_sw}]

    ${arg_sw_number}    Get Regexp Matches  ${build}  \\d+
    ${arg}    Evaluate    [int(number) for number in ${arg_sw_number}]
    Return From Keyword If    ${curr}[0]>${arg}[0]  ${TRUE}
    Return From Keyword If
    ...  ${curr}[0]>=${arg}[0] and ${curr}[1]>=${arg}[1] and ${curr}[2]==0000 and ${arg}[2]==9999  ${TRUE}
    ${verdict}    Set Variable If
    ...    ${curr}[0]>=${arg}[0] and ${curr}[1]>=${arg}[1] and ${curr}[3]>=${arg}[3]
    ...    ${TRUE}
    ...    ${FALSE}

    Run Keyword If  not ${verdict}
    ...  Return From Keyword  ${verdict}
    ...  ELSE
    ...  Return From Keyword If  ${curr}[3]!=${arg}[3]  ${verdict}

    ${verdict}  Set Variable If  ${curr}[4]>${arg}[4]  ${TRUE}  ${FALSE}

    [Return]    ${verdict}
