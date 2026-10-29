*** Settings ***
Documentation     [PURPOSE] General keywords for suite/test setup teardown
...               CA-SWM/CA-Trace
Library           lib/verify_crash.py
Library           lib/verify_reset.py
Library           ute_admin_infomodel

Library           taf.sbts.oam.coam.admin
Library           lib/tool_ping.py
Library           OperatingSystem
Library           String
Library           taf.sw.dcap.rd
Resource          dcap_oam.robot
Resource          Mrat_resource_new.robot
Resource          Convert_variables.robot
Resource          hran_common.robot
Resource          hran_general.robot
Resource          hran_infomodel.robot
Resource          hran_admin.robot
Resource          ca_swm_general.robot
Resource          hran_compa.robot
Library           ute_syslog
Library           lib/verdict.py
Library           lib/common.py
Library           lib/get_latest_enb.py
Library           lib/SSHExecutor.py
Library           SSHExecutor.SSHSystemModuleOperations
Library           lib/extract.py
Library           lib/oam_file_operations.py
Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          hran_pdu.robot
Resource          ../../../../..//resources/RAN_PZ_HAZ_1/Module/Module.robot
Library           lib/oam_compa.py
Library           oam_compa.SSHTools
Library           lib/wft.py
Library           lib/truck_roll.py
Library           taf.sw.scout    WITH NAME    scout
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library            taf.transport.ssh


*** Variables ***
#all needed variables should be given using '--variablefile CONFIG_FILE' or '-V CONFIG_FILE'
${HW_LOCATION_CODE}    Hangzhou
${TESTLINE_NAME}    Null
@{UDP ports}      51000    51001    51003    50011
${dist_GSM_cell_runtime_view}    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-*/GNBCF_R-*/GNCEL_R-*
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
&{IGNORED_FAULT_61524}    faultId=61524    faultName=SSH enabled
&{IGNORED_FAULT_61652}    faultId=61652    faultName=R&D Service Port enabled
&{IGNORED_FAULT_61649}    faultId=61649    faultName=LMP access via port
&{IGNORED_FAULT_6450}    faultId=6450    faultName=Diagnostic Files collected
&{IGNORED_FAULT_61074}    faultId=61074    faultName=CRL Update Failure
&{IGNORED_FAULT_4655}    faultId=4655    faultName=Service account root access is enabled
&{IGNORED_FAULT_4293}    faultId=4293    faultName=IP Traffic Capacity Limit
&{IGNORED_FAULT_4298}    faultId=4298    faultName=ToP reference missing
&{IGNORED_FAULT_4334}    faultId=4334    faultName=Serial console activated
&{IGNORED_FAULT_61510}    faultId=61510    faultName=Automatic BTS Operator Certificate retrieval unsuccessful
@{GLOBALLY_IGNORED_ALARMS}    ${IGNORED_FAULT_61524}    ${IGNORED_FAULT_61652}    ${IGNORED_FAULT_61649}
...  ${IGNORED_FAULT_6450}    ${IGNORED_FAULT_61074}    ${IGNORED_FAULT_4655}    ${IGNORED_FAULT_61074}
...  ${IGNORED_FAULT_4293}    ${IGNORED_FAULT_4298}    ${IGNORED_FAULT_61510}    ${IGNORED_FAULT_4334}
${DSC}            ${FALSE}
@{REMOTE_TESTLINES_LIST}    @{EMPTY}    #list of aliases of remote testlines; to be defined using REMOTE_TESTLINES
#dictionary in testline configuration file or json
${SCF_NR}    ${False}
${SEND_REP_PYTHON_CODE_PATH}    ${CURDIR}/lib/upload_report_portal.py
${COLLECT_LOG_DCAP_FLAG}    ${FALSE}
&{Artifactory_INFO}        path=/shared/TA2021/TA_Case/.netrc
...                        USERNAME=tdlte
...                        PASSWORD=btstest
...                        Host=10.108.184.68
...                        local_path=/home/ute/.netrc
&{Logserver_INFO}          USERNAME=ute
...                        PASSWORD=Ut3pa5s#ff97
...                        Host=10.69.69.233
${MoveLog_to_Logserver}    ${FALSE}
${UTE_ARGFILE_PATH}                /home/ute/argfile.txt
${UTE_RESERVATION_CONTEXT_JSON}    /opt/ute/reservation.context.json
${UTE_RESERVATION_JSON}            /opt/ute/reservation.json
${UTE_EXECUTION_JSON}              /opt/ute/execution.context.json
${UTE_EXECUTION_INDEX}             ${0}


*** Keyword ***
Start trace by Dcap for dual core
    [Documentation]    Short description.
    &{bts_dc}=      Create Dictionary
    ...                host=${BTS_INFO.IP}
    ...                username=Nemuadmin
    ...                password=nemuuser
    ...                port=443
    Set To Dictionary	${bts_dc}	host   192.168.255.129
    Connect To DCAP     ${tl.test_pcs[0].default_ssh_connection_details.addr}     9443     ${None}      ${None}     dcapv3
    ...    ${TRUE}     dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${bts_dc}
    ${lte_profile}=    get_LTE_profiles    dcap-master
    ${bts_profile}=    get_bts_profiles    dcap-master
    ${trace_1}=    Start Trace In DCAP        bts_dic=${bts_dc}          force=True
    ...    enb_trace_profile=${lte_profile}[0][gnb_enb_id]    bts_trace_profile=${bts_profile}[0][gnb_enb_id]     timeout=20min
    Set Test Variable    ${trace_1}      ${trace_1}
    Log To Console     master core done!!
    Connect To DCAP     ${tl.test_pcs[1].default_ssh_connection_details.addr}      9443     ${None}      ${None}    dcapv3
    ...    ${TRUE}
    Set To Dictionary	${bts_dc}	host   192.168.255.119
    Make Sure BTS Integrated In DCAP    bts_dic=${bts_dc}
    ${trace_2}=    Start Trace In DCAP       bts_dic=${bts_dc}          force=True
    ...    enb_trace_profile=${lte_profile}[0][gnb_enb_id]    bts_trace_profile=${bts_profile}[0][gnb_enb_id]     timeout=20min
    Log To Console     second core done!!tl.test_pcs[1].default_ssh_connection_details.addr
    Set Test Variable    ${trace_2}      ${trace_2}
    Log To Console     Trace Collection start on DCAP for dual core BTS!!

Start trace by Dcap for single core and remote option
    [Documentation]    Short description.
    &{bts_dc}=      Create Dictionary
    ...                host=${BTS_INFO.IP}
    ...                username=Nemuadmin
    ...                password=nemuuser
    ...                port=443
    Run keyword if     ${dcap_status}=='local'     Run Keywords    Set To Dictionary	${bts_dc}	host   192.168.255.129
    ...     AND    Connect To DCAP     ${tl.test_pcs[0].default_ssh_connection_details.addr}     9443
    ...    ELSE    Connect To DCAP     ${DCAP_SERVER_INFO.IP}     443
    #Connect To DCAP     ${DCAP_SERVER_INFO.IP}     443
    Make Sure BTS Integrated In DCAP    bts_dic=${bts_dc}
    ${lte_profile}=    get_LTE_profiles    dcap
    ${bts_profile}=    get_bts_profiles    dcap
    ${trace_1}=    Start Trace In DCAP       bts_dic=${bts_dc}          force=True
    ...    enb_trace_profile=${lte_profile}[0][gnb_enb_id]    bts_trace_profile=${bts_profile}[0][gnb_enb_id]     timeout=20min
    Set Test Variable    ${trace_1}      ${trace_1}
    Log To Console     Trace Collection start on DCAP!!}

Stop trace by Dcap
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dual_core}: <description>
    ...        ${local_remote}: <description>
    [arguments]     ${dual_core}      ${local_remote}
    #${trace}=     Run Keyword And Ignore Error     Variable Should Exist     ${trace_2}
    ${trace_status}=    Run Keyword If     ${dual_core}==${TRUE} and ${local_remote}=='local'     Run Keywords
    ...    stop_trace   ${trace_1}     dcap-master
    ...    AND    stop_trace    ${trace_2}     dcap
    ...    ELSE IF   ${dual_core}==${FALSE} and ${local_remote}=='local'  Stop Trace In DCAP    ${trace_1}
    ...    ELSE IF    ${local_remote}=='remote'    Stop Trace In DCAP    ${trace_1}

    Run Keyword If     ${dual_core}==${TRUE} and ${local_remote}=='local'     Run Keywords
    ...    Wait Until Keyword Succeeds     15min   10s    Make Sure Trace Status Ready    ${trace_1}     dcap-master
    ...    AND    Wait Until Keyword Succeeds     15min   10s    Make Sure Trace Status Ready    ${trace_2}    dcap
    ...    AND     Log To Console  status ready,,delete bts
    ...    AND      Download Trace File      192.168.255.129     connection=dcap-master
    ...    AND     Download Trace File      192.168.255.119     connection=dcap
    ...    ELSE IF     ${dual_core}==${FALSE} and ${local_remote}=='local'      Run Keywords
    ...    Wait Until Keyword Succeeds     15min   10s    Make Sure Trace Status Ready    ${trace_1}
    ...    AND     Log To Console  status ready,,delete bts
    ...    AND      Download Trace File      192.168.255.129
    ...    ELSE IF    ${local_remote}=='remote'    Run Keywords
    ...    Wait Until Keyword Succeeds     15min   10s    Make Sure Trace Status Ready    ${trace_1}
    ...    AND     Log To Console  status ready,,delete bts
    ...    AND      Download Trace File      ${BTS_INFO.IP}
    Log To Console     DCAP trace ready to use!!

Prepare Netrc On VM
    [Documentation]    Short description.
    ${exist_netrc}    Run Keyword And Return Status     OperatingSystem.File Should Exist
    ...    ${Artifactory_INFO.local_path}
    Return From Keyword If    ${exist_netrc}
    taf.transport.ssh.connect_to    hostname=${Artifactory_INFO.Host}
    ...    username=${Artifactory_INFO.USERNAME}
    ...    password=${Artifactory_INFO.PASSWORD}
    ...    alias=netrc_server
    taf.transport.ssh.download_file    remote_path=${Artifactory_INFO.path}
    ...    local_path=${Artifactory_INFO.local_path}
    ...    connection=netrc_server
    ${ret}    OperatingSystem.File Should Exist    ${Artifactory_INFO.local_path}
    OperatingSystem.Run    chmod u+r ${Artifactory_INFO.local_path}
    [Teardown]    Run Keyword And Ignore Error    taf.transport.ssh.disconnect    connection=netrc_server

Remove Netrc On VM
    [Documentation]    Short description.
    OperatingSystem.Run    rm ${Artifactory_INFO.local_path}
    OperatingSystem.File Should Not Exist
    ...    ${Artifactory_INFO.local_path}

CNI_Infomodel_Adapter
    [Documentation]    These variables ${_Enabled},${_Unlocked},${_OnAir}
    ...    are global and common variables, used for adapting CNI6110, please do not redefine them in cases bodies.
    [Arguments]  ${target_release}
    ${with_CNI_release}=  CNI_Infomodel_Adapter_release  ${target_release}
#    ${with_CNI_release}=  CNI_Infomodel_Adapter_release  SBTS22R1
    ${_Enabled}    set variable if   ${with_CNI_release}==True   regex"(?i)enabled"    regex"(?i)Enabled"
    ${_Disabled}    set variable if   ${with_CNI_release}==True   regex"(?i)disabled"    regex"(?i)Disabled"
    ${_Unlocked}    set variable if   ${with_CNI_release}==True   regex"(?i)Unlocked"    regex"(?i)Unlocked"
    ${_Locked}    set variable if   ${with_CNI_release}==True   regex"(?i)Locked"    regex"(?i)Locked"
    ${_OnAir}    set variable if   ${with_CNI_release}==True   onAir    OnAir
    ${_Degraded}    set variable if   ${with_CNI_release}==True   regex"(?i)degraded"  regex"(?i)Degraded"
    set global variable    ${_Enabled}
    set global variable    ${_Disabled}
    set global variable    ${_Unlocked}
    set global variable    ${_Locked}
    set global variable    ${_OnAir}
    set global variable    ${_Degraded}
    ${RMOD_expected_states}  set variable  administrativeState=${_Unlocked}, operationalState=${_Enabled}
    ${SMOD_expected_states}    set variable  administrativeState=${_Unlocked}, operationalState=${_Enabled}
    ${ALD_expected_states}    set variable  operationalState=${_Enabled}
    ${cells_NR_expected_states}
    ...  set variable  administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked
    ${cells_LTE_expected_states}
    ...  set variable  administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked
    ${cells_WCDMA_expected_states}
    ...  set variable  operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    ${gsm_temp}=	Catenate	SEPARATOR=	administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...  blockingState=Unblocked, usageState=Active
    ${cells_GSM_expected_states}    set variable  ${gsm_temp}
    set global variable    ${RMOD_expected_states}
    set global variable    ${SMOD_expected_states}
    set global variable    ${ALD_expected_states}
    set global variable    ${cells_NR_expected_states}
    set global variable    ${cells_LTE_expected_states}
    set global variable    ${cells_WCDMA_expected_states}
    set global variable    ${cells_GSM_expected_states}

TAF Config Adapter
    [Documentation]    Short description.
    log variables
    @{configuration}=    Split String    ${CONFIGURATION}    .
    @{tl_params}=    Split String    ${configuration}[1]    _
    Set suite variable    ${TEMP_LOGS_DIR}    /home/ute/btsauto/logs
#    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}
#    Import Library    hran_testline_configuration    ${HW_LOCATION_CODE}    ${TESTLINE_NAME}
    Set taf config variables

Check WebEM After Modify Parameters
    [Documentation]
    ...  Helper keyword used for check webEM after modify parameters
    ...
    ...  *INPUT*
    ...  | Parameter             | Mandatory | Description                                                          |
    ...  | scf_distName          | Yes       | SCF distName of MO for given parameter                               |
    ...  | parameters_dict    | Yes  parameters_dict(dictionary format - key:value) e.q. see netact_plan.yaml file  |

    [Arguments]    ${scf_distName}    &{parameters_dict}

#    ${BTS_scf}=  Admin Collect scf.xml with timestamp  folder_path=${BTSFiles}
#    Import Library  XML  use_lxml=True  WITH NAME  L_XML
#    ${scf_xml}=  L_XML.Parse xml  ${BTS_scf}
#    ${result_value}=  L_XML.Get Elements  ${scf_xml}  .//managedObject[@distName="${scf_distName}"]/p
    wait until keyword succeeds   2min  30s  Get Elements From SCF  ${scf_distName}
    ${result_value_dict}=  Create dictionary
    FOR  ${item}  IN  @{result_value}
        ${key}=  L_XML.Get Element Attribute  ${item}  name
        ${value}=  L_XML.Get Element Text  ${item}
        Set To Dictionary  ${result_value_dict}  ${key}=${value}
    END
    Dictionary Should Contain Sub Dictionary  ${result_value_dict}  ${parameters_dict}

