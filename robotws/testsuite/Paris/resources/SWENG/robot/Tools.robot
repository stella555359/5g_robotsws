*** Settings ***
Documentation
...             == Purpose ==
...             Library that groups a mix of several tools for display, conversion, dictionary manipulation...
...
...             == Description ==
...             This is a tool box, no particular global description
...

Library                             OperatingSystem
Library                             Collections
Library                             String
Library                             DateTime
Library                             ../python/StringTool.py
Library                             ../python/OsTool.py
Library                             BuiltIn


*** Keywords ***
#===================================
# TRACES
#===================================
Dated Log
    [Documentation]                 Trace a string into console, prefixed with a timestamp
    ...                             Example : Dated log     Starting CellSetup
    ...                             will generated in console following kind of trace:
    ...                                  [15:59:18] Starting CellSetup
    ...                             If first is set to True, a CarriageReturn is previously printed
    ...                             to ensure trace will start on another line
    ...                             Deep is number of tab to be inserted after time stamp. Default nb is 0
    [Arguments]                     ${msg}                                      ${first}=${False}
    ...                             ${deep}=${0}
    ...                             ${isConsole}=${True}                        ${isLogFile}=${True}
    StringTool.datedConsole         str=${msg}                                  deep=${deep}
    ...                             first=${first}
    ...                             isConsole=${isConsole}                      isLogFile=${isLogFile}

Dated log in file
    [Documentation]                 Trace a message into a file.
    ...                             If first is set to True, a CarriageReturn is previously printed
    ...                             to ensure trace will start on another line
    ...                             Deep is number of tab to be inserted after time stamp. Default nb is 0
    [Arguments]                     ${file}
    ...                             ${msg}                                      ${first}=${False}
    ...                             ${deep}=${0}
    StringTool.datedConsoleInFile   file=${LOG_PATH}/${file}                    str=${msg}
    ...                             deep=${deep}                                first=${first}


Dated Log New Line
    [Documentation]                 Invoke a Carriage return, then Trace a string into console, prefixed with a timestamp
    [Arguments]                     ${msg}
    ...                             ${isConsole}=${True}                        ${isLogFile}=${True}
    Dated Log                       ${msg}                                      first=${True}
    ...                             isConsole=${isConsole}                      isLogFile=${isLogFile}

Traced Sleep
    [Documentation]                 Trace a log detailing duration of next sleep, then perform the sleep
    ...                             msg is to print a particular message during the wait process
    [Arguments]                     ${duration}                                 ${msg}=unspecified reason
    ${end_wait_time}                DateTime.Get Current date                   increment=${duration}
    Dated Log                       Waiting ${duration} for ${msg} until ${end_wait_time}
    Sleep                           ${duration}

Set Debug Mode
    [Documentation]                 Set Debug Mode by setting global variable ${SUITE_DEBUG_MODE}
    ...                             before calling 'Debug Log Dated'
    [Arguments]                     ${val}=${True}
    Set Suite Variable              ${SUITE_DEBUG_MODE}    ${val}

Debug Dated Log
    [Documentation]                 Log with 'Dated Log' if debug mode is set by 'Set Debug Mode'
    ...                             Example of usage:
    ...                             Set Debug Mode      ${True}
    ...                             Debug Dated Log     Starting CellSetup
    [Arguments]                     ${msg}                                      ${first}=False
    ${result}=                      Run Keyword And Return Status    Variable Should Exist    ${SUITE_DEBUG_MODE}
    Run Keyword If                  ${result}==False       BuiltIn.log           INFO: 'Set Debug Mode' not set
    ...                             ELSE                    Run Keyword If      ${SUITE_DEBUG_MODE}
    ...                                                     Dated Log           DEBUG: ${msg}        ${first}

Debug PMC Log
    [Documentation]                 For Debug PM ONLY 'Dated Log'
    ...                             'Dated Log' if ${simu_glo_pm_file} is set to True
    [Arguments]                     ${msg}
    ${result}=                      OsTool.pmcDebug
    Run Keyword If                  ${result}==True         Dated Log           DEBUG_PM True: ${msg}


#===================================
# Run KW
#===================================
Run Optional Action
    [Documentation]                 Run and trace an action ONLY if a condition is filled
    [Arguments]                     ${optional_operation}=None
    ...                             ${params}=
    Run Keyword If                  '${optional_operation}'!='None'
    ...                             Run and Trace Action
    ...                                 ${optional_operation}               ${params}

Run and Trace Action
    [Documentation]                 Run a KW (with some optional params),
    ...                             but put some traces in console before and after action
    [Arguments]                     ${optional_operation}=None
    ...                             ${params}=
    Dated log                       Starting ${optional_operation}
    Run Keyword And Ignore Error    ${optional_operation}    ${params}
    Dated log                       Ended ${optional_operation}

#===================================
# HTTP Proxy management
#===================================
Backup https proxy
    [Documentation]                 Perform a backup of environment variable <https_proxy>
    ${https_proxy}=                 Get Environment Variable                https_proxy         default=
    Set suite variable              ${https_proxy}
    Set Environment Variable        https_proxy                             ${EMPTY}

