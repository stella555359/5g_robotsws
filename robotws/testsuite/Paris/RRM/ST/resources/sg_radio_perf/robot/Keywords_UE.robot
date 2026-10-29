*** Settings ***
Documentation
...      AUTHOR (I&V):     Annie Wong     annie.wong@nokia.com
...      last update: 08/09/20 (bypass_allocate_ue)
...                   28/09/20 use ute_ue traffic ressource if iperf2 use with Android UE
...                   27/01/21  ad traffic simultaneous uldl
...                   02/03/21  fix IPERF_VERSION_PREFERENCE
...                   28/05/21  no need to get ue_ip for prisma, modify keyword to allow multi ue

#Library           ute_ue                          WITH NAME       ue
Library           taf.ue                          WITH NAME       ue
Library           taf.transport.ssh               WITH NAME       ssh

Library           ../../Tti_Trace.py
Library           ../../Ue_address.py     WITH NAME     ue_addr

Resource          ../../pm_collection.robot
Resource          Keywords_prisma_real4G_realEPC.robot
Resource          Keywords_qualcomm.robot
Resource          ../../iperf_traffic.robot
Resource          Keywords_iperf3_qualcomm.robot
Resource          Keywords_iperf_prisma.robot
Resource          ute_cfg_files_mgt.robot

*** Keywords ***
# updated
Setup UE
    [Documentation]     Setup Prisma LSU Start Mosaic Connect to TSTM, or UE Reserve (QCT)
    ...     :param ue_capabilities    only used for QCT, not in use for PRISMA
    ...     :param ue_index           0 for first UE in __ini__.py
    [Arguments]         ${ue_index}=${0}         ${ue_capabilities}=REAL_ANDROID_UE
    ${ue_type_model}=         ute_cfg_files_mgt.Get UE architecture     ue_id=${ue_index}
    run keyword if     '${ue_type_model}'=='PRISMA'
    ...    Setup Prisma LSU Start Mosaic Connect to TSTM
    run keyword if     '${ue_type_model}'=='QCT'    Run Keywords
    ...    Keywords_qualcomm.Ue reserve with index and ensure detach
    ...                      ue_index=${ue_index}   capabilities=${ue_capabilities}
    ...    AND     Set Suite Variable     ${BYPASS_UE_MULTI_ALLOC}    True
    # UE is reserved successfully, for qualcomm ue, set  BYPASS_UE_MULTI_ALLOC to bypass next ue reservation
    Return from Keyword        ${ue_type_model}

# updated
Start UE attach
    [Arguments]         ${ue_index}=${0}
    ${ue_type_model}=         ute_cfg_files_mgt.Get UE architecture      ue_id=${ue_index}
    Attach UE known Type      ue_type_model=${ue_type_model}     ue_index=${ue_index}
    Return from Keyword        ${ue_type_model}

# new
Attach UE known Type
    [Documentation]     to replace "Start UE attach" in usage when ue type is known
    ...     :param ue_type_model   PRISMA, QCT
    ...     :param ue_index        0 for first UE in __ini__.py
    [Arguments]         ${ue_type_model}      ${ue_index}=${0}
    run keyword if   '${ue_type_model}'=='PRISMA'    Launch Airmosaic Test Scenario
    run keyword if   '${ue_type_model}'=='QCT'       Keywords_qualcomm.Ue attach with index   ue_index=${ue_index}

# updated
Release UE
    [Arguments]         ${ue_index}=${0}
    ${ue_type_model}=         ute_cfg_files_mgt.Get UE architecture     ue_id=${ue_index}
    Release UE known Type     ue_type_model=${ue_type_model}     ue_index=${ue_index}

# new
Release UE known Type
    [Documentation]     to replace "Release UE" in usage when ue type is known
    ...     :param ue_type_model   PRISMA, QCT
    ...     :param ue_index        0 for first UE in __ini__.py
    [Arguments]         ${ue_type_model}      ${ue_index}=${0}
    run keyword if   '${ue_type_model}'=='PRISMA'   run keyword and ignore error
    ...                                                 Stop Airmosaic scenario and Stop LSU
    run keyword if   '${ue_type_model}'=='QCT'     Keywords_qualcomm.Ue detach with index    ue_index=${ue_index}

# updated
Allocate UE Make Call
    [Documentation]      Execute L3 Call
    [Arguments]        ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE
    Log     Setup UE on UE index=${ue_index}    console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=       Setup UE       ue_index=${ue_index}    ue_capabilities=${ue_capabilities}
    Log     Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type      ue_type_model=${ue_type_model}     ue_index=${ue_index}
    sleep                   5
    Log    Detach UE   console=${DEBUG_MODE_CONSOLE}
    Release UE known Type     ue_type_model=${ue_type_model}     ue_index=${ue_index}

# updated
Allocate UE Make Call and Collect Pm files in TestsuiteDir
    [Documentation]    Purpose of keyword is to execute below steps:
    ...              - reserve/setup UE
    ...              - Wait the next PM period
    ...              - Attach the UE
    ...              - Detach the UE
    ...              - Wait the end of the PM period
    ...              - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    [Arguments]     ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    Log      Setup UE   console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=       Setup UE       ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    #added additional_waiting_time_sec: pm files are created on gNB with 1min delay on our gNB
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=15
    ...        gnb=${gNB}

    Log     Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type      ue_type_model=${ue_type_model}     ue_index=${ue_index}
    sleep                   5
    run keyword if     '${ue_type_model}'=='PRISMA'    sleep    ${SCE_DURATION}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Release UE known Type    ue_type_model=${ue_type_model}     ue_index=${ue_index}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}
    ${res_path}=    set variable    ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testsuite
    Log       last period pm file==${res}   console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable      ${PM_PATH}              ${res_path}
    Set Suite Variable      ${PM_FILENAME}          ${res}

