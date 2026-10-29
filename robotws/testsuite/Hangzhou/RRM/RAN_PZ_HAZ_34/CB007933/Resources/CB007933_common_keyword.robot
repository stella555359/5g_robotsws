*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB007933 in 5G22R2 program

Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Resource            taf/rfrl/common_resources/robot/connection_alias_store.robot
#Resource            ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
#Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***
${gnb_index}    0
${du_index}     0
${enb_cell_index}    1

${connection}    GNB_OAM

${UE_TYPE}    askey
${DL_throughput}    250M
${UL_throughput}    50M
${scf_name}    CB007933_SCF_SBTS00.xml
${scf_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T921
${host}        ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
${username}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
${password}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
${BTS_id}      ${tl.gnbs[${gnb_index}].instance_id}
${hostname}    ${tl.test_pc[0].default_ssh_connection_details.addr}
${username_ute}    ${tl.test_pc[0].default_ssh_connection_details.username}
${password_ute}    ${tl.test_pc[0].default_ssh_connection_details.password}
${TS_CASE_LOG_PATH}    /home/ute/casetest/TS_CASE_LOG_PATH/

${command_for_pdsch_specific}     -Y "dldata_pdschsendreq" -T fields -e DlData_PdschGrant.numOfPrb
${command_for_pdcch_specific}     -Y "dldata_pdcchsendreq" -T fields -e DlData_DciInfo.startCce
*** Keywords ***
L3 Call SetUp
    [Arguments]    ${UE_TYPE}=${UE_TYPE}    ${dltp}=${170}    ${ultp}=${35}    ${4G_check}=${True}
    ...    ${ue_index}=${0}
    ${cellid}=    Run Keyword If    ${4G_check}==${True}    Get Attached Cell_ID
    ...    ELSE    Get Cell_ID From GNB
   log to console    L3 call setup and check
   Log To Console    \n ### Prepare UE ###
   power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
   Log To Console    \n ### UE Attach ###
   ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
   Log To Console    \n ### verify UE Attach ###
   power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
   Log To Console    \n ###UE Start traffic and check TP ###
   power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=${UL_throughput}    duration=90    iperf_type=via_command
   ${ULtput_log}    Run keyword and continue on failure    power_ue.Collect Tput
   ...    ue_type=${UE_TYPE}    duration=60s    ignore_time=5s    filter=L2Lo
   Run keyword and ignore error    power_ue.Check Tput
   ...    ue_type=${UE_TYPE}    direction=UL    log=${ULtput_log}    cells=${cellid}
   ...    target_throughput=${ultp}    target_avg_percent=0.95    min_percent=0.75
   power_ue.Stop traffic    direction=UL    ue_index=${ue_index}    ue_type=${UE_TYPE}
   power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${DL_throughput}    duration=90   iperf_type=via_command
   ${DLtput_log}    Run keyword and continue on failure    power_ue.Collect Tput
   ...    ue_type=${UE_TYPE}    duration=60s    ignore_time=5s    filter=L2Lo
   Run keyword and ignore error    power_ue.Check Tput
   ...    ue_type=${UE_TYPE}    direction=DL    log=${DLtput_log}    cells=${cellid}
   ...    target_throughput=${dltp}    target_avg_percent=0.95    min_percent=0.75
   power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
   Log To Console    \n ### UE Detach ###
   power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Start Capture BIP Log
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts
    [Teardown]   run keyword and ignore error    Csn.Disconnect    connection=ASIK Master

stop to capture BIP log And Download
	Connect to Common Unit Master
	csn.send command    command=killall tcpdump     connection=ASIK Master
	${list_log_path_local}    Download BIP Log
    [Teardown]   run keyword and ignore error    Csn.Disconnect    connection=ASIK Master

Download BIP Log
    [Arguments]       ${log_path}=${CURDIR}   ${download_type}=Download
    Log To Console    \n ###download bip log to testPC ###
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    download_type=${download_type}
    Set Suite Variable      ${list_log_path_local}
    [Return]    ${list_log_path_local}

Check PDSCH NumOfPRB
    csn.Connect To     hostname=${hostname}    username=${username_ute}    password=${password_ute}    alias=ute
    ${pdml_file}=    Set Variable    PDSCH_NumOfPRB.pdml
    csn.execute    command=/usr/bin/tshark -r ${list_log_path_local[0]} ${command_for_pdsch_specific} > ${TS_CASE_LOG_PATH}${pdml_file}
    ...    connection=ute
    ${output_value}    csn.execute    command=cat ${TS_CASE_LOG_PATH}${pdml_file} |awk '/./ {print}'    connection=ute
    ${output_value}    Split To Lines    ${output_value}
    csn.Disconnect   connection=ute
    FOR    ${item}    IN    @{output_value}
        Should Be True    ${item} <= 98
    END
    [Teardown]    Run Keyword And Ignore Error    csn.Disconnect   connection=ute

Check PDCCH StartCCE
    csn.Connect To     hostname=${hostname}    username=${username_ute}    password=${password_ute}    alias=ute
    ${pdml_file}=    Set Variable    PDCCH_StartCCE.pdml
    csn.execute    command=/usr/bin/tshark -r ${list_log_path_local[0]} ${command_for_pdcch_specific} > ${TS_CASE_LOG_PATH}${pdml_file}
    ...    connection=ute
    ${output_value}    csn.execute    command=cat ${TS_CASE_LOG_PATH}${pdml_file} |awk '/./ {print}'    connection=ute
    ${output_value}    Split To Lines    ${output_value}
    csn.Disconnect   connection=ute
    @{StartCCE_list}    create list    0    4    8
    FOR    ${item}    IN    @{output_value}
        Should Contain    ${StartCCE_list}    ${item}
    END
    [Teardown]    Run Keyword And Ignore Error    csn.Disconnect   connection=ute

Get Attached Cell_ID
    Connect to eNB via ssl    connection=enb
    @{MOs}    admin_cli.get_managed_objects    class_name=LNBTS_A    connection=enb
    ${dist_path_A}    set variable    ${MOs[0]['distName']}
    ${defaultLnRelGnbCellId}=    admin_cli.get_parameters    dist_name=${dist_path_A}/LNCEL_A-${enb_cell_index}
    ...    pattern=defaultLnRelGnbCellId    connection=enb
    ${defaultLnRelGnbCellId_value}=    Get From Dictionary    ${defaultLnRelGnbCellId}    defaultLnRelGnbCellId
    ${nrCellid}=    admin_cli.get_parameters    dist_name=${dist_path_A}/LNCEL_A-1/LNRELGNBCELL_A-${defaultLnRelGnbCellId_value}
    ...    connection=enb
    ${nrCellid}    Set Variable    ${nrCellid['nrCellId']}
    Enblte close down    connection=enb
     ${nrCellid}=    Create List    ${nrCellid}
    [Return]    ${nrCellid}
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=enb

Get Cell_ID From GNB
    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_R    connection=${connection}
    ${dist_path}    set variable    ${MOs[0]['distName']}
    &{nrCellIdentity}=    admin_cli.get_parameters    dist_name=${dist_path}/NRCELL_R-${cell1_index}    pattern=nrCellIdentity
    ...    connection=${connection}
    ${nrCellIdentity_value}    set variable     ${nrCellIdentity['nrCellIdentity']}
    ${nrCellIdentity_value}=    Create List    ${nrCellIdentity_value}
    [Return]    ${nrCellIdentity_value}


Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}/NRCELL_FDD-1
    ${output}    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=${connection}
    sleep    3s

