*** Settings ***
Documentation     [PURPOSE]

Library          taf.wts.runner                   WITH NAME    wtsemu
Library          ute_wtssim
Library          OperatingSystem
Library          DateTime

Library          ../python/dss_tools.py           WITH NAME    nps_dss_tools
Library          ../python/egate_analyzer.py      WITH NAME    egate_analyzer

Resource         common_Dss_Keywords.robot

*** Variables ***

${UE_attach_pattern}    reported successful RA

${Timeout_SA}    40
${Timeout_NSA}    300

${path_config_uecapa}                    ${CURDIR}/../config/UeCapa
${cfg_capa_file}                         ${path_config_uecapa}/ue_capabilities.cfg

*** Keywords ***

Wait '${time}' for stability for reason '${reason}'
    sleep    ${time}    reason=${reason}

DSS_5g_Call_SA
    [Arguments]                 ${alias}=default    ${w_ue_capa}=True

    ${UeId}   set variable     ${Param.Context.UeId1}
    ${msg}=   Catenate    ***DSS ${Param.Context.DSS_Phase} 5gCAll SA [BW=${Param.seq.bandwidth},UeId=${UeId}] with alias=${alias}***
    Log to console   \n${blue}${msg} ${normal}

    # 10/6/2023 : for testing purpose
    # ${gnbId}   set variable     ${Param.Context.gNBId}
    # ${cell_id}   set variable     1
    # common_Dss_SA_NSA.UL Set cell noise    gnbId=${gnbId}     cell_id=${cell_id}      alias=${alias}
    # common_Dss_SA_NSA.UL Set Target Power And Disable Noise For SRS Signals   ue_id=${UeId}    alias=${alias}
    # 10/6/2023 : End of for testing purpose
    common_Dss_SA_NSA.Set UE Parameters Before Register    ue_id=${UeId}    alias=${alias}
    common_Dss_SA_NSA.UE Register To GNB                   ue_id=${UeId}    alias=${alias}   w_ue_capa=${w_ue_capa}
    common_Dss_SA_NSA.UE PDU Session Setup                 ue_id=${UeId}    alias=${alias}

    log to console   \n${blue}***DSS SA 5gCall BW=${Param.seq.bandwidth} completed*** ${normal}

DSS_5g_Call_SA_TC13
    [Arguments]                 ${alias}=default

    ${UeId}   set variable     ${Param.Context.UeId1}
    ${msg}=   Catenate    ***DSS ${Param.Context.DSS_Phase} 5gCAll SA [BW=${Param.seq.bandwidth},UeId=${UeId}] with alias=${alias}***
    Log to console   \n${blue}${msg} ${normal}

    # common_Dss_SA_NSA.UL Set Target Power And Disable Noise For SRS Signals   ue_id=${UeId}    alias=${alias}
    common_Dss_SA_NSA.Set UE Parameters Before Register    ue_id=${UeId}    alias=${alias}
    common_Dss_SA_NSA.UE Register To GNB for TC13                   ue_id=${UeId}    alias=${alias}
    common_Dss_SA_NSA.UE PDU Session Setup                 ue_id=${UeId}    alias=${alias}

    log to console   \n${blue}***DSS SA 5gCall BW=${Param.seq.bandwidth} completed*** ${normal}

DSS_5g_SA_UL_DL_Traffic
   [Arguments]         ${param}      ${ul_rate}=15      ${dl_rate}=80    ${alias}=default
   Init Sequence       ${param}

   Step       common_Dss_Keywords.Start capture Bip and Xp for DSS     argument=DSS_5g_SA_UL_DL_Traffic.wL1L2Bip.wXP
   Step       Start Generating "${ul_rate}"mbps UL and "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on SA using alias "${alias}"
   Step       common_Dss_Keywords.Stop capture Bip and Xp for DSS      depends=common_Dss_Keywords.Start capture Bip and Xp for DSS
   Step       common_Dss_SA_NSA.Display Ue Statistics       argument=${alias}

DSS_5g_SA_GBR_UL_DL_Traffic
   [Arguments]         ${param}      ${ul_rate}=10      ${dl_rate}=10    ${alias}=default
   Init Sequence       ${param}

   # Step       common_Dss_Keywords.Start capture Bip and Xp for DSS     argument=DSS_5g_SA_GBR_UL_DL_Traffic.wL1L2Bip.wXP
   Step       Start Generating GBR "${ul_rate}"mbps UL and "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on SA using alias "${alias}"
   sleep      1s    reason=wait traffic is stable
   # Step       common_Dss_Keywords.Stop capture Bip and Xp for DSS      depends=common_Dss_Keywords.Start capture Bip and Xp for DSS
   Step       common_Dss_SA_NSA.Display Ue Statistics       argument=${alias}
   [Teardown]                      GenericTest.Display diagnosis

