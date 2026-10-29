---[PL]---
Krotki opis skryptu sprawdzajacego status portow na pdu - Python3.6

1. Skrypt pobiera dane z pliku wejsciowego i (domyslnie) pinguje wszystkie adresy z danej podsieci.
2. Nastepnie, przed przejsciem do nastepnej podsieci sprawdza, czy mozna okreslic typ PDU na tych adresach, ktore
odpowiedzialy. Te dane sa zapisywane do pliku. Proces ma miejsce az do sprawdzenia wszystkich podsieci.
3. Z tego pliku nastepuje sprawdzanie statusow portow na poszczegolnych PDU (tylko, jesli typ jest znany). Wyniki sa
zapisywane do pliku.

Instrukcja uruchamiana:
python3.6 PDU_status.py plik_wejsciowy true/false plik_wyjsciowy

plik_wejsciowy - nazwa pliku, z ktorego maja byc pobrane dane. Z linii posiadajacych tekst zamkniety w [], tylko ta
czesc bedzie przekazana do wynikow.

[nieobowiazkowe] true/false - czy w danym pliku znajduja sie adresy podsieci z prefiksami(true - domyslnie), czy sa tam
wszystkie adresy z typami PDU(false) - taki plik zostanie utworzony, jesli wybierzemy true lub podamy sama nazwe pliku
wejsciowego. Jesli plik ma wczesniej przygotowane adresy oraz typy to wpisujac false od razu przechodzimy do kroku 3.


[nieobowiazkowe] plik_wyjsciowy - nazwa pliku, do ktorego beda zapisane adresy ip, typ PDU oraz statusy wszystkich
portow w formacie csv (domyslnie jest to data_czas_PDU_status.csv). Wczesniej nalezy oczywiscie podac
poprzednie parametry.

Nazwa pliku zawierajacego wylacznie adresy i typy PDU to plik_wyjsciowy_typesxxx, gdzie xxx to rozszerzenie
podanej nazwy pliku/domyslne .csv/zadne, jesli podano plik bez rozszerzenia.

Wspierane typy PDU: ATEN, Gude_8220-1, Gude_8221-1, Gude_8226-1, inne Gude_EPC, APC, IQDG-SWH

Jesli typem PDU jest unknown to:
- ten PDU nie jest wspierany
- protokol SNMPv1 na PDU nie zostal wlaczony
- jest inne urzadzenie
- ustawiony czas nie wystarcza na polaczenie

---[ENG]---
Short description of PDU ports status checking - Python3.6

1. The script will use date from file with provided name and (by default) will ping every address in each subnet.
2. Before going to the next subnet types of the PDUs, at the responding addresses, are going to be checked and saved to
the types file. Process will continue until reaching the end of file.
3. From that file ports of the known PDU types being explored and saved to final output file.

How to run the script:
python3.6 PDU_status.py input_file true/false output_file

input_file - name of a file from which the script will get the data it has to process. From lines containing [], only
that part will be included in the file with results.

[optional] true/false - are there subnets addresses with prefixes in the input file(true - default) or false if file
contains addresses with PDU types - then the script will move to 3rd step. That file will be created after choosing true
or not passing that parameter.

[optional] output_file - name of a file to which results will be saved in csv format
(default - date_time_PDU_status.csv). Before that previous parameters are required.

File that contains only addresses and PDU types is output_file_typesxxx, in which xxx is file extension from given name/
default .csv/nothing if not specified

Supported PDU types: ATEN, Gude_8220-1, Gude_8221-1, Gude_8226-1, other Gude_EPC, APC, IQDG-SWH

If PDU type is unknown, then:
- that PDU type is not supported
- SNMPv1 protocol hasn't been turned on
- it is other device
- timeout was too short
