*** Settings ***
Documentation       Test case for BOAM ET
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Setup       Common BTS Suite Setup
Suite Teardown    Common BTS Suite Teardown
Test Setup    Common BTS Test Setup
Test Teardown    Common BTS Test Teardown
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_Resource.robot
Force Tags        TEAM-BTS_MANO_SOAM5    FEATURE-CB006543    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    OWNER-Cairun

*** Variables ***
${S_BTSID}    1
${TA_LOG_DIRECTORY}    /home/ute/logs

*** Test Cases ***
CB006543-SR-A_01_NE sends expected data in CCNs when CM and HWM and SWM are registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    ...    14.06.2024, yuyan.xu, update case 9/11 upload command, as strict xml verification has been added to enb
    Teardown with Emssim
	Setup with Emssim
    Clear Events
    Set Events Format
    coam.Reset Site
    Sleep   5mins
    Emss Receive Expected CCN
    Teardown with Emssim

CB006543-SR-A_02_NE sends expected data in CCNs when CM and HWM are registered but SWM is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Process.Run Process    sudo cp CB006543/Plan/soc_no_swm.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Process.Run Process    sudo mv soc_no_swm.xml soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
    Setup with Emssim
    Clear Events
    Set Events Format
    coam.Reset Site
    Sleep   5mins
    Emss Receive Expected CCN Without SWM
	Process.Run Process    sudo rm soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Process.Run Process    sudo cp CB006543/Plan/soc.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Teardown with Emssim

CB006543-SR-A_03_NE sends expected data in CCNs when CM and SWM are registered but HWM is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
    Process.Run Process    sudo cp CB006543/Plan/soc_no_hwm.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Process.Run Process    sudo mv soc_no_hwm.xml soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
    Setup with Emssim
    Clear Events
    Set Events Format
    coam.Reset Site
    Sleep   5mins
    Emss Receive Expected CCN Without HWM
	Process.Run Process    sudo rm soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Process.Run Process    sudo cp CB006543/Plan/soc.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Teardown with Emssim

CB006543-SR-A_04_NE sends expected data in CCNs when HWM and SWM are registered but CM is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
    Process.Run Process    sudo cp CB006543/Plan/soc_no_cm.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Process.Run Process    sudo mv soc_no_cm.xml soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
    Setup with Emssim
    Clear Events
    Set Events Format
    coam.Reset Site
    Sleep   5mins
    Emss Receive Expected CCN Without CM
	Process.Run Process    sudo rm soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Process.Run Process    sudo cp CB006543/Plan/soc.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Teardown with Emssim


CB006543-SR-A_05_NE sends expected data in Upload Response when CM and HWM and SWM are registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
    Setup with Emssim
    Clear Events
    Emss Receive Expected Upload
    Teardown with Emssim

CB006543-SR-A_06_NE sends expected data in Upload Response when CM and HWM are registered but SWM is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Process.Run Process    sudo cp CB006543/Plan/soc_no_swm.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Process.Run Process    sudo mv soc_no_swm.xml soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload Without SWM
    Process.Run Process    sudo rm soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Process.Run Process    sudo cp CB006543/Plan/soc.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Teardown with Emssim

CB006543-SR-A_07_NE sends expected data in Upload Response when CM and SWM are registered but HWM is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Process.Run Process    sudo cp CB006543/Plan/soc_no_hwm.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Process.Run Process    sudo mv soc_no_hwm.xml soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload Without HWM
    Process.Run Process    sudo rm soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Process.Run Process    sudo cp CB006543/Plan/soc.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Teardown with Emssim

CB006543-SR-A_08_NE sends expected data in Upload Response when HWM and SWM are registered but CM is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Process.Run Process    sudo cp CB006543/Plan/soc_no_cm.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Process.Run Process    sudo mv soc_no_cm.xml soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload Without CM
    Process.Run Process    sudo rm soc.xml    shell=True    cwd=/opt/emssim/proxy/reg_socs    timeout=5
	Process.Run Process    sudo cp CB006543/Plan/soc.xml /opt/emssim/proxy/reg_socs    shell=True
    ...    cwd=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical    timeout=5
    Teardown with Emssim

CB006543-SR-A_09_NE sends expected data in Upload Response when object class filter is set
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload With Class Filter
    Teardown with Emssim

CB006543-SR-A_10_NE sends expected data in Upload Response when SDN filter is set
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload With SDN Filter
    Teardown with Emssim

CB006543-SR-A_11_NE sends expected data in Upload Response with object class filter for CERT
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload With Class Filter for CERT
    Teardown with Emssim

CB006543-SR-A_12_NE sends expected data in Upload Response when both SDN filter and object class filter are set for CM and HWM
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Setup with Emssim
    Clear Events
    Emss Receive Expected Upload With Both SDN Filter and Class Filter
    Teardown with Emssim

CB006543-SR-A_13_NE sends expected data in Upload Response when Diagnostics Management is not registered
    [Documentation]
    ...    *****************
    ...    | 2022.1.08 | 5G22R3 | CaiRun | first create |
    Teardown with Emssim
	Setup with Emssim
    Clear Events
	Run Keyword And Ignore Error   coam.get remote snapshot    timeout=300
    Emss Receive Expected Upload With SDN Filter for DIAG
    Teardown with Emssim

