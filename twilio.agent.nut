class Twilio {
    _baseUrl = "https://api.twilio.com/2010-04-01/Accounts/";

    _accountSid = null;
    _authToken = null;
    _phoneNumber = null;

    constructor(accountSid, authToken, phoneNumber) {
        _accountSid = accountSid;
        _authToken = authToken;
        _phoneNumber = phoneNumber;
    }

    function send(to, message, callback = null) {
        local url = _baseUrl + _accountSid + "/SMS/Messages.json"

        local auth = http.base64encode(_accountSid + ":" + _authToken);
        local headers = { "Authorization": "Basic " + auth };

        local body = http.urlencode({
            From = _phoneNumber,
            To = to,
            Body = message
        });

        local request = http.post(url, headers, body);
        if (callback == null) return request.sendsync();
        else request.sendasync(callback);
    }

    function respond(resp, message = null) {
        local data = { Response = { Message = message } };
        
        if (message == null)
        {
            data = { Response = "" }
        }
        
        local body = xmlEncode(data);

        resp.header("Content-Type", "text/xml");

        server.log(body);

        resp.send(200, body);
    }

    function xmlEncode(data, version="1.0", encoding="UTF-8") {
        return format("<?xml version=\"%s\" encoding=\"%s\" ?>%s", version, encoding, _recursiveEncode(data))
    }

    /******************** Private Function (DO NOT CALL) ********************/
    function _recursiveEncode(data) {
        local s = "";
        foreach(k, v in data) {
            if (typeof(v) == "table" || typeof(v) == "array") {
                s += format("<%s>%s</%s>", k.tostring(), _recursiveEncode(v), k.tostring());
            }
            else {
                s += format("<%s>%s</%s>", k.tostring(), v.tostring(), k.tostring());;
            }
        }
        return s
    }
}
