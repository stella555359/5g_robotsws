*** Settings ***
Documentation
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    DateTime
Library    taf.sw.syslog    WITH NAME    syslog
Library    taf.transport.ssh    WITH NAME    tafssh
Library    ../../resources/ims2_parser.py

Resource    ./admin.robot
Resource    ./setup_and_teardown.robot
Resource    ../../resources/operations.robot
Resource    ../../resources/Robot/scfc.robot

*** Keywords ***
CUS Get Section Numbers List
    [Arguments]  ${cusini_file_path}  ${section}
    [Documentation]
    ...  Description:
    ...  Keyword gets a list of all section numbers based on general section name in the cusini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | section                | Yes  | Name of section in the cus.ini file.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${section_number_list}=  Create List
    ${cusini_contents}=  OperatingSystem.Get File  path=${cusini_file_path}
    ${section_lines}=  Get Lines Containing String  string=${cusini_contents}  pattern=[${section}_
    @{section_list}=  Split To Lines    string=${section_lines}
    FOR  ${section_element}  IN  @{section_list}
      ${section_number}=  Remove String  ${section_element}  ${section}_  [    ]
      Append To List  ${section_number_list}  ${section_number}
    END
    [Return]  ${section_number_list}

CUS Get Section Names List
    [Arguments]  ${cusini_file_path}  ${section}
    [Documentation]
    ...  Description:
    ...  Keyword gets a list of all section names based on general section name in the cusini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | section                | Yes  | Name of section in the cus.ini file.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${section_name_list}=  Create List
    ${cusini_contents}=  OperatingSystem.Get File  path=${cusini_file_path}
    ${section_lines}=  Get Lines Containing String  string=${cusini_contents}  pattern=[${section}_
    @{section_list}=  Split To Lines  string=${section_lines}
    FOR  ${section_element}  IN  @{section_list}
      ${section_name}=  Remove String  ${section_element}  [    ]
      Append To List  ${section_name_list}  ${section_name}
    END
    [Return]  ${section_name_list}

CUS Get Parameter Values List For Section List
    [Arguments]    ${cusini_file_path}    ${section_list}    ${parameter_name}
    [Documentation]    Keyword gets all the values for the given parameter in all sections in the list.
    ...    Author: slawomir.jastrzebski@nokia.com
    ...    Maintainer: slawomir.jastrzebski@nokia.com
    ${parameter_value_list}=    Create List
    ${cusini_contents}=    OperatingSystem.Get File    ${cusini_file_path}
    ${section_count}=    Get Length    ${section_list}
    FOR  ${section_number}  IN RANGE  ${section_count}
      ${pre_section}    ${rest_section}=    Split String    string=${cusini_contents}    separator=[${section_list[${section_number}]}]
      ${section}=    Split String    string=${rest_section}    separator=[
      ${section_line}=	Get Lines Containing String	   string=${section[0]}    pattern=${parameter_name}
      ${parameter_value}=    Fetch From Right    string=${section_line}    marker==
      ${parameter_value}=    Remove String    ${parameter_value}    ${SPACE}
      Append To List    ${parameter_value_list}    ${parameter_value}
    END
    [Return]    ${parameter_value_list}

CUS Get Parameter Value For Section Name
    [Arguments]  ${cusini_file_path}  ${section_name}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword gets a parameter values of given section in the cus.ini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | section_name           | Yes  | Name of section in the cus.ini file.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | Name of parameter of given section in the cus.ini file.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.co

    ${cusini_contents}=  OperatingSystem.Get File  path=${cusini_file_path}
    ${pre_section}  ${rest_section}=  Split String  string=${cusini_contents}  separator=[${section_name}]
    ${section}=  Split String  string=${rest_section}  separator=[
    ${section_line}=  Get Lines Containing String  string=${section[0]}  pattern=${parameter_name}
    ${parameter_value}=  Fetch From Right  string=${section_line}  marker==
    ${parameter_value}=  Remove String  ${parameter_value}  ${SPACE}
    [Return]  ${parameter_value}

CUS Get Parameter Values List For Section Name
    [Arguments]  ${cusini_file_path}  ${section_name}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword gets a list of parameter values of given section in the cus.ini file.
    ...  Parameter values in the given section are separated by a comma or can be given in the form of a range.
    ...  Example:
    ...  sectors = 20,21,22,23,24,25
    ...  sectors = [20-25]
    ...  sectors = [26x2-31x2]
    ...  sectors = 6,9,[11- 13],16,20
    ...  sectors = [20-21],25,[35-28],54
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | section_name           | Yes  | Name of section in the cus.ini file.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | Name of parameter of given section in the cus.ini file.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cusini_contents}=  OperatingSystem.Get File  path=${cusini_file_path}
    ${pre_section}  ${rest_section}=  Split String  string=${cusini_contents}  separator=[${section_name}]
    ${section_line}=  Get Lines Containing String  string=${rest_section}  pattern=${parameter_name}
    ${section_line}=  Remove String  ${section_line}  ${SPACE}
    ${section_line}=  Split To Lines  string=${section_line}
    ${parameter_values}=  Fetch From Right  string=${section_line[0]}  marker==
    ${parameter_values_list}=  Split String  string=${parameter_values}  separator=,
    Return From Keyword If  not '-' in '${parameter_values}'  ${parameter_values_list}
    ${parameter_values_list}=  Create List
    ${param_values_list}=  Split String  string=${parameter_values}  separator=,
    FOR  ${parameter_values}  IN  @{param_values_list}
      Run Keyword If  not '-' in '${parameter_values}'
      ...  Append To List  ${parameter_values_list}  ${parameter_values}
      Continue For Loop If  not '-' in '${parameter_values}'
      ${parameter_values}=  Remove String  ${parameter_values}  [  ]
      ${start_value}=  Fetch From Left  string=${parameter_values}  marker=-
      ${start_value}=  Fetch From Left  string=${start_value}  marker=x
      ${end_value}=  Fetch From Right  string=${parameter_values}  marker=-
      ${end_value}=  Fetch From Left  string=${end_value}  marker=x
      ${values_list}=  Generate List Of Numbers Based On Range  start_value=${start_value}
      ...  end_value=${end_value}  convert_to_string=${True}
    Append To List  ${parameter_values_list}  @{values_list}
    END
    [Return]  ${parameter_values_list}

CUS Create Rmods Serial Number List
    [Arguments]  ${cusini_file_path}  ${ctrls_list}
    [Documentation]
    ...  Description:
    ...  Keyword creates a list of rmods serial number based on the cus.ini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ctrls_list             | Yes  | List of the [ctrl_X] section in the cus.ini file.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_serial_number_list}=  Create List
    FOR  ${ctrl_name}  IN  @{ctrls_list}
      ${sectors_number_list}=  CUS Get Parameter Values List For Section Name
      ...  cusini_file_path=${cusini_file_path}  section_name=${ctrl_name}  parameter_name=sectors
      ${ctrl_number}=  Fetch From Right  string=${ctrl_name}  marker=_
      ${rmods_name_list}=  CUS Create Rmods List For One Ctrl
      ...  cusini_file_path=${cusini_file_path}  sectors_number_list=${sectors_number_list}  ctrl_number=${ctrl_number}
      Append To List  ${rmods_serial_number_list}  @{rmods_name_list}
    END
    [Return]  ${rmods_serial_number_list}

CUS Create Rmods List For One Ctrl
    [Arguments]  ${cusini_file_path}  ${sectors_number_list}  ${ctrl_number}
    [Documentation]
    ...  Description:
    ...  Keyword creates a list of rmods serial number for one CUS (ctrl) based on "sector_X" section.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sectors_number_list    | Yes  | List of the "[sector_X]" section numbers, e.g. [1 2 3].                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ctrl_number            | Yes  | Number of "[ctrl_X]" section in the cus.ini file.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_name_list}=  Create List
    FOR  ${sector_number}  IN  @{sectors_number_list}
      ${sector_number}=  Fetch From Left  string=${sector_number}  marker=x
      ${antennas_value}=  CUS Get Parameter Value For Section Name
      ...  cusini_file_path=${cusini_file_path}  section_name=sector_${sector_number}  parameter_name=antennas
      ${antenna_rmods_name_list}=  CUS Create Rmods List For One Antenna
      ...  cusini_file_path=${cusini_file_path}  antennas_value=${antennas_value}  ctrl_number=${ctrl_number}
      Append To List  ${rmods_name_list}  @{antenna_rmods_name_list}
    END
    ${rmods_name_list}=  Remove Duplicates  ${rmods_name_list}
    [Return]  ${rmods_name_list}

CUS Create Rmods List For One Antenna
    [Arguments]  ${cusini_file_path}  ${antennas_value}  ${ctrl_number}
    [Documentation]
    ...  Keyword creates a list of rmods serial number for one antenna based on "antennas" parameter
    ...  in the section "[sector_X]".
    ...  Example of the "antennas" parameter:
    ...  "antennas  = 3:0:TxRx, 3:2:TxRx, 6:0:TxRx, 6:2:TxRx" (3 and 6 are the radio numbers)
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antennas_value         | Yes  | Value of the "antennas" parameter in the section "[sector_X]"              |
    ...  |                        |      | in the cus.ini file.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ctrl_number            | Yes  | Number of "[ctrl_X]" section in the cus.ini file.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${antenna_rmods_name_list}=  Create List
    @{antennas_list}=  Split String  string=${antennas_value}  separator=,
    FOR  ${antenna}  IN  @{antennas_list}
      ${rmod_number}=  Fetch From Left  string=${antenna}  marker=:
      ${rmod_full_number}=  Evaluate  (1000*${ctrl_number})+${rmod_number}
      ${rmod_full_number}=  Convert To String  item=${rmod_full_number}
      ${link_type_value}=  CUS Get Parameter Value For Section Name
      ...  cusini_file_path=${cusini_file_path}  section_name=radio_${rmod_number}  parameter_name=link_type
      ${link_type_char}=  Set Link Type Char  ${link_type_value}
      ${links_value}=  CUS Get Parameter Value For Section Name
      ...  cusini_file_path=${cusini_file_path}  section_name=radio_${rmod_number}  parameter_name=links
      ${links_value}=  Fetch From Left  string=${links_value}  marker=,
      @{link_value_list}=  Split String  ${links_value}  :
      ${link_value_count}=  Get Length  ${link_value_list}
      ${link_speed_char}=  Run Keyword If  ${link_value_count}<3
      ...  Set Default Link Speed Char  ${link_type_value}
      ...  ELSE
      ...  Set Link Speed Char  ${link_value_list[2]}
      Append To List  ${antenna_rmods_name_list}  CUS00${rmod_full_number}${link_type_char}${link_speed_char}
    END

    [Return]  ${antenna_rmods_name_list}

CUS Get Mplane Only Sector List
    [Arguments]  ${cusini_file_path}
    [Documentation]
    ...  Keyword gets a list of mplane only sector list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${mplane_only_sector_numbers_list}=  Create List
    ${sectors_number_list}=  CUS Get Section Numbers List  cusini_file_path=${CUSINI_FILE_PATH}  section=sector
    FOR  ${sector_number}  IN  @{sectors_number_list}
      ${mplane_value}=  CUS Get Parameter Value For Section Name
      ...  cusini_file_path=${cusini_file_path}  section_name=sector_${sector_number}  parameter_name=mplane_only
      Run Keyword If  '${mplane_value}'=='true'
      ...  Append To List  ${mplane_only_sector_numbers_list}  ${sector_number}
    END
    [Return]  ${mplane_only_sector_numbers_list}

Set Link Type Char
    [Arguments]  ${link_type_value}
    [Documentation]
    ...  Description:
    ...  Keyword sets the link type char based on the value of the "link_type" parameter read
    ...  from the [radioX] section of the cus.ini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | link_type_value        | Yes  | Value of the "link_type" parameter read from the [radioX] section of the   |
    ...  |                        |      | cus.ini file.                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${link_type_char}=  Set Variable If
    ...  '${link_type_value}' == 'CPRI'   C
    ...  '${link_type_value}' == 'OBSAI'  O
    ...  '${link_type_value}' == 'ECPRI'  E
    ...  '${link_type_value}' == 'FHS'    F
    [Return]  ${link_type_char}

Set Link Speed Char
    [Arguments]  ${link_speed_value}
    [Documentation]
    ...  Description:
    ...  Keyword sets the link speed char based on the value of the "links" parameter read
    ...  from the [radioX] section of the cus.ini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | link_speed_value       | Yes  | Value of the "links" parameter read from the [radioX] section of the       |
    ...  |                        |      | cus.ini file.                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${link_speed_char}=  Set Variable If
    ...  '${link_speed_value}' == 'auto'  A
    ...  '${link_speed_value}' == '4x'    3
    ...  '${link_speed_value}' == '8x'    6
    ...  '${link_speed_value}' == '2.4'   3
    ...  '${link_speed_value}' == '4.9'   5
    ...  '${link_speed_value}' == '6.1'   6
    ...  '${link_speed_value}' == '9.8'   7
    ...  '${link_speed_value}' == '10'    1
    ...  '${link_speed_value}' == '25'    2
    [Return]  ${link_speed_char}

Set Default Link Speed Char
    [Arguments]  ${link_type_value}
    [Documentation]
    ...  Description:
    ...  Keyword sets the default link speed char based on the "link_type" parameter read
    ...  from the [radioX] section of the cus.ini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | link_type_value        | Yes  | Value of the "link_type" parameter read from the [radioX] section of the   |
    ...  |                        |      | cus.ini file.                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${link_type_char}=  Set Variable If
    ...  '${link_type_value}' == 'CPRI'   7
    ...  '${link_type_value}' == 'OBSAI'  6
    ...  '${link_type_value}' == 'ECPRI'  2
    ...  '${link_type_value}' == 'FHS'    7
    [Return]  ${link_type_char}

CUS Create Ctrl Ip Addresses List
    [Arguments]  ${cusini_file_path}  ${ctrl_list}
    [Documentation]
    ...  Keyword creates a list of ctrl (CUS) IP addresses based on the ip_addr parameter
    ...  in the ctrl section in the cus.ini file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ctrl_list              | Yes  | List of [ctrl_X] sections in the cusini file.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ctrl_ips_list}=  Create List
    ${cusini_contents}=  OperatingSystem.Get File  path=${cusini_file_path}
    ${ctrl_count}=  Get Length  item=${ctrl_list}
    FOR  ${ctrl_number}  IN RANGE  ${ctrl_count}
      ${pre_ctrl_section}  ${rest_section}=  Split String  string=${cusini_contents}
      ...  separator=[${ctrl_list[${ctrl_number}]}]
      ${ctrl_section}=  Split String  string=${rest_section}  separator=[
      ${ip_line}=  Get Lines Containing String	 string=${ctrl_section[0]}  pattern=ip_addr
      ${ctrl_ip_addr}=  Fetch From Right  string=${ip_line}  marker==
      ${ctrl_ip_addr}=  Remove String  ${ctrl_ip_addr}  ${SPACE}
      Append To List  ${ctrl_ips_list}  ${ctrl_ip_addr}
    END
    [Return]  ${ctrl_ips_list}

Radio Modules Detection
    [Arguments]  ${scfc_file_path}  ${timeout}=${FR_DETECTION_TIMEOUT_AFTER_BTS_RESET}
    ...  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword gets list of desired RF serial numbers based on cus.ini file and check
    ...  if all simulated radio modules are correctly detected in Admin.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | Yes  | Waiting time for RMOD detection.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_rmods_sn_list}=  SCFC Get Radio Modules Serial Numbers  scfc_file_path=${scfc_file_path}
    ${ctrls_list}=  CUS Get Section Names List  cusini_file_path=${CUSINI_FILE_PATH}  section=ctrl
    ${cus_rmods_sn_list}=  CUS Create Rmods Serial Number List
    ...  cusini_file_path=${CUSINI_FILE_PATH}  ctrls_list=${ctrls_list}
    Should Not Be Empty  item=${cus_rmods_sn_list}
    Remove Values From List  ${scfc_rmods_sn_list}  @{cus_rmods_sn_list}
    ${all_rmods_sn_list}=  Combine Lists  ${cus_rmods_sn_list}  ${scfc_rmods_sn_list}
    ${rmods_count}=  Get Length  item=${all_rmods_sn_list}
    ${rmod_number}=  Evaluate  0
    Log  ${log_prefix}Radio modules are detecting...  console=${log_to_console}
    FOR  ${rmod_serial}  IN  @{all_rmods_sn_list}
      ${rmod_number}=  Evaluate  ${rmod_number}+1
      Admin Check RMOD Detection  rmod_serial=${rmod_serial}  timeout=${timeout}  rmod_count=${rmods_count}
      ...  rmod_number=${rmod_number}  log_to_console=${log_to_console}  log_prefix=${log_prefix}
    END
    ${sorted_all_rmods_sn_list}=  Copy List  ${all_rmods_sn_list}
    Sort List  ${sorted_all_rmods_sn_list}
    ${admin_rmods_sn_list}=  BTS Get Radio Module Serial Number List
    ${sorted_admin_rmods_sn_list}=  Copy List  ${admin_rmods_sn_list}
    Sort List  ${sorted_admin_rmods_sn_list}
    Lists Should Be Equal  ${sorted_all_rmods_sn_list}  ${sorted_admin_rmods_sn_list}
    Log  ${log_prefix}Radio modules detection complete  console=${log_to_console}
    Log  ${log_prefix}Radio modules list defined in SCFC and CUS config files is the same as radio modules list read from ADMIN
    ...  console=${log_to_console}

