import csv
import os
import sys
import time
# from colorama import init, Fore  # color
# init(autoreset=True)
# init(wrap=True)
# v21:+ single UE pair check
# v22:+ if Retx pair, then check <= max_PRB
# v23:change _delta_slot_between_pucch_pusch()
front_col = ['sfn', 'slot',
             'rnti',
             'physCellId',
             # 'ulFdSchedData.pairedUeRnti',
             'ulFdSchedData.virtualUeIndex',
             'ulFdSchedData.ulMuGroupStatus',
             'ulFdSchedData.ulMuStatus',
             'ulFdSchedData.subcellId',
             'ulFdSchedData.numOfLayers',
             'ulFdSchedData.requiredPrb',
             'ulFdSchedData.prbOfVirtualUe',
             'ulFdSchedData.numOfPrb',
             'ulAllocatedPooledResourcesData.numAllocCellPrbUl',
             'ulTdSchedSubcellData.numPrbToBeUsedForPucch',
             # 'ulMetricIndData.nonGbrPrbDemand',
             'ulFdSchedData.rrmMaxNumPrbUl',
             'ulMuUeData.vUeTrace',
             'ulHarqRxData.crcResult',
             'ulHarqRxData.dtx',
             'ulFdSchedData.txNumber',
             'ulFdSchedData.ulHarqProcessIndex',
             # 'ulFdSchedData.rrmBufferedDataUlLcg_bytes',
             # 'ulPreSchedData.highestClassPriority',
             'ulFdSchedData.antPort',
             'antport_index',
             'ulSrsBeamData.ulSrsBmBestBeamIndexH',
             'ulSrsBeamData.ulSrsBmBestBeamIndexV',
             'ulFdSchedData.numCdmGroupNoData',
             'ulFdSchedData.rrmUlUsedMcs',
             # reTx simple pair
             'ulFdSchedData.numOfUciAckBits',
             # MCS comp
             # 'ulLaAverageSinr.harqProcessIndex',
             'ulFdSchedData.deltaMcs',
             'ulFdSchedData.startPrb',
             'ulFdSchedData.reScaledCorrAvgSinrReqPrb',
             'ulFdSchedData.reScaledCorrAvgSinrAllocPrb',
             'ulLaPhr.rrmPhrScaled',
             'ulFdSchedData.estimatedMuSinr',
             'ulLaAverageSinr.estimatedMuSinr',
             'ulLaAverageSinr.rrmInstSinr',
             'ulLaAverageSinr.rrmInstSinrRank',
             'ulFdSchedData.sinrDerivedMcs',
             'ulFdSchedData.rrmUlProposedMcs',
             'ulFdSchedData.rrmUlScaledMcs',
             # 'ulLaPhr.phr',
             # 'ulFdSchedData.patternId1',
             # 'ulFdSchedData.patternId2'
             'ulHarqRxData.ulHarqProcessIndex',
             'ulFdSchedData.pairedUeRnti',
             ]


