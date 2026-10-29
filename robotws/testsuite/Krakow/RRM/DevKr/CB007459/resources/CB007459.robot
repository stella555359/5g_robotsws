*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      == AUTHORS U-PLANE ==
...      - Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
...      - Maciej Majewski <maciej.majewski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     OperatingSystem
Library     ta_emss
Library     ta_messaging
Library     ta_egate_cmd_parser
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_commissioning
Library     ta5g_pm_counters
Library     CB007459_keywords.py
Library     ../../../resources/Python/suite_setup_managment.py
Library     ../../../resources/Python/utilities.py
Library     taf.ul.ue.sim.env_setup

Resource    ../../resources/ssh.robot
Resource    ../../resources/yaml_config_paths.robot
Resource    ../../../resources/Robot/common_keywords/gnb_ssh.robot

Variables   gnb_randd_parameters.py

*** Variables ***
${CP_UE_rdSktPlmnId}    0x522055  # PLMN=250:255
${CP_UE_rdSktPlmnId_ini}    5382229  # PLMN=250:255
${CP_UE_rdSktSpId}    17
${nonMatchingSpId}    34
${CP_UE_rdUlPowerControl}    True
${CP_UE_rdP0NominalPucch}    -52
${CP_UE_rdP0NominalPucchF1F3}    -60
${CP_UE_rdP0NominalPusch}    -88
${CP_UE_rdP0NominalSrs}    4
${CP_UE_rdAlpha_PCAP}    alpha04
${CP_UE_rdInitialPreambleReceivedTargetPower}    -120
${CP_UE_rdPMaxNROwnCell}    1
${CP_UE_rdActInactDetNSAUe}    True
${CP_UE_rdNsaInactTimer}    20
${CP_UE_rdNsaInactTimer_ProactULSched}    60
${CP_UE_rdActProactULScheduling}    True

${CP_RT_rdSktPlmnId}                             0x5900CA=${CP_UE_rdSktPlmnId} # rdSktPlmnId
${CP_RT_rdSktSpId}                               0x5900CB=${CP_UE_rdSktSpId} # rdSktSpId
${CP_RT_rdUlPowerControl}                        0x5900CC=1 # rdUlPowerControl
${CP_RT_rdP0NominalPucch}                        0x5900CD=150 # rdP0NominalPucch=-52
${CP_RT_rdP0NominalPucchF1F3}                    0x5900CE=142 # rdP0NominalPucchF1F3=-60
${CP_RT_rdP0NominalPusch}                        0x5900CF=114 # rdP0NominalPusch=-88
${CP_RT_rdP0NominalSrs}                          0x5900D0=206 # rdP0NominalSrs=4
${CP_RT_rdAlpha}                                 0x5900D1=1 # rdAlpha=al04
${CP_RT_rdAlpha_INVALID}                         0x5900D1=9
${CP_RT_rdInitialPreambleReceivedTargetPower}    0x5900D2=82 # rdInitialPreambleReceivedTargetPower=-120
${CP_RT_rdPMaxNROwnCell}                         0x5900D3=31 # rdPMaxNROwnCell=1
${CP_RT_rdActProactULScheduling}                 0x5900DF=1  # rdActProactUlScheduling=1

@{SWCONFIG_FLAGS_LIST}  ${CP_RT_rdSktPlmnId}  ${CP_RT_rdSktSpId}  ${CP_RT_rdUlPowerControl}  ${CP_RT_rdP0NominalPucch}
...  ${CP_RT_rdP0NominalPucchF1F3}  ${CP_RT_rdP0NominalPusch}  ${CP_RT_rdP0NominalSrs}  ${CP_RT_rdAlpha}
...  ${CP_RT_rdInitialPreambleReceivedTargetPower}  ${CP_RT_rdPMaxNROwnCell}

