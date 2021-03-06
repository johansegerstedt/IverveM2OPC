#!/usr/bin/env bash
set -e

latest_tag=$(git tag | tail -1)
current_branch=$(git rev-parse --abbrev-ref HEAD)
release_filename="Digia_AvardaCheckout.tar.gz"

# DEFINE_SCRIPT_DIR([])
# ARG_OPTIONAL_SINGLE([checkout],[],[It is tag or branch],[branch])
# ARG_OPTIONAL_SINGLE([checkout_value],[],[In case of tag write v1.1.1, in case of branch is a string],[$current_branch])
# ARG_OPTIONAL_SINGLE([m2path],[],[Magento2 installation path],[/var/www/html/magento2opc/])
# ARG_OPTIONAL_BOOLEAN([with_cc],[],[Should clean the cache])
# ARG_OPTIONAL_BOOLEAN([with_release],[],[Should we  build a release])
# ARG_HELP([<Initial deployment script for local deployments :) >])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.6.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option()
{
	local first_option all_short_options
	all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}



# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_checkout="branch"
_arg_checkout_value="$current_branch"
_arg_m2path="/var/www/html/magento2opc/"
_arg_with_cc="off"
_arg_with_release="off"

print_help ()
{
	printf '%s\n' "<Initial deployment script for local deployments :) >"
	printf 'Usage: %s [--checkout <arg>] [--checkout_value <arg>] [--m2path <arg>] [--(no-)with_cc] [--(no-)with_release] [-h|--help]\n' "$0"
	printf '\t%s\n' "--checkout: It is tag or branch (default: 'branch')"
	printf '\t%s\n' "--checkout_value: In case of tag write v1.1.1, in case of branch is a string (default: '$current_branch')"
	printf '\t%s\n' "--m2path: Magento2 installation path (default: '/var/www/html/magento2opc/')"
	printf '\t%s\n' "--with_cc,--no-with_cc: Should clean the cache (off by default)"
	printf '\t%s\n' "--with_release,--no-with_release: Should we  build a release (off by default)"
	printf '\t%s\n' "-h,--help: Prints help"
}

parse_commandline ()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--checkout)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_checkout="$2"
				shift
				;;
			--checkout=*)
				_arg_checkout="${_key##--checkout=}"
				;;
			--checkout_value)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_checkout_value="$2"
				shift
				;;
			--checkout_value=*)
				_arg_checkout_value="${_key##--checkout_value=}"
				;;
			--m2path)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_m2path="$2"
				shift
				;;
			--m2path=*)
				_arg_m2path="${_key##--m2path=}"
				;;
			--no-with_cc|--with_cc)
				_arg_with_cc="on"
				test "${1:0:5}" = "--no-" && _arg_with_cc="off"
				;;
			--no-with_release|--with_release)
				_arg_with_release="on"
				test "${1:0:5}" = "--no-" && _arg_with_release="off"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || die "Couldn't determine the script's running directory, which probably matters, bailing out" 2

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root like sudo ./deploy.sh"
  exit
fi

printf 'Value of --%s: %s\n' 'checkout' "$_arg_checkout"
printf 'Value of --%s: %s\n' 'checkout_value' "$_arg_checkout_value"
printf 'Value of --%s: %s\n' 'm2path' "$_arg_m2path"
printf 'Value of --%s: %s\n' 'with_cc' "$_arg_with_cc"
printf 'Value of --%s: %s\n' 'with_release' "$_arg_with_release"

echo 'Fetching latest commit messages ...'
git fetch --all

echo 'Stashing changes ...'
git stash

if [ "$_arg_checkout" = "branch" ]
then
    echo Checking out the $_arg_checkout_value
    git checkout $_arg_checkout_value
else
    if [ -z {"$_arg_checkout_value"} ]
    then
        _arg_checkout_value=latest_tag
    fi
    echo Checking out the $_arg_checkout_value
    git checkout tags/$_arg_checkout_value
fi

cd ${script_dir}/view/frontend/app/

echo 'Install latest packages'
yarn

echo 'Building the app ...'
yarn build:app

echo "AVARDA iframe style location ./view/frontend/web/css/avarda.css"

if [ "${_arg_with_release}" = on ]
then
    # delete if exsits
    [ -e ${release_filename} ] && rm -f ${release_filename}

    cd ${script_dir}
    GZIP=-9 # maximum compression
    tar --exclude='.git*' \
    --exclude='./view/frontend/app' \
    --exclude='.DS_Store' \
    --exclude='.idea' \
    -zcvf ${release_filename} .
fi

if [ "${_arg_with_cc}" = on ]
then
    echo 'Clear caches and all magento stuff ...'
    cd ${_arg_m2path}

    rm -rf var/cache/* var/page_cache/* var/di/* var/generation/* var/view_preprocessed/*
    bin/magento cache:flush
    bin/magento setup:upgrade
    bin/magento setup:di:compile
    bin/magento setup:static-content:deploy -f en_US fi_FI sv_SE
    bin/magento indexer:reindex
    bin/magento cache:flush
    bin/magento cache:clean
    chmod -R 775 ./
    chown -R root:www-data ./
fi

echo '    _____   ____  _   _ ______    '
echo '   |  __ \ / __ \| \ | |  ____|   '
echo '   | |  | | |  | | . ` |  __|     '
echo '   | |__| | |__| | |\  | |____    '
echo '   |_____/ \____/|_| \_|______|   '
# ] <-- needed because of Argbash
