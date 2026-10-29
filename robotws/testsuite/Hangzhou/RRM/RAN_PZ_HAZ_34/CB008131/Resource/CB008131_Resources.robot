*** Settings ***
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Resource    ../../5GC000496_C/Resources/L3Call.robot
#Resource   ../../5GC001817_FDD/Resource/5GC001817_Resources.robot

Resource     taf/rfrl/common_resources/robot/coam_selenium.robot
Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#Library     ../../../../SISO/Hangzhou/5GC001278/Library/get_bts_info.py    WITH NAME    lib\
#Library             taf.sw.dcap.rd		WITH NAME	rd
#Library     ../../../resources/common/python/check_csv_log.py
#Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
#Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008131/Resource/check_sherpa_csv.py
#Library      ./check_sherpa_csv.py
#Library      ./check_dcap_result_json.py


#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta_SBTS.py

*** Variables ***
${SHERPA_LOG_PATH}          /home/ute/sherpa_log/

#${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/CB008131/
#${DeltaPath}                ${CFGFILE_ON_GIT}Delta_SCF.py
${DeltaPath}                ${CURDIR}/CaseSCFDelta.py
${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${TLDelta_PATH_ON_GIT}      /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}
#${IMSI2}                     ${tl.ues[1].imsi}

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${dist_name}                ${MRBTS_ID}/${NRBTS_ID}

${PA1_INFO}                  ${tl.attenuators[0]}
${PA2_INFO}                  ${tl.attenuators[1]}
@{DFAULT_COLUMN_TO_CHECK}    PCI


##################define these variable for convenient############################
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc
${ALIAS_AMF}                AMF
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####

TC.CB008131_A_01_A-CSI reporting for FR1 CA deployment, 2CCs CA in FDD with DL and UL data transmission
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/8131_A_01_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_8131_A_01    parameters_to_delete=PARAMS_TO_DELETE_8131_A_01
    ...    mo_to_add=ADD_MOS_8131_A_01    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_8131_A_01
    ...    list_to_add=LIST_TO_ADD_8131_A_01
    KW.Get NR Cell Indentities
    KW.Get Physical Cell IDs
    KW.Adjust PA before attach
    KW.Prepare and Attach UE with CPIF Log Collected  log_filename=CPIF_8131_A01_CAblind.pcap
    KW.Adjust PA after attach
    KW.Start DL Traffic and Check Scell Throughput
    KW.Start Bi Traffic and Check Pcell Throughtput with Sherpa Log Collected
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
    run keyword and continue on failure    KW.Verify_Sherpa_Logs
    run keyword and ignore error     KW.Check Scell to Add    filename=CPIF_8131_A01_CAblind.pcap

TC.CB008131_W_01_DL performance comparing between FDD CA Pcell and non-CA cell with ACSI enabled
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/8131_A_01_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_8131_W_01    parameters_to_delete=PARAMS_TO_DELETE_8131_W_01
    ...    mo_to_add=ADD_MOS_8131_W_01    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_8131_W_01
    ...    list_to_add=LIST_TO_ADD_8131_W_01
    KW.Get NR Cell Indentities
    KW.Get Physical Cell IDs
    KW.Adjust PA before attach
    KW.Prepare and Attach UE with CPIF Log Collected  log_filename=CPIF_8131_W01_CAblind.pcap
    KW.Adjust PA after attach
    KW.Start Bi Traffic and Check Pcell and Scell Throughtput with Sherpa Log Collected  ul_throughput=100M   dl_throughput=800M
    ...    duration=1800    pcell_ul_target=70   pcell_dl_target=140   scell_dl_target=280
    run keyword and continue on failure    DCAP.Extract_out_Log_Files  tracer=udptracer
    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
    run keyword and continue on failure    KW.Verify_Sherpa_Logs
    run keyword and ignore error     KW.Check Scell to Add    filename=CPIF_8131_W01_CAblind.pcap

