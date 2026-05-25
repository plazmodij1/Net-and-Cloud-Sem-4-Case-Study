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
        <button id="onboard-btn">Trigger Employee Onboarding (K8s)</button>
        <p id="status-message"></p>

        <script>
          document.getElementById('onboard-btn').addEventListener('click', async () => {
            const statusDiv = document.getElementById('status-message');
            statusDiv.innerHTML = "⏳ Contacting Kubernetes Cluster...";
            
            try {
              // This sends the request to your backend Node.js server
              const response = await fetch('/api/onboard', { method: 'POST' });
              const result = await response.text();
              
              if (response.ok) {
                statusDiv.innerHTML = "✅ " + result;
              } else {
                statusDiv.innerHTML = "❌ Failed: " + result;
              }
            } catch (err) {
              statusDiv.innerHTML = "❌ Network Error: " + err.message;
            }
          });
        </script>
      `);
    }
  } catch (error) {
    console.error("Server Crash:", error);
    res.status(500).send("Internal Server Error");
  }
});

// 🚀 NEW: The route that handles the button click
app.post('/api/onboard', async (req, res) => {
  console.log("Received request to trigger K8s onboarding...");
  
  try {
    // ==========================================
    // 1. Fetch the Base64 String from AWS SSM
    // 2. Decode it into a kubeconfig
    // 3. Authenticate with your EC2 K3s Cluster
    // 4. Spin up the Alpine Job
    // ==========================================
    
    // For now, let's just send a success message to prove the wiring works!
    res.status(200).send("Kubernetes Job Dispatched Successfully!");
    
  } catch (error) {
    console.error("K8s Trigger Error:", error);
    res.status(500).send("Failed to dispatch job to cluster.");
  }
});

app.listen(8080, () => console.log('Self-Service Portal running on port 8080'));