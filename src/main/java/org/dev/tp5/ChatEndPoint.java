package org.dev.tp5;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;


@ServerEndpoint("/chat")
public class ChatEndPoint {


    private static Map<Session, String> userSessions = Collections.synchronizedMap(new HashMap<>());

    @OnOpen
    public void onOpen(Session session) {
    // on fait rien
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        //Message d'arrivée
        if (!userSessions.containsKey(session)) {
            userSessions.put(session, message);
            broadcast("** " + message + " a rejoint le chat. **", session);
        //Message de chat
        } else {

            String username = userSessions.get(session);
            broadcast(username + ": " + message, session);
        }
    }

    @OnClose
    public void onClose(Session session) {
        String username = userSessions.get(session);
        userSessions.remove(session);
        if (username != null) {
            broadcast("** " + username + " a quitté le chat. **", session);
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        throwable.printStackTrace();
    }

    //Diffusion du message à tous les utilisateurs
    private void broadcast(String message, Session senderSession) {
        synchronized (userSessions) {
            for (Session session : userSessions.keySet()) {
                if (session.isOpen()) {
                    try {
                        session.getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