Add Dummy Interface
    [Arguments]  ${ip_addr}
    [Documentation]
    ...  Description:
    ...  Keyword adds dummy interface and set given IP address.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address of dummy interface.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run  sudo ip link add dummy0 type dummy
    Run  sudo ip addr add ${ip_addr}/24 dev dummy0

Set 5G Dummy Interface
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword adds dummy interface and sets given IP address needed by UPF NGU.
    ...  It is nedded only to 5GCN configuration in EPC config file (5G SA configuration).
    ...  Fragment of the "epc.lua" file:
    ...  "set_upf id=1 daemon=:$EDAEMON_PORT type=simulated addr=1.2.4.1/24 ngu=192.168.1.123"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${nr_cells_count}=  SCFC Get Cells Count Based On Class
    ...  scfc_file_path=${scfc_file_path}  cell_class=com.nokia.srbts.nrbts:NRCELL
    Run Keyword If  ${nr_cells_count}>0
    ...  Add Dummy Interface  ip_addr=192.168.1.123

Ims2 Get Alarm List
    [Arguments]  ${ims2_file_path}  ${act_category_alarms}  ${alias}=default  ${bts_l_id}=*
    [Documentation]
    ...  Description:
    ...  Keyword gets all alarms which are available in provided ims2 file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ims2_file_path         | Yes  | Path to InfoModel log file to read.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | act_category_alarms    | Yes  | Information about type of alarms reported by the BTS.                      |
    ...  |                        |      | "True" means that new category alarms are raised.                          |
    ...  |                        |      | "False" means that legacy alarms are raised.                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of execution alias (context).                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_l_id               |  No  | Left (1) or right (4) side of BTS.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    @{alarm_list}=  Create List
    @{alarm_change_sets}=  Run Keyword If  ${act_category_alarms}
    ...  Get Change Sets  filename=${ims2_file_path}  event=//FRI-${bts_l_id}/ALARM-*  alias=${alias}
    ...  ELSE
    ...  Get Change Sets  filename=${ims2_file_path}  event=//LTS-${bts_l_id}//ALARM_L-*  alias=${alias}
    FOR  ${alarm_change}  IN  @{alarm_change_sets}
      Run Keyword If  '${alarm_change.action}' == 'Update'
      ...  Remove From Dictionary  ${alarm_change.object}  lastUpdateTime
      ${status}=  Run Keyword If  '${alarm_change.action}' == 'Update'
      ...  Run Keyword And Return Status  List Should Not Contain Value  ${alarm_list}  ${alarm_change.object}
      ...  ELSE
      ...  Set Variable  ${FALSE}
      Run Keyword If  ${status}  Append To List  ${alarm_list}  ${alarm_change.object}
    END
    [Return]  ${alarm_list}

