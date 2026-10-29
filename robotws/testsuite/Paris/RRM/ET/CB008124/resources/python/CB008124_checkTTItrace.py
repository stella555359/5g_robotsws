import os
import json
import getopt
import sys
from enum import Enum

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


def countULCGstate(jsonPathName, State):
    """
    This function returns the number of an ULCG state in TTI trace.
    jsonPathName: json file of the TTI trace
    State: CG state to count
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    nbULCGstate = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulConfiguredGrantType2Data":
                ULCGstate = event.data["ueCgStateEntry"]
                if ULCGstate == State:
                    nbULCGstate = nbULCGstate+1
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    # print("ULCG state %s found at %s/%s" % (State, SFN, slot))
    return nbULCGstate


def checkULCGconfigured(jsonPathName):
    """
    This function returns the number of ULCG CONFIGURED state in TTI trace.
    jsonPathName: json file of the TTI trace
    """
    ULCGconfigured = countULCGstate(jsonPathName, "CGCONFIGURED")
    print("checkULCGconfigured - ULCG CONFIGURED state found: %s" % (ULCGconfigured))
    return ULCGconfigured


def checkULCGstartActivation(jsonPathName):
    """
    This function returns the number of CGWAITFORACTIVATION state in TTI trace.
    jsonPathName: json file of the TTI trace
    """
    ULCGstartAct = countULCGstate(jsonPathName, "CGWAITFORACTIVATION")
    print("checkULCGstartActivation - ULCG CGWAITFORACTIVATION state found: %s" % (ULCGstartAct))
    return ULCGstartAct


def checkULCGactivated(jsonPathName):
    """
    TThis function returns the number of CGACTIVATED state in TTI trace.
    jsonPathName: json file of the TTI trace
    """
    ULCGact = countULCGstate(jsonPathName, "CGACTIVATED")
    print("checkULCGstartActivation - ULCG CGACTIVATED state found: %s" % (ULCGact))
    return ULCGact


def getCSRNTIfromCGactivation(jsonPathName):
    """
    This function check the ULCG is well activated in TTI trace.
    Return the CSRNTI if OK, 0 else
    jsonPathName: json file of the TTI trace
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulConfiguredGrantType2Data":
                if event.data["ueCgStateEntry"] == "CGACTIVATED":
                    return event.data["csRnti"]
    return 0


