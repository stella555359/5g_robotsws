import pkgutil
import subprocess
import importlib


PASS = 1
FAIL = 0
ccesplit_K1opt = 0
adaptretx = 0
actEnhancedPDSCHSchSplSlot = 0
actDlPaWarmUp = 0
flag_8322 = 0
resp = 0


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def check_dl_slot_1208(df_pdsch):
    """
    Using this function , Only DL_DCI schedulable slots are validated ie, Slot 2,3,7,8,12,13,17,18.
    The formatted csv data is passed as input to this function
    Not ratematched slots are filtered out and validating overlap of SIB and CRNTI message
    """
    df_pdsch_2378_12131718 = df_pdsch.loc[
        (df_pdsch.slot == '2') | (df_pdsch.slot == '3') | (df_pdsch.slot == '12') | (df_pdsch.slot == '13') | (
                    df_pdsch.slot == '7') | (df_pdsch.slot == '8') | (df_pdsch.slot == '17') | (df_pdsch.slot == '18')]
    if df_pdsch_2378_12131718.empty:
        print('FAIL - DataFrame(df_pdsch_2378_12131718) is empty!')
        return FAIL
#    df_pdsch_2378_12131718_ratematching = df_pdsch_2378_12131718.query("rateMatchingOption > 0")
    df_pdsch_2378_12131718_not_ratematching = df_pdsch_2378_12131718.loc[df_pdsch_2378_12131718.rateMatchingOption == 0]
    print(df_pdsch_2378_12131718_not_ratematching)
    count_sirnti = len(
        df_pdsch_2378_12131718_not_ratematching[(df_pdsch_2378_12131718_not_ratematching.rnti == 65535)])
    count_crnti = len(
        df_pdsch_2378_12131718_not_ratematching[(df_pdsch_2378_12131718_not_ratematching.rnti != 65535)])

    if count_sirnti >= ((80 * count_crnti) / 100):
        print("PASS- DL_SI", count_sirnti, count_crnti)
        return PASS
    else:
        print("FAIL- DL_SI", count_sirnti, count_crnti)
        return FAIL


def check_first_dl_after_ul_slot_1208(df_pdsch, rnd_flag):
    """
    Using this function , First DL slot after UL slot is validated ie, Slot 0,5,10,15.
    The formatted csv data and RnD flag are passed as input to this function
    When RnDflag is enabled RATEMATCHING(2) should be enabled in these slots
    and in RnDflag disabled case, no RATEMATCHING
    """
    df_pdsch_05_1015 = df_pdsch.loc[
        (df_pdsch.slot == '0') | (df_pdsch.slot == '5') | (df_pdsch.slot == '10') | (df_pdsch.slot == '15')]
    print(df_pdsch_05_1015)
    if df_pdsch_05_1015.empty:
        print('FAIL - DataFrame(df_pdsch_05_1015) is empty!')
        return FAIL
    len_df_pdsch_05_1015_ratematching = len(
        df_pdsch_05_1015[(df_pdsch_05_1015.rateMatchingOption > 0)])
    if actDlPaWarmUp == 1:
        if len_df_pdsch_05_1015_ratematching == 0:
            print("PASS - FirstDLAfterUL_NO_RATEMATCHING_PaWarmUpEnabled")
            return PASS
    elif len_df_pdsch_05_1015_ratematching != 0:
        if int(rnd_flag) == 0:
            print("FAIL_1 - FirstDLAfterUL", len_df_pdsch_05_1015_ratematching, int(rnd_flag))
            return FAIL
        elif int(rnd_flag) == 1:
            print("PASS - FirstDLAfterUL_RATEMATCHING", len_df_pdsch_05_1015_ratematching, int(rnd_flag))
            return PASS
    else:
        if int(rnd_flag) == 1:
            print("FAIL_2 - FirstDLAfterUL", len_df_pdsch_05_1015_ratematching)
            return FAIL
        elif int(rnd_flag) == 0:
            print("PASS - FirstDLAfterUL_NORATEMATCHING", len_df_pdsch_05_1015_ratematching)
            return PASS


