class Twilio {

    static VERSION = "2.0.0";
    static BASE_URL = "https://api.twilio.com/2010-04-01/Accounts/";

    /*
     * Private properties - do not access directly
     *
     */
    _accountSid = null;
    _authToken = null;
    _phoneNumber = null;

    /*
     * The constructor simply records the user's Twilio access credentals
     *
     * @constructor
     *
     */
    constructor(accountSid = null, authToken = null, phoneNumber = null) {
        // Check supplied parameters
        if (!_paramCheck(accountSid)) _bail("Twilio account SID");
        if (!_paramCheck(authToken)) _bail("Twilio account auth token");
        if (!_paramCheck(phoneNumber)) _bail("Twilio phone number");

        // Set private properties
        _accountSid = accountSid;
        _authToken = authToken;
        _phoneNumber = phoneNumber;
    }

    /*
     * Send an SMS message via Twilio.
     *
     * @param {string}   to       - The target mobile phone number in E.164 format
     * @param {string}   message  - The body of the message to send
     * @param {function} callback - An optional function called when the message has been transmitted. Default: null
     *
     * @returns {table} The HTTPResponse table if no callback is specified, otherwise null
     *
     */
    function send(to, message, callback = null) {
        // Assemble the request to Twilio
        local url = BASE_URL + _accountSid + "/Messages";
        local auth = http.base64encode(_accountSid + ":" + _authToken);
        local headers = {"Authorization": "Basic " + auth};
        local body = {"From": _phoneNumber, "To": to, "Body": message};
        local request = http.post(url, headers, http.urlencode(body));

        // Issue the request, synchronously or asynchronously
        if (callback == null) return request.sendsync();
        request.sendasync(callback);
    }

    /*
     * Respond to a notification from Twilio that an SMS message was received.
     * This is triggered by a webhook set on the Twilio dashboard
     *
     * @param {HTTPResponse} response - The system-assembled HTTPResponse to the original webhook-issued HTTPRequest
     * @param {string}       message  - The body of the message to return via Twilio to the SMS source
     *
     */
    function respond(response, message) {
        // Assemble the data to be sent back with the response
        local data = {"Response": {"Message": message}};
        local body = xmlEncode(data);
        response.header("Content-Type", "text/xml");
        response.send(200, body);
    }

    /*
     * Encode a response body in the XML format Twilio expects (TWiML)
     *
     * @param {any}    data     - The body data
     * @param {string} version  - The XML version. Default: "1.0"
     * @param {string} encoding - The XML file text encoding. Default: "UTF-8"
     *
     * @returns {string} The XML-encoded data
     */
    function xmlEncode(data, version = "1.0", encoding = "UTF-8") {
        return format("<?xml version=\"%s\" encoding=\"%s\" ?>%s", version, encoding, _recursiveEncode(data));
    }

    /******************** PRIVATE FUNCTIONS (DO NOT CALL) ********************/

    /*
     * Recursively convert Squirrel data structures into an XML string
     *
     * @param {any} data - The Squirrel data
     *
     * @returns {string} The SML data
     *
     * @private
     */
    function _recursiveEncode(data) {
        local s = "";
        foreach(k, v in data) {
            if (typeof(v) == "table" || typeof(v) == "array") {
                s += format("<%s>%s</%s>", k.tostring(), _recursiveEncode(v), k.tostring());
            } else if (v == null) {
                s += format("<%s />", k.tostring());
            } else {
                s += format("<%s>%s</%s>", k.tostring(), v.tostring(), k.tostring());
            }
        }
        return s;
    }

    /*
     * Check the supplied constructor argument is of the correct type and not null
     *
     * @param {string} param - The constructor argument
     *
     * @returns {boolean} True if the argument is valid, otherwise false
     *
     * @private
     */
    function _paramCheck(param) {
        // Make sure the supplied
        if (param == null || typeof param != "string" || param.len() == 0) return false;
        return true;
    }

    /*
     * Construct and throw an error if a method is supplied an invalid argument
     *
     * @param {string} reason - The reason for the error
     * @param {string} method - The Twilio library method in which the error took place.
     *
     * @private
     */
    function _bail(reason, method = "") {
        throw "Twilio" + (method.len() > 0 ? "." + method : "") + "() requires a valid " + reason;
    }
}
