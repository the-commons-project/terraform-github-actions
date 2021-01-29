#!/bin/bash

function terragruntShow() {
  # Gather the output of `terragrunt plan`.
  echo "show: info: showing Terragrunt configuration in ${tfWorkingDir}"
  showOutput=$(${tfBinary} show -no-color ${*} 2>&1)
  # showOutput=$(${tfBinary} show -no-color -json plan.out >plan.json)
  showExitCode=${?}
  showCommentStatus="Failed"

  # Exit code of 0 indicates success with no changes. Print the output and exit.
  if [ ${showExitCode} -eq 0 ]; then
    echo "show: info: successfully showed Terragrunt configuration in ${tfWorkingDir}"
    echo "${showOutput}"
    echo
    exit ${showExitCode}
  fi

  # Exit code of !0 indicates failure.
  if [ ${showExitCode} -ne 0 ]; then
    echo "show: error: failed to show Terragrunt configuration in ${tfWorkingDir}"
    echo "${showOutput}"
    echo
  fi

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${tfComment}" == "1" ] && [ "${showCommentStatus}" == "Failed" ]; then
    showCommentWrapper="#### \`${tfBinary} show\` ${showCommentStatus}
<details><summary>Show Output</summary>

\`\`\`
${showOutput}
\`\`\`

</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${tfWorkingDir}\`, Workspace: \`${tfWorkspace}\`*"

    showCommentWrapper=$(stripColors "${showCommentWrapper}")
    echo "show: info: creating JSON"
    showPayload=$(echo "${showCommentWrapper}" | jq -R --slurp '{body: .}')
    showCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "show: info: commenting on the pull request"
    echo "${showPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${showCommentsURL}" >/dev/null
  fi

  # https://github.community/t5/GitHub-Actions/set-output-Truncates-Multiline-Strings/m-p/38372/highlight/true#M3322
  showOutput="${showOutput//'%'/'%25'}"
  showOutput="${showOutput//$'\n'/'%0A'}"
  showOutput="${showOutput//$'\r'/'%0D'}"

  echo "::set-output name=tf_actions_show_output::${showOutput}"
  exit ${showExitCode}
}