*** Keywords ***
Emss Receive Expected CCN
    ${data}    Emss Receive All Message From BTS    value=ocos
    ${data}    Evaluate    " ".join(${data})
    Log    ${data}
    Should Contain    ${data}    INVUNIT
    Should Contain    ${data}    NetworkSoftware
    Should Contain    ${data}    NRBTS

Emss Receive Expected CCN Without SWM
    ${data}    Emss Receive All Message From BTS    value=ocos
    ${data}    Evaluate    " ".join(${data})
    Log    ${data}
    Should Contain    ${data}    INVUNIT
    Should Not Contain    ${data}    NetworkSoftware
    Should Contain    ${data}    NRBTS

Emss Receive Expected CCN Without HWM
    ${data}    Emss Receive All Message From BTS    value=ocos
    ${data}    Evaluate    " ".join(${data})
    Log    ${data}
    Should Not Contain    ${data}    INVUNIT
    Should Contain    ${data}    NetworkSoftware
    Should Contain    ${data}    NRBTS

Emss Receive Expected CCN Without CM
    ${data}    Emss Receive All Message From BTS    value=ocos
    ${data}    Evaluate    " ".join(${data})
    Log    ${data}
    Should Contain    ${data}    INVUNIT
    Should Contain    ${data}    NetworkSoftware
    Should Not Contain    ${data}    NRBTS

Emss Receive Expected Upload
    ${data}    Emss Request Upload And Receive Message
    Log    ${data}
    Should Contain    ${data}[1]    INVUNIT
    Should Contain    ${data}[1]    NetworkSoftware
    Should Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload Without SWM
    ${data}    Emss Request Upload And Receive Message
    Log    ${data}
    Should Contain    ${data}[1]    INVUNIT
    Should Not Contain    ${data}[1]    NetworkSoftware
    Should Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload Without HWM
    ${data}    Emss Request Upload And Receive Message
    Log    ${data}
    Should Not Contain    ${data}[1]    INVUNIT
    Should Contain    ${data}[1]    NetworkSoftware
    Should Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload Without CM
    ${data}    Emss Request Upload And Receive Message
    Log    ${data}
    Should Contain    ${data}[1]    INVUNIT
    Should Contain    ${data}[1]    NetworkSoftware
    Should Not Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload With Class Filter
    Set Events Format
	#run EMSsim command    file_upload 2 -upload_type configuration -depth 1 -class NetworkSoftware
	run EMSsim command    file_upload 2 -upload_type configuration -sdn * -depth 1 -object_class NetworkSoftware
	${data}    Wait Until Keyword Succeeds    10s    1s    Emss Receive Message From BTS    ne3scommon:contentType    ocos
    Log    ${data}
    Should Not Contain    ${data}[1]    INVUNIT
    Should Contain    ${data}[1]    NetworkSoftware
    Should Not Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload With Class Filter for CERT
    Set Events Format
	#run EMSsim command    file_upload 2 -upload_type configuration -depth 1 -object_class CMP
	run EMSsim command    file_upload 2 -upload_type configuration -sdn * -depth 1 -object_class CMP
	${data}    Wait Until Keyword Succeeds    10s    1s    Emss Receive Message From BTS    ne3scommon:contentType    ocos
    Log    ${data}
    Should Not Contain    ${data}[1]    INVUNIT
    Should Not Contain    ${data}[1]    NetworkSoftware
    Should Not Contain    ${data}[1]    NRBTS
	Should Contain    ${data}[1]    MRBTS-1/CERTH-1/CMP-1

Emss Receive Expected Upload With SDN Filter
    Set Events Format
	run EMSsim command    file_upload 2 -upload_type configuration -depth 1 -sdn MRBTS-1/NRBTS-1
	${data}    Wait Until Keyword Succeeds    10s    1s    Emss Receive Message From BTS    ne3scommon:contentType    ocos
    Log    ${data}
    Should Not Contain    ${data}[1]    INVUNIT
    Should Not Contain    ${data}[1]    NetworkSoftware
    Should Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload With Both SDN Filter and Class Filter
    Set Events Format
	run EMSsim command    file_upload 2 -upload_type configuration -depth 1 -sdn MRBTS-1/NRBTS-1 -object_class INVUNIT
	${data}    Wait Until Keyword Succeeds    10s    1s    Emss Receive Message From BTS    ne3scommon:contentType    ocos
    Log    ${data}
    Should Contain    ${data}[1]    INVUNIT
    Should Not Contain    ${data}[1]    NetworkSoftware
    Should Contain    ${data}[1]    NRBTS

Emss Receive Expected Upload With SDN Filter for DIAG
    Set Events Format
#	run EMSsim command    file_upload 2 -upload_type configuration_with_attachments -depth 1 -sdn MRBTS-1/DIAGSNAP-1
	${data}    Get Events
	${data}    Evaluate    " ".join(${data})
    Log    ${data}
    Should Contain    ${data}    Diagsnap state 2 received

#
#
# ../ = /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_OSSEMS_ET/Classical/CB006543/
