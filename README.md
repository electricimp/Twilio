#Twilio
The Twilio library wraps [Twilio's API](http://www.twilio.com/) for sending and receiving SMS message. To get started with this library, you will need a [Twilio developer account](http://developers.twilio.com/).

Once you've created your account, note your Twilio Phone Number, Account SID, and Auth Token.

## Twilio(AccountSID, AuthToken, TwilioNumber)
To create a new Twilio object, pass your SID, Auth token, and Twilio Number to the constructor:

```squirrel
twilio <- Twilio(TWILIO_SID, TWILIO_AUTH, TWILIO_NUM);
```

## Twilio.send(numberToSendTo, message, [callback])
The **send** method is used to send an SMS message. An optional callback can be passed to the function - if the callback is supplied, the message will be sent asynchronously, and your callback will fire when the HTTP request completes. If you don't pass a callback, it will execute the request syncronously, and return a [HTTPResonpse](http://electricimp.com/docs/api/HTTPResonse) object:

```squirrel
numberToSendTo <- "15555555555";
message <- "Hello World!";

// Syncronous send
local resp = twilio.send(numberToSendTo, message);
server.log(resp.statuscode + ": " + resp.body);

// Asyncronous Send
twilio.send(numberToSendTo, message, function(resp) {
	server.log(resp.statuscode + " - " + resp.body);
});
```

## Twilio.respond(HttpResonse, message)
You can respond to Twilio Text messages by using the **respond** methof, which will generate the necessary headers and XML for Twilio to understand your response. In the following exmaples, we're sending back a message of "You just said '{original message}'" - where {original message} is whatever the user sent to your Twilio phone number:

```squirrel
// processing messages
http.onrequest(function(req, resp) {
    local path = req.path.tolower();
    if (path == "/twilio" || path == "/twilio/") {
        // twilio request handler
        try {
            local data = http.urldecode(req.body);
            twilio.Respond(resp, "You just said '" + data.Body + "'");
        } catch(ex) {
            local message = "Uh oh, something went horribly wrong: " + ex;
            twilio.Respond(resp, message);
        }
    } else {
        // default request handler
        resp.send(200, "OK");
    }
});
```

**NOTE**: Before the above example will work, you need to configure your Twilio Phone Number:
## Parsing Incoming SMS Messages
 - Click on the phone number you would like to configure on the [Manage Numbers](https://www.twilio.com/user/account/phone-numbers/incoming) dashboard.
 - Change the **Request URL** under **Messaging** to your agent's URL, then click save. In the example code, we've tacked a /twilio to the end of the path so we know when the message is coming from Twilio: ```https://agent.electricimp.com/{agentID}/twilio```

#License
The Twilio library is licensed under the [MIT License](./LICENSE).
