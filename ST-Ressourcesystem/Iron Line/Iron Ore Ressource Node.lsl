integer g_uses = 0;              
integer g_resource_depleted = FALSE; 
vector g_start_pos;              
key g_last_clicker = NULL_KEY;   
float g_last_click_time = 0.0;   

default
{
    
    state_entry()
    {
        
        g_start_pos = llGetPos();
        llOwnerSay("Iron Ore is ready!");
    }

    
    touch_start(integer total_number)
    {
        
        key toucher = llDetectedKey(0);

        
        
        if (toucher == g_last_clicker && llGetTime() < g_last_click_time + 2.0) {
            
            return;
        }

        
        g_last_clicker = toucher;
        g_last_click_time = llGetTime();
        
        
        if (g_resource_depleted) {
            llInstantMessage(toucher, "This resource has been depleted. It will regenerate shortly.");
            return;
        }

        
        g_uses++;
        
        
        
        float current_depth = 1.0 * g_uses / 10;
        vector new_pos = g_start_pos - <0.0, 0.0, current_depth>;
        llSetPos(new_pos);

        
        if (g_uses >= 10) {
            g_resource_depleted = TRUE;
            llInstantMessage(toucher, "This resource has been depleted!");
            
            
            llSetTimerEvent(3600.0);
        } else {
            
            
            if (llFrand(1.0) < 0.5) {
                
                integer num_items = llGetInventoryNumber(INVENTORY_OBJECT);
                if (num_items > 0) {
                    
                    string item_name = llGetInventoryName(INVENTORY_OBJECT, (integer)llFrand(num_items));
                    llGiveInventory(toucher, item_name);
                    llInstantMessage(toucher, "You have carved " + item_name + "out of the stone! You have " + (string)(10 - g_uses) + " clicks left.");
                } else {
                    llInstantMessage(toucher, "Inventory is empty, but you have mined something!");
                }
            } else {
                
                llInstantMessage(toucher, "You tried, but you didn't get any usable iron ore out of it. You have " + (string)(10 - g_uses) + " clicks left.");
            }
        }
    }

    
    timer()
    {
        
        g_resource_depleted = FALSE;
        g_uses = 0;
        llSetPos(g_start_pos);
        
        
        llSetTimerEvent(0.0);
        
        llSay(0, "Iron Ore has regenerated and is ready for action again!");
    }
}
