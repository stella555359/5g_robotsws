from Hytem8x8 import Hytem8x8
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.libraries.Cockpit.Cockpit_Actions import Cockpit_Actions


import os
import time


path = os.getcwd()
files = None
cockpitActions = Cockpit_Actions()

# Import Environment for HandOver with Hytem Matrix 8x8:

CV39_Hytem = Hytem8x8()

#######################################
#   HYTEM FUNCTIONS
#######################################


def Start_HO_IntraDU():
    CV39_Hytem.ho_intra_du()


def HO_Teardown():
    CV39_Hytem.ho_teardown()


#######################################
#   COCKPIT FUNCTIONS
#######################################


def campaign_setup(campaignName, testLineName):
    time.sleep(1)
    cockpitActions.campaignSetup(
        testLine=testLineName, campaignName=campaignName, sendMail=False
    )


def campaign_teardown(campaignName, testLineName, status="TBD", details="TBD"):
    cockpitActions.stopStateVectorManager()
    cockpitActions.checkTest()
    cockpitActions.campaignTeardown(
        testLine=testLineName,
        campaignName=campaignName,
        status=status,
        details=details,
        sendMail=False,
    )


def prepare_test(campaignName):
    testName = "Preparation"
    cockpitActions.prepareTest(campaignName, testName)
    cockpitActions.startStateVectorManager()


def stop_test(gnodeb=None, smod="ASIK"):
    # cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0a", "br1")
    if smod.find("ASIB") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0a", "any")
    if smod.find("ASIKL") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0b", "any")
    if smod.find("ASIKR") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-4b", "any")


def start_traces_trunk(gnodeb, x2ap, f1ap, smod):
    if x2ap == "True" and f1ap == "True" and smod.find("ASIB") >= 0:
        cockpitActions.startTsharkStateVariableBuilder(
            gnodeb, "fct-0a", "any", "icom_5g || f1ap || x2ap || ngap || xnap || nr-rrc"
        )
    if x2ap == "True" and smod.find("ASIK") >= 0:
        cockpitActions.startTsharkStateVariableBuilder(
            gnodeb, "fct-0a", "fp0", "icom_5g || f1ap || x2ap || ngap || xnap"
        )
    if f1ap == "True" and smod.find("ASIKL") >= 0:
        cockpitActions.startTsharkStateVariableBuilder(
            gnodeb, "fct-0b", "any", "icom_5g || f1ap || nr-rrc"
        )
    if f1ap == "True" and smod.find("ASIKR") >= 0:
        cockpitActions.startTsharkStateVariableBuilder(
            gnodeb, "fct-4b", "any", "icom_5g || f1ap || nr-rrc"
        )


def start_traces_5G20A(gnodeb, x2ap, f1ap, smod):
    if x2ap == "True":
        cockpitActions.startTsharkStateVariableBuilder(
            gnodeb, "fct-0b", "etha01", "icom_5g || f1ap || x2ap || ngap || xnap"
        )


def start_traces(gnodeb, x2ap, f1ap, sw_load, smod):
    if sw_load == "5G20A":
        start_traces_5G20A(gnodeb, x2ap, f1ap, smod)
    else:
        start_traces_trunk(gnodeb, x2ap, f1ap, smod)


def stop_traces_trunk(gnodeb, x2ap, f1ap, smod):
    if x2ap == "True" and f1ap == "True" and smod.find("ASIB") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0a", "any")
    if x2ap == "True" and smod.find("ASIK") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0a", "fp0")
    if f1ap == "True" and smod.find("ASIKL") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0b", "any")
    if f1ap == "True" and smod.find("ASIKR") >= 0:
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-4b", "any")


def stop_traces_5G20A(gnodeb, x2ap, f1ap, smod):
    if x2ap == "True":
        cockpitActions.stopTsharkStateVariableBuilder(gnodeb, "fct-0b", "etha01")


def stop_traces(gnodeb, x2ap, f1ap, sw_load, smod):
    if sw_load == "5G20A":
        stop_traces_5G20A(gnodeb, x2ap, f1ap, smod)
    else:
        stop_traces_trunk(gnodeb, x2ap, f1ap, smod)


# ##################################################
# ## STATE MACHINE (or USe Case Detector) FUNCTIONS
# ##################################################


# ============================================================
# Launch The Use Case Detector with StateMachine scripts list
# ============================================================


def LaunchSpecificUCD(smList):
    cockpitActions.launchUseCaseDetectors(smList)


