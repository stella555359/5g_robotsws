def reader(input, moc, state):
    for rim_moc in input:
        if rim_moc['distName'] == moc:
            if state == 'riDetectEnbInfoList':
                try:
                    return len(rim_moc['parameters'][state])
                except BaseException as e:
                    print("riDetectEnbInfoList is not populated")
                    return 'FAIL'
            else:
                try:
                    return rim_moc['parameters'][state]
                except BaseException as e:
                    print("riDetectEnbInfoList is not populated")
                    return 'FAIL'
    return 'FAIL'
