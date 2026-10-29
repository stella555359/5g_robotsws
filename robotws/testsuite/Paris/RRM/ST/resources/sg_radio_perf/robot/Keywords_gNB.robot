*** Settings ***
Documentation
...           Description : keywords for gNB
...           AUTHOR (I&V):  Annie Wong        annie.wong@nokia.com
...                      23.03.21:  last update replace "coam" with "admin"
...                      24.06.21:  taf.sbts.oam.coam.admin as admin

Library     String
## remove the import of:     taf.gnb.oam coam.admin     WITH NAME   admin
## admin is defined in oam.robot
Library    ../python/software_version_handler.py    WITH NAME    wro_sweng_soft_ver

Resource     oam.robot


*** Keywords ***
Basic checks on Cloud Megazone gNB
    Wait until Keyword Succeeds   600s  5s  Check VM OAM status
    Wait until Keyword Succeeds   600s  5s  Check VM CPNB status
    Wait until Keyword Succeeds   600s  5s  Check VM CPCL status
    Wait until Keyword Succeeds   600s  5s  Check VM CPUE status
    Wait until Keyword Succeeds   600s  5s  Check VM UPUE status
    Wait until Keyword Succeeds   600s  5s  Check VM CPIF status
    Wait until Keyword Succeeds   600s  5s  Check VM CPNRT status
    Wait until Keyword Succeeds   600s   5s    Check FSM Status From WEBUI
    Wait until Keyword Succeeds   600s   5s    Check FCT Status From WEBUI
    Wait until Keyword Succeeds   600s   5s    Check FCT Status From Asik AdetS
    Wait until Keyword Succeeds   60s   5s  Check Loner Status from Asik
    Wait until Keyword Succeeds   300s  5s  Check GpsSync Status
    Wait until Keyword Succeeds   300s  5s  Check Ru id=1 Status


Check status gNB classical coam
    log                           Check ASIK Status
    #Wait until Keyword Succeeds    5min   30s      Check FSM Status From WEBUI
    Wait until Keyword Succeeds    5min   30s      Check FCT Status From Asik AdetS Classical with retry
    #Log                           Check ABIL Status
    #Wait until Keyword Succeeds    5min   10s      Check FBBs Status From WEBUI
    #log                           Check GPS status
    #Wait until Keyword Succeeds    5min   10s      Check Sync Status
    Keywords_gNB.Check gNB State    gNB=0


Check FCT Status From Asik AdetS Classical with retry
    run keyword and ignore error     Close Connections
    # create OAM session
    Create Connections
    ssh.execute             command=export PATH=/usr/local/bin:/usr/sbin:/usr/bin
    ...                     connection=OAM
    ${output}               ssh.execute
    ...                     command=export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/AdetS.py -s
    ...                     connection=OAM
    should not start with   ${output}           timeout while waiting for message            msg=No board detected
    should contain          ${output}           0x10\tFSM1_FCT\tready[0]


Trigger coam Site Reset and Wait Startup Completed
     [Arguments]           ${timeout}      ${gnb_id}=0
     COAM Reset Site                gnb_id=${gnb_id}
     sleep       ${timeout}      Wait some time to be sure the OAM VM is restarted
     log        Waiting bts OnAir state
     Wait COAM Startup Completed          gnb_id=${gnb_id}


COAM Reset Site
     [Arguments]            ${gnb_id}=0
     Keywords_gNB.Create cOAM Session with alias     gnb_id=${gnb_id}    alias=gnb_oam_admin
     admin.reset_site         connection=gnb_oam_admin
     [Teardown]            Teardown cOAM Session with alias       gnb_oam_admin


Wait COAM Startup Completed
     [Arguments]             ${gnb_id}=0
     Keywords_gNB.Create cOAM Session with alias     gnb_id=${gnb_id}    alias=gnb_oam_admin
     wait until keyword succeeds    600    20     Check Coam Startup Completed     connection=gnb_oam_admin
     [Teardown]       Teardown cOAM Session with alias      alias=gnb_oam_admin


Check Coam Startup Completed
     [Arguments]              ${connection}
     &{status}=                  admin.get_bts_statuses        connection=${connection}
     Should be equal as strings      ${status.proceduralState}      OnAir


