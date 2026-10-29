*** Settings ***
Documentation
...  INTRODUCTION    :  CB014134 Feature which interacts LTE 928 and LTE 3544

Library     OperatingSystem
Library     taf.ul.ue.sim.env_setup
Library    XML
Library    ta_uexgate    compress_logs=True
#Library        ta5g_commissioning
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Library     ta_messaging
Library		taf.sw.syslog
Library     taf.sw.wtssim
Library		taf.sbts.oam.coam.admin        WITH NAME       SBTS_COAM
#Library     ute_admin_infomodel
Library      ./python/reader.py
Library          ./python/parametrs.py

Resource   ../../../resources/robot/PM_Counters.robot
Variables      ./python/swconfig_flags.py
Resource   ../CB012719/CB012719_Resource.robot

*** Variables ***
${gNB_IP} 		  192.168.255.129
${connection}		oam
${egate_port}=          20000
${edaemon_port}=        10000

${cus_ini}     ${CURDIR}/config/cus/cus.ini
${lua}         ${CURDIR}/config/cus/epc.lua
${ue_db}       ${CURDIR}/config/cus/ue.db
@{SWCONFIG_FLAGS}=    ${MAC_PS_TRACE_DEBUG}  0x1002B=0x37B0  0x1002C=0x382F  0x1002F=1  0x10030=0   0x1005A=1   0x100CA=16   0x100CE=0   0x1002A = 2
${yaml}=                              ${CURDIR}/config/cus/coco.yaml

${riDetectState}          riDetectState
${riDetectEnbInfoList}    riDetectEnbInfoList
${riDlMitigationState}    riDlMitigationState

