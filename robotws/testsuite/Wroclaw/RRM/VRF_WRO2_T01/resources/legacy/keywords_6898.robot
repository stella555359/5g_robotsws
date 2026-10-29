*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords for 5GC002300
Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.py
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot

*** Variables ***
${ENB_M_PLANE}       ${tl.enbs[0].m.v4}
${BTS_ID}            ${tl.gnbs[0].instance_id}
${MAIN_SCF_PATH}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
@{ALLOWED_FAULT_ID}  4655  61649  61652  4654  61524  4681  4592  1936  8150
@{QCI}               5  6  7  8  9  69  70  79  98-100  128-254
@{ARP}               1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
@{5QI}               1  2  5-9  128-254
@{ARP_NEGATIVE}      0  16  2-17
@{5QI_NEGATIVE}      0  3  4  10  127  255  120-130
@{SST_NEGATIVE}      256  260
@{SD_NEGATIVE}       16777215  16777216
@{QCI_NEGATIVE}      3  4  10  100-130
@{lines_AHLOA_1}            1   2    3    4
@{lines_AHLOA_2}            5   6    7    8
@{lines_AHLOA_3}            9   10   11   12

*** Keywords ***
Detach and Attach several times
    [Arguments]  ${repeating}
    FOR  ${i}  IN RANGE   ${repeating}
        Detach UE   UE_1
        Attach UE   UE_1
        Sleep  5s
    END

Get counters values
    [Arguments]  ${counters_to_get}  ${path}
    ${first_cell_id}   Get global cell id of first cell
    &{counter}    Get counters    ${counters_to_get}
    &{counter_last_value_1}   pu.get last counters values   ${counter['BTS']['CELLS']['NRCELL-${first_cell_id}']['NRPMQAP-1']['${path}']}
    &{counter_last_value_2}   pu.get last counters values   ${counter['BTS']['CELLS']['NRCELL-${first_cell_id}']['NRPMQAP-2']['${path}']}
    @{list_of_counters}   pu.create_list_of_counters   ${counters_to_get}
    FOR  ${i}   IN   ${1}   ${2}
        For loop for counters   ${i}  ${list_of_counters}  ${counter_last_value_1}  ${counter_last_value_2}
    END

Get counters values for different from zero check
    [Arguments]  ${counters_to_get}  ${path}
    ${first_cell_id}   Get global cell id of first cell
    &{counter}    Get counters    ${counters_to_get}
    &{counter_last_value_1}   pu.get_sum_of_counters_last_two__values   ${counter['BTS']['CELLS']['NRCELL-${first_cell_id}']['NRPMQAP-1']['${path}']}
    &{counter_last_value_2}   pu.get_sum_of_counters_last_two__values   ${counter['BTS']['CELLS']['NRCELL-${first_cell_id}']['NRPMQAP-2']['${path}']}
    @{list_of_counters}   pu.create_list_of_counters   ${counters_to_get}
    FOR  ${i}   IN   ${1}   ${2}
        For loop for counters   ${i}  ${list_of_counters}  ${counter_last_value_1}  ${counter_last_value_2}
    END

For loop for counters
    [Arguments]  ${i_value}  ${list_of_counters}  ${counter_last_value_1}  ${counter_last_value_2}
    Log to console    ${counter_last_value_1}  ${counter_last_value_2}
    FOR  ${counter}   IN   @{list_of_counters}
        ${val}  get from dictionary  ${counter_last_value_${i_value}}  ${counter}
        Set test variable  ${${counter}_${i_value}}  ${val}
    END

Check if counters values differ from zero
    [Arguments]  ${counters}
    Log to console  Checking counters values
    FOR  ${counter}  IN  @{counters}
        Should be true  ${${counter}_1} != ${0}
        Should be true  ${${counter}_2} != ${0}
    END
    Log to console  Counters values OK

