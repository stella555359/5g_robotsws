import csv
import sys
import re
input_file = "./csv_TC028_a.csv"
output_file = "./out_csv_TC028_a.csv"


def delete_blank_space_for_mcshark_sencond_column_old(input_file, output_file):
    if sys.version_info < (3, 0):
        fh_w = open(output_file, "wb")
    else:
        fh_w = open(output_file, "w")
    fh = open(input_file)
    head = fh.readline()
    # print("head={}".format(head))
    fh_w.write(head)
    data = csv.reader(fh)
    for line in data:
        info = line[1].strip().replace("  ", " ")
        new_line = line[0]+","+info+","+",".join(line[2:])+"\n"
        # print(new_line)
        fh_w.write(new_line)
    fh.close()
    fh_w.close()


def delete_blank_space_for_mcshark_sencond_column(input_file, output_file):
    if sys.version_info < (3, 0):
        fh_w = open(output_file, "wb")
    else:
        fh_w = open(output_file, "w")
    fh = open(input_file)
    head = fh.readline()
    # print("head={}".format(head))
    fh_w.write(head)
    data = fh.readlines()
    for line in data:
        one_line_data_list = line.split(",", 2)
        if len(one_line_data_list) >= 3:
            column_2_data = one_line_data_list[1]
            trimmed_text = re.sub(r' |  ', '', column_2_data)
            print("column_2_data={},trimmed_text={}".format(
                column_2_data, trimmed_text))
            new_line = one_line_data_list[0]+"," + \
                trimmed_text+","+one_line_data_list[2]
        else:
            new_line = line
        print(new_line,)
        fh_w.write(new_line)
    fh.close()
    fh_w.close()


if __name__ == "__main__":
    delete_blank_space_for_mcshark_sencond_column(input_file="./csv_srs.csv",
                                                  output_file="./out_csv_srs.csv")
