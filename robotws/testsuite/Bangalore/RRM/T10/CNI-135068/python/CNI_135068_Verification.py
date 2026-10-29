import subprocess
import pkgutil
import importlib
import os
import math


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


def is_tkinter_installed():
    return bool(pkgutil.find_loader('tkinter'))


def install_and_import_tkinter():
    print("tkinter library installation")
    if not is_tkinter_installed():
        install_package('tkinter')
    return importlib.import_module('tkinter')


def merge_multiple_csv(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_' + dire + '_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_' + dire + '_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(pd.read_csv(os.path.join(filepath, file), low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)


def syslog_search(filename, search_strings):
    try:
        with open(filename, 'r') as file:
            lines = file.readlines()
        wrn_results = []
        err_results = []
        for line in lines:
            for search_string in search_strings:
                if search_string in line:
                    if search_string == 'WRN/':
                        wrn_results.append(line)
                    elif search_string == 'ERR/':
                        err_results.append(line)

        # Export results to CSV file
        directory_path, file_path = os.path.split(filename)
        txt_file_path = os.path.join(directory_path, 'filtered_syslog.txt')
        print("txt_file_path: ", txt_file_path)
        with open(txt_file_path, 'w') as filtered_syslog:
            if wrn_results:
                filtered_syslog.write('Results for \'WRN/\':\n')
                for line in wrn_results:
                    filtered_syslog.write(line.strip() + '\n')
            else:
                filtered_syslog.write('No \'WRN/\' results found.\n')

            if err_results:
                filtered_syslog.write('Results for \'ERR/\':\n')
                for line in err_results:
                    filtered_syslog.write(line.strip() + '\n')
            else:
                filtered_syslog.write('No \'ERR/\' results found.\n')

    except FileNotFoundError:
        print("File not found:", filename)


def check_entry_exit(rnti, dfrdm, dfsch,
                     shortTermBlerThreshold1,
                     shortTermBlerThreshold2,
                     rdLowCqiThresholdRank1,
                     rdLowCqiThresholdRank2,
                     rdLowCqiThresholdRank3,
                     rdLowCqiThresholdRank4,
                     rdHighCqiThresholdRank1,
                     rdHighCqiThresholdRank2,
                     rdHighCqiThresholdRank3,
                     rdHighCqiThresholdRank4
                     ):
    harqlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

    for idx in range(len(dfrdm)):
        print(len(dfrdm), idx)
        sfn = dfrdm.iloc[idx]['sfn']
        slot = dfrdm.iloc[idx]['slot']
        hsfn = dfrdm.iloc[idx]['hfnTickCount']
        rank = dfrdm.iloc[idx]['rank']
        bler = dfrdm.iloc[idx]['bler'] * 100
        corrcqi = dfrdm.iloc[idx]['correctedCQI']
        state = dfrdm.iloc[idx]['rankDowngradeState']

        # get location of sfn & slot where UE enters or exits rank downgrade mode
        x = dfsch[(dfsch['hfnTickCount'] == hsfn) & (dfsch['sfn'] == sfn) & (dfsch['slot'] == slot)]
        locn = dfsch.index.get_loc(x.index[0])
        harqid = dfsch.iloc[locn]['dlHarqProcessIndex']
        # required data of previous harq with txNumber=1
        numoflayer = dfsch.iloc[locn - 1]['numOfLayers']
        rrmcorravgcqi = dfsch.iloc[locn - 1]['rrmCorrAvgCqi']
        harq_prev_slot = dfsch.iloc[locn - 1]['dlHarqProcessIndex']
        if idx == 0:
            # Entry Validation

            print('samik', numoflayer, rrmcorravgcqi, harq_prev_slot)
            if bler >= shortTermBlerThreshold1 and corrcqi <= rdLowCqiThresholdRank1:
                if rank == numoflayer == 'RANK1' and corrcqi == rrmcorravgcqi and \
                        state == 'UEENTERRANKDOWNGSTATE' and harq_prev_slot == harqlist[int(harqid - 1)]:
                    print("UE-%s rank downgraded to %s" % (rnti, rank))
                else:
                    print("UE-%s not entered in %s State" % (rnti, rank))
                    return 'Fail'
            elif bler >= shortTermBlerThreshold1 and corrcqi <= rdLowCqiThresholdRank2:
                if rank == numoflayer == 'RANK2' and corrcqi == rrmcorravgcqi and \
                        state == 'UEENTERRANKDOWNGSTATE' and harq_prev_slot == harqlist[int(harqid - 1)]:
                    print("UE-%s rank downgraded to %s" % (rnti, rank))
                else:
                    print("UE-%s not entered in %s State" % (rnti, rank))
                    return 'Fail'
            else:
                print("reason unkown entry", rnti, idx)
                return 'Fail'
        else:
            # Exit Validation
            if bler <= shortTermBlerThreshold2 and corrcqi >= rdHighCqiThresholdRank1:
                if rank == numoflayer == 'RANK1' and rrmcorravgcqi <= corrcqi and \
                        state == 'UEEXITRANKDOWNGSTATE' and harq_prev_slot == harqlist[int(harqid - 1)]:
                    print("UE-%s exits rank downgrade mode with %s" % (rnti, rank))
                else:
                    print("UE-%s not able to exit from %s State" % (rnti, rank))
                    return 'Fail'
            elif bler <= shortTermBlerThreshold2 and corrcqi >= rdHighCqiThresholdRank2:
                if rank == numoflayer == 'RANK2' and rrmcorravgcqi <= corrcqi and \
                        state == 'UEEXITRANKDOWNGSTATE' and harq_prev_slot == harqlist[int(harqid - 1)]:
                    print("UE-%s exits rank downgrade mode with %s" % (rnti, rank))
                else:
                    print("UE-%s not able to exit from %s State" % (rnti, rank))
                    return 'Fail'
            else:
                print("reason unkown exit", rnti, idx)
                return 'Fail'
    return 'Pass'


def verify_rankdowngrade(filepath, crnti,
                         shortTermBlerThreshold1,
                         shortTermBlerThreshold2,
                         rdLowCqiThresholdRank1,
                         rdLowCqiThresholdRank2,
                         rdLowCqiThresholdRank3,
                         rdLowCqiThresholdRank4,
                         rdHighCqiThresholdRank1,
                         rdHighCqiThresholdRank2,
                         rdHighCqiThresholdRank3,
                         rdHighCqiThresholdRank4,
                         ):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)

    # Check dlLaForcedRankDowng(lfrd) event is present or not
    lfrd = df[df['type'] == 'dlLaForcedRankDowng']
    if len(lfrd) == 0 or shortTermBlerThreshold1 == 0:
        print("Rank Downgrade Not Happend. check shortTermBlerThreshold1 should be > 0")
        return 'Fail'
    elif len(lfrd) == 1 or shortTermBlerThreshold2 == 0:
        print("either UEs are released or GBR or HR DRB added in between.Check log or robot script")
        print('lfrd with length 1', lfrd)

    # get rnti list which were entered in Rank Downgrade mode(rdm)
    rnti_rdm = set(lfrd['rnti'])
    print("UEs-{0} met rank downgrade criteria".format(rnti_rdm))

    # Validate entry and exit criteria
    for rnti in rnti_rdm:
        df1 = lfrd[lfrd['rnti'] == rnti].reset_index()
        sch_rnti = df[(df['type'] == 'dlFdSchedData') & (df['rnti'] == rnti) & (df['txNumber'] == 1)].reset_index()
        # Validation of Entry criteria
        result = check_entry_exit(rnti, df1, sch_rnti,
                                  shortTermBlerThreshold1,
                                  shortTermBlerThreshold2,
                                  rdLowCqiThresholdRank1,
                                  rdLowCqiThresholdRank2,
                                  rdLowCqiThresholdRank3,
                                  rdLowCqiThresholdRank4,
                                  rdHighCqiThresholdRank1,
                                  rdHighCqiThresholdRank2,
                                  rdHighCqiThresholdRank3,
                                  rdHighCqiThresholdRank4,
                                  )
        if result != 'Pass':
            return 'Fail'

        # check 5QI drbs attached to UE
        keylist = crnti.keys()
        dummy = [int(i) for i in keylist]
        print('dummy==', dummy)
        rnti_not_ent = set(dummy) - rnti_rdm
        print("RNTI not entered rank downgrade mode", rnti_not_ent)
        for key in rnti_not_ent:
            # get length of bearer list. each index indicates
            # 1 DRB property
            gbrflag = 0
            hrflag = 0
            brflag = 0
            df2 = df[(df['type'] == 'dlFdSchedData') & (df['rnti'] == int(key))].reset_index()
            lamode = set(df2['laMode'])
            drblist = crnti[str(key)]
            for idx in range(len(drblist)):
                fiveqi = crnti[str(key)][idx][0].split('-')[1].strip()
                drbid = crnti[str(key)][idx][1].strip()
                print('fiveqi-', fiveqi, 'drbid-', drbid)

                if (1 <= int(fiveqi) < 5) or (71 <= int(fiveqi) <= 76):
                    print("UE-%s having DRB-%s attached with GBR 5QI-%s" % (str(key), drbid, fiveqi))
                    gbrflag += 1
                else:
                    # check Non GBR DRB is BR DRB or not.
                    if len(lamode) == 1 and 'BASICRELIABILITY' in lamode:
                        print("UE-%s having DRB-%s attached with BR Non GBR 5QI-%s" % (str(key), drbid, fiveqi))
                        brflag += 1
                    else:
                        print("UE-%s having DRB-%s attached with HR Non GBR 5QI-%s" % (str(key), drbid, fiveqi))
                        hrflag += 1
            if gbrflag >= 1 and brflag >= 0 and hrflag >= 0:
                print("CRNTI-%s has GBR 5QI.Rank Downgrade would not Happen" % key)
            elif gbrflag == 0 and brflag >= 0 and hrflag >= 1:
                print("CRNTI-%s has HR Non GBR DRB.Rank Downgrade would not Happen" % key)
            else:
                print("Failure-CRNTI-% GBR count-%s BR DRB count-%s HR DRB Count-%s" % (key, gbrflag, brflag, hrflag))
                return 'Fail'
    return 'Pass'


def verify_rrmdeltacqi_handin(filepath, crnti, targetcell, deltaCqiOffsetAdjHo):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)
    crnti_list = crnti.keys()
    for rnti in crnti_list:
        gbrflag = 0
        hrflag = 0
        brflag = 0

        drblist = crnti[str(rnti)]
        df1 = df[(df['type'] == 'dlLaDeltaCqiArray') & (df['physCellId'] == targetcell)
                 & (df['rnti'] == int(rnti))].reset_index()
        df2 = df[(df['type'] == 'dlFdSchedData') & (df['physCellId'] == targetcell)
                 & (df['rnti'] == int(rnti))].reset_index()
        deltacqi = df1['rrmDeltaCqi'].iloc[0]
        harqFb = df1['harqFb'].iloc[0]
        print("harqFb", harqFb)
        lamode = set(df2['laMode'])
        print('deltacqi-', deltacqi)

        for idx in range(len(drblist)):
            fiveqi = crnti[str(rnti)][idx][0].split('-')[1].strip()
            drbid = crnti[str(rnti)][idx][1].strip()
            print('fiveqi-', fiveqi, 'drbid-', drbid)
            if (1 <= int(fiveqi) < 5) or (71 <= int(fiveqi) <= 76):
                print("UE-%s having DRB-%s attached with GBR 5QI-%s" % (str(rnti), drbid, fiveqi))
                gbrflag += 1
            else:
                # check Non GBR DRB is BR DRB or not.
                if len(lamode) == 1 and 'BASICRELIABILITY' in lamode:
                    print("UE-%s having DRB-%s attached with BR Non GBR 5QI-%s" % (str(rnti), drbid, fiveqi))
                    brflag += 1

                else:
                    print("UE-%s having DRB-%s attached with HR Non GBR 5QI-%s" % (str(rnti), drbid, fiveqi))
                    hrflag += 1
        if gbrflag >= 1 and brflag >= 0 and hrflag >= 0:
            if math.isclose(deltacqi, 0.0, abs_tol=0.1):
                print("For UE-%s no additional delta CQI applied due to presence of GBR DRB" % rnti)
            else:
                print("Failure-For UE-%s additional delta CQI applied even though presence of GBR DRB" % rnti)
                return 'Fail'
        elif gbrflag == 0 and brflag >= 1 and hrflag == 0:
            df3 = df[(df['type'] == 'laIniDelta')]
            laIniDelta = df3['iniDelta'].iloc[-1]
            print("laIniDelta", laIniDelta)
            deltaCqiPost = laIniDelta + (-1) * deltaCqiOffsetAdjHo
            print("Post applying deltaCqiOffsetAdjHo resulting rrmDeltaCqi-%s", deltaCqiPost)
            if (deltacqi - deltaCqiPost) >= 0:
                print("For UE-%s additional delta CQI applied by amount-%s on BR Non-GBR 5QI DRB" %
                      (rnti, (deltacqi - deltaCqiPost)))
            else:
                print("Failure-For UE-%s additional delta CQI applied by amount-%s on BR Non-GBR 5QI DRB" %
                      (rnti, (deltacqi - deltaCqiPost)))
                return 'Fail'
        elif gbrflag == 0 and brflag >= 1 and hrflag >= 1:
            # assumption is NIDD param dllaIniDeltaCqiHR not equal to deltaCqiOffsetAdjHo
            # dllaIniDeltaCqiHR value will be close to value set in Webem
            if deltacqi != (0 - deltaCqiOffsetAdjHo):
                print("For UE-%s additional delta CQI not applied on HR Non-GBR DRB" % rnti)
            else:
                print("Failure-For UE-% additional delta CQI not applied on BR Non-GBR 5QI DRB" % rnti)
                return 'Fail'

    return 'Pass'


