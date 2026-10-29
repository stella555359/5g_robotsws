*** Settings ***
Documentation
...    Maintainer: partheeban.asokan@nokia.com
...    Test Description: This feature covers the implementation in 5G classical (BBU-side) of the O-RAN Front Haul
...    M-Plane specification (Netconf/Yang) in compliance to the V02 version with M-Plane IOT profile 1.
...    It addresses the World Market. Functionalities are those defined in the O-RAN FH M-Plane V01 specification
...    for the O-RAN M-Plane IOT profile 1.
...    Confluence link: link
...    Group in charge: I_MN_RAN_BOAM_PZ_OM_ET_1_GMS <I_MN_RAN_BOAM_PZ_OM_ET_1@internal.nsn.com>
...    References: https://gates.nsn-net.net/view/00024ef8#o=0
...    QualityCenter: tds://ran_et.mn_ran.qc-prod.ext.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=22375
...    Sample execution: pybot --variable CONFIGURATION:Wroclaw.XXX -b debug.log -d /home/ute/results/ /home/ute/
...    robotle/testsuite/WMP/SOAM1/CB006943/general.robot
...    Review: -
...    AC/REQ: LTE_OPR_REQ_18838; LTE_OPR_REQ_25786; LTE_OPR_REQ_25796; LTE_OPR_REQ_26344; LTE_OPR_REQ_18902;
...    LTE_OPR_REQ_30133; LTE_OPR_REQ_29010; LTE_OPR_REQ_28919; LTE_OPR_REQ_28935; LTE_OPR_REQ_28936; LTE_OPR_REQ_25486;
...    LTE_OPR_REQ_28938; LTE_OPR_REQ_28939; LTE_OPR_REQ_28940; LTE_OPR_REQ_28215; LTE_OPR_REQ_28228; LTE_OPR_REQ_28212;
...    LTE_OPR_REQ_28216; LTE_OPR_REQ_28225; LTE_OPR_REQ_28239; LTE_OPR_REQ_28240; LTE_OPR_REQ_28241; LTE_OPR_REQ_28242;
...    LTE_OPR_REQ_28243; LTE_OPR_REQ_28273; LTE_OPR_REQ_28524; LTE_OPR_REQ_30247; LTE_OPR_REQ_30209; LTE_OPR_REQ_25634;
...    LTE_OPR_REQ_25625; LTE_OPR_REQ_18708; LTE_OPR_REQ_18980; LTE_OPR_REQ_18991; LTE_OPR_REQ_25324; LTE_OPR_REQ_18968;
...    LTE_OP_REQ_25977; LTE_OPR_REQ_26162; LTE_OPR_REQ_21041; LTE_OPR_REQ_27242; LTE_OPR_REQ_25466; LTE_OPR_REQ_25350;
...    LTE_OPR_REQ_30132; LTE_OPR_REQ_18559; LTE_OPR_REQ_10874; LTE_OPR_REQ_10218; LTE_OPR_REQ_29032; LTE_OPR_REQ_12455;
...    LTE_OPR_REQ_16949; LTE_OPR_REQ_19457; LTE_OPR_REQ_19671; LTE_OPR_REQ_19438; LTE_OPR_REQ_19439; LTE_OPR_REQ_19456;
...    LTE_OPR_REQ_21094; LTE_OPR_REQ_27446; LTE_OPR_REQ_29704; LTE_OPR_REQ_30129; LTE_OPR_REQ_18126; LTE_OPR_REQ_18290;
...    LTE_OPR_REQ_21073; LTE_OPR_REQ_27851; LTE_OPR_REQ_27999; LTE_OPR_REQ_21122; LTE_OPR_REQ_21115; LTE_OPR_REQ_21108;
...    LTE_OPR_REQ_30383; LTE_OPR_REQ_30384; LTE_OPR_REQ_30387; LTE_OPR_REQ_30388; LTE_OPR_REQ_29567; LTE_OPR_REQ_28571;
...    LTE_OPR_REQ_28600; LTE_OPR_REQ_28572; LTE_OPR_REQ_28570; LTE_OPR_REQ_28526; LTE_OPR_REQ_28527; LTE_OPR_REQ_28525;
...    LTE_OPR_REQ_677; LTE_OPR_REQ_694; LTE_OPR_REQ_774; LTE_OPR_REQ_5685; LTE_OPR_REQ_25394; LTE_OPR_REQ_25407;
...    LTE_OPR_REQ_25452; LTE_OPR_REQ_25526; LTE_OPR_REQ_25743; LTE_OPR_REQ_25985; LTE_OPR_REQ_28248; LTE_OPR_REQ_8369;
...    LTE_OPR_REQ_18371; LTE_OPR_REQ_25496; LTE_OPR_REQ_27419; LTE_OPR_REQ_27420; LTE_OPR_REQ_27425; LTE_OPR_REQ_27442;
...    LTE_OPR_REQ_27521; LTE_OPR_REQ_17295; LTE_OPR_REQ_27544; LTE_OPR_REQ_27556

