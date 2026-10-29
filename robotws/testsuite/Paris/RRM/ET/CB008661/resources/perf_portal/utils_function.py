def get_from_insensitive_key(key_to_find, into_dict):
    if key_to_find in into_dict:
        return into_dict[key_to_find]
    insensitive_key = key_to_find.casefold()
    for key_into_dict in into_dict:
        if insensitive_key == key_into_dict.casefold():
            return into_dict[key_into_dict]
    raise KeyError(f"insensitive key {key_to_find} not found")
