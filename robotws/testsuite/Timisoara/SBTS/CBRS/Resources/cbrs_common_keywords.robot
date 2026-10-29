*** Settings ***
Documentation    Description:  CBRS Library with most common use keywords

Library    Collections
Library    DateTime
Library    OperatingSystem
Library    Process
Library    SeleniumLibrary
Library    SSHLibrary     timeout=60s
Library    String
Library    taf.config.scf
Library    taf.hw.pdu
Library    taf.sbts.oam.coam.admin
Library    taf.sw.dcap.rd   WITH NAME    dcap
Library    taf.sw.scout    WITH NAME    scout
Library    ute_admin_infomodel
Library    ute_btssm
Library    ute_syslog
Library    ute_tshark
Library    ute_ue
Library    XML    use_lxml=True

Resource    cbrs_certificates_insta.robot
Resource    cbrs_certificates_openssl.robot
Resource    cbrs_logs_alarms.robot
Resource    cbrs_logs_dcap.robot
Resource    cbrs_sas_common.robot

Library    admin_alarms.py    # TODO: Replace by Łukaszowy solution
Library    lib_NSP.py         # TODO: Replace by Łukaszowy solution
Library    cbrs_common_keywords.py

Resource    taf/rfrl/common_resources/common_step/interface.robot     # TODO: Check missing file

Variables    Configuration/testlines.yaml
Variables    Selenium/Insta.py
Variables    Selenium/DP.py


