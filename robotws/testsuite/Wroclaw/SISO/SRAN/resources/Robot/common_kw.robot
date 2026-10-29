*** Settings ***
Documentation  Common resources keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.ul.oam_kpi_calculations    WITH NAME    kpi

*** Keywords ***
Set Message Colors
    [Documentation]
    ...  Description:
    ...  Keyword sets the variables used to set the color of the displayed message.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ${nc}=  Evaluate  "\\033[0m"
    Set Suite Variable  ${nc}
    ${bold}=  Evaluate  "\\033[1m"
    Set Suite Variable  ${bold}
    ${underscore}=  Evaluate  "\\033[4m"
    Set Suite Variable  ${underscore}
    ${green}=  Evaluate  "\\033[32m"
    Set Suite Variable  ${green}
    ${red}=  Evaluate  "\\033[31m"
    Set Suite Variable  ${red}
    ${white}=  Evaluate  "\\033[37m"
    Set Suite Variable  ${white}
    ${blue}=  Evaluate  "\\033[34m"
    Set Suite Variable  ${blue}
    ${yellow}=  Evaluate  "\\033[33m"
    Set Suite Variable  ${yellow}

Set Color Prefix Variables
    [Documentation]
    ...  Description:
    ...  Keyword sets color log prefix variables.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Suite Variable  ${passed_result}       [${green}PASSED${nc}]
    Set Suite Variable  ${failed_result}       [${red}FAILED${nc}]
    Set Suite Variable  ${start_prefix_green}  [${green}START${nc}]${SPACE}
    Set Suite Variable  ${dots_prefix_green}   [${green}...${SPACE}${nc}]\t(Starting)${SPACE}
    Set Suite Variable  ${ok_prefix_green}     [${green}${SPACE}OK${SPACE}${nc}]\t(Done)${SPACE}
    Set Suite Variable  ${done_prefix_green}   [${green}DONE${nc}]\t
    Set Suite Variable  ${start_prefix_blue}   [${blue}START${nc}]${SPACE}
    Set Suite Variable  ${dots_prefix_blue}    [${blue}...${SPACE}${nc}]\t(Starting)${SPACE}
    Set Suite Variable  ${ok_prefix_blue}      [${blue}${SPACE}OK${SPACE}${nc}]\t(Done)${SPACE}
    Set Suite Variable  ${done_prefix_blue}    [${blue}DONE${nc}]\t
    Set Suite Variable  ${end_prefix_blue}     [${blue}${SPACE}END${SPACE}${nc}]\t
    Set Suite Variable  ${info_prefix}         \t(Info)${SPACE}
    Set Suite Variable  ${below_info_prefix}   \t${SPACE * 7}

Set Empty Prefix Variables
    [Documentation]
    ...  Description:
    ...  Keyword sets empty log prefix variables.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Suite Variable  ${start_prefix_green}  ${EMPTY}
    Set Suite Variable  ${dots_prefix_green}   ${EMPTY}
    Set Suite Variable  ${ok_prefix_green}     ${EMPTY}
    Set Suite Variable  ${done_prefix_green}   ${EMPTY}
    Set Suite Variable  ${start_prefix_blue}   ${EMPTY}
    Set Suite Variable  ${dots_prefix_blue}    ${EMPTY}
    Set Suite Variable  ${ok_prefix_blue}      ${EMPTY}
    Set Suite Variable  ${done_prefix_blue}    ${EMPTY}
    Set Suite Variable  ${end_prefix_blue}     ${EMPTY}
    Set Suite Variable  ${info_prefix}         ${EMPTY}
    Set Suite Variable  ${below_info_prefix}   ${EMPTY}

Set Log Prefix
    [Arguments]  ${set_prefix}=True
    [Documentation]
    ...  Description:
    ...  Keyword sets the log prefix variables.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  |  set_prefix            | No   | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${set_prefix}  Set Color Prefix Variables
    ...  ELSE  Set Empty Prefix Variables

