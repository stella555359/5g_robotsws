*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com,

Resource    DevNJ_upgrade.robot
Resource    DevNJ_testline.robot
Resource    DevNJ_asicli.robot
Resource    DevNJ_epcsim_setup.robot
Resource    DevNJ_5GOAM_keywords.robot

Library     taf.transport.ssh                            WITH NAME    ssh
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     ../python/DevNJ_download_build_from_LS.py

*** Variables ***
@{PARAMS_IN_SWCONFIG}      ${None}
${BTS_TYPE}                ${tl.gnbs[0].__class__.__name__}
${asik alias}              ASIK
${swconfig backup}         ${OUTPUT DIR}/swconfig_backup.txt
${swconfig working copy}   ${OUTPUT DIR}/swconfig.txt


*** Keywords ***
Connect to GNB
    [Arguments]   ${alias}=ASIK
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...   ssh.connect_to   hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                    alias=${alias}
    ...   ELSE
    ...   ssh.connect_to   hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                    alias=${alias}
    ssh.Force Reconnect   connection=${alias}
    [Return]      ${alias}

Get swconfig file from GNB
    Connect to GNB   ${asik alias}
    SWConfig.Download swconfig file from asik to test pc   localFilePath=${swconfig working copy}   asik_alias=${asik alias}
    SWConfig.Download swconfig file from asik to test pc   localFilePath=${swconfig backup}         asik_alias=${asik alias}
    ssh.Disconnect    connection=${asik alias}

Modify parameter in swconfig file
    [Documentation]   This keyword is to modify the parameter in swconfig.txt on ASIK.
    [Arguments]   @{modified content}
    SWConfig.Modify swconfig file   parametersList=@{modified content}   filePath=${swconfig working copy}

Upload swconfig file to GNB
    Connect to GNB   ${asik alias}
    SWConfig.Upload swconfig file to asik and crasign      localFilePath=${swconfig working copy}   asik_alias=${asik alias}
    ssh.Disconnect    connection=${asik alias}

Bring gNB to onAir from gNB commissioned state
    [Documentation]  haiyang.a.zhao@nokia.com: Add flags for truck load to make gNB on air
    Get swconfig file from GNB
    Modify parameter in swconfig file   0x590000=8
    Modify parameter in swconfig file   0x5800BA=11
    Modify parameter in swconfig file   0x190131=0
    Upload swconfig file to GNB
    RestAPI.Reset And Wait For Site
    Run Keyword And Continue On Failure    Wait For Container To Get Up    name=0xe019    timeout=500

Setup Testline To Onair Status
    [Arguments]     ${subtype}=null
    [Documentation]  Cuicui Wang: This Keyword Is To Bringup GNB.
    ...    | 1 | Modify Swconfig |
    ...    | 2 | Get Testline Info |
    ...    | 3 | Perform gNB Commission Upgrade gNB Build And Perform ASIR Commission |
    ...    | 4 | Wait BTS onair |
    ...
    ...    | Para | default value | description |
    ...    | ${subtype} | 'null' | Commission Type Like 4T2R |

    Log To Console  \nModify swconfig
    Run Keyword If  '${PARAMS_IN_SWCONFIG[0]}' != '${None}'   Modify Swconfig
    ${asir_status}    Set Variable    Offline
    ${mrbtsid}  ${PARAMS_IN_SCF_TOTAL}  ${gnb_commission_path}  ${asir_commission_path}   Get GNB ASIR And Testline Info
    ...     ${subtype}

    Log To Console    \nCheck ASIR Status To Access If Upgrade Is Needed Or Not
    ${asir_status}    Check RadioModule Status    'radioModules'
    Run Keyword If  '${asir_status}'=='Online'
    ...    Perfom GNB ASIR Full Commission    ${gnb_commission_path}    ${asir_commission_path}
    ...    ELSE    Upgrade Build And Perfom GNB ASIR Full Commission    ${gnb_commission_path}
    ...    ${asir_commission_path}
    Waiting_For_Site_Response
    Wait for onAir
    Wait Until Keyword Succeeds  6 min  30s  Verify gNB Cells Setup
    Log To Console  gnb is already onair

