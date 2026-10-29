import json
import argparse


class ThputCheckpointException(Exception):
    pass


class McsCheckpointException(Exception):
    pass


class RankCheckpointException(Exception):
    pass


class ValleyCheckpointException(Exception):
    pass


class LaVerification:
    def __init__(self):
        self.content = None
        self.dl_params = None
        self.ul_params = None
        self.att_data = None
        self.dl_data = None
        self.ul_data = None
        self.valley_indices = None

    def _get_content_from_json_file(self, filename):
        f = open(filename, 'r')
        content = f.read()
        dict_con = json.loads(content)
        # print(type(dict_con))
        # print(dict_con)
        f.close()
        self.content = dict_con

    def get_data_from_json_file(self, filename, dl_param_list, ul_param_list, x_key='att'):
        self._get_content_from_json_file(filename)
        self.dl_params = dl_param_list[0] if __name__ == '__main__' else dl_param_list
        self.ul_params = ul_param_list[0] if __name__ == '__main__' else ul_param_list
        x_name = x_key
        # x_values = []
        dl_y_keys = self.dl_params
        ul_y_keys = self.ul_params
        dl_y_values = []
        ul_y_values = []
        # print(self.content['DL LA test result'])
        for param in self.dl_params:
            x_value = []
            dl_y_value = []
            for item in self.content['DL LA test result']:
                for parm_name, parm_value in item.items():
                    if parm_name == param:
                        dl_y_value.append(float(parm_value))
                    if parm_name == x_name:
                        x_value.append(parm_value)
            dl_y_values.append(dl_y_value)

        for param in self.ul_params:
            ul_y_value = []
            for item in self.content['UL LA test result']:
                for parm_name, parm_value in item.items():
                    if parm_name == param:
                        ul_y_value.append(float(parm_value))
            ul_y_values.append(ul_y_value)
        self.att_data = [int(i) for i in x_value]
        self.dl_data = dict(zip(dl_y_keys, dl_y_values))
        self.ul_data = dict(zip(ul_y_keys, ul_y_values))
        print('Attenuator data is:\r\n{}\r\n'.format(self.att_data))
        print('The data for DL:\r\n{}\r\n'.format(self.dl_data))
        print('The data for UL:\r\n{}\r\n'.format(self.ul_data))

    def verify_checkpoints(self, direction, peak_thput, max_mcs=27, max_rank=4):
        res = None
        direction_upper = direction.strip().upper()
        print("The verification for {} LA is started! \r\n".format(direction_upper))
        peak_times = 0
        max_mcs_times = 0
        max_rank_times = 0
        max_att = max(self.att_data)
        self.valley_indices = [i for i, j in enumerate(self.att_data) if j == max_att]
        content_to_check = self.dl_data.items() if direction_upper == 'DL' else self.ul_data.items()
        for param_name, param_values in content_to_check:
            try:
                #  checkpoint 1: The expected peak appears 3 times
                if param_name == 'NR PDCP Thr. ' + direction_upper + ' [Mbps]':
                    temp_values = param_values.copy()
                    thput_valley = sorted(temp_values, reverse=False)[:2]
                    # print(thput_valley)
                    thput_valley_indices = [i for i, j in enumerate(param_values) if j in thput_valley]
                    print('The ' + direction_upper + 'thput valleys are {}, locating at: {}.'
                          .format(thput_valley, thput_valley_indices))
                    for index, value in enumerate(param_values):
                        peak_times = peak_times + 1 if value >= float(peak_thput) * 0.95 else peak_times
                        if value >= float(peak_thput) * 0.95:
                            print('The ' + direction_upper + 'Thput peak {} appears at the index of {}'
                                  .format(value, index))
                    if peak_times < 3:
                        raise ThputCheckpointException
                    else:
                        print('Congrats! ' + direction_upper + ' Peak throughput requirement is met.')

                #  checkpoint 2:  max mcs is reached 3 times.
                if param_name == 'NR MCS Avg. ' + direction_upper:
                    temp_values = param_values.copy()
                    mcs_valley = sorted(temp_values)[:2]
                    # print(mcs_valley)
                    mcs_valley_indices = [i for i, j in enumerate(param_values) if j in mcs_valley]
                    print('Mcs valleys locate at: {}, and indices are: {}.'.format(mcs_valley, mcs_valley_indices))
                    for index, value in enumerate(param_values):
                        max_mcs_times = max_mcs_times + 1 if value >= float(max_mcs) else max_mcs_times
                        if value >= float(max_mcs):
                            print('The ' + direction_upper + 'maximum mcs {} appears at the index of {}'
                                  .format(value, index))
                    if max_mcs_times < 3:
                        raise McsCheckpointException
                    else:
                        print('Congrats! ' + direction_upper + ' Maximum mcs requirement is met.')

                #  checkpoint 3:  max rank is reached 3 times at least
                if param_name == 'NR Rank Avg. ' + direction_upper:
                    # temp_values = param_values.copy()
                    # rank_valley = sorted(temp_values)[:2]
                    # rank_valley_indices = [i for i, j in enumerate(param_values) if j in rank_valley]
                    # print(rank_valley_indices)
                    for index, value in enumerate(param_values):
                        max_rank_times = max_rank_times + 1 if value >= float(max_rank) else max_rank_times
                        if value >= float(max_rank):
                            print('The ' + direction_upper + 'maximum rank {} appears at the index of {}'
                                  .format(value, index))
                    if max_rank_times < 3:
                        raise RankCheckpointException
                    else:
                        print('Congrats! ' + direction_upper + ' Maximum rank requirement is met.')

                # checkpoint 4: Thput, MCS, and RSRP: the 2 valley values of the 3 parmeters appear at
                # the same point (maximum att).
                if param_name == 'NR SSB RSRP[dBm]':
                    temp_values = param_values.copy()
                    rsrp_valley = sorted(temp_values)[:2]
                    rsrp_valley_indices = [i for i, j in enumerate(param_values) if j in rsrp_valley]
                    print('rsrp valleys locate at: {}, and indices are: {}.'.format(rsrp_valley, rsrp_valley_indices))
                    # print(all(i in mcs_valley_indices for i in rsrp_valley_indices))
                    # print(all(i in thput_valley_indices for i in rsrp_valley_indices))

                    # check_exact = all(i in mcs_valley_indices for i in rsrp_valley_indices) and all(
                    #     i in thput_valley_indices for i in rsrp_valley_indices)
                    check_exact_mcs = all(i in mcs_valley_indices for i in rsrp_valley_indices)
                    check_exact_thput = all(i in thput_valley_indices for i in rsrp_valley_indices)

                    # check_coarse = all(i-1 in mcs_valley_indices or
                    #                    i+1 in mcs_valley_indices for i in rsrp_valley_indices) and all(
                    #     i-1 in thput_valley_indices or i+1 in thput_valley_indices for i in rsrp_valley_indices)
                    check_coarse_mcs = all(i - 1 in mcs_valley_indices or i + 1 in mcs_valley_indices
                                           for i in rsrp_valley_indices)
                    check_coarse_thput = all(i - 1 in thput_valley_indices or i + 1 in thput_valley_indices
                                             for i in rsrp_valley_indices)
                    # print('Results are {}, {}, and {}.'.format(check_exact, check_rough_left, check_rough_light))
                    print("Result for mcs valley checking is {}.".format(check_exact_mcs or check_coarse_mcs))
                    print("Result for thput valley checking is {}.".format(check_exact_thput or check_coarse_thput))
                    if not (check_exact_mcs or check_coarse_mcs) and (check_exact_thput or check_coarse_thput):
                        raise ValleyCheckpointException
                    else:
                        print('Congrats! ' + direction_upper + ' Valley-value position requirement is met.')

            except ThputCheckpointException:
                res = False
                print('Oops! ' + direction_upper + ' Peak throughput requirement is not met.')
            except McsCheckpointException:
                res = False
                print('Oops! ' + direction_upper + ' Maximum mcs requirement is not met.')
            except RankCheckpointException:
                res = False
                print('Oops! ' + direction_upper + ' Maximum rank requirement is not met.')
            except ValleyCheckpointException:
                res = False
                print('Oops! ' + direction_upper + ' Valley-value position requirement is not met.')
            else:
                res = True
        print("The verification result for {} LA is {}. \r\n".format(direction_upper, res))
        return res


