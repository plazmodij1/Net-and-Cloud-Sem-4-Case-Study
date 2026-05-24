const express = require('express');
const app = express();

// Robust JWT Decoder that handles Base64URL safely
function decodeJWT(token) {
  if (!token) return {};
  try {
    const base64Url = token.split('.')[1];
    // Convert Base64URL to standard Base64 before decoding
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = Buffer.from(base64, 'base64').toString('utf-8');
    return JSON.parse(jsonPayload);
  } catch (e) {
    return { error: "Failed to parse JWT" };
  }
}

app.get('/', (req, res) => res.redirect('/portal'));

// 🚀 NEW: The X-Ray Debug Route
app.get('/debug', (req, res) => {
  const dataHeader = req.headers['x-amzn-oidc-data'];
  const accessTokenHeader = req.headers['x-amzn-oidc-accesstoken'];
  
  const user = decodeJWT(dataHeader);
  const accessData = decodeJWT(accessTokenHeader);
  
  res.send(`
    <h1>Token X-Ray Machine</h1>
    <hr>
    <h3>Access Token (Should contain cognito:groups):</h3>
    <pre>${JSON.stringify(accessData, null, 2)}</pre>
    <hr>
    <h3>ID Token (Data Header):</h3>
    <pre>${JSON.stringify(user, null, 2)}</pre>
  `);
});

app.get('/portal', (req, res) => {
  const dataHeader = req.headers['x-amzn-oidc-data'];
  const accessTokenHeader = req.headers['x-amzn-oidc-accesstoken'];
  
  if (!dataHeader || !accessTokenHeader) {
    return res.status(401).send("Unauthorized: Missing ALB Identity Headers");
  }

  try {
    const user = decodeJWT(dataHeader);
    const accessData = decodeJWT(accessTokenHeader);
    
    const userEmail = user.email || 'Unknown Email';
    const userGroups = accessData['cognito:groups'] || []; 

    // Better logging: JSON.stringify ensures empty arrays print clearly as []
    console.log(`User ${userEmail} logged in with groups: ${JSON.stringify(userGroups)}`);

    if (userGroups.includes('HR-Admins')) {
      res.send(`
        <h1>Welcome Admin: ${userEmail}</h1>
        <button>Trigger Employee Onboarding</button>
        <button>Trigger Employee Offboarding</button>
      `);
    } else if (userGroups.includes('Employee')) {
      res.send(`
        <h1>Welcome Employee: ${userEmail}</h1>
        <p>View your personal profile and pay stubs here.</p>
      `);
    } else {
      res.status(403).send("Forbidden: Unrecognized User Group");
    }
  } catch (error) {
    console.error("Server Crash:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.listen(8080, () => console.log('Self-Service Portal running on port 8080'));