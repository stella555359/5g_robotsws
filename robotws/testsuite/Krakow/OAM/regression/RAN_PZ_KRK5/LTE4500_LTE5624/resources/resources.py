def get_ids_from_cell_list(cell):
    return cell[cell.index('-') + 1:]


def prepare_ru_id_for_checking_ip(ru_id):
    return int(ru_id) - 1


def prepare_params_to_delta(delta_template, first_val, second_val):
    for element in delta_template[0]['parameters']:
        print(element)
        if element['parameterName'] == 'earfcnDL':
            element['value'] = first_val
        else:
            element['value'] = second_val
    return delta_template


def compare_power_consumption(command_output, ant_id, action):
    ant_powers = command_output.strip().split()
    ant_powers = ant_powers[:len(ant_powers) - 1]
    for num_of_antena, ant_val in enumerate(ant_powers):
        if str(num_of_antena) == ant_id:
            if action == 'off':
                if str(ant_val) == '0':
                    return
                raise IncorrectValue("Wrong value of ant power. Is {}, but should be {}", ant_val, '0')
            else:
                if str(ant_val) != '0':
                    return
                raise IncorrectValue("Wrong value of ant power. Is {}, but should be {}", ant_val, 'not 0')