Get Elements From SCF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf_distName}: <description>
    [Arguments]    ${scf_distName}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp  folder_path=${BTSFiles}
    Import Library  XML  use_lxml=True  WITH NAME  L_XML
    ${scf_xml}=  L_XML.Parse xml  ${BTS_scf}
    ${result_value}=  L_XML.Get Elements  ${scf_xml}  .//managedObject[@distName="${scf_distName}"]/p
    Should Not Be Empty  ${result_value}
    set test variable    ${result_value}

Check paramers from XML
    [Documentation]
    ...  Helper keyword used for check parameters from XML
    ...
    ...  *INPUT*
    ...  | Parameter             | Mandatory | Description                                                           |
    ...  | distName          | Yes       |distName of MO for given parameter                                         |
    ...  | parameters_dict       | Yes| parameters_dict(dictionary format - key:value) e.q. see netact_plan.yaml file|
    ...  | XML_full_path       | Yes       | xml full path  |
    [Arguments]    ${XML_full_path}    ${scf_distName}    ${parameters_dict}
    Import Library  XML  use_lxml=True  WITH NAME  L_XML
    ${scf_xml}=  L_XML.Parse xml  ${XML_full_path}
    ${result_value}=  L_XML.Get Elements  ${scf_xml}  .//managedObject[@distName="${scf_distName}"]/p
    ${result_value_dict}=  Create dictionary
    FOR  ${item}  IN  @{result_value}
        ${key}=  L_XML.Get Element Attribute  ${item}  name
        ${value}=  L_XML.Get Element Text  ${item}
        Set To Dictionary  ${result_value_dict}  ${key}=${value}
    END
    Dictionary Should Contain Sub Dictionary  ${result_value_dict}  ${parameters_dict}
    [Return]    ${result_value_dict}

Suite Setup
    [Arguments]    ${skip_build_download}=${FALSE}
    [Documentation]    These variables ${SW_path} ${SW_path_T1} ${SW_path_T2}
    ...  ${release_list},${release_list_1},${release_list_2},${release_list_3}
    ...    are global and common variables, please do not redifine them in cases bodies.
    ${date}  Get current date
    ${date}  Convert date  ${date}  result_format=%Y%m%d%H%M%S
    Create File  ${CURDIR}/../CRT/${SUITE NAME}-CRASH-${date}.xls
    set suite variable  ${CRASH_FILE_FULLPATH}  ${CURDIR}/../CRT/${SUITE NAME}-CRASH-${date}.xls
    set suite variable  ${CRASH_FILE}  ${SUITE NAME}-CRASH-${date}.xls
    write2xls   ${CRASH_FILE_FULLPATH}  ${SUITE NAME}
    ${Issue_upload_status}  Create list
    set suite variable  ${Issue_upload_status}
    set suite variable  ${CRASH_HOST}  10.108.184.40
    set suite variable  ${CRASH_USR}  ute
    set suite variable  ${CRASH_PWD}  ute
    set library search order    hran_frame_sbts    OperatingSystem
    Log    Start Suite Setup In OAM for UTE
    Run Keyword And Ignore Error    Prepare Netrc On VM
    ${Directory_status}=    run keyword and return status  directory should exist    /home/ute/btsauto/
    run keyword if  ${Directory_status}=='False'  Create Directory    /home/ute/btsauto/
    run keyword if  ${Directory_status}    OperatingSystem.empty directory    /home/ute/btsauto/
    Create Directory    /home/ute/btsauto/TARGET_SW/
    Create Directory    /home/ute/btsauto/TARGET_SW_T1/
    Create Directory    /home/ute/btsauto/TARGET_SW_T2/
    ${SW_path}=    set variable    /home/ute/btsauto/TARGET_SW/
    ${SW_path_T1}=    set variable    /home/ute/btsauto/TARGET_SW_T1/
    ${SW_path_T2}=    set variable    /home/ute/btsauto/TARGET_SW_T2/
    set suite variable    ${SW_path}
    set suite variable    ${SW_path_T1}
    set suite variable    ${SW_path_T2}
    Set suite variable    ${TEMP_LOGS_DIR}    /home/ute/btsauto/logs
    ${release_list}=    get_enb    ${target_release}
    set suite variable    ${release_list}
    set suite variable    ${release_list_1}    ${release_list[1]}
    set suite variable    ${release_list_2}    ${release_list[3]}
    set suite variable    ${release_list_3}    ${release_list[6]}
    Run Keyword If        ${skip_build_download}==${FALSE}      Download packages
    ${NR_Switch_Open}    set variable    False
    set suite variable    ${NR_Switch_Open}
    Set suite Variable    ${local_dcap_satrted}     ${FALSE}

Download packages
    [Documentation]    Short description.
    ${SW_path_package}       Download_Specify_Build_By_Aria    ${release_list_1}    Basic    ${SW_path}
    ${SW_path_T1_package}    Download_Specify_Build_By_Aria    ${release_list_2}    Basic    ${SW_path_T1}
    ${SW_path_T2_package}    Download_Specify_Build_By_Aria    ${release_list_3}    Basic    ${SW_path_T2}
    set suite variable    ${SW_path_package}
    set suite variable    ${SW_path_T1_package}
    set suite variable    ${SW_path_T2_package}
#    ${SW_path_package}  set variable
#     ...  /home/ute/btsauto/TARGET_SW/SBTS00_ENB_9999_240306_000003_release_BTSSM_downloadable_A54.zip
#    ${SW_path_T1_package}  set variable
#     ...  /home/ute/btsauto/TARGET_SW_T1/SBTS00_ENB_9999_240306_000001_release_BTSSM_downloadable_A54.zip
#    ${SW_path_T2_package}  set variable
#    ...  /home/ute/btsauto/TARGET_SW_T2/SBTS00_ENB_9999_240305_000019_release_BTSSM_downloadable_A54.zip

Suite Setup for debug
    [Documentation]    These variables ${SW_path} ${SW_path_T1} ${SW_path_T2}
    ...  ${release_list},${release_list_1},${release_list_2},${release_list_3}
    ...    are global and common variables, please do not redifine them in cases bodies.
    ${date}  Get current date
    ${date}  Convert date  ${date}  result_format=%Y%m%d%H%M%S
    Create File  ${CURDIR}/${SUITE NAME}-CRASH-${date}.xls
    set suite variable  ${CRASH_FILE_FULLPATH}  ${CURDIR}/../CRT/${SUITE NAME}-CRASH-${date}.xls
    set suite variable  ${CRASH_FILE}  ${SUITE NAME}-CRASH-${date}.xls
    write2xls   ${CRASH_FILE_FULLPATH}  ${SUITE NAME}
    set suite variable  ${CRASH_HOST}  10.108.184.40
    set suite variable  ${CRASH_USR}  ute
    set suite variable  ${CRASH_PWD}  ute
    set library search order    hran_frame_sbts    OperatingSystem
    Log    Start Suite Setup In OAM for UTE
    set library search order    hran_frame_sbts    OperatingSystem
    Log    Start Suite Setup In OAM for UTE
    ${Directory_status}=    run keyword and return status  directory should exist    /home/ute/btsauto/
    run keyword if  ${Directory_status}=='False'  Create Directory    /home/ute/btsauto/
    run keyword if  ${Directory_status}    OperatingSystem.empty directory    /home/ute/btsauto/
    Create Directory    /home/ute/btsauto/TARGET_SW/
    Create Directory    /home/ute/btsauto/TARGET_SW_T1/
    Create Directory    /home/ute/btsauto/TARGET_SW_T2/
    ${SW_path}=    set variable    /home/ute/btsauto/TARGET_SW/
    ${SW_path_T1}=    set variable    /home/ute/btsauto/TARGET_SW_T1/
    ${SW_path_T2}=    set variable    /home/ute/btsauto/TARGET_SW_T2/
    set suite variable    ${SW_path}
    set suite variable    ${SW_path_T1}
    set suite variable    ${SW_path_T2}
    Set suite variable    ${TEMP_LOGS_DIR}    /home/ute/btsauto/logs
    ${release_list}=    get_enb    ${target_release}
    set suite variable    ${release_list}
    set suite variable    ${release_list_1}    ${release_list[-1]}
    set suite variable    ${release_list_2}    ${release_list[-6]}
    set suite variable    ${release_list_3}    ${release_list[-10]}

Download SW T2
    [Documentation]    Short description.
    ${Directory_T2_status}=    run keyword and return status
    ...  OperatingSystem.directory should exist    /home/ute/btsauto/SW_Test_Download_T2/
    run keyword if  ${Directory_T2_status}=='False'  Create Directory    /home/ute/btsauto/SW_Test_Download_T2/
    run keyword if  ${Directory_T2_status}    OperatingSystem.empty directory    /home/ute/btsauto/SW_Test_Download_T2/
    ${SW_path_Download_T2}=    set variable    /home/ute/btsauto/SW_Test_Download_T2/
    set suite variable    ${SW_path_Download_T2}
    ${SW_path_Download_T2_package}
    ...  Download_Specify_Build_By_Aria    ${release_list_1}    T2    ${SW_path_Download_T2}
#    ${SW_path_Download_T1_package}    set variable
#    ...  /home/ute/robotlte/SW_Test_Download_T1/SBTS00_ENB_9999_21042
#9_000012_release_BTSSM_downloadable_testpackage_T1_A54.zip
    set suite variable    ${SW_path_Download_T2_package}

Download SW T1
    [Documentation]    Short description.
    ${Directory_T1_status}=    run keyword and return status
    ...  OperatingSystem.directory should exist    /home/ute/btsauto/SW_Test_Download_T1/
    run keyword if  ${Directory_T1_status}=='False'  Create Directory    /home/ute/btsauto/SW_Test_Download_T1/
    run keyword if  ${Directory_T1_status}    OperatingSystem.empty directory    /home/ute/btsauto/SW_Test_Download_T1/
    ${SW_path_Download_T1}=    set variable    /home/ute/btsauto/SW_Test_Download_T1/
    set suite variable    ${SW_path_Download_T1}
    ${SW_path_Download_T1_package}
    ...  Download_Specify_Build_By_Aria    ${release_list_1}    T1    ${SW_path_Download_T1}
#    ${SW_path_Download_T1_package}    set variable
#    ...  /home/ute/robotlte/SW_Test_Download_T1/SBTS00_ENB_9999_21042
#9_000012_release_BTSSM_downloadable_testpackage_T1_A54.zip
    set suite variable    ${SW_path_Download_T1_package}

Download SW Second T1
    [Documentation]    Short description.
    ${Directory_T2_status}=    run keyword and return status
    ...  OperatingSystem.directory should exist    /home/ute/btsauto/SW_Test_Download_T2/
    run keyword if  ${Directory_T2_status}=='False'  Create Directory    /home/ute/btsauto/SW_Test_Download_T2/
    run keyword if  ${Directory_T2_status}    OperatingSystem.empty directory    /home/ute/btsauto/SW_Test_Download_T2/
    ${SW_path_Download_T2}=    set variable    /home/ute/btsauto/SW_Test_Download_T2/
    set suite variable    ${SW_path_Download_T2}
    ${SW_path_Download_T2_package}
    ...  Download_Specify_Build_By_Aria    ${release_list_2}    T1    ${SW_path_Download_T2}
    set suite variable    ${SW_path_Download_T2_package}

Suite Setup for FSMFA
    [Documentation]    Short description.
    set library search order    hran_frame_sbts
    Log    Start Suite Setup In OAM for UTE
    ${Directory_status}=    run keyword and return status  directory should exist    /home/ute/btsauto/
    run keyword if  ${Directory_status}=='False'  Create Directory    /home/ute/btsauto/
    run keyword if  ${Directory_status}    OperatingSystem.empty directory    /home/ute/btsauto/
    Create Directory    /home/ute/btsauto/TARGET_SW/
    Create Directory    /home/ute/btsauto/TARGET_SW_T1/
    Create Directory    /home/ute/btsauto/TARGET_SW_T2/
    ${SW_path}=    set variable    /home/ute/btsauto/TARGET_SW/
    ${SW_path_T1}=    set variable    /home/ute/btsauto/TARGET_SW_T1/
    ${SW_path_T2}=    set variable    /home/ute/btsauto/TARGET_SW_T2/
    set suite variable    ${SW_path}
    set suite variable    ${SW_path_T1}
    set suite variable    ${SW_path_T2}
    ${release_list}=    get_enb    ${target_release}
    set suite variable    ${release_list}
    set suite variable    ${release_list_1}    ${release_list[-1]}
    set suite variable    ${release_list_2}    ${release_list[-6]}
    set suite variable    ${release_list_3}    ${release_list[-10]}
    #${SW_path_package}    _Download_Specify_A54E_Build_By_Aria    ${release_list_1}    ${SW_path}
    #${SW_path_T1_package}    _Download_Specify_A54E_Build_By_Aria    ${release_list_2}    ${SW_path_T1}
    #${SW_path_T2_package}    _Download_Specify_A54E_Build_By_Aria    ${release_list_3}    ${SW_path_T2}
    #set suite variable    ${SW_path_package}
    #set suite variable    ${SW_path_T1_package}
    #set suite variable    ${SW_path_T2_package}

Get upgrade path
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${BUILD}: <description>
    ...        ${Passive_build}: <description>
    ...        ${release_list_1}: <description>
    ...        ${release_list_2}: <description>
    ...        ${release_list_3}: <description>
    ...
    ...    Returns:
    ...        ${Target SW dir}: <description>
    [Arguments]    ${BUILD}    ${Passive_build}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${Target SW dir}    Run keyword if
    ...  '${BUILD}'!='${release_list_1}' and '${Passive_build}'!='${release_list_1}'    set variable    ${SW_path}
    ...    ELSE IF    '${BUILD}'!='${release_list_2}' and '${Passive_build}'!='${release_list_2}'
    ...  set variable    ${SW_path_T1}
    ...    ELSE IF    '${BUILD}'!='${release_list_3}' and '${Passive_build}'!='${release_list_3}'
    ...  set variable    ${SW_path_T2}
    [Return]    ${Target SW dir}

Suite teardown
    [Documentation]    Short description.
    ${cond}  Evaluate  len(${Issue_upload_status})>0
    run keyword and ignore error  Run keyword if  ${cond}  upload_crashfile_to_server
    ...  ${CRASH_FILE}  ${CRASH_FILE_FULLPATH}   ${CRASH_HOST}  ${CRASH_USR}  ${CRASH_PWD}
    Run Keyword If      ${local_dcap_satrted}==${TRUE}     Run Keyword and Ignore Error     Stop DCAP Container For All Nodes     enb
    Run Keyword And Ignore Error    Run keyword If    ${MoveLog_to_Logserver}
    ...         upload test_result to remote
    log    The suite pass entirely

