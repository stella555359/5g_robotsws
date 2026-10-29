*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.rfrl.utilities.dcap.ute_dcap.UteDcap  WITH NAME  dcap
Library    taf.sw.dcap.rd  WITH NAME  rd

*** Keywords ***
#####################################   DCAP Basic Keywords   #####################################
Start DCAP Session
    [Documentation]  Description:           DCAP session starting
    ...              Return:                connection alias
    ...              Output:                str
    ...              Author:                mateusz.majkusiak@nokia.com
    ...              Maintainer:            PM Team
    ...              Last Modification:     2023-06-07 made by mateusz.majkusiak@nokia.com
    [Arguments]      ${host}                 # host ip, typically LMP/m-plane IP
    ...              ${port}=9443            # DCAP connection port
    ...              ${alias}=dcap_pm        # connection alias
    ...              ${rd_version}=dcapv3
    ...              ${secure}=${None}

    Run     DCAP_Basic_controller start
    Wait Until Keyword Succeeds  10x  10s  dcap.connect    host=${host}  port=${port}  rd_version=${rd_version}
    ...                                    secure=True  alias=${alias}
    [Return]    ${alias}

Stop DCAP Traces
    [Documentation]  Description:           DCAP session stopping
    ...              Return:                connection alias
    ...              Output:                None
    ...              Author:                mateusz.majkusiak@nokia.com
    ...              Maintainer:            PM Team
    ...              Last Modification:     2023-06-07 made by mateusz.majkusiak@nokia.com
    [Arguments]      ${alias}=dcap_pm
    ...              ${timeout}=300
    ...              ${result_id}=${None}                     # result id for logs
    ...              ${target_dir}=${BTS Files}/dcap_Syslog.zip    # logs target directory
    ...              ${log_type}=Syslog                       # type of log

    ${trace_id}=    Get From Dictionary  ${trace_id}  tracer_id
    Run Keywords    rd.Stop Trace  trace_id=${trace_id}  connection=${alias}  timeout=${timeout}
    ...    AND  Sleep  300
    Wait Until Keyword Succeeds  10x  10s    rd.Get Results  result_id=${result_id}  target_dir=${target_dir}  connection=${alias}  timeout=${timeout}
    dcap.Extract Logfile From Zip    path=${target_dir}  log_name=${log_type}  collect_trace_logs=${True}  delete_zip=${True}
    [Return]    ${alias}

#####################################   DCAP Results Collection   #####################################
Start DCAP SCF Collection
    [Documentation]  Description:           DCAP SCF.xml collection
    ...              Return:                filepath for extracted SCF.xml file
    ...              Output:                str
    ...              Author:                mateusz.majkusiak@nokia.com
    ...              Maintainer:            PM Team
    ...              Last Modification:     2023-06-07 made by mateusz.majkusiak@nokia.com
    [Arguments]      ${host}=192.168.255.129
    ...              ${port}=443
    ...              ${alias}=dcap_pm
    ...              ${timeout}=100
    ...              ${target_dir}=${BTS Files}/dcap_SCF.zip
    ...              ${log_type}=SCF

    &{bts_dict}=   Create Dictionary    host=${host}  port=${port}  username=Nemuadmin  password=nemuuser
    ${bts_dict}=    Create List    ${bts_dict}

    ${bts_custom_profile}=    Create List    scf

    ${trace_id}=    rd.Start Trace    bts=${bts_dict}  tag=${log_type}  bts_custom_profile=${bts_custom_profile}  wait_for_activation=${True}
    ...                               force=${True}  connection=${alias}
    ${trace_id}=    Get From Dictionary  ${trace_id}  tracer_id
    Wait Until Keyword Succeeds  10x  10s    rd.Get Results  target_dir=${target_dir}  result_id=${None}  connection=${alias}  timeout=${timeout}
    # Extra: Extact logfile from the archive
    ${log_filepath}=    dcap.Extract Logfile From Zip    path=${target_dir}  log_name=${log_type}  collect_trace_logs=${True}  delete_zip=${True}
    [Return]    ${log_filepath}

Stop DCAP Snapshot Collection
    [Documentation]  Description:           DCAP stop Snapshot collection
    ...              Return:                filepath for extracted Snapshot.zip file
    ...              Output:                str
    ...              Author:                mateusz.majkusiak@nokia.com
    ...              Maintainer:            PM Team
    ...              Last Modification:     2023-06-07 made by mateusz.majkusiak@nokia.com
    [Arguments]
    ...              ${alias}=dcap_pm
    ...              ${timeout}=100
    ...              ${target_dir}=${BTS Files}/dcap_Snapshot.zip
    ...              ${log_type}=Snapshot
