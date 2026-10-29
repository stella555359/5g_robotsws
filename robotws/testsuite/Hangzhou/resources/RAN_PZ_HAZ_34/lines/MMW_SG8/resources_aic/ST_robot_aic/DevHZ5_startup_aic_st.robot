*** Setting ***
Documentation
...    Author:kang xiang
...    contact:kang.xiang@nokia-sbell.com
...    squad group:VRF3_7

#Library  ../DevHZ5_lib_py_aic/src/DevHZ5_lib_aic.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG8.resources_aic.DevHZ5_lib_py_aic.src.DevHZ5_lib_aic    WITH NAME    DevHZ5_lib_aic
Library  OperatingSystem
Library  String
Library  Process
Library  XML  use_lxml=True
Library  Collections
Library   ute_fsmaccess
Library  ute_syslog
Library  ta_a2a
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Library  taf.gnb.oam.coam.cu    WITH NAME    coam_cu
#Library  taf.gnb.oam.coam.vdu    WITH NAME    coam_vdu
#Library  taf.hw.fhgw.cli    WITH NAME    fhgw_cli


*** Variables ***
# CU DU IP and account will be auto fetched from testline __init__.py which will follow agent deployment.
${DEBUG}  ${False}
${SCF_TEMPLATE_PATH}  /home/ute/MN/UTE/robotws/commissionings/HGZ
@{PARAMS_IN_SCF_CU}  ${EMPTY}
@{PARAMS_IN_SCF_DU1}  ${EMPTY}
@{PARAMS_IN_SCF_DU2}  ${EMPTY}
@{PARAMS_IN_SCF_DU3}  ${EMPTY}
@{PARAMS_IN_SCF_DU4}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_CU}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_DU}  ${EMPTY}
@{PARAMS_IN_ENV_SWCONFIG}    ${EMPTY}  #current not support
@{PARAMS_IN_SWCONFIG_AP}  ${EMPTY}
@{PARAMS_IN_ENV_SWCONFIG_AP}  ${EMPTY}
@{PARAMS_IN_APMIRROR}  ${EMPTY}  #current only LO in AiC
@{FAULTS_EXCLUDED_CHECKING}  ${EMPTY}
#${IM_FLAG}  ${True}
#@{PARAMS_IN_EMIL}  ${EMPTY}
${PM_COUNTER_INTERVAL}    5min
${AUTO_ANALYSIS_FLAG}  ${True}
${AUTO_FIX_VALIDATION_ERRORS}  ${False}
${BTSLOG_FLAG}  ${True}
${COREDUMP_FLAG}  ${False}
${EMIL_FLAG}  ${True}
${GNB_BIP_FLAG}  ${False}
${GNB_IQ_DATA_FLAG}  ${False}
${GNB_IQ_PARAM}  datalink:UL,iq_pci:50,du_id:1
${JOURNAL_FLAG}  ${False}
${MULTI_CPIF_FLAG}  ${False}
${OCP_DU_FLAG}  ${False}
${RANSHARING_FLAG}  ${False}
${RECREATE_WIRESHARK_FLAG}  ${True}
${REDUNDANT_MODE_CU_FLAG}  ${False}
${RESOURCES_LEAKAGE_FLAG}  ${True}
${STARTUP_LOG_FLAG}  ${False}
${SOS_REPORT_FLAG}    pass:False,fail:True
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${SNAPSHOT_FLAG}     pass:False,fail:True
${SA_NSA_MODEL}  ${EMPTY}
${SYSCOM_FLAG}  ${False}  # flag for syscom in wireshark log
${NOKIA_XNAP_PLUGIN_FLAG}  ${False}
${NOKIA_F1AP_PLUGIN_FLAG}  ${False}
${NOKIA_XNAP_PLUGIN_VERSION}  ${EMPTY}  # for example: 17.2.0-27
${NOKIA_F1AP_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 17.2.0-29
${NSETAPX_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 1.7.2
${TTITRACE_FLAG_CU}  ${False}
${TTITRACE_FLAG_DU1}  ${False}
${TTITRACE_FLAG_DU2}  ${False}
${TTITRACE_FLAG_DU3}  ${False}
${TTITRACE_FLAG_DU4}  ${False}
${TTI_Trace_Type}  Component
${TTI_Target_Component}  All
${TTI_Trace_Cell}  All
${UTE_WIRESHARK_FLAG}  ${True}
${UTE_CPU_MEM_FLAG}  ${False}
${WIRESHARK_FLAG}  ${True}
#${MANUAL_AUTO_REPORT_AIC}  ${False}
#${ONLY_REPORT_REP_AIC}  ${False}
${VDU_FHM_VLAN}  ${EMPTY}
${VDU2_FHM_VLAN}  ${EMPTY}
${VDU3_FHM_VLAN}  ${EMPTY}
${VDU4_FHM_VLAN}  ${EMPTY}
${VDU_RANNIC1_SERIAL_NUMBER}  ${EMPTY}
${VDU_RANNIC1_PRODUCT_CODE}  ${EMPTY}
${VDU_RANNIC2_SERIAL_NUMBER}  ${EMPTY}
${VDU_RANNIC2_PRODUCT_CODE}  ${EMPTY}
${VDU2_RANNIC1_SERIAL_NUMBER}  ${EMPTY}
${VDU2_RANNIC1_PRODUCT_CODE}  ${EMPTY}
${VDU2_RANNIC2_SERIAL_NUMBER}  ${EMPTY}
${VDU2_RANNIC2_PRODUCT_CODE}  ${EMPTY}
${VDU3_RANNIC1_SERIAL_NUMBER}  ${EMPTY}
${VDU3_RANNIC1_PRODUCT_CODE}  ${EMPTY}
${VDU3_RANNIC2_SERIAL_NUMBER}  ${EMPTY}
${VDU3_RANNIC2_PRODUCT_CODE}  ${EMPTY}
${VDU4_RANNIC1_SERIAL_NUMBER}  ${EMPTY}
${VDU4_RANNIC1_PRODUCT_CODE}  ${EMPTY}
${VDU4_RANNIC2_SERIAL_NUMBER}  ${EMPTY}
${VDU4_RANNIC2_PRODUCT_CODE}  ${EMPTY}
${REMOVE_LOGS}  off
${TCE_IP}   10.0.1.1
${TCE_PORT}  49100
${OMS_PORT}  49392
${BTS_STARTUP_RETRY}  1
${Ngc_IP}    10.0.11.10
@{TTI_TRACE_CONFIG_PARAMS_DU}  TNL-3/IPNO-1/IPRT-1:staticRoutes:destIpAddr=172.16.2.10
...  TNL-3/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=32
...  TNL-3/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.2.101
#@{EMIL_CONFIG_PARAMS_CU}  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
#...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
#...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.4.1
#@{EMIL_CONFIG_PARAMS_DU}  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
#...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
#...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.5.1

${Allowed_Faults_Ids_AiC}  8000

*** Keywords ***
Common Suite Setup Aic
  [Arguments]  ${DU_NUMBER}=du
  ${time}  Get Time
  Log To Console  current time is ${time}
  Log Variables
  Conver some variables
  Run Keyword And Ignore Error  Kill Useless Local Hosts
  Run Keyword And Ignore Error  Execute Cmd On Pc  df -h ${OUTPUT_DIR}
  _Create Suite Log Directory Aic
  _Get Testline Info Aic
  Set Suite Variable  ${DU_NUMBER}
  Get Aic Config Ip And Account Info For Vcu And Vdu
  _Get Aic Information
  Run Keyword And Ignore Error  Run Keyword If  '${EMIL_FLAG}' == '${True}'  Check And Install Dcap
  Run Keyword And Ignore Error  Download Wireshark Plugin
  [Teardown]  _Analyze Failure Of Aic SSH Issue

Common Suite Setup Aic 2Du
  Common Suite Setup Aic  DU_NUMBER=2du

Common Suite Setup Aic 4Du
  Common Suite Setup Aic  DU_NUMBER=4du

Import Suite Variables
    ${suite_path}    ${suite_name}    Split Path    ${SUITE SOURCE}
    ${suite_wo_ext}    ${ext}    Split Extension    ${suite_name}
    ${release_path}    select release path    ${suite_path}/test_data
    Log    ${suite_path}/test_data/${release_path}/${suite_wo_ext}_var.py
    ${status}    run keyword and return status    import variables    ${suite_path}/test_data/${release_path}/${suite_wo_ext}_var.py
    run keyword if    not ${status}    log    import ${suite_path}/test_data/${release_path}/${suite_wo_ext}_var.py failed    level=WARN

Suite Setup BTS Env Aic
  [Arguments]  ${scf}
  Setup BTS Env Aic  ${scf}

Suite Setup BTS Env Aic 2Du
  [Arguments]  ${scf}
  Common Suite Setup Aic 2Du
  Setup Airphone Env Aic  ${scf}

Suite Setup BTS Env Aic 4Du
  [Arguments]  ${scf}
  Common Suite Setup Aic 4Du
  Setup Airphone Env Aic  ${scf}

_Get TL TYPE File Path Aic
  ${TL_TYPE_PATH}  get variable value  ${TL_TYPE_PATH}
  Set Suite Variable  ${TL_TYPE_PATH}
  Run Keyword If  '${TL_TYPE_PATH}'=='None'  Log To Console With Time Prefix  '\${TL_TYPE_PATH} not define'  WARN
  Run Keyword If  '${TL_TYPE_PATH}'=='None'  Fail

## below 2 kw inherit from DevHZ5_startup.robot
_Create Suite Log Directory Aic
  ${timestamp}  Get Timestamp
  ${FILE_NAME} =  Replace String Using Regexp  ${SUITE_NAME[:50]}  \\s+$  ${EMPTY}
  ${SUITE_LOG_DIRECTORY} =  Catenate  SEPARATOR=${/}  ${OUTPUT_DIR}  ev_logs  ${FILE_NAME}_${timestamp}/
  ${SUITE_LOG_DIRECTORY}  Replace String  ${SUITE_LOG_DIRECTORY}  ${SPACE}  _
#  ${SUITE_LOG_DIRECTORY}  Replace String  ${SUITE_LOG_DIRECTORY}  -  _
  Create Directory  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Log To Console  LOG_DIR=${SAVE LOG DIRECTORY}

_Get Testline Info Aic
  #get aic testline info
  Log To Console  ===get aic testline info===
  ${testline_ip}  Execute Cmd On Pc  sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
  Set Suite Variable  ${testline_ip}
  Log  TestLineIpAddress\=${testline_ip}  console=True
  ${testline_hostname}  Execute Cmd On Pc  hostname
  Log  TestLineHostName\=${testline_hostname}  level=WARN
  ${HOST_NAME}    Replace String    ${testline_hostname}    -    _
  Set Suite Variable    ${HOST_NAME}
  Run Keyword And Ignore Error  Execute Cmd On Pc  robot --version
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip list | grep -e ute -e ta-a2a -e taf
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip install ta-a2a -U
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip list | grep ta-a2a
  #${ute_version}  Execute Cmd On Pc  ute-setup -v
  #Run Keyword And Ignore Error  Log  UTE_VERSION\=${ute_version.split()[-1]}  level=WARN
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute/MN/UTE/robotws;git log -n1;cd ~

_Get OCP Ranic Sw Controller Sync Operator Version
  Run Keyword And Ignore Error  Get Ocp Version Vcu
  Run Keyword And Ignore Error  Get Ocp Ranic Sw Control Sync Operator Version Vdu
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Ocp Ranic Sw Control Sync Operator Version Vdu2
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Ocp Ranic Sw Control Sync Operator Version Vdu3
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Ocp Ranic Sw Control Sync Operator Version Vdu4


_Get Aic Information
  Log To Console  \n===get vCU vDU info===
  #make sure ssh work with 5 attempts
  Wait For Host Ssh  ${VCU_SSH_IP}  username=${VCU_SSH_USER}  password=${VCU_SSH_PASSWD}  prompt=$  timeout=300  attempts=5
  Wait For Host Ssh  ${VDU_SSH_IP}  username=${VDU_SSH_USER}  password=${VDU_SSH_PASSWD}  prompt=$  timeout=300  attempts=5
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Wait For Host Ssh  ${VDU2_SSH_IP}  username=${VDU2_SSH_USER}
  ...  password=${VDU2_SSH_PASSWD}  prompt=$  timeout=300  attempts=5
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Wait For Host Ssh  ${VDU3_SSH_IP}  username=${VDU3_SSH_USER}
  ...  password=${VDU3_SSH_PASSWD}  prompt=$  timeout=300  attempts=5
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Wait For Host Ssh  ${VDU4_SSH_IP}  username=${VDU4_SSH_USER}
  ...  password=${VDU4_SSH_PASSWD}  prompt=$  timeout=300  attempts=5
  #get Aic info
  _Get OCP Ranic Sw Controller Sync Operator Version
  Check All Pods Is Running
  Run Keyword And Ignore Error  Enable M2M Interface Cu  ${VCU_NAMESPACE}
  Run Keyword And Ignore Error  Enable M2M Interface Du  ${VDU_NAMESPACE}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Enable M2M Interface Du2  ${VDU2_NAMESPACE}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Enable M2M Interface Du3  ${VDU3_NAMESPACE}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Enable M2M Interface Du4  ${VDU4_NAMESPACE}
  ${GNB_CU_VERSION}  Get Cu Version  ${VCU_NAMESPACE}
  ${GNB_DU_VERSION}  Get Du Version  ${VDU_NAMESPACE}
  ${GNB_DU2_VERSION}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Du2 Version  ${VDU2_NAMESPACE}
  ${GNB_DU3_VERSION}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Du3 Version  ${VDU3_NAMESPACE}
  ${GNB_DU4_VERSION}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Du4 Version  ${VDU4_NAMESPACE}
  Log  activeCUBuildVersion\=${GNB_CU_VERSION}  level=WARN
  Log  activeDUBuildVersion\=${GNB_DU_VERSION}  level=WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Log  activeDU2BuildVersion\=${GNB_DU2_VERSION}  level=WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Log  activeDU3BuildVersion\=${GNB_DU3_VERSION}  level=WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Log  activeDU4BuildVersion\=${GNB_DU4_VERSION}  level=WARN
  Set Suite Variable  ${GNB_CU_VERSION}
  Set Suite Variable  ${GNB_DU_VERSION}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Set Suite Variable  ${GNB_DU2_VERSION}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Set Suite Variable  ${GNB_DU3_VERSION}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Set Suite Variable  ${GNB_DU4_VERSION}

_Analyze Failure Of Aic SSH Issue
  Return From Keyword If  '${KEYWORD STATUS}'=='PASS'
  Run Keyword If  'Unable to connect to port 22 on ${VCU_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect ${VCU_SSH_IP}  WARN
  Run Keyword If  'Unable to connect to port 22 on ${VCU_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure vCU connection is reachable for local testline or reseved cloud testline.  WARN
  Run Keyword If  'Unable to connect to port 22 on ${VDU_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect ${VDU_SSH_IP}  WARN
  Run Keyword If  'Unable to connect to port 22 on ${VDU_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure vDU connection is reachable for local testline or reseved cloud testline.  WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...  Run Keyword If  'Unable to connect to port 22 on ${VDU2_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect ${VDU2_SSH_IP}  WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...  Run Keyword If  'Unable to connect to port 22 on ${VDU2_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure vDU2 connection is reachable for local testline or reseved cloud testline.  WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...  Run Keyword If  'Unable to connect to port 22 on ${VDU3_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect ${VDU3_SSH_IP}  WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...  Run Keyword If  'Unable to connect to port 22 on ${VDU3_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure vDU3 connection is reachable for local testline or reseved cloud testline.  WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...  Run Keyword If  'Unable to connect to port 22 on ${VDU4_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect ${VDU4_SSH_IP}  WARN
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...  Run Keyword If  'Unable to connect to port 22 on ${VDU4_SSH_IP}'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure vDU4 connection is reachable for local testline or reseved cloud testline.  WARN

Setup BTS Env Aic
    [Arguments]    ${scf}
    Common Suite Setup Aic
    #  Set Suite Variable  ${BTS_NUMBER}  1
    Run Keyword And Ignore Error    Import Suite Variables
    Return From Keyword If  ${DEBUG}
    Get vCU DU State
    _Decide Config Path For UTE Cloud Aic
    ${onair_status_1}  _Start Aic BTS For The First Time    ${scf}
    run keyword if  not ${onair_status_1}    Fail    fail to startup BTS

Get vCU DU State
    ${INIT_CU_STATE_ret}  Run Keyword And Ignore Error  Get Cu State Aic
    ${INIT_DU_STATE_ret}  Run Keyword And Ignore Error  Get Du State Aic
    ${INIT_DU2_STATE_ret}  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Du2 State
    ${INIT_DU3_STATE_ret}  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Du3 State
    ${INIT_DU4_STATE_ret}  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Du4 State
    Run Keyword And Ignore Error  Set Suite Variable  ${INIT_CU_STATE}  ${INIT_CU_STATE_ret}[1]
    Run Keyword And Ignore Error  Set Suite Variable  ${INIT_DU_STATE}  ${INIT_DU_STATE_ret}[1]
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error
    ...  Set Suite Variable  ${INIT_DU2_STATE}  ${INIT_DU2_STATE_ret}[1]
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error
    ...  Set Suite Variable  ${INIT_DU3_STATE}  ${INIT_DU3_STATE_ret}[1]
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error
    ...  Set Suite Variable  ${INIT_DU4_STATE}  ${INIT_DU4_STATE_ret}[1]


_Decide Config Path For UTE Cloud Aic
  ${ASM_Pod_Full_Name}  Run Keyword If  '${GNB_CU_VERSION}'=='None'  Find Pod Fullname In Aic vCU  oamasm
  ${ASM_Container_Full_Name}  Run Keyword If  '${GNB_CU_VERSION}'=='None'  Find Container Fullname In Aic vCU  oamasm  oamasm
  Run Keyword If  '${GNB_CU_VERSION}'=='None'  Set Suite Variable  ${ASM_Pod_Full_Name}
  Run Keyword If  '${GNB_CU_VERSION}'=='None'  Set Suite Variable  ${ASM_Container_Full_Name}
  ${CONFIG_PATH}    Decide Configurate Files Path Aic    test_type=ST
  Set Suite Variable  \${CONFIG_PATH}


_Get Duplex and Network mode Aic
  [Arguments]  ${tl_type}
  Log To Console  \n===get configuration info===
  ${DUPLEX}    Get Duplex    ${CONFIG_PATH}/${tl_type}/SCFC_1_cu.xml    ${PARAMS_IN_SCF_CU}
  Set Suite Variable  ${DUPLEX}
  log  DUPLEX=${DUPLEX}  console=True
  ${NETWORK_MODE}    Get Network Mode    ${CONFIG_PATH}/${tl_type}/SCFC_1_cu.xml    ${PARAMS_IN_SCF_CU}
  Set Suite Variable  ${NETWORK_MODE}
  log  NETWORK_MODE=${NETWORK_MODE}  console=True
  ${PARAMS_IN_SWCONFIG_CU}=    _Gen Extra Gnb Flag Aic    ${PARAMS_IN_SWCONFIG_CU}
  Set Suite Variable  ${PARAMS_IN_SWCONFIG_CU}
  ${PARAMS_IN_SWCONFIG_DU}=    _Gen Extra Gnb Flag Aic    ${PARAMS_IN_SWCONFIG_DU}
  Set Suite Variable  ${PARAMS_IN_SWCONFIG_DU}
  ${PARAMS_IN_SWCONFIG_AP}=    _Gen Extra Ap Flag Aic    ${PARAMS_IN_SWCONFIG_AP}
  Set Suite Variable  ${PARAMS_IN_SWCONFIG_AP}

_Gen Extra Gnb Flag Aic
  [Arguments]  ${params}
  ${new_params}=    Generate Extra Swconfig Flag Based On Condition    ${params}    ${PARAMS_IN_ENV_SWCONFIG}
  [Return]  ${new_params}

_Start Aic BTS For The First Time
  [Arguments]    ${scf}
  Log To Console  ${scf}
  ${onair_status}  Set Variable  ${False}
  Log To Console  \n===start Aic for 1st time===
  Start To Capture Logs Aic  startup_1
#  ${sw_updated}  judge_sw_updated
#  Change Vendor Parameters  ${PARAMS_IN_VENDOR}
  Change Swconfig Cu  ${PARAMS_IN_SWCONFIG_CU}  ${VCU_NAMESPACE}
  Change Swconfig Du  ${PARAMS_IN_SWCONFIG_DU}  ${VDU_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Change Swconfig Du2  ${PARAMS_IN_SWCONFIG_DU}  ${VDU2_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Change Swconfig Du3  ${PARAMS_IN_SWCONFIG_DU}  ${VDU3_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Change Swconfig Du4  ${PARAMS_IN_SWCONFIG_DU}  ${VDU4_NAMESPACE}
#  change rd parameters  ${PARAMS_IN_CP_UE_RD}
#  Get_Ngc_F1c_Xnc_Ip_With_Fhuc_Vlan  ${tl_type}
  ${scf_for_startup_cu}  Modify Scf And Perform Full Commission Cu    ${CONFIG_PATH}/CU/SCF_vCUCNF00.xml    ${PARAMS_IN_SCF_CU}
  Check Cpif And Capture Wireshark Vcu  startup_1
  ${scf_for_startup_du}  Modify Scf And Perform Full Commission Du    ${CONFIG_PATH}/vDU/SCF_vDUCNF00.xml    ${PARAMS_IN_SCF_DU1}
  ${scf_for_startup_du2}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...    Modify Scf And Perform Full Commission Du2    ${CONFIG_PATH}/vDU/SCF_vDUCNF00.xml    ${PARAMS_IN_SCF}
  ${scf_for_startup_du3}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...    Modify Scf And Perform Full Commission Du3    ${CONFIG_PATH}/vDU/SCF_vDUCNF00.xml    ${PARAMS_IN_SCF}
  ${scf_for_startup_du4}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...    Modify Scf And Perform Full Commission Du4    ${CONFIG_PATH}/vDU/SCF_vDUCNF00.xml    ${PARAMS_IN_SCF}
  Log To Console With Time Prefix  step: Check All Pods Is Running
  Run Keyword And Ignore Error  Check All Pods Is Running
  Run Keyword And Ignore Error  Run Keyword If  '${EMIL_FLAG}' == '${True}'  Start To Capture Emil Log Aic
  Start To Capture Wireshark Log Vdu  startup_1
  Run Keyword And Ignore Error  Run Keyword If  '${AP_BIP_FLAG}' == '${True}'  Start To Capture AP BIP Log Aic  startup_1
  Reestablish All Admin Connection
  ${onair_status}  Wait Aic BTS Onair And Return Status
  [Teardown]  Collect Logs For Startup Aic  startup_1  ${onair_status}
  [Return]  ${onair_status}

Check Cpif And Capture Wireshark Vcu
  [Documentation]  Capture vcu wireshark once cpif pod is running, used in framework during aic startup.
  [Arguments]  ${tag}=${empty}
  Check Single Pod Running Vcu  ${VCU_NAMESPACE}  cpif  ${True}
  Start To Capture Wireshark Log Vcu  ${tag}
  Return From Keyword If  ${MULTI_CPIF_FLAG} is not ${True}
  Start To Capture Wireshark Log Vcu  ${tag}  pod_name=cpifa1
  Start To Capture Wireshark Log Vcu  ${tag}  pod_name=cpifa2
  Start To Capture Wireshark Log Vcu  ${tag}  pod_name=cpifa3

Start To Capture Logs Aic
  [Arguments]  ${tag}=${EMPTY}
  Wait For Host Ssh  ${VCU_SSH_IP}  username=${VCU_SSH_USER}  password=${VCU_SSH_PASSWD}  prompt=$  timeout=600  attempts=5
  Wait For Host Ssh  ${VDU_SSH_IP}  username=${VDU_SSH_USER}  password=${VDU_SSH_PASSWD}  prompt=$  timeout=600  attempts=5
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Wait For Host Ssh  ${VDU2_SSH_IP}  username=${VDU2_SSH_USER}
  ...  password=${VDU2_SSH_PASSWD}  prompt=$  timeout=600  attempts=5
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Wait For Host Ssh  ${VDU3_SSH_IP}  username=${VDU3_SSH_USER}
  ...  password=${VDU3_SSH_PASSWD}  prompt=$  timeout=600  attempts=5
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Wait For Host Ssh  ${VDU4_SSH_IP}  username=${VDU4_SSH_USER}
  ...  password=${VDU4_SSH_PASSWD}  prompt=$  timeout=600  attempts=5
  Start To Capture BTS Logs Aic  ${tag}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Start To Capture BTS Logs eNB2  ${tag}
  _Start To Capture UTE Wireshark Aic  ${tag}
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Start To Capture GNB BIP Log Aic  ${tag}


Get Initial Active Faults
  [Documentation]  Get initial active faults before test.
  ${initial_act_alarm_list_cu}    Get Current Active Faultid Cu
  Set Test variable    ${initial_act_alarm_list_cu}
  ${initial_act_alarm_list_du}    Get Current Active Faultid Du
  Set Test variable    ${initial_act_alarm_list_du}
  ${initial_act_alarm_list_du2} =  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Current Active Faultid Du2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'    Set Test variable    ${initial_act_alarm_list_du2}
  ${initial_act_alarm_list_du3} =  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Current Active Faultid Du3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'    Set Test variable    ${initial_act_alarm_list_du3}
  ${initial_act_alarm_list_du4} =  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Current Active Faultid Du4
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'    Set Test variable    ${initial_act_alarm_list_du4}

Check No New Active Faults
  [Documentation]  Check no new active faults produce after test.
  Check No New Active Faultid Exist Cu    ${initial_act_alarm_list_cu}    ${FAULTS_EXCLUDED_CHECKING}
  Check No New Active Faultid Exist Du    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Check No New Active Faultid Exist Du2
  ...    ${initial_act_alarm_list_du2}    ${FAULTS_EXCLUDED_CHECKING}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Check No New Active Faultid Exist Du3
  ...    ${initial_act_alarm_list_du3}    ${FAULTS_EXCLUDED_CHECKING}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Check No New Active Faultid Exist Du4
  ...    ${initial_act_alarm_list_du4}    ${FAULTS_EXCLUDED_CHECKING}

Start To Capture BTS Logs Aic
  [Arguments]  ${tag}=${empty}
  #Execute Cmd On Pc  netstat -na | grep 1500
  Start To Capture CUDU Systemlog  ${tag}
#  Start To Capture Infomodel Log
  run keyword if  not 'startup' in '${tag}'  Start To Capture Wireshark Log Aic  ${tag}
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Run Keyword If  '${EMIL_FLAG}' == '${True}'
  ...  Start To Capture Emil Log Aic
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Start To Capture Gnb Ttitrace  ${tag}

Start To Capture CUDU Systemlog
  [Arguments]  ${tag}=${empty}
  [Documentation]  capture CUDU Systemlog
  Log  ${tag}
  Run Keyword And Ignore Error    capture_syslog_in_vcu    ${VCU_NAMESPACE}
  Run Keyword And Ignore Error    capture_syslog_in_vdu    ${VDU_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'    Run Keyword And Ignore Error    capture_syslog_in_vdu2    ${VDU2_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'    Run Keyword And Ignore Error    capture_syslog_in_vdu3    ${VDU3_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'    Run Keyword And Ignore Error    capture_syslog_in_vdu4    ${VDU4_NAMESPACE}

_Start To Capture UTE Wireshark Aic
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_WIRESHARK_FLAG} is not ${True} and 'startup' not in '${tag}'
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth3 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth3.pcap>& tmp_3.txt&
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth4 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth4.pcap>& tmp_4.txt&
#  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'
#  ...  Execute Cmd On Pc  sudo tcpdump -i eth5 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth5.pca>& tmp5.txt&

Collect All Startup log
  [Arguments]  ${tag}=${empty}
  [Documentation]  Collect All startup log in vcu/vdu
  Log  ${tag}
  Create Directory    ${SAVE LOG DIRECTORY}/Startup_log
  capture_Startup_log_in_vcu    ${VCU_NAMESPACE}    ${SAVE LOG DIRECTORY}/Startup_log
  capture_Startup_log_in_vdu    ${VDU_NAMESPACE}    ${SAVE LOG DIRECTORY}/Startup_log
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  capture_Startup_log_in_vdu2  ${VDU2_NAMESPACE}  ${SAVE LOG DIRECTORY}/Startup_log
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  capture_Startup_log_in_vdu3  ${VDU3_NAMESPACE}  ${SAVE LOG DIRECTORY}/Startup_log
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  capture_Startup_log_in_vdu4  ${VDU4_NAMESPACE}  ${SAVE LOG DIRECTORY}/Startup_log

Collect All journal log
  [Arguments]  ${tag}=${empty}
  [Documentation]  Collect All journal log in vcu/vdu
  Log  ${tag}
  Create Directory    ${SAVE LOG DIRECTORY}/journal_log
  capture_journal_log_in_vcu    ${VCU_NAMESPACE}    ${SAVE LOG DIRECTORY}/journal_log
  capture_journal_log_in_vdu    ${VDU_NAMESPACE}    ${SAVE LOG DIRECTORY}/journal_log
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  capture_journal_log_in_vdu2  ${VDU2_NAMESPACE}  ${SAVE LOG DIRECTORY}/journal_log
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  capture_journal_log_in_vdu3  ${VDU3_NAMESPACE}  ${SAVE LOG DIRECTORY}/journal_log
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  capture_journal_log_in_vdu4  ${VDU4_NAMESPACE}  ${SAVE LOG DIRECTORY}/journal_log

Collect Coredump Log
  [Documentation]  Collect All coredump log in vcu/vdu
  Collect Coredump Log Cu
  Collect Coredump Log Du
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Collect Coredump Log Du2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Collect Coredump Log Du3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Collect Coredump Log Du4

Start To Capture Wireshark Log Vcu
  [Arguments]  ${tag}=${empty}  ${pod_name}=cpif  ${redundantRole}=active
  [Documentation]  capture wireshark from acitve cpif pod in cu currently, support redundant/multi-cpif deployment.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty   | wireshark name |
    ...    | ${pod_name}      | No   | cpif    | cpif/cpifa1/cpifa2/cpifa3 |
    ...	   | ${redundantRole} | No   | active  | active/standby |
    ...
    ...    Examples:
    ...    | Start To Capture Wireshark Log Vcu | pod_name=cpifa1 |
    ...    | Start To Capture Wireshark Log Vcu | ue_attach | pod_name=cpifa1 |
    ...    | Start To Capture Wireshark Log Vcu | ue_attach | pod_name=cpifa2 | redundantRole=standby |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  Run Keyword And Ignore Error  Execute Cmd On Vcu  rm -rf /tmp/${VCU_NAMESPACE}/tmp_wireshark/*wireshark*.pcap
  Run Keyword And Ignore Error  _Start To Capture Wireshark Log In vCU  ${wireshark_name}  ${pod_name}  redundantRole=${redundantRole}

Start To Capture Wireshark Log In RedundantRole Pod Vcu
  [Documentation]  capture wireshark from acitve cpif pod in cu currently, used in redundant/multi-cpif deployment.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${tag}           | No   | wireshark name,default is empty |
    ...    | ${pod_name}      | No   | cpif/cpifa1/cpifa2/cpifa3,default is cpif |
    ...	   | ${redundantRole} | No   | active/standby, default is active |
    ...
    ...    Examples:
    ...    | Start To Capture Wireshark Log In RedundantRole Pod Vcu | pod_name=cpifa1 |
    ...    | Start To Capture Wireshark Log In RedundantRole Pod Vcu | tag=ue_attach | pod_name=cpifa1 |
  [Arguments]  ${tag}=${empty}  ${pod_name}=cpif  ${redundantRole}=active
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  Run Keyword And Ignore Error  Execute Cmd On Vcu  rm -rf /tmp/${VCU_NAMESPACE}/tmp_wireshark/*wireshark*.pcap
  Run Keyword And Ignore Error  _Start To Capture Wireshark Log In vCU  ${wireshark_name}  ${pod_name}  redundantRole=${redundantRole}

Start To Capture Wireshark Log Vdu
  [Arguments]  ${tag}=${empty}
  [Documentation]  capture wireshark from cprt pod in du and du2, don't support redundant/multi-cprt deployment currently.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty   | wireshark name |
    ...
    ...    Examples:
    ...    | Start To Capture Wireshark Log Vdu | ue_attach |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  Run Keyword And Ignore Error  Execute Cmd On Vdu  rm -rf /tmp/${VDU_NAMESPACE}/tmp_wireshark/*wireshark*.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Execute Cmd On Vdu2
  ...  rm -rf /tmp/${VDU2_NAMESPACE}/tmp_wireshark/*wireshark*.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Execute Cmd On Vdu3
  ...  rm -rf /tmp/${VDU3_NAMESPACE}/tmp_wireshark/*wireshark*.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Execute Cmd On Vdu4
  ...  rm -rf /tmp/${VDU4_NAMESPACE}/tmp_wireshark/*wireshark*.pcap
  Run Keyword And Ignore Error  _Start To Capture Wireshark Log In vDU  ${wireshark_name}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...  _Start To Capture Wireshark Log In vDU2  ${wireshark_name}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...  _Start To Capture Wireshark Log In vDU3  ${wireshark_name}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...  _Start To Capture Wireshark Log In vDU4  ${wireshark_name}

Start To Capture Wireshark Log Aic
  [Arguments]  ${tag}=${empty}
  [Documentation]  capture cpif in vcu and cprt in vdu by default
  Start To Capture Wireshark Log Vcu  ${tag}
  Run Keyword If  ${MULTI_CPIF_FLAG} is ${True}  Start To Capture Wireshark Log Vcu  ${tag}  pod_name=cpifa1
  Run Keyword If  ${MULTI_CPIF_FLAG} is ${True}  Start To Capture Wireshark Log Vcu  ${tag}  pod_name=cpifa2
  Run Keyword If  ${MULTI_CPIF_FLAG} is ${True}  Start To Capture Wireshark Log Vcu  ${tag}  pod_name=cpifa3
  Start To Capture Wireshark Log Vdu  ${tag}

_Start To Capture Wireshark Log In vCU
  [Arguments]    ${wireshark_name}  ${pod_name}=cpif  ${container_name}=nwmgmt  ${redundantRole}=active
  [Documentation]  vcu namespace get from testline init config file
    ...    | Input Parameters | Man | Default | Description |
    ...	   | pod name         | No  | cpif    | the pod_name in vCU |
    ...	   | container name   | No  | nwmgmt  | the container_name in vCU |
    ...	   | redundantRole    | No  | the redundantRole of pod in vCU |
    ...	   | vcu index | No | 0 | the vcu index config on TL |
    ...    | gnb index | No | 0 | the gnb index config on TL |
  Capture Wireshark Log In vCU  ${pod_name}  ${container_name}  ${VCU_NAMESPACE}  ${wireshark_name}  ${redundantRole}

_Start To Capture Wireshark Log In vDU
  [Arguments]    ${wireshark_name}  ${pod_name}=cprt  ${container_name}=nwmgmt
  [Documentation]  vdu namespace get from testline init config file
    ...    | Input Parameters | Man | Default | Description |
    ...	   | pod name         | No  | cprt    | the pod_name in vDU |
    ...	   | container name   | No  | nwmgmt  | the container_name in vDU |
    ...	   | vdu index        | No  | 0 | the vdu index config on TL |
    ...    | gnb index        | No  | 0 | the gnb index config on TL |
  Capture Wireshark Log In vDU  ${pod_name}  ${container_name}  ${VDU_NAMESPACE}  ${wireshark_name}

_Start To Capture Wireshark Log In vDU2
  [Arguments]    ${wireshark_name}  ${pod_name}=cprt  ${container_name}=nwmgmt
  [Documentation]  vdu namespace get from testline init config file
    ...    | Input Parameters | Man | Default | Description |
    ...	   | pod name         | No  | cprt    | the pod_name in vDU |
    ...	   | container name   | No  | nwmgmt  | the container_name in vDU |
    ...	   | vdu index        | No  | 0 | the vdu index config on TL |
    ...    | gnb index        | No  | 0 | the gnb index config on TL |
  Capture Wireshark Log In vDU Du2  ${pod_name}  ${container_name}  ${VDU2_NAMESPACE}  ${wireshark_name}

_Start To Capture Wireshark Log In vDU3
  [Arguments]    ${wireshark_name}  ${pod_name}=cprt  ${container_name}=nwmgmt
  [Documentation]  vdu namespace get from testline init config file
    ...    | Input Parameters | Man | Default | Description |
    ...	   | pod name         | No  | cprt    | the pod_name in vDU |
    ...	   | container name   | No  | nwmgmt  | the container_name in vDU |
    ...	   | vdu index        | No  | 0 | the vdu index config on TL |
    ...    | gnb index        | No  | 0 | the gnb index config on TL |
  Capture Wireshark Log In vDU Du3  ${pod_name}  ${container_name}  ${VDU3_NAMESPACE}  ${wireshark_name}

_Start To Capture Wireshark Log In vDU4
  [Arguments]    ${wireshark_name}  ${pod_name}=cprt  ${container_name}=nwmgmt
  [Documentation]  vdu namespace get from testline init config file
    ...    | Input Parameters | Man | Default | Description |
    ...	   | pod name         | No  | cprt    | the pod_name in vDU |
    ...	   | container name   | No  | nwmgmt  | the container_name in vDU |
    ...	   | vdu index        | No  | 0 | the vdu index config on TL |
    ...    | gnb index        | No  | 0 | the gnb index config on TL |
  Capture Wireshark Log In vDU Du4  ${pod_name}  ${container_name}  ${VDU4_NAMESPACE}  ${wireshark_name}


Modify File Parameter Aic
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Start To Capture GNB BIP Log Aic
  [Arguments]  ${tag}=${empty}
  Log  ${tag}
  Return From Keyword If  ${GNB_BIP_FLAG} is not ${True}
  Run Keyword And Ignore Error  Capture Aic Bip Log Du  namespace=${VDU_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Capture Aic Bip Log Du2  namespace=${VDU2_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Capture Aic Bip Log Du3  namespace=${VDU3_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Capture Aic Bip Log Du4  namespace=${VDU4_NAMESPACE}

_Start To Monitor CPU Mem Aic
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_CPU_MEM_FLAG} is not ${True}
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Comment  Run Keyword And Ignore Error  Execute Egate Command  cp /system_stats/get_testline_info.sh /home/ute  Copied
  Comment  Run Keyword And Ignore Error  Execute Egate Command  cp /system_stats/cpu_stats.sh /home/ute  Copied
  Comment  Run Keyword And Ignore Error  Execute Egate Command  cp /system_stats/system_stats.sh /home/ute  Copied
  Run Keyword And Ignore Error  Execute Cmd On Pc  cp ${CURDIR}/tools_aic/*.sh /home/ute
  Run Keyword And Ignore Error  Execute Cmd On Pc  chmod +x /home/ute/*.sh
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute;./get_testline_info.sh > ${log_dir}/tl_info.log
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute;./cpu_stats.sh ${log_dir}/cpu_stats.log >& ${log_dir}/cpu_error.txt&
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cd /home/ute;./system_stats.sh > ${log_dir}/system_stats.log 2>${log_dir}/system_stats_error.log&

Modify Scf And Perform Full Commission In Cu
  [Arguments]  ${tl_type}
  # Emil_Config_Params_Cu
  Append To List  ${PARAMS_IN_SCF_CU}  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.4.1
  Ready For Commission Checking Vcu  ${VCU_NAMESPACE}
  ${scf_for_startup_cu}  Modify Scf And Perform Full Commission Cu  ${CONFIG_PATH}/${tl_type}/SCFC_1_cu.xml  ${PARAMS_IN_SCF_CU}
  [Return]  ${scf_for_startup_cu}

Modify Scf And Perform Full Commission In Du
  [Arguments]  ${tl_type}
  Run Keyword If  '${VDU_FHUC_VLAN1}' != '${EMPTY}' and '${VDU_FHUC_VLAN1}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU1}  LCELNR-1:vlanId=${VDU_FHUC_VLAN1}
  Run Keyword If  '${VDU_FHUC_VLAN2}' != '${EMPTY}' and '${VDU_FHUC_VLAN2}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU1}  LCELNR-2:vlanId=${VDU_FHUC_VLAN2}
  # RANNIC Info for DC of 1RANNIC/2RANNIC in vDU
  Run Keyword If  '${VDU_RANNIC1_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU_RANNIC1_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU1}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:serialNumberPlanned=${VDU_RANNIC1_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:prodCodePlanned=${VDU_RANNIC1_PRODUCT_CODE}
  Run Keyword If  '${VDU_RANNIC2_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU_RANNIC2_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU1}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:serialNumberPlanned=${VDU_RANNIC2_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:prodCodePlanned=${VDU_RANNIC2_PRODUCT_CODE}
  # Emil_Config_Params_Du
  Append To List  ${PARAMS_IN_SCF_DU1}  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.5.1
  Ready For Commission Checking Vdu  ${VDU_NAMESPACE}
  ${scf_for_startup_du}  Modify Scf And Perform Full Commission Du  ${CONFIG_PATH}/${tl_type}/SCFC_1_du.xml  ${PARAMS_IN_SCF_DU1}
  [Return]  ${scf_for_startup_du}

Modify Scf And Perform Full Commission In Du2
  [Arguments]  ${tl_type}
  # RANNIC Info for DC of 1RANNIC/2RANNIC in vDU
  Run Keyword If  '${VDU2_RANNIC1_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU2_RANNIC1_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU2}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:serialNumberPlanned=${VDU2_RANNIC1_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:prodCodePlanned=${VDU2_RANNIC1_PRODUCT_CODE}
  Run Keyword If  '${VDU2_RANNIC2_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU2_RANNIC2_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU2}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:serialNumberPlanned=${VDU2_RANNIC2_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:prodCodePlanned=${VDU2_RANNIC2_PRODUCT_CODE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Append To List  ${PARAMS_IN_SCF_DU2}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.5.1
  Ready For Commission Checking Vdu2  ${VDU2_NAMESPACE}
  ${scf_for_startup_du2}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Modify Scf And Perform Full Commission Du2
  ...  ${CONFIG_PATH}/${tl_type}/SCFC_1_du2.xml  ${PARAMS_IN_SCF_DU2}
  [Return]  ${scf_for_startup_du2}

Modify Scf And Perform Full Commission In Du3
  [Arguments]  ${tl_type}
  # RANNIC Info for DC of 1RANNIC/2RANNIC in vDU
  Run Keyword If  '${VDU3_RANNIC1_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU3_RANNIC1_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU3}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:serialNumberPlanned=${VDU3_RANNIC1_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:prodCodePlanned=${VDU2_RANNIC1_PRODUCT_CODE}
  Run Keyword If  '${VDU3_RANNIC2_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU3_RANNIC2_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU3}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:serialNumberPlanned=${VDU3_RANNIC2_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:prodCodePlanned=${VDU3_RANNIC2_PRODUCT_CODE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Append To List  ${PARAMS_IN_SCF_DU3}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.5.1
  Ready For Commission Checking Vdu3  ${VDU3_NAMESPACE}
  ${scf_for_startup_du3}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Modify Scf And Perform Full Commission Du3
  ...  ${CONFIG_PATH}/${tl_type}/SCFC_1_du3.xml  ${PARAMS_IN_SCF_DU3}
  [Return]  ${scf_for_startup_du3}

Modify Scf And Perform Full Commission In Du4
  [Arguments]  ${tl_type}
  # RANNIC Info for DC of 1RANNIC/2RANNIC in vDU
  Run Keyword If  '${VDU4_RANNIC1_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU4_RANNIC1_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU4}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:serialNumberPlanned=${VDU4_RANNIC1_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-1:prodCodePlanned=${VDU2_RANNIC1_PRODUCT_CODE}
  Run Keyword If  '${VDU4_RANNIC2_SERIAL_NUMBER}' != '${EMPTY}' and '${VDU4_RANNIC2_SERIAL_NUMBER}' != 'None'
  ...  Append To List  ${PARAMS_IN_SCF_DU4}  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:serialNumberPlanned=${VDU4_RANNIC2_SERIAL_NUMBER}
  ...  MRBTS-1/EQM-1/APEQM-1/RNICMOD-2:prodCodePlanned=${VDU4_RANNIC2_PRODUCT_CODE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Append To List  ${PARAMS_IN_SCF_DU4}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destIpAddr=${testline_ip}
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:destinationIpPrefixLength=24
  ...  TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=172.16.5.1
  Ready For Commission Checking Vdu4  ${VDU4_NAMESPACE}
  ${scf_for_startup_du4}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Modify Scf And Perform Full Commission Du4
  ...  ${CONFIG_PATH}/${tl_type}/SCFC_1_du4.xml  ${PARAMS_IN_SCF_DU4}
  [Return]  ${scf_for_startup_du4}

Make Sure Aic SSH OK
  Run Keyword And Ignore Error  Wait For Host Ssh  ${VCU_SSH_IP}  username=${VCU_SSH_USER}  password=${VCU_SSH_PASSWD}  prompt=$  timeout=180
  Run Keyword And Ignore Error  Wait For Host Ssh  ${VDU_SSH_IP}  username=${VDU_SSH_USER}  password=${VDU_SSH_PASSWD}  prompt=$  timeout=180
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Wait For Host Ssh  ${VDU2_SSH_IP}
  ...  username=${VDU2_SSH_USER}  password=${VDU2_SSH_PASSWD}  prompt=$  timeout=180
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Wait For Host Ssh  ${VDU3_SSH_IP}
  ...  username=${VDU3_SSH_USER}  password=${VDU3_SSH_PASSWD}  prompt=$  timeout=180
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Wait For Host Ssh  ${VDU4_SSH_IP}
  ...  username=${VDU4_SSH_USER}  password=${VDU4_SSH_PASSWD}  prompt=$  timeout=180


Wait Aic BTS Onair And Return Status
    Log To Console With Time Prefix  step: Wait All Dus To Configured State
    ${configured_status}  Set Variable  ${False}
    ${configured_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  20min  30s  Wait Gnb Configured State Aic
    Run Keyword If  '${configured_status}'=='${False}'  Log To Console With Time Prefix  Not all Dus achieve to configured status
    Return From Keyword If    '${configured_status}'=='${False}'    ${configured_status}
    Run Keyword And Ignore Error  Start To Capture GNB BIP Log Aic
    ${onair_status}  Set Variable  ${False}
    ${onair_status}  wait_bts_onair_aic
    Return From Keyword  ${onair_status}

Wait Gnb Configured State Aic
  [Documentation]  no infomodule in aic currently, so using cu du status instead
  ${configured_status_aic}  Set Variable  ${False}
  ${configured_status_du}  Get Du State Aic
  ${operational_state_cu}  Get Cu State Aic
  ${configured_status_du2}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Du2 State
  ${configured_status_du3}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Du3 State
  ${configured_status_du4}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Du4 State
  Should Be True  "${configured_status_du}"=="configured" or "${configured_status_du}"=="integrated to RAN" or "${configured_status_du}"=="onAir"
  Should Be True  "${operational_state_cu}"=="enabled"
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Should Be True
  ...  "${configured_status_du2}"=="configured" or "${configured_status_du2}"=="integrated to RAN" or "${configured_status_du2}"=="onAir"
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Should Be True
  ...  "${configured_status_du3}"=="configured" or "${configured_status_du3}"=="integrated to RAN" or "${configured_status_du3}"=="onAir"
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Should Be True
  ...  "${configured_status_du4}"=="configured" or "${configured_status_du4}"=="integrated to RAN" or "${configured_status_du4}"=="onAir"
  ${configured_status_aic}  Set Variable  ${True}
  Return From Keyword  ${configured_status_aic}

Collect Logs For Startup Aic
  [Arguments]  ${tag}  ${onair_status}
  Run Keyword And Ignore Error  Enable M2M Interface Cu  ${VCU_NAMESPACE}
  Run Keyword And Ignore Error  Enable M2M Interface Du  ${VDU_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Enable M2M Interface Du2  ${VDU2_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Enable M2M Interface Du3  ${VDU3_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Enable M2M Interface Du4  ${VDU4_NAMESPACE}
  Log To Console With Time Prefix  collecting logs
  Check Current Pod Status And Oamext Pod Running In Aic
  Run Keyword If  '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot Gnb1  ${tag}
#  Run Keyword If  '${BTS_NUMBER}'=='2'and '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG}'=='${True}'
#  ... Run Keyword And Ignore Error  Collect Snapshot Enb2  ${tag}
  Run Keyword And Ignore Error  Run Keyword If  'startup' in '${tag}'  execute cmd on pc  mkdir ${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs
  ...  ELSE  execute cmd on pc  mkdir ${SAVE LOG DIRECTORY}/scfc_logs
  Run Keyword And Ignore Error  Get Cu Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/scf_after_startup_cu.xml
  Run Keyword And Ignore Error  Get Du Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_startup_du.xml
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error
  ...  Get Du2 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_startup_du2.xml
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error
  ...  Get Du3 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_startup_du3.xml
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error
  ...  Get Du4 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_startup_du4.xml
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Collect Scf
#  ...  ${SAVE LOG DIRECTORY}${/}${GNB2_ALIAS}/${tag}_logs/scf_after_startup.xml  alias=${GNB2_ALIAS}
  ${tmp_startup_sos}=  Run Keyword If  '${tag}'=='startup_1'  Set Variable  ${SOS_REPORT_STARTUP_1_FLAG_DIC}
  ...  ELSE IF  '${tag}'=='startup_${${BTS_STARTUP_RETRY}+1}'  Set Variable  ${SOS_REPORT_FLAG_DIC}
  ...  ELSE   Create Dictionary  pass=false  fail=false
  ${SOS_REPORT_FLAG_WORK}  Set Variable If  '${onair_status}'=='${False}'  ${tmp_startup_sos['fail']}  ${tmp_startup_sos['pass']}
  Set Suite Variable  ${SOS_REPORT_FLAG_WORK}
  Run Keyword And Ignore Error  Stop Capture Logs Aic  ${tag}
  Start To Capture Rannic Sw Controller Logs  ${tag}
  Run Keyword If  '${onair_status}'=='${False}' and '${OCP_DU_FLAG}'=='${True}'  Start To Capture Ocp Logs Du  ${tag}
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir Aic  ${tag}
  Analyze Logs  ${tag}  ${onair_status}
  Compress Directory Aic  ${SAVE LOG DIRECTORY}/${tag}_logs
  Run Keyword And Ignore Error  Release Admin Connection
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Compress Directory Aic
#  ...  ${SAVE LOG DIRECTORY}${/}${GNB2_ALIAS}/${tag}_logs

Collect Snapshot Gnb1
  [Arguments]  ${tag}=${EMPTY}
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Execute Cmd On Pc    df -h ${OUTPUT_DIR}    # 20G is needed for snapshot capturing according to PR722687
  Run Keyword And Return Status  Execute Cmd on Pc  mkdir ${snapshot_dir}/snapshot_cu
  Run Keyword And Return Status  Execute Cmd on Pc  mkdir ${snapshot_dir}/snapshot_du
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Execute Cmd on Pc  mkdir ${snapshot_dir}/snapshot_du2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Execute Cmd on Pc  mkdir ${snapshot_dir}/snapshot_du3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Execute Cmd on Pc  mkdir ${snapshot_dir}/snapshot_du4
  ${status_cu}=  Run Keyword And Return Status  Collect Snapshot CU  ${snapshot_dir}/snapshot_cu
  ${status_du}=  Run Keyword And Return Status  Collect Snapshot DU  ${snapshot_dir}/snapshot_du
  Run Keyword And Ignore Error  Execute Cmd on Pc  cd ${snapshot_dir}/snapshot_du;zip -m -r snapshot_du.zip *
  ${status_du2}=  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Return Status
  ...  Collect Snapshot DU2  ${snapshot_dir}/snapshot_du2
  ${status_du3}=  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Return Status
  ...  Collect Snapshot DU3  ${snapshot_dir}/snapshot_du3
  ${status_du4}=  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Return Status
  ...  Collect Snapshot DU4  ${snapshot_dir}/snapshot_du4
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Execute Cmd on Pc
  ...  cd ${snapshot_dir}/snapshot_du2;zip -m -r snapshot_du2.zip *
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Execute Cmd on Pc
  ...  cd ${snapshot_dir}/snapshot_du3;zip -m -r snapshot_du3.zip *
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Execute Cmd on Pc
  ...  cd ${snapshot_dir}/snapshot_du4;zip -m -r snapshot_du4.zip *
  ## below kw need check if has similar command execute in cu du
#  Run Keyword Unless  ${status}  Execute Aashell Cmd  log -c full -a -z snapshot.zip  timeout=180
#  Run Keyword Unless  ${status}  Get Enb File  /tmp/snapshot.zip  ${snapshot_dir}/snapshot.zip
  Execute Cmd On Pc    df -h ${OUTPUT_DIR}

Stop Capture Logs Aic
  [Arguments]  ${tag}=${EMPTY}
  _Stop Capture UTE Wireshark Aic
  Stop Capture BTS Logs Aic  ${tag}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Stop Capture BTS Logs eNB2  ${tag}
  ${case_files}    Set Variable
  ...  ${SAVE LOG DIRECTORY.rsplit("/", 1)[0]}/${SUITE SOURCE.rsplit("/", 1)[0].rsplit("/", 1)[1]}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  mkdir -p ${case_files} && cp -r ${SUITE SOURCE.rsplit("/", 1)[0]}/*.robot ${case_files}
  Run Keyword And Ignore Error  Execute Cmd On Pc  cp -r ${SUITE SOURCE.rsplit("/", 1)[0]}/*a2a* ${case_files}

##below 2kw inherit from 5G classical
_Stop Capture UTE Wireshark Aic
  ${status}  ${pids_sys}    Run Keyword And Ignore Error    Get Linux Process Id    tcpdump    ute_wireshark
  Run Keyword And Ignore Error    Kill Linux Process  ${pids_sys}
  ${pid_check_result}=    Run Keyword And Ignore Error    Execute Cmd On Pc  ps aux | grep ute_wireshark | grep -v -w grep
  ${status}    Run Keyword And Return Status    Should Not Contain    ${pid_check_result}[1]    ute_wireshark
  run keyword if  not ${status}  Log   Kill Ute Wireshark Process Failure    level=WARN

Stop Capture BTS Logs Aic
  [Arguments]  ${tag}=${empty}
  Stop Capture Wireshark Log Aic  ${tag}  teardown_flag=${True}
  ## seem no ims log in Aic, can find from snapshot file
#  Stop To Capture Infomodel Log  ${tag}
  Run Keyword And Ignore Error  Stop To Capture CUDU Systemlog  ${tag}
  Run Keyword If  '${EMIL_FLAG}' == '${True}'  Run Keyword And Ignore Error  Stop To Capture Emil Log Aic  ${tag}
  Run Keyword And Ignore Error  Stop To Capture GNB BIP Log Aic  ${tag}
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Stop Capture Gnb TTITrace  ${tag}
  Start To Capture Rannic Sw Controller Logs  ${tag}
  Run Keyword If  'startup' not in '${tag}' and '${OCP_DU_FLAG}'=='${True}'  Run Keyword If Test Failed  Start To Capture Ocp Logs Du  ${tag}

Start To Capture Rannic Sw Controller Logs
  [Arguments]  ${tag}=${EMPTY}
  ${rannic_sw_controller_log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs/  ${SAVE LOG DIRECTORY}/
  Run Keyword And Ignore Error  Capture Rannic Sw Controller Logs Du  rannic_sw_controller_log_path=${rannic_sw_controller_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error
  ...  Capture Rannic Sw Controller Logs Du2  rannic_sw_controller_log_path=${rannic_sw_controller_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error
  ...  Capture Rannic Sw Controller Logs Du3  rannic_sw_controller_log_path=${rannic_sw_controller_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error
  ...  Capture Rannic Sw Controller Logs Du4  rannic_sw_controller_log_path=${rannic_sw_controller_log_dir}

Start To Capture Ocp Logs Du
  [Arguments]  ${tag}=${EMPTY}
  ${ocp_log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs/  ${SAVE LOG DIRECTORY}/
  Run Keyword And Ignore Error  Capture Ocp Logs Du  ocp_log_path=${ocp_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error
  ...  Capture Ocp Logs Du2  ocp_log_path=${ocp_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error
  ...  Capture Ocp Logs Du3  ocp_log_path=${ocp_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error
  ...  Capture Ocp Logs Du4  ocp_log_path=${ocp_log_dir}
  Execute Cmd On Pc  mkdir -p ${ocp_log_dir}/ocp_logs
  Execute Cmd On Pc  mv ${ocp_log_dir}/*_must-gather.tar.gz ${ocp_log_dir}/ocp_logs
  Execute Cmd On Pc  mv ${ocp_log_dir}/*_inspect.tar.gz ${ocp_log_dir}/ocp_logs
  Execute Cmd On Pc  mv ${ocp_log_dir}/*_journal.log ${ocp_log_dir}/ocp_logs

Stop To Capture CUDU Systemlog
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Download Syslog To Master Vcu  ${VCU_NAMESPACE}    ${btslog_dir}/VCU_syslog.zip
  Download Syslog To Master Vdu  ${VDU_NAMESPACE}    ${btslog_dir}/VDU_syslog.zip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  download_syslog_to_master_vdu2  ${VDU2_NAMESPACE}  ${btslog_dir}/VDU2_syslog.zip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  download_syslog_to_master_vdu3  ${VDU3_NAMESPACE}  ${btslog_dir}/VDU3_syslog.zip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  download_syslog_to_master_vdu4  ${VDU4_NAMESPACE}  ${btslog_dir}/VDU4_syslog.zip

_Stop To Monitor CPU Mem Aic
  Return From Keyword If  ${UTE_CPU_MEM_FLAG} is not ${True}
  ${status}  @{pids_sys}  Run Keyword And Ignore Error  Get Linux Process Id  cpu_stats
  FOR  ${pid}  IN  @{pids_sys}
    Run Keyword And Ignore Error  Kill Linux Process  ${pid}
  END
  @{pids_sys}  Get Linux Process Id  system_stats
  FOR  ${pid}  IN  @{pids_sys}
    Run Keyword And Ignore Error  Kill Linux Process  ${pid}
  END
  Run Keyword And Ignore Error  Execute Cmd On Pc  pwd


Stop To Capture Wireshark Log Vcu
  [Arguments]  ${tag}=${EMPTY}  ${decode_option}=${EMPTY}  ${pod_name}=cpif  ${teardown_flag}=${False}
  [Documentation]  download wireshark log from acitve cpif pod in cu, support redundant/multi-cpif deployment currently.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty | wireshark name |
    ...    | ${decode_option} | No   | empty | decode_option |
    ...    | ${pod_name}      | No   | cpif  |cpif/cpifa1/cpifa2/cpifa3 |
    ...
    ...    Examples:
    ...    | Stop To Capture Wireshark Log vCU | pod_name=cpifa1 |
    ...    | Stop To Capture Wireshark Log vCU | ue_attach | pod_name=cpifa1 |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  ${wireshark_pcap_name_cu}  Set Variable  cu_${pod_name}_${wireshark_name}
  ${wireshark_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Vcu  mkdir -p /tmp/${VCU_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Execute Cmd On Vcu  ls -ltr /tmp/${VCU_NAMESPACE}/tmp_wireshark/*.pcap
  # download last one wireshark if teardown_flag is True, used for TA framework in test teardown.
  ${ret_pcap_cu}  Run Keyword And Ignore Error  Download Wireshark Log To Master Vcu  pod_name=${pod_name}  container_name=nwmgmt
  ...  namespace=${VCU_NAMESPACE}  wireshark_name=${pod_name}_${wireshark_name}.pcap  log_dir_in_master=/tmp/${VCU_NAMESPACE}/tmp_wireshark
  ...  teardown=${teardown_flag}
  ${ret_cu}  Run Keyword And Ignore Error  Run Keyword If  ${teardown_flag} is ${False}  Get Wireshark From Vcu
  ...  /tmp/${VCU_NAMESPACE}/tmp_wireshark/${pod_name}_${wireshark_name}.pcap  ${wireshark_dir}/${wireshark_pcap_name_cu}.pcap
  ...  ELSE  Get Wireshark From Vcu
  ...  /tmp/${VCU_NAMESPACE}/tmp_wireshark/${ret_pcap_cu}[1]  ${wireshark_dir}/teardown_cu_${ret_pcap_cu}[1]
  ${decode_cmd_cu}   catenate
  ...  tshark -r ${wireshark_dir}/${wireshark_pcap_name_cu}.pcap -o ntrstr.defragment:TRUE ${decode_option}
  ...  -d tcp.port==${TCE_PORT},ntrstr -d tcp.port==${OMS_PORT},ntrstr -V
  ...  > ${SAVE_LOG_DIRECTORY}${/}${wireshark_pcap_name_cu}.txt
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Run Keyword If  "${ret_cu}[0]"=="PASS" and "${teardown_flag}"=="False"
  ...  Execute Cmd On Pc  ${decode_cmd_cu}

Stop To Capture Wireshark Log Vdu
  [Arguments]  ${tag}=${EMPTY}  ${decode_option}=${EMPTY}  ${pod_name}=cprt  ${teardown_flag}=${False}
  [Documentation]  download wireshark log from acitve cprt pod in du currently.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty | wireshark name |
    ...    | ${decode_option} | No   | empty | decode_option |
    ...    | ${pod_name}      | No   | cprt | pod name |
    ...
    ...    Examples:
    ...    | Stop To Capture Wireshark Log Vdu | pod_name=cprt |
    ...    | Stop To Capture Wireshark Log Vdu | ue_attach | pod_name=cprt |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  ${wireshark_pcap_name_du}  Set Variable  du_${pod_name}_${wireshark_name}
  ${wireshark_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Vdu  mkdir -p /tmp/${VDU_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Execute Cmd On Vdu  ls -ltr /tmp/${VDU_NAMESPACE}/tmp_wireshark/*.pcap
  # download last one wireshark if teardown_flag is True, used for TA framework in test teardown.
  ${ret_pcap_du}  Run Keyword And Ignore Error  Download Wireshark Log To Master Vdu  pod_name=${pod_name}  container_name=nwmgmt
  ...  namespace=${VDU_NAMESPACE}  wireshark_name=${pod_name}_${wireshark_name}.pcap  log_dir_in_master=/tmp/${VDU_NAMESPACE}/tmp_wireshark
  ...  teardown=${teardown_flag}
  ${ret_du}  Run Keyword And Ignore Error  Run Keyword If  ${teardown_flag} is ${False}  Get Wireshark From Vdu
  ...  /tmp/${VDU_NAMESPACE}/tmp_wireshark/${pod_name}_${wireshark_name}.pcap  ${wireshark_dir}/${wireshark_pcap_name_du}.pcap
  ...  ELSE  Get Wireshark From Vdu
  ...  /tmp/${VDU_NAMESPACE}/tmp_wireshark/${ret_pcap_du}[1]  ${wireshark_dir}/teardown_du_${ret_pcap_du}[1]
  ${decode_cmd_du}   catenate
  ...  tshark -r ${wireshark_dir}/${wireshark_pcap_name_du}.pcap -o ntrstr.defragment:TRUE ${decode_option}
  ...  -d tcp.port==${TCE_PORT},ntrstr -d tcp.port==${OMS_PORT},ntrstr -V  > ${SAVE_LOG_DIRECTORY}${/}${wireshark_pcap_name_du}.txt
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Run Keyword If  "${ret_du}[0]"=="PASS" and "${teardown_flag}"=="False"
  ...  Execute Cmd On Pc  ${decode_cmd_du}

Stop To Capture Wireshark Log Vdu2
  [Arguments]  ${tag}=${EMPTY}  ${decode_option}=${EMPTY}  ${pod_name}=cprt  ${teardown_flag}=${False}
  [Documentation]  download wireshark log from acitve cprt pod in du currently.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty | wireshark name |
    ...    | ${decode_option} | No   | empty | decode_option |
    ...    | ${pod_name}      | No   | cprt | pod name |
    ...
    ...    Examples:
    ...    | Stop To Capture Wireshark Log Vdu2 | pod_name=cprt |
    ...    | Stop To Capture Wireshark Log Vdu2 | ue_attach | pod_name=cprt |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  ${wireshark_pcap_name_du2}  Set Variable  du2_${pod_name}_${wireshark_name}
  ${wireshark_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Vdu2  mkdir -p /tmp/${VDU2_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Execute Cmd On Vdu2  ls -ltr /tmp/${VDU2_NAMESPACE}/tmp_wireshark/*.pcap
  # download last one wireshark if teardown_flag is True, used for TA framework in test teardown.
  ${ret_pcap_du2}  Run Keyword And Ignore Error  Download Wireshark Log To Master Vdu2  pod_name=${pod_name}  container_name=nwmgmt
  ...  namespace=${VDU2_NAMESPACE}  wireshark_name=${pod_name}_${wireshark_name}.pcap  log_dir_in_master=/tmp/${VDU2_NAMESPACE}/tmp_wireshark
  ...  teardown=${teardown_flag}
  ${ret_du2}  Run Keyword And Ignore Error  Run Keyword If  ${teardown_flag} is ${False}  Get Wireshark From Vdu2
  ...  /tmp/${VDU2_NAMESPACE}/tmp_wireshark/${pod_name}_${wireshark_name}.pcap  ${wireshark_dir}/${wireshark_pcap_name_du2}.pcap
  ...  ELSE  Get Wireshark From Vdu2
  ...  /tmp/${VDU2_NAMESPACE}/tmp_wireshark/${ret_pcap_du2}[1]  ${wireshark_dir}/teardown_du2_${ret_pcap_du2}[1]
  ${decode_cmd_du2}   catenate
  ...  tshark -r ${wireshark_dir}/${wireshark_pcap_name_du2}.pcap -o ntrstr.defragment:TRUE ${decode_option}
  ...  -d tcp.port==${TCE_PORT},ntrstr -d tcp.port==${OMS_PORT},ntrstr -V  > ${SAVE_LOG_DIRECTORY}${/}${wireshark_pcap_name_du2}.txt
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Run Keyword If  "${ret_du2}[0]"=="PASS" and "${teardown_flag}"=="False"
  ...  Execute Cmd On Pc  ${decode_cmd_du2}

Stop To Capture Wireshark Log Vdu3
  [Arguments]  ${tag}=${EMPTY}  ${decode_option}=${EMPTY}  ${pod_name}=cprt  ${teardown_flag}=${False}
  [Documentation]  download wireshark log from acitve cprt pod in du currently.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty | wireshark name |
    ...    | ${decode_option} | No   | empty | decode_option |
    ...    | ${pod_name}      | No   | cprt | pod name |
    ...
    ...    Examples:
    ...    | Stop To Capture Wireshark Log Vdu3 | pod_name=cprt |
    ...    | Stop To Capture Wireshark Log Vdu3 | ue_attach | pod_name=cprt |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  ${wireshark_pcap_name_du3}  Set Variable  du3_${pod_name}_${wireshark_name}
  ${wireshark_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Vdu3  mkdir -p /tmp/${VDU3_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Execute Cmd On Vdu3  ls -ltr /tmp/${VDU3_NAMESPACE}/tmp_wireshark/*.pcap
  # download last one wireshark if teardown_flag is True, used for TA framework in test teardown.
  ${ret_pcap_du3}  Run Keyword And Ignore Error  Download Wireshark Log To Master Vdu3  pod_name=${pod_name}  container_name=nwmgmt
  ...  namespace=${VDU3_NAMESPACE}  wireshark_name=${pod_name}_${wireshark_name}.pcap  log_dir_in_master=/tmp/${VDU3_NAMESPACE}/tmp_wireshark
  ...  teardown=${teardown_flag}
  ${ret_du3}  Run Keyword And Ignore Error  Run Keyword If  ${teardown_flag} is ${False}  Get Wireshark From Vdu3
  ...  /tmp/${VDU3_NAMESPACE}/tmp_wireshark/${pod_name}_${wireshark_name}.pcap  ${wireshark_dir}/${wireshark_pcap_name_du3}.pcap
  ...  ELSE  Get Wireshark From Vdu3
  ...  /tmp/${VDU3_NAMESPACE}/tmp_wireshark/${ret_pcap_du3}[1]  ${wireshark_dir}/teardown_du3_${ret_pcap_du3}[1]
  ${decode_cmd_du3}   catenate
  ...  tshark -r ${wireshark_dir}/${wireshark_pcap_name_du3}.pcap -o ntrstr.defragment:TRUE ${decode_option}
  ...  -d tcp.port==${TCE_PORT},ntrstr -d tcp.port==${OMS_PORT},ntrstr -V  > ${SAVE_LOG_DIRECTORY}${/}${wireshark_pcap_name_du3}.txt
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Run Keyword If  "${ret_du3}[0]"=="PASS" and "${teardown_flag}"=="False"
  ...  Execute Cmd On Pc  ${decode_cmd_du3}

Stop To Capture Wireshark Log Vdu4
  [Arguments]  ${tag}=${EMPTY}  ${decode_option}=${EMPTY}  ${pod_name}=cprt  ${teardown_flag}=${False}
  [Documentation]  download wireshark log from acitve cprt pod in du currently.
    ...
    ...    | Input Parameters | Man. | Default | Description |
    ...    | ${tag}           | No   | empty | wireshark name |
    ...    | ${decode_option} | No   | empty | decode_option |
    ...    | ${pod_name}      | No   | cprt | pod name |
    ...
    ...    Examples:
    ...    | Stop To Capture Wireshark Log Vdu4 | pod_name=cprt |
    ...    | Stop To Capture Wireshark Log Vdu4 | ue_attach | pod_name=cprt |
  Return From Keyword If  ${WIRESHARK_FLAG} is not ${True}
  ${wireshark_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  wireshark  wireshark_${tag}
  ${wireshark_pcap_name_du4}  Set Variable  du4_${pod_name}_${wireshark_name}
  ${wireshark_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Vdu4  mkdir -p /tmp/${VDU4_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Execute Cmd On Vdu4  ls -ltr /tmp/${VDU4_NAMESPACE}/tmp_wireshark/*.pcap
  # download last one wireshark if teardown_flag is True, used for TA framework in test teardown.
  ${ret_pcap_du4}  Run Keyword And Ignore Error  Download Wireshark Log To Master Vdu4  pod_name=${pod_name}  container_name=nwmgmt
  ...  namespace=${VDU4_NAMESPACE}  wireshark_name=${pod_name}_${wireshark_name}.pcap  log_dir_in_master=/tmp/${VDU4_NAMESPACE}/tmp_wireshark
  ...  teardown=${teardown_flag}
  ${ret_du4}  Run Keyword And Ignore Error  Run Keyword If  ${teardown_flag} is ${False}  Get Wireshark From Vdu4
  ...  /tmp/${VDU4_NAMESPACE}/tmp_wireshark/${pod_name}_${wireshark_name}.pcap  ${wireshark_dir}/${wireshark_pcap_name_du4}.pcap
  ...  ELSE  Get Wireshark From Vdu4
  ...  /tmp/${VDU4_NAMESPACE}/tmp_wireshark/${ret_pcap_du4}[1]  ${wireshark_dir}/teardown_du4_${ret_pcap_du4}[1]
  ${decode_cmd_du4}   catenate
  ...  tshark -r ${wireshark_dir}/${wireshark_pcap_name_du4}.pcap -o ntrstr.defragment:TRUE ${decode_option}
  ...  -d tcp.port==${TCE_PORT},ntrstr -d tcp.port==${OMS_PORT},ntrstr -V  > ${SAVE_LOG_DIRECTORY}${/}${wireshark_pcap_name_du4}.txt
  run keyword if  not 'startup' in '${tag}'  Run Keyword And Ignore Error  Run Keyword If  "${ret_du4}[0]"=="PASS" and "${teardown_flag}"=="False"
  ...  Execute Cmd On Pc  ${decode_cmd_du4}

Stop Capture Wireshark Log Aic
  [Arguments]  ${tag}=${EMPTY}  ${decode_option}=${EMPTY}  ${teardown_flag}=${False}
  Stop To Capture Wireshark Log Vcu  tag=${tag}  decode_option=${decode_option}  teardown_flag=${teardown_flag}
  Run Keyword If  ${MULTI_CPIF_FLAG} is ${True}  Stop To Capture Wireshark Log Vcu
  ...  tag=${tag}  decode_option=${decode_option}.  pod_name=cpifa1  teardown_flag=${teardown_flag}
  Run Keyword If  ${MULTI_CPIF_FLAG} is ${True}  Stop To Capture Wireshark Log Vcu
  ...  tag=${tag}  decode_option=${decode_option}  pod_name=cpifa2  teardown_flag=${teardown_flag}
  Run Keyword If  ${MULTI_CPIF_FLAG} is ${True}  Stop To Capture Wireshark Log Vcu
  ...  tag=${tag}  decode_option=${decode_option}  pod_name=cpifa3  teardown_flag=${teardown_flag}
  Stop To Capture Wireshark Log Vdu  tag=${tag}  decode_option=${decode_option}  teardown_flag=${teardown_flag}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Stop To Capture Wireshark Log Vdu2
  ...  tag=${tag}  decode_option=${decode_option}  teardown_flag=${teardown_flag}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Stop To Capture Wireshark Log Vdu3
  ...  tag=${tag}  decode_option=${decode_option}  teardown_flag=${teardown_flag}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Stop To Capture Wireshark Log Vdu4
  ...  tag=${tag}  decode_option=${decode_option}  teardown_flag=${teardown_flag}

_Copy Config Files To Log Dir Aic
  [Arguments]  ${tag}=${EMPTY}
  ${target_dir}  set variable if  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs/config  ${SAVE LOG DIRECTORY}/config
  Execute Cmd On Pc  mkdir -p ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Copy File  ${SUITE_LOG_DIRECTORY}/scf_for_startup_cu.xml  ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Copy File  ${SUITE_LOG_DIRECTORY}/scf_for_startup_du.xml  ${target_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword If  'startup' in '${tag}'  Copy File
  ...  ${SUITE_LOG_DIRECTORY}/scf_for_startup_du2.xml  ${target_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword If  'startup' in '${tag}'  Copy File
  ...  ${SUITE_LOG_DIRECTORY}/scf_for_startup_du3.xml  ${target_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword If  'startup' in '${tag}'  Copy File
  ...  ${SUITE_LOG_DIRECTORY}/scf_for_startup_du4.xml  ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Get Cu Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/scf_after_test_cu.xml
  ...  ELSE  Get Cu Scf  scf_tar_path=${SAVE LOG DIRECTORY}/scfc_logs/scf_after_test_cu.xml
  Run Keyword If  'startup' in '${tag}'  Get Du Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_test_du.xml
  ...  ELSE  Get Du Scf  scf_tar_path=${SAVE LOG DIRECTORY}/scfc_logs/  scf_file_name=scf_after_test_du.xml
  Run Keyword If  'startup' in '${tag}'  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...  Get Du2 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_test_du2.xml
  Run Keyword If  'startup' in '${tag}'  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...  Get Du3 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_test_du3.xml
  Run Keyword If  'startup' in '${tag}'  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...  Get Du4 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/${tag}_logs/scfc_logs/  scf_file_name=scf_after_test_du4.xml
  run keyword if  not 'startup' in '${tag}'  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...  Get Du2 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/scfc_logs/  scf_file_name=scf_after_test_du2.xml
  run keyword if  not 'startup' in '${tag}'  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...  Get Du3 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/scfc_logs/  scf_file_name=scf_after_test_du3.xml
  run keyword if  not 'startup' in '${tag}'  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...  Get Du4 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/scfc_logs/  scf_file_name=scf_after_test_du4.xml
  Copy File  ${SUITE_LOG_DIRECTORY}/swconfig_modified.txt  ${target_dir}/gnb_swconfig.txt
  Copy File  ${SUITE_LOG_DIRECTORY}/vendor_modified.xml  ${target_dir}/vendor.xml


##below kw inherit from 5g classical
Compress Directory Aic
  [Arguments]  ${directory}
  ${directory}  Set Variable If  ${directory.endswith("/")}  ${directory[:-1]}  ${directory}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cd ${directory}/../; zip -r ${directory}.zip ${directory.split("/")[-1]};cd ~  timeout=300
  ${zip_status}  run keyword and return status  file should exist  ${directory}.zip
  Run Keyword And Ignore Error  Run Keyword If  ${zip_status}  Remove Directory  ${directory}  ${True}

_Retry To Start Aic
  ${onair_status}  Set Variable  ${False}
  FOR  ${retry}  IN RANGE  ${BTS_STARTUP_RETRY}
    BuiltIn.Log To Console  ===start bts for ${${retry}+2}nd time===
    ${onair_status}  Set Variable  ${False}
    Start To Capture Logs Aic  startup_${${retry}+2}
    Restart GNB Until SSH OK Aic
    Check Cpif And Capture Wireshark Vcu  startup_${${retry}+2}
    Run Keyword And Ignore Error  Check All Pods Is Running
    Start To Capture Wireshark Log Vdu  startup_${${retry}+2}
    Run Keyword And Ignore Error  Run Keyword If  '${EMIL_FLAG}' == '${True}'  Start To Capture Emil Log Aic
    Run Keyword And Ignore Error  Run Keyword If  '${AP_BIP_FLAG}' == '${True}'  Start To Capture AP BIP Log Aic  startup_${${retry}+2}
    ${onair_status}  wait_bts_onair_aic
    Collect Logs For Startup Aic  startup_${${retry}+2}  ${onair_status}
    Exit For Loop If  ${onair_status}
  END
  run keyword if  not ${onair_status}  Fail  BTS fail to startup

Restart GNB Until SSH OK Aic
  Restart Aic
  Log To Console With Time Prefix  step: wait GNB SSH connected
  # add sleep for avoiding endless ping try.
  sleep  30s
  Run Keyword And Ignore Error  Make Sure Aic SSH OK

Common Suite Teardown And Restore BTS Configuration Parameters Aic
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Collect CU/DU Logs in BTS
  ##need check at Aic later, exist vendor but need re-deploy aic***
#  Recover Vendor Parameters
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Recover Vendor Parameters Of ENB2
  Common Suite Teardown Aic

Common Suite Teardown Aic
  Run Keyword And Ignore Error  Teardown All Alias For Admin Aic
  Run Keyword And Ignore Error  Teardown All Aliases For Enb Fsmaccess
  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If All Tests Passed  Remove Directory  ${SUITE_LOG_DIRECTORY}  ${True}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Execute Cmd On Pc Enb2  rm -rf ${SUITE_LOG_DIRECTORY}  600
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep CM_EXECUTION_ID
  Run Keyword And Ignore Error  Execute Cmd On Pc  rm -rf /home/ute/scf_* /home/ute/gnb*/scf_*
#  Run Keyword And Ignore Error  Suite Teardown Report Rep Aic  ${OUTPUT FILE}  ${MANUAL_AUTO_REPORT_AIC}

Common Test Setup And Start To Capture Logs Aic
  Common Test Setup Aic
  Run Keyword And Ignore Error  Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Aic
  Start To Capture Logs Aic
  Get Initial Active Faults
  ${case_begin_time}  Get Current Aic Time
  Set Test Variable  \${case_begin_time}
  robot_common_operations.Common Case Setup  allowed_faults_ids=${Allowed_Faults_Ids_AiC}

Common Test Setup Aic
  _Create Test Log Directory Aic

Collect CU/DU Logs in BTS
  Run Keyword If  '${STARTUP_LOG_FLAG}' == '${True}'  Collect All Startup Log
  Run Keyword If  '${JOURNAL_FLAG}' == '${True}'  Collect All journal Log
  Run Keyword If  '${COREDUMP_FLAG}' == '${True}'  Collect Coredump Log

_Create Test Log Directory Aic
  ${TEST_LOG_DIR}  Catenate  SEPARATOR=  ${SUITE_LOG_DIRECTORY}  ${TEST_NAME[:50]}
  ${TEST_LOG_DIR}  Replace String  ${TEST_LOG_DIR}  ${SPACE}  _
#  ${TEST_LOG_DIR}  Replace String  ${TEST_LOG_DIR}  -  _
  Create Directory  ${TEST_LOG_DIR}
  Set Suite Variable  ${TEST_LOG_DIR}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${TEST_LOG_DIR}

Common Test Teardown And Stop Capture Logs Aic
  Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Aic
  Check No New Active Faults
  Common Test Teardown Aic
  Run Keyword If Test Failed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['fail']}
  Run Keyword If Test Passed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['pass']}
  Set Suite Variable  ${SOS_REPORT_FLAG_WORK}
  Stop Capture Logs Aic
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir Aic
  ## Analyze Logs need further adapt later***
  Analyze Logs  test_status=${TEST_STATUS}
  Run Keyword And Ignore Error  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If Test Passed
  ...  Remove Directory  ${SAVE LOG DIRECTORY}  ${True}
  Run Keyword If  '${REMOVE_LOGS}'=='off'  Compress Directory Aic  ${SAVE LOG DIRECTORY}
#  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error
#  ...  Execute Cmd On Pc Gnb2  rm -rf ${SAVE LOG DIRECTORY}  600
  robot_common_operations.Common Case Teardown
  CI_interface.Common Case Teardown

Common Test Teardown Aic
  Run Keyword If Test Failed  Run Keyword If  '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Check Current Pod Status And Oamext Pod Running In Aic
  Run Keyword If Test passed  Run Keyword If  '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Check Current Pod Status And Oamext Pod Running In Aic
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Collect Snapshot Gnb1
  run keyword if test passed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Collect Snapshot Gnb1
#  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If
#  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG}'=='${True}'  Collect Snapshot Enb2
#  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'
#  ...  Collect Scf  ${SAVE LOG DIRECTORY}${/}${GNB2_ALIAS}${/}scf_after_test.xml
#  ...  export_type=configurationAndRuntimeObjects
#  ...  alias=${GNB2_ALIAS}

Check Current Pod Status In Aic
  Run Keyword And Ignore Error  Check Current Pod Status In Cu  ${VCU_NAMESPACE}
  Run Keyword And Ignore Error  Check Current Pod Status In Du  ${VDU_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Check Current Pod Status In Du2  ${VDU2_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Check Current Pod Status In Du3  ${VDU3_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Check Current Pod Status In Du4  ${VDU4_NAMESPACE}

Check Current Oamext Pod Running In Aic
  [Documentation]  check current oamext pod and wait it to running status until 5min timeout
  Run Keyword And Ignore Error  Check Single Pod Running Vcu  ${VCU_NAMESPACE}  oamext
  Run Keyword And Ignore Error  Check Single Pod Running Vdu  ${VDU_NAMESPACE}  oamext
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Check Single Pod Running Vdu2
  ...  ${VDU2_NAMESPACE}  oamext
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Check Single Pod Running Vdu3
  ...  ${VDU3_NAMESPACE}  oamext
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Check Single Pod Running Vdu4
  ...  ${VDU4_NAMESPACE}  oamext

Check Current Pod Status And Oamext Pod Running In Aic
  Check Current Pod Status In Aic
  Check Current Oamext Pod Running In Aic

Stop To Capture GNB BIP Log Aic
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${GNB_BIP_FLAG} is not ${True}
  ${bip_log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs/gnb_bip_logs
  ...  ${SAVE LOG DIRECTORY}/gnb_bip_logs
  Execute Cmd On Pc   mkdir -p ${bip_log_dir}
  Run Keyword And Ignore Error  Stop To Collect BIP log On Du  ${VDU_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Stop To Collect BIP log On Du2  ${VDU2_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Stop To Collect BIP log On Du3  ${VDU3_NAMESPACE}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Stop To Collect BIP log On Du4  ${VDU4_NAMESPACE}
  Run Keyword And Ignore Error  Download Bip Log To Master Vdu  pod_name=l2rt  container_name=l2rt
  ...  namespace=${VDU_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword And Ignore Error  Download Bip Log To Master Vdu  pod_name=l2nrt  container_name=l2hi
  ...  namespace=${VDU_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Download Bip Log To Master Vdu2  pod_name=l2rt
  ...  container_name=l2rt  namespace=${VDU2_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Download Bip Log To Master Vdu2  pod_name=l2nrt
  ...  container_name=l2hi  namespace=${VDU2_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Download Bip Log To Master Vdu3  pod_name=l2rt
  ...  container_name=l2rt  namespace=${VDU3_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Download Bip Log To Master Vdu3  pod_name=l2nrt
  ...  container_name=l2hi  namespace=${VDU3_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Download Bip Log To Master Vdu4  pod_name=l2rt
  ...  container_name=l2rt  namespace=${VDU4_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Download Bip Log To Master Vdu4  pod_name=l2nrt
  ...  container_name=l2hi  namespace=${VDU4_NAMESPACE}  log_dir_in_master=/tmp/tmp_bip
  Run Keyword And Ignore Error  Get Bip Log Vdu    /tmp/tmp_bip/l1up.pcap    ${bip_log_dir}/
  Run Keyword And Ignore Error  Get Bip Log Vdu    /tmp/tmp_bip/l2biprt.pcap    ${bip_log_dir}/
  Run Keyword And Ignore Error  Get Bip Log Vdu    /tmp/tmp_bip/l2biphi.pcap    ${bip_log_dir}/
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Bip Log Vdu2    /tmp/tmp_bip/l1up.pcap    ${bip_log_dir}/l1up_du2.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Bip Log Vdu2    /tmp/tmp_bip/l2biprt.pcap    ${bip_log_dir}/l2biprt_du2.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Bip Log Vdu2    /tmp/tmp_bip/l2biphi.pcap    ${bip_log_dir}/l2biphi_du2.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Bip Log Vdu3    /tmp/tmp_bip/l1up.pcap    ${bip_log_dir}/l1up_du3.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Bip Log Vdu3    /tmp/tmp_bip/l2biprt.pcap    ${bip_log_dir}/l2biprt_du3.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Bip Log Vdu3    /tmp/tmp_bip/l2biphi.pcap    ${bip_log_dir}/l2biphi_du3.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Bip Log Vdu4    /tmp/tmp_bip/l1up.pcap    ${bip_log_dir}/l1up_du4.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Bip Log Vdu4    /tmp/tmp_bip/l2biprt.pcap    ${bip_log_dir}/l2biprt_du4.pcap
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Bip Log Vdu4    /tmp/tmp_bip/l2biphi.pcap    ${bip_log_dir}/l2biphi_du4.pcap
  Run Keyword And Ignore Error  Execute Cmd On Vdu  rm -rf /tmp/tmp_bip/l1up* /tmp/tmp_bip/l2biprt* /tmp/tmp_bip/l2biphi*
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Execute Cmd On Vdu2
  ...    rm -rf /tmp/tmp_bip/l1up* /tmp/tmp_bip/l2biprt* /tmp/tmp_bip/l2biphi*
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Execute Cmd On Vdu3
  ...    rm -rf /tmp/tmp_bip/l1up* /tmp/tmp_bip/l2biprt* /tmp/tmp_bip/l2biphi*
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Execute Cmd On Vdu4
  ...    rm -rf /tmp/tmp_bip/l1up* /tmp/tmp_bip/l2biprt* /tmp/tmp_bip/l2biphi*

Set Debug Log Level For CU Component
  [Documentation]  This keyword deprecated.
  Run Keyword And Ignore Error  Set Debug Log In Cpif  ${VCU_NAMESPACE}
  Run Keyword And Ignore Error  Set Debug Log In Cpnb  ${VCU_NAMESPACE}
  Run Keyword And Ignore Error  Set Debug Log In Cpue  ${VCU_NAMESPACE}
  Run Keyword And Ignore Error  Set Debug Log In Cpcl  ${VCU_NAMESPACE}

Get Aic Config Ip And Account Info For Vcu And Vdu
  Get Aic Config Ip And Account Info For Vcu
  Get Aic Config Ip And Account Info For Vdu
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Aic Config Ip And Account Info For Vdu2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Aic Config Ip And Account Info For Vdu3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Aic Config Ip And Account Info For Vdu4

Get Aic Config Ip And Account Info For Vcu
  set suite variable  ${VCU_NAMESPACE}  ${tl.gnbs[${0}].cloud_deployment.cloud_hosting.namespace}
  set suite variable  ${VCU_SSH_IP}  ${tl.gnbs[${0}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
  set suite variable  ${VCU_SSH_USER}  ${tl.gnbs[${0}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
  set suite variable  ${VCU_SSH_PASSWD}  ${tl.gnbs[${0}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
  set suite variable  ${VCU_IP}  ${tl.gnbs[${0}].cu.oam_http_connection_details.addr}

Get Aic Config Ip And Account Info For Vdu
  set suite variable  ${VDU_NAMESPACE}  ${tl.gnbs[${0}].dus[${0}].cloud_deployment.cloud_hosting.namespace}
  set suite variable  ${VDU_SSH_IP}  ${tl.gnbs[${0}].dus[${0}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
  set suite variable  ${VDU_SSH_USER}  ${tl.gnbs[${0}].dus[${0}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
  set suite variable  ${VDU_SSH_PASSWD}  ${tl.gnbs[${0}].dus[${0}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
  set suite variable  ${VDU_IP}  ${tl.gnbs[${0}].dus[${0}].oam_http_connection_details.addr}
  Run Keyword And Ignore Error  Run Keyword If  '${DU_NUMBER}'=='du'  set suite variable  ${VDU_FHM_VLAN}  ${tl.ues[${0}].preferred_vlan_id}
  Run Keyword And Ignore Error  Run Keyword If  '${VDU_FHM_VLAN}'=='None' and '${DU_NUMBER}'=='du'  set suite variable
  ...  ${VDU_FHM_VLAN}  ${tl.ues[${0}].preferred_vlans[${0}].preferred_vlan_id}
  Run Keyword And Ignore Error  set suite variable  ${VDU_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].product_code}
  Run Keyword And Ignore Error  set suite variable  ${VDU_RANNIC2_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${0}].rannics[${1}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU_RANNIC2_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${0}].rannics[${1}].product_code}
  Run Keyword And Ignore Error  set suite variable  ${UTF_PC_IP}  ${tl.test_pcs[1].default_ssh_connection_details.addr}

Get Aic Config Ip And Account Info For Vdu2
  set suite variable  ${VDU2_NAMESPACE}  ${tl.gnbs[${0}].dus[${1}].cloud_deployment.cloud_hosting.namespace}
  set suite variable  ${VDU2_SSH_IP}  ${tl.gnbs[${0}].dus[${1}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
  set suite variable  ${VDU2_SSH_USER}  ${tl.gnbs[${0}].dus[${1}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
  set suite variable  ${VDU2_SSH_PASSWD}  ${tl.gnbs[${0}].dus[${1}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
  set suite variable  ${VDU2_IP}  ${tl.gnbs[${0}].dus[${1}].oam_http_connection_details.addr}
  Run Keyword And Ignore Error  set suite variable  ${VDU_FHM_VLAN}  ${tl.ues[${0}].preferred_vlans[${0}].preferred_vlan_id}
  Run Keyword And Ignore Error  set suite variable  ${VDU2_FHM_VLAN}  ${tl.ues[${0}].preferred_vlans[${1}].preferred_vlan_id}
  Run Keyword And Ignore Error  set suite variable  ${VDU2_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${1}].rannics[${0}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU2_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${1}].rannics[${0}].product_code}
  Run Keyword And Ignore Error  set suite variable  ${VDU2_RANNIC2_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${1}].rannics[${1}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU2_RANNIC2_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${1}].rannics[${1}].product_code}

Get Aic Config Ip And Account Info For Vdu3
  set suite variable  ${VDU3_NAMESPACE}  ${tl.gnbs[${0}].dus[${2}].cloud_deployment.cloud_hosting.namespace}
  set suite variable  ${VDU3_SSH_IP}  ${tl.gnbs[${0}].dus[${2}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
  set suite variable  ${VDU3_SSH_USER}  ${tl.gnbs[${0}].dus[${2}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
  set suite variable  ${VDU3_SSH_PASSWD}  ${tl.gnbs[${0}].dus[${2}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
  set suite variable  ${VDU3_IP}  ${tl.gnbs[${0}].dus[${2}].oam_http_connection_details.addr}
  Run Keyword And Ignore Error  set suite variable  ${VDU3_FHM_VLAN}  ${tl.ues[${0}].preferred_vlans[${2}].preferred_vlan_id}
  Run Keyword And Ignore Error  set suite variable  ${VDU3_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${2}].rannics[${0}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU3_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${2}].rannics[${0}].product_code}
  Run Keyword And Ignore Error  set suite variable  ${VDU3_RANNIC2_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${2}].rannics[${1}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU3_RANNIC2_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${2}].rannics[${1}].product_code}

Get Aic Config Ip And Account Info For Vdu4
  set suite variable  ${VDU4_NAMESPACE}  ${tl.gnbs[${0}].dus[${3}].cloud_deployment.cloud_hosting.namespace}
  set suite variable  ${VDU4_SSH_IP}  ${tl.gnbs[${0}].dus[${3}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
  set suite variable  ${VDU4_SSH_USER}  ${tl.gnbs[${0}].dus[${3}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
  set suite variable  ${VDU4_SSH_PASSWD}  ${tl.gnbs[${0}].dus[${3}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
  set suite variable  ${VDU4_IP}  ${tl.gnbs[${0}].dus[${3}].oam_http_connection_details.addr}
  Run Keyword And Ignore Error  set suite variable  ${VDU4_FHM_VLAN}  ${tl.ues[${0}].preferred_vlans[${3}].preferred_vlan_id}
  Run Keyword And Ignore Error  set suite variable  ${VDU4_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${3}].rannics[${0}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU4_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${3}].rannics[${0}].product_code}
  Run Keyword And Ignore Error  set suite variable  ${VDU4_RANNIC2_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${3}].rannics[${1}].serial_number}
  Run Keyword And Ignore Error  set suite variable  ${VDU4_RANNIC2_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${3}].rannics[${1}].product_code}

Get_Ngc_F1c_Xnc_Ip_With_Fhuc_Vlan
  [Arguments]  ${tl_type}
  # Not need get Xnc_IP/F1c_IP/Ngc_IPdue to current all TL align UTE standard
  Run Keyword If  '${tl_type}'=='tdd_sansa_cmwv/FS/1du/2cell' or '${tl_type}'=='fdd_sa_cmwv/FS/1du/2cell'  set suite variable  ${VDU_FHUC_VLAN1}
  ...  ${tl.gnbs[${0}].dus[${0}].fhuc_vlans[0]}  ELSE  set suite variable  ${VDU_FHUC_VLAN1}  None
  Run Keyword If  '${tl_type}'=='tdd_sansa_cmwv/FS/1du/2cell' or '${tl_type}'=='fdd_sa_cmwv/FS/1du/2cell'  set suite variable  ${VDU_FHUC_VLAN2}
  ...  ${tl.gnbs[${0}].dus[${0}].fhuc_vlans[1]}  ELSE  set suite variable  ${VDU_FHUC_VLAN2}  None

Check All Pods Is Running
  [Arguments]  ${interrupt_once_fail}=${False}
  [Documentation]  This keyword check all pod if running.
    ...
    ...    | Input Parameters     |  Man | Description |
    ...    | interrupt_once_fail  |  No  | kw will fail once exist pod is not running status (default is False)|
  Wait All Pods Running Vcu  ${VCU_NAMESPACE}  ${interrupt_once_fail}
  Wait All Pods Running Vdu  ${VDU_NAMESPACE}  ${interrupt_once_fail}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Wait All Pods Running Vdu2  ${VDU2_NAMESPACE}  ${interrupt_once_fail}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Wait All Pods Running Vdu3  ${VDU3_NAMESPACE}  ${interrupt_once_fail}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Wait All Pods Running Vdu4  ${VDU4_NAMESPACE}  ${interrupt_once_fail}

Restart Pod And Check All Pod Is Running In Aic vCU
  [Documentation]  This keyword need input brief pod_name like as "cpif/cpcl/cpnb/cpnrt/cpue/upue".
  [Arguments]  ${pod_name}
  Restart Pod In Vcu Aic  ${pod_name}  ${VCU_NAMESPACE}
  Wait All Pods Running Vcu  ${VCU_NAMESPACE}

Restart Pod And Check All Pod Is Running In Aic vDU
  [Documentation]  This keyword need input brief pod_name like as "cprt/up".
  [Arguments]  ${pod_name}
  Restart Pod In Vdu Aic  ${pod_name}  ${VDU_NAMESPACE}
  Wait All Pods Running Vdu  ${VDU_NAMESPACE}

Restart Pod And Check All Pod Is Running In Aic vDU2
  [Arguments]  ${pod_name}
  Restart Pod In Vdu2 Aic  ${pod_name}  ${VDU2_NAMESPACE}
  Wait All Pods Running Vdu2  ${VDU2_NAMESPACE}

Restart Pod And Check All Pod Is Running In Aic vDU3
  [Arguments]  ${pod_name}
  Restart Pod In Vdu3 Aic  ${pod_name}  ${VDU3_NAMESPACE}
  Wait All Pods Running Vdu3  ${VDU3_NAMESPACE}

Restart Pod And Check All Pod Is Running In Aic vDU4
  [Arguments]  ${pod_name}
  Restart Pod In Vdu4 Aic  ${pod_name}  ${VDU4_NAMESPACE}
  Wait All Pods Running Vdu4  ${VDU4_NAMESPACE}

Scale Pod In Aic Vcu
  [Arguments]  ${pod_name}  ${number}
  [Documentation]  This keyword need input brief pod_name like as "cpue/upue".
    ...  like as: "kubectl scale --replicas=${number} statefulset/po-tl123-cpue -n tl123"
    ...
    ...    | Input Parameters | Man | Description |
    ...    | pod_name |  Yes  | cpue/upue/... |
    ...    | number |  Yes  | 1/2/3/... |
  Scale Pod In Vcu  ${pod_name}  ${number}  ${VCU_NAMESPACE}

Scale Pod In Aic Vdu
  [Arguments]  ${pod_name}  ${number}
  [Documentation]  This keyword need input brief pod_name like as "cprt/up".
    ...  like as: "kubectl scale --replicas=${number} statefulset/po-tl123-cprt -n tl123"
    ...
    ...    | Input Parameters | Man | Description |
    ...    | pod_name |  Yes  | cpue/upue/... |
    ...    | number |  Yes  | 1/2/3/... |
  Scale Pod In Vdu  ${pod_name}  ${number}  ${VDU_NAMESPACE}

Scale Pod In Aic Vdu2
  [Arguments]  ${pod_name}  ${number}
  [Documentation]  This keyword need input brief pod_name like as "cprt/up". Same as Vdu
  Scale Pod In Vdu2  ${pod_name}  ${number}  ${VDU2_NAMESPACE}

Scale Pod In Aic Vdu3
  [Arguments]  ${pod_name}  ${number}
  [Documentation]  This keyword need input brief pod_name like as "cprt/up". Same as Vdu
  Scale Pod In Vdu3  ${pod_name}  ${number}  ${VDU3_NAMESPACE}

Scale Pod In Aic Vdu4
  [Arguments]  ${pod_name}  ${number}
  [Documentation]  This keyword need input brief pod_name like as "cprt/up". Same as Vdu
  Scale Pod In Vdu4  ${pod_name}  ${number}  ${VDU4_NAMESPACE}

Find Pod Fullname In Aic vCU
  [Documentation]  This keyword need input brief pod_name like as "cpue/upue".
  [Arguments]  ${pod_name}
  ${pod_full_name_in_vCU}  Find Pod Fullname Cu  ${pod_name}  ${VCU_NAMESPACE}
  [Return]  ${pod_full_name_in_vCU}

Find Pod Fullname In Aic vDU
  [Documentation]  This keyword need input brief pod_name like as "cprt/up".
  [Arguments]  ${pod_name}
  ${pod_full_name_in_vDU}  Find Pod Fullname Du  ${pod_name}  ${VDU_NAMESPACE}
  [Return]  ${pod_full_name_in_vDU}

Find Pod Fullname In Aic vDU2
  [Documentation]  This keyword need input brief pod_name like as "cprt/up".
  [Arguments]  ${pod_name}
  ${pod_full_name_in_vDU2}  Find Pod Fullname Du2  ${pod_name}  ${VDU2_NAMESPACE}
  [Return]  ${pod_full_name_in_vDU2}

Find Pod Fullname In Aic vDU3
  [Documentation]  This keyword need input brief pod_name like as "cprt/up".
  [Arguments]  ${pod_name}
  ${pod_full_name_in_vDU3}  Find Pod Fullname Du3  ${pod_name}  ${VDU3_NAMESPACE}
  [Return]  ${pod_full_name_in_vDU3}

Find Pod Fullname In Aic vDU4
  [Documentation]  This keyword need input brief pod_name like as "cprt/up".
  [Arguments]  ${pod_name}
  ${pod_full_name_in_vDU4}  Find Pod Fullname Du4  ${pod_name}  ${VDU4_NAMESPACE}
  [Return]  ${pod_full_name_in_vDU4}

Find Container Fullname In Aic vCU
  [Documentation]  This keyword need input brief pod_name and container_name.
  ...  pod_name:  like as cpnrt/cpue/cpif/cpcl/cpnb/upue
  ...  container_name:  like as cpnrt/cpue/cpif/cpcl/cpnb/upue
  [Arguments]  ${pod_name}  ${container_name}
  ${container_full_name_in_vCU}  Find Container Fullname Cu  ${pod_name}  ${container_name}  ${VCU_NAMESPACE}
  [Return]  ${container_full_name_in_vCU}

Find Container Fullname In Aic vDU
  [Documentation]  This keyword need input brief pod_name and container_name.
  ...  pod_name:  like as cprt/up
  ...  container_name:  like as cprt/up
  [Arguments]  ${pod_name}  ${container_name}
  ${container_full_name_in_vDU}  Find Container Fullname Du  ${pod_name}  ${container_name}  ${VDU_NAMESPACE}
  [Return]  ${container_full_name_in_vDU}

Find Container Fullname In Aic vDU2
  [Documentation]  This keyword need input brief pod_name and container_name.
  ...  pod_name:  like as cprt/up
  ...  container_name:  like as cprt/up
  [Arguments]  ${pod_name}  ${container_name}
  ${container_full_name_in_vDU2}  Find Container Fullname Du2  ${pod_name}  ${container_name}  ${VDU2_NAMESPACE}
  [Return]  ${container_full_name_in_vDU2}

Find Container Fullname In Aic vDU3
  [Documentation]  This keyword need input brief pod_name and container_name.
  ...  pod_name:  like as cprt/up
  ...  container_name:  like as cprt/up
  [Arguments]  ${pod_name}  ${container_name}
  ${container_full_name_in_vDU3}  Find Container Fullname Du3  ${pod_name}  ${container_name}  ${VDU3_NAMESPACE}
  [Return]  ${container_full_name_in_vDU3}

Find Container Fullname In Aic vDU4
  [Documentation]  This keyword need input brief pod_name and container_name.
  ...  pod_name:  like as cprt/up
  ...  container_name:  like as cprt/up
  [Arguments]  ${pod_name}  ${container_name}
  ${container_full_name_in_vDU4}  Find Container Fullname Du4  ${pod_name}  ${container_name}  ${VDU4_NAMESPACE}
  [Return]  ${container_full_name_in_vDU4}

Pod Swap By Kill Active Pod Vcu
  [Arguments]  ${pod_name}
  [Documentation]  This keyword need input brif pod_name.
    ...
    ...    | Input Parameters  | Man.  | Default | Description |
    ...    | pod_name          | Yes   | cpif    | cpif/cpifa1/cpifa2/... |
  ${pod_full_name}  Find Pod Fullname In Aic vCU  ${pod_name}
  Execute Cmd On Vcu  kubectl delete pod ${pod_full_name} -n ${VCU_NAMESPACE}

Start To Capture Gnb Ttitrace
  [Arguments]  ${tag}
  Log  ${tag}
  Start To Capture Gnb Ttitrace Cu
  Start To Capture Gnb Ttitrace Du1
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Start To Capture Gnb Ttitrace Du2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Start To Capture Gnb Ttitrace Du3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Start To Capture Gnb Ttitrace Du4

Start To Capture Gnb Ttitrace Cu
  [Arguments]  ${trace_type}=${TTI_Trace_Type}  ${target_component}=l2hiPdcp  ${tti_tag}="default"
  [Documentation]    This keyword is to Capture Tti trace log
    ...
    ...    | Input Parameters  | Man | Default   | Description |
    ...    | target_component  | No  | l2hiPdcp  |(1st P is Capital) |
    ...    | trace_type        | No  | Component |Component/Sherpa |
  Return From Keyword If  ${TTITRACE_FLAG_CU} is not ${True}
  ${cu_trace_ret}  Run Keyword And Ignore Error  Start Tti Trace Cu  ${target_component}  ${trace_type}  ${tti_tag}
  Run Keyword And Ignore Error  Set Suite Variable  ${cu_trace_id}  ${cu_trace_ret}[1]

Start To Capture Gnb Ttitrace Du1
  [Arguments]  ${cell}=${TTI_Trace_Cell}  ${trace_type}=${TTI_Trace_Type}  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  [Documentation]    This keyword is to Capture Tti trace log
    ...
    ...    | Input Parameters  | Man.  | Default    | Description |
    ...    | target_component  | Yes   | All        | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
    ...    | cell              | Yes   | All        | cell id like as 1 |
    ...    | trace_type        | Yes   | Component  | Component/Sherpa  |
  Return From Keyword If  ${TTITRACE_FLAG_DU1} is not ${True}
  # no need iprt for cu routing
  #Delta Commission Parameters Du  ${TTI_TRACE_CONFIG_PARAMS_DU}
  ${du_trace_ret}  Run Keyword And Ignore Error  Start Tti Trace Du  ${cell}  ${target_component}  ${trace_type}  ${tti_tag}
  Run Keyword And Ignore Error  Set Suite Variable  ${du_trace_id}  ${du_trace_ret}[1]

Start To Capture Gnb Ttitrace Du2
  [Arguments]  ${cell}=${TTI_Trace_Cell}  ${trace_type}=${TTI_Trace_Type}  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  [Documentation]    This keyword is to Capture Tti trace log
    ...
    ...    | Input Parameters  | Man.  | Default    | Description |
    ...    | target_component  | Yes   | All        | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
    ...    | cell              | Yes   | All        | cell id like as 1 |
    ...    | trace_type        | Yes   | Component  | Component/Sherpa  |
  Return From Keyword If  ${TTITRACE_FLAG_DU2} is not ${True}
  # no need iprt for cu routing
  #Delta Commission Parameters Du2  ${TTI_TRACE_CONFIG_PARAMS_DU}
  ${du2_trace_ret}  Run Keyword And Ignore Error  Start Tti Trace Du2  ${cell}  ${target_component}  ${trace_type}  ${tti_tag}
  Run Keyword And Ignore Error  Set Suite Variable  ${du2_trace_id}  ${du2_trace_ret}[1]

Start To Capture Gnb Ttitrace Du3
  [Arguments]  ${cell}=${TTI_Trace_Cell}  ${trace_type}=${TTI_Trace_Type}  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  [Documentation]    This keyword is to Capture Tti trace log
    ...
    ...    | Input Parameters  | Man.  | Default    | Description |
    ...    | target_component  | Yes   | All        | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
    ...    | cell              | Yes   | All        | cell id like as 1 |
    ...    | trace_type        | Yes   | Component  | Component/Sherpa  |
  Return From Keyword If  ${TTITRACE_FLAG_DU3} is not ${True}
  # no need iprt for cu routing
  #Delta Commission Parameters Du3  ${TTI_TRACE_CONFIG_PARAMS_DU}
  ${du3_trace_ret}  Run Keyword And Ignore Error  Start Tti Trace Du3  ${cell}  ${target_component}  ${trace_type}  ${tti_tag}
  Run Keyword And Ignore Error  Set Suite Variable  ${du3_trace_id}  ${du3_trace_ret}[1]

Start To Capture Gnb Ttitrace Du4
  [Arguments]  ${cell}=${TTI_Trace_Cell}  ${trace_type}=${TTI_Trace_Type}  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  [Documentation]    This keyword is to Capture Tti trace log
    ...
    ...    | Input Parameters  | Man.  | Default    | Description |
    ...    | target_component  | Yes   | All        | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
    ...    | cell              | Yes   | All        | cell id like as 1 |
    ...    | trace_type        | Yes   | Component  | Component/Sherpa  |
  Return From Keyword If  ${TTITRACE_FLAG_DU4} is not ${True}
  # no need iprt for cu routing
  #Delta Commission Parameters Du4  ${TTI_TRACE_CONFIG_PARAMS_DU}
  ${du4_trace_ret}  Run Keyword And Ignore Error  Start Tti Trace Du4  ${cell}  ${target_component}  ${trace_type}  ${tti_tag}
  Run Keyword And Ignore Error  Set Suite Variable  ${du4_trace_id}  ${du4_trace_ret}[1]

Stop Capture Gnb TTITrace
  [Arguments]  ${tag}
  Log  ${tag}
  Stop Capture Gnb TTITrace Cu
  Stop Capture Gnb TTITrace Du1
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Stop Capture Gnb TTITrace Du2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Stop Capture Gnb TTITrace Du3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Stop Capture Gnb TTITrace Du4

Stop Capture Gnb TTITrace Cu
  [Arguments]  ${tti_tag}="default"
  Return From Keyword If  ${TTITRACE_FLAG_CU} is not ${True}
  Run Keyword And Ignore Error  Stop Tti Trace Cu  ${cu_trace_id}  ${tti_tag}
#  Run Keyword If  "${TTITRACE_FLAG_CU}" == "True" and "${TTITRACE_FLAG_DU1}" == "False" and "${TTITRACE_FLAG_DU2}" == "False"
#  ...  Run Keyword And Ignore Error  Decode Tti Trace Cu

Stop Capture Gnb TTITrace Du1
  [Arguments]  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  Return From Keyword If  ${TTITRACE_FLAG_DU1} is not ${True}
  Run Keyword And Ignore Error  Stop Tti Trace Du  ${du_trace_id}  ${target_component}  ${tti_tag}
#  Run Keyword And Ignore Error  Decode Tti Trace Du

Stop Capture Gnb TTITrace Du2
  [Arguments]  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  Return From Keyword If  ${TTITRACE_FLAG_DU2} is not ${True}
  Run Keyword And Ignore Error  Stop Tti Trace Du2  ${du2_trace_id}  ${target_component}  ${tti_tag}
#  Run Keyword And Ignore Error  Decode Tti Trace Du2

Stop Capture Gnb TTITrace Du3
  [Arguments]  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  Return From Keyword If  ${TTITRACE_FLAG_DU3} is not ${True}
  Run Keyword And Ignore Error  Stop Tti Trace Du3  ${du3_trace_id}  ${target_component}  ${tti_tag}
#  Run Keyword And Ignore Error  Decode Tti Trace Du3

Stop Capture Gnb TTITrace Du4
  [Arguments]  ${target_component}=${TTI_Target_Component}  ${tti_tag}="default"
  Return From Keyword If  ${TTITRACE_FLAG_DU4} is not ${True}
  Run Keyword And Ignore Error  Stop Tti Trace Du4  ${du4_trace_id}  ${target_component}  ${tti_tag}
#  Run Keyword And Ignore Error  Decode Tti Trace Du4

Start To Capture Emil Log Aic
  [Documentation]    dcap can't capture in vcu and vdu simutaneously currently.
  Execute Cmd On Pc  sudo rm -rf /home/sharedvolume/trace_results/*
  Run Keyword And Ignore Error  Start To Capture Emil Log In Vcu
  Run Keyword And Ignore Error  Start To Capture Emil Log In Vdu
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error  Start To Capture Emil Log In Vdu2
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error  Start To Capture Emil Log In Vdu3
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error  Start To Capture Emil Log In Vdu4

Start To Capture Emil Log In Vcu
  Disable Tls For Dcap Connect Cu  ${VCU_NAMESPACE}
  ${cu_emil_trace_id}  Start Capture Emil Log Aic Cu
  Set Suite Variable  ${cu_emil_trace_id}

Start To Capture Emil Log In Vdu
  Disable Tls For Dcap Connect Du  ${VDU_NAMESPACE}
  ${du_emil_trace_id}  Start Capture Emil Log Aic Du
  Set Suite Variable  ${du_emil_trace_id}

Start To Capture Emil Log In Vdu2
  Disable Tls For Dcap Connect Du2  ${VDU2_NAMESPACE}
  ${du2_emil_trace_id}  Start Capture Emil Log Aic Du2
  Set Suite Variable  ${du2_emil_trace_id}

Start To Capture Emil Log In Vdu3
  Disable Tls For Dcap Connect Du3  ${VDU3_NAMESPACE}
  ${du3_emil_trace_id}  Start Capture Emil Log Aic Du3
  Set Suite Variable  ${du3_emil_trace_id}

Start To Capture Emil Log In Vdu4
  Disable Tls For Dcap Connect Du4  ${VDU4_NAMESPACE}
  ${du4_emil_trace_id}  Start Capture Emil Log Aic Du4
  Set Suite Variable  ${du4_emil_trace_id}

Stop To Capture Emil Log Aic
  [Arguments]  ${tag}=${EMPTY}
  ${emil_log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Stop Capture Emil Log Aic Cu  ${cu_emil_trace_id}  ${emil_log_dir}
  Run Keyword And Ignore Error  Stop Capture Emil Log Aic Du  ${du_emil_trace_id}  ${emil_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Run Keyword And Ignore Error
  ...  Stop Capture Emil Log Aic Du2  ${du2_emil_trace_id}  ${emil_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Run Keyword And Ignore Error
  ...  Stop Capture Emil Log Aic Du3  ${du3_emil_trace_id}  ${emil_log_dir}
  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Run Keyword And Ignore Error
  ...  Stop Capture Emil Log Aic Du4  ${du4_emil_trace_id}  ${emil_log_dir}

Conver some variables
   ${SOS_REPORT_FLAG_DIC}    Update list parameters to DIC    ${SOS_REPORT_FLAG}
   ${SNAPSHOT_FLAG_DIC}    Update list parameters to DIC    ${SNAPSHOT_FLAG}
   ${SOS_REPORT_STARTUP_1_FLAG_DIC}    Update list parameters to DIC    ${SOS_REPORT_STARTUP_1_FLAG}
   ${GNB_IQ_PARAM_DIC}    Run Keyword If    ${GNB_IQ_DATA_FLAG} is ${True}    Update list parameters to DIC    ${GNB_IQ_PARAM}
   Set suite variable    ${SOS_REPORT_FLAG_DIC}
   Set suite variable    ${SNAPSHOT_FLAG_DIC}
   Set suite variable    ${SOS_REPORT_STARTUP_1_FLAG_DIC}
   Run Keyword If    ${GNB_IQ_DATA_FLAG} is ${True}    Set suite variable    ${IQ_DATALINK}    ${GNB_IQ_PARAM_DIC["datalink"]}
   Run Keyword If    ${GNB_IQ_DATA_FLAG} is ${True}    Set suite variable    ${IQ_PCI}    ${GNB_IQ_PARAM_DIC["iq_pci"]}
   Run Keyword If    ${GNB_IQ_DATA_FLAG} is ${True}    Set suite variable    ${IQ_DU_ID}    ${GNB_IQ_PARAM_DIC["du_id"]}
   Run Keyword If    ${GNB_IQ_DATA_FLAG} is ${True}    Log To Console    GNB_IQ_PARAM is ${GNB_IQ_PARAM_DIC}
   Log To Console  SOS_REPORT is ${SOS_REPORT_FLAG_DIC}
   Log To Console  SNAPSHOT is ${SNAPSHOT_FLAG_DIC}
   Log To Console  SOS_REPORT_STARTUP is ${SOS_REPORT_STARTUP_1_FLAG_DIC}

Update list parameters to DIC
    [Arguments]    ${params}
    ${param_dict}    Create Dictionary
    ${params_list}    set variable    ${params.split(',')}
    BuiltIn.Log    ${params_list[0]}
    FOR    ${index}    IN RANGE    0    len(${params_list})
           ${item_list}    set variable    ${params_list[${index}].split(':')}
           set to dictionary    ${param_dict}    ${item_list[0]}    ${item_list[1]}
    END
    [Return]    ${param_dict}