TC Setup
    [Documentation]    Short description.
    Common Test Setup
    Delete_uboot_parameters

TC Setup and set variables
    [Documentation]    Short description.
    Run Keywords    Common Test Setup
    ...    AND    Set Test Variables
    Delete_uboot_parameters

TC Teardown
    [Documentation]    Short description.
    Common Test Teardown
    Add_uboot_parameters

TC Teardown_table
    [Documentation]    Short description.
    Run keywords    Common Test Teardown
    ...    AND    Log    Nothing    #Log table    sw_table
    Add_uboot_parameters

TC Teardown_table_KPI
    [Documentation]    Short description.
    Run keywords    Common Test Teardown
    Add_uboot_parameters

Common Test Setup For Remote
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${admin_launch}: <description>
    ...        ${syslog_launch}: <description>
    ...        ${infomodel_launch}: <description>
    ...        ${btssm_launch}: <description>
    ...        ${bts_host}: <description>
    ...        ${modules_check}: <description>
    ...        ${cells_check}: <description>
    ...        ${alarms_check}: <description>
    ...        ${expected_BTS_status}: <description>
    ...        ${scf_check}: <description>
    ...        ${expected_alarms}: <description>
    ...        ${ignored_alarms}: <description>
    ...        ${critical_alarms}: <description>
    [Arguments]    ${admin_launch}=${TRUE}    ${syslog_launch}=${TRUE}
    ...   ${infomodel_launch}=${TRUE}    ${btssm_launch}=${FALSE}    ${bts_host}=192.168.255.129
    ...  ${modules_check}=${TRUE}    ${cells_check}=${TRUE}    ${alarms_check}=${TRUE}    ${expected_BTS_status}=OnAir
    ...  ${scf_check}=${TRUE}    ${expected_alarms}=@{EMPTY}    ${ignored_alarms}=@{EMPTY}
    ...  ${critical_alarms}=@{EMPTY}
    #[Timeout]    15 minutes
    Log    ${btssm_launch}
    Set Test Variable    ${scf_check}    ${scf_check}
    Set Test Variable    ${btssm_started}    ${FALSE}
    Set Test Variable    ${infomodel_started}    ${FALSE}
    Set Test Variable    ${SMOD1_syslog_started}    ${FALSE}
    Set Test Variable    ${SMOD2_syslog_started}    ${FALSE}
    Set Test Variable    ${admin_started}    ${FALSE}
    Set Test Variable    ${scf_parser_started}    ${FALSE}
    Set Test Variable    ${bts_verification_status}    norun
    Set Test Variable    ${dcap_collection}    ${FALSE}

    ${host_name}=    common.get hostname
    ${host_name}=    Set Variable    ${host_name.replace('-','_')}
    set suite variable    ${host_name}
    ${TESTLINE_NAME}    Set variable    ${host_name}
    Set suite variable    ${TESTLINE_NAME}
    ${CONFIGURATION}    catenate    SEPARATOR=.    ${HW_LOCATION_CODE}    ${host_name}
    set suite variable    ${CONFIGURATION}
#    import library    hran_testline_configuration    ${HW_LOCATION_CODE}    ${TESTLINE_NAME}
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import variables
    ...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ12/OAM_SRAN/Variables${/}${host_name}.py
    Install ims module
    ${tl}    Set variable    ${host_name}
    ${additional_variables_exist}=    Run Keyword And Return Status
    ...  Variable Should Exist    ${ADDITIONAL_VARIABLES_PATH}
    Run Keyword If    ${additional_variables_exist}    Run Keyword And Ignore Error
    ...  Import Variables    ${ADDITIONAL_VARIABLES_PATH}
    log variables
    ${taf_config_model}=    Run keyword and return status    Variable should exist    ${tl}
    Set test variable    ${TAF_CONFIG_MODEL}    ${taf_config_model}
    Run keyword if    ${TAF_CONFIG_MODEL}    Taf config adapter
#    ...    ELSE    hran_testline_configuration.Set Config Variables    @{TESTLINE_CONFIG_VARIABLES}
    Run keyword if    not ${TAF_CONFIG_MODEL}    Clean VM disk space    Master
    ${HW_TYPE}=    Get_HW_Type
    There should be at least 2048 MB of disk space available in /home/ute
    # product-specific part of precondititons:
    hran_general.Hran_ta Preconditions
    Log
    ...  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}    level=INFO    console=${TRUE}
    Set Tags    ${HW_LOCATION_CODE}\\${TESTLINE_NAME}
    Set Additional Ignored Alarms
    #Set Raw Alarm History Connection Parameters
    Log Variables    level=DEBUG
    Run Keyword If    ${admin_launch}    Run Keyword And Continue On Failure
    ...  Start Admin    bts_host=${bts_host}
    Run Keyword If    'DCAP' in @{TEST TAGS}     Set test variable    ${syslog_launch}     ${FALSE}
    Run Keyword If    ${syslog_launch}    Run Keyword And Continue On Failure    Start syslog   smod=SMOD1
    Run Keyword If    ${infomodel_launch}    Run Keyword And Continue On Failure
    ...    Start Infomodel      bts_host=${bts_host}
    Setup SMOD2    ${admin_started}    ${infomodel_started}    ${syslog_launch}
    #Run Keyword If    ${btssm_launch}    Run Keyword And Continue On Failure    Start BTSSM On 'MSM'
    Run Keyword If    ${infomodel_started}    Run Keyword And Continue On Failure    Print Active And Passive SW Version
    ${active_sw_version}    Run keyword if
    ...  ${infomodel_started}    Infomodel Get Active SW Version    module=MSM    im_param=activeBuildDescriptorId
    ${release_num_for_CNI}  Fetch from left  ${active_sw_version}  _
    CNI_Infomodel_Adapter  ${release_num_for_CNI}
#    set test variable    ${ENB_BUILD}    ${active SW version}
    set test variable    ${Passive_build}    ${passive SW version_need_compare}
#    set test variable    ${ENB_Trunk_Version}    ${ENB_BUILD}
    set test variable    ${ENB_Trunk_Version}    ${active SW version}
#    ${ENB_BRANCH}=    Fetch from left    ${ENB_BUILD}
    ${ENB_BRANCH}=    Fetch from left    ${active SW version}
    set test variable    ${ENB_BRANCH}
    ${is_trunk}=    Run Keyword And Return Status    Should Contain    ${active SW version}    _ENB_9999_
    ${ENB_Trunk_Version}    run keyword if    ${is_trunk}
#    ...  '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${ENB_Trunk_Version}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${ENB_Trunk_Version}
    Log    ****Current BTS version is '${ENB_Trunk_Version}' *****
    set test variable    ${ENB_Trunk_Version}
    ${gsm_states_verification} =	Catenate	SEPARATOR=
    ...   administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...   blockingState=Unblocked,usageState=Active
    set global variable    ${gsm_states_verification}
    Log      ${gsm_states_verification}
    ${Passive_build}    run keyword if    ${is_trunk}
#    ...  '${target_release}'=='SBTS00'
    ...    Replace String Using Regexp    ${Passive_build}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${Passive_build}
    ${Target SW dir}=    run keyword if
    ...  '${ENB_Trunk_Version}' in '${ENB_Trunk_Version}'
    ...  Get upgrade path
    ...  ${ENB_Trunk_Version}    ${Passive_build}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ...    ELSE    set variable    ${SW_path}
    set test variable    ${Target SW dir}
    Run keyword if    ${admin_started}
	...    Verify BTS states    ${expected_BTS_status}    ${modules_check}
	...  ${cells_check}    ${alarms_check}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}
    ...    ELSE    Set Test Variable    ${bts_verification_status}    passed
    Change parameter to disable Netact snapshot collection
    Run keyword and ignore error    Setup Test Line Watchdog
    ${dcap_server_info_status}=     Run Keyword And Ignore Error     Variable Should Exist     ${DCAP_SERVER_INFO}
    Run Keyword If    '${dcap_server_info_status}[0]'=='FAIL'      set suite variable    ${dcap_status}      'local'
    ...    ELSE     set suite variable    ${dcap_status}      'remote'
    Run Keyword If     'DCAP' in @{TEST TAGS} and ${local_dcap_satrted}==${FALSE} and ${dcap_status}=='local'
    ...    Run Keywords      Start DCAP Container For All Nodes     enb
    ...    AND    Set Suite Variable    ${local_dcap_satrted}     ${TRUE}
    Run Keyword if   'DCAP' in @{TEST TAGS} and ${dcap_status}=='local' and ${SMOD2_exists}==${TRUE}
    ...    Run Keywords     Start trace by Dcap for dual core
    ...    AND     Set Test Variable      ${dcap_started}     ${TRUE}
    ...    ELSE IF    'DCAP' in @{TEST TAGS} and ${dcap_status}=='local' and ${SMOD2_exists}==${FALSE}
    ...    Run Keywords     Start trace by Dcap for single core and remote option
    ...    AND     Set Test Variable      ${dcap_started}     ${TRUE}
    ...    ELSE IF     ${dcap_status}=='remote'     Run Keywords
    ...    Start trace by Dcap for single core and remote option
    ...    AND     Set Test Variable      ${dcap_started}     ${TRUE}
    ...    ELSE     Set Test Variable      ${dcap_started}     ${FALSE}
    Log    End of Common Test Setup    level=INFO    console=${TRUE}
    Set Preconditions Passed

Common Test Setup
    [Arguments]    ${admin_launch}=${TRUE}    ${syslog_launch}=${TRUE}
    ...   ${infomodel_launch}=${TRUE}    ${btssm_launch}=${FALSE}    ${bts_host}=192.168.255.129
    ...  ${modules_check}=${TRUE}    ${cells_check}=${TRUE}    ${alarms_check}=${TRUE}    ${expected_BTS_status}=OnAir
    ...  ${scf_check}=${TRUE}    ${expected_alarms}=@{EMPTY}    ${ignored_alarms}=@{EMPTY}
    ...  ${critical_alarms}=@{EMPTY}
    [Documentation]    Set of actions which will be launched before each SBTS SOAM test (starting from SBTS17).
    ...    List of actions:
    ...    -> Hran_ta Preconditions: Gets hran_ta workspace version based on information from SVN
    ...    Creates log directories
    ...    Initializes variables used for test_verdict calculation
    ...    -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space, to ensure Robot test can run
    ...    -> Starts Admin connection
    ...    -> Starts Syslogs collecting
    ...    -> Starts infomodel on LTE site
    ...    -> Starts BTSSM on all sites
    ...    -> Gets and displays SW versions
    ...    -> Checks cells and modules state and active alarms
    ...
    ...    | Parameter | Default | Description |
    ...    | admin_launch | TRUE | Whether to initialise/or not Admin connection |
    ...    | syslog_launch | TRUE | Whether to collect/or not syslog during TC execution |
    ...    | infomodel_launch | TRUE | Whether to initialise/or not InfoModel connection |
    ...    | btssm_launch | TRUE | Whether to initialise/or not btssm library |
    ...    | bts_host | 192.168.255.129 | IP address to connect with BTS |
    ...    | modules_check | TRUE | Flag for enabling/disabling modules precheck |
    ...    | cells_check | TRUE | Flag for enabling/disabling cells precheck |
    ...    | alarms_check | TRUE | Flag for enabling/disabling alarms precheck |
    ...    | expected_BTS_status | OnAir | Expected BTS status|
    ...    | scf_check | TRUE | Whether to initialise/or not SCF parrser, and checking with SCF |
    ...    | expected_alarms | empty | List of expected alarms regex patterns, one for each expected alarm |
    ...    | ignored_alarms | empty | List of ignored alarms regex patterns, will be used multiply |
    ...    | critical_alarms | empty | List of critical alarms regex patterns, will be used multiply |
    ...
    ...    | To run setup for DSC, variable ${DSC}=${True} should be visible in env_config or test parameters in json
    ...   | To run setup for remote testlines, dictionary REMOTE_TESTLINES has to be added to env_config, example entry:
    ...    | REMOTE_TESTLINES:
    ...    | TESTLINE1:
    ...    | PC_IP1: <ip_address_of_msm_host>
    ...    | PC_IP2: <ip_address_of_esm_host>
    ...    |
    ...    | User can import global variables from file in common test setup;
    ...    ${ADDITIONAL_VARIABLES_PATH} need to be included in json file
    #[Timeout]    15 minutes
    Log    ${btssm_launch}
    Log    ${bts_host}
    Set Test Variable    ${scf_check}    ${scf_check}
    Set Test Variable    ${btssm_started}    ${FALSE}
    Set Test Variable    ${infomodel_started}    ${FALSE}
    Set Test Variable    ${SMOD1_syslog_started}    ${FALSE}
    Set Test Variable    ${SMOD2_syslog_started}    ${FALSE}
    Set Test Variable    ${admin_started}    ${FALSE}
    Set Test Variable    ${scf_parser_started}    ${FALSE}
    Set Test Variable    ${bts_verification_status}    norun
    Set Test Variable    ${dcap_collection}    ${FALSE}
    #${SW_path}=    set variable    /home/ute/btsauto/TARGET_SW/
    #${SW_path_T1}=    set variable    /home/ute/btsauto/TARGET_SW_T1/
    #${SW_path_T2}=    set variable    /home/ute/btsauto/TARGET_SW_T2/
    ${host_name}=    common.get hostname
    ${host_name}=    Set Variable    ${host_name.replace('-','_')}
    set suite variable    ${host_name}
    ${TESTLINE_NAME}    Set variable    ${host_name}
    Set suite variable    ${TESTLINE_NAME}
    ${CONFIGURATION}    catenate    SEPARATOR=.    ${HW_LOCATION_CODE}    ${host_name}
    set suite variable    ${CONFIGURATION}
#    import library    hran_testline_configuration    ${HW_LOCATION_CODE}    ${TESTLINE_NAME}
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import Variables
    ...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ12/OAM_SRAN/Variables${/}${host_name}.py
    Install ims module
    ${tl}    Set variable    ${host_name}
    ${additional_variables_exist}=    Run Keyword And Return Status
    ...  Variable Should Exist    ${ADDITIONAL_VARIABLES_PATH}
    Run Keyword If    ${additional_variables_exist}    Run Keyword And Ignore Error
    ...  Import Variables    ${ADDITIONAL_VARIABLES_PATH}
    log variables
    ${taf_config_model}=    Run keyword and return status    Variable should exist    ${tl}
    Set test variable    ${TAF_CONFIG_MODEL}    ${taf_config_model}
    Run keyword if    ${TAF_CONFIG_MODEL}    Taf config adapter
