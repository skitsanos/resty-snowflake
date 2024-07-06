local snowflake = require("snowflake")

ngx.header.content_type = "text/plain"

snowflake.init()

ngx.log(ngx.INFO, "Accessing snowflake...")

-- Get current timestamp
local result, err_exec_sql = snowflake.execute_sql("SELECT CURRENT_TIMESTAMP()")

if err_exec_sql then
    ngx.say("Error: " .. err_exec_sql)
    return
end

ngx.say("Result: ", result.data[1])

-- Testing bindings
local result_bindings, err_exec_sql_with_bindings = snowflake.execute_sql("SELECT 1=?", {
    ["1"] = {
        type = "FIXED",
        value = "123"
    }
})

if err_exec_sql_with_bindings then
    ngx.say("Error: " .. err_exec_sql_with_bindings)
    return
end

ngx.say("Binding Result: ", result_bindings.data[1])

-- Testing CortexAI Translation services
ngx.log(ngx.INFO, "Testing CortexAI Translation services...")
local result_translation, err_translation = snowflake.execute_sql("SELECT SNOWFLAKE.CORTEX.TRANSLATE(?, '', ?) AS TRANSLATION_RESULT", {
    ["1"] = {
        type = "TEXT",
        value = "Ich kriege den Fehlercode 103 zurück."
    },
    ["2"] = {
        type = "TEXT",
        value = "en"
    }
})

if err_translation then
    ngx.say("Error: " .. err_translation)
    return
end

ngx.say("Translation Result: ", result_translation.data[1])