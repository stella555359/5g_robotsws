import os
import csv
import re
csv_file_list = []
dest_file = "dest.py"

for root, dirs, files in os.walk("."):
    for name in files:
        if name.split('.')[-1] == 'csv':
            csv_file_list.append(name)

with open(dest_file, 'w+') as write_object:
    for csv_file in csv_file_list:
        str_name = re.search('(H|V)index\\d+', csv_file).group()
        write_object.write("{} = '''".format(str_name))
        with open(csv_file, 'r') as read_object:
            content = csv.reader(read_object)
            for con in content:
                write_object.write("\n{}{}".format(16 * " ", con[0]))
        write_object.write("\n'''\n")