DSS_5g_SA_GBR_UL_DL_Traffic_New_Tput_Tgt
   [Arguments]         ${param}      ${ul_rate}=10      ${dl_rate}=10    ${alias}=default

   BuiltIn.log    ul_rate is ${ul_rate}
   ${pattern}    Set Variable    TCP DL TRF:
   ${cmd}=     Catenate         trf_data_start ue=${param.Context.UeId1} pdu=1 qfi=2 trf_id=2 mbps=${dl_rate} dir=dl protocol=tcp
   ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
   ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
   Log to Console    ${output}
   ${pattern}    Set Variable    UDP DL TRF:
   ${cmd}=     Catenate         trf_data_start ue=${param.Context.UeId1} pdu=1 qfi=3 trf_id=3 mbps=${dl_rate} dir=dl protocol=udp
   ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
   ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
   Log to Console    ${output}
   ${cmd}=     Catenate         qosflow_disp
   ${output}      wts.execute egate command        cmd=${cmd}   pass_regexp=gbr    timeout=10    alias=${alias}
   Log to Console    ${output}
   Log to Console     Started GBR DL + UL Traffic for UE=${param.Context.UeId1}

   sleep      1s    reason=wait traffic is stable
   [Teardown]                      GenericTest.Display diagnosis

DSS_5g_SA_GBR_UL_DL_Traffic_New_Tput_Tgt_QFI_3_Only
   [Arguments]         ${param}      ${ul_rate}=10      ${dl_rate}=10    ${alias}=default

   # ${pattern}    Set Variable    TCP DL TRF:
   # ${cmd}=     Catenate         trf_data_start ue=${param.Context.UeId1} pdu=1 qfi=2 trf_id=2 mbps=${0} dir=dl protocol=tcp
   # ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
   # ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
   # Log to Console    ${output}
   BuiltIn.log    ul_rate is ${ul_rate}
   ${pattern}    Set Variable    UDP DL TRF:
   ${cmd}=     Catenate         trf_data_start ue=${param.Context.UeId1} pdu=1 qfi=3 trf_id=3 mbps=${dl_rate} dir=dl protocol=udp
   ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
   ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
   Log to Console    ${output}
   ${cmd}=     Catenate         qosflow_disp
   ${output}      wts.execute egate command        cmd=${cmd}   pass_regexp=gbr    timeout=10    alias=${alias}
   Log to Console    ${output}
   Log to Console     Started GBR DL Traffic for UE=${param.Context.UeId1}

   sleep      1s    reason=wait traffic is stable
   [Teardown]                      GenericTest.Display diagnosis

DSS_5g_SA_GBR_VoNR_DL_Traffic
   [Arguments]         ${param}    ${dl_rate}=10  ${rtp_codec}=amr_wb_18_25    ${alias}=default
   Init Sequence       ${param}

   Step  Start Generating GBR DL VoNR "${dl_rate}" mbps with "${rtp_codec}" codec Traffic for Ue "${Param.Context.UeId1}" on SA alias "${alias}"
   sleep      1s    reason=wait traffic is stable
   Step       common_Dss_SA_NSA.Display Ue Statistics       argument=${alias}
   [Teardown]                      GenericTest.Display diagnosis


# ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-300
# ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
UL Set Target Power And Disable Noise For SRS Signals
   [Arguments]        ${ue_id}=1  ${alias}=default

   ${cmd}=    Catenate    ul_sinr_testmode_nr       profile_id=1
   ...                                  sinr_target_pusch=0
   # ...                                  sinr_target_pusch=-100
   # ...                                  sinr_target_pusch=-300
   # ...                                  sinr_target_pucch=-200
   # ...                                  noise_srs=-1053
   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}

   ${cmd}=    Catenate    ue_testmode_set_nr        id=${ue_id}
   ...                                  testmode=ul_sinr
   ...                                  action=activate
   ...                                  profile_id=1

   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}

   ${cmd}=    Catenate    ul_sinr_testmode_nr       profile_id=1
   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}
   Wait '6s' for stability for reason 'wait for ul sinr adjust'
   log to console  \n***ul_sinr_testmode_nr for UeId=${ue_id} completed***

# ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-200
# cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=1 action=activate
UL Set cell noise
   [Arguments]        ${gnbId}=1    ${cell_id}=1    ${alias}=default

   ${cmd}=    Catenate    ul_cell_noise_testmode_nr       profile_id=1
   ...                                  noise_pusch=-611
   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}

   ${cmd}=    Catenate    cell_testmode_set_nr        cell_id=${cell_id}     gnb=${gnbId}
   ...                                  testmode=ul_cell_noise
   ...                                  action=activate
   ...                                  profile_id=1

   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}

   ${cmd}=    Catenate    ul_cell_noise_testmode_nr       profile_id=1
   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}
   Wait '6s' for stability for reason 'wait for cell noise'
   log to console  \n***ul_cell_noise_testmode_nr for gnbId=${gnbId} and cell_id=${cell_id} completed***

