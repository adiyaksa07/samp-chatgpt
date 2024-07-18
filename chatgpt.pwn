/*
    Filterscript chatgpt (openai)
    
    File yang dibutuhkan untuk menjalakan fs ini:
    Plugins : pawn-memory (https://github.com/BigETI/pawn-memory)
    Includes : 
        - requests (https://github.com/Southclaws/pawn-requests)
        - zcmd (https://github.com/Southclaws/zcmd)
        - strlib (https://github.com/oscar-broman/strlib)
        - map (https://github.com/BigETI/pawn-map)

    Author : Adiyaksa.
*/
#define FILTERSCRIPT
#include <a_samp>
#include <requests>
#include <zcmd> 
#include <strlib>
#include <map>

#if defined FILTERSCRIPT

#define MAX_LINK 36
#define MAX_CHATBUBBLE_LENGTH 144
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xFF0000FF
#define COLOR_YELLOW 0xFFFF00FF

new RequestsClient:client;
new Map:LoadRequestToPlayerID;

public OnFilterScriptInit()
{
	print(" Filterscript CHATGPT loaded");
	return 1;
}

RequestChat(playerid, params[]) { 
    new output[1000];
    new output1[1000];
    new link[MAX_CHATBUBBLE_LENGTH + MAX_LINK];

    strurlencode(output, "ingat jawab semua pesan / pertanyaan itu secara ringkas tidak boleh melebihi 144 karakter: ");
    strurlencode(output1, params);

    format(link, sizeof(link), "https://api.nyxs.pw/ai/gpt4?text=%s%s", output, output1);
    client = RequestsClient(link);

    new Request:id = RequestJSON(
        client, 
        "",
        HTTP_METHOD_GET,
        "OnGetData",
        .headers = RequestHeaders( 
            "accept", "application/json"
        )
    );

    MAP_insert_val_val(LoadRequestToPlayerID, _:id, playerid);    
    return 1; 
}

forward OnGetData(Request:id, E_HTTP_STATUS:status, Node:node);
public OnGetData(Request:id, E_HTTP_STATUS:status, Node:node) {
    new string[200];
    new playerid = MAP_get_val_val(LoadRequestToPlayerID, _:id);

    MAP_remove_val(LoadRequestToPlayerID, _:id);
    JsonGetString(node, "result", string);

    if(strlen(string) > MAX_CHATBUBBLE_LENGTH) { 
        SendClientMessage(playerid, COLOR_YELLOW, "*Whoopss: output ai melebihi 144 karakter");
    } else { 
        SendClientMessage(playerid, COLOR_WHITE, string);
    }
    return 1;
}


CMD:chat(playerid, params[]) { 
    if (isnull(params)) { 
        SendClientMessage(playerid, COLOR_RED, "*INFO : /chat <pesan luh>");
    } else { 
        RequestChat(playerid, params);
    }
    return 1; 
}
#endif