*** Settings ***

Documentation
...  author/contact: oleksii.mikhanchuk@nokia.com
...
...  List of keywords for COAM.

Library         Process
Library         coam_resources.py       WITH NAME  coam_res
Library         taf.sbts.oam.coam.admin  WITH NAME  coam_cli
Library         taf.transport.ssh       WITH NAME       ssh

*** Variables ***
${LOG_PATH}                 ${OUTPUT DIR}

*** Keywords ***
Check that sw on radios is updated
    [Arguments]  ${coam_conn_alias}
    ${alarms_eNB}  coam_cli.get_active_alarms   connection=${coam_conn_alias}
    ${should_radio_software_be_updated}  coam_res.check_alarm_occurs  ${alarms_eNB}  23
    run keyword if  ${should_radio_software_be_updated}
    ...             Download and reupdate software  ${coam_conn_alias}

Download current soft
    [Arguments]  ${sw_to_download}  ${download_dir}=/tmp/curr_soft/
    log to console  Download current soft
    ${sw_file_path}  coam_res.download_file_from_artifactory    ${ENB_BUILD}   ${sw_to_download}  ${download_dir}
    log to console  Soft downloaded ${sw_file_path}
    [Return]  ${sw_file_path}

Get module type
    [Arguments]  ${bts_info}  ${module_type}
    ${mod_type}  coam_res.get_type  ${bts_info}  ${module_type}
    log to console  module type ${mod_type}
    [Return]  ${mod_type}

Update Software
    [Arguments]  ${sw_file_path}
    ...          ${coam_conn_alias}
    ...          ${should_activate}=${TRUE}
    ...          ${timeout}=900
    coam_cli.update_software
    ...          sw_package=${sw_file_path}
    ...          should_activate=${should_activate}
    ...          timeout=${timeout}
    ...          connection=${coam_conn_alias}

Download and reupdate software
    [Arguments]  ${coam_conn_alias}
    log to console  Reload software started
    ${sw_to_download}   coam_res.prepare_sw_name_to_dl  ${ENB_BUILD}
    ${sw_file_path}     Download current soft  ${sw_to_download}
    log to console  Updating software
    Wait until keyword succeeds    25m    30s    Update Software  ${sw_file_path}  ${coam_conn_alias}
    log to console  Reload software finished

Check BTS and commission BTS
    [Documentation]
    ...  author/contact: damian.silkowski@nokia.com, I_5G_TLM_WRO_GMS <I_5G_TLM_WRO@internal.nsn.com>
    ...  Keyword checks BTS status and make commissioning and if it needs reupload soft on radios
    ...  param:  ${scf} - path to SCF
    ...  param:  ${coam_conn_alias}  - alias to coam connection
    [Arguments]  ${scf}  ${coam_conn_alias}=BTS_coam
    ${are_cell_on_air}  run keyword and return status  Are cell on air  ${coam_conn_alias}
    run keyword if  '${are_cell_on_air}'=='${FALSE}'  run keyword  run keywords
    ...     coam_cli.perform_commissioning  scf_file=${scf}  connection=${coam_conn_alias}  AND
    ...     sleep  3m  AND
    ...     Force ReConnect to ASIK  AND
    ...     Replace swconfig  ${coam_conn_alias}  AND
    ...     Disconnect from ASIK  AND
    ...     sleep  5m  AND
    ...     Check that sw on radios is updated  ${coam_conn_alias}  AND
    ...     wait until keyword succeeds  12m  30s  Are cell on air  ${coam_conn_alias}

Are cell on air
    [Documentation]
    ...  author/contact: damian.silkowski@nokia.com, I_5G_TLM_WRO_GMS <I_5G_TLM_WRO@internal.nsn.com>
    ...  Keyword checks that BTS in on air state -  all cels
    ...  param:  ${coam_conn_alias}  - alias to coam connection
    ...  param:  ${cell_type}  - cell type - nr=5G - lte=LTE
    [Arguments]  ${coam_conn_alias}  ${cell_type}=nr
    ${cells_info}  coam_cli.get_cells_info  connection=${coam_conn_alias}  cell_type=${cell_type}
    log  ${cells_info}
    ${are_cells_on_air}=  coam_res.check_that_every_cells_on_air_state  ${cells_info}  ${cell_type}
    should be true  ${are_cells_on_air}

Check alarms and raise
    [Arguments]     ${alias}=gNB
    #Check if there are other alarms than faultId 61524, 61649, 6450, 4654, 4655
    ${alarms}=  coam_cli.get_active_alarms   connection=${alias}
    check_alarms_and_raise_exception      ${alarms}