# updated
Allocate UE Make Call and Collect Pm files in TestcaseDir
    [Documentation]    Purpose of keyword is to execute below steps:
    ...              - reserve/setup UE
    ...              - Wait the next PM period
    ...              - Attach the UE
    ...              - Detach the UE
    ...              - Wait the end of the PM period
    ...              - Collect the PM reports and store in path ${OUTPUT_DIR}/${SUITE_NAME}/$${TESTNAME}/gnb_pmcounters
    [Arguments]     ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    Log      Setup UE   console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=         Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    #added additional_waiting_time_sec: pm files are created on gNB with 1min delay on our gNB
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=15
    ...        gnb=${gNB}

    Log     Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type       ue_type_model=${ue_type_model}     ue_index=${ue_index}
    sleep                   5
    run keyword if     '${ue_type_model}'=='PRISMA'    sleep    ${SCE_DURATION}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Release UE known Type    ue_type_model=${ue_type_model}     ue_index=${ue_index}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}
    ${res_path}=    set variable     ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testsuite
    Log       last period pm file==${res}   console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable      ${PM_PATH}              ${res_path}
    Set Suite Variable      ${PM_FILENAME}          ${res}

#### call scenario with traffic

# updated
Allocate UE Make Call with Traffic and Collect PMfiles in TestcaseDir
    [Documentation]    Purpose of keyword is to execute below steps :
    ...        - reserve/setup UE
    ...        - Wait the next PM period
    ...        - Attach the UE
    ...        - Retrieve the UE IP address
    ...        - Do a UL or DL traffic
    ...        - Detach the UE
    ...        - Wait the end of the PM period
    ...        - Collect the PM files and save in path ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters

    [Arguments]      ${traffic_direction}     ${tput}     ${traffic_duration}    ${len}=1000
    ...              ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    Log      Setup UE    console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=        Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=15
    ...        gnb=${gNB}

    Log      Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type       ue_type_model=${ue_type_model}     ue_index=${ue_index}
    Sleep          3s

    # for case Prisma, no need to get ue_ip now, will be retrieved from traffic keyword
    ${ip_ue}=   run keyword if    '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...                           ue_addr.Get UE IP address        ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    ...       ELSE        set variable    None

    Run Keyword If     '${traffic_direction}'=='DL'      Start TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}
    #   Start TrafficDL    distantip=${ip_ue}   tput=${tput}   duration=${traffic_duration}   ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'      Start TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}
    #   Start TrafficUL    distantip=${ip_ue}   tput=${tput}   duration=${traffic_duration}   ueid=${ue_index}

    Log      Detach UE   console=${DEBUG_MODE_CONSOLE}
    Release UE known Type     ue_type_model=${ue_type_model}     ue_index=${ue_index}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testcase
    Log       last period pm file=${res}   console=${DEBUG_MODE_CONSOLE}

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable      ${PM_PATH}          ${res_path}
    Set Test Variable      ${PM_FILENAME}      ${res}

    Run Keyword If    '${traffic_direction}'=='DL'     Stop TrafficDL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'     Stop TrafficUL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}


# updated
Allocate UE Make Call with Traffic and Collect Traffic Period PMfiles in TestcaseDir
    [Documentation]    Purpose of keyword is to execute below steps :
    ...        - reserve/setup UE
    ...        - Attach the UE, get UE Ip
    ...        - Wait the next PM period
    ...        - Do a UL or DL traffic
    ...        - Detach the UE
    ...        - Wait the end of the PM period
    ...        - Collect the PM files and save in path ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters

    [Arguments]      ${traffic_direction}     ${tput}     ${traffic_duration}   ${len}=1000
    ...              ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    Log      Setup UE    console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=        Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log      Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type       ue_type_model=${ue_type_model}     ue_index=${ue_index}
    Sleep          3s

    # for Prisma case, ue_ip will be retrieved from traffic keyword
    ${ip_ue}=   run keyword if   '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...                        ue_addr.Get UE IP address           ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    ...             ELSE        set variable    None
    #Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=15
    ...        gnb=${gNB}

    Run Keyword If     '${traffic_direction}'=='DL'      Start TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}
    #   Start TrafficDL    distantip=${ip_ue}   tput=${tput}   duration=${traffic_duration}   ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'      Start TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}
    #   Start TrafficUL    distantip=${ip_ue}   tput=${tput}   duration=${traffic_duration}   ueid=${ue_index}

    Log           Detach UE   console=${DEBUG_MODE_CONSOLE}
    Release UE known Type        ue_type_model=${ue_type_model}     ue_index=${ue_index}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testcase
    Log           last period pm file=${res}   console=${DEBUG_MODE_CONSOLE}

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable      ${PM_PATH}          ${res_path}
    Set Test Variable      ${PM_FILENAME}      ${res}
    Run Keyword If    '${traffic_direction}'=='DL'     Stop TrafficDL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'     Stop TrafficUL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}


