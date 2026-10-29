#!/bin/bash

# Function to display error and exit
function error_exit {
    echo "ERROR: $1"
    exit 1
}

# Get the board name
BOARD_NAME=$(cat /var/dt/module-identity/unit-id) || error_exit "Failed to read board name."

# Define supported boards and their IDs
declare -A BOARD_IDS=(
    ["ASIL"]="fctp"
    ["ASOE"]="asce"
    ["ASOF"]="ascf"
    ["ASIM"]="fctq"
    ["ASOG"]="ascgh"
    ["ASOH"]="ascgh"
    ["ASIB"]="fctm"
    ["ABIN"]="aspc"
    ["ABIO"]="aspd"
    ["ABIP"]="aspe"
    ["ABIQ"]="aspf"
)

ADDONS_PACKAGES=(
    "/ffs/run/swpool/LFS/addons/sm6_snowfish"
	"/ffs/run/swpool/LFS/addons/sm6_snowfish-asoe"
    "/ffs/run/swpool/LFS/addons/sm7_marlin"
    "/ffs/run/swpool/LFS/addons/sm7_marlin_asogh"
)

FCT_BOARDS=("ASIL" "ASOE" "ASOF" "ASIM" "ASOG" "ASOH" "ASIB")
FSP_BOARDS=("ABIN" "ABIO" "ABIP" "ABIQ")
SLOT_IDS=(1 2 3 5 6 7)

# Check if the board is supported
if [[ -z "${BOARD_IDS[$BOARD_NAME]}" ]]; then
    error_exit "Unsupported board: $BOARD_NAME"
fi

BOARD_ID=${BOARD_IDS[$BOARD_NAME]}

# Function to get the correct source SSBL_PATH based on BOARD_NAME
function get_ssbl_path {
    local board_name=$1
    local ssbl_path

    case $board_name in
        "ABIN"|"ABIO")
            ssbl_path="/tmp/abin_cni_139728_bootfiles/ssbl.test.efi"
            ;;
		"ABIP"|"ABIQ")
            ssbl_path="/tmp/abip_cni_139728_bootfiles/ssbl.test.efi"
            ;;
        "ASOE"|"ASOF")
            ssbl_path="/tmp/asoe_cni_139728_bootfiles/ssbl.test.efi"
            ;;
        "ASOG"|"ASOH")
            ssbl_path="/tmp/asogh_cni_139728_bootfiles/ssbl.test.efi"
            ;;
        *)
            ssbl_path="/tmp/${board_name,,}_cni_139728_bootfiles/ssbl.test.efi"
            ;;
    esac

    echo $ssbl_path
}

# Function to extract packages for existing architectures
extract_packages() {
    local arch_path=$1
    local package_pattern="bootloader-CNI-139728*.tzst"

    if [ -d "$arch_path" ]; then
        extract-pkg /tmp/ ${arch_path}/${package_pattern} || error_exit "Failed to extract package from $arch_path"
    else
        echo "Directory $arch_path does not exist. Skipping extraction."
    fi
}

# Loop through each architecture and attempt files extraction
for package in "${ADDONS_PACKAGES[@]}"; do
    extract_packages "$package"
done

