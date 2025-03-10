import openai
import sys
import json

def get_available_models(api_key):
    """مدل‌های قابل دسترس را از OpenAI API دریافت می‌کند"""
    try:
        client = openai.OpenAI(api_key=api_key, timeout=10)  # ⏳ Timeout اضافه شد
        models = client.models.list()
        model_ids = [model.id for model in models.data if "gpt" in model.id]  # فقط مدل‌های GPT
        return model_ids
    except openai.OpenAIError as e:
        return f"❌ خطا در دریافت مدل‌ها: {str(e)}"
    except openai.Timeout:
        return "❌ خطا: درخواست به OpenAI API بیش از حد طول کشید. لطفاً دوباره امتحان کنید!"

def ask_ai(prompt, model, api_key):
    """ارسال درخواست به AI و دریافت پاسخ"""
    try:
        client = openai.OpenAI(api_key=api_key, timeout=15)  # ⏳ Timeout بیشتر برای درخواست‌های چت
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content.strip()
    except openai.OpenAIError as e:
        return f"❌ خطا در پردازش درخواست: {str(e)}"
    except openai.Timeout:
        return "❌ خطا: زمان درخواست تمام شد. لطفاً دوباره امتحان کنید!"

if __name__ == "__main__":
    action = sys.argv[1]
    if action == "list_models":
        api_key = sys.argv[2]
        available_models = get_available_models(api_key)
        if isinstance(available_models, list):
            print(json.dumps(available_models))  # ارسال لیست مدل‌ها به Vim
        else:
            print(available_models)  # ارسال خطا
    elif action == "chat":
        prompt = sys.argv[2]
        model = sys.argv[3]
        api_key = sys.argv[4]
        print(ask_ai(prompt, model, api_key))
