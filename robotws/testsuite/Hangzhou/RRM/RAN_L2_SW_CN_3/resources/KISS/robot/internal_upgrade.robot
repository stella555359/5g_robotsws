*** Settings ***
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library           taf.transport.ssh    WITH NAME    csn
Library           ute_fsmaccess 
Library           ute_admin_infomodel      WITH NAME   ifmd
Library           taf.pdu      WITH NAME    pdu

*** Variables ***
${L1_TYPE}        L1b
${build_url_hz}      http://artifactory-hz1.int.net.nokia.com/artifactory/ute-files-remote-cache/builds/enb/base
${build_url}      ${build_url_hz}/enb_build_name/enb_build_name_release_BTSSM_downloadable.zip
#${build_url}      http://files.ute.nsn-rdnet.net/builds/enb/base/enb_build_name/enb_build_name_release_BTSSM_downloadable.zip
${yaft_svn_link}    https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk
${ap_url}    https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/
@{gnb_skip_dci}    ASOE    ASIB    ASIL
${ap_ip}      192.168.200.1
${ftm_ip}     192.168.255.129
${gnb_ip}     192.168.255.1
${gnb_usr}    toor4nsn
${gnb_pwd}    oZPS0POrRieRtu
${ap_usr_pwd}    --user zhangzy --password Nsn@1008


*** Keywords ***
teardown with enable ssh
    common suite teardown
    COAM.setup admin
    COAM.Disable Ethernet Port Security
    COAM.Enable Ssh Access
    [Teardown]    COAM.teardown admin

run process and check rc
    [Arguments]    ${cmd}
    ${ret}    run process    ${cmd}    shell=True    stderr=STDOUT    stdout=STDOUT
    run keyword if    ${ret.rc}!=0    fail    ${ret.stderr}
    ...    ELSE    log    ${ret.stdout}
    [Return]    ${ret.stdout}


