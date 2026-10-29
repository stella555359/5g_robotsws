*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_journey.robot



#*** Variables ***



*** Keywords ***

CU Collect Journal Log On All VMs
    [Documentation]    Gets all journal logs and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    None
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Journal Log On All VMs  |   |
    ${count_of_gnbs}=  get length  ${tl.gnbs}
    FOR  ${gnb_index}  IN RANGE  ${count_of_gnbs}
        CU Collect Journal Log On All VMs On Specified GNB  ${gnb_index}
    END


CU Collect Journal Log On All VMs On Specified GNB
    [Arguments]  ${gnb_index}=${0}
    [Documentation]    Gets all journal logs on specified gnb and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Journal Log On All VMs On Specified GNB  |   |
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${user}=  run keyword if  '${username}'=='robot'  set variable  robot
    ...       ELSE     set variable  root
    log to console  ${\n}cu get ALL journal logs start
    ${vm_hostname_list}=  CU Get All VMs Hostame  gnb_index=${gnb_index}
    ${active_oam}=  CU Get Active OAM  gnb_index=${gnb_index}
    ${alias}   get unique id
    CU SSH To OAM     gnb_index=${gnb_index}  alias=${alias}
    issh.Execute  command=sudo mkdir /home/${username}/journal_log  check_result=${False}  alias=${alias}
    issh.Execute  command=sudo chmod 777 /home/${username}/journal_log  check_result=${False}  alias=${alias}
    issh.set_timeout  timeout=120  alias=${alias}
    FOR    ${vm_hostname}    IN    @{vm_hostname_list}
       ${hostname} =    Set Variable    ${vm_hostname}.local
       issh.Execute  command=ssh ${hostname}  check_result=${False}  alias=${alias}
       ${output}=  issh.Execute  command=hostname  check_result=${False}  alias=${alias}
       ${output}=   convert to lowercase   ${output}
       should contain   ${output}   ${vm_hostname}   ssh to vm ${vm_hostname} failed!
       issh.Execute  command=sudo journalctl -b > /tmp/${vm_hostname}.log
    ...               check_result=${False}  alias=${alias}
       issh.Execute  command=sudo chmod 777 /tmp/${vm_hostname}.log  check_result=${False}  alias=${alias}
       issh.Execute
    ...    command=scp -r /tmp/${vm_hostname}.log ${user}@${active_oam}.local:/home/${username}/journal_log
    ...    check_result=${False}  alias=${alias}
       issh.Execute  command=sudo rm -rf /tmp/${vm_hostname}.log  check_result=${False}    alias=${alias}
    END
    ${oam_alias}  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${oam_alias}
    issh.set_timeout  timeout=120  alias=${oam_alias}
    ${journal_dir}=  Get A Directory  journal_log/gnb${gnb_index}_${username}
    issh.download_file  remote_path=/home/${username}/journal_log/*.log  local_path=${journal_dir}/
    ...                 alias=${oam_alias}
    issh.Execute  command=sudo rm -rf /home/${username}/journal_log  check_result=${False}  alias=${oam_alias}
    log to console    ${\n}cu get ALL journal logs end
    [Teardown]  run keywords  Disconnect Interactive Connection  alias=${oam_alias}
    ...             AND       Disconnect Interactive Connection  alias=${alias}

CU Collect Journal Log On Specified VM
    [Arguments]  ${vm_type}    ${gnb_index}=${0}    #${vm_index}=${0}
    [Documentation]    Gets journal log on specified VM except OAM and saves it.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    |  vm_type   | Yes |  specified VM type to get journal log |
        ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Journal Log On Specified VM  |  UPUE  |

    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${user}=  run keyword if  '${username}'=='robot'  set variable  robot
    ...       ELSE     set variable  root
    ${vm}=   convert to lowercase   ${vm_type}
    log to console    ${\n}cu get ${vm_type} journal log start
    ${active_oam}=  CU Get Active OAM  gnb_index=${gnb_index}
    ${oam_alias}  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${oam_alias}
    issh.Execute  command=sudo mkdir /home/${username}/journal_log  check_result=${False}  alias=${oam_alias}
    issh.Execute  command=sudo chmod 777 /home/${username}/journal_log  check_result=${False}  alias=${oam_alias}
    issh.set_timeout  timeout=120  alias=${oam_alias}
    ${alias}=  get unique id
    run keyword  CU SSH To ${vm_type}  gnb_index=${gnb_index}  alias=${alias}

    issh.set_timeout  timeout=120  alias=${alias}
    issh.Execute  command=sudo journalctl -b > /tmp/${vm_type}.log  check_result=${False}    alias=${alias}
    issh.Execute  command=sudo chmod 777 /tmp/${vm_type}.log  check_result=${False}  alias=${alias}
    issh.Execute  command=scp -r /tmp/${vm_type}.log ${user}@${active_oam}.local:/home/${username}/journal_log
    ...    check_result=${False}  alias=${alias}
    issh.Execute  command=sudo rm /tmp/${vm_type}.log  check_result=${False}    alias=${alias}
    ${journal_dir}=  Get A Directory  journal_log/gnb${gnb_index}_${username}
    issh.download_file  remote_path=/home/${username}/journal_log/*.log  local_path=${journal_dir}/
    ...                 alias=${oam_alias}
    issh.Execute  command=sudo rm -rf /home/${username}/journal_log  check_result=${False}    alias=${oam_alias}
    log to console    ${\n}cu get ${vm_type} journal log end
    [Teardown]  run keywords  Disconnect Interactive Connection  alias=${oam_alias}
    ...             AND       Disconnect Interactive Connection  alias=${alias}
