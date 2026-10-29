'''
Author: Zhang Shuang
Funtion: reorder csv for different features with given front_col_list
'''
from Reorder_CSV import *
import re

front_col_list_CB008247_dl = [
    'rnti',
    'dlFdSchedData.beamType',
    'dlBeamData.dlSrsBmBestBeamPatternId',
    'dlBeamData.dlSrsBmPairBeams1stPatternId',
    'dlBeamData.dlSrsBmPairBeams2ndPatternId',
    'dlFdSchedData.bestPatternId',
    'dlFdSchedData.streamConfig.patternId1',
    'dlFdSchedData.streamConfig.patternId2',
    'dlFdSchedData.numOfPrb',
    'dlFdSchedData.ackNack']

front_col_list_CB008360 = [
    'rnti',
    'ulFdSchedData.virtualUeIndex',
    'ulFdSchedData.ulMuGroupStatus',
    'ulFdSchedData.ulMuStatus',
    'ulFdSchedData.subcellId',
    'ulFdSchedData.numOfLayers',
    'ulFdSchedData.requiredPrb',
    'ulFdSchedData.prbOfVirtualUe',
    'ulFdSchedData.numOfPrb',
    'ulHarqRxData.crcResult',
    'ulHarqRxData.dtx',
    'ulFdSchedData.txNumber',
    'ulFdSchedData.ulHarqProcessIndex',
    'ulFdSchedData.antPort',
    'ulFdSchedData.numCdmGroupNoData',
    'ulMuUeData.vUeTrace',
    'ulMuUeData.prbCompensationFactor',
    'ulFdSchedData.rrmTaperingCompensation',
    'ulBeamData.ulSrsBmBestBeamIndexH',
    'ulBeamData.ulSrsBmBestBeamIndexV',
    'ulFdSchedData.rrmMaxNumPrbUl',
    'ulFdSchedData.rrmUlUsedMcs',
    'ulFdSchedData.numOfUciAckBits',
    'ulFdSchedData.deltaMcs',
    'ulFdSchedData.startPrb',
    'ulFdSchedData.reScaledCorrAvgSinrReqPrb',
    'ulFdSchedData.reScaledCorrAvgSinrAllocPrb',
    'ulFdSchedData.estimatedMuSinr',
    'ulLaAverageSinr.estimatedMuSinr',
    'ulLaAverageSinr.rrmInstSinr',
    'ulLaAverageSinr.rrmInstSinrRank']

front_col_list_CB007113 = [
    'rnti',
    'physCellId',
    'ulFdSchedData.virtualUeIndex',
    'ulFdSchedData.ulMuGroupStatus',
    'ulFdSchedData.ulMuStatus',
    'ulFdSchedData.subcellId',
    'ulFdSchedData.numOfLayers',
    'ulFdSchedData.requiredPrb',
    'ulFdSchedData.prbOfVirtualUe',
    'ulFdSchedData.numOfPrb',
    'ulAllocatedPooledResourcesData.numAllocCellPrbUl',
    'ulTdSchedSubcellData.numAllocCellPrbUl',
    'ulTdSchedSubcellData.numPrbToBeUsedForPucch',
    'ulFdSchedData.rrmMaxNumPrbUl',
    'ulHarqRxData.crcResult',
    'ulHarqRxData.dtx',
    'ulFdSchedData.txNumber',
    'ulFdSchedData.ulHarqProcessIndex',
    'ulFdSchedData.antPort',
    'ulMuUeData.vUeTrace',
    'ulMuUeData.prbCompensationFactor',
    'ulFdSchedData.rrmTaperingCompensation',
    'ulBeamData.ulSrsBmBestBeamIndexH',
    'ulBeamData.ulSrsBmBestBeamIndexV',
    'ulFdSchedData.numCdmGroupNoData',
    'ulFdSchedData.rrmUlUsedMcs',
    'ulFdSchedData.numOfUciAckBits',
    'ulFdSchedData.deltaMcs',
    'ulFdSchedData.startPrb',
    'ulFdSchedData.reScaledCorrAvgSinrReqPrb',
    'ulFdSchedData.reScaledCorrAvgSinrAllocPrb',
    'ulFdSchedData.estimatedMuSinr',
    'ulLaAverageSinr.estimatedMuSinr',
    'ulLaAverageSinr.rrmInstSinr',
    'ulLaAverageSinr.rrmInstSinrRank',
    'ulLaPhr.rrmPhrScaled']

