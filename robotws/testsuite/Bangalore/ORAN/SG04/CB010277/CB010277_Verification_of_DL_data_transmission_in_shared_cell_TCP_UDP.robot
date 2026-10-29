*** Settings ***

Documentation
...    author: Suhas Rajesh
...    contact suhas.rajesh@nokia.com
...    Description: Test Suite for CB010277
...    This purpose of the test case is to verify that both DL and UL can be transmitted in the shared cell.
...    This user scenario also checks that the CRM increases resources quickly enough when the first NR enters the cell.


Force Tags      CRT  SBTS24R2    FL00    QCD_MN_RAN   QCP_RAN_ST
...             RAN_5G_TDD__WITH__SBTS00
...             RAN_5G__WITH__SBTS00
...             RAN_5G__WITH__SBTS24R1
...             FT_CB010277

Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh        WITH NAME    ssh
Library        OperatingSystem     WITH NAME    os
Library        String      WITH NAME   str
Library        taf.ue    WITH NAME    ue
Library      testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_uc
#Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
#Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/alarm.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/expected_alarm.robot
Library        ute_ue
Library           OperatingSystem
Library           String
Library           Collections
Library           DateTime
Library    ./testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/bbu.py
Library    ./testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/log.py
#Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    ./testsuite/Bangalore/ORAN/resources/python/SysValidation.py
Library     ./testsuite/Bangalore/ORAN/SG04/resources/LuaHandling.py
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/ca_IWK.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/ca_INTER_RAT.robot
Library     taf.selenium.sbts     WITH NAME    sbts
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
#Library    taf.sw.scout    WITH NAME    scout
Library     taf.hw.rf_attenuator     WITH NAME     at



#Test Setup      Test Setup
#Test Teardown   Test Teardown

*** Variables ***
${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_1     Legacy_2
@{throughput_dl}=   60   40
@{throughput_ul}=   40   30
@{dt_name}=   iperf_dl_test
@{UE_alias}=    UE1    UE2
@{direction_dl}=  dl    dl
@{direction_ul}=  ul    ul
@{duration}=  200s      200s
@{timeout}      180     180
@{tcpcalltype}=    TCP    TCP
@{udpcalltype}=    UDP    UDP
@{deviation_dl}=  10    10
@{deviation_ul}=  10    10
${packet_size}=  1400     1400
${tput}=   100Mbits/sec      100Mbits/sec
${ASP_BOARD_TYPE}     ABIO0
${SCF_PATH}         /home/ute/Downloads
${scf_file1}=        /home/ute/testline_configuration_5G/Bangalore/10_2_UTE5GTLBTS970/Configuration_scf_MRBTS-970_970-NSA_dss_branch_working.xml
${CONFIG_PATH}      /home/ute/testline_configuration_5G/Bangalore/7_2_UTE5GTLBTS9/ta_ue_config.yaml
${port_val_list}     9
${counter_initial_value_1}      M55301C
${ENB_VM_IP}=    10.58.238.71
${GNB_VM_IP}=    10.58.238.71
${attenuator_host}          10.45.153.205                                              			# Attenuator IP
${attenuator_port}          ${3001}    # Attenuator Port    #Path for Emil logs are copied in UE PC
${at_vendor}                TOPYOUNG                                                    			# Attenuator Vendor
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS
@{ports_dss}=                   ${1}    ${2}    ${3}    ${4}     ${5}    ${6}    ${7}    ${8}
@{values0}=   15dB    15dB   15dB    15dB    0dB    0dB   0dB    0dB
@{values1}=   0dB    0dB   0dB    0dB    15dB    15dB   15dB    15dB
@{at_channel}=    ${1}    ${2}    ${3}    ${4}     ${5}    ${6}    ${7}    ${8}


*** Variables ***

${LTE_CELL_ID}=    5                                 # ID of DSS LTE cell which will be tested
${PHYS_LTE_CELL_ID}                            # Physical ID of tested LTE cells (needed for syscomdump filters)
${NR_CELL_ID}=    150                                  # ID of DSS NR cell which will be tested
${SYSCOMDUMP_FILTER}      ${NONE}              # Filetr used during collecting syscomdump, e.g. -i any msg_id=='0x761b'. Default value: ${NONE}
${LTE_MSISDN}                                  # number for volte call to dial
${BLANKED_PUCCH}                               # Value for blankedPucch
${NR_EXPECTED_DL_TPUT_MBPS}                    # [Mbit/sec] Value of expected throughput in NR DSS cell and LTE anchor cell
${LTE_EXPECTED_DL_TPUT_MBPS}                   # [Mbit/sec] Value of expected throughput in LTE DSS cell


*** Test Cases ***
CB010277_Verification of DL data transmission in shared cell-5GC002063
    #[Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    #[Teardown]    run keywords
    # ...      Set QC_Tag     Test Teardown
    coam.setup_admin
#    Perform the Commissioning
    Preconditions
    Step1: Start the NR and LTE call
    #Step2: Wait For CRM Message In Syslog
#    Step3: Analyze Time Difference Of CRM Prints



*** Keywords ***
Perform the Commissioning
    coam.perform_commissioning    970    scf_file=${scf_file1}    skip_parameter_relation_errors=True    should_activate=True    timeout=500
#    gnb_scf.Perform Full Commissioning on gNB    scf_file=${scf_file}    gnb_id=970
    Sleep    400
#    Run Keyword And Continue On Failure      Verify gNB is onAir
#    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
#    taf.sbts.oam.coam.admin.Setup Admin    name=admin1
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    Watch alarms           allowed_alarms=${allowed_alarms}
    ...                    interval=10


Test Setup
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Sleep  10

Test Teardown
    Log to console   --Test teardown--
#    Link SCOUT SCF to Configuration ID for Reporting
    interface.Common step trigger
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog         target_dir=/home/ute/results/
    core.teardown_collectors      names=btslog

Preconditions
    Log  ==== Preconditions ====  console=True
    Set BTS And Cell ID CRM String
    Log  = Preconditions passed =  console=True

Step1: Start the NR and LTE call
    at.setup_attenuator     ip_addr=${attenuator_host}     port=${attenuator_port}      attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}       model=${at_model}
    at.set_ports_attenuation    ${ports_dss}    ${values0}    confirm=True    confirmation_delay=5
    ta_uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_uc.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_uc.Attach UE    ue_alias=${UE_alias}     #UE attach step
    sleep     100
    at.set_ports_attenuation    ${ports_dss}    ${values1}    confirm=True    confirmation_delay=5
    ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