Ims2 Check Create Alarm
    [Arguments]  ${ims2_file_path}  ${act_category_alarms}  ${alarm_detail}  ${alias}=default  ${bts_l_id}=*
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the specified alarm (${alarm_detail}) has created.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ims2_file_path         | Yes  | Path to InfoModel log file to read.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | act_category_alarms    | Yes  | Information about type of alarms reported by the BTS.                      |
    ...  |                        |      | "True" means that new category alarms are raised.                          |
    ...  |                        |      | "False" means that legacy alarms are raised.                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_detail           | Yes  | Name of the checked alarm.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution alias (context).                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_l_id               |  No  | Left (1) or right (4) side of BTS.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    @{infomodel_create_alarms}=  Run Keyword If  ${act_category_alarms}
    ...  Get Change Sets  filename=${ims2_file_path}
    ...  event=create //FRI-${bts_l_id}/ALARM-* [alarmText.alarmDetail=${alarm_detail}]  alias=${alias}
    ...  ELSE
    ...  Get Change Sets  filename=${ims2_file_path}
    ...  event=create //LTS-${bts_l_id}//ALARM_L-* [alarmText.alarmDetail=${alarm_detail}]  alias=${alias}
    ${infomodel_create_alarms_number}=  Get Length  item=${infomodel_create_alarms}
    ${alarm_exist}=  Set Variable If  ${infomodel_create_alarms_number}==${0}  False  True
    [Return]  ${alarm_exist}