Deactive pusch sinr
   [Arguments]        ${ue_id}=1  ${alias}=default
   ${cmd}=    Catenate    ue_testmode_set_nr  id=${ue_id}
   ...                                  testmode=ul_sinr
   ...                                  action=deactivate
   ...                                  profile_id=1
   Dated Log New Line       ${cmd}
   Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}
   Wait '6s' for stability for reason 'wait for ul sinr adjust'

Set UE Parameters Before Register
  [Arguments]  ${ue_id}=1  ${pdu}=1  ${alias}=default
  ${cmd}=    Catenate    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
  Dated Log New Line       ${cmd}
  # csamson ; ${wtsObj} instead of wts
  # wts.execute egate command     cmd=${cmd}      alias=${alias}
  Call Method     ${wtsObj}   execute_egate_command     cmd=${cmd}      alias=${alias}

UE Register To GNB
  [Arguments]  ${ue_id}=1  ${alias}=default  ${w_ue_capa}=True    ${ue_capa_tag}=UE_CAPA
  # ${pattern}    Set Variable    UE now in NG RM Registered state
  ${pattern}    Set Variable    UE now in NG RM Registered
  # ${ue_nr_capabilities}=   Catenate    SEPARATOR=   E1201000014F5E0302C003044009041B38987C283809B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D
  # ...      262A08FE594932814105B260901831E31FF9863CA160703878089C02700040000000000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC0
  #...      CADD200A0800004B29202000032CA480800014B29202000072CA4A0800024B292120000AA5949005D038BA551740E269544D2A88AEC40700F0034020100000010
  # Ue capa updated because of gNB PR651826 & PR652350 correction
  ${ue_nr_capabilities}=   Catenate    SEPARATOR=   E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C002
  ...         83E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0
  ...         390400000290400000A90400001292500001A6017036F236B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA4848000
  ...         2A9652401340E2E91C5D0A89A55115D8816007801A010080000000000200400840

  # for testing purpose (with 2 DL layers)
  # ${ue_nr_capabilities}=   Catenate    SEPARATOR=   E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A
  # ...         0F88DAC31B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026761D86761D802001800000000388C00000000841808DC9A1F00E4100
  # ...         0000A41000002A41000004A494000069805C0CBC8CADD200A0800004B29202000032CA480800014B29202000072CA4A0800024B292120000AA5949004D
  # ...         038BA471742A269544576205801E006804020000000000080100210

  # ${cmd}=    Catenate    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
  ${cmd}=    Catenate    ue_register id=${ue_id}
  # ${cmd}=    run Keyword if    '${w_ue_capa}' == 'True'   Catenate    ${cmd} ue_nr_capabilities=${ue_nr_capabilities}
  # ...         ELSE                                        set Variable   ${cmd}
  # use of ue_capa file for ue capabilities
  OperatingSystem.Run      cp ${cfg_capa_file} /opt/wts/latest
  ${ue_capability_file}=     nps_dss_tools.return_basename      ${cfg_capa_file}
  ${cmd}=    run Keyword if  '${w_ue_capa}' == 'True'   Catenate    ${cmd} ue_nr_capabilities=${ue_capa_tag} capability_file=./${ue_capability_file}
  ...         ELSE                                        set Variable   ${cmd}

  Dated Log New Line       ${cmd}
  # ${wtsObj.execute_egate_command_and_wait_for_data}     cmd=${cmd}   pass_regexp=${pattern}    timeout=30     alias=${alias}
  ${output}     Call Method     ${wtsObj}    execute_egate_command_and_wait_for_data     cmd=${cmd}   pass_regexp=${pattern}
  ...                                                                                    timeout=30     alias=${alias}
  # ${output}     wts.execute egate command And Wait For Data    cmd=${cmd}
  # ...                     pass_regexp=${pattern}    timeout=30     alias=${alias}
  ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
  Log To Console    \n${output}

UE Register To GNB for TC13
  [Arguments]  ${ue_id}=1  ${alias}=default
  # ${pattern}    Set Variable    UE now in NG RM Registered state
  ${pattern}    Set Variable    UE now in NG RM Registered
