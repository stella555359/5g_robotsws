#!/bin/bash

# Wymagane uprawnienia sudo
if [ "$(id -u)" != "0" ]; then
    echo "Ten skrypt musi byc uruchomiony z uprawnieniami administratora (sudo)." 1>&2
    exit 1
fi

if [ -d "/home/ute/rotta/" ]; then
    umount /home/ute/rotta/
    rmdir /home/ute/rotta/
fi

# Wykonanie komend
export DEBIAN_FRONTEND=noninteractive; apt update; apt -y install krb5-user keyutils
sed -i -r "s/default_realm = .*/default_realm = NSN-INTRA.NET/g" /etc/krb5.conf

# Pobierz nazwe uzytkownika jako input
read -p "Podaj nazwe uzytkownika: " USER

# Przypisz pobrana nazwe uzytkownika
export USER=$USER

# Logowanie do Kerberos
kinit ${USER}

# Utwórz katalog i zmien wlasciciela
mkdir -p /home/ute/rotta/
chown ute:ute /home/ute/rotta

# Zamontuj zasób sieciowy
mount //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2 /home/ute/rotta/ -t cifs -o username=${USER}@NSN-INTRA.NET,domain=NSN-INTRA,rw,norelatime,uid=1000,gid=1000,sec=krb5

# Wyczekaj na synchronizację
folder_path="/home/ute/rotta/"  # Zmień na właściwą ścieżkę
timeout=120  # Timeout w sekundach
elapsed_time=0

echo -e "Disc mounted under /home/ute/rotta/ ! \nIt may take a while to synchronize, it's good time for a coffe break =)"
echo "Waiting 2minutes for files.."

while [ ! -d "$folder_path" ] || [ -z "$(ls -A "$folder_path")" ]; do
    sleep 1
    elapsed_time=$((elapsed_time + 1))

    if [ "$elapsed_time" -ge "$timeout" ]; then
        echo "Synchronization took longer than expected $timeout seconds, check rotta dir later or try again!"
        exit 1
    fi
done

echo "Rotta mounded succesfully!"
cd /home/ute/rotta/
exit 0




