const mysql = require('mysql2/promise');
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

let pool;
const secretsClient = new SecretsManagerClient({ region: process.env.AWS_REGION || "us-east-1" });

exports.handler = async (event) => {
    console.log("Request received from ALB:", event.path);

    try {
        if (!pool) {
            console.log("Fetching DB credentials from Secrets Manager...");
            const command = new GetSecretValueCommand({ SecretId: process.env.SECRET_ARN });
            const secretResponse = await secretsClient.send(command);
            const credentials = JSON.parse(secretResponse.SecretString);

            console.log("Creating database connection pool via RDS Proxy...");
            pool = mysql.createPool({
                host: process.env.DB_HOST,
                user: credentials.username,
                password: credentials.password,
                database: process.env.DB_NAME,
                waitForConnections: true,
                connectionLimit: 2, 
                queueLimit: 0
            });
        }

        // 1. Create the table if it does not exist
        await pool.execute(`
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL
            )
        `);

        // 2. Insert a piece of dummy data (IGNORE prevents duplicate errors on reload)
        await pool.execute(`
            INSERT IGNORE INTO users (id, name, email) 
            VALUES (1, 'Marko Cloud Student', 'marko@example.com')
        `);

        // 3. Now query the data!
        const [rows] = await pool.execute('SELECT * FROM users LIMIT 5');
        
        return {
            statusCode: 200,
            statusDescription: "200 OK",
            isBase64Encoded: false,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                message: "Secure Connection via RDS Proxy Successful! Table created.",
                data: rows
            })
        };

    } catch (error) {
        console.error("Database error:", error);
        return {
            statusCode: 500,
            statusDescription: "500 Internal Server Error",
            isBase64Encoded: false,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ error: "Failed to connect or query the database." })
        };
    }
};