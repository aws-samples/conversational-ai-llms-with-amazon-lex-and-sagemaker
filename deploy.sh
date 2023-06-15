AWS_CLI=/usr/local/bin/aws

AWS_PROFILE=<<<AWS_PROFILE_NAME>>>
S3_ASSETS_BUCKET=<<<BUCKET_NAME>>>
VERSION=v1
VERSION_PREFIX=artifacts/ML-12016/$VERSION


echo "Packaging Lambda"
cd ./src/bot_dispatcher

# for Flan Model
zip -v -r9 lex-flan-lambda.zip ./dispatchers/ ./sm_utils/ __init__.py lex_langchain_hook_function.py
$AWS_CLI s3 cp ./lex-flan-lambda.zip s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/lex-flan-lambda.zip --profile $AWS_PROFILE
$AWS_CLI s3 cp ./langchain_layer.zip s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/langchain_layer.zip --profile $AWS_PROFILE

echo "Uploading Static CFN"

JS_LAMBDA_HOOK_CFN=SMJumpstartFlanT5-LambdaHook.template.json
JS_SM_ENDPOINT_CFN=SMJumpstartFlanT5-SMEndpoint.template.json
JS_SM_ENDPOINT_W2_CFN=SMJumpstartFlanT5-SMEndpoint-uswest2.template.json
JS_LEX_BOT_CFN=SMJumpstartFlanT5-LexBot.template.json
JS_LLM_MAIN_CFN=SMJumpstartFlanT5-llm-main.yaml
JS_LLM_MAIN_W2_CFN=SMJumpstartFlanT5-llm-main-uswest2.yaml

cd ../../static
JS_LAMBDA_HOOK_DST=s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/stacks/$JS_LAMBDA_HOOK_CFN
JS_SM_ENDPOINT_DST=s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/stacks/$JS_SM_ENDPOINT_CFN
JS_SM_ENDPOINT_W2_DST=s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/stacks/$JS_SM_ENDPOINT_W2_CFN
JS_LEX_BOT_DST=s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/stacks/$JS_LEX_BOT_CFN

$AWS_CLI s3 cp ./$JS_LAMBDA_HOOK_CFN $JS_LAMBDA_HOOK_DST --profile $AWS_PROFILE
$AWS_CLI s3 cp ./$JS_SM_ENDPOINT_CFN $JS_SM_ENDPOINT_DST --profile $AWS_PROFILE
$AWS_CLI s3 cp ./$JS_SM_ENDPOINT_W2_CFN $JS_SM_ENDPOINT_W2_DST --profile $AWS_PROFILE
$AWS_CLI s3 cp ./$JS_LEX_BOT_CFN $JS_LEX_BOT_DST --profile $AWS_PROFILE

cd ..
JS_LLM_MAIN_DST=s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/stacks/$JS_LLM_MAIN_CFN
$AWS_CLI s3 cp ./$JS_LLM_MAIN_CFN $JS_LLM_MAIN_DST --profile $AWS_PROFILE
JS_LLM_MAIN_DST=s3://$S3_ASSETS_BUCKET/$VERSION_PREFIX/stacks/$JS_LLM_MAIN_W2_CFN
$AWS_CLI s3 cp ./$JS_LLM_MAIN_W2_CFN $JS_LLM_MAIN_DST --profile $AWS_PROFILE
