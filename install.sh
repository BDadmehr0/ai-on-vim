#!/bin/bash

# 1️⃣ Get the path of the cloned repository
REPO_DIR="$(pwd)"  # Assuming the installer is run inside the cloned repository
PLUGIN_DIR="$HOME/.vim/pack/plugins/start/vim-ai"

rm -rf ~/.vim/pack/plugins/start/vim-ai

# 2️⃣ Check if the repository exists
if [ ! -d "$REPO_DIR/plugin" ] || [ ! -d "$REPO_DIR/python" ]; then
    echo "❌ Error: It seems you have run this script in the wrong directory."
    echo "📂 Please clone the repository first and then run this script in the same directory!"
    exit 1
fi

# 3️⃣ Create the plugin path in Vim
echo "📂 Creating plugin directory at: $PLUGIN_DIR"
mkdir -p "$PLUGIN_DIR"

# 4️⃣ Copy plugin files from the repository
echo "📥 Copying plugin files..."
cp -r "$REPO_DIR/plugin" "$PLUGIN_DIR"
cp -r "$REPO_DIR/python" "$PLUGIN_DIR"

# 5️⃣ Install Python dependencies (if needed)
echo "🔍 Checking OpenAI API installation..."
if ! python3 -c "import openai" &> /dev/null; then
    echo "📦 Installing openai..."
    if grep -q '^ID=arch' /etc/os-release; then
        echo "This system is Arch Linux."
        pip3 install openai --break-system-packages # TODO: check if system Arch runs with --break-system-packages
    else
        echo "This system is not Arch Linux."
        pip3 install openai 
    fi
else
    echo "✅ OpenAI API is already installed."
fi

# 6️⃣ Check and add to `vimrc`
VIMRC="$HOME/.vimrc"
if ! grep -q "packloadall" "$VIMRC"; then
    echo "🔧 Adding plugin to vimrc..."
    echo 'packloadall' >> "$VIMRC"
    echo "source $PLUGIN_DIR/plugin/ai.vim" >> "$VIMRC"
fi

# 7️⃣ Success message
echo "🎉 Installation completed! Now you can run the following commands in Vim:"
echo "🔹 :AISetup  (to set up the model and API Key)"
echo "🔹 :AI your question"

echo "✅ Please restart Vim!"
