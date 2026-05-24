const express = require('express');
const app = express();

// Automatically redirect root traffic to the portal
app.get('/', (req, res) => {
  res.redirect('/portal');
});

app.get('/portal', (req, res) => {
  // 1. Grab BOTH headers injected by the ALB
  const dataHeader = req.headers['x-amzn-oidc-data'];             // Contains Email
  const accessTokenHeader = req.headers['x-amzn-oidc-accesstoken']; // Contains Groups
  
  if (!dataHeader || !accessTokenHeader) {
    return res.status(401).send("Unauthorized: Missing ALB Identity Headers");
  }

  try {
    // 2. Decode the User Data (To get the Email)
    const dataPayloadBase64 = dataHeader.split('.')[1];
    const decodedDataPayload = Buffer.from(dataPayloadBase64, 'base64').toString('utf-8');
    const user = JSON.parse(decodedDataPayload);
    const userEmail = user.email;

    // 3. Decode the Access Token (To get the Groups)
    const accessPayloadBase64 = accessTokenHeader.split('.')[1];
    const decodedAccessPayload = Buffer.from(accessPayloadBase64, 'base64').toString('utf-8');
    const accessData = JSON.parse(decodedAccessPayload);
    
    // Grab the groups array, default to empty if none exist
    const userGroups = accessData['cognito:groups'] || []; 

    console.log(`User ${userEmail} logged in with groups: ${userGroups}`);

    // 4. Enforce RBAC for the Employee Lifecycle Automation
    // Grab the groups array, default to empty if none exist
    const userGroups = accessData['cognito:groups'] || []; 

    // --- TEMPORARY DEBUG SCREEN ---
    return res.send(`
      <h1>X-Ray Debug Mode</h1>
      <p><b>Email:</b> ${userEmail}</p>
      <p><b>Parsed Groups:</b> ${userGroups.join(', ')}</p>
      <hr>
      <h3>Raw ALB Data Payload:</h3>
      <pre>${JSON.stringify(user, null, 2)}</pre>
      <hr>
      <h3>Raw Cognito Access Payload:</h3>
      <pre>${JSON.stringify(accessData, null, 2)}</pre>
    `);

  } catch (error) {
    console.error("Error decoding JWT:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.listen(8080, () => {
  console.log('Self-Service Portal running on port 8080');
});