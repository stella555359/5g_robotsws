*** Keywords ***
Build vm alias
    [Arguments]         &{vm_dict}
    ${vm_name_list}             get dictionary keys          ${vm_dict}
    @{list_tmp}                 create list
    :FOR                        ${vm_name}  IN   @{vm_name_list}
    \                           ${alias}            remove string    ${vm_name}     VM
    \                           append to list      ${list_tmp}      ${vm_name}     ${alias}
    log many                    @{list_tmp}
    &{vm_alias_dict}            create dictionary       @{list_tmp}
    set suite variable          &{vm_alias_dict}

Asik Connection
    [Documentation]     Asik ssh connection from OamVM. used for both Asik functions & abil functions
    ...                 TAF used: transport.ssh
    ssh.Connect To					${asik_fh}		toor4nsn		oZPS0POrRieRtu		proxy=${oam_alias} 		alias=asikcnx
    set suite variable              ${asikcnx}      asikcnx

Asik Disconnection
    [Documentation]     Asik ssh disconnection from OamVM. used for both Asik functions & abil functions
    ...                 TAF used: transport.ssh
    ssh.disconnect                  connection=asikcnx

Log Checker Online
    [Documentation]  This keyword check for a given ssh connection and a log path, the presence of a list of elements
    ...              and values that should contain.
    ...              This keyword take as argument:
    ...                    . ${expected_log}  the list of element that is needed to be checked in a log : grep
    ...                    . ${expected_res}  the list of keys that should be contained in the extracted element line
    ...                    . ${connection}    the ssh connection
    ...                    . ${log_path}      the path of the log
    ...                    . ${interval}=5 s    ${timeout}=10 s    ${max_count}=1 : parameters for the Grep function
    ...                    .
    ...                    . TAF used: taf.ul.ssh_addons   WITH NAME   common_ssh_addons  version 1.0.0

    [Arguments]    ${expected_log}  ${expected_res}  ${connection}    ${log_path}    ${interval}=5 s    ${timeout}=10 s    ${max_count}=1

   &{dict}=     create Dictionary
   # Create Dictionnay from the provided list of elements and keys
   ${dict}=     Create_Dict       ${expected_log}  ${expected_res}
   Grep_Check   ${expected_log}   ${connection}    ${log_path}
    ...         ${interval}=5 s   ${timeout}=10 s  ${max_count}=1   &{dict}

Create Dict
    [Documentation]  This keyword take as argument two lists and create a dictionary by association the elements of the
    ...              first list as a dictionary key to the first element of the second list as a dictionary value.

    [arguments]    ${keyword}  ${value}

    #initilization
    ${cnt}=         Get Length          ${keyword}
    ${var}=         set variable        ${0}
    ${var}=         Convert To Integer  ${var}
    @{list}         Create List

    :FOR            ${element}  IN   @{keyword}
    \               append to list      ${list}              ${keyword[${var}]}     ${value[${var}]}
    \               ${var}=             Set Variable If 	 ${var}<${cnt}          ${var + 1}
    &{dict}=        create Dictionary   @{list}
    [Return]        ${dict}

Grep Check
    [Documentation]  This keyword use the grep function of the TAF library to check inside a given log
    ...              This keyword take as arguments:
    ...                    . ${expected_log}  the list of element to be checked
    ...                    . ${connection}    the ssh connection
    ...                    . ${log_path}      the path of the log
    ...                    . ${interval}=5 s  ${timeout}=10 s    ${max_count}=1 : parameters for the Grep function
    ...                    . &{dict}          Dictionary that provide the values that should be contained
    ...                                       in the list of element
    ...                    . TAF used: taf.ul.ssh_addons   WITH NAME   common_ssh_addons  version 1.0.0

    [Arguments]    ${expected_log}    ${connection}    ${log_path}
    ...            ${interval}=5 s    ${timeout}=10 s  ${max_count}=1      &{dict}

    :FOR    ${element}    IN    @{expected_log}
    \               Run Keyword And Continue On Failure    Wait Until Keyword Succeeds       ${timeout}     ${interval}
    ...                                        Grep With Assert    ${element}    ${log_path}    ${connection}    ${max_count}
    \               ${result}=                 Get Last Result
    \               ${result}=                 Convert To String   ${result}
    \               ${expected}                Get From Dictionary   ${dict}        ${element}
    \               Should Contain             ${result}           ${expected}

Grep With Assert
    [arguments]  ${element}    ${log_path}    ${connection}    ${max_count}=1
    ${result}=    common_ssh_addons.Grep File   ${element}    ${log_path}    connection=${connection}    max_count=${max_count}
    Assert Grepper Match
    [Return]    ${result}

Function search filenames
    [Documentation]        Update 20210321 Abderrahmane NEZROUK usage of bsr commands
    [Arguments]             ${path}     ${filename}     ${connection}=No_connection    ${board_socid}=0
    ${output}=              Run Keyword If  '${res_path}' in '${path}'
    ...              Run   ls -lrt ${path} | grep ${filename}
    ...                     ELSE IF    '${board_socid}'=='0'
    ...              ssh.execute     command=ls -lrt ${path} | grep ${filename}      connection=${connection}
    ...                     ELSE
    ...              ssh.execute     command=bsh ${board_socid} ls -lrt ${path} | grep ${filename}      connection=${connection}
    ${l_output}             Get Line Count                      ${output}
    @{lines_list}           Split to lines                      ${output}
    @{result_list}          Create List
    : FOR                   ${index}                            IN RANGE              0                         ${l_output}
    \                       log                                 ${index}
    \                       ${length}                           Get Length               @{lines_list}[${index}]
    \                       ${tmp_string}=                      Fetch from left          @{lines_list}[${index}]             ${filename}
    \                       ${length_tmp_string}                Get Length               ${tmp_string}
    \                       ${sub_result}                       Get Substring            @{lines_list}[${index}]             ${length_tmp_string}
    \                       ${length_s}                         Get Length               ${sub_result}
    \                       Append To List                      ${result_list}           ${sub_result}
    [Return]                @{result_list}

