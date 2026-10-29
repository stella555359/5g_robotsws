*** Settings ***

Documentation     Keywords for journal

Library     taf.collectors.journal      WITH NAME   journal
Library     taf.collectors.core         WITH NAME   core

Resource    ./testline.robot
Resource    ./connect.robot
Resource    ./gnb.robot

*** Keywords ***
Start Journal on all gNBs
    [Documentation]    :Author: Vasileios Papoutsis
    ${gnb_num}=    Get length    ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${0}    ${gnb_num}
       Start Journal on gNB     gnb_id=${gnb_id}
    END

Start Journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...    Start journal logging on all DU over all Common Unit over all Capacity units/Loner
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${gnb_id}=${0}
    Start OAM Journal on gNB    gnb_id=${gnb_id}
    ${gnb_type}=    testline.Get gNB type
    Run Keyword If   '${gnb_type}'=='cloud'     Start all VM journal on gNB     gnb_id=${gnb_id}
    Start Journal on gNB on all DUs     gnb_id=${gnb_id}


Stop Journal on all gNBs
    [Documentation]    :Author: Vasileios Papoutsis
    ${gnb_num}=    Get length     ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${0}    ${gnb_num}
       Stop Journal on gNB     gnb_id=${gnb_id}
    END

Stop Journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop journal logging and download logs from all DU over all Common Unit over all Capacity units/Loner
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None
    Stop OAM Journal on gNB    gnb_id=${gnb_id}    target_dir=${target_dir}
    ${gnb_type}=    testline.Get gNB type
    Run Keyword If   '${gnb_type}'=='cloud'     Stop all VM journal on gNB    gnb_id=${gnb_id}    target_dir=${target_dir}
    Stop Journal on gNB on all DUs    gnb_id=${gnb_id}    target_dir=${target_dir}


Start OAM Journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...     Start journal logging on OAM on a gNB
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${gnb_id}=${0}
    &{oam_ssh_config}=    Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...     user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  extra=oam
    journal.create_journal_collector
    ...     name=${journal_name}
    ...     options=-f -o short-precise
    ...     executor=${oam_ssh_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}


Stop OAM Journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop and fetch journal logging on OAM on a gNB
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}    extra=oam
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    [Return]    ${target_dir}/${journal_name}/journal.log


Start all VM journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...     Start journal log collector on all VM on on gNB
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${gnb_id}=${0}
    @{vm_names}=    gnb.Get gNB VM list     gnb_id=${gnb_id}
    FOR    ${vm}    IN     @{vm_names}
       Start VM Journal on gNB     vm_name=${vm}     gnb_id=${gnb_id}
    END

Stop all VM journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop journal log collector on all VM on on gNB
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None
    @{vm_names}=    gnb.Get gNB VM list     gnb_id=${gnb_id}
    FOR    ${vm}    IN    @{vm_names}
       Stop VM Journal on gNB    vm_name=${vm}    gnb_id=${gnb_id}    target_dir=${target_dir}
    END

Start VM Journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Journal log on a VM on an gNB
    ...
    ...     :param vm_name: Name of virual machine (cpcl|cpif|cpnb|cpue|upue|cpnrt)
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${vm_name}    ${gnb_id}=${0}
    &{oam_config}=    Create dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_config}=   Create dictionary
    ...    host=${vm_name}-0.local
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...    proxy=${oam_config}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}    extra=${vm_name}
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${vm_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias    ${journal_name}


Stop VM Journal on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop Journal log on a VM on an gNB
    ...
    ...    :param vm_name: Name of virual machine (cpcl|cpif|cpnb|cpue|upue|cpnrt)
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${vm_name}    ${gnb_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  extra=${vm_name}
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    [Return]    ${target_dir}/${journal_name}/journal.log


Start Journal on gNB on all DUs
    [Documentation]    :Author: Soenke Kullberg
    ...         Start journal log collector on all Dus
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${gnb_id}=${0}
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du}    IN RANGE    ${du_num}
        Start Journal on gNB on DU  gnb_id=${gnb_id}   du_id=${du}
    END

Stop Journal on gNB on all DUs
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop journal log collector on all Dus
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du}    IN RANGE    ${du_num}
        Stop Journal on gNB on DU    gnb_id=${gnb_id}    du_id=${du}    target_dir=${target_dir}
    END

Start Journal on gNB on DU
    [Documentation]    :Author: Soenke Kullberg
    ...         Start journal log collector on all Common units on one DU
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}
    ${comu_num}=    Get length        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu}    IN RANGE    ${comu_num}
        Start Journal on gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu}
    END

Stop Journal on gNB on DU
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop journal log collector on all Common units on one DU
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${target_dir}=None
    ${comu_num}=    Get length        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu}    IN RANGE    ${comu_num}
        Stop Journal on gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu}    target_dir=${target_dir}
    END

