*** Settings ***
Library           os.path
Library           taf.sbts.oam.coam.admin   WITH NAME   admin
Library           ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/lib/start_dcap_utf_controller.py
Library           taf.sw.dcap.rd       WITH NAME    rd
Library           taf.collectors.dcap    WITH NAME    dcap
Library           Collections
Library           json

#Resource          ../../../Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_setup_teardown.robot
#old usage: Resource          ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_setup_teardown.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/hangzhou/common_setup_teardown.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_log_capture_bj.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_log_analysis_bj.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_ue_command_bj.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/common/resources/pcap_to_txt.robot
Resource          ${EXECDIR}/testsuite/Beijing/ET/common/resources/emil_to_txt.robot

*** Variables ***
${oran_user}    xranuser
${oran_pwd}    xran-password

*** Keywords ***
_keywords_all
    Suite Setup Update GNB bj
    Common Test Setup bj
    Common Test Log Capture
    Common Test Teardown bj
    Common Suite Teardown bj



Common Test Log Capture
    Log To Console     stop logs and save egate console log...
    Run Keyword And Ignore Error    common_log_capture.Stop Logs    ${LOG_NAME_LIST}
    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}


Suite Setup For Common Setting bj
    [Arguments]    ${iphy_file}=${EMPTY}
    #Run Keyword And Ignore Error    Run Cmd On PC    pip install ta_a2a -U
    Import Testline Variables
    #Run Keyword If    "${BASELINE}"!=""    Install Ttitrace And Mcshark    ${BASELINE}
    Check GNB EIF Ping OK
    Check AP EIF Ping OK
    Sync Timezone For GNB AP And WTS
    Print Current Time    Start Robot File Time
    Clean Up Env
    Create Suite Directory
    Run Keyword And Ignore Error    Get Qc File
    Backup Scf    ${OUTPUT_DIR}    before_suite
    Get All Testline Information And Set Suite Variable
    Modify UTE Memory Size
    Run Keyword If    '${iphy_file}'!='${empty}'    Get RRU Type From Local IPHY XML    ${iphy_file}
    Print Testline Info Ahead Of Report
    Setup Connections
    Set CP Debug Log

Suite Setup Update GNB bj
    [Arguments]    ${swconfig_param}=${empty}    ${scf_file}=${empty}    ${iphy_file}=${empty}
    ...    ${swconfig_param_AP}=${empty}    ${log}=${True}
    ...    ${force_reboot}=${False}    ${skip_reboot}=${False}    ${vendor_change_list}=${empty}
    [Documentation]    This keyword is to update the configuration of GNB and WTS both, and wait for configured.
    ...                It also capture the logs for cell setup.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_param} | No | set RD parameter in swconfig file, e.g.0x580017=3;0x580019=1; |
    ...    | ${scf_file} | No | use scf.xml/delta.json to update gNB parameters |
    ...    |  |  | If ${scf_file} is endwith .xml, Full Commission With SCF File will be triggered. |
    ...    |  |  | If ${scf_file} is endwith .jsom, Delta Commission With SCF File will be triggered. |
    ...    |  |  | It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${scf_path} set in suite file, ${SW_BRANCH} is a suite variable, can be used directly. |
    ...    | ${iphy_file} | No | update iphy.xml. not support yet |
    ...
    ...    This keyword will reboot testline if need to update configuration.
    ...    The max times to reboot testline is set by ${MAX_REBOOT_TIME} to make sure the TL will onair.
    ...
    ...    Example1: no need to update anything
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example2: no need to update WTS configuration
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=scf.xml |
    ...    | ... | AND | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example3: need update cfg file of WTS,${WTS_DIR}/${WTS_CFG} is a suite variable
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example3,5 |
    ...    | @{CFG_OLD_PARAMS} | plmn=[0-9]+:[0-9]+ |
    ...    | @{CFG_NEW_PARAMS} | plmn=302:610 |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json |
    ...    | ... | AND | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example4: need update xml file of WTS,${WTS_DIR}/${WTS_AP_XML} is a suite variable
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example 4,5 |
    ...    | &{xml_params_dict} | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=scf.xml |
    ...    | ... | AND | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example5: need update config file of gNB and WTS
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json |
    ...    | ... | AND | swconfig_param=0x580017=3;0x580019=1; | |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |  |  |  |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example6: need update config file of gNB and WTS from local
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example3,5 |
    ...    | ${LOCAL_WTS_DIR} | ${CURDIR}/config |
    ...    | ${WTS_CFG} | xxx.cfg |
    ...    | ${WTS_AP_XML} | xxx.xml |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json |
    ...    | ... | AND | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From Local | ${LOCAL_WTS_DIR} |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example7: for vendor file
    ...    | &{xml_params_dict1} | Create Dictionary | maxNumLayerPrbDlL1Sp=200 | maxNumLayerPrbUlL1Sp=100 |
    ...    | ...| maxNumStreamPrbDlL1Sp=300 | maxNumStreamPrbUlL1Sp=200 |
    ...    | &{vendor_change_dict1} | Create Dictionary | list_name=bbL1SpPrbCapacity |
    ...    | ... |    | ref_value=ABIO\\d+FDD48 | params_dict=${xml_params_dict1} |
    ...    | &{xml_params_dict2} | Create Dictionary | guaranteedResourceRatioPerCell=10 |
    ...    | &{vendor_change_dict2} | Create Dictionary | list_name=${EMPTY} |
    ...    |  ref_value=${EMPTY}  |  params_dict=${xml_params_dict2} | ${vendor_change_dict2} |
    ...    | @{vendor_change_list} | Create List | ${vendor_change_dict1} | ${vendor_change_dict2} |
    ...    | Suite Setup Update GNB | vendor_change_list=${VENDOR_CHANGE_LIST} |
    Suite Setup For Common Setting bj
