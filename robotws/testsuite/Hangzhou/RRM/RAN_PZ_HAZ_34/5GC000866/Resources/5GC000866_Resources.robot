*** Settings ***
Documentation     author: Yuan Hongyan
...               contact: Hongyan.1.yuan@nokia-sbell.com

#Resource          ../../5GC000900/Resources/5GC000900.robot
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           taf.ue    WITH NAME    ute_ue
Library           ../../5GC000638/Resources/coam_close.py
#Variables    ${CFGFILE_ON_GIT}5GC000866/Delta_SCF.py
#Variables         ${TL_CFGFILE_PATH_ON_GIT}/TLDelta.py

*** Variables ***
&{NEA0}    filter_param=Null ciphering algorithm  abbr=nea0   new_value=0
&{NEA1}    filter_param=SNOW 3G-based algorithm  abbr=nea1_128   new_value=0
&{NEA2}    filter_param=AES-based algorithm  abbr=nea2_128   new_value=0
&{NEA3}    filter_param=ZUC-based algorithm  abbr=nea3_128   new_value=0
&{NIA1}    filter_param=SNOW 3G-based algorithm  abbr=nia1_128   new_value=0
&{NIA2}    filter_param=AES-based algorithm  abbr=nia2_128   new_value=0
&{NIA3}    filter_param=ZUC-based algorithm  abbr=nia3_128   new_value=0
#@{ALG_CHANGE_LIST}       &{NEA0}   &{NEA1}   &{NEA2}   &{NEA3}   &{NIA1}   &{NIA2}   &{NIA3}

