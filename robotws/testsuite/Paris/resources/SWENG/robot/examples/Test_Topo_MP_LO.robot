*** Settings ***
Documentation    Just an example to test the MP_LO strange behaviour

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Capture.robot
Resource                            ../CaptureFilter.robot
Resource                            ../Container.robot
Library                             ../../python/OsTool.py

Suite Setup                         Suite Setup     keepAllUeDataInCfgFile=${True}

*** Test Cases ***
Test the GNB_DU variable
    [Tags]      DEBUG
    Dated Log New Line              >>> RDH: GNB_DU.profil:>${GNB_DU.profil}<
    Dated Log                       >>> RDH: TGNB_DU[0].profil: >${TGNB_DU[0].profil}<
    Dated Log                       >>> RDH: AP_DU.profil: >${AP_DU.profil}<

    ${cm_execution}                 check_if_cm_execution
    Dated Log                       >>> RDH: cm_execution: >${cm_execution}<

    ${tl_name}=                     get_testline_name
    Dated Log                       >>> RDH: tl_name: >${tl_name}<

    Dated Log                       >>> RDH: Now call the Produce Scout Data
    Produce Scout Data

    ${CaptureCPRT_setup}            Capture CPRT Set upon config
    Dated Log                       >>> RDH: CaptureCPRT_setup: >${CaptureCPRT_setup}<
    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    Dated Log                       >>> RDH: CaptureCPRT_setup.filter: >${CaptureCPRT_setup.filter}<
    Capture Init                    ${CaptureCPRT_setup}             withTN=True             suffix=_setup

    ${CaptureCore_setup}            Capture CORE Set Upon Config
    Dated Log                       >>> RDH: CaptureCore_setup: >${CaptureCore_setup}<
    Capture Init                    ${CaptureCore_setup}             withTN=True             suffix=_setup

    Capture Start                   ${CaptureCore_setup}
    sleep                           5
    Capture Stop                    ${CaptureCore_setup}

    Capture Start                   ${CaptureCPRT_setup}
    sleep                           5
    Capture Stop                    ${CaptureCPRT_setup}