Backup swconfig
    [Arguments]              ${target_file}
    [Documentation]        Archive swconfig on VM (on target location)
    ${asik_cnx}       ssh.connect_to      ${GNB_AIRSCALE_IP}      ${GNB_AIRSCALE_USERNAME}     ${GNB_AIRSCALE_PASSWORD}
     ...               alias=asik_als
    swconf.backup_swconfig      ${asik_cnx}     /ffs/run/swconfig.txt      ${target_file}
    ssh.disconnect              connection=${asik_cnx}


Load swconfig on BTS
    [Arguments]              ${swconfig_file}         ${gnb_id}=0         ${handle_reset}=1

    #bypass robotcop
    ${gnb_id}    Set Variable    ${gnb_id}

    ${asik_cnx}       ssh.connect_to      ${GNB_AIRSCALE_IP}      ${GNB_AIRSCALE_USERNAME}     ${GNB_AIRSCALE_PASSWORD}
     ...               alias=asik_als
    ${need_reset}       swconf.set_swconfig         ${asik_cnx}       ${swconfig_file}      /ffs/run/swconfig.txt
    ssh.disconnect              connection=${asik_cnx}
    log     Flag reset needed after loading initial swconfig.txt = ${need_reset}
    run keyword if    '${need_reset}'=='1' and '${handle_reset}'=='1'
    ...      Trigger coam Site Reset and Wait Startup Completed     timeout=400    gnb_id=0
    return from keyword        ${need_reset}


COAM commissioning with scf file
    [Arguments]           ${scf_file}     ${gnb_id}=0
    [Documentation]       Perform the commissioning and wait the OAM is ready
    Keywords_gNB.Create cOAM Session with alias       gnb_id=${gnb_id}     alias=gnb_oam_admin
    admin.perform_commissioning
    ...     scf_file=${scf_file}
    ...     skip_parameter_relation_errors=${True}
    ...     should_activate=${True}
    ...     connection=gnb_oam_admin
    ...     timeout=600
    sleep               200s        Wait some time to be sure the OAM VM is restarted
    Teardown cOAM Session with alias      gnb_oam_admin
    log        Waiting bts OnAir state
    Wait COAM Startup Completed          gnb_id=${gnb_id}


Create cOAM Session with alias
    [Arguments]         ${gnb_id}=0     ${alias}=cOAM
    [Documentation]  Connect to Node B.
    ...     gnb_id:  BTS gnb id in Testline configuration i.e ${tl.gnbs[]}
    ...     alias:   AdminConnection object or if used, string name alias
    comment  Release cOAM session before creation to avoid multiple session open
    Teardown cOAM Session with alias       alias=${alias}
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}   name=${alias}


Teardown cOAM Session with alias
    [Arguments]         ${alias}=cOAM
    [Documentation]  Disconnects and destroy node.js daemon
    ...     alias:   AdminConnection object or if used, string name alias
    run keyword and ignore error        admin.teardown          connection=${alias}


Load swconfig and Check gNB classical cOAM status
    [Arguments]           ${swconfig_file}       ${gnb_id}=0
    Load swconfig on BTS
    ...      swconfig_file=${swconfig_file}
    ...      gnb_id=${gnb_id}
    ...      handle_reset=1
    Sleep      10s
    run keyword and ignore error     Close Connections
    run keyword and ignore error     Create Connections
    # if failure in create connection, it is done again in check gNB step
    Keywords_gNB.Create cOAM Session with alias     gnb_id=${gnb_id}    alias=coam_admin
    Check status gNB classical coam


#from : gnb_status.robot
Check gNB State
    [Documentation]
    ...    Check that gNB is in correct state to start tests.
    ...
    ...    Performs :
    ...    Check FSM status from WEBUI
    ...    Check FBBs status from WEBUI
    ...    Check GpsSync status
    ...    Check RUs status from WEBUI
    ...    Check cell status by default : 1

    [Arguments]    ${gNB}=0    ${cell_id}=1

    oam.create_session    base_url=${GN_WEBUI[${gNB}]}    alias=oam_session
    Wait until Keyword Succeeds    10m    1m    Verify FSM Status From WEBUI
    Wait until Keyword Succeeds    10m    1m    Verify FBBs Status From WEBUI
    Wait until Keyword Succeeds    5m     1m    Check GpsSync Status
    Wait until Keyword Succeeds    30m    1m    Verify RUs Status From WEBUI
    Wait until Keyword Succeeds    30m    1m    Check Cell Status    ${cell_id}    ${gNB}
    oam.teardown_session    session=oam_session


Verify FSM Status From WEBUI
    oam.verify_fsm_enabled_online       timeout=30    session=oam_session