Check And Remove No Connection To Unit Alarm
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the alarm "No Connection To Unit Alarm" has occured.
    ...  Keyword is used to prevent detection of alarm 10 occurring during CUS configuration
    ...  and then detection of alarm 10 through the Truck Roll procedure.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ims2_file_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/infomodel.ims2
    Save Infomodel Log  filename=${ims2_file_path}  timeout=360
    ${alarm_exist}=  Ims2 Check Create Alarm  ims2_file_path=${ims2_file_path}
    ...  act_category_alarms=${ACT_CATEGORY_ALARMS}  alarm_detail="No connection to unit"
    Remove File  path=${ims2_file_path}
    Return From Keyword If  '${alarm_exist}'=='False'
    Remove Values From List  ${TRUCK_ROLL_FID_LIST}  ${10}
    Perform Reconnect InfoModel

Get CUS Software Version And Date
    [Arguments]  ${ip_addr}=192.168.200.1
    [Documentation]
    ...  Description:
    ...  Keyword gets CUS software version (and date) installed on device gived by IP address.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address of CUS device.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${sw_version}=  Run  ssh -q ${ip_addr} ls /rom/TargetBD_*.xml
    ${sw_version}=  Get Substring  ${sw_version}  -24  -4
    ${sw_date}=  Get Substring  ${sw_version}  -8  -2
    [Return]  ${sw_version}  ${sw_date}

Yaft Get Existence Status
    [Arguments]  ${yaft_local_dir}
    ${yaft_status}=  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${yaft_local_dir}/yaft.py
    [Return]  ${yaft_status}

Yaft Svn Download
    [Arguments]  ${yaft_local_dir}
    ${username}=  Set Variable  ca_ute_test
    ${password}=  Set Variable  utetest
    ${yaft_path}=  Set Variable  https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk/
    Yaft Svn Local Checkout  yaft_local_dir=${yaft_local_dir}  yaft_path=${yaft_path}
    ...  username=${username}  password=${password}

