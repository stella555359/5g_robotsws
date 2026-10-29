import os
import sys
import shutil


def write_ues_fr1_1cell(fd):
    max_number_of_ues = 100
    number_of_ues_per_cell = {1: 100}
    ue = 1
    for cell in number_of_ues_per_cell:
        print(f"Creating UEs for cell {cell}")
        for ue_in_cell in range(1, 1 + number_of_ues_per_cell[cell]):
            fd.write(f"#UE {ue}: NSA\n")
            fd.write(f"set_ue simulated id={ue} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ")
            fd.write(f"sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g ")
            fd.write(f"eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:21645{400 + ue}\n")

            fd.write(f"ue_param id={ue} ")
            fd.write(f"ue_nr_capabilities=0300000002000800000180008002002000100000018004000000DE00000000000004E800020")
            fd.write(f"0000000020023B0 dual_conn=eutra_nr ")
            fd.write(f"ue_eutra_nr_capabilities=01080402E000007134003A0000000000100801002020040080801002\n")

            fd.write(f"set_bearer id=2 ue={ue} qci=9 pdn=1 ip=4.7.254.{ue} default=on trf_type=internal\n")
            fd.write(f"\n\n")
            if ue >= max_number_of_ues:
                return
            ue += 1


def write_ues_fr1(fd):
    max_number_of_ues = 200
    number_of_ues_per_cell = {1: 100, 3: 100}
    ue = 1
    for cell in number_of_ues_per_cell:
        print(f"Creating UEs for cell {cell}")
        for ue_in_cell in range(1, 1 + number_of_ues_per_cell[cell]):
            fd.write(f"set_ue simulated id={ue} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ")
            fd.write(f"opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc nia=null+zuc ")
            fd.write(f"sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645{400 + ue} ")
            fd.write(f"enb=2 cell={cell} mode=nr\n")

            fd.write(f"ue_param id={ue} ")
            if cell <= 2:
                fd.write(f"ue_nr_capabilities=$SA_Capa_noCA_band66\n")
            else:
                fd.write(f"ue_nr_capabilities=$SA_Capa_Full\n")

            fd.write(f"set_pdu_gateway id={ue} ue_nat_ip=72.{ue + 22}.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP\n")
            fd.write(f"\n\n")
            if ue >= max_number_of_ues:
                return
            ue += 1


def write_ues_fr1_3cells(fd):
    max_number_of_ues = 200
    number_of_ues_per_cell = {1: 60, 2: 60, 3: 80}
    ue = 1
    fd.write(f"set SA_Capa=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851A")
    fd.write(f"C10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB80004000000038")
    fd.write(f"0004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B")
    fd.write(f"1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7")
    fd.write(f"D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041")
    fd.write(f"C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E2680000000101345")
    fd.write(f"40003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C0070")
    fd.write(f"00B000000040080118B130001020304050607080B101112131921252627284A0\n\n")
    for cell in number_of_ues_per_cell:
        print(f"Creating SA UEs for cell {cell}")
        for ue_in_cell in range(1, 1 + number_of_ues_per_cell[cell]):
            fd.write(f"set_ue simulated id={ue} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ")
            fd.write(f"opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g ")
            fd.write(f"sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645{400 + ue} ")

            fd.write(f"enb=2 cell={cell} mode=nr\n")

            fd.write(f"ue_param id={ue} ue_nr_capabilities=$SA_Capa\n")

            fd.write(f"set_pdu_gateway id={ue} ue_nat_ip=72.{ue + 22}.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP\n")
            fd.write(f"\n\n")
            if ue >= max_number_of_ues:
                return
            ue += 1


