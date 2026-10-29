*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_startuplog.robot



#*** Variables ***



*** Keywords ***
CU Collect Startup Logs On All VMs
    [Documentation]    Gets all journal logs and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    None
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Startup Logs On All VMs  |   |
    ${count_of_gnbs}=  get length  ${tl.gnbs}
    FOR  ${gnb_index}  IN RANGE  ${count_of_gnbs}
        CU Collect Startup Logs On All VMs On Specified GNB    ${gnb_index}
    END

CU Collect Startup Logs On All VMs On Specified GNB
    [Arguments]  ${gnb_index}=${0}
    [Documentation]    Gets all startup logs and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Startup Logs On All VMs On Specified GNB  |   |
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${user}=  run keyword if  '${username}'=='robot'  set variable  robot
    ...       ELSE     set variable  root
    log to console    ${\n}cu get ALL startup logs start
    ${vm_hostname_list}=  CU Get All VMs Hostame  gnb_index=${gnb_index}
    ${active_oam}=  CU Get Active OAM  gnb_index=${gnb_index}

    ${oam_alias}  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${oam_alias}
#    issh.set_timeout  timeout=120  alias=${oam_alias}
    ${startup_dir}=  Get A Directory  startup_logs/gnb${gnb_index}_${username}

    FOR    ${vm_hostname}    IN    @{vm_hostname_list}
       issh.Execute  command=sudo mkdir -p /home/${username}/startup_logs/${vm_hostname}
    ...               check_result=${False}  alias=${oam_alias}
       issh.Execute  command=sudo chmod 777 /home/${username}/startup_logs/${vm_hostname}
    ...               check_result=${False}  alias=${oam_alias}
    END

    ${alias}   get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${alias}
#    issh.set_timeout  timeout=120  alias=${alias}

    FOR    ${vm_hostname}    IN    @{vm_hostname_list}
       ${hostname} =    Set Variable    ${vm_hostname}.local
       issh.Execute  command=ssh ${hostname}   check_result=${False}  alias=${alias}
       ${output}=  issh.Execute  hostname  check_result=${False}  alias=${alias}
       ${output}=   convert to lowercase   ${output}
       should contain   ${output}   ${vm_hostname}   ssh to vm ${vm_hostname} failed!
       ${number}=  issh.Execute  ls /tmp | grep ^startup* | wc -l  check_result=${False}  alias=${alias}
       ${number}=  get line  ${number}   1
       run keyword if    '${number}'!='0'   run keywords
    ...    issh.Execute  command=sudo chmod -R 777 /tmp/startup*  check_result=${False}  alias=${alias}  AND
    ...    issh.Execute
    ...      command=scp -r /tmp/startup* ${user}@${active_oam}.local:/home/${username}/startup_logs/${vm_hostname}
    ...      check_result=${False}  alias=${alias}  AND
    ...    issh.Execute  command=sudo chmod -R 777 /home/${username}/startup_logs
    ...                  check_result=${False}  alias=${oam_alias}   AND
    ...    issh.download_file  remote_path=/home/${username}/startup_logs/${vm_hostname}/*
    ...                        local_path=${startup_dir}/${vm_hostname}/  alias=${oam_alias}
    END

    issh.Execute  command=sudo rm -rf //home/${username}/startup_logs  check_result=${False}  alias=${oam_alias}

    log to console    ${\n}cu get ALL startup logs end
    [Teardown]  run keywords  Disconnect Interactive Connection  alias=${oam_alias}
    ...             AND       Disconnect Interactive Connection  alias=${alias}


############################## CU LOG End ##############################