*** Keywords ***
Suite Precondition
    [Documentation]  Description:           Mandatory KW - preparing test suite parameters${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST                   # connection alias
    ...          ${CBSD_check_alias}=CBSD_Check     # ??

    ${logs_dir_path}  Create Suite Logs Dir
    Get Testline ID
    Run Keyword And Ignore Error  Switch Power Outlet Of BTS Radio Units  action=power_on
    Set Suite Variable  ${SUITE_LOGS_DIR_PATH}  ${logs_dir_path}
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.setup_admin  192.168.255.129
    ...  name=${alias}  admin_api_log_dir=${logs_dir_path}/admin_api_log
    Get Current SCF File  local_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  file_name=${alias}_SCFC_Before_Suite.xml  export_type=configuration  connection=${alias}
    Apply CBRS Debug Log Flags
    Get SAS Gerrit Repository
    Setup OpenSSL Certifier
    Prepare And Install CBRS Certificates on BTS    alias=${alias}
    Prepare And Install Certificates on SASSim
    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Setup Infomodel
	...  address=192.168.255.129  port=443  timeout=60  alias=${CBSD_check_alias}
    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Connect Infomodel  alias=${CBSD_check_alias}
    ${enb_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    ${cbsd_r_list}  Query Infomodel  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-*
    ...  timeout=30  alias=${CBSD_check_alias}
    ${cbsd_count}  Get Length  ${cbsd_r_list}
    Set Suite Variable  ${SUM_OF_CBSDS}  ${cbsd_count}
    Synchronize Time Between VM And eNB In Case Of Difference  alias=${CBSD_check_alias}
    ute_admin_infomodel.Teardown Infomodel  alias=${CBSD_check_alias}
    Run Keyword And Ignore Error  Show Current Ute Name


Suite Precondition For Second Enb
    [Documentation]  Description:           Mandatory KW - preparing test suite parameters for 2nd ENB       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_2ND
    ...          ${CBSD_check_alias}=CBSD_Check

    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.setup_admin  name=${alias}
    ...  remote_host=${testlines.${testline_id}.node2.vm_ip}  remote_host_password=${credentials.vm_pass}
    ...  admin_api_log_dir=${SUITE_LOGS_DIR_PATH}/admin_api_log_enb2
    Get Current SCF File  local_dir_path=${SUITE_LOGS_DIR_PATH}  file_name=${alias}_SCFC_Before_Suite.xml
    ...  export_type=configuration  connection=${alias}
    Prepare And Install CBRS Certificates on BTS  alias=${alias}
    Apply CBRS Debug Log Flags  enb_hostname=${testlines.${testline_id}.node2.mplane_ip_addr}    alias=${alias}
    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Setup Infomodel
    ...  address=${testlines.${testline_id}.node2.mplane_ip_addr}  port=443  timeout=60  alias=${CBSD_check_alias}
    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Connect Infomodel  alias=${CBSD_check_alias}
    ${enb_id}  Set Variable  ${testlines.${testline_id}.node2.enb_id}

    ${is_ltebts}  Run Keyword And Return Status  Query Infomodel
    ...  query=check /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-*    timeout=30    alias=${CBSD_check_alias}
    ${cbsd_r_list}  Run Keyword And Return If  ${is_ltebts}  Query Infomodel
    ...  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-*    timeout=30    alias=${CBSD_check_alias}
    ${is_nrbts}  Run Keyword And Return Status  Query Infomodel
    ...  query=check /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-${enb_id}/NRCBSD_R-*    timeout=30    alias=${CBSD_check_alias}
    ${cbsd_r_list}  Run Keyword And Return If  ${is_nrbts}  Query Infomodel
    ...  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-${enb_id}/NRCBSD_R-*    timeout=30    alias=${CBSD_check_alias}

    ${cbsd_count}  Get Length  ${cbsd_r_list}
    ute_admin_infomodel.Teardown Infomodel  alias=${CBSD_check_alias}
    Set Suite Variable  ${SUM_OF_CBSDS_FOR_SEC_ENB}  ${cbsd_count}


Suite Postcondition
    [Documentation]  Description:           Mandatory KW - closing opened connections${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    SSHLibrary.Close All Connections
    taf.sbts.oam.coam.admin.teardown_admin  connection=${alias}
    Run Keyword And Ignore Error  Switch Power Outlet Of BTS Radio Units  action=power_off
    Run Keyword And Ignore Error  Copy OpenSSL Workspace To Suite Logs Directory
    Run Keyword And Ignore Error  Copy Logs To NescRotta


Suite Postcondition For Second Enb
    [Documentation]  Description:           Mandatory KW - closing opened connections for 2nd ENB       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_2ND       # connection alias

    SSHLibrary.Close All Connections
    taf.sbts.oam.coam.admin.Teardown Admin  connection=${alias}


Test Precondition
    [Documentation]  Description:           Mandatory KW - preparing test case parameters${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias
    ...          ${clean_bts}=false     # if true there will be recommissioned SCF gathered before test

    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Setup Infomodel
	...  address=192.168.255.129  port=443  timeout=60  alias=${alias}
    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Connect Infomodel  alias=${alias}
    ${test_logs_dir_path}  Get Test Logs Dir Path  ${SUITE_LOGS_DIR_PATH}
    Set Test Variable  ${TEST_LOGS_DIR_PATH}  ${test_logs_dir_path}
    Start Logging  logs_dir_path=${test_logs_dir_path}
    IF  '${clean_bts}' != 'false' or '${PREV TEST STATUS}'=='FAIL'
        Wait Until BTS Is Not Busy
        Wait Until Keyword Succeeds  10x  30s  taf.sbts.oam.coam.admin.Perform Commissioning
        ...  bts_id=${testlines.${testline_id}.enb_id}
        ...  scf_file=${SUITE_LOGS_DIR_PATH}RAT_1ST_SCFC_Before_Suite.xml
        ...  connection=${alias}
    END
    ${enb_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    Wait Until BTS Is Not Busy
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  10x  10s  scout.Setup Scout  ${ute_name}


Test Precondition For Second Enb
    [Documentation]  Description:           Mandatory KW - preparing test case parameters for 2nd ENB       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${clean_bts}=true      # if true there will be recommissioned SCF gathered before test
    ...          ${alias}=RAT_2ND       # connection alias

    Start Logging On Second eNB  logs_dir_path=${TEST_LOGS_DIR_PATH}
    IF  '${clean_bts}' != 'false'
        taf.sbts.oam.coam.admin.Perform Commissioning
        ...  bts_id=${testlines.${testline_id}.node2.enb_id}
        ...  scf_file=${SUITE_LOGS_DIR_PATH}RAT_2ND_SCFC_Before_Suite.xml
        ...  skip_parameter_relation=True
        ...  connection=${alias}
        ...  timeout=360
    END


Test Postcondition
    [Documentation]  Description:           Mandatory KW - closing opened connections${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    ${enb_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    Teardown All Aliases For Tshark
    Kill All SAS Processes
    Run Keyword And Continue On Failure  Check If Cells Are Disabled  enb_id=${enb_id}    timeout=720s
    Stop Logging  logs_dir_path=${test_logs_dir_path}
    ute_admin_infomodel.Teardown Infomodel  alias=${alias}
    Common Testing Actions
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  10x  10s  scout.Request Scf
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  10x  10s  scout.Teardown Scout Api


Test Postcondition For Second Enb
    [Documentation]  Description:           Mandatory KW - closing opened connections for 2nd ENB       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_2ND       # connection alias

    Stop Logging On Second eNB  logs_dir_path=${TEST_LOGS_DIR_PATH}
    Teardown All Aliases For Tshark
    ute_admin_infomodel.Teardown Infomodel  alias=${alias}


Required CBSD Status Should Be Reached
    [Documentation]  Description:           Check if given cbsdRegistrationState is reached on enb by Infomodel Query${\n}
    ...              Return:                cbsdRegistrationState status - true/false${\n}
    ...              Output:                { ${boolean} }${\n}
    ...              Author:                aleksandra.dagiel@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${expected_status}     # expected cbsdRegistrationState to compare
    ...          ${enb_id}              # testline id
    ...          ${alias}=RAT_1ST       # connection alias
    [Timeout]  60s

    ${status}  ute_admin_infomodel.Query Infomodel
    ...  query=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-* is [cbsdRegistrationState=${expected_status}]
    ...  timeout=30  alias=${alias}
    Log To Console  CBSD status - ${expected_status} reached: ${status}

    RETURN  ${status}


No Alarm Except Allowed Should Appear On EnB
    [Documentation]  Description:           Waiting for alarms that are not allowed to disappear. List of alarms should exist in init file.${\n}
    ...                                     The list name should be RAT_*_ALLOWED_ALARM, where * is RAT taken into consideration${\n}
    ...                                     (ex. RAT_1ST_ALLOWED_ALARMS, RAT_2ND_ALLOWED_ALARMS).${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                aleksandra.dagiel@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    @{allowed_alarms}  Set Variable  ${enb_allowed_alarms}
    Wait Until Keyword Succeeds  20x  10s
    ...  Admin Alarms Get And Check  mandatory=${EMPTY}  allowed=${allowed_alarms}  alias=${alias}


Load JSON From File
    [Documentation]  Description:           Convert JSON data to Dictionary${\n}
    ...              Return:                Converted data from JSON file${\n}
    ...              Output:                { &{dictionary} }${\n}
    ...              Author:                unknown${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${json_filepath}       # path to JSON input file

    ${file}  OperatingSystem.Get File  ${json_filepath}
    ${json}  Evaluate  json.loads('''${file}''')   json

    RETURN  ${json}


Get Parameter From Infomodel
    [Documentation]  Description:           Keyword gets parameter from infomodel independently from structure of object${\n}
    ...                                     Works only for one object, dont use * in dist_name${\n}
    ...                                     Also works on regex. Don't use .+ and .*${\n}
    ...              Return:                List of fetched parameters from infomodel${\n}
    ...              Output:                { @{string} }${\n}
    ...              Author:                krystian.gordziejewski@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${dist_name}                       # ??
    ...          ${regex_parameter}                 # ??
    ...          ${allow_negative_results}=False    # if false then KW fail when parameter not found
    ...          ${alias}=RAT_1ST                   # connection alias

    @{parameters}  Create List
    ${object}  Query Infomodel  query=get object ${dist_name}  alias=${alias}  allow_negative_result=${allow_negative_results}
    ${length}  Get Length  '${object}'
    IF  ${allow_negative_results}  Return From Keyword If  ${length}==6  ${object}
    ${string}  Convert To String  ${object}
    ${matches}  Get Regexp Matches  ${string}  (?<=')${regex_parameter}': ([^,]|u'|/|\\s|\\w|-|\\d|\\.|\\[.*\\]|\\:|\\(|\\)|\\+)+
    FOR  ${element}  IN  @{matches}
        ${matches}  Get Regexp Matches  ${element}  (?<=..:\\s|:\\su')(/|\\/|'|\\s|\\w|-|\\d|\\.|\\[.*\\]|\\:|\\(|\\)|\\+)+
        Remove Values From List  ${matches}  u
        Append To List  ${parameters}  @{matches}
    END
    ${length}  Get Length  ${parameters}
    ${parameter}  IF  ${length}==1  Get From List  ${parameters}  0
    ${parameter_string}  Remove String  ${parameter}    '
    Return From Keyword If  ${length}==1  ${parameter_string}

    RETURN  ${parameters}


Disable CBRS Feature On eNB
    [Documentation]  Description:           Disable CBRS feature on ENB by changing requred parameters${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                albert.sakowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST                                       # connection alias
    ...          ${target_enb}=${testlines.${testline_id}.enb_id}       # ??

    Replace Variables In File  file_path=${CURDIR}/Delta/actCbrs_actCbrsMobEnh_disable_${SUM_OF_CBSDS}xCBSD.json
    ...  file_destination=${OUTPUT_DIR}/actCbrs_disable.json  enb_id=${target_enb}

    Wait Until Keyword Succeeds  30x  10s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  Perform Delta Recommissioning  ${OUTPUT_DIR}/actCbrs_disable.json  connection=${alias}


Disable CBRS Feature On gNB
    [Documentation]  Description:           Disable CBRS feature on gNB by changing requred parameters${\n}
    ...              Return:                none                                                      ${\n}
    ...              Output:                {}                                                        ${\n}
    ...              Author:                aleksandra.chudzik@nokia.com                              ${\n}
    ...              Maintainer:            CBRS Team                                                 ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias
    ...          ${target_gnb}=${testlines.${testline_id}.enb_id}    # target gNB
    ...          ${target_gnb_mrbts}=${NONE}    # target gNB mrbts_id

    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${target_gnb_mrbts}
    IF  ${status}
        ${mrbts_id}  Set Variable  ${target_gnb_mrbts}
    ELSE
        ${mrbts_id}  Set Variable  ${target_gnb}
    END
    Replace Variables In File  ${CURDIR}/Delta/actNrCbrs_disable.json
    ...  ${OUTPUT_DIR}/actNrCbrs_disable.json  enb_id=${target_gnb}  mrbts_id=${mrbts_id}

    Wait Until Keyword Succeeds  30x  10s  Run Keywords
    ...  Wait Until BTS Is Not Busy  alias=${alias}  AND
    ...  Perform Delta Recommissioning  ${OUTPUT_DIR}/actNrCbrs_disable.json  connection=${alias}


Enable CBRS Feature On eNB
    [Documentation]  Description:           Enable CBRS feature on ENB by changing requred parameters, work for AZQC and AEQM${\n}
    ...                                     Radio AEQM did not support actCbrsEnhMeas${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                albert.sakowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST                                       # connection alias
    ...          ${target_enb}=${testlines.${testline_id}.enb_id}       # ??
    ...          ${actCbrsEnhMeas}=true                                 # enhanced measure on/off

    ${AEQM_present}  Run Keyword And Return Status
    ...  Query Infomodel  query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]    timeout=30    alias=RAT_1ST

    IF  '${AEQM_present}'=='True'
        Replace Variables In File
        ...  file_path=${CURDIR}/Delta/actCbrs_actCbrsMobEnh_enable_${SUM_OF_CBSDS}xCBSD.json
        ...  file_destination=${OUTPUT_DIR}/actCbrs_enable.json  enb_id=${target_enb}  actCbrsEnhMeas=false
    ELSE
        Replace Variables In File
        ...  file_path=${CURDIR}/Delta/actCbrs_actCbrsMobEnh_enable_${SUM_OF_CBSDS}xCBSD.json
        ...  file_destination=${OUTPUT_DIR}/actCbrs_enable.json  enb_id=${target_enb}  actCbrsEnhMeas=${actCbrsEnhMeas}
    END
    Wait Until Keyword Succeeds  30x  10s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  Perform Delta Recommissioning  ${OUTPUT_DIR}/actCbrs_enable.json  connection=${alias}

    Check If S1 Link Is Available  enb_id=${target_enb}  alias=${alias}


Enable CBRS Feature On gNB
    [Documentation]  Description:           Enable CBRS feature on gNB by changing requred parameters${\n}
    ...              Return:                none                                                     ${\n}
    ...              Output:                {}                                                       ${\n}
    ...              Author:                aleksandra.chudzik@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                                ${\n}
    [Arguments]  ${alias}=RAT_1ST    # connection alias
    ...          ${target_gnb}=${testlines.${testline_id}.enb_id}    # target gNB
    ...          ${target_gnb_mrbts}=${NONE}                            # target gNB mrbts_id

    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${target_gnb_mrbts}
    IF  ${status}
        ${mrbts_id}  Set Variable  ${target_gnb_mrbts}
    ELSE
        ${mrbts_id}  Set Variable  ${target_gnb}
    END

    Replace Variables In File  ${CURDIR}/Delta/actNrCbrs_enable.json
    ...  ${OUTPUT_DIR}/actNrCbrs_enable.json  enb_id=${target_gnb}  mrbts_id=${mrbts_id}

    Wait Until Keyword Succeeds  40x  5s  Run Keywords
    ...  Wait Until BTS Is Not Busy  alias=${alias}  AND
    ...  Perform Delta Recommissioning  ${OUTPUT_DIR}/actNrCbrs_enable.json  connection=${alias}


Change Swconfig Flag
    [Documentation]  Description:           Add or change value of flag in swconfig.txt file on ENB${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                pawel.rokicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${flag}                # flag name
    ...          ${value}               # flag value
    ...          ${enb_hostname}=192.168.255.129    #?? Constant? // add to testlines.yaml ?
    ...          ${enb_username}=toor4nsn           #?? ${credentials.enb_username} ? (testlines.yaml)
    ...          ${enb_password}=oZPS0POrRieRtu     #?? ${credentials.enb_password} ?

    #TODO: Check arguments
    SSHLibrary.Open Connection  ${enb_hostname}
    SSHLibrary.Login  ${enb_username}  ${enb_password}
    SSHLibrary.Execute command  sed -i '/^${flag}/d' /ffs/run/swconfig.txt
    SSHLibrary.Execute command  echo "\n${flag}=${value}" >> /ffs/run/swconfig.txt
    SSHLibrary.Close Connection


Check Cell Operational State
    [Documentation]  Description:           Check if cells are in operational state${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                pawel.rokicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${cell_state}          # expected state
    ...          ${cell_id}             # cell id
    ...          ${alias}=RAT_1ST       # connection alias

    ute_admin_infomodel.Query infomodel
    ...  query=/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell_id} is [stateInfo.operationalState=${cell_state}]
    ...  timeout=30  alias=${alias}


Replace Variables In File
    [Documentation]  Description:           ??${\n}
    ...              Return:                ??${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                unknown${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${file_path}           # ??
    ...          ${file_destination}    # ??
    ...          &{variables}           # ??

    ${file}  OperatingSystem.Get File  ${file_path}
    ${keys}  Get Dictionary Keys  ${variables}
    FOR  ${key}  IN  @{keys}
        ${temp_string}  Convert To String  ${variables['${key}']}
        ${file}  Replace String  ${file}  {${key}}  ${temp_string}
    END
    OperatingSystem.Create File  path=${file_destination}  content=${file}

    RETURN  ${file_destination}


Sleep And Display Progress
    [Documentation]  Description:           Sleep and display progress in console${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                bartosz.rutkowski@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${waiting_time}        # value of time to wait
    ...          ${unit}=sec            # unit time to wait d/h/m/s/ms

    FOR  ${i}  IN RANGE  ${waiting_time}
        Log To Console  \rSleeping through ${i} of ${waiting_time} ${unit}  no_newline=true
        Sleep  1${unit}
    END
    Log  ${\n}  console=true


Create Suite Logs Dir
    [Documentation]  Description:           Add or change value of flag in swconfig.txt file on ENB${\n}
    ...              Return:                Path to logs directory${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}

    ${current_date}  Get Current Date  exclude_millis=yes
    ${current_date}  Replace String  ${current_date}  ${SPACE}    _
    ${current_date}  Replace String  ${current_date}  :    -
    ${current_suite_name}  Replace String  ${SUITENAME}  ${SPACE}    _
    ${suite_logs_dir_path}  Set Variable  ${OUTPUT_DIR}/${current_suite_name}_${current_date}/

    RETURN  ${suite_logs_dir_path}\


Add CBRS Certificates
    [Documentation]  Description:           Add CBRS certificate files to ENB${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${enb_hostname}=192.168.255.129    # BTS ip

    ${sas_repo}  Set Variable  /home/ute/SASSimRepo/uri/test/py/tools/SASSim

    SSHLibrary.Open Connection  ${enb_hostname}
    SSHLibrary.Login  ${credentials.enb_username}  ${credentials.enb_password}
    Execute Command  rm -R /rom/etc/sas
    SSHLibrary.Put File  ${sas_repo}/nokia04.cert  /rom/etc/sas/cbrsVendorCertChain.pem
    SSHLibrary.Put File  ${sas_repo}/nokia04.key  /rom/etc/sas/cbrsPrivKey.pem.crk
    SSHLibrary.Put File  ${sas_repo}/ca.cert  /rom/etc/sas/cbrsRootCACertificate.pem
    SSHLibrary.Execute Command  openssl x509 -noout -hash -in /rom/etc/sas/cbrsRootCACertificate.pem
    SSHLibrary.Execute Command  ln -s /rom/etc/sas/cbrsRootCACertificate.pem /rom/etc/sas/aaae4089.0
    SSHLibrary.Execute Command  chown btssw:btssw /rom/etc/sas -R

    #Check if certs present on BTS
    SSHLibrary.Execute Command  ls -al /rom/etc/sas/

    SSHLibrary.Get File  source=/rom/etc/sas/cbrsVendorCertChain.pem    destination=${SUITE_LOGS_DIR_PATH}/SAS_certs/cbrsVendorCertChain.pem
    SSHLibrary.Get File  source=/rom/etc/sas/cbrsPrivKey.pem.crk   destination=${SUITE_LOGS_DIR_PATH}/SAS_certs/cbrsPrivKey.pem.crk
    SSHLibrary.Get File  source=/rom/etc/sas/cbrsRootCACertificate.pem    destination=${SUITE_LOGS_DIR_PATH}/SAS_certs/cbrsRootCACertificate.pem

    [Teardown]  SSHLibrary.Close Connection


Start Logging
    [Documentation]  Description:           Start logging and set up libraries: Btssm (RAT_1ST), Syslog (RAT_1ST), Infomodel (RAT_1ST)${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${logs_dir_path}       # path where logs should be created

    Teardown All Aliases For Syslog
    Start Syslog  log_dir=${logs_dir_path}  log_name=syslog_RAT_1st.log  alias=RAT_1ST


Stop Logging
    [Documentation]  Description:           Stop logging and teardown libraries: Btssm (RAT_1ST), Syslog (RAT_1ST), Infomodel (RAT_1ST)${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${logs_dir_path}       # path where logs should be saved

    Run Keyword And Ignore Error  Run Keyword If Test Failed
    ...  taf.sbts.oam.coam.admin.Collect Snapshot  target_file_name=${logs_dir_path}/snapshot_RAT_1ST.zip
    ...  timeout=1800  connection=RAT_1ST
    Stop Syslog  alias=RAT_1ST
    Collect Syslog Results  destination=${logs_dir_path}/  alias=RAT_1ST
    Run  tar -czf ${logs_dir_path}/syslog_RAT_1st.tar.gz -C ${logs_dir_path} syslog_RAT_1st.log; rm ${logs_dir_path}/syslog_RAT_1st.log
    ute_admin_infomodel.Save Infomodel Log  filename=${logs_dir_path}/infomodel_RAT_1st.ims2  timeout=300  alias=RAT_1ST


Get Test Logs Dir Path
    [Documentation]  Description:           Get test logs directory from given logs directory path${\n}
    ...              Return:                Logs directory to specified test: i.e. /home/ute/MN/UTE/robotws/date_+_suite_name/test_name${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${logs_dir_path}       # path to suite logs

    ${test_name}  Replace String  ${TESTNAME}  ${SPACE}    _
    ${test_logs_dir_path}  Normalize Path  ${logs_dir_path}${TESTNAME}/

    RETURN   ${test_logs_dir_path}


Get Active Release Version
    [Documentation]  Description:           Get active release version form BTS${\n}
    ...              Return:                i.e. SBTS22R1${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                michal.kosicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}

    #TODO: check return format and replace by taf solution
    ${software_version}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*  alias=RAT_1ST
    ${software_version}  Set Variable  ${software_version['activeSoftwareVersion']}
    ${software_version}  Fetch From Left  ${software_version}  _

    RETURN  ${software_version}


BTS Operational State Should Be OnAir
    [Documentation]  Description:           Check if BTS is in OnAir state${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                bartosz.rutkowski@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    Wait Until Keyword Succeeds  30x  10s  Check BTS Operational State  required_regexp_state=[oO]nAir  alias=${alias}


Check BTS Operational State
    [Documentation]  Description:           Check if BTS is in expected state${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                bartosz.rutkowski@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${required_regexp_state}   # expected state to compare
    ...          ${alias}                   # connection alias

    ${mrbts_state}  taf.sbts.oam.coam.admin.Get Mrbts State  connection=${alias}
    Should Match Regexp  ${mrbts_state}  ${required_regexp_state}


Admin Alarms Get And Check
    [Documentation]  Description:           Get alarms from BTS and compare to mandatory and allowed alarms.${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                artur.dobosz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${allowed}=${EMPTY}    # list of allowed alarm
    ...          ${mandatory}=${EMPTY}  # list of mandatory alarms
    ...          ${alias}=RAT_1ST       # connection alias
#   Example definition of arguments:
#   @{allowed}     (?i)vendor bts certificate
#   ...              Synchronization lost
#   ...              .*BTS booted at.+
#   @{mandatory}   {'faultName': 'Unit blocked', 'faultId': '48', 'severity': 'Major', 'impactedCells': '.*/LNCEL-(?:_[LR])?-1(?:$|\\D).*'}
#   ...              {'faultName': 'Unit blocked', 'faultId': '48', 'impactedCells': '.*/LNCEL-(?:_[LR])?-2(?:$|\\D).*'}
#   ...              {'alarmDetail': 'Unit blocked', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-3(?:$|\\D).*'}
#   ...              {'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-4(?:$|\\D).*'}
#   ...              {'faultName': 'Transmission path failure', 'alarmCounter': 3}

    ${out_active_alarms_list}  taf.sbts.oam.coam.admin.Get Active Alarms  connection=${alias}
    Admin Alarms Check  available=${out_active_alarms_list}  allowed=${allowed}  mandatory=${mandatory}

    ${unexpected_alarms}  Remove Values From List  ${out_active_alarms_list}  ${allowed}

    RETURN  ${unexpected_alarms}


Get CBSD Id From Infomodel
    [Documentation]  Description:           Get value of cbsdId from Infomodel${\n}
    ...              Return:                cbsdid${\n}
    ...              Output:                {}${\n}
    ...              Author:                aleksandra.dagiel@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Timeout]  60s

    ${CBSD_object_list}  ute_admin_infomodel.Get Infomodel Object
    ...  dist_name=/MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*  timeout=30  alias=RAT_1ST
    ${cbsdId}  Set Variable  ${CBSD_object_list['assignedCbsdId']}
    Should Not Be Equal  ${cbsdId}  ${None}

    RETURN  ${cbsdId}


Get FCC And User Ids From Infomodel
    [Documentation]  Description:           Get fccId and userId from ENB                        ${\n}
    ...              Return:                fccId and userId                                     ${\n}
    ...              Output:                { ${string}, ${string} }                             ${\n}
    ...              Author:                albert.sakowicz@nokia.com                            ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Timeout]  60s

    ${enb_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    ${user}  Set Variable  ${credentials.enb_username}
    ${password}  Set Variable  ${credentials.enb_password}
    ${CBSD_object_list}  ute_admin_infomodel.Get Infomodel Object
    ...  dist_name=/MRBTS-*/RAT-*/BTS_L-*//LNBTS_A-${enb_id}/CBSD_A-*  timeout=30  alias=RAT_1ST
    ${fccId}  Set Variable  ${CBSD_object_list['fccId']}
    ${userId}  Set Variable  ${CBSD_object_list['userId']}
    Should Not Be Equal  ${fccId}  ${None}
    Should Not Be Equal  ${userId}  ${None}

    RETURN  ${fccId}  ${userId}


Set Software Version
    [Documentation]  Description:           Get Software version information                     ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    ${sw_RAT_1}  Get Software Info  connection=RAT_1ST
    ${build_RAT_1}  Fetch From Left  ${sw_RAT_1}[Active SW version]    _
    ${is_trunk_RAT_1}  Run Keyword And Return Status  Should Contain  ${sw_RAT_1}[Active SW version]  _9999_

    ${RAT_2_avaliable}  Run Keyword And Return Status  Get Connection And Configuration Status  connection=RAT_2ND  timeout=10

    ${sw_RAT_2}  IF  ${RAT_2_avaliable}  Get Software Info  connection=RAT_2ND
    ${build_RAT_2}  IF  ${RAT_2_avaliable}  Fetch From Left  ${sw_RAT_2}[Active SW version]  _
    ${is_trunk_RAT_2}  IF  ${RAT_2_avaliable}  Run Keyword And Return Status
    ...  Should Contain  ${sw_RAT_1}[Active SW version]  _9999_

    IF  ${is_trunk_RAT_1}
        ${sw_RAT_1_fixed}  Replace String  ${sw_RAT_1}[Active SW version]  ${build_RAT_1}  SBTS00
    ELSE
        ${sw_RAT_1_fixed}  Set Variable  ${sw_RAT_1}[Active SW version]
    END
    IF  ${is_trunk_RAT_2}
        ${sw_RAT_2_fixed}  Replace String  ${sw_RAT_2}[Active SW version]  ${build_RAT_2}  SBTS00
    ELSE
        ${sw_RAT_2_fixed}  Set Variable If  ${RAT_2_avaliable}  ${sw_RAT_2}[Active SW version]  ${None}
    END
    Set Suite Variable  ${SOFTWARE_VERSION}  ${build_RAT_1}
    Set Suite Variable  ${IS_TRUNK}  ${is_trunk_RAT_1}

    Log To Console  \n========================== SW INFO ==========================
    Log To Console  RAT_1st SW BUILD: ${sw_RAT_1_fixed}\nRAT_2nd SW BUILD: ${sw_RAT_2_fixed}
    IF  ${RAT_2_avaliable} and '${sw_RAT_1_fixed}'=='${sw_RAT_2_fixed}'  Log To Console  SW on both RAT's are same!\n
    IF  ${RAT_2_avaliable} and '${sw_RAT_1_fixed}'!='${sw_RAT_2_fixed}'  Log To Console  SW on both RAT's are NOT same!\n
    IF  ${RAT_2_avaliable}==${FALSE}  Log To Console  Could not connect to RAT_2, skipping!\n

    RETURN  ${sw_RAT_1_fixed}  ${sw_RAT_2_fixed}


All Cells Should Be Enabled And Onair
    [Documentation]  Description:           Check if all cells are enabled and in onAir          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                albert.sakowicz@nokia.com                            ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${times}=30x           # iterations
    ...          ${wait_time}=10s       # time between iterations
    ...          ${alias}=RAT_1ST       # connection alias

    Wait Until Keyword Succeeds  ${times}  ${wait_time}
    ...  ute_admin_infomodel.Query Infomodel
    ...  query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ...  timeout=10  alias=${alias}
    Wait Until Keyword Succeeds  ${times}  ${wait_time}
    ...  ute_admin_infomodel.Query Infomodel
    ...  query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.operationalState=regex"(?i)Enable.*"]
    ...  timeout=10  alias=${alias}


Add SAS FQDN To Known Hosts On eNB
    [Documentation]  Description:           Create /etc/hosts file with new line containing FQDN config on ENB  ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                          ${\n}
    [Arguments]  ${SAS_IP}              # IP to sas
    ...          ${SAS_FQDN}            # ??
    ...          ${enb_user}            # testlines.yaml
    ...          ${enb_password}        # testlines.yaml
    ...          ${eNB_ip}=192.168.255.129  #CONSTANS?
    [Timeout]  3 min

    #TODO: check arguments
    SSHLibrary.Open Connection  ${eNB_IP}  timeout=60 sec
    SSHLibrary.Login  ${enb_user}  ${enb_password}
    SSHLibrary.Execute Command  echo '${SAS_IP} ${SAS_FQDN}' >> /etc/hosts
    ${hosts_content}  SSHLibrary.Execute Command  cat /etc/hosts
    Should Contain  ${hosts_content}  ${SAS_FQDN}

    [Teardown]  SSHLibrary.Close Connection


Remove SAS FQDN From Known Hosts On eNB
    [Documentation]  Description:           Remove line containing FQDN config from /etc/hosts   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${SAS_IP}              # IP to sas
    ...          ${SAS_FQDN}            # ??
    ...          ${enb_user}            # testlines.yaml
    ...          ${enb_password}        # testlines.yaml
    ...          ${eNB_ip}=192.168.255.129  #CONSTANS?
    [Timeout]  3 min

    SSHLibrary.Open Connection  ${eNB_IP}  timeout=60 sec
    SSHLibrary.Login  ${enb_user}  ${enb_password}
    ${FQDN_line}  SSHLibrary.Execute Command  grep -n '${SAS_IP}' /etc/hosts | cut -d : -f 1
    SSHLibrary.Execute Command  sed -i '${FQDN_line}d' /etc/hosts
    ${hosts_content}  SSHLibrary.Execute Command  cat /etc/hosts
    Should Not Contain  ${hosts_content}  ${SAS_FQDN}

    [Teardown]  SSHLibrary.Close Connection


Start Remote TCPDUMP On eNB
    [Documentation]  Description:           Run tcpdump on ENB to monitor bt1 interface          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${enb_user}            # testlines.yaml
    ...          ${enb_password}
    ...          ${trace_file_name}=TCPDUMP_FQDN  # name of the pcap trace file created on BTS
    ...          ${eNB_ip}=192.168.255.129    # const
    [Timeout]  3 min

    ${ASOE_present}  Run Keyword And Return Status  Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/CABINET_L-*/SMOD_L-* is [productName=regex"(?i)ASOE"]

    ${ASIM_present}  Run Keyword And Return Status  Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/CABINET_L-*/SMOD_L-* is [productName=regex"(?i)ASIM"]

    SSHLibrary.Open Connection  ${eNB_IP}  timeout=60 sec
    SSHLibrary.Login  ${enb_user}  ${enb_password}
    IF  '${ASOE_present}'=='True' or '${ASIM_present}'=='True'
        SSHLibrary.Start Command  tcpdump -w /tmp/${trace_file_name}.pcap -i br0 -ttnnvvS &
    ELSE
        SSHLibrary.Start Command  tcpdump -w /tmp/${trace_file_name}.pcap -i br1 -ttnnvvS &
    END


Stop Remote TCPDUMP On eNB And Download Traces
    [Documentation]  Description:           Terminate tcpdump process & download trace file to test logs directory   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${enb_user}    #testlines.yaml
    ...          ${enb_password}
    ...          ${trace_file_name}=TCPDUMP_FQDN  # ??
    ...          ${eNB_ip}=192.168.255.129  # const
    [Timeout]  3 min

    #TODO: check arguments
    SSHLibrary.Open Connection  ${eNB_IP}  timeout=60 sec
    SSHLibrary.Login  ${enb_user}  ${enb_password}
    SSHLibrary.Execute Command  pgrep -f ${trace_file_name} | xargs kill -2
    Sleep  10s   #to make sure the file is saved successfully after gracefull kill
    Run And Return Rc And Output  sshpass -p ${enb_password} scp ${enb_user}@192.168.255.129:/tmp/${trace_file_name}.pcap ${TEST_LOGS_DIR_PATH}
    ${trace_file_size}  Get File Size  ${TEST_LOGS_DIR_PATH}/${trace_file_name}.pcap
    Should Not Be Equal As Integers  ${trace_file_size}  ${0}

    [Teardown]  SSHLibrary.Close All Connections


Read Trace File And Verify SNI Presence
    [Documentation]  Description:           Open downloaded .pcap trace file with tshark library, apply packet filter       ${\n}
    ...                                     and check whether SNI is present in the traces       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${SAS_FQDN}=TCPDUMP_FQDN            # ??
    ...          ${trace_file_name}=TCPDUMP_FQDN     # ??
    [Timeout]  5 min

    Setup Tshark  interface=any  alias=read
    ${handshake_trace}  Read Pcap  pcap_file_path=${TEST_LOGS_DIR_PATH}/${trace_file_name}.pcap
    ...  packet_filter=tls.handshake.extensions_server_name==${SAS_FQDN}  alias=read
    Should Not Be Empty  ${handshake_trace}


Get Random Cbsd Object
    [Documentation]  Description:           Randomly pick and return CBSD from BTS               ${\n}
    ...              Return:                CBSD object                                          ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
	[Arguments]  ${alias}=RAT_1ST       # Connection alias

	${cbsd_list}  Query Infomodel  alias=${alias}  query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*
	${cbsd_object}  Evaluate  random.sample(${cbsd_list}, 1)  modules=random

	RETURN  ${cbsd_object[0]}


Get Random Cell From Cbsd Object
    [Documentation]  Description:           Randomly pick and return cell from CBSD object       ${\n}
    ...              Return:                cell ??                                              ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
	[Arguments]  ${cbsd_object}         # ??
	...          ${alias}=RAT_1ST       # connection alias

	${rmod_object}  Query Infomodel  alias=${alias}  query=get object ${cbsd_object["rmodDN"]}
	${status_old_list}  Run Keyword And Return Status  Dictionary Should Contain Key  ${rmod_object}  activeCellsList
    ${status_new_list}  Run Keyword And Return Status  Dictionary Should Contain Key  ${rmod_object}  activeLteCellsList
    ${cells_list}  Set Variable If  '${status_old_list}'=='True' and '${status_new_list}'=='False'
    ...  ${rmod_object["activeCellsList"]}  ${rmod_object["activeLteCellsList"]}
	${cell}  Evaluate  random.sample(${cells_list}, 1)  modules=random

	RETURN  ${cell[0]}


Get Cells List From Cbsd Object
    [Documentation]  Description:           Get cells list from CBSD object                      ${\n}
    ...              Return:                cell list ??                                         ${\n}
    ...              Output:                { ??, .., ?? }                                       ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
	[Arguments]  ${cbsd_object}         # ??
	...          ${alias}=RAT_1ST       # connection alias

	${rmod_object}  Query Infomodel  alias=${alias}  query=get object ${cbsd_object["rmodDN"]}
	${status_old_list}  Run Keyword And Return Status  Dictionary Should Contain Key  ${rmod_object}  activeCellsList
    ${status_new_list}  Run Keyword And Return Status  Dictionary Should Contain Key  ${rmod_object}  activeLteCellsList
    ${cells_list}  Set Variable If  '${status_old_list}'=='True' and '${status_new_list}'=='False'
    ...  ${rmod_object["activeCellsList"]}   ${rmod_object["activeLteCellsList"]}

	RETURN  ${cells_list}


Get N Random Cells From Cells List
    [Documentation]  Description:           Get randomly picked number of cells and return from cells list       ${\n}
    ...              Return:                cell ??                                              ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
	[Arguments]  ${cell_list}  ${n}

	${cell_pair}  Evaluate  random.sample(${cell_list}, ${n})  modules=random

	RETURN  ${cell_pair}


Get Cbsd Id From Cbsd Object
    [Documentation]  Description:           Get CBSD id from CBSD object                         ${\n}
    ...              Return:                CBSD id                                              ${\n}
    ...              Output:                { ${string} ?? }                                     ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${cbsd_object}         # CBSD object
    ...          ${alias}=RAT_1ST       # connection alias

    ${cbsd_r_object}  Query Infomodel  alias=${alias}
    ...  query=get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBSD_R-* is [cbsdSerialNumber=${cbsd_object["cbsdSerialNumber"]}]
    ${cbsd_r_ref}  Query Infomodel  alias=${alias}  query=get object ${cbsd_r_object["dist_name"]}/CONF_REF-1
    ${cbsd_id}  Fetch From Right  ${cbsd_r_ref["distName"]}  CBSD_A-

    RETURN  ${cbsd_id}


Disable Carrier Aggregation
    [Documentation]  Description:           Deactivate actDLCAggr including additional parameters required from 20A onwards       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ??
    ...          ${alias}=RAT_1ST       # connection alias

    Replace Variables In File  file_path=${CURDIR}/Delta/actDLCAggr_disable.json
    ...  file_destination=${OUTPUT_DIR}/actDLCAggr_disable.json  enb_id=${enb_id}
    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning  ${OUTPUT_DIR}/actDLCAggr_disable.json    connection=${alias}


Enable Carrier Aggregation
    [Documentation]  Description:           Activate actDLCAggr including additional parameters required from 20A onwards       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}                      # ??
    ...          ${cbrs_profile_id}=1           # ??
    ...          ${channel_space_1010}=10       # ??
    ...          ${channel_space_1020}=15       # ??
    ...          ${channel_space_2020}=20       # ??
    ...          ${alias}=RAT_1ST               # connection alias

    ${ca_status}  Run Keyword And Return Status  Query Infomodel  alias=${alias}
    ...  query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id} is [actDLCAggr=true]
    IF  '${ca_status}'=='False'
        Replace Variables In File  file_path=${CURDIR}/Delta/actDLCAggr_enable.json
        ...  file_destination=${OUTPUT_DIR}/actDLCAggr_enable.json
        ...  enb_id=${enb_id}
        ...  cbrs_profile_id=${cbrs_profile_id}
        ...  channel_space_1010=${channel_space_1010}
        ...  channel_space_1020=${channel_space_1020}
        ...  channel_space_2020=${channel_space_2020}
    END
    IF  '${ca_status}'=='False'  taf.sbts.oam.coam.admin.Perform Delta Recommissioning  ${OUTPUT_DIR}/actDLCAggr_enable.json  connection=${alias}


Fetch CBSD ID
    [Documentation]  Description:           Get CBSD id from ENB                                 ${\n}
    ...              Return:                CBSD id                                              ${\n}
    ...              Output:                { ${string} }                                        ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # id of the ENB

    ${cbsd_info}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${assignedCbsdId}  Get From Dictionary  ${cbsd_info}  assignedCbsdId

    RETURN  ${assignedCbsdId}


Wait For All Cells To Be OnAir
    [Documentation]  Description:           Wait 25min until all cells become in onAir state     ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias
    ...          ${wait_time}=15min     # waiting time / timeout
    [Timeout]  ${wait_time}

    FOR  ${i}  IN RANGE  9999    #do-while loop
        ${onAir_flag1}  Run Keyword And Return Status  Query InfoModel  timeout=10  alias=${alias}
        ...  query=every //LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAirDone"]

        Continue For Loop If  ${onAir_flag1}==${False}

        Sleep  10sec

        ${onAir_flag2}  Run Keyword And Return Status  Query InfoModel  timeout=10  alias=${alias}
        ...  query=every //LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAirDone"]

        Exit For Loop If  ${onAir_flag1} and ${onAir_flag2}  #loop end statement
    END


Check If Cells Are Disabled
    [Documentation]  Description:           Check if LTE cells are in disabled state             ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${alias}=RAT_1ST       # connection alias
    ...          ${timeout}=360s        # timeout time

    Query Infomodel  alias=${alias}  timeout=${timeout}
    ...  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-* is [operationalState=regex"(?i)Disabled"]


Check If 5G Cells Are Disabled
    [Documentation]  Description:           Check if all 5G cells are in disabled state          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${gnb_id}              # gNB id
    ...          ${alias}=RAT_1ST       # connection alias
    ...          ${timeout}=300s        # timeout time

    Query Infomodel  alias=${alias}  timeout=${timeout}
    ...  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-${gnb_id}/NRCELL_R-* is [operationalState=regex"(?i)Disabled"]


List Active eNB Faults
    [Documentation]  Description:           Get active alarms from ENB                           ${\n}
    ...              Return:                list of fault id's of active alarms                  ${\n}
    ...              Output:                { ${int}, .., ${int} }                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    @{enb_alarms}  taf.sbts.oam.coam.admin.Get Alarms  connection=${alias}  timeout=30
    ${faults_ids}  Create List
    FOR  ${enb_alarm}  IN  @{enb_alarms}
        ${fault_id}  Get From Dictionary  ${enb_alarm}  faultId
        Append To list  ${faults_ids}  ${fault_id}
    END

    RETURN  ${faults_ids}


Check For Unwanted Faults
    [Documentation]  Description:           Compare active alarms from ENB with user defined allowed alarms list             ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${allowed_faults}=@{EMPTY}        # list of faults that are allowed
    ...          ${active_alarm_list}=@{EMPTY}     #list of all active faults, can be taken from List Active eNB Faults

    List Should Contain Sub List  ${allowed_faults}  ${active_alarm_list}


List Values of GrantId For All Cells
    [Documentation]  Description:           Queries the eNB for details of each CBSDCEL, extracts their GrantId values             ${\n}
    ...              Return:                list of GrantId values                               ${\n}
    ...              Output:                { ${string}, .., ${string} }                         ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${alias}=RAT_1ST       # connection alias

    Log  ${enb_id}  #this is here just to pass the static analysis
    @{cbsdcel_list}  Query Infomodel  query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*    alias=${alias}
    ${cell_num}  Get Length  ${cbsdcel_list}
    ${grantId_list}  Create List  @{EMPTY}
    FOR  ${i}  IN RANGE  ${cell_num}
        Append to list  ${grantId_list}  ${cbsdcel_list[${i}]["grantId"]}
    END

    RETURN  ${grantId_list}


Wait For Any Cell To Be Dropped
    [Documentation]  Description:           Check for 3 minutes if any cell change state to disabled     ${\n}
    ...              Return:                None                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.kosicki@nokia.com                             ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com                         ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias
    ...          ${wait_time}=6min      # waiting time / timeout
    [Timeout]  ${wait_time}

    FOR  ${i}  IN RANGE  999   #do-while loop

        ${onAir_flag}  Run Keyword And Return Status  Check If Any Cell is Disabled  alias=${alias}

        IF  ${onAir_flag}  Sleep  1sec
        ${onAir_flag}  Run Keyword And Return If  ${onAir_flag}  Run Keyword And Return Status
        ...  Check If Any Cell is Disabled  alias=${alias}

        Exit For Loop If  ${onAir_flag}  #loop end statement
    END


Check If Any Cell is Disabled
    [Documentation]  Description:           Checks if any cell is disabled.    ${\n}
    ...              Return:                None                               ${\n}
    ...              Output:                {}                                 ${\n}
    ...              Author:                katarzyna.kadziela@nokia.com       ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com       ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    @{technology}  Create List  LNBTS_M-1  GNBTS_M-1  WNBTS_M-1  NRBTS_M-1
    @{all_cells_status}  Create List
    FOR  ${i}  IN  @{technology}
        ${info}  Run Keyword And Ignore Error  ute_admin_infomodel.Query InfoModel
        ...  query=get list /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/${i}/CELL_M-*  timeout=1  alias=${alias}
        ${cell_status}  IF  '${info[0]}' == 'PASS'  Get operationalState  ${info[1]}
        Continue For Loop If  ${cell_status} == ${None}
        ${all_cells_status}  IF  ${cell_status} != ${None}  Combine lists  ${all_cells_status}  ${cell_status}
    END
    List Should Contain Value  ${all_cells_status}  Disabled


Get operationalState
    [Documentation]  Description:           Get operationalState of all cells           ${\n}
    ...              Return:                operationalState from IM - e.g. Disabled    ${\n}
    ...              Output:                { &{list} }                                 ${\n}
    ...              Author:                katarzyna.kadziela@nokia.com                ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com                ${\n}
    [Arguments]  ${list}

    @{cells_status}  Create List
    ${cell_count}  Get Length  ${list}
    FOR  ${i}  IN RANGE  ${cell_count}
         ${cell_status}  Run Keyword And Ignore Error  Set Variable  ${list[${i}]['stateInfo']['operationalState']}
         Append To List  ${cells_status}  ${cell_status[1]}
    END

    RETURN  @{cells_status}


Get Random CBSD
    [Documentation]  Description:           Get randomly picked CBSD object ??                   ${\n}
    ...              Return:                cbsd object                                          ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    ${cbsd_list}  Query Infomodel  alias=${alias}  query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*
    ${cbsd_object}  Evaluate  random.sample(${cbsd_list}, 1)  modules=random

    RETURN  ${cbsd_object[0]}


Create generic delta and perform commissioning
    [Documentation]  Description:           Replace 'BTS_ID' in input JSON file with the value of ${enb_id} and performs recommissioning    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${delta_file_tmp}      # path to delta commissioning JSON file
    ...          ${delta_file_final}    # desired path for new delfa commissioning JSON file

    ${delta_prep}  Replace Delta Parameters  ${delta_file_tmp}  ${enb_id}
    Wait Until Keyword Succeeds  10x  20s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  taf.sbts.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_file_final}  connection=RAT_1ST


Replace Delta Parameters
    [Documentation]  Description:           Replace 'BTS_ID' in input JSON file with the value of ${enb_id}      ${\n}
    ...              Return:                path to modified inputFileName_tmp.JSON file         ${\n}
    ...              Output:                { ${string} }                                        ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${delta_path}          # path to delta commissioning JSON file
    ...          ${enb_id}              # ENB id

    ${delta_tmp}  OperatingSystem.Get File    ${delta_path}
    ${enb_id}  Convert To String  ${enb_id}
    ${new_delta}  Replace String  ${delta_tmp}  BTS_ID  ${enb_id}
    ${new_path}  Replace String  ${delta_path}  _tmp  ${EMPTY}
    Create File  ${new_path}  ${new_delta}

    RETURN  ${new_path}


Start Capturing Historical Alarms
    [Documentation]  Description:           Start to capture ims2 logs                           ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${im_port}=443                 # ??
    ...          ${address}=192.168.255.129     # const?
    ...          ${alias}=his_alarms

    Setup infomodel  address=${address}  port=${im_port}  alias=${alias}
    Connect infomodel  alias=${alias}


Save And Check Historical Alarms
    [Documentation]  Description:           Check content of ims file for active alarms    ${\n}
    ...              Return:                                                               ${\n}
    ...              Output:                {}                                             ${\n}
    ...              Author:                marek.kot@nokia.com                            ${\n}
    ...              Maintainer:            CBRS Team                                      ${\n}
    [Arguments]  ${ims2_file_path}=${OUTPUT_DIR}        # file destination
    ...          ${alias}=his_alarms                    # connection alias
    ...          ${expected_alarms}=@{EMPTY}            # expected alarms
    ...          ${mandatory_alarms}=@{EMPTY}           # mandatory alarms

    Save Infomodel Log  filename=${ims2_file_path}/historical_alarms.ims2  timeout=300  alias=${alias}
    @{historical_alarms}  Create List
    @{allowed_alarms}  Set Variable  ${enb_allowed_alarms}
    @{events_list}  Get Change Sets  ${ims2_file_path}/historical_alarms.ims2  //LTS-*//ALARM_L-*    alias=${alias}
    @{events_list_fri}  Get Change Sets  ${ims2_file_path}/historical_alarms.ims2  //FRI-*/ALARM-*    alias=${alias}
    FOR  ${event}  IN  @{events_list}
        ${alarm}  Set Variable  ${event.object}
        ${alarm_status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${alarm}  alarmInformation
        IF  ${alarm_status}  Append To List  ${historical_alarms}  ${alarm["alarmInformation"]["alarmText"]["alarmDetail"]}
    END
    FOR  ${event}  IN  @{events_list_fri}
        ${alarm}  Set Variable  ${event.object}
        ${alarm_status_fri}  Run Keyword And Return Status  Dictionary Should Contain Key  ${alarm}  affectedResources
        IF  ${alarm_status_fri}  Append To List  ${historical_alarms}  ${alarm["alarmText"]["alarmDetail"]}
    END
    ${historical_alarms}  Remove Duplicates  ${historical_alarms}
    Check Mandatory Alarms  ${historical_alarms}  ${mandatory_alarms}
    ${historical_alarms}  Remove Allowed Alarms  ${historical_alarms}  ${allowed_alarms}
    ${historical_alarms}  Remove Expected Alarms  ${historical_alarms}  ${expected_alarms}
    Should Be Empty  ${historical_alarms}

    [Teardown]  ute_admin_infomodel.Teardown Infomodel  alias=${alias}


Check If BTS Is Not Busy
    [Documentation]  Description:           Check is BTS busy                                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                marek.kot@nokia.com                                  ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    ${status}  Run Keyword And Return Status  taf.sbts.oam.coam.admin.wait_sw_update_possible
    ...  timeout=10  readiness_timeout=5  connection=${alias}
    Should Be Equal  ${status}  ${true}

    ${np_objects}  Query Infomodel  query=get list /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*  alias=${alias}
    ${np_count}  Get Length  ${np_objects}
    Should Be Equal As Integers  ${np_count}  1


Wait Until BTS Is Not Busy
    [Documentation]  Description:           Wait ${wait_time} until BTS finish any operations           ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias
    ...          ${wait_time}=30min
    [Timeout]  ${wait_time}

#    FOR  ${i}  IN RANGE  9999  #do-while loop
#        ${notBusy_flag}  Run Keyword And Ignore Error  Check If BTS Is Not Busy  alias=${alias}#
#
#        IF  '${notBusy_flag[0]}'=='PASS'  Sleep  10sec
#
#        IF  '${notBusy_flag[0]}'=='PASS'
#            Run Keyword And Ignore Error  Check If BTS Is Not Busy  alias=${alias}
#        ELSE
#            ${notBusy_flag}  Set Variable  ${notBusy_flag}
#        END
#
#        Exit For Loop If  '${notBusy_flag[0]}'=='PASS'   #loop end statement
#        Sleep  250ms   #sleep between loop iterations
#
#    END

    FOR    ${i}     IN RANGE    9999    #do-while loop
        ${notBusy_flag}=    Run Keyword And Ignore Error    Check If BTS Is Not Busy    alias=${alias}

        Run Keyword If    '${notBusy_flag[0]}'=='PASS'    Sleep    10sec

        ${notBusy_flag}=    Run Keyword If    '${notBusy_flag[0]}'=='PASS'
        ...    Run Keyword And Ignore Error    Check If BTS Is Not Busy    alias=${alias}
        ...    ELSE    Set Variable    ${notBusy_flag}

        Exit For Loop If    '${notBusy_flag[0]}'=='PASS'    #loop end statement
        Sleep    250ms     #sleep between loop iterations

    END



Fetch Grant ID of selected cell
    [Documentation]  Description:           Get Grant ID from BTS                                ${\n}
    ...              Return:                Grant ID                                             ${\n}
    ...              Output:                { ${string} }                                        ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${cell_number}         # ??

    ${cbsd_info}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-${cell_number}/CBSDCEL_R-0
    ${assignedGrantId}  Get From Dictionary  ${cbsd_info}  grantId

    RETURN  ${assignedGrantId}


Get Spectrum Inquiry Message
    [Documentation]  Description:           Extract values for relinquishmentRequest:grantId and  relinquishmentResponse:grantId
    ...                                     for each CBSD cell from SAS log and verifies if all existing grants on eNB
    ...                                     have been relinquishedet Grant ID from BTS                                      ${\n}
    ...              Return:                extracted values ??                                  ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # timestamp for SAS log parser
    ...          ${time_stop}           # timestamp for SAS log parser
    ...          ${sas_log_path}        # path of the SAS_Sim.log file

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${measReport}  Extract Values From Sas Log  log_name=${parsed_log_file}  parameter=measReport  data_type=spectrumInquiryRequest

    RETURN  ${measReport}


Check If The CBRS Enhanced Measurement Occured
    [Documentation]  Description:           Check if the measurement result have changed         ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${first_measurement_result}        # first preTX measurement result
    ...          ${second_measurement_result}       # second preTX measurement result

    Should not be equal  ${first_measurement_result}  ${second_measurement_result}


Fetch Measurement Results
    [Documentation]  Description:           ??         ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    ${cbsd_info}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_BAND_MEASUREMENT_REPORT-*

    RETURN  ${cbsd_info}


Check If CBRS Enhanced Measurement Feature Is Enabled
    [Documentation]  Description:           Check if actCbrsEnhMeas is set true on ENB           ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    ute_admin_infomodel.Query InfoModel  timeout=30  alias=RAT_1ST
    ...  query=check /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNBTS_TDD_A-* is [actCbrsEnhMeas=regex"(?i)True"]


Check If CBRS Enhanced Measurement Feature Is Disabled
    [Documentation]  Description:           Check if actCbrsEnhMeas is set false on ENB          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    ute_admin_infomodel.Query InfoModel  timeout=30  alias=RAT_1ST
    ...  query=check /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNBTS_TDD_A-* is [actCbrsEnhMeas=regex"(?i)False"]


Disable CBRS Enhanced Measurement Feature
    [Documentation]  Description:           Set actCbrsEnhMeas to false on ENB                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id

    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/LNBTS_TDD-0
    ...  parameter=actCbrsEnhMeas  operation=update  value=false  connection=RAT_1ST


Enable CBRS Enhanced Measurement Feature
    [Documentation]  Description:           Set actCbrsEnhMeas to true on ENB                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id

    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/LNBTS_TDD-0
    ...  parameter=actCbrsEnhMeas  operation=update  value=true  connection=RAT_1ST


Verify Registration Procedure
    [Documentation]  Description:           Extract value for grantResponse:grantId for each CBSD cell from SAS log
    ...                                     verify if grant procedure has been executed only for valid frequencies                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # timestamp for SAS log parser
    ...          ${time_stop}           # timestamp for SAS log parser
    ...          ${sas_log_path}        # path of the SAS_Sim.log file
    ...          ${enb_id}              # ENB id

    ${cbsd_info_scfc}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBSD_A-*
    ${cbsd_info_runtime}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${userId}  Get From Dictionary  ${cbsd_info_scfc}  userId
    ${fccId}  Get From Dictionary  ${cbsd_info_scfc}  fccId
    ${assignedCbsdId}  Get From Dictionary  ${cbsd_info_runtime}  assignedCbsdId
    ${cbsdCategory}  Get From Dictionary  ${cbsd_info_runtime}  cbsdCategory
    ${cbsdSerialNumber}  Get From Dictionary  ${cbsd_info_runtime}  cbsdSerialNumber

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}

    ${registration_request_userId}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=userId  data_type=registrationRequest
    ${registration_request_fccId}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=fccId    data_type=registrationRequest
    ${registration_request_cbsdSerialNumber}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdSerialNumber  data_type=registrationRequest
    ${registration_request_cbsdCategory}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdCategory  data_type=registrationRequest
    ${registration_response_responseCode}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=responseCode  data_type=registrationResponse

    Should Be Equal  ${registration_request_userId[0]}  ${userId}
    Should Be Equal  ${registration_request_fccId[0]}  ${fccId}
    Should Be Equal  ${registration_request_cbsdSerialNumber[0]}  ${cbsdSerialNumber}
    Should Be Equal  ${registration_request_cbsdCategory[0]}  B
    Should Be Equal  ${registration_response_responseCode[0]}  ${0}


Verify SpectrumInquiry Procedure
    [Documentation]  Description:           Extract value for grantResponse:grantId for each CBSD cell from SAS log
    ...                                     verify if grant procedure has been executed only for valid frequencies               ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # timestamp for SAS log parser
    ...          ${time_stop}           # timestamp for SAS log parser
    ...          ${sas_log_path}        # path of the SAS_Sim.log file
    ...          ${enb_id}              # ENB id

    ${cbsd_info_runtime}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${assignedCbsdId}  Get From Dictionary  ${cbsd_info_runtime}  assignedCbsdId

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}

    ${spectrumInquiryRequest_cbsdId}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdId  data_type=spectrumInquiryRequest  packet_amount=1
    ${spectrumInquiryRequest_inquiredSpectrum}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=inquiredSpectrum  data_type=spectrumInquiryRequest  packet_amount=1
    ${spectrumInquiryRequest_inquiredSpectrum_count}  Get Length  ${spectrumInquiryRequest_inquiredSpectrum[0]}
    ${spectrumInquiryResponse_cbsdId}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdId  data_type=spectrumInquiryResponse  packet_amount=1
    ${spectrumInquiryResponse_availableChannels}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=availableChannel  data_type=spectrumInquiryResponse  packet_amount=1
    ${spectrumInquiryResponse_availableChannels_count}  Get Length  ${spectrumInquiryResponse_availableChannels[0]}

    ${availableChannels_list}  Create List
    FOR  ${i}  IN RANGE  ${spectrumInquiryResponse_availableChannels_count}
        Append To List  ${availableChannels_list}  ${spectrumInquiryResponse_availableChannels[0][${i}]['frequencyRange']}
    END

    Should Be Equal  ${spectrumInquiryRequest_cbsdId[0]}  ${assignedCbsdId}
    Should Be Equal  ${spectrumInquiryResponse_cbsdId[0]}  ${assignedCbsdId}
    Should Be Equal  ${availableChannels_list}  ${spectrumInquiryRequest_inquiredSpectrum[0]}

    RETURN  ${availableChannels_list}


Verify Grant Request Procedure
    [Documentation]  Description:           Extract value for grantResponse:grantId for each CBSD cell from SAS log
    ...                                     verify if grant procedure has been executed only for valid frequencies     ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # timestamp for SAS log parser
    ...          ${time_stop}           # timestamp for SAS log parser
    ...          ${sas_log_path}        # path of the SAS_Sim.log file
    ...          ${enb_id}              # ENB id
    ...          ${availableChannels_list}    # ??

    ${cbsd_info_runtime}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${assignedCbsdId}  Get From Dictionary  ${cbsd_info_runtime}  assignedCbsdId

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}

    ${grantRequest_cbsdId}  Extract Values From Sas Log  log_name=${parsed_log_file}
    ...  parameter=cbsdId  data_type=grantRequest  packet_amount=1

    #TODO:    Sprawdzic czy łączy listę z dwóch grant requestów. jesli tak, to czy wyzszy indeks zawsze = późniejsza wiadomość.
    ${grantRequest_operationFrequencyRange}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=grantRequest  data_type=grantRequest
    ${templog}  log  ${grantRequest_operationFrequencyRange[0][0]['operationParam']['operationFrequencyRange']}
    ${grantRequest_operationFrequencyRange_count}  get length  ${grantRequest_operationFrequencyRange[0]}

    ${requestedChannels_list}  create list
    FOR  ${i}  IN RANGE  ${grantRequest_operationFrequencyRange_count}
        Append To List  ${requestedChannels_list}  ${grantRequest_operationFrequencyRange[0][${i}]['operationParam']['operationFrequencyRange']}
    END
    ${requestedInquiredChannels}  List Should Contain Sub List  ${availableChannels_list}  ${requestedChannels_list}


Verify Grant Relinquishment Procedure
    [Documentation]  Description:           Extract value for grantResponse:grantId for each CBSD cell from SAS log
    ...                                     verify if all existing grants on eNB have been relinquished                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          #
    ...          ${time_stop}           #
    ...          ${sas_log_path}        #
    ...          ${grantId_list}        #

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}     date_stop=${time_stop}
    ${relinquishmentRequest_values}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=grantId  data_type=relinquishmentRequest
    ${grantId_count}  Get Length  ${grantId_list}
    FOR  ${i}  IN RANGE  ${grantId_count}
        Should Contain  ${relinquishmentRequest_values}  ${grantId_list[${i}]}
    END
    ${relinquishmentResponse_values}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=grantId  data_type=relinquishmentResponse
    ${grantId_count}  Get Length  ${grantId_list}
    FOR  ${i}  IN RANGE  ${grantId_count}
        Should Contain  ${relinquishmentResponse_values}  ${grantId_list[${i}]}
    END


#List Grant Response Parameters
#    [Documentation]  Description:           Extract value for grantResponse:grantId for each CBSD cell from SAS log
#    ...                                     verify if all existing grants on eNB have been relinquished                    ${\n}
#    ...              Return:                ??                                                   ${\n}
#    ...              Output:                { ?? }                                               ${\n}
#    ...              Author:                michal.moskala@nokia.com                             ${\n}
#    ...              Maintainer:            CBRS Team                                            ${\n}
#    [Arguments]      ${time_start}                      # timestamp for SAS log parser
#    ...              ${time_stop}                       # timestamp for SAS log parser
#    ...              ${sas_log_path}                    # path of the SAS_Sim.log file
#    ...              ${enb_id}                          # ENB id
#    ...              ${isSuccesfullGrant}=${TRUE}       # ??
#
#    ${cbsd_info_runtime}   ute_admin_infomodel.Query Infomodel    timeout=30    alias=RAT_1ST
#    ...    query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
#    ${assignedCbsdId}   Get From Dictionary    ${cbsd_info_runtime}    assignedCbsdId
#
#    ${parsed_log_file}   Parse Sas Log File
#    ...    log_file_name=${sas_log_path}     date_start=${time_start}     date_stop=${time_stop}
#    ${grantRequest_cbsdId}   Extract Values From Sas Log
#    ...    log_name=${parsed_log_file}     parameter=cbsdId    data_type=grantRequest    packet_amount=1
#    ${grantResponse_responseMessage}   Extract Values From Sas Log
#    ...    log_name=${parsed_log_file}     parameter=response    data_type=grantResponse   packet_amount=1
#
#    RETURN    ${grantResponse_responseMessage}


List Response Codes Of Grants
    [Documentation]  Description:           Extract value for grantResponse:grantId for each CBSD cell from SAS log
    ...                                     verify if all existing grants on eNB have been relinquished                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${grantResponse_responseMessage}       # ??

    ${grantResponse_Channels_count}  Get Length  ${grantResponse_responseMessage}
    ${ResponseCodes}  Create List
    FOR  ${i}  IN RANGE  ${grantResponse_Channels_count}
        Append To List  ${ResponseCodes}  ${grantResponse_responseMessage[${i}]['responseCode']}
    END

    RETURN  ${ResponseCodes}


List earfcn Values For All Cells
    [Documentation]  Description:           Get earfcn values of each cell from BTS                ${\n}
    ...              Return:                Fetched data from BTS 'cellName'='earfcn'              ${\n}
    ...              Output:                { &{dictionary} }                                    ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id

    @{lncel_param_list}  ute_admin_infomodel.Query Infomodel  alias=RAT_1ST
    ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNCEL_A-*/LNCEL_TDD_A-0
    ${cell_num}  Get Length  ${lncel_param_list}
    ${earfcn_list}  Create List
    FOR  ${i}  IN RANGE  ${cell_num}
        Append To List  ${earfcn_list}  ${lncel_param_list[${i}]['earfcn']}
    END

    RETURN  ${earfcn_list}  ${cell_num}


List pMax Values For All Cells
    [Documentation]  Description:           Get pMax values of each cell from BTS                ${\n}
    ...              Return:                Fetched data from BTS 'cellName'='pMax'              ${\n}
    ...              Output:                { &{dictionary} }                                    ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id

    @{pMax_list}  ute_admin_infomodel.Query Infomodel  alias=RAT_1ST
    ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNCEL_A-*
    ${cell_num}  Get Length  ${pMax_list}
    ${pmax_dict}  Create Dictionary
    FOR  ${i}  IN RANGE  ${cell_num}
        ${pmax_dict}  Set To Dictionary  ${pmax_dict}  "${pMax_list[${i}]["cellName"]}"=${pMax_list[${i}]["pMax"]}
    END

    RETURN  ${pmax_dict}


Compare pMax Values For All Cells
    [Documentation]  Description:           Compare two pMax values                              ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${pMax_1}              # first compared value
    ...          ${pMax_2}              # second compared value

    Dictionaries Should Be Equal  ${pMax_1}  ${pMax_2}


Check If pMax Change Is Reflected On eNB
    [Documentation]  Description:           Check if pMax of all cells on BTS are equal to the given value          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${template_values}     # dictionary of pMax values to compare with

    ${new_pMax_values}  List pMax Values For All Cells  ${enb_id}
    Compare pMax Values For All Cells  ${new_pMax_values}  ${template_values}


Check If Cells Are Temporarily Disabled and Recovered
    [Documentation]  Description:           Check if cells are in disabled state, than check if they come back to enabled state          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${alias}=RAT_1ST       # connection alias

    ute_admin_infomodel.Query Infomodel  alias=${alias}  timeout=120
    ...  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-* is [operationalState=regex"(?i)Disabled"]
    ute_admin_infomodel.Query Infomodel  alias=${alias}  timeout=240
    ...  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-* is [operationalState=regex"(?i)Enabled"]


Wait Until All Cells Reach State
    [Documentation]  Description:           Wait until all cells reach given state               ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${state}               # given state name
    ...          ${state_value}         # given state value
    ...          ${alias}=RAT_1ST       # connection alias

    ute_admin_infomodel.Query Infomodel  alias=${alias}  timeout=180
    ...  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-* is [${state}=regex"(?i)${state_value}"]


Assert Fault Presence On Selected Cell
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${cell_id}             # cell id
    ...          ${fault_id}            # fault id number
    ...          ${alarm_name}          # alarm name
    ...          ${bts_side}            # ??

    Log  ${bts_side}  #this is here just to pass the static analysis
    ute_admin_infomodel.Query InfoModel  timeout=120  alias=RAT_1ST
    ...  query=check //LNBTS_L-*/LNCEL_L-${cell_id}/ALARM_L-* is [alarmInformation.faultId=${fault_id}]
    ute_admin_infomodel.Query InfoModel  timeout=120  alias=RAT_1ST
    ...  query=check //LNBTS_L-*/LNCEL_L-${cell_id}/ALARM_L-* is [alarmInformation.alarmText.alarmDetail="${alarm_name}"]


Read Trace File And Assert Lack Of SNI Presence
    [Documentation]  Description:           Open downloaded .pcap trace file with tshark library,
    ...                                     applies packet filter and checks whether SNI is present in the traces           ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${IP_address}                      # ??
    ...          ${trace_file_name}=TCPDUMP_FQDN    # ??

    Setup Tshark  interface=any  alias=read
    ${handshake_trace}  Read Pcap  pcap_file_path=${TEST_LOGS_DIR_PATH}/${trace_file_name}.pcap
    ...  packet_filter=tls.handshake.extensions_server_name==${IP_address}  alias=read
    Should Be Empty  ${handshake_trace}


Add SASUSEGROUP
    [Documentation]  Description:           Add string to SASUSEGROUP                            ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${sas_user_group_id}=1         # ??
    ...          ${group_id_value}=test_id      # ??

    Replace Variables In File  file_path=${CURDIR}/Delta/Add_SASUSERGROUP.json
    ...  file_destination=${OUTPUT_DIR}/Add_SASUSERGROUP.json
    ...  enb_id=${testlines.${testline_id}.enb_id}
    ...  sas_user_group_id=${sas_user_group_id}
    ...  group_id_value=${group_id_value}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/Add_SASUSERGROUP.json  connection=RAT_1ST


Remove SASUSERGROUP
    [Documentation]  Description:           Remove string to SASUSEGROUP                         ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${sas_user_group_id}=1         # ??

    Replace Variables In File  file_path=${CURDIR}/Delta/Delete_SASUSERGROUP.json
    ...  file_destination=${OUTPUT_DIR}/Delete_SASUSERGROUP.json
    ...  enb_id=${testlines.${testline_id}.enb_id}
    ...  sas_user_group_id=${sas_user_group_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/Delete_SASUSERGROUP.json  connection=RAT_1ST


Check If TS Version Is As Expected
    [Documentation]  Description:           Check TS Version and compare with given value        ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]      ${enb_id}              # ENB id
    ...              ${alias}               # connection alias
    ...              ${version}             # version to compare with

    ${CBRSPR_R_info}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=${alias}
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBRSPR_R-1
    ${TS_version}  Get From Dictionary  ${CBRSPR_R_info}  wINNFTSVersion
    Should Be Equal  ${TS_version}  ${version}


Get File And Replace Variables
    [Documentation]  Description:           Replace variables in given file                      ${\n}
    ...              Return:                edited data file                                     ${\n}
    ...              Output:                { ${string} }                                        ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${file_path}           # path to file
    ...          &{variables}           # variable to replace

    ${file}  OperatingSystem.Get File  ${file_path}
    ${keys}  Get Dictionary Keys  ${variables}
    FOR  ${key}  IN  @{keys}
        ${temp_string}  Convert To String  ${variables['${key}']}
        ${file}  Replace String  ${file}  {${key}}  ${temp_string}
    END

    RETURN  ${file}


Create Registration Request Messages According to CBSD State
    [Documentation]  Description:           Get required registration response data from Infomodel and replace data in files      ${\n}
    ...              Return:                all required requests to compare it with original messages                            ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_side}            # ??
    ...          ${enb_id}              # ENB id
    ...          ${alias}               # connection alias
    ...          ${file_path}           # path to file
    ...          ${cbsd_state}          # ??

    Log  ${bts_side}   #this is here just to pass the static analysis
    ${cbsd_r_list}  Query Infomodel  timeout=5min  alias=${alias}
    ...  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-* is [cbsdRegistrationState = "${cbsd_state}"]
    ${cbsd_count}  Get Length  ${cbsd_r_list}
    ${bts_conf}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*   timeout=30    alias=${alias}
    ${buildVersion}  Get From Dictionary  ${bts_conf}  activeSoftwareVersion
    ${sasUserGroup}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=${alias}
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/SASUSERGROUP_A-1
    ${groupId}  Get From Dictionary  ${sasUserGroup}  groupIdString
    ${requests}  Create List
    FOR  ${i}  IN RANGE  ${cbsd_count}
        ${cbsd_conf_ref}  Query Infomodel  query=get object ${cbsd_r_list[${i}]["dist_name"]}/CONF_REF-1    timeout=30    alias=${alias}
        ${cbsd}  Query Infomodel  query=get object ${cbsd_conf_ref["distName"]}  timeout=30  alias=${alias}
        ${cbsd_ref}  Query Infomodel  query=get object ${cbsd_r_list[${i}]["dist_name"]}/REF-1  timeout=30    alias=${alias}
        ${rmod_dist_name}  Query Infomodel  query=get object ${cbsd_ref["distName"]}  timeout=30    alias=${alias}
        ${rmod}  Query Infomodel  query=get object ${rmod_dist_name["rmodDN"]}  timeout=30    alias=${alias}
        ${request_message}  Get File And Replace Variables  ${file_path}
        ...  userId=${cbsd['userId']}
        ...  fccId=${cbsd['fccId']}
        ...  cbrsaGroupIdCcg=${cbsd['userId']} ${cbsd['cbrsaGroupIdCcg']}
        ...  cbrsaGroupIdIcg=${cbsd['userId']} ${cbsd['cbrsaGroupIdIcg']}
        ...  assignedCbsdId=${cbsd_r_list[${i}]['assignedCbsdId']}
        ...  cbsdCategory=${cbsd_r_list[${i}]['cbsdCategory']}
        ...  cbsdSerialNumber=${cbsd_r_list[${i}]['cbsdSerialNumber']}
        ...  productName=${rmod['productName']}
        ...  softwareVersion=${buildVersion}
        ...  groupId=${groupId}

        #NEW SAS SIM SYNTAX FIX IFOLOGY
        IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
            ${request_message}  Replace String  ${request_message}  ${cbsd['userId']} ${cbsd['cbrsaGroupIdCcg']}
            ...  ${cbsd['userId']}${cbsd['cbrsaGroupIdCcg']}
        ELSE
            ${request_message}  Set Variable  ${request_message}
        END
        IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
            ${request_message}  Replace String  ${request_message}  u"WF_ENHANCED_GROUP_HANDLING"  u"WF_ENH_GROUP_HANDLING",u"WF_GRANT_UPDATE"
        ELSE
            ${request_message}  Set Variable  ${request_message}
        END
        #NEW SAS SIM SYNTAX FIX IFOLOGY


        ${dict}  Evaluate  ${request_message}
        Append To List  ${requests}  ${dict}
    END

    RETURN  ${requests}


Create Messages With Required CBSD State
    [Documentation]  Description:           Create message for CBSD which are in required state from provided file      ${\n}
    ...              Return:                all required requests to compare it with original messages ??               ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_side}            # ??
    ...          ${enb_id}              # ENB id
    ...          ${alias}               # connection alias
    ...          ${file_path}           # path to file
    ...          ${cbsd_state}          # ??
    Log  ${bts_side}   #this is here just to pass the static analysis
    ${cbsd_r_list}  Query Infomodel  timeout=30  alias=${alias}
    ...  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-* is [cbsdRegistrationState = "${cbsd_state}"]
    ${cbsd_count}  Get Length  ${cbsd_r_list}
    ${messages}  Create List
    FOR  ${i}  IN RANGE  ${cbsd_count}
        ${cbsd_conf_ref}  Query Infomodel  query=get object ${cbsd_r_list[${i}]["dist_name"]}/CONF_REF-1    timeout=30    alias=${alias}
        ${cbsd}  Query Infomodel  query=get object ${cbsd_conf_ref["distName"]}  timeout=30  alias=${alias}
        ${message}  Get File And Replace Variables  ${file_path}
        ...  userId=${cbsd['userId']}
        ...  fccId=${cbsd['fccId']}
        ...  cbsdSerialNumber=${cbsd_r_list[${i}]['cbsdSerialNumber']}
        ${dict}  Evaluate  ${message}
        Append To List  ${messages}  ${dict}
    END

    RETURN  ${messages}


Create Registration Response Messages With Error Code
    [Documentation]  Description:           Get required reqistration response data and replaces data in file            ${\n}
    ...              Return:                all required responses with specific responseCode to CBSD in provided state  ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_side}            # ??
    ...          ${enb_id}              # ENB id
    ...          ${alias}               # connection alias
    ...          ${file_path}           # path to file
    ...          ${cbsd_state}          # ??
    ...          ${responseData}        # ??
    Log  ${bts_side}   #this is here just to pass the static analysis
    ${cbsd_r_list}  Query Infomodel  timeout=30  alias=${alias}
    ...    query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-* is [cbsdRegistrationState = "${cbsd_state}"]
    ${cbsd_count}  Get Length  ${cbsd_r_list}
    ${responses}  Create List
    FOR  ${i}  IN RANGE  ${cbsd_count}
        ${output}  Get File And Replace Variables  ${file_path}  responseData=${responseData}
        ${response}  Evaluate  ${output}
        Append To List  ${responses}  ${response}
    END

    RETURN  ${responses}


Get Messages From SAS Log
    [Documentation]  Description:           Extract message from specific period of time in SAS_Sim.log      ${\n}
    ...              Return:                fetched data                                         ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${sas_log}             # path to SAS_Sim.log file ??
    ...          ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${message}             # ??

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log}  date_start=${time_start}  date_stop=${time_stop}
    ${extracted_message}  Extract Values From Sas Log  log_name=${parsed_log_file}  parameter=${message}  data_type=${message}

    RETURN  ${extracted_message}


Compare Messages
    [Documentation]  Description:           Check if messages in provided list are the same      ${\n}
    ...              Return:                nonen                                                ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${line}                # ??
    ...          ${list}                # ??

    FOR  ${message}  IN  @{list}
        ${status}  Run Keyword And Return Status  Lists Should Be Equal  ${message}  ${line}
        Exit For Loop IF  "${status}"=="True"
    END
    Should Be Equal  ${status}  ${TRUE}


Check Fault Presence On Selected Cell
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${cell_id}             # cell id
    ...          ${fault_id}            # alarm id
    ...          ${alarm_name}          # alarm name
    ...          ${supplAlarmInfo}      # ??
    ...          ${bts_side}            # ?? ENB id ?

    Log  ${bts_side}   #this is here just to pass the static analysis
    ${query}  Set Variable  /MRBTS-*/RAT-*/LTS-*/LNBTS_L-*/LNCEL_L-${cell_id}/ALARM_L-*

    ute_admin_infomodel.Query InfoModel  timeout=120  alias=RAT_1ST
    ...  query=check ${query} is [alarmInformation.faultId=${fault_id}]
    ute_admin_infomodel.Query InfoModel  timeout=120  alias=RAT_1ST
    ...  query=check ${query} is [alarmInformation.alarmText.alarmDetail="${alarm_name}"]
    ute_admin_infomodel.Query InfoModel  timeout=120  alias=RAT_1ST
    ...  query=check ${query} is [alarmInformation.alarmText.alarmAdditionalInfo.supplAlarmInfo="${supplAlarmInfo}"]


Get Unregistered CBSD IDs
    [Documentation]  Description:           Get unregistered CBSD id                             ${\n}
    ...              Return:                List of unregistered CBSD id's                       ${\n}
    ...              Output:                { @{list} }                                          ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${bts_side}            # ??
    ...          ${alias}               # connection alias

    Log  ${bts_side}   #this is here just to pass the static analysis
    ${affected_cbsd_list}  Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-* is [cbsdRegistrationState = "Unregistered"]
    ${cbsd_id_list}  Create List
    FOR  ${i}  IN  @{affected_cbsd_list}
        ${cbsd_ref}  Query Infomodel  query=get object ${i["dist_name"]}/REF-1  timeout=30  alias=${alias}
        ${cbsd_ref_distName}  Get From Dictionary  ${cbsd_ref}  distName
        ${cbsd_id}  Fetch from Right  ${cbsd_ref_distName}  CBSD-
        Append To List  ${cbsd_id_list}  ${cbsd_id}
    END

    RETURN  ${cbsd_id_list}


Add ICG And CCG Group ID
    [Documentation]  Description:           Add ICG And CCG Group Type to BTS configuration      ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    Replace Variables In File  file_path=${CURDIR}/Delta/Add_ICG_and_CCG_GroupID_${SUM_OF_CBSDS}xAZQC.json
    ...  file_destination=${OUTPUT_DIR}/Add_ICG_and_CCG_GroupID_${SUM_OF_CBSDS}xAZQC.json
    ...   enb_id=${testlines.${testline_id}.enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/Add_ICG_and_CCG_GroupID_${SUM_OF_CBSDS}xAZQC.json  connection=RAT_1ST


Delete ICG And CCG Group ID
    [Documentation]  Description:           Add ICG And CCG Group Type to BTS configuration      ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    Replace Variables In File  file_path=${CURDIR}/Delta/Delete_ICG_and_CCG_GroupID_${SUM_OF_CBSDS}xAZQC.json
    ...  file_destination=${OUTPUT_DIR}/Delete_ICG_and_CCG_GroupID_${SUM_OF_CBSDS}xAZQC.json
    ...  enb_id=${testlines.${testline_id}.enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/Delete_ICG_and_CCG_GroupID_${SUM_OF_CBSDS}xAZQC.json  connection=RAT_1ST


Get CBSD IDs
    [Documentation]  Description:           Keyword gets all CBSD IDs and returns as a list      ${\n}
    ...              Return:                List of all CBS D                                    ${\n}
    ...              Output:                { @{list} }                                          ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${bts_side}            # ??
    ...          ${alias}               # connection alias

    Log  ${bts_side}   #this is here just to pass the static analysis
    Log  ${${enb_id}}   #this is here just to pass the static analysis
    ${affected_cbsd_list}  Query Infomodel  timeout=30  alias=RAT_1ST
    ...  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-*
    ${cbsd_id_list}  Create List
    FOR  ${i}  IN  @{affected_cbsd_list}
        ${cbsd_ref}  Query Infomodel  query=get object ${i["dist_name"]}/REF-1  timeout=30  alias=${alias}
        ${cbsd_ref_distName}  Get From Dictionary  ${cbsd_ref}  distName
        ${cbsd_id}  Fetch from Right  ${cbsd_ref_distName}  CBSD-
        Append To List  ${cbsd_id_list}  ${cbsd_id}
    END

    RETURN  ${cbsd_id_list}


Required Cell Block Status Should Be Reached
    [Documentation]  Description:           Check if given blockingState is reached on given cell   ${\n}
    ...              Return:                true/false status                                    ${\n}
    ...              Output:                { ${bolean} }                                        ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${cell_id}             # cell id
    ...          ${expected_status}     # expected status on cell
    ...          ${enb_id}              # ENB id
    ...          ${bts_side}            # ??
    ...          ${alias}=RAT_1ST       # connection alias

    Log  ${bts_side}   #this is here just to pass the static analysis
    ${status}  ute_admin_infomodel.Query Infomodel  timeout=30  alias=${alias}
    ...  query=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-${cell_id} is [blockingState=${expected_status}]
    Log  Cell ${cell_id} block status reached: ${status}  console=True

    RETURN  ${status}


Create Message With Provided CBSD Cell
    [Documentation]  Description:           Create SAS message: RelinquishmentRequest/Response or
    ...                                     FreatureDataRequest/Response or registrationRequest/Response
    ...                                     according to provided CBSD cell using data from Infomodel??                            ${\n}
    ...              Return:                created SAS message ??                               ${\n}
    ...              Output:                { &{dictionary} }                                    ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_side}              # ??
    ...          ${enb_id}                # ENB id
    ...          ${alias}                 # connection alias
    ...          ${file_path}             # ??
    ...          ${cell_id}               # cell id
    ...          ${cbsd_id}               # CBSD id

    Log  ${bts_side}   #this is here just to pass the static analysis
    ${cbsd_r}  Query Infomodel  query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-${cbsd_id}
    ...  timeout=30  alias=${alias}
    ${grantId}  Fetch Grant ID of selected cell  ${enb_id}  ${cell_id}
    ${cbsd_conf_ref}  Query Infomodel  query=get object ${cbsd_r[0]["dist_name"]}/CONF_REF-1  timeout=30    alias=${alias}
    ${cbsd}  Query Infomodel  query=get object ${cbsd_conf_ref["distName"]}  timeout=30  alias=${alias}
    ${cbsd_ref}  Query Infomodel  query=get object ${cbsd_r[0]["dist_name"]}/REF-1  timeout=30  alias=${alias}
    ${rmod_dist_name}  Query Infomodel  query=get object ${cbsd_ref["distName"]}  timeout=30  alias=${alias}
    ${rmod}  Query Infomodel  query=get object ${rmod_dist_name["rmodDN"]}  timeout=30  alias=${alias}
    ${bts_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*  timeout=30    alias=${alias}
    ${buildVersion}  Get From Dictionary  ${bts_conf}  activeSoftwareVersion
    ${message}  Get File And Replace Variables  ${file_path}
    ...  userId=${cbsd['userId']}
    ...  fccId=${cbsd['fccId']}
    ...  cbsdSerialNumber=${cbsd_r[0]['cbsdSerialNumber']}
    ...  grantId=${grantId}
    ...  softwareVersion=${buildVersion}
    ...  cbrsaGroupIdCcg=${cbsd['userId']} ${cbsd['cbrsaGroupIdCcg']}
    ...  cbrsaGroupIdIcg=${cbsd['userId']} ${cbsd['cbrsaGroupIdIcg']}
    ...  assignedCbsdId=${cbsd_r[0]['assignedCbsdId']}
    ...  cbsdCategory=${cbsd_r[0]['cbsdCategory']}
    ...  productName=${rmod['productName']}
    ${dict}  Evaluate  ${message}

    RETURN  ${dict}


Get Time For Specific Message From SAS_Sim.log
    [Documentation]  Description:           Get date of the provided message from SAS_Sim.log ?? ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ${string} ??? }                                    ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${sas_log}             # path to SAS_Sim.log file ??
    ...          ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${message}             # ??

    ${parsed_log}  Parse Sas Log File  log_file_name=${sas_log}  date_start=${time_start}  date_stop=${time_stop}
    ${message_lines}  Create List
    FOR  ${line}  IN  @{parsed_log}
        ${status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${line}  ${message}
        IF  ${status}==True  Append To List  ${message_lines}  ${line}
    END
    ${messages}  Set Variable  ${message_lines}
    ${message_dates}  Extract Values From Sas Log  log_name=${messages}  parameter=date

    RETURN  ${message_dates}


Check Synchronization Between VM And eNB
    [Documentation]  Description:           Check time synchronization between VM and eNB        ${\n}
    ...              Return:                synchronization status                               ${\n}
    ...              Output:                { ${boolean} ?? }                                    ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_hostname}=192.168.255.129    # BTS ip for SSH connection

    SSHLibrary.Open Connection  ${enb_hostname}
    SSHLibrary.Login  ${credentials.enb_username}  ${credentials.enb_password}
    ${enb_date}  SSHLibrary.Execute command  date +"[%d/%b/%Y:%k:%M:%S %z]"
    ${vm_date}  OperatingSystem.Run  date +"[%d/%b/%Y:%k:%M:%S %z]"
    ${status}  Run Keyword And Return Status  Should Be Equal  ${enb_date}  ${vm_date}
    SSHLibrary.Close Connection

    RETURN  ${status}


Update NTP Server Address On VM
    [Documentation]  Description:           Update NTP Server Adrress On VM                      ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${ntpServerIpAddr}     # ??

    OperatingSystem.Run  sudo service ntp stop
    Sleep  5s
    ${update_status}  OperatingSystem.Run  sudo ntpdate ${ntpServerIpAddr}
    Sleep  5s
    OperatingSystem.Run  sudo service ntp start
    Log  ${update_status} ${\n}Synchronized!  console=True


Synchronize Time Between VM And eNB In Case Of Difference
    [Documentation]  Description:           Update NTP Server Address on VM if there is time offset between them     ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.palamarz@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${attempts}=2          # how many times KW should try to synchronize the time
    ...          ${alias}=RAT_1ST       # connection alias

    ${ntp_r}  Query Infomodel  query=get object //RUNTIME_VIEW-*//CLOCK_CONF_M-1/NTP_CONF_M-1  timeout=30    alias=${alias}
    ${sw}  Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*  timeout=30  alias=${alias}
    ${sw_build}  Fetch From Left  ${sw}[activeSoftwareVersion]  _

    # IFOLOGY FOR 23R2, 23R3, 23R4
    ${ntp_im}  Set Variable If
    ...  '${sw_build}'=='SBTS23R2' or '${sw_build}'=='SBTS23R3' or '${sw_build}'=='SBTS23R4'
    ...  ntpServerIpAddrList  ntpServerIpAddrOrFqdnList
    ${ntpIpAddr}  Get From Dictionary  ${ntp_r}  ${ntp_im}
    FOR   ${i}  IN RANGE  ${1}  ${attempts}+1
        ${is_time_synchronized}  Check Synchronization Between VM And eNB
        IF  '${is_time_synchronized}'=='False'
            Update NTP Server Address On VM  ${ntpIpAddr[0]}
        ELSE
            Exit For Loop
        END
    END


Check For Re-registration Event
    [Documentation]  Description:           Lookup for occurence of deregistrationRequest, then for a new registrationRequest   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??
    ...          ${cbsd_id}             # CBSD id

    ${parsed_log_file}  Parse Sas Log File
    ...  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${deregistration_request_cbsdId}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdId  data_type=deregistrationRequest  packet_amount=1
    Should Contain  ${deregistration_request_cbsdId}  ${cbsd_id}
    ${registration_request_cbsd_SN}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdSerialNumber  data_type=registrationRequest  packet_amount=1
    Should Not Be Empty  ${registration_request_cbsd_SN}


Check The Return Code Of SAS Response
    [Documentation]  Description:           Takes SASSim.log as an input with given time boundaries and returns
    ...                                     responseCode of defined procedure.                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}
    ...          ${procedure}

    ${parsed_log_file}  Parse Sas Log File
    ...  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${response_code}   Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=responseCode  data_type=${procedure}  packet_amount=1

    RETURN  ${response_code[0]}


Check If CBSD Has Only Requested Available Channels
    [Documentation]  Description:           Ensures that the low frequency boundaries of grants authorized on CBSD are a subset
    ...                                     of the ones indicated by SAS as available.??         ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${available_channels_list}     # ??
    ...          ${grant_info}                  # ??

    ${authorized_channels_grantId}  Create List
    ${number_of_grants}  Get Length  ${grant_info}
    FOR  ${grant}  IN RANGE  ${number_of_grants}
        IF  '${grant_info[${grant}]['grantState']}' == 'Authorized'  Append to list  ${authorized_channels_grantId}
        ...  ${grant_info[${grant}]['grantId']}
    END
    @{authorized_channels_high_low_split}  Create List
    FOR  ${channel}  IN RANGE  ${number_of_grants}
        ${split_channels}  Split String  ${authorized_channels_grantId[${channel}]}  separator=_
        Append To List  ${authorized_channels_high_low_split}  ${split_channels}
    END
    @{authorized_channels_lowFreq_list}  Create List
    FOR  ${channel}  IN RANGE  ${number_of_grants}
        ${lowFreq_of_authorized_channel_int}  Convert To Integer  ${authorized_channels_high_low_split[${channel}][0]}
        Append To List  ${authorized_channels_lowFreq_list}  ${lowFreq_of_authorized_channel_int}
    END
    @{available_channels_lowFreq_list}  Create List
    ${available_channels_count}  Get Length  ${available_channels_list}
    FOR  ${channel}  IN RANGE  ${available_channels_count}
        Append To List  ${available_channels_lowFreq_list}  ${available_channels_list[${channel}]['lowFrequency']}
    END
    List Should Contain Sub List  ${available_channels_lowFreq_list}  ${authorized_channels_lowFreq_list}


Get Grant Details For Each CBSD Cell
    [Documentation]  Description:           Iterates through the available CBSDs and its Cells using infomodel, fetches all the Grant
    ...                                     Details and returns it as a list of dictionaries     ${\n}
    ...              Return:                Fetched grant details                                ${\n}
    ...              Output:                { @{list} }                                          ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST                   # connection alias
    ...          ${check_each_CBSD}=${TRUE}         # ??
    ...          ${CBSD_id}=${1}                    # CBSD id

    ${CBSD_id_to_be_checked}  Set Variable If  ${check_each_CBSD} != ${TRUE}  ${CBSD_id}  *
    ${CBSD_details}  ute_admin_infomodel.Query Infomodel  timeout=60  alias=${alias}
    ...  query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-${CBSD_id_to_be_checked}

    ${Grants_detail}  ute_admin_infomodel.Query Infomodel  timeout=60  alias=${alias}
    ...  query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-${CBSD_id_to_be_checked}/GRANT_INFO-*

    ${cell_count}  Get Length  ${Grants_detail}
    ${grant_list}  Create List

    FOR  ${i}  IN RANGE  ${cell_count}
        ${cell_id}  fetch from right  ${Grants_detail[${i}]["cellDN"]}  -
        ${Cell}  create dictionary
        Set To Dictionary  ${Cell}  Cell ID=${cell_id}
        Set To Dictionary  ${Cell}  cellDN=${Grants_detail[${i}]["cellDN"]}
        Set To Dictionary  ${Cell}  grantId=${Grants_detail[${i}]["grantId"]}
        Set To Dictionary  ${Cell}  grantMaxEirp=${Grants_detail[${i}]["grantMaxEirp"]}
        Set To Dictionary  ${Cell}  grantState=${Grants_detail[${i}]["grantState"]}
        Set To Dictionary  ${Cell}  grantChannelType=${Grants_detail[${i}]["grantChannelType"]}
        Append to list  ${grant_list}  ${Cell}
    END

    RETURN  ${grant_list}


Check If Granted Channels Follow FrequencyGuidance
    [Documentation]  Description:           Queries eNB for authorized grants and compares their grantIDs
    ...                                     with data received in the frequencyGuidance          ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { @{list} ?? }                                       ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??
    ...          ${grant_list}          # ??

    ${authorized_channels}  Create List
    ${number_of_grants}  Get Length  ${grant_list}
    FOR  ${grant}  IN RANGE  ${number_of_grants}
        IF  '${grant_list[${grant}]['grantState']}' == 'Authorized'  Append to list  ${authorized_channels}  ${grant_list[${grant}]['grantId']}
    END

    ${frequency_guidance_SI_response}  Read Frequency Guidance From SASSim Log  time_start=${time_start}  time_stop=${time_stop}
    ...  sas_log_path=${sas_log_path}

    List Should Contain Sub List  ${frequency_guidance_SI_response}  ${authorized_channels}

    RETURN  ${authorized_channels}


Read Frequency Guidance From SASSim Log
    [Documentation]  Description:           Get cbsdFrequencyGuidance in spectrumInquiryResponse from log file
    ...                                     and combines allowed channels into a list            ${\n}
    ...              Return:                allowed channels list                                ${\n}
    ...              Output:                { @{list} }                                          ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log ??

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${frequency_guidance_object}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdFrequencyGuidance  data_type=spectrumInquiryResponse

    ${number_of_channels}  Get Length  ${frequency_guidance_object[0]}
    ${frequency_guidance_channels_list}  Create List
    FOR  ${i}  IN RANGE  ${number_of_channels}
        ${low_frequency}  Set Variable  ${frequency_guidance_object[0][${i}]['frequencyRange']['lowFrequency']}
        ${high_frequency}  Set Variable  ${frequency_guidance_object[0][${i}]['frequencyRange']['highFrequency']}
        ${merged_channel}  Catenate  SEPARATOR=_  ${low_frequency}  ${high_frequency}
        Append To List  ${frequency_guidance_channels_list}  ${merged_channel}
    END

    RETURN  ${frequency_guidance_channels_list}


Check If Inquiry is TS2.0 Compliant
    [Documentation]  Description:           Compare data stored in the infomodel with parameters exchanged in the SpectrumInquiry procedure.
    ...                                     Modified procedure shall include groupingParam object
    ...                                     and the inquired channels are to be of 5MHz width??  ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}               # connection alias
    ...          ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??
    ...          ${enb_id}              # ENB id

    ute_admin_infomodel.Query Infomodel  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...  timeout=360  alias=${alias}
    ${CBSD_details}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*
    ...  timeout=60  alias=${alias}
    ${assignedCbsdId}  Get From Dictionary  ${CBSD_details}  assignedCbsdId

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${SI_request_cbsd_Id}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdId  data_type=spectrumInquiryRequest  packet_amount=1
    ${SI_request_inquiredSpectrum}   Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=inquiredSpectrum  data_type=spectrumInquiryRequest  packet_amount=1
    ${SI_request_inquiredSpectrum_count}   Get Length    ${SI_request_inquiredSpectrum[0]}
    ${SI_response_cbsd_Id}   Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdId  data_type=spectrumInquiryResponse  packet_amount=1
    ${SI_response_available_channels}   Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=availableChannel  data_type=spectrumInquiryResponse  packet_amount=1
    ${SI_response_available_channels_count}  Get Length  ${SI_response_available_channels[0]}

    ${availableChannels_list}  Create List
    FOR  ${i}  IN RANGE  ${SI_response_available_channels_count}
        Append To List  ${availableChannels_list}  ${SI_response_available_channels[0][${i}]['frequencyRange']}
    END
    ${5MHz_channel_in_Hz}  Evaluate  int(5000000)

    FOR  ${channel}  IN RANGE  ${SI_request_inquiredSpectrum_count}
        ${lowFrequency}  Get From Dictionary  ${SI_request_inquiredSpectrum[0][${channel}]}  lowFrequency
        ${highFrequency}  Get From Dictionary  ${SI_request_inquiredSpectrum[0][${channel}]}  highFrequency
        ${channel_bandwidth}  Evaluate  ${highFrequency}-${lowFrequency}
        Should be Equal  ${channel_bandwidth}  ${5MHz_channel_in_Hz}
    END

    Should Be Equal  ${SI_request_cbsd_Id[0]}  ${assignedCbsdId}
    Should Be Equal  ${SI_response_cbsd_Id[0]}  ${assignedCbsdId}
    List Should Contain Sub List  ${SI_request_inquiredSpectrum[0]}  ${availableChannels_list}

    ${groupingParam}  Extract groupingParam from SAS log
    ...  time_start=${time_start}  time_stop=${time_stop}  sas_log_path=${sas_log_path}  enb_id=${enb_id}  procedure=spectrumInquiryRequest

    Should be Equal  ${groupingParam[0][0]['groupType']}  COEXISTENCE_GROUP
    Should be Equal  ${groupingParam[0][0]['groupId']}  CBRS_ALLIANCE
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaVersion']}  v2.0
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['frameStructure'][0]}  FS2
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupType']}  CBRSA_CCG
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupType']}  CBRSA_ICG

    RETURN  ${availableChannels_list}


Extract groupingParam from SAS log
    [Documentation]  Description:           Get groupingParam object of defined procedure from the SASSim.log file      ${\n}
    ...              Return:                groupingParam object ??                              ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]      ${time_start}          # start time of read data
    ...              ${time_stop}           # end time of read data
    ...              ${sas_log_path}        # path to SAS_Sim.log file ??
    ...              ${enb_id}              # ENB id
    ...              ${procedure}           # ??

    Log  ${enb_id}  #this is here just to pass the static analysis
    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${extracted_groupingParam}  Extract Values From Sas Log  log_name=${parsed_log_file}  parameter=groupingParam  data_type=${procedure}

    RETURN  ${extracted_groupingParam}


Get WInnForum TS Version From Infomodel
    [Documentation]  Description:           Get wINNFTSVersion parameter indicating TS version   ${\n}
    ...              Return:                wINNFTSVersion parameter                             ${\n}
    ...              Output:                { ${string} ?? }                                     ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}               # connection alias

    ute_admin_infomodel.Query Infomodel  query=none /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="None"]
    ...  timeout=120  alias=${alias}

    ${CBRSPR_object}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-*
    ...  timeout=60  alias=${alias}
    ${wINNFTSVersion}  Set Variable  ${CBRSPR_object['wINNFTSVersion']}

    RETURN  ${wINNFTSVersion}


Wait For Any Grant To Be Authorized
    [Documentation]  Description:           Get wINNFTSVersion parameter indicating TS version   ${\n}
    ...              Return:                wINNFTSVersion parameter                             ${\n}
    ...              Output:                { ${string} ?? }                                     ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}               # connection alias

    ${CBRSPR_object}  ute_admin_infomodel.Query Infomodel  timeout=120  alias=${alias}
    ...  query=check /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-* is [grantState=Authorized]


Verify ICG And CCG In Procedure
    [Documentation]  Description:           check whether valid CCG and ICG parameters are passed to the selected procedure   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??
    ...          ${enb_id}              # ENB id
    ...          ${procedure}           # ??
    ...          ${alias}=RAT_1ST       # connection alias

    ute_admin_infomodel.Query Infomodel  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...  timeout=360  alias=${alias}

    ${fccId}  ${userId}  Get FCC And User Ids From Infomodel

    ${CBSD_params}  ute_admin_infomodel.Query Infomodel  timeout=60  alias=${alias}
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBSD_A-1

    ${CCG_value}  Set Variable  ${CBSD_params['cbrsaGroupIdCcg']}
    ${ICG_value}  Set Variable  ${CBSD_params['cbrsaGroupIdIcg']}

    ${ICG_index}  Set Variable If  '${CCG_value}' == 'None'  ${0}  ${1}

    ${groupingParam}  Extract groupingParam from SAS log  time_start=${time_start}  time_stop=${time_stop}  sas_log_path=${sas_log_path}
    ...  enb_id=${enb_id}  procedure=${procedure}

    Should be Equal  ${groupingParam[0][0]['groupType']}  COEXISTENCE_GROUP
    Should be Equal  ${groupingParam[0][0]['groupId']}  CBRS_ALLIANCE
    IF  '${CCG_value}' != 'None'  Should be Equal
    ...  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupType']}  CBRSA_CCG
    IF  '${ICG_value}' != 'None'  Should be Equal
    ...  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][${ICG_index}]['cbrsaGroupType']}  CBRSA_ICG


Check If Number Of Feature Data Exchanges Is Correct
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}               # connection alias
    ...          ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??

    Log  ${alias}   #this is here just to pass the static analysis
    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}    date_stop=${time_stop}
    ${log_len}  Get Length  ${parsed_log_file}
    ${parsed_log_file_string}  Set Variable  ${\n}
    FOR  ${i}  IN RANGE  ${log_len}
        ${parsed_log_file_string}  Catenate  ${parsed_log_file_string}  ${parsed_log_file[${i}]}  ${\n}
    END

    #NEW SAS SIM SYNTAX FIX IFOLOGY
    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${lines_with_data_exchange}  Get Lines Containing String  ${parsed_log_file_string}  featureCapabilityExchangeRequest
    ELSE
        ${lines_with_data_exchange}  Get Lines Containing String  ${parsed_log_file_string}  featureDataRequest
    END
    #NEW SAS SIM SYNTAX FIX IFOLOGY

    ${num_of_data_exchanges}  Get Line Count  ${lines_with_data_exchange}
    Should Be True  ${num_of_data_exchanges}>${2}


Check If Grant Request is TS2.0 Compliant
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}                       # connection alias
    ...          ${time_start}                  # start time of read data
    ...          ${time_stop}                   # end time of read data
    ...          ${sas_log_path}                # path to SAS_Sim.log file
    ...          ${numberOfCells}               # number of CBSD cells
    ...          ${allowed_low_frequencies}     # ??
    ...          ${exp_max_eirp}=14.1           # expected max EIRP

    Wait For All Cells To Be OnAir
    ute_admin_infomodel.Query Infomodel  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...  timeout=360  alias=${alias}
    ${CBSD_details}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*
    ...  timeout=60  alias=${alias}
    ${assignedCbsdId}  Get From Dictionary  ${CBSD_details}  assignedCbsdId

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}

    ${grant_request_cbsd_Id}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}    parameter=cbsdId    data_type=grantRequest    packet_amount=1
    ${grant_request_operation_param}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}    parameter=operationParam    data_type=grantRequest    packet_amount=1
    ${grant_request_grouping_param}   Extract Values From Sas Log
    ...  log_name=${parsed_log_file}    data_type=grantRequest    parameter=groupingParam    packet_amount=1

    ${ccgGroupId}  Generate Correct Grant GroupId  GroupId=Testccg  assignedCbsdId=${assignedCbsdId}
    ${icgGroupId}  Generate Correct Grant GroupId  GroupId=Testicg  assignedCbsdId=${assignedCbsdId}

    #NEW SAS SIM SYNTAX FIX IFOLOGY
    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${ccgGroupId}  Remove String  ${ccgGroupId}  ${SPACE}
    ELSE
        ${ccgGroupId}  Set Variable  ${ccgGroupId}
    END

    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${icgGroupId}  Remove String  ${icgGroupId}  ${SPACE}
    ELSE
        ${icgGroupId}  Set Variable  ${icgGroupId}
    END
    #NEW SAS SIM SYNTAX FIX IFOLOGY

    Check If Grant Frequency Ranges Are Correct  ${grant_request_operation_param}  ${allowed_low_frequencies}  ${numberOfCells}

    FOR  ${cell_num}  IN RANGE  ${numberOfCells}
        Should Be Equal  ${grant_request_cbsd_Id[${cell_num}]}  ${assignedCbsdId}
        Should Be Equal As Strings
        ...  ${grant_request_operation_param[${cell_num}]['maxEirp']}  ${exp_max_eirp}
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupType']}  COEXISTENCE_GROUP
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupId']}  CBRS_ALLIANCE
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaVersion']}  v2.0
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['frameStructure'][0]}  FS2
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupType']}
        ...  CBRSA_CCG
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupId']}
        ...  ${ccgGroupId}
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupType']}
        ...  CBRSA_ICG
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupId']}
        ...  ${icgGroupId}
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ulDLConfig']}  2
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ssfConfig']}  7
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ulDLConfig']}  2
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ssfConfig']}  7
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ulDLConfig']}  2
        Should Be Equal As Strings
        ...  ${grant_request_grouping_param[${cell_num}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ssfConfig']}  7
    END


Wait For 5G Cells To Be OnAir
    [Documentation]  Description:    Wait 10min until all cells become in onAir state${\n}
    ...              Return:         None                                            ${\n}
    ...              Output:         {}                                              ${\n}
    ...              Author:         piotr.lukaszewicz@nokia.com                     ${\n}
    ...              Maintainer:     CBRS Team                                       ${\n}
    [Arguments]  ${alias}=RAT_1ST     # connection alias
    ...          ${wait_time}=10min   # waiting time / timeout
    [Timeout]  ${wait_time}

    FOR  ${i}  IN RANGE  9999    #do-while loop
        ${onAir_flag}  Run Keyword And Return Status  Query InfoModel
        ...  query=every //NRBTS_M-*//CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAirDone"]
        ...  timeout=10  alias=${alias}

        IF  ${onAir_flag}  Sleep  10sec
        ${onAir_flag}  Run Keyword And Return If  ${onAir_flag}  Run Keyword And Return Status
        ...  Query InfoModel  query=every //NRBTS_M-*//CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAirDone"]
        ...  timeout=5  alias=${alias}

        Exit For Loop If  ${onAir_flag}    #loop end statement
    END


Generate Correct Grant GroupId
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${GroupId}             # ??
    ...          ${assignedCbsdId}      # ??

    ${initial_cbsd_id}  Split String  ${assignedCbsdId}  separator=_
    ${grantGroupId}  Catenate  ${initial_cbsd_id[0]}  ${GroupId}

    RETURN  ${grantGroupId}


Check If Grant Frequency Ranges Are Correct
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${grant_request_operation_param}       # ??
    ...          ${allowed_low_frequencies}             # ??
    ...          ${numberOfCells}                       # ??

    ${10MHz_channel_in_Hz}  Evaluate  int(10000000)
    FOR  ${cell_num}  IN RANGE  ${numberOfCells}
        ${low_frequency}  Set Variable  ${grant_request_operation_param[${cell_num}]['operationFrequencyRange']['lowFrequency']}
        ${high_frequency}  Set Variable  ${grant_request_operation_param[${cell_num}]['operationFrequencyRange']['highFrequency']}
        List Should Contain Value  ${allowed_low_frequencies}  ${low_frequency}
        ${channel_bandwidth}  Evaluate  ${high_frequency}-${low_frequency}
        Should be Equal  ${channel_bandwidth}  ${10MHz_channel_in_Hz}
    END


Get Number of Cells
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id

    ${enabled_cells_list}  List Phycell Values For All Cells  enb_id=${enb_id}
    ${num_of_cells}  Get Length  ${enabled_cells_list}

    RETURN  ${num_of_cells}


Get Number of 5G Cells
    [Documentation]  Description:           Get number of 5G cells from Info Model               ${\n}
    ...              Return:                number of 5G cells                                   ${\n}
    ...              Output:                { ${string} }                                        ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${gnb_id}              # gNB id
    ...          ${alias}=RAT_1ST       # alias
    ...          ${mrbts_gnb_id}=${NONE}                            # target gNB mrbts_id

    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${mrbts_gnb_id}
    IF  ${status}
        ${mrbts_id}  Set Variable  ${mrbts_gnb_id}
    ELSE
        ${mrbts_id}  Set Variable  ${gnb_id}
    END

    @{phycell_param_list}  ute_admin_infomodel.Query Infomodel  alias=${alias}
    ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${mrbts_id}/NRBTS_A-${gnb_id}/NRCELL_A-*
    ${cell_num}  Get Length  ${phycell_param_list}
    ${phycell_list}  Create List
    FOR  ${i}  IN RANGE  ${cell_num}
        Append To List  ${phycell_list}  ${phycell_param_list[${i}]['physCellId']}
    END
    ${num_of_cells}  Get Length  ${phycell_list}

    RETURN  ${num_of_cells}


Check If Grant Of Terminated Cell Has Changed
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${old_grant_id}                # ??
    ...          ${new_grant_id}                # ??
    ...          ${required_new_grant_id}       # ??

    Should Not Be Empty  ${old_grant_id}
    Should Not Be Empty  ${new_grant_id}
    Should Not Be Equal As Strings  ${old_grant_id}  ${new_grant_id}
    Should Be Equal  ${new_grant_id}  ${required_new_grant_id}


Check If Grants Of Other Cell Remain Unchanged
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${old_grant_ids}       # ??
    ...          ${new_grant_ids}       # ??
    ...          ${oldCellGrantId}      # ??
    ...          ${newCellGrantId}      # ??

    Should Not Be Empty  ${old_grant_ids}
    Should Not Be Empty  ${new_grant_ids}
    Remove Values From List  ${old_grant_ids}  ${oldCellGrantId}
    Remove Values From List  ${new_grant_ids}  ${newCellGrantId}
    Sort List  ${old_grant_ids}
    Sort List  ${new_grant_ids}
    Lists Should Be Equal  ${old_grant_ids}  ${new_grant_ids}


Check If All Frequencies Are Within Allowed Range
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${grantIds}            # ??
    ...          ${allowedGrantIds}     # ??

    Should Not Be Empty  ${grantIds}
    ${numberOfGrants}  Get Length  ${grantIds}
    FOR  ${i}  IN RANGE  ${numberOfGrants}
        List Should Contain Value  ${allowedGrantIds}  ${grantIds[${i}]}
    END


Check If Grant Of Suspended Cell Has Changed
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${old_grant_id}        # ??
    ...          ${new_grant_id}        # ??

    Should Not Be Empty  ${old_grant_id}
    Should Not Be Empty  ${new_grant_id}
    Should Not Be Equal As Strings  ${old_grant_id}  ${new_grant_id}


Check If Only One Cell Is Disabled And Other Remain Enabled
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}
    ...          ${terminated_cell_number}
    ...          ${enabled_cells_list}

    ${num_of_enabled_cells}  Get Length  ${enabled_cells_list}
    Check If Cell State Is Reached  cell_id=${terminated_cell_number}  state=operationalState  state_value=Disabled  alias=${alias}
    FOR  ${i}  IN RANGE  ${num_of_enabled_cells}
        Check If Cell State Is Reached  cell_id=${enabled_cells_list[${i}]}  state=operationalState  state_value=Enabled   alias=${alias}
    END
    Sleep  10s  #sleep is needed because this keyword is done many times to continously check status, it cannot be done too quickly


Check If Cell State Is Reached
    [Documentation]  Description:           Check if cell state is reached                       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${cell_id}             # cell id
    ...          ${state}               # state name
    ...          ${state_value}         # state value
    ...          ${alias}=RAT_1ST       # connection alias
    ...          ${timeout}=10          # timeout time

    Query Infomodel  query=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/LNCEL_R-${cell_id} is [${state}=regex"(?i)${state_value}"]
    ...  alias=${alias}  timeout=${timeout}


Get Random Cell Number
    [Documentation]  Description:           Randomly pick one cell number                        ${\n}
    ...              Return:                cell number                                          ${\n}
    ...              Output:                { ${string} ?? }                                     ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${cells_list}          # list of cells ??

    ${random_value}  Evaluate  random.sample(${cells_list}, 1)  modules=random

    RETURN  ${random_value[0]}


List Phycell Values For All Cells
    [Documentation]  Description:           List values of phycells                              ${\n}
    ...              Return:                Phycell values list                                  ${\n}
    ...              Output:                { @{list} }                                          ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id

    @{phycell_param_list}  ute_admin_infomodel.Query Infomodel  alias=RAT_1ST
    ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNCEL_A-*
    ${cell_num}  Get Length  ${phycell_param_list}
    ${all_phycell_list}  Create List
    FOR  ${i}  IN RANGE  ${cell_num}
        Append To List  ${all_phycell_list}  ${phycell_param_list[${i}]['phyCellId']}
    END
    ${phycell_list}  Remove Duplicates  ${all_phycell_list}

    RETURN  ${phycell_list}


Continously Check If Number Of Enabled Cells Is Adequate
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    FOR  ${j}  IN RANGE  ${20}
        ${num_of_enabled_cells}  Check Num Of Enabled Cells
        IF  ${num_of_enabled_cells}<${3}  FAIL  msg=Too many cells dropped
        IF  ${num_of_enabled_cells}==${4}  RETURN
        Sleep  10s
    END
    Sleep  600s
    FAIL  msg=Cells didn't come back on air
    #TODO: Remove


Check Num Of Enabled Cells
    [Documentation]  Description:           Get number of enabled cells on ENB                   ${\n}
    ...              Return:                number of enabled cells                              ${\n}
    ...              Output:                { ${integer} }                                       ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    @{enabled_cells}  create list  @{EMPTY}
    ${result}  Run Keyword And Return Status  Check If Cell State Is Reached  cell_id=1  state=operationalState  state_value=Enabled  alias=${alias}
    IF	${result}  append to list  ${enabled_cells}  1
    ${result}  Run Keyword And Return Status  Check If Cell State Is Reached  cell_id=2  state=operationalState  state_value=Enabled  alias=${alias}
    IF	${result}  append to list  ${enabled_cells}  2
    ${result}  Run Keyword And Return Status  Check If Cell State Is Reached  cell_id=3  state=operationalState  state_value=Enabled  alias=${alias}
    IF	${result}  append to list  ${enabled_cells}  3
    ${result}  Run Keyword And Return Status  Check If Cell State Is Reached  cell_id=4  state=operationalState  state_value=Enabled  alias=${alias}
    IF	${result}  append to list  ${enabled_cells}  4
    ${num_of_enabled_cells}  Get Length  ${enabled_cells}

    RETURN  ${num_of_enabled_cells}
    #TODO: Remove


Check If Cell Status Remains Onair
    [Documentation]  Description:           Run KW in loop: Repeat Keyword    15    Check If..
    ...                                     - Check if cell is online for given period of time   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST

    All Cells Should Be Enabled And Onair  times=1x  alias=${alias}
    Sleep  10s    #sleep is needed because this keyword is done many times to continously check status, it cannot be done too quickly
    #TODO: Remove


Verify Presence of featureDataExchange After Certain Procedure
    [Documentation]  Description:           Extracts the featureDataResponse and featureDataRequest objects
    ...                                     that occur after featureDataExchangeConfig in previous CBRS procedures in the SASSim.log file
    ...                                     and verifies the content of featureId object.        ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??
    ...          ${start_from}          # ??

    @{cbsdFeatureList}  Create List  WF_ENHANCED_GROUP_HANDLING  WF_ENH_GROUP_HANDLING  WF_GRANT_UPDATE
    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}

    #NEW SAS SIM SYNTAX FIX IFOLOGY
    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${dataNamespace}  Set Variable  featureCapabilityExchange
    ELSE
        ${dataNamespace}  Set Variable  featureData
    END

    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${parametrNamespace}  Set Variable  cbsdFeatureCapabilityList
    ELSE
        ${parametrNamespace}  Set Variable  cbsdFeatureInfo
    END
    #NEW SAS SIM SYNTAX FIX IFOLOGY

    ${featureCapabilityExchangeRequest}  Extract Values From Sas Log  log_name=${parsed_log_file}
    ...    parameter=${parametrNamespace}  data_type=${dataNamespace}Request  start_from=${start_from}  packet_amount=1

    ${featureCapabilityExchangeResponse}  Extract Values From Sas Log  log_name=${parsed_log_file}
    ...  parameter=responseCode  data_type=${dataNamespace}Response  start_from=${start_from}  packet_amount=1

    #NEW SAS SIM SYNTAX FIX IFOLOGY
    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${readedFeatureList}  Create List      ${featureCapabilityExchangeRequest[0][0]}
    ELSE
        ${readedFeatureList}  Create List    ${featureCapabilityExchangeRequest[0][0]['featureId']}
    END
    #NEW SAS SIM SYNTAX FIX IFOLOGY

    List Should Contain Sub List  ${cbsdFeatureList}  ${readedFeatureList}
    Should Not Be Empty  '${featureCapabilityExchangeResponse}'


