local http = require ("resty.http")

local snowflake = {}

-- Configuration
snowflake.config = {
    account_name = nil,
    username = nil,
    private_key = nil,
    private_key_password = nil,
    public_key_fp = nil,
}

-- Initialize the module with configuration
function snowflake.init(config)
    config = config or {}

    snowflake.config.account_name = config.account_name or os.getenv("SNOWFLAKE_ACCOUNT_NAME")
    snowflake.config.username = config.username or os.getenv("SNOWFLAKE_USERNAME")
    snowflake.config.private_key = config.private_key or os.getenv("SNOWFLAKE_PRIVATE_KEY")
    snowflake.config.private_key_password = config.private_key_password or os.getenv("SNOWFLAKE_PRIVATE_KEY_PASSWORD")
    snowflake.config.public_key_fp = config.public_key_fp or os.getenv("SNOWFLAKE_PUBLIC_KEY_FINGERPRINT")
end

-- Generate JWT
function snowflake.generate_jwt()
    ngx.log(ngx.INFO, "Generating JWT")
    local header = '{"alg": "RS256", "typ": "JWT"}'
    local account = snowflake.config.account_name
    local user = snowflake.config.username
    local public_key_fp = snowflake.config.public_key_fp
    local now = os.time()
    local exp = now + 3540
    local qualified_username = string.upper(account .. "." .. user)

    local payload = string.format(
            '{"iss": "%s.SHA256:%s", "sub": "%s", "iat": %d, "exp": %d}',
            qualified_username, public_key_fp, qualified_username, now, exp
    )

    local header_base64 = ngx.encode_base64(header):gsub("=+$", ""):gsub("/", "_"):gsub("+", "-")
    local payload_base64 = ngx.encode_base64(payload):gsub("=+$", ""):gsub("/", "_"):gsub("+", "-")

    local openssl_pkey = require("resty.openssl.pkey")
    local pkey, err
    if snowflake.config.private_key_password then
        pkey, err = openssl_pkey.new(snowflake.config.private_key, snowflake.config.private_key_password)
    else
        pkey, err = openssl_pkey.new(snowflake.config.private_key)
    end
    if not pkey then
        ngx.log(ngx.ERR, "Failed to load private key: ", err)
        return nil, "Failed to load private key: " .. (err or "unknown error")
    end

    ngx.log(ngx.INFO, "Private key loaded successfully")

    local signature, err_pkey_sign = pkey:sign(header_base64 .. "." .. payload_base64, "sha256")
    if not signature then
        ngx.log(ngx.ERR, "Failed to sign payload: ", err_pkey_sign)
        return nil, "Failed to sign payload: " .. (err_pkey_sign or "unknown error")
    end

    ngx.log(ngx.INFO, "Payload signed successfully")

    local signature_base64 = ngx.encode_base64(signature):gsub("=+$", ""):gsub("/", "_"):gsub("+", "-")

    return header_base64 .. "." .. payload_base64 .. "." .. signature_base64
end

-- Execute SQL statement
-- Execute SQL statement with optional bindings
function snowflake.execute_sql(statement, bindings)
    local jwt, err = snowflake.generate_jwt()
    if not jwt then
        return nil, err
    end

    local httpc = http.new()

    ngx.log(ngx.INFO, "Executing SQL: ", statement)

    local body = { statement = statement }
    if bindings then
        body.bindings = bindings
    end

    local res, err_http_client = httpc:request_uri("https://" .. snowflake.config.account_name .. ".snowflakecomputing.com/api/v2/statements", {
        method = "POST",
        headers = {
            ["Accept"] = "*/*",
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. jwt,
            ["X-Snowflake-Authorization-Token-Type"] = "KEYPAIR_JWT"
        },
        body = json.encode(body),
        ssl_verify = false
    })

    if not res then
        ngx.log(ngx.ERR, "Failed to execute SQL: ", err_http_client)
        return nil, err_http_client
    end

    return json.decode(res.body), nil
end

return snowflake