if [[ " ${FCT_BOARDS[@]} " =~ " ${BOARD_NAME} " ]]; then
	mount -o remount,rw /ffs/stb

	if [[ "$BOARD_NAME" != "ASIB" ]]; then
		# Install SSBL
		echo "Install SSBL files for FCT = $BOARD_NAME board"

		SSBL_PATH=$(get_ssbl_path "$BOARD_NAME")
		if [[ ! -f "$SSBL_PATH" ]]; then
			error_exit "SSBL file not found: $SSBL_PATH"
		fi

		# Active partition
		cp "$SSBL_PATH" /ffs/run/devicecfg/boot/ssbl.efi || error_exit "Failed to copy SSBL to devicecfg in run partition."
		cp "$SSBL_PATH" /ffs/run/swpool/LFS/boot/${BOARD_ID}/ssbl.efi || error_exit "Failed to copy SSBL to swpool in run partition."

		# Standby partition
		cp "$SSBL_PATH" /ffs/stb/swpool/LFS/boot/${BOARD_ID}/ssbl.efi || error_exit "Failed to copy SSBL to swpool in stb partition."

		# Sign active partition SSBL
		crasign /ffs/run/devicecfg/boot/ssbl.efi || error_exit "Failed to sign SSBL in devicecfg."
		crasign /ffs/run/swpool/LFS/boot/${BOARD_ID}/ssbl.efi || error_exit "Failed to sign SSBL in swpool."

		# Sign standby partition SSBL
		crasign /ffs/stb/swpool/LFS/boot/${BOARD_ID}/ssbl.efi || error_exit "Failed to sign SSBL in swpool."

		# Verify active partition SSBL signature
		craverify /ffs/run/devicecfg/boot/ssbl.efi /ffs/run/devicecfg/boot/ssbl.efi.p7 || error_exit "SSBL signature verification failed in devicecfg."
		craverify /ffs/run/swpool/LFS/boot/${BOARD_ID}/ssbl.efi /ffs/run/swpool/LFS/boot/${BOARD_ID}/ssbl.efi.p7 || error_exit "SSBL signature verification failed in swpool."

		# Verify standby partition SSBL signature
		craverify /ffs/stb/swpool/LFS/boot/${BOARD_ID}/ssbl.efi /ffs/stb/swpool/LFS/boot/${BOARD_ID}/ssbl.efi.p7 || error_exit "SSBL signature verification failed in swpool."
	else
		echo "SSBL installation skipped as feature it is not supported in ASIB! Current board: ${BOARD_NAME}"
	fi


	if [[ "$BOARD_NAME" != "ASOE" && "$BOARD_NAME" != "ASOF" && "$BOARD_NAME" != "ASOG" && "$BOARD_NAME" != "ASOH" ]]; then
		# Second SSBL installation for FCT boards
		echo "Install SSBL files for FSP boards"

		for fsp_board in "${FSP_BOARDS[@]}"; do
			fsp_board_id=${BOARD_IDS[$fsp_board]}
			for slot_id in "${SLOT_IDS[@]}"; do
				fsp_ssbl_source_path=$(get_ssbl_path "$fsp_board")
				act_fsp_ssbl_path="/ffs/run/boardcfg/${slot_id}/A/mcu-${fsp_board_id}/boot/ssbl.efi"
				stb_fsp_ssbl_path="/ffs/stb/boardcfg/${slot_id}/A/mcu-${fsp_board_id}/boot/ssbl.efi"
				if [[ -f "$act_fsp_ssbl_path" && -f "$stb_fsp_ssbl_path" ]]; then
					# Active partition
					cp ${fsp_ssbl_source_path} ${act_fsp_ssbl_path} || error_exit "Failed to copy SSBL to $act_fsp_ssbl_path"
					crasign ${act_fsp_ssbl_path} || error_exit "Failed to sign SSBL at $act_fsp_ssbl_path"
					craverify ${act_fsp_ssbl_path} ${act_fsp_ssbl_path}.p7 || error_exit "SSBL signature verification failed at $act_fsp_ssbl_path"

					# Standby partition
					cp ${fsp_ssbl_source_path} ${stb_fsp_ssbl_path} || error_exit "Failed to copy SSBL to $stb_fsp_ssbl_path"
					crasign ${stb_fsp_ssbl_path} || error_exit "Failed to sign SSBL at $stb_fsp_ssbl_path"
					craverify ${stb_fsp_ssbl_path} ${stb_fsp_ssbl_path}.p7 || error_exit "SSBL signature verification failed at $stb_fsp_ssbl_path"
				else
					error_exit "$act_fsp_ssbl_path or $stb_fsp_ssbl_path not found!"
				fi
			done
		done
	fi

	# Check and remove active partition HashContainer files
	if ls /ffs/run/HashContainer* 1> /dev/null 2>&1; then
		rm /ffs/run/HashContainer* || error_exit "Failed to remove act HashContainer files"
	fi

	# Check and remove standby partition HashContainer files
	if ls /ffs/stb/HashContainer* 1> /dev/null 2>&1; then
		rm /ffs/stb/HashContainer* || error_exit "Failed to remove stb HashContainer files"
	fi

	echo "SSBLs files were correctly installed. Please perform a reset."
else
    echo "SSBL installation skipped as it is not supported while running in FSP board. Current board: ${BOARD_NAME}"
fi

# Perform BIOS/Flash upgrade (skip for ASIB!)
if [[ "$BOARD_NAME" != "ASIB" ]]; then
	case $BOARD_NAME in
		"ASIL")
			update_bios.sh -F -D /tmp/asil_cni_139728_bootfiles/bios_fctp_snfb1.uim || error_exit "BIOS update failed for ASIL."
			;;
		"ASOE"|"ASOF")
			update_bios.sh -F -D /tmp/asoe_cni_139728_bootfiles/bios_asce_snfb1.uim || error_exit "BIOS update failed for ASOE."
			;;
		"ASIM")
			update_marvellfw.sh -T -S -F -D upgrade_firmware /tmp/asim_cni_139728_bootfiles/flash-update-asim.cpio || error_exit "Flash update failed for ASIM."
			;;
		"ASOG"|"ASOH")
			update_marvellfw.sh -T -S -F -D upgrade_firmware /tmp/asogh_cni_139728_bootfiles/flash-update-asogh.cpio || error_exit "Flash update failed for ASOG/ASOH."
			;;
		"ABIN"|"ABIO")
			update_bios.sh -F -D /tmp/abin_cni_139728_bootfiles/bios_aspc_snfb1.uim || error_exit "BIOS update failed for ABIN/ABIO."
			;;
		"ABIP"|"ABIQ")
			update_marvellfw.sh -T -S -F -D upgrade_firmware /tmp/abip_cni_139728_bootfiles/flash-update-abip.cpio || error_exit "Flash update failed for ABIP/ABIQ."
			;;
		*)
			error_exit "Unsupported board for BIOS/Flash update: $BOARD_NAME"
			;;
	esac

	echo "BIOS/Flash update completed successfully."
fi