Get Testline ID
    [Documentation]  Description:           Get testline ID                                      ${\n}
    ...              Return:                testline id                                          ${\n}
    ...              Output:                { ${string} }                                        ${\n}
    ...              Author:                lukasz.lechiwicz@nokia.com                           ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    ${rc}  ${stdout}  Run and Return RC and Output  hostname
    ${parsed_ute_alias}  Get Regexp Matches  ${stdout}  (\\d+\\-\\d+\\-)([A-Z0-9]+)  2
    ${hostname_trim}  Get Regexp Matches  ${stdout}  (\\d+\\-\\d+\\-[A-Z0-9]+)  1
    ${hostname_underscore}  Replace String  string=${hostname_trim[0]}  search_for=-  replace_with=_
    Set Suite Variable  ${testline_id}  ${parsed_ute_alias[0]}
    Set Suite Variable  ${config_hostname}  ${hostname_underscore}
    Run Keyword And Ignore Error  Log  \n\nTesting runs on configuration:\n\n ${testlines.${testline_id}}

    RETURN  ${testline_id}


Apply CBRS Debug Log Flags
    [Documentation]  Description:           Update CBRS debug flags if needed                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${enb_hostname}=192.168.255.129    # hostname for enb i.e. ${testlines.${testline_id}.node2.vm_ip}
    ...          ${alias}=RAT_1ST                   # admin connection alias

    @{CBRS_debug_flags}  Create List
    ...  0x450064=1               # ERadLteSysAdapter_PrintCbrs - OLD ONE
    ...  0x450004=1               # ERadLteSysAdapter_PrintCbrs - NEW ONE
    ...  0x450065=1               # ?? IM ??