def check_dl_ul_slot_1208(df_pdsch):
    """
    Using this function , slots which can schedule UL adn DL DCI are validated ie, Slot 1,6,11,16
    The formatted csv data is passed as input to this function
    Based on the ccesplit_K1opt value RATEMATCHING is checked.
    ccesplit_K1opt = 0, means both actCceSplit and actK1Opt flags are disabled and
    hence RATE_MATCHING can happen in most of the slot except Paging occasion slot.
    """
    df_pdsch_16_1116 = df_pdsch.loc[
        (df_pdsch.slot == '1') | (df_pdsch.slot == '6') | (df_pdsch.slot == '11') | (df_pdsch.slot == '16')]
    print(df_pdsch_16_1116)
    if df_pdsch_16_1116.empty:
        print('FAIL - DataFrame(df_pdsch_16_1116) is empty!')
        return FAIL
    len_df_pdsch_16_1116_ratematching = len(
        df_pdsch_16_1116[(df_pdsch_16_1116.rateMatchingOption > 0)])
    len_df_pdsch_16_1116_no_ratematching = len(
        df_pdsch_16_1116[(df_pdsch_16_1116.rateMatchingOption == 0)])
    if ccesplit_K1opt == 1:
        if len_df_pdsch_16_1116_ratematching == 0:
            print("PASS-UL_DL_1", len_df_pdsch_16_1116_no_ratematching, len_df_pdsch_16_1116_ratematching,
                  ccesplit_K1opt)
            return PASS
        else:
            print("FAIL-UL_DL_1", len_df_pdsch_16_1116_no_ratematching, len_df_pdsch_16_1116_ratematching,
                  ccesplit_K1opt)
            return FAIL
    elif ccesplit_K1opt == 0:
        if len_df_pdsch_16_1116_ratematching == 0:
            print("FAIL-UL_DL_2", len_df_pdsch_16_1116_no_ratematching, len_df_pdsch_16_1116_ratematching,
                  ccesplit_K1opt)
            return FAIL
        elif (flag_8322 == 1) and \
                (len_df_pdsch_16_1116_no_ratematching <= ((40 * len_df_pdsch_16_1116_ratematching) / 100)):
            print("PASS-UL_DL_2", len_df_pdsch_16_1116_no_ratematching, len_df_pdsch_16_1116_ratematching,
                  ccesplit_K1opt)
            return PASS
        elif (flag_8322 == 0) and \
                (len_df_pdsch_16_1116_no_ratematching <= ((25 * len_df_pdsch_16_1116_ratematching) / 100)):
            print("PASS-UL_DL_2", len_df_pdsch_16_1116_no_ratematching, len_df_pdsch_16_1116_ratematching,
                  ccesplit_K1opt)
            return PASS
        else:
            print("FAIL-UL_DL_3", len_df_pdsch_16_1116_no_ratematching, len_df_pdsch_16_1116_ratematching,
                  ccesplit_K1opt)
            return FAIL


def check_first_dl_after_ul_slot_1116(df_pdsch, rnd_flag):
    """
    Using this function , First DL slot after UL slot is validated ie, Slot 0 and 10.
    The formatted csv data and RnD flag are passed as input to this function
    When RnDflag is enabled RATEMATCHING(2) should be enabled in these slots
    and in RnDflag disabled case, no RATEMATCHING
    """
    df_pdsch_0_10 = df_pdsch.loc[
        (df_pdsch.slot == '0') | (df_pdsch.slot == '10')]
    print(df_pdsch_0_10)
    if df_pdsch_0_10.empty:
        print('FAIL - DataFrame(df_pdsch_0_10) is empty!')
        return FAIL

    len_df_pdsch_0_10_ratematching = len(
        df_pdsch_0_10[(df_pdsch_0_10.rateMatchingOption > 0)])
    if len_df_pdsch_0_10_ratematching != 0:
        if int(rnd_flag) == 0:
            print("FAIL - FirstDLAfterUL", len_df_pdsch_0_10_ratematching, int(rnd_flag))
            return FAIL
        elif int(rnd_flag) == 1:
            print("PASS - FirstDLAfterUL_RATEMATCHING", len_df_pdsch_0_10_ratematching, int(rnd_flag))
            return PASS
        else:
            print("Returning FAIL as now of the passing criteria met", int(rnd_flag))
            return FAIL
    else:
        if int(rnd_flag) == 1:
            print("FAIL - FirstDLAfterUL", len_df_pdsch_0_10_ratematching)
            return FAIL
        elif int(rnd_flag) == 0:
            print("PASS - FirstDLAfterUL_NORATEMATCHING", len_df_pdsch_0_10_ratematching)
            return PASS
        else:
            print("Returning FAIL as now of the passing criteria met", int(rnd_flag))
            return FAIL


