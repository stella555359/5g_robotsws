*** Settings ***
Documentation
...          Just an exemple about how to use the capture tool

Resource                            ../Tools.robot
Resource                            ../Topology.robot
Resource                            ../Connect.robot
Resource                            ../WtsCfgConfig.robot
Resource                            ../Backup.robot
Resource                            ../Setup.robot
Resource                            ../CaptureFilter.robot
Resource                            ../Airframes.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../../../RRM/ET/resources/python/luashark_tools.py
Library                             luashark_tools.analyzer       WITH NAME       analyzer
Variables                           NonRegression.py

Suite Setup                         Suite Setup
*** Variables ***
${TestSharkTool}                    MC_SHARK

*** Test Cases ***
Test
    Dated log                       START
    ${pdml}                         analyzer.pcap_to_pdml
    ...                             pcapFile=/ebs/bhoche/FeatureDemo/SCTP_CLASSICAL_GNB_ADDITION_UE1.pcap
    Dated log                       Start Check field
    analyzer.check_field            pdmlFile=${pdml}
    ...                             packetName=x2ap.SgNBAdditionRequestAcknowledge
    ...                             fieldName=nr-rrc.ssb_PositionsInBurst
    ...                             value=1
    Dated log                       END


Test Capture on BOO L2LO L2HI
    ${cap}                          Capture on BOO L2LO L2HI
    dated log                       CAP=${cap}

TestCapture CPRT
    ${cprt}                         Capture CPRT Set Upon Config
    Capture Start                   ${cprt}
    Sleep                           5
    Capture Stop                    ${cprt}

TestCapture CORE
    ${core}                         Capture CORE Set Upon Config
    Capture Start                   ${core}
    Sleep                           5
    Capture Stop                    ${core}

Test Capture
    FOR   ${i}  IN RANGE            ${nbGNB}
        Dated log                       Test Captures for GNB${i}
        Test Capture Airscale           airscale=${TGNB_DU[${i}]}
    END

TestCapture AIC
    ${cprt}                         Capture CPRT Set Upon Config
    Capture Init                    ${cprt}
    Capture Start                   ${cprt}
    Sleep                           5
    Capture Stop                    ${cprt}

    ${core}                         Capture CORE Set Upon Config
    Capture Init                    ${core}
    Capture Start                   ${core}
    Sleep                           5
    Capture Stop                    ${core}

    ${l1l2}                         Capture L1L2 Set Upon Config
    Capture Init                    ${l1l2}
    Capture Start                   ${l1l2}
    Sleep                           5
    Capture Stop                    ${l1l2}

TestCapture L1L2 AIC
    ${l1l2Mirror}                   Capture L1L2 Set Upon Config        isMirror=${True}
    @{list}                         create list                         DlData_SlotTypeReq
    ${l1l2Mirror.filter}            Get Filter For Particular Msgs      ${list}
    #${l1l2Mirror.filter}            Get Filter For UDP                  ${l1l2Mirror}
    #${l1l2Mirror.filter}            set variable                        udp
    Capture Start                   ${l1l2Mirror}
    Sleep                           5
    Capture Stop                    ${l1l2Mirror}

    #${l1l2}                         Capture L1L2 Set Upon Config
    #Capture Start                   ${l1l2}
    #Sleep                           5
    #Capture Stop                    ${l1l2}

TestCapture ApoABIO
    ${l1l2}                         Capture L1L2 Set Upon Config        airscale=${AP_DU}
    Capture Init                    ${l1l2}
    Capture Start                   ${l1l2}
    Sleep                           5
    Capture Stop                    ${l1l2}



Test LOG
    # Getting a LOG for a particular container
    ${containerName}                Set Variable                       l2hicu
    ${podName}                      Set Variable                       upue-0
    dated log                       Getting log file for : POD=[${podName}] CONTAINER=[${containerName}]
    ${log}                          K8s get Log
    ...                             k8s=${GNB_CU}
    ...                             containerName=${containerName}
    ...                             podName=${podName}
    dated log                       LOG=[${log}]
    # Backup it on VM in LOG path
    K8s Download File               airframeFile=${log}
    ...                             localPath=${LOG_PATH}/${log.name}
    ...                             debug=${True}
    dated log                       ======================================================

Test all LOGS
    Dated log                       GNB_DU LOGS
    call method                     ${GNB_DU}                   getAllLogs
    Dated log                       GNB_CU LOGS
    call method                     ${GNB_CU}                   getAllLogs

TestCapture CPRT AND Decode
    ${cprt}                         Capture CPRT Set Upon Config
    Capture Start                   ${cprt}
    Sleep                           5
    Capture Stop                    ${cprt}
    ${pdml}                         analyzer.pcap_to_pdml                   ${cprt.path}
    analyzer.check_list             pdmlFile=${pdml}
    ...                             packetName=${PS_loadMesInd.packetName}
    ...                             path=${PS_loadMesInd.path}
    ...                             value=${PS_loadMesInd.value}
    #...                             packetName=itf_l2_hi_du_meas_loadmeasurementrepind
    #...                             path=.*itf_l2_hi_du_meas_LoadMeasurementRepInd.LoadMeasurementRepInd.l2NrtPoolId$
    #...                             value=0x00000003
    # itf_l2_hi_du_meas_LoadMeasurementRepInd_t.l2NrtPoolId

    ${l1l2}                         Capture L1L2 Set Upon Config
    Capture Start                   ${l1l2}
    Sleep                           5
    Capture Stop                    ${l1l2}
    ${pdml}                         analyzer.pcap_to_pdml                   ${l1l2.path}

    ${core}                         Capture CORE Set Upon Config
    Capture Start                   ${core}
    Sleep                           5
    Capture Stop                    ${core}
    ${pdml}                         analyzer.pcap_to_pdml                   ${core.path}

*** Keywords ***
Test Capture Airscale
    [Arguments]                     ${airscale}
    ${cprt}                         Capture CPRT Set Upon Config            airscale=${airscale}
    Capture init                    ${cprt}
    Capture Start                   ${cprt}
    Sleep                           5
    Capture Stop                    ${cprt}

    ${l1l2}                         Capture L1L2 Set Upon Config            airscale=${airscale}
    Capture init                    ${l1l2}
    Capture Start                   ${l1l2}
    Sleep                           5
    Capture Stop                    ${l1l2}

    ${l1l2}                         Capture L1L2 Set Upon Config            airscale=${airscale}
    ${l1l2.withTN}                  Set Variable                ${True}
    Capture init                    ${l1l2}
    Capture Start                   ${l1l2}
    Sleep                           5
    Capture Stop                    ${l1l2}

    ${core}                         Capture CORE Set Upon Config            airscale=${airscale}
    Capture init                    ${core}
    Capture Start                   ${core}
    Sleep                           5
    Capture Stop                    ${core}