Verify FBBs Status From WEBUI
    oam.verify_fbbs_enabled_online      timeout=30    session=oam_session


Verify RUs Status From WEBUI
    oam.verify_rus_enabled_online      timeout=30    session=oam_session


Check FSM Status
    # old code
    ${fsm_availability_status}=
    ...                     oam.get_fsm
    ...                     attribute=availabilityStatus
    ...                     session=oam_session
    ...                     timeout=10
    Log         FSM Availability Status: ${fsm_availability_status}
    ${fsm_procedural_status}=
    ...                     oam.get_fsm
    ...                     attribute=proceduralStatus
    ...                     session=oam_session
    ...                     timeout=10
    Log         - Procedural Status: ${fsm_procedural_status}
    ${fsm_operational_state}=
    ...                     oam.get_fsm
    ...                     attribute=operationalState
    ...                     session=oam_session
    ...                     timeout=10
    Log         - Operational State: ${fsm_operational_state}
    should be equal    ${fsm_availability_status}           online          ignore_case=True
    should be equal    ${fsm_procedural_status}             configured      ignore_case=True
    should be equal    ${fsm_operational_state}             enabled         ignore_case=True


Check FBB_ID=${fbbid} Status
    # Check ABIL
    ${fbb_availability_status}=
    ...                     oam.get_fbb
    ...                     attribute=availabilityStatus    fbb_id=${fbbid}
    ...                     session=oam_session
    ...                     timeout=10
    Log           FBB Availability Status: ${fbb_availability_status}
    ${fbb_procedural_status}=
    ...                     oam.get_fbb
    ...                     attribute=proceduralStatus      fbb_id=${fbbid}
    ...                     session=oam_session
    ...                     timeout=10
    Log          - Procedural Status: ${fbb_procedural_status}
    ${fbb_operational_state}=
    ...                     oam.get_fbb
    ...                     attribute=operationalState      fbb_id=${fbbid}
    ...                     session=oam_session
    ...                     timeout=10
    Log          - Operational State: ${fbb_operational_state}
    should be equal         ${fbb_availability_status}      online          ignore_case=True
    should be equal         ${fbb_procedural_status}        configured      ignore_case=True
    should be equal         ${fbb_operational_state}        enabled         ignore_case=True



Verify FRM id=${rfid} Status
    #${card_type}   set variable      ${HW_Configuration['LEFT']['CARD']}
    ${card_type}    set variable      ${tl.gnbs[0].dus[0].airscale.common_units[0].hardware_type}
    Run Keyword If      '${card_type}'=='ASIB'      Check ASIB FRM id=${rfid} Status
    ...       ELSE                                  Check FRM id=${rfid} Status


Check FRM id=${rfid} Status
    ${frm_availability_status}=     oam.get_frm    frm_id=${rfid}      attribute=availabilityStatus
    ...                             session=oam_session
    ...                             timeout=10
    Log               FRM Availability Status: ${frm_availability_status}
    ${frm_procedural_status}=       oam.get_frm    frm_id=${rfid}      attribute=proceduralStatus
    ...                             session=oam_session
    ...                             timeout=10
    Log                 - Procedural Status: ${frm_procedural_status}
    ${frm_operational_state}=       oam.get_frm    frm_id=${rfid}      attribute=operationalState
    ...                             session=oam_session
    ...                             timeout=10
    Log                 - Operational State: ${frm_operational_state}
    should be true                  '${frm_availability_status}' in ['online','degraded','Online','Degraded']
    should be equal                 ${frm_procedural_status}           configured   ignore_case=True
    should be equal                 ${frm_operational_state}           enabled      ignore_case=True


Check ASIB FRM id=${rfid} Status
    Log                  Checking FRM Status:
    ${frm_availability_status}=     oam.get_frm_asib    frm_id=${rfid}      attribute=availabilityStatus
    ...                             session=oam_session
    ...                             timeout=10
    Log                  - Availability Status: ${frm_availability_status}
    ${frm_procedural_status}=       oam.get_frm_asib    frm_id=${rfid}      attribute=proceduralStatus
    ...                             session=oam_session
    ...                             timeout=10
    Log                  - Procedural Status: ${frm_procedural_status}
    ${frm_operational_state}=       oam.get_frm_asib    frm_id=${rfid}      attribute=operationalState
    ...                             session=oam_session
    ...                             timeout=10
    Log                  - Operational State: ${frm_operational_state}
    should be true                  '${frm_availability_status}' in ['online','degraded','Online','Degraded']
    should be equal                 ${frm_procedural_status}           configured   ignore_case=True
    should be equal                 ${frm_operational_state}           enabled      ignore_case=True