Restore https proxy
    [Documentation]                 Perform a restore of environment variable <https_proxy> previously saved
    Set Environment Variable        https_proxy                             ${https_proxy}

#===================================
# MISC
#===================================
Is Var Exist
    [Documentation]                 Check if a variable is defined in robot context
    ...                             Ex: ${status}     Is Var Exist            \${ASIK_SWITCH_TAGS}
    ...                             Will return True or False upon variable is defined
    [Arguments]                     ${var}
    ${status}                       run keyword and return status
    ...                             variable should exist       ${var}
    [Return]                        ${status}

Is Key Exist
    [Documentation]                 Check in a dictionary that a key exist
    [Arguments]                     ${var}
    ...                             ${key}
    ${status}                       run keyword and return status
    ...                             Dictionary should contain key
    ...                             ${var}      ${key}
    [Return]                        ${status}

Dictionary Get
    [Documentation]                 Perform a copy of a dictionary, and return new dictionary
     ...                            Interest is that original one is not modified
    [Arguments]                     ${dico}
    ${copyDico}                     Copy Dictionary     ${dico}
    [Return]                        ${copyDico}

Get Date Epoch
    [Documentation]                 Returns epoch date in string integer format
    ${date} =                       DateTime.Get Current Date   result_format=epoch
    ${int_epoch} =                  Convert To Integer          ${date}
    ${str_epoch} =                  Convert To String           ${int_epoch}
    [Return]                        ${str_epoch}

Set Suite Var
    [Arguments]                     ${name}                     ${value}
    # Dated log                       NAME=[${name}] VAL=[${value}]
    Set Suite variable              ${${name}}                  ${value}

Get Number Of Not None Element in List
    [Documentation]                 Returns the number of not 'None' element in the list
    [Arguments]                     ${my_list}
    ${nbOfElement}=                 set variable    ${0}
    FOR     ${elem}     IN          @{my_list}
            ${nbOfElement}=         Set Variable If     '${elem}'!='None'
            ...                                         ${nbOfElement+1}
            ...                                         ${nbOfElement}
    END
    [Return]                        ${nbOfElement}

#===================================
# PowerBI Tools
#===================================
PowerBI Upload PM File
    [Documentation]                 Install PowerBI environment on a Jenkins VM and then transfer PM file to PowerBI database.
    ...
    ...                             *Arguments:*
    ...                             - ${pm_path}: mandatory - Complete path of PM file
    ...                             - ${tc_name}: mandatory - TestName to be created in PowerBI website
    [Timeout]                       5mins
    [Arguments]                     ${pm_path}
    ...                             ${tc_name}

    # Variables needed for PowerBI tools:
    ${random_int}=                  OsTool.GenerateRandomNumber
    ${pwrBI_root_dir}               set variable        /ebs/ca_psci5g/PowerBI_${random_int}
    ${pwrBi_scripts_dir}            set variable        ${pwrBI_root_dir}/ci-scripts/counters_portal
    ${pwrBi_counter_script}         set variable        ${pwrBi_scripts_dir}/et_counters_value.py
    ${gerrit_ci_scripts}            set variable        ssh://gerrit.ext.net.nokia.com:29418/MN/5G/UPLANE/ci-scripts
    ${seesetenv}                    set variable        /opt/EE_LinSEE/bin/seesetenv
    ${python_sql_connector}         set variable        python-mysql-connector=8.0.16.p362
    ${python3_request}              set variable        python3-requests=2.18.4.p362
    ${branch}                       set variable        MASTER
    ${swVersion}                    set variable        ${GNB_BTS_INFO['swInfo']['swVersion']}

    # Connection to Espoo VM:
    ${alias}                        Connect to Espoo Vm

    # Check if load is a Trunk load. If not, display a warning message and exit the keyword
    Run Keyword If                  'SBTS00' not in '${TLConfig.topo.gnbVersion}'
    ...                             Run Keywords
    ...                                 Dated Log       =============================================================================
    ...         AND                     Dated Log       WARNING: GNB LOAD IS ${TLConfig.topo.gnbVersion}
    ...         AND                     Dated Log       \t => AS IT IS NOT A TRUNK LOAD, PowerBI WILL THEREFORE NOT BE UPDATED!!!
    ...         AND                     Dated Log       =============================================================================
    ...         AND                     Return from Keyword

    # PowerBI Tools Installation:
    Dated log                       PowerBI Tools Setup...
    ${cmd}=                         Catenate            mkdir -p ${pwrBI_root_dir};
    ...                                                 cd ${pwrBI_root_dir};
    ...                                                 git clone ${gerrit_ci_scripts}
    Dated Log                       ... command is: ${cmd}
    ${output}=                      ssh.execute         ${cmd}      connection=${alias}
    Should Not Contain              ${output}           Error

    # PowerBI PM File Transfer:
    Dated log                       PM file to add to PowerBI DB is: ${pm_path}
    ${pm_file}                      getFileNameFromPath     ${pm_path}
    ${xmlFile}                      set variable            ${pwrBI_root_dir}/${pm_file}
    ${output}=                      ssh.upload File
    ...                                 local_path=${pm_path}
    ...                                 remote_path=${xmlFile}
    ...                                 connection=${alias}
    ${cmd}=                         Set Variable        ls -l ${xmlFile}
    ${output}=                      ssh.execute         ${cmd}      connection=${alias}
    Should Not Contain              ${output}           No such file or directory

    # PowerBI DataBase Update:
    Dated log                       PowerBI DB Update...
    ${cmd}=                         Catenate            cd ${pwrBi_scripts_dir};
    ...                                                 source ${seesetenv} ${python_sql_connector} ${python3_request};
    ...                                                 python3 ${pwrBi_counter_script}
    ...                                                     --xmlFile ${xmlFile}
    ...                                                     --swVersion ${swVersion}
    ...                                                     --branch ${branch}
    ...                                                     --testName ${tc_name}
    Dated Log                       ... command is: ${cmd}
    ${output}=                      ssh.execute         ${cmd}          connection=${alias}
    Should Not Contain              ${output}           Error
    traced sleep                    duration=10s                        msg=Pause...

    [Teardown]                      Run Keywords
    ...                             PowerBI Tmp Dir CleanUp     alias=${alias}
    ...                                                         pwrBI_root_dir=${pwrBI_root_dir}
    ...                         AND
    ...                             Disconnect from Espoo VM    alias=${alias}