# updated
Allocate UE Make Call with Traffic and Collect PMfiles and TTI traces in TestcaseDir
    [Documentation]    Purpose of keyword is to execute below steps :
    ...        - reserve/setup UE
    ...        - Wait the next PM period
    ...        - Configure and start the TTI Traces
    ...        - Attach the UE
    ...        - Retrieve the UE IP address
    ...        - Do a UL or DL traffic
    ...        - Detach the UE
    ...        - Stop TTI Trace  (add create cnx to abil as failure seen frequently on one TL)
    ...        - Wait the end of the PM period
    ...        - Collect the PM files and save in path ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    ...        - Collect the TTI Traces  (add create cnx to abil as failure seen frequently on one TL)
    ...        New argument ${tti_abil_cnx_option} : xeonA or xeonB
    ...        for the TTI cnx  use of ${GNB_ABIL0_IP} or ${GNB_ABIL0_xeonA}  if gnb in 19B
    ...                         use of ${GNB_ABIL0_xeonB}                     if gnb in 20B
    ...
    [Arguments]      ${tti_target_path}      ${tti_trace_nbfiles}     ${traffic_duration}     ${tput}
    ...              ${traffic_direction}    ${len}=1000     ${tti_abil_cnx_option}=xeonB
    ...              ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    Log           Setup UE    console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=      Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

    # Open a connection to the ASIK master and the ABIL XEON-A / or XEON-B
    ${asik_cnx}         ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                                    ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                    ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				    alias=asik_als
    #case 19B : need to connect to ${GNB_ABIL0_xeonA}
    #case 20A : need to connect to ${GNB_ABIL0_xeonB}
    ${_abil_ip}=   run keyword if     '${tti_abil_cnx_option}'=='xeonA'   set variable    ${GNB_ABIL0_xeonA[${gNB}]}
    ...                     ELSE                                          set variable    ${GNB_ABIL0_xeonB[${gNB}]}

    ${abil_cnx}    ssh.connect_to      ${_abil_ip}
    ...                                ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                 proxy=asik_als

    Log         Start TTI Traces  console=${DEBUG_MODE_CONSOLE}
    Start tti traces     ${abil_cnx}        trace_nbfiles=${tti_trace_nbfiles}
    Sleep          5s

    Log         Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type          ue_type_model=${ue_type_model}     ue_index=${ue_index}
    Sleep          3s

    # for Prisma case, ue_ip will be retrieved from traffic keyword
    ${ip_ue}=   run keyword if   '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...                          ue_addr.Get UE IP address         ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    ...       ELSE        set variable    None
    # Log       UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}

    # run traffic for specified duration
    Run Keyword If     '${traffic_direction}'=='DL'      Start TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'      Start TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}

    Log         Detach UE   console=${DEBUG_MODE_CONSOLE}
    Release UE known Type         ue_type_model=${ue_type_model}     ue_index=${ue_index}
    Sleep          5s                   # Wait to be sure the detach is done before the stop of tti_trace

    #Stop tti traces     ${abil_cnx}   (defense: create again cnx)
    run keyword and ignore error    ssh.disconnect      connection=${asik_cnx}
    run keyword and ignore error    ssh.disconnect      connection=${abil_cnx}
    sleep   2s
    ${asik_cnx}   ssh.connect_to   ${GNB_AIRSCALE_IP[${gNB}]}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				               alias=asik_als
    ${abil_cnx}   ssh.connect_to   ${_abil_ip}  ${GNB_AIRSCALE_USERNAME[${gNB}]}  ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                            proxy=asik_als
    Stop tti traces     ${abil_cnx}

    # need to get PM before tti otherwise it could exceed the meas Period intervale
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testcase
    Log       last period pm file=${res}   console=${DEBUG_MODE_CONSOLE}

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable      ${PM_PATH}          ${res_path}
    Set Test Variable      ${PM_FILENAME}      ${res}

    log                 Collect TTI Traces   console=${DEBUG_MODE_CONSOLE}
    # Re open a connection to the ASIK master and the ABIL before collecting TTI traces  (for defense)
    run keyword and ignore error    ssh.disconnect      connection=${asik_cnx}
    run keyword and ignore error    ssh.disconnect      connection=${abil_cnx}
    sleep   2s
    ${asik_cnx}   ssh.connect_to   ${GNB_AIRSCALE_IP[${gNB}]}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				               alias=asik_als
    ${abil_cnx}   ssh.connect_to   ${_abil_ip}  ${GNB_AIRSCALE_USERNAME[${gNB}]}  ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                            proxy=asik_als

    ${tti_file}         Collect all tti traces     ${abil_cnx}    ${tti_target_path}

    Run Keyword If    '${traffic_direction}'=='DL'     Stop TrafficDL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'     Stop TrafficUL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}

    [Teardown]        run keywords          ssh.disconnect      connection=${asik_cnx}      AND
    ...                                     ssh.disconnect      connection=${abil_cnx}


