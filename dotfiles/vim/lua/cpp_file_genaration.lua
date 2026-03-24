local M = {}

-- 从字符串中删除指定的修饰符
local function remove_modifiers(func_signature, modifiers_to_remove)
  local result = func_signature
  for _, modifier in ipairs(modifiers_to_remove) do
    -- 移除修饰符及其周围的空格
    result = result:gsub("%s*" .. modifier .. "%s*", " ")
  end
  -- 清理多余空格
  result = result:gsub("%s+", " ")
  return result:match("^%s*(.-)%s*$")
end

-- 从函数声明中提取返回类型和函数名
local function parse_function_signature(func_signature)
  -- 移除 virtual 和 override
  local cleaned = remove_modifiers(func_signature, { "virtual", "override" })

  -- 移除尾部的分号
  cleaned = cleaned:gsub(";$", ""):match("^%s*(.-)%s*$")

  -- 尝试匹配：返回类型 函数名(参数列表) [const]
  -- 从右边往左匹配：找到最后一个"函数名("的模式
  -- 首先提取末尾的 const (如果有)
  local const_part = ""
  local sig_without_const = cleaned
  if cleaned:match("%s+const%s*$") then
    const_part = "const"
    sig_without_const = cleaned:gsub("%s+const%s*$", "")
  end

  -- 现在找函数名和参数：从右往左找最后一个单词跟着 (...)
  -- 模式是：(return_type + spaces + func_name)(params)
  local return_type, func_name, params = sig_without_const:match("^(.+)%s+(%w+)%s*(%([^)]*%))%s*$")

  if return_type and func_name and params then
    return {
      return_type = return_type:match("^%s*(.-)%s*$"),
      func_name = func_name,
      params = params,
      const_part = const_part,
      full_signature = cleaned
    }
  end

  return nil
end

-- 返回值类型映射表
local RETURN_VALUE_MAP = {
  -- 基本类型
  ["void"] = "",
  ["int"] = "return 0;",
  ["int8_t"] = "return 0;",
  ["int16_t"] = "return 0;",
  ["int32_t"] = "return 0;",
  ["int64_t"] = "return 0;",
  ["uint8_t"] = "return 0;",
  ["uint16_t"] = "return 0;",
  ["uint32_t"] = "return 0;",
  ["uint64_t"] = "return 0;",
  ["size_t"] = "return 0;",
  ["ssize_t"] = "return 0;",
  ["bool"] = "return false;",
  ["float"] = "return 0.f;",
  ["double"] = "return 0.0;",
  ["char"] = "return 0;",
  ["wchar_t"] = "return 0;",
  ["short"] = "return 0;",
  ["long"] = "return 0;",
  ["unsigned int"] = "return 0;",
  ["unsigned char"] = "return 0;",
  ["unsigned short"] = "return 0;",
  ["unsigned long"] = "return 0;",

  -- 标准库容器
  ["std::string"] = "return \"\";",
  ["std::vector"] = "return {};",
  ["std::array"] = "return {};",
  ["std::deque"] = "return {};",
  ["std::list"] = "return {};",
  ["std::forward_list"] = "return {};",
  ["std::set"] = "return {};",
  ["std::unordered_set"] = "return {};",
  ["std::map"] = "return {};",
  ["std::unordered_map"] = "return {};",
  ["std::pair"] = "return {};",
  ["std::tuple"] = "return {};",
  ["std::optional"] = "return {};",
  ["std::variant"] = "return {};",
}

