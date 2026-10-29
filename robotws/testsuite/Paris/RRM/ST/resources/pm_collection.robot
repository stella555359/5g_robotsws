*** Settings ***
Documentation
...        Keywords Purpose:
...            common keywords to collect pm files
...
...        AUTHOR (I&V):
...            Annie Wong        annie.wong@nokia.com

Library          DateTime
Library          String
Library          OperatingSystem
Library          taf.collectors.pmcounters   WITH NAME  pmcounters
Library          taf.transport.ssh    WITH NAME    csn


*** Keywords ***
#todo supprimer ce kw des autres testcases et les faires pointer sur celui la
Get Counter Value
    [Arguments]     ${counter_name}    ${gnb_id}=0    ${enb_id}=''

    ${res}=      Collect PM Files And Get Last Period Filename
    ...    oam_type=sbts
    ...    name=gnb_pmcounters
    ...    scope=testcase
    ...    gnb_id=${gnb_id}
    ...    enb_id=${enb_id}

    Log     Collect PM Files And Get Last Period Filename res : ${res}

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable    ${PM_PATH}        ${res_path}
    Set Test Variable    ${PM_FILENAME}    ${res}

    ${pi_value}=    pm_analyze.Get Pi Value From File
    ...    pi_dir=${PM_PATH}
    ...    pi_name=${counter_name}
    ...    file_name=${PM_FILENAME}

    [Return]    ${pi_value}


Collect Pm Counters Files Via Dico
    [Documentation]    Create the PM collector (dictionary method), setup the collector, and collect (then teardown)
    ...                If no target_dir is provided to taf keyword, collected files are stored in :
    ...                     ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${name}
    ...                     (since bug fix, PERMON_FILES folder is removed, pm files are directly in
    ...                     result directory with name of collector, for both variant mzOAM and cOAM)
    ...         Arguments :
    ...             oam_type : coam (default) / sbts
    ...             name :  alias for collector(default is pmcounters_collector)
    ...             scope : testcase (default) / testsuite
    ...
    ...       gNB compatibility: CLOUD MZ / CLASSICAL MZ / CLASSICAL COAM
    ...
    ...         25.11.2019: use full name for keywords due to confusion with other collectors (core, tcpdump...)
    ...         09.12.2019: when calling pmcounters.collect_collectors, if testcase is executed through Titan,
    ...                   target_dir should not be provided (because error at target_dir creation, it is not using
    ...                   pull path name). So always use default value=None (ok that the env sets the full path itself)
    ...         07.02.2020: add argument "name" for collector alias
    ...                     add argument "scope" (testcase - default / testsuite)
    ...                       (this will set target_dir, as we might need keyword being executable in setup sequence).
    ...                     set suite scope for alias
    ...         07.08.2020: add gnb_id as argument

    [Arguments]     ${oam_type}=sbts      ${name}=pmcounters_collector     ${scope}=testcase    ${gnb_id}=${0}    ${enb_id}=''

    ${host}=    Set Variable If    ${enb_id} != ''
    ...    ${tl.enbs[${enb_id}].oam_ip.v4}
    ...    ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}

    # gnb and enb have same credentials/port that why we use directly gnb credentials
    ${user}=    Set Variable    ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ${password}=    Set Variable    ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ${port}=    Set Variable    ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}

    ${webservice}=  Create Dictionary
     ...    host=${host}
     ...    user=${user}
     ...    password=${password}
     ...    port=${port}
    log    ${webservice}

    pmcounters.create PM collector       name=${name}     webservice=${webservice}     oam_type=${oam_type}
    pmcounters.Set Suite Alias        ${name}
    pmcounters.setup_collectors       names=${name}

    run keyword if      '${scope}' == 'testcase'
    ...                 pmcounters.collect_collectors       names=${name}
    ...    ELSE         pmcounters.collect_collectors       names=${name}     target_dir=${OUTPUT_DIR}/${SUITE_NAME}

    [Teardown]  pmcounters.teardown_collectors   names=${name}


