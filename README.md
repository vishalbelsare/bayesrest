# Overview

After cloning this repo, there are six steps to setup bayesrest:
1. Setup nginx-proxy
1. Add to /etc/hosts
1. Create a `.bdb` file
1. If you're using the loom backend, add loom libraries
1. Configuration
1. Start the app

### 1. Setup probcomp/nginx-proxy repo

Follow the instructions at https://github.com/probcomp/nginx-proxy -- nginx-proxy must be running before you can access bayesrest.

### 2. Add /etc/hosts entry (if you don't already have one)

    echo "127.0.0.1 bayesrest.probcomp.dev" | sudo tee -a /etc/hosts

### 3. Create a `.bdb` file

BayesREST requires that you provide it a `.bdb` file for which analysis has already been performed. Rename that file `database.bdb` and place it at the project root.

### 4. If you're using the loom backend, add loom libraries

If you are using the `loom` backend, you will need to add loom libraries to your repo.  This has somtimes been done by unpacking a `.tar` file of the loom library files into the repo's root directory.

### 5. Configuration

BayesREST is configured via a `.yaml` file. To get started, create a new `config.yaml` file, copy the contents of `config-example.yaml` into it, and edit to reflect your local environment, ***then write the path to that file into `docker-compose.yml`.***

The values you must configure in `config.yaml` are:

- `bdb_file`: The filename of the `.bdb` file to issue queries against (which must be in the local directory)
- `loom_path`: The absolute path to your loom directory _within your running docker image_
- `log_level`: The log level for the application. Valid options are `CRITICAL`, `ERROR`, `WARNING`, `INFO`, `DEBUG`, and `NOTSET`.
- `table_name`: The table containing the data under analysis.
- `population_name`: The name of the population in your `.bdb` file

In the `gunicorn` section, you can configure:

- `bind`: The IP and address the server should bind to.
- `workers`: The number of preforked worker processes
- `timeout`: The number of seconds requests may take before returning an error. On slower machines, you may need to increase the default value of 30 seconds.
- `reload`: A boolean- if set True, will cause gunicorn to watch source files and reload if the application changes (useful for development)

### 6. Start the app

    CONFIG_FILE_PATH=/path/to/config.yaml docker-compose up

(Use the --build option if you've made docker changes.)

Service is accessible at `https://bayesrest.probcomp.dev:8443` (though the TLS-terminating nginx proxy) and `http://localhost:5000` (directly)

### Example request

    curl --request POST \
      --url http://localhost:5000/find-peers \
      --header 'content-type: application/json' \
      --data '{
        "context-column": "operator_owner",
        "target-row": 10
     }'

### Development

The docker container mounts and runs out of this directory, and by default the server is configured to watch for source file changes, so your changes will generally be immediately visibile in the running container.

The container will crash on some bad syntax errors. Simply restart it in those instances.

You'll need to rebuild your Docker container if you change requirements.

### Documentation

Docs are autogenerated from the API spec. We're using [ReDoc](https://github.com/Rebilly/ReDoc/blob/master/cli/README.md) to do just that.

To rebuild docs, you'll need to install redoc-cli first:

    npm install -g redoc-cli

Then you can rebuild documentation with:

    make docs