# ===================================================================
# Check of feature 772 NSA Call and Release With DRX Activated
# ===================================================================
def checkFeature_772_NSA_Call(load, num, smod):
    X2Counter1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    X2Counter2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g", "X2Counter"
    )
    X2Counter3 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5gsbts", "X2Counter"
    )
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
    print("F1Counter= ", str(F1Counter))
    print("X2Counter1= ", str(X2Counter1))
    print("X2Counter2= ", str(X2Counter2))
    print("X2Counter3= ", str(X2Counter3))
    if smod.find("ASIB") >= 0 and (X2Counter1 != 9 or X2Counter2 != 9):
        try:
            n = X2Counter1 // 9
            X2Counter1 = X2Counter1 // n
            n = X2Counter2 // 9
            X2Counter2 = X2Counter2 // n
        except ZeroDivisionError:
            print("X2Counter1= ", str(X2Counter1))
            print("X2Counter2= ", str(X2Counter2))
    if smod.find("ASIB") >= 0 and F1Counter != 4:
        try:
            m = F1Counter // 4
            F1Counter = F1Counter // m
        except ZeroDivisionError:
            print("F1Counter= ", str(F1Counter))
    if smod.find("ASIK") >= 0:
        X2Counter1 = X2Counter1 // 2
        X2Counter2 = X2Counter2 // 2
    if load != "5G20A" and (X2Counter1 == 9 or X2Counter2 == 9 or X2Counter3 == 9) and num == "2":
        return " OK : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP TRACES"
    if load != "5G20A" and F1Counter == 4 and num == "3":
        return " OK : NSA CALL FLOWS SEEM TO BE GOOD IN F1AP TRACES"
    elif load == "5G20A" and X2Counter1 == 9:
        return " OK : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP TRACES"
    else:
        return " KO : NSA Call Error Detected In Data Flows"


# ==========================================================================
# Check of feature 772 NSA Call and Release With DRX Activated and Multi UEs
# ==========================================================================
def checkFeature_772_NSA_Call_MultiUEs(load, smod):
    X2Counter1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    X2Counter2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g", "X2Counter"
    )
    X2Counter3 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5gsbts", "X2Counter"
    )
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
    if smod.find("ASIK") >= 0 and X2Counter1 != 18:
        try:
            X2Counter1 = X2Counter1 // 2
        except ZeroDivisionError:
            print("X2Counter1= ", str(X2Counter1))
    if smod.find("ASIK") >= 0 and X2Counter2 != 18:
        try:
            X2Counter2 = X2Counter2 // 2
        except ZeroDivisionError:
            print("X2Counter2= ", str(X2Counter2))
    print("F1Counter= ", str(F1Counter))
    print("X2Counter1= ", str(X2Counter1))
    print("X2Counter2= ", str(X2Counter2))
    print("X2Counter3= ", str(X2Counter3))
    if load != "5G20A" and (X2Counter1 == 18 or X2Counter2 == 18 or X2Counter3 == 18) and F1Counter == 8:
        return " OK : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP and F1AP TRACES"
    else:
        return " KO : NSA Call Error Detected In Data Flows"


# ===================================================================
# Counters Check for feature 772 NSA counters_UeSupportsDRX
# ===================================================================
def checkFeature_772_NSA_Counters(checkDrxRatio, num):
    if checkDrxRatio == "True" and num == "5":
        return " OK All DRX Counters Have Good Values during call"
    if checkDrxRatio == "True" and num == "12":
        return " OK All DRX Counters Have Good Values after call release"
    else:
        return "Bad Ratio or Values for Active vs Sleep DRX Counters"


# =====================================================================
# Check of feature 772 NSA MSC_UeSupportsDRX_FeatureNotActive
# =====================================================================
def checkFeature_772_NSA_DRX_OFF(load, smod):
    X2Counter1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_UeSupportsDRX_FeatureNotActive", "X2Counter"
    )
    X2Counter2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_UeSupportsDRX_FeatureNotActiveReleaseFrom5g", "X2Counter"
    )
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_UeSupportsDRX_FeatureNotActive", "F1Counter"
        )
    print("F1Counter= ", str(F1Counter))
    print("X2Counter1= ", str(X2Counter1))
    print("X2Counter2= ", str(X2Counter2))
    if smod.find("ASIK") >= 0:
        X2Counter1 = X2Counter1 // 2
        X2Counter2 = X2Counter2 // 2
    if load != "5G20A" and (X2Counter1 == 7 or X2Counter2 == 7) and F1Counter == 3:
        return " OK : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP and F1AP TRACES"
    else:
        return " KO : NSA Call Error Detected In Data Flows"


