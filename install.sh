#!/bin/bash

# 1️⃣ مسیر رپوی کلون‌شده را دریافت کن
REPO_DIR="$(pwd)"  # فرض می‌کنیم نصب‌کننده در رپوی کلون‌شده اجرا می‌شود
PLUGIN_DIR="$HOME/.vim/pack/plugins/start/vim-ai"

rm -rf ~/.vim/pack/plugins/start/vim-ai

# 2️⃣ بررسی اینکه آیا رپو وجود دارد؟
if [ ! -d "$REPO_DIR/plugin" ] || [ ! -d "$REPO_DIR/python" ]; then
    echo "❌ خطا: به نظر می‌رسد که این اسکریپت را در دایرکتوری اشتباهی اجرا کرده‌اید."
    echo "📂 لطفاً ابتدا رپو را کلون کرده و سپس این اسکریپت را در همان دایرکتوری اجرا کنید!"
    exit 1
fi

# 3️⃣ ایجاد مسیر پلاگین در ویم
echo "📂 ایجاد مسیر پلاگین در: $PLUGIN_DIR"
mkdir -p "$PLUGIN_DIR"

# 4️⃣ کپی کردن فایل‌های پلاگین از رپو
echo "📥 کپی کردن فایل‌های پلاگین..."
cp -r "$REPO_DIR/plugin" "$PLUGIN_DIR"
cp -r "$REPO_DIR/python" "$PLUGIN_DIR"

# 5️⃣ نصب وابستگی‌های پایتون (در صورت نیاز)
echo "🔍 بررسی نصب OpenAI API..."
if ! python3 -c "import openai" &> /dev/null; then
    echo "📦 نصب openai..."
    pip3 install openai --break-system-packages
else
    echo "✅ OpenAI API از قبل نصب شده است."
fi

# 6️⃣ بررسی و اضافه کردن به `vimrc`
VIMRC="$HOME/.vimrc"
if ! grep -q "packloadall" "$VIMRC"; then
    echo "🔧 اضافه کردن پلاگین به vimrc..."
    echo 'packloadall' >> "$VIMRC"
    echo "source $PLUGIN_DIR/plugin/ai.vim" >> "$VIMRC"
fi

# 7️⃣ پیام موفقیت
echo "🎉 نصب کامل شد! حالا می‌توانید دستورات زیر را در Vim اجرا کنید:"
echo "🔹 :AISetup  (برای تنظیم مدل و API Key)"
echo "🔹 :AI سوال شما"

echo "✅ لطفاً Vim را مجدداً راه‌اندازی کنید!"