def _read_csv_as_list_dict(fpath, cared_title):
    value_list_dict = {}
    csv_list = []
    with open(fpath, 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        for c in csvreader:
            csv_list.append(c)
    if cared_title == 'ALL':
        for r in range(len(csv_list)):
            if len(csv_list[r]) == len(csv_list[r + 1]):
                self_cared_title = csv_list[r]
                break
    else:
        self_cared_title = cared_title

    pos_list = []
    # find title line and title index
    for r in range(len(csv_list)):
        row = csv_list[r]
        if self_cared_title[0] in row:
            next = r + 1
            for ca in self_cared_title:
                pos_list.append(row.index(ca))
                value_list_dict[ca] = []
            value_list_dict['Num'] = []
            break
    if not pos_list:
        raise Exception('not find title line')
    # get all title's value
    for r in range(next, len(csv_list)):
        row = csv_list[r]
        for pos in range(len(pos_list)):
            try:
                value_list_dict[self_cared_title[pos]].append(
                    _convert_to_num(row[pos_list[pos]]))
            except Exception as err:
                pass
        value_list_dict['Num'].append(r)
    return value_list_dict, self_cared_title


def _read_csv_as_dict_list(fpath, cared_title):
    value_dict_list = []
    csv_list = []
    with open(fpath, 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        for c in csvreader:
            if c:
                csv_list.append(c)
    if cared_title == 'ALL':
        for r in range(len(csv_list)):
            if len(csv_list[r]) == len(csv_list[r + 1]):
                self_cared_title = csv_list[r]
                break
    else:
        self_cared_title = cared_title

    pos_list = []
    # find title line and title index
    for r in range(len(csv_list)):
        row = csv_list[r]
        if self_cared_title[0] in row:
            next = r + 1
            for ca in self_cared_title:
                pos_list.append(row.index(ca))
            break
    if not pos_list:
        raise Exception('not find title line')
    # get all title's value
    for r in range(next, len(csv_list)):
        dline = {}
        row = csv_list[r]

        for pos in range(len(pos_list)):
            dline[self_cared_title[pos]] = _convert_to_num(row[pos_list[pos]])
        dline['Num'] = r
        value_dict_list.append(dline)
    return value_dict_list, self_cared_title


def _convert_to_num(value):
    if value.isdigit():
        return int(value)
    elif ('.' in value) and (value.count('.') == 1):
        pre, aft = value.split('.')
        if pre.isdigit() and aft.isdigit():
            return float(value)
        else:
            return value
    else:
        return value


def _write_csv_with_dict_list(fpath, content_list, title):
    with open(fpath, "w", newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        keys = title
        writer.writerow(keys)
        for i in content_list:
            values = []
            for key in title:
                values.append(i[key])
            writer.writerow(values)


def _write_csv_with_list_dict(fpath, value_dict, title):
    with open(fpath, "w", newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        writer.writerow(title)
        for i in range(0, len(value_dict['physCellId'])):
            row_list = []
            try:
                for j in title:
                    row_list.append(value_dict[j][i])
                writer.writerow(row_list)
            except Exception as err:
                pass


def _dec_to_bin(a):
    # filter out NaN
    if a > 0:
        a_dec = int(a)
        """
        # 转化为16位二进制，高位补零
        a_bin='{:016b}'.format(a_dec)
        # get high 4 bit
        a_hi_4=a_bin>>12
        #a_hi_4 取值范围=  antport  1       2       3       4       12      34
        #bin                      1000    0100   0010    0001    1100    0011
        #dec                      8         4       2       1       12      3
        """
        # right shift

        a_hi_4 = a_dec >> 12
        if a_hi_4 == 8:
            return 1
        if a_hi_4 == 4:
            return 2
        if a_hi_4 == 2:
            return 3
        if a_hi_4 == 1:
            return 4
        if a_hi_4 == 12:
            return "1,2"
        if a_hi_4 == 3:
            return "3,4"

    else:
        return a
# end dec_to_bin()


def _reorder_tti_ul(filename):
    df, self_title = _read_csv_as_list_dict(filename, 'ALL')
    df['antport_index'] = []
    # add new column "antport_index" according to antport
    for data in df['ulFdSchedData.antPort']:
        try:
            new = _dec_to_bin(data)
            df['antport_index'].append(new)
        except Exception as er:
            df['antport_index'].append('')

    pos = self_title.index('ulFdSchedData.antPort')

    self_title.insert(pos + 1, 'antport_index')

    new_title = front_col + list(set(self_title).difference(front_col))

    # save to ecsv
    _write_csv_with_list_dict(filename.replace('.csv', '_Reorder.csv'), df, new_title)
    print("\n==============save successfully===============\n")
    return df
# end tti_reorder(),返回reorder后的df


def _data_lost(df_curr_slot, curr_pucch_sfn, curr_pusch_slot):
    for j_line in df_curr_slot:
        # data lost line exist
        if (j_line['ulHarqRxData.crcResult']) and (not j_line['ulFdSchedData.numOfPrb']):
            print("WRN:data_lost_sfn-slot:", curr_pucch_sfn, "-", curr_pusch_slot)
            return True
    return False


class US:
    def __init__(self, allocPRB, MU_not_available_subcell_PRB, MU_not_available_physical_PRB,
                 pucch, requirePRB, puschULmax, curr_max_MU_layers, ratio):
        self.allocPRB = allocPRB
        self.MU_not_available_subcell_PRB = MU_not_available_subcell_PRB
        self.MU_not_available_physical_PRB = MU_not_available_physical_PRB
        self.pucch = pucch
        self.requirePRB = requirePRB
        self.puschULmax = puschULmax
        self.curr_max_MU_layers = curr_max_MU_layers
        self.ratio = ratio

    def XYZ_US(self):
        # print('MUnotAvailbleSubcellPRB:',self.MU_not_available_subcell_PRB)
        rrmAvailableSubcellPRbForMu = self.allocPRB - \
            self.pucch - self.MU_not_available_subcell_PRB
        rrmAvailablePrbForMu = self.puschULmax - self.MU_not_available_physical_PRB
        X = rrmAvailableSubcellPRbForMu
        X_thr = rrmAvailablePrbForMu
        X_max = 2 * rrmAvailablePrbForMu
        Y = self.requirePRB
        ratio = self.ratio
        # print('thr=',X_thr)
        if (X <= X_thr):
            if (Y <= X * ratio):
                return 'US1: X<thr,Y <= rrmAvailableSubcellPRbForMu*ratio, Only FDM'
            else:
                return 'US2: X<thr, Y > rrmAvailableSubcellPRbForMu*ratio, Rank1 pair on primary subcell only'
        elif (X_thr < X < X_max):
            if (Y <= rrmAvailablePrbForMu * ratio):
                return 'US3: thr<X<X_max, Y <= rrmAvailablePrbForMu*ratio, PRB enough,Only FDM'
            else:
                return 'US4:thr<X<X_max,Y > rrmAvailablePrbForMu*ratio, full UE pairing use 2 subcells'
        elif (X >= X_max):
            if (Y <= rrmAvailablePrbForMu * ratio):
                return 'US5:X>X_max,Y<=rrmAvailablePrbForMu*ratio, PRB enough,Only FDM'
            else:
                return 'US6:X>X_max,Y>rrmAvailablePrbForMu*ratio, full UE pairing use 2 subcells'

    def MU_layers_check(self):
        US_str = self.XYZ_US()
        # print('debug:US_str',US_str)
        if (US_str.startswith('US1')):
            if (self.curr_max_MU_layers > 0):
                return 'ERR:US1 but MU_layers >0,there should be FDM only'
        elif (US_str.startswith('US2')):
            if (self.curr_max_MU_layers > 2):
                return 'ERR:US2 but MU_layers >2,MU layers at most 1+1'
            elif (self.curr_max_MU_layers < 2):
                return 'WRN:US2 but MU_layers<2,MU layers can be 1+1'
        elif (US_str.startswith('US3')):
            if (self.curr_max_MU_layers > 0):
                return 'ERR:US3 but MU_layers >0,there should be FDM only'
        elif (US_str.startswith('US4')):
            if (self.curr_max_MU_layers < 3):
                return 'WRN:US4 but MU_layers <3,MU can be 4 layers at most'
        elif (US_str.startswith('US5')):
            if (self.curr_max_MU_layers > 0):
                return 'ERR:US5 but MU_layers >0,there should be FDM only'
        elif (US_str.startswith('US6')):
            if (self.curr_max_MU_layers < 3):
                return 'WRN:US6 but MU_layers <3,MU can be 4 layers at most'
# end class US


def _get_max_virtualUE_index(df_curr_slot):
    list_Vi = []
    for j_line in df_curr_slot:
        # print('rnti:',j_line['rnti'],'vi:', j_line['ulFdSchedData.virtualUeIndex'])
        if (isinstance(j_line['ulFdSchedData.ulMuStatus'], str) and
                (j_line['ulFdSchedData.virtualUeIndex'] != '')):  # filter out empty row
            list_Vi.append(j_line['ulFdSchedData.virtualUeIndex'])

    if (list_Vi == []):  # empty list:no schedule in csv
        return -1
    else:
        min_vi = min(list_Vi)
        max_vi = max(list_Vi)
        if (min_vi == 255):  # only 255
            # print("elif_min_Vi:", min(list_Vi))
            # print("elif_max_Vi:", max(list_Vi))
            return 255
        else:  # filter out 255
            list_Vi_1 = []
            for i in list_Vi:
                if i < 255:
                    list_Vi_1.append(i)
            vi_max = max(list_Vi_1)
            # print(list_Vi_1)
            # print("else_max_Vi:", vi_max)
            return int(vi_max)


def _layers_str_to_int(numOfLayers):
    if (numOfLayers.endswith('1')):  # Rank1
        return 1
    elif (numOfLayers.endswith('2')):  # Rank2
        return 2


def _get_MU_layers(df_curr_slot, max_VUE_index):
    # max_VUE_index = _get_max_virtualUE_index(df_curr_slot)
    # 所有Vue 的layer依次存入列表
    Vue_MUlayers_list = []
    if (max_VUE_index == 255):
        return Vue_MUlayers_list
    for Vi in range(max_VUE_index + 1):
        MU_layers = 0
        df_curr_Vi = []
        for line in df_curr_slot:
            if line['ulFdSchedData.virtualUeIndex'] == Vi:
                df_curr_Vi.append(line)
        # NON-Group
        for j_line in df_curr_Vi:
            if (j_line['ulFdSchedData.ulMuStatus'].startswith('MUPAIRED')):
                MU_layers += _layers_str_to_int(
                    j_line['ulFdSchedData.numOfLayers'])
        # Group
            if (j_line['ulFdSchedData.ulMuGroupStatus'].endswith('ROOT')):
                MU_layers += _layers_str_to_int(
                    j_line['ulFdSchedData.numOfLayers'])

        for j_line in df_curr_Vi:
            if (j_line['ulFdSchedData.ulMuGroupStatus'].endswith('INGROUP')):
                MU_layers += _layers_str_to_int(
                    j_line['ulFdSchedData.numOfLayers'])
                break  # 非root UE in group只找一个即可
        # end Group
        # print('Vi:',Vi,'layers:',MU_layers)
        Vue_MUlayers_list.append(MU_layers)
    return Vue_MUlayers_list
# end def get_MU_layers


def _only_ReTx(df_curr_slot):
    flag_only_ReTx = 0
    for i_line in df_curr_slot:  # only reTx will return 1
        if (isinstance(i_line['ulFdSchedData.ulMuStatus'], str)):  # not empty
            if (i_line['ulFdSchedData.txNumber'] and (
               i_line['ulFdSchedData.txNumber'] > 1)):
                flag_only_ReTx = 1
            else:
                flag_only_ReTx = 0
    return flag_only_ReTx

# ReTx is pair(re+re,re+new)and all UEs are paired,it's acceptable if PRB
# not exausted


def _all_VUE_with_reTx(df_curr_slot, max_VUE_index):
    flag_all_VUE_with_reTx = 0
    # 1.there's newTx UE not paired
    for j_line in df_curr_slot:
        if (isinstance(j_line['ulFdSchedData.ulMuStatus'], str)) and \
                j_line['ulFdSchedData.virtualUeIndex']:
            if ((j_line['ulFdSchedData.virtualUeIndex'] == 255) and (
                    j_line['ulFdSchedData.txNumber'] == 1)):
                return flag_all_VUE_with_reTx
    # 2.all UES paired and every VUE has at least one reTx
    num_Vi_reTx = 0
    if (-1 < max_VUE_index < 255):  # MU exist
        for i in range(max_VUE_index + 1):
            df_curr_Vi = []
            for line in df_curr_slot:
                if line['ulFdSchedData.virtualUeIndex'] == i:
                    df_curr_Vi.append(line)
        for j_line in df_curr_Vi:
            if (j_line['ulFdSchedData.txNumber'] > 1):
                num_Vi_reTx += 1
                break
        if (num_Vi_reTx == max_VUE_index + 1):  # all VUE has reTx
            flag_all_VUE_with_reTx = 1

    return flag_all_VUE_with_reTx


def _single_UE_pair(df_curr_slot, max_VUE_index):
    if (-1 < max_VUE_index < 255):  # MU exist
        for i in range(max_VUE_index + 1):
            num_of_pair_UE = 0
            for j_line in df_curr_slot:
                # filter out empty row
                if (isinstance(j_line['ulFdSchedData.ulMuStatus'], str)):
                    if ((j_line['ulFdSchedData.virtualUeIndex'] == i) and (
                            j_line['ulFdSchedData.ulMuStatus'].startswith('MUPAIRED'))):
                        num_of_pair_UE += 1
            if (num_of_pair_UE == 1):  # ERR:only 1 UE pair in curr Vi
                return 1
    return 0


def _not_exausted_due_to_reqPRB_limited(df_curr_slot):
    for i_line in df_curr_slot:
        if (isinstance(i_line['ulFdSchedData.ulMuStatus'],
                       str)):  # filter out empty rows
            if (i_line['ulFdSchedData.requiredPrb'] == i_line['ulFdSchedData.numOfPrb']):
                return 1
            else:
                return 0


def _Analys_curr_slot(df_curr_slot, allocPRB, curr_pucch,
                      MaxPuschUL, df_output_index):
    row_index = 1
    max_VUE_index = _get_max_virtualUE_index(df_curr_slot)
    if (max_VUE_index < 0):
        # print(Fore.RED+"empty pusch ")
        return
    # get curr_sfn_slot
    curr_sfn = 20  # ini v or else ERR
    curr_slot = 20

    for i_line in df_curr_slot:
        if (i_line['ulFdSchedData.numOfPrb'] and (
           i_line['ulFdSchedData.numOfPrb'] > 0)):
            curr_sfn = int(i_line['sfn'])
            curr_slot = int(i_line['slot'])
            break
    MU_subcell_PRB = 0
    MU_physical_PRB = 0
    nonMU_PRB = 0
    MU_not_available_subcell_PRB = 0
    MU_not_available_physical_PRB = 0
    # non Group
    if (max_VUE_index < 255):
        # print('curr_max_index:',max_VUE_index)
        for Vi in range(max_VUE_index + 1):
            # print('curr_Vi=',Vi)
            for j_line in df_curr_slot:
                # str()避免MUstatus=空行是报错AttributeError: 'float' object has no attribute 'endswith'
                # simple pair VUE_PRB in tti =0,get PRB from numofPRB
                flag_sp = 1  # for simple pair physical PRB, only get one subcell
                if ((str(j_line['ulFdSchedData.ulMuStatus']).endswith('SIMPLERE')) and (
                        j_line['ulFdSchedData.virtualUeIndex'] == Vi) and (
                        j_line['ulFdSchedData.subcellId'] == 0)):
                    MU_subcell_PRB += j_line['ulFdSchedData.numOfPrb']
                    # if simple pair  in subcell0
                    if (j_line['ulFdSchedData.numOfPrb'] > 0):
                        MU_physical_PRB += j_line['ulFdSchedData.numOfPrb']
                        flag_sp = 0  # another subcell not needed
                    # print("Vi:", Vi)
                    # print('1:', MU_physical_PRB)
                    break
                if ((str(j_line['ulFdSchedData.ulMuStatus']).startswith('MUPAIRED')) and (
                        j_line['ulFdSchedData.virtualUeIndex'] == Vi) and (
                        j_line['ulFdSchedData.subcellId'] == 0)):
                    MU_subcell_PRB += j_line['ulFdSchedData.prbOfVirtualUe']
                    # print("Vi:", Vi)
                    # print('MU_sub0_PRB:',MU_subcell_PRB)
                    MU_physical_PRB += j_line['ulFdSchedData.prbOfVirtualUe']
                    # print('2:', MU_physical_PRB)
                    break
            for j_line in df_curr_slot:
                if ((str(j_line['ulFdSchedData.ulMuStatus']).endswith('SIMPLERE')) and (
                        j_line['ulFdSchedData.virtualUeIndex'] == Vi) and (
                        j_line['ulFdSchedData.subcellId'] != 0)):   # ==1
                    MU_subcell_PRB += j_line['ulFdSchedData.numOfPrb']
                    if (flag_sp):
                        MU_physical_PRB += j_line['ulFdSchedData.numOfPrb']
                    # print("Vi:", Vi)
                    # print('3:', MU_physical_PRB)
                    break
                if ((str(j_line['ulFdSchedData.ulMuStatus']).startswith('MUPAIRED')) and (
                        j_line['ulFdSchedData.virtualUeIndex'] == Vi) and (
                        j_line['ulFdSchedData.subcellId'] != 0)):   # ==1
                    MU_subcell_PRB += j_line['ulFdSchedData.prbOfVirtualUe']
                    # print("Vi:", Vi)
                    # print('MU_sub1_PRB:1', MU_subcell_PRB)

                    break
            # simple pair: MU_not_available_PRB
            flag_sp = 1
            for j_line in df_curr_slot:
                if ((str(j_line['ulFdSchedData.ulMuStatus']).endswith('SIMPLERE')) and (
                        j_line['ulFdSchedData.virtualUeIndex'] == Vi) and (
                        j_line['ulFdSchedData.subcellId'] == 0)):
                    MU_not_available_subcell_PRB += j_line['ulFdSchedData.numOfPrb']
                    MU_not_available_physical_PRB += j_line['ulFdSchedData.numOfPrb']
                    # print('sub0_not_Avai:',MU_not_available_subcell_PRB)
                    flag_sp = 0  # another subcell not needed
                    break
            for j_line in df_curr_slot:
                if ((str(j_line['ulFdSchedData.ulMuStatus']).endswith('SIMPLERE')) and (
                        j_line['ulFdSchedData.virtualUeIndex'] == Vi) and (
                        j_line['ulFdSchedData.subcellId'] != 0)):   # ==1
                    MU_not_available_subcell_PRB += j_line['ulFdSchedData.numOfPrb']
                    # print('sub0_not_Avai:', MU_not_available_subcell_PRB)
                    if (flag_sp):  # sucell0 not get, then get from subcell1
                        MU_not_available_physical_PRB += j_line['ulFdSchedData.numOfPrb']
                    break
    # end for Vi
    # UE group
    for j_line in df_curr_slot:
        # group status 字符串以ROOT结尾的，PRB相加。ROOT UE的PRB就是整个virtual　UE的PRB
        if (str(j_line['ulFdSchedData.ulMuGroupStatus']).endswith('ROOT')):
            MU_subcell_PRB += j_line['ulFdSchedData.prbOfVirtualUe']
            MU_physical_PRB += j_line['ulFdSchedData.prbOfVirtualUe']
            # print('5:', MU_physical_PRB)
    # nonMU PRB
    for j_line in df_curr_slot:
        if (j_line['ulFdSchedData.virtualUeIndex'] and (
                j_line['ulFdSchedData.virtualUeIndex'] == 255)):
            nonMU_PRB += j_line['ulFdSchedData.numOfPrb']
    # print('nonMU PRB=',nonMU_PRB)
    # total PRB
    subcell_PRB = int(MU_subcell_PRB + nonMU_PRB + curr_pucch)
    physical_PRB = int(MU_physical_PRB + nonMU_PRB)
    # print("pucch:",curr_pucch)
    # print('MU_sub_PRB:',MU_subcell_PRB)
    # print('MU_phy_PRB:', MU_physical_PRB)
    # print('nonMU:',nonMU_PRB)
    # print('physical_PRB =', physical_PRB)
    # print('subcell_PRB =', subcell_PRB)

    subcell_PRB_exausted = 'NO'
    # subcell PRB exausted ?
    if (subcell_PRB < allocPRB - 1):
        subcell_PRB_exausted = 'NO'
        name = 'WRN:subcell PRB not exausted'
        # print(Fore.YELLOW + name)
    elif ((subcell_PRB == allocPRB) | (subcell_PRB == allocPRB - 1)):
        subcell_PRB_exausted = 'YES'
        name = 'subcell PRB exausted'
        # print(Fore.GREEN + name)
    elif (subcell_PRB > allocPRB):
        subcell_PRB_exausted = 'ERR:more than allocPRB'
        name = 'ERR:subcell PRBs exceed allocPRB!'
        # print(Fore.RED + name)

    physical_PRB_exausted = 'NO'
    # physical PRB exausted ?
    if (physical_PRB == MaxPuschUL):
        physical_PRB_exausted = 'YES'
        name = 'phsyical_PRB exausted'
        # print(Fore.Green+name)
    elif (physical_PRB < MaxPuschUL):
        physical_PRB_exausted = 'NO'
        name = 'physical_PRB not exausted'
        # print(Fore.YELLOW+name)
    elif (physical_PRB > MaxPuschUL):
        physical_PRB_exausted = 'ERR:more than maxPusch'
        # print(Fore.RED+physical_PRB_exausted)
        check_result = 'check PRB Fail'

    # get require PRB
    requirePRB = 0
    for j_line in df_curr_slot:
        try:
            req_prb = int(j_line['ulFdSchedData.requiredPrb'])
        except Exception as err:
            continue
        if (req_prb > 0):
            requirePRB += req_prb
            # print('requirePRB:', requirePRB)
    # print('requirePRB =', int(requirePRB))

    list_curr_MU_layers = _get_MU_layers(df_curr_slot, max_VUE_index)
    # print('MU_layers:', list_curr_MU_layers)  # 得到所有VUE MUlayers 列表
    if (bool(list_curr_MU_layers) is False):
        curr_max_MU_layers = 0
    else:
        curr_max_MU_layers = max(list_curr_MU_layers)  # 当前slot 最大MU layers
        # print('curr_max_MU_layers:',curr_max_MU_layers)

    # US(allocPRB, pucch,requirePRB,puschULmax,PRB_Vue,PRB_nonMU,ratio)
    MU_available_PRB = allocPRB - MU_not_available_subcell_PRB - curr_pucch  # ????
    US1 = US(
        allocPRB,
        MU_not_available_subcell_PRB,
        MU_not_available_physical_PRB,
        curr_pucch,
        requirePRB,
        MaxPuschUL,
        curr_max_MU_layers,
        1.1)  # ???
    curr_US_str = US1.XYZ_US()
    MU_layers_check = US1.MU_layers_check()
    # print('US:',curr_US_str)
    MU_layers_check_str = str(MU_layers_check)

    flag_all_VUE_with_reTx = _all_VUE_with_reTx(
        df_curr_slot, max_VUE_index)  # 0 or 1
    flag_only_reTx = _only_ReTx(df_curr_slot)  # 0 or 1

    # 当前结果存入dataframe_output一行
    flag_single_UE_pair = 'OK'
    if _single_UE_pair(df_curr_slot, max_VUE_index):
        flag_single_UE_pair = 'ERR:single UE paired'
        print(curr_sfn, '-', curr_slot, 'ERR: single UE scheduled but paired')
    # check if not exausted due to reqPRB is limited
    if _not_exausted_due_to_reqPRB_limited(df_curr_slot) > 0:
        flag_not_exausted_due_to_reqPRB_limited = 1
    else:
        flag_not_exausted_due_to_reqPRB_limited = 0
    data = {}
    data['num'] = df_output_index
    data['sfn_pusch'] = curr_sfn
    data['slot_pusch'] = curr_slot
    data['slot_pucch'] = curr_slot - 2
    data['pucch'] = curr_pucch
    data['MU_avail_PRB'] = MU_available_PRB
    data['MU_not_avail_PRB'] = MU_not_available_subcell_PRB
    data['X_allocPRB'] = allocPRB
    data['subcell_PRB_used'] = subcell_PRB
    data['subcell_PRB_exausted'] = subcell_PRB_exausted
    data['maxPuschPRB'] = MaxPuschUL
    data['physical_PRB'] = physical_PRB
    data['physical_PRB_exausted'] = physical_PRB_exausted
    data['MU_layers_Check'] = MU_layers_check
    data['Vue_MU_layers'] = list_curr_MU_layers
    data['US'] = curr_US_str
    data['all_VUE_with_reTx'] = flag_all_VUE_with_reTx
    data['only_reTx'] = flag_only_reTx
    data['single_UE_Pair'] = flag_single_UE_pair
    data['not_exausted_due_to_reqPRB_limited'] = flag_not_exausted_due_to_reqPRB_limited
    return data
# end def Analys_curr_slot


def _check_final_Result(df_output, rach_slot):
    # 分析df_output:给出PRB check 结果
    # 1.找出PRB没分完的:filter out reTx slot
    # print('df_output_len:', len(df_output))
    check_result = True
    df_WAR_slot = []
    for line in df_output:
        if (line['subcell_PRB_exausted'] == 'NO') and (
                line['physical_PRB_exausted'] == 'NO') and (
                line['slot_pusch'] != rach_slot) and (
                line['only_reTx'] == 0) and (
                line['all_VUE_with_reTx'] == 0) and (
                line['not_exausted_due_to_reqPRB_limited'] == 0) and (
                line['single_UE_Pair'] == 'OK'):
            df_WAR_slot.append(line)
    # filter out only ReTx slot and all VUE has reTx
    series_WRN_Slot = []
    for line in df_WAR_slot:
        series_WRN_Slot.append(line['slot_pusch'])
    print('length', len(df_output))
    if (series_WRN_Slot):  # not empty
        for i_line in df_WAR_slot[:-1]:  # 最后一slot数据可能不完整，不做判断
            # print('index:',i)

            print(str(i_line['sfn_pusch']) + '-' + str(
                i_line['slot_pusch']) + ':both subcell PRB and phyiscal PRB are not exausted!')
            check_result = False
    # 2.PRB 分超 check all slot
    for i_line in df_output:
        if (i_line['subcell_PRB_exausted'].startswith('ERR')):
            check_result = False
            ERR_time = '[' + str(i_line['sfn_pusch']) + \
                '-' + str(i_line['slot_pusch']) + ']'
            print(ERR_time + i_line['subcell_PRB_exausted'])
        if (i_line['physical_PRB_exausted'].startswith('ERR')):
            check_result = False
            ERR_time = '[' + str(i_line['sfn_pusch']) + \
                '-' + str(i_line['slot_pusch']) + ']'
            print(ERR_time + i_line['physical_PRB_exausted'])

    return check_result


def _delta_slot_between_pucch_pusch(dict_list, physCellId):
    # regard K2 = delta_usedpucch_pusch
    for row in dict_list:
        if row['ulFdSchedData.K2'] and (row['physCellId'] == physCellId):
            delta = int(row['ulFdSchedData.K2'])
            break
    print('delta_pucch_pusch:', delta)
    return delta

# ======================main()========================================================


def check_7113_cell_rachslot(filename, physCellId, rach_slot):
    _reorder_tti_ul(filename)
    # 创建dataframe保存分析结果
    # 先创建列名list
    physCellId = int(physCellId)
    rach_slot = int(rach_slot)
    colu_list = [
        'num',
        'sfn_pusch',
        'slot_pusch',
        'slot_pucch',
        'pucch',
        'MU_avail_PRB',
        'MU_not_avail_PRB',
        'X_allocPRB',
        'subcell_PRB_used',
        'subcell_PRB_exausted',
        'maxPuschPRB',
        'physical_PRB',
        'physical_PRB_exausted',
        'Vue_MU_layers',
        'MU_layers_Check',
        'US',
        'all_VUE_with_reTx',
        'only_reTx',
        'single_UE_Pair',
        'not_exausted_due_to_reqPRB_limited']

    df, self_title = _read_csv_as_dict_list(
        filename.replace(
            '.csv',
            '_Reorder.csv'),
        'ALL')
    slot_delta = _delta_slot_between_pucch_pusch(df, physCellId)
    df_output = []
    # df_output.append( [','.join(colu_list) + '\r\n'])
    for_time = 0
    MaxPuschUL = 0
    df_output_index = 1
    # 遍历alloc列
    for i_line in df:
        if not i_line['ulAllocatedPooledResourcesData.numAllocCellPrbUl']:
            continue
        try:
            curr_allocPRB = i_line['ulAllocatedPooledResourcesData.numAllocCellPrbUl']
        except Exception as err:
            continue
        if (curr_allocPRB > 0) and (i_line['physCellId'] == physCellId):
            alloc_sfn = int(i_line['sfn'])
            # print('===============sfn:',alloc_sfn,'allocPRB=',curr_allocPRB,'===================')
            # 过滤出cell50,sfn 5以内(tti总时长不超过10s)
            df_curr_alloc = []
            for line in df:
                if (int(line['sfn']) - alloc_sfn < 5) and (
                        int(line['sfn']) - alloc_sfn >= 0) and (
                        int(line['physCellId']) == physCellId):
                    df_curr_alloc.append(line)
            # print(df_curr_alloc)
            last_pucch_sfn = -1
            last_pucch_slot = -1
            # find the global maxPusch(rrmMaxNumPrbUl)
            for j_line in df_curr_alloc:
                if j_line['ulFdSchedData.numOfPrb'] and (
                        j_line['ulFdSchedData.txNumber'] == 1):
                    MaxPuschUL = j_line['ulFdSchedData.rrmMaxNumPrbUl']

            # step2: find curr pucch_to_Be_used
            for k_line in df_curr_alloc:
                try:
                    int(float(
                        k_line['ulTdSchedSubcellData.numPrbToBeUsedForPucch']))
                except Exception as err:
                    continue
                if (k_line['ulTdSchedSubcellData.numPrbToBeUsedForPucch'] >= 0) and (
                    (k_line['sfn'] == last_pucch_sfn) and (
                        k_line['slot'] > last_pucch_slot)) or (
                        k_line['sfn'] > last_pucch_sfn):  # 找pucch
                    curr_pucch = k_line['ulTdSchedSubcellData.numPrbToBeUsedForPucch']
                    # print('--------------------------')
                    # print('allocPRB=', curr_allocPRB)
                    curr_pucch_sfn = k_line['sfn']
                    curr_pucch_slot = k_line['slot']

                    # print('curr_Pucch =', curr_pucch)
                    # step3: find curr pusch, save to df
                    curr_pusch_slot = curr_pucch_slot + slot_delta
                    # print('pusch_sfn-slot:', k_line['sfn'], '-', curr_pusch_slot)
                    df_curr_slot = []
                    for line in df_curr_alloc:
                        if (int(line['slot']) == curr_pusch_slot) and (
                                int(line['sfn']) == curr_pucch_sfn):
                            df_curr_slot.append(line)
                    # checkdf_curr_slot非空

                    last_pucch_sfn = curr_pucch_sfn
                    last_pucch_slot = curr_pucch_slot
                    if (not _data_lost(df_curr_slot, curr_pucch_sfn, curr_pusch_slot)):
                        content = _Analys_curr_slot(
                            df_curr_slot, curr_allocPRB, curr_pucch, MaxPuschUL, df_output_index)
                        if content:
                            df_output.append(content)
                            df_output_index += 1
                            for_time += 1

    print('for_time:', for_time)
    if not for_time:
        raise Exception('not find any match line')
    # save the analysis results to csv
    # get the “.” string index
    index_point = filename.index('.')
    # get the substring before“.”
    filename_pre = filename[:index_point]

    check_output_filename_csv = filename_pre + "_Check.csv"
    _write_csv_with_dict_list(check_output_filename_csv, df_output, colu_list)

    # final check pass or fail
    if (_check_final_Result(df_output, rach_slot)):
        print('PASS')
        return 1
    else:
        raise Exception('Fail')
        return 0

    # x=input()
# check_7113_cell_rachslot('tti_no_pair.csv', 50, 19)
