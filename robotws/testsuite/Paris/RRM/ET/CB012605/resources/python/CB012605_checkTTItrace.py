import os
import json
import getopt
import sys
import re
import copy

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec
from collections import defaultdict


def check_SubpoolId_consistency(jsonPathName):
    """
    This function checks the L1Pool IDs and L1Subpool Ids consistency via dl/ulInterL1SubpoolReconfData events:
       - two L1Pool are used
       - L1Subpool IDs of each L1Pool are different
       - two L1Subpool Ids are defined by L1pool
    Input parameters:
       jsonPathName: json file of TTI traces
    Returned value:
       0 in case of error,  number of successful checks else
    IMPORTANT:
       Assumption: same L1Pool IDs and L1Sunpool IDs are used for UL and DL
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI ERROR: json file \"%s\" doesn't exist or size <= 24" % jsonPathName)
        return 0

    nbCheck = 0
    L1pool_0 = {"poolId": -1, "subpoolIdList": []}
    L1pool_1 = {"poolId": -1, "subpoolIdList": []}
    checkState = "poolIDdiscovery1"

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "dlInterL1SubpoolReconfData" or event.type == "ulInterL1SubpoolReconfData":
                if checkState == "poolIDdiscovery1":
                    L1pool_0["poolId"] = event.data["l1PoolId"]
                    L1pool_0["subpoolIdList"].append(event.data["l1SubPools"][0]["subPoolId"])
                    L1pool_0["subpoolIdList"].append(event.data["l1SubPools"][1]["subPoolId"])
                    checkState = "poolIDdiscovery2"
                    continue

                if checkState == "poolIDdiscovery2" and event.data["l1PoolId"] != L1pool_0["poolId"]:
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    L1pool_1["poolId"] = event.data["l1PoolId"]
                    subPoolId_0 = event.data["l1SubPools"][0]["subPoolId"]
                    subPoolId_1 = event.data["l1SubPools"][1]["subPoolId"]
                    if subPoolId_0 in L1pool_0["subpoolIdList"]:
                        print("TTI ERROR: subpool ID %s defined in both L1pool at %s/%s" % (subPoolId_0, SFN, slot))
                        return 0
                    if subPoolId_1 in L1pool_0["subpoolIdList"]:
                        print("TTI ERROR: subpool ID %s defined in both L1pool at %s/%s" % (subPoolId_1, SFN, slot))
                        return 0
                    L1pool_1["subpoolIdList"].append(subPoolId_0)
                    L1pool_1["subpoolIdList"].append(subPoolId_1)
                    checkState = "checkConsistency"
                    continue

                # check subpool Id consistency
                L1poolID = event.data["l1PoolId"]
                subPoolId_0 = event.data["l1SubPools"][0]["subPoolId"]
                subPoolId_1 = event.data["l1SubPools"][1]["subPoolId"]
                if L1poolID == L1pool_0["poolId"]:
                    L1pool_ref = L1pool_0
                elif L1poolID == L1pool_1["poolId"]:
                    L1pool_ref = L1pool_1
                else:
                    print("TTI ERROR: unknown L1pool ID %s at %s/%s)" % (L1poolID, SFN, slot))
                    return 0

                if subPoolId_0 not in L1pool_ref["subpoolIdList"]:
                    print("TTI ERROR: unexpected subpool ID %s for L1pool %s at %s/%s"
                          % (subPoolId_0, L1pool_ref["poolId"], SFN, slot))
                    return 0
                if subPoolId_1 not in L1pool_ref["subpoolIdList"]:
                    print("TTI ERROR: unexpected subpool ID %s for L1pool %s at %s/%s"
                          % (subPoolId_1, L1pool_ref["poolId"], SFN, slot))
                    return 0

                nbCheck = nbCheck+1

    if nbCheck == 0:
        if checkState == "poolID1discovery":
            print("TTI ERROR: TTI event %s not found" % TTIevent)
        else:
            print("TTI ERROR: only one L1pool found")

    print("L1Pool ID 0: %s, L1 subpoll Ids: %s" % (L1pool_0["poolId"], L1pool_0["subpoolIdList"]))
    print("L1Pool ID 1: %s, L1 subpoll Ids: %s" % (L1pool_1["poolId"], L1pool_1["subpoolIdList"]))

    return nbCheck


def check_l1SubPoolLayerPrbCapacity_consistency(jsonPathName, poolMaxNumLayerPrb,
                                                TTIevent="dlInterL1SubpoolReconfData"):
    """
    This function checks min/max/calculated LayerPrbAllocationSp consistency in dl/ulInterL1SubpoolReconfData events
    Input parameters:
       jsonPathName: json file of TTI traces
       poolMaxNumLayerPrb: max number of layer PRBs by L1Pool
       TTIevent: TTI event to check (dl or ul InterL1SubpoolReconfData)
    Returned value:
       0 in case of error,  number of successful checks else
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI ERROR: json file \"%s\" doesn't exist or size <= 24" % jsonPathName)
        return 0

    if TTIevent != "dlInterL1SubpoolReconfData" and TTIevent != "ulInterL1SubpoolReconfData":
        print("TTI ERROR: TTI event \"%s\" not supported" % TTIevent)
        return 0

    poolMaxNumLayerPrb = int(poolMaxNumLayerPrb)
    nbCheck = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == TTIevent:
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                subPoolId_0 = event.data["l1SubPools"][0]["subPoolId"]
                subPoolId_1 = event.data["l1SubPools"][1]["subPoolId"]
                minLayerPrbAllocationSp_0 = event.data["l1SubPools"][0]["minLayerPrbAllocationSp"]
                minLayerPrbAllocationSp_1 = event.data["l1SubPools"][1]["minLayerPrbAllocationSp"]
                calculatedLayerPrbCapacityPerSp_0 = event.data["l1SubPools"][0]["calculatedLayerPrbCapacityPerSp"]
                calculatedLayerPrbCapacityPerSp_1 = event.data["l1SubPools"][1]["calculatedLayerPrbCapacityPerSp"]

                if not (minLayerPrbAllocationSp_0 <= calculatedLayerPrbCapacityPerSp_0):
                    print("TTI ERROR: calculatedLayerPrbCapacityPerSp (%s) out of range (subPool ID %s at %s/%s)"
                          % (calculatedLayerPrbCapacityPerSp_0, subPoolId_0, SFN, slot))
                    return 0

                if not (minLayerPrbAllocationSp_1 <= calculatedLayerPrbCapacityPerSp_1):
                    print("TTI ERROR: calculatedLayerPrbCapacityPerSp (%s) out of range (subPool ID %s at %s/%s)"
                          % (calculatedLayerPrbCapacityPerSp_1, subPoolId_1, SFN, slot))
                    return 0

                if (calculatedLayerPrbCapacityPerSp_0+calculatedLayerPrbCapacityPerSp_1 > poolMaxNumLayerPrb):
                    calculatedLayerPrbCapacity = calculatedLayerPrbCapacityPerSp_0+calculatedLayerPrbCapacityPerSp_1
                    print("TTI ERROR: sum of calculatedLayerPrbCapacityPerSp (%s) exceeds %s at %s/%s"
                          % (calculatedLayerPrbCapacity, poolMaxNumLayerPrb, SFN, slot))
                    return 0

                nbCheck = nbCheck+1

    if not nbCheck:
        print("TTI ERROR: no TTI event %s found" % TTIevent)

    return nbCheck


