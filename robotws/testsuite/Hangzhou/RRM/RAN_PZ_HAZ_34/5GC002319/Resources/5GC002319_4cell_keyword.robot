*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.ul.oam.selenium_coam    WITH NAME    seleniumC
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical    WITH NAME   selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py


*** Variables ***

*** Keywords ***

L3 call setup
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${dltp}=${0}    ${ultp}=${0}    ${4G_check}=${False}    ${reset_sol}=none
    #${cellid}    Run Keyword If    ${defaultLnRelGnbCellId}==1    set variable    ${160769}
    #...    ELSE IF    ${defaultLnRelGnbCellId}==2    set variable    ${160770}
    #...    ELSE IF    ${defaultLnRelGnbCellId}==5    set variable    ${160771}
    #...    ELSE IF    ${defaultLnRelGnbCellId}==6    set variable    ${160772}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    #Log To Console    \n ###UE Start traffic and check TP ###
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=150M    duration=600    iperf_type=via_command
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=150M    duration=600
    #power_ue.Check throughput    ue_index=${ue_index}    direction=dl    ue_type=${UE_TYPE}    throughput=${dltp}
    #power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${UE_TYPE}    throughput=${ultp}    cellid=${cellid}
    #power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}
    #power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
    #Log To Console    \n ### UE Detach ###
    #power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

L3 call stop
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}


