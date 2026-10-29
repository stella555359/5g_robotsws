*** Settings ***

Documentation     Keywords related to gNB handling
...               author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com
...                 TODO: 'Check VMs status' implement for coam
...                 TODO: 'Check RAP status' implement for coam

Library    Collections
Library    String
Library    OperatingSystem
Library    ta_attenuator
Library    taf.sbts.oam.coam.admin           WITH NAME   admin
Library    taf.transport.ssh                WITH NAME   ssh
Library    taf.config.scf                   WITH NAME   scf
Library    taf.rfrl.common_resources.python.SWConfig      WITH NAME   swconf
Library    ../python/Gnb.py                  WITH NAME   gnb_internal
Resource   Connect.robot
Resource   Testline.robot

*** Variables ***
${P_console}              ${False}    # output to console can be enabled via "Set Console Output" from testline.robot
${P_ORIG_GNB_SWCONFIG}    None
@{P_INTERNAL_CELL_DIST_ID}

*** Keywords ***

Set attenuation on gNB cell
    [Documentation]    :Author: Vasileios Papoutsis, [DEPRECATED]
    ...    [WARNING] for JFW blocks mode only works with ta_attenuator >= 2.8.0
    ...    To be re-implemented after having taf implementation
    ...
    ...    :param attenuator_config: config file path, example config:
    ...    https://wrgitlab.int.net.nokia.com/abstract_library/ta_attenuator/blob/master/ta_attenuator/example/config/attenuators_config.yml
    ...    :param attenuation_value: (default 30dB)  value to set in dB or %. It is string like 20dB or 10%
    ...    :param attenuator: (default GNB_1_CELL_1) attenuator alias name which configured in config file
    ...
    [Arguments]    ${attenuator_config}    ${attenuation_value}=30dB    ${attenuator}=GNB_1_CELL_1
    BuiltIn.Log    Keyword is deprecated. New keywords can be found in testline.robot    console=${True}
    ta_attenuator.load_attenuation_config    ${attenuator_config}
    ta_attenuator.require_attenuator_setup_of    ${attenuator}
    ${returnValue}=    ta_attenuator.read_attenuation    ${attenuator}
    ta_attenuator.set_attenuation    ${attenuator}    ${attenuation_value}
    ${returnValue}=    ta_attenuator.read_attenuation    ${attenuator}
    Should Contain    ${attenuation_value}    ${returnValue}


Wait until all gNBs to be onair state
    [Documentation]     :Author: Soenke Kullberg
    ...     Wait for all gNBs to be onAir
    ...     onAir state is checked via OAM
    ...
    ...     :Note: works with COAM and MZOAM
    ...
    ...     :param timeout: (default 500 seconds) Time until all gNBs must be up
    ...
    [Arguments]    ${timeout}=600 sec
    ${gnb_num}=    Get length    ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
           Wait until gNB to be onair state  gnb_id=${gnb_id}  timeout=${timeout}
    END


Wait until gNB to be onair state
    [Documentation]     :Author: Vasileios Papoutsis
    ...     wait for gNB to be onAir, checked via oam interface
    ...     :Note: works with COAM and Cloud COAM (DU)
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param timeout: (default=10 minutes) time till gNB must be on air
    ...
    [Arguments]    ${gnb_id}=${0}   ${du_id}=${0}  ${timeout}=600 sec
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    Run keyword if    '${oam_type}'=='cloud_coam'   Wait Cell onAir with Cloud COAM       gnb_id=${gnb_id}   timeout=${timeout}  du_id=${du_id}
    ...    ELSE IF    '${oam_type}'=='coam'         Wait Cell onAir with COAM       gnb_id=${gnb_id}   timeout=${timeout}
    ...    ELSE    Fail    Unknown OAM type ${oamType}
    BuiltIn.Log    gNB${gnb_id} is on air    console=${P_console}


Wait until all gNBs have first X2 Link Status Available
    [Documentation]     :Author: Michele
    ...     Wait for all gNBs to have Available X2 Link Status
    ...     onAir state is checked via OAM
    ...     :param timeout: (default 500 seconds) Time until all gNBs must have Available X2 Link Status
    ...
    [Arguments]    ${timeout}=600 sec
    ${gnb_num}=    Get length    ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
           Wait until X2 Link Status is Available    gnb_id=${gnb_id}  timeout=${timeout}    lteEnbId_Idx=${0}
    END


Wait until X2 Link Status is Available
    [Documentation]     :Author: Michele
    ...     wait for gNB to have Available X2 Link Status
    ...     :Note: works with classical GNB. And will adapt for Cloud CU
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param timeout: (default=10 minutes) time till gNB must have Available X2 Link Status
    ...
    [Arguments]    ${gnb_id}=${0}    ${timeout}=600 sec    ${lteEnbId_Idx}=${0}
    Wait until keyword succeeds     ${timeout}      20 sec
    ...     Check gNB X2 Link Status is Available    gnb_id=${gnb_id}    lteEnbId_Idx=${lteEnbId_Idx}
    BuiltIn.Log    gNB${gnb_id} have Available X2 Link Status    console=${P_console}