Collect PM Files And Get Last Period Filename
    [Documentation]   This keyword collects all pm files with keyword Collect Pm Counters Files Via Dico
    ...               and return last period pm filename.
    ...               PM storage path is cleaned before files collection.
    ...               (default storage is: ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${name})
    ...
    ...         Argument :
    ...             oam_type : coam (default) / sbts
    ...             name :  alias for collector(default is pmcounters_collector)
    ...             scope : testcase (default) / testsuite
    ...
    ...       gNB compatibility: CLOUD MZ / CLASSICAL MZ / CLASSICAL COAM
    ...
    ...       AUTHOR:  Annie Wong    annie.wong@nokia.com
    ...       09.12.2019: when calling pmcounters.collect_collectors, if testcase is executed through Titan,
    ...                   target_dir should not be provided. Let the env sets the full path itself.
    ...                   Removed argument ${target_dir}=None
    ...       07.02.2020: add argument "name" for collector alias
    ...                   add argument "scope" (testcase - default / testsuite)
    ...                   (this will set target_dir, as we moight need keyword being executable in setup sequence).
    ...         07.08.2020: add gnb_id as argument

    [Arguments]    ${oam_type}=sbts     ${name}=pmcounters_collector     ${scope}=testcase      ${gnb_id}=${0}    ${enb_id}=''

    ###${pm_path}         set variable        ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/pmcounters_collector
    ${pm_path}=      run keyword if      '${scope}' == 'testcase'
    ...                 set variable        ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${name}
    ...    ELSE         set variable        ${OUTPUT_DIR}/${SUITE_NAME}/${name}
    log    PM storage path=${pm_path}

    #-----   PM path is cleared before pm collection.
    Run keyword and continue on failure      Run    rm "${pm_path}"/*

    log    Start collection...
    pm_collection.Collect Pm Counters Files Via Dico
    ...      oam_type=${oam_type}
    ...      name=${name}
    ...      scope=${scope}
    ...      gnb_id=${gnb_id}
    ...      enb_id=${enb_id}

    #-----   get last PM filename
    ${cmd}=   set variable if    '${oam_type}'=='mzoam'     cd "${pm_path}";ls -dr1 *PM_*_SRAN |head -1
    ...       cd "${pm_path}";ls -dr1 *PM*.xml |head -1
    ${pm_filename}     Run     ${cmd}
    log      Last pmfile = ${pm_filename}
    Return From Keyword     ${pm_filename}


Wait For Next Measurement Period
    [Documentation]  This keyword first get the time in from gNB
    ...      then calculate the remaining time (in seconds) till next measurement period
    ...      then it sleeps for this duration (= it waits for the ends of current period)
    ...      (at the moment period is given as argument)
    ...      AUTHOR:  Annie Wong    annie.wong@nokia.com
    ...      new variable needed in testcase or testsuite: ${DEBUG_MODE_CONSOLE} (value = True or False)
    ...
     [Arguments]      ${meas_period_in_minute}=5      ${additional_waiting_time_sec}=30      ${gnb}=0    ${enb}=''
     ${meas_period_in_min}   remove string    ${meas_period_in_minute}    min

     ${oam_addr}    set variable if    ${enb} != ''
     ...    ${tl.enbs[${enb}].oam_ip.v4}
     ...    ${tl.gnbs[${gnb}].cu.oam_ssh_connection_details.addr}

     ${oam_username}   set variable    ${tl.gnbs[${gnb}].cu.oam_ssh_connection_details.username}
     ${oam_password}   set variable    ${tl.gnbs[${gnb}].cu.oam_ssh_connection_details.password}
     csn.Connect to     ${oam_addr}     ${oam_username}     ${oam_password}    alias=OAM

     ${date_format}=    set variable     date +"%Y-%m-%d %H:%M:%S.%3N"
     csn.Send Command    connection=OAM    command=${date_format}
     ${stdout}=    csn.Read Output    connection=OAM
     ${current_time}=     Convert Date     ${stdout}    datetime
     log            gNB current time:${current_time}

     ${minutes}=    Evaluate   int(${current_time.minute}/${meas_period_in_min} + 1)*${meas_period_in_min}
     ${minutes}=    Convert To Integer    ${minutes}
     ${time_delta}=   convert time    00:${minutes}:00   timedelta
     ${secnds}=       Evaluate    (${current_time.second} - ${additional_waiting_time_sec})
     ${subtract}=     Subtract Time From Date     ${current_time}    ${current_time.minute} minutes ${secnds} seconds
     ${next_pm_time}=      Add Time to Date    ${subtract}    ${time_delta}
     log            Next period is (with additional wait time): ${next_pm_time}  console=${DEBUG_MODE_CONSOLE}

     ${waiting_time}=    Subtract Date From Date      ${next_pm_time}    ${current_time}    exclude_millis=false
     ${waiting_time}=    Convert to Integer    ${waiting_time}
     Log            Measurement Period Waiting_time is : ${waiting_time}sec  console=${DEBUG_MODE_CONSOLE}
     csn.disconnect    connection=OAM
     sleep    ${waiting_time}       reason=Wait Next Measurement Period


Get gNB current time
    [Documentation]  This keyword prints the time from gNB
    ...      AUTHOR:  Annie Wong    annie.wong@nokia.com
     [Arguments]     ${gnb}=0
     ${oam_addr}    set variable       ${tl.gnbs[${gnb}].cu.oam_ssh_connection_details.addr}
     ${oam_username}   set variable    ${tl.gnbs[${gnb}].cu.oam_ssh_connection_details.username}
     ${oam_password}   set variable    ${tl.gnbs[${gnb}].cu.oam_ssh_connection_details.password}
     csn.Connect to     ${oam_addr}     ${oam_username}     ${oam_password}    alias=OAM
     ${date_format}=    set variable     date +"%Y-%m-%d %H:%M:%S.%3N"
     csn.Send Command    connection=OAM    command=${date_format}
     ${stdout}=    csn.Read Output    connection=OAM
     ${current_time}=     Convert Date     ${stdout}    datetime
     log            gNB current time:${current_time}    console=${DEBUG_MODE_CONSOLE}
     csn.disconnect    connection=OAM

#Amadou

Connect and move old PM files
	[Arguments]		${oam_addr}		${oam_username}		${oam_password}		${target_dir}
	ssh.Connect To      ${oam_addr}    ${oam_username}    ${oam_password}
	ssh.Send Command    sudo rm ${target_dir}
	ssh.Send Command    sudo mkdir ${target_dir}
	ssh.Send Command	sudo mv /mnt/services/PM9/storage/results/A2* ${target_dir}/
	${output}=  ssh.Read Output


Download PM counters
    [Documentation]    Collect pm counters to local machine
    [Arguments]		${oam_addr}		${oam_username}		${oam_password}
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    set suite variable        ${date}
    &{OAM_config}=   Create Dictionary
    ...  host=${oam_addr}
    ...  user=${oam_username}
    ...  password=${oam_password}
    #...  port=443

    Fail    Deprecated Keyword: Create Coam CU PM collector
    #pm.Create Coam CU PM collector
    #...  name=gnb_pm_counters
    #...  executor=${OAM_config}
    #...  oam_type=sbts
    pm.Setup Collectors
    ...  names=gnb_pm_counters
    pm.Collect Collectors
    ...  names=gnb_pm_counters
    ...  target_dir=${PM_STORAGE}/${date}
    pm.Teardown Collectors
    ...  names=gnb_pm_counters

    # Get last PM filename
    ${cmd}=   cd "${PM_STORAGE}/${date}";ls -dr1 *PM*.xml |head -1
    ${pm_filename}     Run     ${cmd}
    log      Last pmfile = ${pm_filename}
    Return From Keyword     ${pm_filename}


Analyse PM
	[Arguments]		${pi_id}
	${pi_list}=  Create List
	...		${pi_id}
	${pi_dict}=  get_pi_value
	...  pi_list=${pi_list}
	...  pi_dir=${PM_STORAGE}/${date}/gnb_pm_counters
	...  pi_file_pattern=A2*
	Log  ${pi_dict}
	${counters_count}=  Get Length  ${pi_list}
	${valeur}=		evaluate	0
	:FOR   ${i}   IN    @{pi_dict}
	\		${sorted}=		Get Dictionary Keys		${i}
	\		${value_dict}=  Extract last values from pi dict   ${i}   ${counters_count}
	\		${valeur}=		evaluate	${valeur} + ${value_dict}
	[return]		${valeur}

# Philipe VIGNERTE

Connect and move old CU PM files
    [Documentation]    Connect to CU and move previous CU pm counters to local machine
 	[Arguments]		${oam_addr}		${oam_username}		${oam_password}		${target_dir}
	ssh.Connect To      ${oam_addr}    ${oam_username}    ${oam_password}
	ssh.Send Command    sudo rm ${target_dir}
	ssh.Send Command    sudo mkdir ${target_dir}
	Log		${target_dir}
	ssh.Send Command	sudo mv /mnt/services/PM9/storage/results/A2* ${target_dir}/
	ssh.Send Command	ls -lrt ${target_dir}
	${output}=  ssh.Read Output


Connect and move old DU PM files
    [Documentation]    Connect to DU and move previous DU pm counters to local machine
 	[Arguments]		    ${BB1_IP_LOCAL} 		${BB1_LOGIN} 		${BB1_PASSWORD}		${du_pm_target_dir}
	# ip, login passwd for DU
	#${BB1_IP_LOCAL}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    #${BB1_LOGIN}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    #${BB1_PASSWORD}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
	${BB1_IP_LOCAL}     set variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${BB1_LOGIN}        set variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ${BB1_PASSWORD}     set variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

	ssh.Connect to      hostname=${BB1_IP_LOCAL}    username=${BB1_LOGIN}     password=${BB1_PASSWORD}
	ssh.Send Command    rm ${du_pm_target_dir}
	ssh.Send Command    mkdir ${du_pm_target_dir}
	Log		${du_pm_target_dir}
	ssh.Send Command	mv /ram/PM* ${du_pm_target_dir}/
	ssh.Send Command	ls -lrt ${du_pm_target_dir}
	${output}=  ssh.Read Output

Connect and move old DU PM files Other Location
    [Documentation]    Connect to DU and move previous DU pm counters to local machine in other location
 	[Arguments]		    ${BB1_IP_LOCAL} 		${BB1_LOGIN} 		${BB1_PASSWORD}		${du_pm_target_dir2}
	# ip, login passwd for DU
	#${BB1_IP_LOCAL}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    #${BB1_LOGIN}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    #${BB1_PASSWORD}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
	${BB1_IP_LOCAL}     set variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${BB1_LOGIN}        set variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ${BB1_PASSWORD}     set variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

	ssh.Connect to      hostname=${BB1_IP_LOCAL}    username=${BB1_LOGIN}     password=${BB1_PASSWORD}
	ssh.Send Command    rm ${du_pm_target_dir2}
	ssh.Send Command    mkdir ${du_pm_target_dir2}
	Log		${du_pm_target_dir2}
	#ssh.Send Command	mv /ram/PM* ${du_target_dir}/
	ssh.Send Command	mv /ffs/run/uri/PERFMON_FILES/PM* ${du_pm_target_dir2}/
	ssh.Send Command	ls -lrt ${du_pm_target_dir2}
	${output}=  ssh.Read Output


Download CU PM counters
    [Documentation]    Collect CU pm counters to local machine
    [Arguments]		${oam_addr}		${oam_username}		${oam_password}
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    set suite variable        ${date}
	Log		${PM_STORAGE}
    &{OAM_config}=   Create Dictionary
    ...  host=${oam_addr}
    ...  user=${oam_username}
    ...  password=${oam_password}
    #...  port=443

    Fail    Deprecated Keyword: Create Coam CU PM collector
    #pm.Create Coam CU PM collector
    #...  name=gnb_pm_counters
    #...  executor=${OAM_config}
    #...  oam_type=sbts
    pm.Setup Collectors
    ...  names=gnb_pm_counters
    pm.Collect Collectors
    ...  names=gnb_pm_counters
    ...  target_dir=${PM_STORAGE}/${date}
    pm.Teardown Collectors
    ...  names=gnb_pm_counters

Download DU PM counters
    [Documentation]    Collect DU pm counters to local machine
    [Arguments]		    ${du_oam_addr} 		${du_oam_username} 		${du_oam_password}		${du_oam_timeout}
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    set suite variable        ${date}
	Log		${PM_STORAGE}
    &{DU_webservice}=   Create Dictionary
    #${du_oam_addr}=	        10.14.48.101
    #${du_oam_username}=	    Nemuadmin
    #${du_oam_password}=	    nemuuser
    ...  host=${du_oam_addr}
    ...  user=${du_oam_username}
    ...  password=${du_oam_password}
    ...  port=443

    pm.Create Pm Collector
    ...  name=gnb_du_pm_counters
    ...  webservice=${DU_webservice}
    #...  oam_type=sbts
    ...  timeout=${du_oam_timeout}
    pm.Setup Collectors
    ...  names=gnb_du_pm_counters
    pm.Collect Collectors
    ...  names=gnb_du_pm_counters
    ...  target_dir=${PM_STORAGE}/${date}
    pm.Teardown Collectors
    ...  names=gnb_du_pm_counters

# Watiing for issue solved with taf.collectors.pmcounter on DU PM collection - WA
Collect DU PM Files By Download
    [Documentation]         To collect the PM DU files from /ram in gNB ASOD by download as a workarround.
    #[Arguments]                 ${folder}
    #Create Directory            ${custom['PATH_Storage']}/PM_Counters/${folder}
    ## Empty Directory             ${custom['PATH_Storage']}/PM
    ${date2}    Get current date    result_format=%Y%m%d_%H%M%S
    set suite variable        ${date2}
    Log		${date2}
    Log		${PM_STORAGE}
    Log		${local_du_pm_dir}
    Create Directory    ${PM_STORAGE}/${date2}
    Create Directory    ${PM_STORAGE}/${date2}/${local_du_pm_dir}
    ${pm_files_gz}=         ssh.execute     command=cd /ram; ls PM.BTS*.xml.gz       connection=cOAM_DU
    @{pm_files_gz_list}            split string      string=${pm_files_gz}
    :FOR    ${file}     IN      @{pm_files_gz_list}
    \       ssh.Send Command	    cd /ram; gunzip ${file}
    ${pm_files}=         ssh.execute     command=cd /ram; ls PM.BTS*.xml       connection=cOAM_DU
    @{pm_files_list}            split string      string=${pm_files}
    :FOR    ${file}     IN      @{pm_files_list}
    \       ssh.Download File       /ram/${file}
    \       ...                     ${PM_STORAGE}/${date2}/${local_du_pm_dir}/${file}        connection=cOAM_DU
    \       ssh.Send Command	    cd /ram; gzip ${file}


Collect DU PM Files By Download Other Location
    [Documentation]         To collect the PM DU files from /ffs/run/uri/PERFMON_FILES in gNB ASOD by download
    ...     as a workarround.
    #[Arguments]                 ${folder}
    #Create Directory            ${custom['PATH_Storage']}/PM_Counters/${folder}
    ## Empty Directory             ${custom['PATH_Storage']}/PM
    ${date3}    Get current date    result_format=%Y%m%d_%H%M%S
    set suite variable        ${date3}
    Log		${PM_STORAGE}
    Log		${local_du_pm_dir_2}
    Create Directory    ${PM_STORAGE}/${date3}
    Create Directory    ${PM_STORAGE}/${date3}/${local_du_pm_dir_2}
    ${pm_files_gz}=         ssh.execute     command=cd /ffs/run/uri/PERFMON_FILES; ls PM.BTS*.xml.gz
    ...     connection=cOAM_DU
    @{pm_files_gz_list}            split string      string=${pm_files_gz}
    :FOR    ${file}     IN      @{pm_files_gz_list}
    \       ssh.Send Command	    cd /ffs/run/uri/PERFMON_FILES; gunzip ${file}
    ${pm_files}=         ssh.execute     command=cd /ffs/run/uri/PERFMON_FILES; ls PM.BTS*.xml
    ...     connection=cOAM_DU
    @{pm_files_list}            split string      string=${pm_files}
    :FOR    ${file}     IN      @{pm_files_list}
    \       ssh.Download File       /ffs/run/uri/PERFMON_FILES/${file}
    \       ...                     ${PM_STORAGE}/${date3}/${local_du_pm_dir_2}/${file}      connection=cOAM_DU
    \       ssh.Send Command	    cd /ffs/run/uri/PERFMON_FILES; gzip ${file}


Analyse DU PM
    [Documentation]    Analyse DU pm counters by PM id
	[Arguments]		${pi_id}
	${pi_list}=  Create List
	...		${pi_id}
	${pi_dict}=  get_pi_value
	...  pi_list=${pi_list}
	...  pi_dir=${PM_STORAGE}/${date}/gnb_du_pm_counters
	...  pi_file_pattern=PM*.xml
	Log  ${pi_dict}
	${counters_count}=  Get Length  ${pi_list}
	${valeur}=		evaluate	0
	:FOR   ${i}   IN    @{pi_dict}
	\		${sorted}=		Get Dictionary Keys		${i}
	\		${value_dict}=  Extract last values from pi dict   ${i}   ${counters_count}
	\		${valeur}=		evaluate	${valeur} + ${value_dict}
	[return]		${valeur}

Analyse DU PM WA
    [Documentation]    Analyse DU pm counters by PM id as WA when downloaded not using taf.collecteors.pmcounters lib
	[Arguments]		${pi_id}
	${pi_list}=  Create List
	...		${pi_id}
	${pi_dict}=  get_pi_value
	...  pi_list=${pi_list}
	#...  pi_dir=${PM_STORAGE}/${date}/gnb_du_pm_counters
	...  pi_dir=${PM_STORAGE}/${date2}/${local_du_pm_dir}
	...  pi_file_pattern=PM*.xml
	Log  ${pi_dict}
	${counters_count}=  Get Length  ${pi_list}
	${valeur}=		evaluate	0
	:FOR   ${i}   IN    @{pi_dict}
	\		${sorted}=		Get Dictionary Keys		${i}
	\		${value_dict}=  Extract last values from pi dict   ${i}   ${counters_count}
	\		${valeur}=		evaluate	${valeur} + ${value_dict}
	[return]		${valeur}


Analyse DU PM v2
    [Documentation]    Analyse DU pm counters by PM id
	[Arguments]		${pi_id}
	${pi_list}=  Create List
	...		${pi_id}
	${pi_dict}=  get_pi_value
	...  pi_list=${pi_list}
	...  pi_dir=${PM_STORAGE}/${date}/gnb_du_pm_counters
	...  pi_file_pattern=PM*.xml
	Log  ${pi_dict}
	# Removed first DU PM recording file from list
	${exitFromMyFor}=        evaluate        1
	:FOR   ${j}   IN    @{pi_dict}
	\		${first_key}=		Get Dictionary Keys		${j}
    \       Remove From Dictionary	    ${pi_dict}     ${first_key}
	\       exit for loop if            ${exitFromMyFor} == 1
	${counters_count}=  Get Length  ${pi_list}
	${valeur}=		evaluate	0
	:FOR   ${i}   IN    @{pi_dict}
	\		${sorted}=		Get Dictionary Keys		${i}
	\		${value_dict}=  Extract last values from pi dict for du pm  ${i}   ${counters_count}
	\		${valeur}=		evaluate	${valeur} + ${value_dict}
	[return]		${valeur}

Analyse DU PM WA v2
    [Documentation]    Analyse DU pm counters by PM id as WA when downloaded not using taf.collecteors.pmcounters lib
	[Arguments]		${pi_id}
	${pi_list}=  Create List
	...		${pi_id}
	${pi_dict}=  get_pi_value
	...  pi_list=${pi_list}
	#...  pi_dir=${PM_STORAGE}/${date2}/gnb_du_pm_counters
	...  pi_dir=${PM_STORAGE}/${date2}/${local_du_pm_dir}
	...  pi_file_pattern=PM*.xml
	Log  ${pi_dict}
	# Removed first DU PM recording file from list
	${exitFromMyFor}=        evaluate        1
	:FOR   ${j}   IN    @{pi_dict}
	\		${first_key}=		Get Dictionary Keys		${j}
    \       Remove From Dictionary	    ${pi_dict}     ${first_key}
	\       exit for loop if            ${exitFromMyFor} == 1
	${counters_count}=  Get Length  ${pi_list}
	${valeur}=		evaluate	0
	:FOR   ${i}   IN    @{pi_dict}
	\		${sorted}=		Get Dictionary Keys		${i}
	\		${value_dict}=  Extract last values from pi dict for du pm  ${i}   ${counters_count}
	\		${valeur}=		evaluate	${valeur} + ${value_dict}
	[return]		${valeur}