Ip Address Is Accessible
    [Arguments]  ${ip_addr}
    [Documentation]
    ...  Description:
    ...  Keyword checks if IP address is pingable.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address of device.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rc}=  Run And Return Rc  command=ping -c 1 ${ip_addr}
    Should Be Equal As Integers  first=${rc}  second=0

Ip Address Is Available
    [Arguments]  ${ip_addr}  ${timeout}=240
    [Documentation]
    ...  Description:
    ...  Keyword checks if IP address is available (pingable).
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for IP address availability.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10
    ...  Ip Address Is Accessible  ip_addr=${ip_addr}

Ip Address Is Unavailable
    [Arguments]  ${ip_addr}  ${timeout}=240
    [Documentation]
    ...  Description:
    ...  Keyword checks if IP address is unavailable (not pingable).
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for IP address unavailability.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10
    ...   Run Keyword And Expect Error  *  Ip Address Is Accessible  ip_addr=${ip_addr}

Unzip File
    [Arguments]  ${dir_path}  ${filename}
    [Documentation]
    ...  Description:
    ...  Keyword unpacks file.
    ...  ZIP file is unpacked into a subdirectory of the directory where it was located.
    ...  ZIP file is unpacked into a subdirectory with the same name as the ZIP file name.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dir_path               | Yes  | Path to the directory where ZIP file is located.                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | filename               | Yes  | Name of ZIP file.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    File Should Exist  path=${dir_path}/${filename}.zip
    ...  msg=File ${dir_path}/${filename}.zip does not exist !!!
    ${unzip_result}=  Run and Return Rc  command=unzip -o '${dir_path}/${filename}.zip' -d '${dir_path}/${filename}'
    Run Keyword If  ${unzip_result}!=0
    ...  Fail  Cannot unzip file ${filename}.zip !!!

Get Kpi Values
    [Arguments]  ${logs_dir_path}  ${kpi_names}  ${kpi_params}=${None}
    [Documentation]
    ...  Description:
    ...  Keyword get calculated kpi values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  |  Path to directory where ims2 file should be stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | kpi_names              | Yes  | List of kpi names.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | kpi_params             |  No  | Additional kpi parameters.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${kpi_dict}=  Create Dictionary
    admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${logs_dir_path}/${TEST NAME}/IM_infomodel_kpi.ims2
    ...  timeout=120  leave_disconnect_logs=True
    ${extended_ims}=  Run Keyword And Return Status
    ...  File Should Exist  ${logs_dir_path}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
    IF  ${extended_ims}
      ${ims_file_path}=  Create List
      Append To List  ${ims_file_path}  ${logs_dir_path}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
      Append To List  ${ims_file_path}  ${logs_dir_path}/${TEST NAME}/IM_infomodel_kpi.ims2
      ${merge_ims_files}=  Set Variable  True
    ELSE
      ${ims_file_path}=  Set Variable  ${logs_dir_path}/${TEST NAME}/IM_infomodel_kpi.ims2
      ${merge_ims_files}=  Set Variable  False
    END
    ${kpi_results}=  kpi.Calculate Kpis  kpi_names=${kpi_names}
    ...  ims_file_path=${ims_file_path}
    ...  kpi_params=${kpi_params}  merge_ims_files=${merge_ims_files}
    FOR  ${kpi_name}  IN  @{kpi_names}
      ${kpi}=  kpi.Get All Deltas  kpi_name=${kpi_name}
      ${kpi_value}=  Run Keyword And Continue On Failure  Set Variable  ${kpi[-1]}
      Set To Dictionary  ${kpi_dict}  ${kpi_name}=${kpi_value}
#      kpi.Save Results To File  file_path=${logs_dir_path}/${TEST NAME}/${kpi_name}.json
    END
    kpi.Clear Results
#    Run Keyword And Ignore Error  Remove Files  ${logs_dir_path}/${TEST NAME}/IM_infomodel_kpi.ims2
    [Return]  ${kpi_dict}