def check_dl_ul_slot_1116(df_pdsch):
    """
    Using this function , slots which can schedule UL adn DL DCI are validated ie, Slot 7,6,17,16
    The formatted csv data is passed as input to this function
    Based on the ccesplit_K1opt value RATEMATCHING is checked.
    ccesplit_K1opt = 0, means both actCceSplit and actK1Opt flags are disabled and
    hence RATE_MATCHING can happen in most of the slot except Paging occasion slot.
    """
    df_pdsch_6_5_16_15 = df_pdsch.loc[
        (df_pdsch.slot == '5') | (df_pdsch.slot == '6') | (df_pdsch.slot == '15') | (df_pdsch.slot == '16')]
    print(df_pdsch_6_5_16_15)
    if df_pdsch_6_5_16_15.empty:
        print('FAIL - DataFrame(df_pdsch_6_5_16_15) is empty!')
        return FAIL
    len_df_pdsch_6_5_16_15_ratematching = len(
        df_pdsch_6_5_16_15[(df_pdsch_6_5_16_15.rateMatchingOption > 0)])
    len_df_pdsch_6_5_16_15_no_ratematching = len(
        df_pdsch_6_5_16_15[(df_pdsch_6_5_16_15.rateMatchingOption == 0)])
    if ccesplit_K1opt == 1:   # In this case RateMatching should not happen in DL+UL slot
        if len_df_pdsch_6_5_16_15_ratematching == 0:
            print("PASS-UL_DL", len_df_pdsch_6_5_16_15_no_ratematching, len_df_pdsch_6_5_16_15_ratematching,
                  ccesplit_K1opt)
            return PASS
        else:
            print("FAIL-UL_DL", len_df_pdsch_6_5_16_15_no_ratematching, len_df_pdsch_6_5_16_15_ratematching,
                  ccesplit_K1opt)
            return FAIL
    elif ccesplit_K1opt == 0:
        if len_df_pdsch_6_5_16_15_ratematching == 0:
            print("FAIL-UL_DL", len_df_pdsch_6_5_16_15_no_ratematching, len_df_pdsch_6_5_16_15_ratematching,
                  ccesplit_K1opt)
            return FAIL
        elif len_df_pdsch_6_5_16_15_no_ratematching <= ((25 * len_df_pdsch_6_5_16_15_ratematching) / 100):
            print("PASS-UL_DL", len_df_pdsch_6_5_16_15_no_ratematching, len_df_pdsch_6_5_16_15_ratematching,
                  ccesplit_K1opt)
            return PASS
        else:
            print("FAIL-UL_DL", len_df_pdsch_6_5_16_15_no_ratematching, len_df_pdsch_6_5_16_15_ratematching,
                  ccesplit_K1opt)
            return FAIL