PowerBI Tmp Dir CleanUp
    [Arguments]                     ${alias}            ${pwrBI_root_dir}
    Dated Log                       Temporary Directory CleanUp in progress...
    ${cmd}=                         Set Variable        rm -rf ${pwrBI_root_dir}
    ${output}=                      ssh.execute         ${cmd}      connection=${alias}
    Should Be Empty                 ${output}           Command returns this error:${output}
    ${cmd}=                         Set Variable        ls -l ${pwrBI_root_dir}
    ${output}=                      ssh.execute         ${cmd}      connection=${alias}
    Should Contain                  ${output}           No such file or directory

Connect to Espoo VM
    [Documentation]                 SSh connect to Espoo VM
    [Arguments]                     ${alias}=ssh_espoo
    # ssh.Connect_to                  hostname=10.183.33.106
    # ssh.Connect_to                  hostname=10.183.36.241
    ssh.Connect_to                  hostname=10.181.49.46
    ...                             username=ca_psci5g
    ...                             password=Welcome123
    ...                             alias=${alias}
    [Return]                        ${alias}

Disconnect from Espoo VM
    [Documentation]                 SSh disconnection from Espoo VM
    [Arguments]                     ${alias}
    ssh.disconnect                  connection=${alias}

Download Package Using Git
    [Documentation]                 Allows you to retrieve the specified file from a Git project.
    ...                             The default values are set for the BSR Git project. The content of the project is now more generic,
    ...                             including some testfile for SWENG; in any case the keyword can be used for any Git project.
    ...
    ...                             *Argument details:*
    ...
    ...                             - git_path (mandatory): Git project to be used.
    ...
    ...                             - git_folder (mandatory): Name of the Git repository where the package to retrieve is stored.
    ...
    ...                             - git_file_name (mandatory): Name of the package to retrieve.
    ...
    ...                             - token_name and token_access (mandatory): token and access code to be used with the specified Git project.
    ...
    ...                             - target_dir (optional): TL repository where the package should be stored. Default: ${LOG_PATH}

    [Arguments]                     ${git_folder}       ${git_file_name}
    ...                             ${git_path}=gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ...                             ${token_name}=NpsVrfToken
    ...                             ${token_access}=glpat-4yNB_jaBXxz_BsyeAsgL
    ...                             ${target_dir}=${LOG_PATH}/BSR

    Dated Log                       \tDownloading Git file from: ${git_path}/${git_folder}
    Dated Log                       \tinto the following folder: ${target_dir}
    Dated Log                       \twith the git token access: ${token_name} / ${token_access}
    ${tmp_git_dir}                  set variable                        /tmp/tempGitFiles
    ${git_full_path}=               set variable if                     "${token_name}"!=""     https://${token_name}:${token_access}@${git_path}
    ...                                                                                         https://${git_path}
    # Create target directory and remove the temporary directory used during git clone command:
    Run                             mkdir -p ${target_dir}; rm -rf ${tmp_git_dir}
    ${result}=                      Run                                 git clone ${git_full_path} ${tmp_git_dir}
    ${contains}=                    Run Keyword And Return Status       Should Not Contain      ${result}    fatal
    run keyword if                  "${contains}"=="${True}"
    ...                             Run Keywords    Run                 cp -f ${tmp_git_dir}/${git_folder}/${git_file_name} ${target_dir}/.
    ...                                      AND    Dated Log           File Successfully Downloaded from Git project!
    ...         ELSE                Dated Log                           ERROR: Git Clone Command Failed: ${result}
    # Temporary directory cleanup:
    Run                             rm -rf ${tmp_git_dir}
    [Return]                        ${target_dir}/${git_file_name}