Reset all gNBs and wait for availability
    [Documentation]    :Author: Vasileios Papoutsis
    ...    :param timeout: (default 600 seconds)
    [Arguments]    ${timeout}=600 sec
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Reset gNB via OAM and wait for availability    gnb_id=${gnb_id}   timeout=${timeout}
    END


Reset gNB via OAM and wait for availability
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Reset gNB via oam interface and check RAP, DUs, FRM to be up
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param timeout: (default=10 minutes) time till gNB must up agin
    ...
    [Arguments]    ${gnb_id}=${0}
    Perform gNB reboot     gnb_id=${gnb_id}
    Check RAP status           gnb_id=${gnb_id}
    Wait until all DUs up      gnb_id=${gnb_id}
    Check FRMs status          gnb_id=${gnb_id}


Wait until all DUs up
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Waits till all DU of a gNB are up
    ...     (timeout is hardcoded to 10 minutes)
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param timeout:     Time until DUs have to be up  default=10 minutes
    ...
    [Arguments]    ${gnb_id}=0  ${timeout}=10 min
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du}    IN RANGE    ${du_num}
        Wait until DU ready    gnb_id=${gnb_id}    du_id=${du}     timeout=${timeout}
    END


Wait until DU ready
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Waits till all Common and Capacity Unit of a DU are up
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param du_id: (default=0) Id/Number of DU
    ...     :param timeout:     Time until Common+CapacityUnit have to be up  default=10 minutes
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${timeout}=10 min
    BuiltIn.Log    Wait until gNB${gnb_id} DU${du_id} is ready    console=${P_console}
    ${common_units}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu}    IN RANGE    ${common_units}
       Wait for gNB Common and Capacity unit up    gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu}   timeout=${timeout}
    END
    BuiltIn.Log    gNB${gnb_id} DU${du_id} is ready!    console=${P_console}


Wait for gNB Common and Capacity unit up
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...     :param timeout:     Time until Common+CapacityUnit have to be up  default=10 minutes
    [Arguments]    ${gnb_id}=0    ${du_id}=0  ${comu_id}=0  ${timeout}=10 min
    ${capu_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    ${comu_ssh_alias}=  Wait until keyword succeeds     ${timeout}  10 sec
    ...     Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}
    ${CCS_Daemon_node_id}=    gnb_internal.get_CCS_Daemon_node_id    connection=${comu_ssh_alias}
    @{boards_ids}=    Run keyword if    '${CCS_Daemon_node_id}'=='0x1011'
    ...    Create List    0x10    0x12    0x13    0x14
    ...    ELSE IF    '${CCS_Daemon_node_id}'=='0x2011'
    ...    Create List    0x20    0x22    0x23    0x24
    ...    ELSE    Fail    Wrong node id ${CCS_Daemon_node_id}!
    ${board_type}=    Identify Common Unit Type    gnb_id=${gnb_id}  du_id=${du_id}  common_unit_id=${comu_id}
    ${end_index}=    Set Variable If    'ASO' in '${board_type}'    1    ${${capu_num} + 1}
    @{existing_boards_ids}=    Get slice from list    ${boards_ids}    start=${0}    end=${end_index}
    FOR    ${board_id}    IN    @{existing_boards_ids}
        Wait until keyword succeeds     ${timeout}    20 sec    Check Airscale Board Status
        ...     alias=${comu_ssh_alias}   board_id=${board_id}   CCS_Daemon_node_id=${CCS_Daemon_node_id}
    END


Wait For Minimum Required State For Cell Setup
    [Documentation]    :Author: Torsten Dieckmann
    ...     Waits until all pre-conditions for cell setup on first cell are reached.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     :param cell_id:     Id of cell                      [0.. ]  default=0
    ...     :param ru_id:       Id of RU                        [0.. ]  default=0
    [Arguments]    ${cell_id}=0    ${ru_id}=0    ${timeout}=3min
    BuiltIn.Log    Waiting for gNB to be ready... (15min timeout)    console=${P_console}
    ${oam_alias}=    connect.Setup OAM session
    Wait Until Keyword Succeeds    ${timeout}    20sec    Verify Single BTS is Configured    connection=${oam_alias}
    Wait Until Keyword Succeeds    ${timeout}    20sec    Verify Single Radio is Online      connection=${oam_alias}   ru_id=${ru_id}
    Wait Until Keyword Succeeds    ${timeout}    20sec    Verify Single Cell is Configured   connection=${oam_alias}   cell_id=${cell_id}
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    Teardown OAM session    connection=${oam_alias}


Verify Single BTS is Configured
    [Documentation]    :Author: Torsten Dieckmann
    ...     Checks if gNB is Configured.
    ...     :param connection:    connection alias
    [Arguments]    ${connection}={}
    ${bts_state}                  admin.Get Mrbts State     connection=${connection}
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}    console=${P_console}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    onAir    Test     ignore_case=${TRUE}


