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

    def read_file(self, file_name):
        with open(self.file_name) as csv_file:
            self.csv_reader = csv.DictReader(csv_file)
            self.header = self.csv_reader.fieldnames
            self.update_ue()

    def update_ue(self):
        for line in self.csv_reader:
            if 'type' in self.header and line['type'] == self.dire + 'FdSchedData':
                if int(line['rnti']) == int(self.rnti):
                    if float(line['numOf5qi1Prb']) > 0:
                        try:
                            self.harqid['harqid=' + line[self.harq]]['numOf5qi1Prb'].append(line['numOf5qi1Prb'])
                            self.harqid['harqid=' + line[self.harq]]['txNumber'].append(
                                [line['txNumber'], line['ackNack']])
                            self.harqid['harqid=' + line[self.harq]]['numOfPrb'].append(line['numOfPrb'])
                            self.harqid['harqid=' + line[self.harq]]['mcsTable'].append(line['mcsTable'])
                            self.harqid['harqid=' + line[self.harq]]['tbSize'].append(line['tbSize'])
                            self.harqid['harqid=' + line[self.harq]][self.down_tbSize].append(line[self.down_tbSize])
                            self.harqid['harqid=' + line[self.harq]][self.UsedMcs].append(line[self.UsedMcs])
                            self.harqid['harqid=' + line[self.harq]][self.PropMcs].append(line[self.PropMcs])
                            self.harqid['harqid=' + line[self.harq]][self.ScaleMcs].append(line[self.ScaleMcs])
                        except AttributeError:
                            self.harqid['harqid=' + line[self.harq]]['numOf5qi1Prb'] = [line['numOf5qi1Prb']]
                            self.harqid['harqid=' + line[self.harq]]['txNumber'] = [[line['txNumber'], line['ackNack']]]
                            self.harqid['harqid=' + line[self.harq]]['numOfPrb'] = [line['numOfPrb']]
                            self.harqid['harqid=' + line[self.harq]]['mcsTable'] = [line['mcsTable']]
                            self.harqid['harqid=' + line[self.harq]]['tbSize'] = [line['tbSize']]
                            self.harqid['harqid=' + line[self.harq]][self.down_tbSize] = [line[self.down_tbSize]]
                            self.harqid['harqid=' + line[self.harq]][self.UsedMcs] = [line[self.UsedMcs]]
                            self.harqid['harqid=' + line[self.harq]][self.PropMcs] = [line[self.PropMcs]]
                            self.harqid['harqid=' + line[self.harq]][self.ScaleMcs] = [line[self.ScaleMcs]]
        # print(self.harqid)