def write_ues_fr1_ibca(fd):
    max_number_of_ues = 200
    number_of_ues_per_cell = {1: 100, 5: 100, 3: 10, 6: 10}
    ue = 1
    fd.write(f"set SA_Capa_Full_Sector2=E980D000574D5A13160003C0A02C1262C003387A0609B20C39F30C7942C0E098040623")
    fd.write(f"809D46C28C0D608C21A081074804596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E000BE")
    fd.write(f"000280381507C41D608C21A081078804496C98AA091C790E7C639F30C7942C0E070F027F4000001FD00000005")
    fd.write(f"00702A0F88DAC1184301020E0021AB04C55040E3C873E31CF9863C13F8000000FE0000000280381D46C4CC0D6")
    fd.write(f"08C21A081074804596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E000BE0002803800000")
    fd.write(f"0409503882080000200A8384C03882000004240A85C41000C2081841000104015878500018410001840118385")
    fd.write(f"010001038C3C28000C14000143AC3C28000E230000060902A0F11800388200001C2C0AC3C28000E2600000808")
    fd.write(f"070070106014404680980A1AC130276C73E1C29D3B639F0E24E9D3B639F0E14E9DB1CF870226C73E1C2891363")
    fd.write(f"9F0E14E9F81FEBDB853A7E07FAF6E14489B1CF8607A05007C201806030050060240040603E150020000000100")
    fd.write(f"0002008000000040000080200000801000006008000040040000280200100401004000030020000180100000E")
    fd.write(f"00800007004002000000080000800400201806008000090040000500200002C0100080A028020010000700400")
    fd.write(f"20600E0080000D0040000749280103C0F2E4940001E5C9280303C0F03C0F2E4940101E0781E5C9280603C0F03")
    fd.write(f"C0F03C0F03CB9250080781E0781E079724A01C0F03C0F03C0F03C0F03CB825000079724A0000F4E4940081E07")
    fd.write(f"A724A0080F03C0F4E0940001E9C9280703C0F03C0F03C0F03C0F4E4940181E0781E07A724A0000F0E4940381E")
    fd.write(f"0781E0781E0781E078724A0040F03C39250060781E0781E1C1280003C303F9535953582958195833581B594B5")
    fd.write(f"933580B58095811582B5943591B583B5BA403C1000009652504000065949010000296525040000E5949010000")
    fd.write(f"49652404000165949410000696524040001E594901000089652404000265949010000A96524040002E5949410")
    fd.write(f"000C9652504000365949010040E03A5949410000E965250394AAAA9545D2AABA55154162A81D55068AA531549")
    fd.write(f"A2A80C55028AA4D5548EAA83C5576A009940A880402010180C06030080402010080406030180C060300804020")
    fd.write(f"300804020100804020100804020100804020100804020010001028018202004000080800C2010100180404000")
    fd.write(f"0101000020200C020080800000101C00C20200C0180801000101006010040400608080800C020200304040180")
    fd.write(f"30100600C0\n\n")

    for cell in number_of_ues_per_cell:
        print(f"Creating UEs for cell {cell}")
        for ue_in_cell in range(1, 1 + number_of_ues_per_cell[cell]):
            fd.write(f"#UE {ue} on cell {cell}\n")
            fd.write(f"set_ue simulated id={ue} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ")
            fd.write(f"opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc nia=null+zuc ")
            fd.write(f"sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645{400 + ue} ")
            fd.write(f"enb=2 cell={cell} mode=nr\n")

            fd.write(f"ue_param id={ue} ")
            if cell <= 3:
                fd.write(f"ue_nr_capabilities=$SA_Capa_Full\n")
            else:
                # fd.write(f"ue_nr_capabilities=$SA_Capa_Full_Sector2\n")
                fd.write(f"ue_nr_capabilities=$SA_Capa_Full\n")

            fd.write(f"set_pdu_gateway id={ue} ue_nat_ip=72.{ue + 22}.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP\n")
            fd.write(f"\n\n")
            if ue >= max_number_of_ues:
                return
            ue += 1


def write_ues_fr2(fd):
    max_number_of_ues = 200
    number_of_ues_per_cell = {1: 100, 2: 100}
    ue = 1
    for cell in number_of_ues_per_cell:
        print(f"Creating UEs for cell {cell}")
        for ue_in_cell in range(1, 1 + number_of_ues_per_cell[cell]):
            fd.write(f"#UE {ue}: NSA\n")
            fd.write(f"set_ue simulated id={ue} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ")
            fd.write(f"sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g ")
            fd.write(f"eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:21645{400 + ue}\n")

            fd.write(f"ue_param id={ue} ")
            fd.write(f"ue_nr_capabilities=0300000002000800000180008002002000100000018004000000DE00000000000004E800")
            fd.write(f"0200000000020023B4 dual_conn=eutra_nr ")
            fd.write(f"ue_eutra_nr_capabilities=01080402E000007134003A0000000000100801002020040080801002\n")

            fd.write(f"set_bearer id=2 ue={ue} qci=9 pdn=1 ip=4.7.254.{ue} default=on trf_type=internal\n")
            fd.write(f"\n\n")
            if ue >= max_number_of_ues:
                return
            ue += 1


