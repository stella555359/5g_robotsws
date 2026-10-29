*** Settings ***
Documentation    Author: jin_emily.chen@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
Library           taf.ue.prisma    WITH NAME    prisma

*** Variables ***
${lsu_uu}    lsu_uu
${lsu_tstmuu}    lsu_tstmuu
${airmosaic}    airmosaic
${node_name}    airmosaic
${5gcell_path1}    /res/sdr/state/c5gnr.ue/01
${5gcell_path2}    /res/sdr/state/c5gnr.ue/02
${SYNC}    STATE_00 = SYNC

*** Keywords *** 
Prisma Setup 
    [Arguments]       ${yaml_path}        ${tl_info}
    [Documentation]    This keyword is used to setup prisma.
    ...    | Input Parameters | Man. | Description |
    ...    | yaml_path | Yes | path of yaml file |
    ...    | tl_info | Yes | variable for prisma |
    ...    Example:
    ...    | Prisma Setup | ${CURDIR}/risma.yml   |   ${tl.ues[0]}  |
    prisma.load_config     ${yaml_path}    ${tl_info}
    prisma.setup 

Prisma Teardown 	
    [Documentation]    This keyword is used to teardown prisma.
    Run Keyword And Ignore Error    prisma.get_bug_report    ${TEST_LOG_DIRECTORY()}/prisma_bug_report.zip
    Run Keyword And Ignore Error    prisma.close_mosaic
    prisma.teardown
	
	
Prisma Start Lsu And Wait Cell Ready
	[Documentation]    This keyword is used to start lsu and wait cell ready. 
    ${response}=    prisma.start_lsu    ${lsu_uu}    200
    should contain      ${response[1]}       lsustart completed correctly
    prisma.create_5g_cell    ${lsu_uu}
    prisma.create_4g_cell    ${lsu_uu}      
    wait until keyword succeeds    5 min    20 sec    _Check the NRcell sync     ${5gcell_path1}
    wait until keyword succeeds    1 min    20 sec    _Check the NRcell sync     ${5gcell_path2}

_Check the NRcell sync
    [arguments]      ${5gcell_path}
    ${output}     prisma.execute_script     node_name=${lsu_uu}   script_cmd=cat ${5gcell_path} | grep SYNC
    Should Be Equal    ${output[1]}    ${SYNC}	

Prisma Airmosaic Start
    [arguments]       ${sid_name}     ${sce_path}
    [Documentation]    This keyword is used to start prisma Airmosaic.
    ...    | Input Parameters | Man. | Description |
    ...    | sid_name | Yes | name of sid |
    ...    | sce_path | Yes | path of sce |
    ...    Example:
    ...    | Prisma Airmosaic Start |   gaolei.sid  |  ${CURDIR}${/}SA_scenario  |	
    prisma.close_mosaic
    prisma.start_mosaic
    sleep    50
    wait until keyword succeeds    1 min    20 sec    prisma.prepare_test    ${sid_name}     ${sce_path}      60
    prisma.get_scenario_status
    sleep     30

Prisma Ue Attach
    [Documentation]    This keyword is used to ue attach.
    prisma.ue_attach
    prisma.get_scenario_status
    sleep     60
    Wait Until Keyword Succeeds     20     2    _check Scenario Logger    UE Attached     1
    #Wait Until Keyword Succeeds     20     2    _check Scenario Logger    RA_SuccessCompletion    1
    ${ip}    should match Regexp      ${scenario_log}      IP\\=(\\d+.\\d+.\\d+.\\d+)
    [return]    ${ip[1]}

_check Scenario Logger
    [arguments]       ${msg}     ${times}
    ${ret}    prisma.get_scenario_logger    
    ${ret}    Convert To String     ${ret}
    Should Contain X Times     ${ret}     ${msg}      ${times}
    set suite variable     ${scenario_log}    ${ret}

Prisma get counters
    [Documentation]    This keyword is used to get counters.
    ...    Example:
    ...    | ${tp} |   Prisma get counters  |	
    ...    | should be true |   ${tp['DigitalBeams_1_0_bNrPdschGenIniThroughput']} > 500000  |	
    ${ret}    prisma.get_counters
    ${counters} 	Create Dictionary	
    FOR    ${counter}     IN    @{ret}
        Set To Dictionary	    ${counters}	     ${counter['category']}_${counter['instance']}_${counter['name']}    ${counter['value']}
    END
    [return]     ${counters}
    
Prisma Ue Detach
    prisma.ue_detach	