Yaft Svn Local Checkout
    [Arguments]  ${yaft_local_dir}  ${yaft_path}  ${username}  ${password}
    Create Directory  path=${yaft_local_dir}
    Run  command=svn checkout --username ${username} --password ${password} ${yaft_path} ${yaft_local_dir}

Get BTS Software
    [Arguments]  ${sw_dir_path}  ${sw_version}  ${sw_timeout}=30m  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword download BTS software to destination path.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | sw_dir_path            | Yes  | Path to the directory software.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sw_version             | Yes  | Software version to download, for example SBTS00_ENB_9999_231105_000007.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sw_timeout             |  No  | Tmeout for downloading single software package.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${repo_url}=  Convert To String  http://files.ute.nsn-rdnet.net/builds/enb/base
    ${build_name}=  Convert To String  ${sw_version}_release_BTSSM_downloadable
    ${wget_status}=  Run And Return Rc  timeout ${sw_timeout} wget ${repo_url}/${sw_version}/${build_name}.zip -P ${sw_dir_path} -T 120
    Run Keyword If  ${wget_status}==${0}
      ...  Log  ${log_prefix}Software downloaded successfully  console=${log_to_console}
    ${software_package_name}=  Run  command=basename ${sw_dir_path}/${build_name}.zip
    [Return]  ${software_package_name}

Verify Ims File Changes
    [Arguments]  ${ims_log_path}  ${impacted_objects}  ${not_impacted_objects}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks in the InfoModel (ims2) file whether the appropriate objects changed or unchanged their state.
    ...  Keyword assumes that the hardware is online when the check is started and changes the status to offline.
    ...  Keyword is, for example, used to check the states of BTS hardware in RAT reset test cases.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ims_log_path           | Yes  | Path to the InfoModel file.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | impacted_objects       | Yes  | Objects that have changed their state.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | not_impacted_objects   | Yes  | Objects that have not changed their state.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in the log console output.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...  Last update: jakub.pachana@nokia.com

    Log  ${log_prefix}The following objects have been changed:  console=${log_to_console}
    FOR  ${object_dist_name}  IN  @{impacted_objects}
      ${offline_status}=  Run Keyword And Return Status
      ...  Find Parameter Change  file_path=${ims_log_path}  dist_name=${object_dist_name}
      ...  parameter=availabilityStatus  value=Regex"(?i)off.*line"
      ${failed_status}=  Run Keyword And Return Status
      ...  Find Parameter Change  file_path=${ims_log_path}  dist_name=${object_dist_name}
      ...  parameter=availabilityStatus  value=Regex"(?i)failed
      IF  'GNCEL' in '${object_dist_name}'
        ${id}=  Fetch From Right  string=${object_dist_name}  marker=CONF_M-
        ${id}=  Fetch From Left  string=${id}  marker=/
        ${object_id}=  Set Variable  GNCELL_R-${id}
      ELSE
        ${object_id}=  Fetch From Right  string=${object_dist_name}  marker=/
      END
      IF  '${offline_status}'=='True'
        Log  ${log_prefix}${object_id} changed to offline  console=${log_to_console}
      ELSE
        Log  ${log_prefix}${object_id} changed to failed  console=${log_to_console}
      END
    END
    Log  ${log_prefix}All expected objects were changed  console=${log_to_console}
    ${unimpacted_objects_status}=  Run Keyword And Return Status  Should Not Be Empty  item=${not_impacted_objects}
    IF  '${unimpacted_objects_status}'=='True'
      Log  ${log_prefix}The following objects have been unchanged:  console=${log_to_console}
    ELSE
      Log  ${log_prefix}All objects have changed!  console=${log_to_console}
    END
    FOR  ${object_dist_name}  IN  @{not_impacted_objects}
      Run Keyword And Expect Error  No change found in*
      ...  Find Parameter Change  file_path=${ims_log_path}  dist_name=${object_dist_name}  parameter=availabilityStatus
      IF  'GNCEL' in '${object_dist_name}'
        ${id}=  Fetch From Right  string=${object_dist_name}  marker=CONF_M-
        ${id}=  Fetch From Left  string=${id}  marker=/
        ${object_id}=  Set Variable  GNCELL_R-${id}
      ELSE
        ${object_id}=  Fetch From Right  string=${object_dist_name}  marker=/
      END
      Log  ${log_prefix}${object_id} remained unchanged  console=${log_to_console}
    END