#    ...  0x45000B=1               # ERadLteSysAdapter_UseTrialCert - enable vendor certificates

    Add Swconfig Flags  flag_list=@{CBRS_debug_flags}  enb_hostname=${enb_hostname}  alias=${alias}


Wait For One NP Object
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${alias}=RAT_1ST       # connection alias

    ${np}  ute_admin_infomodel.Query Infomodel  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*    alias=${alias}
    ${length}  Get Length  ${np}
    Should Be Equal As Integers  ${length}  1
    #TODO: Check if remove possible


Check If CBSD Is Registered As TS2.0 Compliant
    [Documentation]  Description:           Check whether CBSD is registered in SAS using TS2.0 protocol      ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${alias}               # connection alias

    ute_admin_infomodel.Query Infomodel  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...  timeout=360  alias=${alias}


Disable CRBS Mobility enhancement Feature On eNB
    [Documentation]  Description:           Stop CBRS feature                                    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${alias}=RAT_1ST
    ...          ${enb_id}=${testlines.${testline_id}.enb_id}   #TODO: copy this to other KW

    Replace Variables In File  file_path=${CURDIR}/Delta/actCbrsMobEnh_disable.json
    ...  file_destination=${OUTPUT_DIR}/actCbrsMobEnh_disable.json  enb_id=${testlines.${testline_id}.enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/actCbrsMobEnh_disable.json    connection=${alias}


Enable CRBS Mobility enhancement Feature On eNB
    [Documentation]  Description:           Starting CBRS feature                                ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${alias}=RAT_1ST                                   # connection alias
    ...          ${enb_id}=${testlines.${testline_id}.enb_id}       # ENB id

    Replace Variables In File  file_path=${CURDIR}/Delta/actCbrsMobEnh_enable.json  file_destination=${OUTPUT_DIR}/actCbrsMobEnh_enable.json
    ...  enb_id=${enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/actCbrsMobEnh_enable.json    connection=${alias}


Get Earfcn Value By Cell Id
    [Documentation]  Description:           Get earfcn value from given cell id                  ${\n}
    ...              Return:                earfcn value                                         ${\n}
    ...              Output:                { ${string} ?? }                                     ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${cell_id}             # cell id
    ...          ${alias}=RAT_1ST       # connection alias

    ${cell_mo}  Query Infomodel  alias=${alias}
    ...  query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_id}/LNCEL_TDD_A-*

    RETURN  ${cell_mo["earfcn"]}


Get Grant Value By Cell Id
    [Documentation]  Description:           Get grant value from given cell id                   ${\n}
    ...              Return:                grant value                                          ${\n}
    ...              Output:                { ${string} ?? }                                     ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${cell_id}             # cell id
    ...          ${alias}=RAT_1ST       # connection alias

    ${cbsdcell_mo}  Query Infomodel  alias=${alias}
    ...  query=get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/LNCEL_R-${cell_id}/CBSDCEL_R-*

    RETURN  ${cbsdcell_mo["grantId"]}


Get Channel Type For Cell
    [Documentation]  Description:           Extract grantChannelType from infomodel, runtime view     ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${enb_id}              # ENB id
    ...          ${cell_number}         # cell id
    ...          ${alias}=RAT_1ST       # connection alias

    ${cbsdcel_data}  ute_admin_infomodel.Query Infomodel  alias=${alias}
    ...  query=get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-${cell_number}/CBSDCEL_R-*

    RETURN  ${cbsdcel_data.grantChannelType}


Start Logging On Second eNB
    [Documentation]  Description:           Start logging and set up libraries: Btssm (RAT_2ND), Syslog (RAT_2ND), Infomodel (RAT_2ND)${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${logs_dir_path}       # path where logs should be created

    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Setup Infomodel
    ...  address=${testlines.${testline_id}.node2.mplane_ip_addr}  port=443  timeout=60  alias=RAT_2ND
    Wait Until Keyword Succeeds  6x  10s  ute_admin_infomodel.Connect Infomodel  alias=RAT_2ND
    # virtualenv_dir needed to start syslog on remote host
    Start Syslog  log_dir=${logs_dir_path}  log_name=syslog_RAT_2ND.log  alias=RAT_2ND
    ...  host_ip=${testlines.${testline_id}.node2.vm_ip}  virtualenv_dir=/home/ute/test_repo


Stop Logging On Second eNB
    [Documentation]  Description:           Stop logging and teardown libraries: Syslog (RAT_2ND), Infomodel (RAT_2ND)    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${logs_dir_path}        # path where logs should be saved

    Run Keyword And Ignore Error  Run Keyword If Test Failed  taf.sbts.oam.coam.admin.Collect Snapshot  timeout=1800  connection=RAT_2ND
    ...  target_file_name=${logs_dir_path}/snapshot_RAT_2ND.zip
    Stop Syslog  alias=RAT_2ND
    Collect Syslog Results  destination=${logs_dir_path}/  alias=RAT_2ND
    ute_admin_infomodel.Save Infomodel Log  filename=${logs_dir_path}/infomodel_RAT_2ND.ims2  timeout=300  alias=RAT_2ND
    Run  scp ${testlines.${testline_id}.node2.vm_ip}:/${logs_dir_path}/syslog_RAT_2ND.log ${logs_dir_path}/syslog_RAT_2ND.log
    Run  tar -czf ${logs_dir_path}/syslog_RAT_2ND.tar.gz -C ${logs_dir_path} syslog_RAT_2ND.log; rm ${logs_dir_path}/syslog_RAT_2ND.log


Check If 20MHz Cell Is Present
    [Documentation]  Description:           Check if there is any 20MHz cell on eNB. Having such a cell modifies cell pMax calculations  ${\n}
    ...              Return:                presence status                                      ${\n}
    ...              Output:                { ${bolean} }                                        ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                           ${\n}
    [Arguments]  ${enb_id}

    @{lncel_param_list}  ute_admin_infomodel.Query Infomodel  alias=RAT_1ST
    ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNCEL_A-*/LNCEL_TDD_A-0
    ${cell_num}  Get Length  ${lncel_param_list}
    ${chbw_list}  Create List
    FOR  ${i}  IN RANGE  ${cell_num}
        Append To List  ${chbw_list}  ${lncel_param_list[${i}]['chBw']}
    END
    ${20mhz_present}  Run Keyword And Return Status  Should Contain  ${chbw_list}  20 MHz

    RETURN  ${20mhz_present}


Suspend Grant And Confirm Cell Drop
    [Documentation]  Description:           Send grant_suspend command for specified grant ID and check if any cell
    ...                                     dropped. If not, iterate in the next FOR loop run.   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                          ${\n}
    [Arguments]  ${cbsd_id}             # CBSD id
    ...          ${grant_id}            # grant id
    ...          ${enb_alias}=RAT_1ST   # connection alias
    ...          ${attempt_count}=3     # number of tries
    ...          ${print_details}=True  # print in the console which grant ID has been suspended

    FOR  ${i}  IN RANGE  ${attempt_count}
        Send Command To SAS Manager  alias=default  command=grant_suspend ${cbsd_id} ${grant_id}
        ${is_command_executed}  Run Keyword And Return Status  Wait For Any Cell To Be Dropped  alias=${enb_alias}
        Exit For Loop If  '${is_command_executed}'=='True'
    END
    Log  Grant ${grant_id} has been suspended.  console=${print_details}


Terminate Grant And Confirm Cell Drop
    [Documentation]  Description:           Send grant_terminate command for specified grant IDs and check if any cell
    ...                                     dropped. If not, iterate in the next FOR loop run.   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                          ${\n}
    [Arguments]  ${cbsd_id}             # CBSD id
    ...          ${grant_id}            # grant id
    ...          ${enb_alias}=RAT_1ST   # connection alias
    ...          ${attempt_count}=3     # number of tries
    ...          ${print_details}=True  # print in the console which grant ID has been suspended

    FOR  ${i}  IN RANGE  ${attempt_count}
        Send Command To SAS Manager  alias=default  command=grant_terminate ${cbsd_id} ${grant_id}
        #SAS Grant Termination Revocation Failure
        #Wait Until Keyword Succeeds  60x  5s  taf.sbts.oam.coam.admin.Assert Alarm Active  faultId=6823  alias=RAT_1ST
        ${is_command_executed}  Run Keyword And Return Status  Wait For Any Cell To Be Dropped  alias=${enb_alias}
        Exit For Loop If  '${is_command_executed}'=='True'
    END
    Log  Grant ${grant_id} has been suspended.  console=${print_details}


Terminate Two Grants And Confirm Cells Drop
    [Documentation]  Description:           Send grant_terminate command for specified two grant IDs and check if any cell dropped.
    ...                                     If not, iterate in the next FOR loop run             ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                          ${\n}
    [Arguments]  ${cbsd_id_1}           # CBSD id - 1st termination
    ...          ${grant_id_1}          # grant id - 1st termination
    ...          ${cbsd_id_2}           # CBSD id - 2nd termination
    ...          ${grant_id_2}          # grant id - 2nd termination
    ...          ${enb_alias}=RAT_1ST   # connection alias
    ...          ${attempt_count}=3     # number of tries

    FOR  ${i}  IN RANGE  ${attempt_count}
        Send Command To SAS Manager  alias=default  command=grant_terminate ${cbsd_id_1} ${grant_id_1}
        Send Command To SAS Manager  alias=default  command=grant_terminate ${cbsd_id_2} ${grant_id_2}
        ${is_command_executed}  Run Keyword And Return Status  Wait For Any Cell To Be Dropped  alias=${enb_alias}
        Exit For Loop If  '${is_command_executed}'=='True'
    END


Check If Grant Terminate Message Appeared In Sas Log
    [Documentation]  Description:           Filter SAS log between two timestamps to check if there are mngGrantTerminateRequest
    ...                                     and mngGrantTerminateResponse for defined grant_id.            ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                          ${\n}
    [Arguments]  ${sas_log_name}        # ??
    ...          ${start_timestamp}     # start time of read data
    ...          ${stop_timestamp}      # end time of read data
    ...          ${grant_id}            # grant id

    ${log_file}  Parse Sas Log File  log_file_name=${sas_log_name}  date_start=${start_timestamp}  date_stop=${stop_timestamp}
    ${sas_log_string}  Convert To String  ${log_file}
    Should Match Regexp  ${sas_log_string}  .*mngGrantTerminateRequest.*grantId.*${grant_id}.*
    Should Match Regexp  ${sas_log_string}  .*mngGrantTerminateResponse.*responseCode.*0
    Log  Grant ${grant_id} has been terminated.  console=True


Add Swconfig Flags
    [Documentation]  Description:           Add flags from given list = { 0xAAAAAA=X, 0xBBBBBB=Y, .. } to swconfig.txt, compare each flag
    ...                                     with actual swconfig.txt values, if flag is present it will be overwriten only when it has different
    ...                                     value, if it is not present it will be added.        ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                             ${\n}
    ...              Maintainer:            karol.sadowski@nokia.com                             ${\n}
    [Arguments]  ${flag_list}                               # list of flags to add
    ...          ${enb_hostname}=192.168.255.129            # const ?
    ...          ${alias}=RAT_1ST                           # admin connection alias
    [Timeout]  10 min

    Wait Until Keyword Succeeds  20x  10s  SSHLibrary.Open Connection  ${enb_hostname}
    SSHLibrary.Login  ${credentials.enb_username}  ${credentials.enb_password}

    Log To Console  \n============ Uploading swconfig flags on ${alias} ============\n@{flag_list}\n

    ${swconfig}  SSHLibrary.Execute command  cat /ffs/run/swconfig.txt
    ${added}  Set Variable  ${0}
    ${modified}  Set Variable  ${0}

    FOR  ${i}  IN  @{flag_list}
        ${i}  Remove String  ${i}  ${SPACE}
        ${flag}  Fetch From Left  ${i}  =
        ${value}  Fetch From Right  ${i}  =
        ${flagOccurrences}  Run Keyword And Ignore Error
        ...  Get Regexp Matches  ${swconfig}  (?m)^\\s{0,2}${flag}\\s{0,2}=.*

        IF  '${flagOccurrences[0]}'=='FAIL'
            ${isFlagPresent}  Set Variable  ${0}
        ELSE
            ${isFlagPresent}  Get Length  ${flagOccurrences[1]}
        END
        IF  ${isFlagPresent}>1  Fail  Flag: ${i} has more than one occurrency in swconfig.txt file. Abort update!

        ${flagOccurrences}  Convert To String  ${flagOccurrences[1]}
        ${currentValue}  Get Regexp Matches  ${flagOccurrences}  (=\\s{0,1})(\\d)    2
        ${swconfigMod}  Replace String Using Regexp  ${swconfig}  ${flag}\\s{0,2}=\\s{0,2}\\d  ${i}
        ${swconfigAdd}  Catenate  SEPARATOR=${\n}  ${swconfig}  ${i}

        IF  ${isFlagPresent}==0
            ${added}  Evaluate  ${added}+1
        ELSE
            ${added}  Set Variable  ${added}
        END
        ${swconfig}  Set Variable If  ${isFlagPresent}==0
        ...  ${swconfigAdd}  ${swconfig}
        IF  ${isFlagPresent}==0
            Log To Console  Flag: ${i} has been added!
            Continue For Loop
        END

        IF   ${isFlagPresent}==1 and ${value}==${currentValue[0]}
            Log To Console     Flag: ${i} present in file, skip!
            Continue For Loop
        END

        IF  ${isFlagPresent}==1 and ${value}!=${currentValue[0]}
            ${modified}  Evaluate  ${modified}+1
        ELSE
            ${modified}  Set Variable  ${modified}
        END
        ${swconfig}  Set Variable If  ${isFlagPresent}==1 and ${value}!=${currentValue[0]}
        ...  ${swconfigMod}  ${swconfig}
        IF  ${isFlagPresent}==1 and ${value}!=${currentValue[0]}
            Log To Console  Flag: ${i} has been updated!
            Continue For Loop
        END
    END

    IF  ${added}==0 and ${modified}==0
        Log To Console  swconfig file not changed, BTS reboot not needed.
        RETURN  'PASS'
    ELSE
        Log To Console  Applying changes.. BTS Reboot is needed.
    END

    @{data}  Split To Lines  ${swconfig}
    SSHLibrary.Execute command  rm /ffs/run/swconfig.txt
    FOR  ${i}  IN  @{data}
        SSHLibrary.Execute command  echo '${i}' >> /ffs/run/swconfig.txt
    END

    taf.sbts.oam.coam.admin.Reset Site  connection=${alias}  wait_for_reconnection=True

    Log To Console  Flags added: ${added} | flags modified: ${modified}

    [Teardown]  SSHLibrary.Close Connection


Remove Swconfig Flag
    [Documentation]  Description:           Remove given flag from swconfig.txt                  ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                michal.moskala@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${flag_list}                               # list of flags to add or single flag without value
    ...          ${enb_hostname}=192.168.255.129            # const ?
    ...          ${alias}=RAT_1ST                           # admin connection alias
    [Timeout]  10 min

    Log To Console  \n============= Removing swconfig flags on ${alias} ============\n${flag_list}

    Wait Until Keyword Succeeds  20x  10s  SSHLibrary.Open Connection  ${enb_hostname}
    SSHLibrary.Login  ${credentials.enb_username}  ${credentials.enb_password}

    ${swconfig}  SSHLibrary.Execute command  cat /ffs/run/swconfig.txt
    ${removed}  Set Variable  ${0}
    ${is_list}  Evaluate  isinstance(${flag_list}, list)
    IF  ${is_list}
        @{flags}  Set Variable    ${flag_list}
    ELSE
        @{flags}  Create List     ${flag_list}
    END
    FOR  ${i}  IN  @{flags}
        ${flagOccurrences}  Run Keyword And Ignore Error
        ...  Get Regexp Matches  ${swconfig}  (?m)^\\s{0,2}${i}\\s{0,2}=.*
        IF  '${flagOccurrences[0]}'=='FAIL'
            Log To Console    Flag: ${i} not found, skipped!
        ELSE
            SSHLibrary.Execute command    sed -i '/^${i}/d' /ffs/run/swconfig.txt
        END
        IF  '${flagOccurrences[0]}'!='FAIL'
            ${removed}  Evaluate    ${removed}+1
        ELSE
            ${removed}  Set Variable    ${removed}
        END
    END

    IF  ${removed}>0
        Log To Console  ${removed}${SPACE}flag(s) removed! Performing site reset  AND
        Wait Until Keyword Succeeds  6x  10s  taf.sbts.oam.coam.admin.Reset Site  connection=${alias}  wait_for_reconnection=True
    ELSE
        Log To Console  No flags removed, dont need to reset site.
    END

    [Teardown]  SSHLibrary.Close Connection


Check Cells
    [Documentation]  Description:           Check status of all cells configured on testline.    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${admin_alias}         # connection alias
    [Timeout]  10min

    log to console with time  -== Checking Cell Status ==-

    ${rc_l}  ${lncel_list}  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all
    ...  class_name=LNCEL  connection=${admin_alias}  timeout=60
    ${rc_w}  ${wncel_list}  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all
    ...  class_name=WNCEL  connection=${admin_alias}  timeout=60
    ${rc_g}  ${gncel_list}  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all
    ...  class_name=GNCEL  connection=${admin_alias}  timeout=60
    ${rc_n}  ${nrcel_list}  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all
    ...  class_name=NRCEL  connection=${admin_alias}  timeout=60

    IF  '${rc_l}'=='FAIL'
        @{lncel_list}  create list
    ELSE
        @{lncel_list}  set variable  ${lncel_list}
    END
    IF  '${rc_w}'=='FAIL'
        @{wncel_list}  create list
    ELSE
        @{wncel_list}  set variable  ${wncel_list}
    END
    IF  '${rc_g}'=='FAIL'
        @{gncel_list}  create list
    ELSE
        @{gncel_list}  set variable  ${gncel_list}
    END
    IF  '${rc_n}'=='FAIL'
        @{nrcel_list}  create list
    ELSE
        @{nrcel_list}  set variable  ${nrcel_list}
    END

    ${lncel_list_length} get length  ${lncel_list}
    ${wncel_list_length} get length  ${wncel_list}
    ${gncel_list_length} get length  ${gncel_list}
    ${nrcel_list_length} get length  ${nrcel_list}

    IF  '${lncel_list_length}'=='0' and '${wncel_list_length}'=='0' and
        IF  '${gncel_list_length}'=='0' and '${nrcel_list_length}'=='0'
            Fail  cell_list_length==0 waiting for correct cell list
        END
    END

    log to console with time  ${SPACE * 5}-= Checking LTE Cells=-
    FOR  ${cell}  IN  @{lncel_list}
        log to console with time
        ...  ${SPACE * 7} [${cell['proceduralState']}, ${cell['operationalState']}, ${cell['administrativeState']}]
    END

    log to console with time  ${SPACE * 5}-=Checking WCDMA Cells=-
    FOR  ${cell}  IN  @{wncel_list}
        log to console with time
        ...  ${SPACE * 7} [${cell['operationalState']}]
    END

    log to console with time  ${SPACE * 5}-=Checking GSM Cells=-
    FOR  ${cell}  IN  @{gncel_list}
        log to console with time
        ...  ${SPACE * 7} [${cell['operationalState']}, ${cell['administrativeState']}]
    END

    log to console with time  ${SPACE * 5}-=Checking 5G Cells=-
    FOR  ${cell}  IN  @{nrcel_list}
        log to console with time
        ...  ${SPACE * 7} [${cell['operationalState']}, ${cell['administrativeState']}]
    END

    # check
    # LNCEL (LTE)
    FOR  ${cell}  IN  @{lncel_list}
        IF  '${cell['proceduralState']}'!='OnAirDone'
            Fail  Incorrect cell status @{lncel_list}
        ELSE IF  '${cell['operationalState']}'!='enabled'
            Fail  Incorrect cell status @{lncel_list}
        ELSE IF  '${cell['administrativeState']}'!='unlocked'
            Fail  Incorrect cell status @{lncel_list}
        END
    END

    # WNCEL (WCDMA)
    FOR  ${cell}  IN  @{wncel_list}
        IF  '${cell['operationalState']}'!='enabled'  Fail  Incorrect cell status @{wncel_list}
    END

    # GNCEL (GSM)
    FOR  ${cell}  IN  @{gncel_list}
        IF  '${cell['operationalState']}'!='enabled'
            Fail  Incorrect cell status @{gncel_list}
        ELSE IF  '${cell['administrativeState']}'!='Unlocked'
            Fail  Incorrect cell status @{gncel_list}
        END
    END

    # NRCEL (5G)
    FOR  ${cell}  IN  @{nrcel_list}
        IF  '${cell['operationalState']}'!='enabled'
            Fail  Incorrect cell status @{nrcel_list}
        ELSE IF  '${cell['administrativeState']}'!='Unlocked'
            Fail  Incorrect cell status @{nrcel_list}
        END
    END

    [Teardown]  Run Keywords
    ...  IF  '${KEYWORD STATUS}'=='PASS'  Log to console with time  ->Cells looks OK
    ...  AND  IF  '${KEYWORD STATUS}'=='FAIL'  Log to console with time  ->Incorrect cell status


Log To Console With Time
    [Documentation]  Description:           Keyword log given output with time to console.       ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            CBRS team                                            ${\n}
    [Arguments]  ${output}              # string to log

    @{time}  Get Time  hour min sec  NOW
    ${time_now}  Catenate  SEPARATOR=:  @{time}[0]  @{time}[1]  @{time}[2]
    Log  (${time_now}) ${output}  console=True


Perform RMOD Reset
    [Documentation]  Description:    Reset of randomly picked BBMOD from all available BBMODs on eNB.${\n}
    ...              Return:         None                                                            ${\n}
    ...              Output:         {}                                                              ${\n}
    ...              Author:         aleksandra.chudzik@nokia.com                                    ${\n}
    ...              Maintainer:     aleksandra.chudzik@nokia.com                                    ${\n}
    [Arguments]  ${alias}=RAT_1ST  # connection alias

    ${rmod_list}  taf.sbts.oam.coam.admin.Get Parameters For All  class_name=RMOD  connection=${alias}
    ${rmod_distname}  Set Variable  ${rmod_list[0]['id']}
    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Reset Unit  dist_name=${rmod_distname}  reset_type=Warm  timeout=120  connection=${alias}
    Log  ${\n}------- Reset of RMOD ${rmod_list[0]['productName']} ${rmod_list[0]['serialNumber']} -------  console=True


Perform Power Reset Of Randomly Picked RMOD
    [Documentation]  Description:           Power Reset Of Randomly Picked RMOD from all available on eNB in loops.    ${\n}
    ...              Return:                None                                                                       ${\n}
    ...              Output:                {}                                                                         ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                 ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com                                               ${\n}
    [Arguments]  ${alias}=RAT_1ST       #connection alias

    Get Testline ID
    Import Variables  /home/ute/testline_configuration/${config_hostname}/__init__.py
    ${nodes}  Get Dictionary With Testline PDU Details
    ${radio_list}   Get Random radio Object    alias=${alias}
    ${radio_sn}  Set Variable  ${radio_list[0]['serialNumber']}
    ${pdu_model}  Set Variable  ${nodes['${radio_sn}']['pdu_model']}
    ${pdu_ip}  Set Variable  ${nodes['${radio_sn}']['pdu_ip']}
    ${pdu_port}  Set Variable  ${nodes['${radio_sn}']['pdu_port']}
    IF  ${node_count}==${1}
        ${pdu_version}  Set Variable  ${nodes['${radio_sn}']['pdu_version']}
    ELSE
        ${pdu_version}  Set Variable  ${testlines.${testline_id}.pdu_1.pdu_version}
    END

    taf.hw.pdu.Setup Pdu  host=${pdu_ip}  model=${pdu_model}  version=${pdu_version}
    taf.hw.pdu.Power On  ${pdu_port}
    Wait For Any Cell To Be Dropped

    [Teardown]  Run Keywords
    ...  taf.hw.pdu.Power Off  ${pdu_port}  AND
    ...  Log  ------- RMOD ${radio_list[0]['productName']} ${radio_list[0]['serialNumber']} Powered On again -------    console=True


Get Random Radio Object
    [Documentation]  Description:           Filter SAS log between two timestamps to check if there are mngGrantTerminateRequest
    ...                                     and mngGrantTerminateResponse for defined grant_id.            ${\n}
    ...              Return:                none                                                           ${\n}
    ...              Output:                {}                                                             ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                     ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                                     ${\n}
	[Arguments]  ${alias}=RAT_1ST

	IF  ${node_count}==${1}
	    Prepare Radio List For Single Node
	ELSE
	    Prepare Radio List For Two Nodes
	END
	${radio_list}  taf.sbts.oam.coam.admin.Get Parameters For All  class_name=RMOD  connection=${alias}
	${random_object}  Evaluate  random.sample(${radio_list}, 1)  modules=random

	RETURN  ${random_object}


Prepare Radio List For Single Node
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            unknown                                              ${\n}

    ${radio_list}  taf.sbts.oam.coam.admin.Get Parameters For All  class_name=RMOD  connection=RAT_1ST

    RETURN  ${radio_list}


Prepare Radio List For Two Nodes
    [Documentation]  Description:           ??                                                   ${\n}
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                unknown                                              ${\n}
    ...              Maintainer:            unknown                                              ${\n}
    [Arguments]  ${node2_alias}=RAT_2ND  # connection alias

    #TODO: check
    taf.sbts.oam.coam.admin.setup admin  name=${node2_alias}
    ${radio_list_node1}  taf.sbts.oam.coam.admin.Get Parameters For All  class_name=RMOD  connection=RAT_1ST
    ${radio_list_node2}  taf.sbts.oam.coam.admin.Get Parameters For All  class_name=RMOD  connection=${node2_alias}
    ${radio_list}  Combine Lists  ${radio_list_node1}  ${radio_list_node2}

    RETURN  ${radio_list}
    [Teardown]  taf.sbts.oam.coam.admin.teardown_admin  connection=${node2_alias}


Get Dictionary With Testline PDU Details
    [Documentation]  Description:           Iterates through Gerrit-like __init.py__ testline configuration file.
    ...                                     Returns a dictionary with Radio Serial numbers as keys names and their PDU details as keys values ${\n}
    ...              Return:                {'BL2047Y22LL': {u'pdu_ip': '10.42.80.20', u'pdu_model': 'EPC', u'pdu_port': 8}}    ${\n}
    ...              Output:                { &{dictionary} }                                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                          ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                                                          ${\n}

    ${config_length}  Get Length  ${tl.enbs}
    Set Suite Variable  ${node_count}  ${config_length}
    @{testline_rmod_count}  Create list
    FOR  ${i}  IN RANGE  ${node_count}
        ${node_rmod_count}  Get Length  ${tl.enbs[${i}].rms}
        Append to list  ${testline_rmod_count}  ${node_rmod_count}
    END

    ${total_rmod_count}  Set Variable  ${0}
    FOR  ${i}  IN RANGE  ${node_count}
        ${total_rmod_count}  Evaluate  ${total_rmod_count}+${testline_rmod_count}[${i}]
    END

    ${final_dict}  Create Dictionary
    ${node_1}  Get PDU Details For Specific Node    final_dict=${final_dict}    bts_index=${0}    testline_rmod_count=${testline_rmod_count}
    ${node_2}  IF  ${node_count}>${1}  Get PDU Details For Specific Node  bts_index=${1}  testline_rmod_count=${testline_rmod_count}
    ...  final_dict=${final_dict}

    RETURN  ${final_dict}


Get PDU Details For Specific Node
    [Documentation]  Description:           Takes a list of Radio counts on each node and a node index.
    ...                                     Returns a specific node dictionary with Radio Serial number as key name
    ...                                     and its PDU details as key value.                                                   ${\n}
    ...              Return:                {'BL2047Y22LL': {u'pdu_ip': '10.42.80.20', u'pdu_model': 'EPC', u'pdu_port': 8}}    ${\n}
    ...              Output:                { &{dictionary} }                                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                          ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                                                          ${\n}
    [Arguments]  ${final_dict}              # ??
    ...          ${testline_rmod_count}     # ??
    ...          ${bts_index}=${0}          # ??

    ${node_dict}  Create Dictionary
    FOR  ${i}  IN RANGE  ${testline_rmod_count}[${bts_index}]
        ${temp_dict}  Create Dictionary
        Set To Dictionary  ${temp_dict}  pdu_port=${tl.enbs[${bts_index}].rms[${i}].pdu_port.port_no}
        ...  pdu_ip=${tl.enbs[${bts_index}].rms[${i}].pdu_port.pdu.addr}
        ...  pdu_model=${tl.enbs[${bts_index}].rms[${i}].pdu_port.pdu.model}
        ...  pdu_version=${tl.enbs[${bts_index}].rms[${i}].pdu_port.pdu.version}
        Set To Dictionary  ${final_dict}  ${tl.enbs[${bts_index}].rms[${i}].serial_number}=${temp_dict}
    END

    RETURN  ${final_dict}


Perform Lock/Unlock Of Randomly Picked RMOD
    [Documentation]  Description:          Lock and unlock of randomly picked RMOD from all available RMODs on eNB.            ${\n}
    ...              Return:               {'BL2047Y22LL': {u'pdu_ip': '10.42.80.20', u'pdu_model': 'EPC', u'pdu_port': 8}}    ${\n}
    ...              Output:               { &{dictionary} }                                                                   ${\n}
    ...              Author:               aleksandra.chudzik@nokia.com                                                        ${\n}
    ...              Maintainer:           aleksandra.chudzik@nokia.com                                                        ${\n}
    [Arguments]  ${alias}=RAT_1ST      # connection alias

    Get Testline ID
    Import Variables  /home/ute/testline_configuration/${config_hostname}/__init__.py
    ${nodes}  Get Dictionary With Testline PDU Details
    ${radio_list}  Get Random Radio Object
    ${radio_distname}  Set Variable   ${radio_list[0]['id']}

    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Lock  dist_name=${radio_distname}  timeout=180  connection=${alias}
    Query Infomodel  alias=${alias}  query=check ${radio_distname} is [administrativeState=Locked, operationalState=enabled]    timeout=120

    [Teardown]  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  taf.sbts.oam.coam.admin.Unlock  dist_name=${radio_distname}  timeout=120  connection=${alias}


Perform Block Unblock Of Randomly Picked Cells
    [Documentation]  Description:           Block and unblock of randomly picked cell from all available cells on eNB.    ${\n}
    ...              Return:                None                                                                          ${\n}
    ...              Output:                {}                                                                            ${\n}
    ...              Author:                katarzyna.kadziela@nokia.com                                                  ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com                                                  ${\n}
    [Arguments]  ${alias}=RAT_1ST

    ${random_cell_ID}  Get Random Cell ID  alias=${alias}

    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Block Cell  dist_name=${random_cell_ID}  timeout=180  connection=${alias}
    taf.sbts.oam.coam.admin.Assert Alarm Active  faultId=49, severity=Critical  alias=${alias}  timeout=120

    [Teardown]  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  taf.sbts.oam.coam.admin.Unblock Cell  dist_name=${random_cell_ID}  timeout=60  connection=${alias}  AND
    ...  taf.sbts.oam.coam.admin.Assert Alarm Inactive  faultId=49, severity=Critical  alias=${alias}  timeout=120


Get Random Cell ID
    [Documentation]  Description:           Returns random cell ID from list of all avaialbe cells on eNB.                            ${\n}
    ...              Return:                Cell object path - e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1892/LNCEL_R-1    ${\n}
    ...              Output:                { @{string} }                                                                             ${\n}
    ...              Author:                katarzyna.kadziela@nokia.com                                                              ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com                                                              ${\n}
    [Arguments]  ${alias}

    ${gncell_list}  taf.sbts.oam.coam.admin.Get Ids For All  class_name=GNCEL  connection=${alias}
    ${wncell_list}  taf.sbts.oam.coam.admin.Get Ids For All  class_name=WNCEL  connection=${alias}
    ${lncell_list}  taf.sbts.oam.coam.admin.Get Ids For All  class_name=LNCEL  connection=${alias}
    ${nrcell_list}  taf.sbts.oam.coam.admin.Get Ids For All  class_name=NRCEL  connection=${alias}
    ${all_cells_list}  Combine Lists  ${gncell_list}  ${wncell_list}  ${lncell_list}  ${nrcell_list}
    ${random_cell}  Evaluate  random.sample(${all_cells_list}, 1)  modules=random

    RETURN  ${random_cell[0]}


Perform Reset Of Randomly Picked BBMOD
    [Documentation]  Description:           Reset of randomly picked BBMOD from all available BBMODs on eNB.    ${\n}
    ...              Return:                None                                                                ${\n}
    ...              Output:                {}                                                                  ${\n}
    ...              Author:                aleksandra.chudzik@nokia.com                                        ${\n}
    ...              Maintainer:            aleksandra.chudzik@nokia.com                                        ${\n}
    [Arguments]  ${alias}=RAT_1ST

    ${bbmod_list}  taf.sbts.oam.coam.admin.Get Parameters For All  class_name=BBMOD  connection=${alias}
    ${random_bbmod}  Evaluate  random.sample(${bbmod_list}, 1)  modules=random
    ${bbmod_distname}  Set Variable  ${random_bbmod[0]['id']}
    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Reset Unit  dist_name=${bbmod_distname}  reset_type=Warm  timeout=240  connection=${alias}


Check If S1 Link Is Available
    [Documentation]  Description:           KW checks the S1 link status value and fails if the value is not equal to "available".            ${\n}
    ...              Return:                none                                                                                              ${\n}
    ...              Output:                {}                                                                                                ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                                                                       ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                                                                       ${\n}
    [Arguments]  ${enb_id}
    ...          ${timeout}=10
    ...          ${alias}=RAT_1ST

    ${is_s1_link_available}  Run Keyword And Return Status  ute_admin_infomodel.Query Infomodel  timeout=${timeout}  alias=${alias}
    ...  query=check /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNMME_R-* is [s1LinkStatus=available]
    IF  '${is_s1_link_available}'=='False'  Fail    There is no connection to MME via S1 interface!


Start Tracking Historical Alarms
    [Documentation]  Description:           Setups new admin session and adds default fault to allowed list.
    ...                                     Additional allowed faults can be given as argument list   ${\n}
    ...              Return:                none                                                      ${\n}
    ...              Output:                {}                                                        ${\n}
    ...              Author:                Lukasz.lechowicz@nokia.com                                ${\n}
    ...              Maintainer:            Lukasz.lechowicz@nokia.com                                ${\n}
    [Arguments]  ${expected_alarms}=@{EMPTY}    # list of expected alarms
    ...          ${alias}=historical_alarms     # connection alias

    taf.sbts.oam.coam.admin.setup_admin  name=${alias}
    Add Allowed Alarms To Admin Session  alias=${alias}  fault_list=@{enb_allowed_faults}
    IF  @{expected_alarms} != @{EMPTY}  Add Allowed Alarms To Admin Session  alias=${alias}  fault_list=@{expected_alarms}


Add Allowed Alarms To Admin Session
    [Documentation]  Description:           Takes a fault_list argument and adds those faults to allowed list.  ${\n}
    ...              Return:                none                                                                ${\n}
    ...              Output:                {}                                                                  ${\n}
    ...              Author:                Lukasz.lechowicz@nokia.com                                          ${\n}
    ...              Maintainer:            Lukasz.lechowicz@nokia.com                                          ${\n}
    [Arguments]  ${alias}               # connection alias
    ...          ${fault_list}          # list of faults to add

    FOR  ${fault}  IN  @{fault_list}
       taf.sbts.oam.coam.admin.add_allowed_alarm  connection=${alias}  faultId=${fault}
    END


Check Historical Alarms And Teardown Tracking Session
    [Documentation]  Description:           Checks for unwanted historical alarms and tears down dedicated Admin session.
    ...                                     Additional allowed faults can be given as argument list   ${\n}
    ...              Return:                none                                                      ${\n}
    ...              Output:                {}                                                        ${\n}
    ...              Author:                Lukasz.lechowicz@nokia.com                                ${\n}
    ...              Maintainer:            Lukasz.lechowicz@nokia.com                                ${\n}
    [Arguments]  ${alias}=historical_alarms     # connection alias

    Run Keyword And Continue On Failure  taf.sbts.oam.coam.admin.assert_no_unexpected_historical_alarms  connection=${alias}
    taf.sbts.oam.coam.admin.Teardown Admin  connection=${alias}


Get Value Of querySasServerPeriod
    [Documentation]  Description:           Fetch querySasServerPeriod parameter in seconds.     ${\n}
    ...              Return:                querySasServerPeriod in seconds                      ${\n}
    ...              Output:                { int }                                              ${\n}
    ...              Author:                aleksandra.chudzik@nokia.com                         ${\n}
    ...              Maintainer:            aleksandra.chudzik@nokia.com                         ${\n}
    [Arguments]  ${enb_id}              #ENB id
    ...          ${alias}=RAT_1ST       #connection alias

    ${cbrspr_data}  ute_admin_infomodel.Query Infomodel  alias=${alias}
    ...  query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBRSPR_A-*
    ${querySasServerPeriod_value}  Evaluate  ${cbrspr_data.querySasServerPeriod}*60

    RETURN  ${querySasServerPeriod_value}


Wait Until Enhanced Measure Finish
    [Documentation]  Description:           Waiting for enhanced measure occurred and finish
    ...                                     after a given timestamp                              ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                { }                                                  ${\n}
    ...              Author:                karol.sadowski@nokia.com                             ${\n}
    ...              Maintainer:            katarzyna.kadziela@nokia.com                         ${\n}
    [Arguments]  ${listening_timestamp}    #listening start date <date format>
    ...          ${alias}=RAT_1ST          #connection alias
    ...          ${wait_time}=1min         #waiting time / timeout
    [Timeout]  ${wait_time}

    FOR  ${i}  IN RANGE  999
        ${measurment_timestamp}  Run Keyword And Continue On Failure  ute_admin_infomodel.Query Infomodel
        ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_BAND_MEASUREMENT_REPORT-*    alias=${alias}

        #check if IM object is available
        IF  ${measurment_timestamp == None}
            Sleep  1s  #sleep between loop iterations
            CONTINUE    #check in the next iteration if IM object created
        END

        ${timestamp_offset}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/EQM-*/SMOD-*/TIME-1    alias=${alias}
        ${timestamp_offset}  Set Variable  ${timestamp_offset["timeZone"]["timeZoneOffset"]}

        IF  '${measurment_timestamp["measurementReport"][0]["reportTimeStamp"]}' == ''
            Sleep  1s  #sleep between loop iterations
            CONTINUE    #during measure value equals to ''
        ELSE
             ${measurment_timestamp}  Set Variable  ${measurment_timestamp["measurementReport"][0]["reportTimeStamp"]}
        END
        ${measurment_timestamp}  Fetch From Left  ${measurment_timestamp}  .
        ${measurment_timestamp}  Remove String  ${measurment_timestamp}    -    T    :
        ${measurment_timestamp}  Add Time To Date  ${measurment_timestamp}  ${timestamp_offset}min

        ${measurment_timestamp}  Convert Date  ${measurment_timestamp}  result_format=%Y%m%d%H%M%S
        ${listening_timestamp}  Convert Date  ${listening_timestamp}  result_format=%Y%m%d%H%M%S

        Exit For Loop If  ${measurment_timestamp} > ${listening_timestamp}
        Sleep  1s   #sleep between loop iterations
    END


Switch Power Outlet Of BTS Radio Units
    [Documentation]  Description:           Toggle power outlet status of every RMOD on this testline.                 ${\n}
    ...              Return:                None                                                                       ${\n}
    ...              Output:                {}                                                                         ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                 ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com                                                 ${\n}
    [Arguments]  ${action}=power_on     # power state power_on/power_off

    Get Testline ID
    Import Variables  /home/ute/testline_configuration/${config_hostname}/__init__.py
    Log To Console  \n==================== Power Action on PDU ====================
    ${radio_list}  Get Dictionary With Testline PDU Details
    FOR  ${key}  IN   @{radio_list.keys()}
        taf.hw.pdu.Setup Pdu  host=${radio_list["${key}"].pdu_ip}
        ...  model=${radio_list["${key}"].pdu_model}    version=${radio_list["${key}"].pdu_version}
        IF  '${action}'=='power_off'
            taf.hw.pdu.Power On  port=${radio_list["${key}"].pdu_port}
        ELSE
            taf.hw.pdu.Power Off  port=${radio_list["${key}"].pdu_port}
        END
        Log To Console  ${action} outlet [${radio_list["${key}"].pdu_port}] on PDU [${radio_list["${key}"].pdu_ip}]
    END


Common Testing Actions
    [Documentation]  Description:           A set of methods requested by management to ensure better testing coverage    ${\n}
    ...              Return:                None                                                                       ${\n}
    ...              Output:                {}                                                                         ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                 ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com
    ...              Last Modification:     18-07-2022 made by lukasz.lechowicz@nokia.com          ${\n}

    Run Keyword And Continue On Failure  interface.Common step trigger


Get Serial Number Of System Module
    [Documentation]  Description:        Fetch serial number of system module from Infomodel${\n}
    ...              Return:             smod serial number                                 ${\n}
    ...              Output:             { @{string} }                                      ${\n}
    ...              Author:             piotr.lukaszewicz@nokia.com                        ${\n}
    ...              Maintainer:         piotr.lukaszewicz@nokia.com                        ${\n}
    [Arguments]  ${alias}=RAT_1ST    # connection alias

    ${smod_details}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/EQM-*/SMOD-*  timeout=30  alias=${alias}

    RETURN  ${smod_details['serialNumber']}


Get Freq Block Id For A Given Smod Serial Number
    [Documentation]  Description:        Get id of volatile frequency block for a given smod serial number${\n}
    ...              Return:             matching freq block id                                           ${\n}
    ...              Output:             { @{string} }                                                    ${\n}
    ...              Author:             piotr.lukaszewicz@nokia.com                                      ${\n}
    ...              Maintainer:         piotr.lukaszewicz@nokia.com                                      ${\n}
    [Arguments]  ${smod_serial_num}
    ...          ${alias}=RAT_1ST    # connection alias

    ${matching_freq_block_id}  Create List
    ${freq_blocks_list}  ute_admin_infomodel.Query Infomodel  alias=${alias}
    ...  query=get list /MRBTS-1/RAT-1/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_FREQUENCY_BLOCK-*
    ${num_of_freq_blocks}  Get Length  ${freq_blocks_list}
    # get IDs of Frequency Blocks
    ${current_freq_block_ids}  Create List
    FOR  ${i}  IN RANGE  ${num_of_freq_blocks}
        ${freq_block}  Set Variable  ${freq_blocks_list}[${i}]
        ${freq_block_dn}  Set Variable  ${freq_block['dist_name']}
        ${freq_block_id}  Get Regexp Matches  ${freq_block_dn}  \\d*$
        Append To List  ${current_freq_block_ids}  ${freq_block_id}[0]
        Should Not Be Empty  ${freq_block_id}[0]
    END
    # find which Frequency Block contains given SMOD serial number
    FOR  ${i}  IN RANGE  ${num_of_freq_blocks}
        ${freq_block}  Query Infomodel  timeout=30  alias=${alias}
        ...  query=get object /MRBTS-1/RAT-1/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_FREQUENCY_BLOCK-${current_freq_block_ids}[${i}]
        ${is_sn_found}  Run Keyword And Return Status  Should Contain  ${freq_block['serialNumber']}  ${smod_serial_num}
        IF  ${is_sn_found}
            Append To List    ${matching_freq_block_id}    ${current_freq_block_ids}[${i}]
            Log    CBRS_FREQUENCY_BLOCK-${current_freq_block_ids}[${i}] is matching SMOD ${smod_serial_num}  console=True
            BREAK
        END
    END
    Should Not Be Empty  ${matching_freq_block_id}

    RETURN  ${matching_freq_block_id[0]}


Verify Cbrs Frequency Block Inside The Info Model
    [Documentation]  Description:       Get channels from Frequency Block and compare with aquired grants${\n}
    ...              Return:            None                                                             ${\n}
    ...              Output:            { }                                                              ${\n}
    ...              Author:            piotr.lukaszewicz@nokia.com                                      ${\n}
    ...              Maintainer:        piotr.lukaszewicz@nokia.com                                      ${\n}
    [Arguments]  ${freq_block_id}                   # freq block id for certain smod serial number
    ...          ${alias_for_grant_info}=RAT_1ST    # alias for reading current grant(s)
    ...          ${alias_for_freq_block}=RAT_1ST    # alias for reading frequency block items

    # get current grants
    @{grant_info_list}  ute_admin_infomodel.Query Infomodel  alias=${alias_for_grant_info}
    ...  query=get list //CBRS-*/CBSD-*/GRANT_INFO-*
    ${cell_count}  Get Length  ${grant_info_list}
    # get channels from a given Frequency Block
    ${freq_block}  Query Infomodel  timeout=30  alias=${alias_for_freq_block}
    ...  query=get object /MRBTS-1/RAT-1/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_FREQUENCY_BLOCK-${freq_block_id}
    ${block_list}  Set Variable  ${freq_block['cbrsBlockList']}
    Should Not Be Empty  ${block_list}  msg=There are no channels in CBRS_FREQUENCY_BLOCK-${freq_block_id}
    ${num_of_channels}  Get Length  ${block_list}
    ${list_of_freqs_in_block}  Create List
    # separate low and high freq from default grant format in Frequency Block and put them to a list
    FOR  ${i}  IN RANGE  ${num_of_channels}
        ${chan_low_freq}  Get Substring  ${block_list}[${i}]  start=0  end=4
        Append To List  ${list_of_freqs_in_block}  ${chan_low_freq}
        ${chan_high_freq}  Get Substring  ${block_list}[${i}]  start=5  end=9
        Append To List  ${list_of_freqs_in_block}  ${chan_high_freq}
    END
    # get low and high freq from currently used grants and compare them with Frequency Block object
    FOR  ${i}  IN RANGE  ${cell_count}
        ${chan_low_freq}  Set Variable  ${grant_info_list[${i}]['grantSpectrumFreqLow']}
        ${chan_high_freq}  Set Variable  ${grant_info_list[${i}]['grantSpectrumFreqHigh']}
        Compare Grant Info With Freqency Block Items  low_freq=${chan_low_freq}  high_freq=${chan_high_freq}
        ...  freq_block_list=${list_of_freqs_in_block}
    END


Compare Grant Info With Freqency Block Items
    [Documentation]  Description:        Compare aquired grants with 'locks' in Frequency Block          ${\n}
    ...              Return:             None                                                            ${\n}
    ...              Output:             { }                                                             ${\n}
    ...              Author:             piotr.lukaszewicz@nokia.com                                     ${\n}
    ...              Maintainer:         piotr.lukaszewicz@nokia.com                                     ${\n}
    [Arguments]  ${low_freq}         # low frequency value
    ...          ${high_freq}        # high frequency value
    ...          ${freq_block_list}  # list of current blocked frequency by CBSD

    ${channel_bw}  Evaluate  ${high_freq}-${low_freq}
    ${num_of_freq}  Evaluate  ${channel_bw}/${5}
    ${iterations_needed}  Convert To Integer  ${num_of_freq}
    # generate predicted frequencies based on low freq and channel BW
    FOR  ${i}  IN RANGE  ${0}  ${iterations_needed}+1
        ${predicted_freq}  Evaluate  ${i}*${5}+${low_freq}
        ${predicted_freq_str}  Convert To String  ${predicted_freq}
        # check if each frequency can be found in Frequency Block items
        Should Contain  ${freq_block_list}  ${predicted_freq_str}
    END
    Log  Grant ${low_freq}_${high_freq} found in Frequency Block object.  console=True


Check If Registration is TS2.0 Compliant
    [Documentation]  Description:           Compare data stored in the infomodel with parameters exchanged
    ...                                     in the RegistrationRequest procedure.
    ...              Return:                ??                                                   ${\n}
    ...              Output:                { ?? }                                               ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}               # connection alias
    ...          ${time_start}          # start time of read data
    ...          ${time_stop}           # end time of read data
    ...          ${sas_log_path}        # path to SAS_Sim.log file ??
    ...          ${enb_id}              # ENB id

    @{cbsdFeatureList}  Create List  WF_ENHANCED_GROUP_HANDLING  WF_ENH_GROUP_HANDLING  WF_GRANT_UPDATE
    ${sw_info}  Get Software Info  connection=RAT_1ST
    ${sw_build}  Get From Dictionary  ${sw_info}  Active SW version

    ute_admin_infomodel.Query Infomodel  query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...  timeout=360   alias=${alias}
    ${CBSD_details}  ute_admin_infomodel.Query Infomodel  query=get object /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*
    ...   timeout=60  alias=${alias}
    ${assignedCbsdId}  Get From Dictionary  ${CBSD_details}  assignedCbsdId

    ${parsed_log_file}  Parse Sas Log File  log_file_name=${sas_log_path}  date_start=${time_start}  date_stop=${time_stop}
    ${registration_request_sw_ver}  Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=softwareVersion  data_type=registrationRequest  packet_amount=1
    ${cbsdFeatureCapabilityList}   Extract Values From Sas Log
    ...  log_name=${parsed_log_file}  parameter=cbsdFeatureCapabilityList  data_type=registrationRequest  packet_amount=1

    ${groupingParam}  Extract groupingParam from SAS log
    ...  time_start=${time_start}  time_stop=${time_stop}  sas_log_path=${sas_log_path}  enb_id=${enb_id}  procedure=registrationRequest

    List Should Contain Sub List  ${cbsdFeatureList}  ${cbsdFeatureCapabilityList[0]}
    Should be Equal  ${registration_request_sw_ver[0]}  ${sw_build}
    Should be Equal  ${groupingParam[0][0]['groupType']}  COEXISTENCE_GROUP
    Should be Equal  ${groupingParam[0][0]['groupId']}  CBRS_ALLIANCE
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaVersion']}  v2.0
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['frameStructure'][0]}  FS2
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupType']}  CBRSA_CCG
    Should be Equal  ${groupingParam[0][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupType']}  CBRSA_ICG


Modify Bandwidth For All Cbsd Cells
    [Documentation]  Description:           Prepare and provision delta plan with chBw parameter
    ...                                     modification for all CBSD cells.                     ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${enb_id}              # eNB ID
    ...          ${required_chbw}       # cells bandwidth to be set
    ...          ${alias}=RAT_1ST       # connection alias
    ${num_of_cells}  Get Number of Cells  ${enb_id}
    IF  ${1} < ${num_of_cells} < ${5}
        Log  Setting chBw=${required_chbw}MHz for ${num_of_cells} cells  console=True
    ELSE
        Fail  There is no delta plan for ${num_of_cells} cell(s)
    END
    Replace Variables In File  ${CURDIR}/Delta/chBw_set_to_${num_of_cells}x_${required_chbw}MHz.json
    ...  ${OUTPUT_DIR}/chBw_set_to_${num_of_cells}x_${required_chbw}MHz.json  ENB_ID=${enb_id}
    Wait Until Keyword Succeeds  6x  5s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  delta_file=${OUTPUT_DIR}/chBw_set_to_${num_of_cells}x_${required_chbw}MHz.json
    ...  skip_parameter_relation_errors=${TRUE}
    ...  connection=${alias}


Set Supported Spectrum
    [Documentation]  Description:           Set supportedSpectrumV2 parameter with values provided in a list of desired
    ...                                     CBRS channels, indicated by low frequencies. Values from the list are
    ...                                     converted into a bitmap and then used as an integer, to provision delta
    ...                                     plan to BTS.                                         ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_id}                  # BTS ID
    ...          ${target_spectrum_list}    # list of the lower frequencies of the channels
    ...          ${alias}=RAT_1ST           # connection alias

    ${freq_indexes}  Create Dictionary  3550=${29}  3555=${28}  3560=${27}  3565=${26}
    ...  3570=${25}  3575=${24}  3580=${23}  3585=${22}
    ...  3590=${21}  3595=${20}  3600=${19}  3605=${18}
    ...  3610=${17}  3615=${16}  3620=${15}  3625=${14}
    ...  3630=${13}  3635=${12}  3640=${11}  3645=${10}
    ...  3650=${9}  3655=${8}  3660=${7}  3665=${6}
    ...  3670=${5}  3675=${4}  3680=${3}  3685=${2}
    ...  3690=${1}  3695=${0}

    # Check if target spectrum list contains valid frequencies
    ${freq_count}  Get Length  ${target_spectrum_list}
    ${allowed_freq_values}  Get Dictionary Keys  ${freq_indexes}
    FOR  ${i}  IN RANGE  ${freq_count}
        Should Contain  ${allowed_freq_values}  ${target_spectrum_list}[${i}]  values=False
        ...  msg=${target_spectrum_list}[${i}] is not a valid channel indicator
    END

    ${empty_binary_spectrum}   Set Variable    000000000000000000000000000000
    ${spectrum}  Split String To Characters  ${empty_binary_spectrum}

    # Mark desired channels in the bitmap format
    FOR  ${i}  IN RANGE  ${freq_count}
        ${index}  Get From Dictionary  ${freq_indexes}  ${target_spectrum_list}[${i}]
        Set List Value  ${spectrum}  ${index}  1
    END
    ${modified_spectrum}  Evaluate  "".join($spectrum)
    ${scf_spectrum_value}  Convert To Integer  0b${modified_spectrum}
    Replace Variables In File  file_path=${CURDIR}/Delta/supportedSpectrumV2_set.json
    ...  file_destination=${OUTPUT_DIR}/supportedSpectrumV2_set.json
    ...  bts_id=${bts_id}
    ...  spec=${scf_spectrum_value}
    Wait Until Keyword Succeeds  2x  30s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  Perform Delta Recommissioning  delta_file=${OUTPUT_DIR}/supportedSpectrumV2_set.json
    ...  skip_parameter_relation_errors=${TRUE}
    ...  connection=${alias}


Restore Supported Spectrum
    [Documentation]  Description:           Set supportedSpectrumV2 parameter to the default value (all
    ...                                     30 channels allowed)                                 ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_id}              # BTS ID
    ...          ${alias}=RAT_1ST       # connection alias

    Replace Variables In File  file_path=${CURDIR}/Delta/supportedSpectrumV2_set.json
    ...  file_destination=${OUTPUT_DIR}/supportedSpectrumV2_set.json
    ...  bts_id=${bts_id}
    ...  spec=${1073741823}
    Wait Until Keyword Succeeds  2x  30s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  Perform Delta Recommissioning  delta_file=${OUTPUT_DIR}/supportedSpectrumV2_set.json
    ...  skip_parameter_relation_errors=${TRUE}
    ...  connection=${alias}