Check PM counters
    [Arguments]    ${counter_id}=M55306C06001    ${sleep}=${0}    ${num_count}=${0}    ${counter_path}=BTS/CELLS/NRCELL-2/NMOCU
    ${reportingIntervalPm}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    run keyword if    ${sleep}==${1}    sleep    ${reportingIntervalPm}
    ${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=${counter_id}
    ...    dic_path=${counter_path}    min_len=${0}
    log to console    ${counter_id}=${sb1_dlcounter}
    should be true    ${sb1_dlcounter} > ${num_count}



Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1
    log to console    ${counter_id}    ${dic_path}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${dic_path}    date=${date}
    ${len}    get length    ${counter_value}
    should be true    ${len} > ${min_len}
    [Return]    ${counter_value[0]}

Get parameter value
    [Arguments]   ${class_name}=NRBTS_A    ${pattern}=a2MeashoEnabledSA    ${connection}=COAM    ${target_cell}=2
    @{MOs}    admin_cli.get_managed_objects    class_name=${class_name}    connection=${connection}
    &{dict_pattern}=    admin_cli.get_parameters    dist_name=${MOs[${target_cell}]['distName']}  pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-10048/NRBTS-10048/NRCELL-1    ${skip_parameter_relation_errors}=False
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    sleep    3s

Modify HBTE Channel Vaules
    [Arguments]    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    ${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}


Set PA
    Connect to eNB via ssl
    ${defaultLnRelGnbCellId}    Get NIDD parameter value    class_name=LNCEL_A    pattern=defaultLnRelGnbCellId    connection=enblte
    set suite variable    ${defaultLnRelGnbCellId}
    run keyword if    ${defaultLnRelGnbCellId}==1    run keywords
    ...    Modify HBTE Channel Vaules    value=10    ru_id=0    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=1    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=2    gnb_id=0
    run keyword if    ${defaultLnRelGnbCellId}==2    run keywords
    ...    Modify HBTE Channel Vaules    value=10    ru_id=1    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=0    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=2    gnb_id=0
    run keyword if    ${defaultLnRelGnbCellId}==5    run keywords
    ...    Modify HBTE Channel Vaules    value=10    ru_id=2    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=0    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=1    gnb_id=0

Check delta frequency
    [Arguments]    ${distname}    ${check_num}=${80000}
    ${nrarfcn_dl_dict}    admin_cli.get_parameters    dist_name=${distname}    pattern=nrarfcnDl    connection=COAM
    ${nrarfcn_dl}    set variable     ${nrarfcn_dl_dict['nrarfcnDl']}
    ${nrarfcn_ul_dict}    admin_cli.get_parameters    dist_name=${distname}    pattern=nrarfcnUl    connection=COAM
    ${nrarfcn_ul}    set variable     ${nrarfcn_ul_dict['nrarfcnUl']}
    ${nrarfcn_delta}=    Evaluate    ${nrarfcn_dl} - ${nrarfcn_ul}
    ###/n   FREF=FREF_offs+ΔF_global*(NREF-NREF_offs)=0MHz+5KHz*(nrarfcn-0)###
    ###/n   400MHz=FREF_dl-FREF_ul
    ###/n   80000 = 400MHz/5KHz
    should be equal    ${nrarfcn_delta}    ${check_num}

Get version based on stream version
    [Documentation]    Author: Ding Binmei
    ...                Description: Change the implementation to get program info from GNB.
    ...                Retrun with ${program_version}, valid output: 19A, 19B, 20B, master, ...
    ...                current master version is 21B, if changed then need to update
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    ${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ssh.disconnect  connection=ASIK Master
    [Return]    ${program_version}


Precondition
    [Arguments]    ${type}=NSA    ${freqBandIndicatorNR_expect}=${66}    ${ChBwdl_except}=20MHz
    ...    ${ChBwul_except}=10MHz    ${gscn_expect}=${5364}    ${nrarfcndl_expect}=${429000}
    log to console    \n in precondition stage
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=COAM
    Connect to eNB via ssl    connection=enblte
    run keyword if    '${type}' == 'NSA'
    ...    admin_cli.perform_commissioning    scf_file=/home/ute/casetest/5GC002319_NSA.xml    connection=COAM
    run keyword if    '${type}' == 'SA'    run keywords
    ...    Modify the parameter on enblte    dist_name=MRBTS-922/LNBTS-922/LNCEL-1    parameter_name=administrativeState    value=locked
    ...    AND    admin_cli.perform_commissioning    scf_file=/home/ute/casetest/5GC002319_SA.xml    connection=COAM

    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=COAM

    ${version}    Get version based on stream version
    ${gscn}    set variable if    '${version}'=="21B"    gscn    gscnOrSsPbchArfcn

    ${gscn_value}    Get parameter value    class_name=NRCELL_A    pattern=${gscn}    connection=COAM    target_cell=2
    run keyword if    ${gscn_value} != ${gscn_expect}    Set parameter
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=${gscn}    value=${gscn_expect}    skip_parameter_relation_errors=True

    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_A    connection=COAM
    ${full_path}    set variable    ${MOs[0]['distName']}

    ${nrarfcndl_dict}    admin_cli.get_parameters    pattern=nrarfcnDl    connection=COAM
    ...    dist_name=${full_path}/NRCELL_A-2/NRCELL_FDD_A-1
    ${nrarfcndl}    set variable     ${nrarfcndl_dict['nrarfcnDl']}
    run keyword if    ${nrarfcndl} != ${nrarfcndl_expect}
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1    key=nrarfcnDl
    ...    value=${429000}    skip_parameter_relation_errors=True

    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_A    connection=COAM
    ${full_path}    set variable    ${MOs[0]['distName']}

    ${ChBwdl_dict}    admin_cli.get_parameters    dist_name=${full_path}/NRCELL_A-2/NRCELL_FDD_A-1    pattern=chBwDl    connection=COAM
    ${ChBwdl}    set variable     ${ChBwdl_dict['chBwDl']}
    ${ChBwul_dict}    admin_cli.get_parameters    dist_name=${full_path}/NRCELL_A-2/NRCELL_FDD_A-1    pattern=chBwUl    connection=COAM
    ${ChBwul}    set variable     ${ChBwul_dict['chBwUl']}
    run keyword if    '${ChBwdl}' != '${ChBwdl_except}'
    ...    Set parameter    key=chBwDl    value=${ChBwdl_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    run keyword if    '${ChBwul}' != '${ChBwul_except}'
    ...    Set parameter    key=chBwUl    value=${ChBwul_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1

    ${freqBandIndicatorNR}    Get parameter value    class_name=NRCELL_A    pattern=freqBandIndicatorNR    connection=COAM    target_cell=2
    run keyword if    ${freqBandIndicatorNR} != ${freqBandIndicatorNR_expect}
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=freqBandIndicatorNR
    ...    value=${freqBandIndicatorNR_expect}

    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=COAM

    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_A    connection=COAM
    ${full_path}    set variable    ${MOs[0]['distName']}

    Check delta frequency        distname=${full_path}/NRCELL_A-2/NRCELL_FDD_A-1
    Modify the parameter on enblte        dist_name=MRBTS-922/LNBTS-922/LNCEL-1    parameter_name=defaultLnRelGnbCellId    value=${2}
    Set PA



teardown
    [Arguments]    ${UE_TYPE}=qct_dx50
    log to console    \n in teardown stage
    admin_cli.teardown    connection=COAM
    Modify the parameter on enblte    dist_name=MRBTS-922/LNBTS-922/LNCEL-1    parameter_name=administrativeState    value=unlocked
    Enblte close down    connection=enblte
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

## TTI trace