def check_DLl1SubPoolLayerPrbCapacity_consistency(jsonPathName, poolMaxNumLayerPrb):
    return check_l1SubPoolLayerPrbCapacity_consistency(jsonPathName, poolMaxNumLayerPrb, "dlInterL1SubpoolReconfData")


def check_ULl1SubPoolLayerPrbCapacity_consistency(jsonPathName, poolMaxNumLayerPrb):
    return check_l1SubPoolLayerPrbCapacity_consistency(jsonPathName, poolMaxNumLayerPrb, "ulInterL1SubpoolReconfData")


def check_numAllocCellPrbDl_within_a_range(jsonPathName, minNbLayerPrb, maxNbLayerPrb, physCellId=-1):
    """
    This function checks the number of DL layer PRBs allocated to a cell
    Input parameters:
       jsonPathName: json file of TTI traces
       minNbLayerPrb: expected min value
       maxNbLayerPrb: expected max value
       physCellId: physCellId to check, all cells are checked if set to -1
    Returned value:
       0 in case of error,  number of successful checks else
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI ERROR: json file \"%s\" doesn't exist or size <= 24" % jsonPathName)
        return 0

    physCellId = int(physCellId)
    minNbLayerPrb = int(minNbLayerPrb)
    maxNbLayerPrb = int(maxNbLayerPrb)
    nbCheck = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if (event.type == "dlAllocatedPooledResourcesData" and
               (physCellId == event.data["eventHeader"]["physCellId"] or physCellId == -1)):
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                numAllocCellLayerPrbDl = event.data["numAllocCellLayerPrbDl"]

                if not (minNbLayerPrb <= numAllocCellLayerPrbDl <= maxNbLayerPrb):
                    print("TTI ERROR: numAllocCellLayerPrbDl (%s) out of range [%s-%s] at %s/%s"
                          % (numAllocCellLayerPrbDl, minNbLayerPrb, maxNbLayerPrb, SFN, slot))
                    return 0
                nbCheck = nbCheck+1

    if nbCheck == 0:
        if physCellId == -1:
            print("TTI ERROR: no event dlAllocatedPooledResourcesData found")
        else:
            print("TTI ERROR: no event dlAllocatedPooledResourcesData found for physCellId %s" % physCellId)

    return nbCheck


def check_numAllocCellPrbUl_within_a_range(jsonPathName, minNbLayerPrb, maxNbLayerPrb, physCellId=-1):
    """
    This function checks the number of UL layer PRBs allocated to a cell
    Input parameters:
       jsonPathName: json file of TTI traces
       minNbLayerPrb: expected min value
       maxNbLayerPrb: expected max value
       physCellId: physCellId to check, all cells are checked if set to -1
    Returned value:
       0 in case of error,  number of successful checks else
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI ERROR: json file \"%s\" doesn't exist or size <= 24" % jsonPathName)
        return 0

    physCellId = int(physCellId)
    minNbLayerPrb = int(minNbLayerPrb)
    maxNbLayerPrb = int(maxNbLayerPrb)
    nbCheck = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if (event.type == "ulAllocatedPooledResourcesData" and
               (physCellId == event.data["eventHeader"]["physCellId"] or physCellId == -1)):
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                numAllocCellLayerPrbUl = event.data["numAllocCellLayerPrbUl"]

                if not (minNbLayerPrb <= numAllocCellLayerPrbUl <= maxNbLayerPrb):
                    print("TTI ERROR: numAllocCellLayerPrbUl (%s) out of range [%s-%s] at %s/%s"
                          % (numAllocCellLayerPrbUl, minNbLayerPrb, maxNbLayerPrb, SFN, slot))
                    return 0
                nbCheck = nbCheck+1

    if nbCheck == 0:
        if physCellId == -1:
            print("TTI ERROR: no event ulAllocatedPooledResourcesData found")
        else:
            print("TTI ERROR: no event ulAllocatedPooledResourcesData found for physCellId %s" % physCellId)

    return nbCheck


