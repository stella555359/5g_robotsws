*** Settings ***
Documentation
            ...  Test for uploading licenses to CLS database
            ...  = Author =
            ...    _damian.porebski@nokia.com_
            ...  = Maintainer =
            ...    _damian.porebski@nokia.com_
            ...    _agnieszka.bala@nokia.com_
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Reviewer =
            ...    _agnieszka.bala@nokia.com_
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    - if indicated licenses are uploaded to CLS correctly
            ...  = Pre - requirements =
            ...    -Indicated licenses are not avaiable in CLS
            ...  = Expected results =
            ...    -Test is marked as PASSED
            ...    -Licenses are uploaded to CLS
            ...  = Additional Info =
            ...    N/A


Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         String
Library         XML    use_lxml=True
Library         ute_admin
Library         ute_admin_infomodel
Library         taf.nms.netact
Resource        ../LM_resources/lib_SFE.robot

Suite Setup  Run Keywords     Setup NMS    ${NMS_LAB}    AND
...                           Suite Setup Infomodel    im_port=443    AND
...                           Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443    use_ssl=True    timeout=90s    AND
...                           Get And Set Enb Parameters    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add Node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    cls-services    ${CLS_API_HOST}   root    ${NA_ROOT_PASS}    AND
...                           Add Node    cls-db    ${CLS_DATABASE_HOST}    root    ${NA_ROOT_PASS}

Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Stop Capturing Logs And Collect    ${SUITE_STATUS}    AND
...                             Teardown Infomodel    AND
...                             Teardown Admin    AND
...                             Delete Node    cls-services    AND
...                             Delete Node    cls-db         AND
...                             Delete Node    cmwas         AND
...                             Clean All

*** Variables ***
${NMS_LAB}              srnclab2009
${ENB_ROOT_USER}        toor4nsn
${ENB_ROOT_PASS}        oZPS0POrRieRtu

