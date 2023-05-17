FROM --platform=linux/amd64 public.ecr.aws/sam/build-python3.9:1.83.0-20230511200137

RUN yum update -y

COPY ./build_langchain_layer.sh .
COPY ./bot_dispatcher/requirements.txt .

CMD ["/bin/bash","./build_langchain_layer.sh"]