@{SWCONFIG_FLAGS_INVALID_LIST}  ${CP_RT_rdSktPlmnId}  ${CP_RT_rdSktSpId}  ${CP_RT_rdUlPowerControl}  ${CP_RT_rdP0NominalPucch}
...  ${CP_RT_rdP0NominalPucchF1F3}  ${CP_RT_rdP0NominalPusch}  ${CP_RT_rdP0NominalSrs}  ${CP_RT_rdAlpha_INVALID}
...  ${CP_RT_rdInitialPreambleReceivedTargetPower}  ${CP_RT_rdPMaxNROwnCell}

@{SWCONFIG_FLAGS_LIST_UPLANE}  ${CP_RT_rdSktPlmnId}  ${CP_RT_rdSktSpId}  ${CP_RT_rdUlPowerControl}  ${CP_RT_rdP0NominalPucch}
...  ${CP_RT_rdP0NominalPucchF1F3}  ${CP_RT_rdP0NominalPusch}  ${CP_RT_rdP0NominalSrs}  ${CP_RT_rdAlpha}
...  ${CP_RT_rdInitialPreambleReceivedTargetPower}  ${CP_RT_rdPMaxNROwnCell}  ${CP_RT_rdActProactULScheduling}

${NRCELL-1.actUlOpenLoopPwrCtrl}    true
${NRCELL-1.alpha_PE}    al06
${NRCELL-1.alpha_PCAP}    alpha06
${NRCELL-1.alphaSrs}    alpha06
${NRCELL-1.p0NominalPucch}    -26
${NRCELL-1.p0NominalPucchF1F3}   -30
${NRCELL-1.p0NominalPusch}    -44
${NRCELL-1.initialPreambleReceivedTargetPower}    -60
${NRCELL-1.p0NominalSrs}    8
${NRCELL-1.pucchF1DeltaF}    -10
${NRCELL-1.pucchF3DeltaF}    0
${NRCELL-1.pMaxNROwnCell}    2
${NRCELL-1.pucchModeSelect}    shortPucch
${NRCELL-1.pucchModeSelect_long}    longPucch
${NRCELL-1.actIncreasedFdmUsersPerSlot}    false

${NRBTS-1.actInactDetNSAUe}    True
${NRBTS-1.nsaInactivityTimer}    10

${7459_base_yaml}=              ${CURDIR}/../config/yaml_config/7459_base_setting.yaml
${7459_NRADJNRCELL_NRRELs}=     ${CURDIR}/../config/yaml_config/7459_nradjnrcell_nrrels.yaml
${non_rdSktPlmn}=               ${CURDIR}/../config/yaml_config/delta_non_rdSktPlmn.yaml

@{yamls_to_configure}=     ${disable_ciphering_yaml_path}   ${7459_NRADJNRCELL_NRRELs}   ${7459_base_yaml}


*** Keywords ***
Prepare TL with config files
    ${scfc_filepath}       Get Variable Value    ${SCFC}
    ${ap_xml_filepath}     Get Variable Value    ${AP_XML}
    Run keyword and ignore error      get_lua_for_topology
    ${lua_filepath}=      get variable value          ${LUA}        ${LUA_CFG}

    Run keyword if    '${scfc_filepath}'!='None'
    ...                Add gNB configuration    scfc=${scfc_filepath}
    Run keyword if    '${ap_xml_filepath}'!='None'
    ...                Add simulator    sim_type=airphone    config=${ap_xml_filepath}
    Run keyword if    '${lua_filepath}'!='None'
    ...                Add 5GC    config=${lua_filepath}    edaemon_ports=10000
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default     save_egate=${True}

