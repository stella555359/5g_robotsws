import re


def Parse_Csv_File_For_Message(mesage1, mesage2, csv_path):
    my_reader = open(csv_path, 'r')
    counter1 = 0
    for record in my_reader:
        if record.count(mesage1) > 0:
            counter1 += record.count(mesage1)
    my_reader.close()
    my_reader = open(csv_path, 'r')
    counter2 = 0
    for record in my_reader:
        if record.count(mesage2) > 0:
            counter2 += record.count(mesage2)
    my_reader.close()
    return counter1, counter2