front_col_list_CB010659 = [
    'rnti',
    'ulFdSchedData.adaptRetxStatus',
    'ulFdSchedData.PRBCandRetx',
    'ulFdSchedData.PRBMinRetx',
    'ulFdSchedData.PRBMaxCodeRateRetx',
    'ulFdSchedData.rrmUlUsedMcs',
    'ulFdSchedData.numOfPrb',
    'ulFdSchedData.txNumber',
    'ulHarqRxData.crcResult',
    'ulHarqRxData.dtx',
    'ulFdSchedData.ulHarqProcessIndex',
    'ulFdSchedData.numOfUciAckBits',
    'ulFdSchedData.SLIV',
    'ulFdSchedData.redundancyVersion',
    'ulFdSchedData.rePerPrbInitTx',
    'ulFdSchedData.rePerPrbReTx',
    'ulFdSchedData.tbSize',
    # 'ulAllocatedPooledResourcesData.numAllocCellPrbUl',
    'ulTdSchedSubcellData.numAllocCellPrbUl',
    'ulTdSchedSubcellData.numPrbToBeUsedForPucch',
    'ulFdSchedData.ueData.rrmAvgSinrTpSwitch',
    'ulFdSchedData.puschTPstate',
    'ulFdSchedData.virtualUeIndex',
    'ulFdSchedData.ulMuGroupStatus',
    'ulFdSchedData.ulMuStatus',
    'ulFdSchedData.subcellId',
    'ulFdSchedData.numOfLayers',
    'ulFdSchedData.requiredPrb',
    'ulFdSchedData.prbOfVirtualUe',
    'ulMuUeData.prbCompensationFactor',
    'ulFdSchedData.rrmTaperingCompensation',
    'ulTdSchedSubcellData.numPrbToBeUsedForPucch',
    'ulFdSchedData.rrmMaxNumPrbUl',
    'ulMuUeData.vUeTrace',
    'ulFdSchedData.antPort',
    'ulFdSchedData.numCdmGroupNoData',
    'ulFdSchedData.numOfUciAckBits',
    'ulFdSchedData.deltaMcs',
    'ulFdSchedData.startPrb',
    'ulFdSchedData.estimatedMuSinr',
    'ulLaAverageSinr.estimatedMuSinr',
    'ulLaAverageSinr.rrmInstSinr']

front_col_list_CB008322_dl = [
    'rnti',
    'dlFdSchedData.beamType',
    'dlFdSchedData.rtBeamFailureReason',
    'srsSwitchMeasData.srsSwitchMeas',
    'rnti_',
    'isSPIDUe',
    'srsState',
    'schedPrbRatioM100',
    'rtBeamNewTxNackRatioM100',
    'volatilityStatus',
    'spectrumEfficiencyM100',
    'corrSquareM10000',
    'sinrAvg',
    'srsEpreLinear',
    'srsEpreLinearThd',
    'powerDiffLinear',
    'numOfSrsBufCheck',
    'numOfSrsRlqCheck',
    'sampleDlBufHi',
    'sampleDlBufLo',
    'sampleRlqGood',
    'sampleRlqBad',
    'sampleInterferenceHi',
    'wbSrsConstraintState',
    'accumulatedTpc',
    # 'measGapAndWbSrsOverlapStatus',
    'dlFdSchedData.streamConfig.patternId1',
    'dlFdSchedData.streamConfig.patternId2',
    'csiSrReportData.csiReport.ri',
    'dlFdSchedData.numOfLayers',
    'dlFdSchedData.ackNack',
    'dlFdSchedData.rrmDlUsedMcs',
    'dlFdSchedData.rrmDlProposedMcs',
    'csiSrReportData.csiReport.cqi',
    'dlFdSchedData.numOfPrb',
    'csiRsSchedData.patternId1',
    'csiRsSchedData.patternId2',
    'csiRsSchedData.patternId3',
    'csiRsSchedData.patternId4',
    'dlSrsBmData.numOfSrsBmCalcUePerSlot',
    'dlSrsBmData.numOfSrsBmCalcUePending',
    'dlFdSchedData.streamConfig.numStreamIndex',
    'dlFdSchedData.streamConfig.streamIndex1',
    'dlFdSchedData.streamConfig.streamIndex2',
    'dlFdSchedData.streamConfig.streamIndex3',
    'dlFdSchedData.streamConfig.streamIndex4',
    'csiRsSchedData.density',
    'csiRsSchedData.eCpriConfigFourPatternIds.numCeAxcIndex',
    'csiRsSchedData.eCpriConfigFourPatternIds.ceAxcIndex1',
    'csiRsSchedData.eCpriConfigFourPatternIds.ceAxcIndex2',
    'csiRsSchedData.eCpriConfigFourPatternIds.ceAxcIndex3',
    'csiRsSchedData.eCpriConfigFourPatternIds.ceAxcIndex4']

