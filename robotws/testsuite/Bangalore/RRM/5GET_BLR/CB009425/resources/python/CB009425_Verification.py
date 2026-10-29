import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


class Read_Store_Data:

    def __init__(self, rnti, dire, file_name):
        self.rnti = rnti
        self.dire = dire
        self.harq = self.dire + 'HarqProcessIndex'
        self.UsedMcs = 'rrm' + self.dire.capitalize() + 'UsedMcs'
        self.PropMcs = 'rrm' + self.dire.capitalize() + 'ProposedMcs'
        self.ScaleMcs = 'rrm' + self.dire.capitalize() + 'ScaledMcs'
        self.down_tbSize = self.dire.capitalize() + 'BufBasedDowngradedTbSize'
        self.harqid = AutoDict()
        self.file_name = file_name
        self.read_file(self.file_name)
        self.var = ''

    def read_file(self, file_name):
        with open(self.file_name) as csv_file:
            self.csv_reader = csv.DictReader(csv_file)
            self.header = self.csv_reader.fieldnames
            self.update_ue()

    def update_ue(self):

        if 'numOfVoNrPrb' in self.header:
            self.var = 'numOfVoNrPrb'
        elif 'numOf5qi1Prb' in self.header:
            self.var = 'numOf5qi1Prb'

        for line in self.csv_reader:
            if 'type' in self.header and line['type'] == self.dire + 'FdSchedData':
                if int(line['rnti']) == int(self.rnti):
                    if float(line[self.var]) > 0:
                        try:
                            self.harqid['harqid=' + line[self.harq]][self.var].append(line[self.var])
                            self.harqid['harqid=' + line[self.harq]]['numOfPrb'].append(line['numOfPrb'])
                            self.harqid['harqid=' + line[self.harq]]['mcsTable'].append(line['mcsTable'])
                            self.harqid['harqid=' + line[self.harq]]['tbSize'].append(line['tbSize'])
                            self.harqid['harqid=' + line[self.harq]][self.down_tbSize].append(line[self.down_tbSize])
                            self.harqid['harqid=' + line[self.harq]][self.UsedMcs].append(line[self.UsedMcs])
                            self.harqid['harqid=' + line[self.harq]][self.PropMcs].append(line[self.PropMcs])
                            self.harqid['harqid=' + line[self.harq]][self.ScaleMcs].append(line[self.ScaleMcs])
                            self.harqid['harqid=' + line[self.harq]]['effectiveCodeRate'].append(
                                line['effectiveCodeRate'])
                            if self.dire == 'ul':
                                self.harqid['harqid=' + line[self.harq]]['txNumber'].append([line['txNumber']])
                            else:
                                self.harqid['harqid=' + line[self.harq]]['txNumber'].append(
                                    [line['txNumber'], line['ackNack']])
                        except AttributeError:
                            self.harqid['harqid=' + line[self.harq]][self.var] = [line[self.var]]
                            self.harqid['harqid=' + line[self.harq]]['numOfPrb'] = [line['numOfPrb']]
                            self.harqid['harqid=' + line[self.harq]]['mcsTable'] = [line['mcsTable']]
                            self.harqid['harqid=' + line[self.harq]]['tbSize'] = [line['tbSize']]
                            self.harqid['harqid=' + line[self.harq]][self.down_tbSize] = [line[self.down_tbSize]]
                            self.harqid['harqid=' + line[self.harq]][self.UsedMcs] = [line[self.UsedMcs]]
                            self.harqid['harqid=' + line[self.harq]][self.PropMcs] = [line[self.PropMcs]]
                            self.harqid['harqid=' + line[self.harq]][self.ScaleMcs] = [line[self.ScaleMcs]]
                            self.harqid['harqid=' + line[self.harq]]['effectiveCodeRate'] = [line['effectiveCodeRate']]
                            if self.dire == 'ul':
                                self.harqid['harqid=' + line[self.harq]]['txNumber'] = [line['txNumber']]
                            else:
                                self.harqid['harqid=' + line[self.harq]]['txNumber'] = [[line['txNumber'],
                                                                                         line['ackNack']]]
        print(self.harqid)