def check_dl_slot_1116(df_pdsch):
    """
    Using this function , Only DL_DCI schedulable slots are validated ie, Slot 1,2,3,4,5,11,12,13,14,15 and
    Special slots 7,17
    The formatted csv data is passed as input to this function
    Not ratematched slots are filtered out and validating overlap of SIB and CRNTI message
    """
    df_pdsch_125_111215 = df_pdsch.loc[
        (df_pdsch.slot == '1') | (df_pdsch.slot == '2') | (df_pdsch.slot == '11') | (df_pdsch.slot == '12') | (
                    df_pdsch.slot == '5') | (df_pdsch.slot == '15')]
    if df_pdsch_125_111215.empty:
        print('FAIL - DataFrame(df_pdsch_125_111215) is empty!')
        return FAIL
    #    df_pdsch_125_111215_ratematching = df_pdsch_125_111215.query("rateMatchingOption > 0")
    df_pdsch_125_111215_not_ratematching = df_pdsch_125_111215.loc[df_pdsch_125_111215.rateMatchingOption == 0]
    print(df_pdsch_125_111215_not_ratematching)
    count_sirnti = len(
        df_pdsch_125_111215_not_ratematching[(df_pdsch_125_111215_not_ratematching.rnti == 65535)])
    count_crnti = len(
        df_pdsch_125_111215_not_ratematching[(df_pdsch_125_111215_not_ratematching.rnti != 65535)])
    df_pdsch_34_1314 = df_pdsch.loc[
        (df_pdsch.slot == 3) | (df_pdsch.slot == 4) | (df_pdsch.slot == 13) | (df_pdsch.slot == 14)]
    # print(df_pdsch_34_1314[df_pdsch_34_1314.rateMatchingOption == 0])
    # print(df_pdsch_34_1314[df_pdsch_34_1314.rateMatchingOption == 1])
    len_df_pdsch_34_1314_not_ratematching = len(df_pdsch_34_1314[df_pdsch_34_1314.rateMatchingOption == 0])
    len_df_pdsch_34_1314_ratematching = len(df_pdsch_34_1314[df_pdsch_34_1314.rateMatchingOption != 0])
    # SpecialSlot
    df_pdsch_7_17 = df_pdsch.loc[(df_pdsch.slot == 7) | (df_pdsch.slot == 17)]
    len_df_pdsch_7_17_not_ratematching = len(df_pdsch_7_17[df_pdsch_7_17.rateMatchingOption == 0])
    print("DL_SI_values", count_sirnti, count_crnti, len_df_pdsch_34_1314_not_ratematching,
          len_df_pdsch_34_1314_ratematching, len_df_pdsch_7_17_not_ratematching)
    if actEnhancedPDSCHSchSplSlot == 1 and adaptretx == 1:
        print("actEnhancedPDSCHSchSplSlot and adaptretx enabled")
        if count_sirnti >= ((50 * count_crnti) / 100) and \
           len_df_pdsch_34_1314_not_ratematching <= 25*len_df_pdsch_34_1314_ratematching/100 and \
           len_df_pdsch_7_17_not_ratematching == 0:
            print("PASS_1- DL_SI", count_sirnti, count_crnti, len_df_pdsch_34_1314_not_ratematching,
                  len_df_pdsch_34_1314_ratematching, len_df_pdsch_7_17_not_ratematching)
            return PASS
    elif actEnhancedPDSCHSchSplSlot == 1 and adaptretx == 0:
        print("Only actEnhancedPDSCHSchSplSlot enabled")
        if count_sirnti >= ((50 * count_crnti) / 100) and \
           len_df_pdsch_34_1314_not_ratematching == 0 and \
           len_df_pdsch_7_17_not_ratematching == 0:
            print("PASS_2- DL_SI", count_sirnti, count_crnti, len_df_pdsch_34_1314_not_ratematching,
                  len_df_pdsch_34_1314_ratematching, len_df_pdsch_7_17_not_ratematching)
            return PASS
    elif actEnhancedPDSCHSchSplSlot == 0 and adaptretx == 0:
        print("Both actEnhancedPDSCHSchSplSlot and adaptretx disabled")
        if count_sirnti >= ((50 * count_crnti) / 100) and \
           len_df_pdsch_34_1314_not_ratematching == 0 and \
           len_df_pdsch_7_17_not_ratematching == 0:    # crosscheck  this condition again
            print("PASS_3- DL_SI", count_sirnti, count_crnti, len_df_pdsch_34_1314_not_ratematching,
                  len_df_pdsch_34_1314_ratematching, len_df_pdsch_7_17_not_ratematching)
            return PASS
    else:
        print("FAIL- DL_SI", count_sirnti, count_crnti, len_df_pdsch_34_1314_not_ratematching,
              len_df_pdsch_34_1314_ratematching, len_df_pdsch_7_17_not_ratematching)
        return FAIL


def check_ratematching(file_name, rnti, slot_option, rnd_flag, tdd_framestructure, iwkfeature):
    """
    This function take parameters such as BIP_log_CSV file,RNTI, slot option, RnD parameter value,
    TDD frame structure, and enabled IWK features from user
    slot_option can be  - DLalone , DL_UL , First_DL_after_UL_slot
    rnd_flag can be - 0 ,1
    TDD_framestructure can be - 1208 , 1070
    IWKFeature can be - Empty list , ccesplit_K1opt, adaptretx, actEnhancedPDSCHSchSplSlot, actDlPaWarmUp
    """
    # Passed argument values are validated