Verify Single Radio is Online
    [Documentation]    :Author: Torsten Dieckmann
    ...     Checks if a given RU/rmod is Online.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     :param connection:    connection alias
    ...     :param ru_id:         Id of RU                        [0.. ]  default=0
    [Arguments]    ${connection}={}     ${ru_id}=0
    ${bts_hw_info}                admin.Get Bts Info    connection=${connection}
#    #${radio_state}                Set Variable
#    ...                           ${bts_hw_info['radioModules']['rmod'][${ru_id}]['status']['operationalState'}]
#    BuiltIn.Log                   [INFO] RADIO STATE : ${radio_state}    console=${P_console}
#    Should Be Equal As Strings    ${radio_state}   enabled    ignore_case=${TRUE}
    ${cell_status} =    Set variable  ${bts_hw_info['radioModules']['rmod'][${ru_id}]['status']}
    Should be equal    ${cell_status['operationalState']}         enabled         ignore_case=true
    Should be equal    ${cell_status['proceduralStatus']}         configured      ignore_case=true



Verify Single Cell is Configured
    [Documentation]    :Author: Torsten Dieckmann
    ...     Checks if a given cell is configured.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     :param connection:    connection alias
    ...     :param cell_id:       Id of cell                        [0.. ]  default=0
    [Arguments]    ${connection}={}     ${cell_id}=0
    ${cells_info}                 admin.Get Cells Info    connection=${connection}
    ${procedural_status}          Set Variable    ${cells_info[${cell_id}]['status']['proceduralStatus']}
    BuiltIn.Log                   [INFO] CELL STATE : ${procedural_status}    console=${P_console}
    Should Contain Any            ${procedural_status}    Configured    onAir    ignore_case=${TRUE}


Check RAP status
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}=${0}
    BuiltIn.Log    Check gNB${gnb_id} RAP status    console=${P_console}
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    Return From Keyword If   '${oam_type}'=='coam'   message=Rap check not implemented with coam
    # check Rap with megazone removed
    BuiltIn.Log    check Rap with megazone removed    console=${P_console}


Check FRMs status
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]     ${gnb_id}=${0}    ${timeout}=${60}    ${target_status}=Online
    BuiltIn.Log    Wait until gNB${gnb_id} FRMs are ${target_status}    console=${P_console}
    ${oam_type}=    testline.Get OAM type    gnb_id=${gnb_id}
    Run keyword if    '${oam_type}'=='coam'    Check FRMs status with COAM
    ...    gnb_id=${gnb_id}    target_status=${target_status}   timeout=${timeout}
    ...    ELSE    Fail    Unknown OAM type ${oam_type}
    BuiltIn.Log    gNB${gnb_id} FRMs are ${target_status}!    console=${P_console}


Perform gNB reboot
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Reboot gNB via oam interface
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param timeout: (default 600 seconds)
    ...
    [Arguments]     ${gnb_id}=${0}    ${timeout}=600
    BuiltIn.Log    Reboot of gNB${gnb_id} triggered    console=${P_console}
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    Run keyword if    '${oam_type}'=='cloud_coam' or '${oam_type}'=='coam'
    ...    Reboot gNB with cOAM         gnb_id=${gnb_id}    timeout=${timeout}
    ...    ELSE    Fail    Unknown OAM type ${oamType}
    BuiltIn.Log    Reboot of gNB${gnb_id} finished!    console=${P_console}


Perform gNB reset unit
    [Documentation]    :Author: Noli Valdez III
    ...     :param dist_name:
    ...            Dist name of unit to reset which is runtime view dist name
    ...                ie. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param reset_type: can be Soft, Hard or Warm, defaults to Soft
    ...     :param timeout: Timeout for the operation.
    ...     :param detailed_output: return full request response when True, defaults set to False.
    ...
    ...     See TAF documentation: https://docs.taf.nsn-rdnet.net/taf.sbts.oam.coam.admin/#taf.sbts.oam.coam.admin.interface.admin.reset_unit
    ...
    [Arguments]    ${dist_name}    ${gnb_id}=${0}    ${reset_type}=Soft    ${timeout}=600
    ...            ${detailed_output}=False    &{kwargs}
    ${oam_alias}=       connect.Setup OAM session   gnb_id=${gnb_id}
    BuiltIn.Log    Reboot of ${dist_name} Starting!    console=${P_console}
    admin.reset_unit    dist_name=${dist_name}    reset_type=${reset_type}
    ...                 timeout=${timeout}    &{kwargs}
    ...                 detailed_output=${detailed_output}    connection=${oam_alias}
    BuiltIn.Log    Reboot of ${dist_name} finished!    console=${P_console}
    [Teardown]  admin.teardown    connection=${oam_alias}


Store Current SCF from gNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param target_dir:     (default None) save swconfig to path
    ...
    ...    :return:   scf path for further usage
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None
    ${ORIG_SCF}=    gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${target_dir}
    Run    mv ${ORIG_SCF} ${ORIG_SCF}.orig
    Set Suite Variable    ${P_ORIG_SCF}    ${ORIG_SCF}.orig
    [Return]    ${P_ORIG_SCF}