#    ...    ELSE    hran_testline_configuration.Set Config Variables    @{TESTLINE_CONFIG_VARIABLES}
    Run keyword if    not ${TAF_CONFIG_MODEL}    Clean VM disk space    Master
    ${HW_TYPE}=    Get_HW_Type
    There should be at least 2048 MB of disk space available in /home/ute
    # product-specific part of precondititons:
    hran_general.Hran_ta Preconditions
    Log
    ...  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}    level=INFO    console=${TRUE}
    Set Tags    ${HW_LOCATION_CODE}\\${TESTLINE_NAME}
    Set Additional Ignored Alarms
    #Set Raw Alarm History Connection Parameters
    Log Variables    level=DEBUG
    Run Keyword If    ${admin_launch}    Run Keyword And Continue On Failure
    ...  Start Admin    bts_host=${SMOD1['TRS_IP']}
    Run Keyword If    'DCAP' in @{TEST TAGS}     Set test variable    ${syslog_launch}     ${FALSE}
    Run Keyword If    ${syslog_launch}    Run Keyword And Continue On Failure    Start syslog   smod=SMOD1
    Run Keyword If    ${infomodel_launch}    Run Keyword And Continue On Failure    Start Infomodel
    Setup SMOD2    ${admin_started}    ${infomodel_started}    ${syslog_launch}
    #Run Keyword If    ${btssm_launch}    Run Keyword And Continue On Failure    Start BTSSM On 'MSM'
    Run Keyword If    ${infomodel_started}    Run Keyword And Continue On Failure    Print Active And Passive SW Version
    ${active_sw_version}    Run keyword if
    ...  ${infomodel_started}    Infomodel Get Active SW Version    module=MSM    im_param=activeBuildDescriptorId
    ${release_num_for_CNI}  Fetch from left  ${active_sw_version}  _
    CNI_Infomodel_Adapter  ${release_num_for_CNI}
#    set test variable    ${ENB_BUILD}    ${active SW version}
    set test variable    ${Passive_build}    ${passive SW version_need_compare}
#    set test variable    ${ENB_Trunk_Version}    ${ENB_BUILD}
    set test variable    ${ENB_Trunk_Version}    ${active SW version}
#    ${ENB_BRANCH}=    Fetch from left    ${ENB_BUILD}    _
    ${ENB_BRANCH}=    Fetch from left    ${active SW version}    _
    set test variable    ${ENB_BRANCH}
    ${is_trunk}=    Run Keyword And Return Status    Should Contain    ${active SW version}    _ENB_9999_
    ${ENB_Trunk_Version}    run keyword if    ${is_trunk}
#    ...  '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${ENB_Trunk_Version}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${ENB_Trunk_Version}
    set test variable    ${ENB_Trunk_Version}
    Log    ****Current BTS version is '${ENB_Trunk_Version}' *****
    ${gsm_states_verification} =	Catenate	SEPARATOR=
    ...   administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...   blockingState=Unblocked,usageState=Active
    set global variable    ${gsm_states_verification}
    Log      ${gsm_states_verification}
    ${Passive_build}    run keyword if    '_ENB_9999_' in '${Passive_build}'
    ...    Replace String Using Regexp    ${Passive_build}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${Passive_build}
    ${Target SW dir}=    run keyword if
    ...  '${ENB_Trunk_Version}' in '${ENB_Trunk_Version}'
    ...  Get upgrade path
    ...  ${ENB_Trunk_Version}    ${Passive_build}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ...    ELSE    set variable    ${SW_path}
    set test variable    ${Target SW dir}
    Run keyword If    ${admin_started} and ${scf_check}
    ...  Run keyword and continue on failure    Start scf Parser    UNIVERSAL
	Run keyword if    ${admin_started}
	...    Verify BTS states    ${expected_BTS_status}    ${modules_check}
	...  ${cells_check}    ${alarms_check}    ${expected_alarms}    ${ignored_alarms}    ${critical_alarms}
    ...    ELSE    Set Test Variable    ${bts_verification_status}    passed
    Run keyword if    ${DSC}
    ...  Run Keyword And Continue On Failure    Remote Test Line Setup    remote_host=${PC_IP2}    alias=DSC
    ${remote_testlines_configured}    ${remote_testlines_tmp}=
    ...  Run keyword and ignore error    Get dictionary keys    ${REMOTE_TESTLINES}
    ${REMOTE_TESTLINES_LIST}=    Run Keyword If    '${remote_testlines_configured}'=='PASS'
    ...    Set Variable    ${remote_testlines_tmp}
    ...    ELSE    Create List
    Set Test Variable    ${REMOTE_TESTLINES_LIST}
    FOR    ${remote_alias}    IN    @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Set Up Remote Test Line    ${remote_alias}
    END
    Change parameter to disable Netact snapshot collection
    Run keyword and ignore error    Setup Test Line Watchdog
    ${dcap_server_info_status}=     Run Keyword And Ignore Error     Variable Should Exist     ${DCAP_SERVER_INFO}
    Run Keyword If    '${dcap_server_info_status}[0]'=='FAIL'      set suite variable    ${dcap_status}      'local'
    ...    ELSE     set suite variable    ${dcap_status}      'remote'
    Run Keyword If     'DCAP' in @{TEST TAGS} and ${local_dcap_satrted}==${FALSE} and ${dcap_status}=='local'
    ...    Run Keywords      Start DCAP Container For All Nodes     enb
    ...    AND    Set Suite Variable    ${local_dcap_satrted}     ${TRUE}
    Run Keyword if   'DCAP' in @{TEST TAGS} and ${dcap_status}=='local' and ${SMOD2_exists}==${TRUE}
    ...    Run Keywords     Start trace by Dcap for dual core
    ...    AND     Set Test Variable      ${dcap_started}     ${TRUE}
    ...    ELSE IF    'DCAP' in @{TEST TAGS} and ${dcap_status}=='local' and ${SMOD2_exists}==${FALSE}
    ...    Run Keywords     Start trace by Dcap for single core and remote option
    ...    AND     Set Test Variable      ${dcap_started}     ${TRUE}
    ...    ELSE IF     ${dcap_status}=='remote'     Run Keywords
    ...    Start trace by Dcap for single core and remote option
    ...    AND     Set Test Variable      ${dcap_started}     ${TRUE}
    ...    ELSE     Set Test Variable      ${dcap_started}     ${FALSE}
    Log    End of Common Test Setup    level=INFO    console=${TRUE}
    Set Preconditions Passed

Change parameter to disable Netact snapshot collection
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
    ...  operation=update    value=false
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Change parameter to enable Netact snapshot collection
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
    ...  operation=update    value=true
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Install ims module
    [Documentation]    Short description.
    [Tags]  robot:no-dry-run
    Run keyword and ignore error    Install Library In Loacal PC  sqlalchemy
    Run keyword and ignore error    import Library    ${CURDIR}/lib/ims.py
    Run keyword and ignore error    import Library    ims.TimeRegister

Setup SMOD2
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${admin_started}: <description>
    ...        ${infomodel_started}: <description>
    ...        ${syslog_launch}: <description>
    [Arguments]    ${admin_started}    ${infomodel_started}    ${syslog_launch}
    ${smod2_variable_exists}=    Run keyword and return status    Variable Should Exist    ${SMOD2}
    set test variable    ${smod2_variable_exists}
    ${pc_ip2_variable_exists}=    Run keyword and return status    Variable Should Exist    ${PC_IP2}
    Run keyword if    '${smod2_variable_exists}'=='${False}' or '${pc_ip2_variable_exists}'=='${False}'
    ...  Run keywords    Log    One SMOD or none PC_IP2 was declared in config    console=${TRUE}
    ...    AND    Set test variable    ${SMOD2_exists}    ${FALSE}
    ...    AND    Return from keyword
    Run keyword if    ${admin_started} and ${infomodel_started}    Check SMOD2 in Admin
    ...    ELSE    Run keywords    Log    Skip checking SMOD2 in Admin    console=${TRUE}
    ...    AND    Set test variable    ${SMOD2_exists}    ${TRUE}
    Run keyword if    not ${TAF_CONFIG_MODEL}    Run keyword if    ${SMOD2_exists}
    ...  Clean VM disk space    Extension    host_ip=${PC_IP2}    ssh_port=${22}    ssh_username=ute    ssh_password=ute
    Run keyword if    not ${TAF_CONFIG_MODEL}    Run keyword if    ${SMOD2_exists}
    ...   Check if remote host directory has enough space    /home/ute    2048    ${PC_IP2}    ${22}    ute    ute
    Run Keyword If    ${syslog_launch} and ${SMOD2_exists}
    ...  Run Keyword And Continue On Failure    Start syslog   smod=SMOD2  host_ip=${PC_IP2}

Common Test Teardown
    [Arguments]    ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}
    [Documentation]    Set of actions which will be launched after each SBTS SOAM test ends (starting from SBTS17).
    ...    List of actions:
    ...    -> Triggers snapshot depends on selected option and test_verdict
    ...   -> Gets and displays siteName information from siteconf.xml for Master and Slave SM (if slave_tech is not GSM)
    ...    -> Collects BTSSM files and stops BTSSM session
    ...    -> Collects Infomodel files and stops Infomodel session
    ...    -> Collects Syslog files ands stops logging
    ...    -> Collects Admin files and stops Admin session
    ...
    ...    | Parameter | Default | Description |
    ...    | collect_snapshot | failed_verdict | Flag for enabling/disabling snapshot trace |
    ...
    ...    | Possible collect_snapshot values | Description
    ...    | always | Snapshot is collected unless the test verdict is norun |
    ...    | failed_verdict | Snapshot is collected if the test verdict is failed or blocked |
    ...    | passed_with_restriction | Snapshot is collected if the test verdict is failed,
    ...                                            blocked or passed_with_restriction |
    ...    | never | Snapshot is not collected |
    # this is to allow one to override `collect_snapshot` by providing it in a command line / JSON,
    # even if it is set in a TC (as in `Common Test Teardown    collect_snapshot=never`)
    ${collect_snapshot}=    Set Variable If    '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'
    ...  ${COLLECT_SNAPSHOT_FLAG}    ${collect_snapshot}
    Log    Common Test Teardown    level=INFO    console=${TRUE}
    Run Keyword If    '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...  Set Test Blocked
    ...  Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state
    Log verdict messages
    ${test_verdict}=    Get test verdict
    ${collect_snapshot_condition_1}=    Evaluate
    ...  '${collect_snapshot}'=='always' and '${test_verdict}'!='norun'

    ${snapshot_condition_3}=       Evaluate
    ...  ('${test_verdict}'=='failed') or ('${test_verdict}'=='blocked')
    ${collect_snapshot_condition_2}=        Evaluate
    ...  '${collect_snapshot}'=='failed_verdict' and ${snapshot_condition_3}
    ${snapshot_condition_4}=        Evaluate
    ...  ${snapshot_condition_3} or '${test_verdict}'=='passed_with_restriction'
    ${snapshot_condition_5}=         Evaluate
    ...  '${collect_snapshot}'=='passed_with_restriction' and ${snapshot_condition_4}
    ${snapshot_condition_total}=      Evaluate
    ...  ${collect_snapshot_condition_1} or ${collect_snapshot_condition_2} or ${snapshot_condition_5}
    set test variable  ${snapshot_condition_total}

    Run keyword if    ${DSC}    Remote Test Line Teardown    alias=DSC    verify_states_stability=${True}
    FOR    ${remote_line_alias}    IN    @{REMOTE_TESTLINES_LIST}
        Remote Test Line Teardown    alias=${remote_line_alias}
    END
    #Run Keyword If    ${infomodel_started}    Collect Infomodel
    Run Keyword If    ${admin_started}
    ...  Admin Print Active Alarms    output_file=${Test Results Dir}/teardown_active_alarms.json
    ${res}    ${unexpected_alarms}    Run keyword and ignore error    watchalarm.get detected alarms
    ${empty_list}=   Create List
    ${watch_alarm_not_started}=     Run keyword And Return Status
    ...     Should Contain  ${unexpected_alarms}    WatchdogNotStarted
    ${unexpected_alarms}=   Set Variable If     ${watch_alarm_not_started}==${TRUE}
    ...     ${empty_list}   ${unexpected_alarms}
    set test variable    ${4352_exists}    FALSE
    FOR   ${item}    IN    @{unexpected_alarms}
    Run keyword if    '4352' in str("""${item}""")
    ...    Run keywords
    ...    set test variable    ${4352_exists}    TRUE
    ...    AND    Exit For LOOP
    END
    set test variable    ${6450_exists}    FALSE
    FOR   ${item}    IN    @{unexpected_alarms}
    Run keyword if    '6450' in str("""${item}""")
    ...    Run keywords
    ...    set test variable    ${6450_exists}    TRUE
    ...    AND    Exit For LOOP
    END
    ${num_unexp_alarm}    get length    ${unexpected_alarms}
    set test variable  ${num_unexp_alarm}
    set test variable  ${res}
    set test variable  ${unexpected_alarms}
    Run keyword and ignore error    Stop Watching Alarms
    Teardown All Aliases For Infomodel  imstimeout=300
    Run Keyword If      'DCAP' not in @{TEST TAGS}     Collect Syslog
    Run keyword If    ${scf_parser_started}    Teardown scf Parser
    Collect Swconfigs
    Collect RawAlarmHistory
    #Change parameter to enable Netact snapshot collection
    Log    Move directory ssh_forwarder_log to ${BTS Files}
    Run Keyword And Ignore Error    Move Directory    ${EXECDIR}/ssh_forwarder_log    ${BTS Files}
    hran_general.Hran_ta Postconditions
    Align Verdicts
    Run keyword if    'STOPONFAIL' in @{TEST TAGS} and '${TEST STATUS}' == 'FAIL'
    ...  Fatal error    Execution stopped because critical TC '${TEST NAME}' failed
    Run keyword and ignore error    interface.Common step trigger
    Get_QCID
    ${QCID_NUM}  fetch from right  ${QC_ID}  _
    Run keyword if  'passed' in '${TEST VERDICT}'
    ...  Run keyword and ignore error
    ...  Send ReP With Scf Id  ${QCID_NUM}  bts_id=${TESTLINE_NAME}  sw=${ENB_Trunk_Version}
    ${status}  ${SCF_ID}=    Run keyword and ignore error    wait until keyword succeeds
    ...  5min     5s      Get Configuration Id From Scout
    Run keyword If       ${dcap_started}==${TRUE}             Run Keywords
    ...    Stop trace by Dcap      ${SMOD2_exists}     ${dcap_status}
    ...     AND     Sleep     15s
    ...     AND     getsyslog_from_result      ${Test Results Dir}/
    Run keyword if     '${target_release}'=='SBTS00' or '${target_release}'=='SBTS00_FSM3'
    ...     detect and collect crash
    ...     ELSE IF    'DCAP' not in @{TEST TAGS} and ${snapshot_condition_total} == True     Run keywords    Admin Get Snapshot
    ...     AND    Run keyword if    '${SMOD2_exists}' == 'True' and '${4352_exists}' == 'TRUE'    Admin Get Snapshot for ESM
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    #upload snapshot to remote
    Run Keyword if  'NEED_STOP' in @{TEST TAGS}
    ...  Run Keyword And Ignore Error   truck_roll.stop_and_fix