Start Journal on gNB Common Unit
    # and all Capacity Units
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Jornal log on Common Unit and all releated Capacity Units
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...
   [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}
    &{comu_config}=    Create dictionary
    ...    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}
    journal.create_journal_collector
    ...     name=${journal_name}
    ...     options=-f -o short-precise
    ...     executor=${comu_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} journal started successfully    console=${P_console}
    ${capu_num}=    Get length        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    FOR    ${capu}    IN RANGE    ${capu_num}
           Start Journal on gNB Capacity Unit    gnb_id=${gnb_id}   du_id=${du_id}     comu_id=${comu_id}     capu_id=${capu}
    END

Stop Journal on gNB Common Unit
    # and all Capacity Units
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop journal log collector on Common unit and all Capacity Units
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} journal stopped and collected successfully    console=${P_console}
    # over all capcity units (including loner)
    ${capu_num}=    Get length        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    FOR    ${capu}    IN RANGE    ${capu_num}
        Stop Journal on gNB Capacity Unit    gnb_id=${gnb_id}   du_id=${du_id}     comu_id=${comu_id}     capu_id=${capu}
        ...    target_dir=${target_dir}
    END

Start Journal on gNB Capacity Unit
    [Documentation]    :Author: Soenke Kullberg
    ...     Start journal log collector on Capacity Unit
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...     :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...
     [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${capu_id}=${0}
    &{comu_config}=   Create dictionary
    ...         host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...         user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...         password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    # fsp master
    ${fsp_master_ip}=    testline.Get Capacity Slave IP   gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}   capu_id=${capu_id}     slave=a
    &{capu_config}=   Create dictionary
    ...         host=${fsp_master_ip}
    ...         user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}       # same as comu
    ...         password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}   # same as comu
    ...         proxy=${comu_config}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=a
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${capu_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} Capacity_Unit${capu_id} master journal started successfully    console=${P_console}
    # fsp slave
    ${fsp_slave_ip}=    testline.Get Capacity Slave IP   gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}   capu_id=${capu_id}     slave=b
    &{fsp_b_config}=    Create dictionary
    ...    host=${fsp_slave_ip}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}       # same as comu
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}   # same as comu
    ...    proxy=${comu_config}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}  capu_id=${capu_id}      extra=b
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${fsp_b_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} Capacity_Unit${capu_id} slave journal started successfully    console=${P_console}
    # Loner
    ${loner_ip}=    testline.Get Capacity Slave IP   gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}   capu_id=${capu_id}     slave=loner
    &{loner_config}=    Create dictionary
    ...    host=${loner_ip}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}       # same as comu
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}   # same as comu
    ...    proxy=${comu_config}
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=loner
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${loner_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} Capacity_Unit${capu_id} loner journal started successfully    console=${P_console}


Stop Journal on gNB Capacity Unit
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop journal log collector on Capacity Unit
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${capu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    # fsp master
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=a
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} Capacity_Unit${capu_id} master journal stopped and collected successfully
    ...    console=${P_console}
    # fsp slave
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=b
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} Capacity_Unit${capu_id} slave journal stopped and collected successfully
    ...    console=${P_console}
    # Loner
    ${journal_name}=    Get Journal Name    gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=loner
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    gNB${gnb_id} DU${du_id} Common_Unit${comu_id} Capacity_Unit${capu_id} loner journal stopped and collected successfully
    ...    console=${P_console}


Start Journal on AP
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start journal logging on all DU over all Common Unit over all Capacity units/Loner
    ...
    ...    :param ue_id: (default=0) Id/Number of airphone
    ...
    [Arguments]    ${ue_id}=${0}
    ${comu_num}=    Get length        ${tl.ues[${ue_id}].l1.common_units}
    FOR    ${comu}    IN RANGE    ${comu_num}
        Start Journal on AP Common Unit    ue_id=${ue_id}    comu_id=${comu}
    END

Start Journal on AP Common Unit
    # and all Capacity Units
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Jornal log on Common Unit and all releated Capacity Units
    ...
    ...     :param ue_id:      Id of ue                        [0.. ]  default=0
    ...     :param comu_id:    Id of Common Unit               [0..1]  default=0
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    &{comu_config}=    Create dictionary
    ...    host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}
    journal.create_journal_collector
    ...     name=${journal_name}
    ...     options=-f -o short-precise
    ...     executor=${comu_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} journal started successfully    console=${P_console}
    ${capu_num}=    Get length        ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units}
    FOR    ${capu}    IN RANGE    ${capu_num}
           Start Journal on AP Capacity Unit    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu}
    END