# updated
Allocate UE Make call with Traffic After X seconds traffic Collect TTI traces
    [Documentation]    Purpose of keyword is to execute below steps :
    ...        - reserve/setup UE
    ...        - Configure and start the TTI Traces
    ...        - Attach the UE
    ...        - Retrieve the UE IP address
    ...        - Do a UL or DL traffic
    ...        - Detach the UE
    ...        - Stop TTI Trace
    ...        - Collect the TTI Traces
    ...        New argument ${tti_abil_cnx_option} : xeonA or xeonB
    ...        for the TTI cnx  use of ${GNB_ABIL0_IP} or ${GNB_ABIL0_xeonA}  if gnb in 19B
    ...                         use of ${GNB_ABIL0_xeonB}                     if gnb in 20B
    ...
    [Arguments]      ${tti_target_path}      ${tti_trace_nbfiles}
    ...              ${traffic_duration}     ${tput}     ${traffic_direction}   ${len}=1000
    ...              ${tti_abil_cnx_option}=xeonB     ${tti_duration_after_start_traffic}=2s
    ...              ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE
    ...              ${bypass_allocate_ue}=False

    Log             bypass Setup UE option=${bypass_allocate_ue}     console=${DEBUG_MODE_CONSOLE}
    run keyword if     '${bypass_allocate_ue}'!='True'
    ...              Setup UE       ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    # Open a connection to the ASIK master and the ABIL XEON-A / or XEON-B
    ${asik_cnx}         ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                                    ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                    ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				    alias=asik_als
    #case 19B : need to connect to ${GNB_ABIL0_xeonA}
    #case 20A : need to connect to ${GNB_ABIL0_xeonB}
    ${_abil_ip}=   run keyword if     '${tti_abil_cnx_option}'=='xeonA'   set variable    ${GNB_ABIL0_xeonA[${gNB}]}
    ...                     ELSE                                          set variable    ${GNB_ABIL0_xeonB[${gNB}]}

    ${abil_cnx}    ssh.connect_to      ${_abil_ip}
    ...                                ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                                proxy=asik_als

    Log                  Start TTI Traces  console=${DEBUG_MODE_CONSOLE}
    Start tti traces     ${abil_cnx}        trace_nbfiles=${tti_trace_nbfiles}
    Sleep        5s

    Log                  Attach UE   console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=        Start UE attach      ue_index=${ue_index}
    Sleep        3s

    # for prisma case, no need to get ue ip
    ${ip_ue}=   run keyword if    '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...                       ue_addr.Get UE IP address            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    ...       ELSE        set variable    None
    #Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}

    # start traffic processes :
    Run Keyword If     '${traffic_direction}'=='DL'     Start Process TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'      Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${traffic_duration}
    ...           tput=${tput}
    ...           ue_type_model=${ue_type_model}
    ...           len=${len}
    ...           ueid=${ue_index}

    Sleep        ${tti_duration_after_start_traffic}

    Stop tti traces     ${abil_cnx}
    Sleep       20s

    log                 Collect TTI Traces   console=${DEBUG_MODE_CONSOLE}
    # create again cnx (defense)
    run keyword and ignore error    ssh.disconnect      connection=${asik_cnx}
    run keyword and ignore error    ssh.disconnect      connection=${abil_cnx}
    sleep   2s
    ${asik_cnx}   ssh.connect_to   ${GNB_AIRSCALE_IP[${gNB}]}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				               alias=asik_als
    ${abil_cnx}   ssh.connect_to   ${_abil_ip}  ${GNB_AIRSCALE_USERNAME[${gNB}]}  ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                            proxy=asik_als
    ${tti_file}         Collect all tti traces       ${abil_cnx}    ${tti_target_path}

    Log                 Detach UE   console=${DEBUG_MODE_CONSOLE}
    Release UE known Type     ue_type_model=${ue_type_model}     ue_index=${ue_index}

    Run Keyword If    '${traffic_direction}'=='DL'     Stop TrafficDL UE known Type
    ...        ue_type_model=${ue_type_model}     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'     Stop TrafficUL UE known Type
    ...        ue_type_model=${ue_type_model}     ueid=${ue_index}
    [Teardown]        run keywords          ssh.disconnect      connection=${asik_cnx}      AND
    ...                                     ssh.disconnect      connection=${abil_cnx}


##### stop traffic keywords ######

# updated
Stop TrafficUL
    [Arguments]         ${ueid}=${0}
    ${ue_type_model}=      ute_cfg_files_mgt.Get UE architecture     ue_id=${ueid}
    Stop TrafficUL UE known Type     ue_type_model=${ue_type_model}     ueid=${ueid}

# updated
Stop TrafficDL
    [Arguments]         ${ueid}=${0}
    ${ue_type_model}=      ute_cfg_files_mgt.Get UE architecture     ue_id=${ueid}
    Stop TrafficDL UE known Type     ue_type_model=${ue_type_model}     ueid=${ueid}

# updated
Stop Traffic Simultaneous ULDL
    [Arguments]         ${ueid}=${0}
    ${ue_type_model}=         ute_cfg_files_mgt.Get UE architecture     ue_id=${ueid}
    Stop Traffic Simultaneous ULDL UE known Type       ue_type_model=${ue_type_model}     ueid=${ueid}

# new, to replace "Stop TrafficUL" in usage when ue type is already known
Stop TrafficUL UE known Type
    [Arguments]         ${ue_type_model}      ${ueid}=${0}
    run keyword if   '${ue_type_model}'=='PRISMA'
    ...      Keywords_iperf_prisma.Stop UL iperf pids for UE Index    ueid=${ueid}
    # ...    iperf_traffic.Stop traffic       direction=UL   ueid=${ueid}
    run keyword if   '${ue_type_model}'=='QCT'
    ...    Stop Data Transfer on Android    direction=ul   ue_index=${ueid}   iperf_version=${IPERF_VERSION_PREFERENCE}