#  ${ue_nr_capabilities}=   Catenate    SEPARATOR=   E1201000014F5E0302C000054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F11B586368E
#  ...      9315047F2CA49940E0416C9824060C78C7FE618F28581C0E1E0227009C0010000000000210602372687C0390400000290400000A90400001292500001A601F036F2A6F0
#  ...      32B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA48480002A9652401740E2E9545D0389A55134AA22BB102401E00680402000000200
  ${ue_nr_capabilities}=   Catenate    SEPARATOR=   E1A01000014F5E0302C000074001208367130F8509009B0083FF30C7942C0E09804062280C0298C002
  ...         83E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0
  ...         390400000290400000A90400001292500001A6017036F236B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA4848000
  ...         2A9652401340E2E91C5D0A89A55115D8816007801A010080000000000200400840
  ${cmd}=    Catenate    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
  Dated Log New Line       ${cmd}
  # ${wtsObj.execute_egate_command_and_wait_for_data}     cmd=${cmd}   pass_regexp=${pattern}    timeout=30     alias=${alias}
  ${output}     Call Method     ${wtsObj}    execute_egate_command_and_wait_for_data     cmd=${cmd}   pass_regexp=${pattern}
  ...                                                                                    timeout=30     alias=${alias}
  # ${output}     wts.execute egate command And Wait For Data    cmd=${cmd}
  # ...                     pass_regexp=${pattern}    timeout=30     alias=${alias}
  ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
  Log To Console    \n${output}

UE PDU Session Setup
  # [Arguments]  ${ue_id}=1  ${pdu}=1  ${gw}=1  ${fiveQi}=5  ${alias}=default
  [Arguments]  ${ue_id}=1  ${pdu}=1  ${gw}=1  ${fiveQi}=6  ${alias}=default
  BuiltIn.log     fiveQi is ${fiveQi}
  ${pattern}    Set Variable    Initial Context Setup Successful for
  ${cmd}=    Catenate    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  Dated Log New Line       ${cmd}
  ${output}    wts.execute egate command    cmd=${cmd}    pass_regexp=${pattern}    timeout=30     alias=${alias}
  ${output1}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
  Log To Console    \n${output1}

Start Generating "${ul_rate}"mbps UL and "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on SA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ul_rate:  the volume of uplink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ${pattern}    Set Variable    UDP DL TRF
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=1 trf_id=1 mbps=${dl_rate} dir=dl
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${pattern}    Set Variable    UDP UL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=1 trf_id=1 mbps=${ul_rate} dir=ul
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    Log to Console     Started DL + UL Traffic for UE=${Param.Context.UeId1}

SA Start Generating "${dl_rate}"mbps DL Traffic for UeId "${Param.Context.UeId1}" on SA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ${pattern}    Set Variable    UDP DL TRF
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=1 trf_id=1 mbps=${dl_rate} dir=dl
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    Log to Console     Started DL Traffic for UE=${Param.Context.UeId1}

Get Nb Of Transfers
    [Documentation]                 INTERNAL USAGE
    ...                             Get the number of data transfer needed to reach the requested throughput
    ...                             The max throughput per transfer is provided by maxThroughputPerTransfer parameter
    [Arguments]                     ${throughput}=${0}
    ...                             ${maxThroughputPerTransfer}=${140}
    # For backward compatibility, if no throughput provided then consider that there is only 1 transfer
    Return From Keyword If    '${throughput}'=='${0}' or '${throughput}'=='${None}'    ${1}
    ${nbTrf}         Evaluate   ${throughput}/${maxThroughputPerTransfer}
    ${nbTrf1}        Evaluate    ${nbTrf}+1
    ${remaining}     Evaluate   ${throughput}%${maxThroughputPerTransfer}
    ${nbTrf}         Set Variable If    ${remaining}>${0}      ${nbTrf1}
    ...                                                        ${nbTrf}
    ${nbTrf}         Convert to Integer    ${nbTrf}
    [Return]         ${nbTrf}

SA Start Generating Huge "${dl_rate}"mbps DL Traffic for UeId "${Param.Context.UeId1}" on SA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ${maxThroughputPerTransfer}     Set Variable     ${140}
    ${nb_trf}        Get Nb Of Transfers      throughput=${dl_rate}
    ...                                       maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ${remaining_throughput}     Set Variable    ${dl_rate}
    FOR  ${idx}    IN RANGE     ${nb_trf}
        ${trf_id}    Evaluate    ${1}+${idx}
        ${trfThroughput}    Set Variable If     ${remaining_throughput}>=${maxThroughputPerTransfer}        ${maxThroughputPerTransfer}
        ...                                     ${remaining_throughput}<${maxThroughputPerTransfer}         ${remaining_throughput}
        ${pattern}    Set Variable    UDP DL TRF
        ${cmd}=       Catenate        trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=1 trf_id=${trf_id} mbps=${trfThroughput} dir=dl
        ${output}     wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
        ${output}     Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
        Log to Console    ${output}
        ${remaining_throughput}    Evaluate     ${remaining_throughput}-${trfThroughput}
    END
    Log to Console     Started DL Traffic for UE=${Param.Context.UeId1}