Get SCF from gNB
    [Documentation]    :Author: Nikolay Shkulepov
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param target_dir: (default None) save SCF to path
    ...     :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...     :return:   scf path for further usage
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None  ${component}=DU
    ${oamType}=    testline.Get OAM Type     gnb_id=${gnb_id}
    ${gnbScfName}=    Set variable    SCFC_gNB${gnb_id}_${component}.xml
    Set Suite Variable    ${private_gnbScfName${gnb_id}}    ${gnbScfName}
    ${resultConfigDir}=    Run Keyword If    '${target_dir}'=='None'    Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    Run keyword if    '${oamType}'=='cloud_coam'    Get SCF from gNB with cloud cOAM  component=${component}
    ...                             gnbScfName=${gnbScfName}    resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}
    ...    ELSE IF    '${oamType}'=='coam'        Get SCF from gNB with cOAM
    ...                             gnbScfName=${gnbScfName}    resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}
    ...    ELSE    Fail    Unknown OAM Type ${oamType}
    [Return]    ${resultConfigDir}/${gnbScfName}


Store Current swconfig from gNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param target_dir:     (default None) save swconfig to path
    ...
    [Arguments]    ${gnb_id}=${0}    ${target_dir}=None
    ${ORIG_SWCONFIG}=    gnb.Get swconfig from gNB    gnb_id=${gnb_id}    target_dir=${target_dir}
    Run    mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_GNB_SWCONFIG}    ${ORIG_SWCONFIG}.orig


Get swconfig from gNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:     (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${asik_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.Download File    remote_path=/ffs/run/swconfig.txt    local_path=${target_dir}/gnb-${gnb_id}_swconfig.txt    connection=${asik_alias}
    [Return]    ${target_dir}/gnb-${gnb_id}_swconfig.txt


Get gNB SCF Name
    [Documentation]    :Author: Nikolay Shkulepov
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    ...     :return: gNB scf name
    ...
    [Arguments]     ${gnb_id}=${0}
    [Return]    ${private_gnbScfName${gnb_id}}


Reload stored swconfig to gNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...    used for Suite Teardown or Testcase Teardown
    ...    bring back Keyword "Collect swconfig from gNB" collected swconfig.txt file
    ...
    ...    **Example:**
    ...    | gnb.Store Current swconfig from gNB
    ...    | gnb.Reload stored swconfig to gNB
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}
    ${comu_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.Upload File    local_path=${P_ORIG_GNB_SWCONFIG}    remote_path=/ffs/run/swconfig.txt    connection=${comu_alias}


Set SW Config on Common Module
    [Documentation]    :Author: Srihari Janardhan  | This keyword sets the rnd params in the common module
    ...
    ...     :param rad_param:   rad param to set
    ...     :param rad_param_value:     value for rad param
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...
    [Arguments]  ${rad_param}  ${rad_param_value}  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${comu_alias}=   Connect to gNB Common Unit  gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu_id}
    ssh.Send Command
    ...    command=telnet 0 15007  connection=${comu_alias}
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=${comu_alias}
    ssh.Write Input
    ...    data=rad -mw ${rad_param} ${rad_param_value}\r
    ...    connection=${comu_alias}
    ssh.Write Input
    ...    data=quit\r
    ...    connection=${comu_alias}
    ssh.Read Output Until
    ...    match=Bye ...
    ...    timeout=3
    ...    connection=${comu_alias}


Check L1 bypass
    [Documentation]    :Author: Valentin Hirzel valentin.hirzel@nokia.com
    ...    :parm    gnb_id    Id of gnb            [0...]
    ...    :parm    du_id     Id of DU             [0...]
    ...    :parm    comu_id   Id of Common unit    [0..1]
    ...    :return:    Retruns either true or False:
    ...                True: Layer 1 Bypass is enabled
    ...                Flase: Layer 1 Bypass is not enabled
    ...    check done is described on Confluence:
    ...    https://confluence.ext.net.nokia.com/display/AirPhoneWTS/5G20B_eCPRI_L1By_NSA_TDD_cmW_Integration_Procedure_ASIK_ABIL
    ...    #id-5G20B_eCPRI_L1By_NSA_TDD_cmW_Integration_Procedure_ASIK_ABIL-EnablingL1Bypasstestmode
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}     ${comu_id}=${0}

    ${comu_alias}=   Connect to gNB Common Unit  gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu_id}
    ssh.Send Command
    ...    command=telnet 0 15007  connection=${comu_alias}
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=${comu_alias}
    ssh.Write Input
    ...    data=tag -a\r
    ...    connection=${comu_alias}
    ${output}=  ssh.Read Output Until
    ...    match=ccs.service.aapostmortem.backup.timeout
    ...    timeout=3
    ...    connection=${comu_alias}
    ssh.Write Input
    ...    data=quit\r
    ...    connection=${comu_alias}
    ${matches}=  string.Get Lines Matching Pattern  ${output}  app.btsom.nts.L1BypassMap*  #, (14)[ 30783132 35443A30 78353234 4100 | 0x125D:0x524A.]
    ${L1bp_enabled}=    Set Variable if  '${matches}' != ''  True   False
    [Return]  ${L1bp_enabled}


