import os
import csv


def create_csv(attr, event, *values):
    print("Here csv")
    try:
        fp = open("bip.csv", "w")
        header = 'type'
        for i in attr:
            header = header + ',' + i
        header = header + "\n"
        fp.write(header)

        for j in range(len(values[0])):
            cont = event
            for i in range(len(values)):
                cont = cont + ',' + values[i][j]
            cont = cont + '\n'
            fp.write(cont)
        fp.close()
    except BaseException:
        print("eer")
    print("File is created")

# v=[['853', '853', '853', '853', '853'], ['3', '5', '6', '7', '8'], ['29597', '29597', '29597', '29597', '29597']]
# attr=['sfn','slot','rnti']
# create_csv(attr,'xxx',*v)


def create_csv_file(data, header, event, filePath):
    dummy = []
    for i in range(len(data[0])):
        dummy.append(event)
    data.insert(0, dummy)
    idx = 0
    newData = {}
    for item in header:
        newData[item] = data[idx]
        idx += 1
    # csvfile = filePath + '/' + "test.csv"
    CsvFile = os.path.join(filePath, "test.csv")
    with open(CsvFile, "w", newline='') as outfile:
        writerfile = csv.writer(outfile)
        writerfile.writerow(newData.keys())
        writerfile.writerows(zip(*newData.values()))