Check Installed SW Build
    [Documentation]  Description:           Check if given targetSW is installed on BTS.         ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${targetSW}            # target SW: SBTSxx_ENB_xxxx_yymmdd_000xxx
    ...          ${connection}=RAT_1ST  # connection alias

    Log  Checking if given SW version is installed on BTS...
    ${swInfo}  Get Software Info  alias=${connection}
    ${swBuild}  Get From Dictionary  ${swInfo}  Active SW version
    ${trunk}  Replace String Using Regexp  ${swBuild}  SBTS.{2,5}_ENB  SBTS00_ENB
    ${swBuild}  Set Variable If  '${IS_TRUNK}'=='True'  ${trunk}  ${swBuild}
    Should Be Equal  ${targetSW}  ${swBuild}


Show Current Ute Name
    [Documentation]  Description:           Shows actual ute name                                ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                elzbieta.wlodarczyk@nokia.com                        ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}

    ${CONFIGURATION_defined}  Run Keyword And Return Status  Variable Should Exist  ${CONFIGURATION}
    IF  not ${CONFIGURATION_defined}
        ${hostname}  Run  hostname
        ${hostname}  Replace String  ${hostname}  -  _
        ${CONFIGURATION}  Catenate  SEPARATOR=  Wroclaw.  ${hostname}
        Set Suite Variable  ${CONFIGURATION}
    END
    ${site}  ${ute_name}  Split String From Right  ${CONFIGURATION}  .
    Set Suite Variable  ${ute_name}


