import csv


def get_max_ul_number_of_prbs(file_name):
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        prb_num_list = [int(float(line["ulFdSchedData.numOfPrb"]))
                        for line in csv_reader
                        if line["ulFdSchedData.numOfPrb"] != '']
        return max(prb_num_list)
