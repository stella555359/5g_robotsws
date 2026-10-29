# -*- coding: utf-8 -*
"""
Author: Ding Binmei
Contacts: binmei.ding@nokia-sbell.com
Description: Please do not modify without the permission from author
             Export collected data info and write to csv file

"""
import csv


class Export_data(object):
    def write_data_to_csv(self, input_data, csv_file_path):
        """
        Write collected tput info to CSV file
        :param input_data: Can be a list with dict data in each list item.
               E.G: [{timestamp:xxx, nr_cell_id:xx, dl_tput_avg:xxx, dl_tput_detail:xxx,
                      ul_tput_avg:xxx, ul_tput_detail:xxx},{...}]
        :param csv_file_path:
        :return:
        """
        with open(csv_file_path, 'w') as csvfile:
            fieldnames = input_data[-1].keys()
            try:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                for data in input_data:
                    writer.writerow(data)
            finally:
                csvfile.close()
