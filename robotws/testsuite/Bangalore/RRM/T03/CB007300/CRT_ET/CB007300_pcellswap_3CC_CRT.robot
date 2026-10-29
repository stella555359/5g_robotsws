*** Settings ***
Documentation
...
...  AUTHOR          :   Uthika kaul
...  MAINTAINER      :   uthika.kaul@nokia.com
...  REFERENCES      :   CB007300-CFAM
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown tc
Force Tags        CUS    SBTS00    4G_FDD    CLOUD_R4LAPO_CUS   CA_VRF_RRM
Resource          ./resources/DevHZ5_resource.robot



Library  ta_uexgate
Library  taf.ul.ue.sim.env_setup
Library  taf.sw.scout    WITH NAME    scout
Library    ta5g_commissioning
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot

*** Variables ***
${SCFC}=                    ${CURDIR}/config_files/scf_CPRI_CUS.xml
${iphy_xml}=                ${CURDIR}/config_files/cus.yaml




@{parameter_A_g_002}
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=1
@{parameter_A_g_003_1}
...    LNCEL-1:pcellSwapConfig:pFreqPrio=3
@{parameter_A_g_003_2}
...    LNCEL-1:pcellSwapConfig:pFreqPrio=1
...    LNCEL-2:pcellSwapConfig:pFreqPrio=3
@{PM_Counters_for_a_g_003_1}
...    LNCEL-1:${PCELL_SWAP_SUCC}=1
@{PM_Counters_for_a_g_003_2}
...    LNCEL-2:${PCELL_SWAP_SUCC}=1
${PCELL_SWAP_SUCC}    M8021C42
${UTE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***
CB007300_PCell_Swap_PFreqPrio_StepWise_3cc
    [Documentation]    3CC UEa attach ,Pcell swap due to PfreqPrio change.
    [Tags]
    Two 3CC UEs Attach And Trigger CA
    Pcell Swap For Dl Only Ue
    Pcell Swap Back For Dl Only Ue
    [Teardown]  Run keywords    post condition


*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup tc
    Set Suite Variable  ${BTS_NUMBER}  1
    ${run_update}    get variable value      ${configure}        "True"
	add_enb_configuration    scfc=${SCFC}
	add_simulator            sim_type=cus   config=${iphy_xml}
	configure_environment
    Create Alias


Common Suite Setup tc
  ${time}  Get Time
  Log To Console  current time is ${time}
  Log Variables
  Conver some variables

Common Suite Teardown tc
  Run Keyword And Ignore Error  Copy File  /opt/iphy/latest/egate_console.log  ${SUITE_LOG_DIRECTORY}


Create Alias
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_6    ue_id=6    id_type=cus

Configure UE CA Bands
    [Arguments]    ${ueid}    ${ca_supported_bands}
    run Uex Command    ue_param id=${ueid} ca_supported_bands=${ca_supported_bands}    #configure UE CA capability

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}


Start Dl Traffic And Wait 4CC
    [Arguments]    ${ueid}    ${direction}    ${mbps}
    run Uex Command    trf_data_start ue=${ueid} dir=${direction} protocol=udp Mbps=${mbps} stats=true

Two 3CC UEs Attach And Trigger CA
    Configure UE CA Bands    ueid=5    ca_supported_bands=3:a:a+1::a|3:a:a+8::a|1:a:a+3::a|1:a:a+8::a|3:a:a+1::a+8::a|1:a:a+3::a+8::a
    Configure UE CA Bands    ueid=6    ca_supported_bands=1:a:a+3:a:a|1:a:a+8::a|3:a:a+8::a|3:a:a+1:a:a+8::a|1:a:a+3:a:a+8::a
    Dl Only 3CC Ue Attach To Cell1
    Ul Dl 3CC Ue Attach To Cell1
    Start Dl Traffic And Wait 3CC    ueid=5    direction=dl    mbps=50
    Start Dl Traffic And Wait 3CC    ueid=6    direction=dl    mbps=50