-- 获取返回值的默认初始化代码
local function get_default_return(return_type)
  return_type = return_type:match("^%s*(.-)%s*$")

  -- 1. 先查询完整的返回值类型
  if RETURN_VALUE_MAP[return_type] then
    return RETURN_VALUE_MAP[return_type]
  end

  -- 2. 检查是否是指针类型（包含 *）
  if return_type:match("%*") then
    return "return nullptr;"
  end

  if return_type:match("^std::unique_ptr%s*<") or
     return_type:match("^std::shared_ptr%s*<") then
    return "return nullptr;"
  end

  -- 3. 检查是否是容器模板类型（使用正则匹配）
  -- 匹配 std::vector<...>, std::map<...> 等
  if return_type:match("^std::vector%s*<") or
     return_type:match("^std::deque%s*<") or
     return_type:match("^std::list%s*<") or
     return_type:match("^std::set%s*<") or
     return_type:match("^std::unordered_set%s*<") or
     return_type:match("^std::map%s*<") or
     return_type:match("^std::unordered_map%s*<") or
     return_type:match("^std::array%s*<") or
     return_type:match("^std::forward_list%s*<") or
     return_type:match("^std::deque%s*<") or
     return_type:match("^std::pair%s*<") or
     return_type:match("^std::tuple%s*<") or
     return_type:match("^std::optional%s*<") or
     return_type:match("^std::variant%s*<") then
    return "return {};"
  end

  -- 4. 检查是否是引用类型（&）- 需要特殊处理
  if return_type:match("&") then
    -- 移除引用符号后重新查询
    local base_type = return_type:gsub("%s*&%s*$", "")
    if RETURN_VALUE_MAP[base_type] then
      return RETURN_VALUE_MAP[base_type]
    end
    -- 如果是容器或其他类型，返回默认初始化
    return "return {};  // reference return"
  end

  -- 5. 默认情况：调用默认构造函数
  return "return " .. return_type .. "();"
end

-- 生成函数实现体
local function generate_function_body(func_signature, class_name)
  local parsed = parse_function_signature(func_signature)
  if not parsed then
    return nil
  end

  local return_type = parsed.return_type
  local func_name = parsed.func_name
  local params = parsed.params
  local const_part = parsed.const_part

  local return_stmt = get_default_return(return_type)

  -- 构造完整的函数签名：return_type ClassName::FunctionName(params) [const]
  local func_sig = return_type .. " " .. class_name .. "::" .. func_name .. params
  if const_part and const_part ~= "" then
    func_sig = func_sig .. " " .. const_part
  end

  local body = ""
  body = body .. func_sig .. " {\n"

  if return_stmt == "" then
    body = body .. "}\n"
  else
    body = body .. "  " .. return_stmt .. "\n"
    body = body .. "}\n"
  end

  return body
end

-- 提取类定义和其匹配的括号内容
local function extract_classes(content)
  local classes = {}
  local i = 1

  while i <= #content do
    -- 查找 "class" 关键字
    local class_start = content:find("class%s+%w+", i)
    if not class_start then
      break
    end

    -- 提取类名
    local class_name_start = content:find("%s+(%w+)", class_start)
    local class_name_end = content:find("%w+", class_name_start)
    local class_name = content:sub(class_name_end, content:find("[%s:;{]", class_name_end) - 1)

    -- 查找开括号
    local brace_start = content:find("{", class_start)
    if not brace_start then
      break
    end

    -- 匹配括号
    local brace_count = 1
    local pos = brace_start + 1
    while pos <= #content and brace_count > 0 do
      local char = content:sub(pos, pos)
      if char == "{" then
        brace_count = brace_count + 1
      elseif char == "}" then
        brace_count = brace_count - 1
      end
      pos = pos + 1
    end

    if brace_count == 0 then
      local class_body = content:sub(brace_start + 1, pos - 2)
      table.insert(classes, { name = class_name, body = class_body })
      i = pos
    else
      break
    end
  end

  return classes
end

