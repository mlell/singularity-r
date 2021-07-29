# Functions for launching programs in the container reproducibly.
# 

msg(){
  if [ "$#" -gt 0 ]; then 
    printf "$@" >&2
  fi
  echo >&2
}
get_wd_in_container(){
  # Returns: "." if $1 matches with $PROJECT_DIR, "relative/path" if $1
  # is a subfolder of the project dir, and "" if $1 is not inside the
  # project dir

  # If the working dir is inside the project directory, determine the 
  # corresponding directory inside the container
  local p="${PROJECT_DIR}"
  local w="${1}"
  # normalize trailing slashes

  while [ "${p: -1}" = "/" ]; do p="${p%/}"; done
  while [ "${w: -1}" = "/" ]; do w="${w%/}"; done
  p="${p}/"
  w="${w}/"
  # each path now has exactly one slash at the end. This makes sure that 
  # /home/user/myproject is not counted as subfolder of /home/user/my

  if [ ! "${w::${#p}}" = "$p" ]; then
    echo ""
    return
  fi

  w="${BIND_PROJECT_TO}/${w:${#p}}"

  echo "$w"
}

cexec(){

  if [ "$#" = 0 ]; then
    echo "Argument needed (try --help)" >&2
    exit 1
  fi 
  local wd_inside=""
  while [ "$#" -gt 0 ]; do
    case "$1" in 
    --help)
      msg "Usage: exec COMMAND ARGS..."
      msg "Execute the given command in the container."
      exit 0
      ;;
    --pwd)
      if [ -z "${2-}" ]; then msg "Missing argument to  --pwd"; exit 1; fi
      wd_inside="${2}"
      shift 2
      ;;
    --*)
      echo "Unknown argument '$1'" >&2
      exit 1
      ;;
    --) shift; break; ;;
    *) break; ;;
    esac
  done
 
  if [ -z "$wd_inside" ]; then
    wd_inside="$(get_wd_in_container "$PWD")"
  fi

  if [ "$wd_inside" = "" ]; then
    echo "The current working directory '$PWD' is not inside the project directory '$PROJECT_DIR'"
    exit 1
  fi

  sargs=(
    "${ARGS_INSTANCE[@]}" \
    "${ARGS_EXEC[@]}" \
    --pwd "${wd_inside}" \
    "$CONTAINER" \
  )
  if ! singularity exec "${sargs[@]}" test -d "$wd_inside"; then
    msg "Working directory '$wd_inside' does not exist in the container"
    exit 1
  fi
  
  singularity exec "${sargs[@]}" "$@"
}