Start Generating GBR "${ul_rate}"mbps UL and "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on SA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ul_rate:  the volume of uplink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ...      	ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2 by=amf
	...         ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=3 by=amf
    ...
	...         trf_data_start ue=3 pdu=1 qfi=2 dir=dl trf_id=20 mbps=10 protocol=tcp
	...         trf_data_start ue=3 pdu=1 qfi=3 dir=dl trf_id=21 mbps=10 protocol=udp
	...
    ${pattern}    Set Variable   Pdu Session Resource Modify.*successfully
    ${cmd}=     Catenate         ue_pdu_session_modify ue=${Param.Context.UeId1} pdu=1 qosflows_to_add=2 by=amf
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${cmd}=     Catenate         ue_pdu_session_modify ue=${Param.Context.UeId1} pdu=1 qosflows_to_add=3 by=amf
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}

    ${pattern}    Set Variable    TCP DL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=2 trf_id=2 mbps=${dl_rate} dir=dl protocol=tcp
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${pattern}    Set Variable    UDP DL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=3 trf_id=3 mbps=${dl_rate} dir=dl protocol=udp
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}

    ${pattern}    Set Variable    TCP UL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=2 trf_id=2 mbps=${ul_rate} dir=ul protocol=tcp
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${pattern}    Set Variable    UDP UL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=3 trf_id=3 mbps=${ul_rate} dir=ul protocol=udp
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}

    ${cmd}=     Catenate         qosflow_disp
    ${output}      wts.execute egate command        cmd=${cmd}   pass_regexp=gbr    timeout=10    alias=${alias}
    Log to Console    ${output}
    Log to Console     Started GBR DL + UL Traffic for UE=${Param.Context.UeId1}


Start Generating GBR DL VoNR "${dl_rate}" mbps with "${rtp_codec}" codec Traffic for Ue "${Param.Context.UeId1}" on SA alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ul_rate:  the volume of uplink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ...      	ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2 by=amf
	...         ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=3 by=amf
    ...
	...         trf_data_start ue=3 pdu=1 qfi=3 dir=dl trf_id=2 rtp_codec=${rtp_codec}
	...         trf_data_start ue=3 pdu=1 qfi=3 dir=dl trf_id=3 rtp_codec=${rtp_codec}
	...
    ${pattern}    Set Variable   Pdu Session Resource Modify.*successfully
    ${cmd}=     Catenate         ue_pdu_session_modify ue=${Param.Context.UeId1} pdu=1 qosflows_to_add=2 by=amf
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${cmd}=     Catenate         ue_pdu_session_modify ue=${Param.Context.UeId1} pdu=1 qosflows_to_add=3 by=amf
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}

    ${pattern}    Set Variable    UDP DL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=2 trf_id=2 dir=dl mbps=${dl_rate} protocol=udp
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${cmd}=     Catenate         qosflow_disp
    ${output}      wts.execute egate command        cmd=${cmd}   pass_regexp=gbr    timeout=10    alias=${alias}
    Log to Console    ${output}
    Log to Console     Started GBR DL + UL Traffic for UE=${Param.Context.UeId1}

    ${pattern}    Set Variable    UDP DL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=3 trf_id=3 dir=dl rtp_codec=${rtp_codec}
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${cmd}=     Catenate         qosflow_disp
    ${output}      wts.execute egate command        cmd=${cmd}   pass_regexp=gbr    timeout=10    alias=${alias}
    Log to Console    ${output}
    Log to Console     Started GBR DL + UL Traffic for UE=${Param.Context.UeId1}

Stop Generating Traffic
    [Arguments]    ${ue}=1    ${bearer}=2    ${alias}=default
    [Documentation]    Stop generating traffic for one UE
    ...    :param ue: UE id
    ...    :param bearer: configured bearer
    ...
    Log to Console    Stopping DL + UL Traffic...
    ${output}      wts.execute egate command        cmd=trf_data_stop ue=${ue} id=${bearer}     alias=${alias}
    # ${output}   wts.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}

Display Qfi stats
    [Arguments]    ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1    ${alias}=default
    ${cmd}=   Catenate       qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=bi
    ${output}    wts.execute egate command And Wait For Data     cmd=${cmd}    alias=${alias}
    Log to Console    ${output}

Display Ue Statistics
    # [Arguments]     ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1     ${alias}=default
    [Arguments]     ${alias}=default
    Display Qfi stats    ue_id=${Param.Context.UeId1}    alias=${alias}
    ${cmd}=   Catenate     uec_stats display type=cell_data_pdcp enb=${Param.Context.gNBId} cell=1 format=short
    ${output}    wts.execute egate command And Wait For Data     cmd=${cmd}      alias=${alias}
    Log to Console    ${output}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    common_Dss_SA_NSA.Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    common_Dss_SA_NSA.Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ${output}    wtsemu.Read Wtsemu Output Until Re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Test SgNB Addition PRACH
    ${capture_path}      CallSetup.SgNB Addition to ENB          ueSetting=${UE_SIMPLE_CellDSS}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${capture_path}
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${capture_path}    ${testCaseDir}
    Run Keyword And Ignore Error    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}

