*** Settings ***
Library         String
Library         Collections
Library         ${CURDIR}/../../myLib_maths.py

Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../configuration.robot

*** Keywords ***
Collect L1L2 gNB Trcaes
    [Documentation]  keyword to collect L1L2 gNB traces for 10s
    [Arguments]     ${duration_time}=10s
    [Tags]    DEBUG
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH
    configuration.Create Connections
    configuration.Create ssh

    ##Take L1L2 logs
    gnbMirroring.Start Mirroring Traces    connection=asikFhCnx
    gnbMirroring.Check tcpdump Process is Running    connection=asikFhCnx
    BuiltIn.Sleep    ${duration_time}
    ${l1l2file}    gnbMirroring.Stop and Collect Mirroring Traces   connection=asikFhCnx

    Log  ************************ ${l1l2file} *************************

    configuration.luashark config       expand_field=0         expand_struct=1

    ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${l1l2file} -T fields
    ...       -Y "dldata_ssblocksendreq" -e _ws.col.Info -e DlData_SsBlockSendReq.SsBlockSendReq.slot
    ...       -e DlData_SsBlockSendReq.patternId.patternId -E header=y -E separator=, > ${logs_path}/pcapprocessedPatternsId_ssb.txt
    Run         ${cmd}

    ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${l1l2file} -T fields
    ...       -Y "uldata_prachreceivereq" -e _ws.col.Info -e UlData_PrachReceiveReq.PrachReceiveReq.slot
    ...       -e UlData_PrachReceiveReq.patternId.patternId -E header=y -E separator=, > ${logs_path}/pcapprocessedPatternsId_pRACH.txt
    Run         ${cmd}

    configuration.luashark config

SSB Auto Mapping
    [Documentation]  Find SSB BeamSet configuration for beamforming traces analysis
    [Tags]    DEBUG
    [Arguments]      ${beamSetAbf}=beamSetAbf_32A

    @{SSB_id}    Create list    0x00000001    0x00000003    0x00000005    0x00000007    0x0000000b    0x0000000d    0x0000000f    0x00000011

    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSetAbf}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bss}      Split String    @{lines}[0]    separator=;
    @{bs}       Create List

    FOR    ${index}    IN RANGE    7    39
         ${var}=    myLib_maths.formated_hex_string_v2    @{bss}[${index}]
	     Append To List    ${bs}    ${var}
	END
    log     ${bs}
    # ${pb}       set variable        7

    FOR    ${index}    IN RANGE    0    8
         ${pb}       Evaluate       ${index}*4
         ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatternsId_ssb.txt | grep -E 'ICOM_5G/
          ...         DlData_SsBlockSendReq, MIB,@{SSB_id}[${index}],@{bs}[${pb}]@{bs}[${${pb}+1}]@{bs}[${${pb}+2}]@{bs}[${${pb}+3}]' -c
         ${nb_pattern_specific}      Run      ${cmd}
         ${nb_pattern_specific}      Convert to Number   ${nb_pattern_specific}  2
         log to console      ${nb_pattern_specific} SSB slot @{SSB_id}[${index}] -> @{bs}[${pb}], @{bs}[${${pb}+1}], @{bs}[${${pb}+2}],
          ...             @{bs}[${${pb}+3}]
         ${cmd}      catenate      SEPARATOR=    cat ${logs_path}/pcapprocessedPatternsId_ssb.txt | grep -E 'ICOM_5G/DlData_SsBlockSendReq, MIB,
          ...           @{SSB_id}[${index}]     ,' -c
         ${nb_pattern}               Run      ${cmd}
         ${nb_pattern}      Convert to Number   ${nb_pattern}  2
         ${result}                   Evaluate   ${nb_pattern}/${nb_pattern_specific}
         Should Be True              0.8 < ${result} < 1.2
    END


pRACH Auto Mapping
    [Documentation]  check patternId during pRACH slot every SFN During 8 SFN to cover 32 patternId for every
    ...              for beamforming
    [Tags]    DEBUG
    [Arguments]      ${beamSetAbf}=beamSetAbf_32A

    @{pRach}    Create list    0x00000009  0x00000013  0x0000001d  0x00000027  0x00000031  0x0000003b  0x00000045  0x0000004f  0x00000009
    ...                        0x00000013  0x0000001d

    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSetAbf}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bss}      Split String    @{lines}[0]    separator=;
    @{bs}       Create List

    FOR    ${index}    IN RANGE    7    39
         ${var}=    myLib_maths.formated_hex_string_v2    @{bss}[${index}]
	     Append To List    ${bs}    ${var}
    END

	log     ${bs}

    FOR   ${index}    IN RANGE    0    11
         ${pb}       Evaluate       ${index}*3
         ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatternsId_pRACH.txt | grep -E 'ICOM_5G/
          ...         UlData_PrachReceiveReq,@{pRach}[${index}],@{bs}[${pb}](00){2},@{bs}[${${pb}+1}](00){2}
          ${cmd}     Set Variable If    ${index} < 10
          ...           ${cmd},@{bs}[${${pb}+2}](00){2}
          ...           ${cmd}

         ${nb_pattern_specific}      Run      ${cmd}' -c
         ${nb_pattern_specific}      Convert to Number   ${nb_pattern_specific}  2
         Run Keyword If     ${index} < 10
         ...     log to console      ${nb_pattern_specific} RACH slot @{pRach}[${index}] -> @{bs}[${pb}], @{bs}[${${pb}+1}], @{bs}[${${pb}+2}],
         ...    ELSE
         ...     log to console      ${nb_pattern_specific} RACH slot @{pRach}[${index}] -> @{bs}[${pb}], @{bs}[${${pb}+1}],

         ${cmd}      catenate      SEPARATOR=    cat ${logs_path}/pcapprocessedPatternsId_pRACH.txt | grep -E 'ICOM_5G/
          ...         UlData_PrachReceiveReq,@{pRach}[${index}],' -c
         ${nb_pattern}               Run      ${cmd}
         ${nb_pattern}      Convert to Number   ${nb_pattern}  2
         ${result}                   Evaluate   ${nb_pattern}/${nb_pattern_specific}
         Run Keyword If    3 <= ${index} < 8
         ...               Should Be True              0.8 < ${result} < 1.2
         ...    ELSE
         ...               Should Be True              1.8 < ${result} < 2.2
    END