# new, to replace "Stop TrafficDL" in usage when ue type is already known
Stop TrafficDL UE known Type
    [Arguments]         ${ue_type_model}      ${ueid}=${0}
    run keyword if   '${ue_type_model}'=='PRISMA'
    ...     Keywords_iperf_prisma.Stop DL iperf pids for UE Index       ueid=${ueid}
    # ...    iperf_traffic.Stop traffic       direction=DL   ueid=${ueid}
    run keyword if   '${ue_type_model}'=='QCT'
    ...    Stop Data Transfer on Android    direction=dl   ue_index=${ueid}   iperf_version=${IPERF_VERSION_PREFERENCE}

# new, to replace "Stop Traffic Simultaneous ULDL" in usage when ue type is already known
Stop Traffic Simultaneous ULDL UE known Type
    [Arguments]         ${ue_type_model}      ${ueid}=${0}
    run keyword if   '${ue_type_model}'=='PRISMA'      Run Keywords
    ...    Stop TrafficUL UE known Type      ue_type_model=${ue_type_model}   ueid=${ueid}       AND
    ...    Stop TrafficDL UE known Type      ue_type_model=${ue_type_model}   ueid=${ueid}
    run keyword if   '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'!='3'      Run Keywords
    ...    Stop TrafficUL UE known Type      ue_type_model=${ue_type_model}   ueid=${ueid}       AND
    ...    Stop TrafficDL UE known Type      ue_type_model=${ue_type_model}   ueid=${ueid}
    # killing all iperf process (traffic on all UEs)
    run keyword if   '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...      Keywords_iperf3_qualcomm.Stop simultaneous ULDL traffic iperf3

# unchanged
Stop Data Transfer on Android
    [Arguments]        ${direction}=ul   ${ue_index}=0   ${iperf_version}=2
    [Documentation]    Stop Data Transfer ul or dl, integrate the use of ute_ue for Android Mobile
    ...     :param iperf_version    iperf binary to use, values=2,3  (2: call taf lib, 3: call iperf3 keywords)
    ...                             Related to ${IPERF_VERSION_PREFERENCE} : ${custom['iPerf_version_preference']}
    run keyword if     '${iperf_version}'!='3'
    ...          ue.Stop Data Transfer   dt_name=DT_${direction}_UE${ue_index}

    run keyword if     '${iperf_version}'=='3' and '${direction}'=='ul'
    ...          Keywords_iperf3_qualcomm.Stop UL traffic iperf3     ueid=${ue_index}

    run keyword if    '${iperf_version}'=='3' and '${direction}'=='dl'
    ...          Keywords_iperf3_qualcomm.Stop DL traffic iperf3      ueid=${ue_index}


##### start traffic keywords ######

# updated
Start TrafficUL
    [Arguments]       ${distantip}     ${duration}     ${tput}     ${len}=1000   ${ueid}=0
    Start Process TrafficUL    distantip=${distantip}   duration=${duration}    tput=${tput}   len=${len}   ueid=${ueid}
    Log        traffic_duration=${duration} (sleep...)  console=${DEBUG_MODE_CONSOLE}
    Sleep         ${duration}

# updated
Start TrafficDL
    [Arguments]        ${distantip}     ${duration}     ${tput}     ${len}=1000    ${ueid}=0
    Start Process TrafficDL    distantip=${distantip}   duration=${duration}    tput=${tput}   len=${len}   ueid=${ueid}
    Log        traffic_duration=${duration} (sleep...)  console=${DEBUG_MODE_CONSOLE}
    Sleep         ${duration}

# new, to replace "Start TrafficUL" in usage when ue type is already known
Start TrafficUL UE known Type
    [Arguments]       ${distantip}     ${duration}     ${tput}     ${ue_type_model}   ${len}=1000   ${ueid}=0
    Start Process TrafficUL UE known Type
    ...    distantip=${distantip}
    ...    duration=${duration}
    ...    tput=${tput}
    ...    ue_type_model=${ue_type_model}
    ...    len=${len}
    ...    ueid=${ueid}
    Log           traffic_duration=${duration} (sleep...)  console=${DEBUG_MODE_CONSOLE}
    Sleep         ${duration}

# new, to replace "Start TrafficDL" in usage when ue type is already known
Start TrafficDL UE known Type
    [Arguments]        ${distantip}     ${duration}     ${tput}      ${ue_type_model}   ${len}=1000    ${ueid}=0
    Start Process TrafficDL UE known Type
    ...     distantip=${distantip}
    ...     duration=${duration}
    ...     tput=${tput}
    ...     ue_type_model=${ue_type_model}
    ...     len=${len}
    ...     ueid=${ueid}
    Log           traffic_duration=${duration} (sleep...)  console=${DEBUG_MODE_CONSOLE}
    Sleep         ${duration}

# updated
Start Traffic Simultaneous ULDL
    [Arguments]        ${distantip}     ${duration}     ${tput_ul}      ${tput_dl}    ${len}=1000    ${ueid}=0
    Start Process Traffic Simultaneous ULDL
    ...                distantip=${distantip}
    ...                duration=${duration}
    ...                tput_ul=${tput_ul}
    ...                tput_dl=${tput_dl}
    ...                len=${len}
    ...                ueid=${ueid}
    Log           traffic_duration=${duration} (sleep...)  console=${DEBUG_MODE_CONSOLE}
    Sleep         ${duration}


###  start traffic UL, DL, or ULDL, depending on type Prisma or QCT

