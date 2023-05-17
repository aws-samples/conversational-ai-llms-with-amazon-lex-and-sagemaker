LAYER_NAME=langchain_layer.zip

# langchain layer - run in linux container to be ccompatible with lambda
echo "Create Virtual env"
python3 -m venv .venv 
source .venv/bin/activate
echo "Activated Virtual Env. Installing requirements"
pip install -r requirements.txt --target ./package/python
cd package
echo "Zipping into lambda layer"
zip -v -r9 $LAYER_NAME .
mv $LAYER_NAME /aws-cai-lex-bots/src/bot_dispatcher/$LAYER_NAME
cd ..
rm -rf package/
deactivate