front_col_list_CB008322_dl_gnb_tool = [
    'rnti',
    'ackNack',
    'rxPower',
    'rssi',
    'noisePower',
    'beamType',
    'rtBeamFailureReason',
    'isSPIDUe',
    'rtBeamNewTxNackRatioM100',
    'volatilityStatus',
    'srsState',
    'schedPrbRatioM100',
    'spectrumEfficiencyM100',
    'corrSquareM10000',
    'sinrAvg',
    'srsEpreLinear',
    'srsEpreLinearThd',
    'powerDiffLinear',
    'numOfDlTrafficCheck',
    'numOfSrsRlqCheck',
    'sampleDlTrafficHi',
    'sampleDlTrafficLo',
    'sampleRlqGood',
    'sampleRlqBad',
    'wbSrsConstraintState',
    'patternId1',
    'patternId2',
    'patternId3',
    'patternId4',
    'numOfPrb',
    'numOfLayers',
    'ri',
    'rrmDlUsedMcs',
    'rrmDlProposedMcs',
    'cqi',
    'density',
    'numCeAxcIndex']

front_col_list_CB009235_GL_TA_tti = [
    'rnti',
    'dlFdSchedData.macCe.numTciStateInd',
    'dlBeamData.currentBestBeamId',
    'dlTdSchedSubcellData.resReqClassSubPrio',
    'dlTdSchedSubcellData.resReqClassPrio',
    'dlFdSchedData.muStatus',
    'dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1',
    'dlMuAwareTdSchInfo.nonCorrCheckUeListAfterStep1',
    'dlFdSchedData.requiredPrbForMuAwareTdSch',
    'dlPreTdBlockUeData.cs2BlockUeList',
    'dlLoadControlData.csListInfo.cs2ListMaxSize',
    'dlTdSchedSubcellData.cs2Size',
    'dlLoadControlData.csListInfo.numOfUesInPreSchedCandSet',
    'dlLoadControlData.csListInfo.rrmMaxNumUesFdmOlc',
    'dlLoadControlData.fdSchedInfo[0].numOfSchedUesInInitBwp',
    'dlLoadControlData.fdSchedInfo[0].numToBeScheduledUes',
    'dlLoadControlData.fdSchedInfo[0].scheduledUes',
    'dlPagingOrSibSchedData.dciFormat',
    'dlFdSchedData.numOfLayers',
    'csiSrReportData.csiReport.ri',
    'dlFdSchedData.ackNack',
    'dlFdSchedData.rrmCorrAvgCqi',
    'dlFdSchedData.rrmDlUsedMcs',
    'dlFdSchedData.txNumber',
    'dlFdSchedData.dlHarqProcessIndex',
    'dlFdSchedData.scheduledBytesPerBearer[4]',
    'dlFdSchedData.remainingBytesPerBearerInFdEoBuffer[4]',
    'dlFdSchedData.rrmtotalDrbBufferedBytes',
    'dlFdSchedData.remainingDataVolumeDl',
    'dlFdSchedData.beamType',
    'dlBeamData.dlSrsBmBestBeamPatternId',
    'dlBeamData.dlSrsBmPairBeams1stPatternId',
    'dlBeamData.dlSrsBmPairBeams2ndPatternId',
    'dlFdSchedData.startPrb',
    'dlFdSchedData.numOfPrb',
    'dlFdSchedData.rat0Bitmap',
    'dlFdSchedData.bestBeamPowerOffset',
    'dlFdSchedData.muPdschPowerOffset',
    'dlFdSchedData.suPdschTbTransmitPower',
    'dlFdSchedData.numOfNonVoNRGbrPrb',
    'dlFdSchedData.streamConfig.numStreamIndex',
    'dlFdSchedData.streamConfig.patternId1',
    'dlFdSchedData.streamConfig.patternId2',
    'dlFdSchedData.streamConfig.streamIndex1',
    'dlFdSchedData.streamConfig.streamIndex2',
    'dlFdSchedData.streamConfig.streamIndex3',
    'dlFdSchedData.streamConfig.streamIndex4']

