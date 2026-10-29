import re


def text_save(filename, data):
    file = open(filename, 'a')
    for i in range(len(data)):
        s = str(data[i]).replace('[', '\n').replace(']', '\n')
        s = s.replace("'", '').replace(',', '\n') + '\n'
        file.write(s)
    file.close()
