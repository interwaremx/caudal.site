#!/bin/bash

# Decrypt personal token
# - Crypted with: 
#   openssl aes-256-cbc -e -in github_deploy_key.pub -out github_deploy_key.enc -K $enc_key -iv $enc_iv
openssl aes-256-cbc -d -in .ci/token.enc -out .ci/token -K $enc_key -iv $enc_iv

# Load token
TOKEN=$( cat .ci/token )

# Clone with token
git config --global user.name "Daniel Estevez"
git config --global user.email 'daniel.ef@gmail.com'
git clone https://danielef:$TOKEN@github.com/interwaremx/caudal.docs.git

# Into cloned copy all generated files
cd caudal.docs/
cp -r ../public/* .

# Add all changes && commit && push
git add -A
DATE=$( date +"%Y-%m-%d %T" )
git commit -am "Site updated by codeship: $DATE"
git push