#    print("Arguments : ", slot_option, iwkfeature, tdd_framestructure, rnd_flag, rnti)
    resp_1 = 0
    resp_2 = 0
    resp_3 = 0
    global resp
    if int(rnd_flag) > 1:
        print("RnD flag value passed as an argument is wrong. Supported values are 0 and 1")
        return FAIL
    if len(slot_option) > 3 or len(slot_option) == 0:
        print("Slot option value is wrong.Length of list is ", len(slot_option))
        return FAIL
    # To handle only 1 or 2 options of slot_option is given as argument. At the end final result is set as PASS if all
    # the 3 cases are passed only
    elif len(slot_option) == 2:
        if all(x in slot_option for x in ['DLalone', 'DL_UL']):
            print("Only 'DLalone', 'DL_UL' check")
            resp_1 = 1
        elif all(x in slot_option for x in ['DLalone', 'First_DL_after_UL_slot']):
            print("Only 'DLalone', 'First_DL_after_UL_slot' check")
            resp_3 = 1
        elif all(x in slot_option for x in ['DL_UL', 'First_DL_after_UL_slot']):
            print("Only 'DLalone', 'First_DL_after_UL_slot' check")
            resp_2 = 1
    elif len(slot_option) == 1:
        if all(x in slot_option for x in ['DLalone']):
            print("Only 'DLalone' check")
            resp_1 = 1
            resp_3 = 1
        elif all(x in slot_option for x in ['First_DL_after_UL_slot']):
            print("Only 'First_DL_after_UL_slot' check")
            resp_3 = 1
            resp_2 = 1
        elif all(x in slot_option for x in ['DL_UL']):
            print("Only 'DLalone' check")
            resp_2 = 1
            resp_1 = 1

    for element in iwkfeature:
        print("Element_IWK", element)
        if element == 'ccesplit_K1opt':
            global ccesplit_K1opt
            ccesplit_K1opt = 1
        elif element == 'adaptretx':
            global adaptretx
            adaptretx = 1
        elif element == 'actEnhancedPDSCHSchSplSlot':
            global actEnhancedPDSCHSchSplSlot
            actEnhancedPDSCHSchSplSlot = 1
        elif element == 'actDlPaWarmUp':
            global actDlPaWarmUp
            actDlPaWarmUp = 1
        elif element == 'flag_8322':
            global flag_8322
            flag_8322 = 1

    pd = install_and_import_pandas()
    # Reading converted csv file and formatting it
    data = pd.read_csv(file_name)
    df = pd.DataFrame(data)
    df = df.rename(columns={'_ws.col.info': 'info'})
    df = df.rename(columns={'3gpp.sfn': 'sfn'})
    df = df.rename(columns={'3gpp.slot': 'slot'})
    df = df.rename(columns={'DlData_PdschGrantL1sw.rateMatchingOption': 'rateMatchingOption'})
    df = df.rename(columns={'3gpp.rnti': 'rnti'})
    df = df.rename(columns={'DlData_PdschGrantL1sw.numOfPdschSymbols': 'numOfPdschSymbols'})
    df = df.rename(columns={'DlData_PdschGrantL1sw.startSymbol': 'startSymbol'})
    df[['sfn', 'sfn_ex']] = df['sfn'].str.split(',', expand=True)
    print(df)
    df[['slot', 'slot_ex']] = df['slot'].str.split(',', expand=True)
    print(df)
    df_pdsch = df[df['info'].str.contains("DlData_PdschSendReqL1sw")]
    print(df_pdsch)
    print(df_pdsch.slot)
    # Based on tdd framestructure and slot_option provided respective function is called
    if tdd_framestructure == '1208':
        for element in slot_option:
            print("Element in slot_option", element)
            if element == 'First_DL_after_UL_slot':
                print("Checking 'First_DL_after_UL_slot'")
                resp_1 = check_first_dl_after_ul_slot_1208(df_pdsch, rnd_flag)
            elif element == 'DLalone':
                print("Checking 'DLalone")
                resp_2 = check_dl_slot_1208(df_pdsch)
            elif element == 'DL_UL':
                print("Checking 'DL_UL'")
                resp_3 = check_dl_ul_slot_1208(df_pdsch)
            else:
                print("Wrong slot option provided")
                return FAIL

    elif tdd_framestructure == '1116':
        for element in slot_option:
            print("Element in slot_option", element)
            if element == 'First_DL_after_UL_slot':
                print("Checking 'First_DL_after_UL_slot'")
                resp_1 = check_first_dl_after_ul_slot_1116(df_pdsch, rnd_flag)
            elif element == 'DLalone':
                print("Checking 'DLalone")
                resp_2 = check_dl_slot_1116(df_pdsch)
            elif element == 'DL_UL':
                print("Checking 'DL_UL'")
                resp_3 = check_dl_ul_slot_1116(df_pdsch)
            else:
                print("Wrong slot option provided")
                return FAIL
    if resp_1 == 1 and resp_2 == 1 and resp_3 == 1:
        resp = PASS

    return resp
