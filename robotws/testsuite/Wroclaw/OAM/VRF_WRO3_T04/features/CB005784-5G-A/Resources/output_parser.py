def parse_webem_login_output(output, phrase='"result" : "SUCCESS"'):
    return True if phrase in output else False