Dl Only 3CC Ue Attach To Cell1
    run Uex Command    ue_attach id=5 cell=1 selected_plmn=262:03

Ul Dl 3CC Ue Attach To Cell1
    run Uex Command    ue_attach id=6 cell=1 selected_plmn=262:03

Start Dl Traffic And Wait 3CC
    [Arguments]    ${ueid}    ${direction}    ${mbps}    ${timeout}=120
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE2751_A_g_003_flow1    overall_timeout=${timeout}
    Start Dl Traffic And Wait 4CC    ueid=${ueid}    direction=${direction}    mbps=${mbps}
    Flow Occurred As Expected    alias=LTE2751_A_g_003_flow1

Pcell Swap For Dl Only Ue
    run Uex Command    trf_data_start ue=5 dir=ul protocol=udp Mbps=10 stats=true
    Pcell Swap By Change pFreqPrio
    sleep    60s    #wait Pcell Swap trigger
    Check Ue Location    ueid=5    wait_string=2
    Check Ue Location    ueid=6    wait_string=1


Pcell Swap Back For Dl Only Ue
    Pcell Swap Back By Change pFreqPrio
    sleep    60s    #wait Pcell Swap back trigger
    Check Ue Location    ueid=5    wait_string=1
    Check Ue Location    ueid=6    wait_string=1


Pcell Swap By Change pFreqPrio
    Find Scfc And Send Delta Commissioning      scfc_filename=delta1.json


Pcell Swap Back By Change pFreqPrio
    Find Scfc And Send Delta Commissioning      scfc_filename=delta3.json

Check Ue Location
    [Arguments]    ${ueid}    ${wait_string}
    ${ue_info}    run UEx Command    get_ue_info id=${ueid}
    ${cell_id}=      Convert To String     ${ue_info["cell"]}
    should be equal    ${cell_id}    ${wait_string}

Change Bandwidth And numCaUeThreshold
    Parameters Configuration    ${parameter_A_g_002}

3CC Ue3 Attach To Cell1 And Trigger CA
    Configure UE CA Bands    ueid=3    ca_supported_bands=8:a:a+3::a|1:a:a+3::a|1:a:a+8::a|1:a:a+3::a+8::a
    run Uex Command    ue_attach id=3 cell=1 selected_plmn=262:03
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE2751_A_g_002_flow1    overall_timeout=120
    run Uex Command    trf_data_start ue=3 dir=dl protocol=udp Mbps=30 stats=true
    Flow Occurred As Expected    alias=LTE2751_A_g_002_flow1
    Check Ue Location    ueid=3    wait_string=1
    run Uex Command    trf_data_start ue=3 dir=ul protocol=udp Mbps=10 stats=true    #send ul traffic

3CC Ue4 Attach To Cell1 And Trigger PCell Swap
    Start Rtpm Counter    tag=pcell_swap_ca_threshold
    Configure UE CA Bands    ueid=4    ca_supported_bands=3:a:a+8::a|1:a:a+3::a|1:a:a+8::a|1:a:a+3::a+8::a
    run Uex Command    ue_attach id=4 cell=1 selected_plmn=262:03
    ${DL_2CC_scell_release}    catenate
    ...    sCellToReleaseList-r10 contains (2,1)
    Expect Message Flow
    ...    UE_4:RRC_RRCConnectionReconfiguration ( ${DL_2CC_scell_release} )
    ...    alias=LTE2751_A_g_002_flow2    overall_timeout=120
    run Uex Command    trf_data_start ue=4 dir=dl protocol=udp Mbps=30 stats=true
    Flow Occurred As Expected    alias=LTE2751_A_g_002_flow2
    Check Ue Location    ueid=4    wait_string=2
    sleep    60s    #wait the counter increase
    Check Rtpm Counters    ${PM_Counters_for_a_g_003_1}    tag=pcell_swap_ca_threshold


Post condition
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Test Variable  ${HOSTNAME}  ${hostname_combined}

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

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${HOSTNAME}
    Log To Console    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

