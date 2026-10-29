*** Settings ***
Library     Collections
Library     String
Library     OperatingSystem
Library   taf.transport.ssh   WITH NAME   csn
#Library     taf.sbts.oam.coam.admin   WITH NAME   sbts
Library     counter_ops.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB007271-5GC000952/resources/common.robot



*** Variables ***
${coam_alias}    COAM
${file_to_rename}=             /mnt/factory/configs/unit/calibration_dlpath1.bin
${temp_filename}=              /mnt/factory/configs/unit/temp_filename

*** Keywords ***
Trigger Fault 1901 AHPF
    [Arguments]    ${ru_index}=${L3CALL_cellid}
    Connect Ssh To Asix
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asix
    Connect to RU With Allocated IP
    ...     ru_index=${ru_index}
    ...     ru_alias=ru
    ...     asik_alias=asix
    ...     container_id=${FHNETcontainer_id}
    ...     connection=${coam_alias}
    ssh.execute     mv ${file_to_rename} ${temp_filename}    connection=ru   timeout=60s
#    ssh.Send Command     /sbin/reboot    connection=ru
    COAM Reset RMOD   dist_name=MRBTS-${GLOBAL_BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}  connection=${coam_alias}
    [Teardown]  run_keywords    run keyword and ignore error    csn.disconnect    connection=ru  AND
    ...                         run keyword and ignore error    Disconnect Ssh From Asix

Cancel Fault 1901 AHPF
    [Arguments]    ${ru_index}=${L3CALL_cellid}
    Connect Ssh To Asix
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asix
    Connect to RU With Allocated IP
    ...     ru_index=${ru_index}
    ...     ru_alias=ru
    ...     asik_alias=asix
    ...     container_id=${FHNETcontainer_id}
    ...     connection=${coam_alias}
    ssh.execute     mv ${temp_filename} ${file_to_rename}   connection=ru
    COAM Reset RMOD   dist_name=MRBTS-${GLOBAL_BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}  connection=${coam_alias}
    [Teardown]  run_keywords    run keyword and ignore error    csn.disconnect    connection=ru  AND
    ...                         run keyword and ignore error    Disconnect Ssh From Asix

Fault 1901 cycle AHPF
    [Arguments]    ${ru_index}=${L3CALL_cellid}
    log to console   starting Fault 1901 cycle
    Trigger Fault 1901 AHPF    ru_index=${ru_index}
    FOR    ${CYCLE_INDEX}  IN RANGE    0   3
       wait until keyword succeeds    1000sec    2sec    Expect Fault Should Present   faultId=1901    connection=${coam_alias}
       log to console    start check RU INITIALING STATES...
       Wait Fault with Alarm to disappear      FaultID=1901    AlarmID=7101
       log to console    ${${CYCLE_INDEX}+1} recovery action done
    END
    Wait Fault with Alarm to appear    FaultID=1901    AlarmID=7111
    Cancel Fault 1901 AHPF    ru_index=${ru_index}
    Wait Fault with Alarm to disappear      FaultID=1901    AlarmID=7111


Fault 1901 trigger once
    [Arguments]    ${ru_index}=${L3CALL_cellid}
    log to console   starting Fault 1901
    Trigger Fault 1901 AHPF    ru_index=${ru_index}
#    wait until keyword succeeds    1000sec    3sec    Check components status while recovery action    recovery_component=RMOD
#    ...   index=${ru_index}
    wait until keyword succeeds    1000sec    2sec    Expect Fault Should Present   faultId=1901    connection=${coam_alias}
#    wait until keyword succeeds    600sec    1sec    Check component reset status    recovery_component=RMOD
#    ...    index=${ru_index}
    Wait Fault with Alarm to disappear      FaultID=1901    AlarmID=7101
    log to console     RU reset action done
    wait until keyword succeeds    600    30   Cancel Fault 1901 AHPF    ru_index=${ru_index}
    log to console     Fault 1901 recovery action done