TC.CB008131_A_06_A-CSI reporting for FR1 CA deployment, 2CCs CA in FDD with measurement gap enabled
    [Documentation]  Main test Steps:
	...    1. Precondition of SCF: Disable feature  545/DRX, enable Pcell MG feature (threshold is  P A2), CA scell add based on A1
	...    2. Adjust PA (Pcell(cell1) 5, Scell(cell2) max)   #5 let Pcell RSRP -60dBm
	...    3. Start collect CPIF
	...    4. UE attach to Pcell(cell1)
	...    5. Adjust PA (Scell(cell2) 25)     #25 let Scell RSRP -60dBm
	...    6. Adjust PA (Pcell(cell1) X), X is below than P A2 threshld to trigger A2 event
	...    7. Stop collect CPIF
	...    8. Do DL traffic 600M to activate Scell
	...    9. Check Scell(cell2) DL througphut  {Optional (cause sherpa can"t work now)}
	...    10. Start DL traffic  10M, UL traffic 10M
	...    11. Collect Sherpa
	...    12. Stop Sherpa
	...    13. Check DL traffic Pcell(cell1) 10M, UL traffic 10M
	...    14. Check CPIF MG is enabled
	...    15. Check Sherpa  PCSI
	...    16. Check Sherpa  ACSI
    ...    17.Check CPIF MG is enabled
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/8131_A_06_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_8131_A_06    parameters_to_delete=PARAMS_TO_DELETE_8131_A_06
    ...    mo_to_add=ADD_MOS_8131_A_06    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_8131_A_06
    ...    list_to_add=LIST_TO_ADD_8131_A_06
    KW.Get NR Cell Indentities
    KW.Get Physical Cell IDs
    KW.Adjust PA_A06_before attach
    KW.Prepare and Attach UE with CPIF Log Collected  log_filename=CPIF_8131_A06_Attach.pcap
    KW.Start DL Traffic and Check Scell Throughput
    KW.Start Bi Traffic
    KW.Start Collect CPIF   log_filename=CPIF_8131_A06_MG.pcap
    KW.Adjust PA_A06_MG
    KW.Stop Collect CPIF and Download  log_filename=CPIF_8131_A06_MG.pcap
    KW.Check Pcell Throughtput
    KW.CollectSherpaTrace
    KW.Adjust PA_A06_Scell_Release
    KW.Stop Bi Traffic
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
    run keyword and continue on failure    KW.Verify_Sherpa_Logs
    run keyword and ignore error     KW.Check Scell to Add    filename=CPIF_8131_A06_Attach.pcap
    KW.Check MG enable     filename=CPIF_8131_A06_MG.pcap



TC.CB008131_A_09_A-CSI reporting for FR1 CA deployment, 2CCs CA in FDD, Scell release triggered by A2 measurement event
    [Documentation]  Main test Steps:
	...    1. Precondition of SCF: Disable feature  MG/DRX, enable Pcell 545 feature (threshold is  P 545), CA scell add based on A1
	...    2. Adjust PA (Pcell(cell1) 0, Scell(cell2) max)
	...    3. Start collect CPIF 1
	...    4. UE attach to Pcell(cell1)
	...    5. Adjust PA (Scell(cell2) 25)
	...    6. Adjust PA (Pcell(cell1) Y), Y is below than P 545 threshold to enable 545
	...    7. Stop collect CPIF 1
	...    8. Do DL traffic 600M to activate Scell
	...    9. Check Scell(cell2) DL througphut  {Optional (cause sherpa can"t work now)}
	...    10. Start DL traffic  10M, UL traffic 10M, time shall be long enough to step 13 check
	...    11. Collect Sherpa
	...    12. Stop Sherpa
	...    13. Start collect CPIF 2
	...    14. Adjust PA (Scell(cell2) Z), Z is below than S A2 threshold
	...    15. Adjust PA (Pcell(cell1) A), A is higher than P 545 threshold to disable 545
	...    16. Stop collect CPIF 2
	...    17. Check DL traffic Pcell(cell1) 10M, UL traffic 10M
	...    18. Check CPIF 1, 545 is enabled
	...    19. Check CPIF 2, 545 is disabled
	...    20. Check Sherpa  PCSI
    ...    21. Check Sherpa  ACSI
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/8131_A_09_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_8131_A_09    parameters_to_delete=PARAMS_TO_DELETE_8131_A_09
    ...    mo_to_add=ADD_MOS_8131_A_09    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_8131_A_09
    ...    list_to_add=LIST_TO_ADD_8131_A_09
    KW.Get NR Cell Indentities
    KW.Get Physical Cell IDs
    KW.Adjust PA_A09_before attach
    KW.Prepare and Attach UE with CPIF Log Collected  log_filename=CPIF_8131_A09_Attach.pcap
    KW.Start DL Traffic and Check Scell Throughput
    KW.Start Bi Traffic
    KW.Start Collect CPIF   log_filename=CPIF_8131_A09_TP_enable.pcap
    KW.Adjust PA_A09_TP_enable
    KW.Stop Collect CPIF and Download  log_filename=CPIF_8131_A09_TP_enable.pcap
    KW.CollectSherpaTrace
    KW.Start Collect CPIF   log_filename=CPIF_8131_A09_Scell_Release.pcap
    KW.Adjust PA_A09_Scell_Release
    KW.Stop Collect CPIF and Download  log_filename=CPIF_8131_A09_Scell_Release.pcap
    KW.Start Collect CPIF   log_filename=CPIF_8131_A09_TP_disable.pcap
    KW.Adjust PA_A09_TP_disable
    KW.Stop Collect CPIF and Download  log_filename=CPIF_8131_A09_TP_disable.pcap
    KW.Check Pcell Throughtput
    KW.Stop Bi Traffic
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
    run keyword and continue on failure    KW.Verify_Sherpa_Logs
    run keyword and ignore error     KW.Check Scell to Add    filename=CPIF_8131_A09_Attach.pcap
    KW.Check TP enable     filename=CPIF_8131_A09_TP_enable.pcap
    KW.Check TP disable    filename=CPIF_8131_A09_TP_disable.pcap
    KW.Check Scell Release   filename=CPIF_8131_A09_Scell_Release.pcap

####Case Level Keywords#####
KW.Adjust PA before attach
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 before attach.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 before attach.

KW.Adjust PA after attach
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_3']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 after attach.

KW.Adjust PA_A06_before attach
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_06']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 more than A1 before attach.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_06']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 more than A2 before attach.

KW.Adjust PA_A06_MG
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_06']['PA_Value_3']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 to let MG enable.

KW.Adjust PA_A06_Scell_Release
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_06']['PA_Value_4']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 less than A2 after attach.

KW.Adjust PA_A09_before attach
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_09']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 more than A1 before attach.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_09']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 more than A2 before attach.

KW.Adjust PA_A09_TP_enable
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_09']['PA_Value_3']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 to enable transform precoding.

KW.Adjust PA_A09_Scell_Release
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_09']['PA_Value_4']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 less than A2 to release scell.

KW.Adjust PA_A09_TP_disable
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_09']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 less than A2 to release scell.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_09']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 to disable transform precoding.


KW.PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}   ${logging_message}=Adjusting PA values
    log to console    ${logging_message}
    PA_.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA_.set_attenuation     port=${ports[${i}]}    value=${value}
        PA_.read_attenuation    port=${ports[${i}]}
    END