Check GpsSync Status
    Log              Checking Sync Status:
    ${gps_availability_status}=     oam.get_gps_status
    ...                             session=oam_session
    ...                             timeout=10
    Log              - Availability Status: ${gps_availability_status}
    should be equal                 ${gps_availability_status}         Online        ignore_case=True


Check Cell id=${cell_id} Status
    [Documentation]          Obsolete. This keyword should be replaced by Check Cell Status
    Log          Checking Cell Status:
    ${cel_avail_status}=     oam.get_cell_specific_info
    ...                      cell_number=MRBTS-76/NRBTS-23181/NRCELL-${cell_id}
    ...                      attribute=availabilityStatus
    ...                      session=oam_session
    ...                      timeout=10
    Log         - Availability Status: ${cel_avail_status}
    ${cel_proc_status}=      oam.get_cell_specific_info
    ...                      cell_number=MRBTS-76/NRBTS-23181/NRCELL-${cell_id}
    ...                      attribute=proceduralStatus
    ...                      session=oam_session
    ...                      timeout=10
    Log         - Procedural Status: ${cel_proc_status}
    ${cel_oper_state}=       oam.get_cell_specific_info
    ...                      cell_number=MRBTS-76/NRBTS-23181/NRCELL-${cell_id}
    ...                      attribute=operationalState
    ...                      session=oam_session
    ...                      timeout=10
    Log          - Operational State: ${cel_oper_state}
    should be equal          ${cel_avail_status}         online       ignore_case=True
    should be equal          ${cel_proc_status}          configured   ignore_case=True
    should be equal          ${cel_oper_state}           enabled      ignore_case=True


Check Cell Status
    [Arguments]              ${cell_id}=1    ${gNB}=0
    Log           Checking Cell Status:
    Log            - cell_number=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    ${cel_avail_status}=     oam.get_cell_specific_info
    ...                      cell_number=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    ...                      attribute=availabilityStatus
    ...                      session=oam_session
    ...                      timeout=10
    Log             - Availability Status: ${cel_avail_status}
    ${cel_proc_status}=      oam.get_cell_specific_info
    ...                      cell_number=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    ...                      attribute=proceduralStatus
    ...                      session=oam_session
    ...                      timeout=10
    Log            - Procedural Status: ${cel_proc_status}
    ${cel_oper_state}=       oam.get_cell_specific_info
    ...                      cell_number=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    ...                      attribute=operationalState
    ...                      session=oam_session
    ...                      timeout=10
    Log             - Operational State: ${cel_oper_state}
    #should be equal          ${cel_avail_status}         online       ignore_case=True
    should be true           '${cel_avail_status}' in ['online','degraded','Online','Degraded']
    log to console           cell ${cell_id} availabilityStatus = ${cel_avail_status}
    should be equal          ${cel_proc_status}          configured   ignore_case=True
    should be equal          ${cel_oper_state}           enabled      ignore_case=True


Reset Site and Check Cell
    [Documentation]         Reset the site and check the gNB status (including cell state)
    [Arguments]             ${gNB}=0
    Run Keyword And Ignore error      oam.teardown_session    session=oam_session
    oam.create_session      base_url=${GN_WEBUI[${gNB}]}
    ...                     alias=oam_session
    oam.reset_site          session=oam_session
    oam.teardown_session    session=oam_session
    Log                   Wait 5mn to be sure the OAM is restarted
    sleep                   300s     Wait some time to be sure the OAM VM is restarted
    Check gNB State             ${gNB}


Get gNB software version
    [Arguments]             ${gnb_id}=0
    Keywords_gNB.Create cOAM Session with alias     gnb_id=${gnb_id}    alias=gnb_oam_admin
    ${sw_version} =        admin.Get sw version    timeout=90    connection=gnb_oam_admin
    Should Not Be Empty    ${sw_version}    msg=Taf function Get sw version returned empty response!
    ${sw_version} =    Remove String Using Regexp    ${sw_version}   5G.*_GNB_
    ${sw_version} =    wro_sweng_soft_ver.Prepare software version    ${sw_version}
    Log          gNB(${gnb_id}) software version = ${sw_version}         console=${DEBUG_MODE_CONSOLE}
    [Teardown]       Teardown cOAM Session with alias      alias=gnb_oam_admin
    [return]    ${sw_version}