# ============================================================
# Check of feature 772 NSA onlineFeatureModification
# ============================================================
def checkFeature_772_NSA_OnlineDrxModification(
    firstCallCounterCheck, secondCallCounterCheck, load, smod
):
    if firstCallCounterCheck != "True":
        return "NSA_X2_OnlineDrxModification: Error Detected In DRX Counters during First Call"
    elif secondCallCounterCheck != "True":
        return "NSA_X2_OnlineDrxModification: Error Detected In DRX Counters during Second Call"

    X2CallCounter1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    X2CallCounter2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g", "X2Counter"
    )
    X2odmCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_OnlineDrxModification", "X2Counter"
    )
    X2_DrxLongCycleStartOffset_1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_OnlineDrxModification", "UE1_DrxLongCycleStartOffset"
    )
    X2_DrxLongCycleStartOffset_2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_OnlineDrxModification", "UE2_DrxLongCycleStartOffset"
    )
    if load != "5G20A":
        F1CallCounter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
        F1odmCounter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_OnlineDrxModification", "F1Counter"
        )
        F1_DrxLongCycleStartOffset_1 = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_OnlineDrxModification",
            "UE1_DrxLongCycleStartOffset",
        )
        F1_DrxLongCycleStartOffset_2 = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_OnlineDrxModification",
            "UE2_DrxLongCycleStartOffset",
        )
    print("X2_DrxLongCycleStartOffset_1= ", str(X2_DrxLongCycleStartOffset_1))
    print("X2CallCounter1= ", str(X2CallCounter1))
    print("X2CallCounter2= ", str(X2CallCounter2))
    if smod.find("ASIK") >= 0:
        X2CallCounter1 = X2CallCounter1 // 2
        X2CallCounter2 = X2CallCounter2 // 2
    print("X2_DrxLongCycleStartOffset_2= ", str(X2_DrxLongCycleStartOffset_2))
    print("X2odmCounter= ", str(X2odmCounter))
    print("F1CallCounter= ", str(F1CallCounter))
    print("F1odmCounter= ", str(F1odmCounter))
    print("F1_DrxLongCycleStartOffset_1= ", str(F1_DrxLongCycleStartOffset_1))
    print("F1_DrxLongCycleStartOffset_2= ", str(F1_DrxLongCycleStartOffset_2))
    if (
        load != "5G20A"
        and (X2CallCounter1 == 18 or X2CallCounter2 == 18)
        and X2odmCounter == 4
        and X2_DrxLongCycleStartOffset_1 != X2_DrxLongCycleStartOffset_2
        and F1CallCounter == 8
        and F1odmCounter == 4
        and F1_DrxLongCycleStartOffset_1 != F1_DrxLongCycleStartOffset_2
    ):
        return " OK : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP and F1AP TRACES"
    else:
        return " KO : NSA Call Error Detected In Data Flows"


# ========================================================================================
# Check of feature 772 NSA Call with HO_intraDU_success_DRXactiveInTargetCell_callFlow-RRC
# ========================================================================================
def checkFeature_772_NSA_HO_IntraDU_Call(load, smod):
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    X2Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    if smod.find("ASIK") >= 0:
        X2Counter = X2Counter // 2
    print("X2Counter= ", str(X2Counter))
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
        print("F1Counter= ", str(F1Counter))
    if load != "5G20A" and X2Counter == 9 and F1Counter == 4:
        return (
            " OK for HO_intraDU : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP and F1AP TRACES BUT THE HO IS NOT"
            " YET CHECKED..."
        )
    elif load == "5G20A" and X2Counter == 9:
        return " OK for HO_intraDU : NSA CALL FLOWS SEEM TO BE GOOD IN X2AP TRACES BUT THE HO IS NOT YET CHECKED..."
    else:
        return " KO : NSA Call Error Detected In Data Flows"


# ====================================================================================
# Check of feature 772 NSA Call HO_intraDU_success_DRXactiveInTargetCell_counters
# ====================================================================================
def checkFeature_772_NSA_HO_IntraDU_Counters(checkDrxRatio, checkHoDrxOn):
    if checkDrxRatio == "True" and checkHoDrxOn == "True":
        return " OK for HO_intraDU : All Counters Have Good Values"
    elif checkDrxRatio == "False":
        return (
            "HO_intraDU: Error Detected In DRX Ratio for Active vs Sleep DRX Counters"
        )
    elif checkHoDrxOn == "False":
        return "HO_intraDU: Error Detected In DRX HO Counters"


