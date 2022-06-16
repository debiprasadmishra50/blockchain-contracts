const jwt = require("jsonwebtoken");

function init() {
    // let token = jwt.sign({ item: "thisisapayload" }, secret, {
    //     expiresIn: "1d",
    // });

    // console.log(token);
    let token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpdGVtIjoidGhpc2lzYXBheWxvYWQiLCJpYXQiOjE2NDM5NjEyNjMsImV4cCI6MTY0NDA0NzY2M30.k3FL1GsIi8uzIo8RlhjUNbmWXAAP_LeVK2aiz-fKcMc";

    let secret = "thisisthesupersecret";

    let payload = jwt.verify(token, secret);

    console.log(payload);

    // /////////////////////////////////////////////////////////////

    token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MWZhODUxNDNlZTdiNWU4YjMwMGI0YWYiLCJpYXQiOjE2NDM4MDgzMTF9.LHkq45UjIi_OhaeZiqWhQKmWcphPcCkeDcbG4TZKlFc";

    secret = "thisisparaphraseforjwt";

    payload = jwt.verify(token, secret);

    console.log(payload);
}

init();