*** Test Cases ***
Uploading Licenses
    [Documentation]    This test uploads CRT LKs
    Log    \n64 QAM in UL LKLK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V5100175.XML    ${RESULTS}${/}V5100175.XML
    Set Suite Variable    ${License_template0}    ${RESULTS}${/}V5100175.XML
    Upload_License    ${License_template0}

    Log    \nSBTS Data User LKLK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/U5000838.XML    ${RESULTS}${/}U5000838.XML
    Set Suite Variable    ${License_template1}    ${RESULTS}${/}TU5000838.XML
    Upload_License    ${License_template1}

    Log    \n5G SA and NSA Users LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100110.XML    ${RESULTS}${/}V0100110.XML
    Set Suite Variable    ${License_template2}    ${RESULTS}${/}V0100110.XML
    Upload_License    ${License_template2}

    Log    \n5G Busy Hour UP Throughput (Mbps) LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100111.XML    ${RESULTS}${/}V0100111.XML
    Set Suite Variable    ${License_template3}    ${RESULTS}${/}V0100111.XML
    Upload_License    ${License_template3}

    Log    \nASOG Baseband Capacity Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100153.XML    ${RESULTS}${/}V0100153.XML
    Set Suite Variable    ${License_template4}    ${RESULTS}${/}V0100153.XML
    Upload_License    ${License_template4}

    Log    \nASOH Baseband Capacity ActivationLK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100154.XML    ${RESULTS}${/}V0100154.XML
    Set Suite Variable    ${License_template5}    ${RESULTS}${/}V0100154.XML
    Upload_License    ${License_template5}

    Log    \nRF unit TX Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100300.XML    ${RESULTS}${/}V0100300.XML
    Set Suite Variable    ${License_template6}    ${RESULTS}${/}V0100300.XML
    Upload_License    ${License_template6}

    Log    \nRF unit RX Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100301.XML    ${RESULTS}${/}V0100301.XML
    Set Suite Variable    ${License_template7}    ${RESULTS}${/}V0100301.XML
    Upload_License    ${License_template7}

    Log    \noBW Activation beyond 40Mhz per Band LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100302.XML    ${RESULTS}${/}V0100302.XML
    Set Suite Variable    ${License_template8}    ${RESULTS}${/}V0100302.XML
    Upload_License    ${License_template8}

    Log    \niBW Activation beyond 60Mhz per Band LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100303.XML    ${RESULTS}${/}V0100303.XML
    Set Suite Variable    ${License_template9}    ${RESULTS}${/}V0100303.XML
    Upload_License    ${License_template9}

    Log    \nVP Inter/Intra-freq handover via NG LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100304.XML    ${RESULTS}${/}V0100304.XML
    Set Suite Variable    ${License_template10}    ${RESULTS}${/}V0100304.XML
    Upload_License    ${License_template10}

    Log    \nVP Network Energy Efficiency- step 1 LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100305.XML    ${RESULTS}${/}V0100305.XML
    Set Suite Variable    ${License_template11}    ${RESULTS}${/}V0100305.XML
    Upload_License    ${License_template11}

    Log    \nASOF Baseband Capacity Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100306.XML    ${RESULTS}${/}V0100306.XML
    Set Suite Variable    ${License_template12}    ${RESULTS}${/}V0100306.XML
    Upload_License    ${License_template12}

    Log    \nSuper Cell Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0100307.XML    ${RESULTS}${/}V0100307.XML
    Set Suite Variable    ${License_template13}    ${RESULTS}${/}V0100307.XML
    Upload_License    ${License_template13}

    Log    \nSBTS system module sharing LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V4400135.XML    ${RESULTS}${/}V4400135.XML
    Set Suite Variable    ${License_template14}    ${RESULTS}${/}V4400135.XML
    Upload_License    ${License_template14}

    Log    \nABIO Baseband Capacity Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0200218.XML    ${RESULTS}${/}V0200218.XML
    Set Suite Variable    ${License_template15}    ${RESULTS}${/}V0200218.XML
    Upload_License    ${License_template15}

    Log    \nABIN Baseband Capacity Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0200220.XML    ${RESULTS}${/}V0200220.XML
    Set Suite Variable    ${License_template16}    ${RESULTS}${/}V0200220.XML
    Upload_License    ${License_template16}

    Log    \nABIP Baseband Capacity Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V4400430.XML    ${RESULTS}${/}V4400430.XML
    Set Suite Variable    ${License_template17}    ${RESULTS}${/}V4400430.XML
    Upload_License    ${License_template17}

    Log    \nABIQ Baseband Capacity Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V4400408.XML    ${RESULTS}${/}V4400408.XML
    Set Suite Variable    ${License_template17}    ${RESULTS}${/}V4400408.XML
    Upload_License    ${License_template17}

    Log    \nSBTS 2x5W Pico Power LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V2100258.XML    ${RESULTS}${/}V2100258.XML
    Set Suite Variable    ${License_template18}    ${RESULTS}${/}V2100258.XML
    Upload_License    ${License_template18}

    Log    \nData Session Profiling LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0200552.XML    ${RESULTS}${/}V0200552.XML
    Set Suite Variable    ${License_template19}    ${RESULTS}${/}V0200552.XML
    Upload_License    ${License_template19}

    Log    \nData Session Profiling LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0200553.XML    ${RESULTS}${/}V0200553.XML
    Set Suite Variable    ${License_template20}    ${RESULTS}${/}V0200553.XML
    Upload_License    ${License_template20}

    Log    \nSBTS Essential Pack LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V2100257.XML    ${RESULTS}${/}V2100257.XML
    Set Suite Variable    ${License_template21}    ${RESULTS}${/}V2100257.XML
    Upload_License    ${License_template21}

    Log    \nOpen O1 readiness LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0201227.XML    ${RESULTS}${/}V0201227.XML
    Set Suite Variable    ${License_template22}    ${RESULTS}${/}V0201227.XML
    Upload_License    ${License_template22}

    Log    \nBand activation for mMIMO LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0700174.XML    ${RESULTS}${/}V0700174.XML
    Set Suite Variable    ${License_template23}    ${RESULTS}${/}V0700174.XML
    Upload_License    ${License_template23}

    Log    \n20MHz bandwidth for mMIMO LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0700175.XML    ${RESULTS}${/}V0700175.XML
    Set Suite Variable    ${License_template24}    ${RESULTS}${/}V0700175.XML
    Upload_License    ${License_template24}

    Log    \n4 DL layer activation for mMIMO LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V0700176.XML   ${RESULTS}${/}V0700176.XML
    Set Suite Variable    ${License_template25}    ${RESULTS}${/}V0700176.XML
    Upload_License    ${License_template25}

    Log    \nSBTS Incremental 20W Power LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V1200084.XML    ${RESULTS}${/}V1200084.XML
    Set Suite Variable    ${License_template26}    ${RESULTS}${/}V1200084.XML
    Upload_License    ${License_template26}

    Log    \nSBTS 2x5W Pico Power LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/U2800496.XML    ${RESULTS}${/}U2800496.XML
    Set Suite Variable    ${License_template27}    ${RESULTS}${/}U2800496.XML
    Upload_License    ${License_template27}

    Log    \n4 DL layer activation for mMIMO LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/U0400039.XML    ${RESULTS}${/}U0400039.XML
    Set Suite Variable    ${License_template28}    ${RESULTS}${/}U0400039.XML
    Upload_License    ${License_template28}

    Log    \nLicense AirScale System Module Activation LK is uploaded    console=True
    Copy File    ${CURDIR}/licenses/V3700051.XML    ${RESULTS}${/}V3700051.XML
    Set Suite Variable    ${License_template29}    ${RESULTS}${/}V3700051.XML
    Upload_License    ${License_template29}

    Log    \nSBTS REST API Interface Activation LK    console=True
    Copy File    ${CURDIR}/licenses/V4300225.XML    ${RESULTS}${/}V4300225.XML
    Set Suite Variable    ${License_template30}    ${RESULTS}${/}V4300225.XML
    Upload_License    ${License_template30}

    Reports generation