Verify IQRouting Change Impact
    [Arguments]  ${cells_to_rf}
    [Documentation]
    ...  Description:
    ...  Keyword (test case) checks ASOG behavior after changing parameter "enableInternalIQRouting" in runtime.
    ...  The purpose of this test case is to verify whether FID:1868 is visible after chaning parameter to false on
    ...  particular cells. After disabling IQR, Basic call is performed on not affected cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_to_rf            | Yes  | Dictionary contains cells mapping to RF                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${rf12_type}=  SCFC Get Object Parameter Value
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  dist_name=${mrbts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  parameter_name=port12RATMode
    ${rf12_used}=  Run Keyword And Return Status  Should Not Be Empty  ${rf12_type}
    ${affected}=  Create List
    ${not_affected}=  Create List
    @{cells}=  Get Dictionary Keys  ${cells_to_rf}
    FOR  ${cell}  IN  @{cells}
        ${rf_ports}=  Get From Dictionary  ${cells_to_rf}  ${cell}
        ${is_gncell}=  Run Keyword And Return Status  Should Contain  ${cell}  GNCEL
        ${is_wncell}=  Run Keyword And Return Status  Should Contain  ${cell}  WNCEL
        ${is_lncell}=  Run Keyword And Return Status  Should Contain  ${cell}  LNCEL
        ${is_nrcell}=  Run Keyword And Return Status  Should Contain  ${cell}  NRCELL
        ${is_affected}=  Set Variable  False
        FOR  ${rf}  IN  @{rf_ports}
            ${port_num_str}=  Replace String  ${rf}  RF  ${EMPTY}
            ${port_num}=  Convert To Integer  ${port_num_str}
            IF  (${is_gncell} or ${is_wncell})
                IF  ${port_num} <= 11
                    ${is_affected}=  Set Variable  True
                ELSE IF  ${port_num} == 12 and ${rf12_used} and '${rf12_type}' == '4G5G'
                    ${is_affected}=  Set Variable    True
                END
            END
            IF  (${is_lncell} or ${is_nrcell})
                IF  ${port_num} >= 13 and ${port_num} <= 15
                    ${is_affected}=  Set Variable  True
                ELSE IF  ${port_num} == 12 and ${rf12_used} and '${rf12_type}' == '2G3G'
                    ${is_affected}=  Set Variable    True
                END
            END
        END
        IF  ${is_affected}
            Append To List  ${affected}  ${cell}
        ELSE
            Append To List  ${not_affected}  ${cell}
        END
    END
    [Return]  ${affected}  ${not_affected}

Check And Get SCFC If Big Config Exist
    [Documentation]
    ...  Description:
    ...  Keyword checks whether running configuration is a big one and if so
    ...  downloads SCFC from different repository base on big_config variable.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${big_config}=  Run Keyword And Return Status  Variable Should Exist  ${BIG_CONFIG_PATH}
    Return From Keyword If  '${big_config}'=='False'
    ${big_config_path}=  Replace String  ${BIG_CONFIG_PATH}  /  %2F
    ${scfc_name}=  Fetch From Right  ${scfc_reference_file_path}  /
    ${repository_path}=  Set Variable  https://wrgitlab.ext.net.nokia.com/api/v4/projects/pachana%2Fmax_configuration/repository/files
    Run  command=curl --header "PRIVATE-TOKEN: X9mypvRxx16MNybvvUZK" -o ${scfc_name} "${repository_path}/${big_config_path}/raw?ref=main"
    Run  command=mv ${scfc_name} ${scfc_reference_file_path}

#NOT USED
#Get Executor Version And Date
#    [Documentation]
#    ...  Description:
#    ...  Keyword gets executor version and date.
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    Connect to executor
#    ${build_version}=  Get Version
#    ${version_list}=  Split String  string=${build_version}  separator=.
#    ${build_date}=  Get From List  ${version_list}  -2
#    [Return]  ${build_version}  ${build_date}

#CUS Get Wts Config Files
#    [Arguments]  ${list_of_cus_ips}  ${destination_path}=${SUITE_LOGS_DIR_PATH}
#    [Documentation]
#    ...  Description:
#    ...  Keyword copies iphy.xml from all CUS to specified destination folder.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | destination_path       |  No  | Destination path where iphy.xml will be copied.                            |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    ${number_of_cus}=  Get Length  item=${list_of_cus_ips}
#    FOR  ${cus_index}  IN RANGE  ${number_of_cus}
#      ${active_partition_path}=  tafssh.Execute
#      ...  command=readlink -f /ffs/run
#      ...  connection=${list_of_cus_ips[${cus_index}]}
#      ${result_list}=  Get Regexp Matches  string=${active_partition_path}  pattern=\/ffs\/fs\\d
#      ${active_partition_path}=  Set Variable  ${result_list[0]}
#      tafssh.Download File
#      ...  remote_path=${active_partition_path}/simmode/iphy.xml
#      ...  local_path=${destination_path}/WTS_${list_of_cus_ips[${cus_index}]}.xml
#      ...  connection=${list_of_cus_ips[${cus_index}]}
#    END

#Ims2 Check BTS Reset Cause Alarm
#    [Arguments]  ${ims2_file_path}  ${act_category_alarms}  ${alias}=default  ${bts_l_id}=*
#    [Documentation]
#    ...  Description:
#    ...  Keyword checks if the "Check BTS Reset Cause" fault appears and whether the fault disappears after 30 seconds.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | ims2_file_path         | Yes  | Path to InfoModel log file to read.                                        |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | act_category_alarms    | Yes  | Information about type of alarms reported by the BTS.                      |
#    ...  |                        |      | "True" means that new category alarms are raised.                          |
#    ...  |                        |      | "False" means that legacy alarms are raised.                               |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | alias                  | Yes  | Name of execution alias (context).                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | bts_l_id               |  No  | Left (1) or right (4) side of BTS.                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    ${reset_scenario}=  Run Keyword And Return Status  Variable Should Exist  ${reset_time_stamp}
#    IF  ${reset_scenario}
#      ${current_data}=  Get Current Date  time_zone=UTC
#      ${diff}=  Subtract Date From Date  ${current_data}  ${reset_time_stamp}  result_format=number  exclude_millis=yes
#      ${target}=  Set Variable  480
#      ${4592_awaiting}=  Set Variable  90
#      Run Keyword If  ${diff} < ${target}  Sleep  ${4592_awaiting}
#    END
#    @{infomodel_create_alarms}=  Run Keyword If  ${act_category_alarms}
#    ...  Get Change Sets  filename=${ims2_file_path}
#    ...  event=create //FRI-${bts_l_id}/ALARM-* [alarmText.alarmDetail="BTS Reset Cause"]  alias=${alias}
#    ...  ELSE
#    ...  Get Change Sets  filename=${ims2_file_path}
#    ...  event=create //LTS-${bts_l_id}//ALARM_L-* [alarmText.alarmDetail="BTS Reset Cause"]  alias=${alias}
#     @{infomodel_remove_alarms}=  Run Keyword If  ${act_category_alarms}
#    ...  Get Change Sets  filename=${ims2_file_path}
#    ...  event=remove //FRI-${bts_l_id}/ALARM-* [alarmText.alarmDetail="BTS Reset Cause"]  alias=${alias}
#    ...  ELSE
#    ...  Get Change Sets  filename=${ims2_file_path}
#    ...  event=remove //LTS-${bts_l_id}//ALARM_L-* [alarmText.alarmDetail="BTS Reset Cause"]  alias=${alias}
#    ${infomodel_create_alarms_number}=  Get Length  item=${infomodel_create_alarms}
#    ${infomodel_remove_alarms_number}=  Get Length  item=${infomodel_remove_alarms}
#    Run Keyword And Ignore Error
#    ...  Should Be Equal As Integers  first=${infomodel_create_alarms_number}  second=${infomodel_remove_alarms_number}
#    Return From Keyword If  ${infomodel_create_alarms_number}==${0}
#    Syslog Check BTS Reset Cause Alarm

#Syslog Check BTS Reset Cause Alarm
#    [Documentation]
#    ...  Description:
#    ...  Keyword checks whether FID:4592 "BTS Reset Cause" is set and cancelled properly based on syslog.
#    ...  Keyword uses string operations to pull timestamps out of syslog prints and data time to verify
#    ...  whether given cancelation time is expected for all occurrences.
#    ...
#    ...  Author: jakub.pachana@nokia.com
#    ...  Maintainer: jakub.pachana@nokia.com
#
#    ${alarm_result}=  Run Keyword And Return Status  Assert Alarm Active  faultId=4592  timeout=2
#    ${fault_4592_cancellation_timer}=  SCFC Get Object Parameter Value
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  dist_name=${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
#    ...  parameter_name=fault4592CancellationTimer
#    ${threshold}=  Evaluate  ${fault_4592_cancellation_timer}+5
#    Run Keyword If  ${alarm_result}==True  Sleep  ${threshold}
#    ${create_string}=  syslog.Message Should Exist In Syslog File  regexp=AlarmBuffer.*set.*4592.*
#    ${remove_string}=  syslog.Message Should Exist In Syslog File  regexp=AlarmBuffer.*cancel.*4592.*
#    @{create_lines}=  Split String  string=${create_string}  separator=\n
#    @{remove_lines}=  Split String  string=${remove_string}  separator=\n
#    @{create_list}=  Create List
#    FOR  ${line}  IN  @{create_lines}
#        ${line}=  Strip String  string=${line}
#        Run Keyword If  '${line}' != ''  Append To List  ${create_list}  ${line}
#    END
#    @{remove_list}=  Create List
#    FOR  ${line}  IN  @{remove_lines}
#        ${line}=  Strip String  string=${line}
#        Run Keyword If  '${line}' != ''  Append To List  ${remove_list}  ${line}
#    END
#    ${create_times_count}=  Get Length  item=${create_list}
#    ${remove_times_count}=  Get Length  item=${remove_list}
#    Should Be True  ${create_times_count} == ${remove_times_count}
#    FOR  ${index}  IN RANGE  ${create_times_count}
#        ${create_entry}=  Set Variable  ${create_list[${index}]}
#        ${remove_entry}=  Set Variable  ${remove_list[${index}]}
#        ${create_split_entry}=  Split String  string=${create_entry}  separator=:  max_split=1
#        ${create_time_part}=  Get Substring  string=${create_split_entry[1]}  start=6
#        ${create_time}=  Fetch From Left  string=${create_time_part}  marker=[
#        ${create_time}=  Strip String  string=${create_time}
#        ${remove_split_entry}=  Split String  string=${remove_entry}  separator=:  max_split=1
#        ${remove_time_part}=  Get Substring  string=${remove_split_entry[1]}  start=6
#        ${remove_time}=  Fetch From Left  string=${remove_time_part}  marker=[
#        ${remove_time}=  Strip String  string=${remove_time}
#        ${result}=  Subtract Time From Time  time1=${remove_time}  time2=${create_time}
#        ${result_seconds}=  Convert To Integer  item=${result}
#        Run Keyword If  ${result_seconds} > ${threshold}
#        ...  Fail  The fault 4592 (BTS Reset Cause) was canceled after ${result_seconds} seconds.
#        ...  ELSE
#        ...  Log  The fault 4592 (BTS Reset Cause) was canceled after ${result_seconds} seconds.
#    END

#CUS RMODs Detection
#    [Arguments]  ${list_of_cus_ips}  ${number_of_smod_units}  ${log_to_console}=True  ${log_prefix}=${EMPTY}
#    [Documentation]
#    ...  Description:
#    ...  Keyword detects all CUS simulated radio modules and repeats the action of the first unsuccessful attempt.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | number_of_smod_units   | Yes  | Number of SMOD units.                                                      |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Log text to console.                                                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    ${rmods_detection_status}=  Run Keyword And Return Status
#    ...  Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_to_console=${log_to_console}
#    ...  log_prefix=${log_prefix}
#    Return From Keyword If  ${rmods_detection_status}  Run Keywords
#    ...  Log  ${log_prefix}First attempt of RMODs detection failed  console=True
#    ...  AND
#    ...  Log  ${log_prefix}The snapshot file will be collected and BTS and CUS will be restarted  console=True
#    Collect Snapshot File  logs_dir_path=${SUITE_LOGS_DIR_PATH}  file_name=rmod_detection_snapshot.zip
#    PDU Restart SMOD And CUS And Wait For Availability
#    ...  list_of_cus_ips=${list_of_cus_ips}  number_of_smod_units=${number_of_smod_units}
#    Run Keyword If  ${number_of_smod_units}==2  BTS Start Data Sync With Neighbor Node
#    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_to_console=${log_to_console}
#    ...  log_prefix=${log_prefix}

#CUS Get Parameter Values List For Section Name
#    [Arguments]  ${cusini_file_path}  ${section_name}  ${parameter_name}
#    [Documentation]
#    ...  Description:
#    ...  Keyword gets a list of parameter values of given section in the cus.ini file.
#    ...  Parameter values in the given section are separated by a comma.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | cusini_file_path       | Yes  | Path to the cus.ini file.                                                  |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | section_name           | Yes  | Name of section in the cus.ini file.                                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | parameter_name         | Yes  | Name of parameter of given section in the cus.ini file.                    |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    ${cusini_contents}=  OperatingSystem.Get File  path=${cusini_file_path}
#    ${pre_section}  ${rest_section}=  Split String  string=${cusini_contents}  separator=[${section_name}]
#    ${section}=  Split String  string=${rest_section}  separator=[
#    ${section_line}=  Get Lines Containing String  string=${section[0]}  pattern=${parameter_name}
#    ${parameter_values}=  Fetch From Right  string=${section_line}  marker==
#    ${parameter_values}=  Remove String  ${parameter_values}  ${SPACE}
#    ${parameter_values_list}=  Split String  string=${parameter_values}  separator=,
#    [Return]  ${parameter_values_list}

#Set Prefix Variables
#    [Arguments]  ${log_steps}=True
#    [Documentation]
#    ...  Description:
#    ...  Keyword sets the log prefix variables.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  |  log_steps             | No   | Logs message to console.                                                   |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    Set Suite Variable  ${start_prefix_green}  [${green}START${nc}]${SPACE}
#    Set Suite Variable  ${dots_prefix_green}  [${green}... ${nc}]\t
#    Set Suite Variable  ${ok_prefix_green}  [${green} OK ${nc}]\t
#    Set Suite Variable  ${done_prefix_green}  [${green}DONE${nc}]\t
#    Set Suite Variable  ${start_prefix_blue}  [${blue}START${nc}]${SPACE}
#    Set Suite Variable  ${dots_prefix_blue}  [${blue}... ${nc}]\t
#    Set Suite Variable  ${ok_prefix_blue}  [${blue} OK ${nc}]\t
#    Set Suite Variable  ${done_prefix_blue}  [${blue}DONE${nc}]\t
#    ${info_prefix}=    Set Variable If  ${log_steps}  \t  \n
#    Set Suite Variable  ${info_prefix}  ${info_prefix}

#CUS Create Cells List
#    [Arguments]    ${cusini_file_path}
#    [Documentation]    Keyword creates a list of cells based on the sector section in the cusini file.
#    ...    Author: slawomir.jastrzebski@nokia.com
#    ...    Maintainer: slawomir.jastrzebski@nokia.com
#    ${cells_list}=    Create List
#    ${cusini_contents}=    OperatingSystem.Get File    ${cusini_file_path}
#    ${sector_lines}=    Get Lines Containing String    ${cusini_contents}    sector_
#    @{sectors_list}=   Split To Lines    ${sector_lines}
#    :FOR  ${sector}  IN  @{sectors_list}
#    \  ${cell_number}=    Remove String    ${sector}    sector_    [    ]
#    \  Append To List    ${cells_list}    ${cell_number}
#    [Return]    ${cells_list}

#CUS Create Ctrls List
#    [Arguments]    ${cusini_file_path}
#    [Documentation]    Keyword creates a list of ctrls based on the ctrl section in the cusini file.
#    ...    Author: slawomir.jastrzebski@nokia.com
#    ...    Maintainer: slawomir.jastrzebski@nokia.com
#    ${ctrls_list}=    Create List
#    ${cusini_contents}=    OperatingSystem.Get File    ${cusini_file_path}
#    ${ctrl_lines}=    Get Lines Containing String    ${cusini_contents}    ctrl_
#    @{ctrl_list}=    Split To Lines    ${ctrl_lines}
#    :FOR  ${ctrl}  IN  @{ctrl_list}
#    \  ${ctrl_name}=    Remove String    ${ctrl}    [    ]
#    \  Append To List    ${ctrls_list}    ${ctrl_name}
#    [Return]    ${ctrls_list}

#CUS Create Rmods Serial Number List
#    [Arguments]    ${cusini_file_path}    ${ctrl_list}
#    [Documentation]    Keyword creates a list of rmods serial number based on the sectors parameter
#    ...    in the ctrl section in the cus.ini file.
#    ...    Author: slawomir.jastrzebski@nokia.com
#    ...    Maintainer: slawomir.jastrzebski@nokia.com
#    ${rmods_serial_number_list}=    Create List
#    ${cusini_contents}=    OperatingSystem.Get File    ${cusini_file_path}
#    ${ctrl_count}=    Get Length    ${ctrl_list}
#    :FOR  ${ctrl_number}  IN RANGE  ${ctrl_count}
#    \  ${pre_ctrl_section}    ${rest_section}=    Split String    ${cusini_contents}    [${ctrl_list[${ctrl_number}]}]
#    \  ${ctrl_section}=    Split String    ${rest_section}    [
#    \  ${sectors_line}=	Get Lines Containing String	   ${ctrl_section[0]}    sectors
#    \  ${sectors}=    Fetch From Right    ${sectors_line}    =
#    \  ${sectors}=    Remove String    ${sectors}    ${SPACE}
#    \  ${rmods_number_list}=    Split String    ${sectors}    ,
#    \  ${rmods_name_list}=    CUS Create Rmods List For One Ctrl    ${rmods_number_list}    ${ctrl_number}
#    \  Append To List    ${rmods_serial_number_list}    @{rmods_name_list}
#    [Return]    ${rmods_serial_number_list}

#CUS Create Rmods List For One Ctrl
#    [Arguments]    ${rmods_number_list}    ${ctrl_number}
#    [Documentation]    Keyword creates a list of rmods serial number for one CUS (ctrl).
#    ...    Author: slawomir.jastrzebski@nokia.com
#    ...    Maintainer: slawomir.jastrzebski@nokia.com
#    ${rmods_name_list}=    Create List
#    ${ctrl_number}=    Evaluate    ${ctrl_number}+1
#    :FOR  ${rmod_number}  IN  @{rmods_number_list}
#    \  ${rmod_number}=    Convert To Integer    ${rmod_number}
#    \  ${rmod_full_number}=    Evaluate    (10000*${ctrl_number})+${rmod_number}
#    \  ${rmod_full_number}=    Convert To String    ${rmod_full_number}
#    \  Append To List    ${rmods_name_list}    CUS000${rmod_full_number}
#    [Return]    ${rmods_name_list}

