*** Settings ***
Library     resources_pmqap_du.py
Library     resources_pmqap_du.GnbPMQAPDU   WITH NAME      pmqap_du
Library    taf.rfrl.bts.devices.du.logs_collecting.basic_logs.EnbLog    WITH NAME      enblog

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/bts/robot/common/gnb_log.robot
Resource    taf/rfrl/bts/robot/common/enb_log.robot


*** Variables ***
${dist_name}=            MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1
${scf_dist_name}=        MRBTS-{}/NRBTS-{}/NRPMRNL-1
${dist_x2_link}=         MRBTS-{}/NRBTS-{}/LTEENB-0

${interface_enb}=        FCT

*** Keywords ***
Activate ACCNQ measurement on DU
    [Arguments]    ${dist_name}     ${interval}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=miNrNsaAcCuNrpmqap    operation=update    param_value=${interval}
    ...   skip_parameter_relation_errors=${true}

Deactivate ACCNQ measurement on DU
    [Arguments]    ${dist_name}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=miNrNsaAcCuNrpmqap    operation=update    param_value=disabled
    ...   skip_parameter_relation_errors=${true}

Activate X2CCQ measurement on DU
    [Arguments]    ${dist_name}     ${interval}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=miNrX2ccNrpmqap    operation=update    param_value=${interval}
    ...   skip_parameter_relation_errors=${true}

Deactivate X2CCQ measurement on DU
    [Arguments]    ${dist_name}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=miNrX2ccNrpmqap    operation=update    param_value=disabled
    ...   skip_parameter_relation_errors=${true}

Activate Measurements
    [Arguments]    ${dist_name}    ${interval}
    Activate ACCNQ measurement on DU    dist_name=${dist_name}    interval=${interval}
    Activate X2CCQ measurement on DU    dist_name=${dist_name}    interval=${interval}

Deactivate Measurements
    [Arguments]    ${dist_name}
    Deactivate ACCNQ measurement on DU    dist_name=${dist_name}
    Deactivate X2CCQ measurement on DU    dist_name=${dist_name}

Get Counter Value
    [Arguments]     ${counter_id}    ${full_path}
    ${couter_value}    pmqap_du.get_pm_counter_info_via_gui    counter_id=${counter_id}    full_path=${full_path}
    [Return]    ${couter_value}

Set ARP profile on DU
    [Arguments]     ${dist_name}        ${value}=1
    [Documentation]  Set ARP profile on DU
    ...     :param dist_name: PMQAP instance dist name
    ...     :value:     parameter value
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=cfgArpRange    operation=update    param_value=${value}
    ...   skip_parameter_relation_errors=${true}

Set QCI profile on DU
    [Arguments]     ${dist_name}        ${value}=6-9
    [Documentation]  Set QCI profile on DU
    ...     :param dist_name: PMQAP instance dist name
    ...     :value:     parameter value
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=cfgQciRange    operation=update    param_value=${value}
    ...   skip_parameter_relation_errors=${true}

Set PLMN profile on DU
    [Arguments]     ${instance_id}
    [Documentation]  Set PLMN profile on DU
    ...     :param instance_id: instance_id
    pmqap_du.create_plmn_profile       instance_id=${instance_id}

Create pmqap instance on DU
    [Arguments]     ${instance_id}
    [Documentation]  Create PMQAP instance on DU
    ...     :param instance_id: instance_id
    pmqap_du.create_pmqap_instance    instance_id=${instance_id}

Delete pmqap instance from DU
    [Arguments]     ${instance_id}
    [Documentation]  Delete pmqap instance from DU
    ...     :param instance_id: instance_id
    pmqap_du.delete_pmqap_instance     instance_id=${instance_id}

Activate feature on DU
    [Documentation]  Set feature flag on DU
    Perform Configuration Parameter Recommissioning On gNB      dist_name=MRBTS-{}/NRBTS-{}
    ...   param_name=actNrpmqapProfiles    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}

Deactivate feature on DU
    [Documentation]  Set feature flag on DU
    Perform Configuration Parameter Recommissioning On gNB      dist_name=MRBTS-{}/NRBTS-{}
    ...   param_name=actNrpmqapProfiles    operation=update    param_value=false
    ...   skip_parameter_relation_errors=${true}

Create PMQAP profiles
    Create pmqap instance on DU  instance_id=1
    Set PLMN profile on DU       instance_id=1
    Set ARP profile on DU        ${dist_name}
    Set QCI profile on DU        ${dist_name}
    Activate feature on DU


Remove PMQAP instances
    Deactivate feature on DU
    Delete pmqap instance from DU       instance_id=1

Lock X2 link
    [Documentation]  Lock X2 link on DU
    ...     :param dist_x2_link: location of X2 link in scf
    pmqap_du.set_parameter      new_parameter=X2C link lock    new_value=locked

Unlock X2 link
    [Documentation]  Unlock X2 link on DU
    ...     :param dist_x2_link: location of X2 link in scf
    pmqap_du.set_parameter      new_parameter=X2C link lock    new_value=unlocked

Get tcpdump dir
    [Arguments]    ${log_file_name}  ${sub_dir}  ${enb_id}=0  ${du_id}=0
    [Documentation]  Get directory for logs to be saved
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    ...     :param log_file_name: name of log file
    ...     :param sub_dir: name of subdirectory
    ${directory}    enblog.download_tcpdump_from_bts    interface=${interface_enb}   log_file_name=${log_file_name}
    ...                                               log_dir=${OUTPUTDIR}/${sub_dir}   bts_id=${enb_id}  du_id=${du_id}
    [Return]    ${directory}

Get tcpdump dir bip
    [Documentation]  Copy tcpdump file from enb
    Download BIP logs from gNB

Cause UE inactivity
    [Documentation]  Cause UE inactivity
    pmqap_du.handle_UE_inactivity    activate=true    timer=30

Fix UE inactivity
    [Documentation]  Fix UE inactivity
    pmqap_du.handle_UE_inactivity    activate=false    timer=1000