Get grantMaxEirp For Selected GrantId
    [Documentation]  Description:           Queries eNB infomodel for grantMaxEirp of requested grant ID    ${\n}
    ...              Return:                maxGrantEirp value as integer                        ${\n}
    ...              Output:                integer                                              ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${grant_info}  ${selected_grantId}

    FOR  ${dictionary}  IN  @{grant_info}
            ${grantId}  Get From Dictionary  ${dictionary}  grantId
            ${maxGrantEirp_value}  IF  '${grantId}' == '${selected_grantId}'  Get From Dictionary  ${dictionary}  grantMaxEirp
            Exit For Loop If  '${grantId}' == '${selected_grantId}'
    END
    Log To Console  ${\n} Grant ${selected_grantId} has grantMaxEirp=${maxGrantEirp_value} ${\n}

    RETURN  ${maxGrantEirp_value}


Get grantChannelType For Selected GrantId
    [Documentation]  Description:           Queries eNB infomodel for grantChannelType of requested grant ID    ${\n}
    ...              Return:                grantChannelType value as string                    ${\n}
    ...              Output:                string                                              ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                           ${\n}
    [Arguments]  ${grant_info}  ${selected_grantId}
    FOR  ${dictionary}  IN  @{grant_info}
            ${grantId}  Get From Dictionary  ${dictionary}  grantId
            ${grantChannelType_value}  IF  '${grantId}' == '${selected_grantId}'  Get From Dictionary  ${dictionary}  grantChannelType
            Exit For Loop If  '${grantId}' == '${selected_grantId}'
    END
    Log To Console  ${\n} Grant ${selected_grantId} has grantChannelType=${grantChannelType_value} ${\n}

    RETURN  ${grantChannelType_value}