def checkULCGactivation(jsonPathName):
    """
    This function check the ULCG activation procedure in TTI trace.
    Return the CSRNTI if OK, 0 else
    jsonPathName: json file of the TTI trace
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    CSRNTI = 0
    stateMachine = "checkWaitActivation"

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulConfiguredGrantType2Data":
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                ULCGstate = event.data["ueCgStateEntry"]
                if stateMachine == "checkWaitActivation":
                    if ULCGstate == "CGWAITFORACTIVATION":
                        CSRNTI = event.data["csRnti"]
                        stateMachine = "checkWaitActivationConfirmation"
                elif stateMachine == "checkWaitActivationConfirmation":
                    if ULCGstate == "CGWAITFORACTIVATIONCONFIRMATION":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        stateMachine = "checkCGActivated"
                    else:
                        ueCgEvent = event.data["ueCgEvent"]
                        if ULCGstate != "CGWAITFORACTIVATION" or ueCgEvent != "COLLISIONRATE":
                            print("TTI trace ERROR: found state %s instead of \
                                CGWAITFORACTIVATIONCONFIRMATION at %s/%s" % (ULCGstate, SFN, slot))
                            return 0
                elif stateMachine == "checkCGActivated":
                    if ULCGstate != "CGACTIVATED":
                        print("TTI trace ERROR: found state %s instead of \
                            CGACTIVATED at %s/%s" % (ULCGstate, SFN, slot))
                        return 0
                    if CSRNTI != event.data["csRnti"]:
                        print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                        return 0
                    return CSRNTI
    print("TTI trace ERROR: check CG activation failed, blocked in state \"%s\"" % stateMachine)
    return 0


def checkULCGschedulPeriod(jsonPathName, duplexMode, CSRNTI, CGperiod, maxNbCheck=-1):
    """
    This function check the ULCG shechuling period.
    Return the number of periods checked if everything is correct, 0 else
    jsonPathName: json file of the TTI trace
    duplexMode: TDD or FDD
    CGperiod: CG period in ms
    maxNbCheck: max number of right CG period to consider check passed
                Default value -1 means whole TTI trace must be checked
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    CGperiod = int(CGperiod)

    if duplexMode == "TDD":
        nbSlotPerFrame = 20
    elif duplexMode == "FDD":
        nbSlotPerFrame = 10
    else:
        print("TTI trace ERROR: Undefined duplexMode %s (should be TDD or FDD)" % duplexMode)
        return 0

    stateMachine = "getFirstULCGscheduling"
    nbSuccessfulCGperiod = 0
    DTX = "none"

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if stateMachine == "getFirstULCGscheduling":
                if event.type == "ulFdSchedData" and event.data["csRnti"] == CSRNTI:
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    TimePrevCGgrant = SFN*nbSlotPerFrame+slot
                    stateMachine = "checkPeriodULCG"
            elif stateMachine == "checkPeriodULCG":
                if event.type == "ulFdSchedData":
                    if event.data["csRnti"] == CSRNTI or event.data["cgOverwritingReason"] != "NO_CG_OVERWRITING":
                        SFN = event.data["eventHeader"]["sfn"]
                        slot = event.data["eventHeader"]["slot"]
                        TimeCGgrant = SFN*nbSlotPerFrame+slot
                        if TimeCGgrant < TimePrevCGgrant:
                            TimeCGgrant = (SFN+1024)*nbSlotPerFrame+slot
                        CGduration = (TimeCGgrant-TimePrevCGgrant)*10/nbSlotPerFrame
                        if CGduration != CGperiod:
                            # reTx (RV!=0 if CRC KO, or DTX) of CG PUSCH are sent in first UL slot available
                            # => then, should not be used to check CG period
                            if event.data["redundancyVersion"] == 0 and DTX != "DTX":
                                print("TTI trace ERROR: wrong CG period %s instead of %s at %s/%s"
                                      % (CGduration, CGperiod, SFN, slot))
                                return 0
                        else:
                            TimePrevCGgrant = SFN*nbSlotPerFrame+slot
                            nbSuccessfulCGperiod = nbSuccessfulCGperiod+1
                            if nbSuccessfulCGperiod == maxNbCheck:
                                return nbSuccessfulCGperiod
                elif event.type == "ulHarqRxData" and event.data["csRnti"] == CSRNTI:
                    DTX = event.data["dtx"]
                elif event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGWAITFORDEACTIVATIONORDER":
                        stateMachine = "WaitCGactivated"
                    elif ULCGstate != "CGACTIVATED":
                        print("TTI trace ERROR: unexpected CG state %s at %s/%s" % (ULCGstate, SFN, slot))
                        return 0
            elif stateMachine == "WaitCGactivated":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGACTIVATED":
                        CSRNTI = event.data["csRnti"]
                        stateMachine = "getFirstULCGscheduling"
                    elif ULCGstate == "CGERROR":
                        print("TTI trace ERROR: unexpected CG state %s at %s/%s" % (ULCGstate, SFN, slot))
                        return 0

    return nbSuccessfulCGperiod


