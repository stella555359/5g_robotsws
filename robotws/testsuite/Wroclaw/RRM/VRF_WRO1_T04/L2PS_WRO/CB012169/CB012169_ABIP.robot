*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Marcin Kotula
...              :contact: marcin.kotula@nokia.com

Resource     resources/CB012169_keywords.robot
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin


*** Variables ***
${iphy_CB012169_ABIP}          ${CURDIR}/config/iphy_3xAVQL_3xORAN_ABIP.xml
${scf_CB012169_ABIP}           ${CURDIR}/config/SBTS00/full_CB012169_3xAVQL_3xORAN_ABIP.xml
${cfg_CB012169_ABIP}           ${CURDIR}/config/basic_setup_CB012169_ABIP.cfg
@{SWCONFIG_FLAGS}=             0x8000A6=0  0x42009d=31
@{sudo_list}=                  &{authentication}
&{authentication}             id=1    defaultNetconfAccount=&{default_user}
&{default_user}=              defaultNetconfAccountName=xranuser
...                           defaultNetconfAccountPwd=xran-password
${local_save_path}            /home/ute/Downloads
${ncsnap_path0}=              ${CURDIR}/config/25R2_NCSnapshot-AWHQN.xml
${ncsnap_path1}=              ${CURDIR}/config/25R2_NCSnapshot-AWHQN1.xml
${ncsnap_path2}=              ${CURDIR}/config/25R2_NCSnapshot-AWHQN2.xml
${ADMIN_BTS_HOST}=            192.168.255.129
${ADMIN_BTS_PORT}=            443
${ADMIN_USERNAME}=            Nemuadmin
${ADMIN_PASSWORD}=            nemuuser
${ADMIN_USE_SSL}=             True
${ADMIN_UPDATE_INTERVAL}=     5000
${ADMIN_API_LOG_DIR}=         ${OUTPUT_DIR}
${ADMIN_TIMEOUT}=             30
${ADMIN_ALIAS}=               default
${RFplugin_file}              RFMPlugin_O-RU_NK_475701A-102_0010.zip
${artifactory_link}           "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_O-RU_NK_475701A-102_0010.zip"

*** Keywords ***
Manual_SiSo_SM_Cell_Block_Unblock
    Set Beams For 5 UE
    Attach UEs    num_ue=12
    Start Dl and UL Data Traffic For All UEs      num_ue=12    dl_mbps=175    ul_mbps=100
    Check Cells DL and UL TPUT
    Lock Single Cell    cell_id=1      timeout=60
    Check DL and UL TPUT After Cell 1 Block
    Unlock Single Cell    cell_id=1      timeout=60
    Sleep   30s
    Attach UE After Unblocked Cell     ue_id=1
    Start Dl and UL Traffic     ue_id=1    pdu_id=1    dl_mbps=175    ul_mbps=100
    Lock Single Cell    cell_id=7      timeout=60
    Check DL and UL TPUT After Cell 7 Block
    Unlock Single Cell    cell_id=7      timeout=60
    Sleep   30s
    Attach UE After Unblocked Cell     ue_id=7
    Start Dl and UL Traffic     ue_id=7    pdu_id=7    dl_mbps=175    ul_mbps=100
    Lock Single Cell    cell_id=12      timeout=60
    Check DL and UL TPUT After Cell 12 Block
    Unlock Single Cell    cell_id=12      timeout=60
    Sleep   30s
    Attach UE After Unblocked Cell     ue_id=12
    Start Dl and UL Traffic     ue_id=12    pdu_id=12    dl_mbps=175    ul_mbps=100


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

Configure Netconf Credentials
    ADMIN Setup Admin
    taf.sbts.oam.coam.admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{sudo_list}
    Sleep  30s
    ADMIN Teardown Admin

Get and Update RFMplugin
     [Arguments]      ${sw_file_name}      ${artifactory_link}
     OperatingSystem.Run    wget ${artifactory_link} -P ${local_save_path}     # CA UTE Token cannot be used for this file (10.03.2026)
     ADMIN Setup Admin
     ADMIN Update Software With Activation
     ...           sw_package=${local_save_path}/${sw_file_name}
     ADMIN Teardown Admin


Check Cells DL and UL TPUT
    FOR    ${id}    IN RANGE    1    7
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END
    FOR    ${id}    IN RANGE    7    13
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END

Check DL and UL TPUT After Cell 1 Block
    FOR    ${id}    IN RANGE    2    7
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END
    FOR    ${id}    IN RANGE    7    13
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END

Check DL and UL TPUT After Cell 7 Block
    FOR    ${id}    IN RANGE    1    7
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END
    FOR    ${id}    IN RANGE    8    13
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END

Check DL and UL TPUT After Cell 12 Block
    FOR    ${id}    IN RANGE    1    7
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END
    FOR    ${id}    IN RANGE    7    12
        Verify Tput For UE    ue_id=${id}   dir=dl    expected_tput=90
        Verify Tput For UE    ue_id=${id}   dir=ul    expected_tput=50
    END

Set Beams For 5 UE
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_beam_paths=16
    ...     azimuth=0,17,32,46,0,17,32,46,-21,-37,-50,-10,-21,-37,-50,-10
    ...     zenith=4,4,4,4,4,4,4,4,-7,-7,-7,-7,-7,-7,-7,-7
    ...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=2 num_beam_paths=16
    ...     azimuth=0,-17,-32,-46,0,-17,-32,-46,21,37,50,10,21,37,50,10
    ...     zenith=-4,-4,-4,-4,-4,-4,-4,-4,7,7,7,7,7,7,7,7
    ...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
    Execute Egate Command   cmd=ue_testmode_set_nr id=7 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=8 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=9 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=10 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=11 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=12 testmode=ue_ul_beam_position action=activate profile_id=2


Attach UE After Unblocked Cell
    [Arguments]    ${ue_id}
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${ue_id}
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}     pdu_id=${ue_id}     gw_id=${ue_id}
