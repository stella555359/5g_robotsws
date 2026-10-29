import random


def random_list_shuffle(data: list, seed=None):
    if seed is None:
        seed = random.randint(0, 9999999)
    random.seed(seed)
    shuffled = data[:]
    random.shuffle(shuffled)
    return shuffled, seed


def random_dict_shuffle(data: dict, seed=None):
    if seed is None:
        seed = random.randint(0, 9999999)
    random.seed(seed)
    for key in data:
        random.shuffle(data[key])
    items = list(data.items())
    random.shuffle(items)
    return dict(items), seed
