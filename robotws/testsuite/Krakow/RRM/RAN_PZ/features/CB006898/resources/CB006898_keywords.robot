*** Settings ***
Library     taf.selenium.gnb.oam.coam.cu
Library    resources_pmqap.py
Library    resources_pmqap_cu.py
Library      resources_pmqap.PMQAPDU   WITH NAME      pmqap_du
Library      resources_pmqap_cu.PMQAPCU   WITH NAME      pmqap_cu

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/common/gnb_cu.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot


*** Variables ***
${dist_name}=        MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1
${dist_x2_link}=    MRBTS-{}/NRBTS-{}/LTEENB-0

${log_file_name}=  tcpdump.pcap
${interface}=  CPIF

*** Keywords ***
Activate X2CCQ measurement on CU
    [Arguments]     ${value}
    [Documentation]  Activate X2CCQ measurement on CU
    ...     :param value: parameter value
    pmqap_cu.set_measurement    name=Measurement interval for X2 Connection Control NRPMQAP
    ...     measurement_id=miNrX2ccNrpmqap      value=${value}

Deactivate X2CCQ measurement on CU
    [Documentation]  Deactivate X2CCQ measurement on CU
    pmqap_cu.set_measurement    name=Measurement interval for X2 Connection Control NRPMQAP
    ...     measurement_id=miNrX2ccNrpmqap      value=disabled

Activate ACCNQ measurement on CU
    [Arguments]     ${value}
    [Documentation]  Activate ACCNQ measurement on CU
    ...     :param value: parameter value
    pmqap_cu.set_measurement    name=Measurement interval for Admission Control with CU and for NSA NRPMQAP
    ...     measurement_id=miNrNsaAcCuNrpmqap      value=${value}

Deactivate ACCNQ measurement on CU
    [Documentation]  Activate ACCNQ measurement on CU
    pmqap_cu.set_measurement    name=Measurement interval for Admission Control with CU and for NSA NRPMQAP
    ...     measurement_id=miNrNsaAcCuNrpmqap      value=disabled

Set ARP profile on DU
    [Arguments]     ${dist_name}        ${value}=1
    [Documentation]  Set ARP profile on DU
    ...     :param dist_name: PMQAP instance dist name
    ...     :value:     parameter value
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=cfgArpRange    operation=update    param_value=${value}
    ...   skip_parameter_relation_errors=${true}

Set ARP profile on CU
    [Arguments]     ${instance_id}      ${value}=1
    [Documentation]  Set ARP profile on CU
    ...     :param instance_id: intance_id
    ...     :value:     parameter value
    pmqap_cu.set_profile    name=ARP configuration range
    ...     abbr=cfgArpRange      value=${value}    instance_id=${instance_id}

Set QCI profile on DU
    [Arguments]     ${dist_name}        ${value}=6-9
    [Documentation]  Set QCI profile on DU
    ...     :param dist_name: PMQAP instance dist name
    ...     :value:     parameter value
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=cfgQciRange    operation=update    param_value=${value}
    ...   skip_parameter_relation_errors=${true}

Set QCI profile on CU
    [Arguments]     ${instance_id}      ${value}=6-9
    [Documentation]  Set QCI profile on CU
    ...     :param instance_id: instance_id
    ...     :value:     parameter value
    pmqap_cu.set_profile    name=QCI configuration range
    ...     abbr=cfgQciRange      value=${value}    instance_id=${instance_id}

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

Set PLMN profile on CU
    [Arguments]     ${instance_id}
    [Documentation]  Set PLMN profile on DU
    ...     :param instance_id: instance_id
    pmqap_cu.create_cu_plmn_profile       instance_id=${instance_id}

Create pmqap instance on CU
    [Arguments]     ${instance_id}
    [Documentation]  Create pmqap instance on CU
    ...     :param instance_id: instance_id
    pmqap_cu.create_cu_pmqap_instance     instance_id=${instance_id}

Delete pmqap instance from CU
    [Arguments]     ${instance_id}
    [Documentation]  Delete pmqap instance from CU
    ...     :param instance_id: instance_id
    pmqap_cu.delete_cu_pmqap_instance     instance_id=${instance_id}

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

Activate feature on CU
    [Documentation]  Set feature flag on DU
    pmqap_cu.activate_feature_CB006898    value=true

Deactivate feature on CU
    [Documentation]  Set feature flag on DU
    pmqap_cu.activate_feature_CB006898    value=false

Create PMQAP profiles
    Create pmqap instance on DU  instance_id=1
    Set PLMN profile on DU      instance_id=1
    Set ARP profile on DU       ${dist_name}
    Set QCI profile on DU       ${dist_name}
    Create pmqap instance on CU     instance_id=1
    Set PLMN profile on CU      instance_id=1
    Set ARP profile on CU       instance_id=1
    Set QCI profile on CU       instance_id=1
    Activate feature on DU
    Activate feature on CU

Activate Measurements
    Activate ACCNQ measurement on CU    value=5min
    Activate X2CCQ measurement on CU  value=5min

Deactivate Measurements
    Deactivate ACCNQ measurement on CU
    Deactivate X2CCQ measurement on CU

Remove PMQAP instances
    Deactivate feature on DU
    Deactivate feature on CU
    Delete pmqap instance from CU       instance_id=1
    Delete pmqap instance from DU       instance_id=1

Lock X2 link
    [Documentation]  Lock X2 link on CU
    ...     :param dist_x2_link: location of X2 link in scf
    pmqap_cu.set_parameter      dist_name=${dist_x2_link}      name=X2C link lock   abbr=x2LinkLock    value=locked

Unlock X2 link
    [Documentation]  Unlock X2 link on CU
    ...     :param dist_x2_link: location of X2 link in scf
    pmqap_cu.set_parameter      dist_name=${dist_x2_link}      name=X2C link lock   abbr=x2LinkLock    value=unlocked

Get tcpdump dir
    [Documentation]  Get directory for logs to be saved
    ${directory}     gnbcu.Download Bip Logs From Upue Interface     interface=${interface}    log_file_name=${log_file_name}
    [Return]    ${directory}

Cause UE inactivity
    [Documentation]  Cause UE inactivity
    pmqap_cu.handle_UE_inactivity    activate=true    timer=30

Fix UE inactivity
    [Documentation]  Fix UE inactivity
    pmqap_cu.handle_UE_inactivity    activate=false    timer=1000