Get AaShell SW Config
    [Documentation]    :Author: Michele | This keyword Prints all non default R&D parameters of RadMaster.
    ...
    ...     :param rad_param    Rad Parameter                   [0x580017]  default=Empty
    ...     :param gnb_id:      Id of gnb                       [0.. ]      default=0
    ...     :param du_id:       Id of DU                        [0.. ]      default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]      default=0
    ...
    ...    :return:
    ...           IF rad_param is empty:
    ...                      Prints all non default R&D parameters of RadMaster.
    ...           ELSE  The "Current val" of rad_param. e.g.: [u'0x0']
    [Arguments]  ${rad_param}=${EMPTY}  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${comu_alias}=   Connect to gNB Common Unit  gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu_id}
    ssh.Send Command
    ...    command=telnet 0 15007  connection=${comu_alias}
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=${comu_alias}
    ssh.Write Input
    ...    data=rad -mu \r
    ...    connection=${comu_alias}
    ${nonDefaultRadMaster}=     ssh.Read Output Until
                                ...    match=AaShell>${SPACE}
                                ...    timeout=3
                                ...    connection=${comu_alias}
    ssh.Write Input
    ...    data=quit\r
    ...    connection=${comu_alias}
    ssh.Read Output Until
    ...    match=Bye ...
    ...    timeout=3
    ...    connection=${comu_alias}
    ${radMasterValue}=    Run Keyword If     '${rad_param}'=='${EMPTY}'
    ...    set variable    ${nonDefaultRadMaster}
    ...   ELSE
    ...    Get regexp matches    ${nonDefaultRadMaster}       \\[${rad_param}\\] Default val = .*; Current val = (.*)  1
    [Return]    ${radMasterValue}

Update SW Config file on System Module
    [Documentation]    :Author: Jing Liang
    ...     This keyword sets the rnd params in the swconfig.txt
    ...     :param param_list:      list the update content, example input can be: ["0x4600BA=6","0x460002=6"]
    ...     :param del_param_list:  list the delete content, example input can be: ["0x4600BA","0x460002"]
    ...     :param gnb_id:          Id of gnb                       [0.. ]  default=0
    ...     :param du_id:           Id of DU                        [0.. ]  default=0
    ...     :param comu_id:         Id of Common Unit               [0..1]  default=0
    ...
    [Arguments]  ${param_list}=@{EMPTY}  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${del_param_list}=@{EMPTY}
    ${comu_alias}=   Connect to gNB Common Unit  gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu_id}
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=/tmp/swconfig_tmp.txt    asik_alias=${comu_alias}
    Run Keyword if    ${del_param_list} != @{EMPTY}    swconf.delete_parameter_of_swConfig_file    parametersList=${del_param_list}
    ...    filePath=/tmp/swconfig_tmp.txt
    Run Keyword if    ${param_list} != @{EMPTY}    swconf.modify_swConfig_file    parametersList=${param_list}
    ...    filePath=/tmp/swconfig_tmp.txt
    swconf.upload_swConfig_file_to_asik_and_crasign    localFilePath=/tmp/swconfig_tmp.txt    asik_alias=${comu_alias}

Get gNB Common Unit Port Status
    [Documentation]    :Author: Jing Liang
    ...    :param port: port on ASXX
    ...    :param gnb_id: default 0
    ...    :param du_id: default 0
    ...    :param comu_id: default 0
    ...
    ...    :return: True if port is up, False if port is down
    [Arguments]    ${port}    ${gnb_id}=0    ${du_id}=0    ${comu_id}=0
    ${tmp_alias}=    Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${port_status}=    ssh.execute    dbgrrc show port ${port}    connection=${tmp_alias}
    ${status}=    Run Keyword And Return Status    Should Contain X Times    ${port_status}    up    2
    [Return]    ${status}


Get distNames from gNB SCF
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${regex}    ${gnb_id}=${0}
    ${oam_alias}=    connect.Setup OAM session    gnb_id=${gnb_id}
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    ${scf_content}=  admin.get_scf  parameters_save_variant=actualValues   timeout=${10}    connection=${oam_alias}
    ${distNames}=    gnb_internal.get_distNames_from_scf    regex=${regex}    scf_content=${scf_content}
    connect.Teardown OAM session    connection=${oam_alias}    gnb_id=${gnb_id}
    [Return]    ${distNames}


Enable clock in all gNBs
    [Documentation]    :Author: Vasileios Papoutsis
    ...    It enables airscale clock to synchronize with Viavi
    ...    Viavi only
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Enable gNB clock in all DUs    gnb_id=${gnb_id}
    END


Enable gNB clock in all DUs
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Viavi only
    [Arguments]    ${gnb_id}=${0}
    ${du_num}=     Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Enable airscale clock    gnb_id=${gnb_id}    du_id=${du_id}
    END


