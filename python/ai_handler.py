import json
import sys

import openai


def get_available_models(api_key):
    """Fetches available models from the OpenAI API"""
    try:
        client = openai.OpenAI(api_key=api_key, timeout=10)  # ⏳ Added timeout
        models = client.models.list()
        model_ids = [
            model.id for model in models.data if "gpt" in model.id
        ]  # Only GPT models
        return model_ids
    except openai.OpenAIError as e:
        return f"❌ Error fetching models: {str(e)}"
    except openai.Timeout:
        return "❌ Error: The request to OpenAI API took too long. Please try again!"


def ask_ai(prompt, model, api_key):
    """Sends a request to the AI and retrieves the response"""
    try:
        client = openai.OpenAI(
            api_key=api_key, timeout=15
        )  # ⏳ Increased timeout for chat requests
        response = client.chat.completions.create(
            model=model, messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content.strip()
    except openai.OpenAIError as e:
        return f"❌ Error processing request: {str(e)}"
    except openai.Timeout:
        return "❌ Error: Request timeout. Please try again!"


if __name__ == "__main__":
    action = sys.argv[1]
    if action == "list_models":
        api_key = sys.argv[2]
        available_models = get_available_models(api_key)
        if isinstance(available_models, list):
            print(json.dumps(available_models))  # Send model list to Vim
        else:
            print(available_models)  # Send error message
    elif action == "chat":
        prompt = sys.argv[2]
        model = sys.argv[3]
        api_key = sys.argv[4]
        print(ask_ai(prompt, model, api_key))