#    Get Default NRBTS DistName
    Run Keyword If    "${log}"=="${True}"    common_log_capture.Start Logs    ${LOG_NAME_SUITE_SETUP}
    ...    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable for Suite Backup Files
    Backup And Update Iphy Swconfig File bj    ${iphy_file}    ${swconfig_param}    ${swconfig_param_AP}
    Backup And Update Vendor SCF File    ${scf_file}    ${vendor_change_list}
    Run Keyword And Return If    '${skip_reboot}'=='${True}'    Log    testline is forced to skip reboot ...    WARN
    ${file_empty_state}=    Catenate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}'
    ...    or '${swconfig_param_AP}'!='${empty}'
     ...    or '${iphy_file}'!='${empty}'
    ${file_state}=    Evaluate    ${file_empty_state}
    ${scf_iphy_empty_state}=    Evaluate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}'
    Run Keyword If    '${file_state}'=='${True}' or '${force_reboot}'=='${True}'
    ...    Reboot TL And Check Configured
    Run Keyword If    '${scf_iphy_empty_state}'=='${True}'    Get All Testline Information And Set Suite Variable

Common Test Setup bj
    [Arguments]    ${delta_jason}=${none}    ${log}=yes
    [Documentation]    This keyword is to update parameters for this case.
    ...
    ...          1. Create test directory to store the logs for case
    ...
    ...          2. backup scf before update and after update parameters with jason file
    ...
    ...          3. start logs
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_jason} | No | jason file,It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    | *** Variables *** |
    ...    | ${SCF_PATH} | ${CURDIR}/config |
    ...
    ...    Examples1: no parameter need to update
    ...    | Common Test Setup |
    ...
    ...    Examples2: update parameter with jason file
    ...    | Common Test Setup | Delta_Conf_5GC002504_ET_01.json |
    Create Test Directory
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_LIST}


Common Test Teardown bj
    [Arguments]    ${mode}=${EMPTY}    ${log}=yes
    [Documentation]    This keyword is to detach UE, and stop logs for case
#    stop by lixiang
#    Run Keyword And Ignore Error    common_log_capture.Stop Logs    ${LOG_NAME_LIST}
#    Run Keyword And Ignore Error    NSA LTE Detach    ${ue_id}
#    Run Keyword And Ignore Error    SA 5G Detach    ${ue_id}
#    Run Keyword If    '${mode}'!='debug'    Run Keyword If Test Failed    Collect UTE SosReport
#    ...    ${TEST_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/tmp/APL3.log ${TEST_LOG_DIRECTORY}
#    Run
#    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ram/node_CPRT00/tmp/startup_cp_rt.log* ${TEST_LOG_DIRECTORY}

    ${cmd_1}  Set Variable  sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ram/node_CPRT00/tmp/startup_cp_rt.log*
    ${cmd_2}  Set Variable  ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    ${cmd_1} ${cmd_2}
