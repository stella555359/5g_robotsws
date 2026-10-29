*** Settings ***
Force Tags    CLOUD_5G_I_LPQ_AP_LOO   VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Galczynski
...              :contact: kamil.galczynski@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     resources/CB012169_keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    ../CB007813/CB007813-B_keywords.py
Library    resources/vendor_file_modifier.py
Library    Collections
Resource     ../resources/configuration_id.robot
Library    taf.sbts.oam.coam.admin


Suite Setup    Run Keywords    Get and Update RFMplugin   ${RFplugin_file}     ${artifactory_link}
    ...                 AND     Configure Netconf Credentials
    ...                 AND     Sleep    30s
    ...        AND             Start Default Logging
    ...         AND            load ncsnapshot      ncsnap_path=${ncsnap_path1}
    ...         AND            Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1xAVQL_1xORAN_ABIQ.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Get and Update BSR File  bsr_file_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
    ...        AND             Download and Modify Vendor File and perform commissioning    scf=full_CB012169_1xAVQL_1xORAN_ABIQ
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_CB012169_ABIQ.cfg
Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{SWCONFIG_FLAGS}=      0x8000A6=0  0x42009d=31
@{sudo_list}=        &{authentication}
&{authentication}   id=1    defaultNetconfAccount=&{default_user}
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
${local_save_path}   /home/ute/Downloads
${ncsnap_path1}=              ${CURDIR}/config/25R2_NCSnapshot-AWHQN1.xml
${ADMIN_BTS_HOST}=            192.168.255.129
${ADMIN_BTS_PORT}=            443
${ADMIN_USERNAME}=            Nemuadmin
${ADMIN_PASSWORD}=            nemuuser
${ADMIN_USE_SSL}=             True
${ADMIN_UPDATE_INTERVAL}=     5000
${ADMIN_API_LOG_DIR}=         ${OUTPUT_DIR}
${ADMIN_TIMEOUT}=             30
${ADMIN_ALIAS}=               default
${RFplugin_file}      RFMPlugin_O-RU_NK_475701A-102_0010.zip
${artifactory_link}     "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_O-RU_NK_475701A-102_0010.zip"

*** Test Cases ***
[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
	Set Beams
    Attach UEs
    Start Dl and UL Data Traffic For All UEs
    Sleep   180s
    Check DL and UL TPUT For All Cells
    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
load ncsnapshot
    [Arguments]    ${ncsnap_path}
      ${cmd1}  Set Variable   scp ${ncsnap_path} toor4nsn@192.168.200.1:/rom/simmode/
      ${status1}    run    ${cmd1}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    alias=${alias}

ADMIN Setup Admin
    [Arguments]    ${bts_host}=${ADMIN_BTS_HOST}
    ...            ${bts_port}=${ADMIN_BTS_PORT}
    ...            ${username}=${ADMIN_USERNAME}
    ...            ${password}=${ADMIN_PASSWORD}
    ...            ${use_ssl}=${ADMIN_USE_SSL}
    ...            ${update_interval}=${ADMIN_UPDATE_INTERVAL}
    ...            ${admin_api_log_dir}=${ADMIN_API_LOG_DIR}
    ...            ${timeout}=${ADMIN_TIMEOUT}
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${use_ssl}
    ...    update_interval=${update_interval}
    ...    admin_api_log_dir=${admin_api_log_dir}
    ...    timeout=${timeout}
    ...    alias=${alias}

Configure Netconf Credentials
    taf.sbts.oam.coam.admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{sudo_list}

Get and Update RFMplugin
     [Arguments]      ${sw_file_name}      ${artifactory_link}
     OperatingSystem.Run    wget ${artifactory_link} -P ${local_save_path}    # CA UTE Token cannot be used for this file (10.03.2026)
     ADMIN Setup Admin
     ADMIN Update Software With Activation
     ...           sw_package=${local_save_path}/${sw_file_name}

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Check DL and UL TPUT For All Cells
	FOR    ${id}    IN RANGE    1    5
		Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
		Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END

Set Beams
	Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_beam_paths=16
	...     azimuth=0,17,32,46,0,17,32,46,-21,-37,-50,-10,-21,-37,-50,-10
	...     zenith=4,4,4,4,4,4,4,4,-7,-7,-7,-7,-7,-7,-7,-7
	...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
	Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=2 num_beam_paths=16
	...     azimuth=0,-17,-32,-46,0,-17,-32,-46,21,37,50,10,21,37,50,10
	...     zenith=-4,-4,-4,-4,-4,-4,-4,-4,7,7,7,7,7,7,7,7
	...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
	Execute Egate Command   cmd=ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=1
	Execute Egate Command   cmd=ue_testmode_set_nr id=3 testmode=ue_ul_beam_position action=activate profile_id=2
	Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ue_ul_beam_position action=activate profile_id=1

Start Dl and UL Data Traffic For All UEs
    FOR    ${id}    IN RANGE    1    5
		Start Dl and UL Traffic     ue_id=${id}
    END
    Sleep    30s

Start Dl and UL Traffic
	[Arguments]    ${ue_id}
	Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=dl mbps=175 trf_id=1

    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=ul mbps=100 trf_id=1

Attach UEs
	FOR    ${id}    IN RANGE    1    5
		Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=${id}
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=${id}     gw_id=${id}
    END

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Stop All Data Transfers And Detach UE-${id}
    Execute Egate Command    cmd=trf_data_stop ue=${id} pdu=${id}
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${id} ue_deregister_type=switch_off
