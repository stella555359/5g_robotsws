"""
:copyright: Nokia Networks
:author: Mariusz Makuch
:contact: mariusz.makuch@nokia.com
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.3

This file uses pandas_gate.py and set_pandas.py scripts to install and import pandas.
pd = None at the beginning of this file was added for this purpose. Init pandas needs
to be called in test or testsuite for which there are files with pd = None i.e. files
which need pandas import.
"""

import csv

pd = None


class TtiCsvAnalysis:

    def filter_tti_csv_numofPrb_for_5_and_9_slots(self, csv_path, dir):
        """
        Filters NR TTI collected by KW Create Sbts L2stream Collector as csv.

        :param csv_path: Absolute path to directory where
               NR TTI are located, e.g.
               "home/ute/logs/TC__IWK__NR_MIN_RES/misc_logs"
        :param dir: NR TTI  direction. Used to select a csv file,
               value: "dl" or "ul"
        """

        file_path = csv_path + '/tcpdump_{}.csv'.format(dir)
        tti = pd.read_csv(file_path, low_memory=False)

        numOfPrb_column = tti.pop('dlFdSchedData.numOfPrb')
        tti.insert(5, 'numOfPrb', numOfPrb_column)

        tti = tti[tti['numOfPrb'].notnull()]
        tti = tti.drop(tti.iloc[:, 6:], axis=1)

        tti = tti[(tti.slot == 5) | (tti.slot == 9)]
        tti = tti[(tti.rnti != 0) & (tti.rnti != 65535)]

        tti.to_csv(csv_path + '/tcpdump_5_9_{}.csv'.format(dir), index=False)

    def check_numofprb_for_slot_5_and_9(self, csv_file, min_numOfPrb):
        """
        Checks if numOfPrb in slots 5 and 9 are bigger than expected

        :param csv_file: Absolute path to file where filtered
               NR TTI are located, e.g.
               "home/ute/logs/TC__IWK__NR_MIN_RES/misc_logs/tcpdump_5_9_dl.csv"
        :param min_numOfPrb: Minimum expected value of numOfPrb.
        :return False if numOfPrb are smaller than expected. True otherwise
        """

        tti = pd.read_csv(csv_file, low_memory=False)

        for row in tti[['numOfPrb']]:
            for numOfPrb in tti[row].values:
                if numOfPrb < float(min_numOfPrb):
                    return False
        return True

    def convert_csv_for_check_slot_and_rnti(self, csv_path, dir):
        """
        :param csv_path: Absolute path to directory where
               NR TTI are located, e.g.
               "home/ute/logs/TC_name/misc_logs"
        :param dir: NR TTI  direction. Used to select a csv file,
               value: "dl" or "ul"
        :return New file path
        """

        file_path = csv_path + '/tcpdump_{}.csv'.format(dir)

        tti = pd.read_csv(file_path, low_memory=False)
        tti = tti[tti['{}FdSchedData.dciFormat'.format(dir)].notnull()]
        new_file_path = csv_path + '/tcpdump_rnti_{}.csv'.format(dir)
        tti.to_csv(new_file_path, index=False)
        return new_file_path

    def check_rnti_in_one_slot_dl(self, input_file):
        """
        Checks if rnti's are in the same slots

        :param input_file: Absolute path to file where filtered
               NR TTI are located, e.g.
               "home/ute/logs/TC_name/misc_logs"
        :return False if rnti's are not in the same slots. True otherwise
        """

        input_file = csv.DictReader(open(input_file))
        vals_from_csv = []
        for row in input_file:
            tmp_list = [row['timeStamp'], row['sfn'], row['slot'], row['rnti']]
            vals_from_csv.append(tmp_list)

        time_stamps = set(map(lambda x: x[0], vals_from_csv))
        l3 = [[y for y in vals_from_csv if y[0] == x] for x in time_stamps]

        for i in l3:
            if len(i) != 2:
                raise Exception('Less than 2 UE in one slot near line ' + str(l3.index(i)))
            if i[0][1] != i[1][1]:
                raise Exception('Different sfn in the same time stamp')
            if i[0][2] != i[1][2]:
                raise Exception('Slot number in one time stamp is not valid')
            if i[0][3] == i[1][3]:
                raise Exception('The same rnti in one time stamp')

    def check_rnti_in_one_slot_ul(self, input_file):
        """
        Checks if 50% of rntis are in the same slots

        :param input_file: Absolute path to file where filtered
               NR TTI are located, e.g.
               "home/ute/logs/TC_name/misc_logs"
        :return False if less than half rnti's are not in the same slot. True otherwise
        """

        input_file = csv.DictReader(open(input_file))
        vals_from_csv = []
        for row in input_file:
            tmp_list = [row['timeStamp'], row['sfn'], row['slot'], row['rnti']]
            vals_from_csv.append(tmp_list)

        time_stamps = set(map(lambda x: x[0], vals_from_csv))
        l3 = [[y for y in vals_from_csv if y[0] == x] for x in time_stamps]
        counter_wrong_ue = 0
        for i in l3:
            if len(i) != 2:
                counter_wrong_ue += 1
            else:
                if i[0][1] != i[1][1]:
                    raise Exception('Different sfn in the same time stamp')
                if i[0][2] != i[1][2]:
                    raise Exception('Slot number in one time stamp is not valid')
                if i[0][3] == i[1][3]:
                    raise Exception('The same rnti in one time stamp')

        if counter_wrong_ue > len(l3) / 2:
            raise Exception('Less than 50% in one slot')