def write_ues_r3252512(fd):
    max_number_of_ues = 200
    number_of_ues_per_cell = {1: 8, 2: 8, 3: 8, 16: 8, 17: 8, 18: 8}
    ue = 1

    fd.write(f"set SA_Capa_n78=E1A00000074E5A031E0003832001E09306400043C2400C41B4026010180E01D51B0A35820")
    fd.write(f"28680965944C2403D6C10101070EF1C39061C00103278FAB800FF800E003FE00091003B700008000000070000")
    fd.write(f"8000000002A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C007FC007001FF0004880")
    fd.write(f"1DB800040000000380004000000001546C4DD6080A1A025965130900F5B0404041C3BC70E418700040C9E3EAE")
    fd.write(f"003FE003800FF80024400EDC000200000001C0002000000000AA36276B04050D012CB28984807AD8202020E1D")
    fd.write(f"E38720C38002064F1F55000005000001220076E000100000000E000100000000000841C4D0000000020268780")
    fd.write(f"03804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAE84801C002")
    fd.write(f"C00000010020046AC4C0004080C1014181C202C4044484C648494989CA1288A\n\n")

    fd.write(f"set SA_Capa_n28=E9A09000575F5A13160003C3A000B05F8B800CE175A12013641873E618F28581C130080C4")
    fd.write(f"701BB8D89981AC1184341020F1068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05FF")
    fd.write(f"FFFC007FFFFF0005C0000E0741B0A2AB582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC3")
    fd.write(f"1E50B0381C3C27F63FF001FD8FFC00170000381D46C4DAAD608C21A0810788340185B262A88873E238F11C7A0")
    fd.write(f"67D813E31CF9863CA1607038782FFFFFE003FFFFF8002E0000703A0D88D55AC1184341020F1068032B64C5589")
    fd.write(f"0E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0EE3601606B04610D04083")
    fd.write(f"C41A00DAD931563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C17FFC00001FFF000001700003815")
    fd.write(f"06C41D608C21A0010788340195B262AC4873EC09F11C78048E3C873EA39F30C7942C0E070F09FD8000007F600")
    fd.write(f"00005C0000E0551B06F582308682041E20D00616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0BF")
    fd.write(f"FE00000FFF800000B80001C00E587898001C28000000160562E2600070A000389A0000082C0AC7C4C000E0D80")
    fd.write(f"0711800389A00001C2C0AC3C4C000E260000010B02B1713000389A001C28000008160561E1400070A00000485")
    fd.write(f"8158B89A001C4D000E2300000A0B02B0F13400389A0000302C0803C46000E2080000358B88C001C41000E2080")
    fd.write(f"00050B02B1F008003836001C46000E2080000B0B02B0F11800388C0000182C0AC3C1B000E268000080B02B171")
    fd.write(f"34003898001C4D00001A160403404680990136014401B8005010455005883A14489B1CF871224489B1CF871A0")
    fd.write(f"408103639F0214081B1CF811204081B1CF810A040D8E7C08902040D8E7C0850206C73E0428913639F0E244891")
    fd.write(f"3639F0E340810206C73E0428103639F0214081B1CF811204081B1CF800A870C6318C6318C6318C6FD5555505C")
    fd.write(f"0078005038280381804A00E000C0480080C07C140040000000200000401000004008000010040000100200000")
    fd.write(f"C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A0")
    fd.write(f"0400005802001024090040000600200100802000004010040101DCA9AC8DACA1AC0CAC19AC15ACA5AC99AC05A")
    fd.write(f"C0DAC04AC08AC1DACA9AC14A0682000012CA4A080000CB29282000052CA48080001CB29202000092CA4808000")
    fd.write(f"2CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA4808")
    fd.write(f"00018B29201BA555748EAA9445D2A8AA0B154162A83455298AA4D154062A8145526AAA0F154AA285805E02540")
    fd.write(f"A05028140A05028140A05028140A05028140A05000D0808010020200400840400801010020044020040080801")
    fd.write(f"002020040084040880B0101A0284020040080801002020040088040880B0101A028040680A080811016020440")
    fd.write(f"58C04008010102202C040880B0100200420204405808010021010020040400801100801002020040080811016")
    fd.write(f"30101A028040880B0102202C040680A08080100202004008804008010100200404008011AA1F0001020304060")
    fd.write(f"70A0B0C0D101112131418191B1C1D1F2125262728292A2D2F41655555555382D\n\n")

    for cell in number_of_ues_per_cell:
        print(f"Creating UEs for cell {cell}")
        for ue_in_cell in range(1, 1 + number_of_ues_per_cell[cell]):
            fd.write(f"#UE {ue} on cell {cell}\n")
            fd.write(f"set_ue simulated id={ue} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ")
            fd.write(f"opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc nia=null+zuc ")
            fd.write(f"sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:405:861:0000:0:0:021645{400 + ue} ")
            fd.write(f"enb=2 cell={cell} mode=nr\n")

            fd.write(f"ue_param id={ue} ")
            if cell <= 3:
                fd.write(f"ue_nr_capabilities=$SA_Capa_n78\n")
            else:
                # fd.write(f"ue_nr_capabilities=$SA_Capa_Full_Sector2\n")
                fd.write(f"ue_nr_capabilities=$SA_Capa_n28\n")

            fd.write(f"set_pdu_gateway id={ue} ue_nat_ip=72.{ue + 22}.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP\n")
            fd.write(f"\n\n")
            if ue >= max_number_of_ues:
                return
            ue += 1


