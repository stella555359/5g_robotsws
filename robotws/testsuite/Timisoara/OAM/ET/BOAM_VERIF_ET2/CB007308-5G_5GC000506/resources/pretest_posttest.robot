*** Settings ***
Documentation
...              Author:
...              Maintainer:

Library     XML    use_lxml=True
Library     Collections
Library     String
Library     DateTime    #temporary for PREPOST Check Data Sources KW
Library     ./epoch_converter.py    #temporary for PREPOST Check Data Sources KW
Resource    ./admin.robot
Resource    ./admin_infomodel.robot
Resource    ./logging.robot
#Resource    ./pdu.robot
Resource    ./system.robot
Resource    ../CommonKeywords/custom_commissionings.robot
Resource    ../CommonKeywords/swconfig.robot

*** Variables ***
${PREPARE_TESTLINE}=    ${True}
${OUT_ADMIN_SMOD_PARAMETERS}
${OUT_ADMIN_BTS_PARAMETERS}
${OUT_ADMIN_BTS_NAME}
${OUT_ADMIN_BBMODS_PARAMETERS}
${OUT_ADMIN_RMODS_PARAMETERS}
${OUT_ADMIN_ALDS_PARAMETERS}
${OUT_ADMIN_LNCELS_PARAMETERS}
${OUT_ADMIN_SMODS_AMOUNT}
${OUT_ADMIN_BBMODS_AMOUNT}
${OUT_ADMIN_RMODS_AMOUNT}
${OUT_ADMIN_ALDS_AMOUNT}
${OUT_ADMIN_LNCELS_AMOUNT}
${OUT_ADMIN_SMOD_POSITION}
${OUT_SCF_FILE_PRETEST}
${OUT_SCF_FILE_POSTTEST}
${OUT_SCF_SMOD_COUNT}
${OUT_SCF_BBMOD_COUNT}
${OUT_SCF_RMOD_COUNT}
${OUT_SCF_ALD_COUNT}
${OUT_SCF_LNCEL_COUNT}
${OUT_MRBTS_ID}
${OUT_RMODS_IDS_LIST}
${OUT_RMODS_PRODUCTNAMES_LIST}
${OUT_RMODS_SERIALNUMBERS_LIST}
${OUT_SMODS_IDS_LIST}
${OUT_SMODS_PRODUCT_CODES_LIST}
${OUT_SMODS_PRODUCT_NAMES_LIST}
${OUT_BBMODS_IDS_LIST}
${OUT_CELLS_MAPPED_TO_SMOD}
${OUT_CELLS_MAPPED_TO_BBMOD_1}
${OUT_CELLS_MAPPED_TO_BBMOD_2}

*** Keywords ***
Suite Preconditions
#    [Arguments]    ${prepare_testline}=${PREPARE_TESTLINE}
    Log
    ...    message=\n+ Started Suite PREconditions: ${SUITE_NAME}
    ...    console=yes

    Log Variables
    PREPOST Set Local Time
    PREPOST Setup Admin
    PREPOST Check Date Sources
#    run keyword if   ${prepare_testline}  Prepare Testline
    PREPOST Collect Scf File Presuite
    SCF Get Mrbts Plane Ip Address
    SCF Get Mme Ip Address
    SCF Get Top Ip Address
    SCF Get Ntp Ip Address
    PREPOST Get Smod Position
    PREPOST Get BTS Side
    PREPOST Get Bts Name
    PREPOST Set MRBTS ID

    Update OUT_ADMIN Variables
    PREPOST Set Netboot Recovery Flags If Needed

    Log
    ...    message=\n+ Finished Suite PREconditions: ${SUITE_NAME}
    ...    console=yes
    Branch or Trunk

