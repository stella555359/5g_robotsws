"""
This file gives an example of refactoring for this code below using TtiTrace
and the TtiAnalysis class.

The proposed code is longer as it give some hints on how to use the TtiAnalysis class and its methods
moreover it gives a better structure to the code and makes it more readable and maintainable

##### Oringinal code #####
for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
nbMsg = nbMsg+1
if event.type == "dlFdSchedData":
    nbDlFdSchedData = nbDlFdSchedData+1
    SFN = event.data["eventHeader"]["sfn"]
    slot = event.data["eventHeader"]["slot"]
    numOfLayers = event.data["numOfLayers"]
    antPort = event.data["antPort"]
    dmrsType = event.data["dmrsConfigType"]
    nbCdmGroupWoData = event.data["numCdmGroupNoData"]
    antennaPortValue = event.data["antennaPortValue"]
    RNTI = event.data["eventHeader"]["rnti"]
    dciFormat = event.data["dciFormat"]

    if RNTI in RntiDmrsT1List or dciFormat in DCI_1_0_DL:
        expectedDmrsType = "TYPE1"
    else:
        expectedDmrsType = "TYPE2"

    if dmrsType != expectedDmrsType:
        print("TTI trace ERROR: unexpected DMRS type %s for UE %s (expected %s) at SFN %s, slot %s"
                % (dmrsType, RNTI, expectedDmrsType, SFN, slot))
        return 0

    if dmrsType == "TYPE1":
        nbDmrsType1 = nbDmrsType1+1
        expectedNbCDMGroupWoData = 2
        antValue_DMRS = antValue_DMRStype1
    else:
        nbDmrsType2 = nbDmrsType2+1
        expectedNbCDMGroupWoData = 3
        antValue_DMRS = antValue_DMRStype2

    if nbCdmGroupWoData != expectedNbCDMGroupWoData:
        print("TTI trace ERROR: nb of CDM group without data %s (expected %s) at SFN %s, slot %s"
                % (nbCdmGroupWoData, expectedNbCDMGroupWoData, SFN, slot))
        return 0

    if (nbCdmGroupWoData, antPort) not in antValue_DMRS:
        print("TTI trace ERROR: undefined tuple (%s, %s) at SFN %s, slot %s"
                % (nbCdmGroupWoData, antPort, SFN, slot))
        return 0

    expectedAntennaPortVal = antValue_DMRS[(nbCdmGroupWoData, antPort)]
    if antennaPortValue != expectedAntennaPortVal:
        print("TTI trace ERROR: antennaPortValue %s (expected %s) at SFN %s, slot %s"
                % (antennaPortValue, expectedAntennaPortVal, SFN, slot))
        return 0

"""

import os

from ..TtiTrace.TtiAnalysis import TtiAnalysis

"""
Definition of Antenna Port value accordind to the tuple (nb of DMRS CDM group Wo data, DMRS port) for DMRS type 1
See table 7.3.1.2.2-1 "Antenna port(s) (1000 + DMRS port), dmrs-Type=1, maxLength=1" in 3GPP 38.212
See req. 5G_UP_IF_11859, 5G_UP_IF_12733, 5G_UP_ALG_25102 and 5G_UP_ALG_25107
"""
antValue_DMRStype1 = {
    (1, 32768): 0,
    (1, 16384): 1,
    (1, 49152): 2,
    (2, 32768): 3,
    (2, 16384): 4,
    (2, 8192): 5,
    (2, 4096): 6,
    (2, 49152): 7,
    (2, 24576): 8,
    (2, 57344): 9,
    (2, 61440): 10,
    (2, 40960): 11}

# same values but it is just an example
antValue_DMRStype2 = {
    (1, 32768): 0,
    (1, 16384): 1,
    (1, 49152): 2,
    (2, 32768): 3,
    (2, 16384): 4,
    (2, 8192): 5,
    (2, 4096): 6,
    (2, 49152): 7,
    (2, 24576): 8,
    (2, 57344): 9,
    (2, 61440): 10,
    (2, 40960): 11}