def main():
    parser = argparse.ArgumentParser(
        description="Verify Link Adaption!")
    parser.add_argument(
        "file",
        help="str: Path of the jason file holding input data.")
    args = parser.parse_args()

    # my_file = args.file
    la = LaVerification()
    pram_names_for_dl = ['NR PDCP Thr. DL [Mbps]', 'NR PDSCH iBLER[%]', 'NR MCS Avg. DL',
                         'NR Rank Avg. DL', 'NR SSB RSRP[dBm]', ],
    pram_names_for_ul = ['NR PDCP Thr. UL [Mbps]', 'NR PUSCH iBLER[%]', 'NR MCS Avg. UL',
                         'NR Rank Avg. UL', 'NR SSB RSRP[dBm]', ],
    # my_file = '/home/ute/Cell_Edge_History/SBTS22R3_ENB_9999_220304_000007_20220307_111539.json'
    # my_file = '/home/ute/Cell_Edge_History/SBTS22R1_ENB_0000_001469_000000_20220223_220727.json'
    data_file = '/home/ute/Cell_Edge_History/SBTS22R3_ENB_9999_220307_000009_20220307_215056.json'
    la.get_data_from_json_file(filename=args.file, dl_param_list=pram_names_for_dl, ul_param_list=pram_names_for_ul)
    la.verify_checkpoints(direction='dl', peak_thput=1500, max_mcs=26, max_rank=4)
    la.verify_checkpoints(direction='ul', peak_thput=160, max_mcs=27, max_rank=2)


if __name__ == '__main__':
    main()