Convert duration in ms
    [Documentation]         This keyword convert different duration format in ms. i.e 10 min -> 10000 ; 2h -> 7200000

    [Arguments]             ${duration}
    ${t}                    Get Regexp Matches    ${duration}   (\\d+)   1
    ${c}                    convert to number   @{t}[0]

    ${multiple}             run keyword if   'h' or 'H' in '${duration}'     set variable         3600000
    ...                     ELSE IF          'm'or 'M' in '${duration}'      set variable           60000
    ...                     ELSE IF          's' or 'S' or 'ec' in '${duration}'    set variable     1000
    ...                     ELSE IF          'ms' or 'Ms' in '${duration}'   set variable       1
    ...                     ELSE             set variable       1
    ${multiple}             convert to number   ${multiple}
    ${duration}             evaluate    ${c} * ${multiple}
    [Return]                ${duration}


Convert tput in kbps
    [Documentation]         This keyword convert different duration format in ms. i.e 10 min -> 10000 ; 2h -> 7200000
    [Arguments]             ${tput}
    ${tput}                 convert to string   ${tput}
    ${t}                    Get Regexp Matches    ${tput}   (\\d+)   1
    ${c}                    convert to number   @{t}[0]
    ${multiple}             run keyword if    'm' in $tput or 'M' in $tput   set variable      1000
    ...         ELSE        set variable      1
    ${multiple}             convert to number   ${multiple}
    ${tput}                 evaluate    ${c} * ${multiple}
    [Return]                ${tput}

Convert tput
    [Documentation]         This keyword convert different duration format in ms. i.e 10 min -> 10000 ; 2h -> 7200000
    [Arguments]             ${tput}     ${tput_unit}=k
    ${tput}                 convert to string   ${tput}
    ${t}                    Get Regexp Matches    ${tput}   (\\d+)   1
    ${c}                    convert to number   @{t}[0]
    ${multiple}             run keyword if    'g' in $tput or 'G' in $tput   set variable      1000000
    ...         ELSE IF     'm' in $tput or 'M' in $tput   set variable      1000
    ...         ELSE        set variable      1
    ${multiple}             convert to number   ${multiple}
    ${tput}                 evaluate    ${c} * ${multiple}
    ${tput}                 run keyword if          'g' in $tput_unit or 'G' in $tput_unit       evaluate      ${tput} / 1000000
    ...         ELSE IF     'm' in $tput_unit or 'M' in $tput_unit   evaluate      ${tput} / 1000
    ...         ELSE        evaluate      ${tput} * 1
    log         ${tput}${tput_unit}
    [Return]                ${tput}${tput_unit}

Wait next meas period
    [Documentation]  This keyword calculate the remaining time (in seconds) till next measurement period
    ...      then it sleeps for this duration (= it waits for the ends of current period)
    ...      (at the moment period is given as argument)
    ...      AUTHOR:  Annie Wong    annie.wong@nokia.com (adapted by Denis Verdier)
     [Arguments]      ${meas_period_in_minute}=15      ${additional_waiting_time_sec}=30
     ${meas_period_in_min}   remove string    ${meas_period_in_minute}    min
     ${d}=    Run   date +"%Y-%m-%d %H:%M:%S.%3N"
     ${current_time}=     Convert Date     ${d}    datetime
     log to console    \n gNB current time:${current_time}

     ${minutes}=    Evaluate   (${current_time.minute}/${meas_period_in_min} + 1)*${meas_period_in_min}
     ${time_delta}=   convert time    00:${minutes}:00   timedelta
     ${secnds}=       Evaluate    (${current_time.second} - ${additional_waiting_time_sec})
     ${subtract}=     Subtract Time From Date     ${current_time}    ${current_time.minute} minutes ${secnds} seconds
     ${next_pm_time}=      Add Time to Date    ${subtract}    ${time_delta}
     log     Next period is (with additional wait time): ${next_pm_time}

     ${waiting_time}=    Subtract Date From Date      ${next_pm_time}    ${current_time}    exclude_millis=false
     ${waiting_time}=    Convert to Integer    ${waiting_time}
     Log               Waiting_time is : ${waiting_time} sec
     #if remaining around 12 min should be ok to run test
     log              ${d} : ${waiting_time}
     #run keyword if  (${waiting_time}-${additional_waiting_time_sec})>700    set variable    ${waiting_time}     1
     sleep    ${waiting_time}

Get reportingIntervalPm
    [Documentation]  Get the configured reportingIntervalPm
    ...      AUTHOR:  Stephane Croquet

    ${xml_root}=   XML.parse xml   ${scf_path}/save_initial_scf.xml
    ${xpath}=  set variable  //managedObject[@distName="MRBTS-${mr_bts}/MNL-1/MNLENT-1/PMCADM-1"]/p[@name="reportingIntervalPm"]
    ${value}=  XML.Get Element Text  ${xml_root}  ${xpath}
    ${value}=  remove string  ${value}  min
    [Return]  ${value}