# =======================================================================
# Check of feature 772_A_20 FR1Scheduling_MultiUeSupportsDRX_startOffset
# =======================================================================
def checkFeature_772_A_20():
    NbOfSuccessfulState_772_A_02 = cockpitActions.getUseCaseDetectorCounter(
        "feature772_A_02_MSC_X2_UeSupportsDRX", "Counter"
    )
    NbOfSuccessfulState_772_A_20 = cockpitActions.getUseCaseDetectorCounter(
        "feature772_A_20_FR1scheduling_MultiUeSupportDRX_startOffset", "Counter"
    )
    UE1_DrxlongCycleStartOffset = cockpitActions.getUseCaseDetectorCounter(
        "feature772_A_20_FR1scheduling_MultiUeSupportDRX_startOffset",
        "UE1_DrxlongCycleStartOffset",
    )
    UE2_DrxlongCycleStartOffset = cockpitActions.getUseCaseDetectorCounter(
        "feature772_A_20_FR1scheduling_MultiUeSupportDRX_startOffset",
        "UE2_DrxlongCycleStartOffset",
    )

    if NbOfSuccessfulState_772_A_02 != 10:
        return (
            "SM_772_A_02: Error: Nb Of Successful State is "
            + str(NbOfSuccessfulState_772_A_02)
            + " instead of 10"
        )
    elif NbOfSuccessfulState_772_A_20 != 2:
        return (
            "SM_772_A_20: Error: Nb Of Successful State is "
            + str(NbOfSuccessfulState_772_A_20)
            + " instead of 2"
        )
    elif UE1_DrxlongCycleStartOffset == UE2_DrxlongCycleStartOffset:
        return "SM_772_A_20: Error: Same Value for UE1_DrxlongCycleStartOffset and UE2_DrxlongCycleStartOffset"
    else:
        print("UE1 DrxlongCycleStartOffset= ", str(UE1_DrxlongCycleStartOffset))
        print("UE2 DrxlongCycleStartOffset= ", str(UE2_DrxlongCycleStartOffset))
        return "OK"


# ===================================================================
# Check of feature 1877_772_C_SA Call and Release With DRX Activated
# ===================================================================
def checkFeature_1877_772_C_SA():
    NGCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_CallEstablishmentAndRelease", "NGCounter"
    )
    F1Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_F1_CallEstablishmentAndRelease", "F1Counter"
    )
    print("F1Counter= ", str(F1Counter))
    print("NGCounter= ", str(NGCounter))
    if NGCounter == 9 and (F1Counter == 10 or F1Counter == 6):
        return " OK for SM_1877_772_C_SA : SA CALL FLOWS SEEM TO BE GOOD"
    else:
        return (
            "SM_1877_772_C_SA Error: Successful State Number for NGAP is "
            + str(NGCounter)
            + " (should be 9) and for F1AP is "
            + str(F1Counter)
            + " (should be 10)"
        )


# ===================================================================
# Check of feature 1877_772_C_NSA Call and Release With DRX Activated
# ===================================================================
def checkFeature_1877_772_C_NSA():
    X2Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    F1Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
    )
    print("F1Counter= ", str(F1Counter))
    print("X2Counter= ", str(X2Counter))
    if X2Counter == 9 and F1Counter == 4:
        return " OK for SM_1877_772_C_NSA : NSA CALL FLOWS SEEM TO BE GOOD"
    elif X2Counter != 9:
        return (
            "NSA Call : Error Detected In X2AP Data Flows : "
            + str(X2Counter)
            + " X2 steps detected instead of 9"
        )
    elif F1Counter != 4:
        return (
            "NSA Call : Error Detected In F1AP Data Flows : "
            + str(F1Counter)
            + " F1 steps detected instead of 4"
        )


# ===================================================================
# Counters Check for feature 1877_772_C_05 SA/NSA counters_UeSupportsDRX
# ===================================================================
def checkFeature_1877_772_C_05(checkDrxRatio):
    if checkDrxRatio == "True":
        return " OK All DRX Ratio Have Good Values"
    else:
        return "SM_1877_772_C_05 Error: Bad Ratio for Active vs Sleep DRX Counters"


# =============================================================
# Check of feature 1877_772_C_09 SA Call Release UeSupportsDRX
# =============================================================
def checkFeature_1877_772_C_09_SA(load):
    NGCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_CallEstablishmentAndRelease", "NGCounter"
    )
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_SA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
    print("F1Counter= ", str(F1Counter))
    print("NGCounter= ", str(NGCounter))
    try:
        n = NGCounter // 9
        NGCounter = NGCounter // n
        F1Counter = F1Counter // n
    except ZeroDivisionError:
        print("NGCounter= ", str(NGCounter))
        print("F1Counter= ", str(F1Counter))
    if load != "5G20A" and NGCounter == 9 and (F1Counter == 1 or F1Counter == 6):
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN X2AP AND F1AP TRACES"
    if load == "5G20A" and NGCounter == 9:
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN X2AP TRACES"
    else:
        return " KO : SA Call Error Detected In Data Flows"


