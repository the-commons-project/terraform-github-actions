#!/bin/bash

function terragruntHCLFmt {
  # Gather the output of `terragrunt hclfmt`.
  echo "fmt: info: checking if Terragrunt HCL files in ${tfWorkingDir} are correctly formatted"
  if [ ${tfBinary} != "terragrunt" ]; then
    echo "skipping formatting HCL files"
    exit 0
  fi

  fmtOutput=$(${tfBinary} hclfmt  --terragrunt-check ${*} 2>&1)
  fmtExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${fmtExitCode} -eq 0 ]; then
    echo "hclfmt: info: Terragrunt files in ${tfWorkingDir} are correctly formatted"
    echo "${fmtOutput}"
    echo
    exit ${fmtExitCode}
  fi

  # Exit code of 2 indicates a parse error. Print the output and exit.
  if [ ${fmtExitCode} -eq 1 ]; then
    echo "hclfmt: error: failed to format Terragrunt files"
    echo "${fmtOutput}"
  fi

  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${tfComment}" == "1" ]; then
    fmtCommentWrapper="#### \`${tfBinary} hclfmt\` Failed:

\`\`\`
${fmtOutput}
\`\`\`

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${tfWorkingDir}\`, Workspace: \`${tfWorkspace}\`*"

    fmtCommentWrapper=$(stripColors "${fmtCommentWrapper}")
    echo "fmt: info: creating JSON"
    fmtPayload=$(echo "${fmtCommentWrapper}" | jq -R --slurp '{body: .}')
    fmtCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "fmt: info: commenting on the pull request"
    echo "${fmtPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${fmtCommentsURL}" > /dev/null
  fi

  # Write changes to branch
  echo "::set-output name=tf_actions_fmt_written::false"
  if [ "${tfFmtWrite}" == "1" ]; then
    echo "fmt: info: Terraform files in ${tfWorkingDir} will be formatted"
    terraform fmt -write=true ${fmtRecursive} "${*}"
    fmtExitCode=${?}
    echo "::set-output name=tf_actions_fmt_written::true"
  fi

  exit ${fmtExitCode}
}