Check XPIF and raise
    #Check if XP connection is established
    [Arguments]    ${alias}=eNB
    ${xpif}=     coam_cli.get_managed_objects  connection=${alias}  class_name=XPIFREMOTE_R
    Should be true  '${xpif[0]["parameters"]["xpLinkStatus"]}' == 'available'

Check X2 and raise
    [Arguments]    ${alias}=gNB
    ${x2link}=     coam_cli.get_managed_objects  connection=${alias}  class_name=LTEENB_R
    Should be true  '${x2link[0]["parameters"]["x2LinkStatus"]}' == 'available'

Check cells on-air and raise
    [Arguments]    ${connection}    ${class}
    ${cells}=     coam_cli.get_managed_objects  connection=${connection}  class_name=${class}
    Log  ${cells}
    check_cells_onair   ${cells}

Check cells offline and raise
    [Arguments]    ${connection}    ${class}
    ${cells}=     coam_cli.get_managed_objects  connection=${connection}  class_name=${class}
    Log  ${cells}
    check_cells_offline   ${cells}

Replace swconfig
    [Arguments]    ${ssh_alias}=asik
    Log to console      Replacing swconfig on gNB

    ssh.force_reconnect     connection=asik
    Run keyword if          '5G20A_' in '''${ENB_BUILD}'''
    ...                     ssh.upload file
    ...                         remote_path=/ffs/run/swconfig.txt
    ...                         local_path=testsuite/Wroclaw/SyVe/RRM/resources/swconf/swconfig_20A.txt
    ...                         connection=${ssh_alias}

    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     ssh.upload file
    ...                         remote_path=/ffs/run/swconfig.txt
    ...                         local_path=testsuite/Wroclaw/SyVe/RRM/resources/swconf/swconfig_trunk.txt
    ...                         connection=${ssh_alias}

    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     ssh.upload file
    ...                         remote_path=/ffs/run/swconfig.txt
    ...                         local_path=testsuite/Wroclaw/SyVe/RRM/resources/swconf/swconfig_20B.txt
    ...                         connection=${ssh_alias}

    Run keyword if          '5G21A_' in '''${ENB_BUILD}'''
    ...                     ssh.upload file
    ...                         remote_path=/ffs/run/swconfig.txt
    ...                         local_path=testsuite/Wroclaw/SyVe/RRM/resources/swconf/swconfig_21A.txt
    ...                         connection=${ssh_alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     ssh.upload file
    ...                         remote_path=/ffs/run/swconfig.txt
    ...                         local_path=testsuite/Wroclaw/SyVe/RRM/resources/swconf/swconfig_SBTS.txt
    ...                         connection=${ssh_alias}

    Run keyword if          'SBTS22R1_' in '''${ENB_BUILD}'''
    ...                     ssh.upload file
    ...                         remote_path=/ffs/run/swconfig.txt
    ...                         local_path=testsuite/Wroclaw/SyVe/RRM/resources/swconf/swconfig_SBTS.txt
    ...                         connection=${ssh_alias}

Commission gNB
    [Arguments]  ${alias}=gNB    ${tl_host_name}=default    ${config_file}=20Mhz    ${index_config}=1
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLASSTL052'    Commission scf gNB 51105    alias=${alias}
    ...                     config_file=${config_file}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL06'    Commission scf gNB 50427    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLASSCL05'    Commission scf gNB 50313    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL02'    Commission scf gNB 50432    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLASSTL19'    Commission scf gNB 50440    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}

Commission scf gNB 51105
    [Arguments]  ${alias}=gNB   ${config_file}=20Mhz
    ${scf_name}=    Run keyword if   '${config_file}' == '20Mhz'    Set Variable    TL52_51105_20MHz-CommonTrunk.xml
    ...    ELSE IF   '${config_file}' == '10Mhz'    Set Variable    TL52_51105_10MHz-CommonTrunk.xml
    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/5GC002558/5GC002558-A/resources/SCF/SBTS00/${scf_name}
    ...                     connection=${alias}

    Run keyword if          'SBTS22R1_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/5GC002558/5GC002558-A/resources/SCF/SBTS22R1/${scf_name}
    ...                     connection=${alias}