def create_ues(default_input_name, file_out_name, feature_directory, config_name="FR1"):
    new_ue_written = False
    file_in_name = default_input_name
    custom_config_name = f"{feature_directory}/config/wts/{config_name}.cfg"
    if os.path.exists(custom_config_name):
        file_in_name = custom_config_name

    if os.path.exists(file_in_name):
        if config_name == "FR1_4CELLS" or config_name == "FR1_TMO":
            # Copy the contents of the source file to the destination file
            shutil.copyfile(file_in_name, file_out_name)
            # Print a success message
            print(f"{file_in_name} has been copied to {file_out_name}.")
            return

        with open(file_in_name, "r") as file_in:
            file_in_content = file_in.readlines()
            with open(file_out_name, "w") as file_out:
                if config_name != "FR2_CA":
                    print(f"Patching {file_in_name} into {file_out_name}")
                    for line_in in file_in_content:
                        line_in = line_in.strip()
                        if line_in.startswith("set_ue ") or line_in.startswith("ue_param ") or line_in.startswith(
                                "set_pdu_gateway ") or line_in.startswith("set_bearer "):
                            line_in = "#" + line_in
                            if not new_ue_written:
                                new_ue_written = True
                                if config_name == "FR1":
                                    write_ues_fr1(file_out)
                                elif config_name == "FR1_IBCA":
                                    write_ues_fr1_ibca(file_out)
                                elif config_name == "FR1_1CELL":
                                    write_ues_fr1_1cell(file_out)
                                elif config_name == "FR1_3CELLS":
                                    write_ues_fr1_3cells(file_out)
                                elif config_name == "FR2":
                                    write_ues_fr2(file_out)
                                elif config_name == "FR2_BKG":
                                    write_ues_fr2(file_out)
                                elif config_name == "R3252512":
                                    write_ues_r3252512(file_out)
                        line_in = line_in.replace("debug_log level=0", "debug_log level=4")
                        line_in = line_in.replace('DAEMON_PORT="10000"', 'DAEMON_PORT="22222"')
                        file_out.write(line_in + "\n")
                else:
                    file_out.write("reset\n")
                    file_out.write("# CHANGE STATE: ACTIVE - SimMode is ready now \n")
                file_out.close()
                print(f"{file_out_name} created")
            file_in.close()
    else:
        print(f"{file_in_name} not found, do not consider as error, could be customized file")


if __name__ == '__main__':
    create_ues(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