#    ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    #sleep    100
#    Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_dl}
#    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
#    Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_ul}
#   ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
#    ${result}=    validate_syslog_file_contents
#    ${length}=    Get Length    ${result}
#    log    ${result}
#    log    ${length}
#    Should Not Be Empty    ${result}
     at.setup_attenuator     ip_addr=${attenuator_host}     port=${attenuator_port}      attenuation_port_numbers=${at_channel}
     ...  vendor=${at_vendor}       model=${at_model}
     at.set_ports_attenuation    ${ports_dss}    ${values0}    confirm=True    confirmation_delay=5
     sleep     100
     at.set_ports_attenuation    ${ports_dss}    ${values1}    confirm=True    confirmation_delay=5



#    log to console     ${output["UE_1"]["tputvalue"]}
#    log to console     ${output["UE_2"]["tputvalue"]}
#    ta_uc.start_data_transfer     ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
#    sleep    310
#    ${output1}=        Run Keyword And Continue On Failure    ta_uc.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
#    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
#    log to console     ${output1["UE_1"]["tputvalue"]}
#    log to console     ${output1["UE_2"]["tputvalue"]}
#    #${dl_tput}=       Set Variable     ${output1["result"]["averageDL"]}
#    #log to console     ${dl_tput}
#    #${ul_tput}=       Set Variable     ${output1["result"]["averageUL"]}
#    #log to console     ${ul_tput}


Step2: Wait For CRM Message In Syslog
    Log  \n==== Step 4: Wait For CRM Message In Syslog ====  console=True
    Sleep    150s    Reason=Wait for CRM Message In Syslog
    ${syslog_msg} =  Run Keyword And Continue On Failure  validate_syslog_file_contents
    ...    search_string=CRMexe.*CRM\\/${DSS_STRING}\\/(Init|Alloc|Initial)
#    ${syslog_msg} =  Run Keyword And Continue On Failure  validate_syslog_file_contents
#    ...  search_string=CRMexe.*CRM\\/e3E9c0g2AF9c0\\/(Init|Alloc|Initial)\\s(\\[([0-9]+|,|:|\\s)+\\]){15,30}
    Set Test Variable  ${SYSLOG_MSG}  ${syslog_msg}

#Step3: Analyze Time Difference Of CRM Prints
#    Log  ==== Step 6: Analyze Time Difference Of CRM Prints ====  console=True
#    ${percent} =  Analyze Time Difference Of CRM Prints    ${SYSLOG_MSG}
#    Should Be True  ${percent} >= 1  msg=Percent of prints with time difference less or equal to 10ms is less than 1%.

Set BTS And Cell ID CRM String
#    coam.setup_admin    bts_host=192.168.255.129     bts_port=443     username=Nemuadmin     password=nemuuser     use_ssl=True
#     ...     update_interval=5000    alias=dss
#    ${lnbts_id} =    Get BTS ID From ADMIN
#    coam.teardown_all_aliases_for_admin
#    coam.setup_admin    bts_host=192.168.255.129     bts_port=443     username=Nemuadmin     password=nemuuser     use_ssl=True
#     ...     update_interval=5000    alias=dss
#    ${output}=    coam.get_bts_info    alias=dss
#    ${lnbts_id}=    set variable    ${output['mrbtsID']}
#    ${nrbts_id}=    set variable    ${output['nrBtsId']}

#    ${nrbts_id} =    Get BTS ID From ADMIN
#    ${enb_hex} =    Convert To Hex  ${lnbts_id}
#    ${gnb_hex} =    Convert To Hex  ${nrbts_id}
#    ${lte_lcr_id} =    Get Parameter Value From SCF  ${scf_file1}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='lcrId']
#    ...  dist_name_substring=True
#    ${nr_lcr_id} =    Get Parameter Value From SCF  ${scf_file1}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lcrId']
#   ...  dist_name_substring=True
#    ${lte_lcr_id_hex} =    Convert To Hex  ${lte_lcr_id}
#    ${nr_lcr_id_hex} =    Convert To Hex  ${nr_lcr_id}
#    ${dss_string} =    Set Variable  e${enb_hex}c${lte_lcr_id_hex}g${gnb_hex}c${nr_lcr_id_hex}
    Set Test Variable    ${DSS_STRING}    ${dss_string}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=10_2_BTS1002CRT5G
    log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

