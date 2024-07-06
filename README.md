# resty-snowflake

`resty-snowflake` is a Lua library that integrates Snowflake's powerful capabilities with the high-performance web platform OpenResty. It leverages the Snowflake SQL REST API and supports fast JSON processing, enabling efficient and scalable data management in modern web applications.

## Features

- Direct integration of Snowflake with OpenResty
- High-performance JSON processing using libraries like `rsjson`, `dkjson`, or `cjson`
- Support for Snowflake SQL API operations:
  - Submit SQL statements for execution
  - Check execution status
  - Cancel statement execution
  - Fetch query results concurrently
- Integration with CortexAI Services for AI-powered functionalities
- Flexible configuration via environment variables or Lua scripts

## Installation

1. Ensure you have OpenResty installed on your system.
2. Clone this repository:
   ```
   git clone https://github.com/skitsanos/resty-snowflake.git
   ```
3. Install the required OpenResty packages:
   ```
   opm get bsiara/dkjson
   opm get fffonion/lua-resty-openssl
   opm get pintsized/lua-resty-http
   opm get SkyLothar/lua-resty-jwt
   ```

## Configuration

You can configure `resty-snowflake` using either environment variables or Lua configuration.

### Environment Variables

Set the following environment variables:

- `SNOWFLAKE_ACCOUNT_NAME`
- `SNOWFLAKE_USERNAME`
- `SNOWFLAKE_PRIVATE_KEY`
- `SNOWFLAKE_PUBLIC_KEY_FINGERPRINT`

### Lua Configuration

Initialize the library with a configuration table:

```lua
local snowflake = require("snowflake")

snowflake.init({
    account_name = "your_account_name",
    username = "your_username",
    private_key = "your_private_key",
    private_key_password = "your_private_key_password", -- optional
    public_key_fp = "your_public_key_fingerprint"
})
```

## Usage

Here's a basic example of how to use `resty-snowflake`:

```lua
local snowflake = require("snowflake")

snowflake.init()

local result, err = snowflake.execute_sql("SELECT CURRENT_TIMESTAMP()")
if err then
    ngx.say("Error: " .. err)
    return
end

ngx.say("Result: ", result.data[1])
```

## Docker Support

A Dockerfile is provided for easy deployment. Build and run the Docker image using the following commands:

```bash
docker build -t resty-snowflake-demo .
docker run -it -d -p "8000:80" -v "$(pwd)/app:/app" -v "$(pwd)/lib:/app-libs" -v "$(pwd)/nginx/conf/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf" -e SNOWFLAKE_ACCOUNT_NAME="your_account_name" -e SNOWFLAKE_USERNAME="your_username" -e SNOWFLAKE_PRIVATE_KEY="your_private_key" -e SNOWFLAKE_PUBLIC_KEY_FINGERPRINT="your_public_key_fingerprint" resty-snowflake-demo
```

## Taskfile

A Taskfile is included to simplify common operations:

- `generate-keypair`: Generate RSA key pair
- `test-keypair`: Test Snowflake connectivity
- `generate-jwt`: Generate JWT for authentication
- `test-sql`: Test Snowflake SQL REST API
- `docker-build`: Build Docker image
- `docker-run`: Run Docker container

To use these tasks, install [Task](https://taskfile.dev/) and run `task <taskname>`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any problems or have any questions, please open an issue on this GitHub repository.