Library     BuiltIn
Library     Process
Library     Collections
Library     SeleniumLibrary
Library     OperatingSystem
Library     taf.config.scf   WITH NAME    scf
Library     taf.sw.scout    WITH NAME    scout
Library     taf.collectors.simple    WITH NAME    simple
Library     taf.collectors.core    WITH NAME    core
Library     taf.sbts.oam.coam.admin
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/CB009130/resources/alarms.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot

Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/common/gnb_log.robot

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions

*** Variables ***
&{[1][1.0] CB006943_Collecting logs from O-RU and traces between O-RU and gNB}
...	QC_ID_FL00=QC_31621	QC_ID_SBTS25R1=QC_78979
${CONFIGURATION}	1_2_CLOUD970
${NETCONF_TRACE_REMOTE_PATH}          /tmp/node_FHNET80/tmp/RMOD_L-*_NetconfRpcMessageTrace_0.log
${NETCONF_TRACE_LOCAL_PATH}           /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
*** Test Cases ***
[1][1.0] CB006943_Collecting logs from O-RU and traces between O-RU and gNB
    [Tags]    CRT    6943_EDA_4	   QCP_RAN_VRF    QCD_MN_RAN

    Log To Console    \n'Collecting logs from ORU and traces between ORU and gNB' started!
    ADMIN Setup Admin
    #Log To Console    Configuring Additional Netconf Account
    #Configure Additional Netconf Account In CLI
    #Wait Until Mplane Is Connected
    ADMIN Collect Snapshot	${OUTPUT_DIR}/Snapshot.zip
    Assert Netconf Traces Are In Snapshot
    Log To Console    NETCONF traces Found in Snapshot! \n
    Assert Password Is Not Visible In Netconf Traces
    #Assert Addnl Password Is Not Visible In Netconf Traces
    Edit Flags For Netconf Traces
    ADMIN Reset Site
    Wait Until MRBTS Onair
    ADMIN Collect Snapshot	${OUTPUT_DIR}/Snapshot.zip
    Assert Netconf Traces Are Not In Snapshot
    Log To Console    \nNETCONF traces Not Found in Snapshot!
    [Teardown]    Run Keywords    Edit Flags For Netconf Traces    0    1    0    10000000    AND
    ...    ADMIN Reset Site    AND
    ...    Wait Until MRBTS Onair
    Link SCOUT SCF to Configuration ID for Reporting
    Test teardown

*** Keywords ***
Test teardown
    Log to console   \n--Test teardown Started--\n
    sleep    5
    RP Settings
    reportingportal_Keywords.Set QC_Tag
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    interface.Common step trigger
    Log to console   \n--Test teardown completed--\n

Wait Until MRBTS Onair
    wait until keyword succeeds
    ...                           720
    ...                           200
    ...                           Assert Mrbts Is In Onair State	alias=${ADMIN_ALIAS}
    Log    \n+ Mrbts Is In Onair State    console=yes

Edit Flags For Netconf Traces
    [Arguments]    ${old_value_750000}=1
    ...            ${new_value_750000}=0
    ...            ${old_value_750002}=10000000
    ...            ${new_value_750002}=0
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    sed -i 's;0x750000=${old_value_750000};0x750000=${new_value_750000};g' /ffs/run/swconfig.txt
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    sed -i 's;0x750002=${old_value_750002};0x750002=${new_value_750002};g' /ffs/run/swconfig.txt
    SSHLibrary.Read Until    root@

Assert Password Is Not Visible In Netconf Traces
    ${status}    Check Message In Netconf Trace File    ncCl2fjRu+autH0
    Should Not Contain    ${status}    ncCl2fjRu+autH0

Check Message In Netconf Trace File
    [Arguments]    ${message_to_grep}
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path}
    [Return]    ${output}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Assert Netconf Traces Are In Snapshot
    Run    unzip ${OUTPUT_DIR}/Snapshot.zip -d ${OUTPUT_DIR}/Snapshot
    ${snapshot_file_list}    Run    cat ${OUTPUT_DIR}/Snapshot/snapshot_file_list.txt | grep Netconf
    Should Contain
    ...    ${snapshot_file_list}
    ...    NetconfRpcMessageTrace.log.xz
    Run    rm -rf ${OUTPUT_DIR}/Snapshot*

Assert Netconf Traces Are Not In Snapshot
    Run    unzip ${OUTPUT_DIR}/Snapshot.zip -d ${OUTPUT_DIR}/Snapshot
    ${snapshot_file_list}    Run     cat ${OUTPUT_DIR}/Snapshot/snapshot_file_list.txt | grep Netconf
    Should Not Contain
    ...    ${snapshot_file_list}
    ...    NetconfRpcMessageTrace.log.xz
    Run    rm -R ${OUTPUT_DIR}/Snapshot

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   Wait Until Keyword Succeeds	2min	10s	scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

