#!/usr/bin/env bash

echo "Checking AMPLIFY_ENV=${AMPLIFY_ENV}"

npm install -g @aws-amplify/cli

AWSCONFIG="{\
\"accessKeyId\":\"${AWS_ACCESS_KEY_ID}\",\
\"secretAccessKey\":\"${AWS_SECRET_ACCESS_KEY}\",\
\"region\":\"${AWS_REGION}\"\
}"

AMPLIFY="{\
\"envName\":\"${AMPLIFY_ENV}\"\
}"

PROVIDERS="{\
\"awscloudformation\":${AWSCONFIG}\
}"

CODEGEN="{\
\"generateCode\":false,\
\"generateDocs\":false\
}"

echo "Amplify initialization ..."
amplify init --amplify ${AMPLIFY} --providers ${PROVIDERS} --codegen ${CODEGEN} --yes

echo "Amplify status ..."
amplify status

echo "Amplify push ..."
amplify push --codegen $CODEGEN --yes

echo "Amplify DONE"
