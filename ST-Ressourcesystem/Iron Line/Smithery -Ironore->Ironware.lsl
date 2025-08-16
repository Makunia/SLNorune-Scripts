string IRON_ORE_NAME = "Iron Ore";
string IRONWARE_NAME = "Ironware";
integer TIMER_DURATION = 60;

integer gIronOreCount = 0;
key gOwner;
key gTimerRequester;
key gObjectInventoryID;

// Function to update the count of Iron Ore in the object's inventory
updateCount()
{
    integer count = 0;
    integer numItems = llGetInventoryNumber(INVENTORY_OBJECT);

    integer i;
    for (i = 0; i < numItems; i++)
    {
        string itemName = llGetInventoryName(INVENTORY_OBJECT, i);
        // Check if the item name contains "Iron Ore"
        if (llSubStringIndex(itemName, IRON_ORE_NAME) != -1)
        {
            count++;
        }
    }
    gIronOreCount = count;
    // Update the floating text above the object to show the current count
    llSetText(IRON_ORE_NAME + ": " + (string)gIronOreCount, <1.0, 1.0, 1.0>, 1.0);
}

default
{
    // This event runs when the script starts or is reset
    state_entry()
    {
        gOwner = llGetOwner(); // Get the owner of the object
        // Get the inventory ID of the "Ironware" object (used for giving it out)
        gObjectInventoryID = llGetInventoryKey(IRONWARE_NAME);

        // Check if "Ironware" object is missing from inventory
        if (gObjectInventoryID == "")
        {
            llSay(0, "Error: 'Ironware' object not found in inventory!");
        }

        updateCount(); // Initial count update
        llAllowInventoryDrop(TRUE); // Allow other users to drop items from their inventory into this object
    }

    // This event runs when the object is rezzed (created or moved from inventory to world)
    on_rez(integer start_param)
    {
        llResetScript(); // Reset the script to its initial state
    }
    
    // This event runs when the object's properties change, including inventory
    changed(integer change)
    {
        // Check if the change was due to inventory modification OR if the inventory drop permission changed
        if ((change & CHANGED_INVENTORY) || (change & CHANGED_ALLOWED_DROP))
        {
            updateCount(); // Update the count of Iron Ore
        }
    }

    // This event runs when another physical object collides with this object
    collision_start(integer num_detected)
    {
        integer i;
        for (i = 0; i < num_detected; i++)
        {
            string detectedName = llDetectedName(i);
            key detectedOwner = llDetectedOwner(i);

            // Check if the colliding object is an "Iron Ore" prim
            if (llSubStringIndex(detectedName, IRON_ORE_NAME) != -1)
            {
                // This script cannot directly take or delete a physical prim owned by another avatar.
                // Instruct the user on the correct way to deposit physical "Iron Ore"
                llInstantMessage(detectedOwner, "To deposit " + detectedName + ", please take it into your inventory first, then drag and drop it from your inventory onto this object. Thank you!");
                llSay(0, "A physical " + detectedName + " was detected. Instructing " + llKey2Name(detectedOwner) + " on how to deposit it.");
                // The item is not yet in the object's inventory, so no count update here.
                return; // Process only the first detected Iron Ore if multiple collide simultaneously
            }
        }
    }
    
    // This event runs when an avatar touches the object
    touch_start(integer total_number)
    {
        if (gIronOreCount > 0) // Check if there's enough Iron Ore to craft
        {
            if (gObjectInventoryID != "") // Check if the "Ironware" object is available
            {
                gTimerRequester = llDetectedKey(0); // Store the key of the avatar who touched
                llSay(0, "Crafting started. Please wait " + (string)(TIMER_DURATION/60) + " minutes.");
                llSetTimerEvent(TIMER_DURATION); // Start the timer for crafting
            }
            else
            {
                llInstantMessage(llDetectedKey(0), "Error: 'Ironware' object not found in inventory!");
            }
        }
        else
        {
            llInstantMessage(llDetectedKey(0), "Not enough 'Iron Ore' available!");
        }
    }
    
    // This event runs when the timer expires
    timer()
    {
        llSetTimerEvent(0.0); // Stop the timer

        if (gIronOreCount > 0) // Double-check if Iron Ore is still available
        {
            string oreToDeleteName = "";
            integer numItems = llGetInventoryNumber(INVENTORY_OBJECT);

            integer i;
            for (i = 0; i < numItems; i++)
            {
                string itemName = llGetInventoryName(INVENTORY_OBJECT, i);
                // Find an "Iron Ore" item to remove
                if (llSubStringIndex(itemName, IRON_ORE_NAME) != -1)
                {
                    oreToDeleteName = itemName;
                    jump FoundOre; // Jump out of the loop once an item is found
                }
            }

            @FoundOre; // Label to jump to
            if (oreToDeleteName != "")
            {
                llRemoveInventory(oreToDeleteName); // Remove one Iron Ore
                llGiveInventory(gTimerRequester, IRONWARE_NAME); // Give one Ironware to the requester
                llSay(0, "Crafting finished! 1 'Iron Ore' used and 1 'Ironware' given to " + llKey2Name(gTimerRequester) + ".");
                updateCount(); // Update the display count
            }
            else
            {
                llInstantMessage(gTimerRequester, "Crafting failed: No 'Iron Ore' could be found to delete!");
            }
        }
        else
        {
            llInstantMessage(gTimerRequester, "Crafting failed: Not enough 'Iron Ore' available!");
        }
    }
}
