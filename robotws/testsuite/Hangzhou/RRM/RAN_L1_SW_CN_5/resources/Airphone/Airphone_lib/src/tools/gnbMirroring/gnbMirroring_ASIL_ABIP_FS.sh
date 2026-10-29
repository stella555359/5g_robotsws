#!/bin/bash
MBYTES_TO_KBYTES=1024
MEMORY_MARGIN_KBYTES=512000

readOptionsFromConfigFile() {
    source $directory/gnbMirroring_ASIL_ABIP_FSConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroring_ASIL_ABIP_FSConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroring_ASIL_ABIP_FSConfig.sh) not found${NC}"
        exit
    fi
}

readAsilAbipProductCode(){
    if [ "$BB_SLOT_5" = "true" ] || [ "$BB_SLOT_1" = "true" ]; then
        bget 1:0 /proc/device-tree/module-identity/product-code /tmp > /dev/null
        abil_abip_product_code_slot_1_and_slot_5=$(tr -d '\0' < /tmp/product-code)
        rm -rf /tmp/product-code
    elif [ "$BB_SLOT_6" = "true" ] || [ "$BB_SLOT_2" = "true" ]; then
        bget 2:0 /proc/device-tree/module-identity/product-code /tmp > /dev/null
        abil_abip_product_code_slot_2_and_slot_6=$(tr -d '\0' < /tmp/product-code)
        rm -rf /tmp/product-code
    elif [ "$BB_SLOT_7" = "true" ] || [ "$BB_SLOT_3" = "true" ]; then
        bget 3:0 /proc/device-tree/module-identity/product-code /tmp > /dev/null
        abil_abip_product_code_slot_3_and_slot_7=$(tr -d '\0' < /tmp/product-code)
        rm -rf /tmp/product-code
    fi
}

parseCommandLineOptions() {
    echo -e "\n${YELLOW}Parse command line options${NC}"
    for i in "$@"
    do
    case $i in
        --bb_slot_1=*)
            BB_SLOT_1="${i#*=}"
            shift
        ;;
        --bb_slot_2=*)
            BB_SLOT_2="${i#*=}"
            shift
        ;;
        --bb_slot_3=*)
            BB_SLOT_3="${i#*=}"
            shift
        ;;
        --bb_slot_5=*)
            BB_SLOT_5="${i#*=}"
            shift
        ;;
        --bb_slot_6=*)
            BB_SLOT_6="${i#*=}"
            shift
        ;;
        --bb_slot_7=*)
            BB_SLOT_7="${i#*=}"
            shift
        ;;
		--number_of_files=*)
            NUMBER_OF_FILES="${i#*=}"
            shift
        ;;
        --file_size_mbytes=*)
            FILE_SIZE_MBYTES="${i#*=}"
            shift
        ;;
        *)
            #echo -e "\n${UELLOW}No options given in command line${NC}"
        ;;
    esac
    done
}

checkMemory() {
    memoryRequired=$(expr $NUMBER_OF_FILES \* $FILE_SIZE_MBYTES \* $MBYTES_TO_KBYTES + $MEMORY_MARGIN_KBYTES)
    memoryAvailable=$( df --output=avail /tmp | tail -n 1 )
    echo -e "${NC}Memory check, memoryRequired: $memoryRequired kB memoryAvailable $memoryAvailable kB${NC}"
    
    if [ $memoryAvailable -lt $memoryRequired ]; then
        echo -e "\n${RED}Not enough memory, decrease NUMBER_OF_FILES or FILE_SIZE_MBYTES${NC}"
        exit    
    fi
}

printOptions() {
    echo -e "Mirrored BB boards"
    echo -e "  BB_SLOT_1=$BB_SLOT_1"
    echo -e "  BB_SLOT_2=$BB_SLOT_2"
    echo -e "  BB_SLOT_3=$BB_SLOT_3"
    echo -e "  BB_SLOT_5=$BB_SLOT_5"
    echo -e "  BB_SLOT_6=$BB_SLOT_6"
    echo -e "  BB_SLOT_7=$BB_SLOT_7"
	echo -e "  NUMBER_OF_FILES=$NUMBER_OF_FILES"
    echo -e "  FILE_SIZE_MBYTES=$FILE_SIZE_MBYTES"
}

captureData() {
    if [ "$BB_SLOT_5" = "true" ] || [ "$BB_SLOT_1" = "true" ]; then
        if [[ $abil_abip_product_code_slot_1_and_slot_5 =~ X01|X00 ]];then
            echo -e "Capturing ABIL ABIP x00/x01 board"
            bsh 1:0 "dbgnet mirror port set sport 2 dport 18 direction both enable"
            bsh 1:0 "tcpdump -vvv -i etha01 -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -n -w /tmp/tcpdump_L2L1_bip_filtering_off.pcap"
        elif [[ $abil_abip_product_code_slot_1_and_slot_5 =~ X11|X12 ]];then
            echo -e "Capturing ABIL ABIP x11/x12 board"
            bsh 1:0 "dbgnet mirror port set sport 7 dport 18 direction both enable"
            bsh 1:0 "tcpdump -vvv -i etha01 -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -B 2000 -s 64 -n -w /tmp/tcpdump_L2L1_bip_filtering_off.pcap"
        fi
	fi
}

copyDumpFiles() {
    echo -e "\n${YELLOW}Capturing stopped, copy dump files if needed${NC}"
	if [ "$BB_SLOT_5" = "true" ] || [ "$BB_SLOT_1" = "true" ]; then
	    if [[ $abil_abip_product_code_slot_1_and_slot_5 =~ X01|X00 ]];then
	        bsh 1:0 "dbgnet mirror port set sport 2 dport 18 direction both disable"
        elif [[ $abil_abip_product_code_slot_1_and_slot_5 =~ X11|X12 ]];then
            bsh 1:0 "dbgnet mirror port set sport 7 dport 18 direction both disable"
        fi
        files=$( bsh 1:0 "ls /tmp/tcpdump_L2L1_bip*" )
        for file in $files
        do
            bget 1:0 $file /tmp/
         done
        bsh 1:0 "rm /tmp/tcpdump_L2L1_bip*"
		echo -e "\n${YELLOW}Dump files in /tmp/ folder${NC}"
		ls -la /tmp/tcpdump_L2L1_bip*
	fi
}

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "\n${YELLOW}gnbMirroring_ASIL_ABIP_FS.sh ${NC}"
readOptionsFromConfigFile
parseCommandLineOptions "$@"
printOptions
checkMemory
readAsilAbipProductCode
captureData
copyDumpFiles