def checkULCGActivationErrorNoMACCE(jsonPathName):
    """
    This function checks the ULCG activation error in case of no MACCE returned by UE
    Return the CSRNTI if OK, 0 else
    jsonPathName: json file of the TTI trace
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    CSRNTI = 0
    stateMachine = "checkWaitActivation"
    rdCgConsecutiveActivationAttemptFailureCounterMax = 2
    ActivationAttemptnb = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if stateMachine == "checkWaitActivation":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGWAITFORACTIVATION":
                        CSRNTI = event.data["csRnti"]
                        ActivationAttemptnb = ActivationAttemptnb+1
                        stateMachine = "checkWaitActivationConfirmation"
            elif stateMachine == "checkWaitActivationConfirmation":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGWAITFORACTIVATIONCONFIRMATION":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        stateMachine = "checkWaitActivationConfirmationDeact"
            elif stateMachine == "checkWaitActivationConfirmationDeact":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGWAITFORACTIVATIONCONFIRMATION":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        ueCgEvent = event.data["ueCgEvent"]
                        if ueCgEvent != "CGDEACTIVATION" or event.data["cgDeactivationCause"] != "ACTIVATIONFAILURE":
                            print("TTI trace ERROR: CG event %s at %s/%s" % (ueCgEvent, SFN, slot))
                            print("    CG event CGDEACTIVATION with cause ACTIVATIONFAILURE expected")
                            return 0
                        stateMachine = "checkWaitDeactivationOrder"
                    else:
                        print("TTI trace ERROR: CG state %s at %s/%s" % (ULCGstate, SFN, slot))
                        print("    CGWAITFORACTIVATIONCONFIRMATION expected")
                        return 0
            elif stateMachine == "checkWaitDeactivationOrder":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGWAITFORDEACTIVATIONORDER":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        stateMachine = "checkWaitDeactivationConfirmation"
                    else:
                        print("TTI trace ERROR: CG state %s at %s/%s" % (ULCGstate, SFN, slot))
                        print("    CGWAITFORDEACTIVATIONORDER state expected")
                        return 0
            elif stateMachine == "checkWaitDeactivationConfirmation":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGWAITFORDEACTIVATIONCONFIRM":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        if ActivationAttemptnb == rdCgConsecutiveActivationAttemptFailureCounterMax:
                            stateMachine = "checkErrorState"
                        else:
                            stateMachine = "checkConfiguredState"
                    elif ULCGstate != "CGWAITFORDEACTIVATIONCONFIRMSCHEDULING":
                        print("TTI trace ERROR: CG state %s at %s/%s" % (ULCGstate, SFN, slot))
                        print("    CGWAITFORDEACTIVATIONCONFIRM state expected")
                        return 0
            elif stateMachine == "checkConfiguredState":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGCONFIGURED":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        stateMachine = "checkWaitActivation"
                    else:
                        print("TTI trace ERROR: CG state %s at %s/%s" % (ULCGstate, SFN, slot))
                        print("    CGCONFIGURED state expected")
                        return 0
            elif stateMachine == "checkErrorState":
                if event.type == "ulConfiguredGrantType2Data":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGstate == "CGERROR":
                        if CSRNTI != event.data["csRnti"]:
                            print("TTI trace ERROR: wrong CSRNTI at %s/%s" % (SFN, slot))
                            return 0
                        return CSRNTI
                    else:
                        ueCgEvent = event.data["ueCgEvent"]
                        if ULCGstate != "CGWAITFORDEACTIVATIONCONFIRM" or ueCgEvent != "CGERROR":
                            print("TTI trace ERROR: CG state %s with CF event \
                                at %s/%s at %s/%s" % (ULCGstate, ueCgEvent, SFN, slot))
                            print("    CGERROR state expected")
                            return 0

    print("TTI trace ERROR: blocked in state %s" % stateMachine)
    print("    Nb of CG activation attempt: %s" % ActivationAttemptnb)
    return 0


def checkACSInotInCGslots(jsonPathName, duplexMode):
    """
    This function checks that ACSI are not scheduled in CG slot or when
    CG is in states CG-WaitForActivation, CG-WaitForDeactivationOrder or CG-WaitForDeactivationConfirmScheduling.
    Return the number of A-CSI checked if OK, 0 else
    jsonPathName: json file of the TTI trace
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    CSRNTI = 0
    CGstate = "None"
    CGslot = -1
    nbACSI = 0
    CGstatesNoACSI = ["CGWAITFORACTIVATION", "CGWAITFORDEACTIVATIONORDER", "CGWAITFORDEACTIVATIONCONFIRMSCHEDULING"]
    checkNextCGslot = False

    if duplexMode == "TDD":
        nbSlotPerFrame = 20
    elif duplexMode == "FDD":
        nbSlotPerFrame = 10
    else:
        print("TTI trace ERROR: Undefined duplexMode %s (should be TDD or FDD)" % duplexMode)
        return 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulConfiguredGrantType2Data":
                CSRNTI = event.data["csRnti"]
                CGstate = event.data["ueCgStateEntry"]
            elif event.type == "ulFdSchedData" and event.data["csRnti"] == CSRNTI:
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                CGslot = SFN*nbSlotPerFrame+slot
                if checkNextCGslot:
                    if ACSIslot == CGslot:
                        print("TTI trace ERROR: A-CSI found in CG slot at %s/%s" % (SFN, slot))
                        return 0
                    else:
                        checkNextCGslot = False
                        nbACSI = nbACSI + 1
            elif event.type == "csiSrReportData" and event.data["reportType"] == "APERIODIC_CSI":
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                ACSIslot = SFN*nbSlotPerFrame+slot
                if ACSIslot == CGslot:
                    print("TTI trace ERROR: A-CSI found in CG slot at %s/%s" % (SFN, slot))
                    return 0
                if CGstate in CGstatesNoACSI:
                    print("TTI trace ERROR: A-CSI found in CG state %s at %s/%s" % (CGstate, SFN, slot))
                    return 0
                checkNextCGslot = True

    return nbACSI


