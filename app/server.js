const express = require('express');
const app = express();
const PORT = process.env.PORT || 8000;

app.get('/', (req, res) => {
    res.send('Hello from the Node.js app!');
});
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});