Send base commissioning and configure non-SKT NIDD parameter values
    set enb parameter value
    ...  param_path=NRCELL.actUlOpenLoopPwrCtrl
    ...  value=${NRCELL-1.actUlOpenLoopPwrCtrl}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.alpha_PE
    ...  value=${NRCELL-1.alpha_PE}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.alphaSrs
    ...  value=${NRCELL-1.alphaSrs}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.p0NominalPucch
    ...  value=${NRCELL-1.p0NominalPucch}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.p0NominalPucchF1F3
    ...  value=${NRCELL-1.p0NominalPucchF1F3}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.p0NominalPusch
    ...  value=${NRCELL-1.p0NominalPusch}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.initialPreambleReceivedTargetPower
    ...  value=${NRCELL-1.initialPreambleReceivedTargetPower}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.p0NominalSrs
    ...  value=${NRCELL-1.p0NominalSrs}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.pucchF1DeltaF
    ...  value=${NRCELL-1.pucchF1DeltaF}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.pucchF3DeltaF
    ...  value=${NRCELL-1.pucchF3DeltaF}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.pMaxNROwnCell
    ...  value=${NRCELL-1.pMaxNROwnCell}
    ...  bts_id=1
    Run Keyword if  ${long_pucch} == ${True}
    ...  set enb parameter value
    ...  param_path=NRCELL.pucchModeSelect
    ...  value=${NRCELL-1.pucchModeSelect_long}
    ...  bts_id=1
    Run Keyword if  ${long_pucch} != ${True}
    ...  set enb parameter value
    ...  param_path=NRCELL.pucchModeSelect
    ...  value=${NRCELL-1.pucchModeSelect}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRCELL.actIncreasedFdmUsersPerSlot
    ...  value=${NRCELL-1.actIncreasedFdmUsersPerSlot}
    ...  bts_id=1
    set enb parameter value
    ...  param_path=NRBTS-1.nsaInactivityTimer
    ...  value=${NRBTS-1.nsaInactivityTimer}
    ...  bts_id=1
    Configure       ${yamls_to_configure}       node_id=1

Setup Default Preconditions for UE${ue_id_1} SPID=${spid_1} UE${ue_id_2} SPID=${spid_2}
    Create UEs alias
    ...  alias=UE
    ...  id_type=wts
    Create eNB device with alias 'MeNB' identified by ip=10.0.1.21
    Create gNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create gNB device with alias 'gNB3' identified by ip=10.0.1.31
    Enable internal mirroring for alias  gNB2

    Attach UE${ue_id_1} with SPID=${spid_1}
    Attach UE${ue_id_2} with SPID=${spid_2}

Setup Default Preconditions for UE${ue_id} with SPID=${spid}
    Create UEs alias
    ...  alias=UE
    ...  id_type=wts
    Create eNB device with alias 'MeNB' identified by ip=10.0.1.21
    Create gNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create gNB device with alias 'gNB3' identified by ip=10.0.1.31
    Enable internal mirroring for alias  gNB2

    Attach UE${ue_id} with SPID=${spid}

Attach UE${ue_id} with SPID=${spid}
    Execute egate command  cmd=ue_enb_param id=${ue_id} spid=${spid}
    Execute egate command
    ...  cmd=attach_ue id=${ue_id}
    ...  pass_regexp=UE${ue_id}: === UE IS ACTIVE

Prepare test environment B1
    Setup default preconditions for UE1 SPID=${CP_UE_rdSktSpId} UE2 SPID=${nonMatchingSpId}

Prepare test environment B2
    Setup default preconditions for UE3 with SPID=${CP_UE_rdSktSpId}

Cleanup after test B2
    Run keyword and ignore error   Detach UE3 and UE4

Prepare test environment B3
    Setup default preconditions for UE1 SPID=${CP_UE_rdSktSpId} UE2 SPID=${nonMatchingSpId}

Prepare test environment B4
    Setup default preconditions for UE1 SPID=${nonMatchingSpId} UE2 SPID=${nonMatchingSpId}
    Edit object attributes
    ...  object_name=NRBTS-1
    ...  srb3SupportEnabled=true
    ...  bts_id=1
    Edit object attributes
    ...  object_name=NRBTS-1
    ...  nsaActivityNotificationLevel=drb
    ...  bts_id=1

Cleanup after test B4
    Detach UE1 and UE2
    Edit object attributes
    ...  object_name=NRBTS-1
    ...  srb3SupportEnabled=false
    ...  bts_id=1
    Edit object attributes
    ...  object_name=NRBTS-1
    ...  nsaActivityNotificationLevel=ue
    ...  bts_id=1