# updated
Start Process TrafficUL
    [Arguments]         ${distantip}     ${duration}     ${tput}     ${len}=1000      ${ueid}=${0}
    ${ue_type_model}=       ute_cfg_files_mgt.Get UE architecture     ue_id=${ueid}
    Start Process TrafficUL UE known Type
    ...             distantip=${distantip}
    ...             duration=${duration}
    ...             tput=${tput}
    ...             ue_type_model=${ue_type_model}
    ...             len=${len}
    ...             ueid=${ueid}

# new, to replace "Start Process TrafficUL" in usage when ue type is already known
Start Process TrafficUL UE known Type
    [Arguments]         ${distantip}     ${duration}     ${tput}    ${ue_type_model}    ${len}=1000   ${ueid}=${0}
    run keyword if     '${ue_type_model}'=='PRISMA'
    ...   Launch Iperf TrafficUL UE Prisma      tput=${tput}   duration=${duration}   len=${len}  ueid=${ueid}
    run keyword if     '${ue_type_model}'=='QCT'
    ...         Start UDP Data Transfer on Android
    ...                                    duration=${duration}
    ...                                    tput=${tput}
    ...                                    direction=ul
    ...                                    distantip=${distantip}
    ...                                    ue_index=${ueid}
    ...                                    iperf_version=${IPERF_VERSION_PREFERENCE}

# updated
Start Process TrafficDL
    [Arguments]        ${distantip}     ${duration}     ${tput}    ${len}=1000     ${ueid}=${0}
    ${ue_type_model}=       ute_cfg_files_mgt.Get UE architecture     ue_id=${ueid}
    Start Process TrafficDL UE known Type
    ...             distantip=${distantip}
    ...             duration=${duration}
    ...             tput=${tput}
    ...             ue_type_model=${ue_type_model}
    ...             len=${len}
    ...             ueid=${ueid}

# new, to replace "Start Process TrafficDL" in usage when ue type is already known
Start Process TrafficDL UE known Type
    [Arguments]        ${distantip}     ${duration}     ${tput}    ${ue_type_model}   ${len}=1000   ${ueid}=${0}
    run keyword if     '${ue_type_model}'=='PRISMA'
    ...   Launch Iperf TrafficDL UE Prisma      tput=${tput}   duration=${duration}   len=${len}  ueid=${ueid}
    run keyword if     '${ue_type_model}'=='QCT'
    ...         Start UDP Data Transfer on Android
    ...                                    duration=${duration}
    ...                                    tput=${tput}
    ...                                    direction=dl
    ...                                    distantip=${distantip}
    ...                                    ue_index=${ueid}
    ...                                    iperf_version=${IPERF_VERSION_PREFERENCE}

# updated
Start Process Traffic Simultaneous ULDL
    [Arguments]        ${distantip}     ${duration}     ${tput_ul}      ${tput_dl}    ${len}=1000    ${ueid}=${0}
    ...    ${parallel_thread}=${EMPTY}
    # bypass robocop
    ${parallel_thread}    Set Variable    ${parallel_thread}
    ${ue_type_model}=       ute_cfg_files_mgt.Get UE architecture     ue_id=${ueid}
    Start Process Traffic Simultaneous ULDL UE known Type
    ...             distantip=${distantip}
    ...             duration=${duration}
    ...             tput_ul=${tput_ul}
    ...             tput_dl=${tput_dl}
    ...             ue_type_model=${ue_type_model}
    ...             len=${len}
    ...             ueid=${ueid}

# new, to replace Start Process Traffic Simultaneous ULDL" in usage when ue type is already known
Start Process Traffic Simultaneous ULDL UE known Type
    [Arguments]        ${distantip}    ${duration}    ${tput_ul}    ${tput_dl}    ${ue_type_model}
    ...                ${len}=1000     ${ueid}=${0}    ${parallel_thread}=${EMPTY}
    run keyword if     '${ue_type_model}'=='PRISMA'        Run Keywords
    ...             Start Process TrafficUL UE known Type
    ...                 distantip=${distantip}
    ...                 duration=${duration}
    ...                 tput=${tput_ul}
    ...                 ue_type_model=${ue_type_model}
    ...                 ueid=${ueid}
    ...                 len=${len}
    ...        AND   Start Process TrafficDL UE known Type
    ...                 distantip=${distantip}
    ...                 duration=${duration}
    ...                 tput=${tput_dl}
    ...                 ue_type_model=${ue_type_model}
    ...                 ueid=${ueid}
    ...                 len=${len}
    # android, and use of ute_ue lib (random port usage)
    run keyword if     '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'!='3'     Run Keywords
    ...             Start Process TrafficUL UE known Type
    ...                 distantip=${distantip}
    ...                 duration=${duration}
    ...                 tput=${tput_ul}
    ...                 ue_type_model=${ue_type_model}
    ...                 ueid=${ueid}
    ...                 len=${len}
    ...        AND   Start Process TrafficDL UE known Type
    ...                 distantip=${distantip}
    ...                 duration=${duration}
    ...                 tput=${tput_dl}
    ...                 ue_type_model=${ue_type_model}
    ...                 ueid=${ueid}
    ...                 len=${len}
    #qct, use of perf3
    run keyword if     '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...              Launch Iperf3 Traffic Simultaneous ULDL
    ...                    distantip=${distantip}
    ...                    duration=${duration}
    ...                    tput_ul=${tput_ul}
    ...                    tput_dl=${tput_dl}
    ...                    ueid=${ueid}
    ...                    len=${len}
    ...                    parallel_thread=${parallel_thread}