*** Keywords ***
VerIfy LTE RIM Counters with 928
    ${counter_moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-1/PLMN-PLMN/MCC-311/MNC-09
    ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
    ${ENB_DUR_UL_IMPACT_RI}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C432
    ...    moc=${counter_moc}
    ${ENB_DUR_RI_DHT}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C433
    ...    moc=${counter_moc}
    ${ENB_DUR_SSP_ROL_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C448
    ...    moc=${counter_moc}
    ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C449
    ...    moc=${counter_moc}
    ${ENB_DUR_UL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C450
    ...     moc=${counter_moc}
    ${ENB_NUM_DET_RI_ENB_ID}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C447
    ...    moc=${counter_moc}
    Should Contain       ${ENB_DUR_UL_IMPACT_RI}      900
    Should Contain       ${ENB_DUR_RI_DHT}      0
    Should Contain       ${ENB_DUR_SSP_ROL_DL_MTG}       0
    Should Contain       ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}      0
    Should Contain       ${ENB_DUR_UL_MTG}      900
    Should Contain       ${ENB_NUM_DET_RI_ENB_ID}      0


VerIfy LTE RIM Counters with ssp roll
    ${counter_moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-1/PLMN-PLMN/MCC-311/MNC-09
    ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
    ${ENB_DUR_UL_IMPACT_RI}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C432    moc=${counter_moc}
    ${ENB_DUR_RI_DHT}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C433    moc=${counter_moc}
    ${ENB_DUR_SSP_ROL_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C448    moc=${counter_moc}
    ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C449   moc=${counter_moc}
    ${ENB_DUR_UL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C450    moc=${counter_moc}
    ${ENB_NUM_DET_RI_ENB_ID}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C447    moc=${counter_moc}
    Should Contain       ${ENB_DUR_UL_IMPACT_RI}      900
    Should Contain       ${ENB_DUR_RI_DHT}      0
    Should Contain       ${ENB_DUR_SSP_ROL_DL_MTG}       900
    Should Contain       ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}      0
    Should Contain       ${ENB_DUR_UL_MTG}      0
    Run Keyword and Ignore Error    Should Contain       ${ENB_NUM_DET_RI_ENB_ID}      2

Configure Env for CB014134
   	Add Simulator       sim_type=cus    config=${cus_ini},${ue_db}
    Add Enb Configuration               rad_params=@{SWCONFIG_FLAGS}
    Add Epc                         config=${lua}
    configure_environment
    Setup egate  egate_port=${EGATE_PORT}

Attach UE and Start Data Traffic

      [Arguments]    ${start_ue}     ${end_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${end_ue}
        Run UEx Command  ue_attach    id=${ue_id}  cell=1
        Run UEx Command  trf_data_start  ue=${ue_id}  dir=dl  Mbps=${50}  protocol=udp  size=1400    stats=true
        Run UEx Command  trf_data_start  ue=${ue_id}  dir=ul  Mbps=${10}  protocol=udp  size=1400    stats=true

    END
    Sleep    5s

Detach All UEs
    Run UEx Command  ue_detach  all

Add ul noise
    [Arguments]     ${cell}
    Run UEx command   uec_cell_param  id=${cell}     ul_noise=-40
    log to console   ul noise added...

Remove ul noise
    [Arguments]     ${cell}
    Run UEx command   uec_cell_param  id=${cell}     ul_noise=-140
    log to console   ul noise removed...


Generate RI sequences
    [Arguments]     ${cell}

    log to console   Generate RI sequences commands
    Run UEx command    uec_cell_param       id=${cell}     ul_noise=-40

    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=15
    ...     frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=1         sequence_num=1          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=15
    ...    frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=1         sequence_num=2           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=15
    ...     frame_num=47        subframe_num=1      symbol_num=8
    ...     ri_id=2         sequence_num=3          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=15
    ...    frame_num=47        subframe_num=6      symbol_num=8
    ...     ri_id=2         sequence_num=4           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=15
    ...    frame_num=47        subframe_num=1      symbol_num=9
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=15
    ...     frame_num=47        subframe_num=6      symbol_num=9
    ...     ri_id=3         sequence_num=6           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=15
    ...    frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=15
    ...    frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=3         sequence_num=6           power_dBFS=-2


    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=50
    ...     frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=1         sequence_num=1          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=50
    ...    frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=1         sequence_num=2           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=50
    ...     frame_num=47        subframe_num=1      symbol_num=8
    ...     ri_id=2         sequence_num=3          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=50
    ...    frame_num=47        subframe_num=6      symbol_num=8
    ...     ri_id=2         sequence_num=4           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=50
    ...    frame_num=47        subframe_num=1      symbol_num=9
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=50
    ...     frame_num=47        subframe_num=6      symbol_num=9
    ...     ri_id=3         sequence_num=6           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=50
    ...    frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=50
    ...    frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=3         sequence_num=6           power_dBFS=-2

    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=501
    ...    frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=1         sequence_num=1          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=501
    ...    frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=1         sequence_num=2           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=501
    ...    frame_num=47        subframe_num=1      symbol_num=8
    ...     ri_id=2         sequence_num=3          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=501
    ...     frame_num=47        subframe_num=6      symbol_num=8
    ...     ri_id=2         sequence_num=4           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=501
    ...    frame_num=47        subframe_num=1      symbol_num=9
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=501
    ...    frame_num=47        subframe_num=6      symbol_num=9
    ...     ri_id=3         sequence_num=6           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=501
    ...    frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=501
    ...     frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=3         sequence_num=6           power_dBFS=-2


    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=1022
    ...     frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=1         sequence_num=1          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=1022
    ...    frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=1         sequence_num=2           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=1022
    ...    frame_num=47        subframe_num=1      symbol_num=8
    ...     ri_id=2         sequence_num=3          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=1022
    ...    frame_num=47        subframe_num=6      symbol_num=8
    ...     ri_id=2         sequence_num=4           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=1022
    ...    frame_num=47        subframe_num=1      symbol_num=9
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=1022
    ...     frame_num=47        subframe_num=6      symbol_num=9
    ...     ri_id=3         sequence_num=6           power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command    cell_ri_param         id=${cell}       hyperframe_num=1022
    ...    frame_num=47        subframe_num=1      symbol_num=12
    ...     ri_id=3         sequence_num=5          power_dBFS=-2
    Run keyword and Ignore Error        Run UEx command     cell_ri_param        id=${cell}       hyperframe_num=1022
    ...     frame_num=47        subframe_num=6      symbol_num=12
    ...     ri_id=3         sequence_num=6           power_dBFS=-2

Enable Macpscli To UTE
    log to console   set R&D parametere
    ${otput}     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 -C "ls /ffs/run/TargetBD_*.xml | sed 's/^.*TargetBD_//;s/\.xml$//'"
    ${version}    Split String    ${otput}     \n
    ${sw_version}    Replace String Using Regexp    ${version[1]}     SBTS.*R.*_E     SBTS00_E
    ${dir_path}    Set Variable     ${OUTPUT_DIR}
    ${cmd1}    Set Variable    cd ${OUTPUT_DIR} && wget https://artifactory-espoo2.int.net.nokia.com/
    ${cmd2}    Set Variable    artifactory/mn-cosi-sran-central-public-local/build/SBTS00/${sw_version}/${sw_version}_pstools.zip
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd1}${cmd2}
    Run   cd ${dir_path} && unzip ${sw_version}_pstools.zip
    Run And Return Rc And Output    cd ${OUTPUT_DIR}/pscli && wget http://s3-china-1.eecloud.nsn-net.net/PSCLI/mac_pscli/macpscli
    Run  cd ${dir_path}/pscli && chmod 777 *
    ${x}    Set Variable   -i 192.168.255.1 -u toor4nsn -w oZPS0POrRieRtu
    Run  cd ${dir_path}/pscli && ./macpscli setlog -f FID_UL_INTERFERENCE -l DEBUG -n ALL -c ALL ${x}
    Run  cd ${dir_path}/pscli && ./macpscli setlog -f FID_CELL_TRACE -l DEBUG -n ALL -c ALL ${x}
    Run  cd ${dir_path}/pscli && ./macpscli setrd -r ERadSwDomainLteMac_TRdRIThresSfDiff -v 4294967103 -n ALL -c ALL ${x}
    Run  cd /${dir_path}/pscli && ./macpscli setrd -r ERadSwDomainLteMac_TRdRIMeasPeriod -v 100 -n ALL -c ALL ${x}

Enable Macpscli To UTE Customize
    log to console   set R&D parametere
    ${otput}     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 -C "ls /ffs/run/TargetBD_*.xml | sed 's/^.*TargetBD_//;s/\.xml$//'"
    ${version}    Split String    ${otput}     \n
    ${release}       parametrs.get_sw_release
    ${swv}           parametrs.get_sw_version
    ${sw_version_cus}    Replace String Using Regexp    ${version[1]}     SBTS.*R.*_E     SBTS00_E

    ${sw_version}      set variable if    '${release}' == 'SBTS26R3'       ${sw_version_cus}      ${swv}
    ${release}         set variable if    '${release}' == 'SBTS26R3'       SBTS00      ${release}
    ${dir_path}    Set Variable     ${OUTPUT_DIR}

    ${cmd1}    Set Variable    cd ${OUTPUT_DIR} && wget https://artifactory-espoo2.int.net.nokia.com/
    ${cmd2}    Set Variable    artifactory/mn-cosi-sran-central-public-local/build/${release}/${sw_version}/${sw_version}_pstools.zip
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd1}${cmd2}
    Run   cd ${dir_path} && unzip ${sw_version}_pstools.zip
    Run And Return Rc And Output    cd ${OUTPUT_DIR}/pscli && wget http://s3-china-1.eecloud.nsn-net.net/PSCLI/mac_pscli/macpscli
    Run  cd ${dir_path}/pscli && chmod 777 *
    ${x}    Set Variable   -i 192.168.255.1 -u toor4nsn -w oZPS0POrRieRtu
    Run  cd ${dir_path}/pscli && ./macpscli setlog -f FID_UL_INTERFERENCE -l DEBUG -n ALL -c ALL ${x}
    Run  cd ${dir_path}/pscli && ./macpscli setlog -f FID_CELL_TRACE -l DEBUG -n ALL -c ALL ${x}
    Run  cd ${dir_path}/pscli && ./macpscli setrd -r ERadSwDomainLteMac_TRdRIThresSfDiff -v 4294967103 -n ALL -c ALL ${x}
    Run  cd /${dir_path}/pscli && ./macpscli setrd -r ERadSwDomainLteMac_TRdRIMeasPeriod -v 100 -n ALL -c ALL ${x}

Enable Macpscli To UTE branch
    log to console   set R&D parametere
    ${otput}     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 -C "ls /ffs/run/TargetBD_*.xml | sed 's/^.*TargetBD_//;s/\.xml$//'"
    ${version}    Split String    ${otput}     \n
    ${sw_version}    Set Variable    ${version[1]}     #SBTS.*R.*_E     SBTS00_E
    ${dir_path}    Set Variable     ${OUTPUT_DIR}
    ${cmd1}    Set Variable    cd ${OUTPUT_DIR} && wget https://artifactory-espoo2.int.net.nokia.com/
    ${cmd2}    Set Variable    artifactory/mn-cosi-sran-central-public-local/build/SBTS26R1/${sw_version}/${sw_version}_pstools.zip
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd1}${cmd2}
    Run   cd ${dir_path} && unzip ${sw_version}_pstools.zip
    Run And Return Rc And Output    cd ${OUTPUT_DIR}/pscli && wget http://s3-china-1.eecloud.nsn-net.net/PSCLI/mac_pscli/macpscli
    Run  cd ${dir_path}/pscli && chmod 777 *
    ${x}    Set Variable   -i 192.168.255.1 -u toor4nsn -w oZPS0POrRieRtu
    Run  cd ${dir_path}/pscli && ./macpscli setlog -f FID_UL_INTERFERENCE -l DEBUG -n ALL -c ALL ${x}
    Run  cd ${dir_path}/pscli && ./macpscli setlog -f FID_CELL_TRACE -l DEBUG -n ALL -c ALL ${x}
    Run  cd ${dir_path}/pscli && ./macpscli setrd -r ERadSwDomainLteMac_TRdRIThresSfDiff -v 4294967103 -n ALL -c ALL ${x}
    Run  cd /${dir_path}/pscli && ./macpscli setrd -r ERadSwDomainLteMac_TRdRIMeasPeriod -v 100 -n ALL -c ALL ${x}

Make connection
     SBTS_COAM.setup_admin    bts_host=${gNB_IP}     alias=${connection}    admin_api_log_dir=/tmp

Verify CM state
    [Arguments]     ${cell}
    SBTS_COAM.setup_admin    bts_host=${gNB_IP}     alias=${connection}    admin_api_log_dir=/tmp
    ${params}    Create List     riDetectState     riDlMitigationState    riDetectEnbInfoList
    ${scf_file}   SBTS_COAM.get_parameter_by_distname       MRBTS-1/LNBTS-1/LNCEL-${cell}/LNCEL_TDD-0/RIMINFO-0   ${params}
    ...           connection=${connection}    timeout=30
    log to console    ${scf_file}
    [Return]     ${scf_file}



Verify CM state customize
    [Arguments]       ${moc}    ${state}
#    SBTS_COAM.setup_admin    bts_host=${gNB_IP}     alias=${connection}    admin_api_log_dir=/tmp
#    ${params}    Create List     riDetectState     riDlMitigationState    riDetectEnbInfoList
    ${params}    Create List     riDetectState     riDlMitigationState    riDetectEnbInfoList
    ${scf_file}   SBTS_COAM.get_parameter_by_distname       ${moc}    ${params}
    ...           connection=${connection}    timeout=30
    ${ret}      reader     ${scf_file}     ${moc}    ${state}
    log to console    ${scf_file}
    [Return]     ${ret}


Collect PM Counter LTE
    [Arguments]    ${collector_alias}=enb_pm_counters    ${target_dir}=None  ${component}=DU
    ${webservice}=       Create Dictionary
    ...    host=192.168.255.129
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    log to console    ${component}
    ${oam_type}=    Set Variable     coam
    ${target_dir}=    Set Variable    /home/ute/robotws/Logs/${target_dir}
    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}
    collect_pm.Setup Collectors       names=${collector_alias}
    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_pm.Teardown Collectors    names=${collector_alias}
    [Return]    ${target_dir}/${collector_alias}

#VerIfy LTE RIM Counters
#    ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
#    ${ENB_DUR_UL_IMPACT_RI}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C432    moc=MRBTS-1/LNBTS-1/LNCEL-6
#    ${ENB_DUR_RI_DHT}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C433    moc=MRBTS-1/LNBTS-1/LNCEL-6
#    ${ENB_DUR_SSP_ROL_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C448    moc=MRBTS-1/LNBTS-1/LNCEL-6
#    ${ENB_DUR_SSP_PDSCH_MUT_DL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C449   moc=MRBTS-1/LNBTS-1/LNCEL-6
#    ${ENB_DUR_UL_MTG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C450    moc=MRBTS-1/LNBTS-1/LNCEL-6
#    ${ENB_NUM_DET_RI_ENB_ID}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8005C447    moc=MRBTS-1/LNBTS-1/LNCEL-6