Check if counters values equal zero 6898
    [Arguments]  ${counters}
    Log to console  Checking counters values
    FOR  ${counter}  IN  @{counters}
        Should be true  ${${counter}_1} == ${0}
        Should be true  ${${counter}_2} == ${0}
    END
    Log to console  Counters values OK

Check if counters exist
    [Arguments]  ${counters}
    Log to console  Checking counters values
    FOR  ${counter}  IN  @{counters}
        Should be true  ${${counter}_1} >= ${0}
        Should be true  ${${counter}_2} >= ${0}
    END
    Log to console  Counters values OK

Verify counters CB006898-B differ from zero
    Get counters values for different from zero check  ${COUNTERS_HRLCQ_1}  ${PATH_HRLCQ}
    Get counters values for different from zero check  ${COUNTERS_PDCPQ}    ${PATH_PDCPQ}
    Check if counters values differ from zero          ${TC_B_COUNTERS_LIST}

Verify counters CB006898-B eaqual zero
    Get counters values                             ${COUNTERS_HRLCQ_1}  ${PATH_HRLCQ}
    Get counters values                             ${COUNTERS_PDCPQ}    ${PATH_PDCPQ}
    Check if counters values equal zero 6898        ${TC_B_COUNTERS_LIST}

Verify counters CB006898-A-#2 availability NSA
    Get counters values                             ${COUNTERS_PDCPQ}    ${PATH_PDCPQ}
    Get counters values                             ${COUNTERS_HRLCQ_2}  ${PATH_HRLCQ}
    Get counters values                             ${COUNTERS_X2CCQ}    ${PATH_X2CCQ}
    Get counters values                             ${COUNTERS_ACCNQ}    ${PATH_ACCNQ}
    Check if counters exist                         ${TC_A2_NSA_COUNTERS_LIST}

Verify counters CB006898-A-#2 availability SA
    Get counters values                             ${COUNTERS_PDCPQ}    ${PATH_PDCPQ}
    Get counters values                             ${COUNTERS_HRLCQ_2}  ${PATH_HRLCQ}
    Get counters values                             ${COUNTERS_ACCSQ}    ${PATH_ACCSQ}
    Get counters values                             ${COUNTERS_NGCCQ}    ${PATH_NGCCQ}
    Check if counters exist                         ${TC_A2_SA_COUNTERS_LIST}

Verify counters equal zero CB006898-D-#8
    Get counters values  M55162C00004  ${PATH_X2CCQ}
    Should be true       ${M55162C00004_1} == ${0}
    Should be true       ${M55162C00004_2} == ${0}


Verify counters differ zero CB006898-D-#8
    Get counters values for different from zero check  M55162C00004  ${PATH_X2CCQ}
    Should be true          ${M55162C00004_1} > ${0}
    Should be true          ${M55162C00004_2} > ${0}
    [Return]    ${M55162C00004_1}  ${M55162C00004_2}