#    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt
#    ...    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt

Common Suite Teardown bj
    [Arguments]    ${mode}=${EMPTY}    ${collect_config_file}=${FALSE}
    [Documentation]    This keyword is to collect the logs.
    Run Keyword And Ignore Error    Get Alarms
    Run keyword If    '${FLAG_CATCH_SUITE_LOG}'=='${True}'    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}
    ...    ${SUITE_LOG_DIRECTORY}
#    stop by lixiang
#    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Run Keyword If    '${collect_config_file}'=='${TRUE}' and '${SUITE STATUS}'=='PASS'
    ...    Get Config Files And Put To Local Log Server
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop Logs    ${LOG_NAME_SUITE_TEARDOWN}
    ...    ${SUITE_LOG_DIRECTORY}
#    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed
#    ...    Collect UTE SosReport    ${SUITE_LOG_DIRECTORY}
    common_log_capture.Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts
#    Filter ERR WRN Message From Syslog By Log Path    ${SUITE_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt
#    ...    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt

Reboot TL And Check Configured bj
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
    Run Keyword And Ignore error    Remove hwf File To Save Reboot Time
    Set Suite Variable    ${reboot_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}+1
        Log To Console    ===============Reboot Time: ${index}==============
        Run Keyword If    "${index}"=="2"    Reboot Testline Via SSH
        ...    ELSE    Hard Reboot Testline bj
        # Reboot Testline Via SSH
        # Hard Reboot Testline bj
        ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
        ${reboot_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${reboot_sucess_flag}"=="${True}"
    ...    Reboot ${MAX_REBOOT_TIME} times,RRU still can't go to green state.

Hard Reboot Testline bj
    Log To Console    Start to hard reboot testline...
    Print Current Time    Hard Reboot Time
#    Power Off AP
    Power Off GNB
#    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
#    Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_ap    on    ${AP_PDU_PORT}
    Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_gnb    on    ${GNB_PDU_PORT}

Backup And Update Iphy Swconfig File bj
    [Arguments]    ${iphy_file}=${empty}    ${swconfig_param}=${empty}    ${swconfig_param_AP}=${empty}
    ...    ${backup_dir}=${SUITE_LOG_DIRECTORY}/bak
    Create Directory    ${backup_dir}
    Add RD Parameters To GNB Swconfig File    0x1002A=1    #open catching emil fuction
    Run Keyword If    '${iphy_file}'!='${empty}'    Run Keywords    Get IPHY XML From Airphone    ${backup_dir}
    ...                 AND    Modify IPHY File And Send to Airphone bj    ${iphy_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'     Run Keywords    Get Swconfig File From GNB    ${backup_dir}
    ...                 AND    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
    Run Keyword If    '${swconfig_param_AP}'!='${empty}'    Run Keywords    Get Swconfig File From Airphone
    ...    ${backup_dir}
    ...                 AND   Add RD Parameters To Airphone Swconfig File    ${swconfig_param_AP}

Modify IPHY File And Send to Airphone bj
    [Arguments]    ${iphy_path}
    [Documentation]    adapt ORAN / non-ORAN config in iphy xml
    ...    update sw version for non-ORAN and ignore it for ORU
    ...    identify NCSnapshot file and copy it from local to AP
    ...    configure netconf account in case ORAN
    ...    adapt Send IPHY XML To Airphone for ORAN (can delete folder node_ORU0)
    ${RRU_type_list}    Get RRU Type From Local IPHY XML    ${iphy_path}
    ${wts_folder}    os.path.dirname        ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
#        Set Suite Variable    ${ORU_Flag}   ${RRU_type[0]}
        ${RRU_Version}    Run Keyword If   "${RRU_type[0]}"!="ORAN"    Get RRU Version From TargetBD File    ${RRU_type}
        ...    ${OUTPUT_DIR}
        Run Keyword If   "${RRU_type[0]}"!="ORAN"    Modify RRU Version Of IPHY XML    ${iphy_path}    ${RRU_type[0]}
        ...    ${RRU_Version}
    END
    Send IPHY XML To Airphone bj    ${iphy_path}
#    Run Keyword If    "${RRU_type_list[0][0]}"=="ORAN"    Run Keywords   Set Variable    ${NCSnapshot_File_list}
#    ...    Get NCSnapshot File From Local IPHY XML    ${iphy_path}
    ${NCSnapshot_File_list}   Run Keyword If    "${RRU_type_list[0][0]}"=="ORAN"
    ...    Get NCSnapshot File From Local IPHY XML    ${iphy_path}     ELSE   Create List
    FOR     ${NCSnapshot_File}   IN   @{NCSnapshot_File_list}
        ${scp}  Set Variable  scp ${wts_folder}/${NCSnapshot_File} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/
        Run Keyword If    "${RRU_type_list[0][0]}"=="ORAN"   OperatingSystem.Run   sshpass -p ${AP_ASIK.password} ${scp}
#        ...    scp ${wts_folder}/${NCSnapshot_File} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/
    END
#   Run Keyword If    "${RRU_type_list[0][0]}"=="ORAN"    OperatingSystem.Run    sshpass -p ${AP_ASIK.password}
#   ...    scp ${wts_folder}/${NCSnapshot_File_list[0]} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/
    Run Keyword If    "${RRU_type_list[0][0]}"=="ORAN"    Netconf User Addition bj

Get NCSnapshot File From Local IPHY XML
    [Arguments]    ${iphy_path}
    [Documentation]    Get NCSnapshot file name from iphy.xml in order to copy it from local to AP
    ${ret}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   count(//RE)
    ${num}    Evaluate      int(${ret})+1
    ${NCSnapshot_File_list}    Create List
    FOR     ${index}    IN RANGE     1      ${num}
        ${NCSnapshot_File_path}    tak_xml.Evaluate Xml Xpath    ${iphy_path}
        ...    string(//RE[${index}]/identity/NCSnapshotPath)
        ${NCSnapshot_File}    os.path.basename    ${NCSnapshot_File_path}
        Append To List    ${NCSnapshot_File_list}    ${NCSnapshot_File}
    END
    [Return]    @{NCSnapshot_File_list}

Netconf User Addition bj
    Wait Until Keyword Succeeds    2min    10sec    admin.Connect To    bts_host=${GNB_ASIK.ip}
    admin.Configure Netconf Radio Management    authentication_method=NoAuthentication
    ...    id=1    name=${oran_user}     password=${oran_pwd}    dist_name=${EMPTY}
    ...    unsecure_ciphering=False     format=${EMPTY}    value=${EMPTY}
    admin.Teardown

Send IPHY XML To Airphone bj
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -rf /ffs/run/simmode/*
    Should Be Equal As Integers    ${rc}    0
    ${cmd_1}  Set Variable  sshpass -p ${AP_ASIK.password} scp ${iphy_path}
    ${cmd_2}  Set Variable  @${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    ${rc}    OperatingSystem.Run And Return Rc    ${cmd_1} ${cmd_2}
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Common Test Setup Exception bj
    [Arguments]    ${delta_jason}=${none}    ${log}=yes
    [Documentation]    This keyword is to update parameters for this case.
    ...
    ...          1. Create test directory to store the logs for case
    ...
    ...          2. backup scf before update and after update parameters with jason file
    ...
    ...          3. start logs
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_jason} | No | jason file,It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    | *** Variables *** |
    ...    | ${SCF_PATH} | ${CURDIR}/config |
    ...
    ...    Examples1: no parameter need to update
    ...    | Common Test Setup |
    ...
    ...    Examples2: update parameter with jason file
    ...    | Common Test Setup | Delta_Conf_5GC002504_ET_01.json |
    Create Test Directory
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_LIST}

Suite Setup Start WTS And Check OnAir Without Workaround bj
    [Arguments]    ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${wts_cfg_file}
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection    ${enb_id}
#    ...    ${gnb_id}
    #Get NR Cell Number
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2
#    Verify Cell Setup
#    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}
#    ...    ${SUITE_LOG_DIRECTORY}

Suite Setup Start WTS And Check OnAir bj
    [Arguments]        ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}
    ${status}    Run Keyword And Return Status
    ...    Suite Setup Start WTS And Check OnAir Without Workaround bj    ${log}    ${enb_id}    ${gnb_id}
    ...    ${wts_cfg_file}
#    Run Keyword If    '${status}'=='False'    Workaround For Check SIB2 Fail    ${log}    ${enb_id}    ${gnb_id}
#    ...    ${wts_cfg_file}


Start DCAP Controller
    start_dcap_controller_py


Collect Specific Log By Dcap
    [Arguments]    ${time}    ${log_type}=cp_5g
    &{bts}=  Create Dictionary
    ...  host=192.168.255.1
    ...  port=443
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    @{gnb_custom_profile}=  Create List  ${log_type}
    &{trace}=  Create Dictionary
    ...  bts=${bts}
    ...  gnb_custom_profile=${gnb_custom_profile}
    dcap.Create DCAP Trace Collector
    ...  name=dcap
    ...  trace=${trace}
    Wait Until Keyword Succeeds    60    10    dcap.Setup Collectors   names=dcap
    dcap.Start Collectors   names=dcap
    Sleep    ${time}
    dcap.Stop_collectors     names=dcap
    dcap.Collect Collectors  names=dcap
    [teardown]    dcap.Teardown Collectors  names=dcap


DCAP start collect log
    [Arguments]    ${log_type}=cp_5g
    &{bts}=  Create Dictionary
    ...  host=192.168.255.129
    ...  port=443
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    @{gnb_custom_profile}=  Create List  ${log_type}
    &{trace}=  Create Dictionary
    ...  bts=${bts}
    ...  gnb_custom_profile=${gnb_custom_profile}
    dcap.Create DCAP Trace Collector
    ...  name=dcap
    ...  trace=${trace}
    Wait Until Keyword Succeeds    60    10    dcap.Setup Collectors   names=dcap
    dcap.Start Collectors   names=dcap
    dcap.set_suite_alias    dcap


DCAP stop collect log
    dcap.Stop_collectors     names=dcap
    dcap.Collect Collectors  names=dcap  target_dir=${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    cd ${TEST_LOG_DIRECTORY}/dcap;unzip -j dcap.zip "*.5gm" ; mv *.5gm dcap.5gm
    [teardown]    dcap.Teardown Collectors  names=dcap

DCAP_EMIL_DECODER
    rd.connect_to     host=127.0.0.1    port=9443    secure=${True}
    ${upload_result}      upload_encoded_file     file_name=${TEST_LOG_DIRECTORY}/dcap/dcap.5gm
    get_encoded_files_info
    ${operation_status}     Get from Dictionary    ${upload_result}     operation_status
    ${session_id}     Get from Dictionary    ${upload_result}     session_id
    ${grid_id}    Set Variable    ${upload_result['grid_ids'][0]}
    ${file_id}    Set Variable    ${upload_result['file_ids'][0]}
    # with JSON
    ${decoded_content}    get_decoded_file_contents_in_json
    ...                   session_id=${session_id}
    ...                   data_source_id=${file_id}
    ...                   tree=n

#    Log to console     ${decoded_content}
    ${json_string}    json.dumps    ${decoded_content}   indent=${4}
    Evaluate    open('${TEST_LOG_DIRECTORY}/dcap/emil_dcap.json', 'w').write('''${json_string}''')
    [Return]    ${TEST_LOG_DIRECTORY}/dcap/emil_dcap.json

Convert BIP To TXT By MCShark BJ
    [Arguments]    ${bip_file}    ${output_file}    ${filter}
    ${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}    ${output}=    Run And Return Rc And Output    lsb_release -cs|grep bookworm
    Run Keyword If    '${output}'=='bookworm'    Set Suite Variable    ${mcshark_file}
    ...    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*bookworm.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    OperatingSystem.Run    sudo mkdir -p ${MCSHARK_PLUGIN}/${tashark_version}/epan
    Run Keyword If    '${res}'=='False'    Download MCShark To UTE
#    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T > ${output_file}
    ${cmd}=    Catenate    tshark -V -r ${bip_file} -T text -Y ${filter} > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}
    ...    msg=No json file is converted! Please check whether filter message name is changed!

Install Ttitrace And MCshark BJ
    [Arguments]    ${package}=${BASELINE}
#    Run    sh ${EXECDIR}/testsuite/Beijing/ET/airphone/tools/local_testline/update_ttitrace.sh ${package}
    Run    sh ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/update_ttitrace.sh ${package}