Enable airscale clock
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Viavi only
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}
    ${common_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu_id}    IN RANGE    ${common_units_num}
        connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    alias=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ${output}=    ssh.execute    command=cat /sys/class/clk/clk-fpga/single1-out/clk_io_signal_10m_internal
        ...    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ${status}=    Run keyword and return status    Should contain    ${output}    0x0
        Run keyword if    ${status}    ssh.send_command
        ...    command=echo 0x1 > /sys/class/clk/clk-fpga/single1-out/clk_io_signal_10m_internal
        ...    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ssh.disconnect    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        BuiltIn.Log    gNB${gnb_id} DU${du_id} Comu${comu_id} clock is enabled!    console=${P_console}
    END


Get gNB Physical Cell ID
    [Documentation]    :Author: Srihari Janardhan  | This keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective physical cell id as the value.
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of du                        [0.. ]  default=0
#    [Arguments]     ${gnb_id}=0     ${du_id}=${0}
    ${_test_log_dir}=  Get test suite log directory
    ${distName_params}=  Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${scf_file}=  Get SCF from gNB  target_dir=${_test_log_dir}
    ${_cell_phy_cell_id}=  gnb_internal.get_phy_cell_ids  scf_path=${scf_file}  distnames=${distName_params}
    [Return]  ${_cell_phy_cell_id}
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Check FRMs status with COAM
    [Documentation]     [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${target_status}    ${timeout}
    ${oam_alias}=       connect.Setup OAM session   gnb_id=${gnb_id}
    ${num_of_frms_dict}=    gnb_internal.get_num_of_frms_per_gnb
    ${gnb_str}=    Convert to string    ${gnb_id}
    ${num_of_frms_str}=    Get from dictionary    ${num_of_frms_dict}    ${gnb_str}
    ${num_of_frms}=    Convert to integer    ${num_of_frms_str}
    Wait until keyword succeeds    ${timeout}    5 sec    Compare online with available FRMs with COAM
    ...    ${num_of_frms}    ${oam_alias}    ${target_status}
    [Teardown]  admin.teardown    connection=${oam_alias}


Compare online with available FRMs with COAM
    [Documentation]     [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]    ${num_of_frms}    ${oam_alias}    ${target_status}
    ${frms}=    admin.get_frm    timeout=${60}    connection=${oam_alias}
    ${num_of_frms_in_gnb}=    Get length    ${frms}
    # do we have same amount of FRMS
    Run keyword if    '${num_of_frms_in_gnb}'!='${num_of_frms}'    Fail
    # check status for each
    FOR    ${frm}    IN RANGE    ${num_of_frms_in_gnb}
       Run Keyword If     '${frms[${frm}]['status']['availabilityStatus']}'!='${target_status}'   Fail
       ...     msg=FRM in status ${frms[${frm}]['status']['availabilityStatus']} (Should be: ${target_status})
    END


Reboot gNB with COAM
    [Documentation]     [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}=0    ${timeout}=600
    ${oam_alias}=       connect.Setup OAM session   gnb_id=${gnb_id}
    admin.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${oam_alias}
    ${rc}=    Run and return rc    ping ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr} -w 10
    Should be equal as numbers    first=${0}    second=${rc}
    [Teardown]  admin.teardown    connection=${oam_alias}



Wait Cell onAir with COAM
    [Documentation]     [PRIVATE]
    ...     :Author: Soenke Kullberg
    [Arguments]     ${gnb_id}=0     ${timeout}=600 sec
    ${oam_alias}=      connect.Setup OAM session   gnb_id=${gnb_id}
    ${scf_content}=    admin.get_scf  parameters_save_variant=actualValues   connection=${oam_alias}    timeout=${30}
    ${list_cells}=     string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}=   collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait until keyword succeeds     ${timeout}      20 sec
    ...     Verify that cells are onair with COAM    oam_alias=${oam_alias}    num_of_cells=${num_of_cells}
    [Teardown]  admin.teardown    connection=${oam_alias}


Verify that cells are onair with COAM
    [Documentation]     [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]     ${oam_alias}    ${num_of_cells}
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        ${_internal_cell_dist_id}=  Verify cell setup with COAM    alias=${oam_alias}    cell_id=${cell_id}
        Append to list  ${P_INTERNAL_CELL_DIST_ID}     ${_internal_cell_dist_id}
    END


