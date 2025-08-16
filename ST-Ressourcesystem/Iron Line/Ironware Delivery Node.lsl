// LSL Object Counter Script
// Counts objects with a specific name that are dropped into the prim's inventory,
// and also displays a total inventory count.

// --- Configuration Variables ---
// Adjust these variables to set up the script for your project.
string TARGET_NAME = "Ironware";
integer MAX_COUNT = 150; // Maximum number of objects needed

// --- Script Variables ---
integer currentCount = 0;      // Counts the specific TARGET_NAME objects.
integer totalInventoryCount = 0; // NEW: Counts all items in the prim's inventory.
string hoverText = "";
string my_script_name;       // Variable to store the script's name

default
{
    // --- state_entry: Executed once when the script starts ---
    state_entry()
    {
        // Store the name of the script to prevent it from accidentally being deleted.
        my_script_name = llGetScriptName();

        // Allow others to drop items into this prim's inventory.
        llAllowInventoryDrop(TRUE);

        // Initialize total inventory count and currentCount at startup
        totalInventoryCount = 0;
        currentCount = 0; // Ensure currentCount starts at 0 for initial counting
        integer i;
        integer num_items;

        // Count objects (the type we are interested in for currentCount)
        num_items = llGetInventoryNumber(INVENTORY_OBJECT);
        for (i = 0; i < num_items; i++)
        {
            string item_name = llGetInventoryName(INVENTORY_OBJECT, i);
            // Check if the item is our script; we don't count it as a deliverable.
            if (item_name != my_script_name)
            {
                // This part is crucial for initial setup if objects are already in inventory.
                // Now, we will also count existing TARGET_NAME objects on startup.
                integer is_target_item = FALSE;
                integer target_name_len = llStringLength(TARGET_NAME);

                // Check if the new item name starts with the TARGET_NAME
                if (llSubStringIndex(item_name, TARGET_NAME) == 0)
                {
                    // Case 1: Exact match (e.g., "Ironware")
                    if (llStringLength(item_name) == target_name_len)
                    {
                        is_target_item = TRUE;
                    }
                    // Case 2: Check characters after TARGET_NAME if the name is longer
                    else if (llStringLength(item_name) > target_name_len)
                    {
                        string suffix_char = llGetSubString(item_name, target_name_len, target_name_len);

                        // If the next character is a space, it's valid (e.g., "Ironware 1")
                        if (suffix_char == " ")
                        {
                            is_target_item = TRUE;
                        }
                        // If the next character is a digit (e.g., "Ironware1", "Ironware2")
                        else
                        {
                            // Define a list of all digit characters
                            list digits = ["0","1","2","3","4","5","6","7","8","9"];
                            // Check if the suffix_char exists within the list of digits
                            if (llListFindList(digits, [suffix_char]) != -1)
                            {
                                is_target_item = TRUE;
                            }
                        }
                    }
                }
                
                if (is_target_item)
                {
                    currentCount++; // Increment currentCount for existing TARGET_NAME objects
                }
            }
            totalInventoryCount++; // Count all objects including the script itself for total inventory
        }

        // Add other inventory types to total count if desired (e.g., textures, sounds, notecards)
        // For simplicity, this example primarily focuses on INVENTORY_OBJECT for the specific counter,
        // but totalInventoryCount will reflect everything.
        totalInventoryCount += llGetInventoryNumber(INVENTORY_TEXTURE);
        totalInventoryCount += llGetInventoryNumber(INVENTORY_SOUND);
        totalInventoryCount += llGetInventoryNumber(INVENTORY_ANIMATION);
        totalInventoryCount += llGetInventoryNumber(INVENTORY_NOTECARD);
        totalInventoryCount += llGetInventoryNumber(INVENTORY_SCRIPT); // Scripts, besides my_script_name
        // ... add other types as needed (e.g., INVENTORY_LANDMARK, INVENTORY_CLOTHING, etc.)

        // Initialize the hover text above the prim
        // UPDATED: Now includes total inventory count again
        hoverText = "Delivered Ironware: " + (string)currentCount + " / " + (string)MAX_COUNT;
        llSetText(hoverText, <1.0, 1.0, 1.0>, 1.0); // White text, full opacity

        llSay(0, "Object counter is active and ready.");
        llSay(0, "Current count of " + TARGET_NAME + " objects: " + (string)currentCount);
        llSay(0, "Current total inventory items: " + (string)totalInventoryCount); // Still announce in chat
    }

    // --- changed: Triggered when the prim changes (e.g., inventory change) ---
    changed(integer change)
    {
        if ((change & CHANGED_INVENTORY) || (change & CHANGED_ALLOWED_DROP))
        {
            // Reset total inventory count and recount all items to reflect changes.
            totalInventoryCount = 0;
            integer i;
            integer num_items;

            // First, recount total inventory items correctly for all types
            // Reset currentCount for accurate recalculation based on current inventory
            currentCount = 0;

            num_items = llGetInventoryNumber(INVENTORY_OBJECT);
            for (i = 0; i < num_items; i++)
            {
                string item_name = llGetInventoryName(INVENTORY_OBJECT, i);

                // Only count non-script objects for the total inventory count
                if (item_name != my_script_name)
                {
                    totalInventoryCount++;
                }

                // ALSO, re-evaluate and update currentCount based on current inventory contents
                integer is_target_item = FALSE;
                integer target_name_len = llStringLength(TARGET_NAME);

                if (llSubStringIndex(item_name, TARGET_NAME) == 0)
                {
                    if (llStringLength(item_name) == target_name_len)
                    {
                        is_target_item = TRUE;
                    }
                    else if (llStringLength(item_name) > target_name_len)
                    {
                        string suffix_char = llGetSubString(item_name, target_name_len, target_name_len);
                        if (suffix_char == " ")
                        {
                            is_target_item = TRUE;
                        }
                        else
                        {
                            list digits = ["0","1","2","3","4","5","6","7","8","9"];
                            if (llListFindList(digits, [suffix_char]) != -1)
                            {
                                is_target_item = TRUE;
                            }
                        }
                    }
                }

                if (is_target_item)
                {
                    currentCount++; // Increment currentCount if it's a TARGET_NAME object
                }
            }

            // Add other inventory types to total count.
            totalInventoryCount += llGetInventoryNumber(INVENTORY_TEXTURE);
            totalInventoryCount += llGetInventoryNumber(INVENTORY_SOUND);
            totalInventoryCount += llGetInventoryNumber(INVENTORY_ANIMATION);
            totalInventoryCount += llGetInventoryNumber(INVENTORY_NOTECARD);
            totalInventoryCount += llGetInventoryNumber(INVENTORY_SCRIPT); // Count other scripts
            // ... add other types as needed

            // If the counter has already reached the maximum for TARGET_NAME, exit the function
            // after updating the total inventory count.
            if (currentCount >= MAX_COUNT)
            {
                llSay(0, "Maximum number of " + TARGET_NAME + " objects reached. I won't accept any more " + TARGET_NAME + ".");
                // Update hover text with the new total inventory count even if MAX_COUNT is reached
                llSetText("Delivered Ironware: " + (string)currentCount + " / " + (string)MAX_COUNT +"\n(Goal reached!)", <0.0, 1.0, 0.0>, 1.0);
                return; // Exit here, no further processing for TARGET_NAME specific items
            }

            // Get the number of objects in the inventory.
            // This is primarily for detecting the *newly added* TARGET_NAME object.
            // The totalInventoryCount and currentCount have already been updated above by recounting.
            integer inventory_size = llGetInventoryNumber(INVENTORY_OBJECT);

            // Now, we still need to check the *last added* object specifically for removal if it's not a target.
            // This part of the logic is for reacting to a *new drop* and potentially deleting it.
            if (inventory_size > 0)
            {
                string new_item_name = llGetInventoryName(INVENTORY_OBJECT, inventory_size - 1);

                // SAFETY CHECK: If the new item is the script itself, do nothing.
                if (new_item_name == my_script_name)
                {
                    // Update hover text even if it's just the script itself,
                    // as totalInventoryCount might have changed.
                    hoverText = "Delivered Ironware: " + (string)currentCount + " / " + (string)MAX_COUNT;
                    llSetText(hoverText, <1.0, 1.0, 1.0>, 1.0);
                    return;
                }

                integer is_target_item_just_added = FALSE; // Flag for the *specific item just added*
                integer target_name_len = llStringLength(TARGET_NAME);

                // Check if the new item name starts with the TARGET_NAME
                if (llSubStringIndex(new_item_name, TARGET_NAME) == 0)
                {
                    if (llStringLength(new_item_name) == target_name_len)
                    {
                        is_target_item_just_added = TRUE;
                    }
                    else if (llStringLength(new_item_name) > target_name_len)
                    {
                        string suffix_char = llGetSubString(new_item_name, target_name_len, target_name_len);
                        if (suffix_char == " ")
                        {
                            is_target_item_just_added = TRUE;
                        }
                        else
                        {
                            list digits = ["0","1","2","3","4","5","6","7","8","9"];
                            if (llListFindList(digits, [suffix_char]) != -1)
                            {
                                is_target_item_just_added = TRUE; // Corrected: changed to is_target_item_just_added
                            }
                        }
                    }
                }

                // If the *just added* item is NOT a target item, remove it.
                // We've already updated currentCount by recounting the whole inventory above.
                if (!is_target_item_just_added)
                {
                    llSay(0, "Wrong object: '" + new_item_name + "' was deleted from inventory.");
                    llRemoveInventory(new_item_name);
                    // Re-update totalInventoryCount immediately after removal.
                    // This is slightly redundant as 'changed' will fire again, but ensures immediate accuracy.
                    totalInventoryCount = 0;
                    for (i = 0; i < llGetInventoryNumber(INVENTORY_OBJECT); i++)
                    {
                        if (llGetInventoryName(INVENTORY_OBJECT, i) != my_script_name)
                        {
                            totalInventoryCount++;
                        }
                    }
                    totalInventoryCount += llGetInventoryNumber(INVENTORY_TEXTURE);
                    totalInventoryCount += llGetInventoryNumber(INVENTORY_SOUND);
                    totalInventoryCount += llGetInventoryNumber(INVENTORY_ANIMATION);
                    totalInventoryCount += llGetInventoryNumber(INVENTORY_NOTECARD);
                    totalInventoryCount += llGetInventoryNumber(INVENTORY_SCRIPT);
                }
            }

            // Update the hover text with the new counts, whether an item was added/removed or not.
            hoverText = "Delivered Ironware: " + (string)currentCount + " / " + (string)MAX_COUNT;
            llSetText(hoverText, <1.0, 1.0, 1.0>, 1.0);

            // If the goal is reached, set the text to green and disable the script.
            if (currentCount >= MAX_COUNT)
            {
                llSay(0, "Goal reached! Maximum count of " + (string)MAX_COUNT + " '" + TARGET_NAME + "' objects delivered.");
                llSetText("Delivered Ironware: " + (string)currentCount + " / " + (string)MAX_COUNT +"\n(Goal reached!)", <0.0, 1.0, 0.0>, 1.0);
                llSetScriptState(llGetScriptName(), FALSE); // Disable the script
            }
        }
    }
}