Prepare test environment B1_alternative
    Edit object attributes
    ...  object_name=NRCELL-1
    ...  pucchModeSelect=longPucch
    ...  bts_id=1
    Setup default preconditions for UE9 SPID=${CP_UE_rdSktSpId} UE10 SPID=${nonMatchingSpId}
    Set test variable    ${long_pucch}    ${True}

Cleanup after test B1 alternative
    Detach UE9 and UE10
    Edit object attributes
    ...  object_name=NRCELL-1
    ...  pucchModeSelect=shortPucch
    ...  bts_id=1

Prepare test environment B1_exploratory
    Setup default preconditions for UE1 SPID=${CP_UE_rdSktSpId} UE2 SPID=${nonMatchingSpId}

Send Delta Commissioning with non rdSktPlmn
    [Timeout]       600
    Kill aliases
    Find Scfc and Send Delta Commissioning   scfc_filename=delta_non_rdSktPlmn.json
    Run Keyword And Ignore Error    Trigger site reset
    Wait for all cells reach onair
    Enable UE capture on simulated eNB  enable=${True}
    Create UEs alias
    ...  alias=UE_
    ...  id_type=wts
    Create gNB device with alias 'gNB2_' identified by ip=10.0.1.2
    Enable internal mirroring for alias  gNB2_

Change gNB PLMN to non rdSktPlmn
    Kill aliases
    Configure  ${non_rdSktPlmn}  node_id=1
    Trigger site reset
    Wait for all cells reach onair
    Create gNB device with alias 'gNB2_' identified by ip=10.0.1.2
    Enable internal mirroring for alias  gNB2_

Change RandD parameters
    ${CP_UE_TXZ_FILE} =     Get file name    CPUE_addons    gNB_CLASSICAL_OAM
    Extract file    ${CP_UE_TXZ_FILE}    CPUE_addons    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktSpId    ${CP_UE_rdSktSpId}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktPlmnId    ${CP_UE_rdSktPlmnId_ini}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdUlPowerControl    ${CP_UE_rdUlPowerControl}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdNsaInactivityTimer    ${CP_UE_rdNsaInactTimer}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdActInactDetNSAUe    ${CP_UE_rdActInactDetNSAUe}    gNB_CLASSICAL_OAM
    Compress and crasign RandD parameters file   ${CP_UE_TXZ_FILE}    CPUE_addons    gNB_CLASSICAL_OAM

ABIO specific change RandD parameters
    ${CP_UE_TXZ_FILE} =     Get file name    CPUE_addons_ABIO    gNB_CLASSICAL_OAM
    Extract file    ${CP_UE_TXZ_FILE}    CPUE_addons_ABIO    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktSpId    ${CP_UE_rdSktSpId}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktPlmnId    ${CP_UE_rdSktPlmnId_ini}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdUlPowerControl    ${CP_UE_rdUlPowerControl}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdNsaInactivityTimer    ${CP_UE_rdNsaInactTimer}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdActInactDetNSAUe    ${CP_UE_rdActInactDetNSAUe}    gNB_CLASSICAL_OAM
    Compress and crasign RandD parameters file   ${CP_UE_TXZ_FILE}    CPUE_addons_ABIO    gNB_CLASSICAL_OAM

Change RandD parameters in ${RandDParametersFile}
    [Documentation]     ${RandDParametersFile} param value must be the same as python variable name in
    ...                 testsuite/Krakow/RRM/DevKr/CB007459/resources/gnb_randd_parameters.py

    ${CP_UE_TXZ_FILE} =     Get file name    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    Extract file    ${CP_UE_TXZ_FILE}    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktSpId    ${CP_UE_rdSktSpId}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktPlmnId    ${CP_UE_rdSktPlmnId_ini}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdUlPowerControl    ${CP_UE_rdUlPowerControl}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdNsaInactivityTimer    ${CP_UE_rdNsaInactTimer}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdActInactDetNSAUe    ${CP_UE_rdActInactDetNSAUe}    gNB_CLASSICAL_OAM
    Compress and crasign RandD parameters file   ${CP_UE_TXZ_FILE}    ${RandDParametersFile}    gNB_CLASSICAL_OAM

