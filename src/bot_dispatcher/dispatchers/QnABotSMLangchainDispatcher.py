import boto3
import json
import os
from sm_utils.sm_langchain_sample import SagemakerLangchainBot
from dispatchers import utils
import logging

logger = utils.get_logger(__name__)
logger.setLevel(logging.DEBUG)
CHAT_HISTORY="chat_history"
initial_history = {CHAT_HISTORY: f"AI: Hi there! How Can I help you?\nHuman: ",}


class QnABotSMLangchainDispatcher():
    
    def __init__(self, intent_request):
        # QnABot Session attributes
        self.intent_request = intent_request
        self.input_transcript = self.intent_request['req']['question']
        self.intent_name = self.intent_request['req']['intentname']
        self.session_attributes = self.intent_request['req']['session']

    def dispatch_intent(self):
        prompt_template = """The following is a friendly conversation between a human and an AI. The AI is 
        talkative and provides lots of specific details from its context. If the AI does not know 
        the answer to a question, it truthfully says it does not know. You are provided with information
        about entities the Human mentions, if relevant.

        Chat History:
        {chat_history}

        Conversation:
        Human: {input}
        AI:"""

        if 'ConversationContext' in self.session_attributes:
            # Set context with convo history for custom memory in langchain
            conv_context: dict = self.session_attributes.get('ConversationContext')
            conv_context['inputs']['text'] = self.input_transcript
        else:
            conv_context: dict = {
                'inputs': {
                    "text": self.input_transcript,
                    "past_user_inputs": [],
                    "generated_responses": []
                },
                'history':initial_history
            }

        logger.debug(
            f"Req Session: {json.dumps(self.session_attributes, indent=4)} \n Type {type(self.session_attributes)}")

        logger.debug(
            f"Conversation Conext: {conv_context} \n Type {type(conv_context)}")

        # LLM
        langchain_bot = SagemakerLangchainBot(
            prompt_template = prompt_template,
            sm_endpoint_name = os.environ.get("ENDPOINT_NAME","cai-lex-hf-flan-bot-endpoint"),
            region_name = os.environ.get('AWS_REGION',"us-east-1"),
            lex_conv_history = json.dumps(conv_context['history'])
        )
        
        llm_response = langchain_bot.call_llm(user_input=self.input_transcript)
        curr_context = conv_context['inputs']
        self.text = llm_response

        curr_context["past_user_inputs"].append(self.input_transcript)
        curr_context["generated_responses"].append(self.text)
        conv_context['inputs']=curr_context
        conv_context['history'][CHAT_HISTORY] = conv_context['history'][CHAT_HISTORY] + self.input_transcript + f"\nAI: {self.text}" +"\nHuman: "

        self.intent_request['res']['session']['ConversationContext'] = conv_context

        self.intent_request['res']['message'] = self.text
        self.intent_request['res']['type'] = "plaintext"

        logger.debug(
            f"Response Generated: {json.dumps(self.intent_request['res'], indent=4)}")

        return self.intent_request