# =============================================================
# Check of feature 1877_772_C_09 NSA Call Release UeSupportsDRX
# =============================================================
def checkFeature_1877_772_C_09_NSA():
    F1Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
    )
    X2Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    print("F1Counter= ", str(F1Counter))
    print("X2Counter= ", str(X2Counter))
    if X2Counter == 9 and F1Counter == 4:
        return " OK for SM_1877_772_C_09_NSA : CALL FLOWS SEEM TO BE GOOD"
    else:
        return (
            "SM_1877_772_C_09_NSA Error Detected In F1AP Data Flows : "
            + str(X2Counter)
            + " X2 steps detected instead of 9 and "
            + str(F1Counter)
            + " F1 steps detected instead of 4 "
        )


# =====================================================================
# Check of feature 1877_772_C_10 SA MSC_UeSupportsDRX_FeatureNotActive
# =====================================================================
def checkFeature_1877_772_C_10_SA(load):
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    NGCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_UeSupportsDRX_FeatureNotActive", "NGCounter"
    )
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_SA_F1_UeSupportsDRX_FeatureNotActive", "F1Counter"
        )
    print("F1Counter= ", str(F1Counter))
    print("NGCounter= ", str(NGCounter))
    if NGCounter != 7:
        try:
            n = NGCounter // 7
            NGCounter = NGCounter // n
        except ZeroDivisionError:
            print("NGCounter= ", str(NGCounter))
    if F1Counter != 7:
        try:
            m = F1Counter // 7
            F1Counter = F1Counter // m
        except ZeroDivisionError:
            print("F1Counter= ", str(F1Counter))
    if load != "5G20A" and (F1Counter == 7 or F1Counter == 4) and NGCounter == 7:
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN NGAP AND F1AP TRACES"
    if load == "5G20A" and NGCounter == 7:
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN NGAP TRACES"
    else:
        return " KO : SA Call Error Detected In Data Flows"


# =====================================================================
# Check of feature 1877_772_C_10 NSA MSC_UeSupportsDRX_FeatureNotActive
# =====================================================================
def checkFeature_1877_772_C_10_NSA():
    F1Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_UeSupportsDRX_FeatureNotActive", "F1Counter"
    )
    X2Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_UeSupportsDRX_FeatureNotActive", "X2Counter"
    )
    print("F1Counter= ", str(F1Counter))
    print("X2Counter= ", str(X2Counter))
    if X2Counter == 7 and F1Counter == 3:
        return " OK for SM_1877_772_C_10_NSA "
    elif X2Counter != 7:
        return (
            "NSA Call With Feature Not Active : Error Detected In X2AP Data Flows : "
            + str(X2Counter)
            + " X2 steps detected instead of 7"
        )
    elif F1Counter != 3:
        return (
            "NSA Call With Feature Not Active : Error Detected In F1AP Data Flows : "
            + str(F1Counter)
            + " F1 steps detected instead of 3"
        )


# ==============================================================================================
# Check of feature 1877_772_C_12 SA onlineFeatureModification
# ==============================================================================================
def checkFeature_1877_772_C_12_SA(firstCallCounterCheck, secondCallCounterCheck, load):
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED

    if firstCallCounterCheck != "True":
        return "SM_1877_772_C_12_SA: Error Detected In DRX Counters during First Call"
    elif secondCallCounterCheck != "True":
        return "SM_1877_772_C_12_SA: Error Detected In DRX Counters during Second Call"

    NGCallCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_CallEstablishmentAndRelease", "NGCounter"
    )

    if load != "5G20A":
        F1CallCounter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_SA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
    if NGCallCounter != 18:
        try:
            n = NGCallCounter // 18
            NGCallCounter = NGCallCounter // n
        except ZeroDivisionError:
            print("NGCallCounter= ", str(NGCallCounter))
    if F1CallCounter != 2:
        try:
            m = F1CallCounter // 2
            F1CallCounter = F1CallCounter // m
        except ZeroDivisionError:
            print("F1CallCounter= ", str(F1CallCounter))
    print("F1CallCounter= ", str(F1CallCounter))
    print("NGCallCounter= ", str(NGCallCounter))
    if (
        load != "5G20A"
        and NGCallCounter == 18
        and (F1CallCounter == 2 or F1CallCounter == 12)
    ):
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN NGAP AND F1AP TRACES"
    elif load == "5G20A" and NGCallCounter == 18:
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN NGAP TRACES"
    else:
        return " KO : SA Call Error Detected In Data Flows"