def verify_low_se_region(filepath, crnti, targetbler,
                         sethrtargetblerreduct,
                         dlladeltacqistepdown=0.25,
                         qam256=False):
    # This code only supports UE with multiple BR Non GBR DRB
    # No check is added for GRB or HR DRB due to log size

    pd = install_and_import_pandas()
    qam64table = {0: 0.2344, 1: 0.3066, 2: 0.377, 3: 0.4902, 4: 0.6016, 5: 0.7402,
                  6: 0.877, 7: 1.0273, 8: 1.1758, 9: 1.3262, 10: 1.3281, 11: 1.4766,
                  12: 1.6953, 13: 1.9141, 14: 2.1602, 15: 2.4063, 16: 2.5703,
                  17: 2.5664, 18: 2.7305, 19: 3.0293, 20: 3.3223, 21: 3.6094,
                  22: 3.9023, 23: 4.2129, 24: 4.5234, 25: 4.8164, 26: 5.1152, 27: 5.332, 28: 5.5547}

    qam256table = {0: 0.2344, 1: 0.377, 2: 0.6016, 3: 0.877, 4: 1.1758, 5: 1.4766,
                   6: 1.6953, 7: 1.9141, 8: 2.1602, 9: 2.4063, 10: 2.5703, 11: 2.7305,
                   12: 3.0293, 13: 3.3223, 14: 3.6094, 15: 3.9023, 16: 4.2129,
                   17: 4.5234, 18: 4.8164, 19: 5.1152, 20: 5.332, 21: 5.5547,
                   22: 5.8906, 23: 6.2266, 24: 6.5703, 25: 6.9141, 26: 7.1602, 27: 7.4063}

    usemcstable = {}

    slotlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    df = pd.read_csv(filepath, low_memory=False)
    crntilist = crnti.keys()

    stepuplowse = (dlladeltacqistepdown * 1000 * (targetbler / (100 - targetbler))) / 1000
    stepuplowse = math.floor(stepuplowse * 1000) / 1000.0
    rangestepup = stepuplowse + 0.001
    print('stepuplowse-', stepuplowse)

    for rnti in crntilist:
        df1 = df[(df['rnti'] == int(rnti)) & (df['type'] == 'dlLaDeltaCqiArray')].reset_index()
        print('df1', df1)
        df1['diffrrmDeltaCqi'] = df1['rrmDeltaCqi'].diff()
        print('diffrrmDeltaCqi', df1['diffrrmDeltaCqi'])
        cqilowse = df1.loc[(stepuplowse <= df1['diffrrmDeltaCqi'])
                           & (df1['diffrrmDeltaCqi'] < rangestepup)].reset_index()
        print('cqilowse', cqilowse)
        if len(cqilowse) == 0:
            print("UE-%s not entered Low SE region or Feature not working" % rnti)
            return 'Fail'
        for i in range(10):
            hsfn = cqilowse['hfnTickCount'].iloc[i]
            sfn = cqilowse['sfn'].iloc[i]
            slot = cqilowse['slot'].iloc[i]
            harq = cqilowse['dlHarqProcessIndex'].iloc[i]

            # to get dlFdSchedData date subtract 4 from slot for same HARQ
            sfn_sch = 0
            if int(slot) - 4 < 0:
                sfn_sch = sfn - 1
            else:
                sfn_sch = sfn

            df2 = df[(df['rnti'] == int(rnti)) & (df['type'] == 'dlFdSchedData') & (df['hfnTickCount'] == hsfn) &
                     (df['sfn'] == sfn_sch) & (df['slot'] == slotlist[int(slot) - 4]) & (
                             df['dlHarqProcessIndex'] == harq)]

            print('df2', df2)
            rank = int(df2['numOfLayers'].iloc[0].split('RANK')[1])
            print('used rank', rank)
            mcs = df2['rrmDlProposedMcs'].iloc[0]
            print('rrmDlProposedMcs', mcs)
            mcstable = df2['mcsTable'].iloc[0]
            if mcstable == 'QAM64':
                usemcstable = qam64table
            else:
                usemcstable = qam256table

            calse = rank * float(usemcstable[int(mcs)])
            print("Calculated SE-%s", calse)
            if calse > sethrtargetblerreduct:
                print("UE-% entered Low SE region even though calculate se %s > sethrtargetblerreduct-%s"
                      % (rnti, calse, sethrtargetblerreduct))
                return 'Fail'
    return 'Pass'
