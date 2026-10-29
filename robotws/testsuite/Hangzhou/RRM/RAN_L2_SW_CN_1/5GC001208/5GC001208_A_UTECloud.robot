*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords
#...                Suite Setup Update GNB    scf_file=${DELTA_FILE}    skip_reboot=${False}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Common Test Setup
#Test Teardown     Run Keywords    Common Test Teardown    debug
#...                AND    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}/myconfigs/
#Force Tags        CIT    RAN_5G_TDD
#...               CDRT    FR1    Owner_yuema    PRI-High
#...               SBTS00    SBTS23R1    SBTS22R3    SBTS22R4    RAN_5G    CN1_SQ
#...               CLOUD_5G_I_LO_AP_LO    AP_REG    P3_REG
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#*** Variables ***
#${SCF_PATH}            ${CURDIR}/config
#${DELTA_FILE}          ${CURDIR}/Delta_Conf_5GC001208_A.json
#@{LOG_NAME_LIST}       btslog    snapshot    sosreport
#${COUNT}               0
#${DU_HOST}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${DU_USER}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${DU_PWD}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${filepath}           /tmp/ASP-1740_startup.log
#${LOG_PATH}           ${OUTPUT DIR}
#
#*** Test Cases ***
#
#5GC001208 ET A002 SS PBCH transmission in dBF below 6GHz n78 100MHz with semiStatic TDD frame structure 1-4
#    [Tags]    case2    P3_REG
#    #TDD_SA_UEID_Configuration
#    #UE Id=1 SA cell 1
#    #UE Id=21 SA cell 2
#    #FDD_SA_UEID_Configuration
#    #UE Id=51 SA cell=3
#    #UE Id=71 SA cell=4
#    #TDD_NSA_UEID_Configuration
#    #UE Id=101 NSA cell=1
#    #UE Id=121 NSA cell=2
#    #FDD_NSA_UEID_Configuration
#    #UE Id=151 NSA cell=3
#    #UE Id=171 NSA cell=4
#    Attach NSA UE and Get Throughput    UE_ID=101    dl_tp_set=100    ul_tp_set=50    dl_tp_threshold=50    ul_tp_threshold=5
#    Attach SA UE and Get Throughput    UE_ID=1
#    ...    dl_tp_set=100    ul_tp_set=50    dl_tp_threshold=50    ul_tp_threshold=5
#
#*** Keywords ***
#Check Slot Type For 1208
#    ssh.connect_to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=DU_conn
#    ssh.execute    bget 1:1 /tmp/node_L2RT20/tmp/ASP-1740_startup.log /tmp/ ASP-1740_startup.log    connection=DU_conn
#    ssh.execute    bget 1:1 /tmp/node_L2RT20/tmp/ASP-1740_startup.zip /tmp/ ASP-1740_startup.zip    connection=DU_conn
#    ${output}    ssh.execute    ls /tmp | grep ASP-1740_startup.zip    connection=DU_conn
#    Run Keyword If    '${output.strip()}'== 'ASP-1740_startup.zip'    ssh.execute    unzip -o -d /tmp /tmp/ASP-1740_startup.zip
#    ...    connection=DU_conn
#    ssh.download_file    remote_path=${filepath}    local_path=${LOG_PATH}/ASP-1740_startup_1208.log    connection=DU_conn
#    ${line}    ssh.execute    awk '/Msg2ToMsg3OffsetCalculator: ulDlDataSlotRatio\=RATIO1_4/{print NR;exit}' ${filepath}    connection=DU_conn
#    Should be true    ${line.strip()}!=''
#    : FOR    ${sub}    IN    @{slottype_list_1208}
#    \    ${line.strip()}    Evaluate    ${line.strip()}+1
#    \    ${content}    ssh.execute    sed -n '${line.strip()}p' ${filepath}    connection=DU_conn
#    \    ${match_result}    Should Match Regexp    ${content}    ${sub}
#
#