detect and collect crash
    [Documentation]    Short description.
    ${crash_appear}=   Run keyword and ignore error   check_syslog_for_crashes  ${SUITE NAME}  ${CRASH_FILE}
    ...  ${CRASH_FILE_FULLPATH}  ${TEST NAME}  ${QC_ID}  ${UDPLogs}/
    Log To Console    ${crash_appear}[1]
    ${reset_appear}=  Run keyword and ignore error  check_for_reset  ${CRASH_FILE_FULLPATH}  ${SUITE NAME}
    ...  ${TEST NAME}  ${QC_ID}  ${UDPLogs}/
    Log To console   ${reset_appear}[1]

    ${upload_alarm}=   Run keyword if  '${res}'=='PASS' and ${num_unexp_alarm}>0
    ...  upload_unexpected_alarm  ${SUITE NAME}
    ...  ${CRASH_FILE}  ${CRASH_FILE_FULLPATH}  ${TEST NAME}  ${QC_ID}  ${unexpected_alarms}
    ...  ELSE   set variable  False

    ${cond1}    evaluate    '${crash_appear}[1]'=='NO' and '${reset_appear}[1]'=='NO'
    ${cond2}    evaluate    '${upload_alarm}' == 'True' or ${snapshot_condition_total} == ${True}
    ${total_cond}     evaluate
    ...  ${cond1} ==${False} or ${cond2} == ${True} or '{6450_exists}' == 'TRUE'
    Run keyword if   'DCAP' in @{TEST TAGS} and ${total_cond}== ${TRUE}    Log To Console
    ...   "crash,reset or unexpected alarm found,snapshot is catched in dcap"
    ...   ELSE IF    'DCAP' not in @{TEST TAGS} and ${total_cond}== ${TRUE}
    ...   Run keywords    Admin Get Snapshot
    ...   AND    Run keyword if    '${SMOD2_exists}' == 'True' and '${4352_exists}' == 'TRUE'    Admin Get Snapshot for ESM
    ...   ELSE      Log To Console    "no crash and case pass"
    set test variable  ${crash_appear_sta}  ${crash_appear}[1]
    set test variable  ${reset_appear_sta}  ${reset_appear}[1]
    ${unexp_alarm_sta}  set variable if  ${upload_alarm}  YES  NO
    ${issue_upload_status_per_tc}   Evaluate
    ...  "${crash_appear_sta}"=="YES" or "${reset_appear_sta}"=="YES" or "${unexp_alarm_sta}"=="YES"
    Run keyword if   '${issue_upload_status_per_tc}'=='True'
    ...  APPEND TO LIST  ${Issue_upload_status}  ${issue_upload_status_per_tc}

upload snapshot to remote
    [Documentation]
    ...  | 20220428 | SRAN21A | Dante He | New KW | This KW is about upload snapshot from local to server  |
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${timestamp}=    Convert To String    ${timestamp}
    set library search order  SSHLibrary
    Run Keyword  Run  cd ${Test Results Dir} && zip -r ${timestamp}-${TEST NAME}.zip ${Snapshot}/
    Open Connection     10.108.184.40      alias= snapshot
    ${output}=	  Login	   ute    ute
    SSHLibrary.Put File   ${Test Results Dir}/${timestamp}-${TEST NAME}.zip    /home/ute/SNAPSHOT
    Run Keyword  Run  cd ${Test Results Dir} && rm -rf ${Snapshot}/
    Run Keyword  Run  cd ${Test Results Dir} && rm ${Test Results Dir}/${timestamp}-${TEST NAME}.zip
    [Teardown]  SSHLibrary.Close connection

upload test_result to remote
    [Documentation]
    ...  | 20220428 | SRAN21A | dante he | New KW | This KW is about upload snapshot from local to server  |
    [Arguments]    ${testline}=${TESTLINE_NAME}
    ...    ${get_team_kw}=HAZ12
    ...    ${local_test_result}=/home/ute/test_results/
    Log    ${testline}
    ${is_singlerun}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${UTE_EXECUTION_JSON}
    Return From Keyword If    ${is_singlerun}==${False}
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${timestamp}=    Convert To String    ${timestamp}
    set library search order  SSHLibrary
    Open Connection     ${Logserver_INFO.Host}     alias=log_server
    ${output}=	  Login	   ${Logserver_INFO.USERNAME}    ${Logserver_INFO.PASSWORD}
    ${cmd}    catenate    sshpass -p ${Logserver_INFO.PASSWORD}
    ...    scp -r ${local_test_result}
    ...    ${Logserver_INFO.USERNAME}@${Logserver_INFO.Host}:/data/logs/${get_team_kw}/${TESTLINE_NAME}_${timestamp}
    OperatingSystem.Run    command=${cmd}
    ${files}    get_all_files_from_dir   ${local_test_result}    True
    FOR    ${file}    IN    @{files}
        ${new_file_path}    Replace String    ${file}    /home/ute/test_results
        ...    /data/logs/${get_team_kw}/${TESTLINE_NAME}_${timestamp}
        OperatingSystem.File Should Exist    ${new_file_path}
    END
    Log    message=The new log link: http://10.69.69.233/data/logs/${get_team_kw}/${TESTLINE_NAME}_${timestamp}
    ...    level=WARN    	console=yes
    Log    message=The test_results will be removed    level=WARN    	console=yes
    ${all_dir_in_testresult}    OperatingSystem.List Directories In Directory    ${local_test_result}
    FOR    ${d}    IN    @{all_dir_in_testresult}
        Log To Console    ${d}
        ${clear_path}    Join Path    ${local_test_result}    ${d}
        Remove Directory    ${clear_path}    recursive=${True}
    END
    [Teardown]  SSHLibrary.Close connection

Get Configuration Id From Scout
    [Timeout]  2 minutes
    [Arguments]   ${scout_testline_name}=${TESTLINE_NAME}    ${ute}=${False}
    [Documentation]  This kw is used to get scf id from scout by scout testline name
    ...    Author: Amaand
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scout_testline_name | yes | use the scout testline id ,usually is bts id |
    ...    | internal | yes | if you use CM single run or auto trigger, please set False |
    ...
    ...    | Return Value | Description |
    ...    | scout_scf_id | the internal id from scout |
    ...
    ...    Example
    ...    | Get SCF Internal Id By Scout | testline_name=6141 |
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${scout_scf_id}=   scout.request_scf   use_scout_internal_id=${ute}
    scout.teardown_scout_api
    [Return]  ${scout_scf_id}

Send ReP With Scf Id
    [Arguments]    ${qc_id}    ${scf_id}=${None}    ${bts_id}=${TESTLINE_NAME}
    ...    ${case_name}=${TEST NAME}    ${case_result}=pass    ${sw}=${ACTIVE_SW_VERSION}
    ...    ${pass_number}=${1}    ${run_number}=${1}    ${testline_name}=${TESTLINE_NAME}
    [Documentation]    This kw is used to send test result to rep with scf id
    ...    Author: amli
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | qc_id | yes | qc id of this case,if this is qc file, please input the path |
    ...    | scf_id | yes | get by keyword 'Get SCF Internal Id By Scout' |
    ...    | bts_id | yes | bts id in scout |
    ...    | case_name | yes | update case name |
    ...    | case_result | yes | this test result |
    ...    | sw | yes | the test sw |
    ...    Example
    ...    | Send ReP With Scf Id | qc_id=256752 | bts_id=6141 | case_name=OAM_Stability_4G_Site_reset_ENDC_call |
    ...    | sw=SBTS00_ENB_9999_220325_000007 |
    ...
    ${scf_id}    Run Keyword If    '${scf_id}'=='${None}'
    ...    wait until keyword succeeds  5min  5s  Get Configuration Id From Scout
    ...   scout_testline_name=${bts_id}  ute=${True}
    ...    ELSE   Set Variable    ${scf_id}
    ${pass_rate}    Evaluate    100*${pass_number}/${run_number}
    ${send_cmd}    Catenate    python ${SEND_REP_PYTHON_CODE_PATH} '${case_name}' '${case_result}'
    ...    '${sw}' '${qc_id}' '${pass_rate}%(${pass_number}/${run_number})' '${testline_name}' '${scf_id}'
    Log To Console    ${send_cmd}
    ${ret}    OperatingSystem.Run   ${send_cmd}
    Log To Console    ${ret}
    ${rep_link}    Set Variable    https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?file_hash
    Should Contain    ${ret}    ${rep_link}=

Clean VM disk space
    [Arguments]    ${alias}    &{configuration}
    [Documentation]    Wrapper function for KW used for VM cleaning.
    ...  Cleaning will be perfomrmed on /tmp and ${Temp Logs Dir}. Also
    ...    processes remaining after files deletion would be killed.
    Run keyword if    '${alias}'=='local' or '${alias}'=='Master'
    ...  Run keywords    hran_general.Clean up directory    /tmp    720    ${alias}
    ...    AND    hran_general.Clean up directory    /home/ute/btsauto/logs    240    ${alias}
    ...    AND    hran_general.Kill processes remained after files deletion on VMs /home partition    ${alias}
    ...    ELSE    Run Keywords    hran_general.Clean up directory    /tmp    720    ${alias}
    ...  host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...   ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}
    ...    AND    hran_general.Clean up directory    /home/ute/btsauto/logs    240    ${alias}
    ...  host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}
    ...    AND    hran_general.Kill processes remained after files deletion on VMs /home partition    ${alias}
    ...  host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}

Clean remoteVM disk space
    [Arguments]    ${alias}    &{configuration}
    [Documentation]    Wrapper function for KW used for remoteVM cleaning.
    ...  Cleaning will be perfomrmed on /home/ute/HZOAM/01_BTS_SW
    Run keyword if    '${alias}'=='remote'
    ...  Run keywords
    ...  hran_general.Clean up directory    /home/ute/HZOAM/01_BTS_SW/New_Trunk    480    ${alias}
    ...  host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}
    ...  AND    hran_general.Clean up directory    /home/ute/HZOAM/01_BTS_SW/SBTS24R2    480    ${alias}
    ...  host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}
    ...  AND    hran_general.Clean up directory    /home/ute/HZOAM/01_BTS_SW/Knife    480    ${alias}
    ...  host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}

Start syslog
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${smod}: <description>
    ...        ${host_ip}: <description>
    [Arguments]  ${smod}=SMOD    ${host_ip}=${None}
    Log    Trying to start syslog on ${smod}    level=INFO    console=${TRUE}
    ${syslog_started}=  Run keyword and return status
    ...    Wait until keyword succeeds    5 min    15 sec  Start Collecting BTSLog  alias=${smod}  host_ip=${host_ip}
    Set test variable    ${${smod}_syslog_started}    ${syslog_started}
    Run keyword if    ${${smod}_syslog_started}    Log    Syslog on ${smod} started    level=TRACE    console=${TRUE}
    ...    ELSE    Set test restriction    Syslog on ${smod} did not start and will not be collected during TC execution

Ensure that SMOD2 is detected inside ADMIN
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${TRUE}: <description>
    ${smods}=    taf.sbts.oam.coam.admin.Get ids for all    SMOD
    Run keyword if    len(${smods}) != 2    Fail    SMOD2 wasn't detected inside ADMIN
    [Return]    ${TRUE}

Start remote syslog
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${remote_host}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${remote_host}    ${alias}
    Start Collecting BTSLog  host_ip=${remote_host}   alias=${alias}

Collect syslog
    [Documentation]    Short description.
    Run keyword and ignore error    Run keyword if    ${SMOD1_syslog_started}    Stop Collecting BTSLog    alias=SMOD1
    Run keyword and ignore error    Run keyword if    ${SMOD2_syslog_started}    Stop Collecting BTSLog    alias=SMOD2

Start Collecting BTSLog
    [Documentation]
    ...  KW used to start collection of BTSLog logs.
    ...  | **Author:** amaand.li@nokia-sbell.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to start collection of BTSLog logs. Parameter 'host_ip' can be used to collect BTSLog
    ...  on remote VM or PC. While using this keyword BTSLog application cannot be used
    ...  otherwise collecting will fail (usually on KW 'core.Stop Collectors'). Example of error
    ...  due to BTSLog running in the background:
    ...  'ValueError: unexpected PID value observed : 22265
    ...  22266
    ...  25212
    ...  Please ensure single BTSLog collector instance at a time.
    ...  Ensure not to start or terminate BTSLog tool manually with BTSLog collector instance'
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                            |
    ...  +==============+======+========================================================================+
    ...  | host_ip      | No   | IP of host (VM/PC) on which BTSLog should to be collected.             |
    ...  |              |      | Default is: ${None}.                                                   |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | alias        | No   | Alias used for BTSLog. Default: btslog.                                |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | login        | No   | Login for host (VM/PC) on which BTSLog should to be collected.         |
    ...  |              |      | Default is: ute.                                                       |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | password     | No   | Password for host (VM/PC) on which BTSLog should to be collected.      |
    ...  |              |      | Default is: uteUTE!.                                                   |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${slave_vm_ip} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.addr
    ...     Start Collecting BTSLog  alias=btslog_slave  host_ip=${slave_vm_ip}

    [Arguments]  ${host_ip}=${None}  ${alias}=btslog  ${login}=ute  ${password}=uteUTE!
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${timestamp}=    Convert To String    ${timestamp}

    ${parameters}=    Create Dictionary
    ...    MaxSysLogFileSize=100
    ...    SysLogFileTemplate=/tmp/btslog2/SYSLOG_${alias}_UDP_${timestamp}_%0

    ${btslog_configuration}=    Create Dictionary    LOG_CONFIGURATION=${parameters}

    ${executor}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${login}
    ...  password=${password}

    Run Keyword If  '${host_ip}' != '${None}'  btslog.Create BTSLog Collector
    ...                         name=${alias}
    ...                         executor=${executor}
    ...                         btslog_configuration=${btslog_configuration}
    ...  ELSE                   btslog.Create BTSLog Collector
    ...                         name=${alias}
    ...                         btslog_configuration=${btslog_configuration}

    core.Setup Collectors    names=${alias}
    core.Start Collectors    names=${alias}
    core.Set Test Alias  ${alias}

    Log  Logs collection for BTSlog with alias=${alias} started.  console=True

