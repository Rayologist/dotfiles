awsctx() {
  local profiles selected region

  profiles=$(aws configure list-profiles 2>/dev/null)
  [ -z "$profiles" ] && { echo "no aws profiles"; return 1; }

  selected=$(echo "$profiles" | fzf)
  [ -z "$selected" ] && return 0

  region=$(aws configure get region --profile "$selected" 2>/dev/null)

  export AWS_PROFILE="$selected"
  if [ -n "$region" ]; then
    export AWS_REGION="$region"
  else
    unset AWS_REGION
  fi

  echo "switched to context ${AWS_PROFILE}${AWS_REGION:+ ($AWS_REGION)}"
}
