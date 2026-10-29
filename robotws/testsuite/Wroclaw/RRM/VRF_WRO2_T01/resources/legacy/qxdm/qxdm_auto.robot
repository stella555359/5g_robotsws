*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords of auto config for QXDM.
Library    taf.sw.qualcomm.license    WITH NAME    license
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/UEConfig.py    WITH NAME    ue_config
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/LKCred.py      WITH NAME    cred
Library    taf.transport.ssh    WITH NAME    ssh
Library    OperatingSystem
Library    Process

*** Variables ***
${LK_path}    /cygdrive/c/Users/wro5grrm.NOKLAB/Desktop/QPM_LK1.5/ClientMain.exe
${run_qxdm_script}    python C:\\\\\auto\\\\\QxdmCommand.py
${run_qcat_cmd}       cd C:\\Program\ Files\ \(x86\)\\Qualcomm\\QCAT\ 6.x\\Bin\\;./QCAT.exe
${q_cfg}    C:\\\\\auto\\\\\qxdm_conf.dmc
${q_out}    C:\\\\\auto\\\\\ue_logs.hdf

${given_ue}    UE_1

*** Keywords ***
Get 5G QXDM and QCAT licenses
    [Arguments]    ${ue}=UE_1
    Set Suite Variable  ${given_ue}  ${ue}
    &{yaml_config}=    ue_config.get_ue_config    ue_yaml_alias=${given_ue}
    &{qxdm_cred}=      cred.get_credentials    uepc_ip=${yaml_config['ue_pc_ip']}   ue_pc_username=${yaml_config['login']}
    ...                                 ue_pc_password=${yaml_config['password']}

    ${launcher}=    Create Dictionary
     ...  host=${yaml_config['ue_pc_ip']}
     ...  path=${LK_path}
     ...  user=${yaml_config['login']}
     ...  password=${yaml_config['password']}

    license.setup   launcher=${launcher}
    license.login   username=${qxdm_cred['login']}  password=${qxdm_cred['password']}
    license.get_licence_qxdm_5g    timeout=120    retry=5
    license.get_licence_qcat_5g    timeout=120    retry=5

Release 5G QXDM and QCAT licenses
    license.release_licence_qxdm_5g
    license.release_licence_qcat_5g
    license.logout
    [Teardown]  license.teardown

Run QXDM logs
    [Arguments]    ${time}
    &{yaml_config}=    ue_config.get_ue_config    ue_yaml_alias=${given_ue}
    ${proc}    start process   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/runner.sh
    ...    ${time}
    ...    ${yaml_config['diag_com']}
    ...    ${yaml_config['password']}
    ...    ${yaml_config['login']}
    ...    ${yaml_config['ue_pc_ip']}
    wait for process  ${proc}
    ${out}    get process result    ${proc}    stdout=true
    log to console    ${out}

Parse HDF to TXT
    &{yaml_config}=    ue_config.get_ue_config    ue_yaml_alias=${given_ue}

    run process   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/qcat_runner.sh
    ...    ${yaml_config['login']}
    ...    ${yaml_config['password']}
    ...    ${yaml_config['ue_pc_ip']}
    sleep    15s

Copy logs from UEPC to VM
     [Arguments]
     ...            ${remote}=/cygdrive/c/auto/ue_logs.txt
     ...            ${local}=/home/ute/robotws/ue_logs.txt
     &{yaml_config}=       ue_config.get_ue_config    ue_yaml_alias=${given_ue}
     ssh.connect_to        hostname=${yaml_config['ue_pc_ip']}
    ...                    username=${yaml_config['login']}
    ...                    password=${yaml_config['password']}

    ssh.download file    ${remote}    ${local}

Parse and collect ue logs
    Parse HDF to TXT
    Copy logs from UEPC to VM
    uea.parse_tput_logs

Get ENDC DL Value
    ${5g_dl}    uea.get value    5g_dl    AvgPHY    avg
    ${lte_dl}    uea.get value    lte_dl    AvgPHY    avg

    ${sum}     evaluate    ${5g_dl}+${lte_dl}
    [Return]    ${sum}

Get ENDC UL Value
    ${5g_ul}    uea.get value    5g_ul    AvgPHY    avg
    ${lte_ul}    uea.get value    lte_ul    AvgPHY    avg

    ${sum}     evaluate    ${5g_ul}+${lte_ul}
    [Return]    ${sum}

Get ENDC DL peak
    ${5g_dl}    uea.get value    5g_dl    AvgPHY    max
    ${lte_dl}    uea.get value    lte_dl    AvgPHY    max

    ${sum}     evaluate    ${5g_dl}+${lte_dl}
    [Return]    ${sum}

Get ENDC UL peak
    ${5g_ul}    uea.get value    5g_ul    AvgPHY    max
    ${lte_ul}    uea.get value    lte_ul    AvgPHY    max

    ${sum}     evaluate    ${5g_ul}+${lte_ul}
    [Return]    ${sum}
