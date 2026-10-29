*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles common actions performed on suite/test startup teardown
...              FT in charge: name + mailing list
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library    XML    use_lxml=True
Library    ute_btssm
Library    Collections
Resource    ./admin.robot
Resource    ./admin_infomodel.robot
Resource    ./emssim.robot
Resource    ./logging.robot
Resource    ./pdu.robot
Resource    ./rmod.robot
Resource    ./system.robot
Resource    ./wtssim.robot

*** Variables ***
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
${OUT_BBMODS_IDS_LIST}
${OUT_CELLS_MAPPED_TO_SMOD}
${OUT_CELLS_MAPPED_TO_BBMOD_1}
${OUT_CELLS_MAPPED_TO_BBMOD_2}
@{WHITELIST}=    &{FAULT_61649}    &{FAULT_61524}   &{FAULT_61652}   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}
&{FAULT_61524}             fault_id=61524
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SSH enabled"
...                        notifier=
&{FAULT_61652}             fault_id=61652
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="R&D Service Port enabled"
...                        notifier=
&{FAULT_61649}             fault_id=61649
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex"LMP access via port \\d+"
...                        notifier=
&{FAULT_4654}              fault_id=4654
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Ethernet port security is disabled"
...                        notifier=
&{FAULT_4655}              fault_id=4655
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Service account root access is enabled"
...                        notifier=
&{FAULT_4681}              fault_id=4681
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Sanity Check Error"
...                        notifier=

*** Keywords ***
Suite Preconditions
    Log    \n+ Common Suite Precondition started    console=yes
    Log Variables
    PREPOST Set Local Time
    PREPOST Get Bts Name
    PREPOST Set Admin Port
    PREPOST Setup Admin
    PREPOST Unify Bts Name
    PREPOST Collect Scf File Presuite
    SCF Get Mrbts Plane Ip Address
    SCF Get Mme Ip Address
    SCF Get Top Ip Address
    SCF Get Ntp Ip Address
    PREPOST Get Smod Position
    PREPOST Get BTS Side
    PREPOST Create List Of Smod Parameters
    PREPOST Create List Of Smod Ids
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
    Log    \n+ Common Suite Precondition finished    console=yes

Suite Postconditions
    Log    \n+ Common Suite Postcondition started    console=yes
    PREPOST Collect Scf File Postsuite
    PREPOST Teardown Admin
    Log Variables
    Log    \+ Common Suite Postcondition finished    console=yes

Test Preconditions
    Log    \n+ Common Test Preconditions started    console=yes
    Log Variables
    Set New Project
    LOGGING Start Logging
    ${out_mrbts_id}=    ADMIN Get Id For Current BTS
    Set Test Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id}
    WTSSIM S1 link establish
    ADMIN Add Allowed Alarms    faults_list=@{WHITELIST}
    Log    \n+ Common Test Preconditions finished    console=yes

Test Preconditions Without WTSSIM S1
    Log    \n+ Common Test Preconditions started    console=yes
    Log Variables
    Set New Project
    LOGGING Start Logging
    ${out_mrbts_id}=    ADMIN Get Id For Current BTS
    Set Test Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id}
    ADMIN Add Allowed Alarms    faults_list=@{WHITELIST}
    Log    \n+ Common Test Preconditions finished    console=yes

Test Postconditions
    Log    \n+ Common Test Postconditions started    console=yes
    ADMIN Assert No Unexpected Active And Historical Alarms
    WTSSIM Teardown Egate And Edaemons
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions finished    console=yes

Test Postconditions Without WTSSIM S1
    Log    \n+ Common Test Postconditions started    console=yes
    ADMIN Assert No Unexpected Active And Historical Alarms
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions finished    console=yes

Test Postconditions Without WTSSIM S1 With Reset Site
    Log    \n+ Common Test Postconditions started    console=yes
    ADMIN Assert No Unexpected Active And Historical Alarms
    ADMIN Reset Site
    SYSTEM Wait Till Enb And Transport Are Pingable
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions finished    console=yes