5G Ue Attach Check
   [Arguments]    ${msg_e}=${EMPTY}
   ${verdict}    run keyword and return status    should contain    ${msg_e}    ${UE_attach_pattern}
   ${msg}   set variable if    '${verdict}'=='True'    5g Attach is successful
   ...   ELSE                                          5g Attach is FAILED
   Dated log      ${msg}
   should contain    ${msg}    successful

NSA Start Traffic
    [Arguments]    ${ue_id}    ${bearer_id}     ${dir}    ${mbps}    ${trf_id}=1   ${alias}=default
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start Traffic | 1 | 2 | ul | 10 |
    Log To Console    start ${dir} traffic [ue=${ue_id}]...
    wts.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir\=${dir} mbps\=${mbps} trf_id\=${trf_id}     alias=${alias}
    Sleep    5s    reason=wait ${dir} traffic is stable

NSA Stop Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${trf_id}=1   ${alias}=default
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Stop Traffic | 1 | 2 | dl |
    Log To Console    stop ${dir} traffic [ue=${ue_id}]...
    wts.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id}    alias=${alias}

Start Generating "${ul_rate}"mbps UL and "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on NSA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ul_rate:  the volume of uplink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ${pattern}    Set Variable    UDP DL TRF
    ${cmd}=     Catenate         trf_data_start ue\=${Param.Context.UeId1} id\=2 dir\=dl mbps\=${dl_rate} trf_id\=1
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    ${pattern}    Set Variable    UDP UL TRF:
    ${cmd}=     Catenate         trf_data_start ue\=${Param.Context.UeId1} id\=2 dir\=ul mbps\=${ul_rate} trf_id\=1
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    Log to Console     Started DL + UL Traffic for UE=${Param.Context.UeId1}

NSA Start Generating "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on NSA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ${pattern}    Set Variable    UDP DL TRF
    ${cmd}=     Catenate         trf_data_start ue\=${Param.Context.UeId1} id\=2 dir\=dl mbps\=${dl_rate} trf_id\=1
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    Log to Console     Started DL Traffic for UE=${Param.Context.UeId1}

Stop Generating NSA Traffic
    [Arguments]    ${ue}=1    ${bearer}=2
    [Documentation]    Stop generating traffic for one UE
    ...    :param ue: UE id
    ...    :param bearer: configured bearer
    ...
    Log to Console    Stopping DL + UL Traffic...
    ${output}      wts.execute egate command        cmd=trf_data_stop ue=${ue} id=${bearer}
    # ${output}   wts.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    # ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}

DSS_5g_NSA_UL_DL_Traffic
   [Arguments]         ${param}      ${ul_rate}=15      ${dl_rate}=80    ${alias}=default
   Init Sequence       ${param}

   Step       common_Dss_Keywords.Start capture Bip and Xp for DSS     argument=DSS_5g_NSA_UL_DL_Traffic.wL1L2.wXp
   Step       Start Generating "${ul_rate}"mbps UL and "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on NSA using alias "${alias}"
   Step       common_Dss_Keywords.Stop capture Bip and Xp for DSS      depends=common_Dss_Keywords.Start capture Bip and Xp for DSS
   Step       common_Dss_SA_NSA.Display Ue Statistics       argument=${alias}

Display 5g NSA bearer stats
    [Arguments]    ${ue_id}=1     ${trf_id}=1     ${alias}=default
    # scg => only 5G throughput
    ${cmd}=   Catenate       bearer_stats ue=${ue_id} id=2 dir=bi trf_id=${trf_id} type=l3
    # dc_cell_group=scg
    ${output}    wts.execute egate command And Wait For Data     cmd=${cmd}    alias=${alias}
    Log to Console    ${output}

Display Ue NSA Statistics
    # [Arguments]     ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1     ${alias}=default
    [Arguments]     ${alias}=default
    Display 5g NSA bearer stats    ue_id=${Param.Context.UeId1}    alias=${alias}
    ${cmd}=   Catenate     uec_stats display type=cell_data_pdcp enb=${Param.Context.gNBId} cell=1 format=short
    ${output}    wts.execute egate command And Wait For Data     cmd=${cmd}      alias=${alias}
    Log to Console    ${output}