Stop Collecting BTSLog
    [Documentation]
    ...  KW used to stop collection of BTSLog logs.
    ...  | **Author:** amaand.li@nokia-sbell.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to stop collection of BTSLog logs and save it in 'log_directory'
    ...  and save it in 'log_directory'. File name will have timestamp added to it
    ...  in this KW. It returns absolute path to saved file.
    ...  While using this keyword BTSLog application cannot be used
    ...  otherwise collecting will fail (usually on KW 'core.Stop Collectors'). Example of error
    ...  due to BTSLog running in the background:
    ...  'ValueError: unexpected PID value observed : 22265
    ...  Please ensure single BTSLog collector instance at a time.
    ...  Ensure not to start or terminate BTSLog tool manually with BTSLog collector instance'
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------+
    ...  | Parameter      | Man. | Description                            |
    ...  +================+======+========================================+
    ...  | log_directory  | No   | Directory where logs should be saved.  |
    ...  |                |      | Default is: ${LOG_PATH}/udp_logs.      |
    ...  +----------------+------+----------------------------------------+
    ...  | alias          | No   | Alias used for BTSLog. Has to be the   |
    ...  |                |      | same as the one used during start      |
    ...  |                |      | of logs collection. Default: btslog.   |
    ...  +----------------+------+----------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Stop Collecting BTSLog  alias=btslog_slave

    [Arguments]  ${log_directory}=${UDP Logs}  ${alias}=btslog

    ${timestamp}  Run  date +%H%M%S

    Run keyword and ignore error   core.Stop Collectors      names=${alias}
    core.Collect Collectors   names=${alias}  target_dir=${log_directory}
    Run keyword and ignore error    core.Teardown Collectors  names=${alias}

    ${btslog_exists} =  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${log_directory}/${alias}/syslog_files.tgz
    Should Be True  ${btslog_exists}
    ...  msg=BTSLog file does not exist in ${log_directory}/${alias}/syslog_files.tgz
    Return From Keyword If  not ${btslog_exists}  ${NONE}

    Run  mv ${log_directory}/${alias}/syslog_files.tgz ${log_directory}/${alias}/${alias}_UDP_${timestamp}.tgz

    Log  Logs collection for BTSLog with alias=${alias} finished.  console=True
    [Return]  ${log_directory}/${alias}_UDP_${timestamp}.tgz

Start Infomodel
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    [Arguments]    ${bts_host}=192.168.255.129
    Log    Trying to connect to infomodel (max 5 min)    level=INFO    console=${TRUE}
    ${infomodel_started}=    Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds    5 min    15 sec    _Single attempt to Start Infomodel    bts_host=${bts_host}
    Set Test Variable    ${infomodel_started}
    Run keyword if    not ${infomodel_started}    Set test blocked    Infomodel connection did not start
    Log    Connection to infomodel successfully established!    level=INFO    console=${TRUE}

_Single attempt to Start Infomodel
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    [Arguments]    ${bts_host}=192.168.255.129
    ute_admin_infomodel.Setup Infomodel    address=${bts_host}
    ...  port=443    use_ssl=True
#        admin_api_log_dir=${BTS Files}/
    ${infomodel_started}=    Run Keyword And Return Status    ute_admin_infomodel.Connect Infomodel
    Run keyword if    not ${infomodel_started}    Run keywords    ute_admin_infomodel.Teardown Infomodel
    ...    AND    Fail    Failed to start Infomodel

Collect Infomodel
    [Documentation]    Short description.
    Log    Connection to infomodel will be terminated    level=INFO    console=${TRUE}
    Save Infomodel Log    filename=${BTS Files}/IM/InfoModel_log.ims2    timeout=300
    Teardown Infomodel
    Log    Connection to infomodel terminated    level=INFO    console=${TRUE}

Start Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    ...        ${bts_port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${use_ssl}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${bts_host}=192.168.255.1    ${bts_port}=443    ${username}=Nemuadmin
    ...  ${password}=nemuuser    ${use_ssl}=TRUE    ${alias}=default
    Log    Trying to connect to admin (max 5 min)    level=INFO    console=${TRUE}
    ${admin_started}=    Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds    5 min    15 sec
    ...    taf.sbts.oam.coam.admin.Setup Admin    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}
    ...  password=${password}    use_ssl=${use_ssl}    alias=${alias}    update_interval=1000
    Set Test Variable    ${admin_started}
    Run keyword if    not ${admin_started}    Set test blocked    Admin connection did not start
    Log    Connection to admin successfully established!    level=INFO    console=${TRUE}

Start Admin_before common
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    ...        ${bts_port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${use_ssl}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${bts_host}=192.168.255.1    ${bts_port}=443    ${username}=Nemuadmin
    ...  ${password}=nemuuser    ${use_ssl}=TRUE    ${alias}=default
    Log    Trying to connect to admin (max 5 min)    level=INFO    console=${TRUE}
    ${admin_started}=    Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds    5 min    15 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}
    ...  password=${password}    use_ssl=${use_ssl}    alias=${alias}    update_interval=1000
    ...  admin_api_log_dir=${CURDIR}
    Set Test Variable    ${admin_started}
    Run keyword if    not ${admin_started}    Set test blocked    Admin connection did not start
    Log    Connection to admin successfully established!    level=INFO    console=${TRUE}

Start BTSSM On 'MSM'
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    [Arguments]    ${bts_host}=192.168.255.129
    [Timeout]    1 min
    Kill process by name    btsmanager
    ${btssm_started}=    Run Keyword And Return Status
    ...  Wait until keyword succeeds    5 min    15 sec    ute_btssm.Setup BTSSM    alias=MSM
    ...  log_path=${Temp Logs Dir}    timeout=60s    ne=${bts_host}
    Set Test Variable    ${btssm_started}
    Run keyword if    not ${btssm_started}    Set test blocked    BTSSM initialization failed

Collect BTSSM On 'MSM'
    [Documentation]    Short description.
    ute_btssm.Collect BTSSM files    unzip=True    subdirectory=${BTSFiles}/BTSSM    alias=MSM
    ute_btssm.Teardown BTSSM    alias=MSM

Start SCF Parser
    [Arguments]    ${parser_tech}=SBTS
    [Documentation]    Start SCFC Parser from library hran_file_operations with given parser technology.
    ...
    ...    *AUTHOR*
    ...    patryk.furman@nokia.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | parser_tech | No | Parser technology (UNIVERSAL, SBTS, WCDMA, LTE, GSM) |
    _Set SW_TYPE
    _Set COMMISSIONING_PATH
    Log    SCF which will be used to verify BTS (${COMMISSIONING_PATH})    console=${True}
    ${scf_parser_started}=    Setup SCFC Parser    ${COMMISSIONING_PATH}    parser_technology=${parser_tech}
    Set test variable    ${scf_parser_started}
    Run keyword if    not ${scf_parser_started}    Set test blocked    SCF Parser did not start

_Set SW_TYPE
    [Documentation]    Short description.
    ${regex}=    Set variable
    ...  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}=    Get Regexp Matches    ${ACTIVE_SW_VERSION}    ${regex}    product    postfix
    ${product}    ${postfix}=    Set variable    ${result[0]}
    ${product}=    Convert To Uppercase    ${product}
    ${postfix}=    Convert To Uppercase    ${postfix}
    Set test variable    ${SW_TYPE}    ${product}${postfix}

_Set COMMISSIONING_PATH
    [Documentation]    Short description.
    ${custom_scf_path}=    Get Variable Value    ${COMMISSIONING_PATH}    ${EMPTY}
    Return from keyword if    '${custom_scf_path}'!=''
    ${is_qt_testline}=    Run keyword and return status    Should Match Regexp    ${TESTLINE_NAME}    QT-
    Run keyword if    ${is_qt_testline}    Find QTs SCF file in robotlte configs
    ...    ELSE IF    ${TAF_CONFIG_MODEL}    Find SCF file in robotlte configs
    ...    ELSE    Find SCF file

Teardown SCF Parser
    [Documentation]    Short description.
    Log    Teardown scf Parser    level=INFO    console=${TRUE}
    Teardown SCFC Parser

Find SCF file
    [Documentation]    Short description.
    Log    Find SCF file    console=${True}
    ${COMMISSIONING_PATH}=    Get commissioning path    ${active SW version}
    Set test variable    ${COMMISSIONING_PATH}

Find QTs SCF file in robotlte configs
    [Documentation]    Short description.
    Log    Find SCF file in robotlte configs in QT way    console=${True}
    ${soft_version}=    Set Variable If    "${sbts version}"=="SBTS17"    SBTS17    SBTS00
    ${commissionings_directory}=
    ...   Set Variable    /home/ute/robotlte/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/node1
    ${files_list}=    Get All Files From Dir    ${commissionings_directory}
    ${commissioning_file}=    Filter Files List    ${files_list}    BTS_CLOUD_.*_${soft_version}.*xml
    Set test variable    ${COMMISSIONING_PATH}    ${commissionings_directory}/${commissioning_file[0]}

Find SCF file in robotlte configs
    [Documentation]    Short description.
    Log    Find SCF file in robotlte TAF configs    console=${True}
#    ${commissionings_directory}=    Set Variable
#...  /home/ute/robotlte/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/node1
    ${commissionings_directory}=    Set Variable    /home/ute/testline_configuration/${TESTLINE_NAME}/node1
    @{enb_build_split}=    Split String    ${ENB_BRANCH}    _
    Set test variable    ${COMMISSIONING_PATH}
    ...  ${commissionings_directory}/BTS_${tl.tl_cloud_topology}_${enb_build_split}[0].xml

Verify BTS states
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_BTS_status}: <description>
    ...        ${modules_check}: <description>
    ...        ${cells_check}: <description>
    ...        ${alarms_check}: <description>
    ...        ${expected_alarms}: <description>
    ...        ${ignored_alarms}: <description>
    ...        ${critical_alarms}: <description>
    ...        ${BTS_state_is_correct}: <description>
    ...        ${system_modules_working}: <description>
    ...        ${radio_modules_working}: <description>
    ...        ${cells_GSM_onair}: <description>
    ...        ${cells_WCDMA_onair}: <description>
    ...        ${cells_LTE_onair}: <description>
    ...        ${alarms_status}: <description>
    [Arguments]    ${expected_BTS_status}=OnAir    ${modules_check}=${TRUE}    ${cells_check}=${TRUE}
    ...  ${alarms_check}=${TRUE}    ${expected_alarms}=@{EMPTY}    ${ignored_alarms}=@{EMPTY}
    ...  ${critical_alarms}=@{EMPTY}    ${BTS_state_is_correct}=${FALSE}    ${system_modules_working}=${FALSE}
    ...  ${radio_modules_working}=${FALSE}    ${cells_GSM_onair}=${FALSE}    ${cells_WCDMA_onair}=${FALSE}
    ...  ${cells_LTE_onair}=${FALSE}    ${alarms_status}=FAIL
    ${BTS_state_is_correct}    ${BTS_current_status}=    Verify BTS proceduralState    ${expected_BTS_status}
    ${system_modules_working}=    Run Keyword If    ${modules_check}    Verify system modules states
    ...    ELSE    Set Variable    ${TRUE}
    ${radio_modules_working}=    Run Keyword If    ${modules_check}    Verify radio modules states
    ...    ELSE    Set Variable    ${TRUE}
    ${alds_working}=    Run Keyword If    ${modules_check}    Verify ald states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_GSM_onair}=    Run Keyword If    ${cells_check}    Verify GSM cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_WCDMA_onair}=    Run Keyword If    ${cells_check}    Verify WCDMA cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_LTE_onair}=    Run Keyword If    ${cells_check}    Verify LTE cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_NR_onair}=    Run Keyword If    ${cells_check} and ${SCF_NR}    Verify NR cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${ALL_AVAILABLE_CELLS}=    Run keyword if     '${SCF_NR}'=='False'    Admin Get ids for all cells
    ...    ELSE    Admin Get ids for all cells TAF
    Set test variable    ${ALL_AVAILABLE_CELLS}
    ${alarms_status}    ${alarms_msg}=    Run Keyword If    ${alarms_check}
    ...  Run Keyword And Ignore Error    Admin Check Active Alarms    expected_patterns=${expected_alarms}
    ...  ignored_patterns=${ignored_alarms}    critical_patterns=${critical_alarms}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...  Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction    Unexpected alarms are present: ${alarms_msg}
    ${statuses_dictionary}=    Create Dictionary
    ...  BTS_state_is_correct=${BTS_state_is_correct}    system_modules_working=${system_modules_working}
    ...  radio_modules_working=${radio_modules_working}    alds_working=${alds_working}
    ...  cells_GSM_onair=${cells_GSM_onair}    cells_WCDMA_onair=${cells_WCDMA_onair}
    ...  cells_LTE_onair=${cells_LTE_onair}    alarms_status=${alarms_status}
    ${pretty_statuses}=    Evaluate    pprint.pformat(${statuses_dictionary}, indent=4)    modules=pprint
    ${cells_count_status}=    Run Keyword And Return Status    should be empty    ${ALL_AVAILABLE_CELLS}
    Run Keyword If
    ...  '${BTS_current_status}' == 'NotCommissioned' and ${cells_count_status} and ${BTS_state_is_correct} == ${FALSE}
    ...  Set Test Blocked
    ...  Test blocked due to BTS status: NotCommissioned. There are 0 configred cells.\nSkip to teardown!
    Set Test Variable    ${states_bool}      ${BTS_state_is_correct} and ${system_modules_working}
    Set Test Variable    ${states_bool2}     ${radio_modules_working} and ${cells_GSM_onair} and ${cells_WCDMA_onair}
    Run Keyword If
    ...  ${states_bool} and ${states_bool2} and ${cells_LTE_onair} and ${alds_working} and '${alarms_status}'!='FAIL'
    ...  Set Test Variable    ${bts_verification_status}    passed
    ...  ELSE
    ...  Set Test Blocked    Test blocked due to failure of BTS initial check:\n${pretty_statuses}.\nSkip to teardown!
    [Teardown]

Verify BTS proceduralState
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_BTS_status}: <description>
    ...
    ...    Returns:
    ...        ${BTS_in_expected_status}: <description>
    ...        ${current_status}: <description>
    [Arguments]    ${expected_BTS_status}
    Log    Start BTS commissioning verification    console=${True}
    ${current_status}=    taf.sbts.oam.coam.admin.Get Mrbts State
    ${BTS_in_expected_status}=
    ...  Run keyword and return status    Should Match Regexp    ${current_status}    ${expected_BTS_status}
    Run keyword if    ${BTS_in_expected_status}
    ...  Log    BTS is in expected status (${current_status})!    console=${TRUE}
    ...    ELSE    Log    BTS has state other than expected.    console=${TRUE}
    [Return]    ${BTS_in_expected_status}    ${current_status}