gnb package download
    [Arguments]    ${enb_bd}
    ${pacakge_save_dir}      set variable      /home/ute
    set test variable    ${sw_path}    ${pacakge_save_dir}/${enb_bd}_release_BTSSM_downloadable.zip
    ${final_url}    Replace String    ${build_url}    enb_build_name    ${enb_bd}
    ${ret}    run process and check rc    df --output=avail /home/ute | tail -n 1       #check space
    ${ret}    run process and check rc    ls ${pacakge_save_dir} 
    ${exist}    evaluate      '${enb_bd}_release_BTSSM_downloadable.zip' in """${ret}"""
    run keyword if     'True'=='${exist}'    Return From Keyword
    run keyword and ignore error    run process and check rc    rm /home/ute/*release_BTSSM_downloadable.zip
    log to console    \r\nwget ${enb_bd}_release_BTSSM_downloadable.zip
    run process and check rc    wget -P ${pacakge_save_dir} -q ${final_url}   

gnb upgrade software with admin
    COAM.setup admin
    ${ret}    COAM.Get Bts Statuses
    ${cmd}    gnb get l1bypass para
    log to console    \r\nUpdate Software...
    COAM.Update Software    ${sw_path}    should_activate=${True}     timeout=1200
    run keyword if    '${L1_TYPE}'=='L1b'    gnb set l1bypass      ${cmd}
    log to console    \r\nReset Site...
    Run Keyword And Ignore Error    COAM.Reset Site
    [Teardown]    COAM.teardown admin

gnb check status
    Wait For Host Ssh    ${gnb_ip}    tmieout=180
    wait until keyword Succeeds    180    10    COAM.setup admin
    log to console    \r\nwait for bts status is Configured, IntegratedToRan or OnAir
    run keyword and ignore error    wait until keyword Succeeds    600    30    gnb status should be ready  
    [Teardown]    COAM.teardown admin

gnb status should be ready
    ${expect_state}     create list     Configured     IntegratedToRan    OnAir
    ${state}    COAM.Get Bts Statuses
    ${gnb_state}    set variable    ${state["proceduralState"]}
    ${ret}    evaluate     '${gnb_state}' in ${expect_state}
    run keyword if    '${ret}'!='${True}'    Fail    gnb status is ${state["proceduralState"]}, not ${expect_state}

gnb check sw info
    COAM.setup admin
    ${swinfo}    COAM.Get Software Info
    ${ret}    evaluate    '${swinfo["Active SW version"][-10:]}'=='${sw_build[-10:]}'
    run keyword if    '${ret}'!='${True}'    Fail    gnb sw version is ${swinfo["Active SW version"]}, not ${sw_build}
    [Teardown]    COAM.teardown admin

ap version check
	Wait For Host Ssh    ${ue_ip}    tmieout=180
    Wait Until Keyword Succeeds     300    10   Get WTS Version
    Wait Until Keyword Succeeds     300    10   Get Airphone Software Version
    should be equal    ${WTS_VERSION}    ${ap_bd}

ap packages download
    [Arguments]    ${build_url}=${ap_url}
    log to console    \r\nsvn up yaft trunk and wget airphone packages
    ${ret}    run process and check rc    df --output=avail /home/ute | tail -n 1
    run process and check rc    cd /home/ute;svn co --username ca_ute_test --password utetest ${yaft_svn_link}
    set test variable    ${yaft_path}    /home/ute/trunk    #${CURDIR}/trunk    #
    run process and check rc    wget ${ap_usr_pwd} -P ${yaft_path} ${build_url}${ap_bd}
    ${tmp}    file match all    ${yaft_path}/${ap_bd}    >(esimmode_WTS_.*.tar.bz2)<
    set test variable    ${esim_name}    ${tmp[0]}
    ${ret}    run process and check rc     ls ${yaft_path} 
    ${exist}    evaluate    'AirScale-${ap_bd}.zip' in """"${ret}"""
    run keyword if     'True'=='${exist}'    Return From Keyword
    run keyword and ignore error    run process and check rc    cd /home/ute/trunk;rm AirScale*.zip;rm esimmode*.tar.bz2;rm DCI_link*.tar.gz
    run process and check rc    wget ${ap_usr_pwd} -P ${yaft_path} -q ${build_url}${ap_bd}/AirScale-${ap_bd}.zip
    ${cmd}    set variable     wget ${ap_usr_pwd} -P ${yaft_path} -q ${build_url}${ap_bd}/DCI_link_network_config-${ap_bd}.tar.gz
    run keyword if    '${AP_TYPE}'!='ASIL'    run process and check rc    ${cmd}
    run process and check rc    wget ${ap_usr_pwd} -P ${yaft_path} ${build_url}${ap_bd}/${esim_name}

ap update with yaft
    ${option}    set variable     --clean_to_default
    run process and check rc    cd ${yaft_path};python yaft.py --ignore_FSPs -i ${ap_ip} -z AirScale-${ap_bd}.zip ${option}

ap set domain id
    ute_fsmaccess.Setup Wts Fsm Access
    ute_fsmaccess.Execute Command On Wts    ddal -s ddal_sysinfo_module_set_domain_id 0 5
    ute_fsmaccess.Execute Command On Wts    ddal -s ddal_bip_domain_id_set 4
    ute_fsmaccess.Execute Command On Wts    ddal -s ddal_sysinfo_module_get_domain_id 0
    ute_fsmaccess.Execute Command On Wts    ddal -s ddal_bip_domain_id_get 0
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access

ap get hw type
    ute_fsmaccess.Setup Wts Fsm Access
    ${ret}    ute_fsmaccess.Execute Command On Wts    cat /proc/device-tree/module-identity/unit-id
    ${ret}    Replace String Using Regexp    ${ret}    \x00    ${EMPTY}
    set test variable    ${AP_TYPE}    ${ret}
    log to console    ap hw type is '${AP_TYPE}'
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access

gnb dci link operation
    # gnb fctb board is [ASOE, ASIB, ASIL] skip this step,
    # gnb/ap asik/asik and port15 up, bts execute ./deploy.sh
    # gnb/ap asik/asik and port13 up, gnb/ap 'sed -i 's/eif02/sei13/1' deploy.cfg' and gnb 'execute ./deploy.sh'
    # else bts execute ./deploy.sh
    ${ignore}    evaluate    '${FCT_BOARD_TYPE}' in ${gnb_skip_dci}
    RUN keyword IF    '${ignore}'=='${True}'    Return From Keyword

_ap_asil_operate
    [Documentation]    fix issue No connection to 10.0.2.80, 10.0.2.80 does not exist on neither interfaces, reboot ap is needed
    ute_fsmaccess.Setup Wts Fsm Access
    ${cfg_list}    create list    0    1
    ${content_list}    create list    1    5403
    FOR    ${i}    IN RANGE    2
    ${dir}    set variable    /ffs/run/config/envdata/bts-config/${cfg_list[${i}]}/mcu-fctp
    ${ret}    run keyword and ignore error    ute_fsmaccess.Execute Command On Wts    cat ${dir}/board-config.txt
    Continue For Loop If    '${ret[0]}'=='PASS' and '${ret[1]}'=='${content_list[${i}]}'
    ute_fsmaccess.Execute Command On Wts    mkdir -p ${dir}
    ute_fsmaccess.Execute Command On Wts    echo ${content_list[${i}]} > ${dir}/board-config.txt
    ute_fsmaccess.Execute Command On Wts    crasign ${dir}/board-config.txt
    END
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access

_deploy_sh_operate
    [Arguments]    ${ip}=${ap_ip}    ${option}=${SPACE}    
    ${dci_name}    set variable    DCI_link_network_config-${ap_bd}.tar.gz
    csn.Connect To    ${ip}    ${gnb_usr}    password=${gnb_pwd}    alias=deploy
    csn.Upload File    local_path=${yaft_path}/${dci_name}    remote_path=/user/toor4nsn/${dci_name}    connection=deploy
    csn.execute    cd /user/toor4nsn;rm -rf dci;mkdir dci;mv ${dci_name} ./dci    connection=deploy
    csn.execute    cd /user/toor4nsn/dci;tar -xvf ${dci_name};chmod 777 *;    connection=deploy
    csn.execute    cd /user/toor4nsn/dci;sed -i 's/class/singleChip/1' deploy.cfg    connection=deploy
    csn.execute    cd /user/toor4nsn/dci;echo yes | ./deploy.sh ${option};    connection=deploy
    #csn.send command    reboot    connection=deploy
    #wait until keyword Succeeds     20    5     Check Ping Is Disabled    ${ap_ip}
    #wait until keyword Succeeds     120    5     Check Ping Is Enabled    ${ap_ip}

ap dci link operation
    # gnb ASOE, wts 'sed -i 's/eif02/sei10/1' deploy.cfg;
    # gnb ASIB, wts sed -i 's/eif02/sei13/1' deploy.cfg;
    # gnb/ap ASIL/ASIK port13 up, wts sed -i 's/eif02/sei13/1' deploy.cfg
    # gnb/ap ASIL/ASIK port10 up, wts sed -i 's/eif02/sei10/1' deploy.cfg
    RUN keyword IF    '${AP_TYPE}'=='ASIL'    _ap_asil_operate    #bts ping failed and admin setup failed
    RUN keyword IF    '${AP_TYPE}'=='ASIL'    Return From Keyword
    RUN keyword IF    '${FCT_BOARD_TYPE}'=='ASIB'    _deploy_sh_operate    option=-port sei13
    RUN keyword IF    '${FCT_BOARD_TYPE}'=='ASIB'    _deploy_sh_operate    ip=${ftm_ip}    option=-port ncpeth49
    RUN keyword IF    '${FCT_BOARD_TYPE}'=='ASOE'    _deploy_sh_operate    option=-port sei10

ap relink esimode to latest dir
    log to console    \r\nRelinking the matched esimmode to latest directory
    run keyword and ignore error    run process and check rc    rm -rf /opt/wts/*
    run process and check rc    mkdir /opt/wts/${ap_bd};cd ${yaft_path};tar -xvf ${esim_name} -C /opt/wts/${ap_bd};
    run process and check rc    ln -f -s /opt/wts/${ap_bd} /opt/wts/latest

#ASIB/abio left:  0x124D:0x574A,0x125D:0x584A,0x134D:0x594A
#ASIB/abio right: 0x224D:0x574A,0x225D:0x584A,0x234D:0x594A
#ASIB/asil left:  0x125D:0x574A,0x135D:0x584A,0x145D:0x594
#ASIB/asil right: 0x225D:0x574A,0x235D:0x584A,0x245D:0x594A

#ASIK/abil left:  0x125D:0x574A,0x135D:0x584A
#ASIK/abil right: 0x225D:0x574A,0x235D:0x584A
#ASIL left: 0x124D:0x574A,0x134D:0x584A
#ASIL right: 0x224D:0x574A,0x234D:0x584A
#ASOE: 0x104D:0x574A,0x105D:0x584A
gnb get l1bypass para
    setup_infomodel
    connect_infomodel
    ${ret}     get_infomodel_object      //SMOD_L-1/CONCENTRATOR_L-1
    ${tmp}      set variable    ${ret['positionInRack']}
    ${rack_side}      evaluate       '${tmp}'.lower().strip('side')
    ${asp_abio}    evaluate    'ABIO' in ${ASP_BOARD_TYPE}
    ${asp_asil}    evaluate    'ASIL' in ${ASP_BOARD_TYPE}
    ${asp_abil}    evaluate    'ABIL' in ${ASP_BOARD_TYPE}
    ${cmd}    set variable if  
    ...  '${FCT_BOARD_TYPE}'=='ASIB' and ${asp_abio} and '${rack_side}'=='left'     0x124D:0x574A,0x125D:0x584A,0x134D:0x594A
    ...  '${FCT_BOARD_TYPE}'=='ASIB' and ${asp_abio} and '${rack_side}'=='right'    0x224D:0x574A         #,0x225D:0x584A,0x234D:0x594A
    ...  '${FCT_BOARD_TYPE}'=='ASIB' and ${asp_asil} and '${rack_side}'=='left'     0x125D:0x574A,0x135D:0x584A,0x145D:0x594
    ...  '${FCT_BOARD_TYPE}'=='ASIB' and ${asp_asil} and '${rack_side}'=='right'    0x225D:0x574A,0x235D:0x584A,0x245D:0x594A
    ...  '${FCT_BOARD_TYPE}'=='ASIK' and ${asp_abil} and '${rack_side}'=='left'     0x125D:0x574A,0x135D:0x584A
    ...  '${FCT_BOARD_TYPE}'=='ASIK' and ${asp_abil} and '${rack_side}'=='right'    0x225D:0x574A,0x235D:0x584A
    ...  '${FCT_BOARD_TYPE}'=='ASIL' and '${rack_side}'=='left'     0x125D:0x574A,0x135D:0x584A
    ...  '${FCT_BOARD_TYPE}'=='ASIL' and '${rack_side}'=='right'    0x225D:0x574A,0x235D:0x584A
    ...  '${FCT_BOARD_TYPE}'=='ASOE'     0x104D:0x574A,0x105D:0x584A
    [return]    ${cmd}

gnb set l1bypass      
    [Arguments]      ${cmd}      
    csn.connect to     ${gnb_ip}      ${gnb_usr}     ${gnb_pwd}     alias=gnb
    ${connection_service}     csn.get_connection_by_alias     alias=gnb
    ${channel_service}     Call Method    ${connection_service}     invoke_shell
    set suite variable      ${channel_service}
    ${output}    Call Method     ${channel_service}      recv      ${65535}
    Call Method     ${channel_service}      send     telnet 0 15007\n
    sleep     1
    ${output}    Call Method     ${channel_service}      recv      ${65535}
    Call Method     ${channel_service}      send     tag -3w app.btsom.nts.L1BypassMap ${cmd}\n
    sleep     1
    ${output}    Call Method     ${channel_service}      recv      ${65535}
    ${ret}    evaluate    'succesfully' in """${output}""" or 'tag -3w' in """${output}"""
    run keyword if     'True'!='${ret}'    fail      execute set l1bypass failed 

reboot_operate
    [Arguments]    ${ip}=${ap_ip}     
    csn.Connect To    ${ip}    ${gnb_usr}    password=${gnb_pwd}    alias=deploy
    csn.send command    reboot    connection=deploy
    #wait until keyword Succeeds     20    5     Check Ping Is Disabled    ${ap_ip}
    #wait until keyword Succeeds     120    5     Check Ping Is Enabled    ${ap_ip} 
    sleep    5
    Wait For Host Ssh    ${ap_ip}    tmieout=180

Check 5G gnb or not
    COAM.setup admin
    ${ret}    COAM.get bts info
    ${5g_or_not}     set variable     ${ret['ratState']['nr']}
    Run Keyword If     '${5g_or_not}'=='NO_CELLS'    Fail      It's not a 5G env. Check ${ret['ratState']}  
    [Teardown]     COAM.teardown admin	

make sure gnb and ue ping and ssh ok
    ${gnb_ip}     set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${ue_ip}     set variable    ${tl.ues[0].l1.common_units[0].lmp_connection.addr} 
    set suite variable     ${ue_ip}       ${ue_ip}
    ${gnb_ping}     run keyword and ignore error    Check Ping Is Enabled      ${gnb_ip}
    ${ue_ping}     run keyword and ignore error    Check Ping Is Enabled      ${ue_ip}
    run keyword if      '${gnb_ping[0]}'=='PASS' and '${ue_ping[0]}'=='PASS'     Return From Keyword
    pdu.Setup Pdu    model=${tl.pdus[0].vendor}    host=${tl.pdus[0].addr}
    run keyword if    '${gnb_ping[0]}'!='PASS'    pdu.Power On      ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    run keyword if    '${ue_ping[0]}'!='PASS'    pdu.Power On      ${tl.ues[0].l1.common_units[0].pdu_port.port_no}   
    run keyword if    '${gnb_ping[0]}'!='PASS'   Wait Until Keyword Succeeds     200    10    Check Ping Is Enabled    ${gnb_ip}  
    run keyword if    '${ue_ping[0]}'!='PASS'    Wait Until Keyword Succeeds     200    10    Check Ping Is Enabled    ${ue_ip}     
    run keyword if    '${gnb_ping[0]}'!='PASS'   Wait For Host Ssh    ${gnb_ip}    tmieout=180
    run keyword if    '${ue_ping[0]}'!='PASS'    Wait For Host Ssh    ${ue_ip}    tmieout=180
    run keyword and ignore error    wait until keyword Succeeds    300    30    gnb status should be ready