jsonPathName = "/path/tomy/jsonfile.json"
DCI_1_0_DL = ['DL_10_MSG2', 'DL_10_MSG4', 'DL_10_FORCE']
events_list = ['dlFdSchedData']

# ********************************************************************************************************************
# *      WARNING: this code has not been tested and may not work as expected, it is provided as an example only      *
# ********************************************************************************************************************


def process_trace():
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        raise Exception(f"TTI trace ERROR: {jsonPathName} doesn't exist or size <= 24")
    RntiDmrsT1List = list(map(int, DCI_1_0_DL))
    analyzer = TtiAnalysis(jsonPathName, events_list)
    process_events(analyzer, RntiDmrsT1List)


def process_events(analyzer, RntiDmrsT1List):
    """
    Check the antenna port value according to the DMRS type, the number of DMRS CDM group without data
    and the DMRS port when actDlDataDmrsFdm is set to false.
    Return the number of checks passed, 0 in case of error
    """

    # optional check to explore your dataframe
    check_res_dict = analyzer.check_substrings_in_columns(["antPort", "dmrsConfigType",
                                                           "numCdmGroupNoData", "antennaPortValue"])

    # you get normally:
    # {'antPort': ['dlFdSchedData.antPort'], 'dmrsConfigType': ['dlFdSchedData.dmrsConfigType'],
    # 'numCdmGroupNoData': ['dlFdSchedData.numCdmGroupNoData'], 'antennaPortValue': ['dlFdSchedData.antennaPortValue']}

    nbDmrsType1 = 0
    nbDmrsType2 = 0

    # add a expectedDmrsType column with good value
    # just a way to do it, you can do it in another way
    analyzer.df['expectedDmrsType'] = analyzer.df.apply(
        lambda row: 'TYPE1' if row['rnti'] in RntiDmrsT1List or row['dciFormat'] in DCI_1_0_DL else 'TYPE2', axis=1)

    def check_dmrs_type(row):
        global nbDmrsType1, nbDmrsType2

        if row['dmrsConfigType'] != row['expectedDmrsType']:
            print(f"TTI trace ERROR: unexpected DMRS type {row['dmrsConfigType']}")
            print(f"for UE {row['rnti']} (expected {row['expectedDmrsType']})")
            print(f"at SFN {row['sfn']}, slot {row['slot']}")
            return 0
        if row['dmrsConfigType'] == "TYPE1":
            nbDmrsType1 += 1
            expectedNumcmd = 2
            antValue_DMRS = antValue_DMRStype1
        else:
            nbDmrsType2 += 1
            expectedNumcmd = 3
            antValue_DMRS = antValue_DMRStype2
        if row['dlFdSchedData.numCdmGroupNoData'] != expectedNumcmd:
            print(f"TTI trace ERROR: nb of CDM group without data {row['dlFdSchedData.numCdmGroupNoData']}")
            print(f"(expected 2) at SFN {row['sfn']}, slot {row['slot']}")
            return 0
        check_antenna_port_value = antValue_DMRS[(row['dlFdSchedData.numCdmGroupNoData'], row['dlFdSchedData.antPort'])]
        if row['dlFdSchedData.antennaPortValue'] != check_antenna_port_value:
            print(f"TTI trace ERROR: antennaPortValue {row['dlFdSchedData.antennaPortValue']}")
            print(f"(expected {check_antenna_port_value})")
            print(f"at SFN {row['sfn']}, slot {row['slot']}")
            return 0
        return 1

    # applying the method above to each row to check the DMRS type and the number of CDM group without data
    analyzer.df['checkResult'] = analyzer.df.apply(check_dmrs_type, axis=1)
    if 0 in analyzer.df['checkResult'].values:
        return 0
    else:
        return len(analyzer.df['checkResult'].values)
