import os
import csv
import sys
import zipfile
import tarfile
import subprocess


def Get_counter_list_9322(val, counter, cell):
    value = ""
    for i in str(val).split(":"):
        value = value + "['" + (i.strip(" {").strip("'")) + "']"
        if counter in i:
            break
    for i in value.split("]"):
        if "CEL" in i:
            get = i
            i = i.split("-")[0]
            rep = i + "-" + cell + "'"
    return value.replace(get, rep)


def Parse_Emil_Csv_File(path, msg, msg_col, con_col):
    # Validate the message content in EMIL logs
    # Input : Log path, <Message1>::<content1>,<content2>|<Message2>::<content1>,<content2>
    # Output : Msg content, True/False
    # Usage : /home/ute	  E2setupRequest::ranFunctionID
    # 11,ORAN-E2SM-RC-CA|E2setupResponse::ranFunctionID 11
    # msg_col =3, con_col = 24
    print(path)
    maxInt = sys.maxsize
    while True:
        # decrease the maxInt value by factor 10
        # as long as the OverflowError occurs.

        try:
            csv.field_size_limit(maxInt)
            break
        except OverflowError:
            maxInt = int(maxInt / 10)

    csv.field_size_limit(maxInt)
    messages = msg.split("|")
    Messages = []
    for i in messages:
        Messages.append(i.split("::")[0])
    filetype = ".csv"
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                status = []
                src = csv.reader(open(os.path.join(r, file), "r", encoding="utf-8"))
                for i in messages:
                    print("\nSearching for message", i.split("::")[0], "in file", file)
                    try:
                        val, strings = i.split("::")
                        check = strings.split(",")
                    except BaseException:
                        val = i.split("::")[0]
                        check = []
                    for row in src:
                        temp = []
                        if val in str(row[msg_col]):
                            print("Message found :\n\t", row[msg_col])
                            for content in check:
                                if content in str(row[con_col]):
                                    if content not in temp:
                                        temp.append(content)
                        if sorted(temp) == sorted(check):
                            print("Message content found :\n\t\t", row[con_col])
                            status.append(val)
                            break
                if sorted(Messages) == sorted(status):
                    return True

    print("\nMessages to search :")
    print(sorted(Messages))
    print("\nMessages Found :")
    print(sorted(status))
    print("\nMessages not found :")
    for i in Messages:
        if i not in status:
            print("\t", i)
    return False
