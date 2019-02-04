const Express = require("express");

const PORT = process.env.PORT || 8080;
const app = new Express();
app.use(Express.static("./static"));
app.listen(
    PORT, 
    () => console.log(`Listening on port ${PORT}`)
    );