
def backupamfname_list_contains_same_name(backup_amf_list, name, repetition):
    backup_names = []
    for item in backup_amf_list:
        backup_names.append(item['backupamfname'])
    assert len(set(backup_names)) == 1, 'Not the same backupamfname found: {}'.format(backup_names)
    assert len(backup_names) == int(repetition),\
        'Found number of name: {} does not match expected: {}'.format(len(backup_names), repetition)
    assert str(backup_names[0]).lower() == str(name).lower(),\
        'Backup name: {} not matches expected:{}'.format(str(backup_names[0]).lower(), str(name).lower())
