
def calculate_nbr_of_bits_set_for_union(bitset1, bitset2):
    counter = 0
    for i in range(len(bitset1)):
        # print(f"bitset1 i={i} is {bitset1[i]}")
        # print(f"bitset2 i={i} is {bitset2[79-i]}")
        if bitset1[i] == '1' or bitset2[i] == '1':
            counter += 1
    return counter


def calculate_ratio_from_nbr_of_bits_set(number_bits_set, number_of_bits_in_bitset):
    return number_bits_set * 100 / number_of_bits_in_bitset


def check_collision(bitset1, bitset2):
    for i in range(len(bitset1)):
        if bitset1[i] and bitset2[i]:
            return True
    return False


def check_that_bitset1_is_included_in_bitset2(bitset1, bitset2):
    for i in range(len(bitset1)):
        if not check_included(i, bitset1, bitset2):
            return False
    return sum(bitset1) == sum(bitset2)


def combine_checks(for_collision_check, in_range, ref_bitset):
    for i in range(len(for_collision_check)):
        if for_collision_check[i] and ref_bitset[i]:
            return "collision"
        if not check_included(i, in_range, ref_bitset):
            return "notIncluded"
        return "ok"


def check_included(index, in_range, ref_bitset):
    bit_value_for_in_range = in_range[index]
    bit_value_for_ref = ref_bitset[index]
    if bit_value_for_in_range and not bit_value_for_ref:
        return False
    return True