def checkAllocatedRssWithUEpooling(jsonPathName):
    """
    This function check the allocated number of UEs to the according to CG UEactivated or not
    Return 0 in case of an issue
    jsonPathName: json file of the TTI trace
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    stateMachine = "CGnotActivated"
    Cell1Id = 50
    Cell3Id = 52
    MaxNumSchedUE_cell3_4_noCG = 0
    MaxNumSchedUE_cell3_3_CG = 0
    MaxNumSchedUE_cell1_3_CG = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if stateMachine == "CGnotActivated":
                if event.type == "ulAllocatedPooledResourcesData":
                    if event.data["eventHeader"]["physCellId"] == Cell3Id:
                        MaxNumSchedUE = event.data["maxNumPuschUes"]
                        if MaxNumSchedUE == 4:
                            MaxNumSchedUE_cell3_4_noCG = MaxNumSchedUE_cell3_4_noCG+1
                        elif MaxNumSchedUE < 3 or MaxNumSchedUE > 4:
                            SFN = event.data["eventHeader"]["sfn"]
                            slot = event.data["eventHeader"]["slot"]
                            print("TTI trace ERROR: wrong maxNumPuschUes at %s/%s: %s (should be 3 or 4)"
                                  % (MaxNumSchedUE, SFN, slot))
                            return 0
                elif event.type == "ulConfiguredGrantType2Data":
                    ULCGevent = event.data["ueCgEvent"]
                    ULCGstate = event.data["ueCgStateEntry"]
                    if ULCGevent == "CHANGESTATE" and ULCGstate == "CGACTIVATED":
                        stateMachine = "CGActivated"
            elif stateMachine == "CGActivated":
                if event.type == "ulAllocatedPooledResourcesData":
                    if event.data["eventHeader"]["physCellId"] == Cell3Id:
                        MaxNumSchedUE = event.data["maxNumPuschUes"]
                        if MaxNumSchedUE == 3:
                            MaxNumSchedUE_cell3_3_CG = MaxNumSchedUE_cell3_3_CG+1
                        else:
                            SFN = event.data["eventHeader"]["sfn"]
                            slot = event.data["eventHeader"]["slot"]
                            print("TTI trace ERROR: wrong maxNumPuschUes at %s/%s: %s (should be 3)"
                                  % (MaxNumSchedUE, SFN, slot))
                            return 0
                    elif event.data["eventHeader"]["physCellId"] == Cell1Id:
                        MaxNumSchedUE = event.data["maxNumPuschUes"]
                        if MaxNumSchedUE == 3:
                            MaxNumSchedUE_cell1_3_CG = MaxNumSchedUE_cell1_3_CG+1
                        else:
                            SFN = event.data["eventHeader"]["sfn"]
                            slot = event.data["eventHeader"]["slot"]
                            print("TTI trace ERROR: wrong maxNumPuschUes at %s/%s: %s (should be 3)"
                                  % (MaxNumSchedUE, SFN, slot))
                            return 0

    print("maxNumPuschUes equal to 4 in cell 3 without CG UE: %s" % MaxNumSchedUE_cell3_4_noCG)
    print("maxNumPuschUes equal to 3 in cell 1 with CG UE: %s" % MaxNumSchedUE_cell1_3_CG)
    print("maxNumPuschUes equal to 3 in cell 3 with CG UE: %s" % MaxNumSchedUE_cell3_3_CG)
    return MaxNumSchedUE_cell3_4_noCG*MaxNumSchedUE_cell3_3_CG*MaxNumSchedUE_cell1_3_CG