# ============================================================
# Check of feature 1877_772_C_12 NSA onlineFeatureModification
# ============================================================
def checkFeature_1877_772_C_12_NSA(firstCallCounterCheck, secondCallCounterCheck):
    X2CallCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    F1CallCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
    )
    X2odmCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_OnlineDrxModification", "X2Counter"
    )
    F1odmCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_OnlineDrxModification", "F1Counter"
    )
    X2_DrxLongCycleStartOffset_1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_OnlineDrxModification", "UE1_DrxLongCycleStartOffset"
    )
    X2_DrxLongCycleStartOffset_2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_OnlineDrxModification", "UE2_DrxLongCycleStartOffset"
    )
    F1_DrxLongCycleStartOffset_1 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_OnlineDrxModification", "UE1_DrxLongCycleStartOffset"
    )
    F1_DrxLongCycleStartOffset_2 = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_OnlineDrxModification", "UE2_DrxLongCycleStartOffset"
    )

    if firstCallCounterCheck != "True":
        return "SM_1877_772_C_12_NSA: Error Detected In DRX Counters during First Call"
    elif secondCallCounterCheck != "True":
        return "SM_1877_772_C_12_NSA: Error Detected In DRX Counters during Second Call"
    elif X2CallCounter != 18:
        return (
            "SM_1877_772_C_12_NSA: Error Detected In X2AP Data Flows : "
            + str(X2CallCounter)
            + " X2 steps detected instead of 2x9"
        )
    elif F1CallCounter != 8:
        return (
            "SM_1877_772_C_12_NSA: Error Detected In F1AP Data Flows : "
            + str(F1CallCounter)
            + " F1 steps detected instead of 2x4"
        )
    elif X2odmCounter != 4:
        return (
            "SM_1877_772_C_12_NSA: Error Detected In X2AP Data Flows : "
            + str(X2odmCounter)
            + " Online Drx Modification X2 steps detected instead of 4"
        )
    elif F1odmCounter != 4:
        return (
            "SM_1877_772_C_12_NSA: Error Detected In F1AP Data Flows : "
            + str(F1odmCounter)
            + " Online Drx Modification F1 steps detected instead of 4"
        )
    elif X2_DrxLongCycleStartOffset_1 == X2_DrxLongCycleStartOffset_2:
        return (
            "SM_1877_772_C_12_NSA: Error Detected In X2AP DrxLongCycleStartOffset parameter: "
            + "Same Offset ( "
            + str(X2_DrxLongCycleStartOffset_1)
            + " ) Was Used "
        )
    elif F1_DrxLongCycleStartOffset_1 == F1_DrxLongCycleStartOffset_2:
        return (
            "SM_1877_772_C_12_NSA: Error Detected In F1AP DrxLongCycleStartOffset parameter: "
            + "Same Offset ( "
            + str(F1_DrxLongCycleStartOffset_1)
            + " ) Was Used "
        )
    else:
        print("X2 DrxLongCycleStartOffset 1= ", str(X2_DrxLongCycleStartOffset_1))
        print("X2 DrxLongCycleStartOffset 2= ", str(X2_DrxLongCycleStartOffset_2))
        print("F1 DrxLongCycleStartOffset 1= ", str(F1_DrxLongCycleStartOffset_1))
        print("F1 DrxLongCycleStartOffset 2= ", str(F1_DrxLongCycleStartOffset_2))
        return " OK for SM_1877_772_C_12_NSA : CALL FLOWS and COUNTERS SEEM TO BE GOOD"


# =======================================================================
# Check of feature 1877_772_C_15 SA MultiUe_DrxStartOffset
# =======================================================================
def checkFeature_1877_772_C_15_SA(load):
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    NGCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_CallEstablishmentAndRelease", "NGCounter"
    )

    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_SA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
    print("F1Counter= ", str(F1Counter))
    print("NGCounter= ", str(NGCounter))
    if NGCounter != 18:
        try:
            n = NGCounter // 18
            NGCounter = NGCounter // n
        except ZeroDivisionError:
            print("NGCounter= ", str(NGCounter))
    if F1Counter != 2:
        try:
            m = F1Counter // 2
            F1Counter = F1Counter // m
        except ZeroDivisionError:
            print("F1Counter= ", str(F1Counter))
    if load != "5G20A" and NGCounter == 18 and (F1Counter == 2 or F1Counter == 12):
        # and F1MultiUeCounter == 2 \
        # and UE1_DrxLongCycleStartOffset != UE2_DrxLongCycleStartOffset \
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN NGAP AND F1AP TRACES"
    elif load == "5G20A" and NGCounter == 18:
        return " OK : SA CALL FLOWS SEEM TO BE GOOD IN NGAP TRACES"
    else:
        return " KO : SA Call Error Detected In Data Flows"


# ==============================================================================================
# Check of feature 1877_772_F_23 and 1877_772_F_24 SA HO_interGNB_success Call Flow and Counters
# ==============================================================================================
def checkFeature_1877_772_F23_F24(checkDrxValues, checkDrxRatio, checkHoDrxOn):
    return " KO for SM_1877_772_F23_F24 AS NO CHECK ARE YET FULLY ENCODED..."


