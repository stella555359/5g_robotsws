*** Settings ***
Library             csv_verification.py
Library             taf.transport.ssh      WITH NAME   ssh
Library             OperatingSystem
Resource            testsuite/Wroclaw/RRM/resources/preconditions.robot


*** Keywords ***
Upload TTI Tracing Script To ABIL
    [Documentation]   Uploads a script that gathers and converts TTI traces on ABIL SLAVE.
    ${abil_alias}=  Connection to abil master if release is 5G19B else slave
    ssh.Upload File   local_path=${EXECDIR}/testsuite/Wroclaw/RRM/resources/tti_verification/gnb_tti_traces.sh
    ...               remote_path=/user/toor4nsn/gnb_tti_traces.sh
    ...               connection=${abil_alias}
    ssh.Execute       command=chmod +x gnb_tti_traces.sh   connection=${abil_alias}


Start TTI Tracing On ABIL
    [Documentation]  Uploads a script that gathers and converts TTI traces on ABIL SLAVE and starts it.
    [Arguments]     ${with_script_upload}=true    ${with_events_collect_mod}=false   ${delete_after}=120
    ${abil_alias}=  Connection to abil master if release is 5G19B else slave
    Check TTItrace and copy if missing     ${abil_alias}
    Run Keyword if   '${with_events_collect_mod}' == 'true'    Modify events collector    ${delete_after}
    Run Keyword if   '${with_script_upload}' == 'true'    Upload TTI Tracing Script To ABIL
    ssh.Execute       command=nohup /user/toor4nsn/gnb_tti_traces.sh start   connection=${abil_alias}
    Log   Started TTI tracing!   console=True


Stop And Gather TTI Traces From ABIL
    [Documentation]  Stops gathering TTI traces and downloads them from ABIL to chosen directory
    [Arguments]   ${target_directory}=TTI   ${filename}=combined_tti.csv
    ${abil_alias}=  Connection to abil master if release is 5G19B else slave
    ${tti_dir}=   Set variable   ${LOG_PATH}/${target_directory}
    Run Keyword And Ignore Error   Create directory   ${tti_dir}
    Stop TTI Tracing On ABIL
    ${cmd_output}=   ssh.Execute   command=ls -a /tmp/tti_traces   connection=${abil_alias}
    @{files_list}=   Get list of dlandul tti csvs   ${cmd_output}
    :FOR  ${file}  IN   @{files_list}
    \   ssh.Download File   local_path=${tti_dir}/${file}   remote_path=/tmp/tti_traces/${file}   connection=${abil_alias}
    ssh.Execute   command=rm /tmp/tti_traces/*   connection=${abil_alias}
    ${comb_file}=   Set variable   ${target_directory}/${filename}
    Combine csv files in   ${tti_dir}   output_file=${tti_dir}/${filename}   with_pattern=*dlAndUl*.csv
    Run   command=rm ${tti_dir}/*dlAndUl*.csv
    [Return]   ${comb_file}


Stop TTI Tracing On ABIL
    ${abil_alias}=   Connection to abil master if release is 5G19B else slave
    ssh.Execute       command=nohup /user/toor4nsn/gnb_tti_traces.sh stop   connection=${abil_alias}
    Log   Stopped TTI tracing!   console=True


Process Needed Messages
    [Documentation]  input path to the csv file(s) with tti traces list of names of the messages you want to process,
    ...  outputs a list of dictionaries containing data stored in those messages in order of their consequent appearance
    [Arguments]  ${filepath}   ${message_names}
    ${data}=   Process needed messages  ${filepath}  ${message_names}
    [Return]  ${data}


Modify events collector
    [Arguments]   ${delete_after}=120
    ${abil_alias}=   Connection to abil master if release is 5G19B else slave
    ${events_collector_file}=    Set variable    ${LOG_PATH}/eventsCollect.sh

    ssh.Download File   local_path=${events_collector_file}
    ...                 remote_path=/opt/tools/ttiTrace/eventsCollect.sh
    ...                 connection=${abil_alias}
    Modify events collector file   ${events_collector_file}    ${delete_after}
    ssh.Upload File     local_path=${events_collector_file}
    ...                 remote_path=/opt/tools/ttiTrace/eventsCollect.sh
    ...                 connection=${abil_alias}
    Run   command=rm ${events_collector_file}

Check TTItrace and copy if missing
    [Arguments]       ${abil_alias}
    ${ttiTrace}=      Run Keyword And Return Status      ssh.Assert File Exists   /opt/tools/ttiTrace   connection=${abil_alias}
    run keyword if    ${ttiTrace} == False   run keywords
    ...               ssh.Execute       command=cp -r /ram/node_L2RT20/opt/tools /opt/tools  connection=${abil_alias}    AND
    ...               ssh.Assert File Exists   /opt/tools/ttiTrace   connection=${abil_alias}
