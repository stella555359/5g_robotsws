import csv
import os

# 5G_UP_ALG_16365
mcs_table_ptrson_data = {
    '2': {0: -2, 1: -1, 2: 0, 3: 0, 4: 1, 5: 2, 6: 3, 7: 4, 8: 5, 9: 6, 10: 6,
          11: 7, 12: 8, 13: 9, 14: 10, 15: 11, 16: 12, 17: 13, 18: 14, 19: 15, 20: 16,
          21: 17, 22: 19, 23: 20, 24: 22, 25: 24, 26: 25, 27: 27},
    '3': {0: -3, 1: -2, 2: -1, 3: 0, 4: 0, 5: 1, 6: 2, 7: 3, 8: 4, 9: 5, 10: 6,
          11: 6, 12: 7, 13: 8, 14: 9, 15: 10, 16: 11, 17: 12, 18: 13, 19: 14, 20: 15,
          21: 16, 22: 17, 23: 18, 24: 20, 25: 23, 26: 24, 27: 26},
    '3': {0: -3, 1: -2, 2: -1, 3: 0, 4: 0, 5: 1, 6: 2, 7: 3, 8: 4, 9: 5, 10: 6,
          11: 6, 12: 7, 13: 8, 14: 9, 15: 10, 16: 11, 17: 12, 18: 13, 19: 14, 20: 15,
          21: 16, 22: 17, 23: 18, 24: 20, 25: 23, 26: 24, 27: 26},
    '4': {0: -3, 1: -2, 2: -2, 3: -1, 4: 0, 5: 0, 6: 1, 7: 2, 8: 3, 9: 4, 10: 5,
          11: 6, 12: 6, 13: 7, 14: 8, 15: 9, 16: 10, 17: 11, 18: 12, 19: 13, 20: 14,
          21: 15, 22: 16, 23: 17, 24: 19, 25: 21, 26: 23, 27: 25},
    '8': {0: -4, 1: -3, 2: -2, 3: -1, 4: 0, 5: 0, 6: 1, 7: 2, 8: 3, 9: 4, 10: 4,
          11: 5, 12: 6, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
          21: 14, 22: 15, 23: 16, 24: 17, 25: 19, 26: 20, 27: 24},
    '16': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3, 10: 4,
           11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
           21: 14, 22: 15, 23: 16, 24: 17, 25: 18, 26: 20, 27: 21},
    '64': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3, 10: 4,
           11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
           21: 14, 22: 15, 23: 16, 24: 17, 25: 18, 26: 19, 27: 21},
    '128': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3, 10: 4,
            11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
            21: 14, 22: 15, 23: 16, 24: 17, 25: 18, 26: 19, 27: 20},
    '270': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3, 10: 3,
            11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
            21: 14, 22: 15, 23: 16, 24: 17, 25: 18, 26: 19, 27: 20},
}
# 5G_UP_ALG_16365
mcs_table_ptrsoff_data = {
    '2': {0: -3, 1: -2, 2: -1, 3: 0, 4: 0, 5: 1, 6: 2, 7: 2, 8: 3, 9: 4, 10: 5,
          11: 5, 12: 6, 13: 7, 14: 8, 15: 9, 16: 10, 17: 11, 18: 12, 19: 13, 20: 14,
          21: 15, 22: 16, 23: 17, 24: 18, 25: 19, 26: 20, 27: 21},
    '3': {0: -3, 1: -3, 2: -2, 3: -1, 4: 0, 5: 0, 6: 1, 7: 2, 8: 3, 9: 4, 10: 4,
          11: 5, 12: 6, 13: 7, 14: 8, 15: 9, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
          21: 14, 22: 15, 23: 16, 24: 18, 25: 18, 26: 19, 27: 21},
    '4': {0: -4, 1: -3, 2: -2, 3: -1, 4: 0, 5: 0, 6: 1, 7: 2, 8: 3, 9: 3, 10: 4,
          11: 5, 12: 6, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13,
          21: 14, 22: 15, 23: 16, 24: 17, 25: 18, 26: 19, 27: 20},
    '8': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3,
          10: 4, 11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11,
          19: 12, 20: 13, 21: 14, 22: 15, 23: 16, 24: 16, 25: 17, 26: 19, 27: 20},
    '16': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3,
           10: 3, 11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11,
           19: 11, 20: 12, 21: 13, 22: 14, 23: 15, 24: 16, 25: 17, 26: 19, 27: 20},
    '64': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3,
           10: 3, 11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11,
           19: 11, 20: 12, 21: 13, 22: 14, 23: 15, 24: 16, 25: 17, 26: 18, 27: 20},
    '128': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3,
            10: 3, 11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 8, 17: 10, 18: 11,
            19: 11, 20: 12, 21: 13, 22: 14, 23: 15, 24: 16, 25: 17, 26: 18, 27: 20},
    '270': {0: -5, 1: -4, 2: -3, 3: -2, 4: -1, 5: 0, 6: 0, 7: 1, 8: 2, 9: 3,
            10: 3, 11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 8, 17: 10, 18: 11,
            19: 11, 20: 12, 21: 13, 22: 14, 23: 15, 24: 16, 25: 17, 26: 18, 27: 20},

}


