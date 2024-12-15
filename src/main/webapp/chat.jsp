<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = request.getParameter("username");
    if (username == null || username.trim().isEmpty()) {
        // Si pas de nom, rediriger vers la page de login
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html>
<head>
    <title>Chat en temps réel</title>
    <style>
        #chatMessages {
            width: 500px;
            height: 300px;
            border: 1px solid #000;
            overflow-y: scroll;
            padding: 5px;
            margin-bottom: 10px;
        }
        #messageInput {
            width: 400px;
        }
    </style>
</head>
<body>
<h1>Chat - Connecté en tant que <%= username %></h1>
<div id="chatMessages"></div>
<input type="text" id="messageInput" placeholder="Votre message..." />
<button id="sendBtn">Envoyer</button>

<script type="text/javascript">
    (function() {
        var username = "<%= username %>";
        var ws = new WebSocket("ws://" + window.location.host + "<%= request.getContextPath() %>/chat");
        var chatMessages = document.getElementById("chatMessages");
        var messageInput = document.getElementById("messageInput");
        var sendBtn = document.getElementById("sendBtn");

        // A l'ouverture, on envoie le nom d'utilisateur
        ws.onopen = function() {
            ws.send(username);
        };

        // A la réception d'un message, on l'affiche
        ws.onmessage = function(evt) {
            var msg = document.createElement("div");
            msg.textContent = evt.data;
            chatMessages.appendChild(msg);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        };

        // Envoi du message lors du clic sur le bouton
        sendBtn.onclick = function() {
            sendMessage();
        };

        // Envoi du message lors de l'appui sur la touche Entrée
        messageInput.onkeypress = function(e) {
            if (e.key === 'Enter') {
                sendMessage();
            }
        };

        function sendMessage() {
            var msg = messageInput.value.trim();
            if (msg) {
                ws.send(msg);
                messageInput.value = "";
            }
        }

        ws.onclose = function() {
            var msg = document.createElement("div");
            msg.textContent = "** Connexion fermée **";
            chatMessages.appendChild(msg);
        };

        ws.onerror = function() {
            var msg = document.createElement("div");
            msg.textContent = "** Erreur de communication **";
            chatMessages.appendChild(msg);
        };
    })();
</script>
</body>
</html>