Test Postconditions With Reset Site
    Log    \n+ Common Test Postconditions started    console=yes
    ADMIN Assert No Unexpected Active And Historical Alarms
    ADMIN Reset Site
    SYSTEM Wait Till Enb And Transport Are Pingable
    WTSSIM Teardown Egate And Edaemons
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions finished    console=yes

PREPOST Set Local Time
    Run    sudo cp /usr/share/zoneinfo/Poland /etc/localtime

PREPOST Set Admin Port
    ${enb_sw_active_ver}    SYSTEM Get Active Software Version
    ${sbts_sw_ver}    Run Keyword And Return Status    Should Contain    ${enb_sw_active_ver}    SBTS
    ${5g_sw_ver}    Run Keyword And Return Status    Should Contain    ${enb_sw_active_ver}    5G
    Run Keyword If    ${5g_sw_ver}    Set Suite Variable    ${ADMIN_PORT}    3600
    Run Keyword If    ${sbts_sw_ver}    Set Suite Variable    ${ADMIN_PORT}    443

PREPOST Setup Admin
    ADMIN Setup Admin    bts_port=${ADMIN_PORT}
    ...                  alias=suite

PREPOST Teardown Admin
    ADMIN Teardown Admin    alias=suite

PREPOST Collect Scf File
    [Arguments]    ${file_name}
    ...            ${alias}
    ADMIN Get Current Scf File
    ...                  local_dir_path=${OUTPUT_DIR}
    ...                  file_name=${file_name}
    ...                  export_type=configuration
    ...                  parameters_save_variant=actualValues
    ...                  alias=${alias}
    [Return]    ${OUTPUT_DIR}/${file_name}


PREPOST Unify Bts Name
    ${mrbts_id}=    taf.sbts.oam.coam.admin.Get Bts Info    alias=suite
    Set Suite Variable    ${MRBTS_ID}    ${mrbts_id['mrbtsID']}
    ${cloud_tl}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist
    ...                                             /home/ute/testline_init_results
    Run Keyword If    '${cloud_tl}'=='True' and '${ADMIN_PORT}'=='443'
    ...    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}
    ...    parameter=btsName
    ...    operation=update
    ...    value=MRBTS-1
    ...    connection=suite
    Run Keyword If    '${cloud_tl}'=='True' and '${ADMIN_PORT}'=='3600'
    ...    Run Keywords
    ...    Setup Btssm    AND
    ...    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    Perform Delta Commissioning
    ...    deltafile=${EXECDIR}/testsuite/WMP/SOAM1/resources_taf/configurations/btsName.xml
    ...    timeout=360    AND
    ...    Teardown Btssm

PREPOST Collect Scf File Presuite
    ${out_scf_filename_pretest}=    PREPOST Collect Scf File    file_name=SCF_Presuite.xml    alias=suite
    Set Suite Variable    ${OUT_SCF_FILE_PRETEST}    ${out_scf_filename_pretest}

PREPOST Collect Scf File Postsuite
    ${out_scf_filename_posttest}=    PREPOST Collect Scf File    file_name=SCF_Postsuite.xml    alias=suite
    Set Suite Variable    ${OUT_SCF_FILE_POSTTEST}    ${out_scf_filename_posttest}

SCF Get Mrbts Plane Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_mrbt_ip}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4"]/p[@name="localIpAddr"])
    Set Suite Variable    ${OUT_SCF_MRBTS_IP}    ${out_scf_mrbt_ip}

SCF Get Mme Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_mme_ip}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class="NOKLTE:LNMME"]/p[@name="ipAddrPrim"])
    Set Suite Variable    ${OUT_SCF_MME_IP}    ${out_scf_mme_ip}