Verify system modules states
    [Documentation]    Wrapper KW for checking SMOD product numbers against
    ...  SCF and comparing SMOD states with states defined in
    ...    ${SMOD_expected_states} variable
    ...
    ...    | **Author:** jaroslaw.piszczala@nokia.com
    ...    | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...    | **Released with version:** ---
    Log    Start system modules verification    console=${True}
    Run keyword if    ${scf_parser_started}    Set SCF system modules count and verify product numbers
    Run keyword and return    Verify modules    SMOD    scf_check=${scf_parser_started}

Verify radio modules states
    [Documentation]    Wrapper KW for checking RMOD product numbers against SCF and
    ...  comparing RMOD states with states defined in
    ...    ${RMOD_expected_states} variable
    ...
    ...    | **Author:** jaroslaw.piszczala@nokia.com
    ...    | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...    | **Released with version:** ---
    Log    Start radio modules verification    console=${True}
    Run keyword if    ${scf_parser_started}    Set SCF radio modules count and verify product numbers
    Run keyword and return    Verify modules    RMOD    scf_check=${scf_parser_started}

Verify ald states
    [Documentation]    Wrapper KW for comparing ALD states with states defined in ${ALD_expected_states} variable.
    ...  Because of ticket
    ...    https://jiradc.int.net.nokia.com/browse/URW-5861, productCode checking is now omitted
    ...
    ...    | **Author:** patryk.furman@nokia.com
    ...    | **Maintainer:** patryk.furman@nokia.com
    ...    | **Released with version:** 50.3
    Log    Start ALD verification    console=${TRUE}
    Run keyword and return    Verify modules    ALD    scf_check=${FALSE}

Verify ${technology} cells states
    [Documentation]    Wrapper KW for checking all RATs cells count against SCF and
    ...  comparing cells states with states defined in
    ...    ${cells_LTE_expected_states}, ${cells_WCDMA_expected_states} and ${cells_GSM_expected_states} variables
    ...
    ...    | **Author:** jaroslaw.piszczala@nokia.com
    ...    | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...    | **Released with version:** ---
    Log    Start ${technology} cells verification    console=${True}
    Run keyword if    ${scf_parser_started}    Set SCF cells count    ${technology}
    Run keyword and return    Verify cells    ${technology}    scf_check=${scf_parser_started}

Print Active And Passive SW Version
    [Documentation]    Short description.
    ${status}    ${active SW version msm}=    Run keyword and ignore error
    ...  Infomodel Get Active SW Version    module=MSM    im_param=activeBuildDescriptorId
    ${status}    ${passive SW version msm}=    Run keyword and ignore error
    ...  Infomodel Get Passive SW Version    module=MSM    im_param=passiveBuildDescriptorId
    ${expected_SW_release}=    Set variable    [A-Z]+[0-9]{2}(?=[A-Z]{0,2}[0-9]{0,1}?_[A-Z3-4]+_\\d{4}_\\d{6}_\\d{6})
    ${status}    ${sbts version}=    Run Keyword And Ignore Error
    ...  Should Match Regexp    ${active SW version msm}    ${expected_SW_release}
    Log    Active SW version (MSM): ${active SW version msm}    console=${TRUE}
    Set tags    MSM_SW_active-${active SW version msm}
    Log    Passive SW version (MSM): ${passive SW version msm}    console=${TRUE}
    Set tags    MSM_SW_passive-${passive SW version msm}
    Run keyword if    not '${status}'=='PASS'
    ...  Set Test Norun    Software is not compatible with this frame (expected ${expected_SW_release})
    Set test variable    ${active SW version}    ${active SW version msm}
    Set test variable    ${sbts version}
    Set test variable    ${passive SW version_need_compare}    ${passive SW version msm}
    ${status}    ${active SW version esm}=    Run keyword and ignore error
    ...  Infomodel Get Active SW Version    module=ESM
    Run Keyword If    '${status}'=='PASS' and '${active SW version esm}'
    ...  Run keywords    Log    Active SW version (ESM): ${active SW version esm}    console=${TRUE}
    ...    AND    Set tags    ESM_SW_active-${active SW version esm}
    ${status}    ${passive SW version esm}=
    ...  Run keyword and ignore error    Infomodel Get Passive SW Version    module=ESM
    Run Keyword If    '${status}'=='PASS' and '${passive SW version esm}'
    ...  Run keywords    Log    Passive SW version (ESM): ${passive SW version esm}    console=${TRUE}
    ...    AND    Set tags    ESM_SW_passive-${passive SW version esm}

Collect Extended TRS Logs
    [Documentation]    Short description.
    Log    Collecting extended TRS logs    console=${True}
    ${trs_logs_collected}=    Run Keyword And Return Status
    ...  Run Keywords    Set Connection Parameters    ${SMOD1['IP']}
    ...    AND    Run Command
    ...  /opt/trs/etc/collect_tech_logs.sh --filename=/ffs/run/logs/TRSExtendedLogs.tar.xz    ex_st=False
    ...    AND    Get File From System Module
    ...  source_path=/ffs/run/logs/TRSExtendedLogs.tar.xz    destination_path=${BTS Files}/
    Run Keyword If    ${trs_logs_collected}    Run Keywords    Log    Extended TRS logs collected    console=${True}
    ...    AND    Return From Keyword
    Log    Extended TRS logs not collected!    console=${True}

Collect Swconfigs
    [Documentation]    Short description.
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...  Get File From System Module    source_path=/ffs/run/swconfig.txt    destination_path=${BTS Files}/
    Run Keyword If    '${status}'=='PASS'    Log    swconfig.txt from System module collected    console=${True}
    ...    ELSE
    ...  Run Keyword    Log    swconfig.txt could not be retrieved from System Module! Error: ${result}
    ...  console=${True}
    Run Keyword If    ${SMOD2_exists}    Get Swconfig From Extension

Get Swconfig From Extension
    [Documentation]    Short description.
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...  Get File From System Module    target_ip="192.168.255.7"    source_path=/ffs/run/swconfig.txt
    ...  destination_path=${BTS Files}/    via_ip=${PC_IP2}
    Run Keyword If    '${status}'=='PASS'    Run Keywords
    ...  Log    swconfig.txt from Extension module collected    console=${True}
    ...    AND    Return From Keyword
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...  Get File From System Module    target_ip="192.168.255.1"    source_path=/ffs/run/swconfig.txt
    ...  destination_path=${BTS Files}/    via_ip=${PC_IP2}
    Run Keyword If    '${status}'=='PASS'
    ...  Run Keyword    Log    swconfig.txt from Extension module collected    console=${True}
    ...    ELSE    Run Keyword    Log    swconfig.txt could not be retrieved from Extension Module!    console=${True}

Collect RawAlarmHistory
    [Documentation]    Short description.
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...  Get File From System Module    source_path=/tmp/RawAlarmHistory.txt    destination_path=${BTS Files}/
    Run Keyword If    '${status}'=='PASS'    Log    RawAlarmHistory.txt from System module collected    console=${True}
    ...    ELSE    Run Keyword
    ...  Log    RawAlarmHistory.txt could not be retrieved from System Module! Error: ${result}    console=${True}

Set Additional Ignored Alarms
    [Documentation]    Keyword Adds Alarms definied as ADDITIONAL_IGNORED_ALARMS to GLOBALLY_IGNORED_ALARMS
    ...    https://jira3.int.net.nokia.com/browse/TAT-12375, Ignored alarms from Common Test Setup can be set in json
    ...    ADDITIONAL_IGNORED_ALARMS can be defined in job.json test parameters as list of lists
    ...    eg. "ADDITIONAL_IGNORED_ALARMS": [["faultId", "23", "Severity", "Major"]
    ...   ,[ "faultId", "4082", "alarmId", "7651"]]
    ...
    ...    | **Author:** jacek.mnich@nokia.com
    ...    | **Maintainer:** jacek.mnich@nokia.com
    ...    | **Released with version:** 53.1
    ${var_exists}    Run Keyword And Return Status    Variable should exist    ${ADDITIONAL_IGNORED_ALARMS}
    Return From Keyword If    not ${var_exists}
    Log    Setting Additional Ignored Alarms:${ADDITIONAL_IGNORED_ALARMS}    console=${True}
    ${ADDITIONAL_IGNORED_ALARMS}    Evaluate    ${ADDITIONAL_IGNORED_ALARMS}
    FOR    ${alarm}    IN    @{ADDITIONAL_IGNORED_ALARMS}
        ${ignored_alarm}    Create Dictionary
        Set To Dictionary    ${ignored_alarm}    @{alarm}
        Append To List    ${GLOBALLY_IGNORED_ALARMS}    ${ignored_alarm}
    END

Check SMOD2 in Admin
    [Arguments]    ${block_test_on_fiasco}=${TRUE}
    [Documentation]    Ensure that SMOD2 exists in Admin and set ${SMOD2_exists} variable to True
    ...
    ...    | **Full description:**
    ...    | Keyword ensures existence SMOD2 in Admin and sets True in ${SMOD2_exists} variable.
    ...   | In case SMOD2 does not exists and 'block_test_on_fiasco' variable equals True,
    ...      TC verdict is set to BLOCKED,
    ...    | or FAILED in other cases
    ...
    ...    | **Author:** sebastian.burniak@nokia.com
    ...    | **Maintainer:** sebastian.burniak@nokia.com
    ...    | **Released with version:** 56.0
    ...    | **Last changes done with version:** 58.0
    ...    +-----------------------+------+------------------------------------------------------------------+
    ...    | Parameter name | Man. | Description |
    ...    +=======================+======+==================================================================+
    ...    | block_test_on_fiasco | yes | If True, test verdict set to BLOCKED, FAILED in other cases |
    ...    +-----------------------+------+------------------------------------------------------------------+
    ${im_sync_objects}=    Query Infomodel    get list //IM_SYNC_L-1
    ${connectionState}    Infomodel Get Object Connection Status    ${im_sync_objects}[0][dist_name]
    ${smod2_detected}=    Run keyword and return status    Run keyword if    '${connectionState}'=='Connected'
    ...  Ensure that SMOD2 is detected inside ADMIN
    ...    ELSE    Run keywords    Synchronize SMODs
    ...    AND    Ensure that SMOD2 is detected inside ADMIN
    Run keyword if    ${smod2_detected}    Run keywords    Log    Two SMODs were detected    console=${TRUE}
    ...    AND    Set test variable    ${SMOD2_exists}    ${TRUE}
    ...    ELSE IF    ${block_test_on_fiasco}
    ...  Set test blocked    Extension System Module not detected despite declared in config file.
    ...    ELSE    Fail    Extension System Module not detected despite being declared in config file.

Remote Test Line Setup
    [Arguments]    ${remote_host}    ${udp_ip1}=192.168.255.126
    ...  ${remote_host2}=${EMPTY}    ${udp_ip2}=192.168.255.126    ${alias}=remote
    [Documentation]    Setup verification for remote test line
    ...
    ...    | **Author:** jaroslaw.piszczala@nokia.com
    ...    | **Maintainer:** tomasz.1.filipek@nokia.com
    ...    | **Released with version:** 62.0
    ...
    ...    | **Full description:**
    ...
    ...    | **Input Parameters:**
    ...
    ...    +------------------+------+------------------------+
    ...    | Parameter name | Man. | Description |
    ...    +==================+======+========================+
    ...    | alias | no | ute alias |
    ...    +------------------+------+------------------------+
    ...    | remote_host | no | IP to remote_host |
    ...    +------------------+------+------------------------+
    Log    ${udp_ip1}
    Log    ${udp_ip2}
    Log    Remote Test Line Setup (alias: ${alias})    console=${True}
    Set Test Variable    ${${alias}_verification_status}    failed
    Set Test Variable    ${${alias}_admin_started}    ${False}
    Set Test Variable    ${${alias}_infomodel_started}    ${False}
    Set Test Variable    ${${alias}_syslog_started}    ${False}
    Set Test Variable    ${${alias}_SMOD2_exists}    ${False}
    Set Test Variable    ${${alias}_SMOD2_syslog_started}    ${False}
    ${modules_working}=    Set variable    ${False}
    ${LTE_working}=    Set variable    ${False}
    ${WCDMA_working}=    Set variable    ${False}
    ${GSM_working}=    Set variable    ${False}
    ${alarms_status}=    Set variable    FAIL
    ${SMOD2_exists}=    Set Variable If    '${remote_host2}'!=''    ${True}    ${False}
    Set Test Variable    ${${alias}_SMOD2_exists}    ${SMOD2_exists}
    Start remote syslog    remote_host=${remote_host}    alias=${alias}
    Run Keyword If
    ...  ${${alias}_SMOD2_exists}
    ...  Start remote syslog     remote_host=${remote_host2}    alias=${alias}_SMOD2
    Start remote Admin    remote_host=${remote_host}    alias=${alias}
    ${smod_expected_states}=    Get modules expected states    SMOD    alias=${alias}
    ${rmod_expected_states}=    Get modules expected states    RMOD    alias=${alias}
    ${sm_state}=
    ...  Verify modules    SMOD    alias=${alias}    scf_check=${FALSE}    expected_states=${smod_expected_states}
    ${rf_state}=
    ...  Verify modules    RMOD    alias=${alias}    scf_check=${FALSE}    expected_states=${rmod_expected_states}
    ${modules_working}=    Evaluate    ${sm_state} and ${rf_state}
    ${LTE_expected_states}=    Get cells expected states    LTE    alias=${alias}
    ${WCDMA_expected_states}=    Get cells expected states    WCDMA    alias=${alias}
    ${GSM_expected_states}=    Get cells expected states    GSM    alias=${alias}
    ${LTE_working}=
    ...  Verify cells    LTE    scf_check=${False}    alias=${alias}    expected_states=${LTE_expected_states}
    ${WCDMA_working}=
    ...  Verify cells    WCDMA    scf_check=${False}    alias=${alias}    expected_states=${WCDMA_expected_states}
    ${GSM_working}=
    ...  Verify cells    GSM    scf_check=${False}    alias=${alias}    expected_states=${GSM_expected_states}
    ${alarms_status}    ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms    alias=${alias}
    ${statuses_dictionary}=    Create Dictionary
    ...  modules_working=${modules_working}    LTE_working=${LTE_working}    WCDMA_working=${WCDMA_working}
    ...  GSM_working=${GSM_working}    alarms_status=${alarms_status}
    ${pretty_statuses}=    Evaluate    pprint.pformat(${statuses_dictionary}, indent=4)    modules=pprint
    Run keyword if    '${alarms_status}'=='FAIL'
    ...  Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}
    ...  Set test restriction    Unexpected alarms are present on remote BTS (alias: ${alias}): ${alarms_msg}
    Start remote Infomodel    remote_host=${remote_host}    bts_host=192.168.255.129    alias=${alias}
    [Teardown]    Run Keyword If
    ...  ${modules_working} and ${LTE_working} and ${WCDMA_working} and ${GSM_working} and '${alarms_status}'!='FAIL'
    ...  Set Test Variable    ${${alias}_verification_status}    passed
    ...    ELSE    Set Test Blocked
    ...  Test blocked due to failure of ${alias} initial check:\n${pretty_statuses}.\nSkip to teardown!

