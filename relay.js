const AWS = require("aws-sdk");

// Create an ECS client.
// If your Lambda runs in the same AWS account as ECS, no extra config is required.
// Otherwise, configure your AWS SDK credentials here.
const ecs = new AWS.ECS();

const clusterArn = process.env.ECS_CLUSTER_ARN;
const taskDefinition = process.env.ECS_TASK_DEFINITION;
const subnets = (process.env.SUBNETS || "").split(",");
const securityGroups = (process.env.SECURITY_GROUPS || "").split(",");
const launchType = process.env.ECS_LAUNCH_TYPE || "FARGATE";
const mainContainerName = process.env.MAIN_CONTAINER || "main";

exports.handler = async (event, context) => {
    try {
        const allMessages = [];
        if (event.records) {
            for (const [partition, messages] of Object.entries(event.records)) {
                for (const msg of messages) {
                    // The message value is base64-encoded
                    const decodedValue = Buffer.from(msg.value, "base64").toString("utf8");
                    allMessages.push(decodedValue);
                }
            }
        }
        const inputPayload = Buffer.from(JSON.stringify(allMessages), "utf8").toString("base64");

        // If you want to inspect the MSK messages, they will be in 'event.records'
        // The exact structure will vary based on your MSK -> Lambda event source mapping.
        // Example: const records = event.records;

        // Run an ECS task
        const response = await ecs
            .runTask({
                count: 1,
                cluster: clusterArn,
                launchType: launchType,
                taskDefinition: taskDefinition,
                networkConfiguration: {
                    awsvpcConfiguration: {
                        subnets: subnets,
                        securityGroups: securityGroups,
                        assignPublicIp: "DISABLED",
                    },
                },
                overrides: {
                  containerOverrides: [
                    {
                      name: mainContainerName,
                      environment: [
                        { name: "INPUT_PAYLOAD", value: inputPayload }
                      ]
                    }
                  ]
                }
            })
            .promise();

        console.log("ECS RunTask response:", JSON.stringify(response, null, 2));

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "Task launched successfully",
                response,
            }),
        };
    } catch (err) {
        console.error("Error running ECS task:", err);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message }),
        };
    }
};
