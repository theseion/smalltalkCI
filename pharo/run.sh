################################################################################
# This file provides Pharo support for smalltalkCI. It is used in the context
# of a smalltalkCI build and it is not meant to be executed by itself.
################################################################################

readonly MOOSE_6_NAME="moose-6.0"
readonly MOOSE_6_DOWNLOAD="https://ci.inria.fr/moose/job/${MOOSE_6_NAME}/\
lastSuccessfulBuild/artifact/${MOOSE_6_NAME}.zip"

################################################################################
# Select Pharo image download url. Exit if smalltalk_name is unsupported.
# Arguments:
#   smalltalk_name
# Return:
#   Pharo image download url
################################################################################
pharo::get_image_url() {
  local smalltalk_name=$1

  case "${smalltalk_name}" in
    "Pharo-alpha")
      echo "get.pharo.org/alpha"
      ;;
    "Pharo-stable")
      echo "get.pharo.org/stable"
      ;;
    "Pharo-6.0")
      echo "get.pharo.org/60"
      ;;
    "Pharo-5.0")
      echo "get.pharo.org/50"
      ;;
    "Pharo-4.0")
      echo "get.pharo.org/40"
      ;;
    "Pharo-3.0")
      echo "get.pharo.org/30"
      ;;
    *)
      print_error_and_exit "Unsupported Pharo version '${smalltalk_name}'."
      ;;
  esac
}

################################################################################
# Select Pharo vm download url. Exit if smalltalk_name is unsupported.
# Arguments:
#   smalltalk_name
# Return:
#   Pharo vm download url
################################################################################
pharo::get_vm_url() {
  local smalltalk_name=$1

  case "${smalltalk_name}" in
    "Pharo-alpha"|"Pharo-6.0")
      echo "get.pharo.org/vm60"
      ;;
    "Pharo-stable"|"Pharo-5.0"|"Moose-6.0")
      echo "get.pharo.org/vm50"
      ;;
    "Pharo-4.0")
      echo "get.pharo.org/vm40"
      ;;
    "Pharo-3.0")
      echo "get.pharo.org/vm30"
      ;;
    *)
      print_error_and_exit "Unsupported Pharo version '${smalltalk_name}'."
      ;;
  esac
}

################################################################################
# Download and move vm if necessary.
# Globals:
#   SMALLTALK_CI_VM
# Arguments:
#   smalltalk_name
#   headful: 'true' for headful, 'false' for headless mode
################################################################################
pharo::prepare_vm() {
  local smalltalk_name=$1
  local headless=$2
  local pharo_vm_url="$(pharo::get_vm_url "${smalltalk_name}")"
  local pharo_vm_folder="${SMALLTALK_CI_VMS}/${smalltalk_name}"
  local pharo_zeroconf="${pharo_vm_folder}/zeroconfig"

  if ! is_dir "${pharo_vm_folder}"; then
    travis_fold start download_vm "Downloading ${smalltalk_name} vm..."
      timer_start

      mkdir "${pharo_vm_folder}"
      pushd "${pharo_vm_folder}" > /dev/null

      download_file "${pharo_vm_url}" "${pharo_zeroconf}"
      bash "${pharo_zeroconf}"

      popd > /dev/null

      timer_finish
    travis_fold end download_vm
  fi

  if [[ "${headless}" = "true" ]]; then
    echo "${pharo_vm_folder}/pharo \"\$@\"" > "${SMALLTALK_CI_VM}"
  else
    echo "${pharo_vm_folder}/pharo-ui \"\$@\"" > "${SMALLTALK_CI_VM}"
  fi
  chmod +x "${SMALLTALK_CI_VM}"

  if ! is_file "${SMALLTALK_CI_VM}"; then
    print_error_and_exit "Unable to set vm up at '${SMALLTALK_CI_VM}'."
  fi
}

################################################################################
# Download image if necessary and copy it to build folder.
# Globals:
#   SMALLTALK_CI_BUILD
#   SMALLTALK_CI_CACHE
# Arguments:
#   smalltalk_name
################################################################################
pharo::prepare_image() {
  local smalltalk_name=$1
  local pharo_image_url="$(pharo::get_image_url "${smalltalk_name}")"
  local pharo_image_file="${smalltalk_name}.image"
  local pharo_changes_file="${smalltalk_name}.changes"
  local pharo_zeroconf="${SMALLTALK_CI_CACHE}/${smalltalk_name}_zeroconfig"

  if ! is_file "${SMALLTALK_CI_CACHE}/${pharo_image_file}"; then
    travis_fold start download_image "Downloading ${smalltalk_name} image..."
      timer_start

      pushd "${SMALLTALK_CI_CACHE}" > /dev/null

      download_file "${pharo_image_url}" "${pharo_zeroconf}"
      bash "${pharo_zeroconf}"

      mv "Pharo.image" "${pharo_image_file}"
      mv "Pharo.changes" "${pharo_changes_file}"
      popd > /dev/null

      timer_finish
    travis_fold end download_image
  fi

  print_info "Preparing Pharo image..."
  cp "${SMALLTALK_CI_CACHE}/${pharo_image_file}" "${SMALLTALK_CI_IMAGE}"
  cp "${SMALLTALK_CI_CACHE}/${pharo_changes_file}" "${SMALLTALK_CI_CHANGES}"
}

