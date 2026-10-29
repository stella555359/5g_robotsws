*** Settings ***
Library    OperatingSystem
Library    Process
Library    Collections
Library    DateTime
Library    String
Library    Telnet
Library    XML    use_lxml=${True}
Library    json
Library    ute_wtssim
Library    ute_syslog
Library    ute_fsmaccess
Library    ta_a2a
Library    taf.wts.config
Library    taf.config.wts
Library    taf.transport.ssh    WITH NAME    SSH

*** Variables ***
${gnb_index}              0
&{AP}                     ip=192.168.200.129
...                       username=toor4nsn
...                       password=oZPS0POrRieRtu
@{FDD_RRU_LIST}           AHCA    AHBCC    AHIB    AHBCB    AHFIA    AHFIB    AHPB    AHHB    ARHA
@{TDD_RRU_LIST}           AEQP    AEQY    AEQE    AZQJ    AZQI
${SUITE_LOG_DIRECTORY}    ${EMPTY}
${TEST_LOG_DIRECTORY}     ${EMPTY}
${WTS_DIR}                /opt/iphy/latest
${WTS_CFG}                ${EMPTY}    # basic_fullstack_nsa_call_tdd_cmwv.cfg
${NAMESPACE}              ${EMPTY}    #7-5-ute5gaic015
${VCU_SW_VERSION}         ${EMPTY}    #0.250.5371
${VDU_SW_VERSION}         ${EMPTY}    #0.300.6214
