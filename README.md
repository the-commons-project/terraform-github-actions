# Terragrunt GitHub Actions

Terragrunt GitHub Actions allow you to execute Terragrunt commands within GitHub Actions.

The output of the actions can be viewed from the Actions tab in the main repository view. If the actions are executed on a pull request event, a comment may be posted on the pull request.

Terragrunt GitHub Actions are a single GitHub Action that executes different Terragrunt subcommands depending on the content of the GitHub Actions YAML file.

## Success Criteria

An exit code of `0` is considered a successful execution.

## Usage

The most common workflow is to run `terragrunt fmt`, `terragrunt init`, `terragrunt validate`, `terragrunt plan`, and `terragrunt taint` on all of the Terragrunt files in the root of the repository when a pull request is opened or updated. A comment will be posted to the pull request depending on the output of the Terragrunt subcommand being executed. This workflow can be configured by adding the following content to the GitHub Actions workflow YAML file. Note that this action will use `terragrunt` binary to run all commands. In case of passing a `terraform` subcommand `terragrunt` will forward it to `terraform`.

```yaml
name: 'Terragrunt GitHub Actions'
on:
  - pull_request
env:
  tf_version: 'latest'
  tg_version: 'latest'
  tf_working_dir: '.'
jobs:
  terragrunt:
    name: 'Terragrunt'
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Terragrunt Format'
        uses: the-commons-project/terragrunt-github-actions@master
        with:
          tf_actions_version: ${{ env.tf_version }}
          tg_actions_version: ${{ env.tg_version }}
          tf_actions_binary: 'terraform'
          tf_actions_subcommand: 'fmt'
          tf_actions_working_dir: ${{ env.tf_working_dir }}
          tf_actions_comment: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: 'Terragrunt Init'
        uses: the-commons-project/terragrunt-github-actions@master
        with:
          tf_actions_version: ${{ env.tf_version }}
          tg_actions_version: ${{ env.tg_version }}
          tf_actions_subcommand: 'init'
          tf_actions_working_dir: ${{ env.tf_working_dir }}
          tf_actions_comment: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: 'Terragrunt Validate'
        uses: the-commons-project/terragrunt-github-actions@master
        with:
          tf_actions_version: ${{ env.tf_version }}
          tg_actions_version: ${{ env.tg_version }}
          tf_actions_binary: 'terraform'
          tf_actions_subcommand: 'validate'
          tf_actions_working_dir: ${{ env.tf_working_dir }}
          tf_actions_comment: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: 'Terragrunt Plan'
        uses: the-commons-project/terragrunt-github-actions@master
        with:
          tf_actions_version: ${{ env.tf_version }}
          tg_actions_version: ${{ env.tg_version }}
          tf_actions_subcommand: 'plan'
          tf_actions_working_dir: ${{ env.tf_working_dir }}
          tf_actions_comment: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This was a simplified example showing the basic features of these Terragrunt GitHub Actions. Please refer to the examples within the `examples` directory for other common workflows.

## Inputs

Inputs configure Terraform GitHub Actions to perform different actions.

| Input Name                          | Description                                                | Required |
|:------------------------------------|:-----------------------------------------------------------|:--------:|
| tf_actions_subcommand               | The Terraform/Terragrunt  subcommand to execute.           | `Yes`    |
| tf_actions_binary                   | The binary to run the commands with                        | `No`     |
| tf_actions_version                  | The Terraform version to install and execute. If set to `latest`, the latest stable version will be used. | `Yes` |
| tg_actions_version                  | The Terragrunt version to install and execute. If set to `latest`, the latest stable version will be used. | `Yes` |
| tf_actions_cli_credentials_hostname | Hostname for the CLI credentials file. Defaults to `app.terraform.io`. | `No` |
| tf_actions_cli_credentials_token    | Token for the CLI credentials file.                        | `No`     |
| tf_actions_comment                  | Whether or not to comment on GitHub pull requests. Defaults to `true`. | `No` |
| tf_actions_working_dir              | The working directory to change into before executing Terragrunt subcommands. Defaults to the root of the GitHub repository. | `No` |
| tf_actions_fmt_write                | Whether or not to write `fmt` changes to source files. Defaults to `false`. | `No` |

## Outputs

Outputs are used to pass information to subsequent GitHub Actions steps.

| Output Name                 | Description                                                                      |
|:----------------------------|:---------------------------------------------------------------------------------|
| tf_actions_output           | The Terragrunt outputs in (stringified) JSON format.                             |
| tf_actions_plan_has_changes | `'true'` if the Terragrunt plan contained changes, otherwise `'false'`.          |
| tf_actions_plan_output      | The Terragrunt plan output.                                                      |
| tf_actions_fmt_written      | Whether or not the Terragrunt formatting from `fmt` was written to source files. |

## Secrets

Secrets are similar to inputs except that they are encrypted and only used by GitHub Actions. It's a convenient way to keep sensitive data out of the GitHub Actions workflow YAML file.

* `GITHUB_TOKEN` - (Optional) The GitHub API token used to post comments to pull requests. Not required if the `tf_actions_comment` input is set to `false`.

Other secrets may be needed to authenticate with Terraform backends and providers.

**WARNING:** These secrets could be exposed if the action is executed on a malicious Terraform file. To avoid this, it is recommended not to use these Terraform GitHub Actions on repositories where untrusted users can submit pull requests.

## Environment Variables

Environment variables are exported in the environment where the Terraform GitHub Actions are executed. This allows a user to modify the behavior of certain GitHub Actions.

The usual [Terraform environment variables](https://www.terraform.io/docs/commands/environment-variables.html) are supported. Here are a few of the more commonly used environment variables.

* [`TF_LOG`](https://www.terraform.io/docs/commands/environment-variables.html#tf_log)
* [`TF_VAR_name`](https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name)
* [`TF_CLI_ARGS`](https://www.terraform.io/docs/commands/environment-variables.html#tf_cli_args-and-tf_cli_args_name)
* [`TF_CLI_ARGS_name`](https://www.terraform.io/docs/commands/environment-variables.html#tf_cli_args-and-tf_cli_args_name)
* `TF_WORKSPACE`

Other environment variables may be configured to pass data into Terraform. If the data is sensitive, consider using [secrets](#secrets) instead.


## Testing

If you want to test these scripts locally, its possible after installing docker in your test environment

1. Open `test/local-test.sh` and modify the GLOBAL variables (in caps) according to your needs
2. Run it with: `test/local-test.sh` or `test/local-test.sh run-all plan`
3. The above command:
 - Builds a docker container with image tag `tg`
 - Starts that container with those global variables



**This is a fork of [Terraform Github Actions](https://github.com/hashicorp/terraform-github-actions).**