-- 第一个函数：解析头文件并提取所有未实现的函数
-- 返回哈希表：key=类名，value=函数声明字符串数组
function M.extract_unimplemented_functions(header_file_path)
  local file = io.open(header_file_path, "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  local functions_by_class = {}

  -- 提取所有类定义
  local classes = extract_classes(content)

  for _, class_info in ipairs(classes) do
    local class_name = class_info.name
    local class_body = class_info.body
    local functions = {}

    -- 在类体内按 ; 分割，找到所有函数声明
    for statement in class_body:gmatch("[^;]+") do
      -- 移除注释（包括单行注释和多行注释）
      -- 先移除多行注释
      statement = statement:gsub("/%*.-%*/", "")

      -- 移除单行注释（只移除同一行的注释）
      -- 逐行处理，只移除行内注释
      local lines = {}
      for line in statement:gmatch("[^\n]+") do
        line = line:gsub("//.*$", "")
        table.insert(lines, line)
      end
      statement = table.concat(lines, "\n")

      -- 清理语句
      local cleaned_stmt = statement:match("^%s*(.-)%s*$")

      -- 跳过访问修饰符和空白行
      if cleaned_stmt and cleaned_stmt ~= "" then
        -- 处理访问修饰符行（如 public:、private:、protected:）
        -- 这些行一般只包含修饰符，后面可能有函数声明
        if not (cleaned_stmt:match("^public%s*$") or
                cleaned_stmt:match("^private%s*$") or
                cleaned_stmt:match("^protected%s*$")) then

          -- 检查是否以访问修饰符开头（如 public: int GetData()）
          -- 只处理单个冒号的访问修饰符，避免 std:: 的干扰
          if cleaned_stmt:match("^public%s*:%s+") then
            cleaned_stmt = cleaned_stmt:match("^public%s*:%s+(.+)$")
          elseif cleaned_stmt:match("^private%s*:%s+") then
            cleaned_stmt = cleaned_stmt:match("^private%s*:%s+(.+)$")
          elseif cleaned_stmt:match("^protected%s*:%s+") then
            cleaned_stmt = cleaned_stmt:match("^protected%s*:%s+(.+)$")
          end

          -- 二次检查，跳过某些特殊内容
          if cleaned_stmt and cleaned_stmt ~= "" and
             not cleaned_stmt:match("^struct%s") and
             not cleaned_stmt:match("^typedef") and
             not cleaned_stmt:match("^enum") then

            -- 移除类型定义、枚举、嵌套类等非函数的内容
            if cleaned_stmt:match("%(") and cleaned_stmt:match("%)") then
              -- 这看起来像一个函数声明

              -- 过滤析构函数（~开头）
              if cleaned_stmt:match("^%s*~") then
                goto skip_function
              end

              -- 过滤内联实现（= default, = delete, = 0等）
              if cleaned_stmt:match("=%s*default%s*$") or
                 cleaned_stmt:match("=%s*delete%s*$") or
                 cleaned_stmt:match("=%s*0%s*$") then
                goto skip_function
              end

              -- 检查是否有实现体（花括号）
              if not cleaned_stmt:match("{") then
                -- 这是一个未实现的函数
                table.insert(functions, cleaned_stmt)
              end

              ::skip_function::
            end
          end
        end
      end
    end

    if #functions > 0 then
      functions_by_class[class_name] = functions
    end
  end

  return functions_by_class
end

-- 第二个函数：根据哈希表生成cpp文件内容
-- include_level: -1表示不需要include，>=0表示包含的路径已经计算好
-- namespace: 命名空间名称
-- header_file_name: 已经计算好的include路径
function M.generate_cpp_implementation(functions_by_class, include_level, namespace, header_file_name)
  local lines = {}

  -- 添加include
  if include_level and include_level >= 0 and header_file_name then
    table.insert(lines, "#include \"" .. header_file_name .. "\"")
  end

  -- 添加命名空间开始
  if namespace and namespace ~= "" then
    table.insert(lines, "namespace " .. namespace .. " {")
  end

  -- 生成每个类的函数实现
  for class_name, functions in pairs(functions_by_class) do
    for _, func_sig in ipairs(functions) do
      local body = generate_function_body(func_sig, class_name)
      if body then
        table.insert(lines, body)
      end
    end
  end

  -- 添加命名空间结束
  if namespace and namespace ~= "" then
    table.insert(lines, "} //" .. namespace)
  end

  return table.concat(lines, "\n")
end

-- 查找对应的头文件
-- cpp_file_path: cpp文件的路径
-- 返回头文件路径，或nil如果未找到
function M.find_header_file(cpp_file_path)
  local dir = cpp_file_path:match("^(.-)/[^/]+$") or "."
  local base_name = cpp_file_path:match("([^/]+)%.[^.]+$")

  if not base_name then
    return nil
  end

  -- 首先在同目录查找
  local header_candidates = {
    dir .. "/" .. base_name .. ".h",
    dir .. "/" .. base_name .. ".hpp",
  }

  for _, header_path in ipairs(header_candidates) do
    local file = io.open(header_path, "r")
    if file then
      file:close()
      return header_path
    end
  end

  -- 在上级目录查找
  local parent_dir = dir:match("^(.-)/[^/]+$")
  if parent_dir then
    for _, header_path in ipairs({
      parent_dir .. "/" .. base_name .. ".h",
      parent_dir .. "/" .. base_name .. ".hpp",
    }) do
      local file = io.open(header_path, "r")
      if file then
        file:close()
        return header_path
      end
    end
  end

  return nil
end

-- 获取相对路径的层级数
function M.get_include_level(cpp_file_path, header_file_path)
  local cpp_depth = select(2, cpp_file_path:gsub("/", ""))
  local header_depth = select(2, header_file_path:gsub("/", ""))

  if cpp_depth == header_depth then
    return 0
  end

  return math.abs(cpp_depth - header_depth)
end

-- 验证当前文件是否是有效的cpp文件
function M.is_valid_cpp_file(file_path)
  return (file_path:match("%.cc$") or file_path:match("%.cpp$")) and true or false
end

-- 提取命名空间（如果有的话）
function M.extract_namespace(header_file_path)
  local file = io.open(header_file_path, "r")
  if not file then
    return ""
  end

  local content = file:read("*a")
  file:close()

  -- 寻找命名空间定义（支持下划线）
  local namespace = content:match("namespace%s+([%w_]+)%s*{")
  return namespace or ""
end

-- 将文件名转换为驼峰命名法
-- 例如：aa_bb_dd.cc -> AaBbDd
function M.filename_to_camel_case(filename)
  -- 移除扩展名
  local name = filename:match("^(.+)%.[^.]+$") or filename

  -- 将下划线分隔的部分转换为驼峰
  local parts = {}
  for part in name:gmatch("[^_]+") do
    if part and part ~= "" then
      -- 首字母大写，其余小写
      local camel_part = part:sub(1, 1):upper() .. part:sub(2):lower()
      table.insert(parts, camel_part)
    end
  end

  return table.concat(parts, "")
end

-- 从当前行到最后一行提取函数声明并生成实现
function M.execute_cppc1()
  local current_file = vim.fn.expand("%:p")

  -- 验证是否是有效的cpp文件
  if not M.is_valid_cpp_file(current_file) then
    vim.notify("当前文件不是有效的 C++ 文件（需要 .cc 或 .cpp 后缀）", vim.log.levels.ERROR)
    return
  end

  -- 获取当前行号和总行数
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")

  -- 获取从当前行到最后一行的内容
  local lines = vim.api.nvim_buf_get_lines(0, current_line - 1, total_lines, false)
  local content = table.concat(lines, "\n")

  -- 从文件名生成类名（驼峰命名）
  local file_basename = current_file:match("([^/]+)%.[^.]+$")
  local class_name = M.filename_to_camel_case(file_basename)

  -- 直接提取函数声明
  local functions = {}

  for statement in content:gmatch("[^;]+") do
    -- 移除注释
    statement = statement:gsub("/%*.-%*/", "")
    local lines_stmt = {}
    for line in statement:gmatch("[^\n]+") do
      line = line:gsub("//.*$", "")
      table.insert(lines_stmt, line)
    end
    statement = table.concat(lines_stmt, "\n")

    local cleaned_stmt = statement:match("^%s*(.-)%s*$")

    if cleaned_stmt and cleaned_stmt ~= "" then
      if cleaned_stmt:match("%(") and cleaned_stmt:match("%)") then
        -- 过滤析构函数
        if cleaned_stmt:match("^%s*~") then
          goto skip_func
        end

        -- 过滤内联实现（= default, = delete, = 0）
        if cleaned_stmt:match("=%s*default%s*$") or
           cleaned_stmt:match("=%s*delete%s*$") or
           cleaned_stmt:match("=%s*0%s*$") then
          goto skip_func
        end

        -- 检查是否有实现体
        if not cleaned_stmt:match("{") then
          table.insert(functions, cleaned_stmt)
        end

        ::skip_func::
      end
    end
  end

  if #functions == 0 then
    vim.notify("未找到函数声明", vim.log.levels.INFO)
    return
  end

  -- 构建函数映射表，使用文件名转换后的类名
  local functions_by_class = {
    [class_name] = functions
  }

  -- 生成实现
  local cpp_content = M.generate_cpp_implementation(functions_by_class, -1, "", file_basename)

  -- 删除从当前行到文件末尾的原有内容，然后插入生成的实现
  local impl_lines = vim.split(cpp_content, "\n")
  vim.api.nvim_buf_set_lines(0, current_line - 1, total_lines, false, impl_lines)

  vim.notify("已生成 C++ 函数实现（类名: " .. class_name .. "）", vim.log.levels.INFO)
end

-- 主命令函数
-- include_level: 去掉前面多少个目录层级，0=完整相对路径，1=去掉第一层，-1=不需要include
function M.execute_cppc(include_level)
  -- 默认值为0
  include_level = tonumber(include_level) or 0

  local current_file = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()

  -- 验证是否是有效的cpp文件
  if not M.is_valid_cpp_file(current_file) then
    vim.notify("当前文件不是有效的 C++ 文件（需要 .cc 或 .cpp 后缀）", vim.log.levels.ERROR)
    return
  end

  -- 查找对应的头文件
  local header_file = M.find_header_file(current_file)
  if not header_file then
    vim.notify("未找到对应的头文件", vim.log.levels.ERROR)
    return
  end

  -- 获取相对于 cwd 的相对路径
  local relative_header_path = header_file
  if header_file:sub(1, #cwd) == cwd then
    relative_header_path = header_file:sub(#cwd + 2)  -- +2 跳过 /
  end

  -- 提取未实现的函数
  local functions_by_class = M.extract_unimplemented_functions(header_file)
  if not next(functions_by_class) then
    vim.notify("头文件中没有找到未实现的函数", vim.log.levels.INFO)
    return
  end

  -- 提取命名空间
  local namespace = M.extract_namespace(header_file)

  -- 计算include路径
  local include_path = relative_header_path
  if include_level >= 0 then
    -- 分割相对路径
    local parts = {}
    for part in relative_header_path:gmatch("[^/]+") do
      table.insert(parts, part)
    end

    -- 去掉前 include_level 个目录
    if include_level > 0 and include_level < #parts then
      local result_parts = {}
      for i = include_level + 1, #parts do
        table.insert(result_parts, parts[i])
      end
      include_path = table.concat(result_parts, "/")
    elseif include_level >= #parts then
      vim.notify("include层级过大，超过了路径层数", vim.log.levels.ERROR)
      return
    end
  end

  -- 生成cpp文件内容
  local cpp_content = M.generate_cpp_implementation(functions_by_class, include_level, namespace, include_path)

  -- 在当前文件中插入生成的内容
  local lines = vim.split(cpp_content, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  vim.notify("已生成 C++ 函数实现", vim.log.levels.INFO)
end

-- 设置命令（仅在 Vim 环境中）
if vim and vim.api then
  vim.api.nvim_create_user_command('Cppc', function(opts)
    M.execute_cppc(opts.args)
  end, {
    desc = '从头文件生成 C++ 文件实现',
    nargs = '?'  -- 可选参数
  })

  vim.api.nvim_create_user_command('Cppc1', function()
    M.execute_cppc1()
  end, { desc = '从当前行到最后一行提取函数并生成实现' })
end

return M
