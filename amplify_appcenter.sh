#!/usr/bin/env bash

echo "Checking AMPLIFY_ENV=${AMPLIFY_ENV}"

npm install -g @aws-amplify/cli

AWSCONFIG="{\
\"accessKeyId\":\"${AWS_ACCESS_KEY_ID}\",\
\"secretAccessKey\":\"${AWS_SECRET_ACCESS_KEY}\",\
\"region\":\"${AWS_REGION}\"\
}"

AMPLIFY="{\
\"envName\":\"${AMPLIFY_ENV}\",\
\"appId\":\"${AMPLIFY_APP_ID}\",\
\"defaultEditor\":\"none\"\
}"

PROVIDERS="{\
\"awscloudformation\":${AWSCONFIG}\
}"

FRONTEND="{\
\"frontend\":\"ios\"\
}"

CODEGEN="{\
\"generateCode\":false,\
\"generateDocs\":false\
}"

echo "Amplify pull: amplify pull --amplify $AMPLIFY --frontend $FRONTEND --providers $PROVIDERS -y"
amplify pull --amplify $AMPLIFY --frontend $FRONTEND --providers $PROVIDERS -y

echo "Amplify status ..."
amplify status

#echo "Amplify push ..."
#amplify push --codegen $CODEGEN --yes

echo "Amplify DONE"
