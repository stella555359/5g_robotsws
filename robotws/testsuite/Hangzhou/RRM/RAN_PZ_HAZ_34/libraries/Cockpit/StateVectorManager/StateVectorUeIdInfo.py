import math
import time
from ..utilities.Constants import Constants


class StateVectorUeIdInfo:
    def __init__(self):
        self._traceKeyToBranchId = {}
        self._branchInfo = []
        self._correlationIdToBranchIdAndTimeEpoch = {}
        pass

    def getBranchId(self, idName, idValue, timeEpoch):
        timeEpoch = float(timeEpoch)
        resultBranchId = None
        resultIsNewBranch = False

        if idName not in self._traceKeyToBranchId:
            self._traceKeyToBranchId[idName] = {}

        if idValue not in self._traceKeyToBranchId[idName]:
            self._traceKeyToBranchId[idName][idValue] = []

        for branchId in self._traceKeyToBranchId[idName][idValue]:
            branchInfo = self._branchInfo[branchId]
            # debugWrite("branchInfo:" , branchInfo)
            if timeEpoch <= branchInfo["estimatedEndTimeEpoch"]:
                resultBranchId = branchId

        if resultBranchId is None:
            resultBranchId = len(self._branchInfo)
            resultIsNewBranch = True
            self._traceKeyToBranchId[idName][idValue].append(resultBranchId)
            branchInfo = {}
            branchInfo["idName"] = idName
            branchInfo["idValue"] = idValue
            branchInfo["firstTimeEpoch"] = timeEpoch
            branchInfo["lastTimeEpoch"] = timeEpoch
            branchInfo["estimatedEndTimeEpoch"] = Constants.MAX_TIME_SECONDS
            branchInfo["correlatedId"] = None
            branchInfo["correlationInfo"] = []
            self._branchInfo.append(branchInfo)

        if timeEpoch < self._branchInfo[resultBranchId]["firstTimeEpoch"]:
            self._branchInfo[resultBranchId]["firstTimeEpoch"] = timeEpoch

        if timeEpoch > self._branchInfo[resultBranchId]["lastTimeEpoch"]:
            self._branchInfo[resultBranchId]["lastTimeEpoch"] = timeEpoch

        return (resultBranchId, resultIsNewBranch)

    def storeEstimatedEndTimeEpoch(
            self,
            branchId,
            estimatedEndTimeEpoch,
            guardTimer=0.0):
        estimatedEndTimeEpoch = float(estimatedEndTimeEpoch) + guardTimer
        self._branchInfo[branchId]["estimatedEndTimeEpoch"] = estimatedEndTimeEpoch

    def storeCorrelationInfo(self, branchId, idName, idValue, timeEpoch):
        timeEpoch = float(timeEpoch)
        correlationInfo = {}
        correlationInfo["idName"] = idName
        correlationInfo["idValue"] = idValue
        correlationInfo["timeEpoch"] = timeEpoch
        self._branchInfo[branchId]["correlationInfo"].append(correlationInfo)

        if idName not in self._correlationIdToBranchIdAndTimeEpoch:
            self._correlationIdToBranchIdAndTimeEpoch[idName] = {}

        if idValue not in self._correlationIdToBranchIdAndTimeEpoch[idName]:
            self._correlationIdToBranchIdAndTimeEpoch[idName][idValue] = []

        branchIdAndTimeEpoch = {}
        branchIdAndTimeEpoch["branchId"] = branchId
        branchIdAndTimeEpoch["timeEpoch"] = timeEpoch
        self._correlationIdToBranchIdAndTimeEpoch[idName][idValue].append(
            branchIdAndTimeEpoch)

    def calculateCorrelatedId(self):
        for firstBranchId in range(len(self._branchInfo)):
            resultCorrelatedId = None
            for correlationInfo in self._branchInfo[firstBranchId]["correlationInfo"]:
                # try to find another branchId with same correlationInfo idName
                # & idValue
                firstIdName = correlationInfo["idName"]
                firstIdValue = correlationInfo["idValue"]
                firstTimeEpoch = correlationInfo["timeEpoch"]
                for branchIdAndTimeEpoch in self._correlationIdToBranchIdAndTimeEpoch[
                        firstIdName][firstIdValue]:
                    secondBranchId = branchIdAndTimeEpoch["branchId"]
                    secondTimeEpoch = branchIdAndTimeEpoch["timeEpoch"]
                    if (secondBranchId != firstBranchId) and (
                            self._branchInfo[secondBranchId]["correlatedId"] is not None):
                        if (math.fabs(secondTimeEpoch - firstTimeEpoch) <= 5.5):
                            resultCorrelatedId = self._branchInfo[secondBranchId]["correlatedId"]
                            print(
                                "Correlation OK for branchIds: ",
                                firstBranchId,
                                secondBranchId,
                                time.strftime(
                                    "%Y/%m/%d %H:%M:%S",
                                    time.localtime(firstTimeEpoch)),
                                time.strftime(
                                    "%Y/%m/%d %H:%M:%S",
                                    time.localtime(secondTimeEpoch)),
                                self._branchInfo[firstBranchId],
                                self._branchInfo[secondBranchId])
                            break
                if resultCorrelatedId is not None:
                    break

            if resultCorrelatedId is None and self._branchInfo[firstBranchId]["correlationInfo"]:
                resultCorrelatedId = firstBranchId

            self._branchInfo[firstBranchId]["correlatedId"] = resultCorrelatedId

    def getCorrelatedId(self, branchId):
        return (self._branchInfo[branchId]["correlatedId"])

    def getCorrelatedIdList(self):
        returnResult = []
        for branchInfo in self._branchInfo:
            if branchInfo["correlatedId"] is not None:
                returnResult.append(branchInfo["correlatedId"])
        return (returnResult)

        # def print(self):
        # debugWrite("StateVectorUeIdInfo:\n")
        # debugWrite("_traceKeyToBranchId: ", self._traceKeyToBranchId)
        # debugWrite("\n_branchInfo: ", self._branchInfo)
        # debugWrite("\n_correlationIdToBranchIdAndTimeEpoch", self._correlationIdToBranchIdAndTimeEpoch)
