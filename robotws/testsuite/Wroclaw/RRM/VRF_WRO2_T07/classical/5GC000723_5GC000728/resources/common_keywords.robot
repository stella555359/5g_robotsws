*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com


Library         taf.ue
Library         taf.transport.ssh   WITH NAME    taf_ssh
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/specific_keywords.py
Library         testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/connections.py   WITH NAME   wro_6_connections

Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/specific_keywords.py


*** Keywords ***
Assign inactivity timer
    ${scf}=  AdminUtils.download_current_scf
    ${srb}=  get_single_parameter_value_from_scf_file    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/srbInactivityTimerSA
             ...                                         ${scf}
    ${drb}=  get_single_parameter_value_from_scf_file    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/drbInactivityTimerSA
             ...                                         ${scf}
    ${srb}=  Set variable   ${srb[0]}
    ${drb}=  Set variable   ${drb[0]}
    ${max}=	 Set variable if               ${drb} >= ${srb}   ${drb}   ${srb}
    Set suite variable                     ${max_timer}  ${max}
    ${sum}=  Evaluate                      ${max} + 30
    Set suite variable                     ${inactivity_timer}  ${sum}
    Set suite variable                     ${srbInactivityTimerSA}  ${srb}
    Set suite variable                     ${drbInactivityTimerSA}  ${drb}


Get time from ASIK
    ${alias}=  connect_to_smod
    ${smod_time}   taf_ssh.execute   command=date +"%T"   connection=${alias}
    [Return]   ${smod_time}


Wait till UE will entered IDLE state
    BuiltIn.Sleep  ${inactivity_timer}s


Check if UE goes to idle at correct time
    [Arguments]   ${log_file}   ${inactivity_start_time}   ${pcap_num}=0
    ${detach_time} =   Get time from pcap   ${log_file}   ${pcap_num}
    ${timedelta} =     Return timedelta   ${inactivity_start_time}   ${detach_time}
    Compare timedelta and inactivity timer with deviation   delta=${timedelta}   timer=${max_timer}   deviation=12
    Analyze detach from log given log   ${log_file}
