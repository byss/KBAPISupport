#!/bin/bash

# Reports warning to stderr
print_warning() {
	local f=${f:-"${BASH_SOURCE}"}
	local l=${l:-"${BASH_LINENO}"}

	echo "$f: $l: Warning:" "$@" >&2
}

# Reports error to stderr and dies
fatal_error() {
	local f=${f:-"${BASH_SOURCE}"}
	local l=${l:-"${BASH_LINENO}"}
	
	echo "$f: $l: error:" "$@" >&2
	exit 1
}

# Returns string containing var name & value
dump_var() {
	local var_ref="$1"
	echo "${var_ref} ('${!var_ref}')"
}

# Recursively generate all vars dumps
vars_error_message() {
	local vars_left="$1"
	shift

	if [ "${vars_left}" -gt 0 ]; then
		local var_ref="$1"
		shift
		local var_message="$1"
		shift

		local var_dump=$(dump_var "${var_ref}")
		local other_vars_message=$(vars_error_message $((vars_left - 1)) "$@")
		
		echo "${var_dump}" "${var_message}" "${other_vars_message}"
	else
		echo -e "$@"
	fi
}

# Reports error in variables values and dies
variables_error() {
	local f=${f:-"${BASH_SOURCE}"}
	local l=${l:-"${BASH_LINENO}"}
	
	local message=$(vars_error_message "$@")
	fatal_error "${message}"
}

# Reports error in one variable and dies
variable_error() {
	local f=${f:-"${BASH_SOURCE}"}
	local l=${l:-"${BASH_LINENO}"}

	variables_error '1' "$@"
}

# Returns check for single boolean macro
simple_bool_define_check() {
	local def="$1"
	cat <<EOF
#ifndef ${def}
#	error Please define boolean-compatible '${def}'
#endif
EOF
}

# Checks KBAPISupport-config.h for full set of macros & consistency
check_config() {
	local defines_check_code=
	for def in 'KBAPISUPPORT_DEBUG' 'KBAPISUPPORT_JSON' 'KBAPISUPPORT_USE_SBJSON' 'KBAPISUPPORT_XML' 'KBAPISUPPORT_DECODE'; do
		local current_define=$(simple_bool_define_check "${def}")
		defines_check_code=$(echo -e "${defines_check_code}\n${current_define}")
	done
	defines_check_code=$(cat <<EOF
${defines_check_code}
#if defined (KBAPISUPPORT_DECODE) && !defined (KBAPISUPPORT_DECODE_FROM)
#	error Please define KBAPISUPPORT_DECODE_FROM
#endif
#if !(KBAPISUPPORT_JSON || KBAPISUPPORT_XML)
#	error Please enable one of the following options: KBAPISUPPORT_JSON, KBAPISUPPORT_XML
#endif
#if (KBAPISUPPORT_JSON && KBAPISUPPORT_XML) != (KBAPISUPPORT_BOTH_FORMATS)
#	error Your config header sets KBAPISUPPORT_BOTH_FORMATS incorrectly
#endif
EOF
)
	local config_file="$1"
	echo "${defines_check_code}" | "${COMPILER}" -include "${config_file}" -x objective-c-header -E - 2>&1 >/dev/null
}

py_realpath() {
	python -c 'import os, sys; print "\n".join ([os.path.realpath (p) for p in sys.argv [1:]])' "$@"
}

# Environment details
COMPILER="$(which gcc)" # FIXME

CP=${CP:-$(which cp)}
CP=${CP:-'/bin/cp'}

RM="$(which rm)"
RM=${RM:-'/bin/rm'}

SCRIPT_LINK="$(py_realpath "$0")"
SCRIPT_DIR="$(dirname "${SCRIPT_LINK}")"

ACTION=${ACTION:-"$1"}
ACTION=${ACTION:-'build'}

# Check sources root directory
if [ -z "${SOURCES_ROOT}" ]; then
	if [ ! -z "${SRCROOT}" ] && [ ! -z "${PRODUCT_NAME}" ]; then
		SOURCES_ROOT="${SRCROOT}/${PRODUCT_NAME}/"
	else
		SOURCES_ROOT="${SCRIPT_DIR}"
	fi
fi

if [ ! -d "${SOURCES_ROOT}" ]; then
	variable_error 'SOURCES_ROOT' 'is not library sources directory'
fi
if ! ( [ -r "${SOURCES_ROOT}" ] && [ -w "${SOURCES_ROOT}" ] && [ -x "${SOURCES_ROOT}" ] ); then
	variable_error 'SOURCES_ROOT' 'is not accessible for reading, writing & search'
fi

# Working files
CONFIG_FILE="${SOURCES_ROOT}/KBAPISupport-config.h"
CONFIG_FILE_EXAMPLE="${CONFIG_FILE}.example"
AUTOGEN_HEADER="${SOURCES_ROOT}/KBAutoFieldMacros.gen.h"
AUTOGEN_HEADER_GEN="${AUTOGEN_HEADER}.py"

if [ "${ACTION}" = 'clean' ]; then
	######################## BUILD ACTION ########################
	
	# Remove generated header
	AUTOGEN_HEADER="${SOURCES_ROOT}/KBAutoFieldMacros.gen.h"
	if ! "${RM}" -f "${AUTOGEN_HEADER}" >/dev/null 2>&1; then
		header_dump=$(dump_var 'AUTOGEN_HEADER')
		print_warning "${header_dump}" 'cannot be removed'
	fi
	
#elif [ "${ACTION}" = 'action_name' ]; then
else # default action: build
	######################## BUILD ACTION ########################
	# Check config file; generate header

	# Checking config file
	if [ ! -f "${CONFIG_FILE}" ]; then
		# No custom config, use default example config
		if ! ( [ -f "${CONFIG_FILE_EXAMPLE}" ] && [ -r "${CONFIG_FILE_EXAMPLE}" ] ); then
			variable_error 'CONFIG_FILE_EXAMPLE' 'cannot be read'
		fi
		if ! "${CP}" "${CONFIG_FILE_EXAMPLE}" "${CONFIG_FILE}" >/dev/null 2>&1; then
			variables_error 2 'CONFIG_FILE_EXAMPLE' 'cannot be copied to' 'CONFIG_FILE'
		fi
	fi

	# Checking config file for full macros set & consistency
	CONFIG_ERRORS=$(check_config "${CONFIG_FILE}" | egrep '^\s*<stdin>:' | grep '#error' | sed -E 's/^.*#error[[:space:]]+//')
	if [ ! -z "${CONFIG_ERRORS}" ]; then
		variable_error 'CONFIG_FILE' 'is not valid config file.' 'Please correct the following errors:\n' "${CONFIG_ERRORS}"
	fi

	# Checking auto-generated header
	if ! [ -f "${AUTOGEN_HEADER}" ] || [ "${AUTOGEN_HEADER_GEN}" -nt "${AUTOGEN_HEADER}" ]; then
		# No auto-generated header or generating script update
		if [ ! -x "${AUTOGEN_HEADER_GEN}" ]; then
			variables_error 2 'AUTOGEN_HEADER_GEN' 'is not executable, cannot generate' 'AUTOGEN_HEADER'
		fi
		
		pushd "${SOURCES_ROOT}" >/dev/null 2>&1
		"${AUTOGEN_HEADER_GEN}" >/dev/null 2>&1
		result="$?"
		popd >/dev/null 2>&1
		if [ "$result" -ne 0 ]; then
			variables_error 2 'AUTOGEN_HEADER_GEN' 'failed to generate' 'AUTOGEN_HEADER'
		fi
	fi
	
	exit 0
fi