Verify cell setup with COAM
    [Documentation]     :Author: Vasileios Papoutsis, [PRIVATE]
    ...     Verify Specific Cell status and BTS Cell setup status
    ...
    ...     cell_id:   Id of cell,
    ...     alias:     AdminConnection object or if used, string name alias
    ...     timeout:   Time to wait for positive procedure result
    ...
    [Arguments]        ${alias}=OAM    ${cell_id}=0   ${timeout}=30
    ${cell_status}=    admin.get_cells_info    cell_type=nr     timeout=${timeout}    connection=${alias}
    ${P_internal_cell_dist_id}=  Set Variable   ${cell_status[${cell_id}]['id']['internal']}
    ${cell_status}=    Set variable  ${cell_status[${cell_id}]['status']}
    Should be equal    ${cell_status['operationalState']}         Enabled         ignore_case=true
    Should be equal    ${cell_status['proceduralStatus']}         configured      ignore_case=true
    Should be equal    ${cell_status['blockingState']}            Unblocked       ignore_case=true
    Should Contain Any    ${cell_status['availabilityStatus']}    Degraded    Online    ignore_case=true
    Should be equal    ${cell_status['administrativeState']}      Unlocked        ignore_case=true
    ${bts_status}=     admin.get_bts_statuses    timeout=${timeout}    connection=${alias}
    Should be equal    ${bts_status['operationalState']}          Enabled         ignore_case=true
    Should be equal    ${bts_status['proceduralState']}           OnAir           ignore_case=true
    Should be equal    ${bts_status['blockingState']}             Unblocked       ignore_case=true
    [Return]  ${P_internal_cell_dist_id}


Get SCF from gNB with cOAM
    [Documentation]    :Author: Nikolay Shkulepov, [PRIVATE]
    [Arguments]     ${gnbScfName}    ${resultConfigDir}     ${gnb_id}=${0}
    ${oam_alias}=   connect.Setup OAM session   gnb_id=${gnb_id}
    admin.get_current_scf_file    ${resultConfigDir}    ${gnbScfName}    timeout=${120}    connection=${oam_alias}
    [Teardown]  admin.teardown    connection=${oam_alias}


Get gNB VM list
    [Documentation]     [PRIVATE]
    ...     :Author: Soenke Kullberg
    ...     Return list of vm in gNB
    ...     At the moment this is static, but may later a dynamic list is possible
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
#    [Arguments]     ${gnb_id}=${0}
    @{vmList}   Create list    cpcl    cpif    cpnb    cpue    upue     cpnrt
    [Return]    @{vmList}


Check Airscale Board Status
    [Documentation]    [PRIVATE]
    ...     :Author: Soenke Kullberg
    ...
    ...     :param alias:               ssh connnection alias to common unit board
    ...     :param board_id:            Board ID
    ...     :param CCS_Daemon_node_id:  CC&S Node Id
    [Arguments]     ${alias}  ${board_id}    ${CCS_Daemon_node_id}
    ssh.Force Reconnect    ${alias}
    ${sys_result}=  ssh.execute
    ...     command=PYTHONPATH=/opt/hwmt/python python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 -n ${CCS_Daemon_node_id} | grep ${board_id}
    ...     connection=${alias}
    ...     timeout=60 sec
    Should Contain  ${sys_result}   ready[0]


