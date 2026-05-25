const express = require('express');
const app = express();
const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const k8s = require('@kubernetes/client-node');
const fs = require('fs');

// Initialize the AWS SSM Client (Fargate automatically uses the container's IAM role!)
const ssmClient = new SSMClient({ region: "eu-central-1" });

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

app.post('/api/onboard', async (req, res) => {
  console.log("Received request to trigger K8s onboarding...");
  
  try {
    // 1. Fetch the Base64 String from AWS Systems Manager
    console.log("Fetching Kubeconfig from SSM...");
    const command = new GetParameterCommand({
      Name: "/dev-portal/k3s/kubeconfig",
      WithDecryption: true
    });
    const ssmResponse = await ssmClient.send(command);
    
    // 2. Decode the Base64 string back into standard YAML
    const base64Config = ssmResponse.Parameter.Value;
    const yamlConfig = Buffer.from(base64Config, 'base64').toString('utf-8');

    // 3. Authenticate the Kubernetes Client
    const kc = new k8s.KubeConfig();
    kc.loadFromString(yamlConfig);
    const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

    // 4. Spin up the Onboarding Job (A simple Alpine pod for testing)
    console.log("Dispatching job to K3s cluster...");
    const podManifest = {
      apiVersion: 'v1',
      kind: 'Pod',
      metadata: { name: `onboard-job-${Date.now()}` },
      spec: {
        containers: [{
          name: 'onboard-task',
          image: 'alpine',
          command: ['echo', 'Employee Onboarding Process Initiated!']
        }],
        restartPolicy: 'Never'
      }
    };

    await k8sApi.createNamespacedPod('default', podManifest);
    
    console.log("Job successfully dispatched!");
    res.status(200).send("Kubernetes Pod Created Successfully!");
    
  } catch (error) {
    console.error("K8s Trigger Error:", error);
    res.status(500).send("Failed to dispatch job to cluster. Check backend logs.");
  }
});

app.listen(8080, () => console.log('Self-Service Portal running on port 8080'));