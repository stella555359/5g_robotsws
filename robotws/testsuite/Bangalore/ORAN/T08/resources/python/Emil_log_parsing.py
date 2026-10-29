import os


def Parse_Emil_Csv_File_For_Message(path, msg, log='mon.0'):
    messages = msg.split("|")
    status = []
    filetype = ".csv"
    End_msg = '}"'
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                file = os.path.join(r, file)
                src = open(file).readlines()
                remove_list = []
                for i in messages:
                    print(
                        "\nSearching for message",
                        i.split(":")[0],
                        "and content",
                        i.split(":")[1],
                        "in file",
                        file)
                    temp = []
                    Flag = False
                    count = False
                    message, content = i.split(":")
                    print(content)
                    if log == 'mon.0':
                        message = '"' + message + '"'
                    for j in range(0, len(src)):
                        if (message in src[j] and log == 'mon.0'):
                            print("\n\tMessage found:\n\t", src[j])
                            temp = []
                            if content == '0':
                                return True
                                break
                            for k in range(j, len(src)):
                                temp.append(src[k])
                                if End_msg in src[k] or src[k] in ['\n', '\r\n']:
                                    break
                            for text in range(0, len(temp)):
                                if (content in temp[text]):
                                    print(temp[text].strip(),
                                          "is in message",
                                          message.strip()
                                          )
                                    count = True
                                if count is True:
                                    break
                            if count is True:
                                status.append(i)
                                remove_list.append(i)
                                print("\nMessage: \n")
                                for text in temp:
                                    print(text.strip('\n'))
                                break
                for rem in remove_list:
                    messages.remove(rem)
                if sorted(msg.split("|")) == sorted(status):
                    return True
    print("\nBelow messages or it's content not found :")
    for i in set(msg.split("|")) - set(status):
        print("\t", i)
    return False