Set Primary Sas Server
    [Documentation]  Description:           Prepare and send a delta plan to modify primary SAS server on BTS.
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${bts_id}              # BTS ID
    ...          ${sas_ip}              # IP address in <IP>:<port> format
    ...          ${print_ip}=True       # log in console SAS address
    ...          ${alias}=RAT_1ST       # connection alias

    Wait Until Keyword Succeeds  6x  10s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  Perform Parameter Recommissioning  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/CBRSPR-1
    ...  parameter=primarySasServer
    ...  operation=update
    ...  value=${sas_ip}
    ...  connection=${alias}
    IF  ${print_ip}  Log To Console  Primary SAS server set to ${sas_ip}


Suspend A Random Grant
    [Documentation]  Description:           Suspend a random grant and confirm cell drop. Check if SAS log contains
    ...                                     mngGrantSuspendResponse message and new channel has been choosen. At the end
    ...                                     free suspended grant and check fault list on BTS.    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com
    [Arguments]  ${enb_id}                     # eNB ID, e.g.: 1876
    ...          ${cbsd_id}                    # CBSD ID, e.g.: AEQMadmin_AEQM_1M211713652
    ...          ${sas_log}                    # SAS log path, e.g.: /home/ute/SASSim/default/SAS_Sim.log
    ...          ${expected_fault}=${EMPTY}    # optional fault ID which should be marked as expected

    Wait For All Cells To Be OnAir
    ${active_grant_list}  List Values of GrantId For All Cells  ${enb_id}
    # get random grant ID for suspension
    ${random_grant_to_suspend}  Evaluate  random.choice(${active_grant_list})  modules=random
    ${grant_suspend_time}  Get Time
    Wait Until BTS Is Not Busy
    Suspend Grant And Confirm Cell Drop  cbsd_id=${cbsd_id}  grant_id=${random_grant_to_suspend}    print_details=False
    ${suspension_end_time}  Get Time
    # filter SAS log file near to grant suspension
    ${log_file}  Parse Sas Log File  log_file_name=${sas_log}
    ...  date_start=${grant_suspend_time}
    ...  date_stop=${suspension_end_time}
    ${log_file}  Convert To String  ${log_file}
    # check if SAS log contains grant suspension message
    Should Contain  ${log_file}  mngGrantSuspendResponse
    # add an entry to suspended grant list in the file
    Append To File  ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt  ${grant_suspend_time} Grant ${random_grant_to_suspend} -- SUSPENDED ${\n}
    Log To Console  Grant ${random_grant_to_suspend} suspended on ${grant_suspend_time}
    Wait For All Cells To Be OnAir
    ${new_active_grant_list}  List Values of GrantId For All Cells  ${enb_id}
    # compare grant IDs before and after suspension to check if one of them changed
    Should Not Be Equal  ${new_active_grant_list}  ${active_grant_list}
    ${grant_free_time}  Get Time
    # free suspended grant in SAS resources for the next iteration
    Send Command To SAS Manager  alias=default  command=grant_free ${cbsd_id} ${random_grant_to_suspend}
    # add an entry to freed grant list in the file
    Append To File  ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
    ...  ${grant_free_time} Grant ${random_grant_to_suspend} -- suspension cleared ${\n}
    Log To Console  Grant ${random_grant_to_suspend} freed on ${grant_free_time}
    # check if any unwanted fault has been raised
    ${active_faults}  List Active eNB Faults
    ${is_expected_fid_provided}  Run Keyword And Return Status  Should Not Be Empty  ${expected_fault}
    ${expected_fid}  Run Keyword And Ignore Error  Convert To Integer  ${expected_fault}
    IF  ${is_expected_fid_provided}  Remove Values From List  ${active_faults}  ${expected_fid[1]}
    Check For Unwanted Faults  allowed_faults=@{enb_allowed_faults}  active_alarm_list=${active_faults}