#    ${trace_id}=    Get From Dictionary  ${trace_id}  tracer_id
#    Run Keywords    rd.Stop Trace  trace_id=${trace_id}  connection=${alias}  timeout=${timeout}
    Run Keywords    rd.Stop Trace  connection=${alias}  timeout=${timeout}
    ...     AND  Sleep  300
    Wait Until Keyword Succeeds  10x  10s    rd.Get Results  target_dir=${target_dir}  result_id=${None}  connection=${alias}  timeout=${timeout}
    ${log_filepath}=    dcap.Extract Logfile From Zip    path=${target_dir}  log_name=${log_type}  collect_trace_logs=True  delete_zip=True
    [Return]    ${log_filepath}

Start DCAP Snapshot Collection
    [Documentation]  Description:           DCAP Snapshot collection
    ...              Return:                filepath for extracted Snapshot.zip file
    ...              Output:                str
    ...              Author:                mateusz.majkusiak@nokia.com
    ...              Maintainer:            PM Team
    ...              Last Modification:     2023-06-07 made by mateusz.majkusiak@nokia.com
    [Arguments]      ${host}=192.168.255.129
    ...              ${port}=443
    ...              ${alias}=dcap_pm
    ...              ${timeout}=150
    ...              ${target_dir}=${BTS Files}/dcap_Snapshot.zip
    ...              ${log_type}=Snapshot

    &{bts_dict}=   Create Dictionary    host=${host}  port=${port}  username=Nemuadmin  password=nemuuser
    ${bts_dict}=    Create List    ${bts_dict}

#    ${gnb_custom_profile}=    Create List    immediateSnapshot_5g
#    ${enb_custom_profile}=    Create List    immediateSnapshot_4g
    ${bts_custom_profile}=    Create List    immediateSnapshot

    ${trace_id}=   rd.Start Trace    bts=${bts_dict}  tag=${log_type}  force=${True}  connection=${alias}
    ...                              bts_custom_profile=${bts_custom_profile}  wait_for_activation=${True}
#    [Return]    ${trace_id}
#    ...    gnb_custom_profile=${gnb_custom_profile}
#    ...    enb_custom_profile=${enb_custom_profile}
    ${trace_id}=    Get From Dictionary  ${trace_id}  tracer_id
    Run Keywords    rd.Stop Trace  trace_id=${trace_id}  connection=${alias}  timeout=${timeout}
    ...     AND  Sleep  300
    Wait Until Keyword Succeeds  10x  10s    rd.Get Results  target_dir=${target_dir}  result_id=${None}  connection=${alias}  timeout=${timeout}
    ${log_filepath}=    dcap.Extract Logfile From Zip    path=${target_dir}  log_name=${log_type}  collect_trace_logs=True  delete_zip=True
    [Return]    ${log_filepath}

Start DCAP Syslog Collection
    [Documentation]  Description:           Start Syslog collection on DCAP trace
    ...              Return:                dcap trace id
    ...              Output:                int
    ...              Author:                mateusz.majkusiak@nokia.com
    ...              Maintainer:            PM Team
    ...              Last Modification:     2023-06-07 made by mateusz.majkusiak@nokia.com
    [Arguments]      ${host}=192.168.255.129        # host ip, typically LMP/m-plane IP
    ...              ${port}=443                    # host connection port
    ...              ${alias}=dcap_pm               # connection alias
#    ...             ${bts_custom_profile}=       # [immediateSnapshot, scf, pmFiles, ipCapture]
#    ...             ${gnb_custom_profile}=       # [lteTracer_4g, condor4gTti, condor4gAa, condor4gSyslog,
#    ...                                             immediateSnapshot_4g, pmFiles4g, scf4g, cp_4g, condor4gL2]
#    ...             ${gnb_custom_profile}=       # [cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g,
#    ...                                             L2Ps_Component, L2Lo_Component, L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa,
#    ...                                             L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream]
    ...              ${duration}=-1
    ...              ${log_type}=Syslog

    ${enb_custom_profile}=    Create List    condor4gSyslog
    #    ${gnb_custom_profile}=    Create List    condor5gSyslog   To check if 5gsyslog can be collected with 4g one

    &{bts_dict}=   Create Dictionary    host=${host}  port=${port}  username=Nemuadmin  password=nemuuser
    ${bts_dict}=    Create List    ${bts_dict}
    ${trace_id}=   rd.Start Trace    bts=${bts_dict}  duraton=${duration}  connection=${alias}  tag=${log_type}  force=${True}
    ...                              wait_for_activation=${True}  enb_custom_profile=${enb_custom_profile}
    Set Test Variable    ${trace_id}
    [Return]    ${trace_id}