Start Journal on AP Capacity Unit
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Start journal log collector on Capacity Unit
    ...
    ...     :param ue_id:       Id of ue                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...     :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...
     [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${capu_id}=${0}
    &{comu_config}=   Create dictionary
    ...         host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...         user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...         password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    &{capu_config}=   Create dictionary
    ...         host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units[${capu_id}].addr}
    ...         user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}       # same as comu
    ...         password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}   # same as comu
    ...         proxy=${comu_config}
    # fsp master
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=a
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${capu_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} Capacity_Unit${capu_id} master journal started successfully    console=${P_console}
    # fsp slave
    ${fsp_slave_ip}=    Get AP Capacity Slave IP   ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    slave=b
    &{fsp_b_config}=    Create dictionary
    ...    host=${fsp_slave_ip}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}       # same as comu
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}   # same as comu
    ...    proxy=${comu_config}
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=b
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${fsp_b_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} Capacity_Unit${capu_id} slave journal started successfully    console=${P_console}
    # Phoner
    ${loner_ip}=    Get AP Capacity Slave IP   ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    slave=phoner
    &{loner_config}=    Create dictionary
    ...    host=${loner_ip}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}       # same as comu
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}   # same as comu
    ...    proxy=${comu_config}
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=loner
    journal.create_journal_collector
    ...    name=${journal_name}
    ...    options=-f -o short-precise
    ...    executor=${loner_config}
    journal.setup_collectors    names=${journal_name}
    journal.start_collectors    names=${journal_name}
    journal.set_suite_alias     ${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} Capacity_Unit${capu_id} phoner journal started successfully    console=${P_console}


Stop Journal on AP
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop journal logging and download logs from all Common Units over all Capacity units/Loner
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param target_dir: Directory to store the journal file
    ...
    [Arguments]    ${ue_id}=${0}    ${target_dir}=None
    ${comu_num}=    Get length        ${tl.ues[${ue_id}].l1.common_units}
    FOR    ${comu}    IN RANGE    ${comu_num}
        Stop Journal on AP Common Unit    ue_id=${ue_id}    comu_id=${comu}    target_dir=${target_dir}
    END

Stop Journal on AP Common Unit
    # and all Capacity Units
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop journal log collector on Common unit and all Capacity Units
    ...
    ...    :param ue_id:       Id of ue                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param target_dir:  Directory to store the journal file
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} journal stopped and collected successfully    console=${P_console}
    # over all capcity units (including phoner)
    ${capu_num}=    Get length        ${tl.ues[${ue_id}].l1.common_units[${comu_id}].capacity_units}
    FOR    ${capu}    IN RANGE    ${capu_num}
        Stop Journal on AP Capacity Unit    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu}
        ...    target_dir=${target_dir}
    END

Stop Journal on AP Capacity Unit
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop journal log collector on Capacity Unit
    ...
    ...    :param ue_id:       Id of ue                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...    :param target_dir:  Directory to store the journal file
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${capu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    # fsp master
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=a
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} Capacity_Unit${capu_id} master journal stopped and collected successfully
    ...    console=${P_console}
    # fsp slave
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=b
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} Capacity_Unit${capu_id} slave journal stopped and collected successfully
    ...    console=${P_console}
    # Phoner
    ${journal_name}=    Get Journal Name    ue_id=${ue_id}    comu_id=${comu_id}    capu_id=${capu_id}    extra=loner
    journal.stop_collectors         names=${journal_name}
    journal.collect_collectors      names=${journal_name}   target_dir=${target_dir}
    journal.teardown_collectors     names=${journal_name}
    BuiltIn.Log    UE${ue_id} Common_Unit${comu_id} Capacity_Unit${capu_id} phoner journal stopped and collected successfully
    ...    console=${P_console}



#### PRIVATE ####

Get Journal Name
    [Documentation]     [Private]
    ...     :Author: Soenke Kullberg
    ...     generate journal name based on arguments
    [Arguments]          ${gnb_id}=${EMPTY}  ${ue_id}=${EMPTY}  ${du_id}=${EMPTY}  ${comu_id}=${EMPTY}  ${capu_id}=${EMPTY}    ${extra}=${EMPTY}
    ${journal_name}=    Set Variable If
    ...    '${gnb_id}'!='${EMPTY}'    gnb-${gnb_id}
    ...    '${ue_id}'!='${EMPTY}'    ue-${ue_id}
    ${journal_name}=    Set Variable If     '${du_id}'!='${EMPTY}'     ${journal_name}-du-${du_id}        ${journal_name}
    ${journal_name}=    Set Variable If     '${comu_id}'!='${EMPTY}'   ${journal_name}-comu-${comu_id}    ${journal_name}
    ${journal_name}=    Set Variable If     '${capu_id}'!='${EMPTY}'   ${journal_name}-capu-${capu_id}    ${journal_name}
    ${journal_name}=    Set Variable If     '${extra}'!='${EMPTY}'  ${journal_name}-${extra}        ${journal_name}
    ${journal_name}=    Set Variable    ${journal_name}-journal
    [Return]    ${journal_name}