front_col_list_CB012269_dl = [
    'physCellId',
    'dlAllocatedPooledResourcesData.hasZabPrivilege',
    'rnti',
    'csiRsSchedData.csiRsConfig',
    'csiRsSchedData.startSymbol',
    'csiRsSchedData.csiTransmitPower',
    'dlFdSchedData.numOfLayers',
    'dlFdSchedData.rrmDlProposedMcs',
    'dlFdSchedData.SLIV',
    'dlFdSchedData.dciFormat',
    'dlFdSchedData.txNumber',
    'dlFdSchedData.ackNack',
    'pdschRateMatchingData.rateMatchingOption',
    'dlTdSchedUeDrxState.disable',
    'dlTdSchedUeDrxState.onDurationTimer',
    'pdschRateMatchingData.numRateMatchingRes',
    'dlFdSchedData.rrmDlUsedMcs',
    'dlFdSchedData.adaptRetxStatus',
    'dlPreTdBlockUeData.cs2BlockUeList',
    'csiRsSchedData.density',
    'csiRsSchedData.startPrb',
    'csiRsSchedData.numOfPrb',
    'csiSrReportData.csiReport.cqi',
    'csiSrReportData.csiReport.ri',
    'dlFdSchedData.numOfPrb',
    'dlFdSchedData.beamType',
    'dlFdSchedData.streamConfig.patternId1',
    'dlFdSchedData.streamConfig.patternId2',
    'csiRsSchedData.patternId1',
    'csiRsSchedData.patternId2',
    'csiRsSchedData.patternId3',
    'csiRsSchedData.patternId4']


def reorder_csv_CB008247(filename):
    reorder_csv(filename, front_col_list_CB008247_dl)


def reorder_csv_CB008360(filename):
    reorder_csv(filename, front_col_list_CB008360)


def reorder_csv_CB007113(filename):
    reorder_csv(filename, front_col_list_CB007113)


def reorder_csv_CB010659(filename):
    reorder_csv(filename, front_col_list_CB010659)


def reorder_csv_CB008322(filename):
    reorder_csv(filename, front_col_list_CB008322_dl)


def reorder_csv_CB008322_gnb_tool(filename):
    reorder_csv(filename, front_col_list_CB008322_dl_gnb_tool)


def reorder_csv_CB009235_TA_tti_V1(filename):
    reorder_csv(filename, front_col_list_CB009235_GL_TA_tti)


def reorder_csv_CB012269(filename):
    reorder_csv(filename, front_col_list_CB012269_dl)


# split_8322_tti
def get_split_title(string_line):
    list_new_key = []
    index = 0
    char_1 = False
    for i in string_line:
        if (i == "'") and (not char_1):  # '
            start_index = index
            char_1 = True
        elif i == "'" and char_1:  # 'xxx'
            if string_line[index + 1] == ":":  # 'xxx':
                second_index = index
                find_str = string_line[start_index + 1:index]
                list_new_key.append(find_str)
            char_1 = False
        index += 1
    return list_new_key


def find_substring(string, substring):
    pattern = re.compile(substring)
    matches = pattern.finditer(string)
    indices = [match.end() for match in matches]
    return indices


def get_value_of_new_key(new_key, srsSwitchMeas):
    indices = find_substring(srsSwitchMeas, new_key)
    # print(indices[0])
    i_value_start = indices[0] + 3
    # print("i_Start:",i_value_start,srsSwitchMeas[i_value_start])
    for_i = i_value_start
    for ch in srsSwitchMeas[for_i:]:
        if ch == "," or ch == "}":  # ","  or the end of string
            index_stop = for_i
            # print('stop:',index_stop)
            # print(srsSwitchMeas[i_value_start:index_stop])
            break
        for_i += 1
    return srsSwitchMeas[i_value_start:index_stop]