Terminate A Random Grant
    [Documentation]  Description:           Terminate a random grant and confirm cell drop. Check if SAS log contains
    ...                                     mngGrantTerminateResponse message and new channel has been choosen. At the end
    ...                                     free terminated grant and check fault list on BTS.   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com
    [Arguments]  ${enb_id}                     # eNB ID, e.g.: 1876
    ...          ${cbsd_id}                    # CBSD ID, e.g.: AEQMadmin_AEQM_1M211713652
    ...          ${sas_log}                    # SAS log path, e.g.: /home/ute/SASSim/default/SAS_Sim.log
    ...          ${expected_fault}=${EMPTY}    # optional fault ID which should be marked as expected

    Wait For All Cells To Be OnAir
    # get random grant ID for termination
    ${active_grant_list}  List Values of GrantId For All Cells  ${enb_id}
    ${random_grant_to_terminate}  Evaluate  random.choice(${active_grant_list})  modules=random
    ${grant_terminate_time}  Get Time
    Wait Until BTS Is Not Busy
    Terminate Grant And Confirm Cell Drop  cbsd_id=${cbsd_id}  grant_id=${random_grant_to_terminate}    print_details=False
    ${termination_end_time}  Get Time
    # filter SAS log file near to grant termination
    ${log_file}  Parse Sas Log File  log_file_name=${sas_log}
    ...  date_start=${grant_terminate_time}
    ...  date_stop=${termination_end_time}
    ${log_file}  Convert To String  ${log_file}
    # check if SAS log contains grant termination message
    Should Contain  ${log_file}  mngGrantTerminateResponse
    # add an entry to terminated grant list in the file
    Append To File  ${TEST_LOGS_DIR_PATH}/GrantTerminatingHistory.txt
    ...  ${grant_terminate_time} Grant ${random_grant_to_terminate} -- TERMINATED ${\n}
    Log To Console  Grant ${random_grant_to_terminate} terminated on ${grant_terminate_time}
    Wait For All Cells To Be OnAir
    ${new_active_grant_list}  List Values of GrantId For All Cells  ${enb_id}
    # compare grant IDs before and after termination to check if one of them changed
    Should Not Be Equal  ${new_active_grant_list}  ${active_grant_list}
    ${grant_free_time}  Get Time
    # free terminated grant in SAS resources for the next iteration
    Send Command To SAS Manager  alias=default  command=grant_free ${cbsd_id} ${random_grant_to_terminate}
    Append To File  ${TEST_LOGS_DIR_PATH}/GrantTerminatingHistory.txt
    ...  ${grant_free_time} Grant ${random_grant_to_terminate} -- termination cleared ${\n}
    Log To Console  Grant ${random_grant_to_terminate} freed on ${grant_free_time}
    # check if any unwanted fault has been raised
    ${active_faults}  List Active eNB Faults
    ${is_expected_fid_provided}  Run Keyword And Return Status  Should Not Be Empty  ${expected_fault}
    ${expected_fid}  Run Keyword And Ignore Error  Convert To Integer  ${expected_fault}
    IF  ${is_expected_fid_provided}  Remove Values From List  ${active_faults}  ${expected_fid[1]}
    Check For Unwanted Faults  allowed_faults=@{enb_allowed_faults}  active_alarm_list=${active_faults}


Copy Logs To NescRotta
    [Documentation]  Description:           Copies suite logs to mapped external drive
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com
    [Arguments]  ${local_path}=/home/ute/NescRotta
    ...          ${QC_project}=RAN_VRF
    ...          ${QC_location}=VRF_TSR1/VRF_TSR1_T05/CRT/CBRS

    ${rotta_available}  Run Keyword and Return Status  OperatingSystem.Directory Should Exist    ${local_path}
    IF  ${rotta_available}==False  Map Nesc Rotta Network Drive
    ${release}  Fetch From Right  ${SOFTWARE_VERSION}  SBTS
    ${logs_dir}  Set Variable If  ${IS_TRUNK}==False
    ...  /home/ute/NescRotta/MN_RAN/${QC_project}/${release}/Regression/${QC_location}/
    ...  ${IS_TRUNK}==True
    ...  /home/ute/NescRotta/MN_RAN/${QC_project}/Trunk/${QC_location}/
    ${source_dir}  Get Regexp Matches  ${SUITE_LOGS_DIR_PATH}  ^(.*?)//?$  1
    Copy Directory  ${source_dir}[0]  ${logs_dir}
    Log to console  Copied logs from: ${SUITE_LOGS_DIR_PATH} ${\n}into: ${logs_dir}


Map Nesc Rotta Network Drive
    [Documentation]  Description:           Mounts external network drive for log storage        ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com

    ${password}  Set Variable  Wro5pass!
    ${username}  Set Variable  lopm
    ${network_path}  Set Variable  //nescrotta.nesc.nokia.net/rotta
    ${local_path}  Set Variable  /home/ute/NescRotta
    ${domain}  Set Variable  NSN-INTRA

    ${catenate_cmd}  Catenate  SEPARATOR=
    ...  sudo mkdir -p ${local_path};
    ...  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,
    ...  username=${username},password=${password},
    ...  domain=${domain},users,nounix ${network_path} ${local_path}
    ${rc}  ${output}  Run And Return Rc And Output  ${catenate_cmd}
    Log To Console  NescRotta Mapped into: ${local_path}


Setup Google Chrome And Chrome Driver Version
    [Documentation]  Description:           Setup Chrome environment for selenium usage          ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                             ${\n}
    ...              Maintainer:            karol.sadowski@nokia.com

    ${googleChromeVersion}  Run  google-chrome --version
    ${googleChromeVersion}  Get Regexp Matches  ${googleChromeVersion}  (Chrome.*\\s{1})(\\d{1,3})(\\..*)    2
    ${googleChromeVersion}  Convert To Integer  ${googleChromeVersion[0]}
    ${googleDriverVersion}  Run  chromedriver --version
    ${googleDriverVersion}  Get Regexp Matches  ${googleDriverVersion}  (Chrome.*\\s{1})(\\d{1,3})(\\..*)    2
    ${googleDriverVersion}  Convert To Integer  ${googleDriverVersion[0]}

    IF  "${googleChromeVersion}"!="${googleDriverVersion}"
        Log To Console  Google Driver version incompatible! Installing ver. ${googleChromeVersion}...    AND
        Run  sudo apt install -y --allow-downgrades ute-chromedriver=${googleChromeVersion}
    END

    ${googleDriverVersion}  Run  chromedriver --version
    ${googleDriverVersion}  Get Regexp Matches  ${googleDriverVersion}  (Chrome.*\\s{1})(\\d{1,3})(\\..*)    2
    ${googleDriverVersion}  Convert To Integer  ${googleDriverVersion[0]}

    IF  "${googleChromeVersion}"!="${googleDriverVersion}"  Fail  Google Driver ${googleChromeVersion} Installation Failed!

    ${chrome_params}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method  ${chrome_params}  add_argument  --no-sandbox
    Call Method  ${chrome_params}  add_argument  --headless
    Call Method  ${chrome_params}  add_argument  --disable-extensions
    Call Method  ${chrome_params}  add_argument  --disable-gpu
    Call Method  ${chrome_params}  add_argument  --ignore-certificate-errors
    Create Webdriver  Chrome  chrome_options=${chrome_params}