def check_maxAllocLayerPrbPerL1poolDl(jsonPathName, cellsPerL1pool, maxNbLayerPrb):
    return check_numAllocCellPrb_max(jsonPathName, cellsPerL1pool, maxNbLayerPrb, "dl")


def check_maxAllocLayerPrbPerL1poolUl(jsonPathName, cellsPerL1pool, maxNbLayerPrb):
    return check_numAllocCellPrb_max(jsonPathName, cellsPerL1pool, maxNbLayerPrb, "ul")


def check_numAllocCellPrb_max(jsonPathName, cellsPerL1pool, maxNbLayerPrb, direction):
    """
    This function checks that the number of layer PRBs allocated to L1pools doesn't exceed max
    Input parameters:
       jsonPathName: json file of TTI traces
       cellsPerL1pool: dictionary of cells allocated per L1pool as {9: [50, 52, 54], 12: [51, 53, 55]}
       maxNbLayerPrb: max number of layer PRBs per L1pool
       direction: allocation direction to check, must be dl or ul
    Returned value:
       0 in case of error,  number of successful checks else
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI ERROR: json file \"%s\" doesn't exist or size <= 24" % jsonPathName)
        return 0

    if direction == "dl":
        TTIevent = "dlAllocatedPooledResourcesData"
        fieldName = "numAllocCellLayerPrbDl"
    elif direction == "ul":
        TTIevent = "ulAllocatedPooledResourcesData"
        fieldName = "numAllocCellLayerPrbUl"
    else:
        print("ERROR check_numAllocCellPrbUl_max: direction (%s) must be dl or ul" % direction)
        return 0

    maxNbLayerPrb = int(maxNbLayerPrb)
    nbL1pool = len(cellsPerL1pool)
    if nbL1pool == 0:
        print("ERROR : empty %s cellsPerL1pool parameter" % direction)
        return 0

    L1poolIdList = list(cellsPerL1pool.keys())
    cellsPerL1poolList = list(cellsPerL1pool.values())
    layerPrbAllocList = [0] * nbL1pool

    checkState = "syncFirst"
    nbCheck = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if (event.type == TTIevent):
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                if checkState == "syncFirst":
                    SFNsync = SFN
                    checkState = "syncLast"
                    continue

                if checkState == "syncLast":
                    if SFN == SFNsync:
                        continue
                    SFNinProgress = SFN
                    checkState = "checkInProgress"

                physCellId = event.data["eventHeader"]["physCellId"]
                numAllocCellLayerPrb = event.data[fieldName]
                for poolNum in range(nbL1pool):
                    if physCellId in cellsPerL1poolList[poolNum]:
                        break
                if SFN == SFNinProgress:
                    layerPrbAllocList[poolNum] = layerPrbAllocList[poolNum]+numAllocCellLayerPrb
                    if (layerPrbAllocList[poolNum] > maxNbLayerPrb):
                        print("TTI ERROR: nb of allocated Layer Prb (%s) exceeds max %s for L1pool %s at SFN %s"
                              % (layerPrbAllocList[poolNum], maxNbLayerPrb, L1poolIdList[poolNum], SFN))
                        return 0
                else:
                    layerPrbAllocList = [0] * nbL1pool
                    layerPrbAllocList[poolNum] = numAllocCellLayerPrb
                    SFNinProgress = SFN
                    nbCheck = nbCheck+1

    if nbCheck == 0:
        print("TTI ERROR: no event " + TTIevent + " found")

    return nbCheck


def getCellPerL1pool_from_syslog(syslogFile):
    """
    This function builds the cell lists deployed on the UL and DL L1 pools
    from the cell setup request traced in a syslog
    Input parameters:
       syslogFile: SYSLOG file including cellSetupReq
    Returned value:
       DL and UL dictionaries of cells allocated per L1pool as {9: [50, 52, 54], 12: [51, 53, 55]}
    """
    """
    Wrapper pour Robot Framework:
      - Un seul paramètre syslogFile (comme avant)
      - Active infer_missing=True par défaut
    """
    return _getCellPerL1pool_from_syslog(syslogFile, infer_missing=True, lookahead=50000)
#    if not os.path.exists(syslogFile):
#        print("TTI ERROR: SYSLOG file \"%s\" not found" % syslogFile)
#        return 0

#    DlL1poolsCell = {}
#   UlL1poolsCell = {}
#    cellSetupReqlist = getCellSetupReqList_from_syslog(syslogFile)

#    for msg in cellSetupReqlist:
#        data = json.loads(msg)
#        physCellId = data["physCellId"]
#        DlL1pool = data["dlSubcellList"][0]["l1PoolId"]
#        UlL1pool = data["ulSubcellList"][0]["l1PoolId"]
#        if DlL1pool in DlL1poolsCell:
#            DlL1poolsCell[DlL1pool].append(physCellId)
#        else:
#            DlL1poolsCell[DlL1pool] = [physCellId]
#        if UlL1pool in UlL1poolsCell:
#            UlL1poolsCell[UlL1pool].append(physCellId)
#        else:
#            UlL1poolsCell[UlL1pool] = [physCellId]
#        DlCells = list(DlL1poolsCell.values())
#        UlCells = list(UlL1poolsCell.values())

#    return DlL1poolsCell, UlL1poolsCell


def _getCellPerL1pool_from_syslog(syslogFile, infer_missing=True, lookahead=50000):
    """
    Parse un syslog contenant des traces 'CellSetupReq' potentiellement cassées.
    Stratégie:
      - Détecte tous les physCellId dans le fichier.
      - Pour chaque physCellId, cherche le prochain 'l1PoolId' dans une fenêtre lookahead.
      - Agrège les PCI par poolId et retourne (DL, UL) identiques dans cette trace.
    Paramètres:
      infer_missing: (par défaut True) complète les PCI sans pool avec le voisin suivant (logique constatée ici).
      lookahead: taille de la fenêtre (en caractères) pour chercher l1PoolId après physCellId.
    Retour:
      (DlCellsPerL1pool, UlCellsPerL1pool) — dict {poolId: [pci triés]}
    """
    if not os.path.exists(syslogFile):
        print(f'TTI ERROR: SYSLOG file "{syslogFile}" not found')
        return {}, {}

    with open(syslogFile, 'r', encoding='utf-8', errors='ignore') as f:
        text = f.read()

    # Tous les physCellId vus dans les CellSetupReq
    pci_positions = [(m.start(), int(m.group(1)))
                     for m in re.finditer(r'"physCellId"\s*:\s*(\d+)', text)]

    # Pour chaque PCI, cherche le prochain l1PoolId dans la fenêtre lookahead
    pci_to_pool = {}
    for pos, pci in pci_positions:
        after = text[pos:pos+lookahead]
        m = re.search(r'"l1PoolId"\s*:\s*(\d+)', after)
        if m:
            pci_to_pool[pci] = int(m.group(1))

    # Inférence (complète le PCI sans pool avec celui du voisin suivant, sinon précédent)
    if infer_missing:
        all_pcis = sorted({pci for _, pci in pci_positions})
        for pci in all_pcis:
            if pci not in pci_to_pool:
                next_with_pool = next((p for p in all_pcis if p > pci and p in pci_to_pool), None)
                prev_with_pool = next((p for p in reversed(all_pcis) if p < pci and p in pci_to_pool), None)
                if next_with_pool is not None:
                    pci_to_pool[pci] = pci_to_pool[next_with_pool]
                elif prev_with_pool is not None:
                    pci_to_pool[pci] = pci_to_pool[prev_with_pool]

    # Construit les pools (DL et UL identiques dans cette trace)
    pools = defaultdict(list)
    for pci, pool in pci_to_pool.items():
        pools[pool].append(pci)

    DlCellsPerL1pool = {pool: sorted(pcis) for pool, pcis in pools.items()}
    UlCellsPerL1pool = {pool: sorted(pcis) for pool, pcis in pools.items()}
    return DlCellsPerL1pool, UlCellsPerL1pool


def updateCellPerL1pool_from_syslog(syslogFile, DlL1poolsCell, UlL1poolsCell):
    """
    This function updates the cell lists deployed on the UL and DL L1 pools
    from the cell setup request traced in a syslog
    Could be called after a cell addition as example
    Input parameters:
       syslogFile: SYSLOG file including cellSetupReq
       DlL1poolsCell: dictionary of cells allocated per DL L1pool as {9: [50, 52, 54], 12: [51, 53, 55]}
       UlL1poolsCell: dictionary of cells allocated per UL L1pool as {9: [50, 52, 54], 12: [51, 53, 55]}
    Returned value:
       Updated DL and UL dictionaries of cells allocated per L1pool
    """
    if not os.path.exists(syslogFile):
        print(f'TTI ERROR: SYSLOG file "{syslogFile}" not found')
        return DlL1poolsCell, UlL1poolsCell

    Upd_Dl = {p: list(c) for p, c in DlL1poolsCell.items()}
    Upd_Ul = {p: list(c) for p, c in UlL1poolsCell.items()}

    # Deduplicate & sort
    Upd_DlL1poolsCell = {p: sorted(c) for p, c in Upd_Dl.items()}
    Upd_UlL1poolsCell = {p: sorted(c) for p, c in Upd_Ul.items()}

    return Upd_DlL1poolsCell, Upd_UlL1poolsCell

    #  Upd_DlL1poolsCell = copy.deepcopy(DlL1poolsCell)
    #  Upd_UlL1poolsCell = copy.deepcopy(UlL1poolsCell)

    #  cellSetupReqlist = getCellSetupReqList_from_syslog(syslogFile)
    #  for msg in cellSetupReqlist:
    #      data = json.loads(msg)
    #      physCellId = data["physCellId"]
    #      DlL1pool = data["dlSubcellList"][0]["l1PoolId"]
    #      UlL1pool = data["ulSubcellList"][0]["l1PoolId"]

    #      for L1Id, cellsList in Upd_DlL1poolsCell.items():
    #          if physCellId in cellsList:
    #              Upd_DlL1poolsCell[L1Id].remove(physCellId)

    #      for L1Id, cellsList in Upd_UlL1poolsCell.items():
    #          if physCellId in cellsList:
    #              Upd_UlL1poolsCell[L1Id].remove(physCellId)

    #      if DlL1pool in Upd_DlL1poolsCell:
    #          Upd_DlL1poolsCell[DlL1pool].append(physCellId)
    #      else:
    #          Upd_DlL1poolsCell[DlL1pool] = [physCellId]
    #      if UlL1pool in Upd_UlL1poolsCell:
    #          Upd_UlL1poolsCell[UlL1pool].append(physCellId)
    #      else:
    #          Upd_UlL1poolsCell[UlL1pool] = [physCellId]

    #  return Upd_DlL1poolsCell, Upd_UlL1poolsCell


def getCellSetupReqList_from_syslog(syslogFile):
    cellSetupReqCat = os.popen("cat " + syslogFile + " |grep :CellSetupReq:")
    cellSetupReqLines = cellSetupReqCat.read().strip()

    if not cellSetupReqLines:
        print("WARNING: no cellSetupReq found in SYSLOG \"%s\"" % syslogFile)
        return []

    syslogextract_flt = re.sub(r"\n.*?: ", '', cellSetupReqLines)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    return matches


def get_last_item(input_string, starting_item):
    starting_string = '{"' + starting_item + '":'
    start_idx = input_string.find(starting_string)

    while start_idx != -1:
        end_idx = find_matching_brace(input_string, start_idx)
        if end_idx == -1:
            break

        json_str = input_string[start_idx:end_idx + 1]
        start_idx = input_string.find(starting_string, end_idx + 1)

    last_item = find_last_occurrence('\"(.*?)\":', json_str)
    return last_item


def find_matching_brace(s, start):
    count = 1
    for i in range(start + 1, len(s)):
        if s[i] == '{':
            count += 1
        elif s[i] == '}':
            count -= 1
            if count == 0:
                return i
    return -1


def find_last_occurrence(pattern, input_string):
    matches = re.findall(pattern, input_string)
    if matches:
        return matches[-1]
    else:
        return None
