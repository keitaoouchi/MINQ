#!/bin/bash
usage() {
    cat <<HELP
SYNOPSIS:
  $0 [-d] [iOS(default)|watchOS|tvOS|Mac]
  $0 [-h]

ARGUMENTS:
  iOS       print paths for iOS (default)
  watchOS   print paths for iOS
  tvOS      print paths for iOS
  Mac       print paths for iOS

OPTIONS:
  -h  Show usage
  -d  output decorated result, e.g. "\$(SRCROOT)/Carthage/Build/iOS/APIKit.framework",

EXAMPLE:
  $0 iOS
  $0 -d watchOS

HELP
}

framework_not_found() {
  echo "framework not found."
}

print_paths() {
  dir_path="Carthage/Build/$1"
  if [ ! -d $dir_path ]; then
    framework_not_found; exit 0;
  fi
  if [ $DECORATE -eq 1 ]; then
    paths=$(find Carthage/Build/"$1" -type d -name "*.framework" | sort | xargs -n 1 -I % echo '"$(SRCROOT)/'%'",')
  else
    paths=$(find Carthage/Build/"$1" -type d -name "*.framework" | sort | xargs -n 1 -I % echo '$(SRCROOT)/'%)
  fi
  [ ! -z "$paths" ] && echo "$paths" || framework_not_found
}

main() {
  SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"
  DECORATE=0
  for ARG; do
    case "$ARG" in
      -*)
      while getopts h,d OPT "$ARG"; do
        case "$OPT" in
          h) usage; exit 0;;
          d) DECORATE=1;;
          *) exit 1;;
        esac
      done
      ;;
    esac
  done

  shift $(expr $OPTIND - 1)
  if [ $# -gt 1 ]; then
    echo -e "Too many arguments. See below:\n"; usage; exit 1;
  fi
  if [ ! -d Carthage/Build ]; then
    echo "directory \"Carthage/Build\"  not found"; exit 1;
  fi
  print_paths ${1:-iOS}
}

main "$@"