Update OUT_ADMIN Variables
    PREPOST Create List Of Smod Parameters
    PREPOST Create List Of Smod Ids
    PREPOST Create List Of Smod Product Names
    PREPOST Create List Of Bbmods Parameters
    PREPOST Create List Of Bbmods Ids
    PREPOST Get Amount Of Bbmods In Admin
    PREPOST Create List Of Bts Parameters
    PREPOST Create List Of Rmods Parameters
    PREPOST Create List Of Rmods Ids
    PREPOST Create List Of Rmods Product Names
    PREPOST Create List Of Rmods Serial Numbers
    PREPOST Get Amount Of Rmods In Admin
    PREPOST Create List Of Alds Parameters
    PREPOST Create List Of Cells Parameters
    PREPOST Create List Of Lncels Ids
    PREPOST Get Amount Of Lncels In Admin
    PREPOST Check Cells Mapping To FSPs
    PREPOST Get Active And Passive Software Versions

Suite Postconditions
    Log
    ...    message=\n+ Started Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes
    run keyword and ignore error    PREPOST Collect Scf File Postsuite
    PREPOST Teardown Admin
    Log Variables
#    ADMIN Teardown Admin
    Log
    ...    message=\n+ Finished Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes

Test Preconditions
    Log
    ...    message=\n+ Started Test PREconditions ${TEST_NAME}
    ...    console=yes
    Log Variables
    LOGGING Start Logging
    Log
    ...    message=\n+ Finished Test PREconditions: ${TEST_NAME}
    ...    console=yes

Test Postconditions
    Log
    ...    message=\n+ Started Test POSTconditions: ${TEST_NAME}
    ...    console=yes
    LOGGING Stop Logging
    Log Variables
    Log
    ...    message=\n+ Finished Test POSTconditions: ${TEST_NAME}
    ...    console=yes

PREPOST Set Local Time
    Run    sudo cp /usr/share/zoneinfo/Poland /etc/localtime

PREPOST Setup Admin
    ADMIN Setup Admin
    ...    bts_port=${ADMIN_BTS_PORT}
    ...    alias=${ADMIN_ALIAS}

PREPOST Teardown Admin
    ADMIN Teardown Admin
    ...    alias=${ADMIN_ALIAS}

PREPOST Collect Scf File
    [Arguments]    ${file_name}
    ...            ${alias}
    ADMIN Collect Scf
    ...    local_dir_path=${OUTPUT_DIR}/
    ...    file_name=${file_name}
#    ...    alias=${ADMIN_ALIAS}
    ...    alias=${alias}
    [Return]    ${OUTPUT_DIR}/${file_name}

PREPOST Collect Scf File Presuite
    ${out_scf_filename_pretest}=    PREPOST Collect Scf File
    ...    file_name=SCF_Presuite.xml
    ...    alias=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_SCF_FILE_PRETEST}    ${out_scf_filename_pretest}

PREPOST Collect Scf File Postsuite
    ADMIN Setup Admin
    ...    alias=${TEMP_ADMIN_ALIAS}
    ${out_scf_filename_posttest}=    PREPOST Collect Scf File
    ...    file_name=SCF_Postsuite.xml
    ...    alias=${ADMIN_ALIAS}
    ADMIN Teardown Admin
    ...    alias=${TEMP_ADMIN_ALIAS}
    Set Suite Variable    ${OUT_SCF_FILE_POSTTEST}    ${out_scf_filename_posttest}

SCF Get Mrbts Plane Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${mplane_ipv4_location}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="mPlaneIpv4AddressDN"])
    ${out_scf_mrbt_ipv4}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@distName="${mplane_ipv4_location}"]/p[@name="localIpAddr"])
    Set Suite Variable    ${OUT_SCF_MRBTS_IP}    ${out_scf_mrbt_ipv4}
    ${mplane_ipv6_location}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="mPlaneIpv6AddressDN"])
    ${out_scf_mrbt_ipv6}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@distName="${mplane_ipv6_location}"]/p[@name="localIpAddr"])
    Set Suite Variable    ${OUT_SCF_MRBTS_IPV6}    ${out_scf_mrbt_ipv6}

SCF Get Mme Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_mme_ip}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="NOKLTE:LNMME"]/p[@name="ipAddrPrim"])
    Set Suite Variable    ${OUT_SCF_MME_IP}    ${out_scf_mme_ip}