Change Cell GSCN Value
    [Arguments]    ${gscn}=5435
    ${dict0}=    create dictionary    parameterName=gscnOrSsPbchArfcn
    ...                               operation=update
    ...                               value=5435
    ${dict1}=    create dictionary    parameterName=gscnOrSsPbchArfcn
    ...                               operation=update
    ...                               value=5462
    ${dict2}=    create dictionary    parameterName=gscnOrSsPbchArfcn
    ...                               operation=update
    ...                               value=5438
    ${dict3}=    create dictionary    parameterName=type0CoresetConfigurationIndex
    ...                               operation=update
    ...                               value=6
    ${dict4}=    create dictionary    parameterName=type0CoresetConfigurationIndex
    ...                               operation=update
    ...                               value=7
    @{para_5435}=    create list    ${dict0}    ${dict3}
    @{para_5462}=    create list    ${dict1}    ${dict4}
    @{para_5438}=    create list    ${dict2}    ${dict4}

    Run Keyword If    ${gscn}==5435    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}
    ...    parameter=@{para_5435}    operation=update    skip_parameter_relation_errors=true    connection=${connection}
    ...    ELSE IF    ${gscn}==5462    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}
    ...    parameter=@{para_5462}    operation=update    skip_parameter_relation_errors=true    connection=${connection}
    ...    ELSE IF    ${gscn}==5438    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}
    ...    parameter=@{para_5438}    operation=update    skip_parameter_relation_errors=true    connection=${connection}

Confirm The rbAllocation
    [Arguments]    ${csirsTrackingPeriod}=80ms    ${firstRE}=0    ${rbAllocation}=BWP    ${startRB}=0
    ${csirsForTracking_dict}    Create Dictionary    csirsTrackingPeriod=${csirsTrackingPeriod}    firstRE=${firstRE}
    ...    rbAllocation=${rbAllocation}    startRB=${startRB}
    @{csirsForTracking_list}    create list    ${csirsForTracking_dict}
    run keyword if    '${cell1_info['csirsForTracking']['rbAllocation']}' != '${csirsTrackingPeriod}'    Set parameter    key=csirsForTracking
    ...    value=${csirsForTracking_list}    dict_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}