################################################################################
# Download Moose image if necessary and extract it into build folder.
# Globals:
#   SMALLTALK_CI_BUILD
#   SMALLTALK_CI_CACHE
# Arguments:
#   smalltalk_name
################################################################################
pharo::prepare_moose_image() {
  local smalltalk_name=$1
  local pharo_image_url="${MOOSE_6_DOWNLOAD}"
  local moose_image_file="${MOOSE_6_NAME}.image"
  local moose_changes_file="${MOOSE_6_NAME}.changes"
  local target="${SMALLTALK_CI_CACHE}/${smalltalk_name}.zip"

  if ! is_file "${target}"; then
    travis_fold start download_image "Downloading ${smalltalk_name} image..."
      timer_start

      set +e
      download_file "${MOOSE_6_DOWNLOAD}" "${target}"
      if [[ ! $? -eq 0 ]]; then
        rm -f "${target}"
        print_error_and_exit "Download failed."
      fi
      set -e

      timer_finish
    travis_fold end download_image
  fi

  print_info "Extracting and preparing Moose image..."
  unzip -q "${target}" -d "${SMALLTALK_CI_BUILD}"
  mv "${SMALLTALK_CI_BUILD}/${moose_image_file}" "${SMALLTALK_CI_IMAGE}"
  mv "${SMALLTALK_CI_BUILD}/${moose_changes_file}" "${SMALLTALK_CI_CHANGES}"

  if ! is_file "${SMALLTALK_CI_IMAGE}"; then
    print_error_and_exit "Failed to prepare image at '${SMALLTALK_CI_IMAGE}'."
  fi
}

################################################################################
# Load project into Pharo image.
# Globals:
#   SMALLTALK_CI_HOME
#   SMALLTALK_CI_IMAGE
#   SMALLTALK_CI_VM
################################################################################
pharo::load_project() {
  local status=0

  travis_fold start load_project "Loading project..."
    timer_start

    travis_wait "${SMALLTALK_CI_VM}" "$(resolve_path ${SMALLTALK_CI_IMAGE})" \
        eval --save ${vm_flags} "
      [ Metacello new
          baseline: 'SmalltalkCI';
          repository: 'filetree://$(resolve_path "${SMALLTALK_CI_HOME}/repository")';
          onConflict: [:ex | ex pass];
          load ] on: Warning do: [:w | w resume ].
      (Smalltalk at: #SmalltalkCI) load: '$(resolve_path "${config_ston}")'
    " || status=$?

    timer_finish
  travis_fold end load_project

  if is_nonzero "${status}"; then
    print_error_and_exit "Failed to load project." ${status}
  fi
}

################################################################################
# Run tests for project.
# Globals:
#   SMALLTALK_CI_HOME
#   SMALLTALK_CI_IMAGE
#   SMALLTALK_CI_VM
################################################################################
pharo::test_project() {
  local status=0

  travis_fold start test_project "Testing project..."
    timer_start

    travis_wait "${SMALLTALK_CI_VM}" "$(resolve_path ${SMALLTALK_CI_IMAGE})" \
        eval ${vm_flags} "
      (Smalltalk at: #SmalltalkCI) test: '$(resolve_path "${config_ston}")'
    " || status=$?

    timer_finish
  travis_fold end test_project

  if is_nonzero "${status}"; then
    print_error_and_exit "Failed to test project." "${status}"
  fi
}

################################################################################
# Main entry point for Pharo builds.
################################################################################
run_build() {
  local vm_flags=""

  if ! is_travis_build && [[ "${config_headless}" != "true" ]]; then
    vm_flags="--no-quit"
  fi

  case "${config_smalltalk}" in
    Pharo*)
      pharo::prepare_image "${config_smalltalk}"
      ;;
    Moose*)
      pharo::prepare_moose_image "${config_smalltalk}"
      ;;
  esac

  pharo::prepare_vm "${config_smalltalk}" "${config_headless}"
  pharo::load_project
  pharo::test_project
}
