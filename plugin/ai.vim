" 📂 Path to the configuration file
let g:ai_config_file = expand("~/.vim-ai-config")

" 📌 Load saved settings
function! LoadAIConfig()
    if filereadable(g:ai_config_file)
        let l:config = readfile(g:ai_config_file)
        if len(l:config) >= 2
            let g:ai_model = l:config[0]
            let g:ai_api_key = l:config[1]
        endif
    else
        let g:ai_model = ""
        let g:ai_api_key = ""
    endif
endfunction

" 📌 Save AI settings to the file
function! SaveAIConfig()
    call writefile([g:ai_model, g:ai_api_key], g:ai_config_file)
endfunction

" 📌 Retrieve a list of OpenAI models
function! GetAvailableModels()
    call LoadAIConfig()

    if g:ai_api_key == "" || g:ai_api_key == v:null
        let g:ai_api_key = inputsecret("🔑 Please enter your API Key: ")
        if g:ai_api_key == ""
            echo "❌ API Key was not entered. Operation canceled."
            return []
        endif
        call SaveAIConfig()
    endif

    let l:python_script = expand("~/.vim/pack/plugins/start/vim-ai/python/ai_handler.py")
    let l:command = "python3 " . l:python_script . " list_models " . shellescape(g:ai_api_key)
    let l:output = system(l:command)

    if l:output =~ "❌"
        echo "❌ Error retrieving OpenAI models: " . l:output
        if l:output =~ "Request timeout"
            echo "⏳ Suggestion: Check your internet connection or try again."
        elseif l:output =~ "Invalid API key"
            echo "🔑 Please enter a valid API Key."
        endif
        return []
    endif

    return json_decode(l:output)  " Convert JSON output to a list
endfunction

" 📌 Initial AI setup
function! AISetup()
    let l:models = GetAvailableModels()

    if empty(l:models)
        echo "⚠️ No GPT models are available or you lack access!"
        return
    endif

    echo "🔍 Available models:"
    let l:model_index = 1
    for model in l:models
        echo "[" . l:model_index . "] " . model
        let l:model_index += 1
    endfor

    let l:choice = input("Select the model number: ")

    if l:choice =~ '^\d\+$' && l:choice > 0 && l:choice <= len(l:models)
        let g:ai_model = l:models[l:choice - 1]
    else
        echo "❌ Invalid selection!"
        return
    endif

    call SaveAIConfig()
    echo "✅ Selected model: " . g:ai_model
endfunction

" 📌 Change the model without modifying the API Key
function! AIChangeModel()
    let l:models = GetAvailableModels()

    if empty(l:models)
        echo "⚠️ No GPT models are available!"
        return
    endif

    echo "🔍 Available models:"
    let l:model_index = 1
    for model in l:models
        echo "[" . l:model_index . "] " . model
        let l:model_index += 1
    endfor

    let l:choice = input("Select the new model: ")

    if l:choice =~ '^\d\+$' && l:choice > 0 && l:choice <= len(l:models)
        let g:ai_model = l:models[l:choice - 1]
    else
        echo "❌ Invalid selection!"
        return
    endif

    call SaveAIConfig()
    echo "✅ AI model changed to: " . g:ai_model
endfunction

" 📌 Execute AI request
function! AICommand(...)
    call LoadAIConfig()

    if g:ai_model == "" || g:ai_api_key == ""
        echo "⚠️ Please run :AISetup first."
        return
    endif

    let l:python_script = expand("~/.vim/pack/plugins/start/vim-ai/python/ai_handler.py")
    let l:args = join(a:000, " ")
    let l:command = "python3 " . l:python_script . " chat " . shellescape(l:args) . " " . g:ai_model . " " . g:ai_api_key
    let l:output = system(l:command)

    " Display the result in a new buffer
    new
    put =l:output
endfunction

" 📌 Register Vim commands
command! AISetup call AISetup()
command! AIChangeModel call AIChangeModel()
command! -nargs=+ AI call AICommand(<f-args>)

" 📌 Automatically load settings when Vim starts
autocmd VimEnter * call LoadAIConfig()
