// Este archivo será generado automáticamente por Amplify CLI
// Por ahora, configuración manual basada en la guía

const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "us-east-1:12345678-1234-1234-1234-123456789012",
              "Region": "us-east-1"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_BGLrPMS01",
            "AppClientId": "3tbo7h2b21cna6gj44h8si9g2t",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": [],
            "usernameAttributes": ["email"],
            "signupAttributes": ["email"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": []
            },
            "mfaConfiguration": "OFF",
            "mfaTypes": ["SMS"],
            "verificationMechanisms": ["EMAIL"]
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "capboxapi": {
          "endpointType": "REST",
          "endpoint": "https://api.capbox.site/v1",
          "region": "us-east-1",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  }
}''';
