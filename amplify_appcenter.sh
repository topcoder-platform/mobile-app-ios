#!/bin/bash

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
\"defaultEditor\":\"none\",\
\"configLevel\":\"project\"\
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

echo "Amplify pull: amplify pull --amplify '${AMPLIFY}' --frontend '${FRONTEND}' --providers '${PROVIDERS}' --yes"
amplify pull --amplify $AMPLIFY --frontend $FRONTEND --providers $PROVIDERS --yes

#echo "Amplify status ..."
#amplify status

#echo "Amplify push ..."
#amplify push --codegen $CODEGEN --yes

echo "Amplify DONE"