Change RandD parameters common keyword
    ${sw_release}=   Get gNB SW release
    ${ute_tl_type}=  Get Environment Variable      UTE_TESTLINE_TYPE    ${FALSE}
    ${tl_type}=      Get Environment Variable      CM_TOPOLOGY_NAME     ${ute_tl_type}
    ${results}=      Create List
#    Run keyword if   '${sw_release}'=='SBTS22R2'   Change RandD parameters in CPUE_addons
#    Run keyword if   '${sw_release}'=='SBTS22R2'   Change RandD parameters in CPUE_addons_ABIO
#    Run keyword if   '${sw_release}'!='SBTS22R2' and '${tl_type}'!='CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD'
#    ...                                            Change RandD parameters in CPUE_addons_xeon
    @{status_msg}=      Run Keyword And Ignore Error   Change RandD parameters in CPUE_addons_snowfish
    Append to list     ${results}      ${status_msg[0]}
    @{status_msg}=      Run Keyword And Ignore Error   Change RandD parameters in CPUE_addons_xeon
    Append to list     ${results}      ${status_msg[0]}
    @{status_msg}=      Run Keyword And Ignore Error   Change RandD parameters in CPUE_addons_marlin
    Append to list     ${results}      ${status_msg[0]}
    ${pass_results}=        count values in list    ${results}      PASS

    Run keyword if      '${tl_type}'=='CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD'
    ...                  Should Be True 	int(${pass_results})==int(1)       ASOE TL should be only 1 pass
    Run keyword if      '${tl_type}'=='CLOUD_5G_O_E_AP_LOO'
    ...                  Should Be True 	int(${pass_results})==int(1)       ASOE TL should be only 1 pass
    Run keyword if      '${tl_type}'!='CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD' and '${tl_type}'!='CLOUD_5G_O_E_AP_LOO'
    ...                  Should Be True  	int(${pass_results})>=int(2)    LO and MP tls should have at least 2 passes


Trigger SgnbAddition procedure for UE${ue_id} with SPID=${spid}
    eNB triggers SCG establishment for UE-${ue_id} SPID=${spid} bearer-2 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE${ue_id} with NRCELL_1 on gNB2 succeed

Trigger SgnbAddition procedure when UE${ue_id} with SPID=${spid} and RD params are set to invalid values
    Expect UEContextSetupFailure at gNB2 for UE${ue_id}
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    Sleep  3

Trigger SgnbAddition for UE${ue_id_1} SPID=${spid_1} and UE${ue_id_2} SPID=${spid_2} with SRB3 enabled
    eNB triggers SCG establishment for UE-${ue_id_1} SPID=${spid_1} bearer-2 with NRCELL_1 on gNB2
    Verify if SCG establishment for UE${ue_id_1} with NRCELL_1 on gNB2 succeed with SRB3
    eNB triggers SCG establishment for UE-${ue_id_2} SPID=${spid_2} bearer-2 with NRCELL_1 on gNB2
    Verify if SCG establishment for UE${ue_id_2} with NRCELL_1 on gNB2 succeed with SRB3

Trigger SgnbModification for UE${ue_id} changing SPID to ${spid}
    Execute egate command  cmd=ue_dc_enb_modify ue=${ue_id} by=enb cause=MISC_CauseMisc_unspecified spid=${spid}

eNB triggers SCG establishment for UE-${ue_id} SPID=${spid} bearer-${bearer_id} with NRCELL_${nr_cell_id} on gNB${gnb_id}
    Expect ENDC flow for UE${ue_id} SPID=${spid} with gNB${gnb_id}
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${nr_cell_id} bearer=${bearer_id} type=split_scg