def add_new_key_to_title(csv_filename, output_filename, list_new_key):
    with open(csv_filename, 'r') as file:
        reader = csv.reader(file)
        rows = list(reader)
        # 在每行的最后一列添加新的数据
        for row in rows:
            for i in list_new_key:
                row.append(i)
            break

    with open(output_filename, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(rows)


def add_new_value_to_line(list_new_kew, i_line):
    list_new_value = []
    string1 = i_line['srsSwitchMeasData.srsSwitchMeas']
    for i in list_new_kew:
        list_new_value.append(get_value_of_new_key(i, string1))
    rnti_index = list_new_kew.index('rnti')
    title_key = list_new_kew.copy()
    title_key[rnti_index] = 'rnti_'
    new_dict = dict(zip(title_key, list_new_value))
    i_line['rnti_'] = new_dict['rnti_']
    i_line['srsState'] = new_dict['srsState']
    i_line['schedPrbRatioM100'] = new_dict['schedPrbRatioM100']
    i_line['rtBeamNewTxNackRatioM100'] = new_dict['rtBeamNewTxNackRatioM100']
    i_line['volatilityStatus'] = new_dict['volatilityStatus']
    i_line['spectrumEfficiencyM100'] = new_dict['spectrumEfficiencyM100']
    i_line['corrSquareM10000'] = new_dict['corrSquareM10000']
    i_line['sinrAvg'] = new_dict['sinrAvg']
    i_line['srsEpreLinear'] = new_dict['srsEpreLinear']
    i_line['srsEpreLinearThd'] = new_dict['srsEpreLinearThd']
    i_line['powerDiffLinear'] = new_dict['powerDiffLinear']
    i_line['numOfDlTrafficCheck'] = new_dict['numOfDlTrafficCheck']
    i_line['numOfSrsRlqCheck'] = new_dict['numOfSrsRlqCheck']
    i_line['sampleDlTrafficHi'] = new_dict['sampleDlTrafficHi']
    i_line['sampleDlTrafficLo'] = new_dict['sampleDlTrafficLo']
    i_line['sampleRlqGood'] = new_dict['sampleRlqGood']
    i_line['sampleRlqBad'] = new_dict['sampleRlqBad']
    i_line['isSPIDUe'] = new_dict['isSPIDUe']
    i_line['sampleInterferenceHi'] = new_dict['sampleInterferenceHi']
    i_line['wbSrsConstraintState'] = new_dict['wbSrsConstraintState']
    i_line['accumulatedTpc'] = new_dict['accumulatedTpc']
    # i_line['measGapAndWbSrsOverlapStatus'] = new_dict['measGapAndWbSrsOverlapStatus']
    return i_line


def filename_before_csv(filename):
    index_point = find_substring(filename, '.csv')[0] - 4
    filename_before_csv = filename[:index_point]
    return filename_before_csv


def split_8322_tti(csv_filename):
    with open(csv_filename, 'r') as f_in:
        list_reader = list(csv.DictReader(f_in))
        list_key = []
        for key in list_reader[0]:
            list_key.append(key)

    for i_line in list_reader:
        if i_line['srsSwitchMeasData.srsSwitchMeas']:
            list_new_key = get_split_title(
                i_line['srsSwitchMeasData.srsSwitchMeas'])
            break
    title_list = list_new_key.copy()
    rnti_index = title_list.index('rnti')
    title_list[rnti_index] = 'rnti_'

    file_name_pre = filename_before_csv(csv_filename)
    file_add_new_key = file_name_pre + '_tmp.csv'
    add_new_key_to_title(csv_filename, file_add_new_key, title_list)
    reorder_csv_CB008322(file_add_new_key)
    file_new_key_reorder = file_name_pre + '_tmp_Reorder.csv'
    final_file_name = file_name_pre + '_split.csv'
    with open(file_new_key_reorder, 'r') as infile:
        list_reader = list(csv.DictReader(infile))
        list_r = list_reader.copy()

        for i_line in list_reader:
            if i_line['srsSwitchMeasData.srsSwitchMeas']:
                i_line = add_new_value_to_line(list_new_key, i_line)
        fieldname = []
    for i in list_r[0]:
        fieldname.append(i)

    with open(final_file_name, 'w', encoding='utf8', newline='') as outfile:
        outfile.seek(0)  # 重置文件指针到首
        writer = csv.DictWriter(
            outfile, fieldnames=fieldname)  # reorder as reorder_col
        writer.writeheader()
        for row in list_r:
            writer.writerow(row)

    if os.path.exists(file_add_new_key):
        os.remove(file_add_new_key)
    if os.path.exists(file_new_key_reorder):
        os.remove(file_new_key_reorder)


# split_8322_tti('pn.0.1.csv')