def cb009198_check_mcs_sinr(csv_filename, rach_slot):
    ERR_flag = False
    with open(csv_filename, 'r') as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        list_reader_copy = list_reader

        for i_line in list_reader:
            puschTPstate = i_line['ulFdSchedData.puschTPstate']
            ptrsFlagUlProposedMcs = i_line['ulFdSchedData.ptrsFlagUlProposedMcs']
            reScaledCorrAvgSinrPreAtb = i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrPreAtb']
            UlProposedMcs = i_line['ulFdSchedData.rrmUlProposedMcs']
            rrmUlUsedMcs = i_line['ulFdSchedData.rrmUlUsedMcs']
            numofPrb = i_line['ulFdSchedData.numOfPrb']
            reScaledCorrAvgSinrAtb = i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrAtb']
            sinrOffsetUciInPusch = i_line['ulFdSchedData.ueData.sinrOffsetUciInPusch']
            isScalingDone = i_line['ulFdSchedData.isScalingDone']
            ulHarqProcessIndex = i_line["ulFdSchedData.ulHarqProcessIndex"]
            sfn = int(float(i_line['sfn']))
            slot = int(float(i_line['slot']))
            rnti = i_line['rnti']

            if puschTPstate and reScaledCorrAvgSinrPreAtb and UlProposedMcs and numofPrb \
                    and reScaledCorrAvgSinrAtb and sinrOffsetUciInPusch:
                if puschTPstate == "2.0" and ptrsFlagUlProposedMcs != 'PTRS_VOID' and slot != rach_slot:
                    reScaledCorrAvgSinrPreAtb = float(reScaledCorrAvgSinrPreAtb)
                    UlProposedMcs = int(float(UlProposedMcs))
                    rrmUlUsedMcs = int(float(rrmUlUsedMcs))
                    numofPrb = int(float(numofPrb))
                    reScaledCorrAvgSinrAtb = float(reScaledCorrAvgSinrAtb)
                    sinrOffsetUciInPusch = float(sinrOffsetUciInPusch)
                    isScalingDone = int(float(isScalingDone))
                    sinr_end = reScaledCorrAvgSinrAtb - sinrOffsetUciInPusch
                    if ptrsFlagUlProposedMcs == 'PTRS_ON':
                        df_mcs = mcs_table_ptrson_data
                    elif ptrsFlagUlProposedMcs == 'PTRS_OFF':
                        df_mcs = mcs_table_ptrsoff_data
                    required_sinr = get_requied_sinr(df_mcs, UlProposedMcs, numofPrb)
                    if not required_sinr:
                        continue
                    if UlProposedMcs + 1 < 28:
                        next_requird_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                    requird_sinr_usedmcs = get_requied_sinr(df_mcs, rrmUlUsedMcs, numofPrb)
                    if required_sinr < sinr_end < next_requird_sinr and rrmUlUsedMcs == UlProposedMcs:
                        print("UlProposedMcs:", UlProposedMcs, "rrmUlUsedMcs:", rrmUlUsedMcs, "required sinr:",
                              required_sinr, "actual sinr:", sinr_end, "numofprb:", numofPrb)
                    elif UlProposedMcs == 0 and rrmUlUsedMcs == 0 and reScaledCorrAvgSinrPreAtb < sinr_end \
                            and sinr_end > required_sinr:
                        print("Mcs 0 for sfn:", sfn, "error slot:", slot)
                    elif UlProposedMcs > rrmUlUsedMcs and sinr_end > requird_sinr_usedmcs:
                        print("Scaling, required sinr:", requird_sinr_usedmcs, "actual sinr:", sinr_end, "used mcs:",
                              rrmUlUsedMcs, "numofprb:", numofPrb)
                    elif rrmUlUsedMcs == 27 and sinr_end > requird_sinr_usedmcs:
                        print("UlProposedMcs:", UlProposedMcs, "rrmUlUsedMcs:", rrmUlUsedMcs, "required sinr:",
                              required_sinr,
                              "actual sinr:", sinr_end, "numofprb:", numofPrb)
                    elif sinr_end < required_sinr:
                        ERR_flag = True
                        print("Mcs error for sfn:", sfn, "error slot:", slot,
                              "actual sinr should bigger than required sinr, actual sinr:", sinr_end,
                              "required sinr:", required_sinr, "numofprb:", numofPrb)
                elif puschTPstate == "2.0" and ptrsFlagUlProposedMcs == 'PTRS_VOID':
                    PTRS_VOID_FLAG = False
                    ulHarqProcessIndex = int(float(ulHarqProcessIndex))
                    rnti = int(i_line['rnti'])
                    rrmUlUsedMcs = int(float(rrmUlUsedMcs))
                    curr_index = list_reader.index(i_line)
                    for index in range(curr_index, 1, -1):
                        re_rnti = int(list_reader_copy[index]['rnti'])
                        re_harq = int(float(list_reader_copy[index]['ulFdSchedData.ulHarqProcessIndex']))
                        re_rrmUlUsedMcs = int(float(list_reader_copy[index]['ulFdSchedData.rrmUlUsedMcs']))
                        if re_rnti == rnti and re_harq == ulHarqProcessIndex and re_rrmUlUsedMcs == rrmUlUsedMcs:
                            print("PTRS_VOID, rrmUlUsedMcs:", rrmUlUsedMcs, "sfn:", sfn, "slot:", slot)
                            PTRS_VOID_FLAG = True
                            break
                    if not PTRS_VOID_FLAG:
                        ERR_flag = True
                        print("MCS err while PTRS_VOID,sfn:", sfn, "slot:", slot)
                        continue
    if not ERR_flag:
        print("All log passed! ")
    elif ERR_flag is True:
        print("Mcs table check failed! ")
        raise Exception('Fail')