# ========================================================================================
# Check of feature 1877_772_F_23 SA HO_interGNB_success_DRXactiveInTargetCell_callFlow-RRC
# ========================================================================================
def checkFeature_1877_772_F_23():
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    NGCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_CallEstablishmentAndRelease", "NGCounter"
    )
    F1Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_F1_CallEstablishmentAndRelease", "F1Counter"
    )
    XNCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_XN_HandOverInterGNB_BasicCheck", "XNCounter"
    )
    XnSetupFailureCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_XN_HandOverInterGNB_BasicCheck", "XnSetupFailureCounter"
    )

    if NGCounter == 9 and F1Counter == 10 and XNCounter == 6:
        return " OK for SM_1877_772_F_23_SA : SA CALL FLOWS SEEM TO BE GOOD"
    else:
        return (
            "SM_1877_772_F_23_SA Error Detected in NGAP or F1AP or XNAP Data Flows: "
            + str(NGCounter)
            + " NG steps detected instead of 9 and "
            + str(F1Counter)
            + " F1 steps detected instead of 10 and "
            + str(XNCounter)
            + " XN steps detected instead of 6."
            + "For info they are "
            + XnSetupFailureCounter
            + " XnSetupRequest XnSetupFailure before the XnSetupResponse !"
        )


# ====================================================================================
# Check of feature 1877_772_F_24 SA HO_interGNB_success_DRXactiveInTargetCell_counters
# ====================================================================================
def checkFeature_1877_772_F_24(checkDrxValues, checkDrxRatio, checkHoDrxOn):
    return " KO for SM_1877_772_F24 AS NO CHECK ARE YET FULLY ENCODED..."


# ====================================================================================
# Check of feature 1877_772_F_24 SA HO_interGNB_success_DRXactiveInTargetCell_SRB3
# ====================================================================================
def checkFeature_1877_772_F_24_SRB3(checkDrxValues, checkDrxRatio, checkHoDrxOn):
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    # if checkDrxRatio == 'True' and checkDrxRatio == 'True' and checkHoDrxOn == 'True':
    #     return 'OK'
    # else:
    #     return 'SM_1877_772_F_24 Error on Counters: checkDrxValues=' + str(checkDrxValues) +\
    #                                            ' checkDrxRatio=' + str(checkDrxRatio) + \
    #                                            ' checkHoDrxOn=' + str(checkHoDrxOn)
    return " KO for SM_1877_772_F24_SRB3 AS NO CHECK ARE YET FULLY ENCODED..."


# ========================================================================================
# Check of feature 1877_772_F_28 SA HO_intraDU_success_DRXactiveInTargetCell_callFlow-RRC
# ========================================================================================
def checkFeature_1877_772_F_28_SA(load):
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    NGCounter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_SA_NG_CallEstablishmentAndRelease", "NGCounter"
    )
    print("NGCounter= ", str(NGCounter))
    if load != "5G20A":
        F1Counter = cockpitActions.getUseCaseDetectorCounter(
            "feature1877_772_C_SA_F1_CallEstablishmentAndRelease", "F1Counter"
        )
        print("F1Counter= ", str(F1Counter))
    if load != "5G20A" and NGCounter == 9 and (F1Counter == 10 or F1Counter == 6):
        return " OK : CALL FLOWS SEEM TO BE GOOD IN NGAP AND F1AP TRACES BUT THE HO IS NOT YET CHECKED..."
    elif load == "5G20A" and NGCounter == 9:
        return " OK : CALL FLOWS SEEM TO BE GOOD IN NGAP TRACES BUT THE HO IS NOT YET CHECKED..."
    else:
        return " KO : SA Call Error Detected In Data Flows"


# ========================================================================================
# Check of feature 1877_772_F_28 NSA HO_intraDU_success_DRXactiveInTargetCell_callFlow-RRC
# ========================================================================================
def checkFeature_1877_772_F_28_NSA():
    # CODE TO BE COMPLETED/MODIFIED/ADAPTED
    X2Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_X2_CallEstablishmentAndRelease", "X2Counter"
    )
    F1Counter = cockpitActions.getUseCaseDetectorCounter(
        "feature1877_772_C_NSA_F1_CallEstablishmentAndRelease", "F1Counter"
    )

    if X2Counter == 18 and F1Counter == 8:
        return " OK for SM_1877_772_F_28_NSA : CALL FLOWS SEEM TO BE GOOD"
    elif X2Counter != 18:
        return (
            "SM_1877_772_F_28_NSA: Error Detected In X2AP Data Flows : "
            + str(X2Counter)
            + " X2 steps detected instead of 2x9"
        )
    elif F1Counter != 8:
        return (
            "SM_1877_772_F_28_NSA: Error Detected In F1AP Data Flows : "
            + str(F1Counter)
            + " F1 steps detected instead of 2x4"
        )