SCF Get Top Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_top_ip}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string((.//managedObject[@class="com.nokia.srbts.mnl:TOPF"]//p[@name="masterIpAddr"])[1])
    Set Suite Variable    ${OUT_SCF_TOP_IP}    ${out_scf_top_ip}

SCF Get Ntp Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_ntp_ip}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="com.nokia.srbts.mnl:NTP"]/list[@name="ntpServerIpAddrList"]/p/text()[1])
    Set Suite Variable    ${OUT_SCF_NTP_IP}    ${out_scf_ntp_ip}

SCF Get Parameter Value From SCF File
    [Arguments]    ${path}
    ...            ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${value}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(${path})
    [Return]    ${value}

PREPOST Get Amount Of Bbmods In Admin
    ${out_bbmods_amount}=    Get Length    ${OUT_ADMIN_BBMODS_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_BBMODS_AMOUNT}    ${out_bbmods_amount}

PREPOST Get Amount Of Rmods In Admin
    ${out_rmods_amount}=    Get Length    ${OUT_ADMIN_RMODS_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_RMODS_AMOUNT}    ${out_rmods_amount}

PREPOST Get Amount Of Alds In Admin
    ${out_alds_amount}=    Get Length   ${OUT_ADMIN_ALDS_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_ALDS_AMOUNT}    ${out_alds_amount}

PREPOST Get Amount Of Lncels In Admin
    ${out_lncels_amount}=    Get Length    ${OUT_LNCELS_IDS_LIST}
    Set Suite Variable    ${OUT_ADMIN_LNCELS_AMOUNT}    ${out_lncels_amount}

PREPOST Get Bts Name
    ${bts_name}=    taf.sbts.oam.coam.admin.Get Bts Info
    Set Suite Variable    ${OUT_ADMIN_BTS_NAME}    ${bts_name['name']}

PREPOST Set MRBTS Id
    ${out_mrbts_id}=    taf.sbts.oam.coam.admin.Get Bts Info
    Set Suite Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id['mrbtsID']}

PREPOST Create List Of Smod Parameters
     ${out_smod_parameters}=    ADMIN Get Parameters For All SMOD
     ...    alias=${ADMIN_ALIAS}
     Set Suite Variable    ${OUT_ADMIN_SMOD_PARAMETERS}    ${out_smod_parameters}

PREPOST Create List Of Bts Parameters
     ${out_bts_parameters}=    ADMIN Get Parameters For All BTS
     ...    alias=${ADMIN_ALIAS}
     Set Suite Variable    ${OUT_ADMIN_BTS_PARAMETERS}    ${out_bts_parameters}

PREPOST Create List Of Bbmods Parameters
     ${out_bbmods_parameters}=    ADMIN Get Parameters For All BBMODs
     ...    alias=${ADMIN_ALIAS}
     Set Suite Variable    ${OUT_ADMIN_BBMODS_PARAMETERS}    ${out_bbmods_parameters}

PREPOST Create List Of Rmods Parameters
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    ${out_rmods_parameters}=    ADMIN Get Parameters For All RMODs
     ...    alias=${alias}
    Set Suite Variable    ${OUT_ADMIN_RMODS_PARAMETERS}    ${out_rmods_parameters}
    Set Suite Variable    ${SYSTEM_RMOD_LOCAL_IP}    ${OUT_RMODS_PARAMETERS[0]['ipAddress']}

PREPOST Create List Of Alds Parameters
     ${out_alds_parameters}=    ADMIN Get Parameters For All ALDs
     ...    alias=${ADMIN_ALIAS}
     Set Suite Variable    ${OUT_ADMIN_ALDS_PARAMETERS}    ${out_alds_parameters}

PREPOST Create List Of Cells Parameters
    ${out_lncels_parameters}=    ADMIN Get Parameters For All LNCELs
     ...    alias=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_ADMIN_LNCELS_PARAMETERS}    ${out_lncels_parameters}