${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile
#${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${TL_CFGFILE_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${TL_DeltaPath}          ${TL_CFGFILE_PATH_ON_GIT}/TLDelta.py
#${GoldenScf_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG
#${MODIFIED_CFGFILE_TLSCF}   /home/ute/TAF/cfgfile/modified_SCF/
#${Original_CFGFILE}         ${CFGFILE_PATH}5GC000866/Configuration_scf_original.xml
${IMSI}              ${tl.ues[0].imsi}
${PB_MTK_IP}         ${tl.ues[0].pdu.pdu.addr}
${PB_MTK_PORT}       ${tl.ues[0].pdu.port_no}

${MRBTS_ID}      MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}     NRBTS-${tl.gnbs[0].global_bts_id}
${dist_name}    ${MRBTS_ID}/${NRBTS_ID}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${MTK_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
${MTK_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
${MTK_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}


${REPEAT_TIME}    ${50}
${THRESHOLD}      ${49}
${EXPECTED_PRECENT}    10



##################define these variable for convenient############################
${ALIAS_ASIK}     asik
${ALIAS_ASIK_SLAVE}    ASIK_slave
${ALIAS_UTE}      ute
${ALIAS_ENBCTLPC}    ENB_PC
${ALIAS_SHP}      SHP
${ALIAS_E500}     E500
${ALIAS_PRISMA}    Prisma
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}    LONER
${ALIAS_ASP_1A}    ASP_1A
${AlIAS_QC}       Qualcomm
${UE_alias}       UE_0
${ALIAS_5GC}      5gc
########################END of alias Define#######################################

*** Keywords ***
TC.5GC000865_B_5GC000866_B_6_Configure AES_Integration protection and ciphering for DL Data (DRB) transfer
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
	Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
	set test variable    ${detach_request}    ${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
	set test variable    ${power_reset}    ${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    detach_request=${detach_request}    power_reset=${power_reset}
    Modify TestLineSCF to 866scf
    Process.Verify gNB Readiness and Fail Case if Not After Reset
    Get rid of loner ssh fingerprint change issue
    Set Agorism Values   nia2_value=1    nea2_value=1
    Modify Ciphering and Integration value for gNB
    #Modify Ciphering and Integration value for gNB    AES=1
    gNB.ASIBConnect
    Wireshark.StartCaptureNGLog   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_UL.pcap
    Wireshark.StartCaptureLogFromContainer    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_UL.pcap    nodename=CPIF
    power_ue.Prepare UE    ue_type=${UE_TYPE}    detach_request=${detach_request}    power_reset=${power_reset}
    run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${power_reset}
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${power_reset}
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=22MKbits/sec    duration=90s
    sleep    30s
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
    Wireshark.StopCaptureNGLog
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    run keyword and ignore error    DownloadAlllogtoUTE
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=${power_reset}

Process.Verify gNB Readiness and Fail Case if Not After Reset
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}   Powercycle gNB until Ready

Powercycle gNB until Ready
    Power.ResetgNB
    Power.Reset5GRU
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

Get rid of loner ssh fingerprint change issue
    gNB.ASIBConnect
    ssh.execute    command=ssh-keygen -R 192.168.253.22 -f /user/toor4nsn/.ssh/known_hosts   connection=${ALIAS_ASIK}
    ${wa_presence}    ssh.execute    command=cat /etc/ssh/ssh_config| grep "Host 192.168.253.22"    connection=${ALIAS_ASIK}
    run keyword if  not '${wa_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'    run keywords
    ...    ssh.execute    command=sed -i "1i\\Host 192.168.253.22" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ...    AND    ssh.execute    command=sed -i "2i\\${SPACE*3}StrictHostKeyChecking no" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ...    AND    ssh.execute    command=sed -i "3i\\${SPACE*3}UserKnownHostsFile=/dev/null" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    gNB.ASIBDisconnect

Modify TestLineSCF to 866scf
    #Import Variables    ${CFGFILE_PATH}5GC000866/Delta_SCF.py
    Generate 866 SCF
    gNB.Commission    scf_file=${LOG_PATH}/866_1cell_SA.xml    timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend

Setup 866 suite
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    gNB.EnableDebugLog
    Create Log Directories
    set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    ASIB.get containerid    nodename=CPIF
    #ChangeSwcofigByFlag    flag=0x590048    value=0
    #Modify GoldenSCF to TestLineSCF
    gNB.GenerateTestLineSCFs
    Generate 866 SCF
    gNB.Commission    scf_file=${LOG_PATH}/866_1cell_SA.xml    timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Run Keyword And Ignore Error    force_close_coam_webdriver
    #spark.restartapp    index=${0}
    Conn.ResetCache

Setup My Suite
#    Import Variables    ${CFGFILE_PATH}5GC000866/Delta_SCF.py
    TestSuite.Start
    Setup 866 Suite
    #GNB.SwconfigReplace  file_path=${CFGFILE_PATH}/5GC000865_866
    #GNB.Commissioning   scf_file=scf_s1_sa.xml   file_path=${CFGFILE_PATH}/5GC000865_866
    #    COAM_Admin.BackupSCF
    TestSuite.Start

Teardown My suite
    Set Agorism Values    nia3_value=9    nea3_value=9
    Run Keyword And Ignore Error     Modify Ciphering and Integration value for gNB
    TestSuite.Stop


Modify GoldenSCF to TestLineSCF
    gNB.GenerateTestLineSCFs
#    gNB.ModifySCF    InputFile=${GoldenScf_PATH}/${GoldenSCF}
#    ...              OutputFile=${LOG_PATH}/TestLineSCF1Cell_Both.xml
#    ...              ParameterToDelete=${TL_PARAMS_TO_DELETE_1CELL}
#    ...              MOsToAdd=${TL_ADD_MOS_1CELL}
#    ...              ParamterToModify=${TL_PARAMS_TO_MODIFY_1CELL}
#    ...              ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_1CELL}
#    ...              ListToAdd=${TL_LIST_TO_ADD_1CELL}
#    gNB.ReplaceSCFbtsID     SCFFilePath=${LOG_PATH}/TestLineSCF1Cell_Both.xml
#	...                     MRBTSID=${MRBTS_ID}
#    ...                     NRBTSID=${NRBTS_ID}

Generate 866 SCF
	[Arguments]
	gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF1Cell.xml    OutputFile=${LOG_PATH}/866_1cell_SA.xml
    ...                    ResourceFolder=${CURDIR}
	...                    ParamterToModify=PARAMS_TO_MODIFY_866
	...                    ParameterToDelete=PARAMS_TO_REMOVE_866

gNB.EnableDebugLog
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=cp /user/toor4nsn/wa/cp_runtime.ini /rom/   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}


gNB.ASIBConnect
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
gNB.ASIBDisconnect
    Conn.Disconnect  alias=${ALIAS_ASIK}

ASIB.get containerid
    [Arguments]    ${nodename}=${nodename}
    ${container}   gnb.get_container_id    nodename=${nodename}
    set suite variable   ${containerid}    ${container}

Wireshark.ASIBDownloadLogToUTE
    [Arguments]    ${logtype}=${logtype}    ${filename}=${filename}   ${log_dir}=/tmp    ${connection}=${ALIAS_ASIK}
    [Timeout]    5min
    run keyword if    '${logtype}'=='BIP'
    ...    ssh.execute    command=scp /tmp/tcpdumpL2L1_filtering_off.pcap0 /tmp/${filename}    connection=${connection}
    ...    ELSE IF    '${logtype}'=='CPIF'
    ...    ssh.execute    command=scp /tmp/node_CPIF00/tmp/${filename} /tmp/${filename}    connection=${connection}
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${log_dir}/${filename}   connection=${connection}
    sleep    20s

Modify Ciphering and Integration value for gNB
    [Arguments]  ${dist_name}=${dist_name}   ${change_list}=@{ALG_CHANGE_LIST}
    COAM_WebEM.Login
    FOR    ${item}    IN    @{change_list}
        selenium_coam.set_parameter_value    dist_name=${dist_name}  filter_param=${item}[filter_param]  abbr=${item}[abbr]
    ...    new_value=${item}[new_value]
    END
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    COAM_WebEM.Logout

Set Agorism Values
    [Arguments]   ${nea0_value}=0   ${nea1_value}=0   ${nea2_value}=0   ${nea3_value}=0    ${nia1_value}=0  ${nia2_value}=0  ${nia3_value}=0
    Set To Dictionary    ${NEA0}    new_value=${nea0_value}
    Set To Dictionary    ${NEA1}    new_value=${nea1_value}
    Set To Dictionary    ${NEA2}    new_value=${nea2_value}
    Set To Dictionary    ${NEA3}    new_value=${nea3_value}
    Set To Dictionary    ${NIA1}    new_value=${nia1_value}
    Set To Dictionary    ${NIA2}    new_value=${nia2_value}
    Set To Dictionary    ${NIA3}    new_value=${nia3_value}
    ${change_list}=    create list    ${NEA0}   ${NEA1}   ${NEA2}   ${NEA3}   ${NIA1}   ${NIA2}   ${NIA3}
    Set Suite Variable    ${ALG_CHANGE_LIST}     ${change_list}
    Log    ${ALG_CHANGE_LIST}

DownloadAlllogtoUTE
    Wireshark.ASIBDownloadLogToUTE    logtype=CPIF    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_UL.pcap
    Wireshark.ASIBDownloadLogToUTE    logtype=NG    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_UL.pcap