*** Keywords ***

Reports generation
    Log    \nGeneration of SWEM for SRAN CM    console=True
    ${module}=    Get Modules    moduleName=SWEM for SRAN CM    detailed=${FALSE}
#   Log    \nCurrent module is: ${module}    console=True
    ${report_id}=    Generate Reports    ${module[0]}

#   Log    \nCurrent report id is: ${report_id}    console=True
#    Log    \nGeneration of LTE FDD PM    console=True
#    ${module}=    Get Modules    moduleName=SWEM for LTE FDD PM    detailed=${FALSE}
##    Log    \nCurrent module is: ${module}    console=True
#    ${report_id}=    Generate Reports    ${module[0]}
##    Log    \nCurrent report id is: ${report_id}    console=True
#
#    Log    \nGeneration of SWEM for SRAN PM    console=True
#    ${module}=    Get Modules    moduleName=SWEM for SRAN PM    detailed=${FALSE}
##    Log    \nCurrent module is: ${module}    console=True
#    ${report_id}=    Generate Reports    ${module[0]}
##    Log    \nCurrent report id is: ${report_id}    console=True

#    Log    \nSWAM reports are generated to activate the licenses    console=True
#    Log    \nGeneration of LTE FDD CM    console=True
#    ${module}=    Get Modules    moduleName=SWEM for LTE FDD CM    detailed=${FALSE}
# #   Log    \nCurrent module is: ${module}    console=True
#    ${report_id}=    Generate Reports    ${module[0]}
##    Log    \nCurrent report id is: ${report_id}    console=True

#    Log    \nGeneration of SWEM for 5G CM    console=True
#    ${module}=    Get Modules    moduleName=SWEM for 5G RAN CM    detailed=${FALSE}
##   Log    \nCurrent module is: ${module}    console=True
#    ${report_id}=    Generate Reports    ${module[0]}
#   Log    \nCurrent report id is: ${report_id}    console=True

#    Log    \nGeneration of LTE TD CM    console=True
#    ${module}=    Get Modules    moduleName=SWEM for LTE TD CM    detailed=${FALSE}
# #   Log    \nCurrent module is: ${module}    console=True
#    ${report_id}=    Generate Reports    ${module[0]}
# #   Log    \nCurrent report id is: ${report_id}    console=True