SCF Get Top Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_top_ip}=    Evaluate Xpath    ${scf_file_path}
    ...     string((.//managedObject[@class="com.nokia.srbts.mnl:TOPF"]//p[@name="masterIpAddr"])[1])
    Set Suite Variable    ${OUT_SCF_TOP_IP}    ${out_scf_top_ip}

SCF Get Ntp Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_ntp_ip}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class="com.nokia.srbts.mnl:NTP"]/list[@name="ntpServerIpAddrList"]/p/text()[1])
    Set Suite Variable    ${OUT_SCF_NTP_IP}    ${out_scf_ntp_ip}

SCF Count Given Object In Scf
    [Arguments]    ${scfc_file_path}    ${object_type}
    ${out_count_tmp}=    Evaluate Xpath    ${scfc_file_path}    count(.//managedObject[@class="com.nokia.srbts.eqm:${object_type}"])
    ${out_count}=    Convert To Integer    ${out_count_tmp}
    [Return]    ${out_count}

SCF Get Amount Of Commissioned Smods
    [Arguments]    ${scfc_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_smod_count}=    SCF Count Given Object In Scf    scfc_file_path=${scfc_file_path}    object_type=SMOD
    Set Suite Variable    ${OUT_SCF_SMOD_COUNT}    ${out_scf_smod_count}

SCF Get Amount Of Commissioned Bbmods
    [Arguments]    ${scfc_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_bbmods_count}=    SCF Count Given Object In Scf    scfc_file_path=${scfc_file_path}    object_type=BBMOD
    Set Suite Variable    ${OUT_SCF_BBMODS_COUNT}    ${out_scf_bbmods_count}

SCF Get Amount Of Commissioned Rmods
    [Arguments]    ${scfc_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_rmod_count}=    SCF Count Given Object In Scf    scfc_file_path=${scfc_file_path}    object_type=RMOD
    Set Suite Variable    ${OUT_SCF_RMOD_COUNT}    ${out_scf_rmod_count}

SCF Get Amount Of Commissioned Alds
    [Arguments]    ${scfc_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_ald_count}=    SCF Count Given Object In Scf    scfc_file_path=${scfc_file_path}    object_type=ALD
    Set Suite Variable    ${OUT_SCF_ALD_COUNT}    ${out_scf_ald_count}

SCF Get Amount Of Commissioned Lncels
    [Arguments]    ${scfc_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_lncel_count}=    Evaluate Xpath    ${scfc_file_path}    count(.//managedObject[@class="NOKLTE:LNCEL"])
    ${out_scf_lncel_count}=    Convert To Integer    ${out_scf_lncel_count}
    Set Suite Variable    ${OUT_SCF_LNCEL_COUNT}    ${out_scf_lncel_count}

PREPOST Get Amount Of Smods In Admin
    ${out_smods_amount}=    Get Length   ${OUT_ADMIN_SMOD_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_SMODS_AMOUNT}    ${out_smods_amount}

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
    ${bts_name}=    Fetch From Right    ${CONFIGURATION}    .
    ${bts_name}=    Replace String    ${bts_name}    _    -
    Set Suite Variable    ${OUT_ADMIN_BTS_NAME}    ${bts_name}

PREPOST Create List Of Smod Parameters
     ${out_smod_parameters}=    ADMIN Get Parameters For All SMOD    alias=suite
     Set Suite Variable    ${OUT_ADMIN_SMOD_PARAMETERS}    ${out_smod_parameters}

PREPOST Create List Of Bts Parameters
     ${out_bts_parameters}=    ADMIN Get Parameters For All BTS    alias=suite
     Set Suite Variable    ${OUT_ADMIN_BTS_PARAMETERS}    ${out_bts_parameters}

PREPOST Create List Of Bbmods Parameters
     ${out_bbmods_parameters}=    ADMIN Get Parameters For All BBMODs    alias=suite
     Set Suite Variable    ${OUT_ADMIN_BBMODS_PARAMETERS}    ${out_bbmods_parameters}

PREPOST Create List Of Rmods Parameters
    [Arguments]    ${alias}=suite
    ${out_rmods_parameters}=    ADMIN Get Parameters For All RMODs    alias=${alias}
    Set Suite Variable    ${OUT_ADMIN_RMODS_PARAMETERS}    ${out_rmods_parameters}

PREPOST Create List Of Alds Parameters
     ${out_alds_parameters}=    ADMIN Get Parameters For All ALDs    alias=suite
     Set Suite Variable    ${OUT_ADMIN_ALDS_PARAMETERS}    ${out_alds_parameters}

PREPOST Create List Of Cells Parameters
    ${out_lncels_parameters}=    ADMIN Get Parameters For All LNCELs    alias=suite
    ${out_nrcels_parameters}=    ADMIN Get Parameters For All NRCELs    alias=suite
    ${out_wncels_parameters}=    ADMIN Get Parameters For All WNCELs    alias=suite
    ${out_gncels_parameters}=    ADMIN Get Parameters For All GNCELs    alias=suite
    Set Suite Variable    ${OUT_ADMIN_LNCELS_PARAMETERS}    ${out_lncels_parameters}
    Set Suite Variable    ${OUT_ADMIN_NRCELS_PARAMETERS}    ${out_nrcels_parameters}
    Set Suite Variable    ${OUT_ADMIN_WNCELS_PARAMETERS}    ${out_wncels_parameters}
    Set Suite Variable    ${OUT_ADMIN_GNCELS_PARAMETERS}    ${out_gncels_parameters}

PREPOST Create List Of Objects Parameter Values
    [Arguments]    ${parameters_list}    ${parameter}
    ${out_list}=    Create List
    FOR    ${out_index}    IN    @{parameters_list}
        Log    ${out_index}
        ${out_parameter}=    Get From Dictionary    ${out_index}    ${parameter}
        Append To List    ${out_list}    ${out_parameter}
    END
	[Return]   ${out_list}

PREPOST Create List Of Smod Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values    parameters_list=${OUT_ADMIN_SMOD_PARAMETERS}
    ...                                                                          parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Smod Ids
    ${out_smods_id_list}=    PREPOST Create List Of Smod Parameter Value    parameter=id
    Set Suite Variable    ${OUT_SMODS_IDS_LIST}    ${out_smods_id_list}

PREPOST Create List Of Smod SerialNumbers
    ${out_smods_serial_number_list}=    PREPOST Create List Of Smod Parameter Value    parameter=serialNumber
    Set Suite Variable    ${OUT_SMODS_SERIAL_NUMBER_LIST}    ${out_smods_serial_number_list}

PREPOST Create List Of Smod IpAddresses
    ${out_smods_ip_address_list}=    PREPOST Create List Of Smod Parameter Value    parameter=ipAddress
    Set Suite Variable    ${OUT_SMODS_IP_ADDRESS_LIST}    ${out_smods_ip_address_list}

PREPOST Create List Of Bbmods Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values    parameters_list=${OUT_ADMIN_BBMODS_PARAMETERS}
    ...                                                                          parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Bbmods Ids
    ${out_bbmods_id_list}=    PREPOST Create List Of Bbmods Parameter Value    parameter=id
    Set Suite Variable    ${OUT_BBMODS_IDS_LIST}    ${out_bbmods_id_list}

PREPOST Create List Of Rmods Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values    parameters_list=${OUT_ADMIN_RMODS_PARAMETERS}
    ...                                                                          parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Rmods Ids
    ${out_rmods_id_list}=    PREPOST Create List Of Rmods Parameter Value    parameter=id
    ${out_rmods_id_list}=    evaluate    sorted(${out_rmods_id_list})
    Set Suite Variable    ${OUT_RMODS_IDS_LIST}    ${out_rmods_id_list}

PREPOST Create List Of Rmods Product Names
    ${out_rmods_productnames_list}=    PREPOST Create List Of Rmods Parameter Value    parameter=productName
    Set Suite Variable    ${OUT_RMODS_PRODUCTNAMES_LIST}    ${out_rmods_productnames_list}

PREPOST Create List Of Rmods Serial Numbers
    ${out_rmods_serialnumbers_list}=    PREPOST Create List Of Rmods Parameter Value    parameter=serialNumber
    Set Suite Variable    ${OUT_RMODS_SERIALNUMBERS_LIST}    ${out_rmods_serialnumbers_list}

PREPOST Create List Of Lncels Parameter Values
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values    parameters_list=${OUT_ADMIN_LNCELS_PARAMETERS}
    ...                                                                          parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Lncels Ids
    ${out_lncels_ids_list}=    PREPOST Create List Of Lncels Parameter Values    parameter=id
    ${out_lncels_ids_list}=    evaluate    sorted(${out_lncels_ids_list})
    Set Suite Variable    ${OUT_LNCELS_IDS_LIST}    ${out_lncels_ids_list}

PREPOST Get Smod Position
    ${out_smod_position}=    ADMIN Get Smod Position    alias=suite
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

PREPOST Compare Comissioned And Configured Smods
    Should Be Equal    ${OUT_SCF_SMOD_COUNT}    ${OUT_ADMIN_SMODS_AMOUNT}    msg=Amount Of Commissioned And Configurd Smods Is Different

PREPOST Compare Comissioned And Configured Bbmods
    Should Be Equal    ${OUT_SCF_BBMOD_COUNT}    ${OUT_ADMIN_BBMODS_AMOUNT}    msg=Amount Of Commissioned And Configurd Bbmods Is Different

PREPOST Compare Comissioned And Configured Rmods
    Should Be Equal    ${OUT_SCF_RMOD_COUNT}    ${OUT_ADMIN_RMODS_AMOUNT}    msg=Amount Of Commissioned And Configurd Rmods Is Different

PREPOST Compare Comissioned And Configured Alds
    Should Be Equal    ${OUT_SCF_ALD_COUNT}    ${OUT_ADMIN_ALDS_AMOUNT}    msg=Amount Of Commissioned And Configurd Alds Is Different

PREPOST Compare Comissioned And Configured Lncels
    Should Be Equal    ${OUT_SCF_LNCEL_COUNT}    ${OUT_ADMIN_LNCELS_AMOUNT}    msg=Amount Of Commissioned And Configurd Lncels Is Different

PREPOST Get Active Software Versions
    ${out_active_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    activeSoftwareVersion
    Set Suite Variable    ${OUT_ACTIVE_SW}    ${out_active_sw}

PREPOST Get Passive Software Versions
    ${out_passive_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    passiveSoftwareVersion
    Set Suite Variable    ${OUT_PASSIVE_SW}    ${out_passive_sw}

PREPOST Get Active And Passive Software Versions
    PREPOST Get Active Software Versions
    PREPOST Get Passive Software Versions

PREPOST Create List Of Smods Product Codes
    ${out_smods_product_codes_list}=    Create List
    FOR    ${out_index}    IN    @{OUT_ADMIN_SMODS_PARAMETERS}
        Log    ${out_index}
        ${out_smod_product_code}=    Get From Dictionary    ${out_index}    productCode
        Append To List    ${out_smods_product_codes_list}    ${out_smod_product_code}
    END
	Set Suite Variable    ${OUT_SMODS_PRODUCT_CODES_LIST}    ${out_smods_product_codes_list}

PREPOST Check Cells Mapping To FSPs
    ${out_cells_mapped_to_smod}=    ADMIN Get Cell Mapping By Module Id    module_id=${OUT_SMODS_IDS_LIST[0]}    alias=suite
    Set Suite Variable    ${OUT_CELLS_MAPPED_TO_SMOD}    ${out_cells_mapped_to_smod}
    FOR    ${out_index}    IN RANGE    0    ${OUT_ADMIN_BBMODS_AMOUNT}
        ${bbmod_number}=    Evaluate    ${out_index}+${1}
        ${out_cells_mapped_to_bbmod}=    ADMIN Get Cell Mapping By Module Id    module_id=${OUT_BBMODS_IDS_LIST[${out_index}]}    alias=suite
        Set Suite Variable    ${OUT_CELLS_MAPPED_TO_BBMOD_${bbmod_number}}    ${out_cells_mapped_to_bbmod}
    END