class validate_coding_gain_Target_Bler(Read_Store_Data):

    def __init__(self, rnti, dire, file_name, actVoNRInc=True,
                 numTxPrb=2, maxPrbsVoNR=32,
                 stepUpNumPrbs=2,
                 dlMcsDropLimitForVoNR=2):

        Read_Store_Data.__init__(self, rnti, dire, file_name)
        self.res_64_qam = [29, 30, 31]
        self.res_256_qam = [28, 29, 30, 31]
        self.actVoNRInc = actVoNRInc
        self.numTxPrb = numTxPrb
        self.maxPrbsVoNR = maxPrbsVoNR
        self.stepUpNumPrbs = stepUpNumPrbs
        self.McsDropLim = dlMcsDropLimitForVoNR

    def verify_drop_mcs(self):
        flag_mcs_drop_limit = 0
        for key in self.harqid:
            for mcs in self.harqid[key][self.ScaleMcs]:
                indx = self.harqid[key][self.ScaleMcs].index(mcs)
                if 0 < self.McsDropLim < 28 and float(self.harqid[key]["txNumber"][indx][0]) == 1:
                    if (float(mcs) - self.McsDropLim) <= float(self.harqid[key][self.UsedMcs][indx]) <= float(mcs):
                        print("UsedMcs {0} is within range min {1} and max {2} for {3}"
                              .format(self.harqid[key][self.UsedMcs][indx],
                                      float(mcs) - self.McsDropLim, mcs, key))
                        flag_mcs_drop_limit |= 1
                    else:
                        print("UsedMcs {0} is not within range min {1} and max {2} for {3}"
                              .format(self.harqid[key][self.UsedMcs][indx],
                                      float(mcs) - self.McsDropLim, mcs, key))
                        flag_mcs_drop_limit |= 2
                elif self.McsDropLim == 0 and float(self.harqid[key]["txNumber"][indx][0]) == 1:
                    if (float(self.harqid[key][self.UsedMcs][indx]) == float(mcs)):
                        print("UsedMcs {0}is equal to ScaledMcs{1} for {2}"
                              .format(self.harqid[key][self.UsedMcs][indx], mcs, key))
                        flag_mcs_drop_limit |= 4
                    else:
                        print("UsedMcs {0} is not equal to ScaledMcs-{1} for {2}"
                              .format(self.harqid[key][self.UsedMcs][indx], mcs, key))
                        flag_mcs_drop_limit |= 8
                elif self.McsDropLim == 28 and float(self.harqid[key]["txNumber"][indx][0]) == 1:
                    # Feature Disabled
                    if (0 <= float(self.harqid[key][self.UsedMcs][indx]) <= float(mcs)
                            and float(self.harqid[key]["txNumber"][indx][0]) == 1):
                        print("As dlMcsDropLimitForVoNR-{0}, rrmDlUsedMcs-{1} can drop to"
                              " any value {2} from rrmDlUsedMcs-{3} for {4}"
                              .format(self.McsDropLim, self.harqid[key][self.UsedMcs][indx],
                                      (float(mcs) - float(self.harqid[key][self.UsedMcs][indx])), mcs, key))
                        flag_mcs_drop_limit |= 16
                self.harqid[key]['flag'] = flag_mcs_drop_limit

    def verify_enhanced_retrans(self):
        ini_num_prb = 0
        enh_num_prb = 0
        ini_vonr_prb = 0
        enh_vonr_prb = 0
        ini_umcs_prb = 0
        enh_umcs_prb = 0
        ini_qam = ''
        enh_qam = ''
        flag_enh_retx = 0

        for key in self.harqid:
            if self.actVoNRInc:
                if ['1.0', 'NACK'] in self.harqid[key]['txNumber']:
                    index_list = self.get_index_positions(self.harqid[key]['txNumber'], ['1.0', 'NACK'])
                    for i in index_list:
                        try:
                            if [str(float(1 + self.numTxPrb)), 'NACK'] in self.harqid[key]['txNumber']:
                                ini_num_prb = float(self.harqid[key]['numOfPrb'][i])
                                enh_num_prb = float(self.harqid[key]['numOfPrb'][i + self.numTxPrb])
                                ini_vonr_prb = float(self.harqid[key][self.var][i])
                                enh_vonr_prb = float(self.harqid[key][self.var][i + self.numTxPrb])
                                ini_umcs_prb = float(self.harqid[key][self.UsedMcs][i])
                                enh_umcs_prb = float(self.harqid[key][self.UsedMcs][i + self.numTxPrb])
                                ini_qam = self.harqid[key]['mcsTable'][i]
                                enh_qam = self.harqid[key]['mcsTable'][i + self.numTxPrb]

                                if ini_num_prb >= self.maxPrbsVoNR and ini_umcs_prb == enh_umcs_prb:
                                    print("No extra PRB will be allocated as in_num_prb {0} "
                                          "is >= maxPrbsVoNR {1} for {2} so initial mcs {3}"
                                          " and used mcs {4} remain same"
                                          .format(ini_num_prb, self.maxPrbsVoNR, key, ini_umcs_prb, enh_umcs_prb))
                                    flag_enh_retx |= 1
                                else:
                                    vonr_prb_diff = enh_vonr_prb - ini_vonr_prb
                                    if (ini_num_prb * self.stepUpNumPrbs == enh_num_prb and
                                            (ini_vonr_prb * self.stepUpNumPrbs == enh_vonr_prb or
                                             ini_vonr_prb == enh_vonr_prb)):
                                        print('Vonr prb is incremented by factor of stepUpNumPrbs for %s' % key)
                                        if ini_qam == enh_qam != 'QAM256' and enh_umcs_prb in self.res_64_qam:
                                            print("Reserved MCS {} is assigned from 64QAM after PRB doubling"
                                                  " after {} steps for {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag_enh_retx |= 2

                                        elif ini_qam == enh_qam == 'QAM256' and enh_umcs_prb in self.res_256_qam:
                                            print("Reserved MCS {} is assigned from 256QAM after PRB doubling"
                                                  " after {} steps for {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag_enh_retx |= 4
                                        else:
                                            print("reserved MCS not assigned after PRB Doubling")
                                            flag_enh_retx |= 8

                                    elif (enh_num_prb / ini_num_prb < self.stepUpNumPrbs and
                                          vonr_prb_diff >= 0 and int(enh_num_prb) == self.maxPrbsVoNR):
                                        print("Vonr prb is incremented but not doubled since coding"
                                              " gain prb is limited for %s" % key)
                                        if ini_qam == enh_qam != 'QAM256' and enh_umcs_prb in self.res_64_qam:
                                            print("Reserved MCS {} is assigned from 64QAM after PRB doubling"
                                                  " after {} steps for {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag_enh_retx |= 16
                                        elif ini_qam == enh_qam == 'QAM256' and enh_umcs_prb in self.res_256_qam:
                                            print("Reserved MCS {} is assigned from 256QAM after PRB doubling"
                                                  " after {} steps for {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag_enh_retx |= 32
                        except IndexError:
                            pass
                    self.harqid[key]['flag'] = flag_enh_retx
            else:
                if (ini_num_prb == enh_num_prb and ini_vonr_prb == enh_vonr_prb and
                        ini_umcs_prb == enh_umcs_prb and (enh_umcs_prb not in self.res_64_qam)
                        or (enh_umcs_prb not in self.res_256_qam)):
                    print("No change in MCS and PRB allocation actVoNRIncCodingGain is Disabled")
                    flag_enh_retx |= 64
                else:
                    flag_enh_retx |= 128
                self.harqid[key]['flag'] = flag_enh_retx

    def get_index_positions(self, list_of_elems, element):
        """ Returns the indexes of all occurrences of give element in
        the list- listOfElements """
        index_pos_list = []
        index_pos = 0
        while True:
            try:
                # Search for item in list from indexPos to the end of list
                index_pos = list_of_elems.index(element, index_pos)
                # Add the index position in list
                index_pos_list.append(index_pos)
                index_pos += 1
            except ValueError as e:
                break
        return index_pos_list


class validate_actUlMinTbs_enable(Read_Store_Data):

    def __init__(self, rnti, dire, file_name,
                 actUlMinTbsForVoNR=True,
                 minPuschPrbForMinTbsVoNR=2,
                 ulMinTbsForVoNR=32
                 ):
        Read_Store_Data.__init__(self, rnti, dire, file_name)
        self.actUlMinTbsForVoNR = actUlMinTbsForVoNR
        self.minPuschPrbForMinTbsVoNR = minPuschPrbForMinTbsVoNR
        self.ulMinTbsForVoNR = ulMinTbsForVoNR

    def verify_ul(self):
        flag_ul = 0
        for key in self.harqid:
            for prb in self.harqid[key]['numOfPrb']:
                # if self.actUlMinTbsForVoNR:
                idx = 0
                if self.actUlMinTbsForVoNR:
                    # for prb in self.harqid['numOfPrb']:
                    if (float(prb) <= self.minPuschPrbForMinTbsVoNR and
                            float(self.harqid[key]['tbSize'][idx]) >= self.ulMinTbsForVoNR):
                        print("Assigned PRB {0} and tbSize {1} are within limit defined by"
                              " minPuschPrbForMinTbsVoNR {2} and ulMinTbsForVoNR {3}"
                              .format(prb, self.harqid[key]['tbSize'][idx],
                                      self.minPuschPrbForMinTbsVoNR, self.ulMinTbsForVoNR))
                        flag_ul |= 1
                    else:
                        print("Feature activation failed.Assigned PRB {0} and tbSize {1} are not within "
                              " limit defined by minPuschPrbForMinTbsVoNR {2} and ulMinTbsForVoNR {3}"
                              .format(prb, self.harqid[key]['tbSize'][idx],
                                      self.minPuschPrbForMinTbsVoNR, self.ulMinTbsForVoNR))
                        flag_ul |= 2
                    idx += 1
                else:
                    if ((int(prb) >= self.minPuschPrbForMinTbsVoNR
                         or int(prb) < self.minPuschPrbForMinTbsVoNR)
                            and (int(self.harqid[key]['tbSize'][idx]) <= self.ulMinTbsForVoNR
                                 or int(self.harqid[key]['tbSize'][idx]) > self.ulMinTbsForVoNR)):
                        print("Feature Disabled assigned PRB {0} and tbSize {1} are not within limit defined by"
                              " minPuschPrbForMinTbsVoNR {2} and ulMinTbsForVoNR {3}"
                              .format(prb, self.harqid[key]['tbSize'][idx],
                                      self.minPuschPrbForMinTbsVoNR, self.ulMinTbsForVoNR))
                        flag_ul |= 4
                    idx += 1
                self.harqid[key]['flag'] = flag_ul


class verify_mapped_mcs_vs_used_mcs(Read_Store_Data):

    def __init__(self, rnti, dire, file_name):
        Read_Store_Data.__init__(self, rnti, dire, file_name)
        self.qam64table = {0: 0.11719, 1: 0.15332, 2: 0.18848, 3: 0.24512, 4: 0.30078, 5: 0.37012,
                           6: 0.43848, 7: 0.51367, 8: 0.58789, 9: 0.66309, 10: 0.33203, 11: 0.36914,
                           12: 0.42383, 13: 0.47852, 14: 0.54004, 15: 0.60156, 16: 0.64258, 17: 0.42773,
                           18: 0.45508, 19: 0.50488, 20: 0.55371, 21: 0.60156, 22: 0.65039, 23: 0.70215,
                           24: 0.75391, 25: 0.80273, 26: 0.85254, 27: 0.88867, 28: 0.92578}

        self.qam256table = {0: 0.11719, 1: 0.18848, 2: 0.30078, 3: 0.43848, 4: 0.58789, 5: 0.36914,
                            6: 0.42383, 7: 0.47852, 8: 0.54004, 9: 0.60156, 10: 0.64258, 11: 0.45508,
                            12: 0.50488, 13: 0.55371, 14: 0.60156, 15: 0.65039, 16: 0.70215, 17: 0.75391,
                            18: 0.80273, 19: 0.85254, 20: 0.6665, 21: 0.69434, 22: 0.73633, 23: 0.77832,
                            24: 0.82129, 25: 0.86426, 26: 0.89502, 27: 0.92578}

    def map_effCodeRate_qam_table(self):
        mcs_flag = 0
        for key in self.harqid:
            for tx in self.harqid[key]['txNumber']:
                idx = 0
                if float(tx[0]) == 1:
                    value = float(self.harqid[key]['effectiveCodeRate'][idx])
                    if self.harqid[key]['mcsTable'][idx] == 'QAM256':
                        map_mcs, map_code = min(self.qam256table.items(), key=lambda x: abs(value - x[1]))
                    else:
                        map_mcs, map_code = min(self.qam64table.items(), key=lambda x: abs(value - x[1]))

                    if float(self.harqid[key][self.UsedMcs][idx]) == map_mcs:
                        print("mapped mcs-{0} matched with used mcs-{1} for {2}".
                              format(map_mcs, self.harqid[key][self.UsedMcs][idx], key))
                        mcs_flag |= 1
                    else:
                        print("mapped mcs-{0} not matched with used mcs-{1} for {2}".
                              format(map_mcs, self.harqid[key][self.UsedMcs][idx], key))
                        mcs_flag |= 2
                    idx += 1
            self.harqid[key]['flag'] = mcs_flag


def find_max_tbsize_usedmcs(rnti, dire, file_name):
    obj = Read_Store_Data(rnti, dire, file_name)
    max_tbs = 0
    max_usedmcs = 0
    for key in obj.harqid:
        tmp_tb = max([eval(i) for i in obj.harqid[key]['tbSize']])
        if tmp_tb > max_tbs:
            max_tbs = tmp_tb
            idx = obj.harqid[key]['tbSize'].index(str(max_tbs))
            max_usedmcs = int(float(obj.harqid[key][obj.UsedMcs][idx]))
    return max_usedmcs, max_tbs


def verify(ue_obj, scena):
    flag = 0
    for harqid in ue_obj.harqid:
        try:
            exec_sce = ue_obj.harqid[harqid]['flag'] & scena
            if exec_sce == scena:
                print("Got expected scenario for ", harqid)
                flag |= 1
            else:
                print("Feature not worked for  ", harqid)
                flag |= 0
        except TypeError:
            print("expected scenario is not achieved for ", harqid)
            flag |= 0
    if flag == 0:
        return 'Fail'
    else:
        return 'Pass'


def mcs_drop_verify(rnti, file_name, dlMcsDropLimitForVoNR=2, tc_scen=0):
    obj = validate_coding_gain_Target_Bler(rnti, 'dl', file_name, dlMcsDropLimitForVoNR=dlMcsDropLimitForVoNR)
    obj.verify_drop_mcs()
    return verify(obj, tc_scen)


def enh_retx_verify(rnti, file_name, actVoNRInc=True, numTxPrb=2, maxPrbsVoNR=32, stepUpNumPrbs=2, tc_scen=0):
    obj = validate_coding_gain_Target_Bler(rnti, 'dl', file_name, actVoNRInc, numTxPrb, maxPrbsVoNR, stepUpNumPrbs)
    obj.verify_enhanced_retrans()
    return verify(obj, tc_scen)


def min_tbs_prb_verify(rnti, file_name, actUlMinTbsForVoNR=True, minPuschPrbForMinTbsVoNR=2,
                       ulMinTbsForVoNR=32, tc_scen=0):
    obj = validate_actUlMinTbs_enable(rnti, 'ul', file_name, actUlMinTbsForVoNR, minPuschPrbForMinTbsVoNR,
                                      ulMinTbsForVoNR)
    obj.verify_ul()
    return verify(obj, tc_scen)


def map_code_rate_with_mcs(rnti, dire, file_name, tc_scen=0):
    obj = verify_mapped_mcs_vs_used_mcs(rnti, dire, file_name)
    obj.map_effCodeRate_qam_table()
    return verify(obj, tc_scen)
