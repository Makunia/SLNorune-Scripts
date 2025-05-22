// Configuration
float SENSOR_RANGE = 5.0; // 5 meters
float SCAN_INTERVAL = 2.0; // seconds between scans
integer ANTI_SPAM_SECONDS = 240; // 1 minute

// Storage for last messaged times
list recentAvatars;
list recentTimes;

string MESSAGE = "Norune Forest<->Sabhaif Oasis Transitarea.\n********************************************\nThis is a transit area to symbolize the long distances between the different areas. If you are traveling in character, allow some time for the journey from the forest over the mountains into the desert, usually 1-3 days.";

// Helper to get index of an avatar by key
integer avatarIndex(key av) {
    integer i = llListFindList(recentAvatars, [av]);
    return i;
}

default
{
    state_entry()
    {
        llSensorRepeat("", NULL_KEY, AGENT, SENSOR_RANGE, PI, SCAN_INTERVAL);
    }

    sensor(integer num_detected)
    {
        integer i;
        integer now = (integer)llGetUnixTime();
        for (i = 0; i < num_detected; ++i) {
            key av = llDetectedKey(i);
            integer idx = avatarIndex(av);
            integer lastTime = 0;
            if (idx != -1) {
                lastTime = llList2Integer(recentTimes, idx);
            }
            if (idx == -1 || now - lastTime >= ANTI_SPAM_SECONDS) {
                // Send IM
                llInstantMessage(av, MESSAGE);
                // Update or add to recent lists
                if (idx == -1) {
                    recentAvatars += [av];
                    recentTimes += [now];
                } else {
                    recentTimes = llListReplaceList(recentTimes, [now], idx, idx);
                }
            }
        }
        // Optional: Clean up avatars not detected for a long time (not strictly needed)
    }
}
