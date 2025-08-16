key currentUser;
string siteUrl = "siteURL";
string authKey = "AUTHKEY";
integer ANTI_SPAM_SECONDS = 240;
key lastUser;
float nextTouchTime = 0.0;
key doRequest(string cmd, list data){
 
    string json = llList2Json(JSON_OBJECT, [
        "rawCmd", llEscapeURL(cmd),   
        "ownerKey", llGetOwner(),     
        "unixtime", llGetUnixTime(),  
        "authKey", authKey            
    ] + data);
    
    return llHTTPRequest(siteUrl, [
        HTTP_METHOD, "POST",                  
        HTTP_BODY_MAXLENGTH, 16384,           
        HTTP_MIMETYPE, "application/x-www-form-urlencoded", 
        HTTP_VERBOSE_THROTTLE, FALSE          
    ], "lslData=" + json);
}


default
{
    
    collision_start(integer num)
    {
        currentUser = llDetectedKey(0);
        
        if (currentUser == lastUser && llGetWallclock() < nextTouchTime) {
            
            return;
        }

        
        lastUser = currentUser;
        nextTouchTime = llGetWallclock() + ANTI_SPAM_SECONDS;
        
        
        doRequest("Data ActiveChar", ["uuidSource", (string)currentUser]);
    }

    
    http_response(key request_id, integer status, list metadata, string body)
    {
        
        
        
        if(status != 200) return;

        
        string userName = llJsonGetValue(body, ["name"]);

        
        llRegionSayTo(currentUser, 0, "Welcome " + userName + " to the free city of Nova Cerulle. Please become familiar with the information posted on the board to my left.");
    }
}
