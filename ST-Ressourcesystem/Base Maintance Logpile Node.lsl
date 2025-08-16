// LSL Maintenance Script for Timberwood
// Counts 'Timberwood' objects dropped into the prim's inventory and
// automatically reduces the count every 12 hours for 'maintenance'.

// --- Konfigurationsvariablen ---
string TARGET_NAME = "Timberwood"; // Der Name des Objekts, das für die Wartung gezählt werden soll
integer MAX_COUNT = 20; // Maximale Anzahl von Objekten, die der Prim für die Wartung aufnehmen kann
integer DECREMENT_AMOUNT = 5; // Menge an Timberwood, die für die Wartung verbraucht wird
float MAINTENANCE_INTERVAL = 43200.0; // Intervall für die Wartung in Sekunden (12 Stunden = 43200.0 Sekunden)

// --- Skript-Variablen ---
integer currentCount = 0; // Der aktuelle Zählerstand der Timberwood-Objekte
string hoverText = ""; // Der Text, der über dem Prim schwebt
string my_script_name; // Variable zum Speichern des Skriptnamens, um zu verhindern, dass das Skript selbst entfernt wird

// --- Funktion zum Aktualisieren des schwebenden Textes und zum Speichern des Zählerstands in der Beschreibung ---
updateCountAndText()
{
    // Sicherstellen, dass der Zählerstand nicht unter Null fällt
    if (currentCount < 0) {
        currentCount = 0;
    }

    // Den schwebenden Text über dem Prim aktualisieren
    hoverText = "Timberwood for Maintenance: " + (string)currentCount + " / " + (string)MAX_COUNT;
    llSetText(hoverText, <1.0, 1.0, 1.0>, 1.0); // Weißer Text, volle Deckkraft

    // Den aktuellen Zählerstand in der Beschreibung des Prims für die Persistenz über Resets hinweg speichern
    // Dies ermöglicht es dem Skript, seinen Zustand auch nach einem Neustart zu behalten.
    llSetObjectDesc((string)currentCount);
}

// --- Funktion zum Laden des Zählerstands aus der Beschreibung des Prims ---
loadCountFromDescription()
{
    string desc = llGetObjectDesc(); // Ruft die Beschreibung des Prims ab
    integer loaded_count = (integer)desc; // Versucht, die Beschreibungszeichenfolge in eine Ganzzahl umzuwandeln

    // Den geladenen Zählerstand validieren, um sicherzustellen, dass er eine nicht-negative Zahl und nicht übermäßig groß ist
    if (loaded_count >= 0 && loaded_count <= MAX_COUNT) {
        currentCount = loaded_count;
        llSay(0, "Loaded previous Timberwood count: " + (string)currentCount); // Gibt eine Nachricht in den Chat aus
    } else {
        currentCount = 0; // Wenn die Beschreibung leer oder ungültig ist, bei 0 beginnen
        llSay(0, "Starting with fresh Timberwood count: " + (string)currentCount); // Gibt eine Nachricht in den Chat aus
    }
}

// --- Funktion zum erneuten Zählen aller passenden Objekte im Inventar ---
recountInventory()
{
    integer newCount = 0;
    integer inventory_size = llGetInventoryNumber(INVENTORY_OBJECT);
    integer target_name_len = llStringLength(TARGET_NAME);
    list digits = ["0","1","2","3","4","5","6","7","8","9"];

    // LSL-freundliche while-Schleife zur Iteration durch das Inventar
    integer i = 0;
    while (i < inventory_size)
    {
        string item_name = llGetInventoryName(INVENTORY_OBJECT, i);
        
        // Nur verarbeiten, wenn es nicht das Skript selbst ist
        if (item_name != my_script_name) {
            integer is_target_item = FALSE;

            // Prüfen, ob der Gegenstandsname mit TARGET_NAME beginnt und einen gültigen Suffix hat
            if (llSubStringIndex(item_name, TARGET_NAME) == 0)
            {
                if (llStringLength(item_name) == target_name_len)
                {
                    is_target_item = TRUE; // Exakter Treffer
                }
                else if (llStringLength(item_name) > target_name_len)
                {
                    string suffix_char = llGetSubString(item_name, target_name_len, target_name_len);
                    if (suffix_char == " " || llListFindList(digits, [suffix_char]) != -1)
                    {
                        is_target_item = TRUE;
                    }
                }
            }

            if (is_target_item)
            {
                newCount++;
            }
        }
        
        i++; // Wichtig: Zähler nach jedem Durchlauf erhöhen
    }
    
    currentCount = newCount;
    llSay(0, "Recounted Timberwood objects. Current total: " + (string)currentCount);
    updateCountAndText(); // Text und Zählerstand aktualisieren und speichern
}