Commission scf gNB 50427
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz  ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}  ${config_files_gnb[${index_config}]}
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Commission scf gNB 50313
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}    ${config_files_gnb[${index_config}]}
    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Commission scf gNB 50432
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}    ${config_files_gnb[${index_config}]}
    Run keyword if          '5G21A_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS21B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Commission scf gNB 50440
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}    ${config_files_gnb[${index_config}]}

    Run keyword if          'SBTS21B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Commission eNB
    [Arguments]  ${alias}=eNB    ${tl_host_name}=default    ${config_file}=20Mhz    ${index_config}=1
    Run keyword if          '${tl_host_name}' == 'default'    Commission scf eNB 41105    alias=${alias}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL06'    Commission scf eNB 40427    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLASSCL05'    Commission scf eNB 40313    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL02'    Commission scf eNB 40432    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}

Commission scf eNB 41105
    [Arguments]  ${alias}=eNB
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/LTE-locked-trunk.xml
    ...                     connection=${alias}

    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/LTE-locked-20B.xml
    ...                     connection=${alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/LTE-locked-trunk.xml
    ...                     connection=${alias}

    Run keyword if          'SBTS22R1_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/LTE-locked-trunk.xml
    ...                     connection=${alias}

Commission scf eNB 40427
    [Arguments]  ${alias}=eNB    ${config_file}=20Mhz  ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_enb[0]}  ${config_files_enb[${index_config}]}
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}
Commission scf eNB 40313
    [Arguments]  ${alias}=eNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_enb[0]}    ${config_files_enb[${index_config}]}
    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Commission scf eNB 40432
    [Arguments]  ${alias}=eNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_enb[0]}    ${config_files_enb[${index_config}]}
    Run keyword if          '5G21A_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS21B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.perform_commissioning
    ...                     scf_file=testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Validate scf gNB
    [Arguments]  ${alias}=gNB    ${tl_host_name}=default    ${config_file}=20Mhz    ${index_config}=1
    Run keyword if          '${tl_host_name}' == 'default'    Validate scf gNB 51105    alias=${alias}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL06'    Validate scf gNB 50427    alias=${alias}
    ...                      config_file=${config_file}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLASSCL05'    Validate scf gNB 50313    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL02'    Validate scf gNB 50432    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}


Validate scf gNB 51105
    [Arguments]  ${alias}=gNB
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/5G-locked-trunk.xml
    ...                     connection=${alias}

    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/5G-20B.xml
    ...                     connection=${alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf
    ...                     testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/TL52_51105_10MHz-CommonTrunk.xml
    ...                     connection=${alias}

Validate scf gNB 50427
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz  ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}  ${config_files_gnb[${index_config}]}
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}
Validate scf gNB 50313
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}    ${config_files_gnb[${index_config}]}
    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Validate scf gNB 50432
    [Arguments]  ${alias}=gNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_gnb[0]}    ${config_files_gnb[${index_config}]}
    Run keyword if          '5G21A_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS21B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Validate scf eNB
    [Arguments]  ${alias}=eNB    ${tl_host_name}=default    ${config_file}=20Mhz    ${index_config}=1
    Run keyword if          '${tl_host_name}' == 'default'    Validate scf eNB 41105    alias=${alias}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL06'    Validate scf eNB 40427    alias=${alias}
    ...                     config_file=${config_file}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLASSCL05'    Validate scf eNB 40313    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}
    Run keyword if          '${tl_host_name}' == '7-16-UTE5GCLOUDCLASSTL02'    Validate scf eNB 40432    alias=${alias}
    ...                     config_file=${config_file}    index_config=${index_config}

Validate scf eNB 41105
    [Arguments]  ${alias}=eNB
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/LTE-locked-trunk.xml
    ...                     connection=${alias}

    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/LTE-locked-20B.xml
    ...                     connection=${alias}

Validate scf eNB 40427
    [Arguments]  ${alias}=eNB    ${config_file}=20Mhz  ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_enb[0]}  ${config_files_enb[${index_config}]}
    Run keyword if          '5G_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS00_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}
Validate scf eNB 40313
    [Arguments]  ${alias}=eNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_enb[0]}    ${config_files_enb[${index_config}]}
    Run keyword if          '5G20B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

Validate scf eNB 40432
    [Arguments]  ${alias}=eNB    ${config_file}=20Mhz    ${index_config}=1
    ${config_file}    set variable if   '${config_file}' == '20Mhz'    ${config_files_enb[0]}    ${config_files_enb[${index_config}]}
    Run keyword if          '5G21A_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}

    Run keyword if          'SBTS21B_' in '''${ENB_BUILD}'''
    ...                     coam_cli.validate_scf    testsuite/Wroclaw/SyVe/RRM/resources/coam_commissionings/${config_file}
    ...                     connection=${alias}