Upgrade Build And Perfom GNB ASIR Full Commission
    [Arguments]     ${gnb_commission_path}  ${asir_commission_path}
    [Documentation]  Cuicui Wang: This Keyword Is To Upgrade gNB Build And Perform gNB ASIR Commission.
    ...    | 1 | Download gNB Build From Load Server |
    ...    | 2 | Perform gNB Commission |
    ...    | 3 | Check BaseBand Status|
    ...    | 4 | Upgrade gNB Build |
    ...    | 5 | Check Radio Status |
    ...    | 6 | Perform ASIR Commission |
    ...
    ...    | Para | Default Value | Description |
    ...    | ${gnb_commission_path} | NA | Path Of gNB Commission |
    ...    | ${asir_commission_path} | NA | Path Of ASIR Commission |

    Log To Console  \nStart Download SW Build From Load Server
#    ${verison_id}   Get SW Build
    ${sw_build_path}    Download Sw Build From Loadserver   ${ENB_BUILD}
#    ...     ${tl.gnbs[0].dus[0].airscale.common_units[0].hardware_type}
    Log To Console  \nDownload SW Build From Load Server Finished

    Log To Console  \nStart Perform gNB Commission
    ${b_board_status}=  Run Keyword And Return Status    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Run Keyword If  '${b_board_status}'=='False'  Wait Until Keyword Succeeds  6x  30s  Reset gNB Configuration  400
    Log To Console    wait gNB SSH connected
    Waiting_For_Site_Response
    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Wait Until Keyword Succeeds  6x  60s    Run keywords
    ...   Run Keyword And Continue On Failure    RestAPI.Perform Commissioning  ${gnb_commission_path}
    ...   AND  Log To Console    wait gNB SSH connected
    ...   AND  Waiting_For_Site_Response
    ...   AND  Log To Console  Wait for BaseBandModulesStatus Online
    ...   AND  Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Sleep  5min
    # Upgrade Build Via Coam
    Wait Until Keyword Succeeds     10x   1min    COAM_Admin_UpdateSW     ${sw_build_path}
    Log To Console    wait gNB SSH connected
    Waiting_For_Site_Response
    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'
    Log To Console  Perform ASiR Commission After Load Upgrade
    AsiMgr.Send Commission Fullfile     ${asir_commission_path}
    Sleep  30s

Perfom GNB ASIR Full Commission
    [Arguments]     ${gnb_commission_path}  ${asir_commission_path}
    [Documentation]  Cuicui Wang: This Keyword Is To Perform gNB ASIR Commission.
    ...    | 1 | Perform gNB Commission |
    ...    | 2 | Check BaseBand Status |
    ...    | 3 | Check Radio Status |
    ...    | 4 | Perform ASIR Commission |
    ...
    ...    | Para | Default Value | Description |
    ...    | ${gnb_commission_path} | NA | Path Of gNB Commission |
    ...    | ${asir_commission_path} | NA | Path Of ASIR Commission |

    Wait Until Keyword Succeeds      6 min    30s    RestAPI.Perform Commissioning   ${gnb_commission_path}
    Log To Console    wait gNB SSH connected
    Waiting_For_Site_Response
    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Sleep  5min
    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'
    Log To Console  Perform ASiR Commission
    AsiMgr.Send Commission Fullfile     ${asir_commission_path}
    Sleep  30s

Modify Swconfig
    [Documentation]  Cuicui Wang: This Keyword Is To Modify Swconfig.
    ...    | 1 | Connect To gNB |
    ...    | 2 | Backup Swconfig |
    ...    | 3 | Download Swconfig to ${OUTPUT DIR} |
    ...    | 4 | Change Swconfig With @{PARAMS_IN_SWCONFIG} |
    ...    | 5 | Upload and Crasign Swconfig |

    Wait Until Keyword Succeeds    2min    10 sec    Connect to GNB  ${asik alias}
    ssh.Send_Command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_origin.txt    connection=${asik alias}
    SWConfig.Download_Swconfig_File_From_Asik_To_Test_PC    localFilePath=${OUTPUT DIR}/swconfig.txt
	...    asik_alias=${asik alias}  remoteFilePath=/ffs/run/swconfig.txt
    SWConfig.Modify_Swconfig_File    parametersList=@{PARAMS_IN_SWCONFIG}    filePath=${OUTPUT DIR}/swconfig.txt
    SWConfig.Upload_Swconfig_File_To_Asik_And_Crasign    localFilePath=${OUTPUT DIR}/swconfig.txt
    ...    asik_alias=${asik alias}
    ssh.Disconnect    connection=${asik alias}
