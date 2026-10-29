import os


def Parse_Emil_Csv_File_For_Message_content(path, msg, log='mon.0'):
    messages = msg.split("|")
    print(messages)
    status = []
    filetype = ".csv"
    end_msg = '}"'
    end_msg1 = '"\n'
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                file = os.path.join(r, file)
                src = open(file).readlines()
                remove_list = []
                index = 0
                for i in messages:
                    print("\n", i)
                    print(
                        "\nSearching for message",
                        i.split(":-")[0],
                        "and content",
                        i.split(":-")[1],
                        "in file",
                        file)
                    temp = []
                    message, content = i.split(":-")
                    if log == 'mon.0':
                        message = '"' + message + '"'
                    check = content.split(",")
                    print(check)
                    for j in range(0, len(src)):
                        if message in src[j] and log == 'mon.0':
                            print("\n\tMessage found:\n\t", src[j])
                            print(j, "position")
                            diff = j - index
                            print(diff)
                            index = j
                            if diff > 0:
                                for k in range(j, len(src)):
                                    temp.append(src[k])
                                    if end_msg in src[k] or end_msg1 in src[k]:
                                        break
                                if content == '0':
                                    status.append(i)
                                    remove_list.append(i)
                                    print("\nMessage: \n")
                                    for text in temp:
                                        print(text.strip('\n'))
                                    break
                                word_set = set()
                                for msg21 in range(0, len(temp)):
                                    for m in check:
                                        if m in temp[msg21]:
                                            word_set.add(m)
                                        if len(word_set) is len(check):
                                            break
                                    if len(word_set) is len(check):
                                        break
                                print(word_set)
                                print(len(word_set))
                                if len(word_set) is len(check):
                                    status.append(i)
                                    remove_list.append(i)
                                    print("\nMessage: \n")
                                    for text in temp:
                                        print(text.strip('\n'))
                                    break
                            else:
                                print("Messages are not in order")
                            temp = []
                for rem in remove_list:
                    messages.remove(rem)
                if sorted(msg.split("|")) == sorted(status):
                    return True
    print("\nBelow messages or it's content not found :")
    for i in set(msg.split("|")) - set(status):
        print("\t", i)
    return False
