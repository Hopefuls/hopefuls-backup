FROM ubuntu:latest

RUN apt-get update -y && apt-get install -y git

CMD echo "deploying" && mkdir /deployment/temp && git clone --depth 1 https://$USER:$GHTOKEN@github.com/$USER/$REPO.git /deployment/temp && mv /deployment/temp/deploy/* /deployment/ && rm -rf /deployment/temp