Expect ENDC flow for UE${ue_id} SPID=${spid} with gNB${gnb_id}
    Expect message flow
     ...    gNB${gnb_id}:X2AP_SgNBAdditionRequest as addReq
     ...    gNB${gnb_id}:E1AP_BearerContextSetupRequest as bearerSetupReq
     ...    gNB${gnb_id}:E1AP_BearerContextSetupResponse
     ...    gNB${gnb_id}:F1AP_UEContextSetupRequest as ueCtxSetupReq
     ...    gNB${gnb_id}:F1AP_UEContextSetupResponse as ueCtxSetupResp
     ...    gNB${gnb_id}:X2AP_SgNBAdditionRequestAcknowledge as addResp
     ...    gNB${gnb_id}:X2AP_SgNBReconfigurationComplete as ReconfCmp
     ...    gNB${gnb_id}:X2AP_SNStatusTransfer
     ...    alias=ENDC_UE${ue_id}   overall_timeout=30

Verify that SCG establishment for UE${ue_id} with NRCELL_1 on gNB${gnb_id} succeed
    Flow occurred as expected  alias=ENDC_UE${ue_id}
    Sleep  1

Verify if SCG establishment for UE${ue_id} with NRCELL_1 on gNB${gnb_id} succeed with SRB3
    Flow occurred as expected  alias=ENDC_UE${ue_id}
    Verify if srb-Identity equals to 3 in addResp:srb-ToAddModList for ENDC_UE${ue_id}
    Sleep  1

Verify RD params values in ${msg_alias} message in ${flow} flow having matching SPID/PLMN config
    Verify if preambleReceivedTargetPower equals to ${CP_UE_rdInitialPreambleReceivedTargetPower} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}
    Verify if alpha equals to "${CP_UE_rdAlpha_PCAP}" in ${msg_alias}:p0-AlphaSets for ${flow}
    Verify if p0-NominalWithGrant equals to ${CP_UE_rdP0NominalPusch} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}
#    Verify if p0-nominal equals to ${CP_UE_rdP0NominalPucch} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}
    Verify if p0 equals to ${CP_UE_rdP0NominalSrs} in ${msg_alias}:srs-ResourceSetToAddModList for ${flow}
    Verify if p-Max equals to ${CP_UE_rdPMaxNROwnCell} in ${msg_alias}:frequencyInfoUL for ${flow}

    Run Keyword if  ${long_pucch} == ${True}
    ...    Verify if p0-nominal equals to ${CP_UE_rdP0NominalPucchF1F3} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}

    Run Keyword if  ${long_pucch} != ${True}
    ...    Verify if p0-nominal equals to ${CP_UE_rdP0NominalPucch} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}


Verify NIDD params values in ${msg_alias} message in ${flow} flow having non-matching SPID/PLMN config
    Verify if preambleReceivedTargetPower equals to ${NRCELL-1.initialPreambleReceivedTargetPower} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}
    Verify if alpha equals to "${NRCELL-1.alpha_PCAP}" in ${msg_alias}:p0-AlphaSets for ${flow}
    Verify if p0-NominalWithGrant equals to ${NRCELL-1.p0NominalPusch} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}
#    Verify if p0-nominal equals to ${NRCELL-1.p0NominalPucch} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}
    Verify if p0 equals to ${NRCELL-1.p0NominalSrs} in ${msg_alias}:srs-ResourceSetToAddModList for ${flow}
    Verify if p-Max equals to ${NRCELL-1.pMaxNROwnCell} in ${msg_alias}:frequencyInfoUL for ${flow}

    Run Keyword if  ${long_pucch} == ${True}
    ...    Verify if p0-nominal equals to ${NRCELL-1.p0NominalPucchF1F3} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}

    Run Keyword if  ${long_pucch} != ${True}
    ...    Verify if p0-nominal equals to ${NRCELL-1.p0NominalPucch} in ${msg_alias}:uplinkBWP-ToAddModList for ${flow}


Verify if ${param} equals to ${value} in ${msg}:${container} for ${alias}
    Verify that message fulfills query
    ...  (${container} contains (${param} eq ${value}))
    ...  message_alias=${msg}
    ...  flow_alias=${alias}

