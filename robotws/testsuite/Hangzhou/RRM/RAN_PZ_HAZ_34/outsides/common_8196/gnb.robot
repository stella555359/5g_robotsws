*** Settings ***
Library   taf.transport.ssh   WITH NAME   csn
Library   taf.gnb.oam.megazone_client   WITH NAME   megazone
Library   ./libraries/get_bts_info.py

*** Variables ***
${scf_base_folder}   /opt/nokia/SS_MzOam/cloud-siteoam/siteoam
${scf_classical_folder}   /tmp/node_0xe000${scf_base_folder}
${scf_cloud_folder}   ${scf_base_folder}

*** Keywords ***
Check Disk space
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=disk_space
    ${space_info}   csn.Execute   df -h   connection=disk_space
    ${disk_info}   csn.Execute   ls -al /ffs   connection=disk_space
    ${run_disk}   ${stb_disk}   get_disk_mapping   ${disk_info}
    ${run_spare}   ${stb_spare}   get_disk_space   ${space_info}   ${run_disk}   ${stb_disk}
    [Return]   ${run_spare}   ${stb_spare}
    [Teardown]   csn.Disconnect   connection=disk_space

Check gnb Detect
    [Documentation]   Keep the keyword for origin cases
    [Arguments]   ${gnb_addr}=${asik_addr}
    Try Connect gNB   gnb_addr=${gnb_addr}

Get gnb release
    [Documentation]   Get gnb release version from TargetBD file
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${main_branch}   Set Variable   ${info.split('_')[3]}
    ${release_info}   Run Keyword If   '${main_branch}'=='9999'   Set Variable   TRUNK
    ...   ELSE   set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

gNB not Connected
    [Arguments]   ${gnb_addr}=${asik_addr}
    ${gnb_connected}   Run Keyword and Return Status   Try Connect gNB   gnb_addr=${gnb_addr}
    Should Not Be True   ${gnb_connected}

Try Connect gNB
    [Documentation]   try to connect gnb via SSH
    [Arguments]   ${gnb_addr}=${asik_addr}
    [Timeout]   60s
    csn.Connect to
    ...   hostname=${gnb_addr}   username=${asik_username}   password=${asik_password}   alias=try_connect
    [Teardown]   csn.Disconnect   connection=try_connect

gNB reboot from SSH
    [Documentation]   try to reboot gnb via SSH
    [Arguments]   ${gnb_addr}=${asik_addr}
    [Timeout]   60s
    csn.Connect to
    ...   hostname=${gnb_addr}   username=${asik_username}   password=${asik_password}   alias=reboot
    csn.Execute   reboot   connection=reboot
    Sleep   2s
    [Teardown]   csn.Disconnect   connection=reboot

Config SSH for VM
    [Documentation]   add username and config ssh service
    RUN    Sudo useradd -m coam
    RUN    echo -e "zO&n1W*ktp7\nzO&n1W*ktp7" | sudo passwd coam
    RUN    sudo chmod 777 /etc/ssh/sshd_config
    RUN    echo -e "port 22022" >> /etc/ssh/sshd_config
    RUN    sudo service ssh restart
    sleep    2min
    RUN    sudo iptables -I INPUT -p tcp --dport 22022 -j ACCEPT

Connect Ssh To Asix
    [Documentation]
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}    ${alias}=asix
    csn.Connect to
    ...   hostname=${host}   username=${username}   password=${password}   alias=${alias}

Disconnect Ssh From Asix
    [Documentation]
    [Arguments]   ${alias}=asix
    csn.Disconnect   connection=${alias}