class validate_coding_gain_Target_Bler(Read_Store_Data):

    def __init__(self, rnti, dire, file_name, actVoNRInc=True,
                 numTxPrb=2, maxPrbsVoNR=32,
                 stepUpNumPrbs=2, actTargetBlerVoNR=True,
                 dlMcsDropLimitForVoNR=2,
                 dllaIniMcs=13):

        Read_Store_Data.__init__(self, rnti, dire, file_name)
        self.res_64_qam = [29, 30, 31]
        self.res_256_qam = [28, 29, 30, 31]
        self.actVoNRInc = actVoNRInc
        self.numTxPrb = numTxPrb
        self.maxPrbsVoNR = maxPrbsVoNR
        self.stepUpNumPrbs = stepUpNumPrbs
        self.actTBVoNR = actTargetBlerVoNR
        self.McsDropLim = dlMcsDropLimitForVoNR
        self.dllaIniMcs = dllaIniMcs

    def verify_scena1(self):
        flag = 0

        for key in self.harqid:
            if self.actTBVoNR:
                indx = 0
                for mcs in self.harqid[key]["rrmDlScaledMcs"]:
                    if 0 < self.McsDropLim < 28:
                        if ((int(mcs) - self.McsDropLim) <= int(self.harqid[key]["rrmDlUsedMcs"][indx])
                                and int(self.harqid[key]["rrmDlScaledMcs"][indx]) <= int(mcs) and mcs != '255'):
                            print("UsedMcs {0} is within range min {1} and max {2} for {3}"
                                  .format(self.harqid[key]["rrmDlUsedMcs"][indx],
                                          int(mcs) - self.McsDropLim, mcs, key))
                            flag |= 1
                        elif mcs != '255':
                            print("UsedMcs {0} is not within range min {1} and max {2} for {3}"
                                  .format(self.harqid[key]["rrmDlUsedMcs"][indx],
                                          int(mcs) - self.McsDropLim, mcs, key))
                            flag |= 2

                        indx += 1
                    elif self.McsDropLim == 0:
                        if int(self.harqid[key]["rrmDlUsedMcs"][indx]) <= int(mcs):
                            print("UsedMcs {0}is equal to ScaledMcs{1} for {2}"
                                  .format(self.harqid[key]["rrmDlUsedMcs"][indx], mcs, key))
                            flag |= 4
                        else:
                            print("UsedMcs {0}is not equal to ScaledMcs{1} for {2}"
                                  .format(self.harqid[key]["rrmDlUsedMcs"][indx], mcs, key))
                            flag |= 8
                        indx += 1
            else:
                # Feature Disabled
                indx = 0
                for mcs in self.harqid[key]["rrmDlScaledMcs"]:
                    if ((int(mcs) - int(self.harqid[key]["rrmDlUsedMcs"][indx]) >= self.McsDropLim)
                            and mcs != '255'):
                        print("actTargetBlerVoNR is False", mcs, self.harqid[key]["rrmDlUsedMcs"][indx], key)
                    indx += 1
                    flag |= 16

            ini_num_prb = 0
            enh_num_prb = 0
            ini_vonr_prb = 0
            enh_vonr_prb = 0
            ini_umcs_prb = 0
            enh_umcs_prb = 0
            ini_qam = 0
            enh_qam = 0

            if self.actVoNRInc:
                # for key in self.harqid:
                if ['1', 'NACK'] in self.harqid[key]['txNumber']:
                    index_list = self.get_index_positions(self.harqid[key]['txNumber'], ['1', 'NACK'])
                    for i in index_list:
                        try:
                            if [str(1 + self.numTxPrb), 'NACK'] in self.harqid[key]['txNumber']:
                                ini_num_prb = int(self.harqid[key]['numOfPrb'][i])
                                enh_num_prb = int(self.harqid[key]['numOfPrb'][i + self.numTxPrb])
                                ini_vonr_prb = int(self.harqid[key]['numOf5qi1Prb'][i])
                                enh_vonr_prb = int(self.harqid[key]['numOf5qi1Prb'][i + self.numTxPrb])
                                ini_umcs_prb = int(self.harqid[key][self.UsedMcs][i])
                                enh_umcs_prb = int(self.harqid[key][self.UsedMcs][i + self.numTxPrb])
                                ini_qam = int(self.harqid[key]['mcsTable'][i])
                                enh_qam = int(self.harqid[key]['mcsTable'][i + self.numTxPrb])

                                if ini_num_prb >= self.maxPrbsVoNR and ini_umcs_prb == enh_umcs_prb:
                                    print("No extra PRB will be allocated as in_num_prb {0} "
                                          "is >= maxPrbsVoNR {1} for {2} so initial mcs {3}"
                                          " and used mcs {4} remain same"
                                          .format(ini_num_prb, self.maxPrbsVoNR, key, ini_umcs_prb, enh_umcs_prb))
                                    flag |= 32
                                else:
                                    vonr_prb_diff = enh_vonr_prb - ini_vonr_prb
                                    if (ini_num_prb * self.stepUpNumPrbs == enh_num_prb and
                                            ini_vonr_prb * self.stepUpNumPrbs == enh_vonr_prb):
                                        print('Vonr prb is incremented by factor of stepUpNumPrbs for %s' % key)
                                        if ini_qam == enh_qam != 'QAM256' and enh_umcs_prb in self.res_64_qam:
                                            print("Reserved MCS {} is assigned from 64QAM after PRB doubling"
                                                  " after {} steps for harqid {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag |= 64

                                        elif ini_qam == enh_qam == 'QAM256' and enh_umcs_prb in self.res_256_qam:
                                            print("Reserved MCS {} is assigned from 256QAM after PRB doubling"
                                                  " after {} steps for harqid {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag |= 128
                                        else:
                                            print("reserved MCS not assigned after PRB Doubling")
                                            flag |= 256

                                    elif (enh_num_prb / ini_num_prb < self.stepUpNumPrbs and
                                          vonr_prb_diff >= 0 and int(enh_num_prb) == self.maxPrbsVoNR):
                                        print("Vonr prb is incremented but not doubled since coding"
                                              " gain prb is limited for %s" % key)
                                        if ini_qam == enh_qam != 'QAM256' and enh_umcs_prb in self.res_64_qam:
                                            print("Reserved MCS {} is assigned from 64QAM after PRB doubling"
                                                  " after {} steps for harqid {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag |= 512
                                        elif ini_qam == enh_qam == 'QAM256' and enh_umcs_prb in self.res_256_qam:
                                            print("Reserved MCS {} is assigned from 256QAM after PRB doubling"
                                                  " after {} steps for harqid {}"
                                                  .format(enh_umcs_prb, self.numTxPrb, key))
                                            flag |= 1024
                        except IndexError:
                            pass
            else:
                if (ini_num_prb == enh_num_prb and ini_vonr_prb == enh_vonr_prb and
                        ini_umcs_prb == enh_umcs_prb and (enh_umcs_prb not in self.res_64_qam)
                        or (enh_umcs_prb not in self.res_256_qam)):
                    print("No change in MCS and PRB allocation actVoNRIncCodingGain is Disabled")
                    flag |= 2048
                else:
                    flag |= 4096
            self.harqid[key]['flag'] = flag

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
            for prb in self.harqid['numOfPrb']:
                # if self.actUlMinTbsForVoNR:
                idx = 0
                if self.actUlMinTbsForVoNR:
                    # for prb in self.harqid['numOfPrb']:
                    if (int(prb) <= self.minPuschPrbForMinTbsVoNR and
                            int(self.harqid['tbSize'][idx]) >= self.ulMinTbsForVoNR):
                        print("Assigned PRB {0} and tbSize {1} are within limit defined by"
                              " minPuschPrbForMinTbsVoNR {2} and ulMinTbsForVoNR {3}"
                              .format(prb, self.harqid['tbSize'][idx],
                                      self.minPuschPrbForMinTbsVoNR, self.ulMinTbsForVoNR))
                        flag_ul |= 1
                    else:
                        print("Feature activation failed.Assigned PRB {0} and tbSize {1} are not within "
                              " limit defined by minPuschPrbForMinTbsVoNR {2} and ulMinTbsForVoNR {3}"
                              .format(prb, self.harqid['tbSize'][idx],
                                      self.minPuschPrbForMinTbsVoNR, self.ulMinTbsForVoNR))
                        flag_ul |= 2
                    idx += 1
                else:
                    if ((int(prb) >= self.minPuschPrbForMinTbsVoNR
                         or int(prb) < self.minPuschPrbForMinTbsVoNR)
                            and (int(self.harqid['tbSize'][idx]) <= self.ulMinTbsForVoNR
                                 or int(self.harqid['tbSize'][idx]) > self.ulMinTbsForVoNR)):
                        print("Feature Disabled assigned PRB {0} and tbSize {1} are not within limit defined by"
                              " minPuschPrbForMinTbsVoNR {2} and ulMinTbsForVoNR {3}"
                              .format(prb, self.harqid['tbSize'][idx],
                                      self.minPuschPrbForMinTbsVoNR, self.ulMinTbsForVoNR))

                        flag_ul |= 4
                    idx += 1
            self.harqid[key]['flag'] = flag_ul


def verify(ue_obj, scena):
    flag = 0
    for harqid in ue_obj.harqid:
        exec_sce = ue_obj.harqid[harqid]['flag'] & scena
        if exec_sce == scena:
            print("Got expected scenario for ", harqid)
            flag |= 1
        else:
            print("expected scenario is not achieved for ", harqid)
            flag |= 0
    if flag == 0:
        return 'Fail'
    else:
        return 'Pass'


def dummy_func_dl(rnti, file_name, actVoNRInc=True, numTxPrb=2, maxPrbsVoNR=32, stepUpNumPrbs=2,
                  actTargetBlerVoNR=True, dlMcsDropLimitForVoNR=2, tc_scen=0):
    obj = validate_coding_gain_Target_Bler(rnti, 'dl', file_name, actVoNRInc, numTxPrb, maxPrbsVoNR, stepUpNumPrbs,
                                           actTargetBlerVoNR, dlMcsDropLimitForVoNR)
    obj.verify_scena1()
    return verify(obj, tc_scen)


def dummy_func_ul(rnti, file_name, actUlMinTbsForVoNR=True, minPuschPrbForMinTbsVoNR=2,
                  ulMinTbsForVoNR=32, tc_scen=0):
    obj = validate_coding_gain_Target_Bler(rnti, 'ul', file_name, actUlMinTbsForVoNR, minPuschPrbForMinTbsVoNR,
                                           ulMinTbsForVoNR)
    obj.verify_scena1()
    return verify(obj, tc_scen)