Start remote Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${remote_host}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${remote_host}    ${alias}
    ${remote_admin_started}=    Run keyword and return status
    ...  taf.sbts.oam.coam.admin.Setup Admin    admin_api_log_dir=${BTS Files}    remote_host=${remote_host}    bts_host=192.168.255.129
    ...  bts_port=443    use_ssl=TRUE    update_interval=1000    alias=${alias}
    Set Test Variable    ${${alias}_admin_started}    ${remote_admin_started}

Start remote Infomodel
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${remote_host}: <description>
    ...        ${bts_host}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${remote_host}    ${bts_host}    ${alias}
    Setup infomodel    alias=${alias}    remote_host=${remote_host}
    ...  address=${bts_host}    port=443    use_ssl=True
#        admin_api_log_dir=${BTS Files}/
    ${remote_infomodel_started}=    Run Keyword And Return Status    Connect Infomodel    alias=${alias}
    Set Test Variable    ${${alias}_infomodel_started}    ${remote_infomodel_started}

Remote Test Line Teardown
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    ...        ${verify_states_stability}: <description>
    [Arguments]    ${alias}    ${verify_states_stability}=${False}
    Log    Remote Test Line Teardown (alias: ${alias})    console=${True}
    ${ims_path}=    Set variable    ${BTS Files}/IM/${alias}.ims2
    Run keyword if    ${${alias}_infomodel_started}    Save infomodel log
    ...  filename=${ims_path}    timeout=300    alias=${alias}
    Run keyword if
    ...  ${${alias}_infomodel_started} and ${verify_states_stability} and '${${alias}_verification_status}'=='passed'
    ...  Verify Remote BTS States After Test Case    ims_path=${ims_path}    alias=${alias}
    Run keyword if    ${${alias}_infomodel_started}    Teardown Infomodel    alias=${alias}
    Run keyword if    ${${alias}_SMOD2_syslog_started}    Collect syslog from ${alias}_SMOD2
    Run keyword if    ${${alias}_syslog_started}    Collect syslog from ${alias}

Verify Remote BTS States After Test Case
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ims_path}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${ims_path}    ${alias}
    Log    Verify remote BTS states after test case (alias: ${alias})    console=${True}
    ${alarms_status}    ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms    alias=${alias}
    Run keyword if    '${alarms_status}'=='FAIL'    Set test failed
    ...  Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction
    ...   Unexpected alarms are present on remote BTS (alias: ${alias}): ${alarms_msg}
    ${remote_SMODS}=    taf.sbts.oam.coam.admin.Get Ids For All    SMOD    alias=${alias}
    ${remote_RMODS}=    taf.sbts.oam.coam.admin.Get Ids For All    RMOD    alias=${alias}
    ${remote_CELLS_L}=    taf.sbts.oam.coam.admin.Get Ids For All    LNCEL    alias=${alias}
    ${remote_CELLS_W}=    taf.sbts.oam.coam.admin.Get Ids For All    WNCEL    alias=${alias}
    ${remote_CELLS_G}=    taf.sbts.oam.coam.admin.Get Ids For All    GNCEL    alias=${alias}
    Initialize ims2 validator    ${ims_path}    alias=${alias}
    FOR    ${smod}    IN    @{remote_SMODS}
        Log    ${smod}
        Fail if ims2 object change    ${smod}    administrativeState    Unlocked
        Fail if ims2 object change    ${smod}    operationalState    Enabled
        Fail if ims2 object change    ${smod}    availabilityStatus    Online
    END
    FOR    ${rmod}    IN    @{remote_RMODS}
        Log    ${rmod}
        Fail if ims2 object change    ${rmod}    administrativeState    Unlocked
        Fail if ims2 object change    ${rmod}    operationalState    Enabled
        Fail if ims2 object change    ${rmod}    availabilityStatus    Online
        Fail if ims2 object change    ${rmod}    blockingState    Unblocked
    END
    FOR    ${cell}    IN    @{remote_CELLS_L}
        Log    ${cell}
        Fail if ims2 object change    ${cell}    administrativeState    Unlocked
        Fail if ims2 object change    ${cell}    operationalState    Enabled
        Fail if ims2 object change    ${cell}    availabilityStatus    Online
        Fail if ims2 object change    ${cell}    blockingState    Unblocked
    END
    FOR    ${cell}    IN    @{remote_CELLS_W}
        Fail if ims2 object change    ${cell}    operationalState    Enabled
        Fail if ims2 object change    ${cell}    availabilityStatus    Online
        Fail if ims2 object change    ${cell}    blockingState    Unblocked
        Fail if ims2 object change    ${cell}    usageState    Active
    END
    FOR    ${cell}    IN    @{remote_CELLS_G}
        Fail if ims2 object change    ${cell}    administrativeState    Unlocked
        Fail if ims2 object change    ${cell}    operationalState    Enabled
        Fail if ims2 object change    ${cell}    availabilityStatus    Online
        Fail if ims2 object change    ${cell}    blockingState    Unblocked
        Fail if ims2 object change    ${cell}    usageState    Active
    END
    Fail if ims2 event occur    event=reset    alias=${alias}
    Fail if ims2 event occur    event=create /MRBTS-*/RAT-*/FRI-*/ALARM-* [alarmSeverity=Critical]    alias=${alias}

Verify Configuration And Set Up Remote Test Line
    [Arguments]    ${alias}
    [Documentation]    Helper for KW Remote Test Line Setup which checks if selected test line is well configured
    ...  (exists in given dictionary and has the key "PC_IP1") and if it is, it starts setup
    ${SMOD1_configured}    ${pc_ip1}=    Run keyword and ignore error
    ...  Get from dictionary    ${REMOTE_TESTLINES['${alias}']}    PC_IP1
    Run keyword if    not '${SMOD1_configured}'=='PASS'    Run Keywords    Log
    ...  There is no PC_IP1 defined for ${alias} in REMOTE TESTLINES dict    console=${True}
    ...    AND    Return From Keyword
    ${udp_ip1_configured}    ${udp_ip1}=    Run keyword and ignore error
    ...  Get from dictionary    ${REMOTE_TESTLINES['${alias}']}    UDP_IP1
    ${udp_ip1}=    Set variable if    '${udp_ip1_configured}'=='PASS'    ${udp_ip1}    192.168.255.126
    ${SMOD2_configured}    ${pc_ip2}=    Run keyword and ignore error
    ...  Get from dictionary    ${REMOTE_TESTLINES['${alias}']}    PC_IP2
    ${pc_ip2}=    Set variable if    '${SMOD2_configured}'=='PASS'    ${pc_ip2}    ${EMPTY}
    ${udp_ip2_configured}    ${udp_ip2}=    Run keyword and ignore error
    ...  Get from dictionary    ${REMOTE_TESTLINES['${alias}']}    UDP_IP2
    ${udp_ip2}=    Set Variable If    '${udp_ip2_configured}'=='PASS'    ${udp_ip2}    192.168.255.126
    Remote Test Line Setup    remote_host=${pc_ip1}
    ...  udp_ip1=${udp_ip1}    remote_host2=${pc_ip2}    udp_ip2=${udp_ip2}    alias=${alias}

Collect Snapshot From Remote Test Lines
    [Documentation]    Short description.
    FOR    ${remote_line_alias}    IN    @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Get Snapshot From Remote Test Line    ${remote_line_alias}
    END

Verify Configuration And Get Snapshot From Remote Test Line
    [Arguments]    ${alias}
    [Documentation]    Helper for KW Remote Testline Snapshot which checks if selected test line is well
    ...  configured (exists in given dictionary and has the key "PC_IP1") and if it is, it starts this KW
    ${SMOD1_configured}    ${pc_ip1}=    Run keyword and ignore error
    ...  Get from dictionary    ${REMOTE_TESTLINES['${alias}']}    PC_IP1
    Run keyword if    not '${SMOD1_configured}'=='PASS'    Return From Keyword
    Admin Get Snapshot Remotely Via Admin API    bts_host=192.168.255.129    remote_host=${pc_ip1}
    ...  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}    alias=${alias}
    ${SMOD2_configured}    ${pc_ip2}=    Run keyword and ignore error
    ...  Get from dictionary    ${REMOTE_TESTLINES['${alias}']}    PC_IP2
    Run keyword if    not '${SMOD2_configured}'=='PASS'    Return From Keyword
    Admin Get Snapshot Remotely Via Admin API
    ...  bts_host=192.168.255.119    remote_host=${pc_ip2}
    ...  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}    alias=${alias}_SMOD2

Get cells expected states
    [Arguments]    ${technology}    ${alias}=DSC
    [Documentation]    Get cells expected states in particular technology for remote host
    ...
    ...    | **Author:** sebastian.burniak@nokia.com
    ...    | **Maintainer:** sebastian.burniak@nokia.com
    ...    | **Released with version:** 71.0
    ...
    ...    | **Full description:**
    ...    | Keyword added for DSC and carrier aggregation feature. In case if remote host
    ...    | (one or more) has different expected state than tested one, there is a need to
    ...    | declare new variables. According to alias for remote host ('DSC' for DSC feature)
    ...    | variables in .json file should look like:
    ...    | {{{ "test": "LOGS_Snapshot",
    ...    | "timeout": 14400,
    ...    | "runs": 1,
    ...    | "DSC": true,
    ...    | "filename": "/home/ute/btsauto/hran_ta/testsuite/SBTS/LOGS/LOGS_Snapshot.robot",
    ...    | "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked,
    ...   operationalState = Enabled, availabilityStatus = Degraded, blockingState = Unblocked",
    ...    | "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded,
    ...   blockingState = Unblocked, usageState = Active",
    ...    | "cells_GSM_expected_states": "administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...  availabilityStatus=Degraded, blockingState=Unblocked, usageState=Active",
    ...    | "DSC_cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...  availabilityStatus = Online, blockingState = Unblocked",
    ...    | "DSC_cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Online,
    ...  blockingState = Unblocked, usageState = Active",
    ...    | "DSC_cells_GSM_expected_states": "administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...  blockingState=Unblocked, usageState=Active"
    ...    | }}}
    ...
    ...    | **Input Parameters:**
    ...
    ...    +------------------+------+-------------------------------------+
    ...    | Parameter name | Man. | Description |
    ...    +==================+======+=====================================+
    ...    | technology | yes | Cells technology to be checked |
    ...    +------------------+------+-------------------------------------+
    ...    | alias | no | remote host alias, default DSC |
    ...    +------------------+------+-------------------------------------+
    ${variable_exist}=    Run keyword and Return status
    ...   Variable should exist    ${${alias}_cells_${technology}_expected_states}
    Run keyword if    ${variable_exist}    Return from keyword    ${${alias}_cells_${technology}_expected_states}
    ...    ELSE    Return from keyword    ${cells_${technology}_expected_states}

Get modules expected states
    [Arguments]    ${class_name}    ${alias}=DSC
    [Documentation]    Get modules expected states for remote host
    ...
    ...    | **Author:** sebastian.burniak@nokia.com
    ...    | **Maintainer:** sebastian.burniak@nokia.com
    ...    | **Released with version:** 71.0
    ...
    ...    | **Full description:**
    ...    | Keyword added for DSC and carrier aggregation feature. In case if remote host
    ...    | (one or more) has different expected state than tested one, there is a need to
    ...    | declare new variables. According to alias for remote host ('DSC' for DSC feature)
    ...    | variables in .json file should look like:
    ...    | {{{ "test": "LOGS_Snapshot",
    ...    | "timeout": 14400,
    ...    | "runs": 1,
    ...    | "DSC": true,
    ...    | "filename": "/home/ute/btsauto/hran_ta/testsuite/SBTS/LOGS/LOGS_Snapshot.robot",
    ...    | "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...   availabilityStatus = Degraded, blockingState = Unblocked",
    ...    | "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded,
    ...  blockingState = Unblocked, usageState = Active",
    ...    | "cells_GSM_expected_states": "administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...  availabilityStatus=Degraded, blockingState=Unblocked, usageState=Active",
    ...    | "DSC_SMOD_expected_states": "administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ...  blockingState=Unblocked, usageState=Active"
    ...    | }}}
    ...
    ...    | **Input Parameters:**
    ...
    ...    +------------------+------+-------------------------------------+
    ...    | Parameter name | Man. | Description |
    ...    +==================+======+=====================================+
    ...    | class_name | yes | BTS module class name SMOD or RMOD |
    ...    +------------------+------+-------------------------------------+
    ...    | alias | no | remote host alias, default DSC |
    ...    +------------------+------+-------------------------------------+
    ${variable_exist}=    Run keyword and Return status
    ...  Variable should exist    ${${alias}_${class_name}_expected_states}
    Run keyword if    ${variable_exist}    Return from keyword    ${${alias}_${class_name}_expected_states}
    ...    ELSE    Return from keyword    ${${class_name}_expected_states}

SW update to Target Build
    [Documentation]    The keyword used for update sw to target build (build for single run, via variable ${ENB_BUILD})
    ${vars}=    Get Variables
    Log Dictionary    ${vars}
    ${sw_update_needed}=    Run keyword and return status
    ...    Dictionary Should Contain Key    ${vars}    \${ENB_BUILD}
    Return From Keyword If    ${sw_update_needed}==${FALSE}
    Log   ${ENB_Trunk_Version} ${ENB_BUILD}
    ${ENB_Trunk_Version_tmp}=   Fetch From Right   ${ENB_Trunk_Version}     _ENB_
    ${ENB_BUILD_tmp}=   Fetch From Right    ${ENB_Trunk_Version}    _ENB_
    ${sw_update_needed}=    Set Variable If
    ...    '${ENB_Trunk_Version_tmp}'=='${ENB_BUILD_tmp}'    ${FALSE}    ${sw_update_needed}
    Return From Keyword If    ${sw_update_needed}==${FALSE}
    Log to Console    Sw update to ${ENB_BUILD}
    ${SW_path_package}       Download_Specify_Build_By_Aria    ${ENB_BUILD}    Basic    ${SW_path}
    ${Target SW dir}=    Evaluate    os.path.dirname('${SW_path_package}')    modules=os
	set test variable    ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    Set Test Variable    ${ENB_Trunk_Version}    ${ENB_BUILD}
