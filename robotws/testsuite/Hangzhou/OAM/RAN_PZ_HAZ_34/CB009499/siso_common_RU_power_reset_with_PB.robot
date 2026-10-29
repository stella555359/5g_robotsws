*** Settings ***
Documentation
...    Author: ruiyu.han@nokia-sbell.com
...    to define SG07 siso_common_RU_power_reset_with_PB

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown

*** Test Cases ***
siso_common_RU_power_reset_with_PB
    [Timeout]  8h
    [Setup]    Case Setup:siso_common_RU_power_reset_with_PB
    FOR   ${index}    IN RANGE    ${3}
        log to console     //this is index：${index} time do RU Power Reset...
        Wait Until Keyword Succeeds    2m   30s   COAM Login
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['ru_power_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
        All Site RUs Power Reset
        COAM Logout
     END
     [Teardown]   Case Teardown:siso_common_RU_power_reset_with_PB


*** Keywords ***
Case Setup:siso_common_RU_power_reset_with_PB
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     COAM WEBUI Login
     COAM Backup Full SCF   file_name=RUreset_scf.xml
     ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/RUreset_scf.xml
     ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${scf_xml}
     ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${scf_xml}
     set test variable     ${rmod_cell_mapping}
     set test variable     ${rmod_serial_mapping}
     ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
     ${ru_count}   Get Length   ${rus}
     set test variable     ${rus}
     set test variable     ${ru_count}
     [Teardown]    COAM Logout

Case Teardown:siso_common_RU_power_reset_with_PB
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     run keyword if  ${rulog_exist}    run keywords
     ...   run keyword if test failed    RU Log Operation Teardown if keyword failed
     ...   AND    run keyword if test passed    RU Log Operation Teardown if keyword passed
     Siso Common Save Logs
     FOR   ${index}    IN RANGE    ${ru_count}
         pdu.setup_pdu   model=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu}
         ...   host=${rus[${index}].pdu_port.pdu.addr}   alias=ru_${index}
         PDU power operation   pb_port=${rus[${index}].pdu_port.port_no}   alias=ru_${index}
         pdu.teardown_pdu    pdu_device=ru_${index}
     END
     Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
     COAM WEBUI Logout
     [Teardown]    COAM Logout


