" 📂 مسیر فایل تنظیمات
let g:ai_config_file = expand("~/.vim-ai-config")

" 📌 خواندن تنظیمات ذخیره‌شده
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

" 📌 ذخیره تنظیمات AI در فایل
function! SaveAIConfig()
    call writefile([g:ai_model, g:ai_api_key], g:ai_config_file)
endfunction

" 📌 دریافت لیست مدل‌های OpenAI
function! GetAvailableModels()
    call LoadAIConfig()

    if g:ai_api_key == "" || g:ai_api_key == v:null
        let g:ai_api_key = inputsecret("🔑 لطفاً API Key خود را وارد کنید: ")
        if g:ai_api_key == ""
            echo "❌ API Key وارد نشد. عملیات لغو شد."
            return []
        endif
        call SaveAIConfig()
    endif

    let l:python_script = expand("~/.vim/pack/plugins/start/vim-ai/python/ai_handler.py")
    let l:command = "python3 " . l:python_script . " list_models " . shellescape(g:ai_api_key)
    let l:output = system(l:command)

    if l:output =~ "❌"
        echo "❌ خطا در دریافت مدل‌های OpenAI: " . l:output
        if l:output =~ "زمان درخواست تمام شد"
            echo "⏳ پیشنهاد: اینترنت خود را بررسی کنید یا دوباره امتحان کنید."
        elseif l:output =~ "Invalid API key"
            echo "🔑 لطفاً API Key معتبر وارد کنید."
        endif
        return []
    endif

    return json_decode(l:output)  " تبدیل خروجی JSON به لیست
endfunction


" 📌 تنظیم اولیه AI
function! AISetup()
    let l:models = GetAvailableModels()

    if empty(l:models)
        echo "⚠️ هیچ مدل GPT در دسترس نیست یا دسترسی ندارید!"
        return
    endif

    echo "🔍 مدل‌های موجود:"
    let l:model_index = 1
    for model in l:models
        echo "[" . l:model_index . "] " . model
        let l:model_index += 1
    endfor

    let l:choice = input("شماره مدل موردنظر را انتخاب کنید: ")

    if l:choice =~ '^\d\+$' && l:choice > 0 && l:choice <= len(l:models)
        let g:ai_model = l:models[l:choice - 1]
    else
        echo "❌ انتخاب نامعتبر!"
        return
    endif

    call SaveAIConfig()
    echo "✅ مدل انتخاب‌شده: " . g:ai_model
endfunction

" 📌 تغییر مدل بدون تغییر API Key
function! AIChangeModel()
    let l:models = GetAvailableModels()

    if empty(l:models)
        echo "⚠️ هیچ مدل GPT در دسترس نیست!"
        return
    endif

    echo "🔍 مدل‌های موجود:"
    let l:model_index = 1
    for model in l:models
        echo "[" . l:model_index . "] " . model
        let l:model_index += 1
    endfor

    let l:choice = input("مدل جدید را انتخاب کنید: ")

    if l:choice =~ '^\d\+$' && l:choice > 0 && l:choice <= len(l:models)
        let g:ai_model = l:models[l:choice - 1]
    else
        echo "❌ انتخاب نامعتبر!"
        return
    endif

    call SaveAIConfig()
    echo "✅ مدل AI تغییر کرد به: " . g:ai_model
endfunction

" 📌 اجرای درخواست AI
function! AICommand(...)
    call LoadAIConfig()

    if g:ai_model == "" || g:ai_api_key == ""
        echo "⚠️ لطفاً ابتدا دستور :AISetup را اجرا کنید."
        return
    endif

    let l:python_script = expand("~/.vim/pack/plugins/start/vim-ai/python/ai_handler.py")
    let l:args = join(a:000, " ")
    let l:command = "python3 " . l:python_script . " chat " . shellescape(l:args) . " " . g:ai_model . " " . g:ai_api_key
    let l:output = system(l:command)

    " نمایش نتیجه در یک buffer جدید
    new
    put =l:output
endfunction

" 📌 ثبت دستورات Vim
command! AISetup call AISetup()
command! AIChangeModel call AIChangeModel()
command! -nargs=+ AI call AICommand(<f-args>)

" 📌 بارگیری خودکار تنظیمات هنگام اجرای Vim
autocmd VimEnter * call LoadAIConfig()