PREPOST Create List Of Objects Parameter Values
    [Arguments]    ${parameters_list}
    ...            ${parameter}
    ${out_list}=    Create List
    FOR    ${out_index}    IN    @{parameters_list}
        Log    ${out_index}
        ${out_parameter}=    Get From Dictionary    ${out_index}    ${parameter}
        Append To List    ${out_list}    ${out_parameter}
    END
    [Return]   ${out_list}

PREPOST Create List Of Smod Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_SMOD_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Smod Ids
    ${out_smods_id_list}=    PREPOST Create List Of Smod Parameter Value
    ...    parameter=id
    Set Suite Variable    ${OUT_SMODS_IDS_LIST}    ${out_smods_id_list}

PREPOST Create List Of Smod Product Names
    ${out_smods_productName_list}=    PREPOST Create List Of Smod Parameter Value
    ...    parameter=productName
    Set Suite Variable    ${OUT_SMODS_PRODUCT_NAMES_LIST}    ${out_smods_productName_list}

PREPOST Create List Of Bbmods Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_BBMODS_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Bbmods Ids
    ${out_bbmods_id_list}=    PREPOST Create List Of Bbmods Parameter Value
    ...    parameter=id
    Set Suite Variable    ${OUT_BBMODS_IDS_LIST}    ${out_bbmods_id_list}

PREPOST Create List Of Rmods Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_RMODS_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Rmods Ids
    ${out_rmods_id_list}=    PREPOST Create List Of Rmods Parameter Value
    ...    parameter=id
    ${out_rmods_id_list}=    evaluate    sorted(${out_rmods_id_list})
    Set Suite Variable    ${OUT_RMODS_IDS_LIST}    ${out_rmods_id_list}

PREPOST Create List Of Rmods Product Names
    ${out_rmods_productnames_list}=    PREPOST Create List Of Rmods Parameter Value
    ...    parameter=productName
    Set Suite Variable    ${OUT_RMODS_PRODUCTNAMES_LIST}    ${out_rmods_productnames_list}

PREPOST Create List Of Rmods Serial Numbers
    ${out_rmods_serialnumbers_list}=    PREPOST Create List Of Rmods Parameter Value
    ...    parameter=serialNumber
    Set Suite Variable    ${OUT_RMODS_SERIALNUMBERS_LIST}    ${out_rmods_serialnumbers_list}

PREPOST Create List Of Lncels Parameter Values
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_LNCELS_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Lncels Ids
    ${out_lncels_ids_list}=    PREPOST Create List Of Lncels Parameter Values
    ...    parameter=id
    ${out_lncels_ids_list}=    evaluate    sorted(${out_lncels_ids_list})
    Set Suite Variable    ${OUT_LNCELS_IDS_LIST}    ${out_lncels_ids_list}

PREPOST Get Smod Position
    ${out_smod_position}=    taf.sbts.oam.coam.admin.Get Smod Position
    ...    connection=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_ADMIN_SMOD_POSITION}    ${out_smod_position}

PREPOST Get BTS Side
    ${position}    Convert To String    ${OUT_ADMIN_SMOD_POSITION}
    ${whole}    Run Keyword And Return Status    Should Contain    ${position}    whole
    ${left}    Run Keyword And Return Status    Should Contain    ${position}    left
    ${right}    Run Keyword And Return Status    Should Contain    ${position}    right
    Run Keyword If    '${whole}' == 'True'    Set Suite Variable    ${BTS_Side}    1
    ...               ELSE IF
    ...               '${left}' == 'True'    Set Suite Variable    ${BTS_Side}    1
    ...               ELSE IF
    ...               '${right}' == 'True'    Set Suite Variable    ${BTS_Side}    4
    Run Keyword If    '${whole}' == 'True'    Log    FSMF    console=yes
    ...               ELSE IF
    ...               '${right}' == 'True'    Log    AirScale: Right Side    console=yes
    ...               ELSE IF
    ...               '${left}' == 'True'    Log    AirScale: Left Side    console=yes