def get_requied_sinr(df_file_mcs, UlProposedMcs, numofprb):
    requied_sinr = False
    if UlProposedMcs > 27:
        print("UlProposedMcs bigger than the table,UlProposedMcs", UlProposedMcs)
        return requied_sinr
    if numofprb > 128 and numofprb < 270:
        requied_sinr = \
            float(float((df_file_mcs['270'][UlProposedMcs] - df_file_mcs['128'][UlProposedMcs]) / 142)
                  * (numofprb - 128) + df_file_mcs['128'][UlProposedMcs])
    elif numofprb > 64 and numofprb < 128:
        requied_sinr = \
            float(float((df_file_mcs['128'][UlProposedMcs] - df_file_mcs['64'][UlProposedMcs]) / 64) * (numofprb - 64)
                  + df_file_mcs['64'][UlProposedMcs])
    elif numofprb > 16 and numofprb < 64:
        requied_sinr = \
            float(float((df_file_mcs['64'][UlProposedMcs] - df_file_mcs['16'][UlProposedMcs]) / 48) * (numofprb - 16)
                  + df_file_mcs['16'][UlProposedMcs])
    elif numofprb > 8 and numofprb < 16:
        requied_sinr = \
            float(float((df_file_mcs['16'][UlProposedMcs] - df_file_mcs['8'][UlProposedMcs]) / 8) * (numofprb - 8)
                  + df_file_mcs['8'][UlProposedMcs])
    elif numofprb > 4 and numofprb < 8:
        requied_sinr = \
            float(float((df_file_mcs['8'][UlProposedMcs] - df_file_mcs['4'][UlProposedMcs]) / 4) * (numofprb - 4)
                  + df_file_mcs['4'][UlProposedMcs])
    elif numofprb == 270 or numofprb == 128 or numofprb == 64 or numofprb == 16 or numofprb == 8 \
            or numofprb == 4 or numofprb == 3 or numofprb == 2:
        numofprb = str(int(numofprb))
        requied_sinr = df_file_mcs[numofprb][UlProposedMcs]
    return requied_sinr

# cb009198_check_mcs_sinr("C:/python-project/test_app/dist/SA_UE_pathloss_120_ul.csv", 19)