Verify on board SW Version
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    Check if GNB is updated to expected version
    [Arguments]    ${exp_version}    ${gnb_id}=0    ${du_id}=0    ${comu_id}=0
    ${asik_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${xml_element}=    Set Variable If    'SBTS' in '${exp_version}'    softwareReleaseVersionFlexiRel3    cbtsSoftwareReleaseVersion
    ${gnb_version}=    testline.Get Common Unit SW Version    alias=${asik_alias}    xml_element=${xml_element}
    Should Contain    ${gnb_version}    ${exp_version}    msg=SW update Failed!


Wait until F1 link up
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    wait for F1 up on GNB
    [Arguments]    ${timeout}=5min
    Wait Until Keyword Succeeds    ${timeout}    10 sec    Verify F1 Status


Verify F1 Status
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    check F1 link on GNB
    ${asik_alias}=    connect.Connect to gNB Common Unit
    ${common_unit_type}=     Identify Common Unit Type
    ${cpif_log}=    Run Keyword If    '${common_unit_type}'=='ASIB' or '${common_unit_type}'=='ASIL' or 'ASO' in '${common_unit_type}'
    ...    Verify F1 on ASIB ASIL ASOx  ${asik_alias}
    ...    ELSE IF     '${common_unit_type}'=='ASIK'
    ...    Verify F1 on ASIK  ${asik_alias}
    ...    ELSE     FAIL    Unsupported Controller board!
    ${files_exsit}=    Run Keyword and Return Status    Should not Contain    ${cpif_log}    No such file or directory
    ${cpif_log}=    Run Keyword If    ${files_exsit}    Set Variable    ${cpif_log}
    ...    ELSE    ssh.execute    echo "grep -i 'f1 setup successful' /tmp/node_CPRT00/tmp/startup_cp_rt.log" | bsh 0    connection=${asik_alias}
    Should Contain    ${cpif_log}    f1 setup successful    ignore_case=True


Verify F1 on ASIK
    [Documentation]    :Author: Guenter Goemer
    ...    [PRIVATE]
    [Arguments]  ${asik_alias}
    ${cpif_log}=  ssh.execute   echo "xz --force --stdout -d /tmp/node_CPRT00/tmp/startup_cp_rt.log.xz" | bsh 1 | grep -i 'f1 setup successful'
    ...   connection=${asik_alias}
    ${not_found_in_xz}=  Run Keyword and Return Status  Should not Contain    ${cpif_log}    f1 setup successful    ignore_case=True
    ${cpif_log}=  run keyword if  ${not_found_in_xz}
    ...  Verify F1 with log on ASIK  ${asik_alias}
    ...  ELSE   Set Variable    ${cpif_log}
    [Return]   ${cpif_log}


Verify F1 with log on ASIK
    [Documentation]    :Author: Guenter Goemer
    ...    [PRIVATE]
    [Arguments]  ${asik_alias}
    ${cpif_log}=  ssh.execute    echo "grep -i 'f1 setup successful' /tmp/node_CPRT00/tmp/startup_cp_rt.log" | bsh 1    connection=${asik_alias}
    [Return]   ${cpif_log}


Verify F1 on ASIB ASIL ASOx
    [Documentation]    :Author: Guenter Goemer
    ...    [PRIVATE]
    [Arguments]  ${asik_alias}
    ${cpif_log}=  ssh.execute  xz --force --stdout -d /tmp/node_CPRT00/tmp/startup_cp_rt.log.xz | grep -i 'f1 setup successful'
    ...  connection=${asik_alias}
    ${not_found_in_xz}=  Run Keyword and Return Status  Should not Contain    ${cpif_log}    f1 setup successful    ignore_case=True
    ${cpif_log}=  run keyword if  ${not_found_in_xz}
    ...  Verify F1 with log on ASIB ASIL ASOx  ${asik_alias}
    ...  ELSE  Set Variable    ${cpif_log}
    [Return]   ${cpif_log}


Verify F1 with log on ASIB ASIL ASOx
    [Documentation]    :Author: Guenter Goemer
    ...    [PRIVATE]
    [Arguments]  ${asik_alias}
    ${cpif_log}=  ssh.execute    grep -i 'f1 setup successful' /tmp/node_CPRT00/tmp/startup_cp_rt.log    connection=${asik_alias}
    [Return]   ${cpif_log}


Wait Cell onAir with Cloud COAM
    [Documentation]    :Author: Srihari Janardhan
    ...    [PRIVATE]    check if 5G cell is on air
    ...    Currently checks cell on air for 1 DU
    ...    Enhancement - create keyword to check cell on air for all DUs
    [Arguments]     ${gnb_id}=0     ${timeout}=600 sec  ${du_id}=${0}
    ${oam_alias}=       connect.Setup OAM session   gnb_id=${gnb_id}  du_id=${du_id}  component=DU
    ${scf_content}=   admin.get_scf  parameters_save_variant=actualValues   timeout=${30}    connection=${oam_alias}
    ${list_cells}=     string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}=   collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait until keyword succeeds     ${timeout}      20 sec
    ...     Verify that cells are onair with COAM    oam_alias=${oam_alias}    num_of_cells=${num_of_cells}
    [Teardown]  admin.teardown    connection=${oam_alias}


Get SCF from gNB with cloud cOAM
    [Documentation]    :Author: Srihari Janardhan
    ...    [PRIVATE]    Stores SCF of gNB Cloud COAM (DU) in desired directory
    [Arguments]  ${gnbScfName}    ${resultConfigDir}    ${gnb_id}  ${component}
    Run Keyword if   '${component}'=='DU'  Get SCF from gNB with cOAM  gnbScfName=${gnbScfName}
    ...  resultConfigDir=${resultConfigDir}    gnb_id=${gnb_id}


Check gNB X2 Link Status is Available
    [Documentation]    :Author: Michele
    ...    Only used by KW "Wait until X2 Link Status is Available"
    ...    Tested with classical gNB.
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=${0}    ${lteEnbId_Idx}=${0}
    ${oam_alias}    connect.Setup OAM session    gnb_id=${gnb_id}
    @{MOs_lteenb_a}    admin.get_managed_objects    class_name=LTEENB_A    connection=${oam_alias}
    @{MOs_lteenb_r}    admin.get_managed_objects    class_name=LTEENB_R    connection=${oam_alias}
    &{dict_x2LinkLock}     admin.get_parameters    dist_name=${MOs_lteenb_a[${lteEnbId_Idx}]['distName']}  pattern=x2LinkLock
    ...    connection=${oam_alias}
    &{dict_x2LinkStatus}    admin.get_parameters    dist_name=${MOs_lteenb_r[${lteEnbId_Idx}]['distName']}  pattern=x2LinkStatus
    ...    connection=${oam_alias}
    should be equal as strings    ${dict_x2LinkLock['x2LinkLock']}    unlocked    msg=x2LinkLock is Locked.    ignore_case=${True}
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    available    msg=x2LinkStatus is not Available.    ignore_case=${True}
    Collections.Dictionary Should Contain Item    ${dict_x2LinkStatus}     x2LinkStatus     available
    [Teardown]    admin.teardown    connection=${oam_alias}


Reboot gNB System Module via Console
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    soft reboot GNB
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ssh.execute    set -m ; ddal -s ddal_boot_set_reset_loop_count 0    connection=${alias}
    ssh.send command    system-module-reboot    connection=${alias}