# for SA ?
# run keyword and ignore error       Verify NSA Bearer Stats     id=2      trf_id=2     ue=1     dir=dl    tx_rx_max_diff_pkts=${100}
# run keyword and ignore error       Verify NSA Bearer Stats     id=2      trf_id=2     ue=1     dir=ul    tx_rx_max_diff_pkts=${100}
Verify NSA Bearer Stats
    [Documentation]     Verify Bearer Stats for specific data
    [Arguments]            ${id}=2        ${trf_id}=1     ${ue}=1      ${dir}=dl     ${type}=l3        ${alias}=default
    ...   ${tx_rx_max_diff_pkts}=${10}
    ${bearer_stats}=    wts.execute egate command And Wait For Data     bearer_stats ue=${ue} id=${id} dir=${dir} type=${type} trf_id=${trf_id}
    ...    pass_regexp=Average packet interval         alias=${alias}
    ${total_pkts_received}=   Get regexp matches    ${bearer_stats}     Total packets received (.*)    1
    ${total_pkts_received}   convert to integer  ${total_pkts_received[0].strip()}
    ${total_pkts_sent}=   Get regexp matches    ${bearer_stats}     Total packets sent (.*)    1
    ${total_pkts_sent}   convert to integer  ${total_pkts_sent[0].strip()}
    should not be equal as integers  ${total_pkts_received}    0
    ${pkts_diff}=  evaluate  ${total_pkts_sent}-${total_pkts_received}
    run keyword if   ${pkts_diff} > ${tx_rx_max_diff_pkts}   fail
    ...   msg=Data Transfer Failed, packets sent=${total_pkts_sent} packets received=${total_pkts_received}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Convert Dictionary to Parameter String
    [Documentation]
    ...
    ...    | kwargs | dictionary of pairs "parameter:value" |
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   &{kwargs}
    ${command_args}   Set Variable   ${EMPTY}
    FOR   ${key}   IN   @{kwargs}
       ${value}   Collections.Get From Dictionary   ${kwargs}   ${key}
        ${command_args}   Set Variable   ${command_args} ${key}=${value}
    END
    [Return]   ${command_args}

Trigger LTE dual connectivity and analyze Output
    [Documentation]
        ...    eNB command to trigger LTE-NR dual connectivity for bearers.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                 |
    ...    | bearer_id      | bearer id configured in WTS configuration (e.g. 9,8)  |
    ...    | target_gnb     | target gNB id                                         |
    ...    | target_cells   | target gNB cells                                      |
    ...    | type           | type of dual connectivity                             |
    ...
    ...    *Returns*   egate analysis accroding to parameters
    [Arguments]  ${wts_alias}=ap_egate    ${ue_id}=11   ${bearer_id}=2   ${target_gnb}=2   ${target_cells}=1   ${type}=split_scg
    ...          ${target_path}=/tmp/egate_ouput.json    ${regex_search}=${EMPTY}
    ${status}  ${egate_output}   Run keyword and ignore Error  Trigger LTE-NR dual connectivity for bearers    wts_alias=${wts_alias}
    ...    ue_id=${ue_id}
    ...    bearer_id=${bearer_id}   target_gnb=${target_gnb}
    ...    target_cells=${target_cells}   type=${type}
    Analyze egate log  status=${status}  egate_output=${egate_output}    target_path=${target_path}    ue_id=${ue_id}  regex_search=${regex_search}
    [return]    ${egate_output}

Trigger LTE-NR dual connectivity for bearers
    [Documentation]
    ...    eNB command to trigger LTE-NR dual connectivity for bearers.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                 |
    ...    | bearer_id      | bearer id configured in WTS configsuration (e.g. 9,8)  |
    ...    | target_gnb     | target gNB id                                         |
    ...    | target_cells   | target gNB cells                                      |
    ...    | type           | type of dual connectivity                             |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${wts_alias}=ap_egate    ${ue_id}=11   ${bearer_id}=2   ${target_gnb}=2   ${target_cells}=1   ${type}=split_scg
    ${output}   common_Dss_Keywords.Send Egate Command and verify output
    ...   wts_alias=${wts_alias}
    ...   cmd=enb_ue_dc_start ue=${ue_id} bearer=${bearer_id} target_gnb=${target_gnb} target_cells=${target_cells} type=${type}
    ...   pass_regexp=reported successful RA
    BuiltIn.Log   LTE-NR dual connectivity of UE${ue_id} with bearer${bearer_id} to gNB${target_gnb} and cell${target_cells} is successful
    ...   console=yes
    BuiltIn.Sleep   1s   reason=wait command to be executed
    [Return]   ${output}

Analyze egate log
    [Documentation]  Analyzes egate output and looks for messages with a given regular expression
    [Arguments]  ${status}  ${egate_output}  ${target_path}  ${ue_id}  ${regex_search}=${EMPTY}
    Run Keyword if  '${status}'=='FAIL'  BuiltIn.Log  ue_${ue_id} was not attached sucessfully.  level=Error  console=yes
    ${regex_search}=  Run Keyword If  'not ${regex_search}'  Create List  eventId event[A,B]\\d  frequencyBandList
    egate_analyzer.analyze_egate_output  egate_output=${egate_output}  target_file_path=${target_path}  ue_id=${ue_id}
    ...  regex_search=${regex_search}