Setup Suite for 8131
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
#    set suite variable    ${CFGFILE_ON_GIT}           ${CFGFILE_PATH}/CB008131/
    Import Variables        ${CURDIR}/CaseSCFDelta.py
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTSTRUNK.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTS22R1.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTS22R2.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTS22R3.py
    set suite variable    ${DeltaPath}                ${CURDIR}/CaseSCFDelta.py
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    ${outputfile}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${TLDelta_PATH_ON_GIT}
#	...            TestLineSCF_cell_num=${1}    cell_type=Both
#	...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}
#    ...            TLDelta_PATH=${TLDelta_PATH_ON_GIT}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ${outputfile}    gNB.GenerateTestLineSCFs
    set suite variable    ${Original_CFGFILE}    ${outputfile}
#	gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#	set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    Conn.ResetCache
    set suite variable     ${5GRU1_PA_Ports}       ${CASE_INPUT_CB008131['CB008131']['5GRU1_PA_Ports']}
    set suite variable     ${5GRU2_PA_Ports}       ${CASE_INPUT_CB008131['CB008131']['5GRU2_PA_Ports']}
    set suite variable     ${dcap_ip}    ${CASE_INPUT_CB008131['CB008131']['dcap_server_ip']}
    set suite variable     ${dcap_port}    ${CASE_INPUT_CB008131['CB008131']['dcap_server_port']}

Teardown Suite for 8131
    TestSuite.Stop
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Set back PA values for RU1.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Set back PA values for RU1.

Setup case for 8131
#    TestCase.Start
    log to console     Case Start

Teardown case for 8131
#    log     ${TEST STATUS}
#    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
#    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error     rd.delete_bts
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
#    Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
#    TestCase.Stop

KW.ModifyAndCommissionAndCheckOnair
    [Documentation]    1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
    ...               ${modified_cfgfile}
    ...               ${parameters_to_modify}='NULL'
    ...               ${parameters_to_delete}='NULL'
    ...               ${mo_to_add}='NULL'
    ...               ${list_parameter_to_modify}='NULL'
    ...               ${list_to_add}='NULL'
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.GenerateCaseSCF    InputFile=${original_cfgfile}
    ...                    OutputFile=${modified_cfgfile}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=${parameters_to_modify}
    ...                    ParameterToDelete=${parameters_to_delete}
    ...                    MOsToAdd=${mo_to_add}
    ...                    ListParamterToModify=${list_parameter_to_modify}
    ...                    ListToAdd=${list_to_add}