PREPOST Get Active Software Versions
    ${out_active_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    activeSoftwareVersion
    Set Suite Variable    ${OUT_ACTIVE_SW}    ${out_active_sw}

PREPOST Get Passive Software Versions
    ${out_passive_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    passiveSoftwareVersion
    Set Suite Variable    ${OUT_PASSIVE_SW}    ${out_passive_sw}

PREPOST Get Active And Passive Software Versions
    PREPOST Get Active Software Versions
    PREPOST Get Passive Software Versions

PREPOST Check Cells Mapping To FSPs
    ${out_cells_mapped_to_smod}=    ADMIN Get Cell Mapping By Module Id
    ...    module_id=${OUT_SMODS_IDS_LIST[0]}
    ...    alias=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_CELLS_MAPPED_TO_SMOD}    ${out_cells_mapped_to_smod}
    FOR    ${out_index}    IN RANGE    0    ${OUT_ADMIN_BBMODS_AMOUNT}
        ${bbmod_number}=    Evaluate    ${out_index}+${1}
        ${out_cells_mapped_to_bbmod}=    ADMIN Get Cell Mapping By Module Id
    ...    module_id=${OUT_BBMODS_IDS_LIST[${out_index}]}
    ...    alias=${ADMIN_ALIAS}
        Set Suite Variable    ${OUT_CELLS_MAPPED_TO_BBMOD_${bbmod_number}}    ${out_cells_mapped_to_bbmod}
    END

PREPOST Check Finish BTS State
    ADMIN Setup Admin
    ...    alias=${ADMIN_ALIAS}

    run keyword and ignore error  ADMIN INFOMODEL Check If BTS Is Configured

    ADMIN Teardown Admin
    ...    alias=${ADMIN_ALIAS}

PREPOST Check Date Sources    #temporary KW due to time gaps issues
    #date from shell
    ${date_shell}    Run    date +%Y-%m-%d-%H:%M:%S

    #date from shell gnb
    ${date_gnb_shell}    SYSTEM Execute Command On gNB    command=date +%Y-%m-%d-%H:%M:%S
    #date from python
    ${date_python}    Get Date Python
    #date from robot
    ${date_robot}    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ...                                  time_zone=UTC
    ...                                  increment=2 hours
    #date from admi_api.log
    ${time_adminApi}    Run
    ...    command=tail --lines=4 ${ADMIN_API_LOG_DIR}/admin_api_default.log | awk '{print $1}' | egrep -m 1 '[0-9]+:[0-9]+:[0-9]+'
    #epoch shell
    ${epoch_shell}    Run    date --date='${date_robot}' +"%s"
    #epoch python
    ${epoch_python}    Convert To Epoch    ${date_robot}
    #epoch robot
    ${epoch_robot}    Convert Date    ${date_robot}    epoch

    ${date_list}    Create List    date_shell=${date_shell}    date_gnb_shell=${date_gnb_shell}    date_python=${date_python}
    Append To List    ${date_list}    date_robot${date_robot}    time_adminApi=${time_adminApi}
    ${epoch_list}    Create List    epoch_shell=${epoch_shell}    epoch_python=${epoch_python}    epoch_robot=${epoch_robot}
    Log    ${date_list}
    Log    ${epoch_list}

PREPOST Set Netboot Recovery Flags If Needed
    SYSTEM Remove Unwanted Uboot Flags
    ${asik}    Run Keyword And Return Status    Should Contain    ${OUT_SMODS_PRODUCT_NAMES_LIST[0]}    ASIK
	${asib}    Run Keyword And Return Status    Should Contain    ${OUT_SMODS_PRODUCT_NAMES_LIST[0]}    ASIB
	Run Keyword If    ${asik}    Run Keyword    SYSTEM Set Proper Netboot Recovery Flags    smod_product_name=ASIK
	Run Keyword If    ${asib}    Run Keyword    SYSTEM Set Proper Netboot Recovery Flags    smod_product_name=ASIB
