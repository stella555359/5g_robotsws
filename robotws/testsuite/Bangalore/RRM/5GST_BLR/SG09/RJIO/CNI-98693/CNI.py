import os
"""
contact: lekhashree.s_n@nokia.com
"""


def Parse_Emil_Csv_File_For_Message_content_required_not_required(path, msg, required_message=None,
                                                                  not_required_message=None, log='mon.0'):
    print(msg)
    status = []
    pos = []
    msg_length = []
    filetype = ".csv"
    end_msg = '}"'
    end_msg1 = '"\n'
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                file = os.path.join(r, file)
                src = open(file).readlines()
                print("\nSearching for message", msg, "and content",
                      required_message, "and should not include content",
                      not_required_message, "in file",
                      file)
                check = []
                check1 = []
                if required_message is not None:
                    check = required_message.split(".")
                    print(check)
                if not_required_message is not None:
                    check1 = not_required_message.split(".")
                    print(check1)
                for j in range(0, len(src)):
                    if msg in src[j] and log == 'mon.0':
                        print("\n\tMessage found:\n\t", src[j])
                        pos = j
                        temp = []
                        for k in range(j, len(src)):
                            temp.append(src[k].strip('\n').strip())
                            if end_msg in src[k] or end_msg1 in src[k]:
                                break
                        msg_length = len(temp)
                        if required_message is None and not_required_message is None:
                            status = msg
                            print("\nMessage: \n")
                            for text in temp:
                                print(text)
                            break
                        count = 0
                        if required_message is not None and not_required_message is not None:
                            if all(not_word not in temp for not_word in check1):
                                if all(required_word in temp for required_word in check):
                                    count = 1
                                if count == 1:
                                    break
                        if required_message is not None and not_required_message is None:
                            if all(required_word in temp for required_word in check):
                                count = 1
                            if count == 1:
                                break
                        if required_message is None and not_required_message is not None:
                            if all(not_word not in temp for not_word in check1):
                                count = 1
                            if count == 1:
                                break
                        if count == 1:
                            status = msg
                            print("\nMessage: \n")
                            for text in temp:
                                print(text)
                            break
            if sorted(msg) == sorted(status):
                return True, pos, msg_length
    print("\nBelow messages or it's content not found :")
    return False, pos, msg_length


def compare_values(result, result1, result2):
    if result[0] and result1[0] and result2[0]:
        if result[1] < result1[1] and result[1] < result2[1]:
            if result1[1] > result2[1]:
                sum_value = result2[1] + result2[2]
                if result1[1] != sum_value:
                    print("2nd ueCapabilityEnquiry is far later than ICS response")
                    return False
            else:
                sum_value = result1[1] + result1[2]
                if result2[1] != sum_value:
                    print("2nd ueCapabilityEnquiry is far earlier than ICS response")
                    return False
        else:
            print("1ST ueCapabilityEnquiry is not intended one")
            return False
    else:
        print("ueCapabilityEnquiry contents are not proper or feature is not enabled")
        return False
    return True