#    gNB.ModifySCF        InputFile=${original_cfgfile}
#    ...                  OutputFile=${modified_cfgfile}
#    ...                  ParamterToModify=${parameters_to_modify}
#    ...                  ParameterToDelete=${parameters_to_delete}
#    ...                  MOsToAdd=${mo_to_add}
#    ...                  ListParamterToModify=${list_parameter_to_modify}
#    ...                  ListToAdd=${list_to_add}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}     model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.Check_Sherpa_log_ACSI
    [Arguments]   ${csv_filepath}  ${acsi_mismatch_min}=-3    ${acsi_mismatch_max}=3    ${ACSI_NOK_percent}=0.03
#    ...    ${csv_filepath}=${SHERPA_LOG_PATH}${file_name}
#    KW.Start decode files
    ${num_of_ACSI_request}    run    command=cd ${csv_filepath} ; cat Sherpa_l1l2Trace.csv | grep "bitMapACSI=1" -c
    Log to console   A-CSI request ${num_of_ACSI_request} times
    Should Be True   0<${num_of_ACSI_request}
#    ${all_numOfUciCsiPart2Bits}    run    cat Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | awk -F:'$0!="numOfUciCsiPart2Bits"' >ACSI.txt
    ${cmd1}   Set Variable    Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | grep -v "numOfUciCsiPart2Bits=0" >ACSI.txt
    ${all_numOfUciCsiPart2Bits}    run    command=cd ${csv_filepath} ; cat ${cmd1}
#    @{lines_numOfUciCsiPart2Bits}=    Split to lines    ${all_numOfUciCsiPart2Bits}
#    ${line}    Fetch From Right    string=@{lines_list}    marker=dtxCsiPart1=
#    @{value_of_numOfUciCsiPart2Bits}    Split String    string=${line}    separator=,    max_split=1
    ${num_of_ACSI_report}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "cqi" -c
    ${num_of_psDTX}    run    command=cd ${csv_filepath}; cat ACSI.txt | grep "dtx=DTX" -c
    ${num_of_part1DTX}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "dtxCsiPart1=DTX" -c
    ${num_of_part2DTX}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "dtxCsiPart2=DTX" -c
    ${num_of_part1CRCNOK}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "csiPart1CrcCheck=1" -c
    ${num_of_part2CRCNOK}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "csiPart2CrcCheck=1" -c
    ${cmd2}   Set Variable    ACSI.txt | grep "dtx=DTX\|dtxCsiPart1=DTX\|dtxCsiPart2=DTX\|csiPart1CrcCheck=1\|csiPart2CrcCheck=1" -c
    ${num_of_allDTXCRCNOK}    run    command=cd ${csv_filepath} ; cat ${cmd2}
#    Should Be True  ${acsi_mismatch_min}< ${num_of_ACSI_request}-${num_of_ACSI_report} < ${acsi_mismatch_max}
    Should Be True  ${num_of_allDTXCRCNOK}/${num_of_ACSI_report} < ${ACSI_NOK_percent}

KW.Verify_Sherpa_Logs
#    [Arguments]    ${log_cheking_kws}
    [Documentation]  verify each checkpoint for sherpa.
    FOR    ${item}    IN     @{folders_for_decoded_sherpa_logs}
        KW.Check_Sherpa_log_ACSI    csv_filepath=${item}
        KW.Check PCI in Sherpa_CSI   csv_filepath=${item}
    END

KW.Decode_and_Verify_xxxx_Logs
    no operation

KW.Verify_DCAP_Logs
    [Arguments]    ${log_cheking_kws}
    FOR    ${item}    IN     @{log_cheking_kws}
        log  ${item}
    END

KW.Check PCI in Sherpa_CSI
    [Arguments]    ${csv_filepath}=${SHERPA_LOG_PATH}${file_name}    ${csv_filename}=Sherpa_Csi.csv
#    Connect to gnb coam via ssl    connection=GNB_OAM
#    Get nr cell id mapping if not exist
#    COAM Teardown gnb connections   connection=GNB_OAM
#    ${cell_id_list}    Get Dictionary Keys    ${NR_CELL_ID_MAPPING}
    ${expected_PCIs}    KW.Get Physical Cell IDs
    run  command=sed -i 's/;/,/g' ${csv_filepath}${/}${csv_filename}
