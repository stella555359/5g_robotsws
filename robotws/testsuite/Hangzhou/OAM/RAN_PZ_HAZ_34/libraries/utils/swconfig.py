def swconfig_file_new_set(file_path, key, value):
    with open(file_path, "r+") as fp:
        new_content, updated = swconfig_setting(fp, key, value)
        if updated:
            fp.seek(0)
            fp.truncate()
            fp.write(new_content)
    return updated


def swconfig_setting(fp, key, value):
    content = fp.read()
    lines = content.splitlines()
    key_found = False
    updated = False
    for i, line in enumerate(lines):
        if line.startswith("#"):
            continue
        items = line.split("=")
        item_key = items[0].strip()
        item_value = items[1].strip().split()[0].strip()
        if item_key == key:
            if item_value != value:
                content.replace(line, "%s=%s" % (key, value))
                updated = True
            key_found = True
            break
    if not key_found:
        content += "\n%s=%s\n" % (key, value)
        updated = True
    return content, updated
