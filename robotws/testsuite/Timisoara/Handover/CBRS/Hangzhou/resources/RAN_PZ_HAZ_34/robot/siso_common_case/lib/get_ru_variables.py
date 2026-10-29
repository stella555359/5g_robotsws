def get_ru_type_from_init(ru_type):
    if isinstance(ru_type, str):
        return ru_type
    else:
        return ru_type.value
