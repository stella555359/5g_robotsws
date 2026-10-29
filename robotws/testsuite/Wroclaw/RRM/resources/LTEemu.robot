*** Settings ***
Documentation     Place for LTE emulator bring up and commands to trigger NSA Call
...               author: madhavi.mada
...               contact: madhavi.mada@nokia.com

Library         String
Library         Collections
Library         taf.lteemu            WITH NAME   lteemu
Library         taf.transport.ssh     WITH NAME   ssh

*** Keywords ***
Connect to LTEemu
    [Arguments]    ${testLine}=${tl.core.default_ssh_connection_details.addr}
    ...            ${username}=${tl.core.default_ssh_connection_details.username}
    ...            ${password}=${tl.core.default_ssh_connection_details.password}
    ...            ${alias}=lteemu
     ssh.Connect To   ${testLine}    ${username}    ${password}    alias=${alias}

Kill LTEemu edaemon and egate processes
    [Documentation]     This keyword kills existing LTEemu egate and edaemon processes
    [Arguments]     ${connection}=lteemu
    lteemu.kill_lteemu_edaemon   edaemon_port=${tl.core.edaemon_port}
    ...                          connection=${connection}
    lteemu.kill_lteemu_egate     egate_port=${tl.core.egate_port}
    ...                          connection=${connection}
    ssh.send command   command=rm -rf ${tl.core.dir_path}/*.log*        connection=${connection}

Start LTEemu edaemon and egate processes
    [Documentation]     This keyword starts LTEemu egate and edaemon processes
    [Arguments]     ${connection}=lteemu
    ...             ${testLine}=${tl.core.default_ssh_connection_details.addr}
    lteemu.configure_lteemu_edaemon     edaemon_ssh_alias=${connection}
    ...                                 directory_path=${tl.core.dir_path}
    ...                                 port=${tl.core.edaemon_port}
    lteemu.configure_lteemu_egate       egate_ssh_alias=${connection}
    ...                                 directory_path=${tl.core.dir_path}
    ...                                 port=${tl.core.egate_port}
    lteemu.start_lteemu   egate_console_ip=${testLine}    egate_port=${tl.core.egate_port}
    Log to console    LTEemu edaemon and egate started!

Start LTEemu and load config file to reach active state
    [Documentation]     This keyword starts LTEemu  and load cfg file in egate cosole
    [Arguments]       ${testLine}=${tl.core.default_ssh_connection_details.addr}
    lteemu.start_lteemu   egate_console_ip=${testLine}    egate_port=${tl.core.egate_port}
    lteemu.configure      file=${tl.core.cfg_filename}
    lteemu.read_lteemu_output_until    expected=CHANGE STATE: ACTIVE - SimMode is ready now
    ...                                timeout=30
    Log to console    LTEemu is running!

Setup LTEemu environment
    [Documentation]     This keyword will setup the whole LTEemu environment
    Connect to LTEemu
    Kill LTEemu edaemon and egate processes
    Start LTEemu edaemon and egate processes

Stop LTEemu processes
    [Documentation]   This keyword stops every software component of Lteemu
    lteemu.reset_lteemu_cfg
    sleep   3 s   reason=time needed to release lteemu interfaces before start of next test case
    Log to console    LTEemu stopped!

4G attach for NSA
    [Documentation]    Command used to attach UE to enbsim
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage: Enb attach for NSA id=1 or simply Enb attach for NSA
    ...         it will consider default id as 1 when not passed as well
    [Arguments]      ${ue_id}=1
    lteemu.ue_attach    id=${ue_id}
    lteemu.read_lteemu_output_until    expected=UE IS ACTIVE
    ...                                timeout=10
    Log to console     4G Attach is successful

Start sgNB Addition Procedure
    [Documentation]     triggers dual connectivity
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage:Start sgNB Addition Procedure - considers all the mandatory with default values
    ...         Start sgNB Addition Procedure   pci=10    unsupported_SgNbAdditionReq_option=normal
    ...         Considers optional parameters when user passes these
    [Arguments]    ${ue_cm_id}=1     ${bearer_cm_id}=1    ${gnb_id}=2
    ...     ${log_path}='${tl.core.dir_path}/enb_1.log'
    ...     ${pci}=50     ${arfcn}=2055001
    ...     ${unsupported_SgNbAdditionReq_option}=${None}
    lteemu.ue_dc_start   ue_cm_id=${ue_cm_id}   bearer_cm_id=${bearer_cm_id}
    ...   gNB_id=${gnb_id}   pci=${pci}   arfcn=${arfcn}
    ...   unsupp_SgNbAddReq_opt=${unsupported_SgNbAdditionReq_option}
    Verify messages in SgNB addition procedure   ${log_path}=${tl.core.dir_path}
    Log to console    sgNb Addition procedure is completed successfully

Verify messages in SgNB addition procedure
    [Documentation]    Verification of SgNBAdditionRequestAcknowledge,
    ...    SgNBReconfigurationComplete and SNStatusTransfer  messages
    ...    to confirm that SgNB Addition process us success
    [Arguments]    ${log_path}
    Log to console    Verification of messages in Sgnb Addition procedure
    lteemu.read_lteemu_log   log_path=${log_path}
    ...     expected=Enter void\n enb::UeProcDualConnectivity::SendSgNBAdditionRequest
    lteemu.read_lteemu_log   log_path=${log_path}   expected=SendRRCConnectionReconfiguration
    lteemu.read_lteemu_log   log_path=${log_path}   expected=Sending X2::SgNBReconfigurationComplete
    lteemu.read_lteemu_log   log_path=${log_path}   expected=Sending X2::SendSNStatusTransfer to SgNB

Enb detach for NSA
    [Documentation]     command used to detach UE
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage: Enb detach for NSA or Enb detach for NSA    id=1
    [Arguments]     ${ue_id}=1
    Log to console     4G Detach starting!\nWait for "UE Released" \nWait for max 20s
    lteemu.ue_detach   id=${ue_id}
    lteemu.read_lteemu_output_until    expected=UE1: detached
    ...                                timeout=10
    Log to console   4G detach is successful

Setup X2AP Link between enb and gnb
    [Documentation]     setup X2 link
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage: X2AP Link between enb and gnb
    ...         or X2AP Link between enb and gnb     enb_id=1   target_id=2
    ...         or X2AP Link between enb and gnb     global_enb_id_of_enb=1
    ...         global_enb_id_of_enb is optional parameter if user passes this it will consider
    ...         in message construction otherwise not. The other two i.e. enb_id and terget_id
    ...         are mandatory if not passed default value will be taken
    [Arguments]     ${use_global_enb_id_of_enb}=${None}    ${enb_id}=1     ${target_id}=2
    lteemu.enb_x2_link_up    enb_id=${enb_id}   target_id=${target_id}
    ...         use_global_enb_id_of_enb=${use_global_enb_id_of_enb}
    lteemu.read_lteemu_output_until_re    expected=X2AP Link with [E,G]NB-2.* is up
    ...                                timeout=10
    Log to console    X2 link is up!

Start downlink data from lteemu epcsim
    [Documentation]     Start DL data traffic on a bearer
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage:Start downlink data - by default it will start traffic
    ...         in downlink direction.
    [Arguments]    ${kbps}=${None}    ${bearer_id}=6   ${trf_id}=1
    ...            ${ue_id}=1   ${dir}=dl
    lteemu.trf_data_start   ue=${ue_id}    id=${bearer_id}
    ...                     dir=${dir}   trf_id=${trf_id}
    lteemu.read_lteemu_output_until    expected=UE1: [DATA START]
    ...                                timeout=10
    Log to console    DL data traffic is started!

Stop downlink data from lteemu epcsim
    [Documentation]     Stop DL data traffic on a bearer
    ...         Prior to this DL data should be started.
    [Arguments]    ${bearer_id}=6    ${trf_id}=1   ${ue_id}=1    ${dir}=dl
    lteemu.trf_data_stop   ue=${ue_id}    id=${bearer_id}
    ...                    dir=${dir}   trf_id=${trf_id}
    Log to console    DL data traffic is stopped!

Setup X2AP Link without global enb id
    [Documentation]     setup X2 link without global enb id
    [Arguments]     ${enb}=1     ${enb_id}=1     ${target_id}=2
    lteemu.enb_x2_link_up    enb_id=${enb_id}   target_id=${target_id}
    lteemu.read_lteemu_output_until_re    expected=X2AP Link with [E,G]NB-2.* is up
    ...                                timeout=10
    Log to console    X2 link is up!
