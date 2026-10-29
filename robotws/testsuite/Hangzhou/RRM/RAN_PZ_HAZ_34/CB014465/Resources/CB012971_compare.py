import operator


def check_streamIndex_for_each_subcell(slot_list, sfn_list, subcellid_list, numOfPrb_list, streamIndex_list):
    slot0 = slot_list[0]
    sfn0 = sfn_list[0]
    streamindex = {'6': [], '7': [], '10': [], '11': []}
    numofprb = {'6': [], '7': [], '10': [], '11': []}
    subcellid = ['6', '7', '10', '11']
    expected_streamIndex = ['0', '1', '2', '3']
    result = True
    print(streamindex)
    for index in range(len(slot_list)):
        if slot_list[index] == slot0 and sfn_list[index] == sfn0:
            id = subcellid_list[index]
            start_index = index * 4
            end_index = index * 4 + 2
            streamindex[id].extend(streamIndex_list[start_index:end_index])
            numofprb[id].append(numOfPrb_list[index])
            print(streamindex)
        else:
            slot0 = slot_list[index]
            sfn0 = sfn_list[index]
            for id in subcellid:
                if len(streamindex[id]) == 4:
                    streamindex[id].sort()
                    result = operator.eq(streamindex[id], expected_streamIndex)
                    print(result)
                    if not result:
                        print('stream index is not mapping')
                        return result
            list1 = numofprb['6'] + numofprb['7']
            list2 = numofprb['10'] + numofprb['11']
            print(list1, list2)
            if list1.count(list1[0]) != len(list1):
                print(f'subcell: {id}; slot: {slot_list[index-1]}; numofprb: {list1}')
                return False
            if list2.count(list2[0]) != len(list2):
                print(f'subcell: {id}; slot: {slot_list[index-1]}')
                return False

            id = subcellid_list[index]
            streamindex = {'6': [], '7': [], '10': [], '11': []}
            numofprb = {'6': [], '7': [], '10': [], '11': []}
            print(streamindex)
            start_index = index * 4
            end_index = index * 4 + 2
            streamindex[id].extend(streamIndex_list[start_index:end_index])
            numofprb[id].append(numOfPrb_list[index])

    return result
