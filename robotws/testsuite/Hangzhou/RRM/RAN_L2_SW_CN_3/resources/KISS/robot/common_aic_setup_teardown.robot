*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n AIC common operate keywords.
#Resource    common_setup_teardown.robot
Resource    common_aic_gnb.robot
Resource    common_aic_airphone.robot
Library    taf.sw.scout    WITH NAME    scout
Library     ../python/tak_gnb/tak_gnb/base.py     WITH NAME    GNB_BASE

*** Variables ***
${TOOLS_LIST}    common_config_private
${CHECK_AP_LO_BOARDS}   export PYTHONPATH=/opt/hwmt/python;
                        ...    python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x5011 -p 15004

*** Keywords ***
AiC Common Suite Setup
    [Documentation]    This keyword is aic common Suite Setup.
    ...    Examples:
    ...    | AIC Common Suite Setup |
    Set Tags     QCP_RAN_VRF
    Set Tags     QCD_MN_RAN
    Clean Up Env
    Get Host IP
    Get Host Name
    Get TL config
    Get CU SW version
    Get VDU SW version
    VDU Get SW Branch
    Download Common Config Files From Private Server
    AIC AP Setup

AiC Common Suite Teardown
    Airphone Teardown

AiC Common Test Setup
    Set Timestamp
    Run Keyword And Ignore Error    Set QC Tag In Case     ${TEST_NAME}     ${SOFTWARE_INFO}

AiC Common Test Teardown
    Get all snapshots    ${OAM_VDU}    ${OAM_CU}
    run keyword and ignore error    common_aic_setup_teardown.Ask scout to analyze scf

Ask scout to analyze scf
    # ask scout to analyze scf
    ${hostname}=    Run    cat /etc/hostname | sed 's/-/_/g'
    ${host_name}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name}"))    re
    scout.setup_scout    scout_testline_name=${hostname}
    scout.request_scf

Reboot AP Via Ssh
    Log To Console    -------- Reboot AP via ssh --------
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${AP_ASIK.ip}

Set Timestamp
    ${date_now}=     Get current date
    ${TIMESTAMP}=    Convert date    ${date_now}    result_format=%Y%m%d-%H%M%S
    Set Test Variable      ${TIMESTAMP}

Get all snapshots
    [Arguments]  ${OAM_VDU}  ${OAM_CU}  ${snapshot_path}=${TEST_LOG_DIRECTORY()}/All
    ${du_master}=  VDU OAM Login    VDU
    ${cu_master}=  CU OAM Login    CU

    VDU.Get local snapshot  ${snapshot_path}  vdu_connection=${OAM_VDU}[connection_name]
    ...                     compressed_or_not=${True}
    ${snapshot_names}=  List files in directory  ${snapshot_path}  pattern=Snapshot_*zip
    Move file  ${snapshot_path}/${snapshot_names}[0]  ${snapshot_path}/vDU_snapshot.zip

    CU.Get local snapshot  ${snapshot_path}  connection=${OAM_CU}[alias]
    ${snapshot_names}=  List files in directory  ${snapshot_path}  pattern=Snapshot_*zip
    Move file  ${snapshot_path}/${snapshot_names}[0]  ${snapshot_path}/vCU_snapshot.zip

    [Teardown]  Run keywords  VDU.Disconnect  vdu_connection=${OAM_VDU}[connection_name]
    ...         AND           CU.Disconnect  connection=${OAM_CU}[alias]