Confirm The nrCellType
    run keyword if    '${cell1_info['nrCellType']}' != '4DL4UL'    Set parameter    key=nrCellType
    ...    value=4DL4UL    dict_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}

Confirm The actPdschRmCsirsForTracking
    run keyword if    '${cell1_info['actPdschRmCsirsForTracking']}' != 'true'    Set parameter    key=actPdschRmCsirsForTracking
    ...    value=true    dict_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}
Confirm The pucchModeSelect
    run keyword if    '${cell1_info['pucchModeSelect']}' != 'longPucch'    Set parameter    key=pucchModeSelect
    ...    value=longPucch    dict_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}
Confirm The actPdschAtSsbSlots
    run keyword if    '${cell1_info['actPdschAtSsbSlots']}' != 'true'    Set parameter    key=actPdschAtSsbSlots
    ...    value=true    dict_name=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}


Check The PDL Rules Is Not Available For The Combinations
    [Arguments]    ${dist_name}=MRBTS-${BTS_id}/NRBTS-${BTS_id}/NRCELL-${cell1_index}/NRCELL_FDD-1
    ...    ${parameter}=chBwUl    ${value}=15MHz
    ${status}=    run keyword and ignore error    admin_cli.perform_parameter_recommissioning
    ...    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${value}    connection=${connection}    skip_parameter_relation_errors=False
    ${findstring}    Fetch From Right    ${status[1]}     pdlValidationResult
    ${findstring}=    convert to string    ${findstring}
    Should match regexp     ${findstring}     status\\D*FAIL

Precondition
    [Arguments]    ${gscnOrSsPbchArfcn}=5435    ${chbwul}=10MHz    ${chbwdl}=20MHz    ${nrarfcn_dl}=436000    ${nrarfcn_ul}=355000
    ...    ${guardband}=false
    Adapt SCF Name By Release and Commition SCF
    Adapt Configurations

Adapt SCF Name By Release and Commition SCF
    wait until keyword succeeds    60s    2s    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    Set Suite Variable    ${sw_version}
    ${stream}    get stream from version    ${SW_version}
    Set Suite Variable    ${stream}
    ${scf_name}    Run keyword if   '${stream}'=='SBTS23R3'     set variable   CB007933_SCF_SBTS23R3.xml
    ...   ELSE IF    '${stream}'=='SBTS25R1'     set variable   CB007933_SCF_SBTS25R1.xml
    ...   ELSE IF    '${stream}'=='SBTS24R3'     set variable   CB007933_SCF_SBTS24R3.xml
    ...   ELSE        set variable   CB007933_SCF_SBTS00.xml
    Set Suite Variable    ${scf_name}
    COAM Commission with scf file    scf_file_path=${scf_path}/${scf_name}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    [Teardown]    coam.teardown    connection=GNB_OAM
Adapt Configurations
    [Arguments]    ${gscnOrSsPbchArfcn}=5435    ${chbwul}=10MHz    ${chbwdl}=20MHz    ${nrarfcn_dl}=436000    ${nrarfcn_ul}=355000
    ...    ${guardband}=false
	robot_common_operations.Common Case Setup
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${dist_path}    set variable    ${MOs[0]['distName']}
    &{cell1_info}=    admin_cli.get_parameters    dist_name=${dist_path}/NRCELL_A-${cell1_index}    connection=${connection}
    Set Suite Variable    &{cell1_info}
    run keyword if    ${cell1_info['gscnOrSsPbchArfcn']} != ${gscnOrSsPbchArfcn}
    ...    Change Cell GSCN Value    gscn=${gscnOrSsPbchArfcn}

    @{MOs}    admin_cli.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${dist_path}    set variable    ${MOs[0]['distName']}
    &{cell1_FDD_info}=    admin_cli.get_parameters    dist_name=${dist_path}/NRCELL_A-${cell1_index}/NRCELL_FDD_A-1    connection=${connection}
    Set Suite Variable    &{cell1_FDD_info}
    run keyword if    '${cell1_FDD_info['chBwUl']}' != '${chbwul}'    Set parameter    key=chBwUl    value=${chbwul}
    run keyword if    '${cell1_FDD_info['chBwDl']}' != '${chbwdl}'    Set parameter    key=chBwDl    value=${chbwul}
    run keyword if    ${cell1_FDD_info['nrarfcnDl']} != ${nrarfcn_dl}    Set parameter    key=nrarfcnDl    value=${nrarfcn_dl}
    run keyword if    ${cell1_FDD_info['nrarfcnUl']} != ${nrarfcn_ul}    Set parameter    key=nrarfcnUl    value=${nrarfcn_ul}
    run keyword if    '${cell1_FDD_info['actAsymBwGuardband']}' != '${guardband}'    Set parameter    key=actAsymBwGuardband    value=${guardband}



Teardown
	robot_common_operations.Common Case Teardown
    admin_cli.teardown    connection=${connection}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    #run keyword and ignore error    Stop Device traffic    UE_TYPE=${UE_TYPE}    direction=ul
    run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