#    ${cloumn_num_to_check}    locate_column_in_csv    file_path=${csv_filepath}${/}${csv_filename}    expected=${column}
#    check_column_value    column=${cloumn_num_to_check}[0]  file_path=${csv_filepath}${/}${csv_filename}    expected=${expected_PCIs}
     ${PCI_column_name}    set variable    PCI
     ${PCI_column_values}   sherpa.get_values_of_one_column   file_path=${csv_filepath}${/}${csv_filename}  column_name=${PCI_column_name}
     ${PCI_column_unique_values}    remove duplicates    ${PCI_column_values}
#     lists should be equal    ${expected_PCIs}    ${column_unique_values}
     list should contain sub list    ${expected_PCIs}    ${PCI_column_unique_values}

     ${RNTI_column_name}    set variable   RNTI
     ${RNTI_column_values}   sherpa.get_values_of_one_column  file_path=${csv_filepath}${/}${csv_filename}  column_name=${RNTI_column_name}
     ${RNTI_column_unique_values}    remove duplicates    ${RNTI_column_values}
     ${RNTI_count}    get length    ${RNTI_column_unique_values}
     should be equal    ${RNTI_count}     ${1}


KW.Get Physical Cell IDs
    ${CellIndexs}   Create List    1    2
    ${CellPCIs}   gNB.GetPCIbyIndex    cell_index_list=${CellIndexs}
    ${phycical_cell_ids}    Create List
#    Append To List    ${phycical_cell_ids}    ${CellPCIs}
    set test variable    ${phycical_cell_ids}    ${CellPCIs}
#    [Arguments]
#    Connect to gnb coam via ssl    connection=GNB_OAM
##    Get nr cell id mapping if not exist
#    ${NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
#    COAM Teardown gnb connections   connection=GNB_OAM
##    log to console      ${NR_CELL_ID_MAPPING}
#    ${cell_info}    Get Dictionary Values    ${NR_CELL_ID_MAPPING}
#    ${phycical_cell_ids}   create list
#    FOR    ${item}    IN     @{cell_info}
#         ${keys}    Get Dictionary Keys    ${item}
#         ${values}    Get Dictionary Values    ${item}
#         ${phycical_cell_id}    convert to string   ${values}[-1]
#         Append To List    ${phycical_cell_ids}    ${phycical_cell_id}
#    END
#    set test variable    ${phycical_cell_ids}
    [Return]    ${phycical_cell_ids}

KW.Get NR Cell Indentities
    ${CellIndexs}   Create List    1    2
    ${CellIDs}   gNB.GetCellIDbyIndex    cell_index_list=${CellIndexs}
    ${pcell_to_check}    Create List   ${CellIDs}[0]
    ${scell_to_check}    Create List   ${CellIDs}[1]
    set test variable    ${pcell_to_check}
    set test variable    ${scell_to_check}
#    Connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
#    COAM Teardown gnb connections   connection=GNB_OAM
#    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
#    ${nrCellIdentity_list}    Create List
#    FOR    ${item}    IN     @{cell_id_list}
#        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
#        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
#    END
#    ${pcell_to_check}    Create List   ${nrCellIdentity_list}[0]
#    ${scell_to_check}    Create List   ${nrCellIdentity_list}[1]
#    set test variable    ${pcell_to_check}
#    set test variable    ${scell_to_check}
#    [Return]    ${nrCellIdentity_list}

#gNB.GetCellIDbyIndex

KW.Check Scell to Add
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && f1ap.procedureCode == 12
    Run Keyword And Continue On Failure    Wireshark.CheckExpression
    ...   expression=nr-rrc.sCellToAddModList == 1

KW.Check A2 Event
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && (f1ap.procedureCode == 7 || x2ap.procedureCode == 30)
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=nr-rrc.measGapConfig == 1
    Run Keyword And Continue On Failure  Wireshark.CheckExpression   expression=x2ap.X2AP_PDU == 1

KW.Check A1 Event
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && (f1ap.procedureCode == 7 || x2ap.procedureCode == 30)
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=nr-rrc.measGapConfig == 0
    Run Keyword And Continue On Failure  Wireshark.CheckExpression   expression=x2ap.X2AP_PDU