default
{
    // --- state_entry: Wird einmal ausgeführt, wenn das Skript startet oder zurückgesetzt wird ---
    state_entry()
    {
        my_script_name = llGetScriptName(); // Speichert den Namen des Skripts, um es von Objekten im Inventar zu unterscheiden
        llAllowInventoryDrop(TRUE); // Erlaubt anderen, Gegenstände in dieses Prim zu legen

        loadCountFromDescription(); // Lädt einen zuvor gespeicherten Zählerstand
        recountInventory(); // Führt einen vollständigen Inventar-Recount durch, um sicherzustellen, dass der Zählerstand korrekt ist

        llSetTimerEvent(MAINTENANCE_INTERVAL); // Startet den Wartungs-Timer
        llSay(0, "Timberwood maintenance script is active. Initial count: " + (string)currentCount); // Bestätigung, dass das Skript aktiv ist
    }
    
    // --- changed: Wird ausgelöst, wenn sich der Prim ändert (z. B. Inventaränderung) ---
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            // Zuerst alle neu hinzugefügten Objekte überprüfen und falsche Typen sofort ablehnen.
            integer inventory_size = llGetInventoryNumber(INVENTORY_OBJECT);
            if (inventory_size > 0)
            {
                string new_item_name = llGetInventoryName(INVENTORY_OBJECT, inventory_size - 1); // Name des zuletzt hinzugefügten Objekts

                if (new_item_name != my_script_name) // Nur verarbeiten, wenn es nicht das Skript ist
                {
                    integer is_target_item = FALSE;
                    integer target_name_len = llStringLength(TARGET_NAME);
                    list digits = ["0","1","2","3","4","5","6","7","8","9"];

                    if (llSubStringIndex(new_item_name, TARGET_NAME) == 0)
                    {
                        if (llStringLength(new_item_name) == target_name_len)
                        {
                            is_target_item = TRUE;
                        }
                        else if (llStringLength(new_item_name) > target_name_len)
                        {
                            string suffix_char = llGetSubString(new_item_name, target_name_len, target_name_len);
                            if (suffix_char == " " || llListFindList(digits, [suffix_char]) != -1)
                            {
                                is_target_item = TRUE;
                            }
                        }
                    }

                    if (!is_target_item)
                    {
                        llSay(0, "Wrong object: '" + new_item_name + "' was deleted from inventory.");
                        llRemoveInventory(new_item_name); // Entfernt das nicht passende Objekt
                    }
                    else
                    {
                        llSay(0, "A '" + TARGET_NAME + "' object was detected in inventory change.");
                    }
                }
            }
            
            // Führe nach jeder Inventaränderung und anfänglichen Filterung eine vollständige Zählung durch.
            // Dies stellt sicher, dass currentCount immer genau auf dem tatsächlichen Inventar basiert.
            recountInventory();

            // Nach der Zählung prüfen, ob der Zählerstand MAX_COUNT überschreitet und Überschüsse zurückgeben.
            // Dies behandelt Fälle, in denen Gegenstände in großen Mengen hinzugefügt wurden oder MAX_COUNT reduziert wurde.
            while (currentCount > MAX_COUNT)
            {
                string item_to_remove = "";
                integer item_found_for_removal = FALSE; // Flag, um zu signalisieren, dass ein Objekt gefunden wurde
                
                // LSL-freundliche while-Schleife für die Rückwärtsiteration
                integer i = llGetInventoryNumber(INVENTORY_OBJECT) - 1;
                while (i >= 0 && !item_found_for_removal) // Schleife, solange i gültig ist und kein Objekt gefunden wurde
                {
                    string temp_item_name = llGetInventoryName(INVENTORY_OBJECT, i);
                    
                    if (temp_item_name != my_script_name) { // Nur verarbeiten, wenn es nicht das Skript ist
                        integer is_target_item_check = FALSE;
                        integer target_name_len_check = llStringLength(TARGET_NAME);
                        list digits_check = ["0","1","2","3","4","5","6","7","8","9"];

                        if (llSubStringIndex(temp_item_name, TARGET_NAME) == 0)
                        {
                            if (llStringLength(temp_item_name) == target_name_len_check)
                            {
                                is_target_item_check = TRUE;
                            }
                            else if (llStringLength(temp_item_name) > target_name_len_check)
                            {
                                string suffix_char = llGetSubString(temp_item_name, target_name_len_check, target_name_len_check);
                                if (suffix_char == " " || llListFindList(digits_check, [suffix_char]) != -1)
                                {
                                    is_target_item_check = TRUE;
                                }
                            }
                        }

                        if (is_target_item_check) {
                            item_to_remove = temp_item_name;
                            item_found_for_removal = TRUE; // Objekt gefunden, Flag setzen
                            // Kein jump/break hier, da die Schleifenbedingung (item_found_for_removal) den Ausstieg steuert.
                        }
                    }
                    i--; // Wichtig: Zähler nach jedem Durchlauf dekrementieren
                }

                if (item_to_remove != "") {
                    llSay(0, "Maximum Timberwood supply reached (" + (string)MAX_COUNT + "). Returning excess '" + item_to_remove + "'.");
                    llRemoveInventory(item_to_remove);
                    // Nach dem Entfernen eines Elements ändert sich das Inventar, daher sollten wir neu zählen
                    recountInventory(); // Nach jeder Entfernung neu zählen, um currentCount zu aktualisieren
                } else {
                    llSay(0, "Error: Could not find a Timberwood item to remove, despite currentCount (" + (string)currentCount + ") being over MAX_COUNT (" + (string)MAX_COUNT + ").");
                    currentCount = MAX_COUNT; // Setzen, um zu verhindern, dass die Schleife unendlich läuft
                    // Wenn es keine weiteren Objekte vom Typ TARGET_NAME gibt, kann die Schleife nicht mehr entfernen.
                }
            }
        }
        else if (change & CHANGED_ALLOWED_DROP) {
            // Dieser Flag kann sich ändern, wenn die Berechtigungen des Prims extern geändert werden.
            // Hier sind keine direkten Maßnahmen erforderlich, da llAllowInventoryDrop(TRUE) in state_entry gesetzt wird.
            llSay(0, "Drop permissions for prim have changed.");
        }
    }

    timer()
    {
        // Wenn Timberwood vorhanden ist, die Wartung durchführen
        if (currentCount > 0)
        {
            currentCount -= DECREMENT_AMOUNT; // Reduziert den Zählerstand um den Wartungsbetrag
            llSay(0, "Maintenance consumed " + (string)DECREMENT_AMOUNT + " Timberwood. Current count: " + (string)currentCount);
            updateCountAndText(); // Text und Zählerstand aktualisieren und speichern
        } else {
            llSay(0, "No Timberwood left for maintenance. Please add more!"); // Benachrichtigt, wenn kein Timberwood mehr vorhanden ist
        }
    }
}
