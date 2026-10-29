# @Time    : 2021/12/20 10:01
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : 5GC002033_precondition.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Resource    5GC002033_keywords.robot

*** Keywords ***
Case 11 Precondition
    Cloud DU connect to gnb coam via ssl
    Verify RU Online
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    Enable capture soap msg flag on RU

Case 12 Precondition
    Cloud DU connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${CURDIR}/scf/5GC002033_case12_du_scf.xml
    ...    is_pdl_checking_needed=False
    Wait Until Keyword Succeeds    10min    30s    COAM Check GNB cell on air
    COAM Teardown gnb connections

Case 12 Teardown
    Cloud DU connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${CURDIR}/scf/5GC002033_basic_du_scf.xml
    ...    is_pdl_checking_needed=False
    Wait Until Keyword Succeeds    10min    30s    COAM Check GNB cell on air
    COAM Teardown gnb connections