Attach UE to LTE
    [Documentation]
    ...    Initiates UE Attach procedure to LTE cell
    ...
    ...    | ue_id                  | ue_id configured in WTS configuration                         |
    ...    | emergency              | toggle for Emergency Attach (not applicable for NB-IoT UE)    |
    ...    | pdn_connectivity_type  | IP version of PDN connectivity                                |
    ...    | kwargs                 | dictionary of pairs "parameter:value"                         |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${wts_alias}    ${ue_id}=11   ${emergency}=off   ${pdn_connectivity_type}=auto   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ${output}   common_Dss_Keywords.Send Egate Command and verify output
    ...   cmd=ue_attach id=${ue_id} emergency=${emergency} pdn_connectivity_type=${pdn_connectivity_type}${command_args}
    ...   pass_regexp=UE IS ACTIVE
    ...   wts_alias=${wts_alias}
    BuiltIn.Log    UE${ue_id} is attached to LTE    console=yes
    [Return]   ${output}

Update dual connectivity parameters
    [Documentation]
    ...
    ...    | id             | local identifier for eNodeB / gNodeB                                              |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. serving_cell_index_range_scg=5:31)    |
    ...
    [Arguments]   ${wts_alias}    ${id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    common_Dss_Keywords.Send Egate Command and verify output   cmd=enb_endc_param id=${id}${command_args}   wts_alias=${wts_alias}
    BuiltIn.Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   Dual connectivity with id=${id} is updated with${command_args}   console=yes

Run NSA Attach Script
    [Arguments]   ${wts_alias}    ${ue_id}=1    ${cell}=1    ${bearer_id}=2
    ${egate_output}=  Run Keyword  Attach UE to LTE  ue_id=${ue_id}  wts_alias=${wts_alias}
    ${rnti}=    nps_dss_tools.fetch_rnti_from   ${egate_output}
    BuiltIn.log    Lte rnti=${rnti}      console=yes
    Run Keyword  Update dual connectivity parameters  id=1  serving_cell_index_range_scg=5:31  wts_alias=${wts_alias}
    Log to Console  Performing Sgnb Addition
    Log to console  Triggering LTE-NR dual connectivity for UE ${ue_id} on cell ${cell} for bearer ${bearer_id}
    ${status}    ${egate_output}=  Run Keyword And Ignore Error
    ...  Trigger LTE dual connectivity and analyze Output  wts_alias=${wts_alias}  ue_id=${ue_id}
    ...                                                    bearer_id=${bearer_id}  target_cells=${cell}
    ...                                                    wts_alias=${wts_alias}
    ...                                                    target_path=${testCaseDir}/nsa_attach.json
    Run Keyword If    '${status}'=='FAIL'    BuiltIn.Log  UE ${ue_id} was not attached successfully  level=ERROR  console=yes
    ${rnti}=   Run Keyword If    '${status}'=='PASS'   nps_dss_tools.fetch_rnti_nsa_from   ${egate_output}
    ...                              ELSE              set variable     ${0}
    BuiltIn.log    NR rnti=${rnti}   console=yes

ute_wtssim NSA Start Generating "${dl_rate}"mbps DL Traffic for Ue "${Param.Context.UeId1}" on NSA using alias "${alias}"
    # [Arguments]    ${dl_rate}=1    ${ul_rate}=1    ${ue}=1    ${bearer}=2
    # [Arguments]    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id
    ...
    ${pattern}    Set Variable    UDP DL TRF
    ${cmd}=     Catenate         trf_data_start ue\=${Param.Context.UeId1} id\=2 dir\=dl mbps\=${dl_rate} trf_id\=1
    ${output}      ute_wtssim.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}     ${pattern}    partial_match=True
    Log to Console    ${output}
    Log to Console     Started DL Traffic for UE=${Param.Context.UeId1}

Display 5g NSA bearer stats Using ute_wtssim
    [Arguments]    ${ue_id}=1     ${trf_id}=1     ${alias}=default
    # scg => only 5G throughput
    ${cmd}=   Catenate       bearer_stats ue=${ue_id} id=2 dir=bi trf_id=${trf_id} type=l3
    # dc_cell_group=scg
    ${output}    ute_wtssim.execute egate command And Wait For Data     cmd=${cmd}    alias=${alias}
    Log to Console    ${output}

Display Ue NSA Statistics Using ute_wtssim
    # [Arguments]     ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1     ${alias}=default
    [Arguments]     ${alias}=default
    Display 5g NSA bearer stats Using ute_wtssim    ue_id=${Param.Context.UeId1}    alias=${alias}
    ${cmd}=   Catenate     uec_stats display type=cell_data_pdcp enb=${Param.Context.gNBId} cell=1 format=short
    ${output}    ute_wtssim.execute egate command And Wait For Data     cmd=${cmd}      alias=${alias}
    Log to Console    ${output}

