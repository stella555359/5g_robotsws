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


Library         taf.nms.netact
Resource        ../LM_resources/lib_SFE.robot

Suite Setup  Run Keywords     Setup NMS    ${NMS_LAB}    AND
...                           Set Suite Variable    ${5G}    TRUE    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    cls-services    ${CLS_API_HOST}   root    ${NA_ROOT_PASS}    AND
...                           Add Node    cls-db    ${CLS_DATABASE_HOST}    root    ${NA_ROOT_PASS}

Suite Teardown  Run Keywords    Delete Node    cls-services    AND
...                             Delete Node    cls-db         AND
...                             Clean All

*** Variables ***
${NMS_LAB}              srnclab2009

*** Test Cases ***
Removing Licenses
    Log    \nRequired licenses are removed from CLS    console=True
#   ==============================================================

    Log    \n64 QAM in UL LK    console=True
    Delete_License    license_serialnumber=0011159199105    license_filename=V5100175

    Log    \nSBTS Data User LK    console=True
    Delete_License    license_serialnumber=9991058588929    license_filename=U5000838.XML

    Log    \n5G SA and NSA Users LK    console=True
    Delete_License    license_serialnumber=9991189991041    license_filename=V0100110.XML

    Log    \n5G Busy Hour UP Throughput (Mbps)   console=True
    Delete_License    license_serialnumber=9991253862785    license_filename=V0100111.XML

    Log    \nASOG Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=9991195112353    license_filename=V0100153.XML

    Log    \nASOH Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=9991213966753    license_filename=V0100154.XML

    Log    \nRF unit TX Activation LK    console=True
    Delete_License    license_serialnumber=9991022952001    license_filename=V0100300.XML

    Log    \nRF unit RX Activation LK    console=True
    Delete_License    license_serialnumber=9991258859073    license_filename=V0100301.XML

    Log    \noBW Activation beyond 40Mhz per Band LK    console=True
    Delete_License    license_serialnumber=9991082578817    license_filename=V0100302.XML

    Log    \niBW Activation beyond 60Mhz per Band   console=True
    Delete_License    license_serialnumber=9991196872017    license_filename=V0100303.XML

    Log    \nVP Inter/Intra-freq handover via NG LK    console=True
    Delete_License    license_serialnumber=9991078387345    license_filename=V0100304.XML

    Log    \nVP Network Energy Efficiency- step 1 LK    console=True
    Delete_License    license_serialnumber=9991229457713    license_filename=V0100305.XML

    Log    \nASOF Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=9991079742833    license_filename=V0100306.XML

    Log    \nSuper Cell Activation LK    console=True
    Delete_License    license_serialnumber=9991041410369    license_filename=V0100307.XML

    Log    \nSBTS system module sharing LK    console=True
    Delete_License    license_serialnumber=0011231931265    license_filename=V4400135.XML

    Log    \nASOE Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=9991089870401    license_filename=V0200197.XML

    Log    \nABIO Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=9991047978289    license_filename=V0200218.XML

    Log    \noABIN Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=9991056296065    license_filename=V0200220.XML

    Log    \nABIP Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=0011102245297    license_filename=V4400430.XML

    Log    \nAABIQ Baseband Capacity Activation LK    console=True
    Delete_License    license_serialnumber=0011125511489    license_filename=V4400408.XML

    Log    \nNB-IoT LK LK    console=True
    Delete_License    license_serialnumber=9991240111409    license_filename=U0100172.XML

    Log    \nSBTS 2x5W Pico Power LK    console=True
    Delete_License    license_serialnumber=0011120395249    license_filename=V2100258.XML

    Log    \nData Session Profiling LK    console=True
    Delete_License    license_serialnumber=9991228794545    license_filename=V0200552.XML

    Log    \nData Session Profiling LK    console=True
    Delete_License    license_serialnumber=9991054326065    license_filename=V0200553.XML

    Log    \nSBTS Essential Pack LK    console=True
    Delete_License    license_serialnumber=0011000887985    license_filename=V2100257.XML

    Log    \nOpen O1 readiness LK    console=True
    Delete_License    license_serialnumber=9991219634801    license_filename=V0201227.XML

    Log    \nSBTS Incremental 20W Power LK    console=True
    Delete_License    license_serialnumber=0011179931249    license_filename=V0300205.XML

    Log    \n20W output power for mMIMO LK    console=True
    Delete_License    license_serialnumber=0011098405345    license_filename=V0700173.XML

    Log    \nBand activation for mMIMO LK    console=True
    Delete_License    license_serialnumber=0011131431041    license_filename=V0700174.XML

    Log    \n20MHz bandwidth for mMIMO LK    console=True
    Delete_License    license_serialnumber=0011177505681    license_filename=V0700175.XML

    Log    \n4 DL layer activation for mMIMO LK    console=True
    Delete_License    license_serialnumber=0011068717121    license_filename=V0700176.XML

    Log    \nSBTS Incremental 20W Power LK    console=True
    Delete_License    license_serialnumber=0011068817489    license_filename=V1200084.XML

    Log    \nAirScale System Module Activation LK    console=True
    Delete_License    license_serialnumber=0011136936673    license_filename=V3700051.XML

    Log    \nSBTS REST API Interface Activation LK    console=True
    Delete_License    license_serialnumber=0011070918049    license_filename=V4300225.XML