KW.Prepare and Attach UE with CPIF Log Collected
    [Arguments]  ${log_filename}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    set test variable    ${ue_type}
    run keyword and continue on failure    power_ue.Prepare UE    ue_type=${ue_type}
    conn.connect   ${ALIAS_ASIK}
    run keyword and continue on failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=${log_filename}
    ...    log_dir=/ffs/run/logs
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    run keyword and ignore error   power_ue.Verify attach    ue_type=${ue_type}    4G_check=False    5Grach_ed=${5Grach_ed}
    Sleep    10s
    run keyword and continue on failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    run keyword and continue on failure    Wireshark.DownloadLogToUTE   filename=${log_filename}    log_dir=/ffs/run/logs
    conn.disconnect   ${ALIAS_ASIK}

KW.Start DL Traffic and Check Scell Throughput
    [Arguments]   ${throughput}=300M    ${duration}=1800     ${target}=5
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${throughput}    duration=1800
    sleep    5s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...     cells=${scell_to_check}   target_throughput=${target}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl

KW.Start Bi Traffic and Check Pcell Throughtput with Sherpa Log Collected
    [Arguments]  ${ul_throughput}=10M   ${dl_throughput}=10M   ${duration}=1800    ${ul_target}=5   ${dl_target}=5
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${ul_throughput}   duration=${duration}
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${duration}
    sleep    40s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...     cells=${pcell_to_check}   target_throughput=${dl_target}
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
    ...     cells=${pcell_to_check}    target_throughput=${ul_target}
    @{traces}    create list   L2Ps_Sherpa
    run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
    sleep   10s
    run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

KW.Start Bi Traffic and Check Pcell and Scell Throughtput with Sherpa Log Collected
    [Arguments]  ${ul_throughput}=10M   ${dl_throughput}=10M    ${duration}=1800    ${pcell_ul_target}=5
    ...    ${pcell_dl_target}=5   ${scell_dl_target}=5
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${ul_throughput}   duration=${duration}
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${duration}
    sleep    120s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...     cells=${scell_to_check}   target_throughput=${scell_dl_target}
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...     cells=${pcell_to_check}   target_throughput=${pcell_dl_target}
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
    ...     cells=${pcell_to_check}    target_throughput=${pcell_ul_target}

    @{traces}    create list   L2Ps_Sherpa
    run keyword and continue on failure    DCAP.Start_Collect_Trace    traces=${traces}
    sleep   20s
    run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

KW.Start Bi Traffic
    [Arguments]  ${ul_throughput}=10M   ${dl_throughput}=10M   ${duration}=1800    ${ul_target}=5   ${dl_target}=5
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${ul_throughput}   duration=${duration}
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${duration}

KW.Check Pcell Throughtput
    [Arguments]   ${pcell_ul_target}=5    ${pcell_dl_target}=5
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...     cells=${pcell_to_check}   target_throughput=${pcell_dl_target}
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
    ...     cells=${pcell_to_check}    target_throughput=${pcell_ul_target}

KW.Stop Bi Traffic
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

KW.Start Collect CPIF
    [Arguments]   ${log_filename}
    conn.connect   ${ALIAS_ASIK}
    run keyword and continue on failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=${log_filename}
    ...    log_dir=/ffs/run/logs
    conn.disconnect   ${ALIAS_ASIK}

KW.Stop Collect CPIF and Download
    [Arguments]   ${log_filename}
    conn.connect   ${ALIAS_ASIK}
    run keyword and continue on failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    run keyword and continue on failure    Wireshark.DownloadLogToUTE   filename=${log_filename}    log_dir=/ffs/run/logs
    conn.disconnect   ${ALIAS_ASIK}

KW.Check MG enable
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && f1ap.procedureCode == 12
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression= nr-rrc.gapUE == 1


KW.Check TP enable
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && f1ap.procedureCode == 12
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression= nr-rrc.transformPrecoder == 0

KW.Check TP disable
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}
    ...        filter=nr-rrc && f1ap.procedureCode == 12 && nr-rrc.transformPrecoder == 1
    Run Keyword And Continue On Failure    Wireshark.CheckExpression
    ...        expression=nr-rrc.tp_pi2BPSK == 0

KW.CollectSherpaTrace
    [Arguments]   ${TraceTime}=10
    @{traces}    create list   L2Ps_Sherpa
    run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
    sleep   ${TraceTime}s
    run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result

KW.Check Scell Release
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && f1ap.procedureCode == 12
    Run Keyword And Continue On Failure    Wireshark.CheckExpression
    ...         expression=nr-rrc.sCellToReleaseList == 1