# ====================================================================================
# Check of feature 1877_772_F_29 HO_intraDU_success_DRXactiveInTargetCell_counters
# ====================================================================================
def checkFeature_1877_772_F_29(checkDrxRatio, checkHoDrxOn):
    if checkDrxRatio == "True" and checkHoDrxOn == "True":
        return " OK for HO_intraDU : All Counters Have Good Values"
    elif checkDrxRatio == "False":
        return "SM_1877_772_F_29 Error Detected In DRX Ratio for Active vs Sleep DRX Counters"
    elif checkHoDrxOn == "False":
        return "SM_1877_772_F_29 Error Detected In DRX HO Counters"


def get_file_for_Load(package):
    release, names = package.split("_", 1)
    if package.find("_999") >= 0:
        files = get_file_for_SBTS22R1_Load(package)
    elif package.find("_0000_") >= 0:
        files = get_file_for_SBTS21B_Load(package)
    elif package.find("5G21A") >= 0:
        files = get_file_for_5G21A_Load(package)
    else:
        files = get_file_for_5G20B_Load(package)
    return files


def get_file_for_SBTS22R1_Load(package):
    os.chdir(path)
    release1, gnb, brand, packet, names = package.split("_", 4)
    release1 = release1.lstrip("SBTS")
    package = package.replace(release1, "00")
    release, num = package.split("_", 1)
    for i in range(0, 3):
        packet1 = packet.lstrip("0")
        packet = int(packet1) - i
        packet1 = "%06d" % packet
        packet = str(packet1)
        names = names.lstrip("0")
        for m in range(0, 15):
            if i == 0:
                name = int(names) - m
            else:
                name = 15 - m
            if name == 0:
                break
            name1 = "%06d" % name
            name1 = str(name1)
            files = (
                release
                + "_"
                + gnb
                + "_"
                + brand
                + "_"
                + packet
                + "_"
                + name1
                + "_luashark.zip"
            )
        os.system(
            "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
            % (release, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def get_file_for_SBTS21B_Load(package):
    os.chdir(path)
    release1, gnb, brand, packet, names = package.split("_", 4)
    release, num = package.split("_", 1)
    for i in range(0, 50):
        packet1 = packet.lstrip("0")
        packet = int(packet1) - i
        packet1 = "%06d" % packet
        packet = str(packet1)
        files = (
            release1
            + "_"
            + gnb
            + "_"
            + brand
            + "_"
            + packet
            + "_"
            + names
            + "_luashark.zip"
        )
        os.system(
            "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
            % (release, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def get_file_for_5G21A_Load(package):
    release, gnb, brand, packet, names = package.split("_", 4)
    os.chdir(path)
    for i in range(0, 50):
        names = names.lstrip("0")
        name = int(names) - i
        name1 = "%06d" % name
        name = str(name)
        name1 = str(name1)
        file = brand.lstrip("0") + "." + packet.lstrip("0") + "." + name
        files = "luashark-" + file + ".zip"
        os.system(
            "sudo wget https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/"
            "System_Release/%s/%s" % (file, files)
        )
        print("files= ", str(files))
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def get_file_for_5G20B_Load(package):
    release, gnb, brand, packet, names = package.split("_", 4)
    os.chdir(path)
    for i in range(0, 50):
        names = names.lstrip("0")
        name = int(names) - i
        name = str(name)
        file = brand.lstrip("0") + "." + packet.lstrip("0") + "." + name
        files = "luashark-" + file + ".zip"
        os.system(
            "sudo wget https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/"
            "System_Release/%s/%s" % (file, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def unzip_file(files):
    os.system("rm -rf /home/ute/luashark/*")
    os.chdir(path)
    os.system("mv %s /home/ute/luashark/" % files)
    os.chdir("/home/ute/luashark/")
    os.system("unzip *")
    os.chdir("/home/ute/")
    os.system("rm -rf %s" % files)


def Copy_SM_for_different_release(swversion, file_name, tac=210):
    currentpath1 = os.path.dirname(os.path.realpath(__file__))
    currentpath = currentpath1.rstrip("/5GC000772/resources")
    print("currentpath=%s", currentpath)
    path1 = "libraries/Cockpit/UseCaseDetector"
    file_path = os.path.join(currentpath, path1)
    print("file_path=%s", file_path)
    os.chdir(file_path)
    if swversion.find("5G") >= 0:
        os.system("cp %s_5g.sm %s.sm" % (file_name, file_name))
        print("file_name=%s_5g", file_name)
    if swversion.find("SBTS") >= 0:
        os.system("cp %s_sbts.sm %s.sm" % (file_name, file_name))
        print("file_name=%s_sbts", file_name)
    if tac != 210:
        os.system("sed -i 's/ngap.tAC == 210/ngap.tAC == %s/' %s.sm" % (tac, file_name))