####  start traffic ul / dl / uldl processes, either iperf, iperf3, or android pluggin

# unchanged, but not used, replaced by Launch Iperf TrafficUL UE Prisma
Launch Iperf TrafficUL
    #  distantip is set to ${DLserver_uplane_ip}
    [Arguments]        ${duration}     ${tput}      ${ueid}=0
    iperf_traffic.Start Traffic
    ...            direction=UL
    ...            distantip=${DLserver_uplane_ip}
    ...            tput=${tput}
    ...            duration=${duration}
    ...            ueid=${ueid}
    sleep      5s
    Log        Print Iperf Applicative Tput   console=${DEBUG_MODE_CONSOLE}
    iperf_traffic.Stop iPerf Receiver Pid       traffic_direction=UL
    iperf_traffic.Print Applicative Tput     direction=UL

# unchanged, but not used, replaced by Launch Iperf TrafficDL UE Prisma
Launch Iperf TrafficDL
    #  ${distantip} is UE IP
    [Arguments]       ${distantip}    ${duration}     ${tput}     ${ueid}=0
    iperf_traffic.Start Traffic
    ...            direction=DL
    ...            distantip= ${distantip}
    ...            tput=${tput}
    ...            duration=${duration}
    ...            ueid=${ueid}
    sleep      5s
    Log        Print Iperf Applicative Tput   console=${DEBUG_MODE_CONSOLE}
    iperf_traffic.Stop iPerf Receiver Pid       traffic_direction=DL
    iperf_traffic.Print Applicative Tput     direction=DL

# new replacing "Launch Iperf TrafficUL"
Launch Iperf TrafficUL UE Prisma
    [Arguments]          ${tput}      ${duration}     ${len}=1000    ${ueid}=0
    Keywords_iperf_prisma.Start UL traffic process for UE Index
    ...               tput=${tput}
    ...               duration=${duration}
    ...               len=${len}
    ...               ueid=${ueid}
    sleep      5s

# new replacing "Launch Iperf TrafficDL"
Launch Iperf TrafficDL UE Prisma
    [Arguments]          ${tput}   ${duration}   ${len}=1000    ${ueid}=0
    Keywords_iperf_prisma.Start DL traffic process for UE Index
    ...               tput=${tput}
    ...               duration=${duration}
    ...               len=${len}
    ...               ueid=${ueid}
    sleep      5s

# unchanged, in use
Start UDP Data Transfer on Android
    [Arguments]        ${duration}   ${tput}   ${direction}=ul   ${distantip}=None   ${ue_index}=0
    ...                ${packet_size}=1400     ${iperf_version}=2
    [Documentation]    Data Transfer ul or dl, integrate the use of ute_ue for Android Mobile
    ...     :param iperf_version    iperf binary to use, values=2,3  (2: call taf lib, 3: call iperf3 keywords)
    ...                             Related to ${IPERF_VERSION_PREFERENCE} : ${custom['iPerf_version_preference']}
    ...     :param duration:        Duration of transmission, exaple: 600s
    ...     :param tput:            Expected tput, example 100Mbits/sec, 200Kbits/sec
    ...     :param ue_index         0
    ...     :param distantip: optional (only for iper3)
    ...
    ...     Keyword argument "ue alias" is the one used in setup / attach/ detach:
    ...     ue_alias=MYUE${ue_index}  and ${ue_capabilities}=REAL_ANDROID_UE

    ${tput_final}   set variable if    ${tput.endswith("K")} or ${tput.endswith("M")}    ${tput}bits/sec    ${tput}
    ${duration_s}   set variable if    not ${duration.endswith("s")}    ${duration}s     ${duration}

    run keyword if     '${iperf_version}'!='3'    run keywords
    ...             log      ue.Start Data Transfer :    console=${DEBUG_MODE_CONSOLE}     AND
    ...             log      tput=${tput_final}          console=${DEBUG_MODE_CONSOLE}     AND
    ...             log      duration=${duration_s}      console=${DEBUG_MODE_CONSOLE}     AND
    ...             log      direction=${direction}      console=${DEBUG_MODE_CONSOLE}     AND
    ...             ue.Start Data Transfer   dt_name=DT_${direction}_UE${ue_index}
    ...                                      ue_alias=MYUE${ue_index}
    ...                                      direction=${direction}
    ...                                      duration=${duration_s}
    ...                                      throughput=${tput_final}
    ...                                      protocol=udp
    ...                                      packet_size=${packet_size}
    #...             AND    Check Data Transfer is Alive     dt_name=DT_${direction}_UE${ue_index}
    run keyword if     '${iperf_version}'=='3' and '${direction}'=='ul'
    ...               Launch Iperf3 TrafficUL     distantip=${distantip}
    ...                                           duration=${duration}
    ...                                           tput=${tput}
    ...                                           ueid=${ue_index}
    run keyword if    '${iperf_version}'=='3' and '${direction}'=='dl'
    ...               Launch Iperf3 TrafficDL     distantip=${distantip}
    ...                                           duration=${duration}
    ...                                           tput=${tput}
    ...                                           ueid=${ue_index}

# unchanged, in use
Launch Iperf3 TrafficUL
    #  ${distantip} is UE IP
    [Arguments]        ${distantip}    ${duration}     ${tput}    ${ueid}=0
    Keywords_iperf3_qualcomm.Start UL traffic iperf3
    ...    distantip=${distantip}
    ...    tput=${tput}
    ...    duration=${duration}
    ...    ueid=${ueid}