Add two NRPMQAP objects NSA
    [Arguments]         ${actNrpmqapProfiles}=true
    ...                 ${miNrNgInterfaceNrpmqap}=5min
    ...                 ${miNrX2ccNrpmqap}=5min
    ...                 ${cfgProfType}=NSA
    Log to console      __Adding NRPMQAP objects
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    Initialise delta store
    ${mnp_dict}    Create Dictionary    cfgProfType=${cfgProfType}  cfgQciRange=9
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-1    &{mnp_dict}
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-2    &{mnp_dict}
    Add param to delta     ${nrbts_path}              actA2SgnbRelease          value=true
    Add param to delta     ${nrbts_path}               actNrpmqapProfiles              value=${actNrpmqapProfiles}
    Add param to delta     ${nrbts_path}/NRPMRNL-1               miNrNgInterfaceNrpmqap          value=${miNrNgInterfaceNrpmqap}
    Add param to delta     ${nrbts_path}/NRPMRNL-1               miNrX2ccNrpmqap          value=${miNrX2ccNrpmqap}
    Add param to delta     ${nrbts_path}             actInactDetNSAUe          value=true
    Add param to delta     ${nrbts_path}             drbInactivityTimerSA          value=30
    Add param to delta     ${nrbts_path}             srbInactivityTimerSA          value=30
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Add two NRPMQAP objects
    [Arguments]         ${actNrpmqapProfiles}=true
    ...                 ${miNrNgInterfaceNrpmqap}=5min
    ...                 ${miNrX2ccNrpmqap}=5min
    ...                 ${cfgProfType}=NSA
    Log to console      __Adding NRPMQAP objects
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    Initialise delta store
    ${mnp_dict}    Create Dictionary    cfgProfType=${cfgProfType}
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-1    &{mnp_dict}
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-2    &{mnp_dict}
    Add param to delta     ${nrbts_path}              actA2SgnbRelease          value=true
    Add param to delta     ${nrbts_path}               actNrpmqapProfiles              value=${actNrpmqapProfiles}
    Add param to delta     ${nrbts_path}/NRPMRNL-1               miNrNgInterfaceNrpmqap          value=${miNrNgInterfaceNrpmqap}
    Add param to delta     ${nrbts_path}/NRPMRNL-1               miNrX2ccNrpmqap          value=${miNrX2ccNrpmqap}
    Add param to delta     ${nrbts_path}             actInactDetNSAUe          value=true
    Add param to delta     ${nrbts_path}             drbInactivityTimerSA          value=30
    Add param to delta     ${nrbts_path}             srbInactivityTimerSA          value=30
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Add A2 release
    [Arguments]         ${actA2SgnbRelease}=true
    Log to console      __Setting actA2SgnbRelease=true
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    Initialise delta store
    Add param to delta     ${nrbts_path}              actA2SgnbRelease          value=${actA2SgnbRelease}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Switch cfgProfType in NRPMQAP
    [Arguments]  ${cfgProfType}=SA
    Log to console  ${cfgProfType}
    ${object}  Set Variable  ${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-1
    coam.perform_parameter_recommissioning  ${object}  cfgProfType  update  SA  ${True}  ${True}  240  ${GNB_CONNECTION_ALIAS}
    ${object}  Set Variable  ${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-2
    coam.perform_parameter_recommissioning  ${object}  cfgProfType  update  SA  ${True}  ${True}  240  ${GNB_CONNECTION_ALIAS}

Change parameters to delta
    [Arguments]    ${nrbts_distname}    &{kwargs}
    update managed object and parameter to delta  dist_name=${nrbts_distname}    &{kwargs}

Lock all cells except first 6898
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    ${first_cell_id}   Get global cell id of first cell
    ${first_cell}=     Set variable   '${nrbts_path}/NRCELL-${first_cell_id}'
    ${nrcell_dists}    Get list of specific object dist name  class_name=NRCELL_A
    FOR   ${cell}   IN   @{nrcell_dists}
        ${result}=   Evaluate   ${first_cell} != '${cell}'
        Run keyword if  ${result} == True  coam.lock  dist_name=${cell}  timeout=300  connection=${GNB_CONNECTION_ALIAS}
    END

Unlock all locked cells 6898
    ${nrcell_dists}   Get list of specific object dist name  class_name=NRCELL_A
    FOR   ${cell}   IN   @{nrcell_dists}
        ${status}   coam.get cell specific info   cell_id=${cell}   connection=${GNB_CONNECTION_ALIAS}
        ${cell_status}   set variable   '${status['status']['administrativeState']}'
        Run keyword if  ${cell_status} == 'Locked'  coam.unlock  dist_name=${cell}  connection=${GNB_CONNECTION_ALIAS}
        ...                                         timeout=300
    END

Lock all LTE cells
    ${dist_names}       Create list
    ${objects}          coam.Get managed objects    class_name=LNCEL_A   connection=${ENB_CONNECTION_ALIAS}
    FOR    ${object}   IN    @{objects}
        ${dist_name_a}  Fetch from right    ${object['distName']}    SCF-1/
        ${dist_name}    Remove string  ${dist_name_a}  _A
        Append to list  ${dist_names}  ${dist_name}
    END

    FOR   ${cell}   IN   @{dist_names}
        coam.block_cell   dist_name=${cell}   connection=${ENB_CONNECTION_ALIAS}  timeout=300
    END

Unlock all LTE locked cells
    ${dist_names}       Create list
    ${objects}          coam.Get managed objects    class_name=LNCEL_A   connection=${ENB_CONNECTION_ALIAS}
    FOR    ${object}   IN    @{objects}
        ${dist_name_a}  Fetch from right    ${object['distName']}    SCF-1/
        ${dist_name}    Remove string  ${dist_name_a}  _A
        Append to list  ${dist_names}  ${dist_name}
    END

    FOR   ${cell}   IN   @{dist_names}
        ${status}   coam.get cell specific info   cell_id=${cell}   connection=${ENB_CONNECTION_ALIAS}
        ${cell_status}   set variable   '${status['status']['blockingState']}'
        Run keyword if   ${cell_status} == 'Blocked'   coam.unblock_cell   dist_name=${cell}   connection=${ENB_CONNECTION_ALIAS}
        ...                                            timeout=300
    END

Add 20 NRPMQAP NSA
    [Arguments]         ${actNrpmqapProfiles}=true
    Log to console      __Adding 20 NRPMQAP objects
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    Initialise delta store
    FOR  ${i}   IN RANGE  1   20
        ${arp_1}     Random CFG   ${ARP}
        ${qci_1}     Random CFG   ${QCI}
        ${mnp}    Create Dictionary    cfgProfType=NSA   cfgArpRange=${arp_1}   cfgQciRange=${qci_1}
        Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-${i}    &{mnp}
    END
    ${mnp_dict}    Create Dictionary    cfgProfType=NSA
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-20    &{mnp_dict}
    Add param to delta     ${nrbts_path}               actNrpmqapProfiles              value=${actNrpmqapProfiles}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Add 20 NRPMQAP SA
    [Arguments]         ${actNrpmqapProfiles}=true
    Log to console      __Adding 20 NRPMQAP objects
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    Initialise delta store
    FOR  ${i}   IN RANGE  1   20
        ${arp_1}     Random CFG   ${ARP}
        ${5qi_1}     Random CFG   ${5QI}
        ${mnp}    Create Dictionary    cfgProfType=SA   cfgArpRange=${arp_1}   cfg5qiRange=${5qi_1}
        Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-${i}    &{mnp}
    END
    ${mnp_dict}    Create Dictionary    cfgProfType=SA
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-20    &{mnp_dict}
    Add param to delta     ${nrbts_path}               actNrpmqapProfiles              value=${actNrpmqapProfiles}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Random CFG
    [Arguments]         ${Value}
    ${random}    Evaluate    random.choice(${Value})  random
    [Return]   ${random}

Random objects
     ${population}   Evaluate  random.randint(1,19)  random
     ${random}    Evaluate    random.sample(range(1, 20), ${population})   random
     ${list}  Convert To List   ${random}
     [Return]   ${list}

Delete random objects
    Log to console      __Delete random numer of NRPMQAP objects
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    Initialise delta store
    ${objects}   Random objects
    FOR  ${i}   IN  @{objects}
        delete managed object from delta    ${nrbts_path}/NRPMRNL-1/NRPMQAP-${i}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Check for unexpected active alarms 6898
    coam.connect_to     name=E2E
    FOR  ${faultId}   IN   @{ALLOWED_FAULT_ID}
        coam.add_allowed_alarm    faultId=${faultId}   connection=E2E
    END
    coam.assert_no_unexpected_active_alarms   connection=E2E
    [Teardown]   coam.Teardown      connection=E2E

Add 3 difrent NRPMQAP
    [Arguments]         ${actNrpmqapProfiles}=true
    Log to console      __Add 3 difrent NRPMQAP objects
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    Initialise delta store
    ${mnp_1}    Create Dictionary    cfgProfType=NSA
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-1    &{mnp_1}
    ${mnp_2}    Create Dictionary    cfgProfType=SA
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-2    &{mnp_2}
    ${mnp_3}    Create Dictionary    cfgProfType=both
    Update mo and parameter to delta    nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-3    &{mnp_3}
    Add param to delta     ${nrbts_path}               actNrpmqapProfiles              value=${actNrpmqapProfiles}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Set wrong parameeters SA
    Log to console      __Set wrong parameeters SA
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    ${sd_1}      Random CFG   ${SD_NEGATIVE}
    ${sst_1}     Random CFG   ${SST_NEGATIVE}
    &{cfgSliceId}   Create dictionary   sd=${sd_1}   sst=${sst_1}
    Initialise delta store
    ${arp_1}     Random CFG   ${ARP_NEGATIVE}
    ${5qi_1}     Random CFG   ${5QI_NEGATIVE}
    ${qci_1}     Random CFG   ${QCI}
    ${mnp}    Create Dictionary    cfgProfType=SA   cfgArpRange=${arp_1}   cfg5qiRange=${5qi_1}   cfgQciRange=${qci_1}
    Change parameters to delta   nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-2    &{mnp}
    Add list parameters to delta  ${nrbts_path}/NRPMRNL-1/NRPMQAP-2   cfgSliceId     &{cfgSliceId}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Check incorrect value
   [Arguments]    ${type}=SA
   ${repetitions}    set variable    2
   #run keyword if    "${type}"=="SA"    set test variable  ${repetitions}  1
   ${adminApi}=    Run Keyword And Ignore Error   Set wrong parameeters ${type}
   ${string}   Convert To string   ${AdminApi}
   @{cnt}=  Get Regexp Matches    ${string}    VALUE_IS_TOO_BIG
   ${nr}  Get length  ${cnt}
   should be equal as numbers  ${nr}   2
   @{cnt}=  Get Regexp Matches    ${string}    INCORRECT_PATTERN
   ${nr}  Get length  ${cnt}
   should be true  ${nr} > 0

Set wrong parameeters NSA
    Log to console      __Set wrong parameeters NSA
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    ${sd_1}      Random CFG   ${SD_NEGATIVE}
    ${sst_1}     Random CFG   ${SST_NEGATIVE}
    &{cfgSliceId}   Create dictionary   sd=${sd_1}   sst=${sst_1}
    Initialise delta store
    ${arp_1}     Random CFG   ${ARP_NEGATIVE}
    ${5qi_1}     Random CFG   ${5QI}
    ${qci_1}     Random CFG   ${QCI_NEGATIVE}
    ${mnp}    Create Dictionary    cfgProfType=SA   cfgArpRange=${arp_1}   cfg5qiRange=${5qi_1}   cfgQciRange=${qci_1}
    Change parameters to delta   nrbts_distname=${nrbts_path}/NRPMRNL-1/NRPMQAP-1    &{mnp}
    Add list parameters to delta  ${nrbts_path}/NRPMRNL-1/NRPMQAP-1   cfgSliceId     &{cfgSliceId}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Start tput
    [Arguments]     ${direction}=dl  ${protocol}=udp  ${ue_alias}=UE_1  ${duration}=${DATA_TRANSFER_TIME}
    Run keyword if  '${protocol}' == 'udp'
    ...             Start data transfer
    ...             dt_name=DT_${direction}_${protocol}_${ue_alias}
    ...             ue_alias=${ue_alias}
    ...             direction=${direction}
    ...             duration=${duration}
    ...             throughput=${THROUGHPUT}
    ...             protocol=${protocol}
    ...             packet_size=1400
    ...             ELSE
    ...             Start data transfer
    ...             dt_name=DT_${direction}_${protocol}_${ue_alias}
    ...             ue_alias=${ue_alias}
    ...             direction=${direction}
    ...             duration=${duration}
    ...             throughput=${THROUGHPUT}
    ...             protocol=${protocol}
    ...             packet_size=1400
    ...             parallel_streams=1
    ...             packet=1024B
    ...             buffer=1M
    ...             ttl=64
    ...             max_segment_size=1400

Start ULDL tput
    [Arguments]     ${protocol}=udp  ${ue_alias}=UE_1  ${duration}=${DATA_TRANSFER_TIME}
    ${CELL_ID}      taf.ue.Get Ue Info  ${ue_alias}  CELL_ID
    log to console  ${ue_alias} attached to cell ${CELL_ID}
    Start tput  dl  ${protocol}  ${ue_alias}  ${duration}
    Start tput  ul  ${protocol}  ${ue_alias}  ${duration}

Wait for tput finish
    [Arguments]   ${ue_alias}=UE_1  ${protocol}=udp
    Await datatransfer finish  DT_dl_${protocol}_${ue_alias}
    Await datatransfer finish  DT_ul_${protocol}_${ue_alias}
    Detach UE  ${ue_alias}

Wait for counter interval
    [Arguments]     ${time}=300s
    Log to console  Wait for next counter interval for ${time}.
    sleep           ${time}

Set nsaInactivityTimer
    [Arguments]        ${nsaInactivityTimer}=10
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list  ${nrbts_dist}   0
    Initialise delta store
    Add param to delta     ${nrbts_path}               nsaInactivityTimer              value=${nsaInactivityTimer}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    delete delta if already present  ${delta}

Set attenuation AhloaS1
    Set attenuation and check  lines=${lines_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_AHLOA_3}   value=90

Slowly attenuate for SgNBRelease
    Attach UE  UE_1
    FOR  ${i}  IN RANGE  0  90  10
        set attenuation and check  ${lines_AHLOA_1}  value=${i}
        sleep  4s
    END
    sleep  8s
    Detach UE  UE_1
    set attenuation and check  ${lines_AHLOA_1}  value=0
    sleep  3s

Test Setup 6898
    Connect to gNB and eNB
    Verify if all cells are onair
    Start syslog capture
    Download SCF
    Require ue  UE_1  capabilities=REAL_UE
    Reboot UE   UE_1  180

Test Teardown 6898
    Unbar all eNB cells  eNB
    Collect Snapshot
    Recommission to default
    Stop syslog capture
    Turn off attenuation
    ssh.reset_cache

Add 5 NRPMQAP
    [Arguments]
    ...            ${cfgArpRange}=1
    ...            ${cfg5qiRange}=1

    Initialise delta store
    ${mnp_dict_sa}    Create Dictionary
    ...            cfgProfType=SA
    ...            cfgArpRange=${cfgArpRange}
    ...            cfg5qiRange=${cfg5qiRange}

    ${mnp_dict_nsa}    Create Dictionary
    ...            cfgProfType=NSA

    add managed object and parameter to delta    dist_name=${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-1    &{mnp_dict_nsa}
    add managed object and parameter to delta    dist_name=${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-2    &{mnp_dict_sa}
    add managed object and parameter to delta    dist_name=${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-3    &{mnp_dict_sa}
    add managed object and parameter to delta    dist_name=${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-4    &{mnp_dict_sa}
    add managed object and parameter to delta    dist_name=${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-5    &{mnp_dict_sa}

    ${delta}       Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair

Delete Given NRPMQAP
    [Arguments]    ${id}=1

    Initialise delta store

    delete managed object from delta    ${MAIN_SCF_PATH}/NRPMRNL-1/NRPMQAP-${id}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
