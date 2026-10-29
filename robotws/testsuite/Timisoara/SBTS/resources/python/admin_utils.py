def parse_local_user_name(account_user_type):
    return account_user_type[0] + account_user_type[1:3].lower() + account_user_type[3:] \
        if account_user_type != 'Nemuadmin' else account_user_type