# unchanged, in use
Launch Iperf3 TrafficDL
    #  ${distantip} is UE IP
    [Arguments]        ${distantip}    ${duration}     ${tput}      ${ueid}=0
    Keywords_iperf3_qualcomm.Start DL traffic iperf3
    ...    distantip=${distantip}
    ...    tput=${tput}
    ...    duration=${duration}
    ...    ueid=${ueid}

# unchanged, in use
Launch Iperf3 Traffic Simultaneous ULDL
    #  ${distantip} is UE IP
    [Arguments]        ${distantip}    ${duration}     ${tput_ul}     ${tput_dl}      ${ueid}=0
    ...    ${len}=1300    ${parallel_thread}=${EMPTY}
    Keywords_iperf3_qualcomm.Start simultaneous ULDL traffic iperf3
    ...    distantip=${distantip}
    ...    tput_ul=${tput_ul}
    ...    tput_dl=${tput_dl}
    ...    duration=${duration}
    ...    ueid=${ueid}
    ...    len=${len}
    ...    parallel_thread=${parallel_thread}

#### Prisma multi UE call / traffic sceanrio

# new: only wriiten for Multi UE Prisma at the moment, and UE_0 in TL must be Prisma type, as
# yamlPrisma.py only use tl.ue[0] to create generate_yaml_for_airmosaic
Multi UEs Call with Traffic and Collect Traffic Period PMfiles in TestcaseDir
    [Documentation]    Purpose of keyword is to execute below steps :
    ...        - reserve/setup UE (setup Airmosaic)
    ...        - Attach the UE (start sce)
    ...        - Wait the next PM period
    ...        - Do a UL or DL traffic on all UEs (list)
    ...        - Detach the UE
    ...        - Wait the end of the PM period
    ...        - Collect the PM files and save in path ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters

    [Arguments]     ${list_of_ues}   ${traffic_direction}   ${tput_ul}   ${tput_dl}
    ...             ${traffic_duration}     ${len}=1000     ${gNB}=0

    #### only UE_0 for Prisma
    Log      Setup UE    console=${DEBUG_MODE_CONSOLE}
    ${ue_type_model}=          Setup UE      ue_index=${list_of_ues[0]}
    #${ue_type_model}=         Setup UE      ue_index=${0}

    Run Keyword If  '${ue_type_model}'!='PRISMA'   Fail
    ...                 \n===Keyword only written for Prisma UE at the moment, Failed===

    #### only UE_0 UE_0 for Prisma
    Log      Attach UE   console=${DEBUG_MODE_CONSOLE}
    Attach UE known Type       ue_type_model=${ue_type_model}     ue_index=${list_of_ues[0]}
    #Attach UE known Type        ue_type_model=${ue_type_model}     ue_index=${0}
    Sleep          3s

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=5
    ...        gnb=${gNB}

    #### run traffic on all UEs in list
    Run Keyword If     '${traffic_direction}'=='DL'
    ...        Keywords_iperf_prisma.Start DL traffic process for List UEs
    ...              list_of_ues=${list_of_ues}    tput=${tput_dl}   len=${len}   duration=${traffic_duration}
    Run Keyword If     '${traffic_direction}'=='UL'
    ...        Keywords_iperf_prisma.Start UL traffic process for List UEs
    ...              list_of_ues=${list_of_ues}    tput=${tput_ul}   len=${len}   duration=${traffic_duration}
    Run Keyword If     '${traffic_direction}'=='ULDL'       run keywords
    ...        Keywords_iperf_prisma.Start DL traffic process for List UEs
    ...              list_of_ues=${list_of_ues}    tput=${tput_dl}   len=${len}   duration=${traffic_duration}
    ...        AND      Keywords_iperf_prisma.Start UL traffic process for List UEs
    ...              list_of_ues=${list_of_ues}    tput=${tput_ul}   len=${len}   duration=${traffic_duration}

    log      Sleep ${traffic_duration}...     console=${DEBUG_MODE_CONSOLE}
    Sleep         ${traffic_duration}

    #### only UE_0 for Prisma
    Log           Detach UE   console=${DEBUG_MODE_CONSOLE}
    Release UE known Type      ue_type_model=${ue_type_model}     ue_index=${list_of_ues[0]}
    #Release UE known Type      ue_type_model=${ue_type_model}     ue_index=${0}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testcase
    Log           last period pm file=${res}   console=${DEBUG_MODE_CONSOLE}

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable      ${PM_PATH}          ${res_path}
    Set Test Variable      ${PM_FILENAME}      ${res}

    #### stop iperf process
    Log        Kill remaining iperf pids:           console=${DEBUG_MODE_CONSOLE}
    Run Keyword If    '${traffic_direction}'=='DL'
    ...    Keywords_iperf_prisma.Stop DL iperf pids for List UEs     list_of_ues=${list_of_ues}
    Run Keyword If    '${traffic_direction}'=='UL'
    ...    Keywords_iperf_prisma.Stop UL iperf pids for List UEs     list_of_ues=${list_of_ues}
    Run Keyword If    '${traffic_direction}'=='ULDL'      run keywords
    ...    Keywords_iperf_prisma.Stop DL iperf pids for List UEs     list_of_ues=${list_of_ues}
    ...    AND     Keywords_iperf_prisma.Stop UL iperf pids for List UEs     list_of_ues=${list_of_ues}
