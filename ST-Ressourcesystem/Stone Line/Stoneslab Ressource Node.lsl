// Second Life LSL Script for a Stoneslab Dispenser
// This script manages a stock of "Stoneslab" items and dispenses them to clicking avatars.
// It now includes a timer to automatically refill the stock over time.

// Global variable to store the current count of Stoneslab.
// It starts at 10, representing the initial available stock.
integer g_woodCount = 10;

// The maximum count the Stoneslab stock can reach.
integer g_maxWoodCount = 50;

// The name of the inventory item that this prim should give to the player.
// Make sure an item with this exact name exists in the prim's inventory.
string g_itemName = "Stoneslab";

// The interval in seconds at which the stock will increase by 1.
// For example, 300.0 seconds = 5 minutes.
float g_refillInterval = 900.0; // Refill every 5 minutes (300 seconds)

default
{
    // This event runs once when the script starts or is reset.
    state_entry()
    {
        // Set the initial hovertext displayed above the prim.
        // The text shows the current count out of the maximum.
        // The color is orange (<1.0, 0.5, 0.0>) and it's fully opaque (1.0).
        llSetText("Stoneslab: " + (string)g_woodCount + "/" + (string)g_maxWoodCount, <1.0, 0.5, 0.0>, 1.0);

        // Start the timer event to periodically refill the stock.
        // The timer will fire every g_refillInterval seconds.
        llSetTimerEvent(g_refillInterval);
    }

    // This event triggers when an avatar clicks on the prim.
    touch_start(integer total_number)
    {
        // Get the unique identifier (key) of the avatar who clicked the prim.
        key agent = llDetectedKey(0);

        // Check if there is any Stoneslab left to give.
        if (g_woodCount > 0)
        {
            // If yes, decrement the count by 1.
            g_woodCount--;

            // Give one item named 'g_itemName' (Stoneslab) from the prim's inventory
            // to the clicking avatar. Make sure the 'Stoneslab' item is in the prim's inventory.
            llGiveInventory(agent, g_itemName);

            // Send a message to the local chat confirming the item was given.
            llSay(0, "You received 1 " + g_itemName + "!");
        }
        else
        {
            // If the count is 0, inform the player that no wood is currently available.
            llSay(0, "The Woodcutter are working, to get more, come later back!");
        }

        // After every click, update the hovertext to reflect the new count.
        llSetText("Stoneslab: " + (string)g_woodCount + "/" + (string)g_maxWoodCount, <1.0, 0.5, 0.0>, 1.0);
    }

    // This event triggers when the timer set by llSetTimerEvent fires.
    timer()
    {
        // Check if the current wood count is less than the maximum allowed.
        if (g_woodCount < g_maxWoodCount)
        {
            // If it is, increment the wood count by 1.
            g_woodCount++;

            // Update the hovertext to show the new, increased count.
            llSetText("Stoneslab: " + (string)g_woodCount + "/" + (string)g_maxWoodCount, <1.0, 0.5, 0.0>, 1.0);

            // Optionally, you can add a message to the owner or local chat
            // when the stock is refilled, but be careful not to spam the chat.
            // llOwnerSay("Stoneslab stock refilled to " + (string)g_woodCount);
        }
        else
        {
            // If the stock is already at maximum, we can stop the timer
            // to save resources until it's needed again.
            // However, for continuous refill, you might want to keep it running.
            // If you want it to stop at max and restart when depleted, you'd need
            // to re-enable the timer in touch_start when g_woodCount becomes < g_maxWoodCount.
            // For now, it just keeps checking.
        }
    }
}