UE${ue_id:\d+} triggers inter gNB HO from gNB_real to gNB_sim
    Expect inter gNB HO from gNB2 for UE${ue_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=120 nrsrq_nr=120

Expect inter gNB HO from gNB${gnb_id:\d+} for UE${ue_id:\d+}
    Expect message flow
    ...    gNB${gnb_id}:X2AP_SgNBChangeRequired
    ...    MeNB:X2AP_SgNBChangeConfirm
    ...    gNB${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=Inter_gNB_HO_for_UE_${ue_id}
    ...    overall_timeout=30

Verify that inter gNB HO from gNB_real to gNB_sim succeed for UE${ue_id:\d+}
    Flow occurred as expected  alias=Inter_gNB_HO_for_UE_${ue_id}

Expect UEContextSetupFailure at gNB${gnb_id:\d+} for UE${ue_id:\d+}
    Expect message flow
     ...    gNB${gnb_id}:X2AP_SgNBAdditionRequest as addReq
     ...    gNB${gnb_id}:E1AP_BearerContextSetupRequest as bearerSetupReq
     ...    gNB${gnb_id}:E1AP_BearerContextSetupResponse
     ...    gNB${gnb_id}:F1AP_UEContextSetupRequest
     ...    gNB${gnb_id}:F1AP_UEContextSetupFailure
     ...    gNB${gnb_id}:X2AP_SgNBAdditionRequestReject
     ...    alias=UEContextSetupFailure_for_UE_${ue_id}
     ...    overall_timeout=30

Verify that F1AP_UEContextSetupFailure and X2AP_SgNBAdditionRequestReject occured for UE${ue_id:\d+} at gNB${gnb_id:\d+}
    Flow occurred as expected  alias=UEContextSetupFailure_for_UE_${ue_id}

UE${ue_id:\d+} with SPID=${spid} triggers Inter gNB HO from gNB_sim to gNB_real
    Expect ENDC flow for UE${ue_id} SPID=${spid} with gNB2
    Execute egate command
    ...  cmd=dc_gnb_ue_change ue=${ue_id} gnb=2 target_sgnb_cells=1 cause=RN_sCG_Mobility
    ...  pass_regexp=UE${ue_id}: === Inter Sgnb Handover is successful ===

UE${ue_id} sends measurement with eventA${event_id} triggering PSCell change to gNB${gnb_id} cell-2
    Expect PSCell change flow for UE${ue_id} with gNB${gnb_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A${event_id} phycell_id=51 nrsrp_nr=100 srsrp_nr=10

Expect PSCell change flow for UE${ue_id} with gNB${gnb_id}
    Expect message flow
    ...    gNB${gnb_id}:X2AP_SgNBModificationRequired (physCellId eq 51) as modReq
    ...    gNB${gnb_id}:X2AP_SgNBModificationConfirm as modConfirm
    ...    alias=PSCell_change_UE${ue_id}
    ...    overall_timeout=30

Verify successful PSCell change for UE${ue_id}
    Flow occurred as expected  alias=PSCell_change_UE${ue_id}

Start 20Mbps DL traffic on split bearer for UE${ue_id}
    Execute egate command  cmd=trf_data_start ue=${ue_id} id=2 dir=dl mbps=20
    Sleep  10

Stop and verify 20Mbps DL traffics on split bearers for UE${ue_id_1} UE${ue_id_2} and verify inactivity timers
    Run keyword and ignore error    Verify 20MBps dl traffic on scg split bearer-2 for UE${ue_id_1}
    Run keyword and ignore error    Verify 20MBps dl traffic on scg split bearer-2 for UE${ue_id_2}

    Set time reference point  time_alias=traffic_stop_${ue_id_1}
    Expect inactTimer expiry will occur for UE-${ue_id_1} with context removal from SgNB side
    Execute egate command  cmd=trf_data_stop ue=${ue_id_1} id=2
    Verify inactivity timer flow for UE-${ue_id_1} in ${CP_UE_rdNsaInactTimer}

    Set time reference point  time_alias=traffic_stop_${ue_id_2}
    Expect inactTimer expiry will occur for UE-${ue_id_2} with context removal from SgNB side
    Execute egate command  cmd=trf_data_stop ue=${ue_id_2} id=2
    Verify inactivity timer flow for UE-${ue_id_2} in ${NRBTS-1.nsaInactivityTimer}

Stop and verify 20Mbps DL traffics on split bearers for UE${ue_id_1} UE${ue_id_2} and verify equal NIDD inactivity timers
    Run keyword and ignore error    Verify 20MBps dl traffic on scg split bearer-2 for UE${ue_id_1}
    Run keyword and ignore error    Verify 20MBps dl traffic on scg split bearer-2 for UE${ue_id_2}

    Set time reference point  time_alias=traffic_stop_${ue_id_1}
    Expect inactTimer expiry will occur for UE-${ue_id_1} with context removal from SgNB side
    Execute egate command  cmd=trf_data_stop ue=${ue_id_1} id=2
    Verify inactivity timer flow for UE-${ue_id_1} in ${NRBTS-1.nsaInactivityTimer}

    Set time reference point  time_alias=traffic_stop_${ue_id_2}
    Expect inactTimer expiry will occur for UE-${ue_id_2} with context removal from SgNB side
    Execute egate command  cmd=trf_data_stop ue=${ue_id_2} id=2
    Verify inactivity timer flow for UE-${ue_id_2} in ${NRBTS-1.nsaInactivityTimer}

Stop and verify 20Mbps DL traffic on split bearer for UE${ue_id} and verify ${option:NIDD|RD} inactivity timer
    Expect inactTimer expiry will occur for UE-${ue_id} with context removal from SgNB side
    Run keyword and ignore error    Verify 20MBps dl traffic on scg split bearer-2 for UE${ue_id}

    Set time reference point  time_alias=traffic_stop_${ue_id}

    Execute egate command  cmd=trf_data_stop ue=${ue_id} id=2

    Run keyword if      '${option}' == 'RD'
    ...  Verify inactivity timer flow for UE-${ue_id} in ${CP_UE_rdNsaInactTimer}

    Run keyword if      '${option}' == 'NIDD'
    ...  Verify inactivity timer flow for UE-${ue_id} in ${NRBTS-1.nsaInactivityTimer}

Expect inactTimer expiry will occur for UE-${ue_id:\d+} with context removal from SgNB side
    Expect message flow
    ...  gNB2:X2AP_SgNBReleaseRequired (Cause contains (radioNetwork eq 'user-inactivity')) as releaseReq
    ...  gNB2:X2AP_SgNBReleaseConfirm
    ...  gNB2:X2AP_UEContextRelease
    ...  alias=inactivity-occur_${ue_id}
    ...  overall_timeout=30

Verify inactivity timer flow for UE-${ue_id} in ${diff_time}
    Verify message delay from message to time point
    ...  flow_alias=inactivity-occur_${ue_id}
    ...  message_alias=releaseReq
    ...  time_alias=traffic_stop_${ue_id}
    ...  expected_diff_time=${diff_time}
    ...  tolerance=2.5

Detach UE${ue_id_1} and UE${ue_id_2}
    Execute egate command  cmd=detach_ue id=${ue_id_1}
    Execute egate command  cmd=detach_ue id=${ue_id_2}

UE${ue_id} sends measurement with event${event_id} triggering PSCell change to gNB${gnb_id} cell-2 PCI-${pci}
    Expect SRB3 PSCell change flow with PCI-${pci} for UE${ue_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=${event_id} phycell_id=${pci} nrsrp_nr=100 srsrp_nr=10
    Verify SRB3 successful PSCell change for UE${ue_id} PCI${pci}

Expect SRB3 PSCell change flow with PCI-${pci} for UE${ue_id}
    Expect message flow
    ...    gNB2:F1AP_UEContextModificationRequest as ueCtxModifyReq
    ...    gNB2:F1AP_UEContextModificationResponse as ueCtxModifyResp
    ...    alias=PSCell_change_SRB3_UE${ue_id}
    ...    overall_timeout=30

Verify SRB3 successful PSCell change for UE${ue_id} PCI${pci}
    Flow occurred as expected  alias=PSCell_change_SRB3_UE${ue_id}
    Verify if physCellId equals to ${pci} in ueCtxModifyResp:reconfigurationWithSync for PSCell_change_SRB3_UE${ue_id}
