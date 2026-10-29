*** Settings ***
Documentation     author: Frank Luo
...               Group: HGZ_SG1
...               contact: frank.s.luo@nokia-sbell.com

Resource          ../../5GC000496_C/Resources/L3Call.robot
#Resource          ../../common/made_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           ../../../../SISO/RAN_PZ_HAZ_34/5GC001278/Library/get_bts_info.py    WITH NAME    lib
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py

*** Variables ***
#${TLDelta_PATH_ON_GIT}      /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${CFGFILE_ON_GIT}           ${CFGFILE_PATH}/5GC001473/
#${MODIFIED_CFGFILE_1}    ${CFGFILE_ON_GIT}1473H_QAM64_2x2MIMO.xml
#${MODIFIED_CFGFILE_2}    ${CFGFILE_ON_GIT}1473G_QAM256_4x2MIMO.xml

${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
&{fault_10}                 faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
${alarm_filter_0}           1807
${alarm_filter_1}           No connection to unit
${CPRI_link_status}         /tmp/CPRI_link.log
${VM_CPRI_link}             /tmp/CPRI/
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/
${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
#${UE_TYPE}                  huawei
${asik_dir}                 /ffs/run/config/toor4nsn/

${remote_dir}=    /mnt/sw/
${local_dir}=   ${CURDIR}/
${file_name}=    DIR1
${correct_file}=   DIR2
${log_file_name}=   ru_log
${log_remote_dir}=    /ram/
${log_local_dir}=   ${OUTPUT_DIR}/


#@{bandswith}   60   80   100
#@{bandswith}    90
#${cell_index}   1
#${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_index}

*** Keywords ***

BTS reset and check status
    Perform BTS Site Reset  download_dir=${TS_CASE_LOG_PATH}
    sleep   10min
    wait until keyword succeeds    5min    30s    Verify all cells should be onair


L3_Call
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${cell_list}    create list    ${cell_id}
        Run Keyword And Continue On Failure  Get UE From Init File and Make call    cell_list=${cell_list}
        ...   ue_num_each_call=1    dl_tp=1000M   ul_tp=50M    duration=${300}  loop_times=2    actual_rate=0.5
#     ...   dl_exp=500    ul_exp=40
    END

Modify RU Version and reboot RU
    [Arguments]  ${ru_index}=1
    Log To Console     Modify RU Version and reboot RU
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    ${output}=   csn.execute   command=cat /mnt/sw/DIR1   connection=RU_${ru_index}
    ${match}   ${activeBuild}=   Should Match Regexp   ${output}   activeBuildName=(\\\"[^\\\"]*\\\")
    ${modified_build}=   set variable  1${activeBuild}
    csn.execute   command=sed -i s/${activeBuild}/${modified_build}/g /mnt/sw/DIR1   connection=RU_${ru_index}
    csn.execute   command=cat /mnt/sw/DIR1   connection=RU_${ru_index}
    csn.send_command   command=Reboot   connection=RU_${ru_index}
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}

Change RU Verison to original one and reboot RU
    [Arguments]  ${ru_index}=1
    Log To Console    Change RU Verison to original one and reboot RU
    ${error_file}=   set variable   ${remote_dir}${file_name}
    ${correct_file}=  set variable   ${remote_dir}${correct_file}
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    Write   \\cp ${correct_file} ${error_file}
    Read Until  expected=$
    Write   reboot

Change Bandwith
    [Documentation]   chbw change in webui
    [Arguments]   ${new_band}
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    ${dist_name_1}   Set Variable   ${tl.gnbs[0].global_bts_id}/${tl.gnbs[0].instance_id}/NRCELL-${1}
    ${dist_name_2}   Set Variable   ${tl.gnbs[0].global_bts_id}/${tl.gnbs[0].instance_id}/NRCELL-${2}
    ${curr_band_1}   selenium_coam.Get Parameter Value   dist_name=${dist_name_1}   filter_param=Channel bandwidth
    ${curr_band_2}   selenium_coam.Get Parameter Value   dist_name=${dist_name_2}   filter_param=Channel bandwidth
    Return From Keyword If   '${new_band}MHz'=='${curr_band_1}'  and  '${new_band}MHz'=='${curr_band_2}'
    COAM_WebEM.ModifyParameters   dist_name=${dist_name_1}   filter_param=Channel bandwidth   new_value=${new_band}MHz
    COAM_WebEM.ModifyParameters   dist_name=${dist_name_2}   filter_param=Channel bandwidth   new_value=${new_band}MHz
    COAM_WebEM.ValidateAndActiveParameters
    Wait until keyword succeeds    20 min    20 sec    COAM Check GNB cell on air
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]   Run Keyword and Ignore Error   COAM_WebEM.Logout


RU reset and check status
    [Arguments]  ${gnb_type}='NSA'
    Perform RU Reset    ru_index=${1}   download_dir=${TS_CASE_LOG_PATH}
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${gnb_type}=='NSA'
    ...    run keywords  sleep    ${sleep_time}min   AND
    ...    Wait For Expect Fault Present  faultId=7300   timeout=500
    Wait Until Keyword Succeeds  10min    20 sec   COAM Check GNB cell on air
    Wait Until Keyword Succeeds  5min    20 sec   Verify all cells should be onair
    run keyword if   ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  6min  20sec  Expect Fault Should Absent    faultId=7300
    Run keyword if  ${gnb_type}=='NSA'   Wait Until Keyword Succeeds  5min    20 sec   COAM Check X2 link status from GNB
#    L3_Call_2UE
    [Teardown]  COAM selenium logout

