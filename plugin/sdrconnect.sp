#pragma semicolon 1
#include <sourcemod>

// player connected trough favorites or connect string
bool clientConnectedDirectly[MAXPLAYERS+1];

char serverIp[40];


public Plugin:myinfo = {
	name = "sdrconnect",
	author = "Icewind",
	description = "Chat command to connect to the server via sdr",
	version = "0.1",
	url = "https://spire.tf"
};

public OnPluginStart() {
    char clientConnectMethod[64];
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            GetClientInfo(client, "cl_connectmethod", clientConnectMethod, sizeof(clientConnectMethod));

            if (!StrEqual(clientConnectMethod, "serverbrowser_internet")) {
                clientConnectedDirectly[client] = true;
            }
        }
    }
}

public void OnClientPutInServer(int client) {
    char clientConnectMethod[64];
    GetClientInfo(client, "cl_connectmethod", clientConnectMethod, sizeof(clientConnectMethod));
    if (!StrEqual(clientConnectMethod, "serverbrowser_internet")) {
        clientConnectedDirectly[client] = true;
    }
}

public void OnClientDisconnect(int client) {
    clientConnectedDirectly[client] = false;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
    if (strcmp(sArgs, "!sdr", false) == 0) {
        CreateTimer(0.1, HandleCommand, client);
    }

    return Plugin_Continue;
}

public Action HandleCommand(Handle Timer, int client) {
    retrieveServerIp();
    PrintToChatAll("\x01[\x03SDR\x01]: connect %s", serverIp);

    if (clientConnectedDirectly[client]) {
        Panel panel = new Panel();
        panel.SetTitle("SDR");
        panel.DrawText("Re-connect through SDR?");
        panel.CurrentKey = 3;
        panel.DrawItem("Accept");
        panel.DrawItem("Decline");
        panel.Send(client, MenuConfirmHandler, 15);
    } else {
        PrintToChat(client, "\x01[\x03SDR\x01] Due to Valve game change, clients must connect via connect string or favorites to be redirected by server.");
    }

    return Plugin_Handled;
}

public MenuConfirmHandler(Menu menu, MenuAction action, int client, int choice) {
    if (choice == 3) {
        ClientCommand(client, "redirect %s", serverIp);
    }
}

public void retrieveServerIp() {
    char status[1024];
    char lines[3][100];
    char ips[8][50];
    ServerCommandEx(status, sizeof(status), "status");
    ExplodeString(status, "\n", lines, sizeof(lines), sizeof(lines[]));
    ExplodeString(lines[2], " ", ips, sizeof(ips), sizeof(ips[]));
    strcopy(serverIp, sizeof(serverIp), ips[3]);
}