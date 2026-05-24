const express = require('express');
const app = express();

app.get('/portal', (req, res) => {
  // 1. Grab the injected header from the ALB
  const jwtHeader = req.headers['x-amzn-oidc-data'];
  
  if (!jwtHeader) {
    return res.status(401).send("Unauthorized: Missing ALB Identity Header");
  }

  try {
    // 2. A JWT has 3 parts separated by dots. We want the payload (the middle part).
    const payloadBase64 = jwtHeader.split('.')[1];
    
    // 3. Decode the Base64 string into a readable JSON object
    const decodedPayload = Buffer.from(payloadBase64, 'base64').toString('utf-8');
    const user = JSON.parse(decodedPayload);

    // 4. Extract the user's email and their Cognito RBAC groups
    const userEmail = user.email;
    const userGroups = user['cognito:groups'] || []; // Defaults to empty array if no groups

    console.log(`User ${userEmail} logged in with groups: ${userGroups}`);

    // 5. Enforce RBAC for the Employee Lifecycle Automation
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
    console.error("Error decoding JWT:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.listen(8080, () => {
  console.log('Self-Service Portal